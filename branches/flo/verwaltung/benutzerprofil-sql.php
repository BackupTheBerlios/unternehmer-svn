<?php
session_start();
//loginname und passwort abspeichern
//benutzer zu den ausgewahlten gruppen hinzufuegen
//ausgewaehlte programmoberflaeche in jede db abspeichern welcher mandant ausgewaehlt wurde
//das hat den vorteil, das man spaeter fuer jeden mandanten eine unterschiedliche 
//programmoberflaeche benutzen kann.
$conn = "host={$_SESSION['dbrechner']} port=5432 ".
        "user={$_SESSION['benutzer']} password={$_SESSION['passwort']} dbname=template1";
	
$db = pg_connect ($conn);
$loginname = $_POST['loginname'];
$oldloginname = $_POST['oldloginname'];
$passwort = $_POST['passwort'];

//wuerde ein neues passwort eingegeben?
if($loginname != "") {
	$query = "ALTER ROLE $loginname WITH PASSWORD '$passwort'";
	$resultat = pg_query($query);
	if($resultat == false) {
		print "Fehler";
	} 
}
	
pg_query("BEGIN TRANSACTION");
	
//schleife hier fuer alle angeklickten mandanten
$query = "SELECT groname FROM pg_group";
$resultat = pg_query($query);
$anz = pg_num_rows($resultat);
for($i = 0; $i < $anz; $i++) {
	$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		
	if($_POST[$array[0]] == "on") {
		$mandantenname = $array[0];
		$query = "ALTER GROUP $mandantenname ADD USER $loginname";
		$resultat1 = pg_query($query);
		if($resultat1 == false) {
			print "Fehler Benutzer zu einer Gruppe hinzuzufuegen<br>";
			$db_ok = "KO";
		} else {
			print "Benutzer erfolgreich zu einer Gruppe hinzugefuegt<br>";
		}
	} else {
		$mandantenname = $array[0];
		$query = "ALTER GROUP $mandantenname DROP USER $loginname";
		$resultat1 = pg_query($query);
		if($resultat1 == false) {
			print "Fehler Benutzer von einer Gruppe zu loeschen<br>";
			$db_ok = "KO";
		} else {
			print "Benutzer erfolgreich von Gruppe geloescht<br>";
		}
	}
}
	
if($db_ok == "KO") {
	pg_query("ROLLBACK");
} else {
	pg_query("COMMIT");
	include "verwaltungsmaske.php";
}
	
?>
