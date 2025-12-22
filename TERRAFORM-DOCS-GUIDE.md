# Terraform Documentation Guide

## Overview

This project uses **terraform-docs** to automatically generate comprehensive documentation from Terraform code. The documentation is automatically extracted from:
- Resource definitions
- Variable declarations and descriptions
- Output definitions
- Provider requirements

## Installation

### macOS
```bash
brew install terraform-docs
```

### Linux
```bash
# Download latest version
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/latest/terraform-docs-latest-$(uname)-amd64.tar.gz

# Extract and install
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/

# Verify installation
terraform-docs --version
```

### Windows (Chocolatey)
```bash
choco install terraform-docs
```

### Windows (Manual)
1. Download from: https://github.com/terraform-docs/terraform-docs/releases
2. Extract the executable
3. Add to PATH

## Quick Start

### Generate All Documentation
Simply run the provided script:
```bash
./generate-docs.sh
```

This will generate:
- `DOCS.md` - Root module documentation
- `modules/networking/DOCS.md` - Networking module docs
- `modules/security/DOCS.md` - Security module docs
- `modules/alb/DOCS.md` - ALB module docs
- `modules/compute/DOCS.md` - Compute module docs
- `modules/database/DOCS.md` - Database module docs

### Manual Generation

**Root module:**
```bash
terraform-docs markdown table --output-file DOCS.md --output-mode inject .
```

**Specific module:**
```bash
terraform-docs markdown table --output-file DOCS.md --output-mode inject ./modules/networking
```

## Configuration

The `.terraform-docs.yml` file controls the documentation format:

```yaml
formatter: "markdown table"  # Output format
output:
  file: "DOCS.md"           # Output filename
  mode: inject              # Inject between BEGIN/END markers
sort:
  enabled: true             # Sort tables alphabetically
  by: name
```

## Documentation Markers

The DOCS.md files use special markers to indicate where terraform-docs should inject content:

```markdown
<!-- BEGIN_TF_DOCS -->
# Auto-generated content goes here
<!-- END_TF_DOCS -->
```

**⚠️ Important**: Do NOT edit content between these markers manually - it will be overwritten!

## What Gets Documented

### Requirements
Terraform and provider version constraints:
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### Resources
All AWS resources created by the module:
- `aws_vpc.main`
- `aws_subnet.public`
- etc.

### Inputs (Variables)
All input variables with:
- Description
- Type
- Default value
- Required/Optional status

### Outputs
All output values with descriptions

## Best Practices

### 1. Add Descriptions to Variables
```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"  # ← This appears in docs!
  type        = string
  default     = "10.0.0.0/16"
}
```

### 2. Add Descriptions to Outputs
```hcl
output "vpc_id" {
  description = "ID of the VPC"  # ← This appears in docs!
  value       = aws_vpc.main.id
}
```

### 3. Keep Descriptions Clear and Concise
- ✅ Good: "CIDR block for VPC"
- ❌ Bad: "cidr"
- ❌ Bad: "This is the CIDR block that will be used for creating the VPC resource in AWS..."

### 4. Update Documentation After Changes
Whenever you modify Terraform code, regenerate docs:
```bash
./generate-docs.sh
```

### 5. Commit Documentation with Code
```bash
git add .
git commit -m "Update infrastructure and documentation"
git push
```

## Advanced Usage

### Generate Different Formats

**Markdown document:**
```bash
terraform-docs markdown document . > README.md
```

**JSON:**
```bash
terraform-docs json . > terraform.json
```

**YAML:**
```bash
terraform-docs yaml . > terraform.yaml
```

### Include/Exclude Sections
Edit `.terraform-docs.yml`:
```yaml
sections:
  show:
    - requirements
    - providers
    - inputs
    - outputs
  hide:
    - modules
    - resources
```

### Custom Output Template
```bash
terraform-docs markdown table \
  --header-from header.md \
  --footer-from footer.md \
  --output-file DOCS.md \
  --output-mode inject .
```

## Troubleshooting

### terraform-docs not found
**Solution**: Install terraform-docs (see Installation section above)

### Documentation not updating
**Solution**: Ensure you're using `--output-mode inject` and the markers are present

### Changes not showing
**Solution**: 
1. Check if you modified the right files (variables.tf, outputs.tf)
2. Run the script again
3. Look for error messages

### Formatting issues
**Solution**: 
1. Check `.terraform-docs.yml` syntax
2. Ensure all variables have descriptions
3. Verify HCL syntax is valid

## File Structure

```
3-tier-app/
├── .terraform-docs.yml          # Configuration for terraform-docs
├── generate-docs.sh             # Script to generate all docs
├── DOCS.md                      # Root module documentation
├── main.tf                      # Root module resources
├── variables.tf                 # Root module variables
├── outputs.tf                   # Root module outputs
└── modules/
    ├── networking/
    │   ├── DOCS.md              # Networking module docs
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/
    │   ├── DOCS.md              # Security module docs
    │   └── ...
    └── ...
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Generate Terraform Docs

on:
  pull_request:
    paths:
      - '**.tf'

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Generate terraform docs
        uses: terraform-docs/gh-actions@v1.0.0
        with:
          working-dir: .
          output-file: DOCS.md
          output-method: inject
          
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add DOCS.md modules/*/DOCS.md
          git commit -m "Update terraform docs" || echo "No changes"
          git push
```

### Pre-commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/sh
./generate-docs.sh
git add DOCS.md modules/*/DOCS.md
```

## Resources

- **Official Documentation**: https://terraform-docs.io/
- **GitHub Repository**: https://github.com/terraform-docs/terraform-docs
- **Configuration Reference**: https://terraform-docs.io/user-guide/configuration/

## Common Commands Reference

```bash
# Generate all module docs
./generate-docs.sh

# Generate root module only
terraform-docs markdown table --output-file DOCS.md --output-mode inject .

# Generate specific module
terraform-docs markdown table --output-file DOCS.md --output-mode inject ./modules/networking

# View without saving
terraform-docs markdown table .

# Generate with specific config
terraform-docs -c .terraform-docs.yml .

# Check version
terraform-docs --version

# Get help
terraform-docs --help
```

## Tips

1. **Always run after modifying variables** - Keep docs in sync with code
2. **Review generated docs** - Ensure descriptions are clear
3. **Link modules in root docs** - Help users navigate (already done in DOCS.md)
4. **Use consistent naming** - All module docs named DOCS.md
5. **Automate in CI/CD** - Never forget to update docs
6. **Add usage examples** - Show how to use modules (already done)
7. **Include diagrams** - Visual aids help understanding (already done)

---

**Need Help?**
- Check the official docs: https://terraform-docs.io/
- Open an issue in the repository
- Review the examples in this project's DOCS.md files
