#!/bin/bash

# I am doing this from my local copies of trees, I guess I should really do this from trees pulled from g.l.o each time

# This is my working directory:
# cd /linaro/g.l.o/arm/uefi/

# This is how I cloned the trees from g.l.o
# git clone git://git.linaro.org/arm/uefi/uefi.git uefi.git
# git clone git://git.linaro.org/arm/uefi/uefi.git uefi-next.git

# These are my tree on my machine
RELEASE_TREE=/linaro/g.l.o/arm/uefi/uefi.git
NEXT_TREE=/linaro/g.l.o/arm/uefi/uefi-next.git

# fetch the latest updates from uefi-next
cd $RELEASE_TREE
git remote add uefi-next $NEXT_TREE
git fetch -f uefi-next

# Merge them in.
# Using "-s ours" stops conflicts.
# Using "--no-commit" stops it attmepting to commmit because it will a) fail and b) produce the wrong output!
git merge -s ours --no-commit uefi-next/armlt-tracking

# Now we should force update the release tree to match the next tree
git rm -r edk2
cp -R ../uefi-next.git/edk2 .

# Add all the files and commit them with a sensible message
git add *
git commit -s -m "Merge branch 'armlt-tracking' of git://git.linaro.org/arm/uefi/uefi-next"


