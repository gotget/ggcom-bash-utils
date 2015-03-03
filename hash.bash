#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - Hash v201503030304
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/hashbash
#
# Example usage:
# ./hash.bash sha1 ~/target/path/file
# echo -n "Hello World" | ./hash.bash sha1

################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
source "${LIBPATH}/version.bash"
################################################################################
source "${LIBPATH}/prompt.bash"
source "${LIBPATH}/crypto.bash"
################################################################################

#----- NOTICE: INFO
#echo "`getVersion $0 header`"
#echo "SHA1/MD5: <CHECK>"
#echo "OpenSSL: <CHECK>"
#echo "GPG: <CHECK>"
#echo;
#-----/NOTICE: INFO

#----- CHECK FOR HASH
if [ -z "$1" ]; then
	echo "No hash specified.  Common uses are MD5 or SHA1." >&2
	exit 1
fi
#-----/CHECK FOR HASH

#----- HASH OUTPUT

# Checks STDIN vs FILE ARGUMENT
if [ -z "$2" ]; then	# STRING

# Failed Attempt #1
#	read -r -t 1 STDINP1
#	if [ ! -z "$STDINP1" ]; then
#		stringInput="$STDINP1"
#		stringInput+=`cat`
#	else
#		echo "No hash specified for file '$1'.  Common uses are MD5 or SHA1." >&2
#		exit 1
#	fi

# Failed Attempt #2
#	stringInput=''
#	while :; do
#		read -r -t 1 STDINP
#		stringInput+="$STDINP"
#		if [ -z "$STDINP" ]; then
#			break
#		fi
#	done

#	echo "`cryptoHashCalc "$1" string "$strInp"`"

# This is absolutely not the way that I want to do this, but others are experiencing similar problems with newlines in read, which provides timeouts since cat doesn't:
# http://www.dslreports.com/forum/r28406360-Reading-from-a-pipe-in-a-bash-script-with-timeout

	TMPSTRINP=`mktemp 2>/dev/null || mktemp -t 'sync'`
	cat > $TMPSTRINP
	echo "`cryptoHashCalc "$1" file "$TMPSTRINP"`"
	rm -rf TMPSTRINP

else					# FILE

	if [ ! -f $2 ]; then
		echo "File does not exist" >&2
		exit 1
	fi

	echo "`cryptoHashCalc "$1" file "$2"`"

fi

#-----/HASH OUTPUT
