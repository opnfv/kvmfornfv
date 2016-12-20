#!/bin/bash
#
# Common parameter parsing for kvmfornfv scripts
#

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
         cd $WORKSPACE/ci/build_rpm
         sudo docker build -t kvm_rpm .
         sudo docker run -v $WORKSPACE:/opt/kvmfornfv -t  kvm_rpm \
                      /opt/kvmfornfv/ci/build_interface.sh $1
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

mkdir -p $output_dir
build_package $type
