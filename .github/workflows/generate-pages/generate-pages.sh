#! /bin/bash
if ! test -n "${TARGET_VERSIONS_FILE}"; then
    TARGET_VERSIONS_FILE=_data/versions.csv
fi

if ! test -n "${TARGET_VERSION_PAGES_LOCATION}"; then
    TARGET_VERSION_PAGES_LOCATION=pages/versions
fi

if ! test -n "${SOURCE_INDEX_FILE}"; then
    SOURCE_INDEX_FILE=README.md
fi

if ! test -n "${SOURCE_TEMPLATES_LOCATION}"; then
    SOURCE_TEMPLATES_LOCATION=.github/workflows/generate-pages/templates
fi

# Copy base files
git checkout main -- .github/workflows/generate-pages/templates $SOURCE_INDEX_FILE
cp -rf .github/workflows/generate-pages/templates/_config.yml .
cp -rf .github/workflows/generate-pages/templates/.gitignore .
cp -rf .github/workflows/generate-pages/templates/*.md .
sed -i -e '/@@CONTENT@@/r $SOURCE_INDEX_FILE' index.md
rm -rf .github
rm -rf $SOURCE_INDEX_FILE

mkdir _data
mkdir -p $TARGET_VERSION_PAGES_LOCATION

echo -e "version\nlatest" > $TARGET_VERSIONS_FILE
find ./docs -maxdepth 1 -type d -printf '%P\n' | grep -P "\d+\.\d+\.\d+.*" | sed '/-/!{s/$/_/}' | sort -rV | sed 's/_$//' >>$TARGET_VERSIONS_FILE

readarray -t VERSIONS <<< $(cat $TARGET_VERSIONS_FILE)

rm $TARGET_VERSION_PAGES_LOCATION/*

idx=0
for version in "${VERSIONS[@]:1}"; do
    for file in $SOURCE_TEMPLATES_LOCATION/versions/*.md; do
        target_file=${file/"$SOURCE_TEMPLATES_LOCATION"/versions/"$TARGET_VERSION_PAGES_LOCATION"}
        target_file=${target_file/VERSION/"$version"}
        cp $file $target_file
        sed -i s/VERSION/"$version"/g $target_file
        sed -i s/ORDER/"$idx"/g $target_file
        echo "Created page $target_file"
    done
    idx=$((idx + 1))
done
