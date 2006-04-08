<html>
<body>

<form method="post" action="mandant_erfassen-sql.php">
<table width="100%" border="0">
<tr>
	<td colspan="2"><center><h2>Mandant erfassen</h2></center></td>
</tr>
<tr>
	<td align="right">Datenbankcomputer</td>
	<td><input type="text" name="datenbankcomputer" value="localhost"></td>
</tr>
<tr>
	<td align="right">Port</td>
	<td><input type="text" name="port" value="5432"></td>
</tr>
<tr>
	<td align="right">Benutzer</td>
	<td><input type="text" name="benutzer" value="postgres"></td>
</tr>
<tr>
	<td align="right">Passwort</td>
	<td><input type="password" name="passwort"></td>
</tr>
<tr>
	<td><p></td>
</tr>
<tr>
	<td><p></td>
</tr>
<tr>
	<td align="right"><input type="submit" name="mandanterfassen" value="Mandant erfassen"></form></td>
	<td><form method="post" action="mandantloeschen.php"><input type="submit" name="mandantloeschen" value="Mandant l&ouml;schen"></form></td>
</tr>
</table>

</body>
</html>
