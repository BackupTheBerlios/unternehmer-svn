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
	
	//db-relationen: erst preise einfuegen und konten ids ermitteln, dann das verkaufsobjekt
	$query = "INSERT INTO preise(listenpreis, einkaufspreis, verkaufspreis) VALUES('$listenpreis', '$einkaufspreis', '{$_POST['verkaufspreis']}')";

	$resultat = pg_query($query);

	if($resultat == false){
		pg_query("ROLLBACK");
	} else {
		$query = "SELECT currval('preise_id_seq'::text) as key";
		$resultat = @pg_query($query);

		//fehlerbehandlung
		if( $resultat == false) { 
			$fehlermeldung .= '$php_errormsg';
			$fehlermeldung .= 'fehlermeldung: SELECT currval() fehlgeschlagen';
			print $fehlermeldung;
			pg_query("ROLLBACK");
		} else {
			//ermittlung des primaeren schluessels
			$preise_id = pg_fetch_array($resultat, 0);
			$preise_id = $preise_id[key];
		}
	
		//prim-key-id von den jeweiligen konten holen
		$query = "SELECT id FROM konten WHERE kontennr='{$_POST['erloeskonto']}'";
		
		$resultat = pg_query($query);
		if($resultat == false) {
			pg_query("ROLLBACK");
		} else {
			//daten einsammeln
			$erloeskonto_id = pg_fetch_row($resultat, 0);
			$erloeskonto_id = $erloeskonto_id[0];
			
			$query = "SELECT id FROM konten WHERE kontennr='{$_POST['aufwandskonto']}'";

			$resultat = pg_query($query);

			if($resultat == false) {
				pg_query("ROLLBACK");
			} else {
				$aufwandskonto_id = pg_fetch_row($resultat, 0);
				$aufwandskonto_id = $aufwandskonto_id[0];

				$bezeichnung = $_POST['artikelbezeichnung'];
				
				if($_POST['artikelnr'] != "") {
					$art_nr = $_POST['artikelnr'];
				} else {
					$art_nr = "NULL";
				} 
				//konten_id in aufwandskonto-spalte und erloeskonto-spalte aufteilen, oder noch eine tabelle anlegen

				if($hersteller_id == "") {
					$hersteller_id = "NULL";
				}
				if($vo_details_id == "") {
					$vo_details_id = "NULL";
				}
				$query = "INSERT INTO verkaufsobjekt(bezeichnung, art_nr, preise_id, erloeskonto_id, aufwandskonto_id, hersteller_id, vo_details_id) VALUES('$bezeichnung', $art_nr, $preise_id, $erloeskonto_id, $aufwandskonto_id, $hersteller_id, $vo_details_id)";

				$resultat = pg_query($query);

				if($resultat = false) {
					pg_query("ROLLBACK");
					print "Fehler bei Ware anlegen";
				} else {
					pg_query("COMMIT");
					print "Ware erfolgreich angelegt";
				}
			}
		}
	}
}
?>
