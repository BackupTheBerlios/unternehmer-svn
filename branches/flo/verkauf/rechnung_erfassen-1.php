<?php
session_start();

//hier wird das html-selectfeld fuer kunde gefuellt
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect ($conn);

$query = "SELECT id,firmenname,vorname,nachname FROM go_name";

$resultat = pg_query($query);
if($resultat == false) {
	print "error";
} else {
	$anz_reihen = pg_num_rows($resultat);
	for($i = 0;$i < $anz_reihen; $i++){
		$array = pg_fetch_array($resultat, NULL, PGSQL_ASSOC);
		if($array['firmenname'] == "") {
			$kunden[$i] = $array['vorname'];
			$kunden[$i] .= '&nbsp;';
			$kunden[$i] .= $array['nachname'];
			$kunden[$i] .= '---';
			$kunden[$i] .= $array['id'];
			$kunden_html[$i] = "<option>$kunden[$i]</option>";
		} else {
			$firmenname = $array['firmenname'];
			$firmenname .= '---';
			$firmenname .= $array['id'];
			$kunden_html[$i] = "<option>$firmenname</option>";
		}
	}
}

//ende html-select fuer kunde

//html select feld fuer verkaeufer fuellen
$query = "SELECT g.vorname, g.nachname, g.id, a.go_name_id FROM go_name g, angestellte a WHERE g.id = a.go_name_id";

$resultat = pg_query($query);
if($resultat == false) {
	print "error2";
} else {
	$anz_reihen = pg_num_rows($resultat);
	for($i = 0;$i < $anz_reihen; $i++){
		$array = pg_fetch_array($resultat, NULL, PGSQL_ASSOC);					
		
		$verkaeufer[$i] = $array['vorname'];
		$verkaeufer[$i] .= '&nbsp;';
		$verkaeufer[$i] .= $array['nachname'];
		$verkaeufer_html[$i] = "<option>$verkaeufer[$i]</option>";
	}
}

//ende select fuer verkaeufer


//html select fuellen fuer -buchen auf-
$query = "SELECT kontennr, kontenbezeichnung FROM konten";

$resultat = pg_query($query);
if($resultat == false) {
	print "error3";
} else {
	$anz_reihen = pg_num_rows($resultat);
	for($i = 0;$i < $anz_reihen; $i++){
		$array = pg_fetch_array($resultat, NULL, PGSQL_ASSOC);					
		
		$konten[$i] = $array['kontennr'];
		$konten[$i] .= '---';
		$konten[$i] .= $array['kontenbezeichnung'];
		$konten_html[$i] = "<option>$konten[$i]</option>";
	}
}

//ende html select fuellen

//html select feld fuer waehrung
$query = "SELECT waehrung FROM waehrung";

$resultat = pg_query($query);
if($resultat == false) {
	print "error3";
} else {
	$anz_reihen = pg_num_rows($resultat);
	for($i = 0;$i < $anz_reihen; $i++){
		$array = pg_fetch_array($resultat, NULL, PGSQL_ASSOC);					
		
		$waehrung[$i] = $array['waehrung'];
		$waehrung_html[$i] = "<option>$waehrung[$i]</option>";
	}
}

//ende html select

//html select feld fuer kontakt
$query = "SELECT g.vorname, g.nachname, g.id, k.go_name_id FROM go_name g, kontakt k WHERE g.id = k.go_name_id";

$resultat = pg_query($query);
if($resultat == false) {
	print "error3";
} else {
	$anz_reihen = pg_num_rows($resultat);
	for($i = 0;$i < $anz_reihen; $i++){
		$array = pg_fetch_array($resultat, NULL, PGSQL_ASSOC);					
		
		$kontakt[$i] = $array['vorname'];
		$kontakt[$i] .= '&nbsp;';
		$kontakt[$i] .= $array['nachname'];
		$kontakt_html[$i] = "<option>$kontakt[$i]</option>";;
	}
}

//ende html select
?>
<html>
<body>

<form id='rechnungform' name="rechnung" method="post" action="rechnung_erfassen-sql.php">
<table width="100%" border="0" id="tabelle_id">
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
		<td colspan=3><select name="kunde">
