#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Bootstrap RSA Authentication v201504162001
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/bootstraprsa

Example usage:
bootstrapRsaAuth.bash

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
