# OAC for CloudFront -> S3
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "frontend-oac"
  description                       = "OAC for private S3 bucket"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"
}

resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "s3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
  target_origin_id       = "s3-frontend"
  viewer_protocol_policy = "redirect-to-https"

  allowed_methods  = ["GET", "HEAD"]
  cached_methods   = ["GET", "HEAD"]

  cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"  
}

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}

# S3 Bucket Policy: allow CloudFront OAC to read files
data "aws_iam_policy_document" "oac_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend_cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.oac_policy.json
}
