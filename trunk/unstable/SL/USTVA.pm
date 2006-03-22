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
# Utilities for ustva 
#=====================================================================

package USTVA;

sub create_steuernummer {

  $part=$form->{part};
  $patterncount = $form->{patterncount};
  $delimiter = $form->{delimiter};
  $elster_pattern = $form->{elster_pattern};
  
  # rebuild steuernummer and elstersteuernummer
  # es gibt eine gespeicherte steuernummer $form->{steuernummer}
  # und die parts und delimiter 
  
  my $h =0;
  my $i =0;
  
  $steuernummer_new = $part; 
  $elstersteuernummer_new = $elster_FFFF;
  $elstersteuernummer_new .= '0';
  
  for ( $h = 1; $h < $patterncount; $h++) {
    $steuernummer_new .= qq|$delimiter|;
    for ( $i = 1; $i <= length($elster_pattern); $i++ ) {
      $steuernummer_new .=$form->{"part_$h\_$i"};
      $elstersteuernummer_new .=$form->{"part_$h\_$i"};
    }
  }
  if ($form->{steuernummer} ne $steuernummer_new){
    $form->{steuernummer} = $steuernummer_new;
    $form->{elstersteuernummer} = $elstersteuernummer_new;
    $form->{steuernummer_new} = $steuernummer_new;
  }
  return ($steuernummer_new, $elstersteuernummer_new);
}


sub steuernummer_input {

  ($elsterland, $elsterFFFF, $steuernummer ) = @_;
  
  $elster_land=$elsterland;
  $elster_FFFF=$elsterFFFF;
  $steuernummer = '0000000000' if ( $steuernummer eq '' );
  # $steuernummer formatieren (nur Zahlen) -> $stnr
  $stnr = $steuernummer;
  $stnr =~ s/\D+//g;
  
  #Pattern description Elstersteuernummer
  my %elster_STNRformat =  ( 
        'Mecklenburg Vorpommern' => 'FFF/BBB/UUUUP',	# '/' 3
        'Hessen' => '0FF BBB UUUUP',			# ' ' 3
        'Nordrhein Westfalen' => 'FFF/BBBB/UUUP',	# '/' 3
        'Schleswig Holstein' => 'FF BBB UUUUP',		# ' ' 2
        'Berlin' => 'FF/BBB/UUUUP',			# '/' 3
        'Th�ringen' => 'FFF/BBB/UUUUP',			# '/' 3
        'Sachsen' => 'FFF/BBB/UUUUP',			# '/' 3
        'Hamburg' => 'FF/BBB/UUUUP',			# '/' 3
        'Baden W�rtemberg' => 'FF/BBB/UUUUP',		# '/' 2
        'Sachsen Anhalt' => 'FFF/BBB/UUUUP',		# '/' 3
        'Saarland' => 'FFF/BBB/UUUUP',			# '/' 3
        'Bremen' => 'FF BBB UUUUP',			# ' ' 3
        'Bayern' => 'FFF/BBB/UUUUP',			# '/' 3
        'Rheinland Pfalz' => 'FF/BBB/UUUU/P',		# '/' 4
        'Niedersachsen' => 'FF/BBB/UUUUP',		# '/' 3
        'Brandenburg' => 'FFF/BBB/UUUUP',		# '/' 3
  );
  
  #split the pattern
  $elster_pattern = $elster_STNRformat{$elster_land};
  my @elster_pattern = split(' ', $elster_pattern);
  my $delimiter='&nbsp;';
  my $patterncount = @elster_pattern;
  if ($patterncount < 2) {
     @elster_pattern=();
     @elster_pattern = split('/', $elster_pattern);
     $delimiter='/';
     $patterncount = @elster_pattern;
  };

  # no we have an array of patternparts and a delimiter
  # create the first automated and fixed part and delimiter
  
  print qq|<b><font size="+1">|;  
  $part='';
  SWITCH: {
  $elster_pattern[0] eq 'FFF' && do {
                                     $part= substr($elster_FFFF,1,4);
                                     print qq|$part|;
                                     last SWITCH;
                                    };
  $elster_pattern[0] eq '0FF' && do {
                                     $part= '0'.substr($elster_FFFF,2,4);
                                     print qq|$part|;
                                     last SWITCH;
                                    };
  $elster_pattern[0] eq 'FF' && do {
                                     $part= substr($elster_FFFF,2,4);
                                     print qq|$part|;
                                     last SWITCH;
                                    };
                        1==1 && do {
                                    print qq|Fehler!|;;
                                    last SWITCH;
                                    };
  }
  #now the rest of the Steuernummer ...
  print qq|</b></font>|;
  print qq|\n
           <input type=hidden name="elster_pattern" value="$elster_pattern">
           <input type=hidden name="patterncount" value="$patterncount">
           <input type=hidden name="patternlength" value="$patterncount">
           <input type=hidden name="delimiter" value="$delimiter">
           <input type=hidden name="part" value="$part">  
  |;
  my $h =0;
  my $i =0;
  my $j = 0;
  $k = 0;

  for ( $h = 1; $h < $patterncount; $h++) {
    print qq|&nbsp;$delimiter&nbsp;\n|;
    for ( $i = 1; $i <= length($elster_pattern[$h] ); $i++ ) {
      print qq|<select name="part_$h\_$i">\n|;
      
      for ($j = 0; $j <= 9; $j++){
          print qq|      <option value="$j"|;
          if ($steuernummer ne ''){
            if ( $j eq substr($stnr, length($part) + $k, 1) ) {
              print  qq| selected|;
            }
          }
          print qq|>$j</option>\n|;
      }
      $k++;
      print qq|</select>\n|;
    }
  }
}

