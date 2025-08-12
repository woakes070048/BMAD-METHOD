#!/bin/bash

# BMAD ERPNext v15 Expansion Pack Setup Script
# This script helps you quickly configure the expansion pack for your environment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE} BMAD ERPNext v15 Expansion Pack Setup${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running from correct directory
check_directory() {
    if [[ ! -f "config.yaml.example" ]]; then
        print_error "Please run this script from the bmad-erpnext-v15 directory"
        print_info "Expected files: config.yaml.example, LICENSE, README.md"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if bench is available
    if ! command -v bench &> /dev/null; then
        print_warning "bench command not found. Please make sure Frappe Bench is installed."
        print_info "Installation guide: https://frappeframework.com/docs/user/en/installation"
    else
        print_success "Frappe Bench found: $(bench --version)"
    fi
    
    # Check if we're in a bench directory or can find one
    if [[ -f "../../frappe-bench/sites/common_site_config.json" ]]; then
        BENCH_PATH="$(realpath ../../frappe-bench)"
        print_success "Found bench at: $BENCH_PATH"
    elif [[ -f "../../../frappe-bench/sites/common_site_config.json" ]]; then
        BENCH_PATH="$(realpath ../../../frappe-bench)"
        print_success "Found bench at: $BENCH_PATH"
    elif [[ -f "sites/common_site_config.json" ]]; then
        BENCH_PATH="$(pwd)"
        print_success "Found bench at: $BENCH_PATH"
    else
        print_warning "Could not auto-detect bench path. You'll need to configure it manually."
        BENCH_PATH="/home/frappe/frappe-bench"
    fi
    
    # Check if Claude Code is available
    if command -v claude &> /dev/null; then
        print_success "Claude Code found"
    else
        print_warning "Claude Code not found. Please install Claude Code to use this expansion pack."
        print_info "Installation guide: https://docs.anthropic.com/en/docs/claude-code"
    fi
}

# Create config.yaml from example
create_config() {
    print_info "Setting up configuration..."
    
    if [[ -f "config.yaml" ]]; then
        print_warning "config.yaml already exists."
        read -p "Do you want to backup and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv config.yaml "config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
            print_info "Backed up existing config.yaml"
        else
            print_info "Keeping existing config.yaml"
            return 0
        fi
    fi
    
    # Copy example to config.yaml
    cp config.yaml.example config.yaml
    print_success "Created config.yaml from template"
    
    # Auto-configure some settings if we detected them
    if [[ -n "$BENCH_PATH" ]]; then
        # Update bench path in config
        if command -v sed &> /dev/null; then
            sed -i.bak "s|bench_path: \"/home/frappe/frappe-bench\"|bench_path: \"$BENCH_PATH\"|g" config.yaml
            print_success "Updated bench_path to: $BENCH_PATH"
        fi
        
        # Try to detect site name
        if [[ -d "$BENCH_PATH/sites" ]]; then
            SITES=($(find "$BENCH_PATH/sites" -maxdepth 1 -type d -name "*.com" -o -name "*.local" -o -name "*.localhost" | head -5))
            if [[ ${#SITES[@]} -gt 0 ]]; then
                SITE_NAME=$(basename "${SITES[0]}")
                if [[ "$SITE_NAME" != "common_site_config.json" ]]; then
                    sed -i.bak "s|primary_site: \"your-site-name.com\"|primary_site: \"$SITE_NAME\"|g" config.yaml
                    print_success "Updated primary_site to: $SITE_NAME"
                fi
            fi
        fi
    fi
    
    # Update development directory
    CURRENT_DIR=$(pwd)
    sed -i.bak "s|development_directory: \"/home/frappe/your-development-directory\"|development_directory: \"$CURRENT_DIR\"|g" config.yaml
    print_success "Updated development_directory to: $CURRENT_DIR"
    
    # Clean up backup file
    rm -f config.yaml.bak
}

# Detect existing apps
detect_apps() {
    if [[ -n "$BENCH_PATH" && -f "$BENCH_PATH/sites/apps.txt" ]]; then
        print_info "Detecting installed apps..."
        
        # Read apps and update config
        APPS=$(grep -v "^frappe$\|^erpnext$" "$BENCH_PATH/sites/apps.txt" 2>/dev/null || true)
        
        if [[ -n "$APPS" ]]; then
            print_info "Found additional apps:"
            echo "$APPS" | while read app; do
                if [[ -n "$app" ]]; then
                    print_info "  - $app"
                fi
            done
            print_warning "Please manually add these apps to the existing_apps section in config.yaml"
        fi
    fi
}

# Test configuration
test_config() {
    print_info "Testing configuration..."
    
    # Check if Claude Code can load the expansion pack
    if command -v claude &> /dev/null; then
        print_info "Testing expansion pack loading with Claude Code..."
        # This would require Claude Code to be running, so just show the command
        print_info "To test, run: claude"
        print_info "Then use: *expansion-pack bmad-erpnext-v15*"
    fi
    
    # Validate YAML syntax if possible
    if command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('config.yaml'))" 2>/dev/null && \
        print_success "config.yaml syntax is valid" || \
        print_warning "config.yaml syntax may have issues"
    fi
}

# Show next steps
show_next_steps() {
    print_header
    print_success "Setup completed successfully!"
    echo
    print_info "Next Steps:"
    echo "1. Review and customize config.yaml for your specific environment"
    echo "2. Start Claude Code: claude"
    echo "3. Load the expansion pack: *expansion-pack bmad-erpnext-v15*"
    echo "4. Try your first agent team: *agent-team modern-app-team*"
    echo
    print_info "Quick Start Examples:"
    echo "• Modern App: *agent vue-spa-architect* \"Create a customer portal\""
    echo "• Automation: *agent-team automation-team* \"Automate approval workflows\""
    echo "• Migration: *agent-team airtable-migration-team* \"Migrate CRM data\""
    echo
    print_info "Documentation:"
    echo "• README.md - Complete feature overview"
    echo "• QUICKSTART.md - 5-minute quick start guide"
    echo "• TROUBLESHOOTING.md - Common issues and solutions"
    echo
    print_info "Need help? Check the troubleshooting guide or visit:"
    echo "https://github.com/bmad-code-org/BMAD-METHOD"
}

# Main execution
main() {
    print_header
    
    check_directory
    check_prerequisites
    create_config
    detect_apps
    test_config
    show_next_steps
}

# Run main function
main "$@"