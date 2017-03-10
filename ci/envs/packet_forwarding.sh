#!/bin/bash
JOB_TYPE=$1
QEMURPM_VERSION=$2
HOME='/home/jenkins'
VSPERF="${HOME}/vswitchperf"
LOG_FILE_PREFIX="/tmp/vsperf_build"
VSPERF_BIN='./vsperf'
DATE=$(date -u +"%Y-%m-%d_%H-%M-%S")
VSPERFENV_DIR="$HOME/vsperfenv"
#TEST_REPORT_LOG_DIR="${WORKSPACE}/build_output/results/"
echo $TEST_REPORT_LOG_DIR
echo $HOME
EXIT=0
EXIT_TC_FAILED=1

# DAILY - run selected TCs for defined packet sizes
#TESTCASES_DAILY='phy2phy_tput back2back phy2phy_tput_mod_vlan phy2phy_scalability pvp_tput pvp_back2back '
#TESTPARAM_DAILY='--test-params TRAFFICGEN_PKT_SIZES=(64,128,512,1024,1518)'
TESTCASES_DAILY='phy2phy_tput'
TESTPARAM_DAILY='--test-params TRAFFICGEN_PKT_SIZES=(64,128)'
TESTCASES_SRIOV='pvp_tput'
TESTPARAM_SRIOV='--test-params TRAFFICGEN_PKT_SIZES=(64,128,512,1024,1518)'

shared_dir=$(sudo mount | grep ixia_results)
if [ -z "$shared_dir" ]; then
    echo "mounting shared directory for results"
    sudo mount -t cifs //10.10.100.6/ixia_results/kvm4nfv_ci /mnt/ixia_results/kvm4nfv_ci  -o password=kvm4nfv! -o username=kvm4nfv,file_mode=0777,dir_mode=0777,nounix
else
    echo "shared directory is already mounted for results"
fi

# check if user config file exists if not then we will use default settings
if [ -f $HOME/vsperf.conf ] ; then
        CONF_FILE="--conf-file ${HOME}/vsperf.conf"
    else
        echo "configuration file not found"
        exit 1
fi

# check if sriov config file exists if not then we will use default settings
if [ -f $HOME/vsperf.conf.sriov ] ; then
        CONF_FILE_SRIOV="--conf-file ${HOME}/vsperf.conf.sriov"
    else
        echo " SRIOV configuration file not found"
        exit 1
fi

function install_vsperf() {
    echo "Installing vsperf....."
    ( cd $VSPERF/systems ; ./build_base_machine.sh )
    echo "Installing kvmfornfv built qemu rpm"
    #sudo rpm -ivh /root/rpm/qemu-$QEMURPM_VERSION*.x86_64.rpm
}

function print_results() {
    for i in $TESTCASES ; do
        RES_FILE=`ls -1 $1 | egrep "result_${i}_[0-9a-zA-Z\-]+.csv"`

        if [ "x$RES_FILE" != "x" -a -e "${1}/${RES_FILE}" ]; then
            if grep ^FAILED "${1}/${RES_FILE}" &> /dev/null ; then
                printf "    %-70s %-6s\n" "result_${i}" "FAILED"
                EXIT=$EXIT_TC_FAILED
            else
                echo "--------------------------------------------------------------"
                printf "    %-50s %-6s\n" "result_${i}" "OK"
                echo "--------------------------------------------------------------"
            fi
        else
            echo "------------------------------------------------------------------"
            printf "    %-50s %-6s\n" "result_${i}" "FAILED"
            echo "------------------------------------------------------------------"
            EXIT=$EXIT_TC_FAILED
        fi
    done
}

