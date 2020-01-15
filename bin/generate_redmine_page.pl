#!/usr/bin/perl -w
#
# Copyright Lars Vogdt <lars@linux-schulserver.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street,
# Fifth Floor,
# Boston, MA  02110-1301,
# USA.
#
use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use Getopt::Long;
use Scalar::Util qw(reftype);
use YAML::Tiny;

my $pillar_id_path='pillar/id';
my @wanted=qw(aliases responsible virt_cluster weburls hostusage partners description documentation);
my $print_help='';
my $full_html='';
my $dumpforredmine='';
my $header='';
my $footer='';
my $table_style="width='1820' border='1' style='table-layout:fixed;'";
my $td_style="style='word-wrap:break-word; padding-left:.5em'";
my $td_color_even='#f6f6f6';
my $td_color_odd='fcf8e3';
my $freeipa_user_url='https://freeipa.infra.opensuse.org/ipa/ui/#/e/user/details';

sub getFiles($$) {
    my $path=shift;
    my $ending=shift;
    opendir(DIR,"$path") || die ("Could not open $path: $! $?!\n");
    my @Files= grep {/.*\Q$ending\E/} readdir(DIR);
    closedir(DIR);
    my $number = @Files;
    if ( $number gt 0 ){
      my @return;
      foreach (@Files){
        next if ( $_ eq "." );
        next if ( $_ eq ".." );
        push @return,$_;
      }
     return \@return;
    }
 return 0;
}

sub usage($){
    my $exitcode=shift || 1;
    print <<EOF

$0 Usage Information:

 $0 [OPTION]

 -d <path> | --pillardir <path>  : Path to the files with the Pillar information.
 -t        | --tableonly         : Print only the HTML table (for inclusion in Redmine).

 -r        | --dumpforredmine    : Print including a short manual for direct copy and past into the Redmine wiki.
 -h        | --help              : This help

Use this script to generate a HTML page (or just a HTML table), based on the 
static pillar information provided in YAML files.
Currently the list of tags that end up in the HTML is hardcoded in the script. If you 
want to change it, please edit the line starting with 
  my \@wanted=...


EOF
;

   exit $exitcode;
}

my $redmine_header="
Machines
========

This is a placeholder for some wiki pages containing more details about machines and their setups. The list below is generated based on the [pillar/id](https://gitlab.infra.opensuse.org/infra/salt/tree/production/pillar/id) information in [our Salt Repo in Gitlab](https://gitlab.infra.opensuse.org/).

You need a GIT checkout of the repository and the following perl modules installed on your system:

```bash
  sudo zypper in 'perl(File::Basename)' 'perl(Getopt::Long)' 'perl(Scalar::Util)' 'perl(YAML::Tiny)'
```

After that you should be able to call the script from the root of the checked out Salt repository:

```bash
  bin/generate_redmine_page.pl -t
```

* If you are administrator of a machine, please keep the information of the machine in GIT up to date, so others might be able to step in if there is a problem with the machine and you are not available.
* If you are 'just interested' or needed to fix something on the machine, please get in contact with the administrator mentioned

List of machines
================
";

Getopt::Long::Configure('bundling');

GetOptions(    
    'h|help'            => \$print_help,
    'd|pillardir=s'     => \$pillar_id_path,
    'r|dumpforredmine'  => \$dumpforredmine,
    't|tableonly'       => \$full_html,
);

usage(0) if ($print_help);



my $sls_files=getFiles($pillar_id_path,'.sls');

if (! $full_html){
$header="<!doctype hmtl>
<html>
  <head>
    <meta charset='utf-8'>
    <title>Machine list</title>
    <style type='text/css' media='print'>
      \@page
      {
          size: auto; /* auto is the initial value */
          margin: 2mm 4mm 2mm 4mm; /* this affects the margin in the printer settings */
      }
	  thead {display: table-header-group;}
    </style>
	<style type='text/css' media='screen'>
      /* thead { display: block; } */
      ul { list-style-type: disc; 
           padding-left:1.5em; }
    </style>
  </head>
  <body>\n";
$footer="  </body>
</html>";
}

if (! $dumpforredmine){
	print "$header";
}

my $javascript="
<script>
function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById('machines');
  switching = true;
  // Set the sorting direction to ascending:
  dir = 'asc';
  /* Make a loop that will continue until
  no switching has been done: */
  while (switching) {
    // Start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /* Loop through all table rows (except the
    first, which contains table headers): */
    for (i = 1; i < (rows.length - 1); i++) {
      // Start by saying there should be no switching:
      shouldSwitch = false;
      /* Get the two elements you want to compare,
      one from current row and one from the next: */
      x = rows[i].getElementsByTagName('TD')[n];
      y = rows[i + 1].getElementsByTagName('TD')[n];
      /* Check if the two rows should switch place,
      based on the direction, asc or desc: */
      if (dir == 'asc') {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      } else if (dir == 'desc') {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          // If so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /* If a switch has been marked, make the switch
      and mark that a switch has been done: */
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      // Each time a switch is done, increase this count by 1:
      switchcount ++;
    } else {
      /* If no switching has been done AND the direction is asc,
      set the direction to desc and run the while loop again. */
      if (switchcount == 0 && dir == 'asc') {
        dir = 'desc';
        switching = true;
      }
    }
  }
}
</script>";

