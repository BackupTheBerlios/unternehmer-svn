#=====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#
######################################################################
# SQL-Ledger Accounting
# Copyright (c) 1998-2002
#
#  Author: Dieter Simader
#   Email: dsimader@sql-ledger.org
#     Web: http://www.sql-ledger.org
#
#  Contributors: Christopher Browne
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#######################################################################
#
# thre frame layout with refractured menu
#
# CHANGE LOG:
#   DS. 2002-03-25  Created
#  2004-12-14 - New Optik - Marco Welter <mawe@linux-studio.de>
#######################################################################

$menufile = "menu.ini";
use SL::Menu;

1;
# end of main

  $framesize = ($ENV{HTTP_USER_AGENT} =~ /links/i) ? "240" : "190"; 

sub display {

  $form->header;

  print qq|
<frameset rows="20px,*" cols="*" framespacing="0" frameborder="0">
  <frame  src="kopf.pl?login=$form->{login}&password=$form->{password}&path=$form->{path}" name="kopf"  scrolling="NO">
  <frameset cols="$framesize,*" framespacing="0" frameborder="0" border="0" >
    <frame src="$form->{script}?login=$form->{login}&password=$form->{password}&action=acc_menu&path=$form->{path}" name="acc_menu"  scrolling="auto" noresize marginwidth="0">
    <frame src="login.pl?login=$form->{login}&password=$form->{password}&action=company_logo&path=$form->{path}" name="main_window" scrolling="auto">
  </frameset>
  <noframes>
  You need a browser that can read frames to see this page.
  </noframes>
</frameset>
</HTML>
|;

}



sub acc_menu {
  $mainlevel=$form->{level};
  $mainlevel =~ s/$mainlevel--//g;
  my $menu = new Menu "$menufile";
  $menu = new Menu "custom_$menufile" if (-f "custom_$menufile");
  $menu = new Menu "$form->{login}_$menufile" if (-f "$form->{login}_$menufile");

  $form->{title} = $locale->text('Accounting Menu');

  $form->header;

  print qq|
<body class="menu">

|;
  print qq|<div align="left">\n<table width="|.$framesize.qq|" border=0>\n|;

  &section_menu($menu);

  print qq|</table></div>|;
  print qq|
</body>
</html>
|;

}


sub section_menu {
	my ($menu, $level) = @_;
	# build tiered menus
	my @menuorder = $menu->access_control(\%myconfig, $level);
	while (@menuorder) {
		$item = shift @menuorder;
		$label = $item;
		$ml = $item;
		$label =~ s/$level--//g;
		$ml=~ s/--.*//;
		if ($ml eq $mainlevel) { $zeige=1; } else { $zeige=0; };
		my $spacer = "&nbsp;" x (($item =~ s/--/--/g) * 1);
		$label =~ s/.*--//g;
		$label_icon = $label.".gif";
		$mlab = $label;
		$label = $locale->text($label);
		$label =~ s/ /&nbsp;/g;
		$menu->{$item}{target} = "main_window" unless $menu->{$item}{target};
		if ($menu->{$item}{submenu}) {
			$menu->{$item}{$item} = !$form->{$item};
			if ($form->{level} && $item =~ /^$form->{level}/) {
				# expand menu
				if ($zeige) { print qq|<tr><td valign=bottom><b>$spacer<img src="image/unterpunkt.png">$label</b></td></tr>\n|;}
				# remove same level items
				map { shift @menuorder } grep /^$item/, @menuorder;
				&section_menu($menu, $item);
			} else {
				if ($zeige) { print qq|<tr><td>|.$menu->menuitem(\%myconfig, \%$form, $item, $level).qq|$label&nbsp;...</a></td></tr>\n|;}
				# remove same level items
				map { shift @menuorder } grep /^$item/, @menuorder;
			}
		} else {
			if ($menu->{$item}{module}) {
				if ($form->{$item} && $form->{level} eq $item) {
					$menu->{$item}{$item} = !$form->{$item};
					if ($zeige) { print qq|<tr><td valign=bottom>$spacer<img src="image/unterpunkt.png">|.$menu->menuitem(\%myconfig, \%$form, $item, $level).qq|$label</a></td></tr>\n|;}
					# remove same level items
					map { shift @menuorder } grep /^$item/, @menuorder;
					&section_menu($menu, $item);
				} else {
					if ($zeige) {
						print qq|<tr><td class="hover" height="13" >$spacer<img src="image/unterpunkt.png"  style="vertical-align:text-top">|.$menu->menuitem(\%myconfig, \%$form, $item, $level).qq|$label</a></td></tr>\n|;
					}
				}
			} else {
				my $ml_ = $form->escape($ml);			
				print qq|<tr><td class="bg" height="22" align="left" valign="middle" ><img src="image/$item.png" style="vertical-align:middle">&nbsp;<a href="menu.pl?path=bin/mozilla&action=acc_menu&level=$ml_&login=$form->{login}&password=$form->{password}" class="nohover">$label</a>&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>\n|;
				&section_menu($menu, $item);
				#print qq|<br>\n|;
			}
		}
	}
}
