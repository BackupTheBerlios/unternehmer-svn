<?php
session_start();
require_once("../../klassen/rechnung.php");

$rech = new rechnung;
$rech->nimmAlleDbDaten("{$_SESSION['benutzer']}", "{$_SESSION['datenbankname']}", "5432", "localhost", "{$_SESSION['passwort']}");
$rech->nimmRechnungsnr($_GET['rechnungsnr']);


?>
<html>
<body>
<table width="100%" border="1">
<tr>
	<td>Rechnungnr.</td>
	<td><?php print $rech->holeRechnungsnr(); ?></td>
</tr>
<tr>
	<td>Firmenname</td>
	<td><?php print $rech->holeFirmenname(); ?></td>
</tr>
<tr>
	<td>Vorname</td>
	<td><?php print $rech->holeVorname(); ?></td>
</tr>
<tr>
	<td>Nachname</td>
	<td><?php print $rech->holeNachname(); ?></td>
</tr>
<tr><td colspan="2"><hr></td>
</tr>
<tr>
	<td>Pos</td>
	<td>Art-Nr.</td>
	<td>Bezeichnung</td>
	<td>Anzahl</td>
	<td>Gesamtpreis</td>
<?php
$anz = $rech->holeAnzahlVerkaufsobjekte();
for($i = 0; $i < $anz; $i++) { ?>
	<tr>
	<td><?php print $i+1; ?></td>
	<td><?php print $rech->holeArtnr('$i'); ?></td>
	<td><?php print $rech->holeBezeichnung($i); ?></td>
	<td><?php print $rech->holeAnzahl($i); ?></td>
	<td><?php print $rech->holeGesamtpreis($i); ?></td>
	</tr>
<?php } ?>

<tr>
	<td colspan="5"><hr></td>
</tr>

</table>
</body>
</html>
