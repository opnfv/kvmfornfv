#! /bin/sh

set -e

base=http://wiki.qemu-project.org/download
comp=.bz2

dir() {
  if [ -d $1 ]; then
     echo removing $1/...
     rm -rf $1
  fi
}

clean_dfsg() {
# remove only those blobs which does not have packaged source
# remove all other blobs too

rm -vf pc-bios/bios.bin		# roms/seabios/
rm -vf pc-bios/bios-256k.bin	# roms/seabios/
rm -vf pc-bios/*-dsdt.aml	# roms/seabios/
rm -vf pc-bios/ppc_rom.bin	# comes from openhackware
rm -vf pc-bios/sgabios.bin	# roms/sgabios/
rm -vf pc-bios/slof.bin		# roms/SLOF/
rm -vf pc-bios/spapr-rtas.bin	# pc-bios/spapr-rtas/
rm -vf pc-bios/vgabios*.bin	# roms/vgabios/
rm -vf pc-bios/pxe-*.rom	# roms/ipxe/
rm -vf pc-bios/efi-*.rom	# roms/ipxe/
rm -vf pc-bios/bamboo.dtb	# pc-bios/bamboo.dts
rm -vf pc-bios/openbios-*	# roms/openbios/
rm -vf pc-bios/palcode-clipper	# roms/qemu-palcode/ alpha palcode
rm -vf pc-bios/s390-zipl.rom	# s390-tools+addon, git://repo.or.cz/s390-tools.git, debian #684909
rm -vf pc-bios/s390-ccw.img	# pc-bios/s390-ccw/
rm -vf pc-bios/kvmvapic.bin
rm -vf pc-bios/linuxboot.bin
rm -vf pc-bios/multiboot.bin
rm -vf pc-bios/u-boot.e500
rm -vf pc-bios/QEMU,*.bin

# remove other software (git submodules)
dir roms/ipxe
dir roms/openbios
dir roms/openhackware
dir roms/qemu-palcode
dir roms/seabios
dir roms/sgabios
dir roms/SLOF
dir roms/vgabios
dir roms/u-boot

dir dtc
dir pixman

find scripts -name '*.pyc' -print -delete

}

case "$#$1" in
  1clean | 1dfsg)
    if [ -f vl.c -a -f hw/block/block.c -a -d pc-bios ]; then
      clean_dfsg
      exit 0
    fi
    echo "apparently not a qemu source dir" >&2; exit 1
    ;;

  1[012].*) ;;

  *)
    echo "unknown arguments.  Should be either 'dfsg' or a version number" >&2
    exit 1
    ;;
esac

deb="${1%-*}" # strip debian revision number
upstream="${deb%+dfsg}"
case "$upstream" in
   *~rc*) upstream=$(echo "$upstream" | sed 's/~rc/-rc/') ;;
esac
case "$upstream" in
   2.[0-9] | 2.[0-9][!0-9.]* ) # add .0 to a version number
     upstream=$(echo "$upstream" | sed 's/^.\../&.0/') ;;
esac

tempdir=qemu-$upstream-tmp
basetar=qemu-$upstream.tar$comp
debtar=qemu_$deb.orig.tar.xz

if [ ! -f $basetar ]; then

  echo getting upstream version $upstream ...
  wget -Nc $base/$basetar

fi

if [ ! -f $debtar ]; then

  echo extracting source in $tempdir and cleaning up ...
  rm -rf $tempdir
  mkdir $tempdir
  cd $tempdir
  tar -x -f ../$basetar --strip-components=1
  clean_dfsg

  echo repacking to $debtar ...
  find . -type f -print | sort \
    | XZ_OPT="-v6" \
      tar -caf ../$debtar -T- --owner=root --group=root --mode=a+rX \
         --xform "s/^\\./qemu-$upstream/"

  cd ..
  rm -rf $tempdir

fi
