# Functions provided for task scripts

out_file()
{
    cp "$1" "$OUT_DIR/$1"
}

status()
{
    if [ "$1" ]; then
        status="$1"
    fi
    echo "$status" > $RESULT_DIR/$phase.status
}

error()
{
    status NOK
}

exit_error()
{
    error
    exit 0
}

NA()
{
    status N/A
}

