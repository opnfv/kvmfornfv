#!/bin/bash
#
# Common parameter parsing for kvmfornfv scripts
#

function apex_build() {
    echo ""
    echo "Checking for the files in the patch"
    commit=`git rev-parse HEAD`
    echo "$commit"
    git show --name-only ${commit} | grep apex.conf
    result=`git show --name-only ${commit} | grep apex.conf`
    if [ -z "${result}" ]; then
       echo "Does not include the file apex.conf"
       apex_build_flag=0
    else
       source $WORKSPACE/apex.conf
       echo "Includes apex.conf"
       apex_build_flag=1
       mkdir -p $WORKSPACE/apex
       cd $WORKSPACE/apex
       git clone https://gerrit.opnfv.org/gerrit/kvmfornfv.git
       cd kvmfornfv
       git checkout -f $commit_id
       mkdir -p build_output
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
         echo $apex_build_flag
         if [ $apex_build_flag -eq 1 ];then
	    echo "Copying" 
            cd $WORKSPACE/ci/build_rpm
            sudo docker build -t kvm_rpm .
            sudo docker run --privileged=true -v $WORKSPACE:/opt/kvmfornfv -t  kvm_rpm \
                      /opt/kvmfornfv/ci/build_interface.sh $1 $apex_build_flag 
         else
            cd $WORKSPACE/ci/build_rpm
            sudo docker build -t kvm_rpm .
            sudo docker run --privileged=true -v $WORKSPACE:/opt/kvmfornfv -t  kvm_rpm \
                      /opt/kvmfornfv/ci/build_interface.sh $1
         fi
      ;;
      ubuntu)
	 echo $apex_build_flag
         if [ $apex_build_flag -eq 1 ];then
            cd $WORKSPACE/ci/build_deb
            sudo docker build -t kvm_deb .
            sudo docker run --privileged=true -v $WORKSPACE:/opt/kvmfornfv -t  kvm_deb \
                      /opt/kvmfornfv/ci/build_interface.sh $1 $apex_build_flag
         else
            cd $WORKSPACE/ci/build_deb
            sudo docker build -t kvm_deb .
            sudo docker run -v $WORKSPACE:/opt/kvmfornfv -t  kvm_deb \
                      /opt/kvmfornfv/ci/build_interface.sh $1
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
    type='centos'
fi

if [[ -z "$output_dir" ]]
then
    output_dir=$WORKSPACE/build_output
fi

echo ""
echo "Building for $type package in $output_dir"
echo ""

apex_build

mkdir -p $output_dir
build_package $type

#Renaming the Kernel RPM's
cd $WORKSPACE/build_output
rename 's/^/kvmfornfv-'${short_hash}'-apex-/' kernel-*
variable=`ls kvmfornfv-* | grep "devel" | awk -F "_" '{print $3}' | awk -F "." '{print $1}'`
rename "s/${variable}/centos/" kvmfornfv-*

