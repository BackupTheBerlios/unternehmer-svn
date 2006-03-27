<?php
session_start();
//ueberpruefen nach minimal angaben
if( $_POST['artikelbezeichnung'] == "" && $_POST['verkaufspreis'] == "" && $_POST['erloeskonto'] == "" && $_POST['aufwandskonto'] == "") {
	print "Entschuldigung, Sie haben eine der Pflichtangaben vergessen";
	include "ware_erfassen.php";
} else {
	$benutzer = $_SESSION['benutzer'];
	$passwort = $_SESSION['passwort'];
	$dbname = $_SESSION['datenbankname'];
	
	$conn = "host=localhost port=5432 dbname=$dbname user=$benutzer password=$passwort";
	
	$db = pg_connect ($conn);
	
	pg_query("BEGIN TRANSACTION");
	
	if($_POST['listenpreis'] == "") {
		$listenpreis = 0.0;
	} else {
		$listenpreis = $_POST['listenpreis'];
	}
	if($_POST['einkaufspreis'] == "") {
		$einkaufspreis = 0.0;
	} else {
		$einkaufspreis = $_POST['einkaufspreis'];
	}
	
	//db-relationen: erste preise und konten einfuegen, dann das verkaufsobjekt
	$query = "INSERT INTO preise(listenpreis, einkaufspreis, verkaufspreis) VALUES('$listenpreis', '$einkaufspreis', '{$_POST['verkaufspreis']}')";
print $query;
	$resultat = pg_query($query);

	if($resultat == false){
		pg_query("ROLLBACK");
	} else {
		$query = "SELECT id FROM konten WHERE kontennr='{$_POST['erloeskonto']}'";

		$resultat = pg_query($query);
		if($resultat == false) {
			pg_query("ROLLBACK");
		} else {
			//daten einsammeln
			$erloeskonto = pg_fetch_array($resultat, 0);
			print $erloeskonto;
			
			$query = "SELECT id FROM konten WHERE kontennr='{$_POST['aufwandskonto']}'";

			$resultat = pg_query($query);

			if($resultat == false) {
				pg_query("ROLLBACK");
			} else {
				$aufwandskonto = pg_fetch_array($resultat, 0);
				print $aufwandskonto;
				
				$query = "INSERT INTO verkaufsobjekt(bezeichnung, art_nr, preise_id, konten_id, hersteller_id, vo_details_id) VALUES('{$_POST['artikelbezeichnung']}', '{$_POST['artikelnr']}', '$preise_id', '$konten_id', '$hersteller_id', '$vo_details_id')";

				$resultat = pg_query($query);

				if($resultat = false) {
					pg_query("ROLLBACK");
				} else {
					pg_query("COMMIT");
				}
			}
		}
	}
}
?>
