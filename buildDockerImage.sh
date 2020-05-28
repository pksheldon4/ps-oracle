#!/bin/bash
#
# Since: May, 2018
# Author: psheldon
# Description: Build script for building extended Oracle Docker image with pre-built database.
#

usage() {
  cat << EOF

Usage: buildDockerImage.sh 
Builds a Docker Image for Oracle Database.

EOF
  exit 0
}

##############
#### MAIN ####
##############

while getopts "h" optname; do
  case "$optname" in
    "h")
      usage
      ;;
    "?")
      usage;
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside buildDockerImage.sh"
      ;;
  esac
done

# Parameters
EXPRESS=1
VERSION="18.4.0"
SKIPMD5=1
DOCKEROPS=""
EDITION="xe";

# Oracle Database Image Name
export IMAGE_NAME="pksheldon4/ps-oracle:$VERSION-$EDITION"

cd $VERSION

BUILD_START=$(date '+%s')
echo "Creating Image: " ${IMAGE_NAME}
docker build --force-rm=true --no-cache=true $DOCKEROPS -t $IMAGE_NAME -f Dockerfile.$EDITION . || {
  echo ""
  echo "ERROR: Oracle Database Docker Image was NOT successfully created."
  echo "ERROR: Check the output and correct any reported problems with the docker build operation."
  exit 1
}
echo ""

BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`

echo ""

cat << EOF
  Oracle Database Docker Image is ready to be use:

    --> $IMAGE_NAME

  Build completed in $BUILD_ELAPSED seconds.

EOF
