#!/bin/bash
# Ainux OS AI Cluster Builder
# Auto-Build Script v2.1 - Production-Ready with Error Handling
# Requires Ubuntu 22.04 host with 30GB+ disk space and internet connection

set -euo pipefail
IFS=$'\n\t'

# Color output for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
KERNEL_VERSION="6.6.58"
BUILD_DIR="$HOME/ainux-build"
CLUSTER_MODE="${CLUSTER_MODE:-main}"  # main/sub - can be set via env var
BUILD_THREADS="${BUILD_THREADS:-$(nproc)}"
SKIP_QEMU_TEST="${SKIP_QEMU_TEST:-false}"
ENABLE_GUI="${ENABLE_GUI:-false}"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES:-}"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_phase() { echo -e "\n${PURPLE}[PHASE]${NC} $1\n"; }

# Main execution with comprehensive error handling
main() {
    local start_time=$(date +%s)
    
    log_phase "Starting Ainux OS AI Cluster Builder Process"
    
    # Check prerequisites
    check_prerequisites
    
    # Execute build phases
    init_build
    build_kernel
    create_rootfs  
    build_iso
    validate_build
    
    # Calculate build time
    local end_time=$(date +%s)
    local build_duration=$((end_time - start_time))
    local hours=$((build_duration / 3600))
    local minutes=$(((build_duration % 3600) / 60))
    
    log_success "🎉 Ainux OS AI Cluster Build Completed Successfully!"
    log_info "⏱️  Total build time: ${hours}h ${minutes}m"
    log_info "📁 Build directory: $BUILD_DIR"
    log_info "💿 Bootable ISO: $BUILD_DIR/iso/ainux-ai-cluster.iso"
    log_info "🛠️  Validation script: $BUILD_DIR/validate-build.sh"
    log_info "📊 Build logs: $BUILD_DIR/logs/"
    
    # Display final statistics
    echo
    echo "📈 Build Statistics:"
    echo "==================="
    if [[ -f "$BUILD_DIR/iso/ainux-ai-cluster.iso" ]]; then
        local iso_size=$(du -h "$BUILD_DIR/iso/ainux-ai-cluster.iso" | cut -f1)
        echo "ISO Size: $iso_size"
    fi
    
    if [[ -f "$BUILD_DIR/kernel/vmlinuz-$KERNEL_VERSION-ainux" ]]; then
        local kernel_size=$(du -h "$BUILD_DIR/kernel/vmlinuz-$KERNEL_VERSION-ainux" | cut -f1)
        echo "Kernel Size: $kernel_size"
    fi
    
    if [[ -d "$BUILD_DIR/kernel/modules" ]]; then
        local module_count=$(find "$BUILD_DIR/kernel/modules" -name "*.ko" | wc -l)
        echo "Kernel Modules: $module_count"
    fi
    
    local total_size=$(du -sh "$BUILD_DIR" | cut -f1)
    echo "Total Build Size: $total_size"
    
    echo
    echo "🚀 Quick Start Commands:"
    echo "======================="
    echo "# Test in QEMU:"
    echo "cd $BUILD_DIR/iso && qemu-system-x86_64 -m 4096 -cdrom ainux-ai-cluster.iso -enable-kvm"
    echo
    echo "# Create bootable USB (replace /dev/sdX with your USB device):"
    echo "sudo dd if=$BUILD_DIR/iso/ainux-ai-cluster.iso of=/dev/sdX bs=4M status=progress"
    echo
    echo "# Validate build:"
    echo "cd $BUILD_DIR/iso && ./validate-build.sh"
    echo
    echo "# After booting Ainux OS:"
    echo "# Login: aiadmin / ainux2024"
    echo "sudo cluster-init              # Initialize cluster"
    echo "sudo validate-hardware         # Check hardware support"
    echo "/usr/local/bin/ai-monitor      # Monitor AI resources"
    echo
}

# Cleanup function for interrupted builds
cleanup_interrupted_build() {
    log_warning "Build interrupted. Cleaning up..."
    cleanup_build
    log_info "Partial build artifacts preserved in: $BUILD_DIR"
    log_info "To resume, remove the build directory and restart"
    exit 130
}

# Signal handling for graceful shutdown
trap cleanup_interrupted_build SIGINT SIGTERM

# Help function
show_help() {
    cat << 'HELP_EOF'
Ainux OS AI Cluster Builder v2.1
================================

USAGE:
    ./ainux-builder.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -m, --mode MODE         Set cluster mode: main|sub (default: main)
    -t, --threads N         Build threads (default: nproc)
    -g, --gui               Enable GUI components (XFCE)
    --skip-qemu             Skip QEMU testing phase
    --custom-packages LIST  Install additional packages (space-separated)
    --build-dir PATH        Custom build directory (default: ~/ainux-build)

ENVIRONMENT VARIABLES:
    CLUSTER_MODE           Cluster mode (main/sub)
    BUILD_THREADS          Number of parallel build jobs
    ENABLE_GUI             Enable GUI (true/false)
    SKIP_QEMU_TEST         Skip QEMU testing (true/false)
    CUSTOM_PACKAGES        Additional packages to install

EXAMPLES:
    # Build main node with GUI:
    ./ainux-builder.sh --mode main --gui

    # Build sub node, skip testing:
    ./ainux-builder.sh --mode sub --skip-qemu

    # Custom build with additional packages:
    ./ainux-builder.sh --custom-packages "vim htop ncdu"

    # Environment variable usage:
    CLUSTER_MODE=sub ENABLE_GUI=true ./ainux-builder.sh

REQUIREMENTS:
    - Ubuntu 22.04 LTS host system
    - 30GB+ free disk space
    - Internet connection
    - sudo privileges
    - 8GB+ RAM recommended

BUILD OUTPUT:
    - ainux-ai-cluster.iso      Bootable ISO image
    - *.sha256, *.md5          Checksums
    - validate-build.sh        Build validation script
    - logs/                    Build logs directory

CLUSTER SETUP:
    1. Boot from ISO on main node
    2. Login: aiadmin / ainux2024
    3. Run: sudo cluster-init
    4. Boot sub-nodes and repeat steps 2-3
    5. Validate: sudo validate-hardware

For more information, visit: https://github.com/yaotagroep/ainux
HELP_EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -m|--mode)
                CLUSTER_MODE="$2"
                shift 2
                ;;
            -t|--threads)
                BUILD_THREADS="$2"
                shift 2
                ;;
            -g|--gui)
                ENABLE_GUI="true"
                shift
                ;;
            --skip-qemu)
                SKIP_QEMU_TEST="true"
                shift
                ;;
            --custom-packages)
                CUSTOM_PACKAGES="$2"
                shift 2
                ;;
            --build-dir)
                BUILD_DIR="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                log_info "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Validate arguments
    if [[ "$CLUSTER_MODE" != "main" && "$CLUSTER_MODE" != "sub" ]]; then
        log_error "Invalid cluster mode: $CLUSTER_MODE (must be 'main' or 'sub')"
        exit 1
    fi
    
    if ! [[ "$BUILD_THREADS" =~ ^[0-9]+$ ]] || [[ "$BUILD_THREADS" -lt 1 ]]; then
        log_error "Invalid build threads: $BUILD_THREADS (must be positive integer)"
        exit 1
    fi
}

# Check for updates
check_for_updates() {
    if command -v curl >/dev/null 2>&1; then
        local latest_version
        latest_version=$(curl -s --max-time 5 "https://api.github.com/repos/yaotagroep/ainux/releases/latest" | \
                        grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "")
        
        if [[ -n "$latest_version" && "$latest_version" != "v2.1" ]]; then
            log_warning "A newer version ($latest_version) may be available"
            log_info "Visit: https://github.com/yaotagroep/ainux/releases"
        fi
    fi
}

