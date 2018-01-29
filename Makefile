 # Makefile to build dnsmasq blacklist
 SHELL=/usr/bin/env bash

 # Go parameters
	GOBUILD=$(GOCMD) build
	GOCLEAN=$(GOCMD) clean
	GOCMD=go
	GOGEN=$(GOCMD) generate
	GOGET=$(GOCMD) get
	GOTEST=$(GOCMD) test

# Executables
	GSED=$(shell which gsed || which sed) -i.bak -e

# Environment variables
	COPYRIGHT=s/Copyright © 20../Copyright © $(shell date +"%Y")/g
	COVERALLS_TOKEN=W6VHc8ZFpwbfTzT3xoluEWbKkrsKT1w25
	DATE=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
	GIT=$(shell git rev-parse --short HEAD)
	OLDVER=$(shell cat ./OLDVERSION)
	VER=$(shell cat ./VERSION)
	TAG="v$(VER)"


.PHONY: cdeps 
cdeps: 
	dep status -dot | dot -T png | open -f -a /Applications/Preview.app

.PHONY: clean
clean:
	$(GOCLEAN)
	find . -name debug -type f \
	-o -name "*.deb" -type f \
	-o -name debug.test -type f \
	-o -name "*.tgz" -type f \
	| xargs rm 

.PHONY: coverage 
coverage: 
	./testcoverage

.PHONY: dep-stat 
dep-stat: 
	dep status

.PHONY: deps
deps: 
	dep ensure -update

.PHONY: tags
tags:
	git push origin --tags

.PHONY: version
version:
	cmp -s VERSION OLDVERSION || cp VERSION OLDVERSION

.PHONY: release
release: commit push
	@echo Released $(TAG)

.PHONY: commit
commit:
	@echo Committing release $(TAG)
	git commit -am"Release $(TAG)"
	git tag $(TAG)

.PHONY: push
push:
	@echo Pushing release $(TAG) to master
	git push --tags -v
	git push
