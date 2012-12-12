#!/bin/bash

UEFISHELL_SETUP="n"

function uefishell
{
	if [ "$UEFISHELL_SETUP" != "y" ]
	then
		echo "Setting up shell for building UEFI"
		export TOOLCHAIN=ARMLINUXGCC
		export EDK_TOOLS_PATH=`pwd`/BaseTools
		export CROSS_COMPILE=arm-linux-gnueabi-
		. edksetup.sh `pwd`/BaseTools/
		make -C $EDK_TOOLS_PATH
		UEFISHELL_SETUP="y"
	fi
}

function build_a5
{
	uefishell
	echo "Building Versatile Express A5"
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA5s.dsc -D EDK2_ARMVE_STANDALONE=1
}

function build_a9
{
	uefishell
	echo "Building Versatile Express A9"
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA9x4.dsc -D EDK2_ARMVE_STANDALONE=1 -D EDK2_ARMVE_SINGLE_BINARY=1
}

function build_tc1
{
	uefishell
	echo "Building Versatile Express A15x2 TC1"
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15x2.dsc -D EDK2_ARMVE_STANDALONE=1
}

function build_tc2
{
	uefishell
	echo "Building Versatile Express A15-A7 TC2"
	build -a ARM -b DEBUG -t ARMLINUXGCC -p ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15-A7.dsc -D ARM_BIGLITTLE_TC2=1
}

function build_panda
{
	uefishell
	echo "Building TI PandaBoard"
	cd `pwd`/PandaBoardPkg && ./build.sh && cd ..
}

function build_origen
{
	uefishell
	echo "Building Samsung Origen"
	build -a ARM -b DEBUG -t ARMLINUXGCC -p SamsungPlatformPkgOrigen/OrigenBoardPkg/OrigenBoardPkg-Exynos.dsc
}

function build_arndale
{
	uefishell
	echo "Building Samsung Arndale"
	build -a ARM -b DEBUG -t ARMLINUXGCC -p SamsungPlatformPkg/ArndaleBoardPkg/arndale-Exynos5250.dsc -D EXYNOS5250_EVT1 -D DDR3
}


function usage
{
	echo "usage:"
	echo "uefibuild.sh [ all | a5 | a9 | tc1 | tc2 | panda | origen | arndale ]"
	echo "    all       build all supported platforms"
	echo "    a5        build Versatile Express A5"
	echo "    a9        build Versatile Express A9"
	echo "    tc1       build Versatile Express TC1"
	echo "    tc2       build Versatile Express TC2"
	echo "    panda     build TI Pandaboard"
	echo "    origen    build Samsung Origen"
	echo "    arndale   build Samsung Arndale"
}



# If there were no args, use a menu to select a single board / all boards to build
if [ $# = 0 ]
then
	boards=( a5 a9 tc1 tc2 panda origen arndale all )

	read -p "$(
			f=0
			for board in "${boards[@]}" ; do
					echo "$((++f)): $board"
			done

			echo -ne '> '
	)" selection

	selected_board="${boards[$((selection-1))]}"

	if [[ "$selected_board" = "a5" || "$selected_board" = "all" ]]
	then
		BUILD_A5="y"
	fi
	if [[ "$selected_board" = "a9" || "$selected_board" = "all" ]]
	then
		BUILD_A9="y"
	fi
	if [[ "$selected_board" = "tc1" || "$selected_board" = "all" ]]
	then
		BUILD_TC1="y"
	fi
	if [[ "$selected_board" = "tc2" || "$selected_board" = "all" ]]
	then
		BUILD_TC2="y"
	fi
	if [[ "$selected_board" = "panda" || "$selected_board" = "all" ]]
	then
		BUILD_PANDA="y"
	fi
	if [[ "$selected_board" = "origen" || "$selected_board" = "all" ]]
	then
		BUILD_ORIGEN="y"
	fi
	if [[ "$selected_board" = "arndale" || "$selected_board" = "all" ]]
	then
		BUILD_ARNDALE="y"
	fi
else
	while [ "$1" != "" ]; do
		case $1 in
			all )
				BUILD_A5="y"
				BUILD_A9="y"
				BUILD_TC1="y"
				BUILD_TC2="y"
				BUILD_PANDA="y"
				BUILD_ORIGEN="y"
				BUILD_ARNDALE="y"
				;;
			a5 )
				BUILD_A5="y"
				;;
			a9 )
				BUILD_A9="y"
				;;
			tc1 )
				BUILD_TC1="y"
				;;
			tc2 )
				BUILD_TC2="y"
				;;
			panda )
				BUILD_PANDA="y"
				;;
			origen )
				BUILD_ORIGEN="y"
				;;
			arndale )
				BUILD_ARNDALE="y"
				;;

			/h | /? | -? | -h | --help )
				usage
				exit
				;;
			* )
				usage
				echo "unknown arg $1"
				exit 1
		esac
		shift
	done
fi
if [ "$BUILD_A5" = "y" ]
then
	echo "build a5..."
	build_a5
fi
if [ "$BUILD_A9" = "y" ]
then
	build_a9
fi
if [ "$BUILD_TC1" = "y" ]
then
	build_tc1
fi
if [ "$BUILD_TC2" = "y" ]
then
	build_tc2
fi
if [ "$BUILD_PANDA" = "y" ]
then
	build_panda
fi
if [ "$BUILD_ORIGEN" = "y" ]
then
	build_origen
fi
if [ "$BUILD_ARNDALE" = "y" ]
then
	build_arndale
fi


