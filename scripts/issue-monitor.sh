#!/bin/bash
# 📊 Issue Logger Health Monitor v2.1
# Real-time monitoring and truncation prevention for Ainux OS issue logging system
# 
# This script provides comprehensive protection against log file truncation,
# corruption, and data loss through continuous monitoring and automated recovery.

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ISSUE_DIR="${PROJECT_ROOT}/issue_logger"
BACKUP_DIR="${ISSUE_DIR}/backups"
CHECK_INTERVAL=30
MAX_FILE_SIZE=104857600  # 100MB
RETENTION_DAYS=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case "$level" in
        "INFO") color="$GREEN" ;;
        "WARN") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        *) color="$NC" ;;
    esac
    
    echo -e "${color}[$timestamp] [$level] $message${NC}"
    
    # Also log to file if available
    if [[ -d "$ISSUE_DIR" ]]; then
        echo "[$timestamp] [$level] $message" >> "$ISSUE_DIR/monitor.log"
    fi
}

# Create directory structure if it doesn't exist
initialize_directories() {
    log_message "INFO" "Initializing issue logger directory structure..."
    
    mkdir -p "$ISSUE_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$ISSUE_DIR/analytics"
    
    # Create config if it doesn't exist
    if [[ ! -f "$ISSUE_DIR/config.json" ]]; then
        cat > "$ISSUE_DIR/config.json" << 'EOF'
{
  "version": "2.1",
  "auto_logging": {
    "enabled": true,
    "severity_threshold": "MEDIUM",
    "excluded_categories": ["STY"],
    "max_snippet_length": 200
  },
  "auto_resolution": {
    "enabled": true,
    "require_confirmation": false,
    "retest_on_fix": true
  },
  "truncation_prevention": {
    "enabled": true,
    "max_file_size_mb": 100,
    "backup_interval_minutes": 60,
    "integrity_check_interval": 30,
    "auto_recovery": true
  },
  "notifications": {
    "critical_issues": true,
    "daily_summary": true,
    "truncation_alerts": true
  },
  "retention": {
    "keep_closed_days": 90,
    "archive_after_days": 365,
    "backup_retention_days": 30
  }
}
EOF
        log_message "INFO" "Created default configuration file"
    fi
    
    # Initialize issue files if they don't exist
    for file in "open.issue" "closed.issue"; do
        local filepath="$ISSUE_DIR/$file"
        if [[ ! -f "$filepath" ]]; then
            touch "$filepath"
            chmod 644 "$filepath"
            log_message "INFO" "Created $file"
        fi
    done
}

# Monitor file size and rotate if necessary
monitor_file_size() {
    local file="$1"
    local max_size="${2:-$MAX_FILE_SIZE}"
    
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    
    local current_size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    
    if [[ $current_size -gt $max_size ]]; then
        log_message "WARN" "File $file size ($current_size bytes) exceeds limit ($max_size bytes)"
        
        # Create backup before rotation
        local backup_file="${BACKUP_DIR}/$(basename "$file").rotation.$(date +%s).backup"
        cp "$file" "$backup_file"
        sha256sum "$backup_file" > "${backup_file}.sha256"
        
        # Rotate the file
        mv "$file" "${file}.rotated.$(date +%s)"
        touch "$file"
        chmod 644 "$file"
        
        log_message "INFO" "Rotated $file and created backup at $backup_file"
    fi
}

# Check file integrity
verify_integrity() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    
    local filename=$(basename "$file")
    local last_line=$(tail -n 1 "$file" 2>/dev/null || echo "")
    
    case "$filename" in
        "open.issue")
            if [[ -n "$last_line" && ! "$last_line" =~ \</open\> ]]; then
                log_message "WARN" "Possible truncation detected in $file (missing </open> tag)"
                return 1
            fi
            ;;
        "closed.issue")
            if [[ -n "$last_line" && ! "$last_line" =~ \</closed\> ]]; then
                log_message "WARN" "Possible truncation detected in $file (missing </closed> tag)"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Create backup with verification
create_backup() {
    local file="$1"
    local backup_type="${2:-scheduled}"
    
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/$(basename "$file").${backup_type}.${timestamp}.backup"
    
    # Copy file and create checksum
    cp "$file" "$backup_file"
    sha256sum "$backup_file" > "${backup_file}.sha256"
    
    # Verify backup integrity
    if sha256sum -c "${backup_file}.sha256" >/dev/null 2>&1; then
        log_message "INFO" "Created verified backup: $(basename "$backup_file")"
        return 0
    else
        log_message "ERROR" "Backup verification failed for $backup_file"
        rm -f "$backup_file" "${backup_file}.sha256"
        return 1
    fi
}

# Auto-recovery for corrupted files
auto_recover() {
    local file="$1"
    
    log_message "WARN" "Attempting auto-recovery for $file"
    
    # Find most recent backup
    local backup_pattern="${BACKUP_DIR}/$(basename "$file").*.backup"
    local latest_backup=$(ls -t $backup_pattern 2>/dev/null | head -1)
    
    if [[ -n "$latest_backup" && -f "$latest_backup" ]]; then
        # Verify backup integrity
        local checksum_file="${latest_backup}.sha256"
        if [[ -f "$checksum_file" ]] && sha256sum -c "$checksum_file" >/dev/null 2>&1; then
            log_message "INFO" "Restoring from verified backup: $(basename "$latest_backup")"
            cp "$latest_backup" "$file"
            return 0
        else
            log_message "ERROR" "Backup integrity check failed for $latest_backup"
        fi
    else
        log_message "ERROR" "No valid backup found for recovery of $file"
    fi
    
    return 1
}

