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


use DBI;
use SL::User;
use SL::Form;


$form = new Form;

$locale = new Locale $language, "login";

# customization
if (-f "$form->{path}/custom_$form->{script}") {
  eval { require "$form->{path}/custom_$form->{script}"; };
  $form->error($@) if ($@);
}

# per login customization
if (-f "$form->{path}/$form->{login}_$form->{script}") {
  eval { require "$form->{path}/$form->{login}_$form->{script}"; };
  $form->error($@) if ($@);
}

# window title bar, user info
$form->{titlebar} = "Unternehmer ".$locale->text('Version'). " $form->{version}";

if ($form->{action}) {
  $form->{titlebar} .= " - $myconfig{name} - $myconfig{dbname}";
  &{ $locale->findsub($form->{action}) };
} else {
  &login_screen;
}


1;


sub login_screen {
  
  if (-f "css/unternehmer.css") {
    $form->{stylesheet} = "unternehmer.css";
  }
  
  $form->{fokus} = "loginscreen.login";
  $form->header;

  print qq|


<body class=login onLoad="fokus()">

<pre>

</pre>

<center>
<table class=login border=3 cellpadding=20>
  <tr>
    <td class=login align=center><a href="http://unternehmer.berlios.de" target=_top><img src="image/unternehmer.png" border=0></a>
<h1 class=login align=center>|.$locale->text('Version').qq| $form->{version}
</h1>

<p>

<form method=post name=loginscreen action=$form->{script}>

      <table width=100%>
	<tr>
	  <td align=center>
	    <table>
	      <tr>
		<th align=right>|.$locale->text('Name').qq|</th>
		<td><input class=login name=login size=30 tabindex="1"></td>
	      </tr> 
	      <tr>
		<th align=right>|.$locale->text('Password').qq|</th>
		<td><input class=login type=password name=password size=30 tabindex="2"></td>
	      </tr>
	      <input type=hidden name=path value=$form->{path}>
	    </table>

	    <br>
	    <input type=submit name=action value="|.$locale->text('Login').qq|">

	  </td>
	</tr>
      </table>

</form>

    </td>
  </tr>
</table>
  
</body>
</html>
|;

}


sub login {

  $form->error($locale->text('You did not enter a name!')) unless ($form->{login});

  $user = new User $memberfile, $form->{login};

  # if we get an error back, bale out
  if (($errno = $user->login(\%$form, $userspath)) <= -1) {
    $errno *= -1;
    $err[1] = $err[3] = $locale->text('Incorrect username or password!');
    
    if ($errno == 2) {
      # upgraded dataset, login again
      $form->redirect("<a href=menu.pl?login=$form->{login}&password=$form->{password}&path=$form->{path}&action=display>Continue</a>");
      exit;
    }
    
    $form->error($err[$errno]);
  }
  
  # made it this far, execute the menu
  $form->{callback} = "menu.pl?login=$form->{login}&password=$form->{password}&path=$form->{path}&action=display";

  $form->redirect;
  
}



sub logout {

  unlink "$userspath/$form->{login}.conf";
  
  # remove the callback to display the message
  $form->{callback} = "login.pl?path=$form->{path}&action=&login=";
  $form->redirect($locale->text('You are logged out!'));

}


    
sub company_logo {
  
  require "$userspath/$form->{login}.conf";
  $locale = new Locale $myconfig{countrycode}, "login" unless ($language eq $myconfig{countrycode});

  $myconfig{address} =~ s/\\n/<br>/g;
  $myconfig{dbhost} = $locale->text('localhost') unless $myconfig{dbhost};

  map { $form->{$_} = $myconfig{$_} } qw(charset stylesheet);
  
  $form->{title} = $locale->text('About');
  
 
  # create the logo screen
  $form->header unless $form->{noheader};

  print qq|
<body>
<center>
<a href="http://unternehmer.berlios.de" target=_top><img src="image/unternehmer.png" border=0></a>
<h2 class=login>|.$locale->text('Version').qq| $form->{version}</h2>

|.$locale->text('Free and Open-Source Software').qq|
<p>
<b>
$myconfig{company}
<br>$myconfig{address}
</b>


<br>
<table border=0>
  <tr>
    <th align=left>|.$locale->text('User').qq|</th>
    <td>$myconfig{name}</td>
  </tr>
  <tr>
    <th align=left>|.$locale->text('Dataset').qq|</th>
    <td>$myconfig{dbname}</td>
  </tr>
  <tr>
    <th align=left>|.$locale->text('Database Host').qq|</th>
    <td>$myconfig{dbhost}</td>
  </tr>
  <tr>
  </tr>
  <tr>
  </tr>
  <tr>
    <th colspan="2" align="center"><a href="http://unternehmer.berlios.de" target="blank">http://unternehmer.berlios.de</a></th>
  </tr>
  <tr>
    <th colspan="2" align="center"><a href="mailto:flo_k&#064;users.berlios.de" target="blank">flo_k&#064;users.berlios.de</a></th>
  </tr>
</table>

</center>

</body>
</html>
|;

}



