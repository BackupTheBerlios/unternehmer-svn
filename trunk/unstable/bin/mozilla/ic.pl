#=====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#
#=====================================================================
# SQL-Ledger, Accounting
# Copyright (c) 2001
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
#======================================================================
#
# Inventory Control module
#
#======================================================================


use SL::IC;

require "$form->{path}/io.pl";

1;
# end of main

sub add {

  $form->{title} = $locale->text('Add ' . ucfirst $form->{item});

  $form->{callback} = "$form->{script}?action=add&item=$form->{item}&path=$form->{path}&login=$form->{login}&password=$form->{password}" unless $form->{callback};

  $form->{unit} = ($form->{item} eq 'service') ? $locale->text('hr') : $locale->text('ea');

  &link_part;
  &display_form;

}

sub search {

  $form->{title} = (ucfirst $form->{searchitems})."s";
  $form->{title} = $locale->text($form->{title});

  # switch for backward sorting
  $form->{revers} = 0;
  # memory for which table was sort at last time
  $form->{lastsort} = "";
  # counter for added entries to top100
  $form->{ndxs_counter} = 0;

# $locale->text('Parts')
# $locale->text('Services')

  # use JavaScript Calendar or not
  $form->{jsscript} = $jscalendar;
  $jsscript = "";    
  if ($form->{jsscript}) 
  {
    # with JavaScript Calendar
    $button1 = qq|
       <td><input name=transdatefrom id=transdatefrom size=11 title="$myconfig{dateformat}"></td>
       <td><input type=button name=transdatefrom id="trigger1" value=|.$locale->text('button').qq|></td>
      |;
     $button2 = qq|
       <td><input name=transdateto id=transdateto size=11 title="$myconfig{dateformat}"></td>
       <td><input type=button name=transdateto name=transdateto id="trigger2" value=|.$locale->text('button').qq|></td>
     |;
    #write Trigger
    $jsscript = Form->write_trigger(\%myconfig,"2","transdatefrom","BL","trigger1","transdateto","BL","trigger2");
   }
   else
   {
      # without JavaScript Calendar
      $button1 = qq|
                              <td><input name=transdatefrom id=transdatefrom size=11 title="$myconfig{dateformat}"></td>|;
      $button2 = qq|
                              <td><input name=transdateto id=transdateto size=11 title="$myconfig{dateformat}"></td>|;
    }

  unless ($form->{searchitems} eq 'service') {

    $onhand = qq|
            <input name=itemstatus class=radio type=radio value=onhand>&nbsp;|.$locale->text('On Hand').qq|
            <input name=itemstatus class=radio type=radio value=short>&nbsp;|.$locale->text('Short').qq|
|;

    $makemodel = qq|
        <tr>
          <th align=right nowrap>|.$locale->text('Make').qq|</th>
          <td><input name=make size=20></td>
          <th align=right nowrap>|.$locale->text('Model').qq|</th>
          <td><input name=model size=20></td>
        </tr>
|;

    $serialnumber = qq|
          <th align=right nowrap>|.$locale->text('Serial Number').qq|</th>
          <td><input name=serialnumber size=20></td>
|;

    $l_serialnumber = qq|
        <td><input name=l_serialnumber class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Serial Number').qq|</td>
|;

  }

  if ($form->{searchitems} eq 'assembly') {

    $form->{title} = $locale->text('Assemblies');

    $toplevel = qq|
        <tr>
	  <td></td>
          <td colspan=3>
	  <input name=null class=radio type=radio value=1 checked>&nbsp;|.$locale->text('Top Level').qq|
	  <input name=bom class=checkbox type=checkbox value=1>&nbsp;|.$locale->text('Individual Items').qq|
          </td>
        </tr>
|;

    $bought = qq|
	<tr>
	  <td></td>
	  <td colspan=3>
	    <table>
	      <tr>
	        <td>
		  <table>
		    <tr>
		      <td><input name=sold class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Sold').qq|</td>
		    </tr>
		    <tr>
		      <td colspan=2><hr size=1 noshade></td>
		    </tr>
		    <tr>
		      <td><input name=ordered class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Ordered').qq|</td>
		    </tr>
		    <tr>
		      <td colspan=4><hr size=1 noshade></td>
		    </tr>
		    <tr>
		      <td><input name=quoted class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Quoted').qq|</td>
		    </tr>
		  </table>
		</td>
		<td width=5%>&nbsp;</td>
		<th>|.$locale->text('From').qq|</th>
                $button1
		<th>|.$locale->text('To').qq|</th>
                $button2
	      </tr>
	    </table>
	  </td>
	</tr>
|;

  } else {

     $bought = qq|
        <tr>
          <td></td>
          <td colspan=3>
	    <table>
	      <tr>
	        <td>
		  <table>
		    <tr>
		      <td><input name=bought class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Bought').qq|</td>
		      <td><input name=sold class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Sold').qq|</td>
		    </tr>
		    <tr>
		      <td colspan=4><hr size=1 noshade></td>
		    </tr>
		    <tr>
		      <td><input name=onorder class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('On Order').qq|</td>
		      <td><input name=ordered class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Ordered').qq|</td>
		    </tr>
		    <tr>
		      <td colspan=4><hr size=1 noshade></td>
		    </tr>
		    <tr>
		      <td><input name=rfq class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('RFQ').qq|</td>
		      <td><input name=quoted class=checkbox type=checkbox value=1></td>
		      <td nowrap>|.$locale->text('Quoted').qq|</td>
		    </tr>
		  </table>
		</td>
		<td width=5%>&nbsp;</td>
		<td>
		  <table>
		    <tr>
		      <th>|.$locale->text('From').qq|</th>
		      $button1
		      <th>|.$locale->text('To').qq|</th>
		      $button2
		    </tr>
		  </table>
		</td>
	      </tr>
	    </table>
	  </td>
	</tr>
|;
  }

  $form->header;

  print qq|
<body>

<form method=post action=$form->{script}>

<input type=hidden name=searchitems value=$form->{searchitems}>
<input type=hidden name=title value="$form->{title}">

<input type=hidden name=revers value="$form->{revers}">
<input type=hidden name=lastsort value="$form->{lastsort}">

<table width="100%">
  <tr><th class=listtop>$form->{title}</th></tr>
  <tr height="5"></tr>
  <tr valign=top>
    <td>
      <table>
        <tr>
          <th align=right nowrap>|.$locale->text('Number').qq|</th>
          <td><input name=partnumber size=20></td>
        </tr>
        <tr>
          <th align=right nowrap>|.$locale->text('Description').qq|</th>
          <td colspan=3><input name=description size=40></td>
        </tr>
	<tr>
          <th align=right nowrap>|.$locale->text('Group').qq|</th>
          <td><input name=partsgroup size=20></td>
	  $serialnumber
	</tr>
	$makemodel
        <tr>
          <th align=right nowrap>|.$locale->text('Drawing').qq|</th>
          <td><input name=drawing size=20></td>
          <th align=right nowrap>|.$locale->text('Microfiche').qq|</th>
          <td><input name=microfiche size=20></td>
        </tr>
	$toplevel
        <tr>
          <td></td>
          <td colspan=3>
            <input name=itemstatus class=radio type=radio value=active checked>&nbsp;|.$locale->text('Active').qq|
	    $onhand
            <input name=itemstatus class=radio type=radio value=obsolete>&nbsp;|.$locale->text('Obsolete').qq|
            <input name=itemstatus class=radio type=radio value=orphaned>&nbsp;|.$locale->text('Orphaned').qq|
	  </td>
	</tr>
	$bought
        <tr>
	  <td></td>
          <td colspan=3>
	    <hr size=1 noshade>
	  </td>
	</tr>
	<tr>
          <th align=right nowrap>|.$locale->text('Include in Report').qq|</th>
          <td colspan=3>
            <table>
              <tr>
                <td><input name=l_partnumber class=checkbox type=checkbox value=Y checked>&nbsp;|.$locale->text('Number').qq|</td>
		<td><input name=l_description class=checkbox type=checkbox value=Y checked>&nbsp;|.$locale->text('Description').qq|</td>
		$l_serialnumber
		<td><input name=l_unit class=checkbox type=checkbox value=Y checked>&nbsp;|.$locale->text('Unit of measure').qq|</td>
	      </tr>
	      <tr>
                <td><input name=l_listprice class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('List Price').qq|</td>
		<td><input name=l_sellprice class=checkbox type=checkbox value=Y checked>&nbsp;|.$locale->text('Sell Price').qq|</td>
		<td><input name=l_lastcost class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Last Cost').qq|</td>
		<td><input name=l_linetotal class=checkbox type=checkbox value=Y checked>&nbsp;|.$locale->text('Line Total').qq|</td>
	      </tr>
	      <tr>
                <td><input name=l_priceupdate class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Updated').qq|</td>
		<td><input name=l_bin class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Bin').qq|</td>
		<td><input name=l_rop class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('ROP').qq|</td>
		<td><input name=l_weight class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Weight').qq|</td>
              </tr>
	      <tr>
                <td><input name=l_image class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Image').qq|</td>
		<td><input name=l_drawing class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Drawing').qq|</td>
		<td><input name=l_microfiche class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Microfiche').qq|</td>
		<td><input name=l_partsgroup class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Group').qq|</td>
              </tr>
	      <tr>
                <td><input name=l_subtotal class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('Subtotal').qq|</td>
		<td><input name=l_soldtotal class=checkbox type=checkbox value=Y>&nbsp;|.$locale->text('soldtotal').qq|</td>
	      </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr><td colspan=4><hr size=3 noshade></td></tr>
</table>

$jsscript

<input type=hidden name=nextsub value=generate_report>

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input type=hidden name=revers value="$form->{revers}">
<input type=hidden name=lastsort value="$form->{lastsort}">

<input type=hidden name=ndxs_counter value="$form->{ndxs_counter}">

<br>
<input class=submit type=submit name=action value="|.$locale->text('Continue').qq|">
<input class=submit type=submit name=action value="|.$locale->text('TOP100').qq|">
</form>

</body>
</html>
|;
}#end search() 


