# Ainux OS - AI Cluster Operating System

<div align="center">

![Ainux OS Logo](https://img.shields.io/badge/Ainux%20OS-AI%20Cluster%20OS-00FF88?style=for-the-badge&logo=linux)

[![Build Status](https://img.shields.io/badge/Build-Passing-success?style=flat-square)](https://github.com/yaotagroep/ainux/actions)
[![Kernel](https://img.shields.io/badge/Kernel-6.6.58%20LTS-blue?style=flat-square)](https://kernel.org)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](https://github.com/yaotagroep/ainux/blob/main/LICENSE.md)
[![Release](https://img.shields.io/github/v/release/yaotagroep/ainux?style=flat-square)](https://github.com/yaotagroep/ainux/releases)

*A specialized Linux distribution optimized for AI workloads and cluster computing*

[🚀 Quick Start](#quick-start) • [📖 Documentation](#documentation) • [💻 Installation](#installation) • [🤝 Contributing](#contributing) • [📋 Roadmap](#roadmap)

</div>

---

## 🎯 Overview

**Ainux OS** is a purpose-built Linux distribution designed specifically for AI cluster computing environments. Built on Ubuntu 22.04 LTS with a custom Linux Kernel 6.6 LTS, it provides seamless hardware acceleration for NVIDIA GPUs, AMD ROCm, and NPU (Neural Processing Units) while offering enterprise-grade cluster management capabilities.

### ✨ Key Features

- **🧠 AI-First Architecture**: Native support for PyTorch, TensorFlow, ONNX Runtime
- **🚀 Multi-GPU Support**: NVIDIA CUDA, AMD ROCm, Intel Arc out-of-the-box
- **🔌 NPU Integration**: Rockchip, ARM Ethos, Intel VPU support
- **💾 Flash Memory Optimization**: NVMe caching, bcache, dm-cache support
- **🧠 Advanced Memory Management**: ZRAM compression, huge pages, shared memory pools
- **🌐 Cluster Management**: Automatic node discovery and load balancing
- **⚡ High-Performance Networking**: Optimized for Thunderbolt, InfiniBand, 10GbE
- **🔒 Enterprise Security**: SSH key-based authentication, encrypted cluster communication
- **🖥️ Flexible Interface**: Headless for compute nodes, optional GUI for management nodes
- **📦 Container Ready**: Docker pre-installed with AI runtime optimizations

## 🎪 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Ainux OS Cluster                         │
├─────────────────────────────────────────────────────────────┤
│  Main Node (GUI)           Sub Nodes (Headless)            │
│  ┌─────────────────┐      ┌─────────────────┐             │
│  │ Cluster Manager │      │ Worker Node 1   │             │
│  │ XFCE Desktop    │      │ AI Workloads    │             │
│  │ Web Dashboard   │◄────►│ GPU/NPU Compute │             │
│  └─────────────────┘      └─────────────────┘             │
│            │                        │                     │
│            └────────────────────────┼─────────────────────┤
│                                     │                     │
│  Hardware Support Layer                                   │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐ │
│  │ NVIDIA CUDA │ AMD ROCm    │ NPU Support │ Networking  │ │
│  │ RTX/Tesla   │ RDNA/Vega   │ Rockchip    │ 10GbE/IB    │ │
│  │ Driver 560+ │ ROCm 6.2+   │ ARM Ethos   │ Thunderbolt │ │
│  └─────────────┴─────────────┴─────────────┴─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│              Linux Kernel 6.6.58 LTS (Custom)             │
│           Ubuntu 22.04 LTS Base • AI Optimizations        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Host System**: Ubuntu 22.04 or 24.04 LTS
- **Storage**: 30GB+ free disk space
- **Memory**: 8GB+ RAM recommended
- **Network**: Internet connection for downloads
- **Privileges**: sudo access

### Build Ainux OS

```bash
# Clone the repository
git clone https://github.com/yaotagroep/ainux.git
cd ainux

# Make the builder executable
chmod +x ainux-builder.sh

# Build main node with GUI
./ainux-builder.sh --mode main --gui

# Build worker nodes (headless)
./ainux-builder.sh --mode sub
```

### Deploy to Hardware

```bash
# Create bootable USB (replace /dev/sdX with your device)
sudo dd if=~/ainux-build/iso/ainux-ai-cluster.iso of=/dev/sdX bs=4M status=progress

# Or test in QEMU first
qemu-system-x86_64 -m 4096 -cdrom ~/ainux-build/iso/ainux-ai-cluster.iso -enable-kvm
```

### Initialize Cluster

```bash
# On main node after boot
sudo cluster-init

# Verify hardware support
sudo validate-hardware

# Monitor AI resources
/usr/local/bin/ai-monitor
```

## 💻 Installation

### Supported Hardware

| Component | Supported Hardware | Driver Version |
|-----------|-------------------|----------------|
| **NVIDIA GPUs** | RTX 20/30/40 Series, Tesla, A100, H100 | Driver 560+ |
| **AMD GPUs** | RDNA, RDNA2, RDNA3, Vega, MI Series | ROCm 6.2+ |
| **NPUs** | Rockchip RK3588, ARM Ethos-N, Intel VPU | Native drivers |
| **Flash Storage** | NVMe, SATA SSD, eMMC, UFS | bcache, dm-cache |
| **Memory** | DDR4/DDR5, ZRAM, Huge Pages | Optimized pools |
| **Networking** | 10GbE, InfiniBand, Thunderbolt 3/4 | Kernel native |
| **Storage** | NVMe, SATA, USB 3.0+ | Advanced caching |

### System Requirements

#### Minimum Requirements
- **CPU**: 4 cores, x86_64 architecture
- **Memory**: 8GB RAM
- **Storage**: 64GB available space
- **Network**: Gigabit Ethernet

#### Recommended Specifications
- **CPU**: 8+ cores, AMD Ryzen or Intel Core
- **Memory**: 32GB+ RAM (64GB+ for large models)
- **Storage**: 256GB+ NVMe SSD + 1TB+ HDD (with caching)
- **GPU**: NVIDIA RTX or AMD RDNA2+
- **Flash Cache**: Additional NVMe for caching layer
- **Network**: 10GbE or InfiniBand

## 🛠️ Configuration

### Build Options

```bash
# Available build flags
./ainux-builder.sh [OPTIONS]

Options:
  -h, --help              Show help message
  -m, --mode MODE         Cluster mode: main|sub (default: main)
  -t, --threads N         Build threads (default: nproc)
  -g, --gui               Enable GUI components (XFCE)
  --skip-qemu             Skip QEMU testing phase
  --custom-packages LIST  Install additional packages
  --build-dir PATH        Custom build directory
```

### Environment Variables

```bash
# Customize build behavior
export CLUSTER_MODE=main           # main|sub
export BUILD_THREADS=8             # Parallel build jobs
export ENABLE_GUI=true             # Enable/disable GUI
export ENABLE_FLASH_CACHE=true     # Enable flash caching
export SKIP_QEMU_TEST=true         # Skip testing
export CUSTOM_PACKAGES="htop vim"  # Additional packages
```

### Cluster Configuration

```bash
# Edit cluster settings
sudo vim /etc/cluster/cluster.conf

# Key configuration options:
CLUSTER_MODE=main                    # Node role
CLUSTER_NETWORK=10.99.0.0/16       # Cluster subnet
MAIN_NODE_IP=10.99.0.1              # Main node address
SSH_PORT=22                         # SSH port
GPU_SHARING=enabled                 # Enable GPU sharing
NPU_SHARING=enabled                 # Enable NPU sharing

# Flash Memory and Caching Configuration
FLASH_CACHE_ENABLED=true            # Enable flash caching
FLASH_CACHE_SIZE=auto               # auto, or size in GB
FLASH_CACHE_DEVICE=auto             # auto-detect fastest NVMe
MEMORY_CACHE_SIZE=50%               # Percentage of RAM for cache
ZRAM_ENABLED=true                   # Compressed RAM
HUGE_PAGES_ENABLED=true             # Large page support
BCACHE_ENABLED=true                 # Block cache for HDDs
```

## 🧪 Testing & Validation

### Hardware Validation

```bash
# Comprehensive hardware check
sudo validate-hardware

# Example output:
=== Ainux OS AI Cluster Validation ===
⚡ GPU Hardware Detection:
✅ NVIDIA RTX 4090 (Driver: 560.35.03)
✅ AMD RX 7900 XTX (ROCm: 6.2.4)

🧠 NPU Hardware Detection:
✅ Rockchip RK3588 NPU detected
✅ /dev/rknpu0 accessible

💾 Flash Memory & Cache:
✅ NVMe storage: /dev/nvme0n1 (2TB)
✅ ZRAM compression: 8GB
✅ Huge pages: 1024 pages (2GB)
✅ bcache: Available

🐍 Python AI Frameworks:
✅ PyTorch: 2.4.1 (CUDA: 12.6)
✅ TensorFlow: 2.17.0 (GPU: Available)
✅ ONNX Runtime: 1.19.2
```

### Performance Benchmarks

```bash
# AI workload benchmarks
python3 -m torch.utils.benchmark_utils.benchmark_all_test
python3 -c "import tensorflow as tf; tf.debugging.set_log_device_placement(True)"

# Storage performance test
fio --name=sequential-read --rw=read --bs=1M --size=1G --numjobs=1
fio --name=random-write --rw=randwrite --bs=4k --size=1G --numjobs=4

# Memory cache performance
cache-monitor                    # Custom Ainux OS tool
dd if=/dev/zero of=/mnt/ai-tmp/test bs=1M count=1000  # Test tmpfs speed

# Cluster networking test
iperf3 -s    # On main node
iperf3 -c <main-node-ip>  # On sub nodes
```

## 📊 Monitoring & Management

### Built-in Monitoring

- **Cluster Dashboard**: Web-based management interface
- **AI Resource Monitor**: Real-time GPU/NPU utilization
- **Flash Cache Monitor**: NVMe cache performance and statistics
- **Memory Pool Monitor**: ZRAM, huge pages, shared memory usage
- **Service Health**: Automatic service monitoring and restart
- **Performance Metrics**: System load, memory, network, storage statistics

### CLI Tools

```bash
# Cluster status
systemctl status clusterd

# AI hardware monitoring
/usr/local/bin/ai-monitor

# Flash cache performance
cache-monitor

# Setup flash caching manually
sudo flash-cache-setup

# Node management
cluster-add-node <ip-address>
cluster-remove-node <node-id>
cluster-list-nodes
```

### Web Interface

Access the cluster management interface at `http://<main-node-ip>:8080` (when GUI is enabled).

## 🔧 Development

### Building from Source

```bash
# Development build with debug symbols
./ainux-builder.sh --mode main --gui --custom-packages "gdb valgrind"

# Custom kernel configuration
cd ~/ainux-build/kernel/linux
make menuconfig  # Modify kernel config
cd ~/ainux-build && ./ainux-builder.sh  # Rebuild
```

### Adding Custom Patches

```bash
# Add your patches to the kernel
cd ~/ainux-build/kernel/linux

# Apply patch
patch -p1 < /path/to/your/patch.patch

# Rebuild kernel
make -j$(nproc) LOCALVERSION=-ainux
```

### Custom Package Integration

```bash
# Add packages during build
./ainux-builder.sh --custom-packages "your-package-name another-package"

# Or modify the rootfs directly
sudo chroot ~/ainux-build/rootfs/rootfs /bin/bash
apt install your-package
exit
```

### Contributing to Development

1. Fork the [Ainux repository](https://github.com/yaotagroep/ainux)
2. Create feature branch: `git checkout -b feature/awesome-feature`
3. Make changes and test thoroughly
4. Submit pull request with clear description

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](https://github.com/yaotagroep/ainux/blob/main/CONTRIBUTING.md) for details.

### 📝 Reporting Issues

We use structured issue templates to help us understand and resolve problems quickly:

- **🐛 [Bug Report](https://github.com/yaotagroep/ainux/issues/new?template=bug_report.yml)**: Report bugs and technical issues
- **✨ [Feature Request](https://github.com/yaotagroep/ainux/issues/new?template=feature_request.yml)**: Suggest new features or enhancements  
- **🔧 [Hardware Support](https://github.com/yaotagroep/ainux/issues/new?template=hardware_support.yml)**: Request support for specific hardware
- **📚 [Documentation](https://github.com/yaotagroep/ainux/issues/new?template=documentation.yml)**: Report documentation issues

For questions and discussions, visit our [Community Discussions](https://github.com/yaotagroep/ainux/discussions).

### Development Setup

1. Fork the repository on [GitHub](https://github.com/yaotagroep/ainux)
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and test thoroughly
4. Submit a pull request using our [PR template](https://github.com/yaotagroep/ainux/compare)

### Areas for Contribution

- **Hardware Support**: New GPU/NPU driver integration
- **AI Frameworks**: Additional ML library support
- **Flash Storage**: Advanced caching algorithms and storage optimization
- **Memory Management**: NUMA optimization, memory pool enhancements
- **Networking**: Advanced cluster networking features
- **Security**: Enhanced cluster authentication
- **Documentation**: User guides, tutorials, examples

## 📋 Roadmap

### v2.2 (Q1 2025)
- [ ] Intel Arc GPU support
- [ ] Advanced flash cache algorithms (adaptive caching)
- [ ] RDMA over Converged Ethernet (RoCE) support
- [ ] Kubernetes integration
- [ ] PXE network boot support

### v2.3 (Q2 2025)
- [ ] Web-based cluster configuration
- [ ] Multi-tier storage with automatic tiering
- [ ] NVMe-oF (NVMe over Fabrics) support
- [ ] Multi-cluster federation
- [ ] Enhanced security (RBAC)

### v3.0 (Q3 2025)
- [ ] ARM64 architecture support
- [ ] Persistent memory (PMEM) integration
- [ ] Cloud-native deployment
- [ ] AI model marketplace integration
- [ ] Advanced resource scheduling with ML optimization

## 🐛 Troubleshooting

### Common Issues

**Build fails with "insufficient disk space"**
```bash
# Clean up Docker images and build cache
docker system prune -a
# Ensure 30GB+ free space in build directory
```

**GPU not detected after boot**
```bash
# Check driver installation
nvidia-smi  # For NVIDIA
rocm-smi    # For AMD
lspci | grep -i vga  # List all GPUs
```

**Cluster nodes can't communicate**
```bash
# Check network configuration
ip route show
# Verify SSH keys
ssh-copy-id aiadmin@<node-ip>
# Check firewall
sudo ufw status
```

**Slow storage performance**
```bash
# Test storage speed
fio --name=test --rw=read --bs=1M --size=1G --numjobs=1
hdparm -tT /dev/nvme0n1

# Check cache configuration
cache-monitor
cat /sys/block/*/queue/scheduler  # Should be 'none' for NVMe
```

### Getting Help

- 📚 [Documentation Wiki](https://github.com/yaotagroep/ainux/wiki)
- 💬 [Community Discussions](https://github.com/yaotagroep/ainux/discussions)
- 🐛 [Issue Tracker](https://github.com/yaotagroep/ainux/issues)
- 📧 [Email Support](mailto:support@yaotagroep.nl)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/yaotagroep/ainux/blob/main/LICENSE.md) file for details.

## 🙏 Acknowledgments

- **Linux Kernel Team**: For the excellent 6.6 LTS kernel
- **Ubuntu Team**: For the stable base system
- **AI Community**: PyTorch, TensorFlow, ONNX Runtime teams
- **Hardware Vendors**: NVIDIA, AMD, Intel for driver support
- **Yaotagroep**: For sponsoring and supporting this open source project
- **Contributors**: All community members who made this possible

---

<div align="center">

**Built with ❤️ for the AI Community by Yaotagroep**

[GitHub Repository](https://github.com/yaotagroep/ainux) • [Documentation](https://github.com/yaotagroep/ainux/wiki) • [Community](https://github.com/yaotagroep/ainux/discussions)

</div>
