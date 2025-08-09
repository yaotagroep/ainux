# Ainux OS Build Variants Guide v2.1

Ainux OS supports multiple build variants optimized for different use cases. Choose the appropriate variant for your deployment. Each variant now has dedicated build scripts for enhanced user experience.

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