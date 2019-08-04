#!/bin/bash

#requires phantom.js installed

#get initial URL
read -p "Please provide a link: "  initUrl
#determine the base URL
baseUrl=$(echo $initUrl | grep -P -o '^(.*?/){3}')
baseUrl=${baseUrl::-1}

#scour the initUrl to get links to all the navigation pages
navPages=$initUrl" "
navPages+=$(curl $initUrl | grep -o -E "<a class='navi' [^>]+>" | grep -o -E "href='[^\"]+'" | grep -Eo "/[^']+" | awk '{print "'$baseUrl'"$1}')

#get unique pages
navPages=$(echo "$navPages" | tr ' ' '\n' | sort -u)

#for each nav page, scope our URLs for each image page
imgPages=""
for navPage in $navPages
do
    imgPages+=$navPage" "
    imgPages+=$(curl $navPage | grep -o -E "<td class='pret'><a [^>]+>" | grep -o -E "href='[^\"]+'" | grep -Eo "/[^']+" | awk '{print "'$baseUrl'"$1}')" "
done

#perform the following action for each individual image page
imgLinks=""
fullSizeCheck="view full-sized"
for imgPage in $imgPages
do
    imgHtml=$(phantomjs save_page.js $imgPage)
    #check if the fullsize link exists
    if [[ $imgHtml == *$fullSizeCheck* ]]; 
    then
        imgLinks+=$(echo $imgHtml | grep -o -E "<a [^>]+><b>view full-sized</b>" | grep -o -E 'href="[^\"]+"' | grep -Eo "/[^\"]+" | awk '{print "https:"$1}')" "
    else
        imgLinks+=$(echo $imgHtml | grep -o -E "<img class=\"big\" src=[^>]+>" | grep -o -E 'src="[^\"]+"' | grep -Eo "/[^\"]+" | awk '{print "https:"$1}')" "
    fi
done

wget -i $imgLinks
