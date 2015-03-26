# /etc/csh.login

setenv SFLM_SERVER innersanctum
setenv CDS_LIC_FILE 5280@innersanctum.engr.sjsu.edu:/apps/cadence/license-current
setenv CDSLMD_LICENSE_FILE 5280@innersanctum.engr.sjsu.edu:/apps/cadence/license-current
setenv LM_LICENSE_FILE 27000@innersanctum.engr.sjsu.edu:/apps/synopsys/license/current-license-key:27001@innersanctum.engr.sjsu.edu
setenv SNPSLMS_LICENSE_FILE 27000@innersanctum.engr.sjsu.edu:/apps/synopsys/license/current-license-key
setenv STROOT /apps/synopsys/TCAD
setenv STRELEASE current
setenv ISEROOT /apps/synopsys/TCAD/
setenv STDB ${HOME}/sentaurus



alias h history
alias dump 'find . -name core -print'
alias l 'ls -lFt'
alias atlas 'atlas -V 5.15.8.C' #11/21/08  Nick T

#  XTERM STUFF
    alias xt "xterm -bg gold -fg black &"
    alias con 'xterm -g 98x6+0+0 -fg lightgreen -bg black -title CONSOLE -sb -sl 15000 -C'
    alias xt1 'xterm -g 80x43+0+200 -fg cyan -bg black -title TERMINAL1  -cr pink -sb -sl 30000 -n TERMINAL1'
    alias xt2 'xterm -g 80x43+0+119 -fg green -bg darkslategrey -title TERMINAL2 -cr wheat -sb -sl 30000 -n TERMINAL2'
    alias xt4 'xterm -g 80x43+0+119 -fg white -bg darkgreen -title TERMINAL3 -cr lightgreen -sb -sl 30000 -n TERMINAL3'
    alias xt5 'xterm -g 80x43+0+119 -fg green -bg darkgreen -title TERMINAL4 -cr lightgreen -sb -sl 30000 -n TERMINAL4'
    alias xt3 'xterm -g 80x43+0+100 -fg purple -bg wheat -title TERMINAL5 -cr wheat -sb -sl 50000 -n TERMINAL5'

 
alias prepend 'if (-d \!:2) if ("$\!:1" \!~ *"\!:2"*) setenv \!:1 "\!:2":${\!:1}'
alias extend  'if (-d \!:2) if ("$\!:1" \!~ *"\!:2"*) setenv \!:1 ${\!:1}:\!:2'


setenv SYNOPSYS /apps/synopsys
setenv PRIMETIME_ROOT $SYNOPSYS/pt2000.11
setenv SYNOPSYS_SIM $SYNOPSYS/2000.12
setenv CLS_CSD_COMPATIBILITY_LOCKING NO
setenv SKIP_CDS_DIALOG

# Set tool locations (note that $CDS is needed by dfiiwrapper.pl)

setenv CDS /apps/cadence 
setenv IC  $CDS/IC50
setenv IUS $CDS/INCISIV141
setenv cdk_dir $IC/tools/dfII/local
#setenv ASSURAHOME  $CDS/ASSURA
 
# the lib path setup looks at $CDS_SITE/cdssetup to find the "setup.loc"
# file (other things, like prependNCSUCDKInstallPath(), need $CDS_SITE
# as well) 

setenv CDS_SITE /apps/cadence/IC50/tools/dfII/local
setenv USE_NCSU_CDK  
setenv CDS_VHDL $IUS/tools/leapfrog

# use analog netlister for everything

setenv CDS_Netlisting_Mode Analog

# this sets things so we no longer use cdsd. this won't be a problem,
# since we're not running 442 anymore. plus it makes the tools run on
# solaris 2.6! yay!

setenv CLS_CDSD_COMPATIBILITY_LOCKING NO

# this next one sets a path to our wrapper script; the script
# removes this PATH component to unmask the real executable
#
# note that we have to do this explicitly, rather than using prepend,
# because the "add" that got us here already added $CDS/bin, and we want
# it at the front of PATH (prepend won't add it if it's already there)

#extend MANPATH $IUS/share/man
#extend MANPATH $IC/share/man
#extend MANPATH $IC/tools/man


setenv PATH "/apps/synopsys/TCAD/bin:${PATH}"
setenv PATH "/apps/synopsys/I-2013.12-SP5/bin:${PATH}"
setenv PATH "${PATH}:/apps/silvaco/bin"
setenv PATH "${PATH}:/apps/cadence/IC50/tools/perl/bin"
setenv PATH "${PATH}:/apps/cadence/SOC42/bin:/apps/SOC42/share/celtic/scripts"
setenv PATH "${PATH}:${CDS}/bin"
setenv PATH "${PATH}:${CDS_VHDL}"
setenv PATH "${PATH}:${IC}/tools/bin"
setenv PATH "${PATH}:${IC}/tools/dfII/bin"
setenv PATH "${PATH}:${IC}/tools/concice/bin"
setenv PATH "${PATH}:${IC}/tools/dracula/bin"
setenv PATH "${PATH}:${IUS}/tools/bin"
setenv PATH "${PATH}:/apps/altera8.1/quartus/bin"

setenv LD_LIBRARY_PATH /apps/synopsys/TCAD/tcad/current/linux/lib
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${IUS}/tools/lib
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${IC}/tools/lib

setenv HSP_HOME /apps/synopsys/HSPICE/hspice
setenv VCS_HOME /apps/synopsys/I-2014.03-2
source ${VCS_HOME}/bin/environ.csh

