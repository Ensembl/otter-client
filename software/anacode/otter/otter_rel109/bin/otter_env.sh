
# The installation script will append the proper values to these
# lines.  (It stops substituting at the first non-assignment code.)
#version="106.10"
#anasoft="/software/anacode"
#OTTER_HOME="/software/anacode/otter/otter_rel106.10"
#otter_perl="/software/perl-5.18.2/bin"
var=$PWD #edit 1-4
anasoft="${var}/../../../../../software/anacode" 
OTTER_HOME="${var}/../../../../../software/anacode/otter/otter_rel106.10"
otter_perl="${var}/../../../../../software/perl-5.18.2/bin"

if [ -z "$OTTER_HOME" ]
then
    echo "This script has been improperly installed!  Consult the developers!" >&2
    exit 1
fi

source "${OTTER_HOME}/bin/_otter_env_core.sh"
