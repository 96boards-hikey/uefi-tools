#!/bin/bash
################################################################################
# Update uefi-next repo
#
# You can specifiy an alternative remote as the first parameter.
# nb. the remote has to have been added to the repo first.
################################################################################

if [ "$1" = "" ]
then
	REPO="uefi-next"
	echo "Using default repo: $REPO"
else
	REPO=$1
    echo "REPO is $REPO"
fi

################################################################################
# Update core branches
################################################################################
git push $REPO master
git push $REPO tianocore-edk2
git push $REPO tianocore-edk2-fatdriver2
git push $REPO tianocore-edk2-basetools

################################################################################
# Update topic branches
# Use "push -f" because topic branches are rebased
################################################################################
branches=(`git branch --list linaro-topic-* | sed "s/*//"`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $REPO"
	echo "----------------------------------------"
	git push -f $REPO $branch
done

################################################################################
# Update tracking branches
################################################################################
MONTH_BRANCH=`git branch --list linaro-tracking-* | tail -1 | sed "s/*//"`)
echo "Pushing out monthly branch $REPO $MONTH_BRANCH..."
git push $REPO $MONTH_BRANCH

git push $REPO armlt-tracking
git push $REPO linaro-tracking
git push --tags $REPO
