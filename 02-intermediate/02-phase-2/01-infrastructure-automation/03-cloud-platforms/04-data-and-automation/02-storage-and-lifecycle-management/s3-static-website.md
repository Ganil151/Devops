# AWS S3 Static Website Hosting

Complete guide to hosting static websites on Amazon S3 with custom domains, HTTPS, and global distribution using CloudFront.

## Overview

S3 static website hosting is a cost-effective way to host HTML, CSS, and JavaScript websites without managing servers.

```yaml
Benefits:
  Cost-Effective:
    - No server costs
    - Pay only for storage and bandwidth
    - Free tier available (5GB storage, 15GB transfer)
  
  Scalability:
    - Automatic scaling
    - Handle millions of requests
    - No capacity planning
  
  Reliability:
    - 99.99% availability SLA
    - 11 9's durability
    - Multi-AZ redundancy
  
  Performance:
    - CloudFront CDN integration
    - Global edge locations
    - Low latency delivery

Use Cases:
  - Personal blogs and portfolios
  - Documentation sites
  - Landing pages
  - Single Page Applications (SPAs)
  - Marketing campaigns
  - Product showcases
```

## Quick Start

### 1. Create and Configure Bucket

```bash
# Create bucket (name must match domain if using custom domain)
aws s3 mb s3://my-website.example.com --region us-east-1

# Enable static website hosting
aws s3 website s3://my-website.example.com \
  --index-document index.html \
  --error-document error.html

# Verify configuration
aws s3api get-bucket-website --bucket my-website.example.com
```

### 2. Upload Website Files

```bash
# Upload all files
aws s3 sync ./website-files s3://my-website.example.com/

# Set correct content types
aws s3 sync ./website-files s3://my-website.example.com/ \
  --content-type "text/html" \
  --exclude "*" \
  --include "*.html"

aws s3 sync ./website-files s3://my-website.example.com/ \
  --content-type "text/css" \
  --exclude "*" \
  --include "*.css"

aws s3 sync ./website-files s3://my-website.example.com/ \
  --content-type "application/javascript" \
  --exclude "*" \
  --include "*.js"
```

### 3. Make Bucket Public

```bash
# Disable public access block
aws s3api delete-public-access-block \
  --bucket my-website.example.com

# Create bucket policy for public read
cat > website-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-website.example.com/*"
    }
  ]
}
EOF

# Apply policy
aws s3api put-bucket-policy \
  --bucket my-website.example.com \
  --policy file://website-policy.json
```

### 4. Access Website

```bash
# Website endpoint format
http://my-website.example.com.s3-website-us-east-1.amazonaws.com

# Or region-independent format
http://my-website.example.com.s3-website.us-east-1.amazonaws.com
```

## Complete Example HTML Site

### index.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My S3 Website</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header>
        <h1>Welcome to My S3 Website</h1>
        <nav>
            <a href="index.html">Home</a>
            <a href="about.html">About</a>
            <a href="contact.html">Contact</a>
        </nav>
    </header>
    
    <main>
        <section class="hero">
            <h2>Hosted on Amazon S3</h2>
            <p>Fast, reliable, and cost-effective static website hosting</p>
            <button onclick="showMessage()">Click Me!</button>
        </section>
        
        <section class="features">
            <div class="feature">
                <h3>🚀 Fast</h3>
                <p>Global CDN delivery with CloudFront</p>
            </div>
            <div class="feature">
                <h3>💰 Affordable</h3>
                <p>Pay only for what you use</p>
            </div>
            <div class="feature">
                <h3>🔒 Secure</h3>
                <p>HTTPS encryption included</p>
            </div>
        </section>
    </main>
    
    <footer>
        <p>&copy; 2024 My S3 Website. All rights reserved.</p>
    </footer>
    
    <script src="script.js"></script>
</body>
</html>
```

### styles.css

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
}

header {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    padding: 1.5rem 2rem;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

header h1 {
    color: #667eea;
    margin-bottom: 1rem;
}

nav a {
    color: #333;
    text-decoration: none;
    margin-right: 2rem;
    font-weight: 500;
    transition: color 0.3s;
}

nav a:hover {
    color: #667eea;
}

main {
    max-width: 1200px;
    margin: 3rem auto;
    padding: 0 2rem;
}

.hero {
    background: white;
    padding: 3rem;
    border-radius: 10px;
    text-align: center;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    margin-bottom: 3rem;
}

.hero h2 {
    color: #667eea;
    font-size: 2.5rem;
    margin-bottom: 1rem;
}

.hero p {
    font-size: 1.2rem;
    color: #666;
    margin-bottom: 2rem;
}

button {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1rem 2rem;
    border: none;
    border-radius: 5px;
    font-size: 1rem;
    cursor: pointer;
    transition: transform 0.3s, box-shadow 0.3s;
}

button:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.features {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 2rem;
}

.feature {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    text-align: center;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    transition: transform 0.3s;
}

.feature:hover {
    transform: translateY(-5px);
}

.feature h3 {
    font-size: 2rem;
    margin-bottom: 1rem;
}

footer {
    background: rgba(0, 0, 0, 0.8);
    color: white;
    text-align: center;
    padding: 2rem;
    margin-top: 3rem;
}

@media (max-width: 768px) {
    .hero h2 {
        font-size: 1.8rem;
    }
    
    .features {
        grid-template-columns: 1fr;
    }
}
```

### script.js