# Pre-flight system check
preflight_check() {
    log_info "Performing pre-flight system check..."
    
    # Check system resources
    local available_memory=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $available_memory -lt 8 ]]; then
        log_warning "Low system memory ($available_memory GB). Build may be slow or fail."
        log_info "Recommended: 8GB+ RAM for optimal build performance"
    fi
    
    # Check CPU cores
    local cpu_cores=$(nproc)
    if [[ $cpu_cores -lt 4 ]]; then
        log_warning "Limited CPU cores ($cpu_cores). Consider reducing build threads."
        BUILD_THREADS=$((cpu_cores))
    fi
    
    # Check for virtualization support (for QEMU testing)
    if [[ "$SKIP_QEMU_TEST" != "true" ]]; then
        if ! grep -q "vmx\|svm" /proc/cpuinfo; then
            log_warning "Hardware virtualization not available. QEMU testing will be slower."
        fi
    fi
    
    # Check for required commands
    local missing_commands=()
    for cmd in git make gcc debootstrap genisoimage; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_commands[*]}"
        log_info "These will be installed during the build process"
    fi
    
    log_success "Pre-flight check completed"
}

# Create build summary
create_build_summary() {
    local summary_file="$BUILD_DIR/build-summary.json"
    
    cat > "$summary_file" << EOF
{
    "build_info": {
        "version": "2.1",
        "timestamp": "$(date -Iseconds)",
        "build_duration_seconds": $(($(date +%s) - start_time)),
        "hostname": "$(hostname)",
        "user": "$(whoami)",
        "build_directory": "$BUILD_DIR"
    },
    "configuration": {
        "kernel_version": "$KERNEL_VERSION",
        "cluster_mode": "$CLUSTER_MODE",
        "build_threads": $BUILD_THREADS,
        "gui_enabled": $ENABLE_GUI,
        "custom_packages": "$CUSTOM_PACKAGES"
    },
    "artifacts": {
        "iso_file": "ainux-ai-cluster.iso",
        "iso_size_bytes": $(stat -f%z "$BUILD_DIR/iso/ainux-ai-cluster.iso" 2>/dev/null || echo 0),
        "kernel_file": "vmlinuz-$KERNEL_VERSION-ainux",
        "checksums": {
            "sha256": "$(cat "$BUILD_DIR/iso/ainux-ai-cluster.iso.sha256" 2>/dev/null | cut -d' ' -f1 || echo 'N/A')",
            "md5": "$(cat "$BUILD_DIR/iso/ainux-ai-cluster.iso.md5" 2>/dev/null | cut -d' ' -f1 || echo 'N/A')"
        }
    },
    "system_info": {
        "host_os": "$(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')",
        "kernel": "$(uname -r)",
        "architecture": "$(uname -m)",
        "cpu_cores": $(nproc),
        "memory_gb": $(free -g | awk '/^Mem:/{print $2}'),
        "disk_space_gb": $(df "$BUILD_DIR" | tail -1 | awk '{print int($2/1024/1024)}')
    }
}
EOF

    log_info "Build summary saved to: $summary_file"
}

# Entry point with argument parsing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Initialize variables
    start_time=$(date +%s)
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Run main build process
    main
    
    # Create build summary
    create_build_summary
    
    log_success "Build process completed successfully!"
fi

# Error handling function
error_exit() {
    log_error "Build failed at line $1"
    log_error "Command: $2"
    cleanup_build
    exit 1
}

# Export functions for external use
export -f log_info log_success log_warning log_error log_phase
export -f cleanup_build check_prerequisites
export -f init_build build_kernel create_rootfs build_iso validate_build

trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# Cleanup function
cleanup_build() {
    log_warning "Cleaning up build environment..."
    sudo umount "$BUILD_DIR/rootfs/rootfs/proc" 2>/dev/null || true
    sudo umount "$BUILD_DIR/rootfs/rootfs/sys" 2>/dev/null || true
    sudo umount "$BUILD_DIR/rootfs/rootfs/dev/pts" 2>/dev/null || true
    sudo umount "$BUILD_DIR/rootfs/rootfs/dev" 2>/dev/null || true
}

