#!/bin/bash
#
# Common parameter parsing for kvmfornfv scripts
#
function usage() {
    echo ""
    echo "Usage --> $0 [-p package_type] [-o output_dir] [-h]"
    echo "  -p : centos/ubuntu/both ;  default is centos"
    echo "  -o : stores rpm and debian packages"
    echo "  -h : Help section"
    echo ""
}

output_dir=""
type=""

function build_package() {
    choice=$1

    case "$choice" in
        "centos")
            echo "Build $choice Rpms"
            cd ci/build_rpm
            ./build_rpms.sh
            cd $WORKSPACE
        ;;
        "ubuntu")
            echo "Build $choice Debians"
            cd ci/build_deb
            ./build_debs.sh
            cd $WORKSPACE
        ;;
        "both")
            echo "Build $choice Debians and Rpms"
            cd ci/build_deb
            ./build_debs.sh
            cd ../build_rpm
            ./build_rpms.sh
            cd $WORKSPACE
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
