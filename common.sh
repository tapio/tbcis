# Functions provided for task scripts

out_file()
{
	cp "$1" "$TBCIS_OUT_DIR/"
}

status()
{

	echo "$1" > $TBCIS_RESULT_DIR/$TBCIS_PHASE.status
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

