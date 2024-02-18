# MacOS FontAwesome Directory Icons

This document provides comprehensive guidance on using the Icon Generation Script. This Bash script automates the process of generating icon sets from SVG files and organizing them into specified directories. It's designed to enhance efficiency and streamline workflows for developers, designers, and content creators working with icon assets.

## Overview

The Icon Generation Script takes SVG files from a source directory, processes them, and places the resulting icon sets into a target directory. It features a dynamic progress bar that updates in real-time as icons are processed, providing feedback on the operation's progress.

## Features

- **SVG Processing**: Converts SVG files into macOS icon sets.
- **Dynamic Progress Bar**: Real-time progress feedback.
- **Customizable Source and Target Directories**: Flexibility in file organization.

## Getting Started

### Prerequisites

- **macOS or Linux Environment**: The script is a Bash script, compatible with macOS and Linux environments.
- **Folderify**: A command-line tool required for converting SVG files into macOS icon format. Ensure it is installed and accessible in your system's PATH.
- **Bash Version 4.0 or Higher**: Some features used in the script require Bash version 4.0 or higher.

### Installation

1. **Clone the repository** containing the script:

   ```bash
   git clone https://github.com/PatrickMaul/Scripts.git
   ```

2. **Navigate to the script's directory** and make the script executable:

   ```bash
   chmod +x dir-icon-generation.sh
   ```

## Usage

The script is executed from the command line with options to specify the source and target directories.

```bash
./dir-icon-generation.sh [-s <source_directory>] [-t <target_directory>]
```

### Command Line Options

- `-h`: Displays the help message and exits.
- `-s <source_dir>`: (Optional) Specifies the source directory containing SVG files. If not provided, a positional argument must be used.
- `<source_dir>`: Specifies the source directory as a positional argument.
- `-t <target_dir>`: (Optional) Specifies the target directory for the generated icon sets. Defaults to the current directory if not provided.

### Examples

- **Generate icons with specified source and target directories**:

  ```bash
  ./dir-icon-generation.sh -s /path/to/svgs -t /path/to/icons
  ```

- **Generate icons with source directory as a positional argument**:

  ```bash
  ./dir-icon-generation.sh /path/to/svgs
  ```

## Contributing

Your contributions and suggestions are welcome to improve the script's functionality and usability. Please feel free to fork the repository, make your changes, and submit a pull request.

## License

This script is provided under the MIT License. See the LICENSE file in the repository for full details.

## Contact

For questions, suggestions, or further assistance, please reach out to Patrick Maul at [Insert Contact Information].
