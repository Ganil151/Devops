# Changelog - Terraform Boilerplate Consolidation

All notable changes to the Terraform boilerplate repository will be documented in this file.

## [1.0.0] - 2026-01-24

### Added
- **AWS Golden Foundation**: Created a production-grade modular VPC/EC2/SG boilerplate.
- **Multi-AZ Support**: Added support for distributing subnets across multiple availability zones.
- **Modular Design**: Separated concerns into `vpc` and `sg` modules for better reusability.
- **Professional Tagging**: Implemented a mandatory tagging strategy for all resources.

### Fixed
- **Redundancy Cleanup**: Consolidated numerous disparate `main.tf` and `variables.tf` files from various sub-directories into this unified standard.
- **Provider Pinning**: Explicitly defined required providers and versions to prevent environment drift.

### Removed
- **Obsolete Templates**: Removed legacy, non-modular Terraform scripts that provided similar but less robust functionality.
- **Empty Placeholders**: Cleared out "hollow" Terraform directories and replaced them with this reference architecture.

---
### Audit Context
This consolidation was executed as part of the Repository Sanitization Audit to move the curriculum from "Disconnected Snippets" to "Professional Engineering Patterns."
