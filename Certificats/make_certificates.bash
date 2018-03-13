#!/bin/bash

compiler="/usr/local/texlive/2017/bin/x86_64-linux/xelatex"
year="2018"
filename="workshop${year}_certificat.tex"

listfile='participantlist2015.txt'
nparticipants=$(cat $listfile | wc -l)

echo 'we have '${nparticipants}' participants'

while read -r line
do
    fname=$(echo $line |cut -d : -f 1)
    surname=$(echo $line |cut -d : -f 3)
    name=$(echo $line |cut -d : -f 2)
    institute=$(echo $line |cut -d : -f 4)

    echo ' '
    echo $surname
    echo ' '
    echo name= $name', surname = '$surname', institute = '$institute
    fileout=$(basename ${filename} .tex)'_'${fname}'.tex'

    # Replace within the file
    cat ${filename} | sed -e "s/<name>/${name}/" -e  "s/<surname>/${surname}/"   -e "s/<institute>/${institute}/" >> $fileout

${compiler} ${fileout} > './certif.log'
rm ${fileout}
mkdir -pv "./pdf${year}"
mv $(basename ${filename} .tex)'_'${fname}'.pdf' "./pdf${year}"

done < ${listfile}

rm *aux *log
pdftk pdf2018/workshop2018_*pdf cat  output "all{year}.pdf"
