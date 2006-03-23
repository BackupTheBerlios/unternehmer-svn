<html>
<body>

<?php
//ueberpruefen ob ein passwort und loginname gesetzt sind, wenn nicht, (erneut) maske zeigen
//
if($_POST['passwort'] == "" || $_POST['loginname'] == "") {
?>

<h1>Benutzer anlegen</h1>

<form method=post name=checklogin action="benutzeranlegen.php">
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
//wenn ein passwort und ein loginname gesetz sind, abspeichern in die postgresql db "angestellte"
//
} else {
//verbindung zur datenbank und loginname und passwort speichern.
$conn = "host=localhost port=5432 dbname=phpunternehmer ".
        "user=postgres password=";
	
$db = pg_connect ($conn);

//transaction level auf serializable setzen, damit falls es zu fehlern in einem query kam, die datenbank ein rollback machen kann. sicherheit
$query = "SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE";
$resultat = pg_query($query);
if( $resultat == "FALSE") {
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}

//einfuegen des vornamen, ein angestellter MUSS wohl einen vornamen haben, oder?
$query = "INSERT INTO go_name(vorname) values('{$_POST['vorname']}')";
$resultat = pg_query($query);
if( $resultat == "FALSE") {
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}

//id aus go_name auslesen, damit man die referentielle integrietät der daten sicherstellt
$query = "SELECT currval('go_name_id_seq'::text) as key";
$resultat = pg_query($query);
if( $resultat == "FALSE") { 
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}
$serial_prim_key = pg_fetch_array($resultat, 0);
$serial_prim_key = $serial_prim_key[key];

//einfuegen der id, passwortes und des loginnames
//muss geandert werden , in die tabelle der postgresql-user, damit man auch die tabellenberechtigungen auf der db setzen kann und nciht im code
$query = "INSERT INTO login_info(id, loginname, passwort) values('$serial_prim_key', '{$_POST['loginname']}', '{$_POST['passwort']}')";
$resultat = pg_query($query);
if( $resultat == "FALSE") {
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}

//id aus login_info auslesen, damit man die referentielle integrietat der daten sicherstellt
$query = "INSERT INTO angestellte(login_info_id, name_id) values('$serial_prim_key', '$serial_prim_key')";
$resultat = pg_query($query);
if( $resultat == "FALSE") {
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}

//fehler von query's abfangen und entsprechend ausgeben.

//db verbindung abbauen? noetig bei php?
//laut irc wird verbindung automatisch bei ende des scrips abgebaut, ausser bei persistent verbindungen

}
?>
</table>
</body>
</html>


