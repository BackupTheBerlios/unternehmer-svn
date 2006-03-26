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
	
	$sqlfile = '/var/www/unternehmer/branches/flo/sql/phpunternehmer.sql';
	//datei in array einlesen
	$array = file($sqlfile);
	$query = "";

	for($i = 0; $i < count($array); $i++) {
		if( strstr($array[$i], '--') == FALSE) {
			$query .= $array[$i];
			
			if( strstr($array[$i], ');') != FALSE) {
				print $query;
				$resultat = pg_query($query);
				//fehlerbehandlung
				if( $resultat == false) {
					print "fehler im query generator";
					$db_ok = "KO";
				}
				$query = "";
			}
		}
	}
	
	
	//pg_query(file_get_contents($sqlfile)) or die "fehler dump";
	
	//transaction abschliessen
	if( $db_ok == "KO") {
		pg_query("ROLLBACK");
	} else {
		pg_query("COMMIT");
	}
	

?>

</body>
</html>