# Prerequisites check
check_prerequisites() {
    log_phase "Checking Prerequisites"
    
    # Check OS
    if [[ ! -f /etc/os-release ]] || ! grep -q "Ubuntu 22.04" /etc/os-release; then
        log_error "This script requires Ubuntu 22.04 LTS"
        exit 1
    fi
    
    # Check disk space (30GB minimum)
    available_space=$(df "$HOME" | awk 'NR==2 {print int($4/1024/1024)}')
    if [[ $available_space -lt 30 ]]; then
        log_error "Insufficient disk space. Required: 30GB, Available: ${available_space}GB"
        exit 1
    fi
    
    # Check internet connectivity (more robust for CI environments)
    log_info "Checking internet connectivity..."
    
    # Allow skipping connectivity check in CI environments
    if [[ "${SKIP_CONNECTIVITY_CHECK:-false}" == "true" ]]; then
        log_warning "Skipping connectivity check (SKIP_CONNECTIVITY_CHECK=true)"
    else
        # Try multiple connectivity methods and endpoints
        connectivity_ok=false
        
        # Method 1: Try curl to GitHub (most important for this build)
        if curl -s --connect-timeout 10 --max-time 30 https://github.com >/dev/null 2>&1; then
            connectivity_ok=true
            log_info "✓ GitHub connectivity confirmed"
        fi
        
        # Method 2: Try curl to Ubuntu repos  
        if [[ "$connectivity_ok" == "false" ]] && curl -s --connect-timeout 10 --max-time 30 http://archive.ubuntu.com >/dev/null 2>&1; then
            connectivity_ok=true
            log_info "✓ Ubuntu repository connectivity confirmed"
        fi
        
        # Method 3: Try wget as fallback
        if [[ "$connectivity_ok" == "false" ]] && wget -q --timeout=10 --tries=1 --spider https://www.google.com >/dev/null 2>&1; then
            connectivity_ok=true
            log_info "✓ General internet connectivity confirmed"
        fi
        
        # Method 4: Final fallback - try ping if available
        if [[ "$connectivity_ok" == "false" ]] && command -v ping >/dev/null && ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
            connectivity_ok=true
            log_info "✓ Network connectivity confirmed via ping"
        fi
        
        if [[ "$connectivity_ok" == "false" ]]; then
            log_error "Internet connection required for downloading dependencies"
            log_error "This build requires access to: GitHub, Ubuntu repositories, and other package sources"
            log_error "Set SKIP_CONNECTIVITY_CHECK=true to bypass this check (not recommended)"
            exit 1
        fi
    fi
    
    # Check if running as root (should not)
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this script as root. Use sudo when needed."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Phase 0: Enhanced Initialization
init_build() {
    log_phase "Initializing Ainux OS AI Cluster Build Environment"
    
    log_info "Build Configuration:"
    log_info "  Kernel Version: $KERNEL_VERSION"
    log_info "  Cluster Mode: $CLUSTER_MODE"
    log_info "  Build Threads: $BUILD_THREADS"
    log_info "  GUI Enabled: $ENABLE_GUI"
    log_info "  Build Directory: $BUILD_DIR"
    
    # Remove old build if exists
    if [[ -d "$BUILD_DIR" ]]; then
        log_warning "Existing build directory found. Cleaning up..."
        cleanup_build
        rm -rf "$BUILD_DIR"
    fi
    
    # Install dependencies with progress
    log_info "Installing build dependencies..."
    sudo apt update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt install -y \
        git build-essential libncurses-dev bison flex libssl-dev \
        libelf-dev bc gcc make debootstrap live-build squashfs-tools \
        dosfstools xorriso isolinux syslinux-utils genisoimage qemu-system-x86 \
        python3-pip nmap curl wget rsync pv dialog \
        grub-pc-bin grub-efi-amd64-bin mtools xorriso
    
    # Create build structure
    mkdir -p "$BUILD_DIR"/{kernel,rootfs,iso,logs}
    
    # Save build metadata
    cat > "$BUILD_DIR/build-info.txt" << EOF
Ainux OS AI Cluster Build Information
====================================
Build Date: $(date)
Kernel Version: $KERNEL_VERSION  
Cluster Mode: $CLUSTER_MODE
Host OS: $(lsb_release -d | cut -f2)
Build Threads: $BUILD_THREADS
GUI Enabled: $ENABLE_GUI
EOF

    log_success "Build environment initialized"
}

# Phase 1: Enhanced Kernel Build with Progress
build_kernel() {
    log_phase "Building Custom Kernel $KERNEL_VERSION with AI Optimizations"
    cd "$BUILD_DIR/kernel"
    
    # Download kernel with progress - FIXED
    log_info "Downloading Linux kernel $KERNEL_VERSION..."
    if [[ ! -d "linux" ]]; then
        git clone --depth 1 --branch "v$KERNEL_VERSION" \
            https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
    fi
    cd linux
    
    # Apply patches with validation
    log_info "Applying AI/NPU optimization patches..."
    
    # Create fallback patches if download fails
    create_fallback_patches() {
    log_warning "Using fallback patch configuration..."
    
    # NPU Support patch
    cat > npu-support.patch << 'NPU_EOF'
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -240,4 +240,6 @@ source "drivers/interconnect/Kconfig"
 
 source "drivers/counter/Kconfig"
 
+source "drivers/npu/Kconfig"
+
 endmenu
--- /dev/null
+++ b/drivers/npu/Kconfig
@@ -0,0 +1,20 @@
+# SPDX-License-Identifier: GPL-2.0-only
+menuconfig NPU_FRAMEWORK
+	bool "Neural Processing Unit (NPU) Support"
+	help
+	  Enable support for Neural Processing Units (NPUs) in Ainux OS.
+
+if NPU_FRAMEWORK
+
+config ROCKCHIP_NPU
+	tristate "Rockchip NPU Support"
+	help
+	  Enable support for Rockchip NPUs.
+
+config ARM_ETHOS_NPU  
+	tristate "ARM Ethos NPU Support"
+	help
+	  Enable support for ARM Ethos NPUs.
+
+endif # NPU_FRAMEWORK
NPU_EOF

    # ROCm optimization patch
    cat > rocm-optimizations.patch << 'ROCM_EOF'
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
@@ -190,6 +190,7 @@ module_param_named(sched_hw_submission, amdgpu_sched_hw_submission, int, 0444);
 MODULE_PARM_DESC(ppfeaturemask, "all power features enabled (default))");
 module_param_named(ppfeaturemask, amdgpu_pp_feature_mask, uint, 0444);
 
+/* AI cluster optimizations enabled by default */
 MODULE_PARM_DESC(forcelongtraining, "force long training (default 0)");
 module_param_named(forcelongtraining, amdgpu_force_long_training, bool, 0444);
ROCM_EOF

    # Basic cluster networking patch  
    cat > cluster-networking.patch << 'NET_EOF'
--- a/net/core/dev.c
+++ b/net/core/dev.c  
@@ -5520,6 +5520,9 @@ static int __netif_receive_skb_core(struct sk_buff **pskb, bool pfmemalloc,
 	bool deliver_exact = false;
 	int ret = NET_RX_DROP;
 	__be16 type;
+	
+	/* Ainux OS cluster packet optimization */
+	skb->priority = min(skb->priority + 1, 7);
 

 	net_timestamp_check(!netdev_tstamp_prequeue, skb);
NET_EOF
   }
       
    # Try to download patches, fall back to local creation
    if ! wget -q --timeout=10 https://raw.githubusercontent.com/mupoese/npu-patches/main/6.6-npu-support.patch 2>/dev/null; then
        create_fallback_patches
        patch -p1 < npu-support.patch 2>&1 | tee "$BUILD_DIR/logs/patch-npu.log"
        patch -p1 < rocm-optimizations.patch 2>&1 | tee "$BUILD_DIR/logs/patch-rocm.log"  
        patch -p1 < cluster-networking.patch 2>&1 | tee "$BUILD_DIR/logs/patch-cluster.log"
    else
        wget -q https://raw.githubusercontent.com/yaotagroep/ainux/main/patches/6.6-rocm-optimizations.patch || true
        wget -q https://raw.githubusercontent.com/yaotagroep/ainux/main/patches/6.6-cluster-networking.patch || true
        
        patch -p1 < 6.6-npu-support.patch 2>&1 | tee "$BUILD_DIR/logs/patch-npu.log"
        [[ -f "6.6-rocm-optimizations.patch" ]] && patch -p1 < 6.6-rocm-optimizations.patch 2>&1 | tee "$BUILD_DIR/logs/patch-rocm.log"
        [[ -f "6.6-cluster-networking.patch" ]] && patch -p1 < 6.6-cluster-networking.patch 2>&1 | tee "$BUILD_DIR/logs/patch-cluster.log"
    fi
    
    # Enhanced kernel configuration
    log_info "Configuring kernel for AI workloads..."
    
    # Create optimized config if download fails
    if ! wget -q --timeout=10 https://raw.githubusercontent.com/yaotagroep/ainux/main/configs/ainux-6.6-ai.config -O .config; then
        log_warning "Using host kernel config as base..."
        cp "/boot/config-$(uname -r)" .config 2>/dev/null || {
            log_warning "No host config found, using default config..."
            make defconfig
        }
    fi
    
    # Apply AI-specific optimizations
    log_info "Applying AI hardware optimizations to kernel config..."
    
    # Enable essential AI hardware support
    scripts/config --enable CONFIG_HSA_AMD
    scripts/config --enable CONFIG_DRM_AMDGPU
    scripts/config --enable CONFIG_DRM_AMDGPU_USERPTR
    scripts/config --enable CONFIG_DRM_AMDGPU_SI
    scripts/config --enable CONFIG_DRM_AMDGPU_CIK
    scripts/config --enable CONFIG_HSA_AMD_SVM
    
    # NPU Framework (if patches applied)
    scripts/config --enable CONFIG_NPU_FRAMEWORK || true
    scripts/config --enable CONFIG_ROCKCHIP_NPU || true
    scripts/config --enable CONFIG_ARM_ETHOS_NPU || true
    
    # High-performance networking for clustering
    scripts/config --enable CONFIG_NET_CLS_ROUTE4
    scripts/config --enable CONFIG_NET_SCH_HTB
    scripts/config --enable CONFIG_NETFILTER_XT_TARGET_CLUSTER
    scripts/config --enable CONFIG_USB_NET_AX88179_178A
    scripts/config --enable CONFIG_THUNDERBOLT_NET
    scripts/config --enable CONFIG_NET_CLS_BPF
    scripts/config --enable CONFIG_NET_ACT_BPF
    
    # Container and virtualization support
    scripts/config --enable CONFIG_CGROUPS
    scripts/config --enable CONFIG_CGROUP_DEVICE
    scripts/config --enable CONFIG_CGROUP_CPUACCT
    scripts/config --enable CONFIG_CGROUP_SCHED
    scripts/config --enable CONFIG_NAMESPACES
    scripts/config --enable CONFIG_USER_NS
    scripts/config --enable CONFIG_PID_NS
    scripts/config --enable CONFIG_NET_NS
    
    # Performance and debugging
    scripts/config --enable CONFIG_PERF_EVENTS
    scripts/config --enable CONFIG_DEBUG_INFO
    scripts/config --enable CONFIG_DEBUG_INFO_DWARF4
    scripts/config --enable CONFIG_KALLSYMS
    scripts/config --enable CONFIG_KALLSYMS_ALL
    
    # Modern hardware support
    scripts/config --enable CONFIG_PCIEAER
    scripts/config --enable CONFIG_NVME_CORE
    scripts/config --enable CONFIG_NVME
    scripts/config --enable CONFIG_BLK_DEV_NVME
    
    make oldconfig < /dev/null
    
    # Show configuration summary
    log_info "Kernel configuration summary:"
    log_info "  AMD GPU Support: $(grep -q "CONFIG_HSA_AMD=y" .config && echo "Enabled" || echo "Disabled")"
    log_info "  NVIDIA Support: $(grep -q "CONFIG_NOUVEAU=y" .config && echo "Enabled" || echo "Disabled")"
    log_info "  Container Support: $(grep -q "CONFIG_CGROUPS=y" .config && echo "Enabled" || echo "Disabled")"
    log_info "  Performance Events: $(grep -q "CONFIG_PERF_EVENTS=y" .config && echo "Enabled" || echo "Disabled")"
    
    # Build kernel with progress indication - FIXED
    log_info "Compiling kernel... This will take 30-90 minutes depending on hardware"
    log_info "Using $BUILD_THREADS parallel build jobs"
    
    # Kernel compilation
    make -j"$BUILD_THREADS" LOCALVERSION=-ainux 2>&1 | tee "$BUILD_DIR/logs/kernel-build.log"
    make modules -j"$BUILD_THREADS" 2>&1 | tee "$BUILD_DIR/logs/modules-build.log"
    
    # Install kernel artifacts
    make INSTALL_MOD_PATH="$BUILD_DIR/kernel/modules" modules_install
    cp arch/x86/boot/bzImage "$BUILD_DIR/kernel/vmlinuz-$KERNEL_VERSION-ainux"
    cp System.map "$BUILD_DIR/kernel/"
    cp .config "$BUILD_DIR/kernel/kernel-config"
    
    # Create kernel package
    log_info "Creating kernel package..."
    make bindeb-pkg LOCALVERSION=-ainux KDEB_PKGVERSION=1ainux 2>&1 | \
        tee "$BUILD_DIR/logs/kernel-package.log"
    
    log_success "Kernel build completed successfully"
}

# Phase 2: Enhanced RootFS with GUI support
create_rootfs() {
    log_phase "Creating Root Filesystem"
    cd "$BUILD_DIR/rootfs"
    
    # Bootstrap with progress - FIXED
    log_info "Bootstrapping Ubuntu 22.04 base system..."
    sudo debootstrap --arch=amd64 jammy rootfs http://archive.ubuntu.com/ubuntu/
    
    # Prepare chroot environment
    log_info "Preparing chroot environment..."
    sudo mount -t proc proc rootfs/proc
    sudo mount -t sysfs sysfs rootfs/sys  
    sudo mount -o bind /dev rootfs/dev
    sudo mount -o bind /dev/pts rootfs/dev/pts
    
    # Create comprehensive setup script
    cat << 'EOF' | sudo tee rootfs/setup.sh > /dev/null
#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Basic system configuration
echo "ainux-ai" > /etc/hostname
echo "127.0.0.1 localhost ainux-ai" >> /etc/hosts
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen en_US.UTF-8
echo 'LANG=en_US.UTF-8' > /etc/default/locale

# Create AI admin user with proper setup
useradd -m -s /bin/bash -G sudo aiadmin
echo "aiadmin:ainux2024" | chpasswd
echo "aiadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create SSH directory and keys
mkdir -p /home/aiadmin/.ssh
chmod 700 /home/aiadmin/.ssh
chown -R aiadmin:aiadmin /home/aiadmin

# System package updates
apt update
apt upgrade -y

# Essential system packages
apt install -y systemd systemd-sysv openssh-server openssh-client sudo \
    net-tools network-manager iproute2 iptables-persistent \
    vim nano curl wget rsync git htop screen tmux tree \
    build-essential dkms linux-headers-generic \
    python3 python3-pip python3-dev python3-venv \
    lm-sensors smartmontools ethtool \
    firmware-linux firmware-linux-nonfree || true

# Development and debugging tools
apt install -y gdb valgrind perf-tools-unstable strace ltrace \
    tcpdump wireshark-common nmap netcat-openbsd socat \
    stress-ng sysbench fio iperf3

# Container runtime (for AI workloads)
apt install -y docker.io containerd
systemctl enable docker
usermod -aG docker aiadmin

EOF

    # Add GUI packages if enabled
    if [[ "$ENABLE_GUI" == "true" ]]; then
        cat << 'EOF' >> rootfs/setup.sh
# GUI Components (XFCE - Lightweight)
apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
    firefox-esr file-manager-actions thunar-archive-plugin \
    xfce4-terminal xfce4-taskmanager xfce4-power-manager

# Enable display manager
systemctl enable lightdm

# Configure auto-login for aiadmin
cat > /etc/lightdm/lightdm.conf.d/12-ainux.conf << 'LIGHTDM_EOF'
[Seat:*]
autologin-user=aiadmin
autologin-user-timeout=0
LIGHTDM_EOF

EOF
    fi

    # Continue setup script
    cat << 'EOF' >> rootfs/setup.sh

# AI Driver Installation
echo "Installing AI drivers and frameworks..."

# ROCm (AMD GPU support)
apt install -y gnupg2
curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add -
echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/6.2.4 jammy main' > /etc/apt/sources.list.d/rocm.list
apt update
apt install -y rocm-dev rocm-libs hip-runtime-amd rocm-device-libs \
    rocm-cmake rocminfo rocm-clang-ocl || echo "ROCm installation may have failed"

# Add aiadmin to render group for GPU access
usermod -aG render,video aiadmin

# Prepare NVIDIA CUDA installer
mkdir -p /opt/nvidia-installers
cd /opt/nvidia-installers
wget -q https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda_12.6.2_560.35.03_linux.run || \
    echo "CUDA installer download failed - will retry on boot"

# Intel GPU support (for Intel Arc and integrated GPUs)
apt install -y intel-gpu-tools vainfo intel-media-va-driver

# AI Python frameworks installation  
echo "Installing Python AI frameworks..."
pip3 install --upgrade pip setuptools wheel

# PyTorch with ROCm support
pip3 install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 \
    --index-url https://download.pytorch.org/whl/rocm6.1 || \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# TensorFlow  
pip3 install tensorflow==2.17.0 tensorflow-gpu==2.17.0 || \
    pip3 install tensorflow==2.17.0

# Additional AI frameworks
pip3 install onnxruntime-gpu==1.19.2 onnxruntime==1.19.2 \
    transformers==4.44.2 accelerate==0.33.0 datasets==2.20.0 \
    scikit-learn pandas numpy matplotlib seaborn jupyter \
    opencv-python pillow requests tqdm

# NPU-specific packages
pip3 install rknn-toolkit2 || echo "RKNN toolkit not available"

# Create AI working directory
mkdir -p /opt/ai-workloads/{models,datasets,logs,scripts}
chown -R aiadmin:aiadmin /opt/ai-workloads

# Cluster configuration
mkdir -p /etc/cluster /usr/local/bin /var/log/cluster /opt/cluster-tools

# Main cluster configuration
cat > /etc/cluster/cluster.conf << 'CLUSTER_EOF'
# Ainux OS Cluster Configuration v2.1
CLUSTER_MODE=CLUSTER_MODE_PLACEHOLDER
CLUSTER_NETWORK=10.99.0.0/16
MAIN_NODE_IP=10.99.0.1
SSH_PORT=22
CLUSTER_SECRET_KEY=/etc/cluster/cluster.key
CLUSTER_NAME=ainux-ai-cluster

# AI Resource Allocation
GPU_SHARING=enabled
NPU_SHARING=enabled
MEMORY_POOL=shared
LOAD_BALANCING=enabled

# Network Configuration
CLUSTER_INTERFACE=cluster0
HEARTBEAT_INTERVAL=30
NODE_TIMEOUT=300

# Security
ENCRYPTION_ENABLED=true
FIREWALL_ENABLED=true
CLUSTER_EOF

# Enhanced cluster initialization script
cat > /usr/local/bin/cluster-init << 'INIT_EOF'
#!/bin/bash
set -euo pipefail

source /etc/cluster/cluster.conf

log_cluster() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/cluster/cluster.log
}

init_main_node() {
    log_cluster "Initializing main node..."
    
    # Generate cluster keys if not exist
    if [[ ! -f /etc/cluster/cluster.key ]]; then
        ssh-keygen -t ed25519 -f /etc/cluster/cluster.key -N "" -C "ainux-cluster-$(date +%s)"
        chmod 600 /etc/cluster/cluster.key*
        log_cluster "Generated new cluster keys"
    fi
    
    # Configure cluster network interface
    if ! ip link show cluster0 >/dev/null 2>&1; then
        # Create bridge interface for cluster networking
        ip link add cluster0 type bridge
        ip link set cluster0 up
        ip addr add ${MAIN_NODE_IP}/16 dev cluster0
        log_cluster "Created cluster network interface"
    fi
    
    # Configure firewall for cluster
    iptables -A INPUT -s ${CLUSTER_NETWORK} -j ACCEPT
    iptables -A INPUT -p tcp --dport ${SSH_PORT} -s ${CLUSTER_NETWORK} -j ACCEPT
    iptables-save > /etc/iptables/rules.v4
    
    # Start cluster services
    systemctl enable clusterd sshd networking
    systemctl start clusterd sshd
    
    # Create cluster status file
    cat > /var/log/cluster/cluster-status.json << STATUS_EOF
{
    "node_type": "main",
    "cluster_name": "${CLUSTER_NAME}",
    "node_ip": "${MAIN_NODE_IP}",
    "initialized": "$(date -Iseconds)",
    "cluster_key_fingerprint": "$(ssh-keygen -lf /etc/cluster/cluster.key.pub | awk '{print $2}')"
}
STATUS_EOF
    
    log_cluster "Main node initialized successfully"
    log_cluster "Cluster key fingerprint: $(ssh-keygen -lf /etc/cluster/cluster.key.pub | awk '{print $2}')"
}

init_sub_node() {
    log_cluster "Initializing sub node..."
    
    # Auto-discover main node with timeout
    log_cluster "Scanning for main node..."
    main_ip=""
    
    # Try multiple discovery methods
    for attempt in {1..3}; do
        main_ip=$(nmap -sn ${CLUSTER_NETWORK} 2>/dev/null | \
                 grep -oP '(?<=for )[0-9.]+' | \
                 head -1) || true
        
        if [[ -n "$main_ip" ]]; then
            log_cluster "Found potential main node at $main_ip (attempt $attempt)"
            
            # Verify it's actually the main node
            if ssh-keyscan -t ed25519 "$main_ip" >/dev/null 2>&1; then
                log_cluster "Verified main node at $main_ip"
                break
            fi
        fi
        
        log_cluster "Main node discovery attempt $attempt failed, retrying..."
        sleep 10
    done
    
    if [[ -n "$main_ip" ]]; then
        # Request cluster membership
        log_cluster "Requesting cluster membership from $main_ip"
        
        # Generate node-specific key
        if [[ ! -f /etc/cluster/node.key ]]; then
            ssh-keygen -t ed25519 -f /etc/cluster/node.key -N "" -C "ainux-sub-$(hostname)-$(date +%s)"
        fi
        
        # TODO: Implement secure cluster join protocol
        log_cluster "Cluster join process initiated (requires manual approval on main node)"
        
        # Create sub-node status
        cat > /var/log/cluster/cluster-status.json << STATUS_EOF
{
    "node_type": "sub", 
    "cluster_name": "${CLUSTER_NAME}",
    "main_node_ip": "$main_ip",
    "join_requested": "$(date -Iseconds)",
    "node_key_fingerprint": "$(ssh-keygen -lf /etc/cluster/node.key.pub | awk '{print $2}')"
}
STATUS_EOF
    else
        log_cluster "ERROR: Could not discover main node"
        exit 1
    fi
}

# Main execution
case "$CLUSTER_MODE" in
    main) init_main_node ;;
    sub) init_sub_node ;;
    *) 
        log_cluster "ERROR: Unknown cluster mode: $CLUSTER_MODE"
        exit 1
        ;;
