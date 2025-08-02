# Environment variables
SHELL := /bin/bash
.DEFAULT_GOAL := help

define format_py_version
$(shell echo "py$(subst .,,$(1))")
endef

# PYTHON
PYTHON_VERSION := $(shell cat ./project-helpers/.python-version)

# PROJECT

# Project configuration files
PROJECT_CONFIG_FILE		= pyproject.toml
RUFF_CONFIG_FILE 		= ./project-helpers/ruff.toml
CLIFF_CONFIG_FILE		= ./project-helpers/cliff.toml
MKDOCS_CONFIG_FILE		= ./project-helpers/mkdocs.yml

# Project folders
SOURCE_DIR 				= project_tools
DOCS_DIR 				= docs
SCRIPTS_DIR 			= scripts
TEST_DIR 				= tests
VENV_DIR  				= .venv

## uv run
PACKAGE_MANAGER_RUN = uv run

# TOOLS
PACKAGE_MANAGER = uv
RUFF 			= ${PACKAGE_MANAGER_RUN} ruff --config $(RUFF_CONFIG_FILE)
RUFF-ARGS 		= --target-version $(call format_py_version,$(PYTHON_VERSION)) -n

# TOOL EXECUTOR

## git-cliff
GIT-CLIFF-PV-TE	= ${PACKAGE_MANAGER_RUN} git-cliff --config $(CLIFF_CONFIG_FILE) -v
GIT-CLIFF-TE	= ${GIT-CLIFF-PV-TE} -o CHANGELOG.md


.PHONY: help check clean format generate-docs generate-docs-local install changelog-generate changelog-preview local-dev-config install-all install-python install-uv lint print-header print-footer test

help:
	@echo ""
	@echo "Commons module commands"
	@echo "Using python: $(call format_py_version,$(PYTHON_VERSION))"
	@echo ""
	@echo "Development:"
	@echo "  make install        	: Clean install of dependencies"
	@echo "  make install-all    	: Clean install of dependencies (alias for install)"
	@echo "  make install-python 	: Install Python version from .python-version"
	@echo "  make install-uv     	: Install UV package manager"
	@echo "  make local-dev-config	: Configure development environment"
	@echo ""
	@echo "Code Quality:"
	@echo "  make format         	: Format code using Ruff"
	@echo "  make lint           	: Run linters"
	@echo "  make test           	: Run tests with coverage"
	@echo "  make check          	: Run format, lint, and test"
	@echo "  make clean          	: Clean project artifacts"
	@echo ""
	@echo "Project Management:"
	@echo "  make changelog-generate 	: Generate changelog from git history"
	@echo "  make changelog-preview 	: Preview changelog without writing to file"
	@echo "  make generate-docs 		: Generate the project documentation using mkdocs"
	@echo "  make generate-docs-local 	: Generate the project documentation using mkdocs -- local for tests"
	@echo ""

changelog-generate: print-header
	@echo "Generating changelog..."
	@${GIT-CLIFF-TE}
	@echo ""
	@echo "... changelog generation finalized. check CHANGELOG.md!"
	@make print-footer

changelog-preview: print-header
	@echo "Previewing changelog (without writing to file)..."
	@${GIT-CLIFF-PV-TE}
	@echo ""
	@echo "... changelog preview completed!"
	@make print-footer

check: clean format lint

.ONESHELL:
clean: print-header
	@find . -type d -name "__pycache__" -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@rm -rf .pytest_cache build dist *.egg-info .coverage coverage.xml
	@make print-footer

.ONESHELL:
local-dev-config: print-header
	@echo "Configuring environment..."
	@echo "### Install package manager"
	# placeholder
	@echo "### Install Python"
	@make install-python
	@echo "### Configure virtual environment"
	@${PACKAGE_MANAGER} venv ${VENV_DIR} --allow-existing --trusted-host localhost --color auto --python python${PYTHON_VERSION}
	@echo "### Install project dependencies"
	@make install
	@echo ""
	@echo "...DEV environment configured!"
	@make print-footer

format: print-header
	@echo "Starting ruff check..."
	@echo ""
	@${RUFF} format ${SOURCE_DIR} ${SCRIPTS_DIR} ${TEST_DIR} ${DOCS_DIR} ${RUFF-ARGS} -v
	@${RUFF} check ${SOURCE_DIR} ${SCRIPTS_DIR} ${TEST_DIR} ${DOCS_DIR}  ${RUFF-ARGS} -v --fix
	@echo ""
	@echo "...ending ruff check!"
	@make print-footer

generate-docs:  print-header
	@echo "Generating docs for GitHub Pages..."
	@echo ""
	@${PACKAGE_MANAGER_RUN} mkdocs gh-deploy -b site --force --clean
	@echo ""
	@echo "...ending generate docs! Documentation deployed to GitHub Pages."
	@make print-footer

generate-docs-local:  print-header
	@echo "Generating docs locally..."
	@echo ""
	@${PACKAGE_MANAGER_RUN} mkdocs build --clean -d local-dev/local-mkdocs
	@echo ""
	@echo "...ending generate docs! Documentation available in local-dev/local-mkdocs directory."
	@make print-footer

install: clean print-header
	@echo "Install dependencies using package manager..."
	@echo ""
	@${PACKAGE_MANAGER} sync --link-mode=copy
	@echo ""
	@echo "..Install and configure pre-commit...."
	@echo ""
	@${PACKAGE_MANAGER_RUN} pre-commit install
	@${PACKAGE_MANAGER_RUN} pre-commit install --hook-type commit-msg
	@echo ""
	@echo "..pre-commit installed and configured...."
	@echo ""
	@echo "...ending install dependencies!"
	@make print-footer

install-all: install

install-python:
	@${PACKAGE_MANAGER} python install python${PYTHON_VERSION}

install-uv: print-header
	@echo "Installing UV..."
	@curl -LsSf https://astral.sh/uv/install.sh | sh
	@echo "...UV installed."
	@make print-footer

lint: print-header
	@echo "Starting ruff check..."
	@echo ""
	@echo "SRC :: ${SOURCE_DIR}"
	@${RUFF} check ${SOURCE_DIR} ${SCRIPTS_DIR} ${TEST_DIR} ${DOCS_DIR}  ${RUFF-ARGS} -v
	@echo ""
	@echo "...ending ruff check!"
	@make print-footer

print-header:
	@echo ""
	@echo "Starting..."
	@echo "------------------------------------------------------------------"
	@echo ""

print-footer:
	@echo ""
	@echo "... and done!"
	@echo "=================================================================="
	@echo ""

test: print-header
	@echo "Running unit tests..."
	@echo ""
	@if find tests -type f -name "test_*.py" | grep -q .; then \
		${PACKAGE_MANAGER_RUN} pytest -v -s --log-level=DEBUG --color=auto --code-highlight=yes --cov=${SOURCE_DIR} --cov-report=xml --cov-fail-under=80; \
	else \
		echo "No test files found, skipping tests."; \
		echo "" >> coverage.xml; \
	fi
	@echo ""
	@echo "...ending unit tests!"
	@make print-footer
