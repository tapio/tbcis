#!/bin/bash

if [ ! "`which markdown`" ]; then
	echo "Couldn't find markdown"
	exit 1
fi

markdown ../Readme.markdown > Readme.html
markdown ../webui/php/Readme.markdown > Readme-WebUI-PHP.html
markdown ../webui/cgi/Readme.markdown > Readme-WebUI-CGI.html
