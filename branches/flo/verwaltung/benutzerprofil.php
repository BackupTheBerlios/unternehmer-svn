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
</table>
	
</body>
</html>
