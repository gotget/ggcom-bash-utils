#!/usr/bin/env bash
#
# GGCOM - Bash - Utils - FMDMS (File Mtime Directory Md5 Synchronization) v201503010807
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/fmdms
#
# Example usage:
# fmdms.bash [~/target/path]

# TODO: source hash for resuming from GGCOM data directory (~/.ggcom/) that related GGCOM utilities/libraries use
# TODO: make $ arguments fully carry through for headless running
# TODO: ignore list (e.g. .DS_Store) and some additional features related to grep/pattern exclusion and rsync shenanigans

#----- Variables
# Last X seconds of files to watch for modifications
DIFFMTIME=10
DIFFLSTIME=60

# Local Source
TMPSRC="${1-`pwd -P`}"
INPSRC=''
if [ "${TMPSRC: -1}" != '/' ]; then TMPSRC="$TMPSRC/"; fi # Add trailing slash for TMPSRC

# Destination User
TMPRUSER=`whoami`
INPRUSER=''

# Source user+loc hash (for recalling and resuming from GGCOM preferences)
HASHSRC=''

# Destination Server
TMPRSERV='localhost'
INPRSERV=''

# Destination
TMPDEST='' # SET BELOW INP
INPDEST=''

# Hard Links? (e.g. useful for dealing with synchronizing rsnapshot's directory and preserving hard-link/inode references)
INPROPTHARD='' # SET BELOW
ROPTS='--archive --verbose --progress --partial --delete --rsh=/usr/bin/ssh'

# rsync
RSYNCCMD=`which rsync`

# openssl
OPENSSLBIN=''
OPENSSLEXIST='Y'
hash openssl 2>/dev/null || { OPENSSLEXIST='N'; }
if [ "$OPENSSLEXIST" == 'Y' ]; then OPENSSLBIN=`which openssl`; fi
unset OPENSSLEXIST
#-----/Variables

#----- NOTICE: FINISH
VERL=`head -n5 "$0" | grep -n 'v[0-9]' | cut -f1 -d:`
VERP=`tail -n+"$VERL" "$0" | head -n3`
echo "$VERP"
echo;
unset VERL VERP
#-----/NOTICE: FINISH

#----- Startup Questions
# Source directory
if [ -z $1 ]; then
	read -p "Source [$TMPSRC] : " INPSRC
	if [ -z "$INPSRC" ]; then
		INPSRC=$TMPSRC
	fi
else
	INPSRC=$TMPSRC
fi
if [ "${INPSRC:0:1}" == '.' ]; then
	INPSRC=$( cd "$(dirname "$INPSRC")" ; pwd -P )
fi

# Check directory existence
if [ ! -d "$INPSRC" ]; then
	echo "Invalid source directory ($INPSRC).  Exiting." >&2
	exit 1;
fi

# Source user+loc hash
if [ ! -z "$OPENSSLBIN" ]; then HASHSRC=`echo -n "$TMPRUSER:$INPSRC" | $OPENSSLBIN md5`; fi
# read: do you want to resume your last session?

# Destination User
read -p "Destination User [$TMPRUSER] : " INPRUSER
if [ -z "$INPRUSER" ]; then
	INPRUSER=$TMPRUSER
fi

# Destination Server
read -p "Destination Server [$TMPRSERV] : " INPRSERV
if [ -z "$INPRSERV" ]; then
	INPRSERV=$TMPRSERV
fi

# Test remote connection
if [ "$INPRSERV" != 'localhost' ]; then
	echo -n "Testing connection... "
	echo "(if asked for a password, use ggcom-bash-utils/bootstrapRsaAuth.bash to resolve this)"
	echo '----------'
	REMWHOAMI=`eval ssh $INPRUSER@$INPRSERV "whoami" 2>/dev/null`
	if [ "$REMWHOAMI" != "$INPRUSER" ]; then
		echo "Remote user failure: received '$REMWHOAMI', but was expecting '$INPRUSER'.  Exiting." >&2
		exit 1;
	else
		echo "Connection successful."
	fi
	unset REMWHOAMI
	echo '----------'
fi