sub choice {

  $form->{title} = $locale->text('Top 100 hinzufuegen');
       
  $form->header; 
       
print qq|
  <body>

  <form method=post action=$form->{script}>

  <input type=hidden name=searchitems value=$form->{searchitems}>
  <input type=hidden name=title value="$form->{title}">

  <input type=hidden name=revers value="$form->{revers}">
  <input type=hidden name=lastsort value="$form->{lastsort}">|;

      
print qq|
      <table>
	<tr class=listheading>
         <th class=listheading nowrap>|.$locale->text('Number').qq|</th>
         <th class=listheading nowrap>|.$locale->text('Description').qq|</th>
        </tr>
        <tr valign=top>
         <td><input type=text name=partnumber size=20 value=></td>
         <td><input type=text name=description size=30 value=></td>
       </tr>
      </table>
     <br>|;
     
print qq|

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input type=hidden name=itemstatus value="$form->{itemstatus}">
<input type=hidden name=l_linetotal value="$form->{l_linetotal}">
<input type=hidden name=l_partnumber value="$form->{l_partnumber}">
<input type=hidden name=l_description value="$form->{l_description}">
<input type=hidden name=l_onhand value="$form->{l_onhand}">
<input type=hidden name=l_unit value="$form->{l_unit}">
<input type=hidden name=l_sellprice value="$form->{l_sellprice}">
<input type=hidden name=l_linetotalsellprice value="$form->{l_linetotalsellprice}">
<input type=hidden name=sort value="$form->{sort}">
<input type=hidden name=revers value="$form->{revers}">
<input type=hidden name=lastsort value="$form->{lastsort}">

<input type=hidden name=bom value="$form->{bom}">
<input type=hidden name=titel value="$form->{titel}">
<input type=hidden name=searchitems value="$form->{searchitems}">

<input type=hidden name=row value=$j>

<input type=hidden name=nextsub value=item_selected>

<input type=hidden name=test value=item_selected>

<input name=lastndx type=hidden value=$lastndx>

<input name=ndxs_counter type=hidden value=$form->{ndxs_counter}>

<input name=extras type=hidden value=$form->{extras}>|;

# if choice set data
if ($form->{ndx})
  {
    for($i=0;$i<$form->{ndxs_counter};$i++)
    { 
      # prepeare data 
      $partnumber=$form->{"totop100_partnumber_$j"};
      $description=$form->{"totop100_description_$j"};
      $unit=$form->{"totop100_unit_$j"};
      $sellprice=$form->{"totop100_sellprice_$j"};
      $soldtotal=$form->{"totop100_soldtotal_$j"};

      # insert data into top100
      push @{$form->{parts}},{number => "",partnumber => "$partnumber",description => "$description",unit => "$unit",sellprice => "$sellprice", soldtotal => "$soldtotal"};
    }#rof
  }#fi

  $totop100 = "";

  # set data for next page
  if (($form->{ndxs_counter})>0)
  {
    for($i=1;($i<$form->{ndxs_counter}+1);$i++)
    {
      $partnumber=$form->{"totop100_partnumber_$i"};
      $description=$form->{"totop100_description_$i"};
      $unit=$form->{"totop100_unit_$i"};
      $sellprice=$form->{"totop100_sellprice_$i"};
      $soldtotal=$form->{"totop100_soldtotal_$i"};
      
      $totop100 .= qq|
<input type=hidden name=totop100_partnumber_$i value=$form->{"totop100_partnumber_$i"}>
<input type=hidden name=totop100_description_$i value=$form->{"totop100_description_$i"}>
<input type=hidden name=totop100_unit_$i value=$form->{"totop100_unit_$i"}>
<input type=hidden name=totop100_sellprice_$i value=$form->{"totop100_sellprice_$i"}>
<input type=hidden name=totop100_soldtotal_$i value=$form->{"totop100_soldtotal_$i"}>
      |;
    }#rof
  }#fi

print $totop100;

print qq|
     <input class=submit type=submit name=action value="|.$locale->text('list').qq|"> 
    </form>

   </body>
  </html>|;
}#end choice



sub list {

  # get parts for 
  if (($form->{partnumber} eq "") and ($form->{description} eq "")) 
  {
    IC->get_parts(\%myconfig, \%$form, "");  
  }
  else 
  {
    if ((!($form->{partnumber} eq "")) and ($form->{description} eq ""))
    {
      IC->get_parts(\%myconfig, \%$form, "partnumber");  
    }
    else 
    {
      if (($form->{partnumber} eq "") and (!($form->{description} eq "")))
      {
        IC->get_parts(\%myconfig, \%$form, "description");  
      }
      else
      {
        IC->get_parts(\%myconfig, \%$form, "all");
      }#fi
    }#fi
  }#fi
  
  $form->{title} = $locale->text('Top 100 hinzufuegen');
  
  $form->header;

print qq|
<body>
  <form method=post action=ic.pl>
    <table width=100%>
     <tr>
      <th class=listtop colspan=6>|.$locale->text('choice part').qq|</th>
     </tr>
        <tr height="5"></tr>
	<tr class=listheading>
	  <th>&nbsp;</th>
	  <th class=listheading>|.$locale->text('Number').qq|</th>
	  <th class=listheading>|.$locale->text('Description').qq|</th>
	  <th class=listheading>|.$locale->text('Unit of measure').qq|</th>
	  <th class=listheading>|.$locale->text('Sell Price').qq|</th>
	  <th class=listheading>|.$locale->text('soldtotal').qq|</th>
	</tr>|;
  
  my $j=0;
  my $i=$form->{rows};

  for ($j=1; $j<=$i; $j++){

    print qq|
        <tr class=listrow1>|;
          if ($j==1) {
	    print qq|
	    <td><input name=ndx class=radio type=radio value=$j checked></td>|;
	  }
	  else {
	  print qq|
	  <td><input name=ndx class=radio type=radio value=$j></td>|;
	  }
	  print qq|
	  <td><input name="new_partnumber_$j" type=hidden value="$form->{"partnumber_$j"}">$form->{"partnumber_$j"}</td>
	  <td><input name="new_description_$j" type=hidden value="$form->{"description_$j"}">$form->{"description_$j"}</td>
	  <td><input name="new_unit_$j" type=hidden value="$form->{"unit_$j"}">$form->{"unit_$j"}</td>
	  <td><input name="new_sellprice_$j" type=hidden value="$form->{"sellprice_$j"}">$form->{"sellprice_$j"}</td>
	  <td><input name="new_soldtotal_$j" type=hidden value="$form->{"soldtotal_$j"}">$form->{"soldtotal_$j"}</td>
        </tr>

	<input name="new_id_$j" type=hidden value="$form->{"id_$j"}">|;
  }

print qq|

</table>

<br>


<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input type=hidden name=itemstatus value="$form->{itemstatus}">
<input type=hidden name=l_linetotal value="$form->{l_linetotal}">
<input type=hidden name=l_partnumber value="$form->{l_partnumber}">
<input type=hidden name=l_description value="$form->{l_description}">
<input type=hidden name=l_onhand value="$form->{l_onhand}">
<input type=hidden name=l_unit value="$form->{l_unit}">
<input type=hidden name=l_sellprice value="$form->{l_sellprice}">
<input type=hidden name=l_linetotalsellprice value="$form->{l_linetotalsellprice}">
<input type=hidden name=sort value="$form->{sort}">
<input type=hidden name=revers value="$form->{revers}">
<input type=hidden name=lastsort value="$form->{lastsort}">

<input type=hidden name=bom value="$form->{bom}">
<input type=hidden name=titel value="$form->{titel}">
<input type=hidden name=searchitems value="$form->{searchitems}">

<input type=hidden name=row value=$j>

<input type=hidden name=nextsub value=item_selected>

<input name=lastndx type=hidden value=$lastndx>

<input name=ndxs_counter type=hidden value=$form->{ndxs_counter}>|;


$totop100 = "";

if (($form->{ndxs_counter})>0)
  {
    for($i=1;($i<$form->{ndxs_counter}+1);$i++)
    {
      $j1=$form->{"totop100_partnumber_$i"};
      $j2=$form->{"totop100_description_$i"};
      $j3=$form->{"totop100_unit_$i"};
      $j4=$form->{"totop100_sellprice_$i"};
      $j5=$form->{"totop100_soldtotal_$i"};
      
      $partnumber=$j1;
      $description=$j2;
      $unit=$j3;
      $sellprice=$j4;
      $soldtotal=$j5;

      $totop100 .= qq|
<input type=hidden name=totop100_partnumber_$i value=$form->{"totop100_partnumber_$i"}>
<input type=hidden name=totop100_description_$i value=$form->{"totop100_description_$i"}>
<input type=hidden name=totop100_unit_$i value=$form->{"totop100_unit_$i"}>
<input type=hidden name=totop100_sellprice_$i value=$form->{"totop100_sellprice_$i"}>
<input type=hidden name=totop100_soldtotal_$i value=$form->{"totop100_soldtotal_$i"}>
      |;
    }#rof
  }#fi

print $totop100;

print qq|
<input class=submit type=submit name=action value="|.$locale->text('TOP100').qq|">

</form>
</body>
</html>
|;
}#end list()


sub top100 {

  if ($form->{ndx}){
    $form->{ndxs_counter}++;
  
    if ($form->{ndxs_counter}>0){

      $index = $form->{ndx};
    
      $j1 = $form->{"new_partnumber_$index"};
      $form->{"totop100_partnumber_$form->{ndxs_counter}"} =$j1;
      $j2 = $form->{"new_description_$index"};
      $form->{"totop100_description_$form->{ndxs_counter}"} = $j2;
      $j3 = $form->{"new_unit_$index"};
      $form->{"totop100_unit_$form->{ndxs_counter}"} = $j3;
      $j4 = $form->{"new_sellprice_$index"};
      $form->{"totop100_sellprice_$form->{ndxs_counter}"} = $j4;
      $j5 = $form->{"new_soldtotal_$index"};
      $form->{"totop100_soldtotal_$form->{ndxs_counter}"} = $j5;   
    }#fi
  }#fi
  &addtop100();
}#end top100


