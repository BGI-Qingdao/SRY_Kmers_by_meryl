#!/bin/bash
#################################################
# Usage
#################################################

function usage() {
echo """
Brief       :
    get sry-kmers from male_hapmer and female_main
Usage       :
    sry-kmers.sh [options]

Options     :
        -h/--help               print this usage and exit.
        --male      [required]  path to male population meryl-lib
        --female    [required]  path to female population meryl-lib
        --thread    [optional]  [default: 16] the max thread number.
        --memory    [optional]  [default: 30] the max memory ( in Gb ) .

        --min_female_support [optional]  [default 0] the minimum number of individual
                                          that support femle kmers . set this in case 
                                          when you suspect that there are mixed males
                                          in the females.

Example     :
    meryl-main-group.sh --male  male.meryl --female female.meryl

    meryl-main-group.sh --male  male.meryl --female female.meryl  \\
                        --thread 30 --memory 20

    meryl-main-group.sh --male  male.meryl --female female.meryl
                        --thread 30 --memory 20 --min_female_support 3
"""
}

#################################################
# Global veriable
#################################################
CPU=16
MEMORY=30
MALE=''
FEMALE=''
MIN_FEMALE_SUPPORT=0

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
        "--female")
            FEMALE=$2
            shift
            ;;
        "--min_female_support")
            MIN_FEMALE_SUPPORT=$2
            shift
            ;;
        "--male")
            MALE=$2
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
if [[ ! -d $MALE || ! -d $FEMALE ]] ; then 
    usage
    exit 1
fi

#################################################
# Main
#################################################

if [[ ! -e link.female.meryl ]] ; then 
    if [[ $MIN_FEMALE_SUPPORT -gt 0 ]] ; then 
        MIN=$((MIN_FEMALE_SUPPORT-1))
        echo """
        meryl greater-than $MIN output temp_female.gt$MIN.meryl $FEMALE
        ln -s temp_female.gt$MIN.meryl link.female.meryl
        """
        meryl greater-than $MIN output temp_female.gt$MIN.meryl $FEMALE
        ln -s temp_female.gt$MIN.meryl link.female.meryl
    else
        echo """
        ln -s $FEMALE link.female.meryl
        ""
        ln -s $FEMALE link.female.meryl
    fi
else
    echo " use exist link.female.meryl "
fi

if [[ ! -e SRY_Kmers.meryl ]] ; then
    echo """
    meryl difference output sry_kmers.meryl $MALE link.female.meryl
    """
    meryl difference output sry_kmers.meryl $MALE link.female.meryl
else
    echo "use exist SRY_Kmers.meryl "
fi
echo "Done"