# Strip trailing slash for INPSRC (to build TMPDEST)
if [ "${INPSRC: -1}" == '/' ]; then INPSRC="${INPSRC%?}"; fi

# Try and guess at proper destination location
if [ "$INPRSERV" == 'localhost' ]; then
	TMPDEST="`eval echo ~$INPRUSER`/tmp/${INPSRC##*/}"
else
	TMPDEST="~/tmp/${INPSRC##*/}"
fi

# Re-add trailing slash to INPSRC
INPSRC="$INPSRC/"

# Add trailing slash to TMPDEST
TMPDEST="$TMPDEST/"

# Destination
read -p "Destination Directory [$TMPDEST] : " INPDEST
if [ -z "$INPDEST" ]; then
	INPDEST=$TMPDEST
else
	# Add slash if not there
	if [ "${INPDEST: -1}" != '/' ]; then INPDEST="$INPDEST/"; fi
fi

# Setup destination directory
echo -n "Setting up destination directory ('$INPDEST') for receiving... "
TMPDESTDIRSETUP="mkdir -pv $INPDEST"
# localhost
if [ "$INPRSERV" == 'localhost' ]; then
	# Same user
	if [ "$INPRUSER" == `whoami` ]; then
		if [ -z "$(eval $TMPDESTDIRSETUP)" ]; then echo "setup."; else echo "finished."; fi
	# Different user
	else
		echo "(activating sudo) ";
		if [ "$(eval sudo -u $INPRUSER whoami 2>/dev/null)" != "$INPRUSER" ]; then
			echo "Failed to procure sudo rights.  Exiting." >&2
			exit 1
		fi
		if [ -z "$(eval sudo -u $INPRUSER $TMPDESTDIRSETUP)" ]; then echo "setup."; else echo "finished."; fi
	fi
# remote host
else
	if [ -z "$(eval ssh $INPRUSER@$INPRSERV '$TMPDESTDIRSETUP')" ]; then echo "setup."; else echo "finished."; fi
fi
unset TMPDESTDIRSETUP

# Hard links
read -n1 -r -p "Mind the hard-links (eg for rsnapshot)? [n] " INPROPTHARD
if [[ `echo ${INPROPTHARD:0:1} | tr '[:upper:]' '[:lower:]'` == "y" ]]; then
	ROPTS="$ROPTS --hard-links"
fi
echo; # newline for read's single-character grab
#-----/Startup Questions

#----- Execution
if [ "$INPRSERV" == 'localhost' ]; then
	FULLCMD="$RSYNCCMD $ROPTS '$INPSRC' '$INPDEST'";
	if [ "$INPRUSER" != `whoami` ]; then FULLCMD="(sudo $FULLCMD; sudo chown -R $INPRUSER: '$INPDEST')"; fi
else
	FULLCMD="$RSYNCCMD $ROPTS '$INPSRC' $INPRUSER@$INPRSERV:'$INPDEST'";
fi
#-----/Execution

#----- Initial Sync
echo "Activating logging:"
TMPCHECKLOG=`mktemp 2>/dev/null || mktemp -t 'sync'`
TMPCHECKERR=`mktemp 2>/dev/null || mktemp -t 'sync'`
echo "Operations : $TMPCHECKLOG"
echo "Errors     : $TMPCHECKERR"
echo;
echo "`date +\"%Y-%m-%d %H:%M:%S\"`: Initial synchronization started."
eval "$FULLCMD 1>$TMPCHECKLOG 2>$TMPCHECKERR";
if [ ! -z "$(cat $TMPCHECKERR)" ]; then echo "A critical error has occurred with synchronization.  Exiting." >&2; exit 1; fi
echo "`date +\"%Y-%m-%d %H:%M:%S\"`: Initial synchronization finished."
#-----/Initial Sync

#----- Constant Sync
echo "`date +\"%Y-%m-%d %H:%M:%S\"`: Starting constant synchronization, press 'q' to exit."
echo;

LSCNT=0
if [ ! -z "$OPENSSLBIN" ]; then LSNEW=`ls -laR "$INPSRC" | "$OPENSSLBIN" md5`; else LSNEW=''; fi
LSOLD=$LSNEW
TRIGGERSYNC=false
DIFF=$DIFFMTIME

