clean:
	rm -f ./phantomjs

clearimages:
	rm -rf ./images

raspbian:
	rm -f ./phantomjs
	ln -S ./phantomjs ./phantomjs-lib/raspbian/phantomjs
	#wget https://github.com/piksel/phantomjs-raspberrypi/blob/master/bin/phantomjs

linux-x64:
	rm -f ./phantomjs
	ln -S ./phantomjs ./phantomjs-lib/linux-x64/phantomjs 