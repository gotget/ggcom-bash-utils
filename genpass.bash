#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - Generate Password v201503131459
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/genpass
#
# Example usage:
# genpass.bash [length] [tr format]
# genpass.bash 40 [:alnum:] (only letters and numbers)
# genpass.bash 40 [:print:] (all characters with spaces)
# genpass.bash 40 [:graph:] (all characters without spaces)
#
# Thanks:
# http://serverfault.com/questions/6440/is-there-an-alternative-to-dev-urandom
# http://www.commandlinefu.com/commands/view/13130/generate-random-password-on-mac-os-x

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

#----- VARIABLES
LENGTH=${1-40}
FILTER=${2-'[:print:]'}
#-----/VARIABLES

#----- NOTICE: INFO
echo `str_repeat - 80` >&2
echo "`getVersion $0 header`" >&2
echo `str_repeat - 80` >&2
echo "OpenSSL Entropy: $OPENSSL" >&2
echo `str_repeat - 80` >&2
echo '' >&2;
#-----/NOTICE: INFO

#----- MAIN
echo "`cryptoGenPass "$LENGTH" "$FILTER"`"
echo;
#-----/MAIN