sub addtop100 {

  $form->{top100} = "top100";
  $form->{l_soldtotal} = "Y";
  $form->{soldtotal} = "soldtotal";
  $form->{sort} = "soldtotal";
  $form->{l_qty} = "N";
  $callback .= "&form->{top100}=$form->{top100}";
  $form->{l_linetotal} = "";
  $form->{revers} = 1;
  $form->{number} = "position";
  $form->{l_number} = "Y";
  
  my $totop100 = "";

  $form->{title} = $locale->text('Top 100');
 
  $revers = $form->{revers};
  $lastsort = $form->{lastsort};

  if (($form->{lastsort} eq "")&&($form->{sort} eq undef))
  {
      $form->{revers} = 0;
      $form->{lastsort} = "partnumber";
      $form->{sort} = "partnumber";
  }#fi

  $callback = "$form->{script}?action=top100&path=$form->{path}&login=$form->{login}&password=$form->{password}&searchitems=$form->{searchitems}&itemstatus=$form->{itemstatus}&bom=$form->{bom}&l_linetotal=$form->{l_linetotal}&title=".$form->escape($form->{title},1);

  # if we have a serialnumber limit search
  if ($form->{serialnumber} || $form->{l_serialnumber}) {
    $form->{l_serialnumber} = "Y";
    unless ($form->{bought} || $form->{sold} || $form->{rfq} || $form->{quoted}) {
      $form->{bought} = $form->{sold} = 1;
    }
  }
  IC->all_parts(\%myconfig, \%$form);

  if ($form->{itemstatus} eq 'active') {
    $option .= $locale->text('Active')." : ";
  }
  if ($form->{itemstatus} eq 'obsolete') {
    $option .= $locale->text('Obsolete')." : ";
  }
  if ($form->{itemstatus} eq 'orphaned') {
    $option .= $locale->text('Orphaned')." : ";
  }
  if ($form->{itemstatus} eq 'onhand') {
    $option .= $locale->text('On Hand')." : ";
    $form->{l_onhand} = "Y";
  }
  if ($form->{itemstatus} eq 'short') {
    $option .= $locale->text('Short')." : ";
    $form->{l_onhand} = "Y";
  }
  if ($form->{onorder}) {
    $form->{l_ordnumber} = "Y";
    $callback .= "&onorder=$form->{onorder}";
    $option .= $locale->text('On Order')." : ";
  }
  if ($form->{ordered}) {
    $form->{l_ordnumber} = "Y";
    $callback .= "&ordered=$form->{ordered}";
    $option .= $locale->text('Ordered')." : ";
  }
  if ($form->{rfq}) {
    $form->{l_quonumber} = "Y";
    $callback .= "&rfq=$form->{rfq}";
    $option .= $locale->text('RFQ')." : ";
  }
  if ($form->{quoted}) {
    $form->{l_quonumber} = "Y";
    $callback .= "&quoted=$form->{quoted}";
    $option .= $locale->text('Quoted')." : ";
  }
  if ($form->{bought}) {
    $form->{l_invnumber} = "Y";
    $callback .= "&bought=$form->{bought}";
    $option .= $locale->text('Bought')." : ";
  }
  if ($form->{sold}) {
    $form->{l_invnumber} = "Y";
    $callback .= "&sold=$form->{sold}";
    $option .= $locale->text('Sold')." : ";
  }
  if ($form->{bought} || $form->{sold} || $form->{onorder} || $form->{ordered} || $form->{rfq} || $form->{quoted}) {

    $form->{l_lastcost} = "";
    $form->{l_name} = "Y";
    if ($form->{transdatefrom}) {
      $callback .= "&transdatefrom=$form->{transdatefrom}";
      $option .= "\n<br>".$locale->text('From')."&nbsp;".$locale->date(\%myconfig, $form->{transdatefrom}, 1);
    }
    if ($form->{transdateto}) {
      $callback .= "&transdateto=$form->{transdateto}";
      $option .= "\n<br>".$locale->text('To')."&nbsp;".$locale->date(\%myconfig, $form->{transdateto}, 1);
    }
  }

  $option .= "<br>";

  if ($form->{partnumber}) {
    $callback .= "&partnumber=$form->{partnumber}";
    $option .= $locale->text('Number').qq| : $form->{partnumber}<br>|;
  }
  if ($form->{partsgroup}) {
    $callback .= "&partsgroup=$form->{partsgroup}";
    $option .= $locale->text('Group').qq| : $form->{partsgroup}<br>|;
  }
  if ($form->{serialnumber}) {
    $callback .= "&serialnumber=$form->{serialnumber}";
    $option .= $locale->text('Serial Number').qq| : $form->{serialnumber}<br>|;
  }
  if ($form->{description}) {
    $callback .= "&description=$form->{description}";
    $description = $form->{description};
    $description =~ s/
/<br>/g;
    $option .= $locale->text('Description').qq| : $form->{description}<br>|;
  }
  if ($form->{make}) {
    $callback .= "&make=$form->{make}";
    $option .= $locale->text('Make').qq| : $form->{make}<br>|;
  }
  if ($form->{model}) {
    $callback .= "&model=$form->{model}";
    $option .= $locale->text('Model').qq| : $form->{model}<br>|;
  }
  if ($form->{drawing}) {
    $callback .= "&drawing=$form->{drawing}";
    $option .= $locale->text('Drawing').qq| : $form->{drawing}<br>|;
  }
  if ($form->{microfiche}) {
    $callback .= "&microfiche=$form->{microfiche}";
    $option .= $locale->text('Microfiche').qq| : $form->{microfiche}<br>|;
  }
  if ($form->{l_soldtotal})
  {
    $callback .= "&soldtotal=$form->{soldtotal}";
    $option .= $locale->text('soldtotal').qq| : $form->{soldtotal}<br>|;
  }

  @columns = $form->sort_columns(qw(number partnumber description partsgroup bin onhand rop unit listprice linetotallistprice sellprice linetotalsellprice lastcost linetotallastcost priceupdate weight image drawing microfiche invnumber ordnumber quonumber name serialnumber soldtotal));

  if ($form->{l_linetotal}) {
    $form->{l_onhand} = "Y";
    $form->{l_linetotalsellprice} = "Y" if $form->{l_sellprice};
    if ($form->{l_lastcost}) {
      $form->{l_linetotallastcost} = "Y";
      if (($form->{searchitems} eq 'assembly') && !$form->{bom}) {
	$form->{l_linetotallastcost} = "";
      }
    }
    $form->{l_linetotallistprice} = "Y" if $form->{l_listprice};
  }

  if ($form->{searchitems} eq 'service') {
    # remove bin, weight and rop from list
    map { $form->{"l_$_"} = "" } qw(bin weight rop);

    $form->{l_onhand} = "";
    # qty is irrelevant unless bought or sold
    if ($form->{bought} || $form->{sold} || $form->{onorder} ||
        $form->{ordered} || $form->{rfq} || $form->{quoted}) {
      $form->{l_onhand} = "Y";
    } else {
      $form->{l_linetotalsellprice} = "";
      $form->{l_linetotallastcost} = "";
    }
  }

  $form->{l_lastcost} = "" if ($form->{searchitems} eq 'assembly' && !$form->{bom});

  foreach $item (@columns) {
    if ($form->{"l_$item"} eq "Y") {
      push @column_index, $item;

      # add column to callback
      $callback .= "&l_$item=Y";
    }
  }

  if ($form->{l_subtotal} eq 'Y') {
    $callback .= "&l_subtotal=Y";
  }

  $column_header{number} = qq|<th class=listheading nowrap>|.$locale->text('number').qq|</th>|;
  $column_header{partnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=partnumber&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('Number').qq|</a></th>|;
  $column_header{description} = qq|<th nowrap><a class=listheading href=$callback&sort=description&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('Description').qq|</a></th>|;
  $column_header{partsgroup} = qq|<th nowrap><a class=listheading href=$callback&sort=partsgroup>|.$locale->text('Group').qq|</a></th>|;
  $column_header{bin} = qq|<th><a class=listheading href=$callback&sort=bin>|.$locale->text('Bin').qq|</a></th>|;
  $column_header{priceupdate} = qq|<th nowrap><a class=listheading href=$callback&sort=priceupdate>|.$locale->text('Updated').qq|</a></th>|;
  $column_header{onhand} = qq|<th nowrap><a  class=listheading href=$callback&sort=onhand&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('Qty').qq|</th>|;
  $column_header{unit} = qq|<th class=listheading nowrap>|.$locale->text('Unit').qq|</th>|;
  $column_header{listprice} = qq|<th class=listheading nowrap>|.$locale->text('List Price').qq|</th>|;
  $column_header{lastcost} = qq|<th class=listheading nowrap>|.$locale->text('Last Cost').qq|</th>|;
  $column_header{rop} = qq|<th class=listheading nowrap>|.$locale->text('ROP').qq|</th>|;
  $column_header{weight} = qq|<th class=listheading nowrap>|.$locale->text('Weight').qq|</th>|;

  $column_header{invnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=invnumber>|.$locale->text('Invoice Number').qq|</a></th>|;
  $column_header{ordnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=ordnumber>|.$locale->text('Order Number').qq|</a></th>|;
  $column_header{quonumber} = qq|<th nowrap><a class=listheading href=$callback&sort=quonumber>|.$locale->text('Quotation').qq|</a></th>|;

  $column_header{name} = qq|<th nowrap><a class=listheading href=$callback&sort=name>|.$locale->text('Name').qq|</a></th>|;

  $column_header{sellprice} = qq|<th class=listheading nowrap>|.$locale->text('Sell Price').qq|</th>|;
  $column_header{linetotalsellprice} = qq|<th class=listheading nowrap>|.$locale->text('Extended').qq|</th>|;
  $column_header{linetotallastcost} = qq|<th class=listheading nowrap>|.$locale->text('Extended').qq|</th>|;
  $column_header{linetotallistprice} = qq|<th class=listheading nowrap>|.$locale->text('Extended').qq|</th>|;

  $column_header{image} = qq|<th class=listheading nowrap>|.$locale->text('Image').qq|</a></th>|;
  $column_header{drawing} = qq|<th nowrap><a class=listheading href=$callback&sort=drawing>|.$locale->text('Drawing').qq|</a></th>|;
  $column_header{microfiche} = qq|<th nowrap><a class=listheading href=$callback&sort=microfiche>|.$locale->text('Microfiche').qq|</a></th>|;

  $column_header{serialnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=serialnumber>|.$locale->text('Serial Number').qq|</a></th>|;
  $column_header{soldtotal} = qq|<th nowrap><a class=listheading href=$callback&sort=soldtotal&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('soldtotal').qq|</a></th>|;

  $form->header;
  $colspan = $#column_index + 1;

  print qq|
<body>

<table width=100%>
  <tr>
    <th class=listtop colspan=$colspan>$form->{title}</th>
  </tr>
  <tr height="5"></tr>

  <tr><td colspan=$colspan>$option</td></tr>

  <tr class=listheading>
|;

  map { print "\n$column_header{$_}" } @column_index;

  print qq|
  </tr>
  |;

  # add order to callback
  $form->{callback} = $callback .= "&sort=$form->{sort}";

  # escape callback for href
  $callback = $form->escape($callback);

  if (@{ $form->{parts} }) {
    $sameitem = $form->{parts}->[0]->{$form->{sort}};
  }
  # insert numbers for top100
  my $j=0;
  foreach $ref (@{ $form->{parts} }) {
    $j++;
    $ref->{number} = $j;
    }
  # if avaible -> insert choice here
  if (($form->{ndxs_counter})>0)
  {
    for($i=1;($i<$form->{ndxs_counter}+1);$i++)
    {
      $partnumber=$form->{"totop100_partnumber_$i"};
      $description=$form->{"totop100_description_$i"};
      $unit=$form->{"totop100_unit_$i"};
      $sellprice=$form->{"totop100_sellprice_$i"};
      $soldtotal=$form->{"totop100_soldtotal_$i"};
      
      $totop100 .= qq|
<input type=hidden name=totop100_partnumber_$i value=$form->{"totop100_partnumber_$i"}>
<input type=hidden name=totop100_description_$i value=$form->{"totop100_description_$i"}>
<input type=hidden name=totop100_unit_$i value=$form->{"totop100_unit_$i"}>
<input type=hidden name=totop100_sellprice_$i value=$form->{"totop100_sellprice_$i"}>
<input type=hidden name=totop100_soldtotal_$i value=$form->{"totop100_soldtotal_$i"}>
      |;
      # insert into list
      push @{$form->{parts}},{number => "",partnumber => "$partnumber",description => "$description",unit => "$unit",sellprice => "$sellprice", soldtotal => "$soldtotal"};
    }#rof
  }#fi
  # build data for columns
  foreach $ref (@{ $form->{parts} }) {

    if ($form->{l_subtotal} eq 'Y' && !$ref->{assemblyitem}) {
      if ($sameitem ne $ref->{$form->{sort}}) {
	&parts_subtotal;
	$sameitem = $ref->{$form->{sort}};
      }
    }
    
    $ref->{exchangerate} = 1 unless $ref->{exchangerate};
    $ref->{sellprice} *= $ref->{exchangerate};
    $ref->{listprice} *= $ref->{exchangerate};
    $ref->{lastcost} *= $ref->{exchangerate};

    # use this for assemblies
    $onhand = $ref->{onhand};

    $align = "left";
    if ($ref->{assemblyitem}) {
      $align = "right";
      $onhand = 0 if ($form->{sold});
    }

    $ref->{description} =~ s/
/<br>/g;

    $column_data{number} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{number}, '', "&nbsp;")."</td>";
    $column_data{partnumber} = "<td align=$align>$ref->{partnumber}&nbsp;</a></td>";    
    $column_data{description} = "<td>$ref->{description}&nbsp;</td>";
    $column_data{partsgroup} = "<td>$ref->{partsgroup}&nbsp;</td>";

    $column_data{onhand} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand}, '', "&nbsp;")."</td>";
    $column_data{sellprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{sellprice}, 2, "&nbsp;") . "</td>";
    $column_data{listprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{listprice}, 2, "&nbsp;") . "</td>";
    $column_data{lastcost} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{lastcost}, 2, "&nbsp;") . "</td>";

    $column_data{linetotalsellprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand} * $ref->{sellprice}, 2, "&nbsp;")."</td>";
    $column_data{linetotallastcost} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand} * $ref->{lastcost}, 2, "&nbsp;")."</td>";
    $column_data{linetotallistprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand} * $ref->{listprice}, 2, "&nbsp;")."</td>";

    if (!$ref->{assemblyitem}) {
      $totalsellprice += $onhand * $ref->{sellprice};
      $totallastcost += $onhand * $ref->{lastcost};
      $totallistprice += $onhand * $ref->{listprice};

      $subtotalonhand += $onhand;
      $subtotalsellprice += $onhand * $ref->{sellprice};
      $subtotallastcost += $onhand * $ref->{lastcost};
      $subtotallistprice += $onhand * $ref->{listprice};
    }

    $column_data{rop} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{rop}, '', "&nbsp;")."</td>";
    $column_data{weight} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{weight}, '', "&nbsp;")."</td>";
    $column_data{unit} = "<td>$ref->{unit}&nbsp;</td>";
    $column_data{bin} = "<td>$ref->{bin}&nbsp;</td>";
    $column_data{priceupdate} = "<td>$ref->{priceupdate}&nbsp;</td>";

    $column_data{invnumber} = ($ref->{module} ne 'oe') ? "<td><a href=$ref->{module}.pl?action=edit&type=invoice&id=$ref->{trans_id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{invnumber}</a></td>" : "<td>$ref->{invnumber}</td>";
    $column_data{ordnumber} = ($ref->{module} eq 'oe') ? "<td><a href=$ref->{module}.pl?action=edit&type=$ref->{type}&id=$ref->{trans_id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{ordnumber}</a></td>" : "<td>$ref->{ordnumber}</td>";
    $column_data{quonumber} = ($ref->{module} eq 'oe' && !$ref->{ordnumber}) ? "<td><a href=$ref->{module}.pl?action=edit&type=$ref->{type}&id=$ref->{trans_id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{quonumber}</a></td>" : "<td>$ref->{quonumber}</td>";

    $column_data{name} = "<td>$ref->{name}</td>";

    $column_data{image} = ($ref->{image}) ? "<td><a href=$ref->{image}><img src=$ref->{image} height=32 border=0></a></td>" : "<td>&nbsp;</td>";
    $column_data{drawing} = ($ref->{drawing}) ? "<td><a href=$ref->{drawing}>$ref->{drawing}</a></td>" : "<td>&nbsp;</td>";
    $column_data{microfiche} = ($ref->{microfiche}) ? "<td><a href=$ref->{microfiche}>$ref->{microfiche}</a></td>" : "<td>&nbsp;</td>";

    $column_data{serialnumber} = "<td>$ref->{serialnumber}</td>";

    $column_data{soldtotal} = "<td  align=right>$ref->{soldtotal}</td>";

    $i++; $i %= 2;
    print "<tr class=listrow$i>";

    map { print "\n$column_data{$_}" } @column_index;

    print qq|
    </tr>
