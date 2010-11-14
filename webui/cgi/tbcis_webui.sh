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
elif [ ! "$TBCIS_WEB_RESULTS_ROOT" ]; then
	internal_error "Error: TBCIS_WEB_RESULTS_ROOT undefined"
fi

t=`date +%s%N`

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

create_dl_cell()
{
	echo -n "<td>"
	local cnt=`ls out | wc -l`
	if [ "$cnt" -eq 0 ]; then
		echo -n "N/A"
	elif [ "$cnt" -eq 1 ]; then
		local f="`ls out`"
		echo -n "<a href=\"$TBCIS_WEB_RESULTS_ROOT/$task/$i/out/$f\">"
		echo -n "[DL]"
		echo -n "</a>"
	else
		echo -n "<a href=\"$TBCIS_WEB_RESULTS_ROOT/$task/$i/out\">"
		echo -n "[Browse]"
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
			echo "<tr><th>Run id</th><th>Config</th><th>Build</th><th>Package</th><th>Test</th><th>Output files</th></tr>"
			for i in `ls|tac`; do
				( cd $i
					echo "<tr>"
					echo "<td>$i</td>"
					create_cell config
					create_cell build
					create_cell package
					create_cell test
					create_dl_cell
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

tt=`date +%s%N`
t=$((($tt - $t)/1000000))
# Add the rest of the HTML
cat << EOF
	</div>
	<div id="footer">
		<small>Powered by TBCIS<span> - Page generated in $t ms</span></small>
	</div>
</body>
</html>
EOF

