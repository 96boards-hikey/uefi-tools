#!/bin/bash

################################################################################
source uefi-common
################################################################################

cd $UEFI_NEXT_GIT
git reset --hard HEAD && git clean -dfx
git checkout linaro-release

RELEASE_TAG=$(uefi_next_release_tag)
echo "--------------------------------------------------------------------------------"
echo "Release tag is '$RELEASE_TAG'"
echo "--------------------------------------------------------------------------------"

echo "--------------------------------------------------------------------------------"
echo "Add uefi-next remote"
echo "--------------------------------------------------------------------------------"
# fetch the latest updates from uefi-next
cd $UEFI_GIT
git remote add uefi-next $UEFI_NEXT_GIT
echo "--------------------------------------------------------------------------------"
echo "Fetch latest content from uefi-next"
echo "--------------------------------------------------------------------------------"
git fetch --no-tags -f uefi-next

echo "--------------------------------------------------------------------------------"
echo "Merge uefi-next/linaro-release"
echo "--------------------------------------------------------------------------------"
# Merge them in.
# Using "-s ours" stops conflicts.
# Using "--no-commit" stops it attmepting to commmit because it will a) fail and b) produce the wrong output!
git merge -s ours --no-commit uefi-next/linaro-release

echo "--------------------------------------------------------------------------------"
echo "Force the contents of uefi-next into this tree"
echo "--------------------------------------------------------------------------------"
# Now we should force update the release tree to match the next tree
git rm -r *
cp -R $UEFI_NEXT_GIT/* .

echo "--------------------------------------------------------------------------------"
echo "Add all the files and commit them"
echo "--------------------------------------------------------------------------------"
# Add all the files and commit them with a sensible message
git add *
git commit -s -m "Merge branch 'linaro-release' of $UEFI_NEXT_URL"
git tag $RELEASE_TAG

