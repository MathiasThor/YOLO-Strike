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
-h, --help                       display this usage message and exit
-d, --dryrun                     does a dryrun (does not delete anything)
-p, --picturedir [PICTURE DIR]   path to directory containing training images
-l, --labeldir   [LABEL DIR]     path to directory containing training labels

EOF
    exit 1
}

pic_dir=""
label_dir=""
dryrun=0
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -d|--dryrun)
        dryrun=1
        ;;
    -p|--picturedir)
        if [ ! -d $2 ]; then
          die "Directory '$2' not found!"
        fi
        pic_dir="$2"
        shift
        ;;
    -l|--labeldir)
        if [ ! -d $2 ]; then
          die "Directory '$2' not found!"
        fi
        label_dir="$2"
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

for i in $(echo $pic_dir | sed 's:/*$::')/*; do
    #echo -n "."
    fn=${i##*/}  ## strip path, leaving filename only
    fnn=${fn%.*}

    ## if file in backup matches filename, skip rest of loop
    ls ${label_dir} | sed -e 's/\..*$//' | grep -q $fnn &>/dev/null && continue

    if [ $dryrun = 1 ]; then
      echo "Will remove:" $i
    else
      echo "removing:" $i
      rm "$i" ## remove file
    fi
done
echo "..."
for i in $(echo $label_dir | sed 's:/*$::')/*; do
    #echo -n "."
    fn=${i##*/}  ## strip path, leaving filename only
    fnn=${fn%.*}

    ## if file in backup matches filename, skip rest of loop
    ls ${pic_dir} | sed -e 's/\..*$//' | grep -q $fnn &>/dev/null && continue

    if [ $dryrun = 1 ]; then
      echo "Will remove:" $i
    else
      echo "removing:" $i
      rm "$i" ## remove file
    fi
done
