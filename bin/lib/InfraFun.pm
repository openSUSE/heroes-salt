# Useful functions shared between our Perl based test scripts.
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

package InfraFun;

use v5.26;  # Leap 15.6
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(
	recgrep
);

# "grep -r" equivalent
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
