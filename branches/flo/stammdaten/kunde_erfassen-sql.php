<?php
session_start();

//ueberpruefen ob die minimal angaben gemacht wurden
$ok = 0;
if($_POST['firmenname'] != "") {
	$ok = 1;
} elseif($_POST['vorname'] != "") {
	$ok = 1;
} elseif($_POST['nachname'] != "") {
	$ok = 1;
} 

if($ok != 1) {
	print "firmenname,vorname oder nachname vergessen";
	include "/var/www/unternehmer/branches/flo/stammdaten/kunde_erfassen.php";
}
//ende ueberpruefen ob minimal angaben gemacht wurden, ab hier beginnt angaben-gemacht-entscheidung

else {
	$passwort =  htmlspecialchars($_SESSION['passwort']);
	$benutzer =  htmlspecialchars($_SESSION['benutzer']);
	$dbname =  htmlspecialchars($_SESSION['dbname']);
	
	$conn = "host=localhost port=5432 dbname=$dbname user=$benutzer password=$passwort";
	
	$db = pg_connect ($conn);

	//transaction beginnen
	pg_query("BEGIN TRANSACTION");

	$firmenname = $_POST['firmenname'];
	$vorname = $_POST['vorname'];
	$nachname = $_POST['nachname'];
   
	$query = "INSERT INTO go_name(firmenname, vorname, nachname) values('$firmenname', '$vorname', '$nachname')";

	$resultat = pg_query($query);
	if($resultat == false) {
		 //pg_query("ROLLBACK");
		 $db_ok = "KO";
		 print "error1";
	} else {
		$query = "SELECT currval('go_name_id_seq'::text) as key";
		$resultat = pg_query($query);

		//fehlerbehandlung
		if( $resultat == false) { 
			print "fehler";
			$db_ok = "KO";
		} else {
			//ermittlung der go_name_id
			$serial_prim_key = pg_fetch_array($resultat, 0);
			$go_name_id = $serial_prim_key[key];
		}
		
		//das land erfassen
		if($_POST['land'] != "") { 
			$land_resultat = land_erfassen($_POST['land']);
			if($land_resultat == "KO") {
				$db_ok = "KO";
				$land_resultat = "";
			}
		} else {
			$land_resultat = "";
		}
			
		//den ort erfassen
		if($_POST['stadt'] != "" || $_POST['plz'] != "") {
			$stadt = $_POST['stadt'];
			$plz = $_POST['plz'];
			$ort_resultat = ort_erfassen($stadt, $plz, $land_resultat);
			if($ort_resultat == "KO") {
				$db_ok = "KO";
				$ort_resultat = "";
			}
		} else {
			$ort_resultat = "";
		}
			
		//die adresse erfassen
		if($_POST['strasse'] != "" || $_POST['hausnr'] != "") {
			$strasse = $_POST['strasse'];
			$hausnr = $_POST['hausnr'];
			$adresse_resultat = adresse_erfassen($go_name_id, $strasse, $hausnr, $ort_resultat);
			if($adresse_resultat == "KO") {
				$db_ok = "KO";
				print "fehler2";
			}
		}
			
		
	}
	
	if($db_ok == "KO") {
		pg_query("ROLLBACK");
		print "error";
	} else {
		pg_query("COMMIT");
		print "OK";
	}
}



function land_erfassen($land) {
	$query = "INSERT INTO land VALUES('$land')";
	$resultat = pg_query($query);
	if($resultat == false) {
		return("KO");
	} else {
		$query = "SELECT currval('land_id_seq'::text) as key";
		$resultat = pg_query($query);

		//fehlerbehandlung
		if( $resultat == false) { 
			return("KO");
		} else {
			//ermittlung des primaeren schluessels
			$serial_prim_key = pg_fetch_array($resultat, 0);
			$serial_prim_key = $serial_prim_key[key];
			return($serial_prim_key);
		}
	}
	
}

function ort_erfassen($stadt, $plz, $land_id) {
	if($land_id == "") {
		$query = "INSERT INTO ort(plz, stadt) VALUES('$stadt', '$plz')";
	} else {
		$query = "INSERT INTO ort(plz, stadt, land) VALUES('$stadt', '$plz', '$land_id')";
	}
	$resultat = pg_query($query);
	if($resultat == false) {
		return("KO");
	} else {
		$query = "SELECT currval('ort_id_seq'::text) as key";
		$resultat = pg_query($query);

		//fehlerbehandlung
		if( $resultat == false) { 
			return("KO");
		} else {
			//ermittlung des primaeren schluessels
			$serial_prim_key = pg_fetch_array($resultat, 0);
			$serial_prim_key = $serial_prim_key[key];
			return($serial_prim_key);
		}
	}
}

function adresse_erfassen($go_name_id, $strasse, $hausnr, $ort_id) {
	if( $ort_id == "" ) {
		$query = "INSERT INTO adresse(go_name_id, strasse, hausnr) " .
		"VALUES($go_name_id, '$strasse', $hausnr)";
	} else {	
		$query = "INSERT INTO adresse(go_name_id, strasse, hausnr, ort_id) " .
		"VALUES($go_name_id, '$strasse', $hausnr, $ort_id)";
	}
	print $query;
	$resultat = pg_query($query);
	if($resultat == false) {
		return "KO";
	} else {
		$query = "SELECT currval('adresse_id_seq'::text) as key";
		$resultat = pg_query($query);

		//fehlerbehandlung
		if( $resultat == false) { 
			return("KO");
		} else {
			//ermittlung des primaeren schluessels
			$serial_prim_key = pg_fetch_array($resultat, 0);
			$serial_prim_key = $serial_prim_key[key];
			return($serial_prim_key);
		}
	}
}


?>

<html>
<body>
Kunde erfolgreich angelegt<br>
Danke
</body>
</html>
