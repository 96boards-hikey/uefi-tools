#!/bin/bash

export TOOLCHAIN=ARMLINUXGCC
export EDK_TOOLS_PATH=`pwd`/BaseTools
. edksetup.sh `pwd`/BaseTools/
make -C $EDK_TOOLS_PATH

# Versatile Express A5
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA5s.dsc -D EDK2_ARMVE_STANDALONE=1

# Versatile Express A9
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA9x4.dsc -D EDK2_ARMVE_STANDALONE=1 -D EDK2_ARMVE_SINGLE_BINARY=1


# Versatile Express A15x2 TC1
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15x2.dsc -D EDK2_ARMVE_STANDALONE=1


# Samsung Origen
	build -a ARM -b DEBUG -t ARMLINUXGCC -p SamsungPlatformPkg/OrigenBoardPkg/OrigenBoardPkg-Exynos.dsc


# TI PandaBoard
	cd `pwd`/PandaBoardPkg && ./build.sh && cd ..


# Versatile Express A15-A7 TC2
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15-A7.dsc -D ARM_BIGLITTLE_TC2=1
