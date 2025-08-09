#!/bin/bash
# Ainux OS Hardware Detection and Validation Script v5.0
# Comprehensive hardware acceleration detection with quantum-level accuracy

set -euo pipefail

# Color definitions for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Hardware detection functions
detect_cpu_acceleration() {
    log_header "CPU Acceleration Detection"
    
    local cpu_support=false
    
    # Detect CPU architecture
    local arch=$(uname -m)
    log_info "Architecture detected: $arch"
    
    case "$arch" in
        x86_64)
            log_success "✅ x86_64 CPU architecture detected"
            
            # Check for Intel CPU features
            if grep -q "vendor_id.*Intel" /proc/cpuinfo; then
                log_success "✅ Intel CPU detected"
                
                # Check for AVX support
                if grep -q "avx" /proc/cpuinfo; then
                    log_success "✅ AVX instructions supported"
                fi
                
                if grep -q "avx2" /proc/cpuinfo; then
                    log_success "✅ AVX2 instructions supported"
                fi
                
                if grep -q "avx512" /proc/cpuinfo; then
                    log_success "✅ AVX-512 instructions supported"
                fi
            fi
            
            # Check for AMD CPU features
            if grep -q "vendor_id.*AMD" /proc/cpuinfo; then
                log_success "✅ AMD CPU detected"
                
                if grep -q "avx" /proc/cpuinfo; then
                    log_success "✅ AVX instructions supported"
                fi
            fi
            
            cpu_support=true
            ;;
        aarch64|arm64)
            log_success "✅ ARM64 CPU architecture detected"
            
            # Check for ARM-specific features
            if grep -q "neon" /proc/cpuinfo; then
                log_success "✅ ARM NEON SIMD instructions supported"
            fi
            
            cpu_support=true
            ;;
        *)
            log_warn "⚠️  Unsupported CPU architecture: $arch"
            ;;
    esac
    
    # Check number of CPU cores
    local cores=$(nproc)
    log_info "CPU cores available: $cores"
    
    if [[ $cores -ge 4 ]]; then
        log_success "✅ Sufficient CPU cores for parallel processing"
    else
        log_warn "⚠️  Limited CPU cores - performance may be reduced"
    fi
    
    export CPU_ACCELERATION_SUPPORT=$cpu_support
    return $($cpu_support && echo 0 || echo 1)
}

detect_gpu_support() {
    log_header "GPU Acceleration Detection"
    
    local gpu_found=false
    
    # NVIDIA GPU Detection
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        log_success "✅ NVIDIA GPU detected"
        lspci | grep -i nvidia | while read line; do
            log_info "  📱 $line"
        done
        
        # Check for NVIDIA driver
        if command -v nvidia-smi >/dev/null 2>&1; then
            log_success "✅ NVIDIA driver available"
            export NVIDIA_SUPPORT=true
        else
            log_warn "⚠️  NVIDIA driver not installed"
            export NVIDIA_SUPPORT=false
        fi
        
        gpu_found=true
    fi
    
    # AMD GPU Detection
    if lspci | grep -i amd | grep -i vga >/dev/null 2>&1; then
        log_success "✅ AMD GPU detected"
        lspci | grep -i amd | grep -i vga | while read line; do
            log_info "  📱 $line"
        done
        
        # Check for AMD ROCm
        if command -v rocm-smi >/dev/null 2>&1; then
            log_success "✅ AMD ROCm available"
        else
            log_warn "⚠️  AMD ROCm not installed"
        fi
        
        export AMD_SUPPORT=true
        gpu_found=true
    fi
    
    # Intel GPU Detection
    if lspci | grep -i intel | grep -i graphics >/dev/null 2>&1; then
        log_success "✅ Intel GPU detected"
        lspci | grep -i intel | grep -i graphics | while read line; do
            log_info "  📱 $line"
        done
        
        export INTEL_GPU_SUPPORT=true
        gpu_found=true
    fi
    
    # ARM Mali GPU Detection (for ARM builds)
    if [[ "$(uname -m)" == "aarch64" ]] && dmesg 2>/dev/null | grep -i mali >/dev/null 2>&1; then
        log_success "✅ ARM Mali GPU detected"
        export ARM_MALI_SUPPORT=true
        gpu_found=true
    fi
    
    if [[ "$gpu_found" == "false" ]]; then
        log_warn "⚠️  No dedicated GPU detected - using integrated graphics"
    fi
    
    export GPU_SUPPORT=$gpu_found
    return $($gpu_found && echo 0 || echo 1)
}

