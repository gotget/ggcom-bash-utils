#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - FMDMS (File Mtime Directory Md5 Synchronization) v201503311320
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/fmdms
#
# Example usage:
# export FMDMSDIFFMTIME=5 FMDMSDIFFSETTLETIME=2 FMDMSDIFFLSTIME=10
# export FMDMSRSYNCARGS='--archive --verbose --progress --partial --delete --delete-excluded --rsh=/usr/bin/ssh --exclude=".DS_Store" --exclude=".git"'
# fmdms.bash [ [~/target/localPath | sessionID] [remoteUser@remoteHost:remotePath]]

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
source "${LIBPATH}/colors.bash"
source "${LIBPATH}/fileio.bash"
source "${LIBPATH}/time.bash"
################################################################################

# TODO: multiple destinations
# TODO: reverse synchronization with persistent tunnels
# TODO: synchronization of different files from different locations all together and using delta/patch for quicker throughput

#------------------------------ Functions

function question_source() {

	if [ ! -d "$ansrSrc" ] && [ -z "$sessionId" ]; then

		ansrSrc=`qa_with_def "Source" "$qstnSrc"`

		if [ "${ansrSrc:0:1}" == '.' ]; then
			ansrSrc="$( cd "$(dirname "$ansrSrc")/$ansrSrc" ; pwd -P )"

		elif [ "${ansrSrc:0:1}" == '~' ]; then
			ansrSrc="${meMyselfIpath}/${ansrSrc:1}"

		fi

	fi

	echo `real_dir "$ansrSrc"`

} # END FUNCTION: question_source

function question_destination() {

	#----- Variables
	local testUser=''
	local testHost=''
	local testPath=''
	local ret=`validateUserHost "$ansrDestStr"`
	#-----/Variables

	# No User
	if [ -z "$ansrUser" ]; then
		ret=`qa_with_def "Destination user, server, and path" "${qstnUser}@${qstnSrvr}:${qstnDest}"`
	fi

	# No Path
	if [ ! -z `validateUserHost "$ret"` ] && [ -z `parseUserHost "$ret" path` ]; then

		testUser=`parseUserHost "$ret" user`
		testHost=`parseUserHost "$ret" host`

		testPath=`qa_with_def "Destination path for $(validateUserHost "$ret")" "$qstnDest"`

		ret="${testUser}@${testHost}:${testPath}"
		unset testPath

	fi

	echo `validateUserHost "$ret"`

} # END FUNCTION: question_destination

function question_rsyncopts() {

	#----- Variables
	local ret="$ansrRsyncMain"
	#-----/Variables

	if [ -z "$ret" ]; then
		ret=`qa_with_def "Rsync Main Options" "$qstnRsyncMain"`
	fi
	
	echo "$ret"
	
} # END FUNCTION: question_rsyncopts

function question_rsyncextra() {

	#----- Variables
	local ret="$ansrRsyncExtra"
	#-----/Variables

	if [ -z "$ret" ]; then
		ret=`qa_with_def "Rsync Extra Options" "$qstnRsyncExtra"`
	fi
	
	echo "$ret"
	
} # END FUNCTION: question_rsyncextra

#------------------------------/Functions

#------------------------------ Variables
# Last X seconds of files to watch for modifications at levels: modification, active differences, and routine directory checking
: ${FMDMSDIFFMTIME:=5}
: ${FMDMSDIFFSETTLETIME:=5}
: ${FMDMSDIFFLSTIME:=60}
: ${FMDMSRSYNCARGS:=''}

# Who am I?
meMyselfI=`whoami`
meMyselfIpath="$(eval echo "~$meMyselfI")"

# rsync
RSYNCCMD=`which rsync`

# GGCom Path
GGCOMPATH="$meMyselfIpath/ggcom"

# FMDMS Sessions
GGCOMSESSIONS="$GGCOMPATH/sessions"

# Source user+loc hash (for recalling and resuming from GGCOM preferences)
HASHSRC=''

#------------------------------ Session File / Local Source / Input from argv[1]

sessionId=''
sessionFile=''

qstnSrc=''
ansrSrc=''

