<?php
/**
 * PHP bindings for displaying data from TBCIS,
 * Tiny Bash Continuous Integration System.
 */


function tbcis_iterate_results($dir, $func) {
	$entries = scandir($dir);
	foreach($entries as $entry) {
		if($entry == '.' || $entry == '..') {
			// Skip these
		} else if(is_dir($entry)) {
			// Found a result dir
			$func($entry, $dir.'/'.$entry);
		} // Ignore non-directories
	}
}


function tbcis_show() {
	echo "It works!";
}


function tbcis_print_run_row($dir_path, $id) {

}


?>
