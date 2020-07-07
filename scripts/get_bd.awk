BEGIN{
    MIN=0;
    MIN_INDEX=0;
    MAX_INDEX=0;
    MAX=0;
    STATE=0; # 0 for find min ; 1 for find max
}
{
    i=0+$1; # kmer-count
    c=0+$2; # count of kmer-count
    if(S==0 ) {
        if(MIN==0 || c<MIN) {
            MIN=c ;
            MIN_INDEX=i;
        }else
            S=1;
    }
    else
    {
        if(MAX==0 || c>MAX) {
            MAX=c;
            MAX_INDEX=i;
        }
    }
}
END{
    printf("MIN_INDEX=%d\nMAX_INDEX=%d\n",MIN_INDEX,MAX_INDEX);
}
