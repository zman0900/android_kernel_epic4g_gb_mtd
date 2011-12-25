#!/bin/bash

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

# Bundle
../mkbootfs `pwd` | gzip > ../boot.cpio.gz

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

# Bundle
../mkbootfs `pwd` | gzip > ../recovery.cpio.gz

cd ..