# Valid Session
if [ ! -z "$1" ] && [ -f "$GGCOMSESSIONS/$1" ]; then

	sessionId="$1"
	sessionFile="$GGCOMSESSIONS/$sessionId"

	# If valid session, but source is changed
	qstnSrc=`mod_trail_slash add "$( pwd -P )"`

# Valid Source
elif [ ! -z "$1" ] && [ -d "$1" ]; then

	qstnSrc="$1"
	qstnSrc=`mod_trail_slash add "$( real_dir "$qstnSrc" )"`
#	qstnSrc=`mod_trail_slash add "$qstnSrc"`
	ansrSrc="$qstnSrc"

# Guess at Source
else

	qstnSrc=`mod_trail_slash add "$( pwd -P )"`

fi

#------------------------------/Session File / Local Source / Input from argv[1]

#------------------------------ Remote user@host:~/path

# Valid Destination String? (user@host[:~/path/here])
[[ ! -z "`validateUserHost "$2"`" ]] && qstnDestStr="`validateUserHost "$2"`" || qstnDestStr=''
ansrDestStr="$qstnDestStr"

# Destination User
qstnUser="$meMyselfI"
ansrUser=`parseUserHost "$ansrDestStr" user`

# Destination Server
qstnSrvr='localhost'
ansrSrvr=`parseUserHost "$ansrDestStr" host`

# Destination Path
qstnDest='' # Set below, after "Question: Source" is answered
ansrDest=`parseUserHost "$ansrDestStr" path`

#------------------------------/Remote user@host:~/path

#------------------------------ Rsync Options

qstnRsyncMain='--archive --verbose --progress --partial --delete --delete-excluded --rsh=/usr/bin/ssh'
ansrRsyncMain="$FMDMSRSYNCARGS"

qstnRsyncExtra=''
ansrRsyncExtra=''

#------------------------------/Rsync Options

#------------------------------/Variables

#----- NOTICE: INFO
echo `str_repeat - 80`
echo "`getVersion $0 header`"
echo `str_repeat - 80`

if [ -z "$sessionId" ]; then
	echo -e "You can modify times, example: ${ggcLightCyan}export FMDMSDIFFMTIME=5 FMDMSDIFFSETTLETIME=2 FMDMSDIFFLSTIME=10${ggcNC}"
	echo -e "You can load Rsync arguments, example: ${ggcLightCyan}export FMDMSRSYNCARGS='${qstnRsyncMain} --exclude=\".DS_Store\" --exclude=\".git\"'${ggcNC}"
	echo `str_repeat - 80`
fi

echo;
#-----/NOTICE: INFO

#----- Attempt to restore session
if [ ! -z "$sessionId" ]; then

	echo -e "${ggcLightBlue}Restoring session '${ggcNC}${ggcLightPurple}${sessionId}${ggcNC}${ggcLightBlue}'${ggcNC}"

	echo -e "${ggcLightCyan}$sessionFile${ggcNC}"

	echo `str_repeat - 40`
	echo -e "${ggcLightGreen}`cat "$sessionFile"`${ggcNC}"
	echo `str_repeat - 40`

	source "$sessionFile"
	ansrDestStr="${ansrUser}@${ansrSrvr}:${ansrDest}"

	echo `str_repeat - 80`

fi
#-----/Attempt to restore session

#------------------------------ Startup Questions

#--------------- Question: Source
#: <<'END'
while :
do
	if [ -d "$ansrSrc" ]; then
		echo -e "${ggcLightGreen}Source: $ansrSrc${ggcNC}"
		break

	else
		ansrSrc=`question_source`
		if [ -z "$ansrSrc" ]; then
			echo -e "${ggcLightRed}Invalid path.${ggcNC}";
			if [ ! -z "$sessionId" ]; then
				sessionId=''
			fi
		fi

	fi
done
#END
#---------------/Question: Source

#--------------- Question: Destination
qstnDest="~/tmp/`isolate_dir_name "$ansrSrc"`" # was set above & using qstnSrc

