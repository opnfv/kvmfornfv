#!/bin/sh

tmpdir=$1 #/tmp/kvmfornfv_rpmbuild.1/BUILD/kernel-4.4.50_rt62nfv
OBJCOPY=objcopy
for module in $(find $tmpdir/lib/modules/ -name *.ko -printf '%P\n'); do
                        module=lib/modules/$module
                        mkdir -p $(dirname $tmpdir/usr/lib/debug/$module)
                        # only keep debug symbols in the debug file
                        $OBJCOPY --only-keep-debug $tmpdir/$module $tmpdir/usr/lib/debug/$module
                        # strip original module from debug symbols
                        $OBJCOPY --strip-debug $tmpdir/$module
                        # then add a link to those
                        $OBJCOPY --add-gnu-debuglink=$tmpdir/usr/lib/debug/$module $tmpdir/$module
                done