|;
  }

  if ($form->{l_subtotal} eq 'Y') {
    &parts_subtotal;
  }#fi

  if ($form->{"l_linetotal"}) {
    map { $column_data{$_} = "<td>&nbsp;</td>" } @column_index;
    $column_data{linetotalsellprice} = "<th class=listtotal align=right>".$form->format_amount(\%myconfig, $totalsellprice, 2, "&nbsp;")."</th>";
    $column_data{linetotallastcost} = "<th class=listtotal align=right>".$form->format_amount(\%myconfig, $totallastcost, 2, "&nbsp;")."</th>";
    $column_data{linetotallistprice} = "<th class=listtotal align=right>".$form->format_amount(\%myconfig, $totallistprice, 2, "&nbsp;")."</th>";

    print "<tr class=listtotal>";

    map { print "\n$column_data{$_}" } @column_index;

    print qq|</tr>
    |;
  }

  print qq|
  <tr><td colspan=$colspan><hr size=3 noshade></td></tr>
</table>

|;

  print qq|

<br>

<form method=post action=$form->{script}>

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input type=hidden name=itemstatus value="$form->{itemstatus}">
<input type=hidden name=l_linetotal value="$form->{l_linetotal}">
<input type=hidden name=l_partnumber value="$form->{l_partnumber}">
<input type=hidden name=l_description value="$form->{l_description}">
<input type=hidden name=l_onhand value="$form->{l_onhand}">
<input type=hidden name=l_unit value="$form->{l_unit}">
<input type=hidden name=l_sellprice value="$form->{l_sellprice}">
<input type=hidden name=l_linetotalsellprice value="$form->{l_linetotalsellprice}">
<input type=hidden name=sort value="$form->{sort}">
<input type=hidden name=revers value="$form->{revers}">
<input type=hidden name=lastsort value="$form->{lastsort}">
<input type=hidden name=parts value="$form->{parts}">

<input type=hidden name=bom value="$form->{bom}">
<input type=hidden name=titel value="$form->{titel}">
<input type=hidden name=searchitems value="$form->{searchitems}">|;

  print $totop100;

  print qq|
    <input type=hidden name=ndxs_counter value="$form->{ndxs_counter}">
    
    <input class=submit type=submit name=action value="|.$locale->text('choice').qq|">|;


  if ($form->{menubar}) {
    require "$form->{path}/menu.pl";
    &menubar;
  }

  print qq|
  </form>

</body>
</html>
|;

}# end addtop100


