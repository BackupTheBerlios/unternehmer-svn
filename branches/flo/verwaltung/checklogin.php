<?php
session_start();

//ueberpruefen ob loginname und/oder passwort fehlt
if( $_POST['loginname'] == "" || $_POST['passwort'] == "" || $_POST['dbname'] == "") {
	//wenn was fehlt, zurueck zu login
	include "login.php";
} else {
	if(!empty($_POST['loginname'])) { 
		$loginname = $_POST['loginname']; 
	} else { 
		$loginname = "";
	}
	if(!empty($_POST['passwort'])) { 
		$passwort = $_POST['passwort'];
	} else { 
		$passwort = "";
	}

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
	$dbname = $_POST['dbname'];


	//verbindung zur datenbank 
	$conn = "host={$_POST['dbrechner']} port=5432 dbname=$dbname ".
        	"user={$_POST['loginname']} password=$passwort";

	$db = @pg_connect($conn);
	if(!$db){
		print "Benutzername oder Passwort falsch";
		include "login.php";
	} else {
		include "menu.php"; 
	}
}
?>
