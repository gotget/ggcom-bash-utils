#!/usr/bin/env bash
################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
################################################################################
source "${SCRIPTPATH}/../ggcom-bash-library/varsBash.bash"
source "${SCRIPTPATH}/../ggcom-bash-library/ip.bash"
source "${SCRIPTPATH}/../ggcom-bash-library/string.bash"
################################################################################
VERSION=201502230627
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

echo "Nuking Host Name : ${HOST}"
echo ssh-keygen -f ${TARGET} -R ${HOST} > /dev/null 2>&1

if valid_ipv4 $HOSTIP == true; then
	echo "Nuking Host IP   : ${HOSTIP}"
	echo ssh-keygen -f ${TARGET} -R ${HOSTIP} > /dev/null 2>&1
fi
