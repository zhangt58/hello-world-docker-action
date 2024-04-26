#!/bin/sh
#

PROJ_NAME=$1
APP_NAME=$2
EXEC_NAMES=$3
DIST_DIR=$4
QT_DEPLOYER_OPTS=$5

echo "Build Qt project: ${PROJ_NAME} as ${APP_NAME}, keep artifacts at ${DIST_DIR} "
echo "time=$(date)" >> $GITHUB_OUTPUT

# build
qmake CONFIG+=release CONFIG+=optimize_full ${PROJ_NAME}
make -j$(cat /proc/cpuinfo | /bin/grep processor | wc -l)

echo "Deploy binaries to '${DIST_DIR}'"
[ ! -e ${DIST_DIR} ] && mkdir -p ${DIST_DIR}
cp -r ${EXEC_NAMES} ${DIST_DIR}
cd ${DIST_DIR}
for exec in ${EXEC_NAMES}
do
  linuxdeployqt ${exec} -qmake=qmake ${QT_DEPLOYER_OPTS}
  strip --strip-unneeded ${exec}
done
#cat << EOF > run_app.sh
##!/bin/sh
#cwdir=\`dirname \$0\`
#\${cwdir}/${{ env.MAIN_EXEC }}
#EOF
#chmod +x run_app.sh
