#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - SSH Connector v201503141855
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/sshcon
#
# Example usage:
# $] mkdir -pv ~/hosts/example.com
# $] export PATH="${PATH}:$(find ~/hosts -type d | tr "\n" ":" | sed "s/:$//")" # Works great in ~/.bash_profile or ~/.bashrc
# $] ln -s ~/ggcom/ggcom-bash-utils/sshcon.bash ~/hosts/example.com/exampleUserName
# $] exampleUserName
#
# Thanks:
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

################################################################################
SOURCE="${BASH_SOURCE[0]}" # Dave Dopson, Thank You! - http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPTPATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPTPATH/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
################################################################################
SCRIPTPATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPTNAME=`basename $SOURCE`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
source "${LIBPATH}/version.bash"
################################################################################
source "${LIBPATH}/colors.bash"
################################################################################

#----- VARIABLES
USER=$SCRIPTNAME
HOST=$(basename $SCRIPTPATH)
#-----/VARIABLES

#----- NOTICE: INFO
echo `str_repeat - 80`
echo "`getVersion $0 header`"
echo `str_repeat - 80`
echo ''
#-----/NOTICE: INFO

#----- MAIN
echo `str_repeat - 80`
echo -e "Connecting: ${ggcPurple}${USER}${ggcNC}@${ggcCyan}${HOST}${ggcNC}"
echo `str_repeat - 80`

ssh "${USER}@${HOST}"
#-----/MAIN
