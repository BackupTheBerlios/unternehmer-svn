<html>
<body>
<table width="100%" border="1">
<tr>
	<td><h2>Benutzerprofil</h2></td>
</tr>
<tr>
	<td>Loginname</td>
	<td><input type="text" value="<?php print $_GET['loginname'] ?>"></td>
</tr>
<tr>
	<td>Passwort</td>
	<td><input type="text"></td>
</tr>
<tr>
	<td>Mandant</td>
	<td>
<?php
//mandant heist, man schmeisst jemanden in dessen gruppe, so das er zugriff auf diese mandanten-db hat
//d.h. man legt dessen pg_user(usesysid) in pg_group(grolist)
//mandanten holt man aus pg_group(groname)
$conn = "host=localhost port=5432 ".
        "user=postgres password=postgres dbname=template1";
	
$db = pg_connect ($conn);

$query = "SELECT groname FROM pg_group";
$resultat = pg_query($query);
for($i = 0; $i < pg_num_rows($resultat);$i++) {
	$mandant = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	$html_mandanten[$i] = "<input type=checkbox name=$mandant[0]>$mandant[0]<br>";
	print $html_mandanten[$i];
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
	<td colspan="3"><h2>Kunde erfassen</h2></td>
</tr>
<tr>
	<td>Standard Maske um einen Kunden zu erfassen</td>
	<td><input type="radio"></td>
	<td><a href="../bilder/kunde_erfassen.jpg"><img src="../bilder/kunde_erfassen_klein.jpg"></a></td>
</tr>
<tr>
	<td colspan="3"><h2>Ware erfassen</h2></td>
</tr>
<tr>
	<td>Standard Maske um eine Ware zu erfassen</td>
	<td><input type="radio"></td>
	<td><a href="../bilder/ware_erfassen.jpg"><img src="../bilder/kunde_erfassen_klein.jpg"></a></td>
</tr>
<tr>
	<td colspan="3"><h2>Rechnung erfassen</td>
</tr>
<tr>
	<td>Standard Maske um eine Rechnung zu erfassen</td>
	<td><input type="radio"></td>
	<td><a href="../bilder/rechnung_erfassen.jpg"><img src="../bilder/rechnung_erfassen_klein.jpg"></a></td>
</tr>



<tr>
	<td colspan="3"><center><input type="submit" name="speichern" value="Speichern"></center></td>
</tr>
	

</table>
	
</body>
</html>
