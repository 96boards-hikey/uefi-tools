#!/bin/bash

git checkout master
git branch -D armlt-tracking
git branch armlt-tracking
git checkout armlt-tracking

git merge armlt-tracking-a5
git merge armlt-tracking-a9
git merge armlt-tracking-basetools
git merge armlt-tracking-menu
git merge armlt-tracking-local-fdt
git merge armlt-tracking-misc
git merge armlt-tracking-origen
git merge armlt-tracking-panda
git merge armlt-tracking-tc1
git merge armlt-tracking-tc2

