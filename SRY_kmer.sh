#!/bin/bash
#################################################
# Usage
#################################################
function usage(){
echo """
Brief   :
    detect SRY kmers from male and female population data.

Usage   :
    ./SRY_kmers.sh [options]

Option  :
    --male_group    required    folder of male population.
                                NOTICE : for each individual, put it's fastq into a independant sub-folder.
                                NOITCE : fastq must be ended by "fastq" or "fastq.gz" or "fq" or "fq.gz"
    --female_group  required    folder of female population.
                                NOTICE : for each individual, put it's fastq into a independant sub-folder.
                                NOITCE : fastq must be ended by "fastq" or "fastq.gz" or "fq" or "fq.gz".
    --suffix        required    suffix of sequence files.
    --kmers         optional    [default 21] kmer-size.
    --thread        optional    [default 16] max threads for meryl.
    --memory        optional    [default 50] max memory for meryl. 
    --output        optional    [default output] output folder name.

Example :

    ./SRY_kmers.sh --male_group  xxx --female_group yyy \\
                   --output ouput --suffix fasta.gz

Author  :
    xumengyang@genomics.cn
    guolidong@genomics.cn
"""
}

#################################################
# global variables
#################################################

Male_folder='./'
Female_folder='./'
CPU=16
MEMPORY=100
SUFFIX=''

ROOT_PATH=`dirname $0`
ROOT_PATH=`realpath $ROOT_PATH`

SCRIPT_PATH=$ROOT_PATH"/scripts"
OUTPUT='output'
FORCE='no'
#################################################
# STEP 0 : parse arguments
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
        "--female_group")
            Female_folder=$2
            shift
            ;;
        "--male_group")
            Male_folder=$2
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
        "--output")
            OUTPUT=$2
            shift
            ;;
        "--thread")
            CPU=$2
            shift
            ;;
        *)
            echo "invalid params : \"$1\" . exit ... "
            exit
        ;;
    esac
    shift
done

Male_folder=`realpath $Male_folder`
Female_folder=`realpath $Female_folder`

# santity check
if [[ ! -d $Female_folder  || ! -d $Male_folder || -z $SUFFIX ]] ; then 
    echo "invalid parameters ... exit ... "
    usage
    exit 1
fi

mkdir -p $OUTPUT
cd $OUTPUT
mkdir -p logs

echo """
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
INSTALLED PATH      $ROOT_PATH
MALE GROUP PATH     $Male_folder
FEMALE GROUP PATH   $Female_folder
SUFFIX              $SUFFIX
MEMPORY             $MEMPORY Gb
THREAD              $CPU
OUTPUT              $OUTPUT
KMER                $KMER
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
"""

#################################################
# STEP 1 : run meryl count
#################################################

if [[ ! -e 'step01.meryl-count-male.done' || $FORCE == 'yes' ]] ; then
    echo '######'
    echo 'start step01.meryl-count-male'
    echo """
    mkdir -p male && cd male 
    $SCRIPT_PATH/meryl-count-group.sh --thread $CPU \\
        --memory $MEMPORY \\
        --group_folder $Male_folder \\
        --suffix $SUFFIX \\
        1> ../logs/step01.meryl-count-male.log \\
        2> ../logs/step01.meryl-count-male.err || exit 1
    cd ../
    """ 
    mkdir -p male && cd male 
    $SCRIPT_PATH/meryl-count-group.sh --thread $CPU \
        --memory $MEMPORY \
        --group_folder $Male_folder \
        --suffix $SUFFIX \
        1> ../logs/step01.meryl-count-male.log \
        2> ../logs/step01.meryl-count-male.err || exit 1
    cd ../
    echo 'done step01.meryl-count-male'
    date >>'step01.meryl-count-male.done'
else
    echo "skip meryl-count for $Male_folder due to step01.meryl-count-male.done exist ..."
fi

if [[ ! -e 'step01.meryl-count-female.done' || $FORCE == 'yes' ]] ; then
    echo '######'
    echo 'start step01.meryl-count-female'
    echo """
    mkdir -p female && cd female 
    $SCRIPT_PATH/meryl-count-group.sh --thread $CPU \\
        --memory $MEMPORY \\
        --group $Female_folder \\
        --suffix $SUFFIX \\
        1> ../logs/step01.meryl-count-female.log \\
        2> ../logs/step01.meryl-count-female.err || exit 1
    cd ../
    """
    mkdir -p female && cd female 
    $SCRIPT_PATH/meryl-count-group.sh --thread $CPU \
        --memory $MEMPORY \
        --group $Female_folder \
        --suffix $SUFFIX \
        1> ../logs/step01.meryl-count-female.log \
        2> ../logs/step01.meryl-count-female.err || exit 1
    cd ../
    echo 'done step01.meryl-count-female'
    date >>'step01.meryl-count-female.done'