while :; do
	START=$(date +%s)

	# Hash of entire directory (for detecting deleted files)
	if [ "$LSCNT" == "$DIFFLSTIME" ]; then
		LSCNT=0
		if [ ! -z "$OPENSSLBIN" ]; then
			LSNEW=`ls -laR "$INPSRC" | "$OPENSSLBIN" md5`
			if [ "$LSNEW" != "$LSOLD" ]; then TRIGGERSYNC=true; fi
			LSOLD=$LSNEW
		fi
	fi

	# Changes within DIFF seconds have occurred.
	TMPCHANGES=`find "$INPSRC" -type f -mtime -"$DIFF"s`
	if [ ! -z "$TMPCHANGES" ] || [ "$TRIGGERSYNC" == true ]; then

		TRIGGERSYNC=false

		# Pause until all saves have completed
		echo "`date +\"%Y-%m-%d %H:%M:%S\"`: There is a disturbance in the Force..."
		while :; do
			echo -n "`date +\"%Y-%m-%d %H:%M:%S\"`: Checking in with Obi-Wan for an assessment..."
			TMPLSFRZ=`ls -la "$INPSRC"`
			sleep $DIFFMTIME
			TMPLSNOW=`ls -la "$INPSRC"`
			if [ -z "$(diff <(echo "$TMPLSFRZ") <(echo "$TMPLSNOW"))" ]; then echo; break; else echo " Have patience, Luke.  Changes are still occurring."; fi
		done
		unset TMPLSFRZ TMPLSNOW

		# List detected files and commence synchronization
		echo "`date +\"%Y-%m-%d %H:%M:%S\"`: Force activity has subsided:"
		echo '----------'
		if [ -z "$TMPCHANGES" ]; then
			echo '"I felt a great disturbance in the Force, as if millions of voices suddenly cried out in terror and were suddenly silenced.  I fear something terrible has happened."  -Ben Obi-Wan Kenobi'
			echo "(no modification times were registered, but items were deleted/moved)"
		else
			echo "$TMPCHANGES"
		fi
		echo '----------'

		eval "$FULLCMD 1>$TMPCHECKLOG 2>$TMPCHECKERR";
		if [ ! -z "$(cat $TMPCHECKERR)" ]; then echo "A critical error has occurred with synchronization.  Exiting." >&2; exit 1; fi

		# Update hash of directory listing and reset check count
		if [ ! -z "$OPENSSLBIN" ]; then
			LSNEW=`ls -laR "$INPSRC" | "$OPENSSLBIN" md5`
			LSOLD=$LSNEW
		fi
		LSCNT=0

		# Finished period from START (beginning of entire loop) for detecting files modified within range, and grace period.
		END=$(date +%s)
		DIFF=$(echo "$END - $START" | bc)

		echo "`date +\"%Y-%m-%d %H:%M:%S\"`: Synchronization completed after $DIFF seconds."

		# Add grace period
		if [ $DIFF -lt $DIFFMTIME ]; then sleep $(( DIFFMTIME - DIFF )); fi # Temporary bug fix for dealing with .DS_Store
#		DIFF=$(( DIFF + DIFFMTIME )) # Bug: Too wonky with .DS_Store updating during this process, thus causing vicious looping.
		DIFF=$DIFFMTIME

	# Otherwise back to checking files' modification time of last X seconds
	else

		DIFF=$DIFFMTIME

	fi
	#/Changes within DIFF seconds have occurred.

	# 1 second delay in loop until next check, with the option to quit
	LSCNT=$(( LSCNT + 1 ))
	read -t 1 -n1 -r QUITCMD
	if [[ `echo ${QUITCMD:0:1} | tr '[:upper:]' '[:lower:]'` == "q" ]]; then
		echo;
		echo "Exit request acknowledged.";
		echo "Removing log files:"
		rm -rfv $TMPCHECKLOG $TMPCHECKERR
		echo "Exit completed.";
		exit 0;
	fi

done
#-----/Constant Sync
