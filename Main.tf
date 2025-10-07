module "guardduty_s3" {
  source = "../../../../../../modules/aws_guardduty_s3"

  finding_publishing_frequency = "FIFTEEN_MINUTES"
  enable_s3_logs               = true
  org_enable                   = false  # true if running from org admin account
  tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = "SecurityTeam"
  }
}
