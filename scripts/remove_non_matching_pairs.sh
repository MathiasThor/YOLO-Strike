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
This function can remove images and labels that does not have
a corresponding image or label.

Options:
-h, --help                       display this usage message and exit
-nd, --nodryrun                  does a dryrun (does not delete anything)
-p, --picturedir [PICTURE DIR]   path to directory containing training images
                                 default dir is: ./../data/images/
-l, --labeldir   [LABEL DIR]     path to directory containing training labels
                                 default dur is: ./../data/labels/
EOF
    exit 1
}

if [ -z "$1" ]
  then
    usage "No argument supplied"
fi

pic_dir="./../data/images/"
label_dir="./../data/labels/"
dryrun=1
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -d|--dryrun)
        dryrun=0
        ;;
    -p|--picturedir)
        if [ ! -d $2 ] || [ -z $2 ]; then
          die "Directory '$2' not found!"
        fi
        pic_dir="$2"
        shift
        ;;
    -l|--labeldir)
        if [ ! -d $2 ] || [ -z $2 ]; then
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
echo ""
echo "Seaching for images that are missing a label file (be patient):"
for i in $(echo $pic_dir | sed 's:/*$::')/*; do
    #echo -n "."
    fn=${i##*/}  ## strip path, leaving filename only
    fnn=${fn%.*}

    ## if file in backup matches filename, skip rest of loop
    ls ${label_dir} | sed -e 's/\..*$//' | grep -q $fnn &>/dev/null && continue

    if [ $dryrun = 1 ]; then
      echo "Following image is missing a label file:"
      echo "Will remove:" $i
    else
      echo "Following image is missing a label file:"
      echo "removing:" $i
      rm "$i" ## remove file
    fi
done

echo "Seaching for images that are missing an image file (be patient):"

for i in $(echo $label_dir | sed 's:/*$::')/*; do
    #echo -n "."
    fn=${i##*/}  ## strip path, leaving filename only
    fnn=${fn%.*}

    ## if file in backup matches filename, skip rest of loop
    ls ${pic_dir} | sed -e 's/\..*$//' | grep -q $fnn &>/dev/null && continue

    if [ $dryrun = 1 ]; then
      echo "Following image is missing a label file:"
      echo "Will remove:" $i
    else
      echo "Following image is missing a label file:"
      echo "removing:" $i
      rm "$i" ## remove file
    fi
done

if [ $dryrun = 1 ]; then
  echo "use -nd or --nodryrun to remove the above lised files"
fi
