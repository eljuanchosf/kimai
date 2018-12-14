# import config.
# You can change the default config with `make cfg="config_special.env" build`
appcfg ?= .docker/app.config.env
include $(appcfg)
export $(shell sed 's/=.*//' $(appcfg))

# import deploy config
# You can change the default deploy config with `make cfg="deploy_special.env" release`
dockercfg ?= .docker/docker.config.env
include $(dockercfg)
export $(shell sed 's/=.*//' $(dockercfg))

# import credentials
# You can change the default deploy config with `make cfg="credentials_special.env" release`
# cred ?= credentials.env
# include $(cred)
# export $(shell sed 's/=.*//' $(cred))

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
ORANGE=\033[0;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
DOCKERFILE=".docker/Dockerfile"
ENV_FILE=".env"

info:
	@echo -e "*** $(BLUE)Image info$(NC) ***"
	@echo -e "Dockerfile: $(GREEN)$(DOCKERFILE)$(NC)"
	@echo -e "Repository: $(GREEN)$(DOCKER_REPO)$(NC)"
	@echo -e "Image:      $(GREEN)$(IMAGE_NAME)$(NC)"
	@echo -e "Version:    $(ORANGE)$(VERSION)$(NC)\n"

# DOCKER TASKS
# Build the container
build: info ## Build the container
	docker build --rm --file $(DOCKERFILE) -t $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION) .
	@echo -e "$(ORANGE)Removing dangling intermediate images...$(NC)\n"
	docker image prune -f

run: ## Run container on port configured in `app.config.env`
	docker run --env-file=$(ENV_FILE) -it --rm \
	     -p=$(LOCAL_PORT):$(CONTAINER_PORT) \
		 --mount type=bind,source="$$(pwd)",target=/srv/app \
		 --name="$(IMAGE_NAME)" $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

rund: ## Run container detached on port configured in `app.config.env`
	docker run --env-file=$(ENV_FILE) -d --rm \
		-p=$(LOCAL_PORT):$(CONTAINER_PORT) \
		--mount type=bind,source="$$(pwd)",target=/srv/app \
		--name="$(IMAGE_NAME)" $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

runi: rund ssh ## Run the container and exec interavtively

ssh: ## SSH's into the container
	docker exec -it $(IMAGE_NAME) $(SHELL)

stop: ## Stop and remove a running container
	docker stop "$(IMAGE_NAME)"

up: build run ## Builds the image and runs the container in foreground
upd: build rund ## Builds the image and runs the container in background
upin: build runi ## Builds the image, runs the container and execs the shell into it

rmi: ## Removes the image
	docker rmi $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

publish-latest: tag-latest ## Publish the `latest` taged container to Docker Hub
	@echo 'Publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to ECR
	@echo 'Publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

tag-latest: ## Generate container `{version}` tag
	@echo 'Create tag latest'
	docker tag $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION) $(DOCKER_REPO)/$(IMAGE_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'Create tag $(VERSION)'
	docker tag $(DOCKER_REPO)/$(IMAGE_NAME) $(DOCKER_REPO)/$(IMAGE_NAME):$(VERSION)

# Build the container
compose-up: ## Build the release and develoment container. The development
	docker-compose up

version: ## Output the current version
	@echo $(VERSION)

# Generic commands
remove-no-tag-images: ## Removes all images with tag set in "<none>"
	docker rmi `docker image ls | grep "^<none>" | awk "{print $$3}"`

stop-all-containers: ## Stops all running containers
	docker stop `docker ps -a -q`

remove-all-containers: stop-all-containers ## Stops and removes all containers
	docker rm `docker ps -a -q`