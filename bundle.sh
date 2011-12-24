#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script requires root access to set proper file permissions" 1>&2
   exec sudo bash `basename $0` $EUID
fi

USER=$1

# Clear old stuff
rm -f `pwd`/boot.img
rm -f `pwd`/boot.cpio.gz
rm -f `pwd`/recovery.cpio.gz

# Initramfs_mtd (second boot stage)
cd initramfs_mtd

# Set permissions
find ./ -type f -exec chmod 644 '{}' \;
find ./ -type d -exec chmod 755 '{}' \;
chmod 750 init init.rc init.goldfish.rc
find ./sbin -exec chmod 750 '{}' \;

# Change owner to root
find ./ -exec chown -R root:root '{}' \;

# Bundle
find ./ | cpio -o -c | gzip > ../boot.cpio.gz

# Change back owner
find ./ -exec chown -R $USER:$USER '{}' \;
chown $USER:$USER ../boot.cpio.gz
cd ..

# Recovery
cd recovery

# Set permissions
find ./ -type f -exec chmod 644 '{}' \;
find ./ -type d -exec chmod 755 '{}' \;
chmod 750 init init.rc
find ./sbin -exec chmod 750 '{}' \;

# Change owner to root
find ./ -exec chown -R root:root '{}' \;

# Bundle
find ./ | cpio -o -c | gzip > ../recovery.cpio.gz

# Change back owner
find ./ -exec chown -R $USER:$USER '{}' \;
chown $USER:$USER ../recovery.cpio.gz
cd ..