sub fa_auswahl {
  
  use SL::Form;

  # Referenz wird �bergeben, hash of hash wird nicht 
  # in neues  Hash kopiert, sondern direkt �ber die Referenz ver�ndert
  # Prototyp f�r diese Konstruktion

  my ($land, $elsterFFFF, $elster_init) = @_; #Referenz auf Hash von Hash �bergeben
  my $terminal ='';
  my $FFFF=$elsterFFFF;
  my $ffff='';
  my $checked='';
  $checked='checked' if ($elsterFFFF eq '' and $land eq '');
  #if ($ENV{HTTP_USER_AGENT} =~ /(mozilla|opera|w3m)/i){
  #$terminal='mozilla';
  #} elsif ($ENV{HTTP_USER_AGENT} =~ /(links|lynx)/i){
  #$terminal = 'lynx';
  #}
  
  
  #if ( $terminal eq 'mozilla' or $terminal eq 'js' ) {
          print qq|    
        <br>
        <script language="Javascript">
        function update_auswahl()
        {
                var elsterBLAuswahl = document.verzeichnis.elsterland_new;
                var elsterFAAuswahl = document.verzeichnis.elsterFFFF_new;

                elsterFAAuswahl.options.length = 0; // dropdown aufr�umen
                |;


           foreach $elster_land ( sort keys %$elster_init ) {
             print qq|
               if (elsterBLAuswahl.options[elsterBLAuswahl.selectedIndex].
               value == "$elster_land")
               {
               |;
             my $j=0;
             my %elster_land_fa =();
             $FFFF = '';
             for $FFFF ( keys %{ $elster_init->{$elster_land} } ) {
                $elster_land_fa{$FFFF} = $elster_init->{$elster_land}->{$FFFF}->[0]; 
             }
                        foreach $ffff ( sort {
           $elster_land_fa{$a} cmp $elster_land_fa{$b}
           } keys(%elster_land_fa)) {
               print qq|
                   elsterFAAuswahl.options[$j] = new Option("$elster_land_fa{$ffff} ($ffff)","$ffff");|;
               $j++;
             }
             print qq|
               }|;
          }
          print qq| 
        }
        </script>

        <table width="100%">
          <tr>
            <td>
               Bundesland
            </td>
            <td>
              <select size="1" name="elsterland_new" onchange="update_auswahl()">|;
          if ($land eq ''){
            print qq|<option value="Auswahl" $checked>hier ausw�hlen...</option>\n|;
          }  
          foreach $elster_land ( sort keys %$elster_init ) {
             print qq|
                  <option value="$elster_land"|;
             if ($elster_land eq $land and $checked eq '') {
               print qq| selected|;
             }   
             print qq|>$elster_land</option>
             |;   
          }
          print qq|
            </td>
          </tr>
          |;

         my $elster_land = ''; 
         $elster_land = ( $land ne ''  ) ? $land:'';
           %elster_land_fa =();
           for $FFFF ( keys % { $elster_init->{$elster_land} } ) {
             $elster_land_fa{$FFFF} = $elster_init->{$elster_land}->{$FFFF}->[0]
           }
           
           print qq|
           <tr>
              <td>Finanzamt
              </td> 
              <td>
                 <select size="1" name="elsterFFFF_new">|;
           if ($elsterFFFF eq ''){   
           print qq|<option value="Auswahl" $checked>hier ausw�hlen...</option>|;
           }else {
               foreach $ffff ( sort {
               $elster_land_fa{$a} cmp $elster_land_fa{$b}
               } keys(%elster_land_fa)) {

               print qq|
                        <option value="$ffff"|;
               if ( $ffff eq $elsterFFFF and $checked eq '') {
               print qq| selected|;
                      }
               print qq|>$elster_land_fa{$ffff} ($ffff)</option>|;
                 }
          }
          print qq|
                 </td>
              </tr>
            </table>    
            </select>|;
        
}

