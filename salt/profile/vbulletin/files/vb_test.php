<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta content="text/html; charset=windows-1252" http-equiv="Content-Type" />
	<meta http-equiv="MSThemeCompatible" content="yes" />
	<title>vBulletin Test Script</title>
	<link rel="stylesheet" href="https://images.vbulletin.com/testscript/vb_test.css" />
</head>
<body>
	<table cellpadding="4" cellspacing="0" border="0" width="100%" class="navbody">
		<tr valign="bottom">
			<td><img src="https://www.vbulletin.com/forum/core/cpstyles/vBulletin_5_Default/cp_logo.png" width="155" height="45" alt="cplogo" title="vBulletin &copy;2000-<?php echo date('Y'); ?> MH Sub I, LLC dba vBulletin." border="0" /></td>
			<td><b>vBulletin Server Test Script</b><br /><a href="https://www.vbulletin.com">vBulletin Website</a><br />&nbsp;</td>
		</tr>
	</table>
	<br />
	<table cellpadding="1" cellspacing="0" border="0" align="center" width="50%" class="tborder"><tr><td>
<table cellpadding="4" cellspacing="0" border="0" width="100%">
<?php
error_reporting(E_ALL);

function iif($condition, $truevalue, $falsevalue = '')
{
	if ($condition)
	{
		return $truevalue;
	}
	else
	{
		return $falsevalue;
	}
}

class DB
{
	public static function fetch_db($host, $user, $password, $dbname)
	{
		global $db_connection_error;
		$obj = @new mysqli($host, $user, $password, $dbname);

		//note that according to the documentation we should do this between
		//the init call and real_connect (the constructor effectively does both
		//of these at once).  However there is a bug in PHP where this doesn't work
		//and real_connect will reset the option to the ini value.
		//
		//We can't set the ini value because PHP doesn't allow this value to be
		//set in a script.  So this is the best we can do. Note that on all supported
		//versions of PHP this ini value is set securely by default.
		$obj->options(MYSQLI_OPT_LOCAL_INFILE, false);

		if (mysqli_connect_errno())
		{
			$db_connection_error = mysqli_connect_error();
			return false;
		}
		return $obj;
	}
}

function test_ini_set($setting, $value)
{
	$result = @ini_set($setting, $value);
	if ($result === false OR $result === null)
	{
		return false;
	}
	else
	{
		return $result;
	}
}

//initalise variables dont want any XSS in our test script :)
$versions = array();

$required_versions = array(
	'PHP' => '7.2.0',
	'MySQL' => '5.5.8'
);

