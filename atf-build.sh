#!/bin/bash
#
# Builds ARM Trusted Firmware, and generates FIPs with UEFI
# for the supported platforms. Not intended to be called directly,
# invoked from uefi-build.sh.
#
# Board configuration is extracted from
# parse-platforms.py and platforms.config.
#

TOOLS_DIR="`dirname $0`"
. "$TOOLS_DIR"/common-functions
OUTPUT_DIR="$PWD"/uefi-build

function usage
{
	echo "usage:"
	echo "atf-build.sh -e <EDK2 source directory> -t <UEFI build profile/toolchain> <platform>"
	echo
}

function build_platform
{
	if [ X"$EDK2_DIR" = X"" ];then
		echo "EDK2_DIR not set!" >&2
		return 1
	fi

	echo "PLATFORM_CONFIG: $PLATFORM_CONFIG"
	echo -n "LEIF: "
	$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o build_atf

	if [ X"`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o build_atf`" = X"" ]; then
		echo "Platform '$1' is not configured to build ARM Trusted Firmware."
		return 0
	fi

	ATF_PLATFORM=`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o atf_platform`
	if [ X"$ATF_PLATFORM" = X"" ]; then
		ATF_PLATFORM=$1
	fi

	#
	# Read platform configuration
	#
	PLATFORM_NAME="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o longname`"
	PLATFORM_ARCH="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o arch`"
	PLATFORM_IMAGE_DIR="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o uefi_image_dir`"
	unset BL30 BL31 BL32 BL33
	BL30="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o scp_bin`"
	BL31="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o el3_bin`"
	BL32="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o tos_bin`"
	BL33="$EDK2_DIR/Build/$PLATFORM_IMAGE_DIR/$BUILD_PROFILE/FV/`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $1 get -o uefi_bin`"
	export BL33

	#
	# Set up cross compilation variables (if applicable)
	#
	set_cross_compile
	CROSS_COMPILE="$TEMP_CROSS_COMPILE"
	echo "Building $PLATFORM_NAME - $BUILD_PROFILE"
	echo "CROSS_COMPILE=\"$TEMP_CROSS_COMPILE\""

	if [ X"$BL30" != X"" ]; then
		BL30="${EDK2_DIR}"/"${BL30}"
	fi
	if [ X"$BL31" != X"" ]; then
		BL31="${EDK2_DIR}"/"${BL31}"
	fi
	if [ X"$BL32" != X"" ]; then
		BL32="${EDK2_DIR}"/"${BL32}"
	fi
	export BL30 BL31 BL32

	#
	# Build ARM Trusted Firmware and create FIP
	#
	CROSS_COMPILE="$CROSS_COMPILE" make PLAT="$ATF_PLATFORM" all fip || return 1

	#
	# Copy resulting images to UEFI image dir
	#
	cp -a build/"$ATF_PLATFORM"/release/{bl1,fip}.bin "$EDK2_DIR/Build/$PLATFORM_IMAGE_DIR/$BUILD_PROFILE/FV/"
}

# Check to see if we are in a trusted firmware directory
# refuse to continue if we aren't
if [ ! -d bl32 ]
then
	echo "ERROR: we aren't in the arm-trusted-firmware directory."
	usage
	exit 1
fi

build=

if [ $# = 0 ]
then
	usage
	exit 1
else
	while [ "$1" != "" ]; do
		case $1 in
			"-e" )
				shift
				EDK2_DIR="$1"
				;;
			"/h" | "/?" | "-?" | "-h" | "--help" )
				usage
				exit
				;;
			"-t" )
				shift
				BUILD_PROFILE="$1"
				;;
			* )
				build="$1"
				;;
		esac
		shift
	done
fi

if [ X"$build" = X"" ]; then
	echo "No platform specified!" >&2
	echo
	usage
	exit 1
fi

build_platform $build
exit $?
