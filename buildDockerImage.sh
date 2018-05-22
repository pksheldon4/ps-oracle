#!/bin/bash
#
# Since: May, 2018
# Author: psheldon@pivotal.io
# Description: Build script for building extended Oracle Docker image with pre-built database.
#

usage() {
  cat << EOF

Usage: buildDockerImage.sh -v [version] [-e | -s | -x] [-i] [-o] [Docker build option]
Builds a Docker Image for Oracle Database.

Parameters:
   -v: version to build
       Choose one of: $(for i in $(ls -d */); do echo -n "${i%%/}  "; done)
   -e: creates image based on 'Enterprise Edition'
   -s: creates image based on 'Standard Edition 2'
   -x: creates image based on 'Express Edition'
   -o: passes on Docker build option

* select one edition only: -e, -s, or -x

LICENSE UPL 1.0

Copyright (c) 2014-2017 Oracle and/or its affiliates. All rights reserved.

EOF
  exit 0
}

##############
#### MAIN ####
##############

if [ "$#" -eq 0 ]; then
  usage;
fi

# Parameters
ENTERPRISE=0
STANDARD=0
EXPRESS=0
VERSION="12.2.0.1"
SKIPMD5=0
DOCKEROPS=""

while getopts "hesxiv:o:" optname; do
  case "$optname" in
    "h")
      usage
      ;;
    "e")
      ENTERPRISE=1
      ;;
    "s")
      STANDARD=1
      ;;
    "x")
      EXPRESS=1
      ;;
    "v")
      VERSION="$OPTARG"
      ;;
    "o")
      DOCKEROPS="$OPTARG"
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

# Which Edition should be used?
if [ $((ENTERPRISE + STANDARD + EXPRESS)) -gt 1 ]; then
  usage
elif [ $ENTERPRISE -eq 1 ]; then
  EDITION="ee"
elif [ $STANDARD -eq 1 ]; then
  EDITION="se2"
elif [ $EXPRESS -eq 1 ] && [ "$VERSION" != "11.2.0.2" ]; then
  echo "Version $VERSION does not have Express Edition available.";
  exit 1;
else
  EDITION="xe";
  DOCKEROPS="--shm-size=1G $DOCKEROPS";
fi

export FROM_IMAGE_NAME="ps-oracle/database:$VERSION-$EDITION"
# Oracle Database Image Name
export IMAGE_NAME="ps-oracle:$VERSION-$EDITION"

BUILD_START=$(date '+%s')
echo "Creating Image: " ${IMAGE_NAME}
docker build --force-rm=true --no-cache=true $DOCKEROPS -t $IMAGE_NAME -f $VERSION/Dockerfile.$EDITION . || {
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
