class rechnung
{
	public var $rechnungsdatum;
	public var $faelligkeitsdatum;
	public var $rechnungsnr;
	
	public function ueberpruefe_db_verbindungsdaten() {
		if(!isset($dbloginname)) 
			return -1;
		if(!isset($dbname))
			return -1;
		if(!isset($dbport))
			return -1;
		if(!isset($dbrechner))
			return -1;
		if(!isset($dbpasswort)
			return -1;

		return 0;
	}

		
	public function hole_rechnungsdaten($rechnungsnr) {
		if(ueberpruefe_db_verbindungsdaten() < 0)
			return -1;


