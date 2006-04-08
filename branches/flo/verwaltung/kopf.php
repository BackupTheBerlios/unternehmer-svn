<?php
session_start();
?>

<html>
<body background="../bilder/bg_titel.gif">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td align="right" style="vertical-align:super; color:white; font-family:verdana,arial,sans-serif; font-size:18px;" nowrap>Benutzer:&nbsp;<?php echo $_SESSION['benutzer']; ?></td>

	<td>&nbsp;</td>

	<td style="vertical-align:super; color:white; font-family:verdana,arial,sans-serif; font-size:18px;" nowrap>Datenbankname:&nbsp;<?php echo $_SESSION['datenbankname']; ?></td>
	
	<td style="vertical-align:super; color:white; font-family:verdana,arial,sans-serif; font-size:18px;" nowrap>Uhrzeit:</td>
</tr>


</body>
</html>
