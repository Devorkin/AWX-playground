clean:				## Attempt to clean up everything
	for CONTAINER in $(docker container ps --format "{{.Names}} {{.ID}}" | grep 'awx_' | cut -d ' ' -f2); do \
	docker container stop ${CONTAINER} && docker container rm ${CONTAINER}; done
	cd awx && $(MAKE) clean
	rm -rf awx
	rm -rf postgres_local_data

install:			## Install AWX Tower (free tier) from Github
	bash -x ./install.sh

awx_cli_docs:		## Launch AWX-CLI documentation (web-app)
	cd awx/awxkit/awxkit/cli/docs/build/html && python -m http.server

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
