#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - SSH Connector v201503200716
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
# http://stackoverflow.com/questions/8903239/how-to-calculate-time-difference-in-bash-script

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
source "${LIBPATH}/colors.bash"
################################################################################
ALIASNAME=`basename "$0"`
ALIASPATH=$( cd "$(dirname "$0")" ; pwd -P )

#----- VARIABLES
SSHHOST=$(basename "$ALIASPATH")
if [ -f "$ALIASPATH/.commonname" ]; then COMMONNAME=`cat "$ALIASPATH/.commonname"`; else COMMONNAME=`echo $SSHHOST | cut -d. -f1`; fi
COMMONNAMELENGTH=${#COMMONNAME}
#-----/VARIABLES

# MATCH 1
MATCH1=`echo "$ALIASNAME" | cut -c "$(( COMMONNAMELENGTH + 1 ))-"`

# MATCH 2
if [ ${#ALIASNAME} -gt $COMMONNAMELENGTH ]; then MATCH2=`echo "${ALIASNAME:0:${#ALIASNAME}-$(( COMMONNAMELENGTH + 1 ))}"`; else MATCH2=''; fi

# MATCH 3
if [ ${#ALIASNAME} -gt $COMMONNAMELENGTH ]; then MATCH3="${ALIASNAME:0:$COMMONNAMELENGTH}"; else MATCH3=''; fi

# MATCH 4
MATCH4=`echo "${ALIASNAME: -$COMMONNAMELENGTH}"`

# e.g. ./userName
USERNAMEMODE='normal'
#----- MATCH CONDITIONS
if [ "$COMMONNAME" == "$MATCH4" ] && [ -z "$MATCH2" ]; then
	# e.g. ./host
	USERNAMEMODE='short'

elif [ "$COMMONNAME" == "$MATCH2" ]; then
	# e.g. ./hostRoot
	USERNAMEMODE='medium'

elif [ "$COMMONNAME" == "$MATCH3" ]; then
	# e.g. ./hostRoot
	USERNAMEMODE='medium'

elif [ "$MATCH1" == "$MATCH4" ]; then
	# e.g. ./hostBob
	USERNAMEMODE='medium'

elif [ "$COMMONNAME" == "$MATCH4" ]; then
	# e.g. ./ user-host
	USERNAMEMODE='long'

fi
#-----/MATCH CONDITIONS

# Connection method based upon condition
case "$USERNAMEMODE" in
	normal)
		SSHUSER=$ALIASNAME
		;;
	short)
		SSHUSER=${1-`whoami`}
		;;
	medium)
		SSHUSER="$MATCH1"
		;;
	long)
		SSHUSER="$MATCH2"
		;;
esac

#----- NOTICE: INFO
echo `str_repeat - 80`
echo "`getVersion $0 header`"
echo `str_repeat - 80`
echo ''
#-----/NOTICE: INFO

#----- MAIN
echo `str_repeat - 80`
SSHSTART=$(date +%s);
echo `date +"%Y-%m-%d %H:%M:%S %Z"`
echo -e "${ggcLightGreen}Connecting${ggcNC}: ${ggcPurple}${SSHUSER}${ggcNC}@${ggcCyan}${SSHHOST}${ggcNC}"
echo `str_repeat - 80`

ssh "${SSHUSER}@${SSHHOST}"

echo `str_repeat - 80`
SSHSTOP=$(date +%s);
echo `date +"%Y-%m-%d %H:%M:%S %Z"`
echo -e "${ggcLightRed}Disconnected${ggcNC}: ${ggcPurple}${SSHUSER}${ggcNC}@${ggcCyan}${SSHHOST}${ggcNC}"
echo -e "${ggcLightGray}Duration${ggcNC}: ${ggcLightBlue}$( echo $((SSHSTOP-SSHSTART)) | awk '{printf "%02d:%02d\n",int($1/60), int($1%60)}' )${ggcNC}"
echo `str_repeat - 80`
#-----/MAIN
