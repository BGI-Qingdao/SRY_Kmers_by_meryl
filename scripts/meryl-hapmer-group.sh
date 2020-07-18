#!/bin/bash
#################################################
# Usage
#################################################

function usage() {
echo """
Brief       :
    get hapmer for each individual mery-count-lib in a certain group.
Usage       :
    meryl-hapmer-group.sh [options]

Options     :
        -h/--help               print this usage and exit.
        --group     [required]  path of group directory.
        --thread    [optional]  [default: 16] the max thread number.
        --memory    [optional]  [default: 30] the max memory ( in Gb ) .

Example     :
    meryl-hapmer-group.sh --group xxxx

    meryl-hapmer-group.sh --group xxxx --thread 8 --memory 30
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

for x in `ls $Group`
do
    if [[ ! -d $Group/$x ]] ; then 
        echo "skip $x in $Group because it is not a folder !"
        continue 
    fi

    echo "start $x ..."
    echo """
    mkdir -p $x && cd $x
    """
    mkdir -p $x && cd $x

    if [[ ! -e bounds.txt ]] ; then
        echo """
        meryl histogram $Group/$x/$x'.meryl' >$x'.hist'
        awk -f $ROOT_PATH/get_bd.awk $x'.hist' >bounds.txt
        """
        meryl histogram $Group/$x/$x'.meryl' >$x'.hist'
        awk -f $ROOT_PATH/get_bd.awk $x'.hist' >bounds.txt
    else
        echo " use old bounds.txt."
    fi

    MIN=`grep MIN_INDEX bounds.txt | awk -F '=' '{print $2}'`
    MAX=`grep MAX_INDEX bounds.txt | awk -F '=' '{print $2}'`

    echo "interval for $x is ( $MIN , $MAX ) "
    if [[ ! -e $x.'_gt'$MIN'.meryl' ]] ; then 
        echo """
        meryl greater-than $MIN  $Group/$x/$x'.meryl' output $x'_gt'$MIN'.meryl'
        """
        meryl greater-than $MIN  $Group/$x/$x'.meryl' output $x'_gt'$MIN'.meryl'
    else
        echo " use exist $x'_gt'$MIN'.meryl'"
    fi

    if [[ ! -e $x'_gt'$MIN'_lt'$MAX'.meryl' ]] ; then 
        echo """
        meryl less-than $MAX  $x'_gt'$MIN'.meryl' output $x'_gt'$MIN'_lt'$MAX'.meryl'
        """
        meryl less-than $MAX  $x'_gt'$MIN'.meryl' output $x'_gt'$MIN'_lt'$MAX'.meryl'
    else
        echo " use exist $x'_gt'$MIN'_lt'$MAX'.meryl'"
    fi

    echo """
    ln -s $x'_gt'$MIN'_lt'$MAX'.meryl' $x'.hapmer.meryl'
    cd ..
    """
    ln -s $x'_gt'$MIN'_lt'$MAX'.meryl' $x'.hapmer.meryl'
    cd ..

    echo "end $x ..."
done
