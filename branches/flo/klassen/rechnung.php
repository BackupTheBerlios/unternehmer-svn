<?php

class rechnung
{
	var $rechnungsdatum;
	var $faelligkeitsdatum;
	var $rechnungsnummer;
	var $dbloginname;
	var $dbname;
	var $dbport;
	var $dbrechner;
	var $dbpasswort;
	var $firmenname;
	var $vorname;
	var $nachname;
	var $anzahlverkaufsobjekte
	
	//methodenauflistung , leider kann man nicht ausserhalb
	//einer klasse die methoden definieren, so das etwas mehr uebersicht in den code 
	//gelangt
	//nimmDbLoginname
	//nimmDbName
	//nimmDbPort
	//nimmDbRechner
	//nimmDbPasswort
	//nimmAlleDbDaten
	//holeDbLoginname
	//holeDbName
	//holeDbPort
	//holeDbRechner
	//holeDbPasswort
	//holeAlleDbDaten
	//nimmRechnungsnr
	//existiertRechnungsnr
	//verbindeZuDb
	//holeRechnungsnr
	//ueberpruefeDbVerbindungsdaten
	//holeFirmenname
	//holeVorname
	//holeNachname
	//holeFirmennameVornameNachname
	//holeAnzahlVerkaufsobjekte
	//holeVerkaufsobjekt
	
	function nimmDbLoginname($dbloginname) {
		$this->dbLoginname = $dbloginname;
	}

	function nimmDbName($dbname) {
		$this->dbname = $dbname;
	}

	function nimmDbPort($dbport) {
		$this->dbport = $dbport;
	}

	function nimmDbRechner($dbrechner) {
		$this->dbrechner = $dbrechner;
	}

	function nimmDbPasswort($dbpasswort) {
		$this->dbpasswort = $dbpasswort;
	}
	
	function nimmAlleDbDaten($dbloginname, $dbname, $dbport, $dbrechner, $dbpasswort) {
		$this->dbloginname = $dbloginname;
		$this->dbname = $dbname;
		$this->dbport = $dbport;
		$this->dbrechner = $dbrechner;
		$this->dbpasswort = $dbpasswort;
	}
	
	function holeDbName() {
		if(!isset($this->dbname)) 
			return -1;
		return $this->dbname;
	}

	function holeDbLoginname() {
		if(!isset($this->dbloginname))
			return -1;
		return $this->dbloginname;
	}
	
	function holeDbPort() {
		if(!isset($this->dbport))
			return -1;
		return $this->dbport;
	}

	function holeDbRechner() {
		if(!isset($this->dbrechner))
			return -1;
		return $this->dbrechner;
	}

	function holeDbPasswort() {
		if(!isset($this->dbpasswort))
			return -1;
		return $this->dbpasswort;
	}

	function holeAlleDbDaten(&$dbloginname, &$dbpasswort, &$dbport, &$dbrechner, &$dbname) {
		if(!isset($this->dbloginname))
			return -1;
		if(!isset($this->dbpasswort))
			return -2;
		if(!isset($this->dbport))
			return -3;
		if(!isset($this->dbrechner))
			return -4;
		if(!isset($this->dbname))
			return -5;

		$dbloginname = $this->dbloginname;
		$dbpasswort = $this->dbpasswort;
		$dbrechner = $this->dbrechner;
		$dbname = $this->dbname;
		$dbport = $this->dbport;

		return 0;
	}

	function nimmRechnungsnr($rechnungsnr) {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($rechnungsnr) < 0)
			return -1;
		
		//rechnungsnr existiert
		$this->rechnungsnummer = $rechnungsnr;
	}
	
	function existiertRechnungsnr($rechnungsnr) {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		
		if( ($dbc = $this->verbindeZuDb()) < 0)
			return -2;
	
		if(!isset($rechnungsnr))
			return -3;

		$query = "SELECT id FROM rechnung WHERE id='$rechnungsnr'";
		
		$resultat = pg_query($query);
		if($resultat == false)
			return -3;
		if(pg_num_rows($resultat) <= 0)
			return -4;

		return 0;
	}

	function verbindeZuDb() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		
		$conn = "host={$this->dbrechner} port={$this->dbport} dbname={$this->dbname} ".
			"user={$this->dbloginname} password={$this->dbpasswort}";

		$dbc = pg_connect($conn);

		return $dbc;
	}

	
		
	
	function holeRechnungsnr() {
		if(!isset($this->rechnungsnummer))
			return -1;

		return $this->rechnungsnummer;
	}

	function ueberpruefeDbVerbindungsdaten() {
		if(!isset($this->dbloginname)) 
			return -1;
		if(!isset($this->dbname))
			return -1;
		if(!isset($this->dbport))
			return -1;
		if(!isset($this->dbrechner))
			return -1;
		if(!isset($this->dbpasswort))
			return -1;

		return 0;
	}
	
	function holeFirmenname() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		
		$resultat = pg_query("SELECT firmenname FROM  go_name g ,rechnung r WHERE ".
					"r.id=$this->rechnungsnummer AND g.id=r.kunde_id");
		if($resultat == false)
			return -4;

		$resultat1 = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		$this->firmenname = $resultat1[0];
		
		return $this->firmenname;
	}
	
	function holeVorname() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		
		$resultat = pg_query("SELECT vorname FROM  go_name g ,rechnung r WHERE ".
					"r.id=$this->rechnungsnummer AND g.id=r.kunde_id");
		if($resultat == false)
			return -4;

		$resultat1 = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		$this->vorname = $resultat1[0];
		
		return $this->vorname;
	}
	
	function holeNachname() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		
		$resultat = pg_query("SELECT nachname FROM  go_name g ,rechnung r WHERE ".
					"r.id=$this->rechnungsnummer AND g.id=r.kunde_id");
		if($resultat == false)
			return -4;

		$resultat1 = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		$this->nachname = $resultat1[0];
		
		return $this->nachname;
	}

	function holeFirmennameVornameNachname(&$firmenname, &$vorname, &$nachname) {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		
		$resultat = pg_query("SELECT firmenname, vorname, nachname FROM  go_name g ,rechnung r WHERE ".
					"r.id=$this->rechnungsnummer AND g.id=r.kunde_id");
		if($resultat == false)
			return -4;

		$resultat1 = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		$firmenname = $this->firmenname = $resultat1[0];
		$vorname = $this->vorname = $resultat1[1];
		$nachname = $this->nachname = $resultat1[2];
		
		return 0;
	}

	function holeAnzahlVerkaufsobjekte() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		
		$resultat = pg_query("SELECT count(*) FROM rechnung_vo WHERE ".
					"rechnung_id=$this->rechnungsnummer");

		if($resultat == false)
			return -4;
		$resultat1 = pg_fetch_array($resultat, NULL, PGSQL_NUM);
		$this->anzahlverkaufsobjekte = $resultat1[0];

		return $this->anzahlverkaufsobjekte;
	}
	
	function holeVerkaufsobjekt($nr) {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if(!isset($this->anzahlverkaufsobjekte))
			return -3;
		if($nr > $this->anzahlverkaufsobjekte)
			return -4;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		

}		

?>
