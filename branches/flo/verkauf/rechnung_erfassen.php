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
$query = "SELECT g.vorname, g.nachname, g.id, a.name_id FROM go_name g, angestellte a WHERE g.id = a.name_id";

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
$query = "SELECT g.vorname, g.nachname, g.id, k.name_id FROM go_name g, kontakt k WHERE g.id = k.name_id";

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
	<td><select name="pos_1" size="0">
		<option>1</option>
		<option>2</option>
	</td>
	<td><input name="art_nr_1" size=8 value=""></td>
	<td><input name="bezeichnung_1" size=30 value=""></td>
	<td align=right><input name="anzahl_1" size=5 value=0></td>
	<td><input name="einheit_1" size=5 value=""></td>
	<td align=right><input name="verkaufspreis_1" size=9 value=0></td>
	<td align=right><input name="rabatt_1" size=3 value=0></td>
	<td align=right>0</td>
</tr>
<tr valign=top>
	<td><select name="pos_2" size="0">
		<option>1</option>
		<option selected>2</option>
	</td>
	<td><input name="art_nr_2" size=8 value=""></td>
	<td><input name="bezeichnung_2" size=30 value=""></td>
	<td align=right><input name="anzahl_2" size=5 value=0></td>
	<td><input name="einheit_2" size=5 value=""></td>
	<td align=right><input name="verkaufspreis_2" size=9 value=0></td>
	<td align=right><input name="rabatt_2" size=3 value=0></td>
	<td align=right>0</td>
</tr>


<tr>
	<td colspan="8">&nbsp;</td>
</tr>
<tr>
	<td colspan="5"><input type="submit" name="rechnung_buchen" value="Rechnung buchen" onClick="rechnung_erfassen1.php"></td>
</tr>
</table>
</form>


<script type='text/javascript'>

function suche(e)
{
	
	//name ermitteln des input feldes == was sucht man
	var e = e || event;
	var ele = e.target || e.srcElement;
	
	if(e.keyCode == 13) {
	
		var inputfeld = ele.name;
		//alert(inputfeld);
	
		//suchwert ermitteln, falls es einen gibt
		var inputwert = ele.value;
		//alert(inputwert);
		
		var popupWindow = window.open(
      'rechnung_suche.php','rechnung_suche_fenster',"width=450,height=300, screenY=250, screenX=300");
	}
	
}

window.onload = function() {
    document.getElementById('rechnungform').onkeydown = suche;    
}

</script>

</body>
</html>
