<?php
session_start();
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";

$db = pg_connect($conn);

pg_query("BEGIN TRANSACTION");

$kunde_id = $_POST['kunde_id']; 
print $_POST['anz_reihen'];
for($i = 0; $i < $_POST['anz_reihen']; $i++) {

	$summe = $_POST["summe_$i"];
	if($summe > 0) { 
		$rechnung_id = $_POST['rechnung_id']; 
		$rechnung_vo_id = $_POST["re_vo_id_$i"]; 
		$erloeskonto_id = explode("--", $_POST["erloeskonto_id_$i"]);
		$erloeskonto_id = $erloeskonto_id[0];
	
		$query = "INSERT INTO rechnung_bezahlt(summe, kunde_id, rechnung_id, rechnung_vo_id, " .
			"erloeskonto_id) VALUES('$summe', '$kunde_id', '$rechnung_id', '$rechnung_vo_id', " .
			"'$erloeskonto_id')";
	print $query;
		$resultat = pg_query($query);
		if($resultat == false) {
			$db_ok = "KO";
			print "Fehler bei Buchung";
		} else {
			print "Buchung ok";
		}
	}
}

if($db_ok == "KO") {
	pg_query("ROLLBACK");
	print "Fehler";
} else {
	pg_query("COMMIT");
	print "Alle buchungen erfolgreich gebucht";
}

?>