```javascript
function showMessage() {
    alert('Hello from S3! Your static website is working perfectly! 🎉');
}

// Smooth scroll for navigation
document.querySelectorAll('nav a').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        const href = this.getAttribute('href');
        if (href.startsWith('#')) {
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
            }
        }
    });
});

// Add loading animation
window.addEventListener('load', () => {
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 0.5s';
        document.body.style.opacity = '1';
    }, 100);
});

console.log('🚀 S3 Static Website Loaded Successfully!');
```

### error.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .error-container {
            text-align: center;
            background: white;
            padding: 3rem;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        h1 {
            font-size: 6rem;
            color: #667eea;
            margin: 0;
        }
        h2 {
            color: #333;
            margin: 1rem 0;
        }
        p {
            color: #666;
            margin: 1rem 0 2rem;
        }
        a {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 2rem;
            text-decoration: none;
            border-radius: 5px;
            display: inline-block;
            transition: transform 0.3s;
        }
        a:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>404</h1>
        <h2>Page Not Found</h2>
        <p>Sorry, the page you're looking for doesn't exist.</p>
        <a href="/">Go Back Home</a>
    </div>
</body>
</html>
```

## Terraform Configuration

```hcl
# S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = "my-website.example.com"

  tags = {
    Name        = "Static Website"
    Environment = "Production"
  }
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  # Optional: Routing rules for redirects
  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# Public Access Block (allow public access)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy for Public Read
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Upload files
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "website/index.html"
  content_type = "text/html"
  etag         = filemd5("website/index.html")
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  source       = "website/error.html"
  content_type = "text/html"
  etag         = filemd5("website/error.html")
}

resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.website.id
  key          = "styles.css"
  source       = "website/styles.css"
  content_type = "text/css"
  etag         = filemd5("website/styles.css")
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.website.id
  key          = "script.js"
  source       = "website/script.js"
  content_type = "application/javascript"
  etag         = filemd5("website/script.js")
}

# Output website endpoint
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}
```

## Custom Domain with Route 53

### 1. Create Route 53 Hosted Zone

```bash
# Create hosted zone
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference $(date +%s)

# Note the hosted zone ID from output
```

### 2. Create Alias Record

```bash
cat > route53-record.json << 'EOF'
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "www.example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z3AQBSTGFYJSTF",
          "DNSName": "s3-website-us-east-1.amazonaws.com",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOF

# Apply record
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://route53-record.json
```

### Terraform Route 53 Configuration

```hcl
# Route 53 Hosted Zone
data "aws_route53_zone" "main" {
  name = "example.com"
}

# Alias Record for Website
resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.website.website_domain
    zone_id                = aws_s3_bucket.website.hosted_zone_id
    evaluate_target_health = false
  }
}
```

## HTTPS with CloudFront

### 1. Request SSL Certificate (ACM)

```bash
# Must be in us-east-1 for CloudFront
aws acm request-certificate \
  --domain-name www.example.com \
  --subject-alternative-names example.com \
  --validation-method DNS \
  --region us-east-1

# Follow email/DNS validation process
```

### 2. Create CloudFront Distribution

```hcl
# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${aws_s3_bucket.website.bucket}"
}

# Update S3 Bucket Policy
resource "aws_s3_bucket_policy" "website_cloudfront" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.website.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# ACM Certificate
data "aws_acm_certificate" "website" {
  domain   = "www.example.com"
  statuses = ["ISSUED"]
  provider = aws.us_east_1  # CloudFront requires us-east-1
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["www.example.com", "example.com"]

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.website.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.website.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "Website CDN"
  }
}

# Route 53 CloudFront Alias
resource "aws_route53_record" "website_cloudfront" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.website.domain_name
}
```

## Deployment Script

```bash
#!/bin/bash

# deploy.sh - Deploy static website to S3

set -e

BUCKET_NAME="my-website.example.com"
WEBSITE_DIR="./website"
REGION="us-east-1"

echo "🚀 Deploying website to S3..."

# Sync files
echo "📤 Uploading files..."
aws s3 sync $WEBSITE_DIR s3://$BUCKET_NAME/ \
  --delete \
  --cache-control "max-age=3600" \
  --region $REGION

# Set specific cache controls
echo "⚙️  Setting cache controls..."
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
  --recursive \
  --exclude "*" \
  --include "*.html" \
  --cache-control "max-age=300, must-revalidate" \
  --metadata-directive REPLACE

aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
  --recursive \
  --exclude "*" \
  --include "*.css" \
  --include "*.js" \
  --cache-control "max-age=31536000, immutable" \
  --metadata-directive REPLACE

# Invalidate CloudFront cache (if using CloudFront)
if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo "🔄 Invalidating CloudFront cache..."
  aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
    --paths "/*"
fi

echo "✅ Deployment complete!"
echo "🌐 Website: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
```

## Best Practices

```yaml
Performance:
  - Enable CloudFront CDN
  - Compress files (gzip)
  - Optimize images
  - Minify CSS/JS
  - Set proper cache headers
  - Use lazy loading

Security:
  - Use HTTPS (CloudFront + ACM)
  - Enable CloudFront WAF
  - Restrict bucket to CloudFront OAI
  - Enable access logging
  - Use security headers

Cost Optimization:
  - Enable S3 lifecycle policies
  - Use CloudFront to reduce S3 requests
  - Compress static assets
  - Monitor CloudWatch metrics
  - Clean up old versions

SEO:
  - Use semantic HTML
  - Add meta tags
  - Create sitemap.xml
  - Add robots.txt
  - Use descriptive URLs
```

## Additional Resources

- [S3 Main README](readme.md)
- [S3 Bucket Policies](s3-bucket-policies.md)
- [AWS S3 Website Hosting Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
