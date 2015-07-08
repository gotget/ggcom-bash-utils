#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Hash v201507081231
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/hashbash

Example usage:
$] hash.bash sha1 ~/target/path/file
$] echo -n "Hello World" | ./hash.bash sha1

To-do:
* Fix STDIN bug
* Relating to STDIN bug, use different temporary location if mktemp's location doesn't have enough space

Thanks:

python - Linux: compute a single hash for a given folder & contents? - Stack Overflow
http://stackoverflow.com/questions/545387/linux-compute-a-single-hash-for-a-given-folder-contents

bash - sha1sum for a directory of directories - Super User
http://superuser.com/questions/458326/sha1sum-for-a-directory-of-directories

osx - execute a command in all subdirectories bash - Super User
http://superuser.com/questions/608286/execute-a-command-in-all-subdirectories-bash

file - Bash: Recursively adding subdirectories to the path - Stack Overflow
https://stackoverflow.com/questions/657108/bash-recursively-adding-subdirectories-to-the-path

!COMMENT

################################################################################
SOURCE="${BASH_SOURCE[0]}" # Dave Dopson, Thank You! - http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPTPATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPTPATH/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
################################################################################
SCRIPTPATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPTNAME=`basename "$SOURCE"`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
source "${LIBPATH}/version.bash"
################################################################################
source "${LIBPATH}/prompt.bash"
source "${LIBPATH}/crypto.bash"
source "${LIBPATH}/colors.bash"
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
	echo -e "${ggcLightRed}No hash specified.  Common uses are MD5 or SHA1.${ggcNC}" >&2
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

	TMPSTRINP=`mktemp 2>/dev/null || mktemp -t 'hash'`
	cat > $TMPSTRINP
	echo "`cryptoHashCalc "$1" file "$TMPSTRINP"`"
	rm -rf TMPSTRINP

else					# FILE OR DIRECTORY

	# TARGET DOES NOT EXIST
	if [ ! -f "$2" ] && [ ! -d "$2" ]; then
		echo -e "${ggcLightRed}Target does not exist.${ggcNC}" >&2
		exit 1

	# FILE
	elif [ -f "$2" ]; then
		echo "`cryptoHashCalc "$1" file "$2"`"
		exit 0

	# DIRECTORY - this method is entirely up for debate
	# the tar method would yield a completely different hash value, possibly on separate machines of same content
	# I tried to stick with a method that's as reproducible as possible with minimal size (due to the aforementioned STDIN bug), regardless of system:
	# List individual hashes of all files (except operating system files) in Key:Value CSV format
	# Hash the cumulative output
	elif [ -d "$2" ]; then
		TMPSTRINP=`mktemp 2>/dev/null || mktemp -t 'hash'`
		ORIGPWD="$PWD"
		cd "$2"

		printf "$(find . -type f ! -name '.DS_Store' | sort |
		while listAllFiles= read -r f; do
			printf "$f:$("${SCRIPTPATH}/${SCRIPTNAME}" "$1" "$f"),"
		done; )" | tr -d '\r' | tr -d '\n' | sed 's/,$//' 2>&1 > "$TMPSTRINP"
		"${SCRIPTPATH}/${SCRIPTNAME}" "$1" "$TMPSTRINP"

		cd "$ORIGPWD"
		rm -rf "$TMPSTRINP"
		exit 0

	# UNKNOWN ERROR
	else
		echo -e "${ggcLightRed}An unknown error has occurred.${ggcNC}" >&2
		exit 1

	fi

fi

#-----/HASH OUTPUT
