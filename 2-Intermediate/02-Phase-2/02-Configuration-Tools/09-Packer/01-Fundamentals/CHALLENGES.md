# 🛠️ Packer Challenges

## Challenge 1: The Multi-Provisioner
**Objective**: Combine methods.
1.  Start an AWS build.
2.  Use a `shell` provisioner to install `curl`.
3.  Use an `ansible` (or `shell` + script) provisioner to perform complex setup.
4.  Verify the image boots correctly.

## Challenge 2: Image Tags
**Objective**: Governance.
1.  Add `run_tags` and `tags` to your `amazon-ebs` source.
2.  Include tags like `Owner`, `Project`, and `SecurityScanned = "True"`.

## Challenge 3: Post-Processing
**Objective**: Automate the manifest.
1.  Add a `post-processor "manifest" {}` block.
2.  Run `packer build`.
3.  Observe the `packer-manifest.json` file created. This file contains the AMI ID of your new image.
