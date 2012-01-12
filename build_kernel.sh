#!/bin/bash

echo "$1 $2 $3"

case "$1" in
	Clean)
		echo "************************************************************"
		echo "* Clean Kernel                                             *"
		echo "************************************************************"
		pushd Kernel
			make clean V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
		popd
		echo " Clean is done... "
		exit
		;;
	mrproper)
		echo "************************************************************"
		echo "* mrproper Kernel                                          *"
		echo "************************************************************"
		pushd Kernel
			make clean V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
			make mrproper 2>&1 | tee make.mrproper.out
		popd
		echo " mrproper is done... "
		exit
		;;
	distclean)
		echo "************************************************************"
		echo "* distclean Kernel                                         *"
		echo "************************************************************"
		pushd Kernel
			make clean V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
			make distclean 2>&1 | tee make.distclean.out
		popd
		echo " distclean is done... "
		exit
		;;
	*)
		PROJECT_NAME=SPH-D700
		HW_BOARD_REV="03"
		;;
esac

if [ "$CPU_JOB_NUM" = "" ] ; then
	CPU_JOB_NUM=`grep -c processor /proc/cpuinfo`
fi

TARGET_LOCALE="vzw"

#uncomment to add custom version string
CUSTOMVERSION="KernelSandersCM-v2"
export KBUILD_BUILD_VERSION=$CUSTOMVERSION
LOCALVERSION_STRING="-$CUSTOMVERSION"
DEFCONFIG_STRING=cyanogenmod_epicmtd_defconfig

TOOLCHAIN=$HOME/arm-eabi-4.4.3/bin 
TOOLCHAIN_PREFIX=arm-eabi-
PYTHON=python

KERNEL_BUILD_DIR=`pwd`/Kernel
ANDROID_OUT_DIR=`pwd`/Android/out/target/product/SPH-D700
ZIP_BUILD_DIR=`pwd`/zip

export PRJROOT=$PWD
export PROJECT_NAME
export HW_BOARD_REV

export LD_LIBRARY_PATH=.:${TOOLCHAIN}/../lib

echo "************************************************************"
echo "* EXPORT VARIABLE                                          *"
echo "************************************************************"
echo "PRJROOT=$PRJROOT"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "HW_BOARD_REV=$HW_BOARD_REV"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "************************************************************"

BUILD_MODULE()
{
	echo "************************************************************"
	echo "* BUILD_MODULE                                             *"
	echo "************************************************************"
	echo
	pushd Kernel
		make ARCH=arm modules
	popd
}

CLEAN_ZIMAGE()
{
	echo "************************************************************"
	echo "* Removing old zImage                                      *"
	echo "************************************************************"
	rm -f `pwd`/Kernel/arch/arm/boot/zImage
	echo "* zImage removed"
	echo "************************************************************"
	echo
}

BUILD_KERNEL()
{
	echo "************************************************************"
	echo "* BUILD_KERNEL                                             *"
	echo "************************************************************"
	echo
	pushd $KERNEL_BUILD_DIR
		export KDIR=`pwd`
		#make clean mrproper
		make ARCH=arm $DEFCONFIG_STRING
		make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX LOCALVERSION=$LOCALVERSION_STRING 2>&1 | tee make.out
	popd
}

BUILD_ZIP()
{
	pushd $ZIP_BUILD_DIR
		mkdir -p system/lib/modules
		find $KERNEL_BUILD_DIR -name '*.ko' -exec cp '{}' system/lib/modules/ \;
		$TOOLCHAIN/$TOOLCHAIN_PREFIX'strip' --strip-debug system/lib/modules/*
		$PYTHON $PRJROOT/mkshbootimg.py boot.img $KERNEL_BUILD_DIR/arch/arm/boot/zImage $PRJROOT/boot.cpio.gz $PRJROOT/recovery.cpio.gz
		zip -r $PRJROOT/$CUSTOMVERSION.zip ./*
		rm -rf boot.img
		rm -rf system/lib
	popd
}

# print title
PRINT_USAGE()
{
	echo "************************************************************"
	echo "* PLEASE TRY AGAIN                                         *"
	echo "************************************************************"
	echo
}

PRINT_TITLE()
{
	echo
	echo "************************************************************"
	echo "* MAKE PACKAGES                                            *"
	echo "************************************************************"
	echo "* 1. kernel : zImage"
	echo "* 2. modules"
	echo "************************************************************"
}

##############################################################
#                   MAIN FUNCTION                            #
##############################################################
if [ $# -gt 3 ]
then
	echo
	echo "************************************************************"
	echo "* Option Error                                             *"
	PRINT_USAGE
	exit 1
fi

START_TIME=`date +%s`
PRINT_TITLE
#BUILD_MODULE
CLEAN_ZIMAGE
BUILD_KERNEL
BUILD_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo "Total compile time is $ELAPSED_TIME seconds"
