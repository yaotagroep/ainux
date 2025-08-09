#!/bin/bash
# Quick validation script for CI environments
# This checks that the build environment is properly set up for Ainux OS building

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "🔍 Ainux OS Build Environment Validation"
echo "========================================"

# Check 1: Environment Detection
if [[ "${CI:-false}" == "true" ]] || [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    log_success "✅ CI environment detected"
else
    log_warning "⚠️  CI environment not detected - optimizations may not apply"
fi

# Check 2: Disk Space
available_space=$(df . | awk 'NR==2 {print int($4/1024/1024)}')
log_info "Available disk space: ${available_space}GB"

if [[ $available_space -ge 30 ]]; then
    log_success "✅ Sufficient disk space available"
elif [[ $available_space -ge 20 ]]; then
    log_warning "⚠️  Limited disk space (${available_space}GB) - may work with optimizations"
else
    log_error "❌ Insufficient disk space (${available_space}GB < 20GB minimum)"
    exit 1
fi

# Check 3: Required Tools
required_tools=("wget" "curl" "tar" "make" "gcc" "sudo")
missing_tools=()

for tool in "${required_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        log_success "✅ $tool available"
    else
        missing_tools+=("$tool")
        log_error "❌ $tool missing"
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    log_error "Missing required tools: ${missing_tools[*]}"
    exit 1
fi

# Check 4: Network Connectivity
log_info "Testing network connectivity..."

# Test kernel.org (primary source)
if curl -s --connect-timeout 10 --head "https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.6.58.tar.xz" | head -n 1 | grep -q "200"; then
    log_success "✅ Kernel source accessible (kernel.org)"
else
    log_warning "⚠️  Primary kernel source not accessible"
    
    # Test GitHub fallback
    if curl -s --connect-timeout 10 --head "https://github.com/torvalds/linux/archive/refs/tags/v6.6.58.tar.gz" | head -n 1 | grep -q "200"; then
        log_success "✅ Fallback kernel source accessible (GitHub)"
    else
        log_error "❌ No kernel sources accessible"
        exit 1
    fi
fi

# Test Ubuntu repositories
if curl -s --connect-timeout 10 http://archive.ubuntu.com >/dev/null 2>&1; then
    log_success "✅ Ubuntu repositories accessible"
else
    log_warning "⚠️  Ubuntu repositories may be slow"
fi

# Check 5: Memory and CPU
total_memory=$(free -m | awk 'NR==2{print $2}')
cpu_cores=$(nproc)

log_info "System resources:"
log_info "  Memory: ${total_memory}MB"
log_info "  CPU cores: ${cpu_cores}"

if [[ $total_memory -ge 8000 ]]; then
    log_success "✅ Sufficient memory available"
elif [[ $total_memory -ge 4000 ]]; then
    log_warning "⚠️  Limited memory (${total_memory}MB) - build may be slower"
else
    log_warning "⚠️  Very limited memory (${total_memory}MB) - build may fail"
fi

if [[ $cpu_cores -ge 2 ]]; then
    log_success "✅ Sufficient CPU cores available"
else
    log_warning "⚠️  Limited CPU cores - build will be slow"
fi

# Check 6: Build Script Validation
if [[ -f "ainux-builder.sh" ]]; then
    log_success "✅ Build script found"
    
    # Syntax check
    if bash -n ainux-builder.sh; then
        log_success "✅ Build script syntax valid"
    else
        log_error "❌ Build script has syntax errors"
        exit 1
    fi
    
    # Check for optimizations
    if grep -q "CI.*true" ainux-builder.sh && grep -q "timeout.*debootstrap" ainux-builder.sh; then
        log_success "✅ CI optimizations present in build script"
    else
        log_warning "⚠️  CI optimizations may not be present"
    fi
else
    log_error "❌ Build script not found"
    exit 1
fi

# Check 7: Patches Directory
if [[ -d "patches" ]]; then
    patch_count=$(find patches -name "*.patch" | wc -l)
    log_success "✅ Patches directory found ($patch_count patches)"
else
    log_warning "⚠️  Patches directory not found - will use fallback patches"
fi

echo
echo "📊 Validation Summary:"
echo "====================="
echo "Environment: $([ "${CI:-false}" == "true" ] && echo "CI" || echo "Local")"
echo "Disk Space: ${available_space}GB"
echo "Memory: ${total_memory}MB"
echo "CPU Cores: ${cpu_cores}"
echo "Network: $(curl -s --connect-timeout 5 https://www.kernel.org >/dev/null 2>&1 && echo "Good" || echo "Limited")"

echo
echo "💡 Recommended Build Command:"
echo "============================="
if [[ "${CI:-false}" == "true" ]]; then
    echo "# For CI environment:"
    echo "export CI=true"
    echo "export GITHUB_ACTIONS=true"
    echo "export BUILD_THREADS=2"
    echo "export SKIP_QEMU_TEST=true"
    echo "./ainux-builder.sh --mode main --gui"
else
    echo "# For local environment:"
    echo "./ainux-builder.sh --mode main --gui"
fi

echo
log_success "🎉 Build environment validation completed!"
log_info "The build should now proceed without timeout issues."