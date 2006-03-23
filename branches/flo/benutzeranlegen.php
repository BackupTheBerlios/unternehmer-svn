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

//einfuegen des vornamen, ein angestellter MUSS wohl einen vornamen haben, oder?
$query = "INSERT INTO go_name(vorname) values('{$_POST['vorname']}')";
$result = pg_query($query);
//if($result) 
//	print $result;

//id aus go_name auslesen, damit man die referentielle integrietät der daten sicherstellt
$query = "SELECT currval('go_name_id_seq'::text) as key";
$result = pg_query($query);
$serial_prim_key = pg_fetch_array($result, 0);
$serial_prim_key = $serial_prim_key[key];

//einfuegen der id, passwortes und des loginnames
$query = "INSERT INTO login_info(id, loginname, passwort) values('$serial_prim_key', '{$_POST['loginname']}', '{$_POST['passwort']}')";
$resultat = pg_query($query);

//fehler von query's abfangen und entsprechend ausgeben.

//db verbindung abbauen? noetig bei php?
}
?>
</table>
</body>
</html>


