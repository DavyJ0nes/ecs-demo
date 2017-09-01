# ECS DEMO Makefile
# Davy Jones 2017

all: validate

# This Makefile contains some convenience commands for interacting with terraform

# For example, to validate the terraform files within the dev stack you can use
# $ make plan env=dev

# The default action will validate the stacks terraform files
# $ make

env ?= dev

edit:
	$(call yellow, "# editing ${env} tf file...")
	cd $(CURDIR)/terraform/env/${env} && vi ${env}.tf && cd ${curr_dir}

init:
	$(call yellow, "# initialising ${env}...")
	cd $(CURDIR)/terraform/env/${env} && terraform init && cd ${curr_dir}

validate:
	$(call yellow, "# validating ${env} terraform files...")
	cd $(CURDIR)/terraform/env/${env} && terraform get && terraform validate -var-file=${env}.tfvars && cd $(CURDIR)

plan: validate
	$(call yellow, "# Building plan for ${env}...")
	cd $(CURDIR)/terraform/env/${env} && terraform plan -var-file=${env}.tfvars && cd $(CURDIR)

apply: plan
	$(call yellow, "# Applying plan for ${env}...")
	cd $(CURDIR)/terraform/env/${env}/lambda_functions && zip canary.zip canary.py
	cd $(CURDIR)/terraform/env/${env} && terraform apply -var-file=${env}.tfvars && cd $(CURDIR)

test:
	$(call yellow, "# Testing ${env} Environment...")
	cd $(CURDIR)/terraform && bundle install >> /dev/null && bundle exec rake spec SPEC=spec/${env}_spec.rb && cd $(CURDIR)

define yellow
	@tput setaf 3
	@echo $1
	@tput sgr0
endef
