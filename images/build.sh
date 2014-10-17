#!/bin/bash

CONTAINERS=( sandbox cache data nginx )
for CONTAINER in ${CONTAINERS[@]}; do
	cd $CONTAINER
	if [ -x setup.sh ]; then
		./setup.sh
	fi
	sudo /usr/bin/docker build --tag=mishak/nette-$CONTAINER .
	cd ..
done
