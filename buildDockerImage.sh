#!/bin/bash
#
# Since: May, 2018
# Author: psheldon@pivotal.io
# Description: Build script for building extended Oracle Docker image with pre-built database.
#

export IMAGE_NAME=${1:-ps-oracle:12.2.0.1}
echo "Creating Image: " ${IMAGE_NAME}
docker build --force-rm=true --no-cache=true -t $IMAGE_NAME . || {
  echo ""
  echo "ERROR: Oracle Database Docker Image was NOT successfully created."
  echo "ERROR: Check the output and correct any reported problems with the docker build operation."
  exit 1
}
