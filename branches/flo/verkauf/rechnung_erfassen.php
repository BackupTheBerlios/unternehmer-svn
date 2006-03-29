<html>
<body>


<form id='rechnungform' name="rechnung" method="post">
<table width="100%" border="1">
<tr>
	<th colspan="8"><center>Rechnung erfassen</center></th>
</tr>
<tr>
	<td colspan="8">&nbsp;</td>
</tr>
<tr>
	<td colspan="4">
	<table width="50%">
	<tr>
		<th align=right nowrap>Kunde</th>
		<td colspan=3><select name=customer>
			<option>kunde--377
<!-- php stuff dynamisch -->
		 </select>
	</tr>
	<tr>
 		<th align=right nowrap>Kontakt</th>
	        <td colspan=3><select name=contact>
			<option>kontakt--
<!-- php stuff dynamisch -->
		</select>
	</tr>
	<tr>
		<th align="right">Kreditlimit</th>
		<td>0</td>
	</tr>
	<tr>
		<th align="right">Guthaben</th>
		<td>0</td>
	</tr>
	<tr>
		<th align=right nowrap>buchen auf</th>
		<td colspan=3><select name=AR><option selected>1400--xxxxxxxxxFord. a.Lieferungen und Leistungen
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
	<td colspan="4">
	<table>
	<tr>
	        <th align=right nowrap>Verk&auml;ufer/in</th>
		<td colspan=3><select name=employee>
			<option>
		</select>
		</td>
      	</tr>
      	<tr>
		<th align=right nowrap>Rechnungsnummer</th>
		<td><input name=invnumber size=11 value=""></td>
      	</tr>
      	<tr>
		<th align=right>Rechnungsdatum</th>
       		<td><input name=invdate id=invdate size=11 title="dd.mm.yy" value=28.03.2006></td>
      	</tr>
      	<tr>
		<th align=right>F&auml;lligkeitsdatum</th>
      		 <td width="13"><input type="text" name="duedate" id=duedate size=11 title="dd.mm.yy" value=28.03.2006></td>
      	</tr>
      	<tr>
		<th align=right nowrap>Auftragsnummer</th>
		<td><input name=ordnumber size=11 value="select oder"></td>
      	</tr>
      	<tr>
		<th align=right nowrap>Angebotsnummer</th>
		<td><input name=quonumber size=11 value="auch select"></td>
      	</tr>
      	<tr>
		<th align=right nowrap>Bestellnummer</th>
		<td><input name=cusordnumber size=11 value="auch select"></td>
      	</tr>
	</table>
</td>
<tr>
	<td colspan="8">&nbsp;</td>
</tr>
<tr>
	<td>Pos.</td>
	<td>Artikelnummer</td>
	<td>Artikelbezeichnung</td>
	<td>Anzahl</td>
	<td>Einheit</td>
	<td>Preis</td>
	<td>Rab.</td>
	<td>Gesamt</td>
</tr>

<!-- php dynamisch -->
<tr valign=top>
	<td><select name="pos_1" size="0"></td>
	<td><input name="partnumber_1" size=8 value=""></td>
	<td><input name="description_1" size=30 value=""></td>
	<td align=right><input name="qty_1" size=5 value=0></td>
	<td><input name="unit_1" size=5 value=""></td>
	<td align=right><input name="sellprice_1" size=9 value=0></td>
	<td align=right><input name="discount_1" size=3 value=0></td>
	<td align=right>0</td>
</tr>

</table>
</form>

</body>
</html>

<script type='text/javascript'>

function suche(e)
{
	//name ermitteln des input feldes == was sucht man
	var e = e || event;
	var ele = e.target || e.srcElement;
	
	var inputfeld = ele.name;
	//alert(inputfeld);
	
	//suchwert ermitteln, falls es einen gibt
	var inputwert = ele.value;
	//alert(box);

	
}

window.onload = function() {
    document.getElementById('rechnungform').onkeyup = suche;    
}

</script>


