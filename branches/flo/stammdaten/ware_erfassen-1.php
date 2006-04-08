<html>
<body>
<form method="post" action="ware_erfassen-sql.php">
<table width="100%" border="0">
<tr><td colspan="2"><div align="center"><h2>Ware erfassen</h2></div></td></tr>
<tr>
	<td align="right">Artikelbezeichnung</td>
	<td><input type="text" name="artikelbezeichnung"></td>	
</tr>
<tr>
	<td align="right">Artikelnummer</td>
	<td><input type="text" name="artikelnummer"></td>
</tr>
<tr>
	<td align="right">Hersteller</td>
	<td><input type="text" name="hersteller" value="nichtnutzbar"></td>
</tr>
<tr>
	<td align="right">Modell</td>
	<td><input type="text" name="modell" value="nichtnutzbar"></td>
</tr>
<tr>
	<td align="right">Listenpreis</td>
	<td><input type="text" name="listenpreis"></td>
</tr>
<tr>
	<td align="right">Verkaufspreis</td>
	<td><input type="text" name="verkaufspreis"></td>
</tr>
<tr>
	<td align="right">Einkaufspreis</td>
	<td><input type="text" name="einkaufspreis"></td>
</tr>
<tr>
	<td align="right">Einheit</td>
	<td><input type="text" name="einheit" value="Stck"></td>
</tr>
<tr>
	<td align="right">Gewicht</td>
	<td><input type="text" name="gewicht" value="nichtnutzbar"></td>
</tr>
<tr>
	<td align="right">Mindestlagerbestand</td>
	<td><input type="text" name="mindestlagerbestand" value="nichtnutzbar"></td>
</tr>
<tr>
	<td align="right">Lagerplatz</td>
	<td><input type="text" name="lagerplatz" value="nichtnutzbar"></td>
</tr>

<tr>
	<td colspan="2" align="center"><h3>Konten verkn&uuml;pfen</h3></td>
</tr>
<tr>
	<td align="right">Erl&ouml;skonto</td>
	<td><select name="erloeskonto" size="0">
		<option>8400</option>
		<option>8300</option>
	</select></td>
</tr>
<tr>
	<td align="right">Aufwandskonto</td>
	<td><select name="aufwandskonto" size="0">
		<option>3400</option>
		<option>3500</option>
	</select></td>
</tr>
<tr>
	<td colspan="2"><hr></td>
</tr>
<tr>
	<td align="center" colspan="2"><input type="submit" name="ware_erfassen" value="Ware abspeichern"></td>
</tr>
</table>
</form>
</body>
</html>
