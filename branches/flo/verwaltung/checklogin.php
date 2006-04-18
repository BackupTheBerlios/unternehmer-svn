<?php
session_start();

//ueberpruefen ob loginname und/oder passwort fehlt. 
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
	$_SESSION['dbrechner'] = $_POST['dbrechner'];
	$_SESSION['benutzer'] = $_POST['loginname'];
	$_SESSION['passwort'] = $_POST['passwort'];
	$_SESSION['dbname'] = $_POST['dbname'];
	$dbname = $_POST['dbname'];

	//verbindung zur datenbank 
	$conn = "host={$_POST['dbrechner']} port=5432 dbname={$_POST['dbname']} ".
        	"user={$_POST['loginname']} password={$_POST['passwort']}";

	$db = @pg_connect($conn);
	
	if(!$db){
		print "Benutzername oder Passwort falsch";
		include "login.php";
	} else {
		//noch ueberpruefen ob er/sie in der gruppe(fuer mandant) auch ist
		
		include "menu.php"; 
	}
}
?>
