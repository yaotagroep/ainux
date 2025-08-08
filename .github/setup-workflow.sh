#!/bin/bash

# GitHub Issue Workflow Setup Script
# This script helps set up and test the GitHub issue workflow system

set -e

echo "🚀 Ainux OS - GitHub Issue Workflow Setup"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -d ".github" ]]; then
    print_error "This script must be run from the repository root directory."
    exit 1
fi

print_status "Validating workflow files..."

# Check if all required files exist
required_files=(
    ".github/ISSUE_TEMPLATE/bug_report.yml"
    ".github/ISSUE_TEMPLATE/feature_request.yml"
    ".github/ISSUE_TEMPLATE/hardware_support.yml"
    ".github/ISSUE_TEMPLATE/documentation.yml"
    ".github/ISSUE_TEMPLATE/config.yml"
    ".github/PULL_REQUEST_TEMPLATE.md"
    ".github/workflows/issue-management.yml"
    ".github/workflows/label-management.yml"
    ".github/workflows/stale.yml"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        missing_files+=("$file")
    fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
    print_error "Missing required files:"
    for file in "${missing_files[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

print_success "All required files are present."

# Validate YAML syntax
print_status "Validating YAML syntax..."

yaml_files=(
    ".github/ISSUE_TEMPLATE/bug_report.yml"
    ".github/ISSUE_TEMPLATE/feature_request.yml"
    ".github/ISSUE_TEMPLATE/hardware_support.yml"
    ".github/ISSUE_TEMPLATE/documentation.yml"
    ".github/ISSUE_TEMPLATE/config.yml"
    ".github/workflows/issue-management.yml"
    ".github/workflows/label-management.yml"
    ".github/workflows/stale.yml"
)

# Check if python3 and pyyaml are available
if ! command -v python3 &> /dev/null; then
    print_warning "Python3 not found. Skipping YAML validation."
else
    if python3 -c "import yaml" 2>/dev/null; then
        for file in "${yaml_files[@]}"; do
            if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                print_success "✅ $file: Valid YAML"
            else
                print_error "❌ $file: Invalid YAML"
                exit 1
            fi
        done
    else
        print_warning "PyYAML not installed. Skipping YAML validation."
        print_status "Install with: pip install pyyaml"
    fi
fi

# Check git status
print_status "Checking git status..."
if git diff --quiet && git diff --staged --quiet; then
    print_success "Working directory is clean."
else
    print_warning "There are uncommitted changes."
    git status --short
fi

# Display summary
echo ""
print_success "🎉 GitHub Issue Workflow Setup Complete!"
echo ""
echo "📋 What's included:"
echo "  • 4 Issue templates (Bug, Feature, Hardware, Documentation)"
echo "  • 1 Pull Request template"  
echo "  • 3 Automated workflows (Management, Labels, Stale)"
echo "  • Comprehensive label system"
echo "  • Documentation (ISSUE_WORKFLOW.md)"
echo ""
echo "🔧 Next steps:"
echo "  1. Commit and push these changes to enable the workflows"
echo "  2. The workflows will automatically run when issues/PRs are created"
echo "  3. Manually trigger 'Label Management' workflow to create all labels"
echo "  4. Review and customize the workflows as needed"
echo ""
echo "📚 Documentation: .github/ISSUE_WORKFLOW.md"
echo ""
print_status "Happy issue management! 🚀"