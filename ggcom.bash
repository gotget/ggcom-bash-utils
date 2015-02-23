#!/usr/bin/env bash
################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
LIBPATH="$( cd "$(dirname "${SCRIPTPATH}/../../")" ; pwd -P )/ggcom-bash-library"
################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
################################################################################
source "${LIBPATH}/prompt.bash"
################################################################################
VERSION=201502230811
PROGTITLE="${SCRIPTNAME} (`printf "%x" ${VERSION}`-v${VERSION})"
################################################################################
echo "${PROGTITLE} |";
#echo "`updates_check ${PROGTITLE}`"
echo "`str_repeat - ${#PROGTITLE}`-+";
################################################################################

#----- FYI
echo;
echo "FYI: Right now, the only thing that this utility does is update.";
echo "`pauseret`";
#-----/FYI

#----- CREATE GGCOM UPDATER
TMPUPD=`mktemp /tmp/ggcom.XXXXXXXXX`
chmod 700 $TMPUPD
#-----/CREATE GGCOM UPDATER

#----- CREATE GGCOM MANIFEST
read -r -d '' UPDCMDS <<EOF

cd "${SCRIPTPATH}/"
echo -n "Updating : "
pwd
git pull

cd "${LIBPATH}/"
echo -n "Updating : "
pwd
git pull

echo

echo "[Removing GGCOM updater]"
rm -rfv "${TMPUPD}"

EOF
#-----/CREATE GGCOM MANIFEST

#----- WRITE GGCOM MANIFEST TO GGCOM UPDATER
echo "$UPDCMDS" > $TMPUPD
#-----/WRITE GGCOM MANIFEST TO GGCOM UPDATER

#----- RUN GGCOM UPDATER
echo "[Running GGCOM updater]"
eval $TMPUPD &
#-----/RUN GGCOM UPDATER
