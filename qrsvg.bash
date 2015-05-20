#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Utils - Encode QR to SVG v201505201148
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/qrsvg

Example usage:

Write QR code that displays 'Hello, world!'
$] qrsvg.bash hello.svg 'Hello, world!'

Convert QR code in SVG format to 480x480 PNG with 300 DPI
$] convert -units PixelsPerInch hello.svg -resample 300 -resize 480x480 hello.png

Read QR code from an image
$] zbarimg hello.png

Thanks:

How would you like to design a bitcoin banknote?
https://bitcointalk.org/index.php?topic=92969.545

Convert PNG to SVG - Stack Overflow
http://stackoverflow.com/questions/1861382/convert-png-to-svg

linux - "Bake" an SVG image into a PNG at a given resolution? - Super User
http://superuser.com/questions/516095/bake-an-svg-image-into-a-png-at-a-given-resolution

convert image 75 dpi to 300 dpi - ImageMagick
http://www.imagemagick.org/discourse-server/viewtopic.php?t=18241

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

#------------------------------ NOTICE: INFO
echo `str_repeat - 80`
echo "`getVersion "$0" header`"
echo `str_repeat - 80`
#------------------------------ /NOTICE: INFO

#------------------------------ Support Programs Exist?

hash qrencode 2>/dev/null || { echo -e "${ggcLightRed}qrencode is not installed.  Aborting.${ggcNC}" >&2; exit 1; }
hash convert 2>/dev/null || { echo -e "${ggcLightRed}convert is not installed.  Aborting.${ggcNC}" >&2; exit 1; }
hash potrace 2>/dev/null || { echo -e "${ggcLightRed}potrace is not installed.  Aborting.${ggcNC}" >&2; exit 1; }

#------------------------------/Support Programs Exist?

#------------------------------ Variables

fnameOutput="$1"
if [ -z "$fnameOutput" ]; then echo -e "${ggcLightRed}No output filename has been specified.  Exiting.${ggcNC}" >&2; exit 1; fi

qrMessage="${2-}"

#------------------------------/Variables

cmdRun="qrencode -s 20 -m 1 -l M -o - '"$qrMessage"' | convert -flatten - pbm:- | potrace --svg --output "$fnameOutput""
eval "$cmdRun"

echo -e "${ggcLightBlue}$fnameOutput${ggcNC}:"
echo;
echo -e "${ggcLightPurple}${qrMessage}${ggcNC}"

echo `str_repeat - 80`
