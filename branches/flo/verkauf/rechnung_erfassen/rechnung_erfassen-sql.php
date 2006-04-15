<?php
session_start();

//erst wird in tabelle rechnung eingetragen, eine reihe nur
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect($conn);

pg_query("BEGIN TRANSACTION");

//kundennr ermitteln
$kundennr = $_POST['kunde'];
$kundennr = explode('---', $kundennr);
$kundennr = $kundennr[1];

//faelligkeitsdatum umwandeln in postgresql-date
$faelligkeitsdatum = $_POST['faelligkeitsdatum'];
$datum = explode('.', $faelligkeitsdatum);
for($i = 2; $i >= 0; $i--) {
	$pg_datum .= $datum[$i];
	if($i > 0) {$pg_datum .= '-';};
}
$faelligkeitsdatum = $pg_datum;
$pg_datum = "";

//rechnungsdatum umwandeln in postgresql-date
$rechnungsdatum = $_POST['rechnungsdatum'];
$datum = explode('.', $rechnungsdatum);
for($i = 2; $i >= 0; $i--) {
	$pg_datum .= $datum[$i];
	if($i > 0) {$pg_datum .= '-';};
}
$rechnungsdatum = $pg_datum;


//rechnung eintragen, es gibt nur eine rechnung, aber mehrere verkaufsobjekte, rechnung_vo
$query = "INSERT INTO rechnung(kunde_id, rechnungsdatum, faelligkeitsdatum)".
			" VALUES($kundennr, '$rechnungsdatum', '$faelligkeitsdatum')";
			
$resultat = pg_query($query);
if($resultat == false) {
	print "fehler";
	$db_ok = "KO";
} else {
	$query = "SELECT currval('rechnung_id_seq'::text) as key";
	$resultat = pg_query($query);

	//fehlerbehandlung
	if( $resultat == false) { 
		print "fehler 2";
		$db_ok = "KO";
	} else {
		//ermittlung des primaeren schluessels
		$serial_prim_key = pg_fetch_array($resultat, 0);
		$serial_prim_key = $serial_prim_key[key];
	}
}

//dann alle einzelen objekte als einzelne reihe in rechnung_verkaufsobjekt mit rechnung_id = rechnung(id)
//preise_id wird aus tabelle preise(id) geholt geholt
//buchungskonto_id wird aus konten(id) geholt
//fake anz_vo

//ermitteln der anzahl von reihen
$i = 1;
while($_POST["pos_$i"] != "" && $_POST["bezeichnung_$i"] != "") {
$i++;
}
$anz_vo = $i - 1;

//wenn es keine artikel gibt, wird auch keine rechnung gebucht, KO macht zum schluss ROLLBACK
if($anz_vo == 0) { $db_ok = "KO";}

if($db_ok != "KO") {
for($i = 1; $i <= $anz_vo; $i++) {
	$pos = $_POST['position_$i'];	
	
	$kundennr = $_POST['kunde'];
	$kundennr = explode('---', $kundennr);
	$kundennr = $kundennr[1];
	
	
	//vo_id muss ermittelt werden aus bezeichnung oder art_nr
	$art_nr = $_POST["art_nr_$i"];
	if($art_nr != "") {
		$art_nr = "'"; 
		$art_nr .= $_POST["art_nr_$i"]; 
		$art_nr .= "'";
	}
	$bezeichnung = $_POST["bezeichnung_$i"];
	if($bezeichnung != "") {
		$bezeichnung = "'"; 
		$bezeichnung .= $_POST["bezeichnung_$i"]; 
		$bezeichnung .= "'";
	}
	
	if($bezeichnung != "" && $art_nr != "") {
		$query = "SELECT id FROM verkaufsobjekt WHERE bezeichnung = $bezeichnung AND art_nr = $art_nr";
	} elseif ($bezeichnung == "" && $art_nr != "") {
		$query = "SELECT id FROM verkaufsobjekt WHERE art_nr = $art_nr";
	} elseif ($bezeichnung != "" && $art_nr == "") {
		$query = "SELECT id FROM verkaufsobjekt WHERE bezeichnung = $bezeichnung";
	}
	
	$resultat = pg_query($query);
	if(resultat == false) {
		print "fehler12";
		$db_ok = "KO";
	} else {
		$pg_reihe = pg_fetch_row($resultat);
		$vo_id = $pg_reihe[0];
	}
	//ende vo_id ermitteln
	
	//ermitteln von vo_preise_id ueber tabelle verkaufsobjekt
	$query = "SELECT p.id FROM verkaufsobjekt v, preise p WHERE v.preise_id = p.id AND v.id = $vo_id";
	
	$resultat = pg_query($query);
	if($resultat == false) {
		print "fehler select vo_preise_id";
		$db_ok = "KO";
	} else {
		$pg_reihe = pg_fetch_row($resultat);
		$vo_preise_id = $pg_reihe[0];
	}
	
	//ermitteln buchungskonto id
	$buchungskonto_id = $_POST["buchungskonto"];
	$buchungskonto_id = explode("---", $buchungskonto_id);
	$buchungskonto_id = $buchungskonto_id[0];
	$query = "SELECT id FROM konten WHERE kontennr = $buchungskonto_id";
	$resultat = pg_query($query);
	if($resultat == false) {
		print "fehler select konto";
		$db_ok = "KO";
	} else {
		$pg_reihe = pg_fetch_row($resultat);
		$buchungskonto_id = $pg_reihe[0];
	}
	//ende buchungskonto id ermitteln

	$rabatt = $_POST["rabatt_$i"];
	$anzahl = $_POST["anzahl_$i"];
	
	$query = "INSERT INTO rechnung_vo(rechnung_id, vo_id, vo_preise_id, buchungskonto_id, anzahl, rabatt)" .
				"VALUES($serial_prim_key, $vo_id, $vo_preise_id, $buchungskonto_id, $anzahl, $rabatt)";
		
		
	$result = pg_query($query);
	if($result == false) {
		$db_ok = "KO";
	} 
}
} //ende if


if($db_ok == "KO") {
	pg_query("ROLLBACK");
	print "Fehler beim buchen der Rechnung";
} else {
	pg_query("COMMIT");
	print "Rechnung erfolgreich gebucht";
}


?>
 
