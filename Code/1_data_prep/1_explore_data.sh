#!/bin/bash

#code to explore the files for the formative

DATADIR='../../Data/'

cd ${DATADIR}/original

## 1. ACCEL FILES
#number of participants = counting the number of files in accel 
find accel -type f | wc -l #7455 files #or ls accel | wc -l
find accel -type f | { head; tail; } #to see file names format

#looking at format of first and last accel file
less -S accel/accel-31128.txt
less -S accel/accel-41474.txt
#both files seem to be tab-separated 
#wiith the first two rows being file ID and column headers, and the rest of the rows being data

#first let's use cat -T to check that the files are tab-separated
cat -T accel/accel-31128.txt | head -n 5 #yes
cat -T accel/accel-41474.txt | head -n 5 #yes

#to see the last 20 rows of the first and last accel file
#along with the header in 2nd row (so see what they refer to)
{ sed -n '2p' accel/accel-31128.txt; tail -n20 accel/accel-31128.txt; } | column -t | less -S
{ sed -n '2p' accel/accel-41474.txt; tail -n20 accel/accel-41474.txt; } | column -t | less -S

#printing column headers (second row) of first accel file and last accel file
sed -n '2p' accel/accel-31128.txt 
#"PAXSTAT"       "PAXCAL"        "PAXDAY"        "PAXN"  "PAXHOUR"       "PAXMINUT"      "PAXINTEN" "PAXSTEP"
sed -n '2p' accel/accel-41474.txt
#"PAXSTAT"       "PAXCAL"        "PAXDAY"        "PAXN"  "PAXHOUR"       "PAXMINUT"      "PAXINTEN" "PAXSTEP"

#checking that the second line of all accel files is the expected header
header=$'"PAXSTAT"\t"PAXCAL"\t"PAXDAY"\t"PAXN"\t"PAXHOUR"\t"PAXMINUT"\t"PAXINTEN"\t"PAXSTEP"'
echo "Number of files with the correct header:"
#SLOW - time = 1 minute
sed -ns "2p" accel/accel*.txt | grep -Fxc "$header" #-n suppresses printing and -s gets sed to treat each file separately and reset line numbers
#-x in grep forces a whole line match and -c prints number of matching lines rather than lines themselves

#if the header were on the first line (as for the derived data)
#head -qn1 accel/accel*.txt | grep -Fxc "$header" #-q to suppress the file names as head is being used on multiple files

