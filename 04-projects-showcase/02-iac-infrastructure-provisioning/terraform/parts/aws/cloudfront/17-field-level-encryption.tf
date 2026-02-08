# 17. CloudFront Field-Level Encryption
# encrypting specific sensitive fields (like credit card numbers) at the edge.

resource "aws_cloudfront_field_level_encryption_config" "example" {
  comment = "example encryption config"

  query_arg_profile_config {
    forward_when_query_arg_profile_is_unknown = true
    query_arg_profiles {
      items {
        profile_id = aws_cloudfront_field_level_encryption_profile.example.id
        query_arg  = "sensitive"
      }
    }
  }
}

resource "aws_cloudfront_field_level_encryption_profile" "example" {
  name    = "example-profile"
  comment = "example profile"

  encryption_entities {
    items {
      public_key_id = aws_cloudfront_public_key.example.id
      provider_id   = "AWS"
      field_patterns {
        items = ["credit-card-number"]
      }
    }
  }
}
