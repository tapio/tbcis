TBCIS CGI WebUI
===============

Introduction
------------
This is a CGI script that generates a simple real-time phase-by-phase view of all the available tasks and runs.


Installation
------------
Put the ci.cgi wrapper script to a web-accessible, cgi-enabled place and change the variables in it to suite you. the actual WebUI script (tbcis_webui.sh) can be anywhere as the path is given in the wrapper.

Note: Your results directory should be web-accessible for the generated log and download links to work.


Security
--------
Currently it doesn't take any user input (e.g GET or POST queries) so it should be quite secure.