sub info {
  my $msg = $_[0];

  if ($ENV{HTTP_USER_AGENT}) {
    $msg =~ s/\n/<br>/g;

    print qq|<body><h2 class=info>Hinweis</h2>

    <p><b>$msg</b>
    <br>
    <br>
    <hr>
    <input type=button value="zur�ck" onClick="history.go(-1)">
    </body>
    |;

    exit;

  } else {
  
    if ($form->{error_function}) {
      &{ $form->{error_function} }($msg);
    } else {
      die "Hinweis: $msg\n";
    }
  }
  
}
                                                                        
sub stichtag {
  # noch nicht fertig
  # soll mal eine Erinnerungsfunktion f�r USTVA Abgaben werden, die automatisch 
  # den Termin der n�chsten USTVA anzeigt.
  # 
  #
  my ($today, $FA_dauerfrist, $FA_voranmeld) = @_;
  #$today zerlegen:
  
  #$today =today * 1;
  $today =~ /(\d\d\d\d)(\d\d)(\d\d)/;
  $year   = $1;
  $month  = $2;
  $day    = $3;
  $yy     = $year;
  $mm     = $month;
  $yymmdd = "$year$month$day" * 1;
  $mmdd   = "$month$day" * 1;
  $stichtag = '';
  #$tage_bis = '1234';
  #$ical = '...vcal format';  
  
  #if ($FA_voranmeld eq 'month'){
    
  %liste =  ("0110" => 'December',
             "0210" => 'January', 
             "0310" => 'February', 
             "0410" => 'March', 
             "0510" => 'April',
             "0610" => 'May',
             "0710" => 'June',
             "0810" => 'July',
             "0910" => 'August',
             "1010" => 'September',
             "1110" => 'October',
             "1210" => 'November'
            );

  #$mm += $dauerfrist
  #$month *= 1;
  $month += 1  if ( $day > 10 );
  $month = sprintf("%02d", $month);
  $stichtag = $year.$month."10"; 
  $ust_va = $month."10";
  
    
  foreach $date ( %liste ){
    $ust_va = $liste{$date} if ($date eq $stichtag);
  }
    
  
  #} elsif ($FA_voranmeld eq 'quarter'){
  #1;
  
  #}
  
  #@stichtag = ('10.04.2004', '10.05.2004');
  
  #@liste = ['0110', '0210', '0310', '0410', '0510', '0610', '0710', '0810', '0910',
  #          '1010', '1110', '1210', ];
  #                                                                                                                                                             
  #foreach $key (@liste){
  #  #if ($ddmm < ('0110' * 1));
  #  if ($ddmm ){}
  #  $stichtag = $liste[$key - 1] if ($ddmm > $key);
  #
  #}
  #
  #$stichtag =~ /([\d]\d)(\d\d)$/
  #$stichtag = "$1.$2.$yy"
  #$stichtag=$1;
  return ($stichtag, $description, $tage_bis, $ical);
}

