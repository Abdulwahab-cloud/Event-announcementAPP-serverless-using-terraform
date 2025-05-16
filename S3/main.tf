resource "aws_s3_bucket" "website_bucket" {
  bucket = "abdulwahab-bucket"
  
 
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "Public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "website_object" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
  
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }


} 

/* resource "aws_s3_bucket_acl" "s3_acl" { 
  depends_on = [aws_s3_bucket_public_access_block.Public_access , aws_s3_bucket_ownership_controls.ownership]
  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
} */

resource "aws_s3_bucket_policy" "public_policy" {
  depends_on = [ aws_s3_bucket_public_access_block.Public_access ,
  aws_s3_bucket_ownership_controls.ownership ]
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}