# useful_scripts
My useful scripts

## script to make DASTools contig list needed for DASTools from fasta files
```
#input sample name here
sample=<samplename>

grep ">" *.fna >> $sample-headers.txt &&
sed -i 's/:>/\t/g' $sample-headers.txt &&
#swaps values of the first two fields
awk ' { t = $1; $1 = $2; $2 = t; print; } ' $sample-headers.txt >> $sample-headers_ordered.txt &&
sed -i 's/\s/\t/g' $sample-headers_ordered.txt
```
