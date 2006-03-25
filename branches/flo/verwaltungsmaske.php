<?php
//auslesen der benutzer und dann die daraus tabellenreihen erstellen
$conn = "host=localhost port=5432 dbname=phpunternehmer ".
        "user=postgres password=";
	
$db = pg_connect ($conn);
//brauche ein select statement was vorname,nachname,loginame,datenbank ausliest
$query = "SELECT usename FROM pg_shadow";
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
	<td>Vorname</td>
	<td>Nachname</td>
	<td>Loginname</td>
	<td>Firma</td>
	<td>Datenbankcomputer</td>
	<td>Datenbank</td>
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
	<td colspan="6"><hr><td>
</tr>

<!-- Buttons -->
<tr>
	<form method="post" name="benutzererfassen" action="benutzererfassen.php">
	<td><input type="submit" value="Benutzer erfassen" name="benutzererfassen"></td>
	</form>
	<form method="post" name="datenbankadministration" action="datenbankadministration.php">
	<td><input type="submit" value="Datenbankadministration" name="datenbankadministration"></td>
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
	<td>Loginname</td>
	<td><input name="loginname" type="text"></td>
</tr>
<tr>
	<td>Passwort</td>
	<td><input name="passwort" type="text"></td>
	</tr>
<tr>
	<td><input type="submit" value="Anmelden" name="anmelden"></td>
</tr>
</form>


</table>
</body>
</html>

