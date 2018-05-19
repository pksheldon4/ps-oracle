#!/bin/bash
#
# Since: May, 2018
# Author: psheldon@pivotal.io
# Description: Build script for building extended Oracle Docker image with pre-built database.
#
docker build --force-rm=true --no-cache=true -t ps-oracle . || {
  echo ""
  echo "ERROR: Oracle Database Docker Image was NOT successfully created."
  echo "ERROR: Check the output and correct any reported problems with the docker build operation."
  exit 1
}
