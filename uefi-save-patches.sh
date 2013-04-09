#!/bin/bash

curr_branch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`

version=`git tag --list linaro-uefi-*-rc* | tail -1`
[[ "$version" =~ (.*[^0-9])([0-9]+)$ ]] && version="${BASH_REMATCH[1]}$((${BASH_REMATCH[2]} + 1))";
RC=`echo $version | sed 's#linaro-uefi-.*-rc##g'`
YYYYMM=`echo $version | sed 's#linaro-uefi-##g' | sed 's#-rc.*##g'`

BASE_COMMIT=`git log -1 linaro-base-$YYYYMM | head -1 | sed 's/commit //'`

topics=(`git branch --list linaro-topic-* | sed "s/*//"`)

for topic in "${topics[@]}" ; do

	SAVE_DIR=/linaro/uefi/master/patches/$YYYYMM/$topic

	# update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Saving all patches on $topic into $SAVE_DIR"
	git checkout $topic

	echo "Create patches since $BASE_COMMIT..."
	git format-patch $BASE_COMMIT

	echo "Move patches..."
	mkdir -p $SAVE_DIR
	mv *.patch $SAVE_DIR

done

git checkout $curr_branch
