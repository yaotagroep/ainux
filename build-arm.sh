#!/bin/bash
# Ainux OS ARM Build Script
# Optimized for ARM64 devices including Raspberry Pi and edge computing
# Requires Ubuntu 22.04 host with 20GB+ disk space and internet connection

set -euo pipefail
IFS=$'\n\t'

# Color output for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍓 Ainux OS ARM Edition Builder${NC}"
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}🔧 Building ARM64 OS for Raspberry Pi and edge devices${NC}"
echo -e "${GREEN}⚡ Optimized for low power consumption and IoT workloads${NC}"
echo -e "${GREEN}🤖 Includes edge AI acceleration and GPIO support${NC}"
echo ""

# Configuration for ARM variant
export BUILD_VARIANT="arm"
export ENABLE_GUI="false"  # Can be overridden with ENABLE_GUI=true
export ARCH="arm64"
export CUSTOM_PACKAGES="python3-gpiozero python3-rpi.gpio i2c-tools python3-numpy"

# ARM-specific environment variables
export ARM_OPTIMIZATION="true"
export GPIO_SUPPORT="true"
export LOW_POWER_MODE="true"
export EDGE_AI_SUPPORT="true"
export IOT_FEATURES="true"
export RASPBERRY_PI_SUPPORT="true"

# Hardware acceleration support - ARM optimized
export TPU_SUPPORT="true"     # Coral TPU Edge support
export NPU_SUPPORT="true"     # ARM Ethos, Rockchip NPU
export GPU_SUPPORT="true"     # Mali, VideoCore
export CPU_ACCELERATION="true"
export DPU_SUPPORT="false"    # Generally not available on ARM edge

# ARM AI Framework support
export CORAL_TPU_SUPPORT="true"  # Primary TPU option for ARM
export OPENVINO_SUPPORT="true"   # Intel OpenVINO ARM support
export TENSORFLOW_LITE_SUPPORT="true"
export ONNX_RUNTIME_SUPPORT="true"
export RKNN_SUPPORT="true"       # Rockchip NPU support

# Performance settings for ARM builds
export BUILD_THREADS="${BUILD_THREADS:-4}"  # Limited for ARM cross-compilation
export SKIP_QEMU_TEST="${SKIP_QEMU_TEST:-true}"  # Skip QEMU for ARM

# ARM-specific kernel config
export KERNEL_CONFIG="configs/ainux-6.6-arm.config"

# ARM ISO naming
export OUTPUT_ISO_NAME="ainux-arm-${ARCH}"

# Cross-compilation settings
if [[ "$(uname -m)" != "aarch64" ]]; then
    export CROSS_COMPILE="aarch64-linux-gnu-"
    export CROSS_COMPILE_ARM64="aarch64-linux-gnu-"
fi

# Detect if GUI is requested
if [[ "${ENABLE_GUI:-false}" == "true" ]]; then
    CUSTOM_PACKAGES="${CUSTOM_PACKAGES} lightdm xfce4-session xfce4-panel xfce4-desktop"
    echo -e "${GREEN}🖥️  GUI mode enabled for ARM build${NC}"
fi

echo -e "${YELLOW}🔧 Configuration:${NC}"
echo -e "  📦 Build Variant: ${BUILD_VARIANT}"
echo -e "  🖥️  GUI Enabled: ${ENABLE_GUI}"
echo -e "  🏗️  Architecture: ${ARCH}"
echo -e "  🧵 Build Threads: ${BUILD_THREADS}"
echo -e "  ⚙️  Kernel Config: ${KERNEL_CONFIG}"
echo -e "  ⚡ Low Power Mode: ${LOW_POWER_MODE}"
echo -e "  🔧 GPIO Support: ${GPIO_SUPPORT}"
echo -e "  🤖 Edge AI: ${EDGE_AI_SUPPORT}"
echo -e "  🧠 TPU Support: ${TPU_SUPPORT}"
echo -e "  ⚡ NPU Support: ${NPU_SUPPORT}"
echo -e "  🎨 GPU Support: ${GPU_SUPPORT}"
echo -e "  🍓 RPi Support: ${RASPBERRY_PI_SUPPORT}"
echo ""

