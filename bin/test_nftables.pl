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

if (! ($ENV{container} || $ENV{TEST_NFT_REALLY})) {
  die "You probably want to run this inside a test container and not on your real system.\n";
}
if ( $> != 0 ) {
  die "Needs to run with root privileges.\n";
}

use File::Find::Rule;
use File::Copy::Recursive 'dircopy';
use File::Path 'rmtree';

my $debug = $ENV{TEST_NFT_DEBUG};
my $indir = $ENV{TEST_NFT_INDIR};
if (! $indir) {
  $indir = 'salt/files/nftables'
}
my $workdir = '/etc/nftables.d';

my @directories = File::Find::Rule->mindepth(1)->maxdepth(1)->directory->in( $indir );
my $exit = 0;

foreach (@directories) {
  my $tree = $_;
  my %interfaces;
  my $treestatus = 0;
  print "Analyzing nftables tree \"$tree\" ...\n";
  rmtree($workdir);
  dircopy($tree, $workdir);
  my @files = File::Find::Rule->file()->name( '*.nft' )->in( $workdir );
  if (!@files) {
    print "Directory $tree does not contain any .nft files, skipping!\n";
    $exit = 1;
    next;
  }
  foreach (@files) {
    my $file = $_;
    open(fh, '<', $file);
    my $next_line_interesting = 0;
    while (<fh>) {
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
      if ( $_ =~ /^\s*include "(.*)"$/ ) {
        my $include = $1;
        if ($debug) {
          print "Analyzing include $include ...\n";
        }
        if (index($include, '*') == -1) {
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
        if ( $interface == 'vmap' ) {
          $next_line_interesting = 1;
          if ($debug) {
            print "Starting to analyze vmap in $file\n";
          }
          next;
        }
      }
      if ($interface) {
        if ($debug) {
          print "Found $interface in $file\n";
        }
        $interfaces{$interface} = ();
      }
    }
    close(fh);
  }

  foreach my $interface (keys %interfaces) {
    if ($debug) {
      print "Creating dummy interface: $interface\n";
    }
    system( ip => l => a => $interface => type => 'dummy' );
  }
  
  my $return = system( nft => -c => "flush ruleset ; include \"$workdir/*.nft\"" );
  my $msg = "nftables tree \"$tree\" is";
  if ($return == 0 && $treestatus == 0) {
    print "\e[32mPASSED\e[0m: $msg valid.\n";
  } else {
    print "\e[31mFAILED\e[0m: $msg is invalid.\n";
    $exit = 1;
  }

  foreach my $interface (keys %interfaces) {
    if ($debug) {
      print "Deleting dummy interface: $interface\n";
    }
    system( ip => l => d => $interface );
  }
}

exit $exit;