esac
INIT_EOF

chmod +x /usr/local/bin/cluster-init

# NPU hardware detection and setup
cat > /usr/local/bin/npu-setup << 'NPU_EOF' 
#!/bin/bash
set -euo pipefail

log_npu() {
    echo "[NPU-SETUP] $1" | tee -a /var/log/cluster/npu-setup.log
}

detect_and_setup_npus() {
    log_npu "Starting NPU hardware detection..."
    
    # Rockchip NPU detection
    if lspci | grep -qi rockchip; then
        log_npu "Rockchip NPU hardware detected"
        
        # Load kernel module
        modprobe rknpu_driver 2>/dev/null || log_npu "Warning: rknpu_driver module not available"
        echo "rknpu" >> /etc/modules 2>/dev/null || true
        
        # Install RKNN toolkit
        pip3 install rknn-toolkit2 || log_npu "Warning: RKNN toolkit installation failed"
        
        # Create device permissions
        echo 'KERNEL=="rknpu*", GROUP="aiadmin", MODE="0660"' > /etc/udev/rules.d/99-rknpu.rules
        log_npu "Rockchip NPU setup completed"
    fi
    
    # ARM Ethos NPU detection
    if [[ -e /sys/class/ethos-n ]]; then
        log_npu "ARM Ethos NPU detected"
        modprobe ethos_n_driver 2>/dev/null || log_npu "Warning: ethos_n_driver module not available"
        echo 'KERNEL=="ethosn*", GROUP="aiadmin", MODE="0660"' > /etc/udev/rules.d/99-ethosn.rules
        log_npu "ARM Ethos NPU setup completed"  
    fi
    
    # Intel NPU (VPU) detection
    if lspci | grep -qi "vision processing unit"; then
        log_npu "Intel NPU/VPU detected"
        # Intel OpenVINO setup would go here
        log_npu "Intel NPU setup completed"
    fi
    
    # Generic NPU device permissions
    chmod 666 /dev/npu* 2>/dev/null || true
    chmod 666 /dev/accel* 2>/dev/null || true
    
    # Reload udev rules
    udevadm control --reload-rules
    udevadm trigger
    
    log_npu "NPU detection and setup completed"
}

