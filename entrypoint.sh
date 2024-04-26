#!/bin/sh
#

PROJ_NAME=$1
APP_NAME=$2
DIST_DIR=$3

echo "Build Qt project: ${PROJ_NAME} as ${APP_NAME}, keep artifacts at ${DIST_DIR} "
echo "time=$(date)" >> $GITHUB_OUTPUT

# build
qmake CONFIG+=release CONFIG+=optimize_full ${PROJ_NAME}
make -j$(cat /proc/cpuinfo | /bin/grep processor | wc -l)
