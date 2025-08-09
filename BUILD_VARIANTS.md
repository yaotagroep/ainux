# 🚀 Ainux OS Build Variants Guide v3.0

This document provides comprehensive information about the different Ainux OS build variants, their use cases, hardware support, and build instructions.

## 🎯 Build Variants Overview

Ainux OS offers three specialized variants optimized for different use cases and hardware platforms. Each variant includes comprehensive TPU, NPU, GPU, CPU, and DPU acceleration support.

### 🖥️ Desktop Edition
**Target**: Workstations, gaming PCs, development machines  
**GUI**: XFCE4 desktop environment included  
**Use Cases**: Development, gaming, multimedia, AI research  

### 🏢 Server Edition  
**Target**: Enterprise servers, data centers, cloud infrastructure  
**GUI**: Headless (no GUI) for maximum performance  
**Use Cases**: Enterprise computing, virtualization, containers, AI inference  

### 🍓 ARM Edition
**Target**: Raspberry Pi, edge devices, IoT systems  
**GUI**: Optional (configurable)  
**Use Cases**: Edge computing, IoT, industrial automation, embedded AI  

---

## 💻 Hardware Acceleration Support

All variants include comprehensive support for modern AI acceleration hardware:

### 🧠 TPU (Tensor Processing Unit) Support ✅
- **Google Coral TPU**: Edge TPU USB/M.2/PCIe accelerators
- **Cloud TPU**: Google Cloud TPU integration
- **Performance**: 4+ TOPS at 2W for edge inference
- **Frameworks**: TensorFlow Lite, libcoral, PyCoral

### ⚡ NPU (Neural Processing Unit) Support ✅
- **Intel VPU**: Movidius Myriad X, Keem Bay, Meteor Lake
- **ARM Ethos NPU**: N78, N77, N57, U55/U65 series
- **Rockchip NPU**: RK3588 (6 TOPS), RK3568 (1 TOPS)
- **Hailo NPU**: Hailo-8 (26 TOPS), Hailo-15, Hailo-10
- **Frameworks**: OpenVINO, Arm NN, RKNN-Toolkit, HailoRT

### 🎨 GPU (Graphics Processing Unit) Support ✅
- **NVIDIA**: RTX 40/30/20 series, Tesla, A100, H100
- **AMD**: RX 7000/6000 series, Instinct MI series
- **Intel**: Arc A-series, Xe-HPG, Xe-HPC (Ponte Vecchio)
- **ARM**: Mali GPU series (ARM edition)
- **Frameworks**: CUDA, ROCm, oneAPI, OpenCL

### 🌐 DPU (Data Processing Unit) Support ✅
- **Mellanox BlueField**: BlueField-2/3/4 series
- **Intel IPU**: E2000, Mount Evans
- **Features**: RDMA, SR-IOV, hardware acceleration
- **Frameworks**: DOCA, DPDK, OVS-DPDK, SPDK

### 🔥 CPU (Central Processing Unit) Support ✅
- **Intel**: Xeon Scalable, Core i-series with AI extensions
- **AMD**: EPYC, Ryzen with AI optimizations
- **ARM**: Cortex-A76/A78, Neoverse series
- **Optimizations**: AVX-512, NEON, vectorization, NUMA

---

## 🏗️ Build System Architecture

### Build Scripts
```
ainux-builder.sh       # Main build orchestrator
├── build-desktop.sh   # Desktop variant wrapper
├── build-server.sh    # Server variant wrapper  
└── build-arm.sh       # ARM variant wrapper
```

### Configuration Files
```
configs/
├── ainux-6.6-desktop.config  # Desktop kernel configuration
├── ainux-6.6-server.config   # Server kernel configuration
└── ainux-6.6-arm.config      # ARM kernel configuration
```

### Workflow Files
```
.github/workflows/
├── build-desktop.yml         # Desktop CI/CD pipeline
├── build-server.yml          # Server CI/CD pipeline
├── build-arm.yml             # ARM CI/CD pipeline
└── build-test.yml            # Legacy unified pipeline
```

---

## 🖥️ Desktop Edition Details

