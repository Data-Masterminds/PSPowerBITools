# Set up CI/CD

## Create the repo token for the GitHub Action
1. Click on your profile picture in the top right corner
2. Click on "Settings"
3. Click on "Developer settings"
4. Click on "Personal access tokens"
5. Click on "Fine-grained tokens"
6. Click on "Generate new token"
7. Put in:
   1. Token name: "[Repository Name]_RepoToken" (Replace the [Repository Name] with the name of the repository)
   2. Set the expiration date to ""Custom" and set it for at least a year
   3. Select the "repo" scope by selecting "Only select repositories" and selecting the repository
   4. Click on "Repository permissions"
   5. Go to "Contents" and select "Read & write"
8. Click on "Generate token"
9. Copy the token and save it somewhere safe

## Implement the repo token in the repository
1. Go to the repository on GitHub
2. Click on "Settings"
3. Click on "Secrets and variables"
4. Click on "Actions"
5. Click on "New repository secret"
6. Put in:
   1. Name: REPO_TOKEN
   2. Secret: [The token you generated in the previous step]

## Set up a GitHub Action for building the release

You need to do this action twice for development and productions releases. The only difference is the name of the workflow and a small difference in the actions that are performed.

1. Go to the repository on GitHub
2. Click on the "Actions"
3. Click on the "New workflow" button
4. Select "Set up a workflow yourself"
5. Copy the content of the file [build-release-dev.yml](build-release-dev.yml) into the editor
6. Name the workflow "Build release"
7. Click on the "Commit changes" button

When you perform the same steps for the production release, you need to change the name of the workflow to "Build production release" and use the content of the file [build-release-prod.yml](build-release-prod.yml) instead.