# Check prerequisites
if ! command -v ./ainux-builder.sh &> /dev/null; then
    echo -e "${RED}❌ Error: ainux-builder.sh not found in current directory${NC}"
    exit 1
fi

if [[ ! -f "configs/ainux-6.6-arm.config" ]]; then
    echo -e "${RED}❌ Error: ARM kernel config not found${NC}"
    exit 1
fi

# ARM cross-compilation check
if [[ "$(uname -m)" != "aarch64" ]]; then
    echo -e "${YELLOW}🔄 Cross-compilation mode: Building ARM64 on $(uname -m)${NC}"
    if ! command -v aarch64-linux-gnu-gcc &> /dev/null; then
        echo -e "${YELLOW}📦 Installing ARM64 cross-compilation tools...${NC}"
        sudo apt-get update && sudo apt-get install -y gcc-aarch64-linux-gnu || {
            echo -e "${RED}❌ Failed to install cross-compilation tools${NC}"
            exit 1
        }
    fi
fi

# Display hardware requirements
echo -e "${YELLOW}📋 ARM Edition Hardware Requirements:${NC}"
echo -e "  🔹 CPU: ARM64 (AArch64) - Raspberry Pi 4+, ARM Cortex"
echo -e "  🔹 RAM: 2GB minimum, 8GB recommended"
echo -e "  🔹 Storage: 16GB SD card minimum, 32GB+ recommended"
echo -e "  🔹 Power: 5V 3A power supply (USB-C for RPi 4+)"
echo -e "  🔹 Cooling: Heat sink recommended for sustained loads"
echo -e "  🔹 Expansion: GPIO header for hardware projects"
echo ""

# Display supported devices
echo -e "${YELLOW}🍓 Supported ARM Devices:${NC}"
echo -e "  🔹 Raspberry Pi 4 Model B (4GB/8GB)"
echo -e "  🔹 Raspberry Pi 5 (all variants)"
echo -e "  🔹 Raspberry Pi 400 (keyboard computer)"
echo -e "  🔹 ARM-based single board computers"
echo -e "  🔹 Edge computing devices with ARM64 CPU"
echo -e "  🔹 Industrial IoT and automation systems"
echo ""

# Display features
echo -e "${YELLOW}⚡ ARM Edition Features:${NC}"
echo -e "  🔹 Raspberry Pi GPIO library support"
echo -e "  🔹 I2C, SPI, UART hardware interfaces"
echo -e "  🔹 ARM Mali GPU support (VideoCore VI)"
echo -e "  🔹 Edge AI acceleration (ARM Ethos NPU, Coral TPU)"
echo -e "  🔹 Low-power optimizations for battery operation"
echo -e "  🔹 IoT protocol support (MQTT, CoAP, LoRaWAN)"
echo -e "  🔹 Real-time capabilities for industrial control"
echo ""

# Run validation
echo -e "${BLUE}🔍 Running pre-build validation...${NC}"
if [[ -f "./validate-build-env.sh" ]]; then
    ./validate-build-env.sh
else
    echo -e "${YELLOW}⚠️  Build environment validator not found, continuing...${NC}"
fi

# ARM-specific checks
echo -e "${BLUE}🔧 Performing ARM-specific checks...${NC}"
if [[ "$(uname -m)" != "aarch64" ]] && command -v aarch64-linux-gnu-gcc &> /dev/null; then
    echo -e "${GREEN}✅ ARM64 cross-compiler found: $(aarch64-linux-gnu-gcc --version | head -1)${NC}"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    echo -e "${GREEN}✅ Native ARM64 build environment detected${NC}"
else
    echo -e "${RED}❌ ARM64 toolchain not available${NC}"
    exit 1
fi

# Start the build
echo -e "${GREEN}🚀 Starting Ainux OS ARM Edition build...${NC}"
echo -e "${GREEN}⏱️  Estimated build time: 90-180 minutes (cross-compilation)${NC}"
echo -e "${YELLOW}💡 Tip: ARM builds take longer due to cross-compilation${NC}"
echo ""

# Execute the main builder with ARM configuration
exec ./ainux-builder.sh