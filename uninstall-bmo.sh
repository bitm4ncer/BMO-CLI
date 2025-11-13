#!/usr/bin/env bash

#################################################
# BMO Uninstall Script
# Removes BMO CLI Assistant and Fastfetch Theme
#################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# BMO ASCII art
print_bmo_banner() {
    echo -e "${CYAN}"
    echo '   ___  __  __  ___  '
    echo '  | _ )|  \/  |/ _ \ '
    echo '  | _ \ |\/| | (_) |'
    echo '  |___/_|  |_|\___/ '
    echo -e "${NC}"
    echo -e "${YELLOW}🤖 BMO Uninstaller${NC}"
    echo "======================================"
    echo ""
}

# Print step messages
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_bmo_banner

echo -e "${YELLOW}This will remove BMO CLI Assistant and Fastfetch theme from your system.${NC}"
echo ""
echo "The following will be removed:"
echo "  • BMO Fish function (~/.config/fish/functions/bmo.fish)"
echo "  • BMO conversation history (~/.local/share/bmo/)"
echo "  • BMO Fastfetch theme (~/.config/fastfetch/)"
echo "  • API key from Fish config (~/.config/fish/config.fish)"
echo "  • Fastfetch startup entries from shell profiles"
echo ""
read -p "Are you sure you want to uninstall BMO? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Uninstall cancelled. BMO lives another day! 🎮${NC}"
    exit 0
fi

echo ""

# ============================================
# Step 1: Remove BMO Fish function
# ============================================
print_step "Removing BMO Fish function..."

BMO_FUNCTION="$HOME/.config/fish/functions/bmo.fish"

if [ -f "$BMO_FUNCTION" ]; then
    rm "$BMO_FUNCTION"
    print_success "BMO function removed"
else
    print_warning "BMO function not found (already removed?)"
fi

echo ""

# ============================================
# Step 2: Remove API key from Fish config
# ============================================
print_step "Removing API key from Fish config..."

FISH_CONFIG="$HOME/.config/fish/config.fish"

if [ -f "$FISH_CONFIG" ]; then
    if grep -q "ANTHROPIC_API_KEY" "$FISH_CONFIG"; then
        # Create backup
        cp "$FISH_CONFIG" "$FISH_CONFIG.bmo-backup"

        # Remove BMO-related lines
        sed -i '/# BMO CLI Assistant - API Key/d' "$FISH_CONFIG"
        sed -i '/ANTHROPIC_API_KEY/d' "$FISH_CONFIG"

        print_success "API key removed from Fish config (backup saved to config.fish.bmo-backup)"
    else
        print_warning "API key not found in Fish config"
    fi
else
    print_warning "Fish config not found"
fi

echo ""

# ============================================
# Step 3: Remove Fastfetch from shell configs
# ============================================
print_step "Removing Fastfetch startup entries..."

# Remove from Fish config
if [ -f "$FISH_CONFIG" ]; then
    if grep -q "# BMO Fastfetch" "$FISH_CONFIG"; then
        sed -i '/# BMO Fastfetch/,/end/d' "$FISH_CONFIG"
        print_success "Fastfetch removed from Fish config"
    fi
fi

# Remove from Bash config
if [ -f "$HOME/.bashrc" ]; then
    if grep -q "# BMO Fastfetch" "$HOME/.bashrc"; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.bmo-backup"
        sed -i '/# BMO Fastfetch/,/fi/d' "$HOME/.bashrc"
        print_success "Fastfetch removed from Bash config (backup saved)"
    fi
fi

# Remove from Zsh config
if [ -f "$HOME/.zshrc" ]; then
    if grep -q "# BMO Fastfetch" "$HOME/.zshrc"; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.bmo-backup"
        sed -i '/# BMO Fastfetch/,/fi/d' "$HOME/.zshrc"
        print_success "Fastfetch removed from Zsh config (backup saved)"
    fi
fi

echo ""

# ============================================
# Step 4: Remove BMO conversation history
# ============================================
print_step "Removing BMO conversation history..."

