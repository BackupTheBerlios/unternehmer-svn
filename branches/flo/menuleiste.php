<html>
<body>
<table border="0">

<!-- Hier ist der Hauptmenupunkt Stammdaten definiert -->
<tr><td align="left"><img src="bilder/stammdaten.png">&nbsp;<a href="menuleiste.php?menu_stamm=1">Stammdaten</a><td></tr>

<!-- Hier ist das untermenu fuer Stammdaten definiert -->
<?php if( isset($_GET['menu_stamm']) ) { ?>
<tr><td align="left"><img src="bilder/menu_unterpunkt.png">&nbsp;<a href="stammdaten/kunde_erfassen.php" target="hauptfenster">Kunde erfassen</a></td><tr>
<tr><td align="left"><img src="bilder/menu_unterpunkt.png">&nbsp;Ware erfassen</td><tr>
<?php } ?>

<!-- Hier ist der Hauptmenupunkt Verkauf definiert -->
<tr><td align="left"><img src="bilder/menu_verkauf.png">&nbsp;<a href="menuleiste.php?menu_verkauf=1">Verkauf</a><td></tr>

<!-- Hier ist das untermenu fuer Verkauf definiert
<?php if( isset($_GET['menu_verkauf']) ) { ?>
<tr><td align="left"><img src="bilder/menu_unterpunkt.png">&nbsp;<a href="verkauf/rechnung_erfassen.php" target="hauptfenster">Rechnung erfassen</a></td><tr>
<?php } ?>




</table>
</body>
</html>
