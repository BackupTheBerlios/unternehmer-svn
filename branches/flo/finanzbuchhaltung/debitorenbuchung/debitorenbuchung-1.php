<?php
session_start();
?>
<html>
<body>
<table width="100%">
<tr>
	<th>Rechnungsnr</th>
	<th>Firmenname</th>
	<th>Vorname</th>
	<th>Nachname</th>
</tr>

<?php
//rechnungsnr aus tbl rechnung holen
//dann mit der id, die firmen,vorname oder nachname holen
$conn = "host=localhost port=5432 dbname={$_SESSION['dbname']} " .
	"user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect ($conn);

$query = "SELECT r.id, g.firmenname, g.vorname, g.nachname FROM rechnung r LEFT OUTER JOIN go_name g ON (r.kunde_id = g.id)";

$resultat = pg_query($query);
if($resultat == false) {
	print "fehler";
} else {
	for($i = 0; $i < pg_num_rows($resultat); $i++) {
		if(($i + 1) % 2 > 0) {
			$bgcolor = "bgcolor='grey'";
		}else {
			$bgcolor = "";
		}
		$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		print "<tr $bgcolor><td><a href='debitorenbuchung-1-1.php?rechnungsnr=$array[0]'>$array[0]</a></td><td>$array[1]</td><td>$array[2]</td><td>$array[3]</td></tr>";
	}
}
?>



</table>
</body>
</html>
