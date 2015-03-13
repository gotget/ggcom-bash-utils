#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - Generate Password v201503131459
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/genpass
#
# Example usage:
# generatePassword.bash [length] [tr format]
# generatePassword.bash 40 [:alnum:] (only letters and numbers)
# generatePassword.bash 40 [:print:] (all characters with spaces)
# generatePassword.bash 40 [:graph:] (all characters without spaces)
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

#----- Variables
LENGTH=${1-40}
FILTER=${2-'[:print:]'}

OPENSSL=true
hash openssl 2>/dev/null || { OPENSSL=false; }
#-----/Variables

#----- NOTICE: INFO
echo `str_repeat - 80` >&2
echo "`getVersion $0 header`" >&2
echo `str_repeat - 80` >&2
echo "OpenSSL Entropy: $OPENSSL" >&2
echo `str_repeat - 80` >&2
echo '' >&2;
#-----/NOTICE: INFO

#----- MAIN
if [ "$OPENSSL" == true ]; then
	(openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt < /dev/zero | env LC_CTYPE=C tr -dc $FILTER | head -c $LENGTH) 2>/dev/null
else
	cat /dev/urandom | env LC_CTYPE=C tr -dc $FILTER | head -c $LENGTH;
fi

echo;
#-----/MAIN
