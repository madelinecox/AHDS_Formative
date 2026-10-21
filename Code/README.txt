SUMMARY OF THE ORIGINAL DATA

BMX_D is a CSV file containing comma-separated values of the body measures documentation
It contains 9951, rows, the first of which corresponds to column headers and the following
9950 rows each correspond to a single participant. 
There are 28 columns, the first just contains participant number from 1 to 9950.
The second column containing the participant ID.
The remaining 27 have the headers "SEQN"  "BMDSTATS"  "BMXWT"  "BMIWT"  "BMXRECUM"  "BMIRECUM"  "BMXHEAD"  "BMIHEAD"  "BMXHT"  "BMIHT"  "BMXBMI"  "BMXLEG"  "BMILEG"  "BMXCALF"  "BMICALF"  "BMXARML"  "BMIARML"  "BMXARMC"  "BMIARMC"  "BMXWAIST"  "BMIWAIST"  "BMXTHICR"  "BMITHICR"  "BMXTRI"  "BMITRI"  "BMXSUB"  "BMISUB".
There are no empty entries in the dataset but there are 147549 NA values.
There are no rows containing NA values only (so no data-less participants).
But column 9 titled "BMIHEAD" contains only NA values.

The accel directory contains the physical activity monitor documentation
It contains 7455 files, named "accel-xxxxx.txt" each of which is a .txt file containing tab-separated values
and each of which contains data corresponding to a single participant.
Each file has the following format:
First row: a header line with partcipant ID
Second row: the column names
8 columns titled: "PAXSTAT"       "PAXCAL"        "PAXDAY"        "PAXN"  "PAXHOUR"       "PAXMINUT"      "PAXINTEN" "PAXSTEP"
The majority of the files (7324) have 10082 rows and 8 columns 
Hence, 10080 rows of data, one row for each minute of each hour of each day over a 7 day period: 60x24x7 = 10080
The remaining files have 8 columns but varying numbers of rows between 2253 and 10097
A list of the 131 abnormal files and their number of rows can be found in "abnormal_entries.txt"
A list of every file, its column and rows numbers, and whether or not there are any inconsistencies 
between the numbers of rows and columns can be found in "file_checks.txt"
Files "accel-31268.txt" and "accel-34974.txt" were found to contain inconsistencies.
Looking at these in more detail, we can see that the last 10 and 15 rows, respectively contain only 3 columns with NA values
Across all 7455 files, there are 137 distinct NA values
There are no rows or columns in any of the files consisting entirely of NA values
There were no empty entries in the dataset

Data processing:
The BMX_D file was converted to tab-separated for consistency.
