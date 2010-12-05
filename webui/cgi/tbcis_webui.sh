#!/bin/bash

TBCIS_WEBUI_CACHE_FILE="`pwd`/.tbcis.cache.html"
TBCIS_WEBUI_CACHE_TIME=5

internal_error()
{
	echo Content-type: text/html
	echo ""
	echo $@
	exit 1
}

if [ ! "$TBCIS_WEBUI_ROOT" ]; then
	internal_error "Error: TBCIS_WEBUI_ROOT undefined"
elif [ ! "$TBCIS_TASKS_ROOT" ]; then
	internal_error "Error: TBCIS_TASKS_ROOT undefined"
elif [ ! "$TBCIS_RESULTS_ROOT" ]; then
	internal_error "Error: TBCIS_RESULTS_ROOT undefined"
fi

t=`date +%s%N`

# Content header
echo Content-type: text/html
echo ""

create_cell()
{
	status=`cat $1.status || echo N/A`
	if [ $status = "N/A" ]; then
		echo -n "<td class=\"na\">"
		echo -n "$status"
	else
		class=`echo "$status" | tr "[:upper:]" "[:lower:]"`
		echo -n "<td class=\"$class\">"
		echo -n "<a href=\"$TBCIS_RESULTS_ROOT/$task/$i/$1.log\">"
		echo -n "$status"
		echo -n "</a>"
	fi
	echo "</td>"
}

create_dl_cell()
{
	echo -n "<td>"
	local cnt=`ls out | wc -l`
	if [ "$cnt" -eq 0 ]; then
		echo -n "N/A"
	elif [ "$cnt" -eq 1 ]; then
		local f="`ls out`"
		echo -n "<a href=\"$TBCIS_RESULTS_ROOT/$task/$i/out/$f\">"
		echo -n "[DL]"
		echo -n "</a>"
	else
		echo -n "<a href=\"$TBCIS_RESULTS_ROOT/$task/$i/out\">"
		echo -n "[Browse]"
		echo -n "</a>"
	fi
	echo "</td>"
}

generate_page()
{
	# Output some HTML ot start with
	cat << EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="refresh" content="120" />
	<title>Tiny Bash Continuous Integration System WebUI</title>
	<!--<link href="style.css" rel="stylesheet" type="text/css" />-->
	<style type="text/css">
EOF
	# Embed stylesheet for now.
	cat "$TBCIS_WEBUI_ROOT/style.css"
	cat << EOF
	</style>
</head>
<body>
	<div id="header">
		<h1>CI Tasks @ $HOSTNAME</h1>
	</div>

<div id="content">
EOF

	if [ -f "$TBCIS_WEBUI_MOTD_FILE" ]; then
		cat "$TBCIS_WEBUI_MOTD_FILE"
	fi

	# Check that there is tasks
	if [ -d "$TBCIS_RESULTS_ROOT" -a "`ls $TBCIS_RESULTS_ROOT`" ]; then
		# Iterate tasks
		cd "$TBCIS_RESULTS_ROOT"
		for task in *; do
			echo "<div class=\"task\">";
			echo "<h3>$task</h3>"
			( cd $task
				# Check for desciption
				if [ -f "description.txt" ]; then
					echo "<p>"
					cat description.txt
					echo "</p>"
				fi
				# Table start
				echo "<table class=\"runtable\">"
				echo "<tr><th>Run id</th><th>Changes</th><th>Config</th><th>Build</th><th>Package</th><th>Test</th><th>Output files</th></tr>"
				for i in `ls|tac`; do
					if [ -d "$i" ]; then
						( cd $i
							echo "<tr>"
							echo "<td>$i</td>"
							create_cell changes
							create_cell config
							create_cell build
							create_cell package
							create_cell test
							create_dl_cell
							echo "</tr>"
						)
					fi
				done
				echo "</table>"
			)
			echo "</div>"
		done
	else
		echo "<p>No tasks/runs.</p>"
	fi

	# Add the rest of the HTML
	cat << EOF
</div>

	<div id="footer">
		<small>Powered by TBCIS</small>
	</div>
</body>
</html>
EOF
}

# Cache system
if [ ! -e "$TBCIS_WEBUI_CACHE_FILE" ]; then
	# Create if no cache not found
	generate_page > "$TBCIS_WEBUI_CACHE_FILE"
else
	cache_age=`stat -c %Y "$TBCIS_WEBUI_CACHE_FILE"`
	cur_time=`date +%s`
	cache_diff=$(($cur_time-$cache_age))
	if [ "$cache_diff" -gt "$TBCIS_WEBUI_CACHE_TIME" ]; then
		# Recreate only if old enough
		generate_page > "$TBCIS_WEBUI_CACHE_FILE"
	fi
fi

# Display cache
cat "$TBCIS_WEBUI_CACHE_FILE"

# Calculate generation time
tt=`date +%s%N`
t=$((($tt - $t)/1000000))
echo "<!-- Page generated in $t ms -->"


