module "r53_record" {
  source = "../"

  zone_name = local.zone_name
  #  zone_id   = local.zone_id   # one or the other

  records = [
    {
      name = ""
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.10",
      ]
    },
    {
      name = "s3-bucket"
      type = "A"
      alias = {
        name    = module.s3_bucket.s3_bucket_website_domain
        zone_id = module.s3_bucket.s3_bucket_hosted_zone_id
      }
    },
    {
      name           = "eu-geo"
      type           = "CNAME"
      ttl            = 5
      records        = ["europe.example.com."]
      set_identifier = "europe"
      geolocation_routing_policy = {
        continent = "EU"
      }
    },
    {
      name = "cdn"
      type = "A"
      alias = {
        name    = module.cdn.cloudfront_distribution_domain_name
        zone_id = module.cdn.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "cloudfront"
      type = "AAAA"
      alias = {
        name    = module.cdn.cloudfront_distribution_domain_name
        zone_id = module.cdn.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test.example.com."]
      set_identifier = "test-primary"
      weighted_routing_policy = {
        weight = 90
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test2.example.com."]
      set_identifier = "test-secondary"
      weighted_routing_policy = {
        weight = 10
      }
    },
    {
      name            = "failover-primary"
      type            = "A"
      set_identifier  = "failover-primary"
      health_check_id = aws_route53_health_check.failover.id
      alias = {
        name    = module.cdn.cloudfront_distribution_domain_name
        zone_id = module.cdn.cloudfront_distribution_hosted_zone_id
      }
      failover_routing_policy = {
        type = "PRIMARY"
      }
    },
    {
      name           = "failover-secondary"
      type           = "A"
      set_identifier = "failover-secondary"
      alias = {
        name    = module.s3_bucket.s3_bucket_website_domain
        zone_id = module.s3_bucket.s3_bucket_hosted_zone_id
      }
      failover_routing_policy = {
        type = "SECONDARY"
      }
    }
  ]
}
