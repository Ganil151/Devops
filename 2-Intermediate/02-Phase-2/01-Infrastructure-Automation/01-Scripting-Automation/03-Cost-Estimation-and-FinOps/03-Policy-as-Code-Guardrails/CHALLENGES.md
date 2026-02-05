# 🛠️ Policy Challenges

## Challenge 1: The Region Guard
**Objective**: Prevent deployment in expensive regions.
1.  Write a Rego rule that denies any resource in `af-south-1` (Cape Town) or `me-south-1` (Bahrain) unless a specific project tag is present.

## Challenge 2: Storage Limit
**Objective**: Prevent massive data costs.
1.  Infracost output includes `aws_ebs_volume`.
2.  Write a rule that fails if any single volume is >= 10,000 GB (10 TB).

## Challenge 3: Instance Pruning
**Objective**: Force usage of Burstables.
1.  If the environment is `dev`, deny any instance that is NOT in the `t3` family.
2.  Hint: `not startswith(instance_type, "t3")`.
