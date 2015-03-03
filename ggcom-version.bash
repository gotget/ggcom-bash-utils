#!/usr/bin/env bash
#
# GGCOM Application Version Checker v201502250329
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/versions
#
# Example usage:
# ggcom-version.bash /usr/bin/dfwu.py

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

GGCOMAPP=${1-$0}
VERTYPE=${2-header}

# No such file
if [ ! -f $GGCOMAPP ]; then echo "No such file ($GGCOMAPP).  Exiting." >&2; exit 1; fi

echo "`getVersion "$GGCOMAPP" "$VERTYPE"`"
