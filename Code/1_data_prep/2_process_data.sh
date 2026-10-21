#!/bin/bash

#code to process the files for the formative

DATADIR='../../data/'

cd ${DATADIR}/original

#remove first line in each of the accel data files
#cp -r original/accel/ derived/
for file in accel/accel-*.txt
    do 
        sed -i '1d' "$file"
    done
#faster to use regex within sed - only runs sed once
sed -i '1d' derived/accel/accel-*.txt

#remove the rows that contains NA values (in known files, known locations)
sed -i '/NA\tNA\tNA/d' derived/accel/accel-{31268,34974}.txt 
#OR, more generally, to remove lines with all NAs (as we know these have 3 NA columns)
sed -i '/NA\tNA\tNA/d' ${DATADIR}/derived/accel/accel-*.txt

# check the files to make sure the lines have been removed correctly - rerun same command as above to find lines that don't have 8 columns
echo "Any lines still not with 8 columns are listed here:"
awk -F'\t' '(NF!=8){print $0}' ${DATADIR}/derived/accel/accel-*.txt | sort -u