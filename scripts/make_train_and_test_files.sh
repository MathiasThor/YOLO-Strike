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
-c, --clean                      remove all files generated by this script
-p, --picturedir [PICTURE DIR]   path to directory containing training images
-r, --percentage [  0 - 100  ]   how many percentage of the data should train
                                 contain. ( default is 85% )
EOF
    exit 1
}

pic_dir=""
label_dir=""
clean=0
procent=0.85
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -c|--clean)
        clean=1
        ;;
    -p|--picturedir)
        if [ ! -d $2 ]; then
          die "Directory '$2' not found!"
        fi
        pic_dir="$2"
        shift
        ;;
    -r|--percentage)
        procent=`bc <<<"scale=2; $2 / 100"`
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

file="file_names_all.txt"
file_split_dir="file_names_splitted"
train="train.txt"
test="test.txt"

if [[ $clean = 1 ]]; then
  rm $file
  rm -r $file_split_dir
  rm $train
  rm $test
else

  if [ -f $file ] ; then
      rm $file
  fi

  ls $pic_dir | sed -e 's/\..*$//' > $file

  if [ -d $file_split_dir ]; then
    rm -r $file_split_dir
  fi

  mkdir -p $file_split_dir
  cd $file_split_dir
  split -d -l 100 ./../$file
  find . -type f -exec mv '{}' '{}'.txt \;
  cd - &> /dev/null

  num_lines=`find $pic_dir -maxdepth 1 | wc -l`
  num_lines=$((num_lines-1))
  limit=$(expr $num_lines*$procent | bc | awk '{print int($1+0.5)}')

  find $pic_dir -maxdepth 1 | head -n "$limit" > $train
  sed -i '1d' $train

  limit=$((limit+1))
  find $pic_dir -maxdepth 1 | tail -n +"$limit" > $test

fi
