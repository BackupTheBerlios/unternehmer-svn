#!/bin/perl
#=====================================================================
# Lx-Office ERP
# Copyright (c) 2004 by Udo Spallek, Aachen
#
#  Author: Udo Spallek
#   Email: udono@gmx.net
#     Web: http://www.lx-office.org
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
#======================================================================
# German Tax authority Module and later ELSTER Interface
#======================================================================

require "$form->{path}/arap.pl";


#use strict; 
#no strict 'refs';
#use diagnostics;
#use warnings FATAL=> 'all';
#use vars qw($locale $form %myconfig);
#our ($myconfig);
#use CGI::Carp "fatalsToBrowser";

use SL::PE;
use SL::RP;
use SL::USTVA;
use SL::User;
1;

# this is for our long dates
# $locale->text('January')
# $locale->text('February')
# $locale->text('March')
# $locale->text('April')
# $locale->text('May ')
# $locale->text('June')
# $locale->text('July')
# $locale->text('August')
# $locale->text('September')
# $locale->text('October')
# $locale->text('November')
# $locale->text('December')

# this is for our short month
# $locale->text('Jan')
# $locale->text('Feb')
# $locale->text('Mar')
# $locale->text('Apr')
# $locale->text('May')
# $locale->text('Jun')
# $locale->text('Jul')
# $locale->text('Aug')
# $locale->text('Sep')
# $locale->text('Oct')
# $locale->text('Nov')
# $locale->text('Dec')
#############################

sub report {
  my $myconfig = \%myconfig;
  use CGI;
  $form->{title} = $locale->text('UStVA');
  $form->{kz10}='' ; #Berichtigte Anmeldung? Ja =1 
#  $accrual = ($eur) ? "" : "checked";
#  $cash = ($eur) ? "checked" : "";
  my $year = '';
  my $null = '';
  ($null,$null,$null,$null,$null,$year,$null,$null,$null) = localtime();
  $year += 1900;
  
  my $department = '';
  local $hide ='';  
  $form->header;
 
  print qq|
<body>

<form method=post action=$form->{script}>

<input type=hidden name=title value="$form->{title}">

<table width=100%>
  <tr>
    <th class=listtop>$form->{title}</th>
  </tr>
  <tr height="5"></tr>
  <tr>
    <td>
      <table>
      $department
|;
  # Hier Aufruf von get_config aus bin/mozilla/fa.pl zum 
  # Einlesen der Finanzamtdaten
  &get_config($userspath, 'finanzamt.ini');
  
  my @a = qw(signature name company address businessnumber tel fax email
          company_street company_city company_email);
  map { $form->{$_} = $myconfig->{$_} } @a;
  
  my $oeffnungszeiten = $form->{FA_Oeffnungszeiten} ;
  $oeffnungszeiten =~ s/\\\\n/<br>/g;  
  print qq|
	<tr >
	  <td width="50%" align="left" valign="top">
	  <fieldset>
	  <legend>
	  <b>|.$locale->text('Firma').qq|</b>
	  </legend>
  |;
  if ( $form->{company} ne '' ){
    print qq|<h3>$form->{company}</h3>\n|;
  } else 
  {
    print qq|
	    <a href=am.pl?path=$form->{path}&action=config&level=Programm--Preferences&login=$form->{login}&password=$form->{password}>
	    |.$locale->text('Kein Firmenname hinterlegt!').qq|</a><br>
    |;
  }
  
  #kl�ren, ob $form->{company_street|_address} gesetzt sind
  ###
  if ( $form->{address} ne '' ) {
        my $temp = $form->{address};
        $temp =~ s/\\n/<br \/>/;
        print qq|$temp|;
        ($form->{company_street}, $form->{company_city}) = split("<br \/", $temp);
    } elsif ($form->{address} eq '' and ($form->{company_street} ne '' and $form->{company_city} ne '' ) ) {
              print qq|$form->{company_street}<br>\n| if ($form->{company_street} ne '');
              print qq|$form->{company_city}\n| if ($form->{company_city} ne '');
    } elsif ($form->{company_street} eq '' or $form->{company_city} eq '') {
          print qq|
	  <a href=am.pl?path=$form->{path}&action=config&level=Programm--Preferences&login=$form->{login}&password=$form->{password}>
	  |.$locale->text('Keine Firmenadresse hinterlegt!').qq|</a>\n|;
    }
  
  print qq|
	  <br>
	  <br>
	  |.$locale->text('Tel.: ').qq|
	  $form->{tel}
	  <br>
	  |.$locale->text('Fax.: ').qq|
	  $form->{fax}	  
	  <br>
	  <br>
	  $form->{email}	  
	  <br>
	  <br>
	  |.$locale->text('Steuernummer: ').qq|
  |;
	  
  if ($form->{steuernummer} ne ''){
    print qq|$form->{steuernummer}|;
  } else {
    print qq|
	  <a href="ustva.pl?path=$form->{path}&action=edit&level=Programm--Finanzamteinstellungen&login=$form->{login}&password=$form->{password}">
	  Keine Steuernummer hinterlegt!</a><br>|;
  }
  print qq|
	  <!--<br>
	  |.$locale->text('ELSTER-Steuernummer: ').qq|
	  $form->{elstersteuernummer}
          <br>-->
          <br>

	  </fieldset>
	  <br>
  |;
  if ($form->{FA_steuerberater_name} ne ''){
    print qq|
	  <fieldset>
	  <legend>
            <input checked="checked" title="|.$locale->text('Beraterdaten in UStVA �bernehmen?').qq|" name="FA_steuerberater" id=steuerberater class=checkbox type=checkbox value="1">&nbsp;
            <b>|.$locale->text('Steuerberater/-in').qq|</b>
            </legend>
            
            $form->{FA_steuerberater_name}<br>
            $form->{FA_steuerberater_street}<br>
            $form->{FA_steuerberater_city}<br>
            Tel: $form->{FA_steuerberater_tel}<br>
	  </fieldset>
	  <br>
    |;
  }
  print qq|
	  <fieldset>
	  <legend>
          <b>|.$locale->text('Voranmeldezeitraum').qq|</b>
	  </legend>
  |;
  &ustva_vorauswahl();
          
  my @years = ();        
  if ( not defined $form->{all_years} ) {
    # accounting years if SQL-Ledger Version < 2.4.1
#    $year = $form->{year} * 1;
    @years = sort {$b <=> $a} (2000..($year));
    $form->{all_years} = \@years;
  }
  map { $form->{selectaccountingyear} .= qq|<option>$_\n| } @{ $form->{all_years} };
  print qq|
          <select name=year title="|.$locale->text('Year').qq|">
  |;
  my $key = '';
  foreach $key ( @years ){
    print qq|<option |;
    print qq|selected| if ($key eq $form->{year});
    print qq| >$key</option>
    |;
  }
 
  
  my $voranmeld = $form->{FA_voranmeld};
  print qq|             </select>|;
  my $checked = '';
  $checked = "checked" if ( $form->{kz10} eq '1' );
  print qq|
           <input name="FA_10" id=FA_10 class=checkbox type=checkbox value="1" $checked title = "|.$locale->text('Ist dies eine berichtigte Anmeldung? (Nr. 10/Zeile 15 Steuererkl�rung)').qq|">
            |.$locale->text('Berichtigte Anmeldung').qq|
          <br>
  |;
  if ($voranmeld ne ''){
  print qq|
          <br>
          |.$locale->text($voranmeld).qq|
  |;
  print qq| mit Dauerfristverl�ngerung| if ( $form->{FA_dauerfrist} eq '1');
  print qq|

      <br>
  |;
  }
  if ($form->{method} ne '' ){
    print qq||.$locale->text('Method').qq|: |;
    print qq||.$locale->text('accrual').qq|| if ($form->{method} eq 'accrual');
    print qq||.$locale->text('cash').qq|| if ($form->{method} eq 'cash');
  }
  print qq|
	  </fieldset>

    </td>|;
    
  if ($form->{FA_Name} ne ''){  
    print qq|
    <td width="50%" valign="top">	  
	  <fieldset>
	  <legend>
	  <b>|.$locale->text('Finanzamt').qq|</b>
	  </legend>
          <h3>$form->{FA_Name}</h2>
    |;
          
    #if ($form->{FA_Ergaenzung_Name ne ''}){
    #  print qq|
    #          $form->{FA_Ergaenzung_Name}&nbsp
    #          <br>
    #  |;
    #}
    print qq|
          $form->{FA_Strasse}
          <br>
          $form->{FA_PLZ}&nbsp; &nbsp;$form->{FA_Ort}
          <br>
          <br>
          |.$locale->text('Tel. : ').qq|
          $form->{FA_Telefon}
          <br> 
          |.$locale->text('Fax. : ').qq|
          $form->{FA_Fax}
          <br>
          <br>
          <a href="mailto:$form->{FA_Email}?subject=|.CGI::escape("Steuer Nr: $form->{steuernummer}:").qq|&amp;body=|.CGI::escape("Sehr geehrte Damen und Herren,\n\n\nMit freundlichen Gr��en\n\n").CGI::escape($form->{signature}).qq|">
            $form->{FA_Email}
          </a>
          <br>
          <a href="$form->{FA_Internet}">
            $form->{FA_Internet}
          </a>
          <br>
          <br>
          |.$locale->text('�ffnungszeiten').qq|
          <br>
          $oeffnungszeiten
          <br>
   |;
             
   my $FA_1= ($form->{FA_BLZ_1} ne '' && 
          $form->{FA_Kontonummer_1} ne '' && 
          $form->{FA_Bankbezeichnung_1} ne '');
   my $FA_2= ($form->{FA_BLZ_2} ne '' &&
          $form->{FA_Kontonummer_2} ne '' && 
          $form->{FA_Bankbezeichnung_oertlich} ne '');

   if ( $FA_1 && $FA_2){
     print qq|
          <br>
          |.$locale->text('Bankverbindungen').qq|
          <table>
          <tr>
          <td>
          $form->{FA_Bankbezeichnung_1}
          <br>                  
          |.$locale->text('Konto: ').qq|
          $form->{FA_Kontonummer_1}
          <br>
          |.$locale->text('BLZ: ').qq|
          $form->{FA_BLZ_1}
          </td>
          <td>
          $form->{FA_Bankbezeichnung_oertlich}
          <br>
          |.$locale->text('Konto: ').qq|
          $form->{FA_Kontonummer_2}
          <br> 
          |.$locale->text('BLZ: ').qq|
          $form->{FA_BLZ_2}
          </td>
          </tr>
          </table>
          <br>|;
   } elsif ( $FA_1 ) {
     print qq|
          <br>
          |.$locale->text('Bankverbindung').qq|
          <br>
          <br>
          $form->{FA_Bankbezeichnung_1}
          <br>                  
          |.$locale->text('Konto: ').qq|
          $form->{FA_Kontonummer_1}
          <br> 
          |.$locale->text('BLZ: ').qq|
          $form->{FA_BLZ_1}          <br>
          <br>|;
   } elsif ( $FA_2 ) {
     print qq|
          <br>
          |.$locale->text('Bankverbindung').qq|
          <br>
          <br>
          $form->{FA_Bankbezeichnung_oertlich}
          <br>                  
          |.$locale->text('Konto: ').qq|
          $form->{FA_Kontonummer_2}
          <br> 
          |.$locale->text('BLZ: ').qq|
          $form->{FA_BLZ_2}
     |;                     
   }
   print qq|

      </fieldset>
      <br>
      <fieldset>
      <legend>
      <b>|.$locale->text('Ausgabeformat').qq|</b>
      </legend>
  |;
	
  &show_options;
  my $ausgabe = '1';	
  print qq|
	  </fieldset>
      |;
      


   # Stichtag der n�chsten USTVA berechnen
   # 
   # ($stichtag, $tage_bis, $ical) = FA->stichtag($today[dd.mm.yyyy], 
   #                                              $FA_dauerfrist[1,0],
   #                                              $FA_voranmeld[month, quarter])
   #$tmpdateform= $myconfig{dateformat};
   #  $myconfig{dateformat}= "dd.mm.yyyy";
   #  $form->{today} = $form->datetonum($form->current_date(\%myconfig), \%myconfig);
   #  ($stichtag, $description, $tage_bis, $ical) = FA::stichtag($form->{today}, $form->{FA_dauerfrist},$form->{FA_voranmeld});
   #   $form->{today} = $form->date($stichtag, \%myconfig );
   #$myconfig{dateformat}= $tmpdateform;


   #print qq|
   #   <br>
   #   <br>
   #   <fieldset>
   #    <label>
   #    |.$locale->text('Anstehende Voranmeldungen').qq|
   #    </label>
   #     <h2 class="confirm">$stichtag<h2>
   #     <h3>$description</h3>
   #     <h4>$form->{today}</h4>
   #    
   #   </fieldset>|;

   } else {
     print qq|
     <td width="50%" valign="bottom">
     <fieldset>
     <legend>
     <b>|.$locale->text('Hinweise').qq|</b>
     </legend>
      <h2 class="confirm">Die Ausgabefunktionen sind wegen fehlender Daten deaktiviert.</h2>
      <h3>Hilfe:</h3>
      <ul>
      <li><a href="ustva.pl?path=$form->{path}&action=edit&level=Programm--Finanzamteinstellungen&login=$form->{login}&password=$form->{password}">
      Bitte 'Einstellungen' w�hlen um die Erweiterten UStVa Funktionen nutzen zu k�nnen.</a></li>
      <br>
      <li><a href="am.pl?path=$form->{path}&action=config&level=Programm--Preferences&login=$form->{login}&password=$form->{password}">
      Firmendaten k�nnen bei den Benutzereinstellungen ver�ndert werden.</a></li>
      </ul>
      </fieldset>
     |;
      my  $ausgabe='';     
      $hide = q|disabled="disabled"|;
   }



   print qq|
      </td>
    </tr>
  |;
 #}# end if report = ustva
  


  print qq|
      </table>
     </td>
    </tr>
    <tr>
     <td><hr size="3" noshade></td>
    </tr>
  </table>

  <br>
  <input type="hidden" name="address" value="$form->{address}">
  <input type="hidden" name="reporttype" value="custom">
  <input type="hidden" name="company_street" value="$form->{company_street}">
  <input type="hidden" name="company_city" value="$form->{company_city}">
  <input type="hidden" name="path" value="$form->{path}">
  <input type="hidden" name="login" value="$form->{login}">
  <input type="hidden" name="password" value="$form->{password}">
  <table width="100%">
  <tr>
   <td align="left">
     <input type=hidden name=nextsub value=generate_ustva>
     <input $hide type=submit class=submit name=action value="|.$locale->text('Show').qq|">
     <input type=submit class=submit name=action value="|.$locale->text('Config').qq|">
   </td>
   <td align="right">

    <!--</form>
    <form action="doc/ustva.html" method="get">
    -->
       <input type=submit class=submit name=action value="|.$locale->text('Help').qq|">
   <!-- </form>-->
   </td>
  </tr>
  </table>
  |;

  print qq|

  </body>
  </html>
  |;

}

