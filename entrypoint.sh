#!/bin/bash
#
# Build a Qt project into deployable binaries.
#

# fix:
# fatal: detected dubious ownership in repository at '/github/workspace'
sh -c "git config --global --add safe.directory $PWD"

# Arguments
PROJ_NAME=$1
APP_NAME=$2
APP_VERSION=$3
APP_DESC=$4
EXEC_NAMES=$5
MAIN_EXEC=$6
DIST_DIR=$7
QT_DEPLOYER_OPTS=$8
MAKESELF_OPTS=$9

# if MAIN_EXEC is not-defined, set it the first word of EXEC_NAMES
[[ $MAIN_EXEC == "not-defined" ]] && MAIN_EXEC=$(echo ${EXEC_NAMES} | cut -d' ' -f1)
# if APP_DESC is not-defined, set it "A Qt app (APP_NAME) built with qt-builder action"
[[ $APP_DESC == "not-defined" ]] && APP_DESC="A Qt app (${APP_NAME}) built with qt-builder action"
# if APP_VERSION is not-defined, get the sha1 of the last commit or the tag
if [[ $APP_VERSION == "not-defined" ]]; then
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

echo "Build Qt project: ${PROJ_NAME} as ${APP_NAME}, keep artifacts at ${DIST_DIR} "

# build
qmake CONFIG+=release CONFIG+=optimize_full ${PROJ_NAME}
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

# generate self-extractable run file
cd ${cwdir0}
makeself ${MAKESELF_OPTS} ${DIST_DIR} ${run_filename} \
    "${APP_DESC}" ./run_app.sh
chmod +x ${run_filename}

# action outputs
echo "run_filename=${run_filename}" >> $GITHUB_OUTPUT
