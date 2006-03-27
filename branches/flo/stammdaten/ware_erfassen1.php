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
		$preise_id = pg_fetch_row($resultat, 0);
		
		$query = "SELECT id FROM konten WHERE kontennr='{$_POST['erloeskonto']}'";

		$resultat = pg_query($query);
		if($resultat == false) {
			pg_query("ROLLBACK");
		} else {
			//daten einsammeln
			$erloeskonto = pg_fetch_row($resultat, 0);
			
			$query = "SELECT id FROM konten WHERE kontennr='{$_POST['aufwandskonto']}'";

			$resultat = pg_query($query);

			if($resultat == false) {
				pg_query("ROLLBACK");
			} else {
				$aufwandskonto = pg_fetch_row($resultat, 0);
				
				if($_POST['artikelbezeichnung'] != "") {$bezeichnung = $_POST['artikelbezeichnung'];} else {$bezeichnung = 0;}
				if($_POST['artikelnr'] != "") {$art_nr = $_POST['artikelnr'];} else {$art_nr = 0;} 
				if($hersteller_id == "") {$hersteller_id = 0;} 
				if($vo_details_id == "") {$vo_details_id = 0;}
				
				//konten_id in aufwandskonto-spalte und erloeskonto-spalte aufteilen, oder noch eine tabelle anlegen
				$query = "INSERT INTO verkaufsobjekt(bezeichnung, art_nr, preise_id, konten_id, hersteller_id, vo_details_id) VALUES('$bezeichnung', '$art_nr', '$preise_id', '$konten_id', '$hersteller_id', '$vo_details_id')";
print $query;
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
