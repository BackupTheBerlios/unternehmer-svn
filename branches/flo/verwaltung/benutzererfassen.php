<?php
session_start();
//ueberpruefen ob ein passwort und loginname gesetzt sind, wenn nicht, (erneut) maske zeigen
//
if($_POST['passwort'] == "" || $_POST['loginname'] == "") {
?>
<html>
<body>

<h1>Benutzer anlegen</h1>

<form method=post name=checklogin action="benutzererfassen.php">
<table border=1>
<tr>
	<td>Login Name:</td>
	<td><input type=text name="loginname" size=20 maxlength=20 tabindex="1"></td>
</tr>

<tr>
	<td>Passwort:</td>
	<td><input type=text name="passwort" size=20 maxlength=20></td>
</tr>

<tr>
	<td>Vorname:</td>
	<td><input type=text name="vorname" size=20 maxlength=20></td>
</tr>


<tr>
	<td><input type=submit value="Benutzer anlegen"></td>
</tr>

<?php
//wenn ein passwort und ein loginname gesetz sind, abspeichern in die postgresql db 
//
} else {
//verbindung zur datenbank und loginname und passwort speichern.
$conn = "host={$_SESSION['dbrechner']} port=5432 dbname=template1 ".
        "user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect ($conn);

//transaction level auf serializable setzen, damit falls es zu fehlern in einem query kam, die datenbank ein rollback machen kann. sicherheit
$query = "SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE";
$resultat = @pg_query($query);

//fehlerbehandlung
if( $resultat == false) {
		$db_ok = "KO";
}



//transaction beginnen
if( $db_ok != "KO") {
$query = "BEGIN TRANSACTION";
$resultat = @pg_query($query);
if( $resultat == false) {
	$_POST['passwort'] = "";
	$db_ok = "KO";
}
} //ende if

//einfuegen der id, passwortes und des loginnames,
//damit man tabellenberechtigungen auf der db setzen kann und nicht im code.
//pg_user ist die public-view (ohne passwoerter) von benutzerdb, pg_shadow ist die original
//ein programmbediener (kann auch fremdfirma sein,kein direkter mitarbeiter) bekommt keine 
//berechtigung eine db anzulegen, er/sie benutzt sie nur.
if( $db_ok != "KO") {
$query = "CREATE USER {$_POST['loginname']} PASSWORD '{$_POST['passwort']}'";

//fehlerbehandlung
$resultat = @pg_query($query);
if( $resultat == false) {
	$db_ok = "KO";
}
} //ende if

//wenn nichts ein fehler ergab, dann fuhre die transaction jetzt aus
//wenn man bis hierhin gekommen ist, dann sag bescheid was los war
if( $db_ok != "KO") { 
	pg_query("COMMIT");
	print "Benutzer erfolgreich angelegt";
	include "verwaltungsmaske.php";
} else {
	pg_query("ROLLBACK");
	print "Benutzer anlegen fehlgeschlagen";
	//passwort loeschen, damit die obere bedingung eintritt um die maske zu sehen
	$_POST['passwort'] = "";
	include "benutzererfassen.php";
}
}

?>
</table>
</body>
</html>