function execute_vsperf() {
    # figure out list of TCs and execution parameters
    case $2 in
        "verify")
            TESTPARAM=$TESTPARAM_DAILY
            TESTCASES=$TESTCASES_DAILY
            ;;
        *)
            echo "No vsperf test cases implemented for this job type"
            ;;
    esac

    # execute testcases
    echo -e "\nExecution of VSPERF for $1"
    DATE_SUFFIX=$(date -u +"%Y-%m-%d_%H-%M-%S")
    source "$VSPERFENV_DIR"/bin/activate
    case $1 in
        "SRIOV")
            # use SRIOV specific TCs and configuration
            TESTPARAM=$TESTPARAM_SRIOV
            TESTCASES=$TESTCASES_SRIOV
            # figure out log file name
            LOG_SUBDIR="SRIOV"
            LOG_FILE="${LOG_FILE_PREFIX}_${LOG_SUBDIR}_${DATE_SUFFIX}.log"
            echo "    $VSPERF_BIN --vswitch none --vnf QemuPciPassthrough $CONF_FILE_SRIOV $TESTPARAM $TESTCASES &> $LOG_FILE"
            $VSPERF_BIN --vswitch none --vnf QemuPciPassthrough $CONF_FILE_SRIOV $TESTPARAM $TESTCASES &> $LOG_FILE
            ;;
        *)
            # figure out log file name
            LOG_SUBDIR="OvsDpdkVhost"
            LOG_FILE="${LOG_FILE_PREFIX}_${LOG_SUBDIR}_${DATE_SUFFIX}.log"
            echo "    $VSPERF_BIN $OPNFVPOD --vswitch OvsDpdkVhost --vnf QemuDpdkVhostUser $CONF_FILE $TESTPARAM $TESTCASES > $LOG_FILE"
            echo "daily test cases started"
            cd $HOME/vswitchperf
            $VSPERF_BIN --list
            $VSPERF_BIN  --vswitch OvsDpdkVhost --vnf QemuDpdkVhostUser $CONF_FILE $TESTPARAM $TESTCASES &>> $LOG_FILE
            ;;
    esac
    # evaluation of results
    echo -e "\nResults for $1"
    RES_DIR="/$(grep "Creating result directory" $LOG_FILE | cut -d'/' -f2-)"
    if [[ "/" == "${RES_DIR}" ]] ; then
        echo "FAILURE: Results are not available."
        echo "-------------------------------------------------------------------"
        cat $LOG_FILE
        echo "-------------------------------------------------------------------"
        exit $EXIT_NO_RESULTS
    else
        print_results "${RES_DIR}"
        if [ $(($EXIT & $EXIT_TC_FAILED)) -gt 0 ] ; then
            echo "-------------------------------------------------------------------"
            cat $LOG_FILE
            echo "-------------------------------------------------------------------"
        fi
    fi
    # show detailed result figures
    for md_file in $(grep '\.md"$' $LOG_FILE | cut -d'"' -f2); do
        # TC resut file header
        echo -e "\n-------------------------------------------------------------------"
        echo -e " $md_file"
        echo -e "-------------------------------------------------------------------\n"
        # TC details
        sed -n '/^- Test ID/,/Bidirectional/{/Packet size/b;p;/Bidirectional/q};/Results\/Metrics Collected/,/Statistics collected/{/^$/p;/^|/p}' $md_file
        # TC results
        sed -n '/Results\/Metrics Collected/,/Statistics collected/{/^$/p;/^|/p}' $md_file | grep -v "Unknown" | cat -s
    done

    # copy logs into dedicated directory
    #mkdir -p ${TEST_REPORT_LOG_DIR}/${LOG_SUBDIR}
    #[ -f "$LOG_FILE" ] && cp -a "${LOG_FILE}" "${TEST_REPORT_LOG_DIR}/${LOG_SUBDIR}" &> /dev/null
    #[ -d "$RES_DIR" ] && cp -ar "$RES_DIR" "${TEST_REPORT_LOG_DIR}/${LOG_SUBDIR}" &> /dev/null
}

#Install vsperf and set up the environment
install_vsperf

# execute job based on passed parameter
case $1 in
    "verify")
        echo "================"
        echo "VSPERF daily job"
        echo "================"
        execute_vsperf OVS_with_DPDK_and_vHost_User $1
        #execute_vsperf SRIOV $1
        #cleanup
        exit $EXIT
        ;;
    *)
        echo "test cases not implemented for this job type"
esac

exit $EXIT
