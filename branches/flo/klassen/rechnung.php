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
	var $anzahlverkaufsobjekte;
	var $bezeichnung;
	var $art_nr;
	var $gesamtpreis;
	var $anzahl;

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
	//holeIdsVerkaufsobjekte
	//holeGesamtpreisBezeichnungArtnrAnzahl
	//holeGesamtpreis
	//holeBezeichnung
	//holeArtnr
	//holeAnzahl

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
			return -2;
	
		$this->rechnungsnummer = $rechnungsnr;

		//rechnungsnr existiert
		$this->holeFirmennameVornameNachname();
		
		$this->holeIdsVerkaufsobjekte();
		$anzahl = $this->holeGesamtpreisBezeichnungArtnrAnzahl();
		
		return $anzahl;
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

	function holeFirmennameVornameNachname() {
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
		$this->firmenname = $resultat1[0];
		$this->vorname = $resultat1[1];
		$this->nachname = $resultat1[2];

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
	
	function holeGesamtpreisBezeichnungArtnrAnzahl() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;
		if( ($ids = $this->holeIdsVerkaufsobjekte()) < 0)
			return -4;

		for($i = 0; $i < count($ids);$i++) {
			$query = "SELECT verkaufspreis*anzahl,bezeichnung, art_nr, anzahl ".
				"FROM verkaufsobjekt LEFT OUTER JOIN rechnung_vo ".
				"ON(rechnung_vo.vo_id=verkaufsobjekt.id) LEFT OUTER JOIN ".
				"preise ON(preise.id=rechnung_vo.vo_preise_id) ".
				"WHERE rechnung_vo.rechnung_id='{$this->rechnungsnummer}'";

		
			$resultat = pg_query($query);
			if($resultat == false)
				return -5;
			
			$resultat1 = pg_fetch_array($resultat);
			$this->gesamtpreis[$i] = $resultat1[0];
			$this->bezeichnung[$i] = $resultat1[1];
			$this->art_nr[$i] = $resultat1[2];
			$this->anzahl[$i] = $resultat1[3];
		}
		
		$anz = count($ids);
		$this->anzahlverkaufsobjekte = $anz;
		return $anz;
	}
		
	
	function holeIdsVerkaufsobjekte() {
		if($this->ueberpruefeDbVerbindungsdaten() < 0)
			return -1;
		if($this->existiertRechnungsnr($this->rechnungsnummer) < 0)
			return -2;
		if( ($db = $this->verbindeZuDb()) < 0)
			return -3;

		$query = "SELECT id  FROM rechnung_vo WHERE rechnung_id='{$this->rechnungsnummer}'";
		$resultat = pg_query($query);
		if($resultat == false) 
			return -4;
		
		for($i = 0; $i < pg_num_rows($resultat); $i++) {
			$tmp_id = pg_fetch_array($resultat);
			$ids[$i] = $tmp_id;
		}
		return $ids;
	}

	function holeGesamtpreis($pos) {
		return $this->gesamtpreis[$pos];
	}

	function holeBezeichnung($pos) {
		return $this->bezeichnung[$pos];
	}

	function holeArtnr($pos) {
		return $this->art_nr[$pos];
	}

	function holeAnzahl($pos) {
		return $this->anzahl[$pos];
	}
		

}		

?>
