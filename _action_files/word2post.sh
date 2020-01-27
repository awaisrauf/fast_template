#!/bin/sh

# This sets the environment variable when testing locally and not in a GitHub Action
if [ -z "$GITHUB_ACTIONS" ]; then
    GITHUB_WORKSPACE='/data'
    echo "=== Running Locally: All assets expected to be in the directory /data ==="
fi

# Loops through directory of *.docx files and converts to markdown
# markdown files are saved in _posts, media assets are saved in assets/img/<filename>/media
for FILENAME in ${GITHUB_WORKSPACE}/_word/*.docx; do
    
    NAME=${FILENAME##*/} # Get filename without the directory
    NEW_NAME=`python3 "${GITHUB_WORKSPACE}/_action_files/word2post.py" "${FILENAME}"` # clean filename to be Jekyll compliant for posts
    BASE_NEW_NAME=${NEW_NAME%.md}  # Strip the file extension

    if [ -z "$NEW_NAME" ]; then
        echo "Unable To Rename: ${FILENAME} to a Jekyll complaint filename for blog posts"
        exit 1
    fi
    
    echo "Converting: ${NAME}  ---to--- ${NEW_NAME}"

    pandoc --from docx --to gfm --output "${GITHUB_WORKSPACE}/_posts/${NEW_NAME}" --columns 9999 \
    --extract-media="${GITHUB_WORKSPACE}/assets/img/${BASE_NEW_NAME}" --standalone "${FILENAME}"
done