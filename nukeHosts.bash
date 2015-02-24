#!/usr/bin/env bash
################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
################################################################################
source "${LIBPATH}/ip.bash"
################################################################################
VERSION=201502230811
PROGTITLE="${SCRIPTNAME} (`printf "%x" ${VERSION}`-v${VERSION})"
################################################################################
echo "${PROGTITLE} |";
#echo "`updates_check ${PROGTITLE}`"
echo "`str_repeat - ${#PROGTITLE}`-+";
################################################################################

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
