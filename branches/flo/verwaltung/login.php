<html>
<body onLoad="fokus()">

<pre>

</pre>

<center>
<table class=login border=3 cellpadding=20>
  <tr>
    <td class=login align=center><a href="http://unternehmer.berlios.de" target=_top><img src="../bilder/unternehmer.png" border=0></a>
<h1 align=center>Version 0.1</h1>

<p>

<form method=post name=loginscreen action="checklogin.php">

      <table width=100%>
	<tr>
	  <td align=center>
	    <table>
	      <tr>
		<th align=right>Name</th>
		<td><input name="loginname" size=20  maxlength=20 tabindex="1"></td>
	      </tr> 
	      <tr>
		<th align=right>Password</th>
		<td><input type=password name="passwort" size=20 maxlength=20 tabindex="2"></td>
	      </tr>
	      <tr>
	      	<th align="right">Mandant</th>
		<td><input type="text" name="dbname" size="20" tabindex="3"></td>
	      </tr>
	      <tr>
	        <th align="right">Datenbankrechner</th>
		<td><input type="text" name="dbrechner" size="20" tabindex="3" value="localhost"></td>
	      <tr>
	    </table>

	    <br>
	    <input type=submit name=action value="Anmelden",>

	  </td>
	</tr>
      </table>

</form>

    </td>
  </tr>
</table>
  
</body>
</html>

