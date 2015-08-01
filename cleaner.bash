#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Cleaner v201508012114
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/cleaner

Example usage:

Purge Python compiled bytecode in present directory by default
$] cleaner.bash

Purge PDF files in /tmp/ without a confirmation message
$] cleaner.bash --path='/tmp' --pattern='*.pdf' --silent

Thanks:

Find escape xargs rm - Google Search
https://www.google.com/search?q=find+escape+xargs+rm

linux - How can I use xargs to copy files that have spaces and quotes in their names? - Stack Overflow
http://stackoverflow.com/questions/143171/how-can-i-use-xargs-to-copy-files-that-have-spaces-and-quotes-in-their-names

command line arguments - How can I use long options with the Bash getopts builtin? - Stack Overflow
http://stackoverflow.com/questions/12022592/how-can-i-use-long-options-with-the-bash-getopts-builtin

BashFAQ/035 - Greg's Wiki
http://mywiki.wooledge.org/BashFAQ/035

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
source "${LIBPATH}/colors.bash"
################################################################################

#------------------------------ Variables
#----- Options
# Array of arguments that we will pass and parse
ARGSN=$#
ARGSA=()
for var in "$@"; do ARGSA+=("$var"); done;

# Target Path
[ ! -z "`parseArgs "${ARGSA[@]}" "-t"`" ] && pathSelect="`parseArgs "${ARGSA[@]}" "-t"`" || pathSelect="`parseArgs "${ARGSA[@]}" "--target"`"
if [ -z "$pathSelect" ]; then pathSelect='./'; fi
pathSelect=`mod_trail_slash add "${pathSelect}"`

# Pattern
[ ! -z "`parseArgs "${ARGSA[@]}" "-p"`" ] && extSelect="`parseArgs "${ARGSA[@]}" "-p"`" || extSelect="`parseArgs "${ARGSA[@]}" "--pattern"`"
if [ -z "$extSelect" ]; then extSelect='*.pyc'; fi

# Silent
[ ! -z "`parseArgs "${ARGSA[@]}" "-s"`" ] && silentMode="`parseArgs "${ARGSA[@]}" "-s"`" || silentMode="`parseArgs "${ARGSA[@]}" "--silent"`"
if [ "$silentMode" != True ]; then silentMode=False; fi

# Version
if [ "`parseArgs "${ARGSA[@]}" "--version"`" = True ]; then valVersion=True; fi

# Help Menu
[ ! -z "`parseArgs "${ARGSA[@]}" "-h"`" ] && valHelp="`parseArgs "${ARGSA[@]}" "-h"`" || valHelp="`parseArgs "${ARGSA[@]}" "--help"`"
if [ "`parseArgs "${ARGSA[@]}" "-?"`" = True ]; then valHelp=True; fi

showHeader=True
#-----/Options

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

#----- NOTICE: HELP INFO
if [ "$valHelp" = True ]; then
read -r -d '' HELPMENU <<EOF
Usage: $SCRIPTNAME [OPTIONS]... (-p|--pattern)=PATTERN (-t|--target)=TARGET

Options
 -t, --target                target to hash (file or directory)
 -p, --pattern               file pattern to match for deletion (default is "${extSelect}")
 -s, --silent                increase verbosity
     --version               print version number
(-h) --help                  show this help (-h is --help only if used alone)
EOF
	echo "$HELPMENU"
	exit 0
fi
#-----/NOTICE: HELP INFO

#----- List of files that match our path and pattern
fileListMatchOutput=`mktemp 2>/dev/null || mktemp -t 'fmdms'`
fileListErrorOutput=`mktemp 2>/dev/null || mktemp -t 'fmdms'`

find "${pathSelect}" -iname "${extSelect}" 1>"$fileListMatchOutput" 2>"$fileListErrorOutput"

fileList=`cat "$fileListMatchOutput"`
fileListError=`cat "$fileListErrorOutput"`
rm -rf "$fileListMatchOutput"
rm -rf "$fileListErrorOutput"
unset fileListMatchOutput fileListErrorOutput

if [ -z "$fileList" ] && [ ! -z "$fileListError" ]; then
	echo -e "${ggcLightRed}An error has occurred with arguments passed to find:${ggcNC}" >&2
	echo -e "${ggcLightBlue}find "${pathSelect}" -iname "${extSelect}"${ggcNC}"
	echo;
	echo "${fileListError}"
	exit 1;
fi
#-----/List of files that match our path and pattern

#------------------------------/Variables

echo -e "${ggcLightPurple}Cleaning:${ggcNC} ${ggcCyan}`mod_trail_slash rem "${pathSelect}"`/${extSelect}${ggcNC}"
echo;

# Match found
if [ ! -z "$fileList" ]; then

	echo -e "${ggcLightPurple}Files found:${ggcNC}"
	echo -e "${ggcCyan}`echo "${fileList}" | perl -pe 's{^}{\"};s{$}{\"}' | xargs ls -ld`${ggcNC}";

	# Confirmation message, along with reminder about silent mode
	if [ "$silentMode" != True ]; then
		echo;
		echo -e "${ggcLightRed}This is a destructive action. Press enter to confirm, or CTRL-C to cancel.${ggcNC}"
		echo -e "${ggcLightBlue}You can disable this warning with --silent${ggcNC}"
		echo;
		`pauseret`
	fi

	echo;
	echo -e "${ggcLightRed}Deleting:${ggcNC}"
	echo "${fileList}" | perl -pe 's{^}{\"};s{$}{\"}' | xargs rm -rfv;

# No match found
else
	echo -e "${ggcCyan}No matching files.${ggcNC}"
fi
