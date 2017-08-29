all: run

# This Makefile contains some convenience commands for deploying and publishing.

# For example, to build and run the docker container locally, just run:
# $ make

# or to publish the :latest version to the specified registry as :1.0.0, run:
# $ make publish version=1.0.0

app = bill
name = ecs-demo/${app}
registry = name_of_registry
version ?= latest
local_port = 8082

binary:
	$(call blue, "# Building Static Linux Binary...")
	docker run --rm -it -v "${GOPATH}":/gopath -v "$(CURDIR)":/app -e "GOPATH=/gopath" -w /app golang:1.7 sh -c 'CGO_ENABLED=0 go build -a --installsuffix cgo --ldflags="-s" -o ${app}'

image: binary
	$(call blue, "# Building Docker Image...")
	docker build -t ${name}:${version} .
	$(MAKE) clean

run: image
	$(call blue, "# Running Docker Image Locally...")
	docker run -i -t --rm -p ${local_port}:8080 ${name}:${version} 

publish:  
	$(call blue, "# Publishing Docker Image to Registry...")
	docker tag ${name}:latest ${registry}/${name}:${version}
	docker push ${registry}/${name}:${version} 

clean: 
	@rm -f ${app} 

define blue
	@tput setaf 4
	@echo $1
	@tput sgr0
endef
