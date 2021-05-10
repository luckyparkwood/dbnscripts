#!/bin/bash
#script prints out letters to numbers as will be entered via a phone for troubleshooting


awk -F',' '{print $2}' $1 > temp.csv

cat temp.csv | sed s/[abcABC]/2/g | sed s/[defDEF]/3/g | sed s/[ghiGHI]/4/g | sed s/[jklJKL]/5/g | sed s/[mnoMNO]/6/g | sed s/[pqrsPQRS]/7/g | sed s/[tuvTUV]/8/g | sed s/[wxyzWXYZ]/9/g > temp2.csv

paste temp.csv temp2.csv > $1_digitmap.csv
cat $1_digitmap.csv

rm temp.csv temp2.csv