sub generate_report {

  $revers = $form->{revers};
  $lastsort = $form->{lastsort};

  if (($form->{lastsort} eq "")&&($form->{sort} eq undef))
  {
      $form->{revers} = 0;
      $form->{lastsort} = "partnumber";
      $form->{sort} = "partnumber";
  }
  else
  { 
    # switch between backward sorting of tables
    if ($form->{lastsort} eq $form->{sort})
    {
      if ($form->{revers}==0)
      {
	$form->{revers} = 1;
      }
      else
      {
	$form->{revers} = 0;
      }#fi
    }
    else
    {
      $form->{revers}== 0;
      $form->{lastsort} = $form->{sort};
    }#fi
  }#fi

  $callback = "$form->{script}?action=generate_report&path=$form->{path}&login=$form->{login}&password=$form->{password}&searchitems=$form->{searchitems}&itemstatus=$form->{itemstatus}&bom=$form->{bom}&l_linetotal=$form->{l_linetotal}&title=".$form->escape($form->{title},1);


  # if we have a serialnumber limit search
  if ($form->{serialnumber} || $form->{l_serialnumber}) {
    $form->{l_serialnumber} = "Y";
    unless ($form->{bought} || $form->{sold} || $form->{rfq} || $form->{quoted}) {
      $form->{bought} = $form->{sold} = 1;
    }
  }

  IC->all_parts(\%myconfig, \%$form);


  if ($form->{itemstatus} eq 'active') {
    $option .= $locale->text('Active')." : ";
  }
  if ($form->{itemstatus} eq 'obsolete') {
    $option .= $locale->text('Obsolete')." : ";
  }
  if ($form->{itemstatus} eq 'orphaned') {
    $option .= $locale->text('Orphaned')." : ";
  }
  if ($form->{itemstatus} eq 'onhand') {
    $option .= $locale->text('On Hand')." : ";
    $form->{l_onhand} = "Y";
  }
  if ($form->{itemstatus} eq 'short') {
    $option .= $locale->text('Short')." : ";
    $form->{l_onhand} = "Y";
  }
  if ($form->{onorder}) {
    $form->{l_ordnumber} = "Y";
    $callback .= "&onorder=$form->{onorder}";
    $option .= $locale->text('On Order')." : ";
  }
  if ($form->{ordered}) {
    $form->{l_ordnumber} = "Y";
    $callback .= "&ordered=$form->{ordered}";
    $option .= $locale->text('Ordered')." : ";
  }
  if ($form->{rfq}) {
    $form->{l_quonumber} = "Y";
    $callback .= "&rfq=$form->{rfq}";
    $option .= $locale->text('RFQ')." : ";
  }
  if ($form->{quoted}) {
    $form->{l_quonumber} = "Y";
    $callback .= "&quoted=$form->{quoted}";
    $option .= $locale->text('Quoted')." : ";
  }
  if ($form->{bought}) {
    $form->{l_invnumber} = "Y";
    $callback .= "&bought=$form->{bought}";
    $option .= $locale->text('Bought')." : ";
  }
  if ($form->{sold}) {
    $form->{l_invnumber} = "Y";
    $callback .= "&sold=$form->{sold}";
    $option .= $locale->text('Sold')." : ";
  }
  if ($form->{bought} || $form->{sold} || $form->{onorder} || $form->{ordered} || $form->{rfq} || $form->{quoted}) {

    $form->{l_lastcost} = "";
    $form->{l_name} = "Y";
    if ($form->{transdatefrom}) {
      $callback .= "&transdatefrom=$form->{transdatefrom}";
      $option .= "\n<br>".$locale->text('From')."&nbsp;".$locale->date(\%myconfig, $form->{transdatefrom}, 1);
    }
    if ($form->{transdateto}) {
      $callback .= "&transdateto=$form->{transdateto}";
      $option .= "\n<br>".$locale->text('To')."&nbsp;".$locale->date(\%myconfig, $form->{transdateto}, 1);
    }
  }

  $option .= "<br>";

  if ($form->{partnumber}) {
    $callback .= "&partnumber=$form->{partnumber}";
    $option .= $locale->text('Number').qq| : $form->{partnumber}<br>|;
  }
  if ($form->{partsgroup}) {
    $callback .= "&partsgroup=$form->{partsgroup}";
    $option .= $locale->text('Group').qq| : $form->{partsgroup}<br>|;
  }
  if ($form->{serialnumber}) {
    $callback .= "&serialnumber=$form->{serialnumber}";
    $option .= $locale->text('Serial Number').qq| : $form->{serialnumber}<br>|;
  }
  if ($form->{description}) {
    $callback .= "&description=$form->{description}";
    $description = $form->{description};
    $description =~ s/
/<br>/g;
    $option .= $locale->text('Description').qq| : $form->{description}<br>|;
  }
  if ($form->{make}) {
    $callback .= "&make=$form->{make}";
    $option .= $locale->text('Make').qq| : $form->{make}<br>|;
  }
  if ($form->{model}) {
    $callback .= "&model=$form->{model}";
    $option .= $locale->text('Model').qq| : $form->{model}<br>|;
  }
  if ($form->{drawing}) {
    $callback .= "&drawing=$form->{drawing}";
    $option .= $locale->text('Drawing').qq| : $form->{drawing}<br>|;
  }
  if ($form->{microfiche}) {
    $callback .= "&microfiche=$form->{microfiche}";
    $option .= $locale->text('Microfiche').qq| : $form->{microfiche}<br>|;
  }
  # table soldtotal aktive
  if ($form->{l_soldtotal})
  {
    $callback .= "&soldtotal=$form->{soldtotal}";
    $option .= $locale->text('soldtotal').qq| : $form->{soldtotal}<br>|;
  }

  @columns = $form->sort_columns(qw(partnumber description partsgroup bin onhand rop unit listprice linetotallistprice sellprice linetotalsellprice lastcost linetotallastcost priceupdate weight image drawing microfiche invnumber ordnumber quonumber name serialnumber soldtotal));

  if ($form->{l_linetotal}) {
    $form->{l_onhand} = "Y";
    $form->{l_linetotalsellprice} = "Y" if $form->{l_sellprice};
    if ($form->{l_lastcost}) {
      $form->{l_linetotallastcost} = "Y";
      if (($form->{searchitems} eq 'assembly') && !$form->{bom}) {
	$form->{l_linetotallastcost} = "";
      }
    }
    $form->{l_linetotallistprice} = "Y" if $form->{l_listprice};
  }

  if ($form->{searchitems} eq 'service') {
    # remove bin, weight and rop from list
    map { $form->{"l_$_"} = "" } qw(bin weight rop);

    $form->{l_onhand} = "";
    # qty is irrelevant unless bought or sold
    if ($form->{bought} || $form->{sold} || $form->{onorder} ||
        $form->{ordered} || $form->{rfq} || $form->{quoted}) {
      $form->{l_onhand} = "Y";
    } else {
      $form->{l_linetotalsellprice} = "";
      $form->{l_linetotallastcost} = "";
    }
  }

  $form->{l_lastcost} = "" if ($form->{searchitems} eq 'assembly' && !$form->{bom});

  foreach $item (@columns) {
    if ($form->{"l_$item"} eq "Y") {
      push @column_index, $item;

      # add column to callback
      $callback .= "&l_$item=Y";
    }
  }

  if ($form->{l_subtotal} eq 'Y') {
    $callback .= "&l_subtotal=Y";
  }
  $column_header{partnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=partnumber&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('Number').qq|</a></th>|;
  $column_header{description} = qq|<th nowrap><a class=listheading href=$callback&sort=description&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('Description').qq|</a></th>|;
  $column_header{partsgroup} = qq|<th nowrap><a class=listheading href=$callback&sort=partsgroup>|.$locale->text('Group').qq|</a></th>|;
  $column_header{bin} = qq|<th><a class=listheading href=$callback&sort=bin>|.$locale->text('Bin').qq|</a></th>|;
  $column_header{priceupdate} = qq|<th nowrap><a class=listheading href=$callback&sort=priceupdate>|.$locale->text('Updated').qq|</a></th>|;
  $column_header{onhand} = qq|<th nowrap><a  class=listheading href=$callback&sort=onhand&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('Qty').qq|</th>|;
  $column_header{unit} = qq|<th class=listheading nowrap>|.$locale->text('Unit').qq|</th>|;
  $column_header{listprice} = qq|<th class=listheading nowrap>|.$locale->text('List Price').qq|</th>|;
  $column_header{lastcost} = qq|<th class=listheading nowrap>|.$locale->text('Last Cost').qq|</th>|;
  $column_header{rop} = qq|<th class=listheading nowrap>|.$locale->text('ROP').qq|</th>|;
  $column_header{weight} = qq|<th class=listheading nowrap>|.$locale->text('Weight').qq|</th>|;

  $column_header{invnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=invnumber>|.$locale->text('Invoice Number').qq|</a></th>|;
  $column_header{ordnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=ordnumber>|.$locale->text('Order Number').qq|</a></th>|;
  $column_header{quonumber} = qq|<th nowrap><a class=listheading href=$callback&sort=quonumber>|.$locale->text('Quotation').qq|</a></th>|;

  $column_header{name} = qq|<th nowrap><a class=listheading href=$callback&sort=name>|.$locale->text('Name').qq|</a></th>|;

  $column_header{sellprice} = qq|<th class=listheading nowrap>|.$locale->text('Sell Price').qq|</th>|;
  $column_header{linetotalsellprice} = qq|<th class=listheading nowrap>|.$locale->text('Extended').qq|</th>|;
  $column_header{linetotallastcost} = qq|<th class=listheading nowrap>|.$locale->text('Extended').qq|</th>|;
  $column_header{linetotallistprice} = qq|<th class=listheading nowrap>|.$locale->text('Extended').qq|</th>|;

  $column_header{image} = qq|<th class=listheading nowrap>|.$locale->text('Image').qq|</a></th>|;
  $column_header{drawing} = qq|<th nowrap><a class=listheading href=$callback&sort=drawing>|.$locale->text('Drawing').qq|</a></th>|;
  $column_header{microfiche} = qq|<th nowrap><a class=listheading href=$callback&sort=microfiche>|.$locale->text('Microfiche').qq|</a></th>|;

  $column_header{serialnumber} = qq|<th nowrap><a class=listheading href=$callback&sort=serialnumber>|.$locale->text('Serial Number').qq|</a></th>|;
  $column_header{soldtotal} = qq|<th nowrap><a class=listheading href=$callback&sort=soldtotal&revers=$form->{revers}&lastsort=$form->{lastsort}>|.$locale->text('soldtotal').qq|</a></th>|;

  $form->header;
  $colspan = $#column_index + 1;

  print qq|
<body>

<table width=100%>
  <tr>
    <th class=listtop colspan=$colspan>$form->{title}</th>
  </tr>
  <tr height="5"></tr>

  <tr><td colspan=$colspan>$option</td></tr>

  <tr class=listheading>
|;

  map { print "\n$column_header{$_}" } @column_index;

  print qq|
  </tr>
  |;


  # add order to callback
  $form->{callback} = $callback .= "&sort=$form->{sort}";

  # escape callback for href
  $callback = $form->escape($callback);

  if (@{ $form->{parts} }) {
    $sameitem = $form->{parts}->[0]->{$form->{sort}};
  }

  foreach $ref (@{ $form->{parts} }) {

    if ($form->{l_subtotal} eq 'Y' && !$ref->{assemblyitem}) {
      if ($sameitem ne $ref->{$form->{sort}}) {
	&parts_subtotal;
	$sameitem = $ref->{$form->{sort}};
      }
    }

    $ref->{exchangerate} = 1 unless $ref->{exchangerate};
    $ref->{sellprice} *= $ref->{exchangerate};
    $ref->{listprice} *= $ref->{exchangerate};
    $ref->{lastcost} *= $ref->{exchangerate};

    # use this for assemblies
    $onhand = $ref->{onhand};

    $align = "left";
    if ($ref->{assemblyitem}) {
      $align = "right";
      $onhand = 0 if ($form->{sold});
    }

    $ref->{description} =~ s/
/<br>/g;

    $column_data{partnumber} = "<td align=$align><a href=$form->{script}?action=edit&id=$ref->{id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{partnumber}&nbsp;</a></td>";
    $column_data{description} = "<td>$ref->{description}&nbsp;</td>";
    $column_data{partsgroup} = "<td>$ref->{partsgroup}&nbsp;</td>";

    $column_data{onhand} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand}, '', "&nbsp;")."</td>";
    $column_data{sellprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{sellprice}, 2, "&nbsp;") . "</td>";
    $column_data{listprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{listprice}, 2, "&nbsp;") . "</td>";
    $column_data{lastcost} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{lastcost}, 2, "&nbsp;") . "</td>";

    $column_data{linetotalsellprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand} * $ref->{sellprice}, 2, "&nbsp;")."</td>";
    $column_data{linetotallastcost} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand} * $ref->{lastcost}, 2, "&nbsp;")."</td>";
    $column_data{linetotallistprice} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{onhand} * $ref->{listprice}, 2, "&nbsp;")."</td>";

    if (!$ref->{assemblyitem}) {
      $totalsellprice += $onhand * $ref->{sellprice};
      $totallastcost += $onhand * $ref->{lastcost};
      $totallistprice += $onhand * $ref->{listprice};

      $subtotalonhand += $onhand;
      $subtotalsellprice += $onhand * $ref->{sellprice};
      $subtotallastcost += $onhand * $ref->{lastcost};
      $subtotallistprice += $onhand * $ref->{listprice};
    }

    $column_data{rop} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{rop}, '', "&nbsp;")."</td>";
    $column_data{weight} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{weight}, '', "&nbsp;")."</td>";
    $column_data{unit} = "<td>$ref->{unit}&nbsp;</td>";
    $column_data{bin} = "<td>$ref->{bin}&nbsp;</td>";
    $column_data{priceupdate} = "<td>$ref->{priceupdate}&nbsp;</td>";

    $column_data{invnumber} = ($ref->{module} ne 'oe') ? "<td><a href=$ref->{module}.pl?action=edit&type=invoice&id=$ref->{trans_id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{invnumber}</a></td>" : "<td>$ref->{invnumber}</td>";
    $column_data{ordnumber} = ($ref->{module} eq 'oe') ? "<td><a href=$ref->{module}.pl?action=edit&type=$ref->{type}&id=$ref->{trans_id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{ordnumber}</a></td>" : "<td>$ref->{ordnumber}</td>";
    $column_data{quonumber} = ($ref->{module} eq 'oe' && !$ref->{ordnumber}) ? "<td><a href=$ref->{module}.pl?action=edit&type=$ref->{type}&id=$ref->{trans_id}&path=$form->{path}&login=$form->{login}&password=$form->{password}&callback=$callback>$ref->{quonumber}</a></td>" : "<td>$ref->{quonumber}</td>";

    $column_data{name} = "<td>$ref->{name}</td>";

    $column_data{image} = ($ref->{image}) ? "<td><a href=$ref->{image}><img src=$ref->{image} height=32 border=0></a></td>" : "<td>&nbsp;</td>";
    $column_data{drawing} = ($ref->{drawing}) ? "<td><a href=$ref->{drawing}>$ref->{drawing}</a></td>" : "<td>&nbsp;</td>";
    $column_data{microfiche} = ($ref->{microfiche}) ? "<td><a href=$ref->{microfiche}>$ref->{microfiche}</a></td>" : "<td>&nbsp;</td>";

    $column_data{serialnumber} = "<td>$ref->{serialnumber}</td>";

    $column_data{soldtotal} = "<td align=right>".$form->format_amount(\%myconfig, $ref->{soldtotal}, '', "&nbsp;")."</td>";

    $i++; $i %= 2;
    print "<tr class=listrow$i>";

    map { print "\n$column_data{$_}" } @column_index;

    print qq|
    </tr>
|;

  }


  if ($form->{l_subtotal} eq 'Y') {
    &parts_subtotal;
  }

  if ($form->{"l_linetotal"}) {
    map { $column_data{$_} = "<td>&nbsp;</td>" } @column_index;
    $column_data{linetotalsellprice} = "<th class=listtotal align=right>".$form->format_amount(\%myconfig, $totalsellprice, 2, "&nbsp;")."</th>";
    $column_data{linetotallastcost} = "<th class=listtotal align=right>".$form->format_amount(\%myconfig, $totallastcost, 2, "&nbsp;")."</th>";
    $column_data{linetotallistprice} = "<th class=listtotal align=right>".$form->format_amount(\%myconfig, $totallistprice, 2, "&nbsp;")."</th>";

    print "<tr class=listtotal>";

    map { print "\n$column_data{$_}" } @column_index;

    print qq|</tr>
    |;
  }

  print qq|
  <tr><td colspan=$colspan><hr size=3 noshade></td></tr>
</table>

|;


  print qq|

<br>

<form method=post action=$form->{script}>

<input name=callback type=hidden value="$form->{callback}">

<input type=hidden name=item value=$form->{searchitems}>

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>|;

  print qq|
  <input class=submit type=submit name=action value="|.$locale->text('Add').qq|">|;


  if ($form->{menubar}) {
    require "$form->{path}/menu.pl";
    &menubar;
  }

  print qq|
  </form>

</body>
</html>
|;

}#end generate_report



