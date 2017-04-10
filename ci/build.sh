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
         cd $WORKSPACE/ci/build_deb
         sudo docker build -t kvm_deb .
         sudo docker run -v $WORKSPACE:/opt/kvmfornfv -t  kvm_deb \
                      /opt/kvmfornfv/ci/build_interface.sh $1
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
    type='centos'
fi

if [[ -z "$output_dir" ]]
then
    output_dir=$WORKSPACE/build_output
fi

echo ""
echo "Building for $type package in $output_dir"
echo ""

echo "Job name is: $JOB_NAME"
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

# Modifying the packages in build_output based on the job_type(verify/daily)
if [ $JOB_NAME == "verify" ]; then
   if [ $type == "centos" ]; then
      echo "Remove kernel-debuginfo rpm package from build_output"
      rm -f $WORKSPACE/${output_dir}/kernel-debuginfo*
   else
      echo "Remove linux-image-dbg debian package from build_output"
      rm -f $WORKSPACE/${output_dir}/*dbg.rpm
   fi
fi
