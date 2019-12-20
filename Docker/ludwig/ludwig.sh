#!/bin/sh

#
# runs the Docker image
#
# Author: Christian Decker (cdeck3r)
#

# this directory is the script directory
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPT_DIR

#
# Image parameter initialization
# Defaults to directory name
#
IMG_NAME=$(basename ${SCRIPT_DIR})
TARGET=latest

IMAGE="${IMG_NAME}:${TARGET}"

#
# Note that under Windows not every directory can be used as shared folder.
# The host directory specified in `-v <host dir>:<container dir>`
# must be a subdir of `C:\Users\<username>\`.
#
HOST_DIR=$(pwd -P)/data
mkdir -p ${HOST_DIR}


#################################################
# Do not edit below
#################################################

# takes the first command line argument
RUNMODE=$1

# need to check for invalid params
PARAMFAIL=1

#
# Help text, usage
#
usage ()
{
  echo -e "Usage : $0 [bash|jupyter|root]"
  echo ""
  echo -e "Default image: ${IMAGE}"
  exit
}

if [ -z $RUNMODE ]
then
    echo "Too few arguments."
    usage
    exit 1
fi

# jupyter
if [ "$RUNMODE" = "jupyter" ]
then

docker run -it --rm \
    -p 8888:8888 \
    -e JUPYTER_ENABLE_LAB=yes \
    -e NB_UID=1000 \
    --user root \
    -v $HOST_DIR:/home/jovyan \
    $IMAGE

PARAMFAIL=0
fi

if [ "$RUNMODE" = "root" ]
then
docker run -it --rm \
    --user root -e GRANT_SUDO=yes \
    -v $HOST_DIR:/home/jovyan \
    $IMAGE /bin/bash

PARAMFAIL=0
fi

if [ "$RUNMODE" = "bash" ]
then
docker run -it --rm \
    -v $HOST_DIR:/data \
    $IMAGE -h

PARAMFAIL=0
fi


if [ $PARAMFAIL -ne 0 ]
then
docker run -it --rm \
    -v $HOST_DIR:/data \
    $IMAGE $@
fi
