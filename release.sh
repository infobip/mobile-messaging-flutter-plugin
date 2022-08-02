#!/bin/zsh
#export FLUTTER=/Users/mobile_ci/Developer/flutter/bin/flutter
export LANG=en_US.UTF-8

function evalNewVersion {
  curr_major=$(sed -n "s/^version: *\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/\1/p" pubspec.yaml)
  curr_minor=$(sed -n "s/^version: *\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/\2/p" pubspec.yaml)
  curr_patch=$(sed -n "s/^version: *\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/\3/p" pubspec.yaml)

  if [ "$1" = "major" ]; then
      curr_major=$((curr_major+1))
      curr_minor=0
      curr_patch=0
  fi
  if [ "$1" = "minor" ]; then
      curr_minor=$((curr_minor+1))
      curr_patch=0
  fi
  if [ "$1" = "patch" ]; then
      curr_patch=$((curr_patch+1))
  fi

  echo "$curr_major.$curr_minor.$curr_patch"
}

function setVersion {
  sed -i '' -e "s/^version: *\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/version: $1/" pubspec.yaml
}

function updateChangelog () {
  NEW_VERSION_LOG=$(echo "# "$1"\n"$RELEASE_NOTES"\n")
  echo $NEW_VERSION_LOG | cat - CHANGELOG.md > temp && mv temp CHANGELOG.md
}

git remote rm github

# Find last git tag and create commit log
LAST_TAG=`git describe --tags --abbrev=0`
RELEASE_COMMIT_LOG=`git log $LAST_TAG..HEAD --oneline`

# Save commit log to property file as a property
# (replacing newlines with "\n")
echo RELEASE_COMMIT_LOG="${RELEASE_COMMIT_LOG//$'\n'/\\n}" > $PROPERTIES_FILE


# Bump version
if [ "${RELEASE}" = "custom" ]; then
    release_version=${CUSTOM_RELEASE_VERSION}
else
    release_version=$(evalNewVersion $RELEASE)
fi

echo "*** [DEBUG] Setting version $release_version"

setVersion $release_version
rm -f pubspec.lock

# Update changelog
updateChangelog $release_version

# Remove package lock (temporary)
rm -f pubspec.lock

git add .

# Commit release version
git commit -a -m "Release: $RELEASE_VERSION"

# Create and push tag
git tag $RELEASE_VERSION -m "Release: $RELEASE_VERSION"

# Push changes
git push origin master --tags
