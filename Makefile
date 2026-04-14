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

.PHONY: start start-watch watch