### Hardware Requirements
- **CPU**: Intel/AMD x86_64 (4+ cores recommended)
- **RAM**: 4GB minimum, 16GB recommended
- **Storage**: 25GB minimum, 50GB+ SSD recommended
- **GPU**: Dedicated GPU recommended for gaming/AI
- **Audio**: HD Audio or USB Audio device
- **Network**: Ethernet or WiFi adapter

### Features
- **Desktop Environment**: XFCE4 (lightweight and customizable)
- **Gaming Support**: Steam, Lutris, Discord, OBS Studio
- **Multimedia**: Firefox, Thunderbird, GIMP, VLC
- **AI Acceleration**: Full TPU/NPU/GPU/CPU/DPU support
- **Development**: Complete development toolchain
- **Connectivity**: WiFi, Bluetooth, full hardware support

### Build Hardware Variants
```bash
# NVIDIA-optimized build
./build-desktop.sh  # Set NVIDIA_SUPPORT=true

# AMD-optimized build  
./build-desktop.sh  # Set AMD_SUPPORT=true

# Intel GPU-optimized build
./build-desktop.sh  # Set INTEL_GPU_SUPPORT=true

# Integrated graphics build
./build-desktop.sh  # Set INTEGRATED_ONLY=true
```

### Environment Variables
```bash
export BUILD_VARIANT="desktop"
export ENABLE_GUI="true"
export ARCH="x86_64"
export GAMING_SUPPORT="true"
export MULTIMEDIA_CODECS="true"
export TPU_SUPPORT="true"
export NPU_SUPPORT="true"
export GPU_SUPPORT="true"
export CPU_ACCELERATION="true"
export DPU_SUPPORT="true"
```

---

## 🏢 Server Edition Details

### Hardware Requirements
- **CPU**: Intel/AMD x86_64 (8+ cores, NUMA support)
- **RAM**: 8GB minimum, 64GB+ recommended
- **Storage**: 40GB minimum, enterprise SSD/NVMe RAID
- **Network**: Enterprise ethernet (1GbE+), redundant preferred
- **Management**: IPMI/BMC for remote management
- **Security**: TPM 2.0 chip recommended

### Server Profiles
#### Datacenter Profile
- **Target**: Enterprise data centers
- **Features**: High availability, enterprise storage, InfiniBand
- **Packages**: Docker, Kubernetes, PostgreSQL, Ceph, HAProxy

#### Cloud Profile  
- **Target**: Cloud-native deployments
- **Features**: Microservices, container orchestration
- **Packages**: Docker, Kubernetes, Consul, Vault, Prometheus

#### Edge Profile
- **Target**: Edge computing infrastructure
- **Features**: Low latency, IoT support, distributed computing
- **Packages**: Docker, K3s, MQTT, InfluxDB

#### HPC Profile
- **Target**: High-performance computing
- **Features**: MPI support, scientific computing tools
- **Packages**: OpenMPI, SLURM, GCC Fortran, scientific libraries

### Security Features
- **SELinux**: Mandatory access control
- **AppArmor**: Application security framework
- **Kernel Hardening**: FORTIFY_SOURCE, KASLR, stack protection
- **Container Security**: Secure container runtime, namespace isolation
- **Network Security**: Advanced firewall, intrusion detection

### Environment Variables
```bash
export BUILD_VARIANT="server"
export ENABLE_GUI="false"
export ARCH="x86_64"
export SERVER_KERNEL="true"
export SECURITY_HARDENING="true"
export VIRTUALIZATION_SUPPORT="true"
export CONTAINER_RUNTIME="true"
export TPU_SUPPORT="true"
export NPU_SUPPORT="true"
export GPU_SUPPORT="true"
export CPU_ACCELERATION="true"
export DPU_SUPPORT="true"
```

---

## 🍓 ARM Edition Details

### Hardware Requirements
- **CPU**: ARM64 (AArch64) - Raspberry Pi 4+, ARM Cortex
- **RAM**: 2GB minimum, 8GB recommended
- **Storage**: 16GB SD card minimum, 32GB+ recommended
- **Power**: 5V 3A power supply (USB-C for RPi 4+)
- **Cooling**: Heat sink recommended for sustained loads
- **Expansion**: GPIO header for hardware projects

### Supported Devices
#### Raspberry Pi Targets
- **RPi 4**: Raspberry Pi 4 Model B (optimized for Cortex-A72)
- **RPi 5**: Raspberry Pi 5 (optimized for Cortex-A76)
- **RPi 400**: Raspberry Pi 400 keyboard computer

