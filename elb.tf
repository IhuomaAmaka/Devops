module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "nuvei-alb"

  load_balancer_type = "application"

  vpc_id          = aws_vpc.prodvpc.id
  subnets         = [aws_subnet.prodpublic_1.id, aws_subnet.prod-public.id]
  security_groups = [aws_security_group.allow_tls.id]

  access_logs = {
    bucket  = "loggingbyamaka.com"
    prefix  = "elb-bucket"
    enabled = true
  }
  target_groups = [
    {
      name_prefix      = "prod-"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]

  /* https_listeners = [
    {
      port                 = 443
      protocol             = "HTTPS"
      certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      action_type          = "authenticate-cognito"
      target_group_index   = 0
      authenticate_cognito = {
        user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
        user_pool_client_id = "6oRmFiS0JHk="
        user_pool_domain    = "test-domain-com"
      }
    }
  ]
  */

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  tags = {
    Environment = "Test"
  }
}

resource "aws_s3_bucket" "elb-bucket" {
  bucket = "loggingbyamaka.com"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::127311923021:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::loggingbyamaka.com/*"
    }
  ]
}
EOF
}
