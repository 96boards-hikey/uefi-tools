#!/bin/bash
################################################################################
# restore all the main branches with versions starting with $PREFIX
# - topic branches
# - tracking branches, eg armlt-tracking and linaro-tracking
# - master
# - tianocore-edk2* upstreams
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
	echo "Restoring $PREFIX-$branch to $branch"
	git checkout $PREFIX-$branch
	git branch -D $branch
	git branch $branch $PREFIX-$branch

	if [ "$?" != "0" ]
	then
		echo "********************************************************************************"
		echo "Error during restore of $branch"
		echo "********************************************************************************"
		exit 1
	fi
done

git checkout $current_branch
