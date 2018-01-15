#!/bin/bash -e
# Replaces the current gitlab version with a new version

display_usage() { 
	echo "Replaces the current gitlab version" 
	echo -e "\nUsage:\n./bump-version.sh [new-version] \n./bump-version.sh 0.9.0" 
}

if [[  $# != 1 ]] 
then 
    display_usage
    exit 1
fi 

NEW_VERSION="$1"
CURRENT_VERSION="$(cat VERSION)"
# -i.sedbak so its portable between osx and linux
grep  --exclude="Changelog.md" -rl "$CURRENT_VERSION" ./ | xargs sed -i.sedbak "s/$CURRENT_VERSION/$NEW_VERSION/g"
find . -name "*.sedbak" -print0 | xargs -0 rm