sub parts_subtotal {

  map { $column_data{$_} = "<td>&nbsp;</td>" } @column_index;
  $subtotalonhand = 0 if ($form->{searchitems} eq 'assembly' && $form->{bom});

  $column_data{onhand} = "<th class=listsubtotal align=right>".$form->format_amount(\%myconfig, $subtotalonhand, '', "&nbsp;")."</th>";

  $column_data{linetotalsellprice} = "<th class=listsubtotal align=right>".$form->format_amount(\%myconfig, $subtotalsellprice, 2, "&nbsp;")."</th>";
  $column_data{linetotallistprice} = "<th class=listsubtotal align=right>".$form->format_amount(\%myconfig, $subtotallistprice, 2, "&nbsp;")."</th>";
  $column_data{linetotallastcost} = "<th class=listsubtotal align=right>".$form->format_amount(\%myconfig, $subtotallastcost, 2, "&nbsp;")."</th>";

  $subtotalonhand = 0;
  $subtotalsellprice = 0;
  $subtotallistprice = 0;
  $subtotallastcost = 0;

  print "<tr class=listsubtotal>";

  map { print "\n$column_data{$_}" } @column_index;

  print qq|
  </tr>
|;

}



sub edit {

  IC->get_part(\%myconfig, \%$form);

  $form->{title} = $locale->text('Edit '.ucfirst $form->{item});

  &link_part;
  &display_form;

}



sub link_part {

  IC->create_links("IC", \%myconfig, \%$form);
  # currencies 
  map { $form->{selectcurrency} .= "<option>$_\n" } split /:/, $form->{currencies};
  
  # parts and assemblies have the same links
  $item = $form->{item};
  if ($form->{item} eq 'assembly') {
    $item = 'part';
  }

  # build the popup menus
  $form->{taxaccounts} = "";
  foreach $key (keys %{ $form->{IC_links} }) {
    foreach $ref (@{ $form->{IC_links}{$key} }) {
      # if this is a tax field
      if ($key =~ /IC_tax/) {
	if ($key =~ /$item/) {
	  $form->{taxaccounts} .= "$ref->{accno} ";
	  $form->{"IC_tax_$ref->{accno}_description"} = "$ref->{accno}--$ref->{description}";

	  if ($form->{id}) {
	    if ($form->{amount}{$ref->{accno}}) {
	      $form->{"IC_tax_$ref->{accno}"} = "checked";
	    }
	  } else {
	    $form->{"IC_tax_$ref->{accno}"} = "checked";
	  }
	}
      } else {

	$form->{"select$key"} .= "<option $ref->{selected}>$ref->{accno}--$ref->{description}\n";
	if ($form->{amount}{$key} eq $ref->{accno}) {
	  $form->{$key} = "$ref->{accno}--$ref->{description}";
	}

      }
    }
  }
  chop $form->{taxaccounts};

  if (($form->{item} eq "part") || ($form->{item} eq "assembly")) {
    $form->{selectIC_income} = $form->{selectIC_sale};
    $form->{selectIC_expense} = $form->{selectIC_cogs};
    $form->{IC_income} = $form->{IC_sale};
    $form->{IC_expense} = $form->{IC_cogs};
  }

  delete $form->{IC_links};
  delete $form->{amount};

  
  $form->get_partsgroup(\%myconfig, {all => 1});
  $form->{partsgroup} = "$form->{partsgroup}--$form->{partsgroup_id}";
  if (@{ $form->{all_partsgroup} }) {
    $form->{selectpartsgroup} = qq|<option>\n|;
    map { $form->{selectpartsgroup} .= qq|<option value="$_->{partsgroup}--$_->{id}">$_->{partsgroup}\n| } @{ $form->{all_partsgroup} };
  }

    if ($form->{item} eq 'assembly') {

    foreach $i (1 .. $form->{assembly_rows}) {
      if ($form->{"partsgroup_id_$i"}) {
	$form->{"partsgroup_$i"} = qq|$form->{"partsgroup_$i"}--$form->{"partsgroup_id_$i"}|;
      }
    }
    $form->get_partsgroup(\%myconfig);
    
    if (@{ $form->{all_partsgroup} }) {
      $form->{selectassemblypartsgroup} = qq|<option>\n|;

      map { $form->{selectassemblypartsgroup} .= qq|<option value="$_->{partsgroup}--$_->{id}">$_->{partsgroup}\n| } @{ $form->{all_partsgroup} };
    }
  }
}



sub form_header {
  
  ($dec) = ($form->{sellprice} =~ /\.(\d+)/);
  $dec = length $dec;
  my $decimalplaces = ($dec > 2) ? $dec : 2;

  map { $form->{$_} = $form->format_amount(\%myconfig, $form->{$_}, $decimalplaces)} qw(listprice sellprice);

  ($dec) = ($form->{lastcost} =~ /\.(\d+)/);
  $dec = length $dec;
  my $decimalplaces = ($dec > 2) ? $dec : 2;

  $form->{lastcost} = $form->format_amount(\%myconfig, $form->{lastcost}, $decimalplaces);

  map { $form->{$_} = $form->format_amount(\%myconfig, $form->{$_}) } qw(weight rop stock);

  foreach $item (qw(partnumber description unit notes)) {
    $form->{$item} =~ s/\"/&quot;/g;
  }

  if (($rows = $form->numtextrows($form->{notes}, 40)) < 2) {
    $rows = 2;
  }

  $notes = qq|<textarea name=notes rows=$rows cols=40 wrap=soft>$form->{notes}</textarea>|;
  if (($rows = $form->numtextrows($form->{description}, 40)) > 1) {
    $description = qq|<textarea name="description" rows=$rows cols=40 wrap=soft>$form->{description}</textarea>|;
  } else {
    $description = qq|<input name=description size=40 value="$form->{description}">|;
  }

  foreach $item (split / /, $form->{taxaccounts}) {
    $form->{"IC_tax_$item"} = ($form->{"IC_tax_$item"}) ? "checked" : "";
  }

  # set option
  foreach $item (qw(IC IC_income IC_expense)) {
    if ($form->{$item}) {
      if ($form->{id} && $form->{orphaned}) {
	$form->{"select$item"} =~ s/ selected//;
	$form->{"select$item"} =~ s/option>\Q$form->{$item}\E/option selected>$form->{$item}/;
      } else {
	$form->{"select$item"} = qq|<option selected>$form->{$item}|;
      }
    }
  }
  if ($form->{selectpartsgroup}) {
    $form->{selectpartsgroup} = $form->unescape($form->{selectpartsgroup});
    $partsgroup = qq|<input type=hidden name=selectpartsgroup value="|.$form->escape($form->{selectpartsgroup},1).qq|">|;
    $form->{selectpartsgroup} =~ s/(<option value="\Q$form->{partsgroup}\E")/$1 selected/;

    $partsgroup .= qq|<select name=partsgroup>$form->{selectpartsgroup}</select>|;
    $group = $locale->text('Group');
  }
  # tax fields
  foreach $item (split / /, $form->{taxaccounts}) {
    $tax .= qq|
      <input class=checkbox type=checkbox name="IC_tax_$item" value=1 $form->{"IC_tax_$item"}>&nbsp;<b>$form->{"IC_tax_${item}_description"}</b>
      <br><input type=hidden name=IC_tax_${item}_description value="$form->{"IC_tax_${item}_description"}">
|;
  }

  $form->{obsolete} = "checked" if $form->{obsolete};

  $lastcost = qq|
 	      <tr>
                <th align="right" nowrap="true">|.$locale->text('Last Cost').qq|</th>
                <td><input name=lastcost size=11 value=$form->{lastcost}></td>
              </tr>
|;
  if (!$eur) {
    $linkaccounts = qq|
               <tr>
		<th align=right>|.$locale->text('Inventory').qq|</th>
		<td><select name=IC>$form->{selectIC}</select></td>
		<input name=selectIC type=hidden value="$form->{selectIC}">
	      </tr>|;
  }
  
  if ($form->{item} eq "part") {

    $linkaccounts .= qq|
	      <tr>
		<th align=right>|.$locale->text('Revenue').qq|</th>
		<td><select name=IC_income>$form->{selectIC_income}</select></td>
		<input name=selectIC_income type=hidden value="$form->{selectIC_income}">
	      </tr>
	      <tr>
		<th align=right>|.$locale->text('COGS').qq|</th>
		<td><select name=IC_expense>$form->{selectIC_expense}</select></td>
		<input name=selectIC_expense type=hidden value="$form->{selectIC_expense}">
	      </tr>
|;



    $weight = qq|
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('Weight').qq|</th>
		<td>
		  <table>
		    <tr>
		      <td>
			<input name=weight size=10 value=$form->{weight}>
		      </td>
		      <th>
			&nbsp;
			$form->{weightunit}
			<input type=hidden name=weightunit value=$form->{weightunit}>
		      </th>
		    </tr>
		  </table>
		</td>
	      </tr>
|;

  }


  if ($form->{item} eq "assembly") {

    $lastcost = "";

    $linkaccounts = qq|
	      <tr>
		<th align=right>|.$locale->text('Revenue').qq|</th>
		<td><select name=IC_income>$form->{selectIC_income}</select></td>
		<input name=selectIC_income type=hidden value="$form->{selectIC_income}">
	      </tr>
|;



    $weight = qq|
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('Weight').qq|</th>
		<td>
		  <table>
		    <tr>
		      <td>
			&nbsp;$form->{weight}
			<input type=hidden name=weight value=$form->{weight}>
		      </td>
		      <th>
			&nbsp;
			$form->{weightunit}
			<input type=hidden name=weightunit value=$form->{weightunit}>
		      </th>
		    </tr>
		  </table>
		</td>
	      </tr>
|;
    
  }

 
  if ($form->{item} eq "service") {
    
    $linkaccounts = qq|
	      <tr>
		<th align=right>|.$locale->text('Revenue').qq|</th>
		<td><select name=IC_income>$form->{selectIC_income}</select></td>
		<input name=selectIC_income type=hidden value="$form->{selectIC_income}">
	      </tr>
	      <tr>
		<th align=right>|.$locale->text('Expense').qq|</th>
		<td><select name=IC_expense>$form->{selectIC_expense}</select></td>
		<input name=selectIC_expense type=hidden value="$form->{selectIC_expense}">
	      </tr>
|;


  }


  if ($form->{item} ne 'service') {
    $n = ($form->{onhand} > 0) ? "1" : "0";
    $rop = qq|
	      <tr>
		<th align="right" nowrap>|.$locale->text('On Hand').qq|</th>
		<th align=left nowrap class="plus$n">&nbsp;|.$form->format_amount(\%myconfig, $form->{onhand}).qq|</th>
	      </tr>
|;

    if ($form->{item} eq 'assembly') {
      $rop .= qq|
              <tr>
	        <th align="right" nowrap>|.$locale->text('Stock').qq|</th>
		<td><input name=stock size=10 value=$form->{stock}></td>
	      </tr>
|;
    }

    $rop .= qq|
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('ROP').qq|</th>
		<td><input name=rop size=10 value=$form->{rop}></td>
	      </tr>
|;
    
    $bin = qq|
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('Bin').qq|</th>
		<td><input name=bin size=10 value=$form->{bin}></td>
	      </tr>
|;
    
    $imagelinks = qq|
  <tr>
    <td>
      <table width=100%>
        <tr>
	  <th align=right nowrap>|.$locale->text('Image').qq|</th>
	  <td><input name=image size=40 value="$form->{image}"></td>
	  <th align=right nowrap>|.$locale->text('Microfiche').qq|</th>
	  <td><input name=microfiche size=20 value="$form->{microfiche}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>|.$locale->text('Drawing').qq|</th>
	  <td><input name=drawing size=40 value="$form->{drawing}"></td>
	</tr>
      </table>
    </td>
  </tr>
|;

  }

  if ($form->{id}) {
    $obsolete = qq|
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('Obsolete').qq|</th>
		<td><input name=obsolete type=checkbox class=checkbox value=1 $form->{obsolete}></td>
	      </tr>
|;
  }
	$shopok=$form->{shop} == 1 ? "checked" : "";
        $obsolete .= qq|
              <tr>
                <th align=right nowrap>|.$locale->text('Shopartikel').qq|</th>
                <td><input class=checkbox type=checkbox name=shop value=1 $shopok></td>
             </tr>
|;


# type=submit $locale->text('Add Part')
# type=submit $locale->text('Add Service')
# type=submit $locale->text('Add Assembly')

# type=submit $locale->text('Edit Part')
# type=submit $locale->text('Edit Service')
# type=submit $locale->text('Edit Assembly')
  # use JavaScript Calendar or not
  $form->{jsscript} = $jscalendar;
  $jsscript = "";    
  if ($form->{jsscript}) 
  {
    # with JavaScript Calendar
    $button1 = qq|
       <td width="13"><input name=priceupdate id=priceupdate size=11  title="$myconfig{dateformat}" value="$form->{priceupdate}"></td>
       <td width="4" align="left"><input type=button name=priceupdate id="trigger1" value=|.$locale->text('button').qq|></td>
      |;
      #write Trigger
      $jsscript = Form->write_trigger(\%myconfig,"1","priceupdate","BL","trigger1","","","");
   }
   else
   {
      # without JavaScript Calendar
      $button1 = qq|
                              <td><input name=transdatefrom id=transdatefrom size=11 title="$myconfig{dateformat}"></td>|;
    }


  $form->header;

  print qq|
<body>

<form method=post action=$form->{script}>

<input name=id type=hidden value=$form->{id}>
<input name=item type=hidden value=$form->{item}>
<input name=title type=hidden value="$form->{title}">
<input name=makemodel type=hidden value="$form->{makemodel}">
<input name=alternate type=hidden value="$form->{alternate}">
<input name=onhand type=hidden value=$form->{onhand}>
<input name=orphaned type=hidden value=$form->{orphaned}>
<input name=taxaccounts type=hidden value="$form->{taxaccounts}">
<input name=rowcount type=hidden value=$form->{rowcount}>
<input name=eur type=hidden value=$eur>

<table width="100%">
  <tr>
    <th class=listtop>$form->{title}</th>
  </tr>
  <tr height="5"></tr>
  <tr>
    <td>
      <table width="100%">
        <tr valign=top>
          <th align=left>|.$locale->text('Number').qq|</th>
          <th align=left>|.$locale->text('Description').qq|</th>
          <th align=left>$group</th>
        </tr>
	<tr valign=top>
          <td><input name=partnumber value="$form->{partnumber}" size=20></td>
          <td>$description</td>
          <td>$partsgroup</td>
	  <input type=hidden name=oldpartsgroup value="$form->{oldpartsgroup}">
	</tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width="100%" height="100%">
        <tr valign=top>
          <td width=70%>
            <table width="100%" height="100%">
              <tr class="listheading">
                <th class="listheading" align="center" colspan=2>|.$locale->text('Link Accounts').qq|</th>
              </tr>
              $linkaccounts
              <tr>
                <th align="left">|.$locale->text('Notes').qq|</th>
              </tr>
              <tr>
                <td colspan=2>
                  $notes
                </td>
              </tr>
            </table>
          </td>
	  <td width="30%">
	    <table width="100%">
	      <tr>
                <th align="right" nowrap="true">|.$locale->text('Updated').qq|</th>
                $button1
              </tr>  
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('List Price').qq|</th>
		<td><input name=listprice size=11 value=$form->{listprice}></td>
	      </tr>
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('Sell Price').qq|</th>
		<td><input name=sellprice size=11 value=$form->{sellprice}></td>
	      </tr>
	      $lastcost
	      <tr>
		<th align="right" nowrap="true">|.$locale->text('Unit').qq|</th>
		<td><input name=unit size=5 value="$form->{unit}"></td>
	      </tr>
	      $weight
	      $rop
	      $bin
	      $obsolete
	    </table>
	  </td>
	</tr>
      </table>
    </td>
  </tr>
  $imagelinks
  
$jsscript
|;
}