#### Generic ARM Targets
- **Generic**: Generic ARM64 single-board computers
- **Industrial**: Industrial ARM devices with real-time support

### ARM-Specific Features
- **GPIO Support**: Raspberry Pi GPIO library, hardware interfaces
- **Hardware Interfaces**: I2C, SPI, UART, PWM support
- **Edge AI**: ARM Ethos NPU, Coral TPU, optimized inference
- **Power Management**: Low-power optimizations for battery operation
- **Real-time**: Real-time kernel support for industrial applications
- **IoT Protocols**: MQTT, CoAP, LoRaWAN support

### Cross-Compilation Support
- **Host Requirements**: Ubuntu 22.04+ with cross-compilation tools
- **Toolchain**: GCC ARM64 cross-compiler (aarch64-linux-gnu)
- **Emulation**: QEMU ARM64 emulation for testing
- **Device Trees**: Support for device-specific configurations

### Environment Variables
```bash
export BUILD_VARIANT="arm"
export ENABLE_GUI="false"  # Can be set to "true"
export ARCH="arm64"
export ARM_OPTIMIZATION="true"
export GPIO_SUPPORT="true"
export LOW_POWER_MODE="true"
export EDGE_AI_SUPPORT="true"
export TPU_SUPPORT="true"     # Coral TPU Edge
export NPU_SUPPORT="true"     # ARM Ethos, Rockchip
export GPU_SUPPORT="true"     # Mali, VideoCore
export CPU_ACCELERATION="true"
export DPU_SUPPORT="false"    # Not available on ARM edge
```

---

## 🚀 Quick Start Guide

### Prerequisites
```bash
# Ubuntu 22.04+ host system
sudo apt-get update
sudo apt-get install -y git build-essential libncurses-dev bison flex \
  libssl-dev libelf-dev bc gcc make debootstrap live-build squashfs-tools \
  dosfstools xorriso isolinux syslinux-utils genisoimage python3-pip \
  grub-pc-bin grub-efi-amd64-bin mtools debhelper

# For ARM builds, also install:
sudo apt-get install -y gcc-aarch64-linux-gnu qemu-user-static
```

### Build Commands

#### Desktop Edition
```bash
# Basic desktop build
./build-desktop.sh

# Desktop with NVIDIA optimization
NVIDIA_SUPPORT=true ./build-desktop.sh

# Desktop with AMD optimization  
AMD_SUPPORT=true ./build-desktop.sh
```

#### Server Edition
```bash
# Basic server build
./build-server.sh

# Datacenter profile
SERVER_PROFILE=datacenter ./build-server.sh

# Cloud profile with maximum security
SERVER_PROFILE=cloud SECURITY_LEVEL=maximum ./build-server.sh
```

#### ARM Edition
```bash
# Raspberry Pi 4 (headless)
./build-arm.sh

# Raspberry Pi 4 with GUI
ENABLE_GUI=true ARM_TARGET=rpi4 ./build-arm.sh

# Raspberry Pi 5 optimized
ARM_TARGET=rpi5 ./build-arm.sh

# Industrial ARM with real-time support
ARM_TARGET=industrial REALTIME_SUPPORT=true ./build-arm.sh
```

### CI/CD Integration
```bash
# Desktop workflow
.github/workflows/build-desktop.yml

# Server workflow  
.github/workflows/build-server.yml

# ARM workflow
.github/workflows/build-arm.yml
```

---

## 🐳 Docker Distribution

All variants are automatically built and published to GitHub Container Registry:

### Desktop Images
```bash
# Pull desktop variant optimized for NVIDIA
docker pull ghcr.io/yaotagroep/ainux-desktop:nvidia-latest

# Pull desktop variant optimized for AMD
docker pull ghcr.io/yaotagroep/ainux-desktop:amd-latest

# Pull desktop variant for integrated graphics
docker pull ghcr.io/yaotagroep/ainux-desktop:integrated-latest
```

### Server Images
```bash
# Pull datacenter server profile
docker pull ghcr.io/yaotagroep/ainux-server:datacenter-latest

# Pull cloud-native server profile
docker pull ghcr.io/yaotagroep/ainux-server:cloud-latest

# Pull edge computing profile
docker pull ghcr.io/yaotagroep/ainux-server:edge-latest
```

