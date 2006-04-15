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

	function nimm_dbloginname($dbloginname) {
		$this->dbloginname = $dbloginname;
	}

	function nimm_dbname($dbname) {
		$this->dbname = $dbname;
	}

	function nimm_dbport($dbport) {
		$this->dbport = $dbport;
	}

	function nimm_dbrechner($dbrechner) {
		$this->dbrechner = $dbrechner;
	}
	
	function nimm_alle_dbdaten($dbloginname, $dbname, $dbport, $dbrechner, $dbpasswort) {
		$this->dbloginname = $dbloginname;
		$this->dbname = $dbname;
		$this->dbport = $dbport;
		$this->dbrechner = $dbrechner;
		$this->dbpasswort = $dbpasswort;
	}
	
	function hole_dbname() {
		if(!isset($this->dbname)) 
			return -1;
		return $this->dbname;
	}

	function hole_dbloginname() {
		if(!isset($this->dbloginname))
			return -1;
		return $this->dbloginname;
	}
	
	function hole_dbport() {
		if(!isset($this->dbport))
			return -1;
		return $this->dbport;
	}

	function hole_dbrechner() {
		if(!isset($this->dbrechner))
			return -1;
		return $this->dbrechner;
	}

	function hole_dbpasswort() {
		if(!isset($this->dbpasswort))
			return -1;
		return $this->dbpasswort;
	}

	function hole_alle_dbdaten(&$dbloginname, &$dbpasswort, &$dbport, &$dbrechner, &$dbname) {
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
		$dbport = $this->dbrechner;
		$dbname = $this->dbname;
		$dbrechner = $this->dbrechner;

		return 0;
	}

	function nimm_rechnungsnr($rechnungsnr) {
		if($this->ueberpruefe_db_verbindungsdaten() < 0)
			return -1;
		if($this->existiert_rechnungsnr($rechnungsnr) < 0)
			return -1;
		
		//rechnungsnr existiert
		$this->rechnungsnummer = $rechnungsnr;
	}
	
	function existiert_rechnungsnr($rechnungsnr) {
		if($this->ueberpruefe_db_verbindungsdaten() < 0)
			return -1;
		
		if( ($dbc = $this->verbinde_zu_db()) < 0)
			return -2;
		
		if(pg_query("SELECT rechnungsnr FROM rechnungen WHERE rechnungsnr='this->rechnungsnummer'") == false)
			return -3;

		return 0;
	}

	function verbinde_zu_db() {
		if($this->ueberpruefe_db_verbindungsdaten() < 0)
			return -1;
		
		$conn = "host=this->dbrechner port=this->dbport dbname=this->dbname ".
			"user=this->dbloginname password=this->passwort";
	
		$dbc = pg_connect($conn);

		return $dbc;
	}

	
		
	
	function hole_rechnungsnr() {
		if(!isset($this->rechnungsnummer))
			return -1;

		return $this->rechnungsnummer;
	}

	function ueberpruefe_db_verbindungsdaten() {
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
	
		
}		

?>
