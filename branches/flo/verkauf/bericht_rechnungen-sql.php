<?php
session_start();
//db abfrage
$conn = "host=localhost port=5432 dbname={$_SESSION['datenbankname']} user={$_SESSION['benutzer']} password={$_SESSION['passwort']}";
	
$db = pg_connect($conn);

//hier die konten fuer drop-down-felder holen
$query = "SELECT kontennr, kontenbezeichnung FROM konten";

$resultat = pg_query($query);
if($resultat == false) {
	print "error3";
} else {
	$anz_reihen = pg_num_rows($resultat);
	for($i = 0;$i < $anz_reihen; $i++){
		$array = pg_fetch_array($resultat, NULL, PGSQL_ASSOC);					
		
		$konten[$i] = $array['kontennr'];
		$konten[$i] .= '---';
		$konten[$i] .= $array['kontenbezeichnung'];
		$html_konten .= "<option>$konten[$i]</option>";
	}
}

//hier firmenamen,vor-und nachname holen
$query = "SELECT firmenname, vorname, nachname, go_name.id FROM go_name WHERE rechnung.kunde_id = go_name.id AND rechnung.id = {$_GET['rechnungsnr']}";

$resultat = pg_query($query);

if($resultat == false) {
	print "fehler";
} else {
	$array = pg_fetch_array($resultat, NULL, PGSQL_NUM);
	$firmenname = $array[0];
	$vorname = $array[1];
	$nachname = $array[2];
	$html_kunde_id = "<input type='hidden' name='kunde_id' value='$array[3]'";
	$html_rechnung_id = "<input type='hidden' name='rechnung_id' value='{$_GET['rechnungsnr']}'>";

	//hole ids der rechnung_vo's um damit dann die einzelnen rechnung_bezahlt summen zu holen
	$query = "SELECT id, vo_id  FROM rechnung_vo WHERE rechnung_id='{$_GET['rechnungsnr']}'";
	$resultat = pg_query($query);

	if($resultat == false) {	
		print "fehler";
	} else {
		$anz_reihen = pg_num_rows($resultat);
		$html_anz_reihen = "<input type='hidden' name='anz_reihen' value='$anz_reihen'>";	
		
		//fuer jede id jetzt die summe der einzelen verkaufsobjekte holen
		for($i = 0; $i < pg_num_rows($resultat); $i++) {
			$rechnung_vo_id = pg_fetch_array($resultat, NULL, PGSQL_NUM);

			$query = "SELECT verkaufspreis*anzahl FROM rechnung_vo ".
				"LEFT OUTER JOIN preise ON(vo_preise_id=preise.id) ".
				"WHERE rechnung_vo.id='$rechnung_vo_id[0]'";
		
			$resultat1 = pg_query($query);
			if($resultat1 == false) {
				print "fehler";
			} else {
				$summe_vo = pg_fetch_array($resultat1,  NULL, PGSQL_NUM);
				
				//jetzt eventuell die summe holen, die schon fuer
				//die ware bezahlt wurde
				$query = "SELECT sum(summe) FROM rechnung_bezahlt ".
					"WHERE rechnung_vo_id='$rechnung_vo_id[0]'";

				$resultat2 = pg_query($query);
				if($resultat2 == false) {
					print "fehler";
				} else {
					$summe_bezahlt = pg_fetch_array($resultat2, NULL, PGSQL_NUM);
					
					//art_nr und bezeichnung holen
					$query = "SELECT art_nr,bezeichnung FROM verkaufsobjekt ".
						"WHERE verkaufsobjekt.id='$rechnung_vo_id[1]'";

					$resultat3 = pg_query($query);
					if($resultat3 == false) {
						print "fehler";
					} else {
						$art_bezeichnung = pg_fetch_array($resultat3, NULL, PGSQL_NUM);
						
						//jetzt die html input zusammenbauen
						$html_gesamtpreise[$i] = "<tr><td>$art_bezeichnung[0]</td>" .
							 "<td>$art_bezeichnung[1]</td>" .
							 "<td>$summe_vo[0]</td>" .
							 "<td>$summe_bezahlt[0]</td> ".
							 "<td><select name='erloeskonto_id_$i'> " .
							 "echo $html_konten </select></td>" .
							 "</tr><input type='hidden' " .
							 "name='re_vo_id_$i' value='$rechnung_vo_id[0]'";
					}
				}
			}
		}
	}
}



?>
<html>
<body>
<table width="100%" border="1">
<form method="post" action="debitorenbuchung-sql.php">

<?php 
echo $html_anz_reihen;
echo $html_kunde_id;
echo $html_rechnung_id;
?>
<tr>
	<td colspan="5"><center><h2>Bericht Rechnung</center></h2></td>
</tr>
<tr>
	<td align="right">Firmenname</td>
	<td colspan="4"><input type="text" name="firmenname" value="<?php echo $firmenname ?>"></td>
</tr>
<tr>
	<td align="right">Vorname</td>
	<td colspan="4"><input type="text" name="vorname" value=<?php echo $vorname ?> ></td>
</tr>
<tr>
	<td align="right">Nachname</td>
	<td colspan="4"><input type="text" name="nachname" value=<?php echo $nachname ?> ></td>
</tr>
<tr>
	<td colspan="5">&nbsp;</td>
</tr>
<tr>
	<td>Artikelnr</td>
	<td>Artikelbezeichnung</td>
	<td>Gesamtpreis</td>
	<td>Bezahlt</td>
	<td>Erl&ouml;skonto</td>
</tr>
<tr><td colspan="5"><hr></td>
</tr>

<?php
// dynamische vervollstaendigung der tabellen-spalten
for($i = 0; $i < count($html_gesamtpreise); $i++) {
	print $html_gesamtpreise[$i];
}
?>
<tr>
	<td colspan="5"><hr></td>
</tr>
<tr>
	<td colspan="5"><center><input type="submit" name="debitorenbuchung" value="Einzahlung buchen"></center></td>
</tr>
</form>
</table>
</body>
</html>