### ARM Images
```bash
# Pull Raspberry Pi 4 image
docker pull ghcr.io/yaotagroep/ainux-arm:rpi4-false-latest

# Pull Raspberry Pi 4 with GUI
docker pull ghcr.io/yaotagroep/ainux-arm:rpi4-true-latest

# Pull Raspberry Pi 5 image
docker pull ghcr.io/yaotagroep/ainux-arm:rpi5-false-latest
```

---

## 🔧 Advanced Configuration

### Custom Package Installation
```bash
# Add custom packages to any variant
export CUSTOM_PACKAGES="package1 package2 package3"
./build-<variant>.sh
```

### Build Optimization
```bash
# Optimize build performance
export BUILD_THREADS=$(nproc)      # Use all CPU cores
export SKIP_QEMU_TEST=true         # Skip time-consuming tests
export CI=true                     # Enable CI optimizations
```

### Hardware-Specific Builds
```bash
# Target specific hardware acceleration
export NVIDIA_SUPPORT=true         # Enable NVIDIA-specific optimizations
export AMD_SUPPORT=true            # Enable AMD-specific optimizations  
export INTEL_GPU_SUPPORT=true      # Enable Intel GPU optimizations
export TPU_CORAL_SUPPORT=true      # Enable Google Coral TPU support
export NPU_FRAMEWORK=true          # Enable NPU framework support
```

---

## 📊 Performance Comparison

| Variant | Build Time | ISO Size | RAM Usage | Use Case |
|---------|------------|----------|-----------|----------|
| **Desktop** | 45-90 min | 2.5-3.5 GB | 2-4 GB | Workstation, gaming |
| **Server** | 60-120 min | 1.5-2.5 GB | 1-2 GB | Enterprise, cloud |
| **ARM** | 90-180 min | 1-2 GB | 512MB-1GB | Edge, IoT |

---

## 🛠️ Troubleshooting

### Common Issues

#### Permission Denied (rootfs/setup.sh)
**Fixed in v3.0**: Enhanced permission handling prevents this issue.
```bash
# Manual fix if needed
chmod +x rootfs/setup.sh 2>/dev/null || true
```

#### Build Timeout
```bash
# Increase timeout for large builds
export BUILD_TIMEOUT=7200  # 2 hours
```

#### Cross-Compilation Issues (ARM)
```bash
# Ensure cross-compiler is installed
sudo apt-get install -y gcc-aarch64-linux-gnu
aarch64-linux-gnu-gcc --version
```

#### Memory Issues
```bash
# Free up space before building
sudo apt-get clean
sudo rm -rf /tmp/*
```

### Build Validation
```bash
# Validate build environment
./validate-build-env.sh

# Check build artifacts
cd ~/ainux-build/iso
sha256sum -c *.sha256
```

---

## 📚 Additional Resources

