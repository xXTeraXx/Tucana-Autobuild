#!/bin/bash
source autobuild.conf
PACKAGE=$1

cd $BUILD_SCRIPTS_ROOT
cat $(find . -name $PACKAGE) | grep git &> /dev/null
if [[ $? -ne 0 ]]; then
   exit 1
fi
REPO=$(cat $(find . -name $PACKAGE) | grep URL | head -1 | sed 's/.*\.com//' | sed 's/.*\.org//' | sed 's|/|!|3' | sed 's/!.*//' | sed 's/^.//')
PROJECT_ID=$(echo $REPO | sed 's!/!%2F!')
GITLAB_SERVER=$(cat $(find . -name $PACKAGE)  | grep URL= | sed 's/URL=//' | sed 's/.com.*/.com\//g' | sed 's/.org.*/.org\//g' )
LATEST_VER=$(curl \
  -Ls "$GITLAB_SERVER/api/v4/projects/$PROJECT_ID/releases/permalink/latest" | grep tag_name | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//' | sed 's!.*/!!' | sed 's/.$//' )
# Some apps have TAG_OVERRIDE because the tags are newer than the releases, in that case use those instead
cat $(find . -name $PACKAGE) | grep TAG_OVERRIDE &> /dev/null
if [[ $? == 0 ]]; then
   LATEST_VER=""
fi
echo $LATEST_VER
