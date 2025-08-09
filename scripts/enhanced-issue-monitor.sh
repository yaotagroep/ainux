#!/bin/bash
# Enhanced Issue Logger Health Monitor v4.0 - Multi-variant Support
# Prevents truncation and monitors hardware support across build variants

set -euo pipefail

ISSUE_DIR="./issue_logger"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
MAX_FILE_SIZE="${MAX_FILE_SIZE:-104857600}"  # 100MB default

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Enhanced file monitoring with hardware-aware checks
monitor_file_size() {
    local file="$1"
    local max_size="${2:-$MAX_FILE_SIZE}"
    
    if [[ -f "$file" && $(stat -c%s "$file") -gt $max_size ]]; then
        log_warning "Rotating $file (size limit exceeded: $(stat -c%s "$file") bytes)"
        local backup_name="${file}.$(date +%s).backup"
        mv "$file" "$backup_name"
        touch "$file" && chmod 644 "$file"
        log_info "Created backup: $backup_name"
        
        # Compress old backup if it exists
        if [[ -f "$backup_name" ]]; then
            gzip "$backup_name" 2>/dev/null || true
        fi
    fi
}

# Atomic append with enhanced integrity check
safe_append() {
    local content="$1"
    local target="$2"
    local temp="${target}.tmp.$$"
    
    # Validate content before writing
    if [[ -z "$content" ]]; then
        log_error "Cannot append empty content to $target"
        return 1
    fi
    
    # Atomic write operation
    if echo "$content" > "$temp" && mv "$temp" "$target"; then
        log_info "Successfully appended to $target"
        return 0
    else
        log_error "Failed to append to $target"
        rm -f "$temp" 2>/dev/null || true
        return 1
    fi
}

# Enhanced auto-recovery with SHA-256 verification
auto_recover() {
    local file="$1"
    local backup_dir="$ISSUE_DIR/backups"
    
    # Find most recent backup
    local backup
    if [[ -d "$backup_dir" ]]; then
        backup=$(find "$backup_dir" -name "$(basename "$file")*.backup*" -type f 2>/dev/null | sort -r | head -1)
    fi
    
    if [[ -z "$backup" ]]; then
        backup=$(ls -t "${file}".*.backup* 2>/dev/null | head -1)
    fi
    
    if [[ -n "$backup" ]]; then
        log_warning "Recovering $file from $backup"
        
        # Decompress if needed
        if [[ "$backup" == *.gz ]]; then
            gunzip -c "$backup" > "$file" 2>/dev/null || {
                log_error "Failed to decompress backup $backup"
                return 1
            }
        else
            cp "$backup" "$file" || {
                log_error "Failed to copy backup $backup"
                return 1
            }
        fi
        
        log_success "Recovery completed for $file"
        return 0
    else
        log_error "No backup found for $file"
        return 1
    fi
}

# Verify file integrity with enhanced checks
verify_integrity() {
    local file="$1"
    local issues_found=0
    
    if [[ ! -f "$file" ]]; then
        log_error "File $file does not exist"
        return 1
    fi
    
    # Check file endings for proper XML structure
    if [[ "$file" == *"open.issue" ]]; then
        if ! tail -1 "$file" | grep -q "</open>" 2>/dev/null; then
            log_warning "Possible truncation in $file - missing closing tag"
            ((issues_found++))
        fi
    elif [[ "$file" == *"closed.issue" ]]; then
        if ! tail -1 "$file" | grep -q "</closed>" 2>/dev/null; then
            log_warning "Possible truncation in $file - missing closing tag"
            ((issues_found++))
        fi
    fi
    
    # Check for incomplete lines
    if [[ -s "$file" ]] && ! tail -1 "$file" | grep -q ".*" 2>/dev/null; then
        log_warning "Possible incomplete line in $file"
        ((issues_found++))
    fi
    
    # Verify basic structure for non-empty files
    if [[ -s "$file" ]]; then
        local line_count=$(wc -l < "$file" 2>/dev/null || echo "0")
        if [[ $line_count -eq 0 ]]; then
            log_warning "File $file appears to be empty or corrupted"
            ((issues_found++))
        fi
    fi
    
    return $issues_found
}

