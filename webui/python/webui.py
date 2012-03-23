#!/usr/bin/env python

import os
import sys
import time

t = time.clock()

TBCIS_TASKS_ROOT = "tasks"
TBCIS_RESULTS_ROOT = "results"
TBCIS_WEBUI_MOTD_FILE = "motd.html"

def internal_error(reason):
	print 'Content-type: text/html'
	print ''
	print reason
	sys.exit(1)


print 'Content-type: text/html'
print ''

def read_file(filename):
	try:
		with open(filename, 'r') as f:
			contents = f.read()
	except:
		return ''
	return contents

def create_cell(phase):
	status = read_file(phase + '.status').rstrip('\n')
	tdclass = 'na'
	if status == '':
		status = 'N/A'
	if status != 'N/A':
		tdclass = status.lower()
		status = '<a href="' +os.path.join(TBCIS_RESULTS_ROOT, task, i, phase)+ '.log">' +status+ '</a>'
	return '<td class="' +tdclass+ '">' +status+ '</td>'


def create_dl_cell():
	cell = '<td>'
	cnt = len(os.listdir('out'))
	if cnt == 0:
		cell += 'N/A'
	elif cnt == 1:
		f = os.listdir('out')[0]
		cell += '<a href="' + os.path.join(TBCIS_RESULTS_ROOT, task, i, 'out', f) + '">[DL]</a>'
	else:
		cell += '<a href="' + os.path.join(TBCIS_RESULTS_ROOT, task, i, 'out') + '">[Browse]</a>'
	return cell + '</td>'


# Output some HTML ot start with
print '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="refresh" content="120" />
	<title>Tiny Bash Continuous Integration System WebUI</title>
	<link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>

<div id="header">
	<h1>CI Tasks</h1>
</div>

<div id="content">
'''

# Page header text
print read_file(TBCIS_WEBUI_MOTD_FILE)

# Additional info
print '<p><em>Only runs with changes are displayed.</em></p>'

# Check that there is tasks
if os.path.exists(TBCIS_RESULTS_ROOT) and os.listdir(TBCIS_RESULTS_ROOT) != []: 
	# Iterate tasks
	os.chdir(TBCIS_RESULTS_ROOT)
	tasks = sorted(os.listdir('.'))
	for task in tasks:
		print '<div class="task">'
		print '<h3>%s</h3>' % task
		os.chdir(task)

		# Check for desciption
		print "<p>"
		print read_file('description.txt')
		print "</p>"

		# Table start
		print '<table class="runtable">'
		print '<tr><th>Run id</th><th>Changes</th><th>Config</th><th>Build</th><th>Package</th><th>Test</th><th>Output files</th></tr>'

		runs = sorted(os.listdir('.'), reverse=True)
		for i in runs:
			if os.path.isdir(i):
				os.chdir(i)
				status = read_file('changes.status').rstrip('\n')
				if status != 'NOCHG':
					print '<tr>'
					print '<td>%s</td>' % i
					print create_cell('changes')
					print create_cell('config')
					print create_cell('build')
					print create_cell('package')
					print create_cell('test')
					print create_dl_cell()
					print '</tr>'
				os.chdir('..')

		print '</table>'
		os.chdir('..')
		print '</div>'
else:
	print '<p>No tasks/runs.</p>'

# Add the rest of the HTML
print '''
</div>

	<div id="footer">
		<small>Powered by TBCIS</small>
	</div>
</body>
</html>
'''

elapsed = (time.clock() - t) * 1000
print '<!-- Page generation took %d ms -->' % elapsed


