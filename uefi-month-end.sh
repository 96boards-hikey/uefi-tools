#!/bin/bash
################################################################################
# Month End
#
# At the end of the month, we:
#
# 1) Merge the current monthly branch to the release branch
# 2) Make sure the linaro/armlt-tracking branches are up-to-date
# 3) Tag the release branch with linaro-uef-YYYY.MM
################################################################################


################################################################################
function usage
{
	echo "Usage: $0"
	echo "   YYYY.MM        where YYYY is the year and MM is the month"
}
################################################################################
#
# Check all parameters
while [ "$1" != "" ]; do
    case $1 in
		[0-9][0-9].[0-9][0-9])
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
	echo "You need to specify a month tag, eg. 13.01"
	exit
fi



################################################################################
echo "--------------------------------------------------------------------------------"
echo "Updating linaro-release"
echo "--------------------------------------------------------------------------------"
git checkout linaro-release
git merge linaro-tracking-$YYYYMM
git tag linaro-uefi-$YYYYMM

echo "--------------------------------------------------------------------------------"
echo "Update global tracking branches"
echo "--------------------------------------------------------------------------------"
git checkout linaro-tracking
git merge linaro-uefi-$YYYYMM
git checkout armlt-tracking
git merge linaro-uefi-$YYYYMM


