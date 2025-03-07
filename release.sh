#!/bin/zsh
export LANG=en_US.UTF-8

function setVersion {
  sed -i '' -e "s/^version: *\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/version: $1/" pubspec.yaml
}

function updateChangelog () {
  NEW_VERSION_LOG=$(echo "# "$1"\n"$RELEASE_NOTES"\n")
  echo $NEW_VERSION_LOG | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
}

git remote rm github

# Find last git tag and create commit log
#LAST_TAG=`git describe --tags --abbrev=0`
#RELEASE_COMMIT_LOG=`git log $LAST_TAG..HEAD --oneline`

# Save commit log to property file as a property
# (replacing newlines with "\n")
#echo RELEASE_COMMIT_LOG="${RELEASE_COMMIT_LOG//$'\n'/\\n}" > $PROPERTIES_FILE

echo "*** [DEBUG] Setting version $RELEASE_VERSION"

setVersion $RELEASE_VERSION

# Update changelog
updateChangelog $RELEASE_VERSION

# Remove package lock (temporary)
# rm -f pubspec.lock

git add .

# Commit release version
git commit -a -m "Release: $RELEASE_VERSION"

# Create and push tag
git tag $RELEASE_VERSION -m "Release: $RELEASE_VERSION"

# git show-ref

# Setting username and password for HTTPS to BitBucket
encoded_username=$(echo ${GIT_USERNAME} | jq -Rr @uri)
encoded_password=$(echo ${GIT_PASSWORD} | jq -Rr @uri)
git remote set-url origin https://${encoded_username}:${encoded_password}@git.ib-ci.com/scm/mml/infobip-mobile-messaging-flutter.git

# Push changes
git push origin $BRANCH_NAME_TO_BUILD --tags
