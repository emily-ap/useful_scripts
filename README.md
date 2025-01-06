# useful_scripts
Emily's Useful Scripts!!!

## use a text file to copy files from a separate directory 
```
for i in `cat file.txt` ; do cp /path/to/directory/$i . ; done
```

## prep a megahit final.contigs.fa file for post-assembly processing & binning
```
##Script for renaming scaffolds within the assembly file and copying it to new directory
#when you use this script, do ./rename_contigs.sh <original file> <new file name> <output directory>

#rename the final.contigs.fa and then,
#rename the scaffolds with the sample name with 'scaffold'
mv final.contigs.fa $1 &&
sed "s/^>/>$sample/" $1 >> $2 &&
sed -i 's/k127/_scaffold/g' $2 &&
mkdir $3 &&
cp $2 $3
```

## make contig list needed for DASTools from fasta files
```
#input sample name here
sample=<samplename>

grep ">" *.fna >> $sample-headers.txt &&
sed -i 's/:>/\t/g' $sample-headers.txt &&
#swaps values of the first two fields
awk ' { t = $1; $1 = $2; $2 = t; print; } ' $sample-headers.txt >> $sample-headers_ordered.txt &&
sed -i 's/\s/\t/g' $sample-headers_ordered.txt
```

