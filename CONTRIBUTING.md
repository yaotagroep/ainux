# Contributing to Ainux OS

Thank you for your interest in contributing to Ainux OS! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
- Use the [GitHub Issues](https://github.com/yaotagroep/ainux/issues) page
- Provide detailed information about the problem
- Include system specifications and error logs
- Use the appropriate issue template

### Suggesting Features
- Open a [Discussion](https://github.com/yaotagroep/ainux/discussions) first
- Describe the use case and benefits
- Consider implementation complexity
- Get community feedback before coding

### Code Contributions

#### 1. Fork and Clone
```bash
git clone https://github.com/your-username/ainux.git
cd ainux
git remote add upstream https://github.com/yaotagroep/ainux.git
```

#### 2. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

#### 3. Make Changes
- Follow coding standards (see below)
- Write tests for new functionality
- Update documentation as needed
- Test thoroughly on multiple hardware configurations

#### 4. Commit and Push
```bash
git add .
git commit -m "feat: add NPU support for Intel VPU"
git push origin feature/your-feature-name
```

#### 5. Create Pull Request
- Use the PR template
- Provide clear description of changes
- Link related issues
- Request review from maintainers

## 📝 Coding Standards

### Shell Scripts
```bash
#!/bin/bash
set -euo pipefail  # Always use strict mode

# Use descriptive variable names
kernel_version="6.6.58"
build_directory="/tmp/ainux-build"

# Function naming: use snake_case
build_kernel() {
    log_info "Building kernel..."
}

# Error handling
if [[ ! -f "$config_file" ]]; then
    log_error "Configuration file not found: $config_file"
    exit 1
fi
```

### Documentation
- Use clear, concise language
- Include code examples
- Keep README sections updated
- Use proper markdown formatting

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
```
feat: add new NPU driver support
fix: resolve GPU detection issue
docs: update installation guide
test: add hardware validation tests
```

## 🧪 Testing Guidelines

### Before Submitting
1. **Build Test**: Ensure the build completes successfully
```bash
./ainux-builder.sh --mode main --skip-qemu
```

2. **Hardware Test**: Test on actual hardware when possible
```bash
# Boot from ISO and run
sudo validate-hardware
sudo cluster-init
```

3. **Virtual Test**: Always test in QEMU
```bash
qemu-system-x86_64 -m 4096 -cdrom ainux-ai-cluster.iso -enable-kvm
```

### Test Environments
- **Primary**: Ubuntu 22.04 LTS
- **Secondary**: Debian 12, Fedora 39
- **Hardware**: NVIDIA RTX, AMD RDNA, Intel Arc

## 🏗️ Development Areas

### High Priority
- [ ] ARM64 architecture support  
- [ ] Additional NPU drivers (Qualcomm, MediaTek)
- [ ] Enhanced TPU support (Edge TPU optimizations)
- [ ] DPU/SmartNIC acceleration improvements
- [ ] Kubernetes integration
- [ ] Web management interface

### Medium Priority
- [ ] Intel Arc GPU optimization
- [ ] Advanced NPU scheduling and load balancing
- [ ] CPU-specific AI acceleration (AVX-512, ARM NEON)
- [ ] Advanced networking (RDMA)
- [ ] Container orchestration
- [ ] Monitoring dashboards

### Documentation
- [ ] Video tutorials
- [ ] Hardware compatibility matrix
- [ ] Deployment best practices
- [ ] Troubleshooting guides

## 🐛 Bug Reports

When reporting bugs, include:

### System Information
```bash
# Run this and include output
cat /etc/os-release
uname -a
lscpu
lspci | grep -E "(VGA|3D)"
free -h
```

### Build Information
```bash
# If build-related issue
cat ~/ainux-build/build-info.txt
tail -50 ~/ainux-build/logs/*.log
```

### Error Details
- Exact error message
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if relevant

## 📚 Resources

### Documentation
- [Linux Kernel Documentation](https://kernel.org/doc/)
- [Ubuntu Development](https://wiki.ubuntu.com/DevelopmentCodeNames)
- [NVIDIA CUDA Documentation](https://docs.nvidia.com/cuda/)
- [AMD ROCm Documentation](https://rocm.docs.amd.com/)

### Community
- [Discussions](https://github.com/yaotagroep/ainux/discussions) - General questions
- [Issues](https://github.com/yaotagroep/ainux/issues) - Bug reports
- [Wiki](https://github.com/yaotagroep/ainux/wiki) - Extended documentation

## 📄 License

By contributing to Ainux OS, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project website (when available)

Thank you for helping make Ainux OS better! 🚀
