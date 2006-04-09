<?php
//mandant heist, man schmeisst jemanden in dessen gruppe, so das er zugriff auf diese mandanten-db hat
//d.h. man legt dessen pg_user(usesysid) in pg_group(grolist)
//mandanten holt man aus pg_group(groname)
$conn = "host=localhost port=5432 ".
        "user=postgres password=postgres dbname=template1";
	
$db = pg_connect ($conn);
$loginname = $_GET['loginname'];
$query = "SELECT passwd FROM pg_shadow WHERE usename='$loginname'";

$resultat = pg_query($query);
if($resultat == false) {
	print "error select";
} else {
	$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	$passwort = $array[0];
}

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
$array = pg_fetch_row($resultat, NULL, PGSQL_NUM);
$loginuid = $array[0];

$query = "SELECT groname,grolist FROM pg_group";
$resultat = pg_query($query);
$k = 0;
$l = 1;
for($i = 0; $i < pg_num_rows($resultat);$i++) {
	
	$mandant = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	for($j = 0; $j < strlen($mandant[1]); $j++) {
		if($mandant[1][$j] == $loginuid) {
			$html_mandanten[$k] = "<input type=checkbox name=$mandant[0] checked>$mandant[0]<br>";
			print $html_mandanten[$k];
			$k++;
			$l = 0;
		} 
	}
	if($l == 1) {
		$html_mandanten[$k] = "<input type=checkbox name=$mandant[0]>$mandant[0]<br>";
		print $html_mandanten[$k];
		$k++;
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
