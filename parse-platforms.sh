#!/bin/bash

CONFIG="`dirname $0`/platforms.config"
PLATFORM=""
OUTPUT=""

check_for_header()
{
	(echo "$1" | grep '^\[' | grep '\]') >/dev/null || return 1
	HEADER=`echo $1 | cut -d'[' -f2 | cut -d']' -f1`
	if [ X"$HEADER" != X"" ]; then
		PLATFORM="$HEADER"
		return 0
	fi

	return 1
}

check_for_option()
{
	(echo "$1" | grep '=') >/dev/null || return 1
	OPTION=`echo "$1" | cut -d'=' -f1 | tr [a-z] [A-Z]`
	VALUE=`echo "$1" | cut -d'=' -f2-`
}

printusage()
{
    echo "`basename $0`: [-p <platform>] <command>"
}

#
# Parse command line.
#
CMD=
TARGET_PLAT=

while [ $# -gt 0 ]; do
    case $1 in
	-p)
	    shift
	    TARGET_PLAT="$1"
	;;
	*)
	    CMD="$1"
	;;
    esac
    shift
done

#
# Scan through config file, line by line
#
while read line
do
	check_for_header "$line"
	if [ $? -ne 0 ]; then
		continue
	fi
	if [ X"$CMD" = X"shortlist" -a X"$PLATFORM" != X"" ]; then
	    OUTPUT="$OUTPUT$PLATFORM "
	fi
	while read item
	do
		(echo "$item" | grep '^\[/\]') >/dev/null && PLATFORM="" && break
		check_for_option "$item"
		if [ $? -ne 0 ]; then
			continue
		fi
		case "$CMD" in
		    get-*)
			GETVAR="`echo $CMD | cut -d- -f2- | tr [a-z] [A-Z]`"
			if [ X"$TARGET_PLAT" = X"$PLATFORM" ]; then
			    if [ X"$OPTION" = X"$GETVAR" ]; then
				echo "$VALUE"
				exit 0
			    fi
			fi
			;;
		    list)
			if [ X"$OPTION" = X"LONGNAME" ]; then
			    OUTPUT="`printf \"%s\n%20s\t%s\" \"$OUTPUT\" \"$PLATFORM\" \"$VALUE\"`"
			fi
			;;
		    shortlist)
			continue
			;;
		    *)
			printusage
			exit 1
			;;
		esac
	done
done < "$CONFIG"

#
# Finish up
#
case "$CMD" in
    get-*)
	# No match found
	exit 1
	;;
    *)
	echo -n -e "$OUTPUT"
	if [ X"$CMD" = X"list" ];then
	    echo -e "\n"
	fi
	;;
esac
