#!/bin/bash

if [ ! -d node_modules/.bin ]; then
    echo "fatal: Cannot find build tools (have you done 'make build-tools?')"
    exit 1
fi

PATH=$PWD/node_modules/.bin:$PATH

function extract {
    checkout=$1
    target_dir=$2
    echo "Extracting documentation from $checkout into $target_dir"
    mkdir "$target_dir"
    cd source-repo
        echo "Checking out $checkout..."
        git checkout "$checkout"
        if [ -d docs ]; then
            cp -r docs "../$target_dir"
        fi
        if [ -d APIs ]; then
            cd APIs
                cd schemas
                    mkdir with-refs resolved
                    for i in *.json; do
                        echo "Resolving schema references for $i"
                        ../../../resolve-schema.py $i > resolved/$i
                        mv $i with-refs/
                        cp resolved/$i $i
                    done
                    cd ..
                for i in *.raml; do
                    echo "Generating HTML from $i..."
                    raml2html $i > "${i%%.raml}.html"
                done
                mkdir "../../$target_dir/html-APIs"
                mv *.html "../../$target_dir/html-APIs/"
                if [ -d schemas ]; then
                    echo "Linting schemas..."
                    jsonlint -v schemas/*.json
                    echo "Copying schemas..."
                    mkdir "../../$target_dir/html-APIs/schemas"
                    mkdir "../../$target_dir/html-APIs/schemas/with-refs"
                    cp schemas/with-refs/*.json "../../$target_dir/html-APIs/schemas/with-refs"
                    mkdir "../../$target_dir/html-APIs/schemas/resolved"
                    cp schemas/resolved/*.json "../../$target_dir/html-APIs/schemas/resolved"
                    echo "Tidying..."
                    # Restore things how they were to ensure next checkout doesn't overwrite
                    mv schemas/with-refs/*.json schemas/ 
                    rm -rf schemas/with-refs schemas/resolved
                fi
                cd ..
        fi
        if [ -d examples ]; then
            echo "Linting examples..."
            jsonlint -v examples/*.json
            echo "Copying examples..."
            cp -r examples "../$target_dir"
        fi
    cd ..
}

# Find out which branches and tags will be shown
. ./get-config.sh

mkdir branches
for branch in $(cd source-repo; git branch -r | sed 's:origin/::' | grep -v HEAD | grep -v gh-pages); do
    if [[ "$branch" =~ $SHOW_BRANCHES ]]; then
        extract "$branch" "branches/$branch"
    else
        echo Skipping branch $branch
    fi
done

mkdir tags
for tag in $(cd source-repo; git tag); do
    if [[ "$tag" =~ $SHOW_TAGS ]]; then
        extract "tags/$tag" "tags/$tag"
    else
        echo Skipping tag $tag
    fi
done
