#!/bin/bash

#
# Board Configuration Section
# ===========================
#
# Board configuration moved to parse-platforms.py and platforms.config.
#
# No need to edit below unless you are changing script functionality.
#

TOOLS_DIR="`dirname $0`"
. "$TOOLS_DIR"/common-functions
PLATFORM_CONFIG=""
ATF_DIR=
TOS_DIR=

# Number of threads to use for build
export NUM_THREADS=$((`getconf _NPROCESSORS_ONLN` + 1))

function build_platform
{
	PLATFORM_NAME="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o longname`"
	PLATFORM_PREBUILD_CMDS="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o prebuild_cmds`"
	PLATFORM_BUILDFLAGS="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o buildflags`"
	PLATFORM_BUILDFLAGS="$PLATFORM_BUILDFLAGS ${EXTRA_OPTIONS[@]}"
	PLATFORM_BUILDCMD="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o buildcmd`"
	PLATFORM_DSC="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o dsc`"
	PLATFORM_ARCH="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o arch`"

	set_cross_compile
	CROSS_COMPILE="$TEMP_CROSS_COMPILE"

	echo "Building $PLATFORM_NAME - $PLATFORM_ARCH"
	echo "CROSS_COMPILE=\"$TEMP_CROSS_COMPILE\""
	echo "$board"_BUILDFLAGS="'$PLATFORM_BUILDFLAGS'"

	if [ "$TARGETS" == "" ]; then
		TARGETS=( RELEASE )
	fi

	gcc_version=$(${CROSS_COMPILE}gcc -dumpversion)
	case $gcc_version in
		4.6*|4.7*|4.8*|4.9*)
		export TOOLCHAIN=GCC$(echo ${gcc_version} | awk -F. '{print $1$2}')
		echo "TOOLCHAIN is ${TOOLCHAIN}"
		;;
		*)
		echo "Unknown toolchain version '$gcc_version'" >&2
		echo "Attempting to build using GCC49 profile." >&2
		export TOOLCHAIN=GCC49
		;;
	esac

	export ${TOOLCHAIN}_${PLATFORM_ARCH}_PREFIX=$CROSS_COMPILE
	echo "Toolchain prefix: ${TOOLCHAIN}_${PLATFORM_ARCH}_PREFIX=$CROSS_COMPILE"

	for target in "${TARGETS[@]}" ; do
		if [ X"$PLATFORM_PREBUILD_CMDS" != X"" ]; then
			echo "Run pre build commands"
			eval ${PLATFORM_PREBUILD_CMDS}
		fi
		if [ X"$PLATFORM_BUILDCMD" == X"" ]; then
			echo  ${TOOLCHAIN}_${PLATFORM_ARCH}_PREFIX=$CROSS_COMPILE build -n $NUM_THREADS -a "$PLATFORM_ARCH" -t ${TOOLCHAIN} -p "$PLATFORM_DSC" -b "$target" \
				${PLATFORM_BUILDFLAGS}
			build -n $NUM_THREADS -a "$PLATFORM_ARCH" -t ${TOOLCHAIN} -p "$PLATFORM_DSC" -b "$target" \
				${PLATFORM_BUILDFLAGS}
		else
			${PLATFORM_BUILDCMD} -b "$target" ${PLATFORM_BUILDFLAGS}
		fi
		RESULT=$?
		if [ $RESULT -eq 0 ]; then
			if [ X"$TOS_DIR" != X"" ]; then
				pushd $TOS_DIR >/dev/null
				$TOOLS_DIR/tos-build.sh -e "$EDK2_DIR" -t "$target"_${TOOLCHAIN} $board
				RESULT=$?
				popd >/dev/null
			fi
		fi
		if [ $RESULT -eq 0 ]; then
			if [ X"$ATF_DIR" != X"" ]; then
				pushd $ATF_DIR >/dev/null
				$TOOLS_DIR/atf-build.sh -e "$EDK2_DIR" -t "$target"_${TOOLCHAIN} $board
				RESULT=$?
				popd >/dev/null
			fi
		fi
		result_log $RESULT "$PLATFORM_NAME $target"
	done
}


function uefishell
{
	BUILD_ARCH=`uname -m`
	case $BUILD_ARCH in
		arm*)
			ARCH=ARM
			;;
		aarch64)
			ARCH=AARCH64
			;;
		*)
			unset ARCH
			;;
	esac
	export ARCH
	echo "Setting up shell for building UEFI"
	export EDK_TOOLS_PATH=`pwd`/BaseTools
	. edksetup.sh BaseTools
	make -C $EDK_TOOLS_PATH
	if [ $? -ne 0 ]; then
		echo " !!! UEFI BaseTools failed to build !!! " >&2
		exit 1
	fi
}


function usage
{
	echo "usage:"
	echo -n "uefi-build.sh [-b DEBUG | RELEASE] [ all "
	for board in "${boards[@]}" ; do
	    echo -n "| $board "
	done
	echo "]"
	printf "%8s\tbuild %s\n" "all" "all supported platforms"
	for board in "${boards[@]}" ; do
		PLATFORM_NAME="`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG -p $board get -o longname`"
		printf "%8s\tbuild %s\n" "$board" "${PLATFORM_NAME}"
	done
}

if [ $1 == "-c" ]; then
	shift
	case "$1" in
		/*)
			PLATFORM_CONFIG="-c $1"
		;;
		*)
			PLATFORM_CONFIG="-c `readlink -f \"$1\"`"
		;;
	esac
	echo "Platform config file: '$1'"
	export PLATFORM_CONFIG
	shift
fi

builds=()
boards=()
boardlist=`$TOOLS_DIR/parse-platforms.py $PLATFORM_CONFIG shortlist`
for board in $boardlist; do
    boards=(${boards[@]} $board)
done

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
			"-a" )
				shift
				ATF_DIR="$1"
				;;
			"-s" )
				shift
				export TOS_DIR="$1"
				;;
			"-b" | "--build" )
				shift
				echo "Adding Build profile: $1"
				TARGETS=( ${TARGETS[@]} $1 )
				;;
			"-D" )
				shift
				echo "Adding option: -D $1"
				EXTRA_OPTIONS=( ${EXTRA_OPTIONS[@]} "-D" $1 )
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

# Check to see if we are in a UEFI repository
# refuse to continue if we aren't
if [ ! -e BaseTools ]
then
	echo "ERROR: we aren't in the UEFI directory."
	echo "       I can tell because I can't see the BaseTools directory"
	exit 1
fi

EDK2_DIR="$PWD"

if [[ "${EXTRA_OPTIONS[@]}" != *"FIRMWARE_VER"* ]]; then
	if test -d .git && head=`git rev-parse --verify --short HEAD 2>/dev/null`; then
		FIRMWARE_VER=`git rev-parse --short HEAD`
		if ! git diff-index --quiet HEAD --; then
			FIRMWARE_VER="${FIRMWARE_VER}-dirty"
		fi
		EXTRA_OPTIONS=( $EXTRA_OPTIONS "-D" FIRMWARE_VER=$FIRMWARE_VER )
	fi
fi

uefishell

for board in "${builds[@]}" ; do
	build_platform
done

result_print
