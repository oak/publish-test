#! /bin/bash
# Check input env vars and set default variables
if ! test -n "${SOURCE_INDEX_FILE}"; then
    SOURCE_INDEX_FILE=README.md
fi

if ! test -n "${MASTER_BRANCH_NAME}"; then
    MASTER_BRANCH_NAME=master
fi

SOURCE_TEMPLATES_LOCATION=./generate-pages/templates
TARGET_VERSIONS_LOCATION=_data
TARGET_VERSIONS_FILE=$TARGET_VERSIONS_LOCATION/versions.csv
TARGET_VERSION_PAGES_LOCATION=pages/versions

# Create folders (should just fail if already exists)
mkdir -p $TARGET_VERSIONS_LOCATION
mkdir -p $TARGET_VERSION_PAGES_LOCATION

# Checkout SOURCE_INDEX_FILE from MASTER_BRANCH_NAME to inject into index.md
# Then copy base files
#git fetch origin $MASTER_BRANCH_NAME:$MASTER_BRANCH_NAME
git fetch origin $MASTER_BRANCH_NAME:$MASTER_BRANCH_NAME
git checkout $MASTER_BRANCH_NAME -- $SOURCE_INDEX_FILE
cp ./generate-pages/templates/.gitignore .
cp ./generate-pages/templates/_config.yml .
cp ./generate-pages/templates/Gemfile .
cp ./generate-pages/templates/index.md .
cp ./generate-pages/templates/[^index.md]*.md  ./pages/

# Inject source index file into index.md
echo "Injecting $SOURCE_INDEX_FILE into index.md"
cat $SOURCE_INDEX_FILE >> index.md

# Create a jekyll var file with available versions
echo -e "version\nlatest" > $TARGET_VERSIONS_FILE
find ./docs -maxdepth 1 -type d -printf '%P\n' | grep -P "\d+\.\d+\.\d+.*" | sed '/-/!{s/$/_/}' | sort -rV | sed 's/_$//' >>$TARGET_VERSIONS_FILE

readarray -t VERSIONS <<< "$(cat $TARGET_VERSIONS_FILE)"

# Clean up version pages
rm $TARGET_VERSION_PAGES_LOCATION/*

# Create all version pages
idx=0
for version in "${VERSIONS[@]:1}"; do
    for file in "$SOURCE_TEMPLATES_LOCATION"/versions/*.md; do
        target_file=${file/"$SOURCE_TEMPLATES_LOCATION/versions"/"$TARGET_VERSION_PAGES_LOCATION"}
        target_file=${target_file/VERSION/"$version"}
        cp "$file" "$target_file"
        sed -i s/VERSION/"$version"/g "$target_file"
        sed -i s/ORDER/"$idx"/g "$target_file"
        echo "Created page $target_file"
    done
    idx=$((idx + 1))
done

# Remove injected source index file
rm -rf $SOURCE_INDEX_FILE
