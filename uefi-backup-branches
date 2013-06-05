#!/bin/bash
################################################################################
# backup all the main branches
# - topic branches
# - tracking branches, eg armlt-tracking and linaro-tracking
# - master
# - tianocore-edk2* upstreams
################################################################################
source uefi-common
################################################################################


################################################################################
function usage
{
	echo "Usage: $0 <prefix>"
}
################################################################################

if [ "$1" = "" ]
then
	PREFIX="previous"
	echo "Using default prefix: $PREFIX"
else
	PREFIX=$1
    echo "PREFIX is $PREFIX"
fi

cd $UEFI_NEXT_GIT

current_branch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
branches=(
	`git branch --list linaro-topic-* linaro-internal-feature-* linaro-internal-topic-* | sed "s/*//"`
	master
	armlt-tracking
	linaro-tracking
	tianocore-edk2
	tianocore-edk2-fatdriver2
	tianocore-edk2-basetools
)

for branch in "${branches[@]}" ; do
	echo "--------------------------------------------------------------------------------"
	echo "Backing up $branch to $PREFIX-$branch"

	# the only reason for checking out $branch is to make sure we aren't currently checking
	# out "$PREFIX-branch"
	git checkout $branch
	git branch -D $PREFIX-$branch
	git branch $PREFIX-$branch $branch

	if [ "$?" != "0" ]
	then
		echo "********************************************************************************"
		echo "Error during backup of $branch"
		echo "********************************************************************************"
		exit 1
	fi
done

git checkout $current_branch
