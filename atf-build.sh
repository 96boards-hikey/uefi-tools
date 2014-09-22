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

	if [ X"`$TOOLS_DIR/parse-platforms.py -p $1 get -o build_atf`" = X"" ]; then
		echo "Platform '$1' is not configured to build ARM Trusted Firmware."
		return 0
	fi
	#
	# Read platform configuration
	#
	PLATFORM_NAME="`$TOOLS_DIR/parse-platforms.py -p $1 get -o longname`"
	PLATFORM_ARCH="`$TOOLS_DIR/parse-platforms.py -p $1 get -o arch`"
	PLATFORM_IMAGE_DIR="`$TOOLS_DIR/parse-platforms.py -p $1 get -o uefi_image_dir`"
	PLATFORM_UEFI_IMAGE="$EDK2_DIR/Build/$PLATFORM_IMAGE_DIR/$BUILD_PROFILE/FV/`$TOOLS_DIR/parse-platforms.py -p $1 get -o uefi_bin`"

	#
	# Set up cross compilation variables (if applicable)
	#
	set_cross_compile
	CROSS_COMPILE="$TEMP_CROSS_COMPILE"
	echo "Building $PLATFORM_NAME - $BUILD_PROFILE"
	echo "CROSS_COMPILE=\"$TEMP_CROSS_COMPILE\""

	#
	# Build ARM Trusted Firmware and create FIP
	#
	CROSS_COMPILE="$CROSS_COMPILE" BL33="$PLATFORM_UEFI_IMAGE" make PLAT="$1" all fip || return 1

	#
	# Copy resulting images to UEFI image dir
	#
	cp -a build/"$1"/release/{bl1,fip}.bin "$EDK2_DIR/Build/$PLATFORM_IMAGE_DIR/$BUILD_PROFILE/FV/"
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
