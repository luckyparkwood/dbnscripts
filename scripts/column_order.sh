#!/bin/bash

inFile=$1

echo "Current column order: "
sed -n 2,11p $inFile

echo "Input new column order 1-5 separated by a space (ex. 2 3 1): "
read -a order_array

col1="${order_array[0]}"
col2="${order_array[1]}"
col3="${order_array[2]}"
col4="${order_array[3]}"
col5="${order_array[4]}"

if [[ -z $col1 ]] ; then col1="5" ; fi
if [[ -z $col2 ]] ; then col2="5" ; fi
if [[ -z $col3 ]] ; then col3="5" ; fi
if [[ -z $col4 ]] ; then col4="5" ; fi
if [[ -z $col5 ]] ; then col5="5" ; fi

echo "New column order: $col1 $col2 $col3 $col4 $col5"

#echo "Variable col1 = $col1"
#echo "Variable col2 = $col2"
#echo "Variable col3 = $col3"
#echo "Variable col4 = $col4"
#echo "Variable col5 = $col5"

awk -F',' 'BEGIN{OFS=",";}{ print $("'$col1'"), $("'$col2'"), $("'$col3'"), $("'$col4'"), $("'$col5'") }' $inFile | sed 's/,,,,\|,,,\|,,//g' > col_$inFile && mv col_$inFile $inFile



