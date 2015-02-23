#!/usr/bin/env bash
################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
################################################################################
#
################################################################################
VERSION=201502231010
PROGTITLE="${SCRIPTNAME} (`printf "%x" ${VERSION}`-v${VERSION})"
################################################################################
echo "${PROGTITLE} |";
#echo "`updates_check ${PROGTITLE}`"
echo "`str_repeat - ${#PROGTITLE}`-+";
################################################################################

#----- PROMPTS
read -p "Username: " user;
read -p "Server: " server;
#-----/PROMPTS

value=`cat ~/.ssh/id_rsa.pub`;
ssh $user@$server "mkdir -p ~/.ssh; chmod 700 ~/.ssh/; echo '$value' >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys;"