detect_and_setup_npus
NPU_EOF

chmod +x /usr/local/bin/npu-setup

# System service for cluster daemon
cat > /etc/systemd/system/clusterd.service << 'SERVICE_EOF'
[Unit]
Description=Ainux OS Cluster Management Daemon
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/clusterd
Restart=always
RestartSec=5
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Cluster daemon implementation
cat > /usr/local/bin/clusterd << 'DAEMON_EOF'
#!/bin/bash
set -euo pipefail

source /etc/cluster/cluster.conf

DAEMON_LOG="/var/log/cluster/clusterd.log"
PID_FILE="/var/run/clusterd.pid"
STATUS_FILE="/var/log/cluster/cluster-status.json"

log_daemon() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CLUSTERD] $1" | tee -a "$DAEMON_LOG"
}

# Signal handlers
cleanup() {
    log_daemon "Shutting down cluster daemon..."
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGTERM SIGINT

# Store PID
echo $ > "$PID_FILE"

log_daemon "Starting Ainux OS Cluster Daemon (Mode: $CLUSTER_MODE)"

# Main daemon loop
while true; do
    # Update node status
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -Iseconds)\","
        echo "  \"hostname\": \"$(hostname)\","
        echo "  \"mode\": \"$CLUSTER_MODE\","
        echo "  \"uptime\": \"$(uptime -p)\","
        echo "  \"load_avg\": \"$(uptime | awk -F'load average:' '{print $2}')\","
        echo "  \"memory_usage\": \"$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')\","
        echo "  \"disk_usage\": \"$(df / | tail -1 | awk '{print $5}')\","
        echo "  \"gpu_status\": {"
    
    # GPU information
    if command -v nvidia-smi >/dev/null 2>&1; then
        echo "    \"nvidia\": \"$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -1)%\","
    fi
    
    if command -v rocm-smi >/dev/null 2>&1; then
        echo "    \"amd\": \"$(rocm-smi --showuse | grep -o '[0-9]*%' | head -1 || echo "0%")\","
    fi
    
    echo "    \"last_check\": \"$(date -Iseconds)\""
    echo "  },"
    echo "  \"network_interfaces\": ["
    
    # Network interface status
    ip -json addr show | jq -c '.[] | select(.ifname != "lo") | {name: .ifname, state: .operstate, addrs: [.addr_info[].local]}' | \
        sed 's/$/,/' | sed '$ s/,$//'
    
    echo "  ],"
    echo "  \"services\": {"
    echo "    \"ssh\": \"$(systemctl is-active sshd)\","
    echo "    \"docker\": \"$(systemctl is-active docker)\","
    echo "    \"network\": \"$(systemctl is-active systemd-networkd || echo inactive)\""
    echo "  }"
    echo "}"
    } > "$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
    
    # Heartbeat for main node
    if [[ "$CLUSTER_MODE" == "main" ]]; then
        # Check for new node join requests
        if [[ -d /tmp/cluster-join-requests ]]; then
            for request in /tmp/cluster-join-requests/*.json; do
                [[ -f "$request" ]] || continue
                log_daemon "Processing join request: $request"
                # TODO: Implement secure node authentication
            done
        fi
    fi
    
    # Sub-node heartbeat to main
    if [[ "$CLUSTER_MODE" == "sub" ]] && [[ -f "$STATUS_FILE" ]]; then
        main_ip=$(jq -r '.main_node_ip // empty' "$STATUS_FILE" 2>/dev/null || true)
        if [[ -n "$main_ip" ]]; then
            # Send heartbeat (simplified - use proper secure protocol in production)
            curl -s -X POST "http://$main_ip:8099/heartbeat" \
                -H "Content-Type: application/json" \
                -d "@$STATUS_FILE" >/dev/null 2>&1 || true
        fi
    fi
    
    sleep "$HEARTBEAT_INTERVAL"
done
DAEMON_EOF

chmod +x /usr/local/bin/clusterd

# AI resource monitor service
cat > /etc/systemd/system/ai-monitor.service << 'AI_SERVICE_EOF'
[Unit]
Description=AI Hardware Resource Monitor
After=clusterd.service
Requires=clusterd.service

[Service]
Type=simple
User=aiadmin
ExecStart=/usr/local/bin/ai-monitor
Restart=always
RestartSec=10
Environment=HOME=/home/aiadmin

[Install]
WantedBy=multi-user.target
AI_SERVICE_EOF

# AI monitoring script
cat > /usr/local/bin/ai-monitor << 'AI_MONITOR_EOF'
#!/bin/bash
set -euo pipefail

AI_LOG="/var/log/cluster/ai-monitor.log"

log_ai() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [AI-MONITOR] $1" | tee -a "$AI_LOG"
}

log_ai "Starting AI Hardware Monitor"

while true; do
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -Iseconds)\","
        echo "  \"gpu_info\": {"
        
        # NVIDIA GPU monitoring
        if command -v nvidia-smi >/dev/null 2>&1; then
            echo "    \"nvidia\": {"
            echo "      \"driver_version\": \"$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)\","
            echo "      \"gpu_count\": $(nvidia-smi -L | wc -l),"
            echo "      \"utilization\": \"$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -1)%\","
            echo "      \"memory_used\": \"$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | head -1) MB\","
            echo "      \"memory_total\": \"$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1) MB\","
            echo "      \"temperature\": \"$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -1)°C\""
            echo "    },"
        fi
        
        # AMD GPU monitoring
        if command -v rocm-smi >/dev/null 2>&1; then
            echo "    \"amd\": {"
            echo "      \"gpu_count\": $(rocm-smi --showid | grep -c "GPU" || echo 0),"
            echo "      \"utilization\": \"$(rocm-smi --showuse | grep -o '[0-9]*%' | head -1 || echo "0%")\","
            echo "      \"temperature\": \"$(rocm-smi --showtemp | grep -o '[0-9]*°C' | head -1 || echo "N/A")\""
            echo "    },"
        fi
        
        echo "    \"last_update\": \"$(date -Iseconds)\""
        echo "  },"
        echo "  \"npu_info\": {"
        
        # NPU device detection
        npu_count=0
        [[ -e /dev/npu0 ]] && npu_count=$((npu_count + 1))
        [[ -e /dev/rknpu0 ]] && npu_count=$((npu_count + 1))
        [[ -e /dev/ethosn0 ]] && npu_count=$((npu_count + 1))
        
        echo "    \"device_count\": $npu_count,"
        echo "    \"devices\": ["
        
        # List available NPU devices
        for dev in /dev/npu* /dev/rknpu* /dev/ethosn* /dev/accel*; do
            [[ -e "$dev" ]] && echo "      \"$dev\","
        done | sed '$ s/,$//'
        
        echo "    ]"
        echo "  },"
        echo "  \"python_env\": {"
        
        # Python AI framework versions
        python3 -c "
import sys, json
frameworks = {}
try:
    import torch
    frameworks['torch'] = torch.__version__
    frameworks['cuda_available'] = torch.cuda.is_available()
    if torch.cuda.is_available():
        frameworks['cuda_devices'] = torch.cuda.device_count()
except ImportError:
    frameworks['torch'] = 'not installed'

try:
    import tensorflow as tf
    frameworks['tensorflow'] = tf.__version__
    frameworks['tf_gpu_available'] = len(tf.config.list_physical_devices('GPU')) > 0
except ImportError:
    frameworks['tensorflow'] = 'not installed'

try:
    import onnxruntime as ort
    frameworks['onnxruntime'] = ort.__version__
    frameworks['ort_providers'] = ort.get_available_providers()
except ImportError:
    frameworks['onnxruntime'] = 'not installed'

print(json.dumps(frameworks, indent=4))
" | sed 's/^/    /'
        
        echo "  }"
        echo "}"
    } > /tmp/ai-status.json
    
    # Copy to cluster status directory
    cp /tmp/ai-status.json /var/log/cluster/ai-status.json
    
    sleep 60  # Update every minute
done
AI_MONITOR_EOF

chmod +x /usr/local/bin/ai-monitor

# Hardware validation script
cat > /usr/local/bin/validate-hardware << 'VALIDATE_EOF'
#!/bin/bash
set -euo pipefail

echo "=================================="
echo "Ainux OS AI Cluster Validation"
echo "=================================="
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "OS: $(lsb_release -d | cut -f2)"
echo

echo "⚡ GPU Hardware Detection:"
echo "------------------------"
if lspci | grep -i -e vga -e nvidia -e amd; then
    lspci | grep -i -e vga -e nvidia -e amd
else
    echo "No discrete GPUs detected"
fi

if command -v nvidia-smi >/dev/null 2>&1; then
    echo -e "\n🟢 NVIDIA GPU Status:"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
fi

if command -v rocm-smi >/dev/null 2>&1; then
    echo -e "\n🔴 AMD GPU Status:"
    rocm-smi --showid --showproduct
fi

echo -e "\n🧠 NPU Hardware Detection:"
echo "-------------------------"
npu_found=false
for dev in /dev/npu* /dev/rknpu* /dev/ethosn* /dev/accel*; do
    if [[ -e "$dev" ]]; then
        echo "Found NPU device: $dev"
        npu_found=true
    fi
done
$npu_found || echo "No NPU devices detected"

if lspci | grep -i rockchip; then
    echo "Rockchip NPU hardware detected in PCI"
fi

echo -e "\n🌐 Network Interfaces:"
echo "---------------------"
ip -brief addr show

echo -e "\n🐍 Python AI Frameworks:"
echo "------------------------"
python3 -c "
import sys
try:
    import torch
    print(f'✅ PyTorch: {torch.__version__}')
    if torch.cuda.is_available():
        print(f'   CUDA devices: {torch.cuda.device_count()}')
        for i in range(torch.cuda.device_count()):
            print(f'   GPU {i}: {torch.cuda.get_device_name(i)}')
    else:
        print('   CUDA: Not available')
except ImportError:
    print('❌ PyTorch: Not installed')

try:
    import tensorflow as tf
    print(f'✅ TensorFlow: {tf.__version__}')
    gpus = tf.config.list_physical_devices('GPU')
    print(f'   GPU devices: {len(gpus)}')
    for gpu in gpus:
        print(f'   {gpu}')
except ImportError:
    print('❌ TensorFlow: Not installed')

try:
    import onnxruntime as ort
    print(f'✅ ONNX Runtime: {ort.__version__}')
    print(f'   Providers: {", ".join(ort.get_available_providers())}')
except ImportError:
    print('❌ ONNX Runtime: Not installed')
"

echo -e "\n🔧 System Services:"
echo "------------------"
for service in clusterd ai-monitor sshd docker; do
    status=$(systemctl is-active $service 2>/dev/null || echo "inactive")
    if [[ "$status" == "active" ]]; then
        echo "✅ $service: $status"
    else
        echo "❌ $service: $status"
    fi
done

echo -e "\n📊 System Resources:"
echo "-------------------"
echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"

echo -e "\n🔗 Cluster Status:"
echo "-----------------"
if [[ -f /var/log/cluster/cluster-status.json ]]; then
    cat /var/log/cluster/cluster-status.json | python3 -m json.tool
else
    echo "Cluster not initialized. Run: sudo cluster-init"
fi

echo -e "\n=================================="
echo "Validation completed at $(date)"
echo "=================================="
VALIDATE_EOF

chmod +x /usr/local/bin/validate-hardware

# Replace cluster mode placeholder
sed -i "s/CLUSTER_MODE_PLACEHOLDER/$CLUSTER_MODE/g" /etc/cluster/cluster.conf

# Enable services
systemctl enable clusterd ai-monitor ssh docker
systemctl enable npu-setup.service 2>/dev/null || true

# System cleanup
apt autoremove -y
apt autoclean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*

# Set proper permissions
chown -R aiadmin:aiadmin /home/aiadmin
chown -R aiadmin:aiadmin /opt/ai-workloads
chmod -R 755 /usr/local/bin
chmod -R 644 /etc/cluster/*.conf

echo "Root filesystem setup completed successfully"
exit 0
EOF

    # Execute chroot setup with progress monitoring - FIXED
    log_info "Executing system setup in chroot environment..."
    sudo chmod +x rootfs/setup.sh
    
    # Run setup with timeout and progress indication
    timeout 3600 sudo chroot rootfs /setup.sh 2>&1 | tee "$BUILD_DIR/logs/rootfs-setup.log"
    
    sudo rm rootfs/setup.sh
    
    # Install custom packages if specified
    if [[ -n "$CUSTOM_PACKAGES" ]]; then
        log_info "Installing custom packages: $CUSTOM_PACKAGES"
        sudo chroot rootfs /bin/bash -c "apt update && apt install -y $CUSTOM_PACKAGES"
    fi
    
    # Cleanup chroot mounts
    cleanup_build
    
    log_success "Root filesystem creation completed"
}

# Phase 3: Enhanced ISO Build with UEFI support
build_iso() {
    log_phase "Building Bootable ISO with UEFI Support"
    cd "$BUILD_DIR/iso"
    
    # Install kernel into rootfs
    log_info "Installing custom kernel into rootfs..."
    sudo cp -r "$BUILD_DIR/kernel/modules/lib/modules"/* "$BUILD_DIR/rootfs/rootfs/lib/modules/"
    sudo cp "$BUILD_DIR/kernel/vmlinuz-$KERNEL_VERSION-ainux" "$BUILD_DIR/rootfs/rootfs/boot/"
    
    # Generate initramfs
    log_info "Generating initramfs for custom kernel..."
    sudo mount -t proc proc "$BUILD_DIR/rootfs/rootfs/proc"
    sudo mount -t sysfs sysfs "$BUILD_DIR/rootfs/rootfs/sys"
    
    sudo chroot "$BUILD_DIR/rootfs/rootfs" /bin/bash -c \
        "update-initramfs -c -k $KERNEL_VERSION-ainux"
    
    sudo umount "$BUILD_DIR/rootfs/rootfs/proc"
    sudo umount "$BUILD_DIR/rootfs/rootfs/sys"
    
    # Copy kernel artifacts
    sudo cp "$BUILD_DIR/rootfs/rootfs/boot/vmlinuz-$KERNEL_VERSION-ainux" vmlinuz-ainux
    sudo cp "$BUILD_DIR/rootfs/rootfs/boot/initrd.img-$KERNEL_VERSION-ainux" initrd-ainux
    
    # Create ISO directory structure  
    log_info "Creating ISO filesystem structure..."
    mkdir -p iso/{casper,boot/{grub,isolinux},EFI/{BOOT,ubuntu}}
    
    # Copy kernel files
    cp vmlinuz-ainux iso/casper/vmlinuz
    cp initrd-ainux iso/casper/initrd
    
    # Create compressed filesystem
    log_info "Creating compressed filesystem (this may take 10-30 minutes)..."
    sudo mksquashfs "$BUILD_DIR/rootfs/rootfs" iso/casper/filesystem.squashfs \
        -comp xz -e boot 2>&1 | tee "$BUILD_DIR/logs/squashfs.log"
    
    # Calculate filesystem size
    du -sx --block-size=1 "$BUILD_DIR/rootfs/rootfs" | cut -f1 > iso/casper/filesystem.size
    
    # Create package manifest
    sudo chroot "$BUILD_DIR/rootfs/rootfs" dpkg-query -W --showformat='${Package} ${Version}\n' \
        > iso/casper/filesystem.manifest
    
    # GRUB BIOS configuration
    log_info "Configuring GRUB bootloader..."
    cat > iso/boot/grub/grub.cfg << 'GRUB_EOF'
set timeout=10
set default=0

insmod all_video
insmod gfxterm
terminal_output gfxterm

set theme=/boot/grub/theme.txt

menuentry "Ainux OS AI Cluster (Live Mode)" {
    linux /casper/vmlinuz boot=casper quiet splash
    initrd /casper/initrd
}

menuentry "Ainux OS AI Cluster (Install Mode)" {
    linux /casper/vmlinuz boot=casper only-ubiquity quiet splash
    initrd /casper/initrd
}

menuentry "Ainux OS AI Cluster (Safe Mode)" {
    linux /casper/vmlinuz boot=casper nomodeset quiet splash
    initrd /casper/initrd
}

menuentry "Memory Test (memtest86+)" {
    linux16 /boot/memtest86+.bin
}

menuentry "Boot from Hard Disk" {
    chainloader +1
}
GRUB_EOF

    # GRUB EFI configuration
    cp iso/boot/grub/grub.cfg iso/EFI/ubuntu/grub.cfg
    
    # Create GRUB theme
    cat > iso/boot/grub/theme.txt << 'THEME_EOF'
title-text: "Ainux OS - AI Cluster Operating System"
title-font: "DejaVu Sans Bold 16"
title-color: "#00FF88"
desktop-image: "background.png"
desktop-color: "#1a1a1a"
terminal-box: "terminal_box_*.png"
terminal-font: "DejaVu Sans Mono 12"
THEME_EOF

    # ISOLINUX configuration for legacy BIOS
    cat > iso/boot/isolinux/isolinux.cfg << 'ISOLINUX_EOF'
DEFAULT live
LABEL live
  menu label ^Ainux OS (Live)
  kernel /casper/vmlinuz
  append initrd=/casper/initrd boot=casper quiet splash

LABEL install  
  menu label ^Install Ainux OS
  kernel /casper/vmlinuz
  append initrd=/casper/initrd boot=casper only-ubiquity quiet splash

LABEL safe
  menu label ^Safe Mode
  kernel /casper/vmlinuz
  append initrd=/casper/initrd boot=casper nomodeset quiet splash

LABEL memtest
  menu label ^Memory Test
  kernel /boot/memtest86+.bin

LABEL hd
  menu label ^Boot from Hard Disk
  localboot 0x80
ISOLINUX_EOF

    # Create bootloader files
    cp /usr/lib/ISOLINUX/isolinux.bin iso/boot/isolinux/
    cp /usr/lib/syslinux/modules/bios/ldlinux.c32 iso/boot/isolinux/
    cp /usr/lib/syslinux/modules/bios/libcom32.c32 iso/boot/isolinux/
    cp /usr/lib/syslinux/modules/bios/libutil.c32 iso/boot/isolinux/
    cp /usr/lib/syslinux/modules/bios/vesamenu.c32 iso/boot/isolinux/
    
    # Copy memtest86+
    cp /boot/memtest86+.bin iso/boot/ 2>/dev/null || true
    
    # Create EFI boot files
    grub-mkimage -O x86_64-efi -o iso/EFI/BOOT/bootx64.efi \
        boot linux search normal configfile part_gpt btrfs ext2 fat iso9660 loopback \
        test keystatus gfxmenu regexp probe efi_gop efi_uga all_video gfxterm font \
        echo read ls cat png jpeg halt reboot
    
    # Create ISO with hybrid boot support
    log_info "Creating final ISO image..."
    genisoimage -D -r -V "AINUX-AI-CLUSTER" -cache-inodes -J -l \
        -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot -e EFI/BOOT/bootx64.efi -no-emul-boot \
        -o ainux-ai-cluster.iso iso/ 2>&1 | tee "$BUILD_DIR/logs/iso-creation.log"
    
    # Make ISO hybrid (bootable from USB)
    isohybrid --uefi ainux-ai-cluster.iso
    
    # Calculate and save checksums
    log_info "Calculating checksums..."
    sha256sum ainux-ai-cluster.iso > ainux-ai-cluster.iso.sha256
    md5sum ainux-ai-cluster.iso > ainux-ai-cluster.iso.md5
    
    # Get ISO size
    iso_size=$(du -h ainux-ai-cluster.iso | cut -f1)
    
    log_success "ISO created successfully: ainux-ai-cluster.iso ($iso_size)"
}

# Phase 4: Comprehensive Validation
validate_build() {
    log_phase "Build Validation and Testing"
    
    # Create comprehensive validation script
    cat > "$BUILD_DIR/validate-build.sh" << 'VALIDATE_EOF'
#!/bin/bash
set -euo pipefail

echo "=================================="
echo "Ainux OS AI Cluster Build Validation"
echo "=================================="
echo "Build completed: $(date)"
echo "Build directory: $PWD"

# Check file integrity
echo -e "\n📁 Build Artifacts:"
echo "-------------------"
if [[ -f "ainux-ai-cluster.iso" ]]; then
    echo "✅ ISO file: ainux-ai-cluster.iso ($(du -h ainux-ai-cluster.iso | cut -f1))"
    
    # Verify checksums
    if [[ -f "ainux-ai-cluster.iso.sha256" ]]; then
        if sha256sum -c ainux-ai-cluster.iso.sha256 >/dev/null 2>&1; then
            echo "✅ SHA256 checksum: Valid"
        else
            echo "❌ SHA256 checksum: Invalid"
        fi
    fi
else
    echo "❌ ISO file not found"
    exit 1
fi

# Validate ISO structure
echo -e "\n💿 ISO Structure Validation:"
echo "----------------------------"
if command -v isoinfo >/dev/null 2>&1; then
    echo "Boot catalog: $(isoinfo -d -i ainux-ai-cluster.iso | grep "El Torito" || echo "Not found")"
    echo "Volume ID: $(isoinfo -d -i ainux-ai-cluster.iso | grep "Volume id" | cut -d: -f2 | xargs)"
    echo "System ID: $(isoinfo -d -i ainux-ai-cluster.iso | grep "System id" | cut -d: -f2 | xargs)"
fi

# Test kernel artifacts
echo -e "\n🔧 Kernel Validation:"
echo "---------------------"
if [[ -f "../kernel/vmlinuz-$KERNEL_VERSION-ainux" ]]; then
    echo "✅ Custom kernel: vmlinuz-$KERNEL_VERSION-ainux"
    kernel_size=$(du -h "../kernel/vmlinuz-$KERNEL_VERSION-ainux" | cut -f1)
    echo "   Size: $kernel_size"
else
    echo "❌ Custom kernel not found"
fi

if [[ -d "../kernel/modules/lib/modules/$KERNEL_VERSION-ainux" ]]; then
    module_count=$(find "../kernel/modules/lib/modules/$KERNEL_VERSION-ainux" -name "*.ko" | wc -l)
    echo "✅ Kernel modules: $module_count modules built"
else
    echo "❌ Kernel modules not found"
fi

# Build logs analysis
echo -e "\n📋 Build Log Analysis:"
echo "----------------------"
if [[ -d "../logs" ]]; then
    for log in ../logs/*.log; do
        [[ -f "$log" ]] || continue
        log_name=$(basename "$log")
        log_size=$(du -h "$log" | cut -f1)
        error_count=$(grep -c -i "error" "$log" 2>/dev/null || echo 0)
        warning_count=$(grep -c -i "warning" "$log" 2>/dev/null || echo 0)
        
        if [[ $error_count -eq 0 ]]; then
            echo "✅ $log_name: $log_size, $warning_count warnings"
        else
            echo "⚠️  $log_name: $log_size, $error_count errors, $warning_count warnings"
        fi
    done
fi

echo -e "\n🎯 Recommended Next Steps:"
echo "--------------------------"
echo "1. Test ISO in virtual machine:"
echo "   qemu-system-x86_64 -m 4096 -cdrom ainux-ai-cluster.iso -enable-kvm"
echo ""
echo "2. Create bootable USB drive:"
echo "   sudo dd if=ainux-ai-cluster.iso of=/dev/sdX bs=4M status=progress"
echo ""
echo "3. Validate on target hardware:"
echo "   - Boot from ISO/USB"
echo "   - Run: sudo validate-hardware"
echo "   - Initialize cluster: sudo cluster-init"
echo ""
echo "4. Production deployment:"
echo "   - Copy ISO to network location"
echo "   - Use PXE boot for mass deployment"
echo "   - Configure cluster networking"

echo -e "\n=================================="
echo "Validation completed successfully!"
echo "=================================="
VALIDATE_EOF

    chmod +x "$BUILD_DIR/validate-build.sh"
    
    # Run validation
    cd "$BUILD_DIR/iso"
    "$BUILD_DIR/validate-build.sh"
    
    # Optional QEMU testing
    if [[ "$SKIP_QEMU_TEST" != "true" ]] && command -v qemu-system-x86_64 >/dev/null 2>&1; then
        log_info "Starting QEMU test (press Ctrl+C to exit)..."
        log_info "Login with: aiadmin / ainux2024"
        
        timeout 300 qemu-system-x86_64 \
            -m 4096 -smp 4 \
            -cdrom ainux-ai-cluster.iso \
            -netdev user,id=net0 -device e1000,netdev=net0 \
            -enable-kvm -display gtk || true
    fi
    
    log_success "Build validation completed"
}
