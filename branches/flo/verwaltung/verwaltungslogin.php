<?php
session_start();
if($_POST['loginname'] != "" && $_POST['passwort'] && $_POST['dbrechner'] != "") {

	if(!empty($_POST['loginname'])) { 
		$loginname = $_POST['loginname']; 
	} else { 
		$loginname = "";
	}
	
	if(!empty($_POST['passwort'])) { 
		//passwort in postgresql is md5 und salted mit username
		$tmp = trim($_POST['passwort']); 
		$tmp1 = trim($_POST['loginname']);
		$tmp2 = $tmp . $tmp1;
		$passwort1 = md5(trim($tmp2));
		$passwort = "md5" . $passwort1;
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
	
	$_SESSION['dbrechner'] = $_POST['dbrechner'];

	//verbindung zur datenbank 
	$conn = "host={$_POST['dbrechner']} port=5432 dbname=template1 ".
        	"user={$_POST['loginname']} password='{$_POST['passwort']}'";

	$db = @pg_connect($conn);
	if(!$db){print "Benutzername oder Passwort falsch";}
	if($db) {include "verwaltungsmaske.php"; $log = "OK";}

} else {

?>
<html>
<body>
<table width="100%" border="1">
<form method="post" action="verwaltungslogin.php">
<tr>
	<td><center><h2>Verwaltungslogin</center></h2></td>
</tr>
<tr>
	<td>Loginname</td>
	<td><input type="text" name="loginname"></td>
</tr>
<tr>
	<td>Passwort</td>
	<td><input type="text" name="passwort"></td>
</tr>
<tr>
	<td>Datenbankrechner</td>
	<td><input type="text" name="dbrechner" value="localhost"></td>
</tr>
<tr>
	<td colspan="2"><center><input type="submit" value="Anmelden"></center></td>
</tr>
</form>
</table>
</body>
</html>

<?php } ?>
