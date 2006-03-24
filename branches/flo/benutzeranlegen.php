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

// -----ERSTE DATENBANKAKTION

//transaction level auf serializable setzen, damit falls es zu fehlern in einem query kam, die datenbank ein rollback machen kann. sicherheit
$query = "SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE";

//fehlerbehandlung
//das @-zeichen vor einer funktion bedeutet das die fehler/warning ausgabe unterdrueckt wird.
//fehler sollen in menschlich-verstaendlicher form ausgegeben werden.(wenn moeglich)
$resultat = @pg_query($query);
if( $resultat == false) {
	$fehlermeldung .= '$php_errormsg';
	$fehlermeldung .= 'fehlermeldung: SET SESSION CHARACTERISTICS fehlgeschlagen';	
	print $fehlermeldung;
	//passwort loeschen, damit die obere bedingung eintritt um die maske zu sehen
	$_POST['passwort'] = "";
	//variable um am schluss richtigerweise "geklappt" oder "nicht geklappt" auszugeben, vielleicht hat jemand ne eleganter art
	//und um andere querys zu unterbinden. Man koennte es mit elseif's machen, aber das waere zu verschachtelt/unuebersichtlich
	$db_ok = "KO";
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}


// -----ZWEITE DATENBANKAKTION

//transaction beginnen
if( $db_ok != "KO") {
$query = "BEGIN TRANSACTION";
$resultat = @pg_query($query);
if( $resultat == false) {
	$fehlermeldung .= '$php_errormsg';
	$fehlermeldung .= 'fehlermeldung: BEGIN TRANSACTION fehlgeschlagen';
	print $fehlermeldung;
	$_POST['passwort'] = "";
	$db_ok = "KO";
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}
} //ende if

// -----DRITTE DATENBANKAKTION

//einfuegen des vornamen, ein angestellter MUSS wohl einen vornamen haben, oder?
if( $db_ok != "KO") {
$query = "INSERT INTO go_name(vorname) values('{$_POST['vorname']}')";
$resultat = @pg_query($query);

//fehlerbehandlung
if( $resultat == false) {
	//fehlerbehandlung einfuegen
	$fehlermeldung .= '$php_errormsg';
	$fehlermeldung .= 'fehlermeldung: Datenbank INSERT in tabelle go_name fehlgeschlagen';
	//fehlermeldung ausgeben als information fuer den benutzer/entwickler
	print $fehlermeldung;
	//alle transactionen zuruecksetzen in der datenbank
	pg_query("ROLLBACK");
	$_POST['passwort'] = "";
	$db_ok = "KO";
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}
} //ende if

// -----VIERTE DATENBANKAKTION

//id aus go_name auslesen, damit man die referentielle integrietät der daten sicherstellt
if( $db_ok != "KO") {
$query = "SELECT currval('go_name_id_seq'::text) as key";
$resultat = @pg_query($query);

//fehlerbehandlung
if( $resultat == false) { 
	//fehlerbehandlung einfuegen
	$fehlermeldung .= '$php_errormsg';
	$fehlermeldung .= 'fehlermeldung: SELECT currval() fehlgeschlagen';
	print $fehlermeldung;
	pg_query("ROLLBACK");
	$_POST['passwort'] = "";
	$db_ok = "KO";
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}
//ermittlung des primaeren schluessels
$serial_prim_key = pg_fetch_array($resultat, 0);
$serial_prim_key = $serial_prim_key[key];
} //ende if

// ------FUENFTE DATENBANKAKTION

//einfuegen der id, passwortes und des loginnames,
//damit man tabellenberechtigungen auf der db setzen kann und nicht im code.
//pg_user ist die public-view (ohne passwoerter) von benutzerdb, pg_shadow ist die original
//ein angestellter bekommt keine berechtigung eine db anzulegen, er/sie benutzt sie nur.
if( $db_ok != "KO") {
$query = "INSERT INTO pg_shadow(usesysid, usename, passwd, usecreatedb, usesuper, usecatupd ) values('$serial_prim_key', '{$_POST['loginname']}', '{$_POST['passwort']}', 'f', 'f', 'f')";

//fehlerbehandlung
$resultat = @pg_query($query);
if( $resultat == false) {
	//fehlerbehandlung einfuegen
	$fehlermeldung .= '$php_errormsg';
	$fehlermeldung .=  'fehlermeldung: INSERT INTO pg_shadow fehlgeschlagen';
	print $fehlermeldung;
	pg_query("ROLLBACK");
	$_POST['passwort'] = "";
	$db_ok = "KO";
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}
} //ende if

// ------SECHSTE DATENBANKAKTION

//id aus login_info auslesen, damit man die referentielle integrietat der daten sicherstellt
if( $db_ok != "KO") {
$query = "INSERT INTO angestellte(pg_shadow_usesysid, name_id) values('$serial_prim_key', '$serial_prim_key')";

//fehlerbehandlung
$resultat = @pg_query($query);
if( $resultat == false) {
	//fehlerbehandlung einfuegen
	$fehlermeldung .=  '$php_errormsg';
	$fehlermeldung .=  'fehlermeldung: INSERT INTO angestellte fehlgeschlagen';
	print $fehlermeldung;
	pg_query("ROLLBACK");
	$_POST['passwort'] = "";
	$db_ok = "KO";
	include "/var/www/unternehmer/branches/flo/benutzeranlegen.php";
}
} //ende if

//db verbindung abbauen? noetig bei php?
//laut irc wird verbindung automatisch bei ende des scrips abgebaut, ausser bei persistent verbindungen

//wenn man bis hierhin gekommen ist, dann sag bescheid was los war
if( $db_ok != "KO") { 
	print "Benutzer erfolgreich angelegt";
} else {
	print "Benutzer anlegen fehlgeschlagen";
}

}
?>
</table>
</body>
</html>


