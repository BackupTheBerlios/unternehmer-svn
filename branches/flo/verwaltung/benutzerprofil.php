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
<?php
//mandant heist, man schmeisst jemanden in dessen gruppe, so das er zugriff auf diese mandanten-db hat
//d.h. man legt dessen pg_user(usesysid) in pg_group(grolist)
//mandanten holt man aus pg_group(groname)
?>
<td><select></select></td>
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
	<td colspan="3"><center><input type="submit" name="speichern" value="Speichern"></center></td>
</tr>
	

</table>
	
</body>
</html>