detect_tpu_support() {
    log_header "TPU (Tensor Processing Unit) Detection"
    
    local tpu_found=false
    
    # Google Coral USB TPU
    if lsusb 2>/dev/null | grep -i coral >/dev/null 2>&1; then
        log_success "✅ Google Coral USB TPU detected"
        lsusb | grep -i coral | while read line; do
            log_info "  🧠 $line"
        done
        export CORAL_USB_SUPPORT=true
        tpu_found=true
    fi
    
    # Google Coral PCIe TPU
    if lspci 2>/dev/null | grep -i coral >/dev/null 2>&1; then
        log_success "✅ Google Coral PCIe TPU detected"
        lspci | grep -i coral | while read line; do
            log_info "  🧠 $line"
        done
        export CORAL_PCIE_SUPPORT=true
        tpu_found=true
    fi
    
    # Check for Edge TPU runtime
    if command -v edgetpu_compiler >/dev/null 2>&1; then
        log_success "✅ Edge TPU compiler available"
    fi
    
    if python3 -c "import tflite_runtime.interpreter as tflite" 2>/dev/null; then
        log_success "✅ TensorFlow Lite runtime available"
    fi
    
    if [[ "$tpu_found" == "false" ]]; then
        log_warn "⚠️  No TPU hardware detected"
    fi
    
    export TPU_SUPPORT=$tpu_found
    return $($tpu_found && echo 0 || echo 1)
}

detect_npu_support() {
    log_header "NPU (Neural Processing Unit) Detection"
    
    local npu_found=false
    
    # Intel VPU/NPU Detection
    if lspci 2>/dev/null | grep -i "processing.*unit\|neural.*processor\|movidius\|vpu" >/dev/null 2>&1; then
        log_success "✅ Intel VPU/NPU detected"
        lspci | grep -i "processing.*unit\|neural.*processor\|movidius\|vpu" | while read line; do
            log_info "  🧠 $line"
        done
        export INTEL_VPU_SUPPORT=true
        npu_found=true
    fi
    
    # ARM Ethos NPU Detection (ARM builds)
    if [[ "$(uname -m)" == "aarch64" ]] && dmesg 2>/dev/null | grep -i "ethos\|npu" >/dev/null 2>&1; then
        log_success "✅ ARM Ethos NPU detected"
        export ARM_ETHOS_SUPPORT=true
        npu_found=true
    fi
    
    # Rockchip NPU Detection (ARM builds)
    if [[ "$(uname -m)" == "aarch64" ]] && dmesg 2>/dev/null | grep -i "rk.*npu\|rockchip.*npu" >/dev/null 2>&1; then
        log_success "✅ Rockchip NPU detected"
        export ROCKCHIP_NPU_SUPPORT=true
        npu_found=true
    fi
    
    # Hailo NPU Detection
    if lspci 2>/dev/null | grep -i hailo >/dev/null 2>&1; then
        log_success "✅ Hailo NPU detected"
        lspci | grep -i hailo | while read line; do
            log_info "  🧠 $line"
        done
        export HAILO_NPU_SUPPORT=true
        npu_found=true
    fi
    
    if [[ "$npu_found" == "false" ]]; then
        log_warn "⚠️  No NPU hardware detected"
    fi
    
    export NPU_SUPPORT=$npu_found
    return $($npu_found && echo 0 || echo 1)
}

detect_dpu_support() {
    log_header "DPU (Data Processing Unit) Detection"
    
    local dpu_found=false
    
    # Mellanox BlueField DPU
    if lspci 2>/dev/null | grep -i "mellanox.*bluefield" >/dev/null 2>&1; then
        log_success "✅ Mellanox BlueField DPU detected"
        lspci | grep -i "mellanox.*bluefield" | while read line; do
            log_info "  🌐 $line"
        done
        export MELLANOX_DPU_SUPPORT=true
        dpu_found=true
    fi
    
    # Intel IPU (Infrastructure Processing Unit)
    if lspci 2>/dev/null | grep -i "intel.*infrastructure.*processing" >/dev/null 2>&1; then
        log_success "✅ Intel IPU detected"
        lspci | grep -i "intel.*infrastructure.*processing" | while read line; do
            log_info "  🌐 $line"
        done
        export INTEL_IPU_SUPPORT=true
        dpu_found=true
    fi
    
    # Check for DPDK support
    if command -v dpdk-hugepages.py >/dev/null 2>&1; then
        log_success "✅ DPDK tools available"
    fi
    
    if [[ "$dpu_found" == "false" ]]; then
        log_warn "⚠️  No DPU hardware detected (normal for desktop/edge systems)"
    fi
    
    export DPU_SUPPORT=$dpu_found
    return $($dpu_found && echo 0 || echo 1)
}

detect_build_variant() {
    log_header "Build Variant Detection"
    
    # Detect build variant based on environment or system characteristics
    if [[ "${BUILD_VARIANT:-}" ]]; then
        log_info "Build variant specified: $BUILD_VARIANT"
    else
        # Auto-detect based on system characteristics
        if [[ "$(uname -m)" == "aarch64" ]]; then
            BUILD_VARIANT="arm"
        elif systemctl is-active --quiet lightdm 2>/dev/null || systemctl is-active --quiet gdm 2>/dev/null; then
            BUILD_VARIANT="desktop"
        else
            BUILD_VARIANT="server"
        fi
        log_info "Auto-detected build variant: $BUILD_VARIANT"
    fi
    
    export BUILD_VARIANT
}

