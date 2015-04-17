#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Generate Password v201504162001
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/genpass

Example usage:
genpass.bash [length] [tr format]
genpass.bash 40 [:alnum:] (only letters and numbers)
genpass.bash 40 [:print:] (all characters with spaces)
genpass.bash 40 [:graph:] (all characters without spaces)

Thanks:
http://serverfault.com/questions/6440/is-there-an-alternative-to-dev-urandom
http://www.commandlinefu.com/commands/view/13130/generate-random-password-on-mac-os-x
http://askubuntu.com/questions/60712/how-do-i-quickly-encrypt-a-file-with-aes

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
################################################################################

#----- VARIABLES
LENGTH=${1-40}
FILTER=${2-'[:print:]'}
#-----/VARIABLES

#----- NOTICE: INFO
echo `str_repeat - 80` >&2
echo "`getVersion $0 header`" >&2
echo `str_repeat - 80` >&2
echo '' >&2;
#-----/NOTICE: INFO

#----- MAIN
echo "`cryptoGenPass "$LENGTH" "$FILTER"`"
#-----/MAIN
