# 🛠️ Jenkins Mastery Challenges

## Challenge 1: The Multi-Agent Build
**Objective**: Scale your workload.
1.  Setup a Jenkins Agent using Docker.
2.  Modify the `Jenkinsfile` to run the "Test" stage on the `docker-agent` label.
3.  Modify the "Build" stage to run on the `master` (controller) node.

## Challenge 2: Post-Build Integrity
**Objective**: Reporting and Cleanup.
1.  Add a `post` block to the "Build" stage.
2.  Ensure that if the build fails, the workspace is cleaned up automatically.
3.  Ensure that if the build succeeds, the artifact is "Archived" using the `archiveArtifacts` step.

## Challenge 3: Shared Library Refactor
**Objective**: DRY (Don't Repeat Yourself) at Scale.
1.  Create a `vars/standardBuild.groovy` file.
2.  Move the "Build" and "Test" logic from the `Jenkinsfile` into this shared library.
3.  Call the library in the `Jenkinsfile` using a single line: `standardBuild()`.
