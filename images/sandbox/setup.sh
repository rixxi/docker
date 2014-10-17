#!/bin/bash
if [ -d sandbox ]; then
	cd sandbox
	git pull
	cd ..
else
	git clone https://github.com/nette/sandbox.git
fi

cd sandbox && composer install --prefer-dist --no-dev --optimize-autoloader && cd ..

if [ -d build ]; then
	rm -rf build
fi

ln -s sandbox build
