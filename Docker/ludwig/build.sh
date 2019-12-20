#!/bin/sh

#
# Builds the Docker image
#
# Author: Christian Decker (cdeck3r)
#

#
# if called with no args, check what images are availble
# As a result, suggest a scripte call with appropriate params
#

# this directory is the script directory
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPT_DIR

## Parameter initialization
IMG_NAME=$(basename ${SCRIPT_DIR})
TARGET=latest

BUILD_PARAMS=
FORCE_OPTION=
OPT_CNT=0

# shared vars


####################################################
# helper functions
####################################################
usage()
{
    echo -e "Usage: $0 <options>"
    echo
    echo -e "Options:"
    echo
    echo -e "-h --help\t This message"
    echo -e "[-b | --base]\t build base image"
    echo -e "[-a | --app]\t build app image"
    echo -e "[-r | --remove]\t remove ${IMG_NAME}:${TARGET} image"
    echo ""
	echo -e "Default image name: ${IMG_NAME}"
	echo -e "Default target name: ${TARGET}"
}

####################################################
# parse params
####################################################
while :; do
	case $1 in
        -h|-\?|--help)   # Call a "usage" function to display a synopsis, then exit.
            usage
            exit 1
            ;;
        -b|--base)
		    BUILD_BASE=1
            OPT_CNT=$((OPT_CNT + 1))
            ;;
        -a|--app)
            BUILD_APP=1
            OPT_CNT=$((OPT_CNT + 1))
            ;;
        -r|--remove)
            REMOVE_OPTION=1
            OPT_CNT=$((OPT_CNT + 1))
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)  # Default case: no more options; test required param and break out
			if [ "$OPT_CNT" -ge 1 ]
			then
                break
			else
				echo -e "Error: too few options provided."
				echo -e "Please specify at least an option."
				echo -e ""
				usage
				exit 1
			fi
			;;
    esac
    shift
done

####################################################
# prints the build command
####################################################
buildcmd()
{
    echo -e "Call script with the following parameters:"
    echo
    echo -e "$0 $BUILD_PARAMS"
}

dockercleanup()
{
    # remove dangling images if build failed
    docker rmi -f $(docker images --quiet --filter "dangling=true") 2> /dev/null
}

########################################################

if [ -n "$BUILD_BASE" ]; then
echo Building base image [${IMG_NAME}:${TARGET}]

# we will create a new image and container
# so, we will need to remove possible previous container with that name
docker rmi -f ${IMG_NAME}:${TARGET}
# remove dangling images
dockercleanup

docker build --force-rm --rm --no-cache \
    -t ${IMG_NAME}:${TARGET} . \
    -f Dockerfile \
    || echo "[$TARGET] build error"; dockercleanup; exit 1

# remove dangling images
dockercleanup

fi

########################################################

if [ -n "$REMOVE_OPTION" ]; then
TARGET=latest
echo Remove [${IMG_NAME}:${TARGET}]

# we will need to remove possible previous container with that name
docker rmi -f ${IMG_NAME}:${TARGET}

# remove dangling images
dockercleanup

fi

########################################################

if [ -n "$BUILD_APP" ]; then

echo "Option --app not yet implemented."
echo "Abort."
exit


TARGET=latest
echo Create R NLP image [rnlp:latest]
TARGET=latest
BUILD_PARAMS=

# check availble resources

if [ -z $(docker images -q rnlp:latest) ]; then
    BUILD_PARAMS="$BUILD_PARAMS --base"
fi

# still things to build
# suggest so call appropriate build cmd first
if [ -n "$BUILD_PARAMS" ]; then
    BUILD_PARAMS="$BUILD_PARAMS --app"
    buildcmd
    exit 0
fi

if [ -z "$BUILD_PARAMS" ]; then
    # we know all ingredients exist

    echo "Remove previous image ...:latest..." && \
    docker rmi -f rnlp:latest

    # copy all into base
    echo "Create container $TARGET..." && \
    docker create --name $TARGET rnlp:base && \
    echo "Copy taenv.tgz into container..." && \
    gunzip -c "$SCRIPT_DIR/taenv.tgz" | docker cp - talatest:/ && \
    echo "Copy tapipeline.tgz into container..." && \
    gunzip -c "$SCRIPT_DIR/tapipeline.tgz" | docker cp - $TARGET:/home/taapp && \
    echo "Stop container $TARGET..." && \
    docker stop $TARGET && \
    echo "Commit container $TARGET as [taapp:latest]..." && \
    docker container commit $TARGET taapp:latest && \
    docker container rm $TARGET
fi

fi
