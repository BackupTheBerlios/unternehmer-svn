<?php
session_start();
//db abfrage
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect($conn);
$query = "SELECT (verkaufspreis * anzahl) from preise left outer join rechnung_vo  on(vo_preise_id=preise.id) WHERE rechnung_id={$_GET['rechnungsnr']}";

$resultat = pg_query($query);
if($resultat == false) {
	print "fehler";
} else {
	for($i = 0; $i < pg_num_rows($resultat); $i++) {
		$array = pg_fetch_array($resultat);
		$html_gesamtpreise[$i] = "<tr><td>&nbsp;</td><td>&nbsp;</td><td>$array[0]</td><td>&nbsp;</td></tr>";
	}
}


?>
<html>
<body>
<table width="100%" border="1">
<tr>
	<td><center><h2>Debitorenbuchung</center></h2></td>
</tr>
<tr>
	<td>Firmenname</td>
	<td><input type="text" name="firmenname"></td>
</tr>
<tr>
	<td>Vorname</td>
	<td><input type="text" name="vorname"></td>
</tr>
<tr>
	<td>Nachname</td>
	<td><input type="text" name="nachname"></td>
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

</table>
</body>
</html>


