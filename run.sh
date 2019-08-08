#!/bin/bash
#
# ===================================================================
# Purpose:           To download imgsrc images via an automated script
# Parameters:        one ; two ; three ; four ; five; six; seven
#                    ---------------------------
#                    -i = (file or string) URL, or file to a list of URLs
#                    -l = (bool) retain the download image link files list
#                    -s = (bool) only download the single image from the URL
#                    -n = (bool) don't run the download of the files
#                    -o = (bool) overwrite existing files
#                    -t = (bool) enable a TOR connection
#                    -d = (string) define a separate output directory (or file with a reference to a directory) for all the downloads
#                    ---------------------------
# Called From:       (script) any
# Author:            Gary Namestnik
# Notes:             Simply execute this script with a URL or a list of URLs and the script will scrape the URL
# Requires:          cURL, wget-internet command line utilities
#	                 grep, sed, awk-command line utilities
#		             phantom.js-on debian based machines use sudo apt install phantomsjs, on raspbian use https://github.com/piksel/phantomjs-raspberrypi
#                    tor and torsocks - https://www.linuxuprising.com/2018/10/how-to-install-and-use-tor-as-proxy-in.html
# Revsion:           Last change: 05/08/19 by GN :: Added input parameters
# ===================================================================
#

#make images folder
mkdir -p "./images"

#prepare variable defaults for input parameters
url=''
deleteList=true
singleFlag=false
download=true
overwriteFlag="-nc"
torFlag=false
output=''
while getopts 'i:lsnotd:' flag; do
  case "${flag}" in
    i) url="${OPTARG}"  ;;
    l) deleteList=false ;;
    s) singleFlag=true  ;;
    n) download=false   ;;
    o) overwriteFlag="" ;;
    t) torFlag=true     ;;
    d) output="${OPTARG}";;
    *) error "Unexpected option ${flag}" ;;
  esac
done


#check if input is a file (i.e. a list) or a single url
if [ -e "$url" ]
then
    urlList=$(cat $url | tr ' ' '\n')
else
    urlList=$url
fi
urlCount=$(echo $urlList | tr ' ' '\n' | wc -l)
urlIdx=0

#download directory
if [ ! -z "$output" ]
then
    #check if it's a file
    if [ -f "$output" ]; then
        #if the file exists, then grab the first line
        wgetPrefix=$(head "$output" -n 1)
    else 
        #if file doesn't exist, then assumed a directory, and create (if not already created)
        mkdir -p "$output"    
        wgetPrefix=$output
    fi
else
    wgetPrefix="./images"
fi

# #single image flag
# if [ ! -z "$3" ] && [ "$3" == "true" ]
# then
#     singleFlag=true
# else
#     singleFlag=false
# fi

# #overwrite image flag
# if [ ! -z "$5" ] && [ "$5" == "true" ]
# then
#     overwriteFlag=""
# else
#     overwriteFlag="-nc"
# fi

#tor enabling flag
if [ $torFlag = true ]
then
    torFlagWgetCurl="torify"
    torFlagPhantomJS="--proxy=127.0.0.1:9050 --proxy-type=socks5"
else
    torFlagWgetCurl=""
    torFlagPhantomJS=""
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
        navPages+=$($torFlagWgetCurl curl -s $initUrl | grep -o -E "<a class='navi' [^>]+>" | grep -o -E "href='[^\"]+'" | grep -Eo "/[^']+" | awk '{print "'$baseUrl'"$1}') 
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
            imgPages+=$($torFlagWgetCurl curl -s $navPage | grep -o -E "<td class='pret'><a [^>]+>" | grep -o -E "href='[^\"]+'" | grep -Eo "/[^']+" | awk '{print "'$baseUrl'"$1}')" "
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
        imgHtml=$(./phantomjs $torFlagPhantomJS save_page.js $imgPage)
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
    if [ $download = true ]
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
        $torFlagWgetCurl wget -i "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt" -q --show-progress -P "$wgetPrefix/$userFolder/$galleryFolder" $overwriteFlag
    else
        echo "Skipping downloading"
    fi

    #delete the list file if it is not required
    if [ $deleteList = true ] && [ -e "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt" ]
    then
        rm "$wgetPrefix/$userFolder/$galleryFolder/export-image-urls.txt"
    fi
done
echo "Finished"