#############################

sub help {
  # parse help documents under doc
  my $tmp = $form->{templates};
  $form->{templates} = 'doc';
  $form->{help}   = 'ustva';
  $form->{type}   = 'help';
  $form->{format} = 'html';
  &generate_ustva();
  #$form->{templates} = $tmp;
}


sub show { 
#&generate_ustva();
no strict 'refs';
&{$form->{nextsub}} ;
use strict 'refs';
};

sub ustva_vorauswahl {
 #Aktuelles Datum zerlegen:
 $locale->date(\%myconfig, $form->current_date(\%myconfig,'0','0'), 0)=~ /(\d\d).(\d\d).(\d\d\d\d)/;
 #$locale->date($myconfig, $form->current_date($myconfig), 0)=~ /(\d\d).(\d\d).(\d\d\d\d)/;
 $form->{day}= $1;
 $form->{month}= $2;
 $form->{year}= $3;
 my $sel='';
 my $yymmdd='';
 # Testdaten erzeugen:
 #$form->{day}= '11';
 #$form->{month}= '01';
 #$form->{year}= 2004;
 print qq|
     <input type=hidden name=day value=$form->{day}>
     <input type=hidden name=month value=$form->{month}>
     <input type=hidden name=yymmdd value=$yymmdd>
     <input type=hidden name=sel value=$sel>
 |;
 
 if ($form->{FA_voranmeld} eq 'month'){
   # Vorauswahl bei monatlichem Voranmeldungszeitraum 
   print qq|
     <select name="duetyp" id=zeitraum title="|.$locale->text('Hier den Berechnungszeitraum ausw�hlen...').qq|">
   |;

   my %liste =  ('01' => 'January', 
              '02' => 'February', 
              '03' => 'March', 
              '04' => 'April',
              '05' => 'May',
              '06' => 'June',
              '07' => 'July',
              '08' => 'August',
              '09' => 'September',
              '10' => 'October',
              '11' => 'November',
              '12' => 'December');

   my $yy = $form->{year}* 10000;
   $yymmdd = "$form->{year}$form->{month}$form->{day}" * 1;
   $sel='';
   my $dfv = '0'; # Offset f�r Dauerfristverl�ngerung
   #$dfv = '100' if ($form->{FA_dauerfrist} eq '1');
    
   SWITCH: {
    	$yymmdd <= ($yy + 110 + $dfv) && do {   
      					$form->{year} = $form->{year} - 1;
      					$sel='12';
					last SWITCH;
    					};    
    	$yymmdd <= ($yy + 210 + $dfv) && do {
      					$sel='01';
					last SWITCH;
    					};
    	$yymmdd <= ($yy + 310 + $dfv) && do {
      					$sel='02';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 410 + $dfv) && do {
      					$sel='03';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 510 + $dfv) && do {
      					$sel='04';
					last SWITCH;
    					};
    	$yymmdd <= ($yy + 610 + $dfv) && do {
      					$sel='05';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 710 + $dfv) && do {
      					$sel='06';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 810 + $dfv) && do {
      					$sel='07';
					last SWITCH;
    					};
    	$yymmdd <= ($yy + 910 + $dfv) && do {
      					$sel='08';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 1010 + $dfv) && do {
      					$sel='09';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 1110 + $dfv) && do {
      					$sel='10';
					last SWITCH;
    					};
    	$yymmdd <= ($yy + 1210) && do {
      					$sel='11';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 1231) && do {
      					$sel='12';
					last SWITCH;
    					};

   };
   my $key = '';
   foreach $key ( sort keys %liste ){
   my $selected = '';
   $selected = 'selected' if ( $sel eq $key );
   print qq|
         <option value="$key" $selected>|.$locale->text("$liste{$key}").qq|</option>
         
   |;
 }
 print qq|</select>|;

 } elsif ($form->{FA_voranmeld} eq 'quarter'){
   # Vorauswahl bei quartalsweisem Voranmeldungszeitraum 
   my %liste = ( 'A' => '1.',
                 'B' => '2.',
                 'C' => '3.',
                 'D' => '4.',
               );

   my $yy = $form->{year}* 10000;
   $yymmdd = "$form->{year}$form->{month}$form->{day}" * 1;
   $sel='';
   my $dfv = ''; # Offset f�r Dauerfristverl�ngerung
   $dfv = '100' if ($form->{FA_dauerfrist} eq '1');
    
   SWITCH: {
    	$yymmdd <= ($yy + 110 + $dfv) && do {   
      					$form->{year} = $form->{year} - 1;
      					$sel='D';
					last SWITCH;
    					};    
    	$yymmdd <= ($yy + 410 + $dfv) && do {
      					$sel='A';
					last SWITCH;
    					};
    	$yymmdd <= ($yy + 710 + $dfv) && do {
      					$sel='B';
					last SWITCH;
    					};    					
    	$yymmdd <= ($yy + 1010 + $dfv) && do {
      					$sel='C';
					last SWITCH;
    					};    					
        $yymmdd <= ($yy + 1231) && do    {
                                        $sel='D';
                                        };
   };

   print qq|<select id="zeitraum" name="duetyp" title="|.$locale->text('Select a period').qq|" >|;
   my $key = '';
   foreach $key ( sort keys %liste ){
     my $selected = '';
     $selected = 'selected' if ( $sel eq $key );
     print qq|
         <option value="$key" $selected>$liste{$key} |.$locale->text('Quarter').qq|</option>
     |;
    }
   print qq|\n</select>
   |;

 } else {
 
   # keine Vorauswahl bei Voranmeldungszeitraum 
   print qq|<select id="zeitraum" name="duetyp" title="|.$locale->text('Select a period').qq|" >|;
 
   my %listea = ( 'A' => '1.',
               'B' => '2.',
               'C' => '3.',
               'D' => '4.',
               );
             
   my %listeb = ( '01' => 'January', 
               '02' => 'February', 
               '03' => 'March', 
               '04' => 'April',
               '05' => 'May',
               '06' => 'June',
               '07' => 'July',
               '08' => 'August',
               '09' => 'September',
               '10' => 'October',
               '11' => 'November',
               '12' => 'December',
             );
   my $key = '';
   foreach $key ( sort keys %listea ){
     print qq|
         <option value="$key">$listea{$key} |.$locale->text('Quarter').qq|</option>
         
     |;
   }

   foreach $key ( sort keys %listeb ){
     print qq|
         <option value="$key">|.$locale->text("$listeb{$key}").qq|</option>
         
     |;
   }
   print qq|</select>|;
 }
}


