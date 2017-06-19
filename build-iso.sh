#!/bin/bash -e

ROOT=$(cd $(dirname $0); pwd)

ISO_FILE=$1
MNT_DIR=/tmp/mnt
ISO_DIR=/tmp/iso

[ -z "$ISO_FILE" ] && ISO_FILE=$(echo $ROOT/CentOS-*.iso)

if [ ! -f "$ISO_FILE" ]; then
    echo "file not found: $ISO_FILE"
    exit 1
fi

echo "Using $ISO_FILE ..."

if [ $(type -Pt mkisofs) != "file" ]; then
    echo "Installing mkisofs ..."
    yum install -y genisoimage
fi

mkdir -p $MNT_DIR
umount $MNT_DIR > /dev/null 2>&1 || true
mount $ISO_FILE $MNT_DIR

echo "Copying files from ISO ..."
rm -rf $ISO_DIR
cp -r $MNT_DIR $ISO_DIR
umount $MNT_DIR

echo "Generating kickstart file ..."
cd $ROOT
cp -f ks.cfg $ISO_DIR/ks.cfg

if [ "$(grep Kickstart $ISO_DIR/isolinux/isolinux.cfg)" == "" ]; then
    # update timeout and insert a new label before 'label check'
    sed -i \
        -e 's/timeout 600/timeout 50/' \
        -e '/menu default/d' \
        -e '/label check/{h;s/.*/cat isolinux.cfg.part/e;G}' \
        $ISO_DIR/isolinux/isolinux.cfg
fi

if [ "$(grep Kickstart $ISO_DIR/EFI/BOOT/grub.cfg)" == "" ]; then
    sed -i \
        -e 's/set timeout=60/set timeout=5/' \
        -e 's/set default="1"/set default="2"/' \
        -e '/Test this media/{h;s/.*/cat grub.cfg.part/e;G}' \
        $ISO_DIR/EFI/BOOT/grub.cfg
fi

OUTPUT_ISO_FILE="$(dirname $ISO_FILE)/KS_$(basename $ISO_FILE)"
echo "Creating $OUTPUT_ISO_FILE ..."
cd $ISO_DIR
# the param "-V label" must match the vmlinuz label in isolinux/isolinux.cfg
mkisofs -R -J -T -joliet-long \
        -boot-load-size 4 -boot-info-table \
        -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
        -V "CentOS 7 x86_64" \
        -o "$OUTPUT_ISO_FILE" \
        ./

echo "Completed!"

