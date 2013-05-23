#!/bin/bash
################################################################################
# Month End
#
# At the end of the month, we:
#
# 1) Merge the current monthly branch to the release branch
# 2) Make sure the linaro/armlt-tracking branches are up-to-date
# 3) Tag the release branch with linaro-uef-YYYY.MM
################################################################################


################################################################################
source uefi-common
################################################################################

echo "--------------------------------------------------------------------------------"
echo "Updating linaro-release"
echo "--------------------------------------------------------------------------------"
git checkout linaro-release
git merge -Xtheirs $(uefi_next_current_month_branch)
git tag $(uefi_next_release_tag)

echo "--------------------------------------------------------------------------------"
echo "Update global tracking branches"
echo "--------------------------------------------------------------------------------"
git checkout linaro-tracking
git merge -Xtheirs $(uefi_next_release_tag)
git checkout armlt-tracking
git merge -Xtheirs $(uefi_next_release_tag)


