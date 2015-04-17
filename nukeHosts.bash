#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Nuke Hosts v201504162001
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/nukehosts

Example usage:
nukehosts.bash HOST [KNOWN_HOSTS_FILE]

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
source "${LIBPATH}/ip.bash"
################################################################################

#----- NOTICE: INFO
echo "`getVersion $0 header`"
echo;
#-----/NOTICE: INFO

#----- HOSTS FILE TARGET
if [ -z "$2" ]; then
	TARGET=$HOME/.ssh/known_hosts
else
	TARGET=${2}
fi
#-----/HOSTS FILE TARGET

#----- HOST
if [ -z "$1" ]; then
	echo "Usage: ${SCRIPTNAME} host [known_hosts_file]"
	exit;
fi
#----- HOST

echo "Known host file  : ${TARGET}"

HOST=${1}
HOSTIP=`host ${1} | awk '{print $4}'`
# TO FIX: HOSTIP doesn't follow-through on aliases, and thus provides an invalid IP return

echo "Nuking Host Name : ${HOST}"
ssh-keygen -f ${TARGET} -R ${HOST} > /dev/null 2>&1

if valid_ipv4 $HOSTIP == true; then
	echo "Nuking Host IP   : ${HOSTIP}"
	ssh-keygen -f ${TARGET} -R ${HOSTIP} > /dev/null 2>&1
fi
