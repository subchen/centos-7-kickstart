#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

ISO_FILE=$1

[ -z "$ISO_FILE" ] && ISO_FILE=$(echo $CWD/CentOS-*.iso)

if [ ! -f "$ISO_FILE" ]; then
    echo "file not found: $ISO_FILE"
    exit 1
fi

echo "Using $ISO_FILE ..."

type -P mkisofs     || yum install -y mkisofs
type -P ksvalidator || yum install -y pykickstart
type -P createrepo  || yum install -y createrepo

echo "Validating ks.cfg ..."
ksvalidator -e $CWD/ks.cfg

KS_MNT_DIR=/tmp/.ks/mnt
KS_ISO_DIR=/tmp/.ks/iso

mkdir -p $KS_MNT_DIR
umount $KS_MNT_DIR > /dev/null 2>&1 || true
mount $ISO_FILE $KS_MNT_DIR

echo "Copying files from ISO ..."
rm -rf $KS_ISO_DIR
cp -r $KS_MNT_DIR $KS_ISO_DIR
umount $KS_MNT_DIR

echo "Generating kickstart file ..."
cd $CWD
cp -f ks.cfg $KS_ISO_DIR/ks.cfg

if [ "$(grep Kickstart $KS_ISO_DIR/isolinux/isolinux.cfg)" == "" ]; then
    # update timeout and insert a new label before 'label check'
    sed -i \
        -e 's/timeout 600/timeout 50/' \
        -e '/menu default/d' \
        -e '/label check/{h;s/.*/cat isolinux.cfg.part/e;G}' \
        $KS_ISO_DIR/isolinux/isolinux.cfg
fi

if [ "$(grep Kickstart $KS_ISO_DIR/EFI/BOOT/grub.cfg)" == "" ]; then
    # update timeout and insert a new menu before 'Test this media'
    sed -i \
        -e 's/set timeout=60/set timeout=5/' \
        -e 's/set default="1"/set default="2"/' \
        -e '/Test this media/{h;s/.*/cat grub.cfg.part/e;G}' \
        $KS_ISO_DIR/EFI/BOOT/grub.cfg
fi


echo "Adding scripts and repo ..."
cp -rf $CWD/scripts $KS_ISO_DIR/
createrepo $KS_ISO_DIR/scripts/repo/


OUTPUT_ISO_FILE="$(dirname $ISO_FILE)/KS_$(basename $ISO_FILE)"
echo "Creating $OUTPUT_ISO_FILE ..."

# the param "-V label" must match the vmlinuz label in isolinux/isolinux.cfg
cd $KS_ISO_DIR
mkisofs -R -J -T -joliet-long \
        -boot-load-size 4 -boot-info-table \
        -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
        -V "CentOS 7 x86_64" \
        -o "$OUTPUT_ISO_FILE" \
        ./

echo "Completed!"
