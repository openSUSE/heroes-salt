#!/usr/bin/perl
# Miscellaneous tests for our network segments.
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

use feature 'say';

use File::Find::Rule;
use YAML::XS 'LoadFile';
$YAML::XS::ForbidDuplicateKeys = 1;

my %Firewalls = (
  'prg2' => 'asgard',
  'slc1' => 'avalon',
);

my $nftbase = 'salt/files/nftables';
my $networks = LoadFile('pillar/infra/networks.yaml');
my @hvnw = File::Find::Rule->file()->name( 'network.sls' )->in( 'pillar/cluster' );

my $status = 0;
my $FAILPREFIX = "\e[31mFAIL\e[0m:";
my $WARNPREFIX = "\e[33mWARN\e[0m:";


sub recgrep {
    my ($string, @tree) = @_;
    my $found = 0;
    foreach my $file (@tree) {
      open my $fh, '<', $file
        or die "Could not open file $file: $!";
      while (<$fh>) {
        if (index($_, $string) > -1) {
          $found = 1;
          last;
        }
      }
      close $fh;
      if ($found == 1) {
        last;
      }
    }
    return $found;
}


foreach my $site (keys %{ $networks }) {
  next if ($site eq 'pseudo');

  if (! exists $Firewalls{$site}) {
    die "Unmapped site \"$site\", bailing out!"
  }

  my $firewall = $Firewalls{$site};
  my %siteshortnets;

  foreach my $network (keys %{ $networks->{$site} }) {
    # add VLAN short name => VLAN ID mapping to hash
    $siteshortnets{$networks->{$site}->{$network}->{'short'}} = $networks->{$site}->{$network}->{'id'};
  }

  my $sitechaindir = "$nftbase/$firewall/base_inet";
  my @sitechainnfts = File::Find::Rule->file()->name( '*put.nft' )->in( "$sitechaindir" );

  foreach my $shortnet (keys %siteshortnets) {
    my $id = $siteshortnets{$shortnet};
    print "Testing $site => $id $shortnet ...\n";

    my $nftzonefile = "$nftbase/$firewall/zones/${id}_$shortnet.nft";

    if (! -f $nftzonefile) {
      say "$FAILPREFIX Expected zone definition at $nftzonefile, but file does not exist.";
      $status = 1;
    }

    if (recgrep($shortnet, @sitechainnfts) == 0) {
      say "$FAILPREFIX Expected at least one chain connection for $shortnet, but none found in $sitechaindir.";
      $status = 1;
    }

    if (recgrep($shortnet, @hvnw) == 0) {
      say "$WARNPREFIX Expected at least one hypervisor connection for $shortnet, but none found in cluster network pillars.";
      # TODO: clean up / finish networks with loose ends
      #$status = 1;
    }
  }
}

exit $status;
