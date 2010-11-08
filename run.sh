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

# Include the task if exists
if [ ! -e "$TASKS_ROOT/$TASK" ]; then
    echo "Cannot find task $TASK"
    exit 1
fi
source $TASKS_ROOT/$TASK

# Create a directory for result files
RESULT_DIR="$RESULTS_ROOT/$TASK/$RESULT_ID"
mkdir -p "$RESULT_DIR"
OUT_DIR="$RESULT_DIR/out"
mkdir -p "$OUT_DIR"

# Function for handling phase result
finish_task()
{
    if [ $status = "RUNNING" ]; then
        status OK
    elif [ $status = "N/A" ]; then
        rm $RESULT_DIR/$phase.status
        rm $RESULT_DIR/$phase.log
    elif [ $status = "NOK" ]; then
        # We exit "succesfully" although NOK.
        # Return value is used for script errors.
        exit 0
    fi
}

# Run phases
for phase in $SUBTASKS; do
    status RUNNING
    do_${phase} > "$RESULT_DIR/$phase.log" 2>&1
    finish_task
done

