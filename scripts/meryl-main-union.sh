#!/bin/bash
#################################################
# Usage
#################################################

function usage() {
echo """
Brief       :
    get main union for a certain group.
Usage       :
    meryl-main-union.sh [options]

Options     :
        -h/--help               print this usage and exit.
        --group     [required]  path of group directory.
        --thread    [optional]  [default: 16] the max thread number.
        --memory    [optional]  [default: 30] the max memory ( in Gb ) .

Example     :
    meryl-main-group.sh --group xxxx

    meryl-main-group.sh --group xxxx --thread 8 --memory 30
"""
}

#################################################
# Global veriable
#################################################
CPU=16
MEMORY=30
Group=''

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

Group=`realpath $Group`
# santity check
if [[ ! -d $Group ]] ; then 
    echo "$Group is not a directory ! exit ... "
    usage
    exit 1
fi

#################################################
# Main
#################################################
id=0
batch=0
libs=''
for x in `ls $Group`
do
    id=$((id+1))
    if [[ -d $Group/$x/$x.main.meryl ]] ; then 
       libs=$libs" "$Group/$x/$x.main.meryl
    fi
    if [[ $id -eq 10 ]] ; then 
        batch=$((batch+1))
        echo """
        meryl union output main_union_batch_$batch.meryl $libs
        """
        meryl union output main_union_batch_$batch.meryl $libs

        libs=''
        id=0
    fi
done

if [[ $id -gt 0 ]] ; then
    batch=$((batch+1))
    echo """
    meryl union output main_union_batch_$batch.meryl $libs
    """
    meryl union output main_union_batch_$batch.meryl $libs
fi

echo """
meryl union-sum output main_union.meryl main_union_batch_*.meryl
"""
meryl union-sum output main_union.meryl main_union_batch_*.meryl

echo "Done"
