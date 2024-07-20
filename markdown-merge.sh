#!/bin/bash

# Function to display help
function display_help() {
  echo "Usage: $0 [OPTIONS] [OUTFILE]"
  echo
  echo "Options:"
  echo "  -o, --outfile    Output file (default: first argument without any '-')"
  echo "  -v, --verbose    Enable verbose output (default: false)"
  echo "  -i, --inpath     Input directory path (default: current working directory)"
  echo "  -g, --glob       Input file glob pattern (default: .md)"
  echo "  -h, --help       Display this help and exit"
  echo
}

# Default values
outfile=""
verbose=false
inpath="."
glob="*.md"

# Parse options
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -o|--outfile) outfile="$2"; shift ;;
    -v|--verbose) verbose=true ;;
    -i|--inpath) inpath="$2"; shift ;;
    -g|--glob) glob="$2"; shift ;;
    -h|--help) display_help; exit 0 ;;
    *) outfile="$1" ;;
  esac
  shift
done

# Set outfile to first non-option argument if not set
if [ -z "$outfile" ] && [[ "$1" != "-"* ]]; then
  outfile="$1"
fi

# Verbose output function
function v_echo() {
  if [ "$verbose" = true ]; then
    echo "$@"
  fi
}

v_echo "Output file: $outfile"
v_echo "Verbose: $verbose"
v_echo "Input path: $inpath"
v_echo "File glob pattern: $glob"

# Create a temporary markdown file if no outfile is specified
if [ -z "$outfile" ]; then
  outfile=$(mktemp)
fi

# Generate TOC
v_echo "Generating Table of Contents..."
echo "" > $outfile
for file in "$inpath"/$glob; do
  if [ "$file" != "$outfile" ]; then
    echo "- [$(basename "$file")](#$(basename "$file"))" >> $outfile
  fi
done

# Add a newline after TOC
echo "" >> $outfile

# Concatenate files with anchors
v_echo "Concatenating files..."
for file in "$inpath"/$glob; do
  if [ "$file" != "$outfile" ]; then
    echo "### <a name=\"$(basename "$file")\">$(basename "$file")</a>" >> $outfile
    cat "$file" >> $outfile
    echo -e "\n----\n" >> $outfile
  fi
done

# Echo the final contents if no outfile is specified
if [[ "$outfile" == "$(basename "$outfile")" ]]; then
  cat $outfile
  rm $outfile
else
  v_echo "Done! The output is in $outfile"
fi
