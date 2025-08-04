# Environment variables
SHELL := /bin/bash
.DEFAULT_GOAL := help

define format_py_version
$(shell echo "py$(subst .,,$(1))")
endef

# PYTHON
PYTHON_VERSION := $(shell cat ./config/.python-version)

# PROJECT

# Project configuration files
PROJECT_CONFIG_FILE			= pyproject.toml
RUFF_CONFIG_FILE 			= ./config/ruff.toml
CHANGELOG_CONFIG_FILE		= ./config/git-changelog.toml
MKDOCS_CONFIG_FILE			= ./config/mkdocs.yml

# Project folders
SOURCE_DIR 					= src
DOCS_DIR 					= docs
SCRIPTS_DIR 				= scripts
TEST_DIR 					= tests
VENV_DIR  					= .venv

# TOOLS
PACKAGE_MANAGER 			= uv

## uv run
PACKAGE_MANAGER_RUN 		= ${PACKAGE_MANAGER} run

## Ruff linter
RUFF 						= ${PACKAGE_MANAGER_RUN} ruff --config $(RUFF_CONFIG_FILE)
RUFF-ARGS 					= --target-version $(call format_py_version,$(PYTHON_VERSION)) -n

## Pyright linter
PYRIGHT						= ${PACKAGE_MANAGER_RUN} pyright -p ${SOURCE_DIR}

# TOOL EXECUTOR

## git-changelog
GIT-CHANGELOG-PV-TE			= ${PACKAGE_MANAGER_RUN} git-changelog --style conventional
GIT-CHANGELOG-TE			= ${GIT-CHANGELOG-PV-TE} --output CHANGELOG.md
GIT-CHANGELOG-VERSION-TE 	= ${PACKAGE_MANAGER_RUN} git-changelog --style conventional --output CHANGELOG.md

## pre-commit
PRE-COMMIT-RUN-ALL-FILES	= ${PACKAGE_MANAGER_RUN}  pre-commit run --all-files

.PHONY: help check clean format generate-docs generate-docs-local install changelog-generate changelog-preview local-dev-config install-all install-python install-uv lint print-header print-footer test release release-major release-minor release-patch pre-commit-all-files

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
	@echo "  make changelog-generate 	: Generate changelog from git history using git-changelog"
	@echo "  make changelog-preview 	: Preview changelog without writing to file"
	@echo "  make generate-docs 		: Generate the project documentation using mkdocs"
	@echo "  make generate-docs-local 	: Generate the project documentation using mkdocs -- local for tests"
	@echo ""

changelog-generate: print-header
	@echo "Generating changelog..."
	@${GIT-CHANGELOG-TE}
	@echo ""
	@echo "... changelog generation finalized. check CHANGELOG.md!"
	@make print-footer

changelog-preview: print-header
	@echo "Previewing changelog (without writing to file)..."
	@${GIT-CHANGELOG-PV-TE}
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

pre-commit-all-files: print-header
	@echo "pre-commit run for all files for validation..."
	@${PRE-COMMIT-RUN-ALL-FILES}
	@echo "...pre-commit run for all files for validation executed!"
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
		PYTHONPATH=src ${PACKAGE_MANAGER_RUN} pytest -v -s --log-level=DEBUG --color=auto --code-highlight=yes --cov=${SOURCE_DIR} --cov-report=xml --cov-fail-under=80; \
	else \
		echo "No test files found, skipping tests."; \
		echo "" >> coverage.xml; \
	fi
	@echo ""
	@echo "...ending unit tests!"
	@make print-footer

# Common release function to avoid code duplication
# Using --no-verify flag with git commit commands to bypass pre-commit hooks during automated releases
# This prevents conflicts between pre-commit hooks and the release process
define do_release
	@echo "Running tests before release..."
	@make test || { echo "Tests failed! Aborting release."; exit 1; }
	@echo ""
	@echo "Bumping $(1) version..."
	@${PACKAGE_MANAGER} version --bump $(1) || { echo "Version bump failed! Aborting release."; exit 1; }
	@NEW_RELEASE_VERSION=$$(${PACKAGE_MANAGER} version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
	@echo "New version: $$NEW_RELEASE_VERSION"
	@echo "Creating temporary commit for version bump..."
	@git add pyproject.toml || { echo "Git add failed! Aborting release."; exit 1; }
	@git commit --no-verify -m "build(release): bump version to $$NEW_RELEASE_VERSION" || { echo "Git commit failed! Aborting release."; exit 1; }
	@echo "Generating changelog with version $$NEW_RELEASE_VERSION..."
	@${GIT-CHANGELOG-VERSION-TE} -B $$NEW_RELEASE_VERSION || { echo "Changelog generation failed! Aborting release."; exit 1; }
	@echo "Committing changelog..."
	@git add CHANGELOG.md || { echo "Git add failed! Aborting release."; exit 1; }
	@git commit --amend --no-verify -m "build(release): bump version to $$NEW_RELEASE_VERSION and generate changelog" || { echo "Git commit failed! Aborting release."; exit 1; }
	@echo "Creating version tag..."
	@git tag -f v$$NEW_RELEASE_VERSION || { echo "Git tag failed! Aborting release."; exit 1; }
	@git tag -f latest || { echo "Git tag latest failed! Aborting release."; exit 1; }
	@echo "Pushing changes and tags..."
	@git push origin main || { echo "Git push failed! Aborting release."; exit 1; }
	@echo "Pushing tags..."
	@git push origin v$$NEW_RELEASE_VERSION --force || { echo "Git push version tag failed! Aborting release."; exit 1; }
	@git push origin latest --force || { echo "Git push latest tag failed! Aborting release."; exit 1; }
	@echo ""
	@echo "...ending release!"
endef

.ONESHELL:
release: print-header
	@echo "Starting release (minor version bump)..."
	@echo ""
	$(call do_release,minor)
	@make print-footer

.ONESHELL:
release-major: print-header
	@echo "Starting release (major version bump)..."
	@echo ""
	$(call do_release,major)
	@make print-footer

.ONESHELL:
release-minor: print-header
	@echo "Starting release (minor version bump)..."
	@echo ""
	$(call do_release,minor)
	@make print-footer

.ONESHELL:
release-patch: print-header
	@echo "Starting release (patch version bump)..."
	@echo ""
	$(call do_release,patch)
	@make print-footer
