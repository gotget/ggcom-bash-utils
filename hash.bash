#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Hash v201507101115
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/hashbash

Example usage:
$] hash.bash sha1 ~/target/path/file
$] echo -n "Hello World" | ./hash.bash sha1

To-do:
* Fix STDIN bug
* Relating to STDIN bug, use different temporary location if mktemp's location doesn't have enough space
* OSX adding newline characters for hashing directories; temporary workaround is printf cat.

Thanks:

python - Linux: compute a single hash for a given folder & contents? - Stack Overflow
http://stackoverflow.com/questions/545387/linux-compute-a-single-hash-for-a-given-folder-contents

bash - sha1sum for a directory of directories - Super User
http://superuser.com/questions/458326/sha1sum-for-a-directory-of-directories

osx - execute a command in all subdirectories bash - Super User
http://superuser.com/questions/608286/execute-a-command-in-all-subdirectories-bash

file - Bash: Recursively adding subdirectories to the path - Stack Overflow
https://stackoverflow.com/questions/657108/bash-recursively-adding-subdirectories-to-the-path

Capturing output of find . -print0 into a bash array - Stack Overflow
http://stackoverflow.com/questions/1116992/capturing-output-of-find-print0-into-a-bash-array

linux - How to do for each file using find in shell/bash? - Stack Overflow
http://stackoverflow.com/questions/15065010/how-to-do-for-each-file-using-find-in-shell-bash

osx - Why does UTF-8 text sort in different order between OS X and Linux? - Stack Overflow
http://stackoverflow.com/questions/27395317/why-does-utf-8-text-sort-in-different-order-between-os-x-and-linux

shell - Sorting the output of "find"? - Unix & Linux Stack Exchange
http://unix.stackexchange.com/questions/34325/sorting-the-output-of-find

python - case-insensitive list sorting, without lowercasing the result? - Stack Overflow
http://stackoverflow.com/questions/10269701/case-insensitive-list-sorting-without-lowercasing-the-result

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

#------------------------------ Options and Variables

# Array of arguments that we will pass and parse
ARGSN=$#
ARGSA=()
for var in "$@"; do ARGSA+=("$var"); done;

# Verbosity
[ ! -z "`parseArgs "${ARGSA[@]}" "-v"`" ] && valVerbose="`parseArgs "${ARGSA[@]}" "-v"`" || valVerbose="`parseArgs "${ARGSA[@]}" "--verbose"`"

# Algorithm
[ ! -z "`parseArgs "${ARGSA[@]}" "-a"`" ] && valAlg="`parseArgs "${ARGSA[@]}" "-a"`" || valAlg="`parseArgs "${ARGSA[@]}" "--algorithm"`"

# Target
[ ! -z "`parseArgs "${ARGSA[@]}" "-t"`" ] && valTarget="`parseArgs "${ARGSA[@]}" "-t"`" || valTarget="`parseArgs "${ARGSA[@]}" "--target"`"

# Version
if [ "`parseArgs "${ARGSA[@]}" "--version"`" = True ]; then valVersion=True; fi

# Help Menu
[ ! -z "`parseArgs "${ARGSA[@]}" "-h"`" ] && valHelp="`parseArgs "${ARGSA[@]}" "-h"`" || valHelp="`parseArgs "${ARGSA[@]}" "--help"`"
if [ "`parseArgs "${ARGSA[@]}" "-?"`" = True ]; then valHelp=True; fi

# Show header?
showHeader=False
if [ "$valVerbose" = True ] || [ "$valHelp" = True ]; then
	showHeader=True
fi

#----- Default Values
TMPARGCOUNT=0
for var in "${ARGSA[@]}"; do
	if [ "${var:0:1}" = '-' ]; then
		continue
	fi
	((TMPARGCOUNT++))
	case "$TMPARGCOUNT" in
		1)
			valAlg="$var"
			;;
		2)
			valTarget="$var"
			;;
	esac
done;
unset TMPARGCOUNT var
#-----/Default Values

#----- NOTICE: VERSION
if [ "$valVersion" = True ]; then
	echo "`getVersion $0 number`"
	exit 0
fi

if [ "$showHeader" = True ]; then
	echo "`getVersion $0 header`"
	echo;
fi
#-----/NOTICE: VERSION

#----- VERBOSITY: ARGUMENTS
if [  "$valVerbose" = True ]; then
	for var in "${ARGSA[@]}"; do echo -e "${ggcLightPurple}Supplied argument:${ggcNC} ${ggcLightBlue}${var}${ggcNC}"; done;
	echo;
fi
unset var
#-----/VERBOSITY: ARGUMENTS

#----- NOTICE: HELP INFO
if [ "$valHelp" = True ]; then
	echo -e "${ggcLightPurple}Hash candidate      :${ggcNC} ${ggcLightBlue}`cryptoHashCandidate "$valAlg"`${ggcNC}"
	echo -en "${ggcLightPurple}Post hash arguments :${ggcNC} ${ggcLightBlue}"
	echo -n `cryptoHashCandidatePost "$valAlg"`
	echo -e "${ggcNC}"
	echo;
read -r -d '' HELPMENU <<EOF
Usage: $SCRIPTNAME [OPTIONS]... ALGORITHM TARGET
  or   $SCRIPTNAME [OPTIONS]

Options
 -a, --algorithm             hashing algorithm (Common are 'CK' (CRC-32), 'MD5', or 'SHA1')
 -t, --target                target to hash (file or directory)
 -v, --verbose               increase verbosity
     --version               print version number
(-h) --help                  show this help (-h is --help only if used alone)
EOF
	echo "$HELPMENU"
	exit 0