else
    echo "skip meryl-count for $Female_folder due to step01.meryl-count-female.done exist ..."
fi

#################################################
# STEP 2 : Get Male-hapmer-union
#################################################

if [[ ! -e 'step02.male-hapmer-union.done' || $FORCE == 'yes' ]] ; then
    echo '######'
    echo 'start step02.male-hapmer-union'
    echo """
    $SCRIPT_PATH/meryl-hapmer-group.sh --thread $CPU \\
        --memory $MEMPORY \\
        --group ./ \\
        1 > ../logs/step02.male-hapmer-group.log \\
        2 > ../logs/step02.male-hapmer-group.err || exit 1
    cd ../
    """
    $SCRIPT_PATH/meryl-hapmer-group.sh --thread $CPU \
        --memory $MEMPORY \
        --group ./        \
        1 > ../logs/step02.male-hapmer-group.log \
        2 > ../logs/step02.male-hapmer-group.err || exit 1
    cd ../

    echo """
    mkdir -p male_hapmer_union && cd male_hapmer_union
    $SCRIPT_PATH/meryl-hapmer-union.sh --thread $CPU \\
        --memory $MEMPORY \\
        --group ../male \\
        1 > ../logs/step02.male-hapmer-union.log \\
        2 > ../logs/step02.male-hapmer-union.err || exit 1
    cd ../
    """
    mkdir -p male_hapmer_union && cd male_hapmer_union
    $SCRIPT_PATH/meryl-hapmer-union.sh --thread $CPU \
        --memory $MEMPORY \
        --group ../male   \
        1 > ../logs/step02.male-hapmer-union.log \
        2 > ../logs/step02.male-hapmer-union.err || exit 1
    cd ../

    echo 'done step02.male-hapmer-union'
    date >>'step02.male-hapmer-union.done'
else
    echo "skip male-hapmer-union due to step02.male-hapmer-union.done exist ..."
fi

#################################################
# STEP 3 : Get Female-main-union
#################################################

if [[ ! -e 'step03.female-main-union.done' || $FORCE == 'yes' ]] ; then
    echo '######'
    echo 'start step03.female-main-union'
    echo """
    cd female
    $SCRIPT_PATH/meryl-main-group.sh --thread $CPU \\
        --memory $MEMPORY \\
        --group ./  \\
        1 > ../logs/step03.meryl-main-group.log \\
        2 > ../logs/step03.meryl-main-group.err || exit 1
    cd ../
    """
    cd female
    $SCRIPT_PATH/meryl-main-group.sh --thread $CPU \
        --memory $MEMPORY \
        --group ./        \
        1 > ../logs/step03.meryl-main-group.log \
        2 > ../logs/step03.meryl-main-group.err || exit 1
    cd ../

    echo """
    mkdir -p female_main_union && cd female_main_union
    $SCRIPT_PATH/meryl-main-union.sh --thread $CPU \\
        --memory $MEMPORY \\
        --group ../female \\
        1 > ../logs/step03.meryl-main-union.log \
        2 > ../logs/step03.meryl-main-union.err || exit 1
    cd ../
    """
    mkdir -p female_main_union && cd female_main_union
    $SCRIPT_PATH/meryl-main-union.sh --thread $CPU \
        --memory $MEMPORY \
        --group ../female \
        1 > ../logs/step03.meryl-main-union.log \
        2 > ../logs/step03.meryl-main-union.err || exit 1
    cd ../
    echo 'done step03.female-main-union'
    date >>'step03.female-main-union.done'
else
    echo "skip female-main-union due to step03.female-main-union.done exist ..."
fi

#################################################
# STEP 4 : Get SRY-kmers
#################################################

if [[ ! -e 'step04.sry-kmers.done' || $FORCE == 'yes' ]] ; then
    echo '######'
    echo 'start step04.sry-kmers'
    echo """
    mkdir -p sry-kmers && cd sry-kmers
    $SCRIPT_PATH/sry-kmers.sh --thread $CPU \\
        --memory $MEMPORY \\
        --male_hapmer ../male_hapmer_union \\
        --female_main ../female_main_union \\
        1> ../logs/step04.sry-kmers.log \\
        2> ../logs/step04.sry-kmers.err ||exit 1
    cd ../
    """
    mkdir -p sry-kmers && cd sry-kmers
    $SCRIPT_PATH/merl-sry-kmers.sh --thread $CPU \
        --memory $MEMPORY \
        --male_hapmer ../male_hapmer_union \
        --female_main ../female_main_union \
        1> ../logs/step04.sry-kmers.log \
        2> ../logs/step04.sry-kmers.err ||exit 1
    cd ../
    echo 'done step04.sry-kmers'
    date >>'step04.sry-kmers.done'
else
    echo "skip sry-kmers due to step04.sry-kmers.done exist ..."
fi
