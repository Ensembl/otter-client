# The installation script will append the proper values to these
# lines.  (It stops substituting at the first non-assignment code.)

version="109"
var=$PWD 
anasoft="${var}/../../../../../software/anacode" 
OTTER_HOME="${var}/../../../../../software/anacode/otter/otter_rel109" #Editing this line to call 109 version
otter_perl="/usr/bin"

if [ -z "$OTTER_HOME" ]
then
    echo "This script has been improperly installed!  Consult the developers!" >&2
    exit 1
fi

source "${OTTER_HOME}/bin/_otter_env_core.sh"
