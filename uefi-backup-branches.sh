#!/bin/bash
################################################################################
# backup all the main branches
# - topic branches
# - tracking branches, eg armlt-tracking and linaro-tracking
# - master
# - tianocore-edk2* upstreams
################################################################################


################################################################################
function usage
{
	echo "Usage: $0"
}
################################################################################

current_branch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
branches=(
	`git branch --list linaro-topic-* | sed "s/*//"`
	master
	armlt-tracking
	linaro-tracking
	tianocore-edk2
	tianocore-edk2-fatdriver2
	tianocore-edk2-basetools
)

for branch in "${branches[@]}" ; do
	echo "--------------------------------------------------------------------------------"
	echo "Backing up $branch to previous-$branch"
	git branch -D previous-$branch
	git checkout $branch
	git branch previous-$branch

	if [ "$?" != "0" ]
	then
		echo "********************************************************************************"
		echo "Error during backup of $branch"
		echo "********************************************************************************"
		exit 1
	fi
done

git checkout $current_branch
