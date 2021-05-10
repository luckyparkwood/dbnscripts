#!/bin/bash
#script takes 3 digit input and finds all possible letter combinations for the input
if [[ -z $1 ]] ; then
	read -p " Input number? " inputNum
else
        inputNum=$1
fi


array=(`echo $inputNum | grep -o .`)
#echo "array: "
#echo ${array[@]}

for ((i = 0; i < ${#array[@]}; ++i)); 
do
	if [[ ${array[$i]} = "2" ]] ; then array[$i]="a,b,c";
	elif [[ ${array[$i]} = "3" ]] ; then array[$i]="d,e,f";
	elif [[ ${array[$i]} = "4" ]] ; then array[$i]="g,h,i";
	elif [[ ${array[$i]} = "5" ]] ; then array[$i]="j,k,l";
	elif [[ ${array[$i]} = "6" ]] ; then array[$i]="m,n,o,p";
	elif [[ ${array[$i]} = "7" ]] ; then array[$i]="q,r,s";
	elif [[ ${array[$i]} = "8" ]] ; then array[$i]="t,u,v";
	elif [[ ${array[$i]} = "9" ]] ; then array[$i]="w,x,y,z";
	fi
	#echo "${array[$i]}"
done
#echo ${array[0]}
#echo ${array[1]}
#echo ${array[2]}

num1="${array[0]}"
num2="${array[1]}"
num3="${array[2]}"


eval "echo {$num1}{$num2}{$num3}" | sed 's/ /\n/g'

