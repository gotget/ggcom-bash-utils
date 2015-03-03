#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - Bootstrap RSA Authentication v201503031004
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/bootstraprsa
#
# Example usage:
# ./bootstrapRsaAuth.bash

################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
source "${LIBPATH}/version.bash"
################################################################################
#
################################################################################

#----- NOTICE: INFO
echo "`getVersion $0 header`"
echo;
#-----/NOTICE: INFO

#----- PROMPTS
read -p "Username: " user;
read -p "Server: " server;
#-----/PROMPTS

value=`cat ~/.ssh/id_rsa.pub`;
ssh $user@$server "mkdir -p ~/.ssh; chmod 700 ~/.ssh/; echo '$value' >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys;"
