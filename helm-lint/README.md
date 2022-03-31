# Helm-Linter

This repository is for the **GitHub Action** to run a **Helm-Linter**.
It is a simple combination of helm linter tools to help validate your charts, templates and manifests file.

**The end goal of this tool:**

- Prevent broken code from being uploaded to the default branch (_Usually_ `master`)
- Help establish helm best practices


## How it Works

The Helm-linter finds issues and reports them to the console output. Fixes are suggested in the console output but not automatically fixed, and a status check will show up as failed on the pull request.

The design of the **Helm-Linter** is currently to allow linting to occur in **GitHub Actions** as a part of continuous integration occurring on pull requests as the commits get pushed.


## How to use

To use this **GitHub** Action you will need to complete the following:

1. Create a new file in your repository called `.github/workflows/helm-linter.yml`
2. Copy the example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Enjoy your more _stable_, and _cleaner_ codebase


### Example connecting GitHub Action Workflow

In your repository you should have a `.github/workflows` folder with **GitHub** Action similar to below:

- `.github/workflows/helm-linter.yml`

This file should have the following code:

```yml
---
#################################
#################################
## Helm Linter GitHub Actions ##
#################################
#################################
name: Helm-Linter 

#
# Documentation:
# https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions
#

#############################
# Start the job on all push #
#############################
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

###############
# Set the Job #
###############
jobs:
  Helm-Linter-Actions:
    # Name the Job
    name: Lint Helm Templates
    # Set the agent to run on
    runs-on: ubuntu-latest

    ##################
    # Load all steps #
    ##################
    steps:
      ##########################
      # Checkout the code base #
      ##########################
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          # Full git history is needed to get a proper list of changed files within `helm-linter`
          fetch-depth: 0

      ################################
      # Run Helm Linter against multiple code base #
      ################################
      - name: Lint `charts` Code Base
        uses: hometogo/actions/helm-lint@main
        with:
          # Provide the chart directory location
          chart_location: 'charts'
      - name: Lint `infrastructure` Code Base
        uses: hometogo/actions/helm-lint@main
        with:
          # Provide the chart directory location
          chart_location: 'infrastructure'

```
