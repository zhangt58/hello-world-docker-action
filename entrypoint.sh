#!/bin/bash
#
# Build a Qt project into deployable binaries.
#
set -Eeuo pipefail

# Input arguments
PROJ_FILE=$1
APP_NAME=$2
EXEC_NAMES=$3
MAIN_EXEC=$4
APP_VERSION=$5
APP_DESC=$6
DIST_DIR=$7
QT_DEPLOYER_OPTS=$8
MAKESELF_OPTS=$9
EXTRA_REQUIRES="${10}"
POST_DIST="${11}"

# install extra required packages via apt if set
dpkg-query -l git > /dev/null 2>&1 || EXTRA_REQUIRES+=" git"
EXTRA_REQUIRES=$(echo ${EXTRA_REQUIRES} | xargs -n1 | sort -u | xargs)
[[ -n ${EXTRA_REQUIRES} ]] && apt-get update && apt-get install -y ${EXTRA_REQUIRES}

# fix: "fatal: detected dubious ownership in repository at '/github/workspace'"
sh -c "git config --global --add safe.directory $PWD"

# if MAIN_EXEC is '', set it the first word of EXEC_NAMES
[[ -z ${MAIN_EXEC} ]] && MAIN_EXEC=$(echo ${EXEC_NAMES} | cut -d' ' -f1)
# if APP_DESC is '', set it "A Qt app (APP_NAME) built with qt-builder action"
[[ -z ${APP_DESC} ]] && APP_DESC="A Qt app (${APP_NAME}) built with qt-app-builder action"
# if APP_VERSION is not-defined, get the sha1 of the last commit or the tag
if [[ -z ${APP_VERSION} ]]; then
    # sha1
    sha1full=$(git rev-parse HEAD)
    # test if a tag is available
    tag=$(git tag --contains ${sha1full})
    [ -n "$tag" ] && APP_VERSION=${tag} || APP_VERSION=${sha1full::6}
fi

echo "MAIN_EXEC: " $MAIN_EXEC
echo "APP_DESC: " $APP_DESC
echo "APP_VERSION: " $APP_VERSION

run_filename=${APP_NAME}_${APP_VERSION}.run

cwdir0=`pwd`

echo "Build Qt project: ${PROJ_FILE} as ${APP_NAME}, keep artifacts at ${DIST_DIR} "

# build
qmake CONFIG+=release CONFIG+=optimize_full ${PROJ_FILE}
make -j$(cat /proc/cpuinfo | /bin/grep processor | wc -l)

# generate deployable binaries as a distro
echo "Deploy binaries to '${DIST_DIR}'"
[ ! -e ${DIST_DIR} ] && mkdir -p ${DIST_DIR}
cp -r ${EXEC_NAMES} ${DIST_DIR}
cd ${DIST_DIR}
for exec in ${EXEC_NAMES}
do
  linuxdeployqt ${exec} -qmake=qmake ${QT_DEPLOYER_OPTS}
  strip --strip-unneeded ${exec}
done
cat << EOF > run_app.sh
#!/bin/sh
cwdir=\`dirname \$0\`
\${cwdir}/${MAIN_EXEC}
EOF
chmod +x run_app.sh

# executing scripts after binary distro dir is generated
[[ -n "${POST_DIST}" ]] && eval "${POST_DIST}"

# generate self-extractable run file
cd ${cwdir0}
makeself ${MAKESELF_OPTS} ${DIST_DIR} ${run_filename} \
    "${APP_DESC}" ./run_app.sh
chmod +x ${run_filename}

# action outputs
# path for .run file
echo "run_filename=${run_filename}" >> $GITHUB_OUTPUT
# path for all binary artifacts
echo "binary_distro=${DIST_DIR}" >> $GITHUB_OUTPUT
# string of app name
echo "app_name=${APP_NAME}" >> $GITHUB_OUTPUT
# string of app version
echo "app_version=${APP_VERSION}" >> $GITHUB_OUTPUT
