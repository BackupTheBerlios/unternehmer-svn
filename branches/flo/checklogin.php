<html>
<body>

<?php
//ueberpruefen ob loginname und/oder passwort fehlt
if( $_POST['loginname'] == "" || $_POST['passwort'] == "") {

//zurueck zu login

} else {
//verbindung zur datenbank 
$conn = "host=localhost port=5432 dbname=phpunternehmer ".
        "user=postgres password=";
	
$db = pg_connect ($conn);

//ueberpruefen ob loginname und passwort existieren
$query = "SELECT * FROM login_info WHERE loginname='{$_POST['loginname']}' AND passwort='{$_POST['passwort']}' ";
$result = pg_query($query);
print $result;

//loginname und passwort existieren, login erlaubt

//loginname und passwort existieren NICHT, zurueck zu login-bild

}
?>

</body>
</html>
