.DEFAULT_GOAL := help
.PHONY: all

PROJECT_NAME=$(shell grep "name" pyproject.toml | cut -d "\"" -f 2)

help:
	@# Got it from here: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deps: ## Installs project dependencies
	poetry install --no-root

deps-outdated: ## Shows outdated dependencies
	poetry show --outdated

clean: ## Resets the development environment to the initial state
	-find . -name "*.pyc" -delete
	-rm requirements.txt
	-rm dist/${PROJECT_NAME}*
	-poetry env remove --quiet --all

setup: deps ## Sets up the developement environment
	poetry run pre-commit install

check: ## Runs static checks on the code
	poetry run pre-commit run --all

test: ## Runs all the tests
	poetry run pytest .

coverage: ## Shows coverage in the browser
	poetry run coverage run -m pytest .
	poetry run coverage html
	open htmlcov/index.html

future: ## Tests the code against multiple python versions
	poetry export -f requirements.txt --output requirements.txt --with dev
	poetry run nox
	-rm requirements.txt

build:  ## Builds this project into a package
	poetry build

all: clean setup check test future build deps-outdated