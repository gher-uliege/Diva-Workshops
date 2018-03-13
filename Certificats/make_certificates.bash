#!/bin/bash

compiler="/usr/local/texlive/2017/bin/x86_64-linux/xelatex"
year="2018"
filename="workshop${year}_certificat.tex"

listfile="participantlist${year}.txt"
nparticipants=$(cat $listfile | wc -l)

rm *out
echo 'we have '${nparticipants}' participants'
i=0
while read -r line
do  
    ((++i))
    ii=$(printf "%03d" $i)
    name=$(echo $line |cut -d , -f 2)
    surname=$(echo $line |cut -d , -f 1)
    email=$(echo $line |cut -d , -f 3)
    institute=$(echo $line |cut -d , -f 4)
    country=$(echo $line |cut -d , -f 5)
    
    echo "name= ${name}, surname = ${surname}, institute = ${institute}"
    fileout=$(basename ${filename} .tex)'_'${ii}'.tex'

    echo "File out: ${fileout}"
    # Replace within the file
    cat ${filename} | sed -e "s/<name>/${name}/" -e  "s/<surname>/${surname}/" -e "s/<institute>/${institute}/" -e "s/<country>/${country}/" >> $fileout

    ${compiler} ${fileout} > './certif.log'
    rm ${fileout}
    mkdir -pv "./pdf${year}"
    mv $(basename ${filename} .tex)'_'${ii}'.pdf' "./pdf${year}"

done < ${listfile}

rm *.aux *.log *.out
pdftk pdf2018/workshop2018_*pdf cat  output "all${year}.pdf"
