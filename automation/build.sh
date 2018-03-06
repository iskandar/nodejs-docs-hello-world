#!/usr/bin/env bash


set -e            # fail fast
set -u            # fail when variable is unbound
set -o pipefail   # don't ignore exit codes when piping output
set -x            # enable debugging

##
APP_NAME=nodejs-docs-hello-world

# Resolve paths to our output directories
# Where do we store the build output?
# VSTS: $BUILD_ARTIFACTSTAGINGDIRECTORY
DIST_DIR=$(pwd)/dist

# Extract Git metadata.
# These may also be available in the environment,
# depending on the build server in use (if any).
GIT_BRANCH=${GIT_BRANCH:-${BUILD_SOURCEBRANCHNAME}:-unknown}}
GIT_COMMIT=${GIT_COMMIT:-${BUILD_SOURCEVERSION:-unknown}}
if [ -d "./.git" ]; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    GIT_COMMIT=$(git rev-parse HEAD)
fi
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_NUMBER=${BUILD_BUILDNUMBER:-unknown}

# Create a sensible version string
# Here, we'll just use the short git commit hash, but this could be arbitrary
APP_VERSION=${GIT_COMMIT:0:7}

echo "----> Showing current working directory"
pwd

echo "----> Creating the output directories..."
mkdir -vp ${DIST_DIR} 2>/dev/null || true

echo "----> Showing npm version"
npm --version

echo "----> Showing yarn version"
yarn --version

echo "----> Fetching dependencies with yarn..."
yarn --non-interactive

# echo "----> Building Production files..."
# npm run build.prod

echo "----> Generating license info..."
yarn licenses list > ${DIST_DIR}/licenses.txt
yarn licenses generate-disclaimer > ${DIST_DIR}/license-disclaimer.txt

echo "----> Copying specific files to our dist dir..."
cp -a ./process.json ${DIST_DIR}/
cp -a ./package.json ${DIST_DIR}/
cp -a ./index.js ${DIST_DIR}/

echo "----> Updating the VERSION file to '${APP_VERSION}'..."
echo $APP_VERSION > ${DIST_DIR}/VERSION

echo "----> Adding build-time metadata..."
cat << EOF > ${DIST_DIR}/build.properties
APP_NAME=${APP_NAME}
APP_VERSION=${APP_VERSION}
BUILD_DATE=${BUILD_DATE}
BUILD_NUMBER=${BUILD_NUMBER}
GIT_BRANCH=${GIT_BRANCH}
GIT_COMMIT=${GIT_COMMIT}
EOF
