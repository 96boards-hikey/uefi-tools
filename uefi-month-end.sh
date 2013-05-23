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
force_update_branch $(uefi_next_current_month_branch) linaro-release
git tag $(uefi_next_release_tag)

echo "--------------------------------------------------------------------------------"
echo "Update global tracking branches"
echo "--------------------------------------------------------------------------------"
force_update_branch $(uefi_next_current_month_branch) linaro-tracking

# Force armlt-tracking to match linaro-tracking exactly
git branch -D armlt-tracking
git branch armlt-tracking linaro-tracking

