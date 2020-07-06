#!/bin/bash

#################################################
# Usage
#################################################
function usage() {
echo """
Brief       :
    run kmer-count for each individual independently in a certain group.
Usage       :
    meryl-count-group.sh [options]

Options     :
        -h/--help               print this usage and exit.
        --group     [required]  path of group directory.
        --suffix    [optional]  [default: fq.gz] the suffix of sequence file.
        --kmer      [optional]  [default: 21] kmer-size.
        --thread    [optional]  [default: 16] the max thread number.
        --memory    [optional]  [default: 100] the max memory ( in Gb ) .

Example     :
    meryl-count-group.sh --group xxxx

    meryl-count-group.sh --kmer 21 --group xxxx --suffix fastq.gz

    meryl-count-group.sh --kmer 21 --group xxxx --suffix fastq.gz \\
                         --thread 8 --memory 50
"""
}

#################################################
# Global veriable
#################################################
CPU=16
MEMORY=100
Group=''
SUFFIX='fq.gz'
KMER=21

# import meryl into path
ROOT_PATH=`dirname $0`
ROOT_PATH=`realpath $ROOT_PATH`
PATH=$ROOT_PATH"/../bin/:"$PATH
# meryl -h

#################################################
# Parse arguments
#################################################

if [[ $# == 0 ]] ; then
    usage
    exit 0
fi
echo "CMD :$0 $*"
while [[ $# > 0 ]]
do
    case $1 in
        "-h")
            usage
            exit 0
            ;;
        "--help")
            usage
            exit 0
            ;;
        "--memory")
            MEMORY=$2
            shift
            ;;
        "--group")
            Group=$2
            shift
            ;;
        "--suffix")
            SUFFIX=$2
            shift
            ;;
        "--kmer")
            KMER=$2
            shift
            ;;
        "--thread")
            CPU=$2
            shift
            ;;
        *)
            echo "invalid params : \"$1\" . exit ... "
            exit 1
        ;;
    esac
    shift
done

# santity check
if [[ ! -d $Group ]] ; then 
    echo "$Group is not a directory ! exit ... "
    usage
    exit 1
fi

#################################################
# Main
#################################################

for x in `ls $Group`
do
    if [[ ! -d $Group/$x ]] ; then 
        echo "skip $x in $Group because it is not a folder !"
        continue 
    fi

    reads=`ls $Group/$x/*$SUFFIX`
    read_num=`ls $Group/$x/*$SUFFIX | wc -l`

    if [[ $read_num == 0 ]] ; then 
        echo "skip $x because no reads found in $Group/$x by suffix $SUFFIX !!!"
        continue
    fi

    echo "found reads : { $reads } in $Group/$x ."
    echo """
    mkdir -p $x && cd $x
    """
    mkdir -p $x && cd $x

    echo "mery count for $x ..."

    if [[ ! -e $x.meryl ]] ; then
        echo """
        meryl threads=$CPU memory=$MEMORY k=$KMER count output $x.meryl $reads || exit 1
        """
        meryl threads=$CPU memory=$MEMORY k=$KMER count output $x.meryl $reads || exit 1
    else
        echo "use exist $x.meryl"
    fi
    echo """
    cd ..
    """
    cd ..
    echo "mery count for $x done."
done
