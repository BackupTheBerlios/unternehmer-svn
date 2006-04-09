<?php
session_start();
?>

<html>
<body>
<table width="100%" border="1">
<tr>
	<th>Bezeichnung</th>
	<th>Artikelnummer</th>
	<th>Verkaufspreis</th>
</tr>

<?php
$dbname = $_SESSION['datenbankname'];
$benutzer = $_SESSION['benutzer'];
$passwort = $_SESSION['passwort'];

$conn = "host=localhost port=5432 dbname=$dbname user=$benutzer password=$passwort";
	
$db = pg_connect ($conn);
$query = "SELECT bezeichnung, art_nr, verkaufspreis FROM verkaufsobjekt LEFT OUTER JOIN preise ON (verkaufsobjekt.preise_id = preise.id)";

$resultat = pg_query($query);
if($resultat == false) {
	print "fehler";
} else {
	for($i = 0; $i < pg_num_rows($resultat); $i++) {
		$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		print "<tr><td>$array[0]</td><td>$array[1]</td><td>$array[2]</td></tr>";
	}
}
?>
</table>
</body>
</html>
