#!/bin/bash

#
# Board Configuration Section
# ===========================
#
# To add a new platform:
# - add a <shortname> to the "boards" array
# - create a <shortname>_LONGNAME variable with a descriptive name
# - create a <shortname>_BUILDFLAGS variable with any platform specific
#   options for edk2 'build'.
# And for platforms using standard edk2 'build':
# - create a <shortname>_DSC variable containing the path to the
#   platform .dsc file.
# Or for platforms not using edk2 'build' directly:
# - create a <shortname>_BUILDCMD variable pointing to the path of the
#   build command to use.
#

boards=( a5 a9 tc1 tc2 panda origen arndale )

a5_LONGNAME="Versatile Express A5"
a5_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
a5_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA5s.dsc"

a9_LONGNAME="Versatile Express A9"
a9_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1 -D EDK2_ARMVE_SINGLE_BINARY=1"
a9_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA9x4.dsc"

tc1_LONGNAME="Versatile Express TC1"
tc1_BUILDFLAGS="-D EDK2_ARMVE_STANDALONE=1"
tc1_DSC=" ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15x2.dsc"

tc2_LONGNAME="Versatile Express TC2"
tc2_BUILDFLAGS="-D ARM_BIGLITTLE_TC2=1"
tc2_DSC="ArmPlatformPkg/ArmVExpressPkg/ArmVExpress-CTA15-A7.dsc"

panda_LONGNAME="TI Pandaboard"
panda_BUILDCMD="./PandaBoardPkg/build.sh"
panda_BUILDFLAGS=""

origen_LONGNAME="Samsung Origen"
origen_BUILDFLAGS=""
origen_DSC="SamsungPlatformPkgOrigen/OrigenBoardPkg/OrigenBoardPkg-Exynos.dsc"

arndale_LONGNAME="Samsung Arndale"
arndale_BUILDFLAGS="-D EXYNOS5250_EVT1 -D DDR3"
arndale_DSC="SamsungPlatformPkg/ArndaleBoardPkg/arndale-Exynos5250.dsc"

#
# End of Board Configuration Section.
#
# No need to edit below unless you are changing script functionality.
#

BUILD=DEBUG

RESULT_BUF=`echo -e --------------------------------------------`
PASS_COUNT=0
FAIL_COUNT=0

function log_result
{
	if [ $1 -eq 0 ]; then
		RESULT_BUF="`printf \"%s\n%32s\tpass\" \"$RESULT_BUF\" \"$2\"`"
		PASS_COUNT=$(($PASS_COUNT + 1))
	else
		RESULT_BUF="`printf \"%s\n%32s\tfail\" \"$RESULT_BUF\" \"$2\"`"
		FAIL_COUNT=$(($FAIL_COUNT + 1))
	fi
}

function print_result
{
	printf "%s" "$RESULT_BUF"
	echo -e "\n--------------------------------------------"
	printf "pass\t$PASS_COUNT\n"
	printf "fail\t$FAIL_COUNT\n"

	exit $FAIL_COUNT
}

function build_platform
{
	PLATFORM_NAME="$board"_LONGNAME
	PLATFORM_BUILDFLAGS="$board"_BUILDFLAGS
	PLATFORM_BUILDCMD="$board"_BUILDCMD
	PLATFORM_DSC="$board"_DSC

	echo "Building ${!PLATFORM_NAME}"
	echo "$board"_BUILDFLAGS="'${!PLATFORM_BUILDFLAGS}'"

	if [ X"${!PLATFORM_BUILDCMD}" == X"" ]; then
		build -a ARM -t ARMLINUXGCC -p "${!PLATFORM_DSC}" -b "$BUILD" \
			${!PLATFORM_BUILDFLAGS}
	else
		${!PLATFORM_BUILDCMD} -b "$BUILD" ${!PLATFORM_BUILDFLAGS}
	fi
	log_result $? "${!PLATFORM_NAME}"
}


function uefishell
{
	BUILD_ARCH=`uname -m`
	case $BUILD_ARCH in
		arm*)
			ARCH=ARM
			DEFAULT_CROSS_COMPILE=
			;;
		*)
			unset ARCH
			DEFAULT_CROSS_COMPILE=arm-linux-gnueabi-
			;;
	esac
	if [ -z "$CROSS_COMPILE" ]; then
		CROSS_COMPILE="$DEFAULT_CROSS_COMPILE"
	fi
	export CROSS_COMPILE ARCH
	echo "Setting up shell for building UEFI"
	export TOOLCHAIN=ARMLINUXGCC
	export EDK_TOOLS_PATH=`pwd`/BaseTools
	. edksetup.sh `pwd`/BaseTools/
	make -C $EDK_TOOLS_PATH
	if [ $? -ne 0 ]; then
		echo " !!! UEFI BaseTools failed to build !!! " >&2
		exit 1
	fi
}


function usage
{
	echo "usage:"
	echo -n "uefibuild.sh [ all "
	for board in "${boards[@]}" ; do
	    echo -n "| $board "
	done
	echo "]"
	printf "%8s\tbuild %s\n" "all" "all supported platforms"
	for board in "${boards[@]}" ; do
		PLATFORM_NAME="$board"_LONGNAME
		printf "%8s\tbuild %s\n" "$board" "${!PLATFORM_NAME}"
	done
}

# Check to see if we are in a UEFI repository
# refuse to continue if we aren't
if [ ! -e BaseTools ]
then
	echo "ERROR: we aren't in the UEFI directory."
	echo "       I can tell because I can't see the BaseTools directory"
	exit 1
fi

builds=()

# If there were no args, use a menu to select a single board / all boards to build
if [ $# = 0 ]
then
	read -p "$(
			f=0
			for board in "${boards[@]}" ; do
					echo "$((++f)): $board"
			done
			echo $((++f)): all

			echo -ne '> '
	)" selection

	if [ "$selection" -eq $((${#boards[@]} + 1)) ]; then
		builds=(${boards[@]})
	else
		builds="${boards[$((selection-1))]}"
	fi
else
	while [ "$1" != "" ]; do
		case $1 in
			all )
				builds=(${boards[@]})
				break
				;;
			"/h" | "/?" | "-?" | "-h" | "--help" )
				usage
				exit
				;;
			"-b" )
				shift
				echo "Build profile: $1"
				BUILD="$1"
				;;
			* )
				MATCH=0
				for board in "${boards[@]}" ; do
					if [ "$1" == $board ]; then
						MATCH=1
						builds=(${builds[@]} "$board")
						break
					fi
				done

				if [ $MATCH -eq 0 ]; then
					echo "unknown arg $1"
					usage
					exit 1
				fi
				;;
		esac
		shift
	done
fi

uefishell

for board in "${builds[@]}" ; do
	build_platform
done

print_result