sub form_footer {

  if ($form->{item} eq "assembly") {

    print qq|
	<tr>
	  <td>
            <table width="100%">
              <tr>
                <th colspan=2 align=right>|.$locale->text('Total').qq|&nbsp;</th>
                <th align=right>|.$form->format_amount(\%myconfig, $form->{assemblytotal}, 2).qq|</th>
              </tr>
            </table>
          </td>
        </tr>
        <input type=hidden name=assembly_rows value=$form->{assembly_rows}>
|;
  }

  print qq|
      <input type=hidden name=path value=$form->{path}>
      <input type=hidden name=login value=$form->{login}>
      <input type=hidden name=password value=$form->{password}>
      <input type=hidden name=callback value="$form->{callback}">
      <input type=hidden name=previousform value="$form->{previousform}">
      <input type=hidden name=taxaccount2 value="$form->{taxaccount2}">
      <input type=hidden name=vc value=$form->{vc}>
  <tr>
    <td><hr size=3 noshade></td>
  </tr>
</table>

<br>
<input class=submit type=submit name=action value="|.$locale->text('Update').qq|">
  |;

  unless ($form->{item} eq "service") {
    print qq|
      <input type=hidden name=makemodel_rows value=$form->{makemodel_rows}>
    |;
  }

  print qq|
      <input class=submit type=submit name=action value="|.$locale->text('Save').qq|">|;

  if ($form->{id}) {

    if (! $form->{previousform}) {
      print qq|
      <input class=submit type=submit name=action value="|.$locale->text('Save as new').qq|">|;
    }

    if ($form->{orphaned}) {
      if (! $form->{previousform}) {
	if ($form->{item} eq 'assembly') {
	  if (! $form->{onhand}) {
	    print qq|
      <input class=submit type=submit name=action value="|.$locale->text('Delete').qq|">|;
	  }
	} else {
	  print qq|
      <input class=submit type=submit name=action value="|.$locale->text('Delete').qq|">|;
	}
      }
    }
  }

  if (! $form->{previousform}) {
    if ($form->{menubar}) {
      require "$form->{path}/menu.pl";
      &menubar;
    }
  }

  print qq|

</form>

</body>
</html>
|;

}


sub makemodel_row {
  my ($numrows) = @_;

  $form->{"make_$i"} =~ s/\"/&quot;/g;
  $form->{"model_$i"} =~ s/\"/&quot;/g;

  print qq|
  <tr>
    <td>
      <table width=100%>
	<tr>
	  <th class="listheading">|.$locale->text('Make').qq|</th>
	  <th class="listheading">|.$locale->text('Model').qq|</th>
	</tr>
|;

  for $i (1 .. $numrows) {
    print qq|
	<tr>
	  <td width=50%><input name="make_$i" size=30 value="$form->{"make_$i"}"></td>
	  <td width=50%><input name="model_$i" size=30 value="$form->{"model_$i"}"></td>
	</tr>
|;
  }

  print qq|
      </table>
    </td>
  </tr>
|;

}


sub assembly_row {
  my ($numrows) = @_;

  @column_index = qw(runningnumber qty unit bom partnumber description partsgroup total);

  if ($form->{previousform}) {
    $nochange = 1;
    @column_index = qw(qty unit bom partnumber description partsgroup total);
  } else {
    # change callback
    $form->{old_callback} = $form->{callback};
    $callback = $form->{callback};
    $form->{callback} = "$form->{script}?action=display_form";

    # delete action
    map { delete $form->{$_} } qw(action header);

    $previousform = "";
    # save form variables in a previousform variable
    foreach $key (sort keys %$form) {
      # escape ampersands
      $form->{$key} =~ s/&/%26/g;
      $previousform .= qq|$key=$form->{$key}&|;
    }
    chop $previousform;
    $previousform = $form->escape($form->escape($previousform, 1));
    $form->{callback} = $callback;

    $form->{assemblytotal} = 0;
    $form->{weight} = 0;

  }
    $column_header{runningnumber} = qq|<th nowrap width=5%>|.$locale->text('No.').qq|</th>|;
    $column_header{qty} = qq|<th align=left nowrap width=10%>|.$locale->text('Qty').qq|</th>|;
    $column_header{unit} = qq|<th align=left nowrap width=5%>|.$locale->text('Unit').qq|</th>|;
    $column_header{partnumber} = qq|<th align=left nowrap width=20%>|.$locale->text('Number').qq|</th>|;
    $column_header{description} = qq|<th nowrap width=50%>|.$locale->text('Description').qq|</th>|;
    $column_header{total} = qq|<th align=right nowrap>|.$locale->text('Extended').qq|</th>|;
    $column_header{bom} = qq|<th>|.$locale->text('BOM').qq|</th>|;
    $column_header{partsgroup} = qq|<th>|.$locale->text('Group').qq|</th>|;

    print qq|
  <tr class=listheading>
    <th class=listheading>|.$locale->text('Individual Items').qq|</th>
  </tr>
  <tr>
    <td>
      <table width=100%>
        <tr>
|;

  map { print "\n$column_header{$_}" } @column_index;

  print qq|
        </tr>
|;

  for $i (1 .. $numrows) {
    $form->{"partnumber_$i"} =~ s/\"/&quot;/g;

    $linetotal = $form->round_amount($form->{"sellprice_$i"} * $form->{"qty_$i"}, 2);
    $form->{assemblytotal} += $linetotal;

    $form->{"qty_$i"} = $form->format_amount(\%myconfig, $form->{"qty_$i"});

    $linetotal = $form->format_amount(\%myconfig, $linetotal, 2);

    if (($i >= 1) && ($i == $numrows)) {

      if ($nochange) {
	map { $column_data{$_} = qq|<td></td>| } qw(qty unit partnumber description bom partsgroup);
      } else {

	map { $column_data{$_} = qq|<td></td>| } qw(runningnumber unit bom);

	$column_data{qty} = qq|<td><input name="qty_$i" size=5 value="$form->{"qty_$i"}"></td>|;
	$column_data{partnumber} = qq|<td><input name="partnumber_$i" size=15 value="$form->{"partnumber_$i"}"></td>|;
	$column_data{description} = qq|<td><input name="description_$i" size=40 value="$form->{"description_$i"}"></td>|;
	$column_data{partsgroup} = qq|<td><input name="partsgroup_$i" size=10 value="$form->{"partsgroup_$i"}"></td>|;

      }

    } else {


      if ($form->{previousform}) {
	$column_data{partnumber} = qq|<td><input type=hidden name="partnumber_$i" value="$form->{"partnumber_$i"}">$form->{"partnumber_$i"}</td>|;
	$column_data{qty} = qq|<td align=right><input type=hidden name="qty_$i" value="$form->{"qty_$i"}">$form->{"qty_$i"}</td>|;

	$column_data{bom} = qq|<td align=center><input type=hidden name="bom_$i" value=$form->{"bom_$i"}>|;
	$column_data{bom} .= ($form->{"bom_$i"}) ? "x" : "&nbsp;";
	$column_data{bom} .= qq|</td>|;

	$column_data{partsgroup} = qq|<td><input type=hidden name="partsgroup_$i" value="$form->{"partsgroup_$i"}">$form->{"partsgroup_$i"}</td>|;

      } else {
	$href = qq|$form->{script}?action=edit&id=$form->{"id_$i"}&path=$form->{path}&login=$form->{login}&password=$form->{password}&rowcount=$i&previousform=$previousform|;
	$column_data{partnumber} = qq|<td><input type=hidden name="partnumber_$i" value="$form->{"partnumber_$i"}"><a href=$href>$form->{"partnumber_$i"}</a></td>|;
	$column_data{runningnumber} = qq|<td><input name="runningnumber_$i" size=3 value="$i"></td>|;
	$column_data{qty} = qq|<td><input name="qty_$i" size=5 value="$form->{"qty_$i"}"></td>|;

        $form->{"bom_$i"} = ($form->{"bom_$i"}) ? "checked" : "";
	$column_data{bom} = qq|<td align=center><input name="bom_$i" type=checkbox class=checkbox value=1 $form->{"bom_$i"}></td>|;

	$column_data{partsgroup} = qq|<td><input type=hidden name="partsgroup_$i" value="$form->{"partsgroup_$i"}">$form->{"partsgroup_$i"}</td>|;
      }

      $column_data{unit} = qq|<td><input type=hidden name="unit_$i" value="$form->{"unit_$i"}">$form->{"unit_$i"}</td>|;
      $column_data{description} = qq|<td><input type=hidden name="description_$i" value="$form->{"description_$i"}">$form->{"description_$i"}</td>|;
    }
    
    $column_data{total} = qq|<td align=right>$linetotal</td>|;
    
    print qq|
        <tr>|;

    map { print "\n$column_data{$_}" } @column_index;
    
    print qq|
        </tr>
  <input type=hidden name="id_$i" value=$form->{"id_$i"}>
  <input type=hidden name="sellprice_$i" value=$form->{"sellprice_$i"}>
  <input type=hidden name="weight_$i" value=$form->{"weight_$i"}>
|;
  }

  print qq|
      </table>
    </td>
  </tr>
|;
 
}