sub config { 
  edit();
}



sub debug {
  $form->debug();
}
    
sub show_options {
#  $form->{PD}{$form->{type}} = "selected";
#  $form->{DF}{$form->{format}} = "selected";
#  $form->{OP}{$form->{media}} = "selected";
#  $form->{SM}{$form->{sendmode}} = "selected";
  my $type = qq|      <input type=hidden name="type" value="ustva">|;
  my $media = qq|      <input type=hidden name="media" value="screen">|;
  my $format = qq|       <option value=html selected>|.$locale->text('Vorschau').qq|</option>|;
  if ($latex) {
    $format .= qq|    <option value=pdf>|.$locale->text('UStVA als PDF-Dokument').qq|</option>|;
  }
  
    #my $disabled= qq|disabled="disabled"|; 
  #$disabled='' if ($form->{elster} eq '1' );
  if ($form->{elster} eq '1'){
    $format .= qq|<option value=elster>|.$locale->text('ELSTER Export nach Winston').qq|</option>|;
  }
  #$format .= qq|<option value=elster>|.$locale->text('ELSTER Export nach Winston').qq|</option>|;
  print qq|
    $type
    $media
    <select name=format title = "|.$locale->text('Ausgabeformat ausw�hlen...').qq|">$format</select>
  |;
}

