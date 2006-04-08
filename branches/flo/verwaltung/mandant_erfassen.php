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
	<td><hr></td>
</tr>
<tr>
	<td colspan="2">Mandanten Daten</td>
</tr>
<tr>
	<td align="right">Mandantenname</td>
	<td><input type="text" name="mandantenname"></td>
<tr>
	<td align="right">Firmenname</td>
	<td><input type="text" name="firmenname"></td>
</tr>
<tr>
	<td align="right">Vorname</td>
	<td><input type="text" name="vorname"></td>
</tr>
<tr>
	<td align="right">Nachname</td>
	<td><input type="text" name="nachname"></td>
</tr>
<tr>
	<td align="right">Strasse</td>
	<td><input type="text" name="strasse"></td>
</tr>
<tr>
	<td align="right">Stadt</td>
	<td><input type="text" name="stadt"></td>
</tr>
<tr>
	<td align="right">Land</td>
	<td><input type="text" name="land"></td>
</tr>
<tr>
	<td align="right">Steuernummer</td>
	<td><input type="text" name="steuernr"></td>
</tr>
<tr>
	<td align="right">undsoweiter</td>
	<td><input type="text" name=""></td>
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
