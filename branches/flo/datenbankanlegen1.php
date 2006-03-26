<html>
<body>

<?php
	
	//ueberpruefen ob alle daten vorhanden sind,  nach passwort sollte man eigentlich auch abfragen
	if( $_POST['datenbankcomputer'] == "") {
		print "fehler1";
	} elseif( $_POST['port'] == "") {
		print "fehler2";
	} elseif( $_POST['benutzer'] == "") {
		print "fehler3";
	} elseif( $_POST['datenbankname'] == "") {
		print "fehler4";
	}
	
	$host = $_POST['datenbankcomputer']; 
	$port =  $_POST['port']; 
	$user = $_POST['benutzer']; 
	$password = $_POST['passwort'];
	$datenbankname =  $_POST['datenbankname'];

	$conn = "host=$host port=$port dbname=template1 user=$user password=$password";
	
	$db = pg_connect ($conn);

	$query = "CREATE DATABASE $datenbankname";

	$resultat = pg_query($query);

	//fehlerbehandlung
	if( $resultat == false) {
		print "Datenbank anlegen leider fehlgeschlagen";
	} else {
		print "Datenbank anlegen war erfolgreich";
	}

	//sql file einspielen um die tabellen undsoweiter zu erstellen
	//transaction beginnen
	pg_query("BEGIN TRANSACTION");

	$oid = pg_lo_import($db, '/var/www/unternehmer/branches/flo/sql/phpunternehmer.sql');
	print $oid;

	//transaction abschliessen
	pg_query("COMMIT");

?>

</body>
</html>
