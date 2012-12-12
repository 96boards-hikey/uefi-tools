#!/bin/bash

if [ "$1" = "" ]
then
	REPO="uefi-next"
	echo "Using default repo: $REPO"
else
	REPO=$1
    echo "REPO is $REPO"
fi


branches=(`git branch | grep linaro-tracking`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $1"
	echo "----------------------------------------"
	git push -f $REPO $branch
done

git push -f $REPO armlt-tracking