sub update {
  
  if ($form->{item} eq "assembly") {
    $i = $form->{assembly_rows};

    # if last row is empty check the form otherwise retrieve item
    if (($form->{"partnumber_$i"} eq "") && ($form->{"description_$i"} eq "") && ($form->{"partsgroup_$i"} eq "")) {

      &check_form;

    } else {

      IC->assembly_item(\%myconfig, \%$form);

      $rows = scalar @{ $form->{item_list} };

      if ($rows) {
	$form->{"qty_$i"} = 1 unless ($form->{"qty_$i"});

	if ($rows > 1) {
	  $form->{makemodel_rows}--;
	  &select_item;
	  exit;
	} else {
	  map { $form->{item_list}[$i]{$_} =~ s/\"/&quot;/g } qw(partnumber description unit partsgroup);
	  map { $form->{"${_}_$i"} = $form->{item_list}[0]{$_} } keys %{ $form->{item_list}[0] };
	  $form->{"runningnumber_$i"} = $form->{assembly_rows};
	  $form->{assembly_rows}++;

	  &check_form;

	}

      } else {

        $form->{rowcount} = $i;
	$form->{assembly_rows}++;

	&new_item;

      }
    }
  }
  
  if ($form->{item} eq "part") {
    &check_form;
  }

  if ($form->{item} eq 'service') {
    map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) } qw(sellprice listprice);
    
    &form_header;
    &form_footer;
  }

}


sub save {

  # check if there is a part number
  # $form->isblank("partnumber", $locale->text(ucfirst $form->{item}." Number missing!"));

  if ($form->{obsolete}) {
    $form->error($locale->text("Inventory quantity must be zero before you can set this $form->{item} obsolete!")) if ($form->{onhand});
  }

# expand dynamic strings
# $locale->text('Inventory quantity must be zero before you can set this part obsolete!')
# $locale->text('Inventory quantity must be zero before you can set this assembly obsolete!')
# $locale->text('Part Number missing!')
# $locale->text('Service Number missing!')
# $locale->text('Assembly Number missing!')


  # save part
  $rc = IC->save(\%myconfig, \%$form);

  $parts_id = $form->{id};
  
  # load previous variables
  if ($form->{previousform}) {
    # save the new form variables before splitting previousform
    map { $newform{$_} = $form->{$_} } keys %$form;

    $previousform = $form->unescape($form->{previousform});

    # don't trample on previous variables
    map { delete $form->{$_} } keys %newform;

    # now take it apart and restore original values
    foreach $item (split /&/, $previousform) {
      ($key, $value) = split /=/, $item, 2;
      $value =~ s/%26/&/g;
      $form->{$key} = $value;
    }
    $form->{taxaccounts} = $newform{taxaccount2};
    
    if ($form->{item} eq 'assembly') {

      # undo number formatting
      map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) } qw(weight listprice sellprice rop);

      $form->{assembly_rows}--;
      $i = $newform{rowcount};
      $form->{"qty_$i"} = 1 unless ($form->{"qty_$i"});

      $form->{sellprice} -= $form->{"sellprice_$i"} * $form->{"qty_$i"};
      $form->{weight} -= $form->{"weight_$i"} * $form->{"qty_$i"};
      
      # change/add values for assembly item
      map { $form->{"${_}_$i"} = $newform{$_} } qw(partnumber description bin unit weight listprice sellprice inventory_accno income_accno expense_accno);
      
      $form->{sellprice} += $form->{"sellprice_$i"} * $form->{"qty_$i"};
      $form->{weight} += $form->{"weight_$i"} * $form->{"qty_$i"};

    } else {
      # set values for last invoice/order item
      $i = $form->{rowcount};
      $form->{"qty_$i"} = 1 unless ($form->{"qty_$i"});

      map { $form->{"${_}_$i"} = $newform{$_} } qw(partnumber description bin unit listprice inventory_accno income_accno expense_accno sellprice);
      $form->{"sellprice_$i"} = $newform{lastcost} if ($form->{vendor_id});

      if ($form->{exchangerate} != 0) {
	$form->{"sellprice_$i"} /= $form->{exchangerate};
      }
      
      map { $form->{"taxaccounts_$i"} .= "$_ " } split / /, $newform{taxaccount};
      chop $form->{"taxaccounts_$i"};
      foreach $item (qw(description rate taxnumber)) {
		$index = $form->{"taxaccounts_$i"} . "_$item";
  		$form->{$index} = $newform{$index};
      }

      # credit remaining calculation
      $amount = $form->{"sellprice_$i"} * (1 - $form->{"discount_$i"} / 100) * $form->{"qty_$i"};
      map { $form->{"${_}_base"} += $amount } (split / /, $form->{"taxaccounts_$i"});
      map { $amount += ($form->{"${_}_base"} * $form->{"${_}_rate"}) } split / /, $form->{"taxaccounts_$i"} if !$form->{taxincluded};

      $form->{creditremaining} -= $amount;
      
    }
    
    $form->{"id_$i"} = $parts_id;
    delete $form->{action};

    # restore original callback
    $callback = $form->unescape($form->{callback});
    $form->{callback} = $form->unescape($form->{old_callback});
    delete $form->{old_callback};

    $form->{makemodel_rows}--;

    # put callback together
    foreach $key (keys %$form) {
      # do single escape for Apache 2.0
      $value = $form->escape($form->{$key}, 1);
      $callback .= qq|&$key=$value|;
    }
    $form->{callback} = $callback;
  }

  # redirect
  $form->redirect;

}


sub save_as_new {

  $form->{id} = 0;
  &save;

}


sub delete {

  $rc = IC->delete(\%myconfig, \%$form);
  
  # redirect
  $form->redirect($locale->text('Item deleted!')) if ($rc > 0);
  $form->error($locale->text('Cannot delete item!'));

}


sub stock_assembly {

  $form->{title} = $locale->text('Stock Assembly');
  
  $form->header;
  
  print qq|
<body>

<form method=post action=$form->{script}>

<table width="100%">
  <tr>
    <th class=listtop>$form->{title}</th>
  </tr>
  <tr height="5"></tr>
  <tr valign=top>
    <td>
      <table>
        <tr>
          <th align="right" nowrap="true">|.$locale->text('Number').qq|</th>
          <td><input name=partnumber size=20></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <th align="right" nowrap="true">|.$locale->text('Description').qq|</th>
          <td><input name=description size=40></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr><td><hr size=3 noshade></td></tr>
</table>

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input type=hidden name=nextsub value=list_assemblies>

<br>
<input class=submit type=submit name=action value="|.$locale->text('Continue').qq|">
</form>

</body>
</html>
|;

}


sub list_assemblies {

  IC->retrieve_assemblies(\%myconfig, \%$form);

  $column_header{partnumber} = qq|<th class=listheading>|.$locale->text('Number').qq|</th>|;
  $column_header{description} = qq|<th class=listheading>|.$locale->text('Description').qq|</th>|;
  $column_header{bin} = qq|<th class=listheading>|.$locale->text('Bin').qq|</th>|;
  $column_header{onhand} = qq|<th class=listheading>|.$locale->text('Qty').qq|</th>|;
  $column_header{rop} = qq|<th class=listheading>|.$locale->text('ROP').qq|</th>|;
  $column_header{stock} = qq|<th class=listheading>|.$locale->text('Add').qq|</th>|;

  @column_index = (qw(partnumber description bin onhand rop stock));
  
  $form->{title} = $locale->text('Stock Assembly');

  $form->{callback} = "$form->{script}?action=stock_assembly&path=$form->{path}&login=$form->{login}&password=$form->{password}";
  
  $form->header;
  
  $colspan = $#column_index + 1;

  print qq|
<body>

<form method=post action=$form->{script}>

<table width=100%>
  <tr>
    <th class=listtop colspan=$colspan>$form->{title}</th>
  </tr>
  <tr size=5></tr>
  <tr class=listheading>|;

  map { print "\n$column_header{$_}" } @column_index;

  print qq|
  </tr>
|;

  $i = 1;
  foreach $ref (@{ $form->{assembly_items} }) {

    map { $ref->{$_} =~ s/\"/&quot;/g } qw(partnumber description);
   
    $column_data{partnumber} = qq|<td width=20%>$ref->{partnumber}</td>|;
    $column_data{description} = qq|<td width=50%>$ref->{description}&nbsp;</td>|;
    $column_data{bin} = qq|<td>$ref->{bin}&nbsp;</td>|;
    $column_data{onhand} = qq|<td align=right>|.$form->format_amount(\%myconfig, $ref->{onhand}, '', "&nbsp;").qq|</td>|;
    $column_data{rop} = qq|<td align=right>|.$form->format_amount(\%myconfig, $ref->{rop}, '', "&nbsp;").qq|</td>|;
    $column_data{stock} = qq|<td width=10%><input name="qty_$i" size=10></td>|;

    $j++; $j %= 2;
    print qq|<tr class=listrow$j><input name="id_$i" type=hidden value=$ref->{id}>\n|;
    
    map { print "\n$column_data{$_}" } @column_index;
    
    print qq|
    </tr>
|;

    $i++;

  }
  
  $i--;
  print qq|
  <tr>
    <td colspan=6><hr size=3 noshade>
  </tr>
</table>
<input name=rowcount type=hidden value="$i">

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input name=callback type=hidden value="$form->{callback}">

<input type=hidden name=nextsub value=restock_assemblies>

<br>
<input class=submit type=submit name=action value="|.$locale->text('Continue').qq|">

</form>

</body>
</html>
|;
 
}


sub restock_assemblies {

  $form->redirect($locale->text('Assemblies restocked!')) if (IC->restock_assemblies(\%myconfig, \%$form));
  $form->error($locale->text('Cannot stock assemblies!'));
  
}


sub continue { &{ $form->{nextsub} } };


