#!/usr/bin/env bash

HUGO ?= hugo

default: start

watch: #sudo apt-get install inotify-tools
	inotifywait -qrm --event modify --format '%w%f' $(PWD) | grep '\*.*' | hugo --watch=false

start:
	$(HUGO) server --watch=true

start-watch:
	$(HUGO) server --watch=true

build:
	rm -rf public && $(HUGO)

deploy-setup:
	./deploy.sh setup

deploy:
	./deploy.sh

.PHONY: start start-watch watch build deploy deploy-setup
