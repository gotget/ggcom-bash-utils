#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Disk Inventory v201504162001
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/diskInventory

Example usage:
diskInventory.bash /tmp 5

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

#----- NOTES
# https://www.google.com/search?q=%22du+-m%22+%2B+%22sort+-nr%22+%2B+%22head+-n%22&ie=utf-8&oe=utf-8
# http://superuser.com/questions/162749/how-to-get-the-summarized-sizes-of-folders-and-their-subfolders
# http://www.commandlinefu.com/commands/view/11079/find-biggest-10-files-in-current-and-subdirectories-and-sort-by-file-size
# https://github.com/kdeldycke/kevin-deldycke-blog/blob/master/content/posts/file-management-commands.md
#-----/NOTES

#----- NOTICE: INFO
echo "`getVersion $0 header`"
echo;
#-----/NOTICE: INFO

#----- CALCULATE
pathSelect=${1-./}
displayLimit=${2-20}

du -m $pathSelect | sort -nr | head -n $displayLimit
#-----/CALCULATE