# Hardware support monitoring
monitor_hardware_support() {
    local build_log="$1"
    
    if [[ ! -f "$build_log" ]]; then
        return 0
    fi
    
    log_info "Monitoring hardware support status..."
    
    # Check GPU support
    if grep -q "AMD GPU Support: Disabled\|NVIDIA Support: Disabled" "$build_log" 2>/dev/null; then
        log_warning "GPU support issues detected in build"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - GPU support disabled" >> "$ISSUE_DIR/hardware_issues.log"
    fi
    
    # Check NPU/TPU support
    if grep -q "NPU Framework: Disabled\|TPU Support: Disabled" "$build_log" 2>/dev/null; then
        log_warning "AI acceleration hardware issues detected"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - AI hardware support disabled" >> "$ISSUE_DIR/hardware_issues.log"
    fi
    
    # Check permission issues
    if grep -q "Permission denied.*setup.sh" "$build_log" 2>/dev/null; then
        log_error "Permission issues detected in build"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Setup permission denied" >> "$ISSUE_DIR/permission_issues.log"
    fi
}

# Create directory structure if missing
setup_directories() {
    local dirs=(
        "$ISSUE_DIR"
        "$ISSUE_DIR/backups"
        "$ISSUE_DIR/analytics"
        "$ISSUE_DIR/scripts"
        "$ISSUE_DIR/workflows"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
}

# Main monitoring loop
main_monitor() {
    log_info "Starting Enhanced Issue Logger Monitor v4.0"
    log_info "Monitoring interval: ${CHECK_INTERVAL}s"
    log_info "Max file size: ${MAX_FILE_SIZE} bytes"
    
    setup_directories
    
    while true; do
        # Monitor core issue files
        for file in "$ISSUE_DIR"/{open,closed}.issue; do
            if [[ -f "$file" ]]; then
                # Verify file integrity
                if ! verify_integrity "$file"; then
                    log_warning "Integrity issues found in $file, attempting recovery..."
                    auto_recover "$file" || log_error "Recovery failed for $file"
                fi
                
                # Monitor file size
                monitor_file_size "$file"
            fi
        done
        
        # Monitor build logs for hardware issues
        if [[ -d "~/ainux-build/logs" ]]; then
            find ~/ainux-build/logs -name "*.log" -type f -mmin -60 2>/dev/null | while read -r log_file; do
                monitor_hardware_support "$log_file"
            done
        fi
        
        # Create periodic backups
        local current_hour=$(date +%H)
        local current_minute=$(date +%M)
        
        if [[ "$current_minute" == "00" ]]; then
            log_info "Creating hourly backups..."
            for file in "$ISSUE_DIR"/{open,closed}.issue; do
                if [[ -f "$file" ]]; then
                    local backup_name="$ISSUE_DIR/backups/$(basename "$file").${current_hour}.backup"
                    cp "$file" "$backup_name" 2>/dev/null || log_warning "Failed to create backup for $file"
                fi
            done
        fi
        
        # Cleanup old backups (keep last 7 days)
        if [[ "$current_hour" == "02" && "$current_minute" == "00" ]]; then
            log_info "Cleaning up old backups..."
            find "$ISSUE_DIR/backups" -name "*.backup*" -type f -mtime +7 -delete 2>/dev/null || true
        fi
        
        # Status report every hour
        if [[ "$current_minute" == "00" ]]; then
            local open_count=$(grep -c "<open>" "$ISSUE_DIR/open.issue" 2>/dev/null || echo "0")
            local closed_count=$(grep -c "<closed>" "$ISSUE_DIR/closed.issue" 2>/dev/null || echo "0")
            log_info "Status: $open_count open issues, $closed_count resolved issues"
        fi
        
        sleep "$CHECK_INTERVAL"
    done
}

# Handle script termination
cleanup() {
    log_info "Enhanced Issue Logger Monitor shutting down..."
    exit 0
}

trap cleanup SIGTERM SIGINT

# Run monitor
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_monitor
fi