<?php

//ueberpruefen ob loginname und/oder passwort fehlt
if( $_POST['loginname'] == "" || $_POST['passwort'] == "") {

//wenn was fehlt, zurueck zu login
include "/var/www/unternehmer/branches/flo/login.php";

} else {

//session variable setzen
if(!isset($_SESSION['user']) && !isset($_SESSION['pass']) ) {
	$_SESSION['user'] = $_POST['loginname'];
	$_SESSION['pass'] = $_POST['passwort'];
}

//verbindung zur datenbank 
$conn = "host=localhost port=5432 dbname=phpunternehmer ".
        "user=postgres password=";
	
$db = pg_connect ($conn);

//ueberpruefen ob loginname und passwort existieren
$query = "SELECT usename, passwd FROM pg_shadow WHERE usename='{$_POST['loginname']}' AND passwd='{$_POST['passwort']}' ";
$resultat = @pg_query($query);
if( $resultat == false || pg_numrows($resultat) < 1) {
	$fehlermeldung .= 'Benutzer oder Passwort existiert nicht';
	print $fehlermeldung;
	include "/var/www/unternehmer/branches/flo/login.php";
	$db_ok = "KO";
}

//loginname und passwort existieren, login erlaubt
if( $db_ok != "KO") {
	include "/var/www/unternehmer/branches/flo/menu.php";
}

}
?>

