PATH := ${PATH}:/usr/bin:/usr/local/bin:/Library/Developer/CommandLineTools/usr/bin

CURRENT_DIR = $(shell pwd)
OS_VERSION = $(shell uname)

VERSION := $(shell git describe --tags --always)

TERRAFORM_DIR := $(shell pwd)/terraform

APP_DIR := app

CONTAINERS_PREFIX = nanomdm
CONTAINERS_DIR = $(APP_DIR)/images

CONTAINERS = $(shell find $(CONTAINERS_DIR) -type d -name template -prune -o -mindepth 1 -maxdepth 1 -exec basename {} \;)

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
	docker-compose -f ./$(APP_DIR)/docker-compose.yml build
	$(info *** build and upload containers to AWS ECR)
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	@for container in $(CONTAINERS); do \
		echo "building $$container" ; \
		docker tag $$container:latest $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$$container:latest ; \
		docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$$container:latest ; \
	done

docker-compose: build-containers-docker-compose

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
	terraform -chdir=$(TERRAFORM_DIR) apply -target module.route53 -target module.nanomdm_ecr -target module.scep_ecr

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
	$(error SERVICE is not set. please use `make {XXX} SERVICE=<production>.`)
endif

.PHONY: ecs-update-service # Force redeployment of ECS service
ecs-update-service: .check-args-ecs-update-service
	aws ecs update-service --cluster $(CLUSTER) --service $(SERVICE) --desired-count 1 --force-new-deployment --enable-execute-command


# golang - cli
#
#
.PHONY: cli # go build
cli: # go build
	go build -o build/cli ./cmd/main.go

.PHONY: .check-args
