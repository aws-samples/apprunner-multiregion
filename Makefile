PACKAGES := $(shell go list ./...)

all: help

.PHONY: help
help: Makefile
	@echo
	@echo " Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## init: Provision infrastructure
.PHONY: init
init:
	./scripts/init.sh

## deploy: Build code into a container and deploy it to AppRunner
.PHONY: deploy
deploy:
	./scripts/deploy.sh

## destroy: Tears down infrastructure
.PHONY: destroy
destroy:
	./scripts/destroy.sh

## vet: vet code
.PHONY: vet
vet:
	go vet $(PACKAGES)

## test: run unit tests
.PHONY: test
test:
	go test -race -cover $(PACKAGES)

## devfrontend: iterate on frontend next.js app
.PHONY: devfrontend
devfrontend:
	cd nextjs && npm run dev

## frontend: build frontend next.js app
.PHONY: frontend
frontend:
	cd nextjs && npm run export

## build: build a binary (backend is dependent upon frontend)
.PHONY: build
build: test frontend
	go build -o ./app -v

## start: build and run local project
.PHONY: start
start: build
	clear
	@echo ""
	DYNAMO_TABLE=apprunner-multiregion ./app

## devbackend: compile and run go backend
.PHONY: devbackend
devbackend: test
	go build -o ./app -v
	clear
	@echo ""
	DYNAMO_TABLE=apprunner-multiregion ./app
