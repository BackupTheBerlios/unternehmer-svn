<?php
session_start();

//ueberpruefen ob loginname und/oder passwort fehlt
if( $_POST['loginname'] == "" || $_POST['passwort'] == "" || $_POST['dbname'] == "") {

//wenn was fehlt, zurueck zu login
include "/var/www/unternehmer/branches/flo/login.php";

} else {

if(!empty($_POST['loginname'])) { $loginname = $_POST['loginname']; } else { $loginname = "";}
//if(!empty($_POST['passwort'])) { $passwort = md5(trim($_POST['passwort'])); } else { $passwort = "";}
if(!empty($_POST['passwort'])) { $passwort = $_POST['passwort']; } else { $passwort = "";}

//session variable setzen
if(!isset($_SESSION['benutzer']) && !isset($_SESSION['passwort']) ) {
	$_SESSION['benutzer'] = $_POST['loginname'];
	$_SESSION['passwort'] = $_POST['passwort'];
} elseif (isset($_SESSION['benutzer']) && isset($_SESSION['passwort']) ) {
	if(!empty($_POST['benutzer']) && !empty($_POST['passwort']) ) {
		$_SESSION['benutzer'] = $loginname;
		$_SESSION['passwort'] = $passwort;
	} else {
		$loginname = $_SESSION['benutzer'];
		$passwort = $_SESSION['passwort'];
	}
}

$_SESSION['datenbankname'] = $_POST['dbname'];

//verbindung zur datenbank 
$conn = "host=localhost port=5432 dbname=phpunternehmer ".
        "user=postgres password=";
	
$db = pg_connect ($conn);

//ueberpruefen ob loginname und passwort existieren
$query = "SELECT usename, passwd FROM pg_shadow WHERE usename='$loginname' AND passwd='$passwort' ";
$resultat = @pg_query($query);
if( $resultat == false || pg_numrows($resultat) < 1) {
	$fehlermeldung .= 'Benutzer oder Passwort existiert nicht';
	print $fehlermeldung;
	include "/var/www/unternehmer/branches/flo/login.php";
}

//loginname und passwort existieren, login erlaubt

//noch zusaetzlich ueberpruefen ob er berechtigungen fuer zugriff auf db hat, wegen mandantenfaehigkeit
//es gibt ja mehrere mandanten/tabellen
if( pg_num_rows($resultat) == 1) {
	include "/var/www/unternehmer/branches/flo/menu.php";
}

}
?>

