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
-h, --help                            display this usage message and exit
-g, --genanchors  [TRAININGFILE]      path to the training file for your data
-c, --clusternums [NUMBEROFCLUSTERS]  the desired number of clusters (default 2)
-v, --vizualizeanchors                vizualize the anchors
EOF
    exit 1
}

if [ -z "$1" ]
  then
    usage "No argument supplied"
fi

train="none"
viz_anchor=0
num_clusters=2
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -g|--genanchors)
        if [ ! -f $2 ] || [ -z $2 ]; then
          die "File '$2' not found!"
        fi
        train="$2"
        eval train=$train
        shift
        ;;
    -c|--numberofclusters)
        if [ -z $2 ]; then
          die "Please input number of clusters"
        fi
        num_clusters=$2
        shift
        ;;
    -v|--vizualizeanchors)
        viz_anchor=1
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

# TODO:
# python python_files/convert_anchor_res.py -anchor_file=./anchors/anchors7.txt -n_w=800 -n_h=800

################ MAIN
if [ $viz_anchor = 1 ] && [ ! $train = "none" ]; then
  echo "Generating and Vizualizing anchors"
  python python_files/gen_anchors.py -filelist=$train -output_dir=$PWD/output_data/anchors/ -num_clusters=$num_clusters &> /dev/null
  python python_files/vizualize_anchors.py -anchor_dir=$PWD/output_data/anchors/ -visualization_dir=$PWD/output_data/ &> /dev/null
  echo "Generated:" # TODO: Make better
  ls -d -1 $PWD/output_data/anchors*.png
  ls -d -1 $PWD/output_data/anchors/*
elif [ $viz_anchor = 1 ]; then
  echo "Vizualizing anchors"
  python python_files/vizualize_anchors.py -anchor_dir=$PWD/output_data/nchors/ -visualization_dir=$PWD/output_data/ &> /dev/null
  echo ""
  echo "Generated:" # TODO: Make better
  ls -d -1 $PWD/output_data/anchors*.png
elif [ ! $train = "none" ]; then
  echo "Generating anchors from $train"
  python python_files/gen_anchors.py -filelist=$train -output_dir=$PWD/output_data/anchors/ -num_clusters=$num_clusters &> /dev/null
  echo ""
  echo "Generated:" # TODO: Make better
  ls -d -1 $PWD/output_data/anchors/*
else
  usage "No parameters provided"
fi