if (!empty($_GET['help']))
{
	$tested = false;

	$type = strtolower($_GET['help']);
	$help = array();
	$help['php'] = 'Your PHP Version is too low to support vBulletin 5, you must at least upgrade to ' . $required_versions['PHP'];
	$help['mysql'] = 'Your MySQL version is too low to support vBulletin 5, you must at least upgrade to ' . $required_versions['MySQL'];
	$help['pcre'] = 'vBulletin requires PCRE to be enabled in PHP, ask your host to enable this in php.ini';
	$help['open_basedir'] = 'You may experience problems with uploading files to vBulletin';
	$help['curl'] = 'The cUrl extension is needed for many features that gather data from the internet';
	$help['json'] = 'The JSON extension is required to support vBulletin 5';
	$help['gzip'] = 'vBulletin uses GZIP to compress pages, though this is not essential for operation';
	$help['mysql_perms'] = 'vBulletin requires that the mysql username has create, select, update, insert, ' .
		'delete, alter and drop privledges, contact your host and ask them to adjust these privledges.';
	$help['xml'] = 'XML is required as a major component of vBulletin for data storage of languages, settings and templates.';
	$help['gd'] = 'GD functions are used to produce images, this includes features such as thumbnails and image verification on registration';
	$help['iconv'] = 'Iconv is used to handle different character encodings.  Either the Multibyte String ' .
		'or iconv modules are required to properly handle character encodings. Multibyte String is preferred.';
	$help['mbstring'] = 'Multibyte String is used to handle different character encodings.  Either the Multibyte String ' .
		'or iconv modules are required to properly handle character encodings. Multibyte String is preferred.';
	$help['pcre.backtrack_limit'] = 'PHP 5.2.0 and above imposes a limit on PCRE code that we are unable to work-around on this server. ' .
		'Ask your host to add the following to php.ini:<br /><code>pcre.backtrack_limit = -1</code>';
	$help['pcre.utf8'] = 'PCRE with utf8 support is recommended';
	$help['mysql.utf8mb4'] = 'The utf8mb4 character set allows extended (up to four byte) utf8 characters. Requires MySql 5.5.3 or greater.';

	echo '<tr><td class="tcat" colspan="3" align="center"><b>' . htmlspecialchars($type) . ' Help</b></td></tr>';
	echo '<tr valign="top" align="left" class="alt1"><td>' . $help["$type"] . '</td></tr>';
}
elseif (empty($_POST['server']) or empty($_POST['user']) or empty($_POST['db']))
{
	$tested = false;

	echo '<tr><td class="tcat" colspan="3" align="center"><b>MySQL Information</b></td></tr>';
	echo '<form method="post">';
	echo '<tr valign="top" align="center" class="alt1">';
	echo '	<td align="left">MySQL Server</td>';
	echo '	<td align="left"><input type="text" name="server" value="localhost" /></td>';
	echo '</tr>';
	echo '<tr valign="top" align="center" class="alt2">';
	echo '	<td align="left">MySQL Database</td>';
	echo '	<td align="left"><input type="text" name="db" /></td>';
	echo '</tr>';
	echo '<tr valign="top" align="center" class="alt1">';
	echo '	<td align="left">MySQL Username</td>';
	echo '	<td align="left"><input type="text" name="user" /></td>';
	echo '</tr>';
	echo '<tr valign="top" align="center" class="alt2">';
	echo '	<td align="left">MySQL Password</td>';
	echo '	<td align="left"><input type="password" name="pass" autocomplete="off" /></td>';
	echo '</tr>';
	echo '<tr valign="top align="center">';
	echo '<td class="submitrow" colspan="2" align="center"><input type="submit" value="Run Test" accesskey="s" /></td>';
	echo '</tr>';
	echo '</form>';
}
else
{
	$tested = true;

	/**
	 *	Define the tests
	 */

	// modules
	// modulename => 'represtative function' or array('function1', 'function2').  There should also be a "help"
	// entry for every module
	$required_modules = array(
		'PCRE' => 'preg_replace',
		'XML' => 'xml_set_element_handler',
		'curl' => 'curl_init',
		'json' => 'json_encode'
	);

	$recommended_modules = array(
		'GZIP' => array('crc32', 'gzcompress'),
		'GD' => 'imagecreatetruecolor',
		'iconv' => 'iconv',
		'mbstring' => 'mb_convert_encoding'
	);

	//'feature' => test query. Will check if query produces an error, but not
	//what it returns
	$mysql_perms = array(
		'create' => 'CREATE TABLE vb3_test (test int(10) unsigned NOT NULL)',
		'alter' => 'ALTER TABLE vb3_test CHANGE test test VARCHAR(254) NOT NULL',
		'insert' => 'INSERT INTO vb3_test (test) VALUES (\'abcd\')',
		'update' => 'UPDATE vb3_test SET test=123 WHERE test=\'abcd\'',
		'select' => 'SELECT * FROM vb3_test WHERE test=123',
		'delete' => 'DELETE FROM vb3_test WHERE test=123',
		'drop' => 'DROP TABLE vb3_test'
	);

	//either a query string (check for error) or an anonymous function that
	//takes the mysqli object as a parameter.  Always fails when the db connection
	//does not exist (function will not be called).
	$mysql_recommended = array(
		'mysql.utf8mb4' => function($db)
		{
				$result = $db->query("SHOW CHARACTER SET LIKE 'utf8mb4'");
				return ($result->num_rows > 0);
		},
	);

	$required_tests = array();

	$recommended_tests = array(
		'open_basedir' => function()
		{
			return (get_cfg_var('open_basedir') == '');
		},
		'pcre.backtrack_limit' => function()
		{
			return (!test_ini_set('pcre.backtrack_limit', -1) === false);
		},
		'pcre.utf8support' => function()
		{
			return (@preg_match('/\p{L}/u', 'a') == 1);
		},
	);


	/**
	 *	Run the tests
	 */

	class vB_TestObserver
	{
		private $results = array();
		private $failures = 0;

		public function getFailureCount()
		{
			return $this->failures;
		}

		public function getResults()
		{
			return $this->results;
		}

		public function logTest($name, $result)
		{
			$this->results[$name] = (bool) $result;
			if(!$result)
			{
				$this->failures++;
			}
		}
	}

	$requiredResults = new vB_TestObserver();
	$recommendedResults = new vB_TestObserver();
	$mysqlResults = new vB_TestObserver();

	//PHP
	$versions['PHP'] = phpversion();

	$db = DB::fetch_db($_POST['server'], $_POST['user'], $_POST['pass'], $_POST['db']);
	//MySQL
	if(!$db)
	{
		//if we don't this this, then then it will be set by the version test.
		$requiredResults->logTest('MySQL', false);
	}
	else
	{
		$vquery = $db->query('SELECT VERSION() AS version');
		$mysql = $vquery->fetch_array();
		$versions['MySQL'] = $mysql['version'];
	}

	//check mysql permissions
	foreach($mysql_perms AS $feature => $query)
	{
		$mysqlResults->logTest($feature, ($db AND $db->query($query)));
	}

	foreach($mysql_recommended AS $feature => $query)
	{
		if(!$db)
		{
			$result = false;
		}
		else if (is_callable($query))
		{
			$result = $query($db);
		}
		else
		{
			$result = (bool) $db->query($query);
		}

		$recommendedResults->logTest($feature, $result);
	}


	if ($db)
	{
		$db->close();
	}

	//check versions -- if we don't set the version of something, we skip the check
	//(presumably this means we couldn't look it up and there is another error that covers
	//that such as the database.
	foreach($versions as $feature => $version)
	{
		$requiredResults->logTest($feature, !version_compare($version, $required_versions[$feature], '<'));
	}

	function check_modules($modules, $observer)
	{
		//check modules.
		foreach ($modules AS $module => $function)
		{
			$test_function = $function;
			if (!is_array($function))
			{
				$test_function = array($test_function);
			}

			$pass = true;
			foreach($test_function AS $check)
			{
				if (!function_exists($check))
				{
					$pass = false;
				}
			}

			$observer->logTest($module, $pass);
		}
	}

	check_modules($required_modules, $requiredResults);
	check_modules($recommended_modules, $recommendedResults);

	foreach($required_tests AS $name => $function)
	{
		$requiredResults->logTest($name, $function());
	}

	foreach($recommended_tests AS $name => $function)
	{
		$recommendedResults->logTest($name, $function());
	}

	//translate to the previos vars for display -- should eventually rewrite that
	//part as well.
	$e_test = $requiredResults->getResults();
	$mysql = $mysqlResults->getResults();
	$test = $recommendedResults->getResults();

	//a bit of a hack to handle previous behavior.  This doesn't
	//fit into our nice little formal setup.
	//not sure why we set the version only if GD passes.
	if ($test['GD'])
	{
		$versions['GD'] = '2.x';
	}

	$e_error = $requiredResults->getFailureCount() + $mysqlResults->getFailureCount();
	$error = $recommendedResults->getFailureCount();

	echo '<tr><td class="tcat" colspan="3" align="center"><b>Essential vBulletin Requirements</b></td></tr>';
	foreach ($e_test AS $type => $result) {
		echo '<tr valign="top" align="center" class="alt1">';
		echo '	<td align="left">' . $type . '</td>';
		echo '	<td align="left">' . (!isset($versions["$type"]) ? '' : $versions["$type"]) . '</td>';
		echo '	<td align="left">' . iif($result, 'Pass', '<b><a href="vb_test.php?help=' . $type . '">Fail</a></b>') . '</td>';
		echo '</tr>';
	}
	if ($db_connection_error)
	{
		echo '<tr valign="top" align="center" class="alt1">';
		echo '	<td align="left" colspan="3"><strong>Database Connection Error</strong>:&nbsp;&nbsp;' . htmlspecialchars($db_connection_error) . '</td>';
		echo '</tr>';
	}
	echo '<tr><td class="tcat" colspan="3" align="center"><b>MySQL Permission Requirements</b></td></tr>';
	foreach ($mysql AS $type => $result) {
		echo '<tr valign="top" align="center" class="alt2">';
		echo '	<td align="left" colspan="2">' . $type . '</td>';
		echo '	<td align="left">' . iif($result, 'Pass', '<b><a href="vb_test.php?help=mysql_perms">Fail</a></b>') . '</td>';
		echo '</tr>';
	}

	echo '<tr><td class="tcat" colspan="3" align="center"><b>Recommended Settings</b> (<em>Optional</em>)</td></tr>';
	foreach ($test AS $type => $result) {
		echo '<tr valign="top" align="center" class="alt1">';
		echo '	<td align="left">' . $type . '</td>';
		echo '	<td align="left">' . (!isset($versions["$type"]) ? '' : $versions["$type"]) . '</td>';
		echo '	<td align="left">' . iif($result, 'Pass', '<b><a href="vb_test.php?help=' . $type . '">Fail</a></b>') . '</td>';
		echo '</tr>';
	}

	echo '<tr><td class="tcat" colspan="2" align="center">Overall Result:</td><td class="tcat"><b>' . iif($e_error, 'Fail', 'Pass') . '</b></td></tr>';

}

?>
</table>
</td></tr></table>
<?php
	if ($tested AND is_array($test) AND is_array($e_test))
	{
		if ($e_error == 0 AND $error == 0)
		{
			echo '<p style="text-align: center">vBulletin 5 should run on your system without any errors</p>';
		}
		elseif ($e_error == 0)
		{
			echo '<p style="text-align: center">vBulletin 5 should run on your system though there may be reduced functionality, click the link(s) above for more information</p>';
		}
		else
		{
			echo '<p style="text-align: center">vBulletin5  will not run on your system, please click the link(s) above for more information.</p>';
		}
	}
/*======================================================================*\
|| ####################################################################
|| # CVS: $RCSfile$ - $Revision: 105451 $
|| ####################################################################
\*======================================================================*/
?>
</body>
</html>