# Cleanup old backups
cleanup_old_backups() {
    local retention_days="$RETENTION_DAYS"
    
    log_message "INFO" "Cleaning up backups older than $retention_days days"
    
    find "$BACKUP_DIR" -name "*.backup" -type f -mtime +$retention_days -delete 2>/dev/null || true
    find "$BACKUP_DIR" -name "*.sha256" -type f -mtime +$retention_days -delete 2>/dev/null || true
    
    # Log cleanup results
    local remaining_backups=$(find "$BACKUP_DIR" -name "*.backup" -type f | wc -l)
    log_message "INFO" "Cleanup completed. $remaining_backups backup files remaining"
}

# Generate health report
generate_health_report() {
    local report_file="$ISSUE_DIR/health_report.txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$report_file" << EOF
# Issue Logger Health Report
Generated: $timestamp

## File Status
EOF
    
    for file in "$ISSUE_DIR/open.issue" "$ISSUE_DIR/closed.issue"; do
        if [[ -f "$file" ]]; then
            local size=$(stat -c%s "$file")
            local lines=$(wc -l < "$file")
            local last_modified=$(stat -c%y "$file")
            
            echo "- $(basename "$file"): $size bytes, $lines lines, modified $last_modified" >> "$report_file"
        else
            echo "- $(basename "$file"): File not found" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
    echo "## Backup Status" >> "$report_file"
    local backup_count=$(find "$BACKUP_DIR" -name "*.backup" -type f | wc -l)
    echo "- Total backups: $backup_count" >> "$report_file"
    echo "- Backup directory size: $(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)" >> "$report_file"
    
    log_message "INFO" "Health report generated at $report_file"
}

# Main monitoring loop
monitor_loop() {
    log_message "INFO" "Starting issue logger health monitor (PID: $$)"
    log_message "INFO" "Monitoring directory: $ISSUE_DIR"
    log_message "INFO" "Check interval: ${CHECK_INTERVAL}s"
    
    local iteration=0
    
    while true; do
        iteration=$((iteration + 1))
        
        # Monitor critical files
        for file in "$ISSUE_DIR/open.issue" "$ISSUE_DIR/closed.issue"; do
            # Check file size
            monitor_file_size "$file"
            
            # Check integrity
            if ! verify_integrity "$file"; then
                # Attempt recovery if integrity check fails
                auto_recover "$file"
            fi
        done
        
        # Hourly tasks
        local current_minute=$(date +%M)
        if [[ "$current_minute" == "00" ]]; then
            log_message "INFO" "Performing hourly maintenance tasks"
            
            # Create scheduled backups
            for file in "$ISSUE_DIR/open.issue" "$ISSUE_DIR/closed.issue"; do
                create_backup "$file" "hourly"
            done
            
            # Generate health report
            generate_health_report
        fi
        
        # Daily tasks (at midnight)
        local current_hour=$(date +%H)
        if [[ "$current_hour" == "00" && "$current_minute" == "00" ]]; then
            log_message "INFO" "Performing daily maintenance tasks"
            cleanup_old_backups
        fi
        
        # Log periodic status
        if [[ $((iteration % 10)) -eq 0 ]]; then
            log_message "INFO" "Monitor active (iteration $iteration) - All systems nominal"
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Signal handlers
cleanup_and_exit() {
    log_message "INFO" "Received shutdown signal, performing cleanup..."
    log_message "INFO" "Issue logger health monitor stopped"
    exit 0
}

# Set up signal handlers
trap cleanup_and_exit SIGTERM SIGINT

# Main execution
main() {
    echo -e "${BLUE}📊 Ainux OS Issue Logger Health Monitor v2.1${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    # Initialize
    initialize_directories
    
    # Check if running as daemon
    if [[ "${1:-}" == "--daemon" ]]; then
        log_message "INFO" "Starting in daemon mode"
        monitor_loop &
        echo $! > "$ISSUE_DIR/monitor.pid"
        log_message "INFO" "Monitor started with PID $(cat "$ISSUE_DIR/monitor.pid")"
    elif [[ "${1:-}" == "--stop" ]]; then
        if [[ -f "$ISSUE_DIR/monitor.pid" ]]; then
            local pid=$(cat "$ISSUE_DIR/monitor.pid")
            log_message "INFO" "Stopping monitor (PID: $pid)"
            kill $pid 2>/dev/null || log_message "WARN" "Process $pid not found"
            rm -f "$ISSUE_DIR/monitor.pid"
        else
            log_message "WARN" "No monitor PID file found"
        fi
    elif [[ "${1:-}" == "--status" ]]; then
        if [[ -f "$ISSUE_DIR/monitor.pid" ]]; then
            local pid=$(cat "$ISSUE_DIR/monitor.pid")
            if kill -0 $pid 2>/dev/null; then
                log_message "INFO" "Monitor is running (PID: $pid)"
                generate_health_report
                cat "$ISSUE_DIR/health_report.txt"
            else
                log_message "WARN" "Monitor PID file exists but process not running"
            fi
        else
            log_message "INFO" "Monitor is not running"
        fi
    else
        # Run in foreground
        log_message "INFO" "Starting in foreground mode (use --daemon for background)"
        monitor_loop
    fi
}

# Execute main function with all arguments
main "$@"