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

<tr>
	<td colspan="6"><hr><td>
</tr>

<!-- Buttons -->
<tr>
	<form method="post" name="benutzererfassen" action="benutzererfassen.php">
	<td><input type="submit" value="Benutzer erfassen" name="benutzererfassen"></td>
	</form>
	<td><input type="submit" value="Datenbankadministration" name="datenbankadministration"></td>
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

