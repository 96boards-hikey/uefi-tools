#!/bin/bash

if [ "$1" = "" ]
then
	REPO="uefi-next"
	echo "Using default repo: $REPO"
else
	REPO=$1
    echo "REPO is $REPO"
fi


branches=(`git branch | grep linaro-tracking | sed "s/*//"`)

for branch in "${branches[@]}" ; do
	echo "----------------------------------------"
	echo "Pushing branch $branch to $REPO"
	echo "----------------------------------------"
	git push -f $REPO $branch
done

git push -f $REPO armlt-tracking
