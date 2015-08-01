#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM Application Version Checker v201507120415
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/versions

Example usage:
ggcom-version.bash /usr/bin/dfwu.py

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
source "${LIBPATH}/colors.bash"
################################################################################

GGCOMAPP=${1-$0}
VERTYPE=${2-header}

# No such file
if [ ! -f $GGCOMAPP ]; then echo -e "${ggcLightRed}No such file ($GGCOMAPP).  Exiting.${ggcNC}" >&2; exit 1; fi

OUTPUT="`getVersion "$GGCOMAPP" "$VERTYPE"`"

# No version information found
if [ -z "${OUTPUT}" ]; then echo -e "${ggcLightRed}No version information found ($GGCOMAPP).  Exiting.${ggcNC}" >&2; exit 1; fi

echo "${OUTPUT}"
