#!/bin/bash

git checkout master
git branch -D linaro-tracking
git branch linaro-tracking
git checkout linaro-tracking

branches=(`git branch | grep linaro-tracking-`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Merging branch $branch"
	echo "----------------------------------------"
	git merge $branch
done

