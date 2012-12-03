#!/bin/bash

# 1) update source trees
git checkout edk2
git pull edk2
git checkout edk2-fatdriver2
git pull edk2-fatdriver2

# 2) create a new master branch
git checkout edk2
git branch -D master
git branch master
git checkout master

# 3) pull edk2-fatdriver2 into the master branch
TREE=edk2-fatdriver2
git merge -s ours --no-commit $TREE/trunk
git read-tree --prefix=edk2/FatPkg/ -u $TREE:FatPkg
git commit -m "Adding $TREE FatPkg into edk2 tree"

# 4) rebase tracking branches
git checkout linaro-tracking-a5
git rebase master
git checkout linaro-tracking-a9
git rebase master
git checkout linaro-tracking-menu
git rebase master
git checkout linaro-tracking-misc
git rebase master
git checkout linaro-tracking-origen
git rebase master
git checkout linaro-tracking-panda
git rebase master
git checkout linaro-tracking-tc1
git rebase master
git checkout linaro-tracking-tc2

git checkout master
git branch -D linaro-tracking
git branch linaro-tracking
git checkout linaro-tracking

git merge linaro-tracking-a5
git merge linaro-tracking-a9
git merge linaro-tracking-local-fdt
git merge linaro-tracking-menu
git merge linaro-tracking-misc
git merge linaro-tracking-origen
git merge linaro-tracking-panda
git merge linaro-tracking-tc1
git merge linaro-tracking-tc2

