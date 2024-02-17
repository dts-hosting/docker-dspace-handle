SHELL:=/bin/bash

ifneq (,$(wildcard ./.env))
	include .env
	export
endif

.PHONY: install
install: ## make install # Install dependencies
	@mkdir -p "src"
	@rbenv install -s && gem install bundler
	@bundle install
	@gem install overcommit && overcommit --install && overcommit --sign pre-commit
	@npm install && npm i -g npx || true

.PHONY: lint
lint: ## make lint # Run all linters
	@npx prettier . --write

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
