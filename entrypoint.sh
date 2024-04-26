#!/bin/sh
#

PROJ_NAME=$1
APP_NAME=$2

echo "Build Qt project: ${PROJ_NAME} to ${APP_NAME}"
echo "time=$(date)" >> $GITHUB_OUTPUT

# build
qmake CONFIG+=release CONFIG+=optimize_full ${PROJ_NAME}
make -j$(cat /proc/cpuinfo | /bin/grep processor | wc -l)