<!-- php stuff dynamisch -->
<?php  
$anz = count($kunden_html); 
for($i = 0;$i < $anz; $i++) {
	echo $kunden_html[$i];
}
?>			
		</select>
	</tr>
	<tr>
 		<th align=right nowrap>Kontakt</th>
	        <td colspan=3><select name="kontakt">
<?php  
$anz1 = count($kontakt_html); 
for($i = 0;$i < $anz1; $i++) {
	echo $kontakt_html[$i];
}
?>		        
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
		<td colspan=3><select name="buchungskonto">
<!-- php dynamisch -->
<?php
$anz2 = count($konten_html); 
for($i = 0;$i < $anz2; $i++) {
	echo $konten_html[$i];
}
?>	

		</select></td>
	</tr>
	<tr>
		<th align=right nowrap>W&auml;hrung</th>
		<td><select name="waehrung">
<?php  
$anz3 = count($waehrung_html); 
for($i = 0;$i < $anz3; $i++) {
	echo $waehrung_html[$i];
}
?>	
			</select>
		</td>
	</tr>
	<tr>
		<th align=right nowrap>Versandort</th>
		<td colspan=3><input name="versandort" size=35 value="nicht nutzbar"></td>
	</tr>
	<tr>
		<th align=right nowrap>Transportmittel</th>
		<td colspan=3><input name="transportmittel" size=35 value="nicht nutzbar"></td>
	</tr>
	</table>
	</td>
	<td colspan="4">
	<table>
	<tr>
	        <th align=right nowrap>Verk&auml;ufer/in</th>
		<td colspan=3><select name="angestellter">
<?php
$anz4 = count($verkaeufer_html); 
for($i = 0;$i < $anz4; $i++) {
	echo $verkaeufer_html[$i];
}
?>	
		</select>
		</td>
      	</tr>
      	<tr>
		<th align=right nowrap>Rechnungsnummer</th>
		<td><input name="rechnungsnr" size=11 value="automatisch"></td>
      	</tr>
      	<tr>
		<th align=right>Rechnungsdatum</th>
       		<td><input name="rechnungsdatum" id="invdate" size="11" title="dd.mm.yy" value=28.03.2006></td>
      	</tr>
      	<tr>
		<th align=right>F&auml;lligkeitsdatum</th>
      		 <td width="13"><input type="text" name="faelligkeitsdatum" id=duedate size=11 title="dd.mm.yy" value=28.03.2006></td>
      	</tr>
      	<tr>
		<th align=right nowrap>Auftragsnummer</th>
		<td><input name="auftragsnr" size=11 value="select oder"></td>
      	</tr>
      	<tr>
		<th align=right nowrap>Angebotsnummer</th>
		<td><input name="angebotsnr" size=11 value="auch select"></td>
      	</tr>
      	<tr>
		<th align=right nowrap>Bestellnummer</th>
		<td><input name="bestellnr" size=11 value="auch select"></td>
      	</tr>
	</table>
</td>
<tr>
	<td colspan="8">&nbsp;</td>
</tr>
<tr>
	<td bgcolor="grey">Pos.</td>
	<td bgcolor="grey">Artikelnummer</td>
	<td bgcolor="grey">Artikelbezeichnung</td>
	<td bgcolor="grey">Anzahl</td>
	<td bgcolor="grey">Einheit</td>
	<td bgcolor="grey">Preis</td>
	<td bgcolor="grey">Rab.</td>
	<td bgcolor="grey">Gesamt</td>
</tr>

<!-- php dynamisch -->
<tr valign=top>
	<td><select name="pos_1" size="0">
		<option>1</option>
		<option>2</option>
	</td>
	<td><input name="art_nr_1" size="20" value=""></td>
	<td><input name="bezeichnung_1" id="bez_id" size="30" value=""></td>
	<td align=right><input name="anzahl_1" size="5" value=1></td>
	<td><input name="einheit_1" size="5" value="Stck"></td>
	<td align=right><input name="verkaufspreis_1" size="9" value=0></td>
	<td align=right><input name="rabatt_1" size="3" value=0 onkeypress="naechste_reihe(event)">%</td>
	<td align=right>0</td>