if ( "$sls_files" ne "0" ){
    my $i=1;
	if ( $dumpforredmine ){
		print "$redmine_header\n";	
	}
	print "$javascript\n";
    print "<table id='machines' $table_style>\n";
	print "<thead>\n";
	print "<tr bgcolor='#e5e5e5'>";
	print "<th onclick='sortTable(0)' $td_style width='30px'><center><strong>#</strong></center></th>\n";
	print "<th onclick='sortTable(1)' $td_style width='220px'><center><strong>Hostname</strong></center></th>\n";
	my $td=1;
    foreach my $entry (sort(@wanted)){
		my $width='';
		if ("$entry" =~ m/responsible/){
			$width="width='150px'";
		}
		if ("$entry" =~ m/virt_cluster/){
            $width="width='50px'";
        }
		$td++;
	    print "<th onclick='sortTable($td)' $td_style $width><strong>$entry</strong></th>\n";
    }
    print "</tr>\n";
    print "</thead>\n";

    for my $file (sort (@$sls_files)){
	my $bgcolor="bgcolor='$td_color_odd'";
	if ($i % 2){
		$bgcolor="bgcolor='$td_color_even'";
	}
	print "<tr $bgcolor>";
	my $hostname=basename("$file",'.sls');
	$hostname=~ s/_/./g;
   	print "<td $td_style>$i</td><td $td_style><p id='$hostname'>$hostname</p></td>\n";
	my $yaml = YAML::Tiny->read("$pillar_id_path/$file");
	my $grains=$yaml->[0];
	# print Data::Dumper->Dump([$grains])."\n";
	foreach my $entry (sort(@wanted)){
		print "<td $td_style>";
		if (defined($grains->{'grains'}->{$entry})){
			my $type=reftype $grains->{'grains'}->{$entry};
			if (defined($type) && "$type" eq 'ARRAY'){
				if (@{$grains->{'grains'}->{$entry}} > 0){
					print "<ul style='padding-left:1.5em'>\n";
					foreach my $string (sort(@{$grains->{'grains'}->{$entry}})){
						if ("$string" =~ m/^http.*/){
							print "<li><a href='$string'>$string</a></li>";
						} 
						else {
							if ("$entry" eq "partners"){
								print "<li><a href='#$string'>$string</a></li>\n";
							}
							elsif ("$entry" eq "responsible"){
								print "<li><a href='$freeipa_user_url/$string'>$string</a></li>\n";
							}
							else {
								print "<li>$string</li>\n";
							}
						}
					}
					print "</ul>\n";
				}
			}
			else {
				print "$grains->{'grains'}->{$entry}" if ($grains->{'grains'}->{$entry} ne "");
			}
		}
		else {
			print "&nbsp;";
		}
		print "</td>\n";
	}
	print "</tr>\n";
	$i++;
    }
    print "</table>\n";
}
print "$footer";

