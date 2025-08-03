# Python project utils

Linters, formatters and general python project utils and helpers

## Project main information

`Project Name`: python-project-utils\
`Short description`: This project is to be used as a common project for linters, formatters and general helpers
for python projects

## Project libs


### Configuration

- Python version: `3.13`
- Package management: [UV](https://docs.astral.sh/uv/)

### Development


#### Linters:

- [Ruff](https://docs.astral.sh/ruff/)


#### Formatters:

- [Ruff](https://docs.astral.sh/ruff/)

#### Tools:

- [Taskipy](https://github.com/taskipy)


#### Tests:

- [PyTest](https://docs.pytest.org/en/stable/)

## Implemented Modules


## Development Workflow

This project uses a streamlined development workflow:

1. **Feature Development**: Develop features in separate branches. The Branch Validation workflow automatically validates all pushes to non-main branches.

2. **Pull Request & Auto-merge**: Create a pull request to merge your feature into main. The validate-and-merge workflow will:
   - Automatically validate the changes (linting, testing)
   - Auto-merge the PR if it:
     - Passes all validation checks
     - Has the `ready-to-merge` label (and doesn't have the `work-in-progress` label)
     - Has at least one approval
   
3. **Manual Release**: After changes are merged to main, a release is manually triggered.

## Release Process

### How to Release

To create a new release:

1. Ensure all desired changes have been merged into the main branch
2. Go to the GitHub repository's "Actions" tab
3. Select the "Manual Release" workflow
4. Click "Run workflow"
5. Select the desired version bump type:
   - **major**: For breaking changes (e.g., 1.0.0 → 2.0.0)
   - **minor**: For new features (e.g., 1.0.0 → 1.1.0)
   - **patch**: For bug fixes (e.g., 1.0.0 → 1.0.1)
6. Click "Run workflow" to start the release process

The release process will:
- Run tests to ensure the code is in a releasable state
- Bump the version according to the selected type
- Create a git tag for the new version
- Generate the changelog
- Push the changes and tags to GitHub

This two-step process ensures that version tags are properly created and that the changelog correctly categorizes changes under the appropriate version instead of keeping them under "Unreleased".

