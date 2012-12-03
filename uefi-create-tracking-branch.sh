#!/bin/bash

git checkout master
git branch -D linaro-tracking
git branch linaro-tracking
git checkout linaro-tracking

git merge linaro-tracking-a5
git merge linaro-tracking-a9
git merge linaro-tracking-basetools
git merge linaro-tracking-menu
git merge linaro-tracking-local-fdt
git merge linaro-tracking-misc
git merge linaro-tracking-origen
git merge linaro-tracking-panda
git merge linaro-tracking-tc1
git merge linaro-tracking-tc2

