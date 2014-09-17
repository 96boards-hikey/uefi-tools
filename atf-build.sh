#!/bin/bash
#
# Builds ARM Trusted Firmware, and generates FIPs with UEFI
# for the supported platforms.
#
# Board configuration is extracted from
# parse-platforms.sh and platforms.config.
#

TOOLS_DIR="`dirname $0`"
. "$TOOLS_DIR"/common-functions

function usage
{
	echo "usage:"
	echo -n "atf-build.sh -e <EDK2 source directory> -t <UEFI build profile/toolchain> [ all "
	for platform in "${platforms[@]}" ; do
	    echo -n "| $platform "
	done
	echo "]"
	printf "%8s\tbuild %s\n" "all" "all supported platforms"
	for platform in "${platforms[@]}" ; do
		PLATFORM_NAME="$platform"_LONGNAME
		printf "%8s\tbuild %s\n" "$platform" "${PLATFORM_NAME}"
	done
}

function build_platform
{
	if [ X"$EDK2_DIR" = X"" ];then
		echo "EDK2_DIR not set!" >&2
		return 1
	fi
	PLATFORM_NAME="`$TOOLS_DIR/parse-platforms.sh -p $1 get-longname`"
	PLATFORM_ARCH="`$TOOLS_DIR/parse-platforms.sh -p $1 get-arch`"
	PLATFORM_IMAGE_DIR="`$TOOLS_DIR/parse-platforms.sh -p $1 get-uefi_image_dir`"
	PLATFORM_UEFI_IMAGE="$EDK2_DIR/Build/$PLATFORM_IMAGE_DIR/$BUILD_PROFILE/FV/`$TOOLS_DIR/parse-platforms.sh -p $1 get-uefi_bin`"

	set_cross_compile
	CROSS_COMPILE="$TEMP_CROSS_COMPILE"

	echo "Building $PLATFORM_NAME - $BUILD_PROFILE"
	echo "CROSS_COMPILE=\"$TEMP_CROSS_COMPILE\""

	CROSS_COMPILE="$CROSS_COMPILE" BL33="$PLATFORM_UEFI_IMAGE" make PLAT="$1" all fip
	result_log $? "$PLATFORM_NAME"
}

builds=()
platforms=()
platformlist=`$TOOLS_DIR/parse-platforms.sh shortlist`
for platform in $platformlist; do
    if $TOOLS_DIR/parse-platforms.sh -p $platform get-build_atf; then
        platforms=(${platforms[@]} $platform)
    fi
done

# If there were no args, display a menu
if [ $# = 0 ]
then
	read -p "$(
			f=0
			for platform in "${platforms[@]}" ; do
					echo "$((++f)): $platform"
			done
			echo $((++f)): all

			echo -ne '> '
	)" selection

	if [ "$selection" -eq $((${#platforms[@]} + 1)) ]; then
		builds=(${platforms[@]})
	else
		builds="${platforms[$((selection-1))]}"
	fi
else
	while [ "$1" != "" ]; do
		case $1 in
			all )
				builds=(${platforms[@]})
				break
				;;
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
				MATCH=0
				for platform in "${platforms[@]}" ; do
					if [ "$1" == $platform ]; then
						MATCH=1
						builds=(${builds[@]} "$platform")
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

# Check to see if we are in a trusted firmware directory
# refuse to continue if we aren't
if [ ! -e bl32 ]
then
	echo "ERROR: we aren't in the arm-trusted-firmware directory."
	exit 1
fi

for platform in "${builds[@]}" ; do
	build_platform $platform
done

result_print
