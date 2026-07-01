#!/bin/bash

# Parse command-line options
OPTS=$(getopt -o f:d:h --long file:,directory:,help -n 'file_processor.sh' -- "$@")

if [ $? -ne 0 ]; then
  echo "Failed to parse options" >&2
  exit 1
fi

# Reset the positional parameters to the parsed options
eval set -- "$OPTS"

# Initialize variables
FILE=""
DIRECTORY=""
HELP=false

# Process the options
while true; do
  case "$1" in
    -f | --file)
      FILE="$2"
      shift 2
      ;;
    -d | --directory)
      DIRECTORY="$2"
      shift 2
      ;;
    -h | --help)
      HELP=true
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

# Display the results
if [ "$HELP" = true ]; then
  echo "Usage: $0 [-f|--file FILE] [-d|--directory DIR] [-h|--help]"
  echo ""
  echo "Options:"
  echo "  -f, --file FILE      Specify a file to process"
  echo "  -d, --directory DIR  Specify a directory to process"
  echo "  -h, --help           Display this help message"
  exit 0
fi

if [ -n "$FILE" ]; then
  if [ -f "$FILE" ]; then
    echo "Processing file: $FILE"
    echo "File size: $(wc -c < "$FILE") bytes"
  else
    echo "Error: File '$FILE' does not exist or is not a regular file"
  fi
fi

if [ -n "$DIRECTORY" ]; then
  if [ -d "$DIRECTORY" ]; then
    echo "Processing directory: $DIRECTORY"
    echo "Files in directory: $(ls -1 "$DIRECTORY" | wc -l)"
  else
    echo "Error: Directory '$DIRECTORY' does not exist or is not a directory"
  fi
fi

if [ -z "$FILE" ] && [ -z "$DIRECTORY" ] && [ "$HELP" = false ]; then
  echo "No file or directory specified. Use -h or --help for usage information."
fi