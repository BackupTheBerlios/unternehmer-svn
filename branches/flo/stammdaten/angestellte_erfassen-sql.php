<?php
session_start();
$dbname = $_SESSION['datenbankname'];
$benutzer = $_SESSION['benutzer'];
$passwort = $_SESSION['passwort'];
$vorname = $_POST['vorname'];
$nachname = $_POST['nachname'];

$conn = "host=localhost port=5432 dbname=$dbname user=$benutzer password=$passwort";
$db = pg_connect ($conn);

$query = "INSERT INTO go_name(vorname, nachname) VALUES('$vorname', '$nachname')";

$resultat = pg_query($query);
if($resultat == false) {
	print "Fehler beim erfassen des/der Angestellten";
} else {
	print "Angestellte(n) erfolgreich angelegt";
	
	$query = "SELECT currval('go_name_id_seq'::text) as key";
	$resultat = @pg_query($query);

	//fehlerbehandlung
	if( $resultat == false) { 
		//fehlerbehandlung einfuegen
	}
	//ermittlung des primaeren schluessels
	$serial_prim_key = pg_fetch_array($resultat, 0);
	$serial_prim_key = $serial_prim_key[key];
	
	$query = "INSERT INTO angestellte(go_name_id) VALUES($serial_prim_key)";
	$resultat = pg_query($query);
	if($resultat == false) {
		print "fehler angestellte anlegen";
	} else {
		print "angestellte erfolgreich angelegt";
	}

}

?>
