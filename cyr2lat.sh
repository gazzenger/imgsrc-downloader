#!/bin/bash
#taken from https://vladimir-ivanov.net/batch-rename-files-with-cyrillic-filenames-to-latin-ones-transliterate-file-names/
#and https://stackoverflow.com/a/54795466
#many thanks Vladimir Ivanov
#this script has been modified to convert Cyrillic to Latin for saving to files
declare -A dictionary=(
    ["Ч"]="Ch"
    ["Ш"]="Sh"
    ["Щ"]="Sht"
    ["Ю"]="Yu"
    ["Я"]="Ya"
    ["Ж"]="Zh" 
    ["А"]="A"
    ["Б"]="B"
    ["В"]="V"
    ["Г"]="G"
    ["Д"]="D"
    ["Е"]="E"
    ["З"]="Z"
    ["И"]="I"
    ["Й"]="Y"
    ["К"]="K"
    ["Л"]="L"
    ["М"]="M"
    ["Н"]="N"
    ["О"]="O"
    ["П"]="P"
    ["Р"]="R"
    ["С"]="S"
    ["Т"]="T"
    ["У"]="U"
    ["Ф"]="F"
    ["Х"]="H"
    ["Ц"]="C"
    ["Ъ"]="A"
    ["Ь"]="I"
)
 
for letter in "${!dictionary[@]}"; do
    lowercase_from=$(echo $letter | sed 's/[[:upper:]]*/\L&/')
    lowercase_to=$(echo ${dictionary[$letter]} | awk '{print tolower($0)}')
    dictionary[$lowercase_from]=$lowercase_to
done
 
function cyr2lat {
    string=$1
    for letter in "${!dictionary[@]}"; do
        string=${string//$letter/${dictionary[$letter]}}
    done
 
    echo $string;
}
# convert non-latin chars using my transliterate script OR uconv from the icu-devtools package
OUTPUT=$(cyr2lat "$1") 
echo $OUTPUT

