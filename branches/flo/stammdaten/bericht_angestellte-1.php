<?php
session_start();
?>

<html>
<body>
<table width="100%" border="0">
<tr>
	<th>Vorname</th>
	<th>Nachname</th>
</tr>
<tr>
	<td colspan="2"><hr></td>
</tr>

<?php
$dbname = $_SESSION['datenbankname'];
$benutzer = $_SESSION['benutzer'];
$passwort = $_SESSION['passwort'];

$conn = "host=localhost port=5432 dbname=$dbname user=$benutzer password=$passwort";
	
$db = pg_connect ($conn);
$query = "SELECT g.vorname,g.nachname FROM go_name g, angestellte a WHERE a.go_name_id = g.id";

$resultat = pg_query($query);
if($resultat == false) {
	print "fehler";
} else {
	for($i = 0; $i < pg_num_rows($resultat); $i++) {
		$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		if(($i + 1) % 2 > 0) {
			$bgcolor = "bgcolor='grey'";
		}else {
			$bgcolor = "";
		}
			print "<tr $bgcolor><td>$array[0]</td><td>$array[1]</td></tr>";
	}
}
?>
</table>
</body>
</html>
