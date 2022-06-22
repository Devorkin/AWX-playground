clean:		## Attempt to clean up everything
	cd awx
	make clean
	cd ..
	rm -rf awx

install:	## Install AWX Tower (free tier) from Github
	bash ./install.sh

awx_cli_docs:	## Launch AWX-CLI documentation (web-app)
	cd awx/awxkit/awxkit/cli/docs/build/html && python -m http.server

prepare_pyenv:
	pyenv install 3.9.5
	pyenv virtualenv 3.9.5 awx_project
	pyenv activate awx_project
