export COMPOSE_DOCKER_CLI_BUILD = 1
export DOCKER_BUILDKIT = 1
export COMPOSE_PROJECT_NAME = metrics
export ARCH = $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
export META = $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null | sed 's:.*/::')
export VERSION = $(shell git fetch --tags --force 2> /dev/null; tags=($$(git tag --sort=-v:refname)) && ([ "$${\#tags[@]}" -eq 0 ] && echo v0.0.0 || echo $${tags[0]}) | sed -e "s/^v//")

.ONESHELL:
.PHONY: arm64
.PHONY: amd64

.PHONY: all
all: package

.PHONY: package
package:
	@$(MAKE) package-$(ARCH)
	@$(MAKE) bundle-docker-$(ARCH)

.PHONY: package-%
package-%: %
	@$(MAKE) bundle-debian-$^

.PHONY: bundle-debian-%
bundle-debian-%: %
	@\
		docker \
		compose \
		run \
		--rm debian-package \
		--version $(VERSION) \
		--arch $^ \
		--pkg metrics \
		--source /project/packaging

.PHONY: bundle-docker-%
bundle-docker-%: %
	@\
		docker \
		build \
		-t openbank/metrics:$^-$(VERSION).$(META) \
		-f packaging/docker/$^/Dockerfile \
		.

.PHONY: release
release:
	@\
		docker \
		compose \
		run \
		--rm release \
		--version $(VERSION) \
		--token ${GITHUB_RELEASE_TOKEN}
