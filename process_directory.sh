#!/bin/bash

# Define the output file
output_file="content.txt"

# Clear the output file if it exists
> "$output_file"

# Define arrays for excluded directories and files
excluded_dirs=("node_modules" "dist" "build")
excluded_files=("package-lock.json" "content.txt" "process_directory.sh")

# Function to check if an item is in the exclusion list
is_excluded() {
    local item="$1"
    local type="$2" # "dir" or "file"
    local exclude_list

    if [ "$type" == "dir" ]; then
        exclude_list=("${excluded_dirs[@]}")
    else
        exclude_list=("${excluded_files[@]}")
    fi

    for exclude in "${exclude_list[@]}"; do
        if [[ "$item" == *"/$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to process directories
process_directory() {
    local dir="$1"
    local indent="$2"
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            if is_excluded "$item" "dir"; then
                continue
            fi
            echo "${indent}├── $(basename "$item")/" >> "$output_file"
            process_directory "$item" "│   $indent"
        elif [ -f "$item" ]; then
            if is_excluded "$item" "file"; then
                continue
            fi
            echo "${indent}├── $(basename "$item")" >> "$output_file"
            echo "${indent}│   " >> "$output_file"
            cat "$item" | sed "s/^/${indent}│   /" >> "$output_file"
            echo -e "\n" >> "$output_file"
        fi
    done
}

# Check if the -only flag is provided
if [[ "$1" == "-only" ]]; then
    target_dir="$2"
    if [ -d "$target_dir" ]; then
        echo "$target_dir/" >> "$output_file"
        process_directory "$target_dir" ""
    else
        echo "The directory '$target_dir' does not exist."
    fi
else
    # Start processing from the current directory
    echo "./" >> "$output_file"
    process_directory "." ""
fi