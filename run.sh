#!/bin/bash
#
# ===================================================================
# Purpose:           To download imgsrc images via an automated script
# Parameters:        one ; two ; three ; four ; five
#                    ---------------------------
#                    $one = (file or string) URL, or file to a list of URLs
#                    $two = (bool) retain the download image link files list
#                    $three = (bool) only download the single image from the URL
#                    $four = (string) define a separate output directory for all the downloads
#                    $five = (bool) don't download the files
#                    ---------------------------
# Called From:       (script) any
# Author:            Gary Namestnik
# Notes:             Simply execute this script with a URL or a list of URLs and the script will scrape the URL
# Requires:          cURL, wget, grep, sed, awk, phantom.js (install sudo apt install phantomjs)
# Revsion:           Last change: 05/08/19 by GN :: Added input parameters
# ===================================================================
#

#check if input is a file (i.e. a list) or a single url
if [ -e "$1" ]
then
    urlList=$(cat $1 | tr ' ' '\n')
else
    urlList=$1
fi

urlCount=$(echo $urlList | tr ' ' '\n' | wc -l)
urlIdx=0

#download directory
if [ ! -z "$4" ] && [ -e "$4" ]
then
    wgetPrefix=$4
else
    wgetPrefix="./"
fi

#single image flag
if [ ! -z "$3" ] && [ "$3" == "true" ]
then
    singleFlag=true
else
    singleFlag=false
fi

#loop through each link in list
for initUrl in $urlList
do
    urlIdx=$[$urlIdx+1]
    echo "URL $urlIdx of $urlCount"
    #determine the base URL
    baseUrl=$(echo $initUrl | grep -P -o '^(.*?/){3}')
    baseUrl=${baseUrl::-1}

    #scour the initUrl to get links to all the navigation pages
    navPages=$initUrl" "
    if [ $singleFlag = false ]
    then
        navPages+=$(curl -s $initUrl | grep -o -E "<a class='navi' [^>]+>" | grep -o -E "href='[^\"]+'" | grep -Eo "/[^']+" | awk '{print "'$baseUrl'"$1}') 
    fi

    #get unique pages
    navPages=$(echo "$navPages" | tr ' ' '\n' | sort -u)

    #for each nav page, scope our URLs for each image page
    echo "Scraping image pages ..."
    imgPages=""
    for navPage in $navPages
    do
        imgPages+=$navPage" "
        if [ $singleFlag = false ]
        then 
            imgPages+=$(curl -s $navPage | grep -o -E "<td class='pret'><a [^>]+>" | grep -o -E "href='[^\"]+'" | grep -Eo "/[^']+" | awk '{print "'$baseUrl'"$1}')" "
        fi
    done

    #perform the following action for each individual image page
    echo "Getting image links, this can take a while ..."
    imgCount=$(echo $imgPages | tr ' ' '\n' | wc -l)
    imgIdx=0
    imgLinks=""
    fullSizeCheck="view full-sized"
    for imgPage in $imgPages
    do
        imgIdx=$[$imgIdx+1]
        echo "Image $imgIdx of $imgCount"
        imgHtml=$(phantomjs save_page.js $imgPage)
        #check if the fullsize link exists
        if [[ $imgHtml == *$fullSizeCheck* ]]; 
        then
            imgLinks+=$(echo $imgHtml | grep -o -E "<a [^>]+><b>view full-sized</b>" | grep -o -E 'href="[^\"]+"' | grep -Eo "/[^\"]+" | awk '{print "https:"$1}')" "
        else
            imgLinks+=$(echo $imgHtml | grep -o -E "<img class=\"big\" src=[^>]+>" | grep -o -E 'src="[^\"]+"' | grep -Eo "/[^\"]+" | awk '{print "https:"$1}')" "
        fi
    done

    #save the image list to a temp file and start downloading pictures
    echo $imgLinks | tr ' ' '\n' > "./export-image-urls$urlIdx.txt"
    if [ -z "$5" ] || [ "$5" == "false" ]
    then
        echo "Downloading images ..."
        wget -i "./export-image-urls$urlIdx.txt" -q --show-progress -P $wgetPrefix
    fi

    #delete the list file if it is not required
    if ([ -z "$2" ] || [ "$2" == "false" ]) && [ -e "./export-image-urls$urlIdx.txt" ]
    then
        rm "./export-image-urls$urlIdx.txt"
    fi
done
echo "Finished"
