# The guts of setting up the otter environment,
# usually called from otter_env.sh which will set:
#
# version
# anasoft
# OTTER_HOME
# otter_perl

# In a development environment, the caller can set:
# ENSEMBL_OTTER_DEV        to override the location of ensembl-otter.
# ENSEMBL_DEV              to override the location of all EnsEMBL packages.
# ANACODE_PERL_MODULES_DEV to override the location of PerlModules.
# OTTER_LIB_PERL5_DEV      to override the location of other perl modules (Zircon).

# check that the installation script has set things up
if [ -z "$version" ] || [ -z "$otter_perl" ]
then
    echo "This script has been improperly installed!  Consult the developers!" >&2
    exit 1
fi

if [ -z "$OTTER_HOME" ]
then
    echo "OTTER_HOME not set. Script improperly installed." >&2
    exit 1
fi

if [ "$otter_perl" = 'perl_is_bundled' ] || [ -x "$otter_perl/perl" ]; then
    # ok
    :
else
    echo "Cannot find Perl at otter_perl=$otter_perl" >&2
    exit 1
fi

echo "perl loc= $otter_perl"


export OTTER_HOME
var=$PWD #edit 1
LD_LIBRARY_PATH=${var}/../../../../../software/anacode/distro/trusty/lib #edit 2
#LD_LIBRARY_PATH=/software/anacode/distro/trusty/lib
export LD_LIBRARY_PATH


# Settings for wublast needed by local blast searches
WUBLASTFILTER=$anasoft/bin/wublast/filter
export WUBLASTFILTER
WUBLASTMAT=$anasoft/bin/wublast/matrix
export WUBLASTMAT

# Some setup for acedb
ACEDB_NO_BANNER=1
export ACEDB_NO_BANNER

#cp -f "$OTTER_HOME/acedbrc" ~/.acedbrc

if [ -n "$ENSEMBL_OTTER_DEV" ]
then
    echo "  DEVEL override for ensembl-otter=        $ENSEMBL_OTTER_DEV"
    ensembl_otter_home="$ENSEMBL_OTTER_DEV"
    ensembl_otter_path="$ENSEMBL_OTTER_DEV/scripts/client"
fi
: ${ensembl_otter_home:=$OTTER_HOME/ensembl-otter}

if [ -n "$ENSEMBL_DEV" ]
then
    echo "  DEVEL override for all EnsEMBL=          $ENSEMBL_DEV"
    ensembl_home="$ENSEMBL_DEV"
fi
: ${ensembl_home:=$OTTER_HOME}

if [ -n "$ANACODE_PERL_MODULES_DEV" ]
then
    echo "  DEVEL override for Anacode Perl Modules= $ANACODE_PERL_MODULES_DEV"
    anacode_perl_modules="$ANACODE_PERL_MODULES_DEV"
fi
: ${anacode_perl_modules:=$OTTER_HOME/PerlModules}

if [ -n "$OTTER_LIB_PERL5_DEV" ]
then
    echo "  DEVEL override for Otter Perl Modules=   $OTTER_LIB_PERL5_DEV"
    otter_lib_perl5="$OTTER_LIB_PERL5_DEV"
fi
: ${otter_lib_perl5:=$OTTER_HOME/lib/perl5}

PERL5LIB="\
$OTTER_HOME/PerlModules:\
$anacode_perl_modules:\
$ensembl_otter_home/modules:\
$ensembl_home/ensembl/modules:\
$otter_lib_perl5:\
$ensembl_otter_home/tk:\
${PERL5LIB:+:${PERL5LIB}}"
#Edit 3-4 /usr/local/lib/perl5/5.18.2:\
#/usr/local/lib/perl5/5.18.2/x86_64-linux\
#/usr/lib/x86_64-linux-gnu/perl/5.22/:\
#home/smm/.cpanm/work/1531750455.13341/Crypt-JWT-0.022/lib/Crypt$:\
#/home/smm/.cpanm/work/1531750455.13341/CryptX-0.061/lib/:\

osname="$( uname -s )"

case "$osname" in
    Darwin)
        anasoft_distro=
        otter_perl=
        PERL5LIB="${PERL5LIB}:\
$anasoft/lib/site_perl:\
$anasoft/lib/perl5/site_perl:\
$anasoft/lib/perl5/vendor_perl:\
$anasoft/lib/perl5\
"
        if [ -z "$OTTER_MACOS" ]
        then
            source "$ensembl_otter_home/scripts/client/_otter_macos_env.sh"
        fi
        ;;

    *)
        distro_code="$( $anasoft/bin/anacode_distro_code )" || {
            echo "Failed to get $anasoft distribution type" >&2
            exit 1
        }
        anasoft_distro="$anasoft/distro/$distro_code"
        
        PERL5LIB="${PERL5LIB}:\
$anasoft_distro/lib:\
$anasoft_distro/lib/site_perl:\
${var}/../../../../../software/perl-5.18.2/lib:\
${var}/../../../../../software/perl-5.18.2/lib/site_perl:\
${var}/../../../../../software/perl-5.18.2/lib/site_perl\5.18.2\
"
#Edit 4-5
#Removed $anasoft/lib:\
#Removed $anasoft/lib/site_perl\
        ;;
esac

ensembl_otter_path="${ensembl_otter_path:+$ensembl_otter_path:}\
$OTTER_HOME/bin\
"

otterbin="\
$ensembl_otter_path:\
${anasoft_distro:+$anasoft_distro/bin:}\
$anasoft/bin:\
${otter_perl:+$otter_perl}:\
/software/pubseq/bin/EMBOSS-5.0.0/bin\
"
#EMBOSS-5.0.0 not available

#ZMAP_BIN=$ZMAP_BIN:~/usr/bin
if [ -n "$ZMAP_BIN" ]
then
    otterbin="$ZMAP_BIN:$otterbin"
    echo "  Hacked otterbin for ZMAP_BIN=$ZMAP_BIN" >&2
fi


if [ -n "$ZMAP_LIB" ]
then
    PERL5LIB="$ZMAP_LIB:$ZMAP_LIB/site_perl:$PERL5LIB"
    echo "  Hacked PERL5LIB for ZMAP_LIB=$ZMAP_LIB" >&2
fi

export PATH="$otterbin${PATH:+:$PATH}"
export PERL5LIB
echo $PATH
export ensembl_otter_home
unset ensembl_otter_path
unset otterbin
unset ensembl_home
