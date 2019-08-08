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
* phantoms.js (checkout the phantomjs website for more info, [https://phantomjs.org/api/webpage/property/settings.html](https://phantomjs.org/api/webpage/property/settings.html))


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

### Using Tor
To install and configure TOR, follow the guide below
https://www.linuxuprising.com/2018/10/how-to-install-and-use-tor-as-proxy-in.html
https://superuser.com/questions/404732/how-to-use-wget-with-tor-bundle-in-linux

```bash
$ sudo apt install apt-transport-https curl
$ sudo -i
$ echo "deb https://deb.torproject.org/torproject.org/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/tor.list
$ curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
$ gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
$ apt update
$ exit
$ sudo apt install tor tor-geoipdb torsocks deb.torproject.org-keyring
```

To use tor for wget and curl commands, simply use
```bash
$ torify curl ifconfig.me
$ torify wget -qO- -U curl ifconfig.me
```

The TOR parameter forces wget, curl and phantoms.js to use the torsocks 127.0.0.1:9050 SOCKS5 connection.
Note that sometimes the relay server won't work, and hence it may be required to get a new TOR route by restarting the service,
```bash
$ sudo service tor restart
```

## Contents

The following files
* phantomjs folder - contains a couple of the popular platforms for phantomjs
* run.sh - the main script for running
* save_page.js - the blank phantom.js script for simply outputting the rendered url
* makefile - for creating the correct symbolic link to the phantomjs-lib folder
* cyr2lat.sh - the cyrillic converter for converting cyrillic strings to latin

## Use

The script takes the form

```bash
$ ./run.sh -i URL -l -s -n -o -t -d OUTPUT
```
Where
* -i URL is either a URL string or a path to a file with URL strings
* -l is a boolean flag for retaining the download image links file after running (handy if planning on downloading the actual images later)
* -s is a boolean flag for only downloading a single image (base on a single URL or list of URLs), and will not scrape the gallery
* -n is a boolean flag to prevent downloading the actual images (however the image list file is still generated)
* -o is a boolean flag to overwrite the existing images for the gallery (by default this is turned off), so rerunning the command without this will only add new images
* -t is a boolean flag to use a TOR connection
* -d OUTPUT is the path for where all the downloads will be placed (the default is ./images) - OR a link to a text file with a link in it

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
** currently doesn't support logging in

## Special thanks to
* Vladimir Ivanov - who I've taken the Cyrillic converter script from [here](https://vladimir-ivanov.net/batch-rename-files-with-cyrillic-filenames-to-latin-ones-transliterate-file-names/)