#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Cleaner v201505312254
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

#------------------------------ NOTICE: INFO
echo `str_repeat - 80`
echo "`getVersion "$0" header`"
echo `str_repeat - 80`
#------------------------------ /NOTICE: INFO

#------------------------------ Variables
# Path, which defaults to present working directory
pathSelect='./'

# File pattern to clean
extSelect='*.pyc'

# Silent Mode (can be turned on with --silent)
silentMode=false

#----- Options
while :; do
	case "$1" in

		--path=?*) pathSelect=${1#*=} ;;

		--pattern=?*) extSelect=${1#*=} ;;

		--silent) silentMode=true ;;

		*)	# Default case: If no more options then break out of the loop.
			break

	esac

	shift
done

pathSelect=`mod_trail_slash add "${pathSelect}"`

#-----/Options

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
	if [ "$silentMode" != true ]; then
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
