# IMGSRC-Downloader
### *A script by Gary Namestnik*

This script allows the scraping and downloading of images from websites.

## Installation
Simply running
```bash
$ git clone https://github.com/gazzenger/imgsrc-downloader
```
And then run the makefile (depending on which system you are running)
#### Raspberry Pi
```bash
$ make rasbian
```
#### Linux x64
```bash
$ make linux-x64
```
#### Empty phantomjs file
To emtpy the phantomjs file, simply run
```bash
$ make clean
```


The script depends on the following libraries
* wget
* cURL
* grep, sed, awk
* phantoms.js


### Installing Phantoms.js
Depending on the different platforms, this will dictate the version of phantoms.js to use.

Most can be simply downloaded (already compiled) at the following link.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*[https://phantomjs.org/download.html](https://phantomjs.org/download.html)*

For the Raspberry Pi you will need the repository from

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*[https://github.com/piksel/phantomjs-raspberrypi](https://github.com/piksel/phantomjs-raspberrypi)*

On Ubuntu you can use 
```bash
$ sudo apt install phantomjs
```

## Contents

The following files
* phantomjs folder - contains a couple of the popular platforms for phantomjs
* run.sh - the main script for running
* save_page.js - the blank phantom.js script for simply outputting the rendered url

## Use

The script takes the form

```bash
$ ./run.sh URL A B C D PATH
```
Where
* URL is either a URL string or a path to a file with URL strings
* A is a boolean flag for retaining the download image links file after running (handy if planning on downloading the actual images later)
* B is a boolean flag for only downloading a single image (base on a single URL or list of URLs), and will not scrape the gallery
* C is a boolean flag to prevent downloading the actual images (however the image list file is still generated)
* D is a boolean flag to overwrite the existing images for the gallery (by default this is turned off), so rerunning the command without this will only add new images
* PATH is the path for where all the downloads will be placed (the default is ./images)

And example using a URL, not retaining any image lists, and only downloading a single image, and overwriting any is:
```bash
$ ./run.sh http://XXX/XXXX/XXXX.html false true false true ./test
```

An example using a file input and not actually downloading any images, but producing a list of links, and saving to the default location is:
```bash
$ ./run.sh ./list.txt true false true false
```

If you choose to only download the link files, then you can download the images later by using the wget command,
```bash
$ wget -i ./export-image-urls.txt
```

## Supported websites
Currently this only supports imgsrc