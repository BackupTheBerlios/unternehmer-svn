<?php
session_start();
//mandant heist, man schmeisst jemanden in dessen gruppe, so das er zugriff auf diese mandanten-db hat
//d.h. man legt dessen pg_user(usesysid) in pg_group(grolist)
//mandanten holt man aus pg_group(groname)
$conn = "host={$_SESSION['dbrechner']} port=5432 ".
        "user={$_SESSION['benutzer']} password={$_SESSION['passwort']} dbname=template1";
	
$db = pg_connect ($conn);
//fuer anzeige in html inputfeld
$loginname = $_GET['loginname'];

//daten fuer die programmoberflaeche holen

?>

<html>
<body>
<table width="100%" border="0">
<form method="post" action="benutzerprofil-sql.php">
<tr>
	<td colspan="3"><center><h2>Benutzerprofil</h2></center></td>
</tr>
<tr>
	<td>Loginname</td>
	<td><input type="text" name="loginname" value="<?php print $loginname ?>"></td>
	<input type="hidden" name="oldloginname" value="<?php print $loginname ?>">
</tr>
<tr>
	<td>Passwort</td>
	<td><input type="text" name="passwort" value="<?php print $passwort ?>"></td>
</tr>
<tr>
	<td>Berechtigung f&uuml;r Mandant(en)</td>
	<td>
<?php
$query = "SELECT usesysid FROM pg_user WHERE usename='$loginname'";
$resultat = pg_query($query);
if($resultat == false) {
	print "fehler1";
}
$array = pg_fetch_row($resultat, NULL, PGSQL_NUM);
$loginuid = $array[0];

$query = "SELECT groname,grolist FROM pg_group";
$resultat = pg_query($query);
$l = 1;

//fuer jeden mandanten, alle gruppenmitglieder durchgehen
//wer bei mandant in gruppe ist, bekommt sein html-checkbox angekreutzt
for($i = 0; $i < pg_num_rows($resultat);$i++) {
	
	$mandant = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	for($j = 0; $j < strlen($mandant[1]); $j++) {
		if($mandant[1][$j] == $loginuid) {
			print "<input type=checkbox name=$mandant[0] checked>$mandant[0]<br>";
			$l = 0;	
		} 
	}
	
	//wuerde die loginuid nicht in der grolist gefunden, checkbox ohne checked ausgeben
	if($l == 1) {
		print "<input type=checkbox name=$mandant[0]>$mandant[0]<br>";
	} else {
		$l = 1;
	}
}
?>
</td>

</tr>
<tr><td colspan="3"><hr></td>
</tr>
<tr>
	<td colspan="3"><center><h2>Programmoberfl&auml;che</h2></center></td>
<tr>
<tr>	
	<td colspan="3" bgcolor="grey"><h2>Kunde erfassen</h2></td>
</tr>
<tr>
	<td>Standard Maske um einen Kunden zu erfassen</td>
	<td><input type="radio" name="kundeerfassen" value="1"></td>
	<td><a href="../bilder/kunde_erfassen.jpg"><img src="../bilder/kunde_erfassen_klein.jpg"></a></td>
</tr>
<tr>
	<td>Maske mit z.B. besserem layout, noch nicht vorhanden</td>
	<td><input type="radio" name="kundeerfassen" value="2"></td>
	<td><img src="../bilder/x.jpg"</td>
</tr>
<tr>
	<td colspan="3" bgcolor="grey"><h2>Ware erfassen</h2></td>
</tr>
<tr>
	<td>Standard Maske um eine Ware zu erfassen</td>
	<td><input type="radio" name="ware_erfassen" value="1"></td>
	<td><a href="../bilder/ware_erfassen.jpg"><img src="../bilder/ware_erfassen_klein.jpg"></a></td>
</tr>
<tr>
	<td colspan="3" bgcolor="grey"><h2>Rechnung erfassen</td>
</tr>
<tr>
	<td>Standard Maske um eine Rechnung zu erfassen</td>
	<td><input type="radio" name="rechnung_erfassen" value="1"></td>
	<td><a href="../bilder/rechnung_erfassen.jpg"><img src="../bilder/rechnung_erfassen_klein.jpg"></a></td>
</tr>



<tr>
	<td colspan="3"><center><input type="submit" name="speichern" value="Speichern"></center></td>
</tr>
	
</table>
</form>

</body>
</html>
