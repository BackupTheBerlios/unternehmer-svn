<html>
<body>
<table border="0">

<!-- Hier ist der Hauptmenupunkt Stammdaten definiert -->
<tr><td align="left"><img src="../bilder/stammdaten.png">&nbsp;<a href="menuleiste.php?menu_stamm=1">Stammdaten</a><td></tr>

<!-- Hier ist das untermenu fuer Stammdaten definiert -->
<?php if( isset($_GET['menu_stamm']) ) { ?>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../stammdaten/kunde_erfassen-1.php" target="hauptfenster">Kunde erfassen</a></td></tr>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../stammdaten/ware_erfassen-1.php" target="hauptfenster">Ware erfassen</a></td></tr>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../stammdaten/angestellte_erfassen-1.php" target="hauptfenster">Angestellte(n) erfassen</a></td></tr>

<tr><td align="left">&nbsp;&nbsp;<img src="../bilder/menu_unterpunkt.png">Berichte</td></tr>
<tr><td align="left">&nbsp;&nbsp;<img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../stammdaten/bericht_kunden-1.php" target="hauptfenster">Kunden</a></td></tr>
<tr><td align="left">&nbsp;&nbsp;<img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../stammdaten/bericht_waren-1.php" target="hauptfenster">Waren</a></td></tr>
<tr><td align="left">&nbsp;&nbsp;<img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../stammdaten/bericht_angestellte-1.php" target="hauptfenster">Angestellte</a></td></tr>




<?php } ?>

<!-- Hier ist der Hauptmenupunkt Verkauf definiert -->
<tr><td align="left"><img src="../bilder/menu_verkauf.png">&nbsp;<a href="menuleiste.php?menu_verkauf=1">Verkauf</a></td></tr>

<!-- Hier ist das untermenu fuer Verkauf definiert -->
<?php if( isset($_GET['menu_verkauf']) ) { ?>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../verkauf/rechnung_erfassen/rechnung_erfassen-1.php" target="hauptfenster">Rechnung erfassen</a></td></tr>

<tr><td align="left">&nbsp;&nbsp;<img src="../bilder/menu_unterpunkt.png">Berichte</td></tr>
<tr><td align="left">&nbsp;&nbsp;<img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../verkauf/bericht_rechnungen/bericht_rechnungen-1.php" target="hauptfenster">Rechnungen</a></td></tr>


<?php } ?>

<!-- Hier ist der Hauptmenupunkt Finanzbuchhaltung definiert -->
<tr><td align="left"><img src="../bilder/menu_finanzbuchhaltung.png">&nbsp;<a href="menuleiste.php?menu_finanzbuchhaltung=1">Finanzbuchhaltung</a></td></tr>

<!-- Hier ist das untermenu fuer Finanzbuchhaltung definiert -->
<?php if( isset($_GET['menu_finanzbuchhaltung']) ) { ?>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../finanzbuchhaltung/debitorenbuchung/debitorenbuchung-1.php" target="hauptfenster">Debitorenbuchung</a></td></tr>

<?php } ?>


<!-- Hier ist das Einstellungen-menu definiert -->
<tr><td align="left"><img src="../bilder/menu_einstellungen.png">&nbsp;<a href="menuleiste.php?menu_einstellungen=1">Einstellungen</a></td></tr>

<!-- Hier ist das untermenu fuer Einstellungen definiert -->
<?php if( isset($_GET['menu_einstellungen']) ) { ?>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../verwaltung/einstellungen.php" target="hauptfenster">Prog. Einstellungen</a></td></tr>

<?php } ?>

<!-- Hier ist das Hilfemenupunkt definiert -->
<tr><td align="left"><img src="../bilder/menu_hilfe.png">&nbsp;<a href="menuleiste.php?menu_hilfe=1">Hilfe</a></td></tr>

<!-- Hier ist das untermenu fuer Hilfe definiert -->
<?php if( isset($_GET['menu_hilfe']) ) { ?>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../hilfe/kunde_erfassen-1.php" target="hauptfenster">Kunde erfassen</a></td></tr>
<tr><td align="left"><img src="../bilder/menu_unterpunkt.png">&nbsp;<a href="../hilfe/ware_erfassen-1.php" target="hauptfenster">Ware erfassen</a></td></tr>



<?php } ?>

</table>
</body>
</html>
