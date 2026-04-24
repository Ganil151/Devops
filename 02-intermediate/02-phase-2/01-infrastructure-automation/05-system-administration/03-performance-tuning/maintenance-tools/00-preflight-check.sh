#!/bin/bash
# PRE-MIGRATION SAFETY CHECKLIST
# DO NOT PROCEED UNTIL ALL ITEMS ARE CHECKED

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   DEVOPS REORGANIZATION - PRE-FLIGHT SAFETY CHECKLIST          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  WARNING: This operation will reorganize 4,687 files and"
echo "   potentially break 3,131 internal links temporarily."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "REQUIRED SAFETY MEASURES:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

CHECKLIST_COMPLETE=true

# Check 1: Git repository status
echo "[1/7] Checking Git repository status..."
if [ -d ".git" ]; then
    if git diff-index --quiet HEAD --; then
        echo "    ✅ Git: Clean working directory"
    else
        echo "    ❌ Git: You have uncommitted changes!"
        echo "       ACTION REQUIRED: Commit all changes before proceeding"
        CHECKLIST_COMPLETE=false
    fi
else
    echo "    ⚠️  Warning: Not a git repository"
    echo "       STRONGLY RECOMMENDED: Initialize git first"
fi

# Check 2: Backup existence
echo ""
echo "[2/7] Checking for backup..."
BACKUP_DIR="../Devops-Backup-$(date +%Y%m%d)"
if [ -d "$BACKUP_DIR" ]; then
    echo "    ✅ Backup exists at: $BACKUP_DIR"
else
    echo "    ❌ No backup found!"
    echo "       ACTION REQUIRED: Create backup first"
    echo "       Run: cp -r . '$BACKUP_DIR'"
    CHECKLIST_COMPLETE=false
fi

# Check 3: Disk space
echo ""
echo "[3/7] Checking disk space..."
REQUIRED_SPACE=5000000  # 5GB in KB
AVAILABLE_SPACE=$(df . | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -gt "$REQUIRED_SPACE" ]; then
    echo "    ✅ Disk space: $(($AVAILABLE_SPACE / 1024 / 1024))GB available"
else
    echo "    ❌ Insufficient disk space!"
    echo "       Required: 5GB, Available: $(($AVAILABLE_SPACE / 1024 / 1024))GB"
    CHECKLIST_COMPLETE=false
fi

# Check 4: Python availability
echo ""
echo "[4/7] Checking Python installation..."
if command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1)
    echo "    ✅ Python found: $PYTHON_VERSION"
else
    echo "    ❌ Python not found!"
    echo "       ACTION REQUIRED: Install Python 3.7+"
    CHECKLIST_COMPLETE=false
fi

# Check 5: Required permissions
echo ""
echo "[5/7] Checking file permissions..."
if [ -w "." ]; then
    echo "    ✅ Write permissions: OK"
else
    echo "    ❌ No write permission in current directory!"
    CHECKLIST_COMPLETE=false
fi

# Check 6: Time availability
echo ""
echo "[6/7] Estimated time requirements..."
echo "    ⏱️  Migration time: 12-16 hours"
echo "    ⏱️  Validation time: 2-4 hours"
echo "    ⏱️  Total commitment: 14-20 hours"
echo ""
read -p "    Do you have this time available? (yes/no): " TIME_CONFIRM
if [ "$TIME_CONFIRM" != "yes" ]; then
    echo "    ❌ Time commitment not confirmed"
    CHECKLIST_COMPLETE=false
else
    echo "    ✅ Time commitment: Confirmed"
fi

# Check 7: Final confirmation
echo ""
echo "[7/7] Understanding the risks..."
echo ""
echo "    By proceeding, you acknowledge that:"
echo "    • 3,131 internal links will temporarily break"
echo "    • 709 Mermaid diagrams may need path updates"
echo "    • Git history may become harder to track"
echo "    • Manual intervention may be required"
echo "    • The process is NOT easily reversible mid-way"
echo ""
read -p "    I understand and accept these risks (type 'I ACCEPT'): " RISK_ACCEPT

if [ "$RISK_ACCEPT" != "I ACCEPT" ]; then
    echo "    ❌ Risk acknowledgment: Not confirmed"
    CHECKLIST_COMPLETE=false
else
    echo "    ✅ Risk acknowledgment: Confirmed"
fi

# Final verdict
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$CHECKLIST_COMPLETE" = true ]; then
    echo "✅ PRE-FLIGHT CHECKLIST: PASSED"
    echo ""
    echo "You may now proceed with migration."
    echo "Run: python 02_migrate_files.py"
    echo ""
    exit 0
else
    echo "❌ PRE-FLIGHT CHECKLIST: FAILED"
    echo ""
    echo "Please resolve the issues above before proceeding."
    echo "This is for YOUR protection."
    echo ""
    exit 1
fi
