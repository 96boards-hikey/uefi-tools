#!/bin/bash
################################################################################
# Setup the tree for a new month
#
# The general idea is to
# 1) merge all the topic branches into the monthly tracking branch & tag it
#    as with the latest -rc number
# 2) update the linaro-tracking branch that follows the monthly tracking branch
################################################################################


################################################################################
# Check all the parameters
# we should pass in the YY.MM used for the release, eg. "13.01" for January 2013
# and a number for the release candidate, eg, 2.

version=`git tag --list linaro-uefi-*-rc* | tail -1`
[[ "$version" =~ (.*[^0-9])([0-9]+)$ ]] && version="${BASH_REMATCH[1]}$((${BASH_REMATCH[2]} + 1))";
RC=`echo $version | sed 's#linaro-uefi-.*-rc##g'`
YYYYMM=`echo $version | sed 's#linaro-uefi-##g' | sed 's#-rc.*##g'`

git tag --list linaro-uefi-$YYYYMM-rc$RC
if [ "$?" = "0" ]
then
	echo "linaro-uefi-$YYYYMM-rc$RC already exists, you should use a new RC number"
else
	echo "YAY! you're using a new RC number"
fi

################################################################################
MONTH_BRANCH=linaro-tracking-$YYYYMM
#UEFI_NEXT_GIT=uefi-next.git
UEFI_NEXT_GIT=`pwd`
INTERNAL_MONTH_BRANCH=linaro-internal-tracking-$YYYYMM
################################################################################

echo "--------------------------------------------------------------------------------"
echo "CONFIG"
echo "--------------------------------------------------------------------------------"
echo "YYYYMM                $YYYYMM"
echo "RC                    $RC"
echo "MONTH_BRANCH          $MONTH_BRANCH"
echo "INTERNAL_MONTH_BRANCH $INTERNAL_MONTH_BRANCH"
echo "UEFI_NEXT_GIT         $UEFI_NEXT_GIT"
echo "--------------------------------------------------------------------------------"

################################################################################
# First, merge all the topic branches that have changed into the monthly tracking branch
# I don't know how we tell "if it's changed", but I think merge takes care of it.
################################################################################

topics=(`git branch --list linaro-topic-* | sed "s/*//"`)

for topic in "${topics[@]}" ; do

	# update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Merging $topic into $MONTH_BRANCH"
	git checkout $MONTH_BRANCH
	git merge $topic
	git checkout $INTERNAL_MONTH_BRANCH
	git merge $topic

done

# Tag the latest merges
git checkout $MONTH_BRANCH
git tag linaro-uefi-$YYYYMM-rc$RC

# Update linaro-tracking
git checkout linaro-tracking
git merge -Xtheirs linaro-tracking-$YYYYMM

# re-create armlt-tracking to match linaro-tracking
git checkout armlt-tracking
git merge -Xtheirs linaro-tracking

################################################################################
################################################################################
# Now update the Private/Internal tree
################################################################################
################################################################################
git checkout $INTERNAL_MONTH_BRANCH

topics=(`git branch --list linaro-internal-topic-* | sed "s/*//"`)

for topic in "${topics[@]}" ; do

	# update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Merging $topic into $INTERNAL_MONTH_BRANCH"
	git checkout $INTERNAL_MONTH_BRANCH
	git merge $topic

done

exit
################################################################################
