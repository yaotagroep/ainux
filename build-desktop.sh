#!/bin/bash
# Ainux OS Desktop Build Script
# Optimized for desktop workstations with full GUI support, gaming, and multimedia
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

echo -e "${BLUE}🖥️  Ainux OS Desktop Edition Builder${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}✨ Building desktop-optimized OS with full GUI support${NC}"
echo -e "${GREEN}🎮 Includes gaming optimizations and multimedia support${NC}"
echo -e "${GREEN}🎨 Features XFCE4 desktop environment and AI acceleration${NC}"
echo ""

# Configuration for Desktop variant
export BUILD_VARIANT="desktop"
export ENABLE_GUI="true"
export ARCH="x86_64"
export CUSTOM_PACKAGES="firefox thunderbird gimp vlc steam lutris discord obs-studio"

# Desktop-specific environment variables
export DESKTOP_ENVIRONMENT="xfce4"
export GAMING_SUPPORT="true"
export MULTIMEDIA_CODECS="true"
export BLUETOOTH_SUPPORT="true"
export WIFI_SUPPORT="true"

# Hardware acceleration support - Full stack enabled
export TPU_SUPPORT="true"
export NPU_SUPPORT="true"
export GPU_SUPPORT="true"
export CPU_ACCELERATION="true"
export DPU_SUPPORT="true"

# AI Framework support
export CUDA_SUPPORT="true"
export ROCM_SUPPORT="true"
export OPENVINO_SUPPORT="true"
export CORAL_TPU_SUPPORT="true"
export TENSORRT_SUPPORT="true"

# Performance settings for desktop builds
export BUILD_THREADS="${BUILD_THREADS:-$(nproc)}"
export SKIP_QEMU_TEST="${SKIP_QEMU_TEST:-false}"

echo -e "${YELLOW}🔧 Configuration:${NC}"
echo -e "  📦 Build Variant: ${BUILD_VARIANT}"
echo -e "  🖥️  GUI Enabled: ${ENABLE_GUI}"
echo -e "  🏗️  Architecture: ${ARCH}"
echo -e "  🧵 Build Threads: ${BUILD_THREADS}"
echo -e "  🎮 Gaming Support: ${GAMING_SUPPORT}"
echo -e "  🎵 Multimedia: ${MULTIMEDIA_CODECS}"
echo -e "  📡 WiFi/Bluetooth: ${WIFI_SUPPORT}/${BLUETOOTH_SUPPORT}"
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

if [[ ! -f "configs/ainux-6.6-desktop.config" ]]; then
    echo -e "${RED}❌ Error: Desktop kernel config not found${NC}"
    exit 1
fi

# Display hardware requirements
echo -e "${YELLOW}📋 Desktop Edition Hardware Requirements:${NC}"
echo -e "  🔹 CPU: Intel/AMD x86_64 (4+ cores recommended)"
echo -e "  🔹 RAM: 4GB minimum, 16GB recommended"
echo -e "  🔹 Storage: 25GB minimum, 50GB+ SSD recommended"
echo -e "  🔹 GPU: Dedicated GPU recommended for gaming/AI"
echo -e "  🔹 Audio: HD Audio or USB Audio device"
echo -e "  🔹 Network: Ethernet or WiFi adapter"
echo ""

# Run validation
echo -e "${BLUE}🔍 Running pre-build validation...${NC}"
if [[ -f "./validate-build-env.sh" ]]; then
    ./validate-build-env.sh
else
    echo -e "${YELLOW}⚠️  Build environment validator not found, continuing...${NC}"
fi

# Start the build
echo -e "${GREEN}🚀 Starting Ainux OS Desktop Edition build...${NC}"
echo -e "${GREEN}⏱️  Estimated build time: 45-90 minutes depending on hardware${NC}"
echo ""

# Execute the main builder with desktop configuration
exec ./ainux-builder.sh