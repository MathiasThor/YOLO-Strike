#!/bin/bash
set -e

PROGNAME=$(basename $0)

die() {
    echo "$PROGNAME: $*" >&2
    exit 1
}

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION ...] [foo] [bar]

Options:
-h, --help              display this usage message and exit
-f, --file [LOGFILE]    path to YOLO log file
EOF
    exit 1
}

filename=""
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -f|--file)
        if [ ! -f $2 ] || [ -z $2 ]; then
          die "File '$2' not found!"
        fi
        filename="$2"
        shift
        ;;
    -*)
        usage "Unknown option '$1'"
        ;;
    *)
        usage "Invalid parameter was provided: '$1'"
        ;;
    esac
    shift
done

################ MAIN
echo "Plotting $filename"
# temp_file="tmpfile.txt"
temp_file=$(mktemp /tmp/abc-script.XXXXXX)

sed -n '/^[0-9]/p' $filename > $temp_file
sed -n '/images$/p' $filename > $temp_file
awk -F'[: ]' '{print $1 "\t" $4}' $temp_file > temp_file.tmp && mv temp_file.tmp $temp_file

python ./python_files/plotter.py $temp_file &> /dev/null

rm ${temp_file}
