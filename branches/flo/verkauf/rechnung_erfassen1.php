<?php
session_start();

//erst wird in tabelle rechnung eingetragen, eine reihe nur
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect ($conn);

pg_query("BEGIN TRANSACTION");

$query = "INSERT INTO rechnung(kunde_id, rechnungsdatum, faelligkeitsdatum)".
			" VALUES($_POST['kundennr'], $_POST['rechnungsdatum'], $_POST['faelligkeitsdatum'])";
			
$resultat = pg_query($query);
if($resultat == false) {
	print "fehler";
} else {
	$query = "SELECT currval('go_name_id_seq'::text) as key";
	$resultat = @pg_query($query);

	//fehlerbehandlung
	if( $resultat == false) { 
		print "fehler";
		pg_query("ROLLBACK");
	} else {
		//ermittlung des primaeren schluessels
		$serial_prim_key = pg_fetch_array($resultat, 0);
		$serial_prim_key = $serial_prim_key[key];
	}
}

//dann alle einzelen objekte als einzelne reihe in rechnung_verkaufsobjekt mit rechnung_id = rechnung(id)
//preise_id wird aus tabelle preise(id) geholt geholt
//buchungskonto_id wird aus konten(id) geholt

for($i = 0; $i < anz_vo; $i++) {
	$pos = $_POST['position_$i'];	
	$kundennr = $_POST['kundennr'];
	$vo_preise_id = $_POST['vo_preise_id_$i'];
	$vo_id = $_POST['vo_id_$i'];
	$buchungskonto_id = $_POST['buchungskonto_id_$i'];
	$rabatt = $_POST['rabatt_$i'];
	$anzahl = $_POST['anzahl_$i'];
	
	$query = "INSERT INTO rechnung_vo(rechnung_id, vo_id, vo_preise_id, buchungskonto_id, anzahl, rabatt)" .
				"VALUES($serial_prim_key, $vo_id, $vo_preise_id, $buchungskonto_id, $anzahl, $rabatt)";
				
	$result = pg_query($query);
	if($result == false) {
		pg_query("ROLLBACK");
		exit();
	}
}

 