#!/bin/bash

# This will download the precompiled android toolchain to your home directory
cd ~
mkdir android-toolchain
cd android-toolchain
curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > repo
chmod a+x ./repo
./repo init -u https://android.googlesource.com/platform/manifest -b android-2.3.5_r1
./repo sync prebuilt
cd prebuilt
git filter-branch --subdirectory-filter linux-x86/toolchain/arm-eabi-4.4.0/
git checkout-index -a -f --prefix=$HOME/arm-eabi-4.4.0/
cd ~
rm -rf android-toolchain
