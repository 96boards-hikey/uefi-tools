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
git checkout armlt-tracking-a5
git rebase master
git checkout armlt-tracking-a9
git rebase master
git checkout armlt-tracking-menu
git rebase master
git checkout armlt-tracking-misc
git rebase master
git checkout armlt-tracking-origen
git rebase master
git checkout armlt-tracking-panda
git rebase master
git checkout armlt-tracking-tc1
git rebase master
git checkout armlt-tracking-tc2

git checkout master
git branch -D armlt-tracking
git branch armlt-tracking
git checkout armlt-tracking

git merge armlt-tracking-a5
git merge armlt-tracking-a9
git merge armlt-tracking-menu
git merge armlt-tracking-misc
git merge armlt-tracking-origen
git merge armlt-tracking-panda
git merge armlt-tracking-tc1
git merge armlt-tracking-tc2