#OR FASTER - time = 19s
for file in accel/*.txt
do
    awk -v header="$header" '
        NR == 2 {
            if ($0 == header) print FILENAME
            exit
        }
    ' "$file"
done | wc -l
#awk -v header="$header" : -v allows you to pass variables into awk from outside awk

#OR EVEN FASTER - time = 9s (only usese awk once)
awk -v header="$header" '
    FNR == 2 {
        if ($0 == header)
            count++
        nextfile
    }
    END {
        print count+0
    }
' accel/*.txt

#checking the number of columns in the first and last accel files
#note we only count the number of columns in the second row, corresponding to the column headers
#and we assume all rows have the same number of columns
awk -F'\t' 'NR == 2{print NF; exit}' accel/accel-31128 #8
awk -F'\t' 'NR == 2{print NF; exit}' accel/accel-41474 #8  

# checking the number of rows in the first and last accel files 
wc -l accel/accel-31128.txt #10082
wc -l accel/accel-41474.txt #10082 
#first two rows are file ID and column headers, so 10080 rows of data in each file
#PAXDAY contains the day 1-7, PAXHOUR contains the hour 0-23 and PAXMINUT contains the minutes 0-59
#this then totals 10080 inputs for each participant 
#Note that PAXN is the number of the input, so it goes from 1-10080 for each participant

#checking that all files in accel contain 10082 rows

#checking that all files in accel contain 8 columns (in the header row) and 10082 rows
cols_and_rows=$(for file in accel/*.txt
do
    awk 'NR == 2 {columns = NF} END {print columns, NR}' "$file"
done | sort | uniq -c)
#7324 files have 10082 rows and 8 columns
#the remaining files have a variable number between 2253 and 10097

#OR
awk '
    BEGINFILE {columns = 0} 
    FNR ==2 {columns = NF} 
    ENDFILE {print columns, FNR}
    ' accel/accel-*.txt

#finding the list of files that do not have 10082 rows (entries)
abnormal_entries=$(
for file in accel/*.txt
do
    rows=$(wc -l < "$file")
    if [ "$rows" -ne 10082 ]
    then
        echo "$file has $rows rows"
    fi
done
)
#save list of files with abnormal number of entries
echo "$abnormal_entries" > ../../Results/abnormal_entries.txt

#OR
awk 'ENDFILE {if (FNR != 10082) print FILENAME, "has", FNR, "rows"}' accel/accel-*.txt

#OR
wc -l accel/*.txt |
awk '$1 != 10082 && $2 != "total" {print $2, "has", $1, "rows"}' 

#checking that each accel file starts with the same ID line
#first checking my regex expression
grep -n "<ACTIGRAPH ID=.*>" accel/accel-31128.txt
#now checking in all files, that the first line contains the ID line
for file in accel/*.txt
do
    awk 'NR==1 && $0 ~ "<ACTIGRAPH ID=.*>" {print FILENAME}' "$file"
done | wc -l
#7455
#the above code took 2 minutes to run because it searched through every row of every file

#this code below stops as soon as the first row is searched using "exit"
#and putting the second requirement into the action as an if statement 
#if I put exit after the above code,
#e.g., awk 'NR==1 && $0 ~ "<ACTIGRAPH ID=.*>" {print FILENAME; exit}' "$file"
#it would only stop at the first row if it did contain the ID line and otherwise search the whole file
for file in accel/*.txt
do
    awk 'NR == 1 {
        if ($0 ~ "<ACTIGRAPH ID=.*>") print FILENAME
        exit
    }' "$file"
done | wc -l
# 7455
#took 20 seconds to run instead of 2 minutes

#OR
echo "Number of files with the ID line:"
head -qn1 accel/accel*.txt | grep -Exc "<ACTIGRAPH ID=.*>" 

#checking that there are the right number of columns on each row of each file
#this code also gives you the number of rows for each file 
file_checks=$(
for file in accel/*.txt
do
    awk '
        NR == 2 {columns = NF}
        NR > 2 {
            rows++
            if (NF != columns) inconsistent++
        }
        END {
            print FILENAME, columns, rows, inconsistent + 0, (inconsistent ? "CHECK" : "OK")
        }
    ' "$file"
done
)
echo "$file_checks" | head
#creating a tsv of the variable file_checks
{
    echo -e "filename\tcolumns\trows\tinconsistencies\status"
    echo "$file_checks" | tr ' ' '\t'
} > ../../Results/file_checks.txt

#OR I could have created a tsv directly using awk and setting the 
#output to tab separated values with -v OFS='\t'
{
echo -e "filename\tcolumns\trows\tinconsistencies\tstatus" 

for file in accel/*.txt
do
    awk -F '\t' -v OFS='\t' '
        NR == 2 {columns = NF}
        NR > 2 {
            rows++
            if (NF != columns) inconsistent++
        }
        END {
            print FILENAME, columns, rows, inconsistent + 0, (inconsistent ? "CHECK" : "OK")
        }
    ' "$file"
done
} > ../../Results/file_checks_2.tsv

#first, check all files have 8 columns (2nd row of file_checks = 8)
cut -f2 ../../Results/file_checks.tsv | sort -u | grep -v "columns" #8

#now, check all the files have 10080 rows of data (3rd row = 10080)
tail -n +2 ../../Results/file_checks.tsv | 
awk '$3!=10080 {count++} END {print count + 0}'
#131 - number of files that do not have 10080 entries

#then check if there are any inconsistencies where any of the rows
#in any of the files do not have 8 columns (4th row does not equal 0)
tail -n +2 ../../Results/file_checks.tsv | 
awk '$4!=0 {count++; print $1, $4} 
END {print "inconsistencies =", count + 0}'
#accel/accel-31268.txt 10 - 10 rows do not have 8 columns
#accel/accel-34974.txt 15 - 15 rows do not have 8 columns
#inconsistencies = 2

#let's have a look at these inconsistent files
#seeing as we know all files have 8 column headers now
#accel/accel-31268.txt 
awk -F '\t' '
    NR > 2 && NF != 8 {
    print "row number=", NR, "and number of columns=", NF}
' accel/accel-31268.txt
# row number= 10083 and number of columns= 3
# row number= 10084 and number of columns= 3
# row number= 10085 and number of columns= 3
# row number= 10086 and number of columns= 3
# row number= 10087 and number of columns= 3
# row number= 10088 and number of columns= 3
# row number= 10089 and number of columns= 3
# row number= 10090 and number of columns= 3
# row number= 10091 and number of columns= 3
# row number= 10092 and number of columns= 3
wc -l accel/accel-31268.txt #10092
#so we know that the last 10 values of accel-31268.txt have 3 columns
tail -n15 accel/accel-31268.txt | column -t
#looking at the end of the data, we can see that these are all NA values


#accel/accel-34974.txt 
awk -F '\t' '
    NR > 2 && NF != 8 {
    print "Row number=", NR, "and number of columns=", NF}
' accel/accel-34974.txt
# row number= 10083 and number of columns= 3
# row number= 10084 and number of columns= 3
# row number= 10085 and number of columns= 3
# row number= 10086 and number of columns= 3
# row number= 10087 and number of columns= 3
# row number= 10088 and number of columns= 3
# row number= 10089 and number of columns= 3
# row number= 10090 and number of columns= 3
# row number= 10091 and number of columns= 3
# row number= 10092 and number of columns= 3
# row number= 10093 and number of columns= 3
# row number= 10094 and number of columns= 3
# row number= 10095 and number of columns= 3
# row number= 10096 and number of columns= 3
# row number= 10097 and number of columns= 3
wc -l accel/accel-34974.txt #10097
#so we know that the last 15 entries of accel-34974.txt have 3 columns
tail -n20 accel/accel-31268.txt | column -t
#looking at the end of the data, we can see that these are all NA values

#find all possible total number of rows
cut -f3 ../../Results/file_checks.tsv | sort -unr | grep -v "rows" 
#can see that only two files had more than 10080 data rows - the two files with NA values
#minimum number of rows = 2251 and max number of rows = 10095

#finally, return a list of all files that do not contain 10080 data entries 
tail -n +2 ../../Results/file_checks.tsv | 
awk '$3!=10080 {count++
    print "File name is", $1, "and number of rows =", $3} 
END {print "Total number of files with unexpected row counts=", count + 0}'
#prints 131 as before and a list of all files and their numbers of data rows
#this should match the "abnormal_entries.txt" file that we have already created before


#check if there are any NA entries across rows
for file in accel/*.txt
    do grep "NA" "$file"
done | wc -l
#87 - there are 87 rows containing an NA value across all 7455 files

#use -o to return all instances of NA across all the files
for file in accel/*.txt
    do grep -o "NA" "$file"
done | wc -l
#137 - there are 137 distinct NA values across all 7455 files

#checking which files and which rows contain NA values
for file in accel/*.txt
do
    awk -F '\t' '
            NR > 2 {
                count = 0

                for (i = 1; i <= NF; i++) {
                    if ($i == "NA") count++
                }

                if (count > 0)
                    if (count == NF)
                        print FILENAME, "row =", NR, "NA values =", count, "- WHOLE ROW OF NAs"
                    else
                        print FILENAME, "row =", NR, "NA values =", count
            }
    ' "$file"
done
#no row contains 8 NA values 
# 25 rows in 2 files contain 3 NA values which is the whole row - as we found above 
#also there are only 137 NA values so no column is completely NA across 
#the files as we we know every file has at least 2251 data rows
#checking if there are any empty entries across all files
for file in accel/*.txt
do
    awk -F '\t' 'NR > 2 {
        for (i = 1; i <= NF; i++)
            if ($i ~ /^[[:space:]]*$/) print "empty"
    }' "$file"
done | wc -l
#returns 0 - no empty entries 






## 2.BMX_D.csv FILE
cat BMX_D.csv | head -n 20
#file is comma-separated, with the first row being column headers and the rest of the rows being data

column -t -s',' BMX_D.csv | less -S
#file has row names also, corresponding to ID number from 1 onwards 

#number of participants 
tail -n +2 BMX_D.csv | wc -l #9950 rows excluding the header row

#number of columns 
awk -F',' 'NR==1{print NF; exit}' BMX_D.csv #28 column headers

#column headers
sed -n "1p" BMX_D.csv | column -t -s',' 

#first, let's convert this csv file to a tsv file 
tr ',' '\t' < BMX_D.csv > BMX_D.tsv

#check if there are any empty entries
awk -F '\t' 'NR > 1 {
        for (i = 1; i <= NF; i++)
            if ($i ~ /^[[:space:]]*$/) print "empty"
    }' BMX_D.tsv | wc -l
#0 - no empty entries

#check if there are any NA entries
awk -F '\t' 'NR > 1 {
        for (i = 1; i <= NF; i++)
            if ($i=="NA") print "NA"
    }' BMX_D.tsv | wc -l
#same check
grep -o "NA" BMX_D.tsv | wc -l
#both return 147548

#check if there are entire columns of NA values (starting at 2nd column as
#first column just contains ID number)
for column in {2..28}
do  
    count=$(cut -f "$column" BMX_D.tsv |
    grep -xc "NA")
    if [ "$count" -eq 9950 ] #9950 = nnumber of rows in dataset
    then 
        echo "Column $column contains $count NA values - IT IS A COLUMN FULL OF NAs"
    else
        echo "Column $column contains $count NA values"
    fi
done
#Column 9 contains purely NA values - BMIHEAD

#check if there are entire rows of NA values
for row in {2..9950}
do
    count=$(sed -n "${row}p" BMX_D.tsv |
    grep -o "NA" | wc -l)
    if [ "$count" -ge 27 ] #27 = number of data columns as first column is participant number from 1 to 9950, >= 27 to allow for NA in participant ID also 
    then 
        echo "Row $row contains $count NA values - IT IS A ROW FULL OF NAs"
    fi
done
#the above code took far too long to run as sed reopens and rereads the file every time it is called
#so for each 9950 iteration and then executes 2 further functions, it also has to read each line 1 by 1 
#retrieve row 9,000, for example, it must read through the preceding 8,999 rows.
#whereas awk works in one exection - opens the file once, reads each row once and checks its 28 fields

#the code below is faster
awk -F '\t' '
    NR > 1 {
        count = 0
        for (i = 1; i <= NF; i++)
            if ($i == "NA") count++

        if (NF == count) {
            print "Row", NR, "contains only NA values"
            NA_rows++}
    }        
    END {
        if (NA_rows==0)
            print "No entirely NA rows found."
        else 
            print "Total number of entirely NA rows:", NA_rows}
    ' BMX_D.tsv
#No entirely NA rows found.
#Note, you reset count to 0 for each row so that it does not accumulate across rows

#OR, you can get the same result without a for loop, using gsub 
#(gsub is an awk function that substitutes values for others AND counts their instances
#so we can use it in this instance like grep to count the number of NA values on each row, without
#having to cycle through each column)
awk -F '\t' '
    NR > 1 {
        count += gsub(/NA/, "NA", $0)
        if (NF == count) {
            print "Row", NR, "contains only NA values"
            NA_rows++}
    }        
    END {
        if (NA_rows==0)
            print "No entirely NA rows found."
        else 
            print "Total number of entirely NA rows:", NA_rows}
    ' BMX_D.tsv


#Note, if we had 9950 columns instead, we would have to use awk for finding all NA columns 
#here count is an array with counts for each column
awk -F '\t' '
NR > 1 {
    for (i = 2; i <= NF; i++)
        if ($i == "NA")
            count[i]++
}
END {
    for (i = 2; i <= 28; i++)
        if (count[i] == 9950)
            print "Column", i, "contains", count[i]+0, "NA values - THIS COLUMN IS FULL OF NAs"
        else 
            print "Column", i, "contains", count[i]+0, "NA values"
}' BMX_D.tsv