BMO_HISTORY_DIR="$HOME/.local/share/bmo"

if [ -d "$BMO_HISTORY_DIR" ]; then
    echo ""
    echo -e "${YELLOW}BMO history directory found at: $BMO_HISTORY_DIR${NC}"
    echo "This contains your conversation history with BMO."
    echo ""
    read -p "Remove BMO history? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create backup
        HISTORY_BACKUP_DIR="$HOME/.local/share/bmo.bmo-backup-$(date +%Y%m%d-%H%M%S)"
        mv "$BMO_HISTORY_DIR" "$HISTORY_BACKUP_DIR"
        print_success "BMO history moved to $HISTORY_BACKUP_DIR"
    else
        print_warning "BMO history kept at $BMO_HISTORY_DIR"
    fi
else
    print_warning "BMO history directory not found"
fi

echo ""

# ============================================
# Step 5: Remove Fastfetch theme
# ============================================
print_step "Removing BMO Fastfetch theme..."

FASTFETCH_DIR="$HOME/.config/fastfetch"

if [ -d "$FASTFETCH_DIR" ]; then
    echo ""
    echo -e "${YELLOW}Fastfetch directory found at: $FASTFETCH_DIR${NC}"
    echo ""
    read -p "Remove entire Fastfetch directory? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create backup
        BACKUP_DIR="$HOME/.config/fastfetch.bmo-backup-$(date +%Y%m%d-%H%M%S)"
        mv "$FASTFETCH_DIR" "$BACKUP_DIR"
        print_success "Fastfetch directory moved to $BACKUP_DIR"
    else
        # Remove only BMO-specific files
        rm -f "$FASTFETCH_DIR/config.jsonc"
        rm -f "$FASTFETCH_DIR/ascii.txt"
        rm -f "$FASTFETCH_DIR/bmo_eyes.txt"
        rm -f "$FASTFETCH_DIR/bmo_mouths.txt"
        rm -f "$FASTFETCH_DIR/bmo_sayings.txt"
        rm -f "$FASTFETCH_DIR/random_eyes.sh"
        rm -f "$FASTFETCH_DIR/random_saying.sh"
        rm -f "$FASTFETCH_DIR/color_wave.sh"
        print_success "BMO Fastfetch theme files removed (directory kept)"
    fi
else
    print_warning "Fastfetch directory not found"
fi

echo ""

# ============================================
# Success!
# ============================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║     BMO has been uninstalled. Goodbye!     ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}What was removed:${NC}"
echo "  ✓ BMO Fish function"
echo "  ✓ API key configuration"
echo "  ✓ Conversation history (if selected)"
echo "  ✓ Fastfetch shell integration"
echo "  ✓ BMO Fastfetch theme"
echo ""

echo -e "${YELLOW}Backup files created:${NC}"
BACKUPS_CREATED=false
if [ -f "$FISH_CONFIG.bmo-backup" ]; then
    echo "  • $FISH_CONFIG.bmo-backup"
    BACKUPS_CREATED=true
fi
if [ -f "$HOME/.bashrc.bmo-backup" ]; then
    echo "  • $HOME/.bashrc.bmo-backup"
    BACKUPS_CREATED=true
fi
if [ -f "$HOME/.zshrc.bmo-backup" ]; then
    echo "  • $HOME/.zshrc.bmo-backup"
    BACKUPS_CREATED=true
fi
if [ -d "$HISTORY_BACKUP_DIR" ] 2>/dev/null; then
    echo "  • $HISTORY_BACKUP_DIR"
    BACKUPS_CREATED=true
fi
if [ -d "$BACKUP_DIR" ] 2>/dev/null; then
    echo "  • $BACKUP_DIR"
    BACKUPS_CREATED=true
fi
if [ "$BACKUPS_CREATED" = false ]; then
    echo "  (none)"
fi
echo ""

echo -e "${BLUE}If you ever want BMO back, just run setup-bmo.sh again! 🎮${NC}"
echo ""
