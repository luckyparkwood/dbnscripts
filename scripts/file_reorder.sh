#!/bin/bash

inFile="$1"
inFilePath="$(pwd "$inFile")"

cd $inFilePath

cat $inFile | grep -n '' | sed -E 's/:[0-9]+//g' >> reorder_$inFile

echo "Accounts re-ordered, saved as 'reorder_$inFile'"
