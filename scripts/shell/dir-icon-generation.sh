#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: $0 [-h] [-s] <source_directory> [-t <target_directory>]"
    echo ""
    echo "Options:"
    echo "  -h                 Display this help message and exit."
    echo "  -s <source_dir>    Specify the source directory to process. This option is optional."
    echo "  <source_dir>       Specify the source directory as a positional argument."
    echo "  -t <target_dir>    Specify the target directory. This option is optional."
    echo ""
    echo "The <source_directory> is mandatory and can be specified either with -s option or as a positional argument."
}

# Function to parse and handle command line options
parse_options() {
    while getopts ":hs:t:" option; do
        case "${option}" in
            h)
                display_help
                exit 0
                ;;
            s)
                SOURCE_DIRECTORY=${OPTARG}
                SOURCE_SPECIFIED_WITH_S=true
                ;;
            t)
                TARGET_DIRECTORY=${OPTARG}
                ;;
            ?)
                echo "Error: Invalid option -${OPTARG}." >&2
                display_help
                exit 1
                ;;
            :)
                echo "Error: Option -${OPTARG} requires an argument." >&2
                exit 1
                ;;
        esac
    done

    # Check if source directory was specified as a positional argument
    if ! $SOURCE_SPECIFIED_WITH_S; then
        shift $((OPTIND-1))
        if [ -n "$1" ]; then
            SOURCE_DIRECTORY=$1
        else
            echo "Error: A source directory must be specified." >&2
            display_help
            exit 1
        fi
    fi
}

# Function to verify input and set defaults
verify_and_set_defaults() {
    # Verify that a source directory has been provided
    if [ -z "${SOURCE_DIRECTORY}" ]; then
        echo "Error: A source directory must be specified." >&2
        display_help
        exit 1
    fi

    # Specify default target directory (e.g., current directory) if not provided
    if [ -z "${TARGET_DIRECTORY}" ]; then
        TARGET_DIRECTORY="." # Default to current directory if not specified
    fi
}

# Function to generate icons and show progress
generate_icons() {
    # Initialize variables
    declare -i index=0
    declare -a result=()
    declare -i total_icons=0
    declare -i processed_icons=0
    declare -a fails=()

    # Count total number of SVG files for progress calculation
    for dir in "${SOURCE_DIRECTORY}"/*/; do
        if [ -d "$dir" ]; then
            total_icons+=$(find "$dir" -name '*.svg' | wc -l)
        fi
    done

    # Check if total_icons is greater than 0
    if [ $total_icons -eq 0 ]; then
        echo "No SVG files found in the source directory."
        return
    fi

    # Iterate through icon directories
    echo "$LOG_PREFIX Start generating $total_icons icon sets"
    for dir in "${SOURCE_DIRECTORY}"/*/; do
        if [ -d "$dir" ]; then
            icons_sub_dir_path="$dir"
            # Change cwd
            cd "$dir" || continue

            # Iterate through SVG icons
            for icon in *.svg; do
                if [ -f "$icon" ]; then
                    icon_svg_path="$icons_sub_dir_path$icon"
                    iconset_path="${TARGET_DIRECTORY}/$(basename "$icon" .svg)"
                    iconset_svg_path="$iconset_path/$icon"

                    echo
                    echo "Start processing: $icon"
                    if [ -d "$iconset_path" ]; then
                      echo "Target directory ('$iconset_path') already exists!"
                      echo "Skipping $icon"
                    else
                      # Make iconset dir
                      mkdir -p "$iconset_path"
                      echo "Make dir: $iconset_path"
                      # Copy svg into target
                      cp "$icon_svg_path" "$iconset_svg_path"
                      echo "Copied from: $icon_svg_path"
                      echo "Copied   to: $iconset_svg_path"
                      folderify --output-icns "$iconset_path/$(basename "$icon" .svg).icns" --output-iconset "$iconset_path/$(basename "$icon" .svg).iconset" --no-progress --verbose "$iconset_svg_path" "$iconset_path" > /dev/null 2>&1
                      echo "Successfully generated MacOS dir icon for: $icon"
                    fi
                else
                  echo "'$icon' is not a file!"
                  echo "Skipping '$icon'"
                fi
                # Increment processed icons and update progress
                ((processed_icons++))
                show_progress "$processed_icons" "$total_icons" "$icon" "$iconset_path"
            done
            # Reset to the parent directory
            cd "${SOURCE_DIRECTORY}" || exit
        else
          echo "'$dir' is not a directory!"
          echo "Skipping '$dir'"
        fi
    done
}

# Function to display a progress bar
show_progress() {
    local current_step=$1
    local total_steps=$2
    local icon_processed=$3
    local icon_target=$4
    local progress=$((current_step * 100 / total_steps))
    local filled=$((progress / 2)) # Number of filled parts of the progress bar
    local unfilled=$((50 - filled)) # Remaining parts

    # Calculate how many lines we want to move up
    # local lines_to_move_up=0
    # Move cursor up to overwrite previous progress display
    # printf "\033[%dA" $lines_to_move_up

    # Display progress bar on its own line
    printf "\r["
    printf "%-${filled}s" | tr ' ' '#'
    printf "%-${unfilled}s" "]"
    printf " %d%% (%d/%d)\n" $progress $current_step $total_steps

    # Display additional "information on the next %s" line
    # printf "\r\033[K" # Clear the line
    # echo "Last processed icon: $icon_processed"
    # printf "\r\033[K" # Clear the line
    # echo "Target directory: $icon_target"
}

# Main logic of the script
main() {
    parse_options "$@"
    verify_and_set_defaults
    echo "$LOG_PREFIX Start generating MacOS iconized dir icons"
    echo "$LOG_PREFIX Processing source directory: ${SOURCE_DIRECTORY}"

    generate_icons ${SOURCE_DIRECTORY} ${TARGET_DIRECTORY}
    echo "$LOG_PREFIX Successfully processed all icons. Have fun."
}

# Initialize global variables
SOURCE_DIRECTORY=""
TARGET_DIRECTORY=""
SOURCE_SPECIFIED_WITH_S=false
LOG_PREFIX="[$0] ->"

# Entry point of the script
main "$@"
