<?php
//hier muss dann eine db angelegt werden mit dem mandantenname, 
//dann muesste sql script manipuliert werden, in grant statemnets am schluss der datei
//den gruppenname=mandantenname einfuegen
//dann muesste postgresql db gruppe angelegt werden, name=mandantenname
//und sql-file einspielen

$conn = "host=localhost port=5432 ".
        "user=postgres password=postgres dbname=template1";
	
$db = pg_connect ($conn);

//create database kann nicht in einem transaction block laufen,deshalb per code loeschen
$mandantenname = $_POST['mandantenname'];
$query = "CREATE DATABASE $mandantenname";

$resultat = pg_query($query);
if($resultat == false) {
	print "Fehler bei Mandant anlegen";
	$db_ok = "KO";
	$query = "DROP DATABASE $mandantenname";
	if( ($resultat = pg_query($query)) == false)
		print "Fehler db fuer Mandant loeschen<br>";
} else {
	print "Datenbank fuer Mandant erfolgreich angelegt<br>";
}

$query = "CREATE GROUP $mandantenname";

$resultat = pg_query($query);
if($resultat == false) {
	print "Fehler bei Gruppe anlegen";
	$query = "DROP GROUP $mandantenname";
	if( ($resultat = pg_query($query)) == false)
		print "Fehler gruppe fuer Mandant loeschen<br>";
	$db_ok = "KO";
} else {
	print "Gruppe fuer Mandant erfolgreich angelegt<br>";
}


pg_close($db);
$conn = "host=localhost port=5432 ".
	"user=postgres password=postgres dbname=$mandantenname";

if($db_ok != "KO") {
$db = pg_connect($conn);

	pg_query("BEGIN TRANSACTION");
	$sqlfile = '/var/www/unternehmer/branches/flo/sql/phpunternehmer.sql';
	//datei in array einlesen
	$array = file($sqlfile);
	$query = "";
	
	for($i = 0; $i < count($array); $i++) {
		if( strstr($array[$i], '--') == FALSE) {
			$query .= str_replace("xyz", $mandantenname, $array[$i]);
			
			if( strstr($array[$i], ';') != FALSE) {
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
		//da create database und group nicht in einer transaction stehen duerfen
		//muessen diese wieder geloescht werden per code, wenn fehler auftrat
		$query = "DROP DATABASE $mandantenname";
		if( ($resultat = pg_query($query)) == false)
			print "Fehler db loeschen<br>";
		$query = "DROP GROUP $mandantenname";
		if( ($resultat = pg_query($query)) == false)
			print "Fehler gruppe loeschen<br>";
	} else {
		pg_query("COMMIT");
		print "Mandant erfolgreich angelegt";
	}
	
}



?>
