#!/bin/bash

# I am doing this from my local copies of trees, I guess I should really do this from trees pulled from g.l.o each time

# This is my working directory:
# cd /linaro/g.l.o/arm/uefi/

# This is how I cloned the trees from g.l.o
# git clone git://git.linaro.org/arm/uefi/uefi.git uefi.git
# git clone git://git.linaro.org/arm/uefi/uefi.git uefi-next.git

# These are my tree on my machine
RELEASE_TREE=/linaro/lt/uefi/uefi.git
NEXT_TREE=/linaro/lt/uefi/uefi-next.git

echo "--------------------------------------------------------------------------------"
echo "Find release tag"
echo "--------------------------------------------------------------------------------"
cd $NEXT_TREE
TAG=`git tag | grep linaro-uefi | grep -v rc | tail -1`
echo "Release tag is '$TAG'"

echo "--------------------------------------------------------------------------------"
echo "Add uefi-next remote"
echo "--------------------------------------------------------------------------------"
# fetch the latest updates from uefi-next
cd $RELEASE_TREE
git remote add uefi-next $NEXT_TREE
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
echo "Force the contents or uefi-next into this tree"
echo "--------------------------------------------------------------------------------"
# Now we should force update the release tree to match the next tree
git rm -r edk2
cp -R $NEXT_TREE/* .

echo "--------------------------------------------------------------------------------"
echo "Add all the files and commit them"
echo "--------------------------------------------------------------------------------"
# Add all the files and commit them with a sensible message
git add *
git commit -s -m "Merge branch 'armlt-tracking' of git://git.linaro.org/arm/uefi/uefi-next"
git tag $TAG

