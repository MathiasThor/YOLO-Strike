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
-r, --resolutionconvert               convert the standard 416x416 anchors to
                                      the resolution specified as user input
EOF
    exit 1
}

if [ -z "$1" ]
  then
    usage "No argument supplied"
fi

train="none"
rescon="none"
viz_anchor=0
num_clusters=2
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -r|--resolutionconvert)
        rescon="yes"
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
if [ $rescon = "yes" ]; then
  echo "New anchor Width  (pixels): "
  read width
  echo "New anchor Height (pixels): "
  read height
  echo "Name of anchor file to be converted (do not use an already resolution converted file): "
  read file_name
  file_name="$PWD/output_data/anchors/$file_name"
  if [ ! -f $file_name ] || [ -z $file_name ]; then
    die "File '$file_name' not found!"
  fi
  echo " "
  echo "Converting $file_name to $width x $height..."
  echo " "
  python python_files/convert_anchor_res.py -anchor_file=$file_name -n_w=$width -n_h=$height

elif [ $viz_anchor = 1 ] && [ ! $train = "none" ]; then
  echo "Generating and Vizualizing anchors"
  python python_files/gen_anchors.py -filelist=$train -output_dir=$PWD/output_data/anchors/ -num_clusters=$num_clusters &> /dev/null
  python python_files/vizualize_anchors.py -anchor_dir=$PWD/output_data/anchors/ -visualization_dir=$PWD/output_data/ &> /dev/null
  echo "Generated:" # TODO: Make better
  echo "$PWD/output_data/anchors$num_clusters.png"
  echo "$PWD/output_data/anchors/anchors$num_clusters.txt"
  echo " "
  echo "Copy the content of this file into the yolo_obj.cfg file (after 'anchors=')"
  echo "The second line in the file shows the avg. IOU for the anchor"
elif [ $viz_anchor = 1 ]; then
  echo "Vizualizing anchors"
  python python_files/vizualize_anchors.py -anchor_dir=$PWD/output_data/anchors/ -visualization_dir=$PWD/output_data/ &> /dev/null
  echo ""
  echo "Generated:" # TODO: Make better
  echo "$PWD/output_data/anchors$num_clusters.png"
elif [ ! $train = "none" ]; then
  echo "Generating anchors from $train"
  python python_files/gen_anchors.py -filelist=$train -output_dir=$PWD/output_data/anchors/ -num_clusters=$num_clusters &> /dev/null
  echo ""
  echo "Generated:" # TODO: Make better
  echo "$PWD/output_data/anchors/anchors$num_clusters.txt"
  echo " "
  echo "Copy the content of this file into the yolo_obj.cfg file (after 'anchors=')"
  echo "The second line in the file shows the avg. IOU for the anchor"
else
  usage "No parameters provided"
fi
