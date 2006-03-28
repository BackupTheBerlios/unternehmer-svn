<html>
<body>

<table width="100%" border="1">
  <tr class=listtop>
    <th class=listtop>Rechnung erfassen</th>
  </tr>
  <tr height="5"></tr>
  <tr>
    <td>

      <table width=100% border="1">
	<tr valign=top>
	  <td>
	    <table border="1">
	      <tr>
		<th align=right nowrap>Kunde</th>
		<td colspan=3><select name=customer><option selected>kunde--377
<!-- php stuff dynamisch -->
		</td>
                <th align=right nowrap>Kontakt</th>
                <td colspan=3><select name=contact>
			<option>kontakt--
		</select>
	      </tr>
	      <tr>
		<td></td>
		<td colspan=3>
		  <table border="1">
		    <tr>
		      <th nowrap>Kreditlimit</th>
		      <td>0</td>
		      <td width=20%></td>
		      <th nowrap>Rest</th>
		      <td class="plus0">-25</td>
		    </tr>
		  </table>
		</td>
	      </tr>
	      
	      <tr>
		<th align=right nowrap>buchen auf</th>
		<td colspan=3><select name=AR><option selected>1400--Ford. a.Lieferungen und Leistungen
<!-- php dynamisch -->
		</select></td>
	      </tr>
	      <tr>
		<th align=right nowrap>W&auml;hrung</th>
		<td><select name=currency><option selected>EUR
			</select>
		</td>
	      </tr>
	      <tr>
		<th align=right nowrap>Versandort</th>
		<td colspan=3><input name=shippingpoint size=35 value=""></td>
	      </tr>
	      <tr>
		<th align=right nowrap>Transportmittel</th>
		<td colspan=3><input name=shipvia size=35 value=""></td>
	      </tr>
	    </table>
	  </td>
	  <td align=right>
	    <table border="1">
	      <tr>
	        <th align=right nowrap>Verk&auml;ufer/in</th>
		<td colspan=2><select name=employee>
			<option>
		</select>
		</td>
                <td></td>
	      </tr>
	      <tr>
		<th align=right nowrap>Rechnungsnummer</th>
		<td><input name=invnumber size=11 value=""></td>
	      </tr>
	      <tr>
		<th align=right>Rechnungsdatum</th>
       		<td><input name=invdate id=invdate size=11 title="dd.mm.yy" value=28.03.2006></td>
       		<td><input type=button name=invdate id="trigger1" value=?></td>  
	      </tr>
	      <tr>
		<th align=right>F&auml;lligkeitsdatum</th>
      		 <td width="13"><input name=duedate id=duedate size=11 title="dd.mm.yy" value=28.03.2006></td>
	         <td width="4"><input type=button name=duedate id="trigger2" value=?></td></td>
	      </tr>
	      <tr>
		<th align=right nowrap>Auftragsnummer</th>
		<td><input name=ordnumber size=11 value=""></td>
	      </tr>
	      <tr>
		<th align=right nowrap>Angebotsnummer</th>
		<td><input name=quonumber size=11 value=""></td>
	      </tr>
	      <tr>
		<th align=right nowrap>Bestellnummer des Kunden</th>
		<td><input name=cusordnumber size=11 value=""></td>
	      </tr>
	    </table>
          </td>
	</tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
    </td>
  </tr>
   <tr>
    <td>
      <table width=100% border="1">
	<tr class=listheading>
<th class=listheading nowrap>Artikelnummer</th>
<th class=listheading nowrap>Artikelbezeichnung</th>
<th class=listheading nowrap>Menge</th>
<th class=listheading nowrap>Einheit</th>
<th class=listheading nowrap>Preis</th>
<th class=listheading>%</th>
<th class=listheading nowrap>Gesamt</th>
        </tr>
        <tr valign=top>
<td><input name="partnumber_1" size=20 value=""></td>
<td><input name="description_1" size=30 value=""></td>
<td align=right><input name="qty_1" size=5 value=0></td>
<td><input name="unit_1" size=5 value=""></td>
<td align=right><input name="sellprice_1" size=9 value=0></td>
<td align=right><input name="discount_1" size=3 value=0></td>
<td align=right>0</td>
        </tr>
</table>
</body>
</html>
