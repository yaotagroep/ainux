#!/bin/bash
# Issue Logger Integrity Verification Script
# Verifies file integrity and prevents truncation issues

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOGGER_DIR="${1:-./issue_logger}"
BACKUP_DIR="${LOGGER_DIR}/backups"

echo -e "${BLUE}🔍 Issue Logger Integrity Verification${NC}"
echo -e "${BLUE}====================================${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to check file integrity
check_file_integrity() {
    local file="$1"
    local file_type="$2"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${YELLOW}⚠️  $file_type file not found: $file${NC}"
        return 1
    fi
    
    # Check file size
    local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
    if [[ $size -eq 0 ]]; then
        echo -e "${RED}❌ $file_type file is empty: $file${NC}"
        return 1
    fi
    
    # Check for proper XML-like structure
    if [[ "$file_type" == "Open issues" ]]; then
        # For open issues, check if file has content and proper structure
        if [[ $size -gt 10 ]]; then
            if ! tail -n 5 "$file" | grep -q "</open>"; then
                echo -e "${RED}❌ $file_type file may be truncated (missing closing tag): $file${NC}"
                return 1
            fi
        fi
    elif [[ "$file_type" == "Closed issues" ]]; then
        # For closed issues, check if file has content and proper structure
        if [[ $size -gt 10 ]]; then
            if ! tail -n 5 "$file" | grep -q "</closed>"; then
                echo -e "${RED}❌ $file_type file may be truncated (missing closing tag): $file${NC}"
                return 1
            fi
        fi
    fi
    
    echo -e "${GREEN}✅ $file_type file integrity verified: $file (${size} bytes)${NC}"
    return 0
}

# Function to create backup
create_backup() {
    local file="$1"
    local backup_name="$(basename "$file").$(date +%Y%m%d_%H%M%S).backup"
    
    if [[ -f "$file" ]]; then
        cp "$file" "${BACKUP_DIR}/${backup_name}"
        echo -e "${GREEN}📦 Created backup: ${backup_name}${NC}"
    fi
}

# Function to check and fix permissions
check_permissions() {
    local dir="$1"
    
    if [[ ! -w "$dir" ]]; then
        echo -e "${RED}❌ Logger directory not writable: $dir${NC}"
        return 1
    fi
    
    # Check individual files
    for file in "$dir"/*.issue "$dir"/*.json; do
        if [[ -f "$file" && ! -w "$file" ]]; then
            echo -e "${YELLOW}⚠️  File not writable: $file${NC}"
            chmod 644 "$file" 2>/dev/null || echo -e "${RED}❌ Failed to fix permissions for: $file${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ Permissions verified${NC}"
}

# Function to clean old backups
clean_old_backups() {
    local backup_dir="$1"
    local keep_days="${2:-7}"
    
    if [[ -d "$backup_dir" ]]; then
        echo -e "${BLUE}🧹 Cleaning backups older than $keep_days days...${NC}"
        find "$backup_dir" -name "*.backup" -type f -mtime +$keep_days -delete
        local remaining=$(find "$backup_dir" -name "*.backup" -type f | wc -l)
        echo -e "${GREEN}✅ Backup cleanup complete. $remaining backups remaining.${NC}"
    fi
}

# Main verification process
echo -e "${BLUE}📁 Checking logger directory: $LOGGER_DIR${NC}"

# Check if logger directory exists
if [[ ! -d "$LOGGER_DIR" ]]; then
    echo -e "${RED}❌ Logger directory not found: $LOGGER_DIR${NC}"
    exit 1
fi

# Check permissions
check_permissions "$LOGGER_DIR"

# Check main files
check_file_integrity "$LOGGER_DIR/open.issue" "Open issues"
check_file_integrity "$LOGGER_DIR/closed.issue" "Closed issues"
check_file_integrity "$LOGGER_DIR/config.json" "Configuration"

# Create backups
echo -e "${BLUE}📦 Creating backups...${NC}"
create_backup "$LOGGER_DIR/open.issue"
create_backup "$LOGGER_DIR/closed.issue"
create_backup "$LOGGER_DIR/config.json"

# Clean old backups
clean_old_backups "$BACKUP_DIR" 7

# Check disk space
echo -e "${BLUE}💾 Checking disk space...${NC}"
df -h "$LOGGER_DIR" | tail -1 | awk '{
    if ($5+0 > 90) 
        print "⚠️  Warning: Disk usage high (" $5 " used)"
    else 
        print "✅ Disk space OK (" $5 " used)"
}'

# Final report
echo -e "${BLUE}📊 Verification Summary${NC}"
echo -e "${BLUE}=====================${NC}"

total_files=$(find "$LOGGER_DIR" -name "*.issue" -o -name "*.json" | wc -l)
total_backups=$(find "$BACKUP_DIR" -name "*.backup" 2>/dev/null | wc -l)
total_size=$(du -sh "$LOGGER_DIR" | cut -f1)

echo -e "  📁 Logger files: $total_files"
echo -e "  📦 Backup files: $total_backups"
echo -e "  💾 Total size: $total_size"
echo -e "${GREEN}✅ Integrity verification complete${NC}"

exit 0