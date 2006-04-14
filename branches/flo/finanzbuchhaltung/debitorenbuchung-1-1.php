<?php
session_start();
//db abfrage
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect($conn);

//hier die konten fuer drop-down-felder holen
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
		$html_konten .= "<option>$konten[$i]</option>";
	}
}

//hier firmenamen,vor-und nachname holen
$query = "SELECT firmenname, vorname, nachname, go_name.id FROM go_name WHERE rechnung.kunde_id = go_name.id AND rechnung.id = {$_GET['rechnungsnr']}";

$resultat = pg_query($query);

if($resultat == false) {
	print "fehler";
} else {
	$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	$firmenname = $array[0];
	$vorname = $array[1];
	$nachname = $array[2];
	$html_kunde_id = "<input type='hidden' name='kunde_id' value='$array[3]'";
	$html_rechnung_id = "<input type='hidden' name='rechnung_id' value='{$_GET['rechnungsnr']}'>";
	
	//hole summe der einzelnen verkaufsobjekte
	$query = "SELECT (verkaufspreis * anzahl)-(SELECT sum(summe) FROM rechnung_bezahlt b, " .
		 "rechnung_vo r WHERE rechnung_vo_id=rechnung_vo.id AND " .
		 "b.rechnung_id='{$_GET['rechnungsnr']}'), " .
		 "vo_id, rechnung_vo.id FROM preise " .
		 "left outer join rechnung_vo  ON(vo_preise_id=preise.id) WHERE " .
		 "rechnung_id='{$_GET['rechnungsnr']}'";
print $query;
	$resultat = pg_query($query);
	if($resultat == false) {
		print "fehler";
	} else {
		$anz_reihen = pg_num_rows($resultat);
		$html_anz_reihen = "<input type='hidden' name='anz_reihen' value='$anz_reihen'";
		
		for($i = 0; $i < pg_num_rows($resultat); $i++) {
			$array = pg_fetch_array($resultat);
			
			//hole bezeichnung und art_nr von verkaufsobjekt wo id=vo_id 
			// vo_id = array[1] von vorherigeer abfrage
			$query = "SELECT art_nr, bezeichnung, id FROM verkaufsobjekt WHERE " .
				"verkaufsobjekt.id = '$array[1]'";

			$resultat1 = pg_query($query);
			if($resultat1 == false) {
				print "fehler";
			} else {
				$array1 = pg_fetch_array($resultat1);
				$html_gesamtpreise[$i] = "<tr><td>$array1[0]</td>" .
							 "<td>$array1[1]</td>" .
							 "<td>$array[0]</td>" .
							 "<td><input type='text' name='summe_$i'></td> ".
							 "<td><select name='erloeskonto_id_$i'> " .
							 "echo $html_konten </select></td>" .
							 "</tr><input type='hidden' " .
							 "name='re_vo_id_$i' value='$array[2]'";
			}
		}
	}
}

?>
<html>
<body>
<table width="100%" border="1">
<form method="post" action="debitorenbuchung-sql.php">

<?php 
echo $html_anz_reihen;
echo $html_kunde_id;
echo $html_rechnung_id;
?>
<tr>
	<td colspan="5"><center><h2>Debitorenbuchung</center></h2></td>
</tr>
<tr>
	<td align="right">Firmenname</td>
	<td colspan="4"><input type="text" name="firmenname" value="<?php echo $firmenname ?>"></td>
</tr>
<tr>
	<td align="right">Vorname</td>
	<td colspan="4"><input type="text" name="vorname" value=<?php echo $vorname ?> ></td>
</tr>
<tr>
	<td align="right">Nachname</td>
	<td colspan="4"><input type="text" name="nachname" value=<?php echo $nachname ?> ></td>
</tr>
<tr>
	<td colspan="5">&nbsp;</td>
</tr>
<tr>
	<td>Artikelnr</td>
	<td>Artikelbezeichnung</td>
	<td>Gesamtpreis</td>
	<td>Bezahlen</td>
	<td>Erl&ouml;skonto</td>
</tr>
<tr><td colspan="5"><hr></td>
</tr>

<?php
// dynamische vervollstaendigung der tabellen-spalten
for($i = 0; $i < count($html_gesamtpreise); $i++) {
	print $html_gesamtpreise[$i];
}
?>
<tr>
	<td colspan="5"><hr></td>
</tr>
<tr>
	<td colspan="5"><center><input type="submit" name="debitorenbuchung" value="Einzahlung buchen"></center></td>
</tr>
</form>
</table>
</body>
</html>