sub query_finanzamt {
  
  my ($myconfig, $form) =@_;
  my $dbh = $form->dbconnect($myconfig) or $self->error(DBI->errstr);
  #Test, if table finanzamt exist
  my $table= 'finanzamt';
  my $filename= "sql/$table.sql";

  my $tst = $dbh->prepare("SELECT * FROM $table");
  $tst->execute ;
  if ( $DBI::err ) {
    #There is no table, read the table from sql/finanzamt.sql
    print qq|<p>Bitte warten, Tabelle $table wird einmalig in Datenbank: 
    $myconfig->{dbname} als Benutzer: $myconfig->{dbuser} hinzugef�gt...</p>|;
    process_query($form, $dbh, $filename)||$self->error(DBI->errstr);
    #execute second last call
    my $dbh = $form->dbconnect($myconfig) or $self->error(DBI->errstr);
    $dbh->disconnect();
  };
  $tst->finish();
  #$dbh->disconnect();
  
  my @vars = (
         'FA_Land_Nr',					#  0
         'FA_BUFA_Nr',					#  1 
         #'FA_Verteiler',				#  2
         'FA_Name',					#  3 
         'FA_Strasse',					#  4
         'FA_PLZ',					#  5
         'FA_Ort',					#  6
         'FA_Telefon',					#  7
         'FA_Fax',					#  8 
         'FA_PLZ_Grosskunden', 				#  9
         'FA_PLZ_Postfach', 				# 10
         'FA_Postfach',					# 11
         'FA_BLZ_1',					# 12
         'FA_Kontonummer_1',				# 13
         'FA_Bankbezeichnung_1',			# 14
         #'FA_BankIBAN_1',				# 15
         #'FA_BankBIC_1',				# 16
         #'FA_BankInhaber_BUFA_Nr_1',			# 17
         'FA_BLZ_2',					# 18
         'FA_Kontonummer_2',    			# 19
         'FA_Bankbezeichnung_2', 			# 20 
         #'FA_BankIBAN_2',				# 21
         #'FA_BankBIC_2',				# 22
         #'FA_BankInhaber_BUFA_Nr_2',			# 23
         'FA_Oeffnungszeiten',				# 24
         'FA_Email',					# 25
         'FA_Internet'					# 26
         #'FA_zustaendige_Hauptstelle_BUFA_Nr',		# 27
         #'FA_zustaendige_vorgesetzte_Finanzbehoerde'	# 28
         );

  my $field = join(', ', @vars);
  
  my $query = "SELECT $field FROM finanzamt ORDER BY FA_Land_nr";
  my $sth = $dbh->prepare($query) or $self->error($dbh->errstr);
  $sth->execute || $form->dberror($query);
  my $array_ref = $sth->fetchall_arrayref(  );
  my $land = '';
  foreach my $row ( @$array_ref ) {  
    my $FA_finanzamt = $row;
    $land = 'Schleswig Holstein' if ( @$FA_finanzamt[0] eq '1' );
    $land = 'Hamburg' if ( @$FA_finanzamt[0] eq '2' );
    $land = 'Niedersachsen' if ( @$FA_finanzamt[0] eq '3' );
    $land = 'Bremen' if ( @$FA_finanzamt[0] eq '4' );
    $land = 'Nordrhein Westfalen' if ( @$FA_finanzamt[0] eq '5' );
    $land = 'Hessen' if ( @$FA_finanzamt[0] eq '6' );
    $land = 'Rheinland Pfalz' if ( @$FA_finanzamt[0] eq '7' );
    $land = 'Baden W�rtemberg' if ( @$FA_finanzamt[0] eq '8' );
    $land = 'Bayern' if ( @$FA_finanzamt[0] eq '9' );
    $land = 'Saarland' if ( @$FA_finanzamt[0] eq '10' );
    $land = 'Berlin' if ( @$FA_finanzamt[0] eq '11' );
    $land = 'Brandenburg' if ( @$FA_finanzamt[0] eq '12' );
    $land = 'Mecklenburg Vorpommern' if ( @$FA_finanzamt[0] eq '13' );
    $land = 'Sachsen' if ( @$FA_finanzamt[0] eq '14' );
    $land = 'Sachsen Anhalt' if ( @$FA_finanzamt[0] eq '15' );
    $land = 'Th�ringen' if ( @$FA_finanzamt[0] eq '16' );
    
    my $ffff = @$FA_finanzamt[1];
        
    my $rec = {};
    $rec->{$land} = $ffff;     

    shift @$row;
    shift @$row;

    $finanzamt{$land}{$ffff} = [ @$FA_finanzamt ] ;
  } 

  $sth->finish();
  $dbh->disconnect();
  return \%finanzamt;

}


sub process_query {
# Copyright D. Simander -> SL::Form under Gnu GPL.
  my ($form, $dbh, $filename) = @_;
  
#  return unless (-f $filename);
  
  open(FH, "$filename") or $form->error("$filename : $!\n");
  my $query = "";
  my $sth;
  my @quote_chars;

  while (<FH>) {
    # Remove DOS and Unix style line endings.
    s/[\r\n]//g;

    # don't add comments or empty lines
    next if /^(--.*|\s+)$/;

    for (my $i = 0; $i < length($_); $i++) {
      my $char = substr($_, $i, 1);

      # Are we inside a string?
      if (@quote_chars) {
        if ($char eq $quote_chars[-1]) {
          pop(@quote_chars);
        }
        $query .= $char;

      } else {
        if (($char eq "'") || ($char eq "\"")) {
          push(@quote_chars, $char);

        } elsif ($char eq ";") {
          # Query is complete. Send it.

          $sth = $dbh->prepare($query);
          $sth->execute || $form->dberror($query);
          $sth->finish;

          $char = "";
          $query = "";
        }

        $query .= $char;
      }
    }
  }

  close FH;

}



1;


