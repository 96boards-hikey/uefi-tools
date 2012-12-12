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

# 4) Create the main tracking branch
git checkout master
git branch -D linaro-tracking
git branch linaro-tracking
git checkout linaro-tracking

# 5) rebase topic branches and merge them into the main tracking branch
branches=(`git branch | grep linaro-tracking-`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Rebasing branch $branch"
	echo "----------------------------------------"
	git checkout $branch
	git rebase master
	git checkout linaro-tracking
	echo "----------------------------------------"
	echo "Merging branch $branch"
	echo "----------------------------------------"
	git merge $branch

	# do this to clean up the log
	sleep 1
done

# create the armlt-tracking branch
#   the CI job depends on this branch, so we need it
#   in this case, it's just a clone of linaro-tracking
git branch -D armlt-tracking
git branch armlt-tracking

