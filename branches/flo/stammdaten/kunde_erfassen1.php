<?php
session_start();

//ueberpruefen ob die minimal angaben gemacht wurden
$ok = 0;
if($_POST['firmenname'] != "") {
	$ok = 1;
} elseif($_POST['vorname'] != "") {
	$ok = 1;
} elseif($_POST['nachname'] != "") {
	$ok = 1;
} 

if($ok != 1) {
	print "firmenname,vorname oder nachname vergessen";
	include "/var/www/unternehmer/branches/flo/stammdaten/kunde_erfassen.php";
}

else {
	$passwort =  htmlspecialchars($_SESSION['passwort']);
	$benutzer =  htmlspecialchars($_SESSION['benutzer']);
	$dbname =  htmlspecialchars($_SESSION['datenbankname']);
	
	$conn = "host=localhost port=5432 dbname=$dbname user=$benutzer password=$passwort";
	
	$db = pg_connect ($conn);

	//transaction beginnen
	pg_query("BEGIN TRANSACTION");

	$firmenname = $_POST['firmenname'];
	$vorname = $_POST['vorname'];
	$nachname = $_POST['nachname'];
	$strasse = $_POST['strasse'];
	$hausnr = $_POST['hausnr'];
	$plz = $_POST['plz'];
	$land = $_POST['land'];		
   $stadt = $_POST['stadt'];
   
	$query = "INSERT INTO go_name(firmenname, vorname, nachname) values('$firmenname', '$vorname', '$nachname')";

	$resultat = pg_query($query);
	if($resultat == false) {
		 pg_query("ROLLBACK");
	} else {
		$query = "SELECT currval('go_name_id_seq'::text) as key";
		$resultat = @pg_query($query);

		//fehlerbehandlung
		if( $resultat == false) { 
			//fehlerbehandlung einfuegen
			$fehlermeldung .= '$php_errormsg';
			$fehlermeldung .= 'fehlermeldung: SELECT currval() fehlgeschlagen';
			print $fehlermeldung;
			pg_query("ROLLBACK");
		}
		//ermittlung des primaeren schluessels
		$serial_prim_key = pg_fetch_array($resultat, 0);
		$serial_prim_key = $serial_prim_key[key];
	
		$query = "INSERT INTO adresse VALUES('$serial_prim_key', '$strasse', '$hausnr', '$plz', '$stadt', '$land');";

		$resultat = pg_query($query);
		if($resultat == false) {
			print "fehler2";
			pg_query("ROLLBACK");
		} else {
			pg_query("COMMIT");
		}

	}
}
?>

<html>
<body>
Kunde erfolgreich angelegt<br>
Danke
</body>
</html>
