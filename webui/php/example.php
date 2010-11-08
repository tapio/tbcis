<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Tiny Bash Continuous Integration System Example</title>
	<link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<div id="header">
		<h1>Tiny Bash Continuous Integration System</h1>
	</div>
	<div id="content">
		<?php
			include("config.php");
			include("tbcis.php");
			tbcis_show();
		?>
	</div>
	<div id="footer">
		<small>Powered by TBCIS</small>
	</div>
</body>
</html>
