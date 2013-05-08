#!/bin/bash
################################################################################
# Update uefi-next repo
#
# You can specifiy an alternative remote as the first parameter.
# nb. the remote has to have been added to the repo first.
#
# The public code goes to both the public and the private repo
#
################################################################################

if [ "$1" = "" ]
then
	REPO="uefi-next"
	echo "Using default repo: $REPO"
else
	REPO=$1
    echo "REPO is $REPO"
fi

INTERNAL_REPO=linaro-internal

################################################################################
# Update core branches
################################################################################
git push $REPO          master
git push $INTERNAL_REPO master
git push $REPO          tianocore-edk2
git push $INTERNAL_REPO tianocore-edk2
git push $REPO          tianocore-edk2-fatdriver2
git push $INTERNAL_REPO tianocore-edk2-fatdriver2
git push $REPO          tianocore-edk2-basetools
git push $INTERNAL_REPO tianocore-edk2-basetools

################################################################################
# Update topic branches
# Use "push -f" because topic branches are rebased
################################################################################
branches=(`git branch --list linaro-topic-* | sed "s/*//"`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $REPO"
	echo "----------------------------------------"
	# -f is needed because these branches are rebased
	git push -f $REPO $branch
	git push -f $INTERNAL_REPO $branch
done

################################################################################
# Update tracking branches
################################################################################
MONTH_BRANCH=`git branch --list linaro-tracking-* | tail -1 | sed "s/*//"`
echo "Pushing out monthly branch $REPO $MONTH_BRANCH..."
git push $REPO          $MONTH_BRANCH
git push $INTERNAL_REPO $MONTH_BRANCH

git push $REPO          armlt-tracking
git push $INTERNAL_REPO armlt-tracking
git push $REPO          linaro-tracking
git push $INTERNAL_REPO linaro-tracking
git push --tags $REPO
git push --tags $INTERNAL_REPO

################################################################################
# Update internal topic and feature branches on the internal tree
# Use "push -f" because topic/feature branches are/may be rebased
################################################################################
#
#   PPP  RRR   I  V   V   AA  TTTTT  EEEE
#   P  P R  R  I  V   V  A  A   T    E
#   PPP  RRR   I   V V   AAAA   T    EEE
#   P    RR    I   V V   A  A   T    E
#   P    R R   I    V    A  A   T    EEEE
#
# Everything from here down goes to the private repo
#
################################################################################

# make sure REPO isn't used again in this script
REPO=error

branches=(`git branch --list linaro-internal-topic-* linaro-internal-feature-* | sed "s/*//"`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $INTERNAL_REPO"
	echo "----------------------------------------"
	# -f is needed because these branches are rebased
	git push -f $INTERNAL_REPO $branch
done

################################################################################
# Update tracking branch
################################################################################
INTERNAL_MONTH_BRANCH=`git branch --list linaro-internal-tracking-* | tail -1 | sed "s/*//"`
echo "Pushing out monthly branch $INTERNAL_REPO $INTERNAL_MONTH_BRANCH..."
git push $INTERNAL_REPO $INTERNAL_MONTH_BRANCH

