# 18. CloudFront with Continuous Deployment
# Validating new configurations on a subset of traffic before full rollout.

resource "aws_cloudfront_continuous_deployment_policy" "example" {
  enabled = true

  staging_distribution_dns_names {
    items    = [aws_cloudfront_distribution.staging.domain_name]
    quantity = 1
  }

  traffic_config {
    type = "SingleWeight"
    single_weight_config {
      weight = 0.1 # 10% of traffic
    }
  }
}