</tr>


<?php
$test
?>
<tr>
	<td colspan="8">&nbsp;</td>
</tr>
<tr>
	<td colspan="5"><input type="submit" name="rechnung_buchen" value="Rechnung buchen" onClick=document.rechnung.submit()></td>
</tr>
</table>
</form>


<script type='text/javascript'>
function naechste_reihe(e)
{
	//alert("hallo");
	//tr = document.createElement('tr');
	//td = document.createElement('td');
	//input = document.createElement('input'); 
	//tr.appendChild(td);
	//td.appendChild(input);
	if(!e)
		var e = e;
		
	if(e.keyCode == 9) {
	
	var tabelle = document.getElementById('tabelle_id');
	var letzte_reihe = tabelle.rows.length;
	letzte_reihe -= 2;
	//zahler minus 4 weil es noch reihen darueber gibt
	var zaehler = letzte_reihe - 4;
	var reihe = tabelle.insertRow(letzte_reihe);
	
	var zelle0 = reihe.insertCell(0);
	var zelle0_select = document.createElement('select');
	zelle0_select.name = 'pos_' + zaehler;
	zelle0_select.options[0] = new Option(zaehler, 'drei');
	zelle0.appendChild(zelle0_select);
	
	var zelle1 = reihe.insertCell(1);
	var zelle1_input = document.createElement('input');
	zelle1_input.type = 'text';
	zelle1_input.name = 'art_nr_' + zaehler;
 	zelle1_input.id = 'txtRow' + zaehler;
 	zelle1_input.size = '20';
	zelle1.appendChild(zelle1_input);
   
	var zelle2 = reihe.insertCell(2);
	var zelle2_input = document.createElement('input');
	zelle2_input.type = 'text';
	zelle2_input.name = 'bezeichnung_' + zaehler;
	zelle2_input.id = 'txtRow' + zaehler;
	zelle2_input.size = '30';
	zelle2.appendChild(zelle2_input);
	   
	var zelle3 = reihe.insertCell(3);
	var zelle3_input = document.createElement('input');
	zelle3_input.type = 'text';
	zelle3_input.name = 'anzahl_' + zaehler;
	zelle3_input.id = 'txtRow' + zaehler;
	zelle3_input.value = '1';
	zelle3.align = 'right';
	zelle3_input.size = '5';
	zelle3.appendChild(zelle3_input);
	   
	var zelle4 = reihe.insertCell(4);
	var zelle4_input = document.createElement('input');
	zelle4_input.type = 'text';
	zelle4_input.name = 'einheit_' + zaehler;
	zelle4_input.id = 'txtRow' + zaehler;
	zelle4_input.size = '5';
	zelle4_input.value = 'Stck';
	zelle4.appendChild(zelle4_input);
	   
	var zelle5 = reihe.insertCell(5);
	var zelle5_input = document.createElement('input');
	zelle5_input.type = 'text';
	zelle5_input.name = 'verkaufspreis_' + zaehler;
	zelle5_input.id = 'txtRow' + zaehler;
	zelle5.align = 'right';
	zelle5.value = '0';
	zelle5_input.size = '9';
	zelle5.appendChild(zelle5_input);
	   
	var zelle6 = reihe.insertCell(6);
	var zelle6_input = document.createElement('input');
	zelle6.align = 'right';
	zelle6.onkeypress = naechste_reihe;
	zelle6_input.value = '0';
	zelle6_input.type = 'text';
	zelle6_input.name = 'rabatt_' + zaehler;
	zelle6_input.id = 'txtRow' + zaehler;
	var prozent_text = document.createTextNode('%');
	zelle6_input.size = '3';
	zelle6.appendChild(zelle6_input);
	zelle6.appendChild(prozent_text);
	  
	var zelle7 = reihe.insertCell(7);
	var gesamt = document.createTextNode('0');
	zelle7.align = 'right';
	zelle7.appendChild(gesamt);
	}

}


</script>

</body>
</html>
