#!/bin/bash

function create_link {
    # 1. Store the first parameter to the script in a variable.
    file_name="$1"

    # 2. Now that we expect a parameter, lets check if it was provided.
    if [[ -z "$file_name" ]]; then
        echo "Script expects a parameter"
        exit 1
    fi

    # 3. Create the symlink
    pushd $SRCROOT/Snowplow/include
    path=$(find ../Internal -name $file_name)
    ln -vs $path .
    popd
}

function check_link {
    # 1. Store the first parameter to the script in a variable.
    path="$1"

    # 2. Now that we expect a parameter, lets check if it was provided.
    if [[ -z "$path" ]]; then
        echo "Script expects a parameter"
        exit 1
    fi

    # 3. Check if the parameter is a symlink.
    if [[ -L "$path" ]]; then
        # 4. Check if it links to a valid path.
        if [[ -e "$path" ]]; then
            echo "$path is a valid link!"
        else
            unlink "$path"
            echo "Cleaned up broken link: $path"
        fi
    else
        echo "$path is not a symlink."
    fi
}

for i in `ls $TARGET_BUILD_DIR/$PUBLIC_HEADERS_FOLDER_PATH`; do create_link $i ; done

for i in $SRCROOT/Snowplow/include/*.h; do check_link $i ; done 
