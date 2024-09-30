resource "aws_route53_record" "myRecord" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "wp-abdullah"
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.wordpress_lb.dns_name]
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }


  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.selected.id
}
