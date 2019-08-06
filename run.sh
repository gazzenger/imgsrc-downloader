#!/bin/bash
#
# ===================================================================
# Purpose:           To download imgsrc images via an automated script
# Parameters:        one ; two ; three ; four ; five; six
#                    ---------------------------
#                    $one = (file or string) URL, or file to a list of URLs
#                    $two = (bool) retain the download image link files list
#                    $three = (bool) only download the single image from the URL
#                    $four = (bool) don't run the download of the files
#                    $five = (bool) overwrite existing files
#                    $six = (string) define a separate output directory for all the downloads
#                    ---------------------------
# Called From:       (script) any
# Author:            Gary Namestnik
# Notes:             Simply execute this script with a URL or a list of URLs and the script will scrape the URL
# Requires:          cURL, wget-internet command line utilities
#	                 grep, sed, awk-command line utilities
#		             phantom.js-on debian based machines use sudo apt install phantomsjs, on raspbian use https://github.com/piksel/phantomjs-raspberrypi
# Revsion:           Last change: 05/08/19 by GN :: Added input parameters
# ===================================================================
#

#make images folder
mkdir -p "./images"

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
if [ ! -z "$6" ]
then
    #check if directory exists, if it doesn't then query to create it
    #if [ ! -d "$6" ]; then
    #    echo "Output directory doesn't exist, do you want to create it?"
    #    select yn in "Yes" "No"; do
    #        case $yn in
    #            Yes ) mkdir -p "$6"; break;;
    #            No ) exit;;
    #        esac
    #    done
    #fi
    mkdir -p "$6"
    wgetPrefix=$6
else
    wgetPrefix="./images"
fi

#single image flag
if [ ! -z "$3" ] && [ "$3" == "true" ]
then
    singleFlag=true
else
    singleFlag=false
fi

#overwrite image flag
if [ ! -z "$5" ] && [ "$5" == "true" ]
then
    overwriteFlag=""
else
    overwriteFlag="-nc"
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
        imgHtml=$(./phantomjs save_page.js $imgPage)
        #for the first html page, grab the other info about the account, and the album
        if [ $imgIdx == 1 ]
        then
            userFolder=$(echo $imgHtml | grep -o -E "<a [^>]+\">more photos from" | grep -o -E "user=[^\"]+" | grep -Eo "=[^']+" | cut -c 2-)
            userFolder=$(./cyr2lat.sh "$userFolder")
            galleryFolder=$(echo $imgHtml | grep -o -E "iMGSRC.RU</a> [^>]+</div>" | grep -o -E "> [^,]+" | cut -c 3-)
            galleryFolder=$(./cyr2lat.sh "$galleryFolder")
        fi

        #check if the fullsize link exists
        if [[ $imgHtml == *$fullSizeCheck* ]]; 
        then
            imgLinks+=$(echo $imgHtml | grep -o -E "<a [^>]+><b>view full-sized</b>" | grep -o -E 'href="[^\"]+"' | grep -Eo "/[^\"]+" | awk '{print "https:"$1}')" "
        else
            imgLinks+=$(echo $imgHtml | grep -o -E "<img class=\"big\" src=[^>]+>" | grep -o -E 'src="[^\"]+"' | grep -Eo "/[^\"]+" | awk '{print "https:"$1}')" "
        fi
    done

    #check on the user and gallery folder existing
    mkdir -p "$wgetPrefix/$userFolder/$galleryFolder"

    #save the image list to a temp file and start downloading pictures
    echo $imgLinks | tr ' ' '\n' > "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt"
    if [ -z "$4" ] || [ "$4" == "false" ]
    then
        #check for overwrite flag, and if so delete all the files
        if [ -z $overwriteFlag ]
        then
            for files in `cat "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt"`
            do
                if [ -e "$wgetPrefix/$userFolder/$galleryFolder/$(basename $files)" ]
                then
                    rm -f "$wgetPrefix/$userFolder/$galleryFolder/$(basename $files)"
                fi
            done
        fi
        echo "Downloading images ..."
        wget -i "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt" -q --show-progress -P "$wgetPrefix/$userFolder/$galleryFolder" $overwriteFlag
    else
        echo "Skipping downloading"
    fi

    #delete the list file if it is not required
    if ([ -z "$2" ] || [ "$2" == "false" ]) && [ -e "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt" ]
    then
        rm "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt"
    fi
done
echo "Finished"
