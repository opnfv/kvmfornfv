#!/bin/bash

export PATH=$PATH:/usr/local/bin/

if [ ! -d kernel ] ; then
    echo ${0}: Directory \'kernel\' does not exist, run this script from the root of kvmfornfv source tree
    exit -1
fi

cd kernel

echo
echo "Build"
echo "-----"
echo

config_file=arch/x86/configs/opnfv.config
if [ ! -f ${config_file} ] ; then
    echo ${0}: ${config_file} does not exist
    exit -1
fi
cp -f ${config_file} .config

rpmbuild_dir=/tmp/kvmfornfv_rpmbuild
artifact_dir=${rpmbuild_dir}/RPMS/x86_64

rm -rf ${rpmbuild_dir}

make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg
if [ ${?} -ne 0 ] ; then
    echo ${0}: Kernel build failed
    exit -1
fi

# Make sure the build was successful
if [ ! -d ${artifact_dir} ] ; then
    echo ${0}: Kernel RPM packages build failed
    exit -1
fi

RPMs=`ls -1 ${artifact_dir} | wc -w`
if [ ${RPMs} -ne 3 ] ; then
    echo ${0}: Only ${RPMs} RPM packages were built
    exit -1
fi

echo
echo "Upload"
echo "------"
echo

set -e
set -o pipefail

# NOTE: make sure source parameters for GS paths are not empty.
[[ $GERRIT_CHANGE_NUMBER =~ .+ ]]
[[ $GERRIT_PROJECT =~ .+ ]]
[[ $GERRIT_BRANCH =~ .+ ]]

gs_path_review="artifacts.opnfv.org/review/$GERRIT_CHANGE_NUMBER"
gs_path_daily="artifacts.opnfv.org/daily/$GERRIT_CHANGE_NUMBER"
if [[ $GERRIT_BRANCH = "master" ]] ; then
    gs_path_branch="artifacts.opnfv.org/$GERRIT_PROJECT"
else
    gs_path_branch="artifacts.opnfv.org/$GERRIT_PROJECT/${GERRIT_BRANCH}"
fi

if [[ $JOB_NAME =~ "verify" ]] ; then
    gsutil cp -r ${artifact_dir}/* "gs://$gs_path_review/"
    echo
    echo "Kernel RPM packages are available at http://$gs_path_review"
elif [[ $JOB_NAME =~ "daily" ]] ; then
    gsutil cp -r ${artifact_dir}/* "gs://$gs_path_daily/"
    echo
    echo "Kernel RPM packages are available at http://$gs_path_daily"
elif [[ $JOB_NAME =~ "merge" ]] ; then
    gsutil cp -r ${artifact_dir}/* "gs://$gs_path_branch/"
    echo
    echo "Latest kernel RPM packages are available at http://$gs_path_branch"

    if gsutil ls "gs://$gs_path_review" > /dev/null 2>&1 ; then
        echo
        echo "Deleting Out-of-dated kernel RPM packages"
        gsutil rm -r "gs://$gs_path_review"
    fi
else
    echo ${0}: Unknown job ${JOB_NAME}
    exit -1
fi
