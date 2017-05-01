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
This script initializes the workspace.

Options:
-h, --help              display this usage message and exit
EOF
    exit 1
}

filename=""
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
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
echo "Initializing your YOLO Workspace"

echo -n "Enter the number of classes in your dataset (1-99): "
read num_of_classes
[[ "$num_of_classes" =~ -?[0-9]+ ]] || die "You need to input an integer!"
(( num_of_classes >= 1 && num_of_classes <= 99 )) || die "The integer you entered is out of range!"
echo ""

> obj.names
for ((i=1; i<=num_of_classes; i++)); do
  echo -n "Enter the name of object $i: "
  read name
  echo $name >> obj.names
done

echo ""
while true; do
    read -p "Do you have an NVIDIA GPU + CUDA and want to compile darknet with it? (y/n): " yn
    case $yn in
        [Yy]* ) gpu="yes"; break;;
        [Nn]* ) gpu="no";  break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""
while true; do
    read -p "Do you have CUDNN and want to compile darknet with it? (y/n): " yn
    case $yn in
        [Yy]* ) cudnn="yes"; break;;
        [Nn]* ) cudnn="no";  break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""
while true; do
    read -p "Do you have OpenCV and want to compile darknet with it? (y/n): " yn
    case $yn in
        [Yy]* ) opencv="yes"; break;;
        [Nn]* ) opencv="no";  break;;
        * ) echo "Please answer yes or no.";;
    esac
done

sed -i "s/^classes=.*/classes=${num_of_classes}/" obj.data
sed -i "s/^classes=.*/classes=${num_of_classes}/" yolo-obj.cfg
newfilter=$(((${num_of_classes}+5)*5))
tac yolo-obj.cfg | sed "0,/filters=/ s/^filters=.*/filters=${newfilter}/" | tac > yolo-obj_tmp.cfg
mv yolo-obj_tmp.cfg yolo-obj.cfg

# TODO: Replace filters in yolo cfg

if [ $gpu = "yes" ]; then
  sed -i 's/^GPU=.*/GPU=1/' Makefile
else
  sed -i 's/^GPU=.*/GPU=0/' Makefile
fi

if [ $cudnn = "yes" ]; then
  sed -i 's/^CUDNN=.*/CUDNN=1/' Makefile
else
  sed -i 's/^CUDNN=.*/CUDNN=0/' Makefile
fi

if [ $opencv = "yes" ]; then
  sed -i 's/^OPENCV=.*/OPENCV=1/' Makefile
else
  sed -i 's/^OPENCV=.*/OPENCV=0/' Makefile
fi

echo ""
while true; do
    read -p "Do you want to 'make'? (y/n): " yn
    case $yn in
        [Yy]* )
        make;
        echo ""
        echo "You are now ready to train and detect with YOLO"
        echo " "
        echo "Note: Please place your training images in ./data/obj-images"
        echo "Note: Pleace place your training labels in ./data/obj-labels"
        break;;
        [Nn]* )
        echo ""
        echo "The workspace has been set up to meet your requirements"
        echo "Run 'make' in your root workspace folder."
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done
