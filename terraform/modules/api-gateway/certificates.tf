resource "tls_private_key" "self_signed" {
  count     = var.acm_certificate_arn == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "self_signed" {
  count           = var.acm_certificate_arn == "" ? 1 : 0
  private_key_pem = tls_private_key.self_signed[0].private_key_pem

  subject {
    common_name  = "prop-agent-${var.environment}.local"
    organization = "Property Management Agent"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "imported_self_signed" {
  count            = var.acm_certificate_arn == "" ? 1 : 0
  private_key      = tls_private_key.self_signed[0].private_key_pem
  certificate_body = tls_self_signed_cert.self_signed[0].cert_pem

  tags = merge(
    var.tags,
    {
      Name        = "prop-agent-${var.environment}-self-signed-cert"
      Environment = var.environment
    }
  )
}

locals {
  certificate_arn = var.acm_certificate_arn != "" ? var.acm_certificate_arn : aws_acm_certificate.imported_self_signed[0].arn
}
