#!/bin/bash

## get all the IDs from the accelerometer files and store as a list in a file
ls ../../Data/derived/accel | grep -Eo '[0-9]+' > ../Data/derived/accel/accel_IDs.txt

#OR, using bash parameter expansion
for file in ../../Data/derived/accel/*.txt
do
    id="${file##*-}"
    id="${id%.txt}"
    echo "$id"
done