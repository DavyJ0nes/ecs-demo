all: run

# This Makefile contains some convenience commands for deploying and publishing.

# For example, to build and run the docker container locally, just run:
# $ make

# or to publish the :latest version to the specified registry as :1.0.0, run:
# $ make publish version=1.0.0

app = davyj-ao-training-frontend
version ?= latest
local_port = 8082

binary:
	$(call blue, "# Building Golang Binary...")
	docker run --rm -it -v "${GOPATH}":/gopath -v "$(CURDIR)":/app -e "GOPATH=/gopath" -w /app golang:1.7 sh -c 'CGO_ENABLED=0 go build -a --installsuffix cgo --ldflags="-s" -o ${app}'

image: binary
	$(call blue, "# Building Docker Image...")
	docker build -t ${app}:${version} .
	$(MAKE) clean

run: image
	$(call blue, "# Running Docker Image Locally...")
	docker run -i -t --rm -p ${local_port}:8080 ${app}:${version} 

publish: image
	$(call blue, "# Publishing Docker Image to Registry...")
	$(shell aws ecr get-login --no-include-email --region eu-west-1)
	docker tag ${app}:latest "${ECR_REPO}":${version}
	docker push "${ECR_REPO}":${version} 

test:
	$(call blue, "# Testing Golang Code...")
	docker run --rm -it -v "${GOPATH}":/gopath -v "$(CURDIR)":/app -e "GOPATH=/gopath" -w /app golang:1.7 sh -c 'go test -v'

clean: 
		@rm -f ${app}

define blue
	@tput setaf 4
	@echo $1
	@tput sgr0
endef
