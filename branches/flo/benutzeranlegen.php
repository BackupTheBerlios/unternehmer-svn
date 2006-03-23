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
	<td><input type=text name="passwort" size=20 maxlength=20 tabindex="1"></td>
</tr>

<tr>
	<td><input type=submit value="Benutzer anlegen"></td>
</tr>

<?php
//wenn ein passwort und ein loginname gesetz sind, abspeichern in die postgresql db "angestellte"
//
} else {
define('PGHOST','localhost');
define('PGPORT',5432);
define('PGDATABASE','phpunternehmer');
define('PGUSER', 'postgres');
define('PGPASSWORD', '');
define('PGCLIENTENCODING','UNICODE');
define('ERROR_ON_CONNECT_FAILED','Sorry, can not connect the database server now!');

$conn = "host=$PGHOST port=$PGPORT dbname=$PGDATABASE ".
        "user='postgres' password=''";
	$db = pg_connect ($conn);

$query = "INSERT INTO angestellte('login_name', 'passwort') values('{$_POST['loginname']}', '{$_POST['passwort']}')";

$resultat = pg_query($conn, $query);

print $resultat;

}
?>
</table>
</body>
</html>


