<?php
session_start();
//db abfrage
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect($conn);

//hier firmenamen,vor-und nachname holen
$query = "SELECT firmenname, vorname, nachname FROM go_name WHERE rechnung.kunde_id = go_name.id AND rechnung.id = {$_GET['rechnungsnr']}";

$resultat = pg_query($query);

if($resultat == false) {
	print "fehler";
} else {
	$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	$firmenname = $array[0];
	$vorname = $array[1];
	$nachname = $array[2];

	$rechnungsnr = $_GET['rechnungsnr'];
	$query = "SELECT (verkaufspreis * anzahl) from preise left outer join rechnung_vo  on(vo_preise_id=preise.id) WHERE rechnung_id='{$_GET['rechnungsnr']}'";

	$resultat = pg_query($query);
	if($resultat == false) {
		print "fehler";
	} else {
		for($i = 0; $i < pg_num_rows($resultat); $i++) {
			$array = pg_fetch_array($resultat);
			$html_gesamtpreise[$i] = "<tr><td>&nbsp;</td><td>&nbsp;</td><td>$array[0]</td><td><input type='text' name='var_art_id'</td></tr>";
		}
	}
}

?>
<html>
<body>
<table width="100%" border="1">
<form method="post" action="debitorenbuchung-sql.php">
<tr>
	<td colspan="4"><center><h2>Debitorenbuchung</center></h2></td>
</tr>
<tr>
	<td align="right">Firmenname</td>
	<td colspan="3"><input type="text" name="firmenname" value="<?php echo $firmenname ?>"></td>
</tr>
<tr>
	<td align="right">Vorname</td>
	<td colspan="3"><input type="text" name="vorname" value=<?php echo $vorname ?> ></td>
</tr>
<tr>
	<td align="right">Nachname</td>
	<td colspan="3"><input type="text" name="nachname" value=<?php echo $nachname ?> ></td>
</tr>
<tr>
	<td colspan="4">&nbsp;</td>
</tr>
<tr>
	<td>Artikelnr</td>
	<td>Artikelbezeichnung</td>
	<td>Gesamtpreis</td>
	<td>Bezahlen</td>
</tr>
<tr><td colspan="4"><hr></td>
</tr>

<?php
// dynamische vervollstaendigung der tabellen-spalten
for($i = 0; $i < count($html_gesamtpreise); $i++) {
	print $html_gesamtpreise[$i];
}
?>
<tr>
	<td colspan="4"><hr></td>
</tr>
<tr>
	<td colspan="4"><center><input type="submit" name="debitorenbuchung" value="Einzahlung buchen"></center></td>
</tr>
</form>
</table>
</body>
</html>


