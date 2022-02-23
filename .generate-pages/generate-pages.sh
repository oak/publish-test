#! /bin/bash
# Check input env vars and set default variables
if ! test -n "${SOURCE_INDEX_FILE}"; then
    SOURCE_INDEX_FILE=README.md
fi

if ! test -n "${MASTER_BRANCH_NAME}"; then
    MASTER_BRANCH_NAME=master
fi

VERSIONS_LOCATION=_data
VERSIONS_FILE=$VERSIONS_LOCATION/versions.csv

SOURCE_TEMPLATES_LOCATION=.generate-pages/templates

PAGES_LOCATION=pages
VERSION_PAGES_LOCATION=$PAGES_LOCATION/versions

# Clean up old pages
rm -rf $PAGES_LOCATION

# Create folders (should just fail if already exists)
mkdir -p $VERSIONS_LOCATION
mkdir -p $VERSION_PAGES_LOCATION

# Checkout SOURCE_INDEX_FILE from MASTER_BRANCH_NAME to inject into index.md
# Then copy base files
git fetch origin "$MASTER_BRANCH_NAME":"$MASTER_BRANCH_NAME"
git checkout "$MASTER_BRANCH_NAME" -- "$SOURCE_INDEX_FILE"
cp "$SOURCE_TEMPLATES_LOCATION"/.gitignore .
cp "$SOURCE_TEMPLATES_LOCATION"/_config.yml .
cp "$SOURCE_TEMPLATES_LOCATION"/Gemfile .
cp "$SOURCE_TEMPLATES_LOCATION"/index.md .
cp "$SOURCE_TEMPLATES_LOCATION"/"$PAGES_LOCATION"/*.md  "$PAGES_LOCATION"

# Inject source index file into index.md
echo "Injecting $SOURCE_INDEX_FILE into index.md"
cat $SOURCE_INDEX_FILE >> index.md

# Create a jekyll var file with available versions
echo -e "version\nlatest" > $VERSIONS_FILE
find ./docs -maxdepth 1 -type d -printf '%P\n' | grep -P "\d+\.\d+\.\d+.*" | sed '/-/!{s/$/_/}' | sort -rV | sed 's/_$//' >>$VERSIONS_FILE

readarray -t VERSIONS <<< "$(cat $VERSIONS_FILE)"

# Create all version pages
idx=0
for version in "${VERSIONS[@]:1}"; do
    for file in "$SOURCE_TEMPLATES_LOCATION/$VERSION_PAGES_LOCATION"/*.md; do
        target_file=${file/"$SOURCE_TEMPLATES_LOCATION/$VERSION_PAGES_LOCATION"/"$VERSION_PAGES_LOCATION"}
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