check_docker_support() {
    log_header "Docker Integration Support"
    
    if command -v docker >/dev/null 2>&1; then
        log_success "✅ Docker is available"
        
        if docker info >/dev/null 2>&1; then
            log_success "✅ Docker daemon is running"
        else
            log_warn "⚠️  Docker daemon is not running"
        fi
        
        # Check for GPU support in Docker
        if command -v nvidia-docker >/dev/null 2>&1 || docker info 2>/dev/null | grep -i nvidia >/dev/null; then
            log_success "✅ NVIDIA Docker support available"
        fi
        
    else
        log_warn "⚠️  Docker is not installed"
    fi
}

generate_hardware_report() {
    log_header "Hardware Acceleration Summary Report"
    
    echo ""
    echo -e "${CYAN}🎯 Ainux OS Hardware Acceleration Status Report${NC}"
    echo "======================================================"
    echo -e "📅 Generated: $(date)"
    echo -e "🖥️  System: $(uname -s) $(uname -r) $(uname -m)"
    echo -e "🏗️  Build Variant: ${BUILD_VARIANT:-auto-detect}"
    echo ""
    
    echo -e "${YELLOW}📊 Processing Unit Support Matrix:${NC}"
    echo "┌─────────────────┬─────────────┬─────────────┬─────────────┐"
    echo "│ Unit Type       │ Detected    │ Supported   │ Status      │"
    echo "├─────────────────┼─────────────┼─────────────┼─────────────┤"
    
    # CPU Support
    if [[ "${CPU_ACCELERATION_SUPPORT:-false}" == "true" ]]; then
        echo "│ CPU             │ ✅ Yes      │ ✅ Yes      │ 🟢 Ready    │"
    else
        echo "│ CPU             │ ❌ No       │ ⚠️  Limited │ 🟡 Partial  │"
    fi
    
    # GPU Support
    if [[ "${GPU_SUPPORT:-false}" == "true" ]]; then
        echo "│ GPU             │ ✅ Yes      │ ✅ Yes      │ 🟢 Ready    │"
    else
        echo "│ GPU             │ ❌ No       │ ⚠️  Fallback│ 🟡 CPU Only │"
    fi
    
    # TPU Support
    if [[ "${TPU_SUPPORT:-false}" == "true" ]]; then
        echo "│ TPU             │ ✅ Yes      │ ✅ Yes      │ 🟢 Ready    │"
    else
        echo "│ TPU             │ ❌ No       │ ⚠️  Optional│ 🟡 Optional │"
    fi
    
    # NPU Support
    if [[ "${NPU_SUPPORT:-false}" == "true" ]]; then
        echo "│ NPU             │ ✅ Yes      │ ✅ Yes      │ 🟢 Ready    │"
    else
        echo "│ NPU             │ ❌ No       │ ⚠️  Optional│ 🟡 Optional │"
    fi
    
    # DPU Support
    if [[ "${DPU_SUPPORT:-false}" == "true" ]]; then
        echo "│ DPU             │ ✅ Yes      │ ✅ Yes      │ 🟢 Ready    │"
    else
        echo "│ DPU             │ ❌ No       │ ⚠️  Optional│ 🟡 Optional │"
    fi
    
    echo "└─────────────────┴─────────────┴─────────────┴─────────────┘"
    echo ""
    
    # Recommendations
    echo -e "${YELLOW}💡 Recommendations:${NC}"
    
    if [[ "${GPU_SUPPORT:-false}" == "false" ]]; then
        echo "  🔹 Consider adding a dedicated GPU for AI acceleration"
    fi
    
    if [[ "${TPU_SUPPORT:-false}" == "false" ]] && [[ "$BUILD_VARIANT" == "arm" || "$BUILD_VARIANT" == "desktop" ]]; then
        echo "  🔹 Google Coral TPU recommended for edge AI workloads"
    fi
    
    if [[ "${NPU_SUPPORT:-false}" == "false" ]]; then
        echo "  🔹 NPU hardware can significantly improve AI inference performance"
    fi
    
    echo ""
    echo -e "${GREEN}🚀 System is ready for Ainux OS build with detected hardware acceleration!${NC}"
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}🔍 Ainux OS Hardware Detection v5.0${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    
    # Initialize all detection flags
    export CPU_ACCELERATION_SUPPORT=false
    export GPU_SUPPORT=false
    export TPU_SUPPORT=false
    export NPU_SUPPORT=false
    export DPU_SUPPORT=false
    
    # Detect build variant first
    detect_build_variant
    
    # Run all hardware detection
    detect_cpu_acceleration
    echo ""
    
    detect_gpu_support
    echo ""
    
    detect_tpu_support
    echo ""
    
    detect_npu_support
    echo ""
    
    detect_dpu_support
    echo ""
    
    check_docker_support
    echo ""
    
    # Generate comprehensive report
    generate_hardware_report
    
    # Save report to file
    local report_file="/tmp/ainux-hardware-report-$(date +%Y%m%d-%H%M%S).txt"
    generate_hardware_report > "$report_file" 2>&1
    log_info "Hardware report saved to: $report_file"
    
    echo -e "${GREEN}🎉 Hardware detection completed successfully!${NC}"
}

# Run main function
main "$@"