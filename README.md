# IMGSRC-Downloader
### *A script by Gary Namestnik*

This script allows the scraping and downloading of images from websites.

## Installation
Simply running
```bash
$ git clone https://github.com/gazzenger/imgsrc-downloader
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