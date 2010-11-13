#!/bin/bash

USAGE_LINE="Usage: `basename $0` task [subtask]"
VERSION=pre-alpha
if [ ! "$1" ]; then
    echo $USAGE_LINE
    exit 1
elif [ "$1" = "-h" -o "$1" = "--help" ]; then
    echo "TBCIS - Tiny Bash Continuous Integration System"
    echo "Version: $VERSION"
    echo
    echo $USAGE_LINE
    exit 0
elif [ "$1" = "-v" -o "$1" = "--version" ]; then
    echo $VERSION
    exit 0
fi

TASK="$1"
shift
SUBTASKS="$@"

if [ ! "$SUBTASKS" -o "$SUBTASKS" = "run" ]; then
    SUBTASKS="config build test"
fi

source config.sh
source common.sh

# Check the task exists
if [ ! -e "$TBCIS_TASKS_ROOT/$TASK" ]; then
    echo "Cannot find task $TASK"
    exit 1
fi

# Create a directory for result files
TBCIS_RESULT_DIR="$TBCIS_RESULTS_ROOT/$TASK/$TBCIS_RESULT_ID"
mkdir -p "$TBCIS_RESULT_DIR"
TBCIS_OUT_DIR="$TBCIS_RESULT_DIR/out"
mkdir -p "$TBCIS_OUT_DIR"

# Function for handling phase result
finish_task()
{
	if [ $? -ne 0 ]; then
		status ERR
		exit 0
	fi
	local status=`cat $TBCIS_RESULT_DIR/$TBCIS_PHASE.status || echo N/A`
    if [ $status = "RUNNING" ]; then
        status OK
    elif [ $status = "N/A" ]; then
        rm $TBCIS_RESULT_DIR/$TBCIS_PHASE.status
        rm $TBCIS_RESULT_DIR/$TBCIS_PHASE.log
    elif [ $status = "NOK" ]; then
        exit 0
    fi
}

# Run phases
for TBCIS_PHASE in $SUBTASKS; do
    logfile="$TBCIS_RESULT_DIR/$TBCIS_PHASE.log"
    echo "Starting phase '$TBCIS_PHASE' on `date -R`" > "$logfile"
    echo "" >> "$logfile"
    status RUNNING
    export TBCIS_PHASE
    export TBCIS_RESULT_DIR
    export TBCIS_OUT_DIR
    echo "source common.sh; source $TBCIS_TASKS_ROOT/$TASK; do_${TBCIS_PHASE}" | bash >> "$logfile" 2>&1
    echo "" >> "$logfile"
    echo "Ending phase '$TBCIS_PHASE' on `date -R`" >> "$logfile"
    finish_task
done

