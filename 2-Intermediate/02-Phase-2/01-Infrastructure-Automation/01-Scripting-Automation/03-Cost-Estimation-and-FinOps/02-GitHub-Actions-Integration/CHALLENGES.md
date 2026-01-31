# 🛠️ GHA Integration Challenges

## Challenge 1: The Multi-Project Workflow
**Objective**: Handle complex repos.
1.  Assume a repo with `/infra/aws` and `/infra/google`.
2.  Modify the GHA boilerplate to run Infracost on BOTH and post a combined comment.

## Challenge 2: Auto-Failure
**Objective**: Hard budget enforcement.
1.  Use the `post-condition` feature of the Infracost GHA action.
2.  Set it to fail the build if the monthly cost increase is greater than $50.
3.  Syntax: `post-condition: '{"averageLabel": "Total monthly cost", "condition": "< 50"}'`.

## Challenge 3: Slack Notification
**Objective**: Cross-platform alerting.
1.  Add a step to the workflow that only runs if Infracost detected a change.
2.  Use a Slack Action to send the cost diff to the `#finops` channel.