fi
#-----/NOTICE: HELP INFO

#----- CHECK FOR HASH
if [ -z "$valAlg" ]; then
	echo -e "${ggcLightRed}No hash algorithm specified.  Common uses are 'CK' (CRC-32), 'MD5', or 'SHA1'.${ggcNC}" >&2
	exit 1
fi

TMPHASHCHECK="`cryptoHashCalc "$valAlg" test`"
if [ ! -z "$TMPHASHCHECK" ]; then
	echo -e "${ggcLightRed}It appears that your hash selection ('$valAlg') is invalid.  Common uses are 'CK' (CRC-32), 'MD5', or 'SHA1'.${ggcNC}" >&2
	echo -e "The specific error message was: ${ggcLightPurple}$TMPHASHCHECK${ggcNC}" >&2
	exit 1
fi
unset TMPHASHCHECK
#-----/CHECK FOR HASH

#------------------------------/Options and Variables

#----- HASH OUTPUT

# Checks STDIN vs FILE ARGUMENT
if [ -z "$valTarget" ]; then	# STRING

# Failed Attempt #1
#	read -r -t 1 STDINP1
#	if [ ! -z "$STDINP1" ]; then
#		stringInput="$STDINP1"
#		stringInput+=`cat`
#	else
#		echo "No hash specified for file '$valAlg'.  Common uses are MD5 or SHA1." >&2
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

#	echo "`cryptoHashCalc "$valAlg" string "$strInp"`"

# This is absolutely not the way that I want to do this, but others are experiencing similar problems with newlines in read, which provides timeouts since cat doesn't:
# http://www.dslreports.com/forum/r28406360-Reading-from-a-pipe-in-a-bash-script-with-timeout

	TMPSTRINP=`mktemp 2>/dev/null || mktemp -t 'hash'`
	cat > $TMPSTRINP
	echo "`cryptoHashCalc "$valAlg" file "$TMPSTRINP"`"
	rm -rf TMPSTRINP

else					# FILE OR DIRECTORY

	# TARGET DOES NOT EXIST
	if [ ! -f "$valTarget" ] && [ ! -d "$valTarget" ]; then
		echo -e "${ggcLightRed}Target does not exist.${ggcNC}" >&2
		exit 1

	# FILE
	elif [ -f "$valTarget" ]; then
		echo "`cryptoHashCalc "$valAlg" file "$valTarget"`"
		exit 0

	# DIRECTORY - this method is entirely up for debate
	# the tar method would yield a completely different hash value, possibly on separate machines of same content
	# I tried to stick with a method that's as reproducible as possible with minimal cache size (due to the aforementioned STDIN bug), regardless of system:
	# List individual hashes of all files (except operating system files) in Key:Value CSV format
	# Hash the cumulative output
	elif [ -d "$valTarget" ]; then
		TMPSTRINP=`mktemp 2>/dev/null || mktemp -t 'hash'`
		ORIGPWD="$PWD"
		cd "$valTarget"

		if [  "$valVerbose" = True ]; then
			echo -e "${ggcLightPurple}Cumulative hash cache:${ggcNC} ${ggcLightBlue}${TMPSTRINP}${ggcNC}"
			echo;
		fi

		# Create array of files to work through, and more importantly, show when the verbose flag is set
		if [ "$valVerbose" = True ]; then
			echo -e "${ggcLightPurple}Scanning files:${ggcNC}"
		fi

		# Hideous sorting technique has to be done due to the way that OSX differs from Linux on UTF-8
		unset FILEHASHLIST i f
		while IFS= read -r -d $'\0' f; do
			FILEHASHLIST[i++]="$f"
		done < <( python -c "import os, sys; fdl=os.listdir('.'); sys.stdout.write('\0'.join( sorted( [x for x in fdl if x not in ['.DS_Store']], key=lambda s: s.lower() ) )+'\0' )" )
		unset i f

		fileItems=${#FILEHASHLIST[@]}
		countFile=1
		for fileItem in "${FILEHASHLIST[@]}"; do

			if [ "$valVerbose" = True ]; then printf "($countFile/$fileItems = $(bc <<< "scale=1; ($countFile*100/$fileItems)") %%) ${fileItem}:"; fi

			hashItem="$( "${SCRIPTPATH}/${SCRIPTNAME}" "$valAlg" "$fileItem" )"

			if [  "$valVerbose" = True ]; then printf "${hashItem}\n"; fi

			printf "${fileItem}:${hashItem}" >> "$TMPSTRINP"

			# Comma separator if not last entry
			if [ $countFile -lt $fileItems ]; then printf "," >> "$TMPSTRINP"; fi

			(( countFile++ ))

		done; # END: for fileItem in "${FILEHASHLIST[@]}"
		unset FILEHASHLIST fileItems countFile fileItem

		# Dealing with OSX-based issue in erroneously adding newline, thus messing up the hash
		# cache="$( cat "$TMPSTRINP" | tr -d '\r' | tr -d '\n' | sed 's/,$//' )" # Can be used to clean-up the cache file
		hashCache="$( "${SCRIPTPATH}/${SCRIPTNAME}" "$valAlg" "$TMPSTRINP" )"

		if [  "$valVerbose" = True ]; then
			echo;
			echo -e "${ggcLightPurple}Directory Cache:${ggcNC}"
			cat "$TMPSTRINP"
			echo;
			echo;
			echo -e "${ggcLightPurple}Directory Cache Hash:${ggcNC}"
			echo -e "${ggcLightBlue}${hashCache}${ggcNC}"
		else
			echo "${hashCache}"
		fi

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
