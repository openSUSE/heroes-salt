#!/usr/bin/perl
# Script to test our nftables configuration files.
#
# Reads a tree of *.nft files from TEST_NFT_INDIR (default: ./salt/files/nftables),
# creates dummy interfaces to satisfy iif/oif, and executes a nftables config test.
# Set TEST_NFT_DEBUG=1 to enable verbose output.
#
# Careful, this will overwrite /etc/nftables.d and hence refuse to run outside
# a container unless TEST_NFT_REALLY is set.
# This is necessary as our nftables snippets tend to use absolute include paths.
#
# Recommended base container image (large sets might require privileged operation):
# registry.opensuse.org/opensuse/infrastructure/containers/heroes-salt-testing-nftables
#
# Copyright (C) 2024 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use v5.26;  # Leap 15.5
use warnings;

if (! ($ENV{container} || $ENV{TEST_NFT_REALLY})) {
  die "You probably want to run this inside a test container and not on your real system.\n";
}
if ( $> != 0 ) {
  die "Needs to run with root privileges.\n";
}

use Archive::Tar;
use File::Basename;
use File::Find::Rule;
use File::Copy 'cp';
use File::Copy::Recursive 'dircopy';
use File::Path qw(make_path rmtree);
use Inline 'Python';

my $debug = $ENV{TEST_NFT_DEBUG};
my $dumpif = $ENV{TEST_NFT_DUMP_INTERFACES};
my $dumpnft = $ENV{TEST_NFT_DUMP_NFT};
my $indir = $ENV{TEST_NFT_INDIR};
my $renderdir = $ENV{TEST_NFT_RENDERDIR};

if (! $indir) {
  $indir = 'salt/files/nftables'
}

if (! $renderdir) {
  $renderdir = 'salt/files_rendered/nftables'
}

if (-d $renderdir) {
  rmtree($renderdir)
}
make_path($renderdir)
  or die "Cannot create render directory at $renderdir: $!";

my $workdir = '/etc/nftables.d';

my @directories = File::Find::Rule->mindepth(1)->maxdepth(1)->directory->in( $indir );
my $exit = 0;

sub render_tree {
  my $intree = $_[0];
  my @indirs = File::Find::Rule->directory->in( $intree );
  for (@indirs) {
    my $outdir = $_ =~ s/$indir/$renderdir/r;
    mkdir($outdir)
      or die "Cannot create render directory at $outdir: $!";
  }
  my @infiles = File::Find::Rule->file()->name( qr/.*\.nft(?:\.j2)?/ )->in( $intree );
  if (!@infiles) {
    print "Directory $intree does not contain any .nft or .nft.j2 files!\n";
    return;
  }
  for (@infiles) {
    my $infile = $_;
    my ($outfile, $outpath, $suffix) = fileparse($infile, '.j2');
    $outpath =~ s/$indir/$renderdir/;
    $outfile = $outpath . $outfile;
    if ($suffix eq '.j2') {
      open(FH, '>', $outfile)
        or die "Cannot write file $outfile: $!";
      print FH render_file($infile);
      close(FH);
    } else {
      cp($infile, $outfile)
        or die "Cannot copy file $outfile: $!";
    }
 }
}

foreach (@directories) {
  my $tree = $_;
  my %interfaces;
  my %groups;
  my $treestatus = 0;
  print "Analyzing nftables tree \"$tree\" ...\n";
  rmtree($workdir);
  render_tree($tree);
  $tree =~ s/$indir/$renderdir/;
  dircopy($tree, $workdir);
  my @files = File::Find::Rule->file()->name( '*.nft' )->in( $workdir );
  if (!@files) {
    $exit = 1;
    next;
  }

  my $treebase = basename($tree);

  if ($dumpnft) {
    my $tar = Archive::Tar->new();
    $tar->add_files(@files);
    $tar->write("$treebase.tar.gz", 5);
  }

  foreach (@files) {
    my $file = $_;
    open(FH, '<', $file);
    my $next_line_interesting = 0;
    while (<FH>) {
      chomp;
      if ( $_ =~ /^\s*#/ ) {
        next;
      }
      if ( $_ =~ /[\s\t]+$/ ) {
        print "Trailing spaces or tabs in $file, line $..\n";
        $treestatus = 1;
        next;
      }
      my $interface;
      my $group;
      if ( $_ =~ /^\s*include "(.*)"$/ ) {
        my $include = $1;
        if ($debug) {
          print "Analyzing include $include ...\n";
        }
        if (index($include, '*') != -1) {
          if (! ( () = glob($include) ) ) {
            print "No files match include \"$include\" in $file.\n";
            $treestatus = 1;
          }
        } elsif (! -e $include) {
          print "Included file \"$include\" in $file does not exist!\n";
          $treestatus = 1;
        }
      } elsif ($next_line_interesting) {
        if ( $_ =~ /^\s*([\w-]+)\s+:/ ) {
          $interface = $1;
        } elsif ( $_ =~ /^\s*}/) {
          $next_line_interesting = 0;
          if ($debug) {
            print "Found end of vmap in $file\n";
          }
        }
      } elsif ( $_ =~ /([io]if)(?: !?=?)? (?!lo)([\w-]+)/ ) {
        $interface = $2;
        if ( $interface eq 'vmap' ) {
          $next_line_interesting = 1;
          if ($debug) {
            print "Starting to analyze vmap in $file\n";
          }
          next;
        }
        # meta skgid != { foo, bar, ... }
        # meta skgid foo
      } elsif ( $_ =~ /meta skgid (?:!= )?(?:\{ )?((?:[\w]+(?:, )?)+)(?: \})? / ) {
        $group = $1;
      }

      if ($interface) {
        if ($debug) {
          print "Found interface $interface in $file\n";
        }
        $interfaces{$interface} = ();
      }

      if ($group) {
        if ($debug) {
          print "Found group(s) $group in $file\n";
        }
        if (index($group, ',') == -1) {
          $groups{$group} = ();
        } else {
          foreach my $group (split(', ', $group)) {
            $groups{$group} = ();
          }
        }
      }

    }
    close(FH);
  }

  foreach my $interface (keys %interfaces) {
    if ($debug) {
      print "Creating dummy interface: $interface\n";
    }
    system( ip => l => a => $interface => type => 'dummy' );
  }

  foreach my $group (keys %groups) {
    if ($debug) {
      print "Creating group: $group\n";
    }
    system( "getent group $group >/dev/null || groupadd $group" );
  }

  my $return = system( nft => -c => "flush ruleset ; include \"$workdir/*.nft\"" );
  my $msg = "nftables tree \"$tree\" is";
  if ($return == 0 && $treestatus == 0) {
    print "\e[32mPASSED\e[0m: $msg valid.\n";
  } else {
    print "\e[31mFAILED\e[0m: $msg is invalid.\n";
    $exit = 1;
  }

  my $ifout = $treebase . '.interfaces';
  if ($dumpif) {
    if ($debug) {
      print "Writing interfaces to $ifout\n";
    }
    open(IFH, '>', $ifout);
  }
  foreach my $interface (keys %interfaces) {
    if ($debug) {
      print "Deleting dummy interface: $interface\n";
    }
    system( ip => l => d => $interface );
    if ($dumpif) {
      print IFH "$interface\n";
    }
  }
  if ($dumpif) {
    close(IFH);
  }
}

exit $exit;

__END__
__Python__
from jinja2 import Template

def render_file(path):
  if path is None:
    return
  with open(path) as file:
    return Template(file.read()).render()
