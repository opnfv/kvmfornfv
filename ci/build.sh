#!/bin/bash
#
# Common parameter parsing for kvmfornfv scripts
#

function checking_apex_build() {
    echo ""
    commit=`git rev-parse HEAD`
    echo "commit id: $commit"
    echo "Checking for presence of apex.conf in the current patch"
    git diff-tree --no-commit-id --name-only -r ${commit} | grep apex.conf
#    result=`git show --name-only ${commit} | grep apex.conf`
    result=`git diff-tree --no-commit-id --name-only -r ${commit} | grep apex.conf`
    if [ -z "${result}" ]; then
       echo "Does not include the file apex.conf"
       apex_build_flag=0
    else
       source $WORKSPACE/ci/apex.conf
       echo "Includes apex.conf"
       apex_build_flag=1
    fi
}

function checking_compass_build() {
    echo ""
    commit=`git rev-parse HEAD`
    echo "commit id: $commit"
    echo "Checking for presence of compass.conf in the current patch"
    git diff-tree --no-commit-id --name-only -r ${commit} | grep compass.conf
    result=`git diff-tree --no-commit-id --name-only -r ${commit} | grep compass.conf`
    if [ -z "${result}" ]; then
       echo "Does not include the file compass.conf"
       compass_build_flag=0
    else
       source $WORKSPACE/ci/compass.conf
       echo "Includes compass.conf"
       compass_build_flag=1
    fi
}


function usage() {
    echo ""
    echo "Usage --> $0 [-p package_type] [-o output_dir] [-h]"
    echo "  package_type : centos/ubuntu/both ;  default is centos"
    echo "  output_dir : stores rpm and debian packages"
    echo "  -h : Help section"
    echo ""
}

output_dir=""
type=""

function run() {
   case $1 in
      centos)
         if [ ${apex_build_flag} -eq 0 ];then
            cd $WORKSPACE/ci/build_rpm
            sudo docker build -t kvm_rpm .
            sudo docker run --privileged=true -v $WORKSPACE:/opt/kvmfornfv -t  kvm_rpm \
                         /opt/kvmfornfv/ci/build_interface.sh $1
         else
            cd $WORKSPACE/ci/
            echo $output_dir
            sudo docker build -t kvm_apex .
            sudo docker run --privileged=true -v $WORKSPACE:/opt/kvmfornfv -t  kvm_apex  \
                         /opt/kvmfornfv/ci/apex_build.sh build_output
         fi
      ;;
      ubuntu)
         if [${compass_build_flag} -eq 0]; then
            cd $WORKSPACE/ci/build_deb
            sudo docker build -t kvm_deb .
            sudo docker run -v $WORKSPACE:/opt/kvmfornfv -t  kvm_deb \
                        /opt/kvmfornfv/ci/build_interface.sh $1
         else
            cd $WORKSPACE/ci/
            echo $output_dir
            sudo docker build -t kvm_docker .
            sudo docker run --privileged=true -v $WORKSPACE:/opt/kvmfornfv -t  kvm_docker  \
                         /opt/kvmfornfv/ci/compass_build.sh build_output
         fi
      ;;
      *) echo "Not supported system"; exit 1;;
   esac
}

function build_package() {
    choice=$1
    case "$choice" in
        "centos"|"ubuntu")
            echo "Build $choice Rpms/Debians"
            run $choice
        ;;
        "both")
            echo "Build $choice Debians and Rpms"
            run "centos"
            run "ubuntu"
        ;;
        *)
            echo "Invalid package option"
            usage
            exit 1
        ;;
    esac
}

##  --- Parse command line arguments / parameters ---
while getopts ":o:p:h" option; do
    case $option in
        p) # package
          type=$OPTARG
          ;;
        o) # output_dir
          output_dir=$OPTARG
          ;;
        :)
          echo "Option -$OPTARG requires an argument."
          usage
          exit 1
          ;;
        h)
          usage
          exit 0
          ;;
        *)
          echo "Unknown option: $OPTARG."
          usage
          exit 1
          ;;
        ?)
          echo "[WARNING] Unknown parameters!!!"
          echo "Using default values for package generation & output"
    esac
done

if [[ -z "$type" ]]
then
    type='ubuntu'
fi

if [[ -z "$output_dir" ]]
then
    output_dir=$WORKSPACE/build_output
fi

job_type=`echo $JOB_NAME | cut -d '-' -f 2`

echo ""
echo "Building for $type package in $output_dir"
echo ""

checking_compass_build
checking_apex_build
mkdir -p $output_dir
build_package $type

# Renaming the rpms in the format kvmfornfv-xxxxxxxx-apex-kernel-4.4.6_rt14.el7.centos.x86_64.rpm
if [ ${apex_build_flag} -eq 1 ];then
    cd ${output_dir}
    echo "Renaming the rpms"
    source $WORKSPACE/ci/apex.conf
    echo "${commit_id}"
    short_hash=`git rev-parse --short=8 ${commit_id}`
    echo "$short_hash"
    rename 's/^/kvmfornfv-'${short_hash}'-apex-/' kernel-*
    variable=`ls kvmfornfv-* | grep "devel" | awk -F "_" '{print $3}' | awk -F "." '{print $1}'`
    rename "s/${variable}/centos/" kvmfornfv-*
fi

# Uploading rpms only for daily job
if [ $job_type == "verify" ]; then
   if [ $type == "centos" ]; then
      echo "Removing kernel-debuginfo rpm from output_dir"
      rm -f ${output_dir}/kernel-debug*
      echo "Checking packages in output_dir"
      ls -lrth ${output_dir}
   else
     echo "Removing debug debian from output_dir"
     rm -f ${output_dir}/*dbg*
     echo "Checking packages in output_dir"
     ls -lrth ${output_dir}
   fi
fi
