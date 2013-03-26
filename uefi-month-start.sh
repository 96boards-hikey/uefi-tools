#!/bin/bash
################################################################################
# Setup the tree for a new month
#
# The general idea is to
# 1) update the master branch to the latest tianocore sources & tag it
# 2) rebase all the topic branches to the master branch
# 3) create a new monthly tracking branch, based on master
# 4) merge all the topic branches into the tracking branch & tag it as "rc1"
# 5) create the "latest" tracking branch that follows the monthly tracking branch
################################################################################


################################################################################
function usage
{
	echo "Usage: $0"
	echo "   -p|--pull        Pull the latest updates from the upstream repos first"
}
################################################################################
# Check all the parameters
# we should pass in the YYYY.MM used for the release, eg. "2013.01" for January 2013

YYYYMM=`date +%Y.%m`

while [ "$1" != "" ]; do
    case $1 in
        -p | --pull )
            PULL="yes"
            UPDATE="yes"
            ;;

        -u | --update )
            UPDATE="yes"
            ;;

		[0-9][0-9][0-9][0-9].[0-9][0-9])
			YYYYMM=$1
			;;

        /h | /? | -? | -h | --help )
            usage
            exit
            ;;
        -* )
            usage
			echo "unknown arg $1"
            exit 1
    esac
    shift
done


if [ "$YYYYMM" = "" ]
then
	echo "You need to specify a month tag, eg. 2013.01"
	exit
fi

################################################################################
GIT_BASE_DIR=/linaro/uefi/git
MASTER=master
MONTH_BRANCH=linaro-tracking-$YYYYMM
#UEFI_NEXT_GIT=uefi-next.git
UEFI_NEXT_GIT=`pwd`
################################################################################

echo "--------------------------------------------------------------------------------"
echo "CONFIG"
echo "--------------------------------------------------------------------------------"
echo "PULL          $PULL"
echo "UPDATE        $UPDATE"
echo "YYYYMM        $YYYYMM"
echo "GIT_BASE_DIR  $GIT_BASE_DIR"
echo "MASTER        $MASTER"
echo "MONTH_BRANCH  $MONTH_BRANCH"
echo "UEFI_NEXT_GIT $UEFI_NEXT_GIT"
echo "--------------------------------------------------------------------------------"

################################################################################
# 1) update the master branch
# 1.1) update the trees that act as our inputs

if [ "$PULL" = "yes" ]
then
	## TODO - we should probably have an option to update directly from upstream rather than via a local mirror
	echo "Updating local mirrors from upstream"
	echo "--------------------------------------------------------------------------------"
	echo "EDK2"
	pushd $GIT_BASE_DIR/edk2
	git checkout master
	git pull

	echo "--------------------------------------------------------------------------------"
	echo "EDK2-FATDRIVER2"
	cd $GIT_BASE_DIR/edk2-fatdriver2.git
	git checkout trunk
	git pull

	echo "--------------------------------------------------------------------------------"
	echo "BaseTools"
	cd $GIT_BASE_DIR/buildtools-BaseTools
	git checkout master
	git pull

	echo "--------------------------------------------------------------------------------"
	echo "Updated all local mirrors"
	echo "--------------------------------------------------------------------------------"
	popd
fi

if [ "$UPDATE" = "yes" ]
then
	## I have now updated my local copies, now update the branches on the local uefi-next.git
	echo "--------------------------------------------------------------------------------"
	echo "Updating local branches from local mirrors"
	echo "--------------------------------------------------------------------------------"
	echo "edk2"
	cd $UEFI_NEXT_GIT
	git checkout tianocore-edk2
	git pull tianocore-edk2 master

	echo "--------------------------------------------------------------------------------"
	echo "FatDriver2"
	git checkout tianocore-edk2-fatdriver2
	git pull tianocore-edk2-fatdriver2 trunk

	echo "--------------------------------------------------------------------------------"
	echo "BaseTools"
	git checkout tianocore-edk2-basetools
	git pull tianocore-edk2-basetools master

	# 1.2) update core branch
	echo "--------------------------------------------------------------------------------"
	echo "Updating $MASTER branch from local branches"
	git checkout $MASTER

	TREE=tianocore-edk2
	echo "--------------------------------------------------------------------------------"
	echo "Merge $TREE into $MASTER"
	git merge $TREE

	TREE=tianocore-edk2-fatdriver2
	echo "--------------------------------------------------------------------------------"
	echo "Pull $TREE into $MASTER"
	git pull tianocore-edk2-fatdriver2 trunk

	TREE=tianocore-edk2-basetools
	echo "--------------------------------------------------------------------------------"
	echo "Merge $TREE into $MASTER"
	git merge -s subtree tianocore-edk2-basetools

	echo "--------------------------------------------------------------------------------"
	echo "Updated local branches from local mirrors and merged to $MASTER"
	echo "--------------------------------------------------------------------------------"
else
	echo "********************************************************************************"
	echo "WARNING: using existing local mirrors and $MASTER branch"
	echo "********************************************************************************"
fi

# 1.3) tag it
git checkout $MASTER
echo "--------------------------------------------------------------------------------"
echo "Tagging monthly base"
git tag linaro-base-$YYYYMM

# 1.4) Create new monthly branch
git branch $MONTH_BRANCH $MASTER

topics=(`git branch --list linaro-topic-* | sed "s/*//"`)

for topic in "${topics[@]}" ; do
	# 1.5) Rebase all the topic branches
	# One of these could fail because a patch made it upstream.
	# Need some error trapping and fixing procedure here
	echo "--------------------------------------------------------------------------------"
	echo "Rebasing $topic"
	git checkout $topic
	git rebase --ignore-whitespace $MASTER

	if [ "$?" != "0" ]
	then
		echo "********************************************************************************"
		echo "Error rebasing $topic"
		echo "********************************************************************************"
		exit 1
	fi

	# 1.6) update monthly branch
	# Now that we have the topic branches, we merge them all back to the tracking branch
	echo "--------------------------------------------------------------------------------"
	echo "Merging $topic into $MONTH_BRANCH"
	git checkout $MONTH_BRANCH
	git merge --no-commit $topic 

	if [ "$?" != "0" ]
	then
		echo "********************************************************************************"
		echo "Error merging $topic back to $MONTH_BRANCH"
		echo "********************************************************************************"
		exit 1
	fi

	# now commit
	git commit -s -m "Merging $topic into $MONTH_BRANCH" #--date "Mon Jan 7 13:00:00 GMT 2013"

done

echo "--------------------------------------------------------------------------------"
echo "Finished rebasing and merging"
echo "Tagging first release candidate"
echo "--------------------------------------------------------------------------------"

git checkout $MONTH_BRANCH
git tag linaro-uefi-$YYYYMM-rc1

#--------------------------------------------------------------------------------
# Now create a "latest" tracking branch
# CI and other automated things need to be able to pull a specific, fixed, branch
# to do their work, so create a branch for this.  Historically, this was:
#   armlt-tracking
# Which we'll keep, but we should use something not ARMLT related for the future:
#   linaro-tracking
#--------------------------------------------------------------------------------
echo "--------------------------------------------------------------------------------"
echo "Update global tracking branches"
echo "--------------------------------------------------------------------------------"
git checkout linaro-tracking
git merge -Xtheirs linaro-tracking-$YYYYMM
git checkout armlt-tracking
git merge -Xtheirs linaro-tracking


exit
################################################################################
