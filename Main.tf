terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
}

locals {
  tags = merge(
    {
      Module = "aws_guardduty_s3_malware"
    },
    var.tags
  )
}

# ----------------------------
# 1. Create GuardDuty Detector
# ----------------------------
resource "aws_guardduty_detector" "this" {
  enable                      = true
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.enable_s3_logs
    }

    malware_protection {
      # Enables scanning of S3 objects for malware
      service_role {
        enable = var.enable_s3_malware_protection
      }
    }
  }

  tags = local.tags
}

# -------------------------------------
# 2. Organization-wide GuardDuty setup
# -------------------------------------
resource "aws_guardduty_organization_admin_account" "this" {
  count                            = var.org_enable ? 1 : 0
  admin_account_id                 = var.org_admin_account_id
  auto_enable_organization_members = var.org_auto_enable_members
}

resource "aws_guardduty_organization_configuration" "this" {
  count       = var.org_enable ? 1 : 0
  detector_id = aws_guardduty_detector.this.id
  auto_enable = var.org_auto_enable_members

  datasources {
    s3_logs {
      auto_enable = var.enable_s3_logs
    }

    malware_protection {
      service_role {
        auto_enable = var.enable_s3_malware_protection
      }
    }
  }

  depends_on = [aws_guardduty_organization_admin_account.this]
}


variables.tf
variable "finding_publishing_frequency" {
  description = "How often GuardDuty findings are published. Valid values: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "enable_s3_logs" {
  description = "Enable S3 data event protection"
  type        = bool
  default     = true
}

variable "enable_s3_malware_protection" {
  description = "Enable S3 malware scanning"
  type        = bool
  default     = true
}

variable "org_enable" {
  description = "Enable org-wide GuardDuty (set to true in delegated admin account)"
  type        = bool
  default     = true
}

variable "org_admin_account_id" {
  description = "Delegated admin account ID for GuardDuty"
  type        = string
  default     = ""
}

variable "org_auto_enable_members" {
  description = "Automatically enable GuardDuty for new org accounts"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

outputs.tf

output "detector_id" {
  description = "GuardDuty Detector ID"
  value       = aws_guardduty_detector.this.id
}

output "s3_malware_protection_status" {
  description = "Shows if S3 Malware Protection is enabled"
  value       = var.enable_s3_malware_protection ? "ENABLED" : "DISABLED"
}

output "organization_auto_enable" {
  description = "Shows if org auto enable is turned on"
  value       = var.org_auto_enable_members ? "TRUE" : "FALSE"
}

call module

---

# 🧠 PART 2 — MODULE CALL  
📁 Example path:  
`terraform/XENIAL/xen/engineering/us-east-1/guardduty_s3/dev/main.tf`

---

### **main.tf**
```hcl
module "guardduty_s3_malware" {
  source = "../../../../../../modules/aws_guardduty_s3_malware"

  finding_publishing_frequency  = "FIFTEEN_MINUTES"
  enable_s3_logs                = true
  enable_s3_malware_protection  = true

  org_enable                   = true
  org_admin_account_id         = "123456789012"   # Replace with your delegated admin account
  org_auto_enable_members      = true

  tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = "SecurityTeam"
  }
}


variable.tf

variable "project" {
  type        = string
  description = "Project name"
  default     = "GeniusRestaurant"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
  default     = "dev"
}

outputs.tf

output "guardduty_detector_id" {
  value = module.guardduty_s3_malware.detector_id
}

output "s3_malware_status" {
  value = module.guardduty_s3_malware.s3_malware_protection_status
}

output "auto_enable_status" {
  value = module.guardduty_s3_malware.organization_auto_enable
}
