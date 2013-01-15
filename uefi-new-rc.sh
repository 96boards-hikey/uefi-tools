#!/bin/bash
################################################################################
# Setup the tree for a new month
#
# The general idea is to
# 1) update the master branch to the latest tianocore sources & tag it
# 2) rebase all the topic branches to the master branch
# 3) create a new monthly tracking branch, based on master
# 4) merge all the topic branches into the tracking branch & tag it as "rc1"
# 5) create the "latest" tracking branch that follows the monthly tracking branch
################################################################################


################################################################################
function usage
{
	echo "Usage: $0"
	echo "   YY.MM X        eg. 13.01 3 means release 13.01-rc3"
}
################################################################################
# Check all the parameters
# we should pass in the YY.MM used for the release, eg. "13.01" for January 2013
# and a number for the release candidate, eg, 2.

YYMM=$1
RC=$2

if [ "$YYMM" = "" ]
then
	echo "You need to specify a month tag, eg. 13.01"
	exit
fi

git branch | grep linaro-tracking-$YYMM

if [ "$?" = "1" ]
then
	echo "linaro-tracking-$YYMM does not exist, you should use in existing tracking branch"
else
	echo "YAY! linaro-tracking-$YYMM exists"
fi


git tag | grep linaro-uefi-$YYMM-rc$RC

if [ "$?" = "0" ]
then
	echo "linaro-uefi-$YYMM-rc$RC already exists, you should use a new RC number"
else
	echo "YAY! you're using a new RC number"
fi

################################################################################
BASE_DIR=/linaro/lt/uefi
MASTER=master
MONTH_BRANCH=linaro-tracking-$YYMM
#UEFI_NEXT_GIT=uefi-next.git
UEFI_NEXT_GIT=`pwd`
################################################################################

echo "--------------------------------------------------------------------------------"
echo "CONFIG"
echo "--------------------------------------------------------------------------------"
echo "YYMM          $YYMM"
echo "BASE_DIR      $BASE_DIR"
echo "MASTER        $MASTER"
echo "MONTH_BRANCH  $MONTH_BRANCH"
echo "UEFI_NEXT_GIT $UEFI_NEXT_GIT"
echo "--------------------------------------------------------------------------------"

################################################################################
# First, merge all the topic branches that have changed into the monthly tracking branch
# I don't know how we tell "if it's changed", but I think merge takes care of it.
################################################################################

topics=(`git branch | grep linaro-topic- | sed "s/*//"`)

for topic in "${topics[@]}" ; do

	# update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Merging $topic into $MONTH_BRANCH"
	git checkout $MONTH_BRANCH
	git merge $topic

done

# Tag the latest merges
git checkout linaro-tracking-$YYMM
git tag linaro-uefi-$YYMM-rc$RC

# Update linaro-tracking
git checkout linaro-tracking
git merge linaro-tracking-$YYMM

# re-create armlt-tracking to match linaro-tracking
git branch -D armlt-tracking
git branch armlt-tracking


exit
################################################################################