#: <<'END'
while :
do
	if [ ! -z "$ansrUser" ] && [ ! -z "$ansrSrvr" ] && [ ! -z "$ansrDest" ] && [ ! -z `validateUserHost "${ansrUser}@${ansrSrvr}:${ansrDest}"` ]; then
		echo -e "${ggcLightGreen}Destination: $ansrDestStr${ggcNC}"
		break
	else
		ansrDestStr=`question_destination`
		ansrUser=`parseUserHost "$ansrDestStr" user`
		ansrSrvr=`parseUserHost "$ansrDestStr" host`
		ansrDest=`parseUserHost "$ansrDestStr" path`
		if [ -z "$ansrDestStr" ]; then
			echo -e "${ggcLightRed}Invalid destination.${ggcNC}";
		fi
	fi
done
#END
#---------------/Question: Destination

#--------------- Question: Rsync Main Options
while :
do
	if [ ! -z "$ansrRsyncMain" ]; then
		echo -e "${ggcLightGreen}${ansrRsyncMain} ${ansrRsyncExtra}${ggcNC}"
		break
	else
		ansrRsyncMain=`question_rsyncopts`

		#--------------- Question: Rsync Extra Options
		echo;
		echo "Additional Rsync options can aid for deeper synchronization efforts, examples:"
		echo -e "* If you're synchronizing rsnapshot, you'll want to add '${ggcLightCyan}--hard-links${ggcNC}'"
		echo -e "* Exclude temporary files and OSX-specific files? Add ${ggcLightCyan}--exclude=\"*~\" --exclude=\".DS_Store\" --exclude=\".git\"${ggcNC}"
		echo;
		ansrRsyncExtra=`question_rsyncextra`
		#---------------/Question: Rsync Extra Options
	fi
done
#---------------/Question: Rsync Main Options

#------------------------------/Startup Questions

#----- Save Session File
if [ -z "$sessionId" ]; then
	mkdir -pv "$GGCOMSESSIONS"

	echo;

	# MD5 hash of SOURCE:USER@SERVER:REMOTEPATH
	HASHSRC=`qa_with_def "Session file name" "$( cryptoHashCalc sha1 string "FMDMS:$SCRIPTPATH:$SCRIPTNAME:$ansrSrc:$ansrUser@$ansrSrvr:$ansrDest:'$ansrRsyncMain':'$ansrRsyncExtra'" )"`

cat <<!FMDMSSESSION > "$GGCOMSESSIONS/$HASHSRC"
export FMDMSDIFFMTIME=$FMDMSDIFFMTIME
export FMDMSDIFFSETTLETIME=$FMDMSDIFFSETTLETIME
export FMDMSDIFFLSTIME=$FMDMSDIFFLSTIME

ansrRsyncMain="$ansrRsyncMain"
ansrRsyncExtra='$ansrRsyncExtra'

ansrSrc="$ansrSrc"
ansrUser="$ansrUser"
ansrSrvr="$ansrSrvr"
ansrDest="$ansrDest"
!FMDMSSESSION

	echo;
	echo -e "${ggcLightGreen}Session file saved to:${ggcNC}"
	echo -e "${GGCOMSESSIONS}/${HASHSRC}"
fi
#-----/Save Session File

# Session Resume Notice
if [ -z "$sessionId" ]; then
	echo;
	echo -e "${ggcLightBlue}This session can be restarted with:${ggcNC}";
	echo -e "${ggcLightCyan}$SCRIPTNAME${ggcNC} ${ggcLightPurple}$HASHSRC${ggcNC}"
fi

#----- Test remote connection
if [ "$ansrSrvr" != 'localhost' ]; then

	echo -n "Testing connection... "
	echo "(if asked for a password, use ggcom-bash-utils/bootstrapRsaAuth.bash to resolve this)"
	echo `str_repeat - 80`

	REMWHOAMIERR=`mktemp 2>/dev/null || mktemp -t 'fmdms'`
	REMWHOAMI=`ssh $ansrUser@$ansrSrvr "whoami" 2>"$REMWHOAMIERR"`

	if [ "$REMWHOAMI" == "$ansrUser" ]; then
		echo "Connection successful."

	else
		echo -e "${ggcLightRed}ERROR: `cat "$REMWHOAMIERR"`${ggcNC}" >&2
		echo -e "${ggcLightRed}Remote user failure ($ansrUser@$ansrSrvr): received '$REMWHOAMI', but was expecting '$ansrUser'.  Exiting.${ggcNC}" >&2
		rm -rf $REMWHOAMIERR
		exit 1;

	fi

	unset REMWHOAMI
	rm -rf $REMWHOAMIERR
	echo `str_repeat - 80`

