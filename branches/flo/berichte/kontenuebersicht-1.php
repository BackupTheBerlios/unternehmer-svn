<?php
session_start();
//alle konten holen aus konten
$conn = "host={$_SESSION['dbrechner']} port=5432 ".
        "user={$_SESSION['benutzer']} password={$_SESSION['passwort']} dbname={$_SESSION['dbname']}";
	
$db = pg_connect ($conn);
$query = "SELECT kontennr,kontenbezeichnung FROM konten ORDER BY kontennr";
$resultat = pg_query($query);
if($resultat == false) {
	print "Fehler";
} else {
	$anz = pg_num_rows($resultat);
	for($i = 0; $i < $anz; $i++) {
		$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		if($i % 2 > 0) {
			$html_konten[$i] = "<tr><td>$array[0]</td><td>$array[1]</td><td></td><td></td></tr>";
		} else {
			$html_konten[$i] = "<tr><td bgcolor='grey'>$array[0]</td><td bgcolor='grey'>$array[1]</td><td bgcolor='grey'></td><td bgcolor='grey'></td></tr>";
		}
	}
}
?>



<html>
<body>
<table width="100%" border="0">
<tr>
	<td colspan="4"><center><h2>Konten&uuml;bersicht</h2></td>
</tr>
<tr>
	<td>Konto</td>
	<td>Beschreibung</td>
	<td>Soll</td>
	<td>Haben</td>
</tr>
<?php
for($i = 0;$i < $anz; $i++) {
	print $html_konten[$i];
}
?>

</table>
</body>
</html>
