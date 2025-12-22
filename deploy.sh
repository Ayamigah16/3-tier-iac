#!/bin/bash

# 3-Tier Architecture Deployment Helper Script
# This script helps you deploy and manage your 3-tier AWS infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Terraform
    if command -v terraform &> /dev/null; then
        TERRAFORM_VERSION=$(terraform version | head -n 1)
        print_success "Terraform installed: $TERRAFORM_VERSION"
    else
        print_error "Terraform is not installed!"
        exit 1
    fi
    
    # Check AWS CLI
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version 2>&1)
        print_success "AWS CLI installed: $AWS_VERSION"
    else
        print_error "AWS CLI is not installed!"
        exit 1
    fi
    
    # Check AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
        print_success "AWS credentials configured (Account: $AWS_ACCOUNT)"
    else
        print_error "AWS credentials not configured!"
        exit 1
    fi
}

# Initialize Terraform
init_terraform() {
    print_header "Initializing Terraform"
    terraform init
    print_success "Terraform initialized successfully"
}

# Validate configuration
validate_config() {
    print_header "Validating Configuration"
    
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found!"
        echo -e "Creating from example file..."
        cp terraform.tfvars.example terraform.tfvars
        print_warning "Please edit terraform.tfvars with your values before deploying!"
        exit 0
    fi
    
    terraform validate
    print_success "Configuration is valid"
    
    terraform fmt -check -recursive || terraform fmt -recursive
    print_success "Code formatted"
}

# Plan deployment
plan_deployment() {
    print_header "Planning Deployment"
    terraform plan -out=tfplan
    print_success "Plan created successfully"
    print_warning "Review the plan above before applying"
}

# Deploy infrastructure
deploy() {
    print_header "Deploying Infrastructure"
    
    echo -e "${YELLOW}This will create resources in AWS that will incur costs.${NC}"
    read -p "Are you sure you want to proceed? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_warning "Deployment cancelled"
        exit 0
    fi
    
    terraform apply tfplan
    print_success "Infrastructure deployed successfully!"
    
    # Show outputs
    print_header "Deployment Outputs"
    terraform output
    
    # Get ALB URL
    echo ""
    print_success "Application URL:"
    terraform output alb_dns_name
}

# Test deployment
test_deployment() {
    print_header "Testing Deployment"
    
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null | sed 's/http:\/\///')
    
    if [ -z "$ALB_DNS" ]; then
        print_error "Could not get ALB DNS name. Is the infrastructure deployed?"
        exit 1
    fi
    
    echo "Testing ALB connectivity..."
    
    # Wait for ALB to be ready
    echo "Waiting for ALB to be ready (this may take a few minutes)..."
    for i in {1..30}; do
        if curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS" | grep -q "200"; then
            print_success "ALB is responding!"
            break
        fi
        echo -n "."
        sleep 10
    done
    
    # Test HTTP response
    echo -e "\nTesting HTTP response:"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS")
    
    if [ "$HTTP_CODE" == "200" ]; then
        print_success "HTTP test passed (Status: $HTTP_CODE)"
    else
        print_error "HTTP test failed (Status: $HTTP_CODE)"
    fi
    
    # Test ping (if ICMP is enabled)
    echo -e "\nTesting ICMP (ping):"
    if ping -c 4 "$ALB_DNS" > /dev/null 2>&1; then
        print_success "ICMP test passed"
    else
        print_warning "ICMP test failed (this is OK if ICMP is not enabled in security groups)"
    fi
    
    echo ""
    print_success "Access your application at: http://$ALB_DNS"
}

# Show status
show_status() {
    print_header "Infrastructure Status"
    
    echo "VPC:"
    terraform output vpc_id
    
    echo -e "\nSubnets:"
    echo "  Public: $(terraform output -json public_subnet_ids | jq -r '. | length') subnets"
    echo "  Private App: $(terraform output -json private_app_subnet_ids | jq -r '. | length') subnets"
    echo "  Private DB: $(terraform output -json private_db_subnet_ids | jq -r '. | length') subnets"
    
    echo -e "\nCompute:"
    echo "  ASG: $(terraform output asg_name)"
    
    echo -e "\nLoad Balancer:"
    terraform output alb_dns_name
    
    echo -e "\nDatabase:"
    terraform output rds_endpoint
}

# Destroy infrastructure
destroy() {
    print_header "Destroying Infrastructure"
    
    echo -e "${RED}WARNING: This will destroy all resources!${NC}"
    echo -e "${RED}This action cannot be undone!${NC}"
    read -p "Type 'destroy' to confirm: " confirm
    
    if [ "$confirm" != "destroy" ]; then
        print_warning "Destruction cancelled"
        exit 0
    fi
    
    terraform destroy
    print_success "Infrastructure destroyed"
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}3-Tier AWS Architecture Manager${NC}"
    echo "=================================="
    echo "1. Check Prerequisites"
    echo "2. Initialize Terraform"
    echo "3. Validate Configuration"
    echo "4. Plan Deployment"
    echo "5. Deploy Infrastructure"
    echo "6. Test Deployment"
    echo "7. Show Status"
    echo "8. Destroy Infrastructure"
    echo "9. Exit"
    echo ""
}

# Main script
main() {
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            read -p "Select an option (1-9): " choice
            
            case $choice in
                1) check_prerequisites ;;
                2) init_terraform ;;
                3) validate_config ;;
                4) plan_deployment ;;
                5) deploy ;;
                6) test_deployment ;;
                7) show_status ;;
                8) destroy ;;
                9) exit 0 ;;
                *) print_error "Invalid option" ;;
            esac
            
            read -p "Press Enter to continue..."
        done
    else
        # Command line mode
        case $1 in
            check) check_prerequisites ;;
            init) init_terraform ;;
            validate) validate_config ;;
            plan) plan_deployment ;;
            deploy) deploy ;;
            test) test_deployment ;;
            status) show_status ;;
            destroy) destroy ;;
            *)
                echo "Usage: $0 {check|init|validate|plan|deploy|test|status|destroy}"
                exit 1
                ;;
        esac
    fi
}

# Run main function
main "$@"