fi
#-----/Test remote connection

#----- Setup destination directory
ansrDestFull=`userDestPath "$ansrDestStr"`

echo -n "Setting up destination directory ('$ansrDestFull') for receiving... "

qstnDestDIRSETUP="mkdir -pv $ansrDestFull"

# Local Host
if [ "$ansrSrvr" == 'localhost' ]; then

	# me@localhost
	if [ "$ansrUser" == "$meMyselfI" ]; then
		if [ -z "$(eval $qstnDestDIRSETUP)" ]; then echo "setup."; else echo "finished."; fi

	# other@localhost
	else
		echo "(activating sudo) ";
		if [ "$(eval sudo -u "$ansrUser" whoami 2>/dev/null)" != "$ansrUser" ]; then
			echo -e "${ggcLightRed}ERROR: Failed to procure sudo rights.  Exiting.${ggcNC}" >&2
			exit 1
		fi
		if [ -z "$(eval sudo -u $ansrUser -H bash -c "'$qstnDestDIRSETUP'")" ]; then echo "setup."; else echo "finished."; fi

	fi

# Remote Host
else
	if [ -z "$(eval ssh "$ansrUser@$ansrSrvr" "'$qstnDestDIRSETUP'")" ]; then echo "setup."; else echo "finished."; fi
fi

unset qstnDestDIRSETUP
#-----/Setup destination directory

#----- Execution Command
# Rsync Options
ROPTS="$ansrRsyncMain"
if [ ! -z "$ansrRsyncExtra" ]; then ROPTS="$ROPTS $ansrRsyncExtra"; fi

# Local host
if [ "$ansrSrvr" == 'localhost' ]; then

	# me@localhost
	FULLCMD="$RSYNCCMD $ROPTS '$( mod_trail_slash add "$ansrSrc" )' '$( mod_trail_slash add "$ansrDestFull" )'";

	# other@localhost
	if [ "$ansrUser" != "$meMyselfI" ]; then FULLCMD="(sudo $FULLCMD; sudo chown -R $ansrUser: '$ansrDestFull')"; fi

# Remote Host
else
	FULLCMD="$RSYNCCMD $ROPTS '$( mod_trail_slash add "$ansrSrc" )' $ansrUser@$ansrSrvr:'$( mod_trail_slash add "$ansrDestFull" )'";

fi

unset ROPTS
#-----/Execution Command

#------------------------------ Initial Sync
echo "Activating logging:"
TMPCHECKLOG=`mktemp 2>/dev/null || mktemp -t 'fmdms'`
TMPCHECKERR=`mktemp 2>/dev/null || mktemp -t 'fmdms'`

echo "Operations : $TMPCHECKLOG"
echo "Errors     : $TMPCHECKERR"

echo `str_repeat - 80`

echo -e "${ggcBrownOrange}$FULLCMD 1>$TMPCHECKLOG 2>$TMPCHECKERR${ggcNC}";

echo `str_repeat - 80`

echo -e "`iso8601 LightCyan`: Initial synchronization started: ${ggcLightPurple}$meMyselfI@localhost${ggcNC} ${ggcLightRed}=>${ggcNC} ${ggcLightBlue}$ansrUser@$ansrSrvr${ggcNC}"

eval "$FULLCMD 1>$TMPCHECKLOG 2>$TMPCHECKERR";

if [ ! -z "$(cat $TMPCHECKERR)" ]; then echo -e "${ggcLightRed}ERROR: A critical error has occurred with synchronization and has been logged ($TMPCHECKERR).  Exiting.${ggcNC}" >&2; exit 1; fi

echo -e "`iso8601 LightCyan`: Initial synchronization finished."
#------------------------------/Initial Sync

#----- Constant Sync
echo -e "`iso8601 LightCyan`: Starting constant synchronization, press 'q' to exit."
echo;

LSCNT=0
LSNEW=`cryptoHashCalc md5 string "$(ls -laR "$ansrSrc")"`
LSOLD=$LSNEW
TRIGGERSYNC=false
DIFF=$FMDMSDIFFMTIME

