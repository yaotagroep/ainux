#!/bin/bash
# Ainux OS Server Build Script
# Optimized for enterprise servers with high availability and security
# Requires Ubuntu 22.04 host with 40GB+ disk space and internet connection

set -euo pipefail
IFS=$'\n\t'

# Color output for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏢 Ainux OS Server Edition Builder${NC}"
echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}🛡️  Building enterprise-grade server OS${NC}"
echo -e "${GREEN}🔒 Enhanced security, virtualization, and container support${NC}"
echo -e "${GREEN}⚡ High-performance networking and storage optimization${NC}"
echo ""

# Configuration for Server variant
export BUILD_VARIANT="server"
export ENABLE_GUI="false"
export ARCH="x86_64"
export CUSTOM_PACKAGES="docker.io kubernetes-client nginx haproxy postgresql mysql-server"

# Server-specific environment variables
export SERVER_KERNEL="true"
export SECURITY_HARDENING="true"
export VIRTUALIZATION_SUPPORT="true"
export CONTAINER_RUNTIME="true"
export ENTERPRISE_STORAGE="true"
export HIGH_AVAILABILITY="true"

# Hardware acceleration support - Full enterprise stack
export TPU_SUPPORT="true"
export NPU_SUPPORT="true"
export GPU_SUPPORT="true"
export CPU_ACCELERATION="true"
export DPU_SUPPORT="true"

# Enterprise AI Framework support
export CUDA_SUPPORT="true"
export ROCM_SUPPORT="true"
export OPENVINO_SUPPORT="true"
export CORAL_TPU_SUPPORT="false"  # Typically not needed on servers
export TENSORRT_SUPPORT="true"
export TRITON_SUPPORT="true"  # NVIDIA Triton Inference Server

# Performance settings for server builds
export BUILD_THREADS="${BUILD_THREADS:-$(nproc)}"
export SKIP_QEMU_TEST="${SKIP_QEMU_TEST:-false}"

# Server-specific kernel config
export KERNEL_CONFIG="configs/ainux-6.6-server.config"

# Server ISO naming
export OUTPUT_ISO_NAME="ainux-server-${ARCH}"

echo -e "${YELLOW}🔧 Configuration:${NC}"
echo -e "  📦 Build Variant: ${BUILD_VARIANT}"
echo -e "  🖥️  GUI Enabled: ${ENABLE_GUI}"
echo -e "  🏗️  Architecture: ${ARCH}"
echo -e "  🧵 Build Threads: ${BUILD_THREADS}"
echo -e "  ⚙️  Kernel Config: ${KERNEL_CONFIG}"
echo -e "  🛡️  Security Hardening: ${SECURITY_HARDENING}"
echo -e "  🐳 Container Runtime: ${CONTAINER_RUNTIME}"
echo -e "  💾 Enterprise Storage: ${ENTERPRISE_STORAGE}"
echo -e "  🔄 High Availability: ${HIGH_AVAILABILITY}"
echo -e "  🧠 TPU Support: ${TPU_SUPPORT}"
echo -e "  ⚡ NPU Support: ${NPU_SUPPORT}"
echo -e "  🎨 GPU Support: ${GPU_SUPPORT}"
echo -e "  🌐 DPU Support: ${DPU_SUPPORT}"
echo ""

# Check prerequisites
if ! command -v ./ainux-builder.sh &> /dev/null; then
    echo -e "${RED}❌ Error: ainux-builder.sh not found in current directory${NC}"
    exit 1
fi

if [[ ! -f "configs/ainux-6.6-server.config" ]]; then
    echo -e "${RED}❌ Error: Server kernel config not found${NC}"
    exit 1
fi

# Display hardware requirements
echo -e "${YELLOW}📋 Server Edition Hardware Requirements:${NC}"
echo -e "  🔹 CPU: Intel/AMD x86_64 (8+ cores, NUMA support)"
echo -e "  🔹 RAM: 8GB minimum, 64GB+ recommended"
echo -e "  🔹 Storage: 40GB minimum, enterprise SSD/NVMe RAID"
echo -e "  🔹 Network: Enterprise ethernet (1GbE+), redundant preferred"
echo -e "  🔹 Management: IPMI/BMC for remote management"
echo -e "  🔹 Security: TPM 2.0 chip recommended"
echo ""

# Display features
echo -e "${YELLOW}🏢 Server Edition Features:${NC}"
echo -e "  🔹 SELinux and AppArmor security frameworks"
echo -e "  🔹 KVM virtualization with IOMMU support"
echo -e "  🔹 Docker and Kubernetes container platforms"
echo -e "  🔹 Enterprise storage (RAID, LVM, ZFS)"
echo -e "  🔹 High-performance networking (InfiniBand, RDMA)"
echo -e "  🔹 AI inference acceleration (GPU compute)"
echo -e "  🔹 Advanced monitoring and logging"
echo ""

# Run validation
echo -e "${BLUE}🔍 Running pre-build validation...${NC}"
if [[ -f "./validate-build-env.sh" ]]; then
    ./validate-build-env.sh
else
    echo -e "${YELLOW}⚠️  Build environment validator not found, continuing...${NC}"
fi

# Security check
echo -e "${BLUE}🔒 Performing security pre-checks...${NC}"
if command -v openssl &> /dev/null; then
    echo -e "${GREEN}✅ OpenSSL found: $(openssl version)${NC}"
else
    echo -e "${YELLOW}⚠️  OpenSSL not found, some security features may be limited${NC}"
fi

# Start the build
echo -e "${GREEN}🚀 Starting Ainux OS Server Edition build...${NC}"
echo -e "${GREEN}⏱️  Estimated build time: 60-120 minutes depending on hardware${NC}"
echo -e "${YELLOW}💡 Tip: Server builds include extensive security scanning${NC}"
echo ""

# Execute the main builder with server configuration
exec ./ainux-builder.sh