#Defaults
include .env
export #exports the .env variables

IMAGE ?= tulibraries/centralized-metadata
VERSION ?= $(DOCKER_IMAGE_VERSION)
HARBOR ?= harbor.k8s.temple.edu
CLEAR_CACHES=no
RAILS_MASTER_KEY ?= $(CENTRALIZED_METADATA_MASTER_KEY)
CI ?= false
CM_DB_HOST ?= host.docker.internal
CM_DB_NAME ?= centralized_metadata
CM_DB_USER ?= root

DEFAULT_RUN_ARGS ?= -e "EXECJS_RUNTIME=Disabled" \
		-e "K8=yes" \
		-e "RAILS_ENV=production" \
		-e "RAILS_MASTER_KEY=$(RAILS_MASTER_KEY)" \
		-e "RAILS_SERVE_STATIC_FILES=yes" \
		-e "CM_DB_HOST=$(CM_DB_HOST)" \
		-e "CM_DB_NAME=$(CM_DB_NAME)" \
		-e "CM_DB_PASSWORD=$(CM_DB_PASSWORD)" \
		-e "CM_DB_USER=$(CM_DB_USER)" \
		--rm -it

run:
	@docker run --name=centralized_metadata -p 127.0.0.1:3001:3000/tcp \
		-e "RAILS_ENV=production" \
		-e "RAILS_SERVE_STATIC_FILES=yes" \
		-e "RAILS_MASTER_KEY=$(RAILS_MASTER_KEY)" \
		-e "K8=yes" \
		-e "CM_DB_HOST=$(CM_DB_HOST)" \
		-e "CM_DB_NAME=$(CM_DB_NAME)" \
		-e "CM_DB_PASSWORD=$(CM_DB_PASSWORD)" \
		-e "CM_DB_USER=$(CM_DB_USER)" \
		--rm -it \
		$(HARBOR)/$(IMAGE):$(VERSION)

build:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--tag $(HARBOR)/$(IMAGE):$(VERSION) \
		--tag $(HARBOR)/$(IMAGE):latest \
		--file .docker/app/Dockerfile \
		--no-cache .

lint:
	@if [ $(CI) == false ]; \
		then \
			hadolint .docker/app/Dockerfile; \
		fi

scan:
	trivy image $(HARBOR)/$(IMAGE):$(VERSION);

deploy: scan lint
	@docker push $(HARBOR)/$(IMAGE):$(VERSION) \
	# This "if" statement needs to be a one liner or it will fail.
	# Do not edit indentation
	@if [ $(VERSION) != latest ]; \
		then \
			docker push $(HARBOR)/$(IMAGE):latest; \
		fi
