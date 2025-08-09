# Ainux OS Build Variants Guide

Ainux OS supports multiple build variants optimized for different use cases. Choose the appropriate variant for your deployment.

## Build Variants

### 1. AI/Cluster Edition (Default)
**Command:** `./ainux-builder.sh` or `BUILD_VARIANT=ai ./ainux-builder.sh`

**Features:**
- Full AI/ML hardware support (TPU, NPU, GPU acceleration)
- Optimized for cluster computing and AI workloads
- Container and virtualization support
- High-performance networking
- Minimal GUI (optional with ENABLE_GUI=true)

**Hardware Support:**
- ✅ CPU: Intel x86_64, AMD x86_64
- ✅ GPU: AMD (HSA, ROCm), NVIDIA (CUDA), Intel Arc
- ✅ NPU: Rockchip, ARM Ethos, Intel VPU, Google TPU
- ✅ TPU: Google Coral USB/PCIe, Edge TPU
- 🔧 DPU: SmartNIC support, DPDK integration

**Target Use Cases:**
- AI/ML training and inference clusters
- Deep learning workstations
- High-performance computing (HPC)
- Edge AI deployment

### 2. Desktop Edition
**Command:** `BUILD_VARIANT=desktop ./ainux-builder.sh`

**Features:**
- Full desktop environment (XFCE4)
- Gaming optimizations
- Complete multimedia support (audio, video, graphics)
- Enhanced input device support (gaming controllers, touchscreens)
- Bluetooth and wireless networking
- Performance-oriented scheduler
- AI acceleration for desktop workloads

**Hardware Support:**
- ✅ CPU: Intel x86_64, AMD x86_64
- ✅ GPU: Enhanced gaming support (AMD, NVIDIA, Intel)
- ✅ Audio: HD Audio, USB Audio, all sound cards
- ✅ Input: Gaming controllers, multiple keyboard/mouse
- ✅ Bluetooth: All common Bluetooth devices
- ✅ WiFi: Comprehensive wireless support

**Target Use Cases:**
- AI-enabled desktop workstations
- Gaming with AI features
- Content creation and multimedia
- Development workstations
- AI research and experimentation

### 3. Server Edition
**Command:** `BUILD_VARIANT=server ./ainux-builder.sh`

**Features:**
- Server-optimized kernel (non-preemptive)
- Enterprise security features (SELinux, AppArmor, IMA/EVM)
- Advanced storage support (RAID, LVM, enterprise filesystems)
- High-performance networking (InfiniBand, 10GbE+)
- Virtualization and container platforms
- Datacenter management features
- AI compute acceleration for server workloads

**Hardware Support:**
- ✅ CPU: Up to 8192 cores, NUMA support
- ✅ GPU: Compute-focused (no desktop graphics)
- ✅ Storage: Enterprise SCSI, SATA, NVMe, SAN storage
- ✅ Network: Enterprise ethernet, InfiniBand, RDMA
- ✅ Virtualization: KVM, container engines
- ✅ IOMMU: Advanced memory management

**Target Use Cases:**
- AI inference servers
- Cloud computing platforms
- Virtualization hosts
- Container orchestration (Kubernetes)
- Enterprise data centers
- High-availability clusters

### 4. ARM Edition (Raspberry Pi & ARM Devices)
**Command:** `BUILD_VARIANT=arm ./ainux-builder.sh`

**Features:**
- ARM64 optimization for embedded and edge devices
- Raspberry Pi 4/5 support
- Low-power optimizations
- GPIO and hardware interface support
- Edge AI acceleration
- IoT and embedded features

**Hardware Support:**
- ✅ CPU: ARM64 (AArch64) - Raspberry Pi, ARM Cortex
- ✅ GPU: VideoCore (RPi), ARM Mali, Tegra, Etnaviv
- ✅ NPU: ARM Ethos NPU, Google Coral TPU
- ✅ I/O: GPIO, I2C, SPI, UART interfaces
- ✅ Wireless: Raspberry Pi WiFi/Bluetooth
- ✅ Storage: SD cards, eMMC, USB storage

**Target Use Cases:**
- Edge AI inference
- IoT devices and sensors
- Embedded AI applications
- Raspberry Pi AI projects
- Industrial automation
- Smart home devices

## Usage Examples

### Basic Build
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

### Advanced Configuration
```bash
# Desktop with custom packages
BUILD_VARIANT=desktop ENABLE_GUI=true CUSTOM_PACKAGES="firefox gimp" ./ainux-builder.sh

# Server with specific thread count
BUILD_VARIANT=server BUILD_THREADS=16 ./ainux-builder.sh

# AI cluster with parallel optimization
BUILD_VARIANT=ai CLUSTER_MODE=main BUILD_THREADS=$(nproc) ./ainux-builder.sh
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

## Support Matrix

| Feature | AI/Cluster | Desktop | Server | ARM |
|---------|------------|---------|--------|-----|
| **CPU Support** | ✅ Full | ✅ Full | ✅ Full | ✅ ARM64 |
| **GPU Acceleration** | ✅ Compute | ✅ Gaming | 🔧 Compute | ✅ Embedded |
| **NPU/TPU** | ✅ Full | ✅ Limited | ✅ Compute | ✅ Edge |
| **GUI Desktop** | 🔧 Optional | ✅ Full | ❌ None | 🔧 Minimal |
| **Container Support** | ✅ Full | ✅ Full | ✅ Enterprise | ✅ Limited |
| **Networking** | ✅ HPC | ✅ Standard | ✅ Enterprise | ✅ IoT |
| **Security** | ✅ Standard | ✅ Desktop | ✅ Enterprise | ✅ IoT |
| **Power Management** | 🔧 Performance | ✅ Balanced | 🔧 Efficiency | ✅ Low Power |

**Legend:** ✅ Full Support, 🔧 Partial/Optional, ❌ Not Available

---

**Next Steps:**
- Review the [main README](./README.md) for general installation instructions
- Check [Contributing Guidelines](./CONTRIBUTING.md) for development
- See [Issue Logger](./issue_logger.md) for troubleshooting