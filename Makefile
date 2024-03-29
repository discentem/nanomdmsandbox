PATH := ${PATH}:/usr/bin:/usr/local/bin:/Library/Developer/CommandLineTools/usr/bin

CURRENT_DIR = $(shell pwd)
OS_VERSION = $(shell uname)

VERSION := $(shell git describe --tags --always)

TERRAFORM_DIR := $(shell pwd)/terraform
TERRAFORM_REMOTE_STATE_INIT_DIR := $(shell pwd)/terraform/remote_state

DOCKER_DIR := docker

BUILD_DIR := $(CURRENT_DIR)/build

CMD_DIR := $(CURRENT_DIR)/cmd

CONTAINERS_PREFIX = nanomdm
CONTAINERS_DIR = $(DOCKER_DIR)

# CONTAINERS = $(shell find $(CONTAINERS_DIR) -type d -name template -prune -o -mindepth 1 -maxdepth 1 -exec basename {} \;)
# CONTAINERS = $(shell find $(CONTAINERS_DIR) -type d -prune -maxdepth 1 -mindepth 1 -exec basename {} \;)
CONTAINERS = enroll_endpoint mdmdirector micro2nano nanomdm scep

.check-args:
ifndef AWS_REGION
	$(error AWS_REGION is not set. please use `make {XXX} AWS_REGION=<us-east-1,us-east-2, ...AWS_REGION>.`)
endif
ifndef AWS_ACCOUNT_ID
	$(error AWS_ACCOUNT_ID is not set. please use `make {XXX} AWS_ACCOUNT_ID=<1234567890 ...AWS_ACCOUNT_ID>.`)
endif
# ifndef AWS_PROFILE
# 	$(error AWS_PROFILE is not set. please use `make {XXX} AWS_PROFILE=<DEFAULT, ...YOUR_PROFILE_NAME>.`)
# endif

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------
.PHONY: help # Print this help
help:
	@echo "Available targets:"
	@echo
	@cat $(MAKEFILE_LIST) | grep '^\.PHONY:.*#.*$$' | sed 's/^\.PHONY:[[:space:]]*//g' | sed 's/[[:space:]]*#[[:space:]]*/ # /g' | column -t -c 70 -s '#' | sed 's/^\(.*\)/    \1/g'
	@echo

# ------------------------------------------------------------------------------
# Build and Push All Containers
# ------------------------------------------------------------------------------

# As of today, this does not include all the env variables we need.
# Use the docker compose target.

# .PHONY: build-containers # Build all containers and publish the containers to AWS ECR
# build-containers: .check-args
# 	$(info *** build and upload containers to AWS ECR)
# 	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
# 	@for container in $(CONTAINERS); do \
# 		echo "building $$container" ; \
# 		docker build -t $$container $(CONTAINERS_DIR)/$$container/. ; \
# 		docker tag $$container:latest $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(CONTAINERS_PREFIX)/$$container:latest ; \
# 		docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(CONTAINERS_PREFIX)/$$container:latest ; \
# 	done

# ------------------------------------------------------------------------------
# Build and Push All Platform Containers
# ------------------------------------------------------------------------------
.PHONY: build-containers-docker-compose # Build all containers and publish the containers to AWS ECR

build-containers-docker-compose: DOCKER_BUILDKIT=1
build-containers-docker-compose: COMPOSE_DOCKER_CLI_BUILD=1
build-containers-docker-compose: .check-args
	$(info *** building containers using docker-compose)
	docker-compose -f $(CURRENT_DIR)/docker-compose.yml build
	echo "$(CONTAINERS)"
# docker-compose -f ./$(APP_DIR)/docker-compose.yml build
	$(info *** build and upload containers to AWS ECR)
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	@for container in $(CONTAINERS); do \
		echo "building $$container" ; \
		docker tag $$container:latest $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$$container:latest ; \
		docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$$container:latest ; \
	done

.PHONY: docker-compose # Build all containers and publish the containers to AWS ECR
docker-compose: build-containers-docker-compose


# terraform tf-remote-state-init
#
#
.PHONY: tf-remote-state-init # Runs tf-init and tf-apply for the initial terraform remote state
tf-remote-state-init: .check-args
	terraform -chdir=$(TERRAFORM_REMOTE_STATE_INIT_DIR) init
	terraform -chdir=$(TERRAFORM_REMOTE_STATE_INIT_DIR) apply

# terraform deploy
#
#
.PHONY: tf-deploy # Runs tf-init and tf-apply
tf-deploy: tf-init tf-apply


# terraform apply
#
#
.PHONY: tf-apply # Runs tf-apply
tf-apply:
	terraform -chdir=$(TERRAFORM_DIR) apply

# terraform apply refresh
#
#
.PHONY: tf-apply-refresh # Runs tf-apply -refresh-only
tf-apply-refresh:
	terraform -chdir=$(TERRAFORM_DIR) apply -refresh-only

.PHONY: tf-init-migrate # Runs tf-init -migrate-state
tf-init-migrate:
	terraform -chdir=$(TERRAFORM_DIR) init -migrate-state


# terraform destroy
#
#
.PHONY: tf-destroy # Runs tf-destroy
tf-destroy: tf-init
	terraform -chdir=$(TERRAFORM_DIR) destroy

# terraform plan
#
#
.PHONY: tf-plan # Runs tf-plan
tf-plan: # Runs tf-plan
	terraform -chdir=$(TERRAFORM_DIR) plan

# terraform init
#
#
.PHONY: tf-init # Runs tf-init
tf-init: # Runs tf-init
	terraform -chdir=$(TERRAFORM_DIR) init


# tf-first-run
#
#

tf-create-route53-and-ecr: 
	terraform -chdir=$(TERRAFORM_DIR) init
	terraform -chdir=$(TERRAFORM_DIR) apply -target module.route53 -target module.nanomdm_ecr -target module.scep_ecr -target module.micro2nano_ecr -target module.mdmdirector_ecr -target module.enroll_endpoint_ecr

.PHONY: tf-first-run # Runs tf-first-run
tf-first-run: .check-args tf-create-route53-and-ecr build-containers-docker-compose # Runs tf-first-run


.check-args-ecs-update-service: .check-args
ifndef AWS_REGION
	$(error AWS_REGION is not set. please use `make {XXX} AWS_REGION=<us-east-1,us-east-2, ...AWS_REGION>.`)
endif
ifndef AWS_ACCOUNT_ID
	$(error AWS_ACCOUNT_ID is not set. please use `make {XXX} AWS_ACCOUNT_ID=<1234567890 ...AWS_ACCOUNT_ID>.`)
endif
ifndef CLUSTER
	$(error CLUSTER is not set. please use `make {XXX} CLUSTER=<production-nanomdm-cluster>.`)
endif
ifndef SERVICE
	$(error SERVICE is not set. please use `make {XXX} SERVICE=<nanomdm>.`)
endif

.PHONY: ecs-update-service # Force redeployment of ECS service
ecs-update-service: .check-args-ecs-update-service
	aws ecs update-service --cluster $(CLUSTER) --service $(SERVICE) --desired-count 1 --force-new-deployment --enable-execute-command



# golang - deps
#
#
.PHONY: deps # go mod download and go mod tidy
deps:
	@go mod download
	@go mod tidy

# golang - cli
#
#
.PHONY: cli # go build
cli: deps # go build
	cd $(CMD_DIR)/cli; go build -o $(BUILD_DIR)/cli

.PHONY: gen_enrollment # ./build/cli create_enrollment
gen_enrollment: cli
	./build/cli create_enrollment

.PHONY: .check-args
