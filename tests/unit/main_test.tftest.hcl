# Unit Tests for tf-molecule-acm-dns-validated-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:         terraform test -test-directory=tests/unit
# Run verbose:      terraform test -test-directory=tests/unit -verbose
# Run specific:     terraform test -test-directory=tests/unit -run "disabled_creates_nothing"
#
# NOTE on coverage: the ENABLED path cannot be exercised under `terraform test`
# with a mock provider. aws_route53_record.validation derives its `for_each`
# keys from aws_acm_certificate.this[0].domain_validation_options, which is a
# computed set (unknown until apply). Terraform rejects for_each over unknown
# keys during the PLAN phase — before a mock provider gets to populate any
# computed value — so both `command = plan` and `command = apply` fail with
# "Invalid for_each argument". This is an architectural property of the module,
# not a test defect. The enabled path is covered by the integration tests
# (tests/integration/, real AWS). Here we assert the deterministic, mock-safe
# disabled path on the module's ACTUAL outputs and resource counts.

mock_provider "aws" {}

variables {
  # tf-label context
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  # Module-specific required inputs
  domain_name = "app.example.com"
  zone_id     = "Z1234567890ABCDEFGHIJ"

  subject_alternative_names = ["www.example.com"]
}

# ---------------------------------------------------------------------------
# Test: enabled = false creates no resources and empties the outputs
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = length(aws_acm_certificate.this) == 0
    error_message = "No ACM certificate should be created when disabled"
  }

  assert {
    condition     = length(aws_acm_certificate_validation.this) == 0
    error_message = "No ACM certificate validation should be created when disabled"
  }

  assert {
    condition     = length(aws_route53_record.validation) == 0
    error_message = "No Route53 validation records should be created when disabled"
  }

  assert {
    condition     = output.certificate_arn == ""
    error_message = "certificate_arn output should be empty when disabled"
  }

  assert {
    condition     = output.domain_name == ""
    error_message = "domain_name output should be empty when disabled"
  }
}
