#!/bin/bash
################################################################################
# Setup the tree for a new month
#
# The general idea is to
# 1) merge all the topic branches into the monthly tracking branch
# 2) also merge them to the internal monthly tracking branch
# 3) tag the monthly tracking branch with the latest -rc number
# 4) update the linaro-tracking branch that follows the monthly tracking branch
# 5) update the internal monthly tracking branch with all the internal topics.
################################################################################


################################################################################
source uefi-common
################################################################################

echo "--------------------------------------------------------------------------------"
echo "CONFIG"
echo "--------------------------------------------------------------------------------"
echo "Current Month Branch  $(uefi_next_current_month)"
echo "Internal Month Branch $(uefi_next_internal_current_month)"
echo "uefi-next dir         $UEFI_NEXT_GIT"
echo "Next RC tag           $(uefi_next_next_rc)"
echo "Next internal RC tag  $(uefi_next_internal_next_rc)"
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
	echo "Merging $topic into $(uefi_next_current_month)$"
	git checkout $(uefi_next_current_month)
	git merge $topic
	git checkout $(uefi_next_internal_current_month)
	git merge $topic

done

# Tag the latest merges
git checkout $(uefi_next_current_month)
git tag $(uefi_next_next_rc)

# Update linaro-tracking
git checkout linaro-tracking
git merge -Xtheirs $(uefi_next_current_month)

# re-create armlt-tracking to match linaro-tracking
git checkout armlt-tracking
git merge -Xtheirs linaro-tracking

################################################################################
################################################################################
# Now update the Private/Internal tree
################################################################################
################################################################################
git checkout $(uefi_next_internal_current_month)

topics=(`git branch --list linaro-internal-topic-* | sed "s/*//"`)

for topic in "${topics[@]}" ; do

	# update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Merging $topic into $(uefi_next_internal_current_month)"
	git checkout $(uefi_next_internal_current_month)
	git merge $topic

done

git tag $(uefi_next_internal_next_rc)

exit
################################################################################
