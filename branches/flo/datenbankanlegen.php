<html>
<body>

<?php
//wenn eine Angabe fehlt zurueck zur maske
//man sollte noch das passwort abfragen, das wiederrum heist das es ein passwort fuer denjenigen user geben muss.

if( $_POST['datenbankcomputer'] == "" || $_POST['port'] == "" || $_POST['benutzer'] == "") {
	$fehlermeldung .= 'Sie haben eine Angabe vergessen';
	print $fehlermeldung;
	include "/var/www/unternehmer/branches/flo/datenbankadministration.php";
} 



elseif( $_POST['dbanlegen'] == "") {
?>

<table width="100%" border="1">
<tr>
	<td colspan="2"><center><h2>Datenbank anlegen</h2></center></td>
</tr>
<form method="post" action="datenbankanlegen1.php">
<tr>
	<td align="right">Datenbankname</td>
	<td><input type="text" name="datenbankname"></td>
</tr>
<tr>
	<td colspan="2"><hr></td>
</tr>
<input type="hidden" name="datenbankcomputer" value=<?php echo htmlspecialchars($_POST['datenbankcomputer']) ?> >
<input type="hidden" name="port" value=<?php echo htmlspecialchars($_POST['port']) ?> >
<input type="hidden" name="benutzer" value=<?php echo htmlspecialchars($_POST['benutzer']) ?> >
<input type="hidden" name="passwort" value=<?php echo htmlspecialchars($_POST['passwort']) ?> >

<tr>
	<td colspan="2"><center><input type="submit" name="dbanlegen" value="Datenbank anlegen"></center></td>
</tr>
</form>
</table>

</body>
</html>


<?php
} ?>

