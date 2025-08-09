#!/bin/bash
# Fix NPU Kconfig Truncation Issue
# This script ensures the complete NPU Kconfig is properly written after patch application

set -euo pipefail

KCONFIG_FILE="$1"

if [[ ! -f "$KCONFIG_FILE" ]]; then
    echo "Error: Kconfig file not found: $KCONFIG_FILE"
    exit 1
fi

echo "Checking NPU Kconfig completeness..."

# Check if the file ends with the proper endif
if ! grep -q "endif # NPU_FRAMEWORK" "$KCONFIG_FILE"; then
    echo "Fixing incomplete NPU Kconfig..."
    
    # Remove any truncated lines at the end
    sed -i '/^[[:space:]]*Edge TPU devices with enhanced driver framework.$/,$d' "$KCONFIG_FILE" 2>/dev/null || true
    sed -i '/config GOOGLE_TPU/,$d' "$KCONFIG_FILE" 2>/dev/null || true
    
    # Add the complete Google TPU and NPU_DEBUG configs
    cat >> "$KCONFIG_FILE" << 'KCONFIG_EOF'
config GOOGLE_TPU
	tristate "Google TPU (Tensor Processing Unit) Support"  
	depends on PCI
	default y
	help
	  Enable support for Google TPU (Tensor Processing Unit).
	  Google TPUs are specialized ASIC designed for neural
	  network machine learning. This includes support for
	  Google Coral USB Accelerator, PCIe TPU cards, and
	  Edge TPU devices with enhanced driver framework.

config NPU_DEBUG
	bool "NPU Framework Debug Support"
	depends on NPU_FRAMEWORK
	default n
	help
	  Enable debug support for NPU framework. This includes
	  additional logging, debugging interfaces, and validation
	  checks for NPU operations.

endif # NPU_FRAMEWORK
KCONFIG_EOF
    
    echo "NPU Kconfig fixed successfully"
else
    echo "NPU Kconfig is already complete"
fi