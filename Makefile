SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec
COMMIT = $(shell git log --pretty=format:'%h' -n 1)
VERSION=$(shell git describe --tags)
USER = $(shell id -u)
GROUP = $(shell id -g)
PROJECT = "ecr-credential-provider"
GOBUILD_OPTS = -ldflags="-s -w -X ${PROJECT}/cmd.Version=${VERSION} -X ${PROJECT}/cmd.CommitHash=${COMMIT}"
GO_IMAGE = "golang:1.22-alpine"
GO_IMAGE_CI = "golangci/golangci-lint:v1.57.2"
DISTROLESS_IMAGE = "gcr.io/distroless/static:nonroot"
IMAGE_TAG_BASE ?= "ghcr.io/dntosas/${PROJECT}"

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: lint
lint: ## Run golangci-lint against code.
	golangci-lint run --enable revive,gofmt,exportloopref --exclude-use-default=false --modules-download-mode=vendor --build-tags integration

.PHONY: test
test: ## Run go tests against code.
	go test -v `go list ./...` -coverprofile cover.out

.PHONY: ci
ci: fmt vet lint test ## Run go fmt/vet/lint/tests against the code.

.PHONY: modsync
modsync: ## Run go mod tidy && vendor.
	go mod tidy && go mod vendor

##@ Build

.PHONY: build
build: ## Build ecr-credential-provider amd64 binary.
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -mod=vendor ${GOBUILD_OPTS} -o ${PROJECT}

.PHONY: build-arm64
build-arm64: ## Build ecr-credential-provider arm64 binary.
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -mod=vendor ${GOBUILD_OPTS} -o ${PROJECT}

.PHONY: run
run: ## Run the controller from your host against your current kconfig context.
	go run -mod=vendor ./main.go

checksums:
	sha256sum bin/${PROJECT} > bin/${PROJECT}.sha256