while :; do
	START=$(date +%s)

	# Hash of entire directory (for detecting deleted files)
	if [ "$LSCNT" -ge "$FMDMSDIFFLSTIME" ]; then
		LSCNT=0
		LSNEW=`cryptoHashCalc md5 string "$(ls -laR "$ansrSrc")"`
		if [ "$LSNEW" != "$LSOLD" ]; then TRIGGERSYNC=true; fi
		LSOLD=$LSNEW
	fi

	# Changes within DIFF seconds have occurred.
	TMPCHANGES=`find "$ansrSrc" -type f -mtime -"$DIFF"s`
	if [ ! -z "$TMPCHANGES" ] || [ "$TRIGGERSYNC" == true ]; then

		TRIGGERSYNC=false

		# Pause until all saves have completed
		echo -e "`iso8601 LightCyan`: There is a disturbance in the Force..."
		while :; do

			echo -e -n "`iso8601 LightCyan`: Checking in with Obi-Wan for an assessment..."

			# Freeze snapshot of entire directory
			TMPLSFRZ=`cryptoHashCalc md5 string "$(ls -laR "$ansrSrc")"`

			# Sleep
			sleep $FMDMSDIFFSETTLETIME

			# Current snapshot of entire directory
			TMPLSNOW=`cryptoHashCalc md5 string "$(ls -laR "$ansrSrc")"`

			# Determine if identical or different
			if [ "$TMPLSFRZ" == "$TMPLSNOW" ]; then echo; break; else echo " Have patience, Luke.  Changes are still occurring."; fi

		done # END WHILE LOOP
		unset TMPLSFRZ TMPLSNOW

		# List detected files and commence synchronization
		echo -e "`iso8601 LightCyan`: Force activity has subsided:"
		echo '----------'
		if [ -z "$TMPCHANGES" ]; then
			echo '"I felt a great disturbance in the Force, as if millions of voices suddenly cried out in terror and were suddenly silenced.  I fear something terrible has happened."  -Ben Obi-Wan Kenobi'
			echo "(no modification times were registered, but items were deleted/moved)"
		else
			echo "$TMPCHANGES"
		fi
		echo '----------'

		eval "$FULLCMD 1>$TMPCHECKLOG 2>$TMPCHECKERR";
		if [ ! -z "$(cat $TMPCHECKERR)" ]; then echo -e "${ggcLightRed}ERROR: A critical error has occurred with synchronization and has been logged ($TMPCHECKERR).  Exiting.${ggcNC}" >&2; exit 1; fi

		# Update hash of directory listing
		LSNEW=`cryptoHashCalc md5 string "$(ls -laR "$ansrSrc")"`
		LSOLD=$LSNEW
		
		# Reset check count
		LSCNT=0

		# Finished period from START (beginning of entire loop) for detecting files modified within range, and grace period.
		END=$(date +%s)
		DIFF=$(echo "$END - $START" | bc)

		echo -e "`iso8601 LightCyan`: Synchronization completed after $DIFF seconds."

		# Add grace period
		if [ $DIFF -lt $FMDMSDIFFMTIME ]; then sleep $(( FMDMSDIFFMTIME - DIFF )); fi # Temporary bug fix for dealing with .DS_Store
#		DIFF=$(( DIFF + FMDMSDIFFMTIME )) # Bug: Too wonky with .DS_Store updating during this process, thus causing vicious looping.
		DIFF=$FMDMSDIFFMTIME

	# Otherwise back to checking files' modification time of last X seconds
	else

		DIFF=$FMDMSDIFFMTIME

	fi
	#/Changes within DIFF seconds have occurred.

	# 1 second delay in loop until next check, with the option to quit
	LSCNT=$(( LSCNT + 1 ))
	read -t 1 -n1 -r QUITCMD
	if [[ `echo ${QUITCMD:0:1} | tr '[:upper:]' '[:lower:]'` == "q" ]]; then
		echo;
		echo -e "`iso8601 LightCyan`: Exit request acknowledged.";
		echo -e "`iso8601 LightCyan`: Removing log files:"
		rm -rfv $TMPCHECKLOG $TMPCHECKERR
		echo -e "`iso8601 LightCyan`: Exit completed.";
		exit 0;
	fi

done
#-----/Constant Sync