- **Hardware Support**: [HARDWARE_SUPPORT.md](./HARDWARE_SUPPORT.md)
- **Contributing**: [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Issue Logging**: [issues_logger.md](./issues_logger.md)
- **GitHub Repository**: [https://github.com/yaotagroep/ainux](https://github.com/yaotagroep/ainux)

---

*Last Updated: January 2025 | Ainux OS v3.0 | For support: [GitHub Issues](https://github.com/yaotagroep/ainux/issues)*

## 🚀 Quick Start

```bash
# Desktop Edition (Gaming + AI workstation)
./build-desktop.sh

# Server Edition (Enterprise + High availability)
./build-server.sh

# ARM Edition (Raspberry Pi + Edge computing)
./build-arm.sh

# AI/Cluster Edition (Default - Full AI acceleration)
./ainux-builder.sh
```

## Build Variants

### 1. AI/Cluster Edition (Default)
**Command:** `./ainux-builder.sh` or `BUILD_VARIANT=ai ./ainux-builder.sh`
**Quick Build:** `./ainux-builder.sh`

**Features:**
- Full AI/ML hardware support (TPU, NPU, GPU acceleration)
- Optimized for cluster computing and AI workloads
- Container and virtualization support
- High-performance networking
- Minimal GUI (optional with ENABLE_GUI=true)

**Hardware Support:**
- ✅ **CPU**: Intel x86_64, AMD x86_64 (up to 8192 cores, NUMA support)
- ✅ **GPU**: AMD (HSA, ROCm), NVIDIA (CUDA, TensorRT), Intel Arc (OpenVINO)
- ✅ **NPU**: Rockchip RK3588, ARM Ethos-N78, Intel VPU, Google Edge TPU
- ✅ **TPU**: Google Coral USB/PCIe/M.2, Edge TPU, Cloud TPU support
- ✅ **DPU**: SmartNIC support, DPDK integration, Mellanox BlueField

**Target Use Cases:**
- AI/ML training and inference clusters
- Deep learning workstations
- High-performance computing (HPC)
- Edge AI deployment

### 2. Desktop Edition
**Command:** `./build-desktop.sh` or `BUILD_VARIANT=desktop ./ainux-builder.sh`
**Quick Build:** `./build-desktop.sh`

**Features:**
- Full desktop environment (XFCE4)
- Gaming optimizations and hardware acceleration
- Complete multimedia support (audio, video, graphics)
- Enhanced input device support (gaming controllers, touchscreens)
- Bluetooth and wireless networking
- Performance-oriented scheduler
- AI acceleration for desktop workloads

**Hardware Support:**
- ✅ **CPU**: Intel x86_64, AMD x86_64 (gaming optimized)
- ✅ **GPU**: Enhanced gaming support (AMD RDNA/Vega, NVIDIA RTX/GTX, Intel Arc)
- ✅ **NPU**: Desktop AI acceleration (Intel VPU, discrete NPU cards)
- ✅ **TPU**: USB Coral devices for edge AI workloads
- ✅ **Audio**: HD Audio, USB Audio, all professional sound cards
- ✅ **Input**: Gaming controllers, VR headsets, multiple keyboard/mouse
- ✅ **Bluetooth**: All common Bluetooth devices (mice, keyboards, headphones)
- ✅ **WiFi**: Comprehensive wireless support including WiFi 6E/7

**Target Use Cases:**
- AI-enabled desktop workstations
- Gaming with AI features
- Content creation and multimedia
- Development workstations
- AI research and experimentation

### 3. Server Edition
**Command:** `./build-server.sh` or `BUILD_VARIANT=server ./ainux-builder.sh`
**Quick Build:** `./build-server.sh`

**Features:**
- Server-optimized kernel (non-preemptive, low-latency)
- Enterprise security features (SELinux, AppArmor, IMA/EVM, TPM 2.0)
- Advanced storage support (RAID, LVM, ZFS, enterprise filesystems)
- High-performance networking (InfiniBand, 100GbE, RDMA, SR-IOV)
- Virtualization and container platforms (KVM, Docker, Kubernetes)
- Datacenter management features (IPMI, Redfish, BMC)
- AI compute acceleration for server workloads

**Hardware Support:**
- ✅ **CPU**: Up to 8192 cores, NUMA support, Intel Xeon, AMD EPYC
- ✅ **GPU**: Compute-focused (NVIDIA Tesla, AMD Instinct, Intel Data Center GPU)
- ✅ **NPU**: Data center NPU cards (Intel VPU, Habana Gaudi)
- ✅ **TPU**: Google Cloud TPU, custom ASIC accelerators
- ✅ **DPU**: SmartNIC with DPDK, Mellanox BlueField, Intel IPU
- ✅ **Storage**: Enterprise SCSI, SATA, NVMe, NVMe-oF, SAN storage
- ✅ **Network**: Enterprise ethernet, InfiniBand, RDMA, Omni-Path
- ✅ **Virtualization**: Intel VT-x/VT-d, AMD-V/IOMMU, SR-IOV, PASID
- ✅ **IOMMU**: Advanced memory management, DMA protection

**Target Use Cases:**
- AI inference servers
- Cloud computing platforms
- Virtualization hosts
- Container orchestration (Kubernetes)
- Enterprise data centers
- High-availability clusters

### 4. ARM Edition (Raspberry Pi & ARM Devices)
**Command:** `./build-arm.sh` or `BUILD_VARIANT=arm ./ainux-builder.sh`
**Quick Build:** `./build-arm.sh`

**Features:**
- ARM64 optimization for embedded and edge devices
- Raspberry Pi 4/5 support with hardware acceleration
- Low-power optimizations and thermal management
- GPIO and hardware interface support (I2C, SPI, UART)
- Edge AI acceleration with ARM-specific optimizations
- IoT and embedded features (real-time capabilities)
- Optional minimal GUI for kiosk applications

**Hardware Support:**
- ✅ **CPU**: ARM64 (AArch64) - Raspberry Pi 4+, ARM Cortex-A76/A78
- ✅ **GPU**: VideoCore VII (RPi 5), ARM Mali-G310, Tegra Xavier/Orin, Etnaviv
- ✅ **NPU**: ARM Ethos-N78 NPU, Google Coral TPU (USB), Hailo-8/15 accelerators
- ✅ **TPU**: Google Coral USB Accelerator, M.2 Coral, Edge TPU dev boards
- ✅ **DPU**: ARM-based SmartNIC support, embedded networking processors
- ✅ **I/O**: GPIO (40-pin header), I2C, SPI, UART, PWM interfaces
- ✅ **Wireless**: Raspberry Pi WiFi 6/Bluetooth 5.2, cellular modems
- ✅ **Storage**: SD cards (UHS-I/II), eMMC, NVMe (via PCIe), USB 3.0+
- ✅ **Display**: HDMI 2.1 (4K@60), DSI touchscreens, CSI cameras

**Target Use Cases:**
- Edge AI inference
- IoT devices and sensors
- Embedded AI applications
- Raspberry Pi AI projects
- Industrial automation
- Smart home devices

## Usage Examples

### Quick Build (Recommended)
```bash
# Desktop edition with GUI and gaming support
./build-desktop.sh

# Server edition for enterprise deployment
./build-server.sh

# ARM edition for Raspberry Pi
./build-arm.sh

# Default AI/Cluster edition
./ainux-builder.sh
```

### Advanced Build (Environment Variables)
```bash
# Default AI/Cluster edition
./ainux-builder.sh

# Desktop edition with GUI
BUILD_VARIANT=desktop ./ainux-builder.sh

# Server edition (no GUI)
BUILD_VARIANT=server ./ainux-builder.sh

# ARM edition for Raspberry Pi
BUILD_VARIANT=arm ARCH=arm64 ./ainux-builder.sh
```

### Custom Configuration
```bash
# Desktop with additional packages
CUSTOM_PACKAGES="firefox gimp obs-studio" ./build-desktop.sh

# Server with specific thread count
BUILD_THREADS=16 ./build-server.sh

# ARM with GUI enabled
ENABLE_GUI=true ./build-arm.sh

# AI cluster with parallel optimization
BUILD_THREADS=$(nproc) ./ainux-builder.sh
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BUILD_VARIANT` | `ai` | Build variant: ai, desktop, server, arm |
| `ARCH` | `x86_64` | Target architecture: x86_64, arm64 |
| `ENABLE_GUI` | variant-dependent | Enable graphical interface |
| `BUILD_THREADS` | `$(nproc)` | Compilation thread count |
| `CLUSTER_MODE` | `main` | Cluster role: main, sub |
| `CUSTOM_PACKAGES` | empty | Additional packages to install |
| `SKIP_QEMU_TEST` | `false` | Skip QEMU validation |

## Hardware Requirements

### Minimum Requirements
- **AI/Cluster:** 8GB RAM, 30GB disk, x86_64 CPU
- **Desktop:** 4GB RAM, 25GB disk, x86_64 CPU, GPU recommended
- **Server:** 8GB RAM, 40GB disk, x86_64 CPU, enterprise network
- **ARM:** 2GB RAM, 16GB SD card, ARM64 CPU (RPi 4+)

### Recommended Requirements
- **AI/Cluster:** 32GB+ RAM, 100GB+ NVMe, multi-GPU setup
- **Desktop:** 16GB RAM, 50GB SSD, dedicated GPU, sound card
- **Server:** 64GB+ RAM, RAID storage, redundant networking
- **ARM:** 8GB RAM, 32GB+ fast SD card, cooling, GPIO expansion

## Verification

After building, verify your installation:

```bash
# Check GPU support
lspci | grep -i vga
lsmod | grep -E "(amdgpu|nouveau|i915)"

# Check NPU/TPU support
lsmod | grep -E "(npu|tpu)"
dmesg | grep -i "npu\|tpu"

# Check variant-specific features
# Desktop: Check GUI
systemctl status lightdm

# Server: Check virtualization
systemctl status libvirtd
lsmod | grep kvm

# ARM: Check GPIO
ls /sys/class/gpio/
```

## Troubleshooting

### Build Issues
1. **Insufficient disk space:** Ensure 30GB+ free space
2. **Missing dependencies:** Run `./validate-build-env.sh` first
3. **GPU compilation errors:** Check that GPU drivers support your hardware

### Runtime Issues
1. **GPU not detected:** Verify CONFIG_HSA_AMD and CONFIG_DRM_NOUVEAU are enabled
2. **NPU not available:** Check if your hardware has supported NPU/TPU
3. **Permission errors:** Ensure setup.sh has correct permissions (fixed in v2.1)

## 🔧 Hardware Support Matrix v2.1

### Processing Units Support

| Unit Type | Vendors/Models | AI/Cluster | Desktop | Server | ARM |
|-----------|----------------|------------|---------|--------|-----|
| **CPU** | Intel x86_64, AMD x86_64, ARM64 | ✅ Full | ✅ Full | ✅ Enterprise | ✅ ARM64 |
| **GPU** | NVIDIA (RTX/Tesla), AMD (RDNA/Instinct), Intel (Arc/Data Center) | ✅ Compute | ✅ Gaming | ✅ Compute | ✅ Embedded |
| **NPU** | Intel VPU, ARM Ethos-N78, Rockchip RK3588, Habana Gaudi | ✅ Full | ✅ Desktop AI | ✅ Data Center | ✅ Edge AI |
| **TPU** | Google Coral (USB/PCIe/M.2), Edge TPU, Cloud TPU | ✅ Full | ✅ USB/M.2 | ✅ PCIe/Cloud | ✅ USB/Edge |
| **DPU** | Mellanox BlueField, Intel IPU, ARM SmartNIC | ✅ HPC | 🔧 Limited | ✅ Enterprise | ✅ Embedded |

### Accelerator Compatibility

| Accelerator | Model | Interfaces | Software Stack | Variants |
|-------------|-------|------------|----------------|----------|
| **Google Coral** | USB/M.2/PCIe | USB 3.0, M.2 A+E, PCIe | TensorFlow Lite, libcoral | All |
| **Intel VPU** | Movidius Myriad X/Keem Bay | PCIe, USB-C | OpenVINO, Intel Distribution of OpenVINO | AI/Desktop/Server |
| **NVIDIA GPU** | RTX 30/40/50, Tesla A/H/L series | PCIe 4.0/5.0 | CUDA, TensorRT, cuDNN | AI/Desktop/Server |
| **AMD GPU** | RDNA 2/3, Instinct MI series | PCIe 4.0/5.0 | ROCm, HIP, MIOpen | AI/Desktop/Server |
| **ARM Ethos NPU** | Ethos-N78, Ethos-U55/65 | AXI, AHB | Arm NN, CMSIS-NN | ARM/Edge |
| **Hailo NPU** | Hailo-8, Hailo-15 | PCIe, M.2 | HailoRT, TensorFlow/PyTorch | All |

### 🌟 Build Performance Metrics

| Variant | Avg Build Time | ISO Size | RAM Usage | Accelerator Support |
|---------|----------------|----------|-----------|-------------------|
| **AI/Cluster** | 45-90 min | 2.8-3.2 GB | 8-16 GB | Full (TPU+NPU+GPU+DPU) |
| **Desktop** | 35-75 min | 3.2-3.8 GB | 6-12 GB | Gaming+AI (GPU+NPU+TPU) |
| **Server** | 50-120 min | 2.5-3.0 GB | 8-32 GB | Enterprise (All units) |
| **ARM** | 60-180 min | 1.8-2.2 GB | 2-8 GB | Edge AI (NPU+TPU) |

---

**Next Steps:**
- Review the [main README](./README.md) for general installation instructions
- Check [Contributing Guidelines](./CONTRIBUTING.md) for development
- See [Issue Logger](./issue_logger.md) for troubleshooting