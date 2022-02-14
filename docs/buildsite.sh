#!/bin/bash
set -x

apt-get update
apt-get -y install git rsync python3-sphinx

pwd ls -lah
export SOURCE_DATE_EPOCH=(git log -1 --pretty=%ct)

# Install detectorcal
# -------------------
pip install detectorcal


# Build Docs
# ----------
make clean
make html


# Update Github Pages
# -------------------

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "{GITHUB_ACTOR}@users.noreply.github.com"

docroot=`mktemp -d`
rsync -av "build/html/" "${docroot}/"

pushd "${docroot}"

git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages

touch .nojekyll

git . add

msg="Updating docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by {GITHUB_ACTOR}"
git commit -am "${msg}"

# overwrite the contents of the gh-pages branch on github.com repo
git push deploy gh-pages --force

popd # return to main repo sanxbox root

exit 0
