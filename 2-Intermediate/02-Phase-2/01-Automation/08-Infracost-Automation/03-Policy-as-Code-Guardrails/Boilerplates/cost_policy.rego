package infracost

# 1. Deny if any project has a cost increase of over $100/mo
deny_high_cost[msg] {
    # Find the total monthly cost diff
    cost := to_number(input.totalMonthlyCost)
    cost > 100
    msg := sprintf("Total cost increase is $%v. This exceeds the $100/mo budget threshold per PR.", [cost])
}

# 2. Warn if forbidden instance types are used
warn_instance_types[msg] {
    some i
    resource := input.projects[0].breakdown.resources[i]
    resource.name == "aws_instance"
    
    # Example: Disallow expensive 'g' class unless approved
    startswith(resource.metadata.instance_type, "g")
    msg := sprintf("GPU instance detected (%v). Please ensure this is approved by the ML team.", [resource.metadata.instance_type])
}

# Helper to convert strings to numbers
to_number(s) = n {
    n := cast_to_number(s)
}
