#!/bin/bash

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

cd "$TBCIS_WEBUI_ROOT"

if [ "$QUERY_STRING" ]; then
	query_task=`echo "$QUERY_STRING" | sed -n 's/^.*task=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	query_runid=`echo "$QUERY_STRING" | sed -n 's/^.*runid=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	query_file=`echo "$QUERY_STRING" | sed -n 's/^.*file=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	if [ ! "$query_task" -o ! "$query_runid" -o ! "$query_file" ]; then
		internal_error "Error: Invalid query \"$QUERY_STRING\""
	fi
	trap="$query_task""$query_runid""$query_file"
	if [ "`echo "$trap" | grep "/"`" -o "`echo "$trap" | grep "\.\."`" ]; then
		internal_error "Error: Malformed query \"$QUERY_STRING\""
	fi
	echo Content-type: text/plain
	echo ""
	cat "$TBCIS_RESULTS_ROOT/$query_task/$query_runid/$query_file"
	exit 0
fi

# Content header
echo Content-type: text/html
echo ""

# Output some HTML ot start with
cat << EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="refresh" content="120">
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

create_cell()
{
	status=`cat $1.status || echo N/A`
	if [ $status = "N/A" ]; then
		echo -n "<td class=\"na\">"
		echo -n "$status"
	else
		class=`echo "$status" | tr "[:upper:]" "[:lower:]"`
		echo -n "<td class=\"$class\">"
		echo -n "<a href=\"?task=$task&runid=$i&file=$1.log\">"
		echo -n "$status"
		echo -n "</a>"
	fi
	echo "</td>"
}

# Check that there is tasks
if [ -d "$TBCIS_RESULTS_ROOT" -a "`ls $TBCIS_RESULTS_ROOT`" ]; then
	# Iterate tasks
	cd "$TBCIS_RESULTS_ROOT"
	for task in *; do
		echo "<div class=\"task\">";
		echo "<h3>$task</h3>"
		( cd $task
			# Table start
			echo "<table class=\"runtable\">"
			echo "<tr><th>Run id</th><th>Config</th><th>Build</th><th>Package</th><th>Test</th></tr>"
			for i in *; do
				( cd $i
					echo -n "<tr>"
					echo -n "<td>$i</td>"
					create_cell config
					create_cell build
					create_cell package
					create_cell test
					echo "</tr>"
				)
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