sub generate_ustva {
  # Aufruf von get_config aus bin/mozilla/ustva.pl zum 
  # Einlesen der Finanzamtdaten aus finanzamt.ini

  get_config($userspath, 'finanzamt.ini');

  # form vars initialisieren
  my @anmeldungszeitraum = qw('0401' '0402' '0403' '0404' '0405' '0405' '0406' '0407' '0408' '0409' '0410' '0411' '0412' '0441' '0442' '0443' '0444');
  my $item = '';
  foreach $item (@anmeldungszeitraum) {
    $form->{$item} = "";
  }
  if ($form->{reporttype} eq "custom"){
    #forgotten the year --> thisyear
    if ($form->{year}  !~ m/^\d\d\d\d$/ ) {
      $locale->date(\$myconfig, $form->current_date(\$myconfig), 0)=~ /(\d\d\d\d)/;
      $form->{year}= $1;
    }
    #yearly report
    if ($form->{duetyp} eq "13"   ){
      $form->{fromdate}="1.1.$form->{year}";
      $form->{todate}="31.12.$form->{year}";
    }
    #Quater reports    
    if ($form->{duetyp} eq "A"   ){
      $form->{fromdate}="1.1.$form->{year}";
      $form->{todate}="31.3.$form->{year}";
      $form->{'0441'} = "X";
    }
    if ($form->{duetyp} eq "B"   ){
      $form->{fromdate}="1.4.$form->{year}";
      $form->{todate}="30.6.$form->{year}";
      $form->{'0442'} = "X";
    }
    if ($form->{duetyp} eq "C"   ){
      $form->{fromdate}="1.7.$form->{year}";
      $form->{todate}="30.9.$form->{year}";
      $form->{'0443'} = "X";
    }
    if ($form->{duetyp} eq "D"   ){
      $form->{fromdate}="1.10.$form->{year}";
      $form->{todate}="31.12.$form->{year}";
      $form->{'0444'} = "X";
    }
 
    #Monthly reports
    SWITCH: {
    	$form->{duetyp} eq "01" && do {
      					$form->{fromdate}="1.1.$form->{year}";
				      	$form->{todate}="31.1.$form->{year}";
					$form->{'0401'} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "02" && do {
      					$form->{fromdate}="1.2.$form->{year}";
					#this works from 1901 to 2099, 1900 and 2100 fail.
					my $leap=($form->{year} % 4 == 0) ? "29" : "28";
				      	$form->{todate}="$leap.2.$form->{year}";
					$form->{"0402"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "03" && do {
      					$form->{fromdate}="1.3.$form->{year}";
				      	$form->{todate}="31.3.$form->{year}";
					$form->{"0403"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "04" && do {
      					$form->{fromdate}="1.4.$form->{year}";
				      	$form->{todate}="30.4.$form->{year}";
					$form->{"0404"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "05" && do {
      					$form->{fromdate}="1.5.$form->{year}";
				      	$form->{todate}="31.5.$form->{year}";
					$form->{"0405"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "06" && do {
      					$form->{fromdate}="1.6.$form->{year}";
				      	$form->{todate}="30.6.$form->{year}";
					$form->{"0406"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "07" && do {
      					$form->{fromdate}="1.7.$form->{year}";
				      	$form->{todate}="31.7.$form->{year}";
					$form->{"0407"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "08" && do {
      					$form->{fromdate}="1.8.$form->{year}";
				      	$form->{todate}="31.8.$form->{year}";
					$form->{"0408"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "09" && do {
      					$form->{fromdate}="1.9.$form->{year}";
				      	$form->{todate}="30.9.$form->{year}";
					$form->{"0409"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "10" && do {
      					$form->{fromdate}="1.10.$form->{year}";
				      	$form->{todate}="31.10.$form->{year}";
					$form->{"0410"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "11" && do {
      					$form->{fromdate}="1.11.$form->{year}";
				      	$form->{todate}="30.11.$form->{year}";
					$form->{"0411"} = "X";
					last SWITCH;
    					};
    	$form->{duetyp} eq "12" && do {
      					$form->{fromdate}="1.12.$form->{year}";
				      	$form->{todate}="31.12.$form->{year}";
					$form->{"0412"} = "X";
					last SWITCH;
    					};
        }
   }
  #$myconfig = \%myconfig;
  RP->ustva(\%myconfig, \%$form);

  #??($form->{department}) = split /--/, $form->{department};
  
  $form->{period} = $locale->date(\%myconfig, $form->current_date(\%myconfig), 1, 0, 0);
  $form->{todate} = $form->current_date($myconfig) unless $form->{todate};

  # if there are any dates construct a where
  if ($form->{fromdate} || $form->{todate}) {
    
    unless ($form->{todate}) {
      $form->{todate} = $form->current_date($myconfig);
    }

    my $longtodate = $locale->date($myconfig, $form->{todate}, 1, 0, 0);
    my $shorttodate = $locale->date($myconfig, $form->{todate}, 0, 0, 0);
    
    my $longfromdate = $locale->date($myconfig, $form->{fromdate}, 1, 0, 0);
    my $shortfromdate = $locale->date($myconfig, $form->{fromdate}, 0, 0, 0);
    
    $form->{this_period} = "$shortfromdate<br>\n$shorttodate";
    $form->{period} = $locale->text('for Period').qq|<br>\n$longfromdate |.$locale->text('bis').qq| $longtodate|;
  }

  if ($form->{comparefromdate} || $form->{comparetodate}) {
    my $longcomparefromdate = $locale->date(\%myconfig, $form->{comparefromdate}, 1, 0, 0);
    my $shortcomparefromdate = $locale->date(\%myconfig, $form->{comparefromdate}, 0, 0, 0);
    
    my $longcomparetodate = $locale->date(\%myconfig, $form->{comparetodate}, 1, 0, 0);
    my $shortcomparetodate = $locale->date(\%myconfig, $form->{comparetodate}, 0, 0, 0);
    
    $form->{last_period} = "$shortcomparefromdate<br>\n$shortcomparetodate";
    $form->{period} .= "<br>\n$longcomparefromdate ".$locale->text('bis').qq| $longcomparetodate|;
  }

  $form->{Datum_heute} = $locale->date(\%myconfig, $form->current_date(\%myconfig), 0, 0, 0);

  # setup variables for the form
  my @a = ();
  @a = qw(company businessnumber tel fax email company_email);
  map { $form->{$_} = $myconfig{$_} } @a;
  
  if ( $form->{address} ne '' ) {
        my $temp = $form->{address};
        $temp =~ s/\\n/<br \/>/;
        ($form->{company_street}, $form->{company_city}) = split("<br \/>", $temp);
  }
  
  if ($form->{format} eq 'pdf' 
       or $form->{format} eq 'postscript') {
    $form->{padding} = "~~";
    $form->{bold} = "\textbf{";
    $form->{endbold} = "}";
    $form->{br} = '\\\\';
    
    my @numbers = qw(51r 86r 97r 93r 96 43 45 
                  66 62 67);
    my $number = '';
    foreach $number ( @numbers){
      $form->{$number} =~ s/,/~~/g;
    }
  } 
  elsif ($form->{format} eq 'html') {
    $form->{padding} = "&nbsp;&nbsp;";
    $form->{bold} = "<b>";
    $form->{endbold} = "</b>";
    $form->{br} = "<br>";
    $form->{address} =~ s/\\n/<br \/>/;
    
  };
  
  
  if ($form->{format} eq 'elster'){
      &create_winston();
    } else {
      $form->{templates} = $myconfig{templates};
      $form->{templates} = "doc" if ($form->{type} eq 'help');
      
      $form->{IN}  = "$form->{type}";
      $form->{IN}  = "$form->{help}" if ($form->{type} eq 'help');
      $form->{IN} .= "-$form->{year}" if ($form->{format} eq 'pdf'
                       or $form->{format} eq 'postscript');

      $form->{IN} .= '.tex' if ($form->{format} eq 'pdf' 
                       or $form->{format} eq 'postscript');

      $form->{IN} .= '.html' if ($form->{format} eq 'html');
      #$form->header;    
      #print qq|$myconfig<br>$path|;
      $form->parse_template($myconfig, $userspath);
  }
}


sub edit {
# edit all taxauthority prefs

  $form->header;
  &get_config($userspath, 'finanzamt.ini');
  
  #&create_steuernummer;
  
  my $land=$form->{elsterland};
  my $amt=$form->{elsterFFFF};  

  $form->{title} = $locale->text('Finanzamt - Einstellungen');
  print qq|
    <body>
    <form name="verzeichnis" method=post action="$form->{script}">
     <table width=100%>
	<tr>
	  <th class="listtop">|.$locale->text('Finanzamt - Einstellungen').qq|</th>
	</tr>
        <tr>
         <td>
           <br>
           <fieldset>
           <legend><b>|.$locale->text('Angaben zum Finanzamt').qq|</b></legend>
  |;
  #print qq|$form->{terminal}|;

  USTVA::fa_auswahl($land, $amt, &elster_hash());
  print qq|
           </fieldset>
           <br>
  |;
  my $checked = '';
  $checked ="checked" if ( $form->{method} eq 'accrual' );
  print qq|
           <fieldset>
           <legend><b>|.$locale->text('Verfahren').qq|</b>
           </legend>
           <input name=method id=accrual class=radio type=radio value="accrual" $checked>
           <label for="accrual">|.$locale->text('accrual').qq|</label>
           <br>
  |;
  $checked = '';
  $checked ="checked" if ( $form->{method} eq 'cash' );
  print qq|
           <input name=method id=cash class=radio type=radio value="cash" $checked>
           <label for="cash">|.$locale->text('cash').qq|</label>
           </fieldset>
           <br>
           <fieldset>
           <legend><b>|.$locale->text('Voranmeldungszeitraum').qq|</b>
           </legend>
  |;
  $checked = '';
  $checked ="checked" if ( $form->{FA_voranmeld} eq 'month' );
  print qq|
           <input name=FA_voranmeld id=month class=radio type=radio value="month" $checked>
           <label for="month">|.$locale->text('month').qq|</label>
           <br>
  |;
  $checked = '';
  $checked ="checked" if ( $form->{FA_voranmeld} eq 'quarter' );
  print qq|
           <input name="FA_voranmeld" id=quarter class=radio type=radio value="quarter" $checked>
           <label for="quarter">|.$locale->text('quarter').qq|</label>
           <br>
  |;
  $checked = '';
  $checked ="checked" if ( $form->{FA_dauerfrist} eq '1' );
  print qq|
           <input name="FA_dauerfrist" id=FA_dauerfrist class=checkbox type=checkbox value="1" $checked>
           <label for="">|.$locale->text('Dauerfristverl�ngerung').qq|</label>
           
           </fieldset>
           <br>
           <fieldset>
           <legend><b>|.$locale->text('Steuerberater/-in').qq|</b>
           </legend>
  |;
  $checked = '';
  $checked ="checked" if ( $form->{FA_71} eq 'X' );
  print qq|
          <!-- <input name="FA_71" id=FA_71 class=checkbox type=checkbox value="X" $checked>
           <label for="FA_71">|.$locale->text('Verrechnung des Erstattungsbetrages erw�nscht (Zeile 71)').qq|</label>
           <br>
           <br>-->
           <table>
           <tr>
           <td>
           |.$locale->text('Name').qq|
           </td>
           <td>
           |.$locale->text('Stra�e').qq|
           </td>
           <td>
           |.$locale->text('PLZ, Ort').qq|
           </td>
           <td>
           |.$locale->text('Telefon').qq|
           </td>
           </tr>
           <tr>
           <td>
           <input name="FA_steuerberater_name" id=steuerberater size=25 value="$form->{FA_steuerberater_name}">
           </td>
           <td>
           <input name="FA_steuerberater_street" id=steuerberater size=25 value="$form->{FA_steuerberater_street}">
           </td>
           <td>
           <input name="FA_steuerberater_city" id=steuerberater size=25 value="$form->{FA_steuerberater_city}">
           </td>
           <td>
           <input name="FA_steuerberater_tel" id=steuerberater size=25 value="$form->{FA_steuerberater_tel}">
           </tr>
           </table>
           
           </fieldset>

           <br>
           <br>
           <hr>
           <!--<input type=submit class=submit name=action value="|.$locale->text('debug').qq|">-->
           <input type=submit class=submit name=action value="|.$locale->text('continue').qq|">
         </td>
       </tr>
     </table>
  |;
  
  my @variables = qw( steuernummer elsterland elstersteuernummer elsterFFFF);
  my $variable = '';
    foreach $variable (@variables) {
    print qq|	
          <input name=$variable type=hidden value="$form->{$variable}">|;
  }
  my $steuernummer_new = '';
  #<input type=hidden name="steuernummer_new" value="$form->{$steuernummer_new}">        
  print qq|

          <input type=hidden name="nextsub" value="edit_form">
          <input type=hidden name="warnung" value="1">
          <input type=hidden name="saved" value="|.$locale->text('Bitte Angaben �berpr�fen').qq|">
          <input type=hidden name="path" value=$form->{path}>
          <input type=hidden name="login" value=$form->{login}>
          <input type=hidden name="password" value=$form->{password}>
          <input type=hidden name="warnung" value="0">
  |;
         
  @variables = qw(FA_Name FA_Strasse FA_PLZ 
    FA_Ort FA_Telefon FA_Fax FA_PLZ_Grosskunden FA_PLZ_Postfach FA_Postfach 
    FA_BLZ_1 FA_Kontonummer_1 FA_Bankbezeichnung_1 FA_BLZ_2
    FA_Kontonummer_2 FA_Bankbezeichnung_oertlich FA_Oeffnungszeiten 
    FA_Email FA_Internet);
  
  foreach $variable (@variables) {
    print qq|	
          <input name=$variable type=hidden value="$form->{$variable}">|;
  }
  
  print qq|
   </form>
   </body>
|;
}


sub edit_form {
  $form->header();
  print qq|
    <body>
  |;
  my $elsterland = '';
  my $elster_amt = '';
  my $elsterFFFF = '';
  my $elstersteuernummer = '';
  &get_config($userspath, 'finanzamt.ini') if ($form->{saved} eq $locale->text('saved'));

  # Auf �bergabefehler checken
  USTVA::info($locale->text('Bitte das Bundesland UND die Stadt bzw. den Einzugsbereich Ihres zust�ndigen Finanzamts ausw�hlen.')) if ($form->{elsterFFFF_new} eq 'Auswahl' || $form->{elsterland_new} eq 'Auswahl');
  USTVA::info($locale->text('Es fehlen Angaben zur Versteuerung. 
  Wenn Sie Ist Versteuert sind, w�hlen Sie die Einnahmen/�berschu�-Rechnung aus. 
  Sind Sie Soll-Versteuert und Bilanzverpflichtet, dann w�hlen Sie Bilanz aus.')) if ( $form->{method} eq '' );
  # Kl�ren, ob Variablen bereits bef�llt sind UND ob ver�derungen auf
  # der vorherigen Maske stattfanden: $change = 1(in der edit sub, 
  # mittels get_config)
  
  my $change = $form->{elsterland} eq $form->{elsterland_new} && $form->{elsterFFFF} eq $form->{elsterFFFF_new} ? '0':'1';
  $change = '0' if ($form->{saved} eq $locale->text('saved'));
  my $elster_init = &elster_hash();
  #my %elster_init = ();
  my %elster_init = %$elster_init;
  
  if ( $change eq '1' ){
    # Daten �ndern
    $elsterland = $form->{elsterland_new};
    $elsterFFFF = $form->{elsterFFFF_new};
    $form->{elsterland} = $elsterland;
    $form->{elsterFFFF} = $elsterFFFF;
    $form->{steuernummer} = '';
    &create_steuernummer;  
    # rebuild elster_amt
    my $amt = '';
    foreach $amt ( keys %{ $elster_init{$form->{elsterland}} } ) {
       $elster_amt = $amt  if ($elster_init{$form->{elsterland}{$amt} eq $form->{elsterFFFF}} );
    }  

    # load the predefined hash data into the FA_* Vars    
    my @variables = qw(FA_Name FA_Strasse FA_PLZ FA_Ort 
                    FA_Telefon FA_Fax FA_PLZ_Grosskunden FA_PLZ_Postfach 
                    FA_Postfach 
                    FA_BLZ_1 FA_Kontonummer_1 FA_Bankbezeichnung_1 
                    FA_BLZ_2 FA_Kontonummer_2 FA_Bankbezeichnung_oertlich 
                    FA_Oeffnungszeiten FA_Email FA_Internet);
    
    for (my $i = 0; $i <= 20; $i++) {
       $form->{$variables[$i]} = $elster_init->{$elsterland}->{$elsterFFFF}->[$i];
    }

  } else {

    $elsterland = $form->{elsterland};
    $elsterFFFF = $form->{elsterFFFF};
  
  } 
  my $stnr = $form->{steuernummer};
  $stnr =~ s/\D+//g;
  my $patterncount = $form->{patterncount};
  my $elster_pattern = $form->{elster_pattern};
  my $delimiter = $form->{delimiter};
  my $steuernummer = '';
  $steuernummer = $form->{steuernummer} if ($steuernummer eq '');

  #Warnung
  my $warnung = $form->{warnung};
  #printout form
  print qq|
   <form name="elsterform" method=post action="$form->{script}">
   <table width="100%">
       <tr>
        <th colspan="2" class="listtop">|.$locale->text('Finanzamt - Einstellungen').qq|</th>
       </tr>
       <tr>
         <td colspan=2>
         <br>
  |;
  &show_fa_daten;
  print qq|
         </td>
       </tr>
       <tr>
         <td colspan="2">
           <br>
           <fieldset>
           <legend>
           <font size="+1">|.$locale->text('Steuernummer').qq|</font>
           </legend>
           <br>
  |;
  $steuernummer = USTVA::steuernummer_input($form->{elsterland}, 
         $form->{elsterFFFF}, $form->{steuernummer} );
  print qq|
           </H2><br>
           </fieldset>
           <br>
           <br>
           <hr>
         </td>
      </tr>
      <tr>
         <td align="left">


          <!--<input type=hidden name=nextsub value="debug">
          <input type=submit class=submit name=action value="|.$locale->text('debug').qq|">
          <input type=hidden name=nextsub value="test">
          <input type=submit class=submit name=action value="|.$locale->text('test').qq|">-->
          <input type=hidden name=lastsub value="edit">
          <input type=submit class=submit name=action value="|.$locale->text('back').qq|">
  |;
  if ( $form->{warnung} eq "1" ){
    print qq|
          <input type=hidden name=nextsub value="edit_form">
          <input type=submit class=submit name=action value="|.$locale->text('continue').qq|">
          <input type=hidden name="saved" value="|.$locale->text('Bitte alle Angaben �berpr�fen').qq|">
    |;
  } else {
    print qq|
          <input type=hidden name="nextsub" value="save">
          <input type=hidden name="filename" value="finanzamt.ini">
          <input type=submit class=submit name=action value="|.$locale->text('save').qq|">
         |;
  }

  print qq|
         </td>
         <td align="right">
           <H2 class=confirm>$form->{saved}</H2>
         </td>
      </tr>
  </table>
  |;

  my @variables = qw(FA_steuerberater_name FA_steuerberater_street
                  FA_steuerberater_city FA_steuerberater_tel
                  FA_voranmeld method  
                  FA_dauerfrist FA_71 FA_Name elster
                  path login password type elster_init saved
                  );
  my $variable = '';
  foreach $variable (@variables) {
  print qq|
        <input name="$variable" type="hidden" value="$form->{$variable}">|;
  }
  print qq|
          <input type=hidden name="elsterland" value="$elsterland">
          <input type=hidden name="elsterFFFF" value="$elsterFFFF">
          <input type=hidden name="warnung" value="$warnung">
          <input type=hidden name="elstersteuernummer" value="$elstersteuernummer">
          <input type=hidden name="steuernummer" value="$stnr">
  </form>
  |;
}


sub create_steuernummer {
  my $part=$form->{part};
  my $patterncount = $form->{patterncount};
  my $delimiter = $form->{delimiter};
  my $elster_pattern = $form->{elster_pattern};
  # rebuild steuernummer and elstersteuernummer
  # es gibt eine gespeicherte steuernummer $form->{steuernummer}
  # und die parts und delimiter 
  
  my $h =0;
  my $i =0;
  
  my $steuernummer_new = $part; 
  my $elstersteuernummer_new = $form->{elster_FFFF};
  $elstersteuernummer_new .= '0';
  
  for ( $h = 1; $h < $patterncount; $h++) {
    $steuernummer_new .= qq|$delimiter|;
    for (my $i = 1; $i <= length($elster_pattern); $i++ ) {
      $steuernummer_new .= $form->{"part_$h\_$i"};
      $elstersteuernummer_new .= $form->{"part_$h\_$i"};
    }
  }
  if ($form->{steuernummer} ne $steuernummer_new){
    $form->{steuernummer} = $steuernummer_new;
    $form->{elstersteuernummer} = $elstersteuernummer_new;
    $form->{steuernummer_new} = $steuernummer_new;
  } else{
    $form->{steuernummer_new} = '';
    $form->{elstersteuernummer_new} = '';   
  }
}


sub get_config {

  my ($userpath, $filename) = @_;
  my ($key, $value) = '';
  open(FACONF, "$userpath/$filename") or $form->error("$userpath/$filename : $!");
    while (<FACONF>) {
          last if /^\[/;
          next if /^(#|\s)/;
          # remove comments
          s/\s#.*//g;
          # remove any trailing whitespace
          s/^\s*(.*?)\s*$/$1/;
          ($key, $value) = split /=/, $_, 2;
          #if ($value eq ' '){
          #   $form->{$key} = " " ;
          #} elsif ($value ne ' '){
             $form->{$key} = "$value";
          #}
    }
  close FACONF;
  # Textboxen formatieren: Linebreaks entfernen
  #
  #$form->{FA_Oeffnungszeiten} =~ s/\\\\n/<br>/g;
}



sub save {
  my $filename = $form->{filename};
  #zuerst die steuernummer aus den part, parts_X_Y und delimiter herstellen
  create_steuernummer;
  # Textboxen formatieren: Linebreaks entfernen
  #
  $form->{FA_Oeffnungszeiten} =~ s/\r\n/\\n/g;
  #URL mit http:// davor?
  $form->{FA_Internet} =~ s/^http:\/\///;
  $form->{FA_Internet} = 'http://'. $form->{FA_Internet};
  
  my @config = qw(elster elsterland elstersteuernummer steuernummer 
               elsteramt elsterFFFF FA_Name FA_Strasse 
               FA_PLZ FA_Ort FA_Telefon FA_Fax FA_PLZ_Grosskunden 
               FA_PLZ_Postfach FA_Postfach FA_BLZ_1 FA_Kontonummer_1 
               FA_Bankbezeichnung_1 FA_BLZ_2 FA_Kontonummer_2 
               FA_Bankbezeichnung_oertlich FA_Oeffnungszeiten 
               FA_Email FA_Internet FA_voranmeld method FA_steuerberater_name
               FA_steuerberater_street FA_steuerberater_city FA_steuerberater_tel
               FA_71 FA_dauerfrist);
  # Hier kommt dann die Plausibilit�tspr�fung der ELSTERSteuernummer
  if ( $form->{elstersteuernummer} ne '000000000' ) { 
    $form->{elster}='1';
    open(CONF, ">$userspath/$filename") or $form->error("$filename : $!");
    # create the config file
    print CONF qq|# Configuration file for USTVA\n\n|;
    my $key = '';   
    foreach $key (sort @config) {
      $form->{$key} =~ s/\\/\\\\/g;
      $form->{$key} =~ s/"/\\"/g;
      # strip M
      $form->{$key} =~ s/\r\n/\n/g;
      print CONF qq|$key=|; 
      if ($form->{$key} ne 'Y') {
        print CONF qq|$form->{$key}\n|;
      }
      if ($form->{$key} eq 'Y') {
        print CONF qq|checked \n|;
      }
    }
    print CONF qq|\n\n|;
    close CONF;
    $form->{saved} = $locale->text('saved');
  
  } else {
  
    $form->{saved} = $locale->text('Bitte eine Steuernummer angeben');
  }

  &edit_form;
}

sub show_fa_daten {
  my $readonly = $_;
  my $oeffnungszeiten = $form->{FA_Oeffnungszeiten} ;
  $oeffnungszeiten =~ s/\\\\n/\n/g;
  print qq|    <br>
               <fieldset>
               <legend>
               <font size="+1">|. $locale->text('Finanzamt').qq| $form->{FA_Name}</font>
               </legend>
  |;
  #print qq|\n<h4>$form->{FA_Ergaenzung_Name}&nbsp;</h4>
  #        | if ( $form->{FA_Ergaenzung_Name} );
  print qq|
               <table width="100%" valign="top">
               <tr>
                <td valign="top">
                  <br>
                  <fieldset>
                    <legend>
                    <b>|.$locale->text('Address').qq|</b>
                    </legend>

                  <table width="100%">
                   <tr>
                    <td colspan="2">
                     <input name="FA_Strasse" size="40" title="FA_Strasse" value="$form->{FA_Strasse}" $readonly>
                    </td width="100%">
                   </tr>
                   <tr>
                    <td width="116px">
                     <input name="FA_PLZ" size="10" title="FA_PLZ" value="$form->{FA_PLZ}" $readonly>
                    </td>
                    <td>
                     <input name="FA_Ort" size="20" title="FA_Ort" value="$form->{FA_Ort}" $readonly>
                    </td>
                  </tr>
                  </table>
                  </fieldset>
                  <br>
                  <fieldset>
                  <legend>
                  <b>|.$locale->text('Kontakt').qq|</b>
                  </legend>
                      |.$locale->text('Telefon').qq|<br>
                      <input name="FA_Telefon" size="40" title="FA_Telefon" value="$form->{FA_Telefon}" $readonly>
                      <br>
                      <br> 
                      |.$locale->text('Fax').qq|<br>
                      <input name="FA_Fax" size="40" title="FA_Fax" value="$form->{FA_Fax}" $readonly>
                      <br>
                      <br>
                      |.$locale->text('Internet').qq|<br>
                      <input name="FA_Email" size="40" title="FA_Email" value="$form->{FA_Email}" $readonly>
                      <br>
                      <br>
                      <input name="FA_Internet" size="40" title="" title="FA_Internet" value="$form->{FA_Internet}" $readonly>
                      <br>
                  </fieldset>
                </td>
                <td valign="top">
                  <br>
                  <fieldset>
                  <legend>
                  <b>|.$locale->text('�ffnungszeiten').qq|</b>
                  </legend>
                  <textarea name="FA_Oeffnungszeiten" rows="4" cols="40" $readonly>$oeffnungszeiten</textarea>
                  </fieldset>
                  <br>
  |;
  my $FA_1= ($form->{FA_BLZ_1} ne '' && 
       $form->{FA_Kontonummer_1} ne '' && 
       $form->{FA_Bankbezeichnung_1} ne '');
  my $FA_2= ($form->{FA_BLZ_2} ne '' &&
       $form->{FA_Kontonummer_2} ne '' && 
       $form->{FA_Bankbezeichnung_oertlich} ne '');
  if ( $FA_1 && $FA_2){
     print qq|
                    <fieldset>
                    <legend>
                    <b>|.$locale->text('Bankverbindungen des Finanzamts').qq|</b>
                    <legend>
                    <table>   
                    <tr>
                     <td>
                        |.$locale->text('Kreditinstitut').qq|
                        <br>
                        <input name="FA_Bankbezeichnung_1" size="30" value="$form->{FA_Bankbezeichnung_1}" $readonly>
                        <br>
                        <br>
                        |.$locale->text('Kontonummer').qq|
                        <br>
                        <input name="FA_Kontonummer_1" size="15" value="$form->{FA_Kontonummer_1}" $readonly>
                        <br>
                        <br> 
                        |.$locale->text('Bankleitzahl').qq|
                        <br>
                        <input name="FA_BLZ_1" size="15" value="$form->{FA_BLZ_1}" $readonly>
                     </td>
                     <td>
                        |.$locale->text('Kreditinstitut').qq|
                        <br>
                        <input name="FA_Bankbezeichnung_oertlich" size="30" value="$form->{FA_Bankbezeichnung_oertlich}" $readonly>
                        <br>
                        <br>
                        |.$locale->text('Kontonummer').qq|
                        <br>
                        <input name="FA_Kontonummer_2" size="15" value="$form->{FA_Kontonummer_2}" $readonly>
                        <br>
                        <br> 
                        |.$locale->text('Bankleitzahl').qq|
                        <br>
                        <input name="FA_BLZ_2" size="15" value="$form->{FA_BLZ_2}" $readonly>
                     </td>
                    </tr>
                    </table>
                    </fieldset>
    |; 
  } elsif ( $FA_1 ) {
    print qq|
                    <fieldset>
                    <legend>
                      <b>|.$locale->text('Bankverbindung des Finanzamts').qq|</b>
                    <legend>
                    |.$locale->text('Kontonummer').qq|
                    <br>
                    <input name="FA_Kontonummer_1" size="30" value="$form->{FA_Kontonummer_1}" $readonly>
                    <br>
                    <br> 
                    |.$locale->text('Bankleitzahl (BLZ)').qq|
                    <br>
                    <input name="FA_BLZ_1" size="15" value="$form->{FA_BLZ_1}" $readonly>
                    <br>
                    <br>
                    |.$locale->text('Kreditinstitut').qq|
                    <br>
                    <input name="FA_Bankbezeichnung_1" size="15" value="$form->{FA_Bankbezeichnung_1}" $readonly>
                    <br>
                    </fieldset>
    |;
  } else {
    print qq|
                    <fieldset>
                    <legend>
                      <b>|.$locale->text('Bankverbindung des Finanzamts').qq|</b>
                    <legend> 
                    |.$locale->text('Kontonummer').qq|
                    <br>
                    <input name="FA_Kontonummer_2" size="30" value="$form->{FA_Kontonummer_2}" $readonly>
                    <br>
                    <br> 
                    |.$locale->text('Bankleitzahl (BLZ)').qq|
                    <br>
                    <input name="FA_BLZ_2" size="15" value="$form->{FA_BLZ_2}" $readonly>
                    <br>
                    <br>
                    |.$locale->text('Kreditinstitut').qq|
                    <br>
                    <input name="FA_Bankbezeichnung_oertlich" size="15" value="$form->{FA_Bankbezeichnung_oertlich}" $readonly>
                    </fieldset>
    |;                     
  }
  print qq|
                 </td>
               </tr>              
          </table>
  </fieldset>
  |;
}



sub create_winston {
  &get_config($userspath, 'finanzamt.ini');

  # There is no generic Linux GNU/GPL solution out for using ELSTER.
  # In lack of availability linux users may use windows pendants. I choose
  # WINSTON, because it's free of coast, it has an API and its tested under
  # Linux using WINE.
  # The author of WINSTON developed some c-code to realize ELSTER under 
  # WINDOWS and Linux (http://www.felfri.de/fa_xml/). Next year (2005) I start to
  # develop a server side solution for LX-Office ELSTER under Linux and 
  # WINDOWS based on this c-code.
  #
  # You need to download WINSTON from http://www.felfri.de/winston/
  # There (http://www.felfri.de/winston/download.htm) you'll find instructions 
  # about WINSTON under Linux WINE
  # More infos about Winstons API: http://www.felfri.de/winston/schnittstellen.htm
  my $azr ='';
  my $file = ''; # Filename for Winstonfile
  $file .= 'U'; # 1. char 'U' = USTVA
       
  SWITCH: { # 2. and 3. char 01-12= Month 41-44= Quarter (azr:Abrechnungszeitraum)
    	$form->{duetyp} eq "01" && do {
    	                                $azr = "01";
					last SWITCH;
    					};
    	$form->{duetyp} eq "02" && do {
    	                                $azr = "02";
					last SWITCH;
    					};
    	$form->{duetyp} eq "03" && do {
    	                                $azr = "03";
					last SWITCH;
    					};
    	$form->{duetyp} eq "04" && do {
    	                                $azr = "04";
					last SWITCH;
    					};
    	$form->{duetyp} eq "05" && do {
    	                                $azr = "05";
					last SWITCH;
    					};
    	$form->{duetyp} eq "06" && do {
    	                                $azr = "06";
					last SWITCH;
    					};
    	$form->{duetyp} eq "07" && do {
    	                                $azr = "07";
					last SWITCH;
    					};
    	$form->{duetyp} eq "08" && do {
    	                                $azr = "08";
					last SWITCH;
    					};
    	$form->{duetyp} eq "09" && do {
    	                                $azr = "09";
					last SWITCH;
    					};
    	$form->{duetyp} eq "10" && do {
    	                                $azr = "10";
					last SWITCH;
    					};
    	$form->{duetyp} eq "11" && do {
    	                                $azr = "11";
					last SWITCH;
    					};
    	$form->{duetyp} eq "12" && do {
    	                                $azr = "12";
					last SWITCH;
    					};
    	$form->{duetyp} eq "A" && do {
    	                                $azr = "41";
					last SWITCH;
    					};
    	$form->{duetyp} eq "B" && do {
    	                                $azr = "42";
					last SWITCH;
    					};
    	$form->{duetyp} eq "C" && do {
    	                                $azr = "43";
					last SWITCH;
    					};
    	$form->{duetyp} eq "D" && do {
    	                                $azr = "44";
					last SWITCH;
    					};
                                   do { 
                                        $form->error("Ung�ltiger Anmeldezeitraum.\n
                                        Sie k�nnen f�r ELSTER nur einen monatlichen oder 
                                        quartalsweisen Anmeldezeitraum ausw�hlen.");
                                        }; 
  }

  $file .= $azr;      
  #4. and 5. char = year modulo 100
  $file .= sprintf("%02d", $form->{year}%100);

  #6. to 18. char = Elstersteuernummer
  #Beispiel: Steuernummer in Bayern 
  #111/222/33334 ergibt f�r UStVA Jan 2004: U01049111022233334
      
  $file .= $form->{elsterFFFF};
  $file .= $form->{elstersteuernummer};

  #file suffix

  $file .= '.xml';
  $form->{elsterfile} = $file;
      
  #Calculations
      
  my $k51 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"51"})); # Ums�tze zu 16% USt 
  my $k86 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"86"})); # Ums�tze zu 7% USt 
  my $k97 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"97"})); # 16% Steuerpflichtige innergemeinsachftliche Erwerbe
  my $k93 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"93"})); # 16% Steuerpflichtige innergemeinsachftliche Erwerbe
  my $k94 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"94"})); # neuer Fahrzeuge von Lieferern
  my $k66 = $form->parse_amount(\%myconfig, $form->{"66"}) * 100;# Vorsteuer 7% plus 16% 
  my $k83 = $form->parse_amount(\%myconfig, $form->{"67"}) * 100;# Ums�tze zu 7% USt 
  my $k96 = $form->parse_amount(\%myconfig, $form->{"96"}) * 100;#        
  #
  # Now build the xml content
  # 
      
  $form->{elster}= qq|<?xml version="1.0" encoding="ISO-8859-1" ?>
<!-- Diese Datei ist mit Lx-Office $form->{version} generiert -->
<WinstonAusgang>
 <Formular Typ="UST"></Formular>
 <Ordnungsnummer>$form->{elstersteuernummer}</Ordnungsnummer>
 <AnmeldeJahr>$form->{year}</AnmeldeJahr>
 <AnmeldeZeitraum>$azr</AnmeldeZeitraum>
  |;
 
  $form->{elster} .= qq|<Kennzahl Nr="51">$k51</Kennzahl>\n| if ($k51 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="86">$k86</Kennzahl>\n| if ($k86 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="97">$k97</Kennzahl>\n| if ($k97 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="93">$k93</Kennzahl>\n| if ($k93 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="94">$k94</Kennzahl>\n| if ($k94 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="96">$k96</Kennzahl>\n| if ($k96 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="66">$k66</Kennzahl>\n| if ($k66 ne '0');
  $form->{elster} .= qq|<Kennzahl Nr="83">$k83</Kennzahl>\n| if ($k83 ne '0');
  $form->{elster} .= qq|\n</WinstonAusgang>\n\n|;
  
  #$form->header;
  #print qq|$form->{elsterfile}|;
  #print qq|$form->{elster}|;
  $SIG{INT} = 'IGNORE';
  
  &save_winston;
}


sub save_winston {
  my $elster = $form->{elster};
  my $elsterfile = $form->{elsterfile};
  open(OUT, ">-") or $form->error("STDOUT : $!");
    print OUT qq|Content-Type: application/file;
Content-Disposition: attachment; filename="$elsterfile"\n\n|;
    print OUT $elster;
  close(OUT);
}

sub continue {
# allow Symbolic references just here:
no strict 'refs'; 
&{$form->{nextsub}};
use strict 'refs';
}

sub back { &{$form->{lastsub}} };

sub elster_hash {
  my $finanzamt = USTVA::query_finanzamt(\%myconfig, \%$form);
  return $finanzamt
}

sub test {
# biegt nur den Testeintrag in Programm->Test auf eine Routine um

$form->header;
&elster_send;
}


sub elster_send {
  #read config
  my $elster_conf = &elster_conf();
  &elster_xml();
  use Cwd;
  $form->{cwd} = cwd();
  $form->{tmpdir} = $form->{cwd} . '/' . $elster_conf->{'path'};
  $form->{tmpfile} = $elster_conf->{'err'};
  my $caller = $elster_conf->{'call'}[0];    
  
  chdir("$form->{tmpdir}") or $form->error($form->cleanup."chdir : $!");
  my $send= "faxmlsend $caller -config etc/faxmlsend.cnf -xml faxmlsend.xml -tt faxmlsend.tt -debug";

  system("$send > $form->{tmpfile}");
  $form->{tmpdir} .= "$elster_conf->{'path'}/";
  $form->{tmpfile} = "faxmlsend.err";
  $form->error($form->cleanup."faxmlsend : OFD meldet: Error 404 \n Internetseite nicht vorhanden") if ($? eq '1024');
  $form->error($form->cleanup."faxmlsend : No such File: faxmlsend.xml \n Fehlernummer: $? \n Problem beim �ffnen der faxmlsend.xml") if ($?);
  # foreach my $line (&elster_feedback("$elster_conf->{'path'}")){
  #   print qq|$line\n|;
  # }
  print qq|Log:<br>|;
  #for (my $i=0; $i<= )
  &elster_readlog();  
  print qq|\n ende\n|;
}


sub elster_readlog {
  my $elster_conf = &elster_conf();
  open(LOG, "$elster_conf->{'logfile'}") or $form->error("$elster_conf->{'logfile'}: $!");
  print qq|<listing>|;
  my $log='';
  my $xml='';
  my $tmp='';
  while (<LOG>){
    my $i = 0;
    #$_ =~ s/</&lt\;/;
    #$_ =~ s/>/&gt\;/;
    $_ =~ s/\s+//mg;
    #$_ =~ s/\015\012//mg;
    $_ =~ s/</\n</mg;
    #$_ =~ s/\n\n+//mg;
    if ($_ =~ /^\d\d\d\d\d\d/g){
      $log .= qq|$_<br>|;
    #} elsif ($_ =~ /(<([^\/]*?)>)/ ) {
    } elsif ($_ =~ /(<([^\/].*?)>(.*))/g ) {
      #$xml .= qq|$2 = $3\n\n|;
      #$_ =~ s/\015\012//mg;
      $_=~ s/\s+//;
      $xml .= qq|$_\n|;
      
    } else {
      $tmp .= qq|$_<br>|;
    }
    $i++;
  }
  #second parse
  #my $var='';
  #while (<$xml>){
  #  $var .= qq|$2 = $3\n\n|;
  #}
  #print qq|$log|;
  print qq|$xml|;
  print qq|</listing>|;
 # $_=$log;
 #  s{<(\w+)\b([^<>]*)>
 #    ((?:.(?!</?\1\b))*.)
 #      (<\1>) }
 #   { print "markup=",$1," args=",$2," enclosed=",$3," final=",$4 ; "" }gsex;
  close LOG;
}


sub elster_feedback {
  my ($file) = @_;
  my @content = ();
  print qq|feedback:<br>|;
  if (-f "$file") {
    open(FH, "$file");
      @content = <FH>;
    close(FH);
  }
  return(@content);              
}


sub elster_conf {
  my $elster_conf = {
          'path'    => 'elster',
          'prg'     => 'faxmlsend',
          'err'	    => 'faxmlsend.err',
          'ttfile'  => 'faxmlsend.tt',
          'xmlfile' => 'faxmlsend.xml',
          'cline'   => '-tt $ttfile -xml $xmlfile',
          'call'    => ['send', 'protokoll', 'anmeldesteuern'],
          'logfile' => 'log/faxmlsend.log',
          'conffile' => 'faxmlsend.cnf',
          'debug'   => '-debug'
  };
  return $elster_conf;


}

sub elster_xml {

  my $elster_conf = &elster_conf();
#  $k51 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"51"})); # Ums�tze zu 16% USt 
#  $k86 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"86"})); # Ums�tze zu 7% USt 
#  $k97 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"97"})); # 16% Steuerpflichtige innergemeinsachftliche Erwerbe
#  $k93 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"93"})); # 16% Steuerpflichtige innergemeinsachftliche Erwerbe
#  $k94 = sprintf("%d", $form->parse_amount(\%myconfig, $form->{"94"})); # neuer Fahrzeuge von Lieferern
#  $k66 = $form->parse_amount(\%myconfig, $form->{"66"}) * 100;# Vorsteuer 7% plus 16% 
#  $k83 = $form->parse_amount(\%myconfig, $form->{"67"}) * 100;# Ums�tze zu 7% USt 
#  $k96 = $form->parse_amount(\%myconfig, $form->{"96"}) * 100;#        

  my $TransferHeader = qq|<?xml version="1.0" encoding="ISO-8859-1"?>
<?xml-stylesheet type="text/xsl" href="..\\Stylesheet\\ustva.xsl"?>
<Elster xmlns="http://www.elster.de/2002/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.elster.de/2002/XMLSchema
..\\Schemata\\elster_UStA_200501_extern.xsd">
   <TransferHeader version="7">
      <Verfahren>ElsterAnmeldung</Verfahren>
      <DatenArt>UStVA</DatenArt>
      <Vorgang>send-NoSig</Vorgang>
      <Testmerker>700000004</Testmerker>
      <HerstellerID>74931</HerstellerID>
      <DatenLieferant>Helmut</DatenLieferant>
      <Datei>
        <Verschluesselung>PKCS#7v1.5</Verschluesselung>
        <Kompression>GZIP</Kompression>
        <DatenGroesse>123456789012345678901234567890123456789012</DatenGroesse>
        <TransportSchluessel/>
      </Datei>
      <RC>
        <Rueckgabe>
          <Code>0</Code>
          <Text/>
        </Rueckgabe>
        <Stack>
          <Code>0</Code>
          <Text/>
        </Stack>
      </RC>
      <VersionClient/>
      <Zusatz>
        <Info>test</Info>
      </Zusatz>
   </TransferHeader>|;
  
  my $DatenTeil = qq|
   <DatenTeil>
      <Nutzdatenblock>
         <NutzdatenHeader version="9">
            <NutzdatenTicket>234234234</NutzdatenTicket>
            <Empfaenger id="F">9198</Empfaenger>
            <Hersteller>
               <ProduktName>ElsterAnmeldung</ProduktName>
               <ProduktVersion>V 1.4</ProduktVersion>
            </Hersteller>
            <DatenLieferant>String, der Lieferanteninfo enthaelt</DatenLieferant>
            <Zusatz>
              <Info>....</Info>
            </Zusatz>
         </NutzdatenHeader>
         <Nutzdaten>
            <!--die Version gibt Auskunft ueber das Jahr und die derzeit gueltige Versionsnummer-->
            <Anmeldungssteuern art="UStVA" version="200501">
               <DatenLieferant>
                  <Name>OFD Muenchen</Name>
                  <Strasse>Meiserstr. 6</Strasse>
                  <PLZ>80335</PLZ>
                  <Ort>M�nchen</Ort>
               </DatenLieferant>
               <Erstellungsdatum>20041127</Erstellungsdatum>
               <Steuerfall>
                  <Umsatzsteuervoranmeldung>
                     <Jahr>2005</Jahr>
                     <Zeitraum>01</Zeitraum>
                     <Steuernummer>9198011310134</Steuernummer>
                     <Kz09>74931*NameSteuerber.*Berufsbez.*089*59958327*Mandantenname</Kz09>
                  </Umsatzsteuervoranmeldung>
               </Steuerfall>
            </Anmeldungssteuern>
         </Nutzdaten>
      </Nutzdatenblock>
   </DatenTeil>
</Elster>\n|;

  #$DatenTeil .= qq|                              <Kz51>$k51</Kz51>\n| if ($k51 ne '0');
  #$DatenTeil .= qq|                              <Kz86>$k86</Kz86>\n| if ($k86 ne '0');
  #$DatenTeil .= qq|                              <Kz97>$k97</Kz97>\n| if ($k97 ne '0');
  #$DatenTeil .= qq|                              <Kz93>$k93</Kz93>\n| if ($k93 ne '0');
  #$DatenTeil .= qq|                              <Kz94>$k94</Kz94>\n| if ($k94 ne '0');
  #$DatenTeil .= qq|                              <Kz96>$k96</Kz96>\n| if ($k96 ne '0');
  #$DatenTeil .= qq|                              <Kz66>$k66</Kz66>\n| if ($k66 ne '0');
  #$DatenTeil .= qq|                              <Kz83>$k83</Kz83>\n| if ($k83 ne '0');

  my $filename = "$elster_conf->{'path'}/$elster_conf->{'xmlfile'}";
  open(XML, ">$elster_conf->{'path'}/$elster_conf->{'xmlfile'}") or $form->error("$filename : $!");
  print XML qq|$TransferHeader $DatenTeil|;
  close XML;
}

