<?php
//auslesen der benutzer und dann die daraus tabellenreihen erstellen
$conn = "host=localhost port=5432 dbname=phpunternehmer ".
        "user=postgres password=";
	
$db = pg_connect ($conn);
//brauche ein select statement was vorname,nachname,loginame,datenbank ausliest
$query = "SELECT usename FROM pg_user";
$resultat = pg_query($query);
if( $resultat == false) {
	print "fehler bei benutzer holen";
} else {
	for($i = 0; $i < pg_num_rows($resultat); $i++) {
		$arr = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		
		//user postgres auslassen
		if($i != 0) {
			$loginnamen[$i-1] = $arr[0];
		}
	}
	//vorname und nachname holen aus go_name
	$query = "SELECT vorname, nachname FROM go_name";
	$resultat = pg_query($query);
	if($resultat == false) {
		print "fehler bei go_name";
	}else {
		$anzahl = pg_num_rows($resultat);
		for($i = 0; $i < pg_num_rows($resultat); $i++) {
			$arr = pg_fetch_array($resultat, NULL, PGSQL_NUM);
			$vornamen[$i] = $arr[0];
			$nachnamen[$i] = $arr[1];
		}
	}
}
?>



<html>
<body>
<table width="100%" border="0">
<tr>
	<td colspan="6"><center><h2>Verwaltungsmaske</h2></center></td>
</tr>
<!-- Benutzerabteilung, muss flexible sein, da es ja mehrere oder weniger benutzer gibt, angezeigt werden -->
<tr>
	<td bgcolor="grey">Vorname</td>
	<td bgcolor="grey">Nachname</td>
	<td bgcolor="grey">Loginname</td>
	<td bgcolor="grey">Mandant</td>
	<td bgcolor="grey">Datenbankcomputer</td>
	<td bgcolor="grey">Datenbankname</td>
</tr>
<!-- hier kommen die flexiblen rows mit den benutzern dann automatisch -->
<?php
for($i = 0; $i < $anzahl; $i++) { ?>
	<tr>
		<td><?php print $vornamen[$i] ?></td>
		<td><?php print $nachnamen[$i] ?></td>
		<td><?php print $loginnamen[$i] ?></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
<?php } ?>


<tr>
	<td colspan="6"><hr></td>
</tr>

<!-- Buttons -->
<tr>
	<td>Hier k&ouml;nnen Sie einen neuen Benutzer anlegen</td>
</tr>
<tr>
	<form method="post" name="benutzererfassen" action="benutzererfassen.php">
	<td align="right"><input type="submit" value="Benutzer erfassen" name="benutzererfassen"></form>
	</td>
</tr>
<tr>
	<td colspan="6"><hr></td>
</tr>
<tr>
	<td>Hier k&ouml;nnen Sie einen neuen Mandanten anlegen</td>
</tr>
<tr>
	<form method="post" name="mandanterfassen" action="mandant_erfassen.php">
	<td align="right"><input type="submit" value="Mandant erfassen" name="mandanterfassen"></td>
	</form>
</tr>

<!-- Anmelden an unternehmer -->
<tr>
	<td colspan="6"><hr></td>
</tr>
<tr>
	<td>Direkt anmelden an "Unternehmer"</td>
</tr>
<form method="post" name="einloggen" action="checklogin.php">
<tr>
	<td align="right">Loginname</td>
	<td><input name="loginname" type="text"></td>
</tr>
<tr>
	<td align="right">Passwort</td>
	<td><input name="passwort" type="text"></td>
</tr>
<tr>
	<td align="right">Datenbankname</td>
	<td><input name="datenbankname" type="text"></td>
</tr>
<tr>
	<td align="right"><input type="submit" value="Anmelden" name="anmelden"></td>
</tr>
</form>


</table>
</body>
</html>

