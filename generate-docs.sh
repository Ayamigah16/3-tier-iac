#!/bin/bash

# Script to generate Terraform documentation using terraform-docs
# Usage: ./generate-docs.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Terraform Documentation Generator${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo -e "${RED}❌ terraform-docs not found!${NC}"
    echo ""
    echo "Install terraform-docs:"
    echo "  • macOS:   brew install terraform-docs"
    echo "  • Linux:   https://terraform-docs.io/user-guide/installation/"
    echo "  • Windows: choco install terraform-docs"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ terraform-docs found: $(terraform-docs --version)${NC}"
echo ""

# Function to generate docs for a module
generate_docs() {
    local module_path=$1
    local module_name=$2
    
    echo -e "${YELLOW}Generating documentation for: ${module_name}${NC}"
    
    if [ -d "$module_path" ]; then
        cd "$module_path"
        terraform-docs markdown table --output-file DOCS.md --output-mode inject .
        echo -e "${GREEN}  ✓ ${module_name}/DOCS.md generated${NC}"
        cd - > /dev/null
    else
        echo -e "${RED}  ✗ Directory not found: ${module_path}${NC}"
    fi
}

# Generate root module documentation
echo -e "${YELLOW}Generating root module documentation...${NC}"
terraform-docs markdown table --output-file DOCS.md --output-mode inject .
echo -e "${GREEN}  ✓ DOCS.md generated${NC}"
echo ""

# Generate module documentation
generate_docs "./modules/networking" "networking"
generate_docs "./modules/security" "security"
generate_docs "./modules/alb" "alb"
generate_docs "./modules/compute" "compute"
generate_docs "./modules/database" "database"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Documentation Generation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Generated files:"
echo "  • DOCS.md (root module)"
echo "  • modules/networking/DOCS.md"
echo "  • modules/security/DOCS.md"
echo "  • modules/alb/DOCS.md"
echo "  • modules/compute/DOCS.md"
echo "  • modules/database/DOCS.md"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the generated documentation"
echo "  2. Commit the changes to git"
echo "  3. Documentation will auto-update with: terraform-docs markdown table --output-mode inject ."
echo ""
