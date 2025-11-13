#!/usr/bin/env bash

#################################################
# BMO Setup Wizard
# Installs BMO CLI Assistant for Fish Shell
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
    echo -e "${YELLOW}🤖 BMO CLI Assistant Setup${NC}"
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_bmo_banner

# ============================================
# Step 1: Check for Fish Shell
# ============================================
print_step "Checking for Fish shell..."

if command_exists fish; then
    FISH_VERSION=$(fish --version 2>/dev/null | cut -d' ' -f3)
    print_success "Fish shell installed (version $FISH_VERSION)"
else
    print_warning "Fish shell not found"
    echo ""
    echo "BMO requires Fish shell to work. Would you like to install it?"
    echo ""
    echo "Installation methods:"
    echo "  • Ubuntu/Debian: sudo apt install fish"
    echo "  • Fedora:        sudo dnf install fish"
    echo "  • Arch:          sudo pacman -S fish"
    echo "  • macOS:         brew install fish"
    echo ""
    read -p "Install Fish shell now? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Detect OS and install Fish
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y fish
        elif command_exists dnf; then
            sudo dnf install -y fish
        elif command_exists pacman; then
            sudo pacman -S --noconfirm fish
        elif command_exists brew; then
            brew install fish
        else
            print_error "Could not detect package manager. Please install Fish manually:"
            echo "  https://fishshell.com/"
            exit 1
        fi

        if command_exists fish; then
            print_success "Fish shell installed successfully!"
        else
            print_error "Fish installation failed. Please install manually."
            exit 1
        fi
    else
        print_error "Fish shell is required for BMO. Exiting."
        exit 1
    fi
fi

echo ""

# ============================================
# Step 2: Check for required tools
# ============================================
print_step "Checking for required tools..."

MISSING_TOOLS=()

if ! command_exists curl; then
    MISSING_TOOLS+=("curl")
fi

if ! command_exists jq; then
    MISSING_TOOLS+=("jq")
fi

if ! command_exists fastfetch; then
    MISSING_TOOLS+=("fastfetch")
fi

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    print_success "All required tools are installed (curl, jq, fastfetch)"
else
    print_warning "Missing required tools: ${MISSING_TOOLS[*]}"
    echo ""
    echo "Installation commands:"
    echo "  • Ubuntu/Debian: sudo apt install ${MISSING_TOOLS[*]}"
    echo "  • Fedora:        sudo dnf install ${MISSING_TOOLS[*]}"
    echo "  • Arch:          sudo pacman -S ${MISSING_TOOLS[*]}"
    echo "  • macOS:         brew install ${MISSING_TOOLS[*]}"
    echo ""
    read -p "Install missing tools now? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y "${MISSING_TOOLS[@]}"
        elif command_exists dnf; then
            sudo dnf install -y "${MISSING_TOOLS[@]}"
        elif command_exists pacman; then
            sudo pacman -S --noconfirm "${MISSING_TOOLS[@]}"
        elif command_exists brew; then
            brew install "${MISSING_TOOLS[@]}"
        else
            print_error "Could not detect package manager. Please install tools manually."
            exit 1
        fi
        print_success "Tools installed successfully!"
    else
        print_error "Required tools not installed. Exiting."
        exit 1
    fi
fi

echo ""

# ============================================
# Step 3: Setup Fish directories
# ============================================
print_step "Setting up Fish configuration directories..."

FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_FUNCTIONS_DIR="$FISH_CONFIG_DIR/functions"
FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"

mkdir -p "$FISH_FUNCTIONS_DIR"
print_success "Fish directories created/verified"

echo ""

# ============================================
# Step 4: Get Anthropic API Key
# ============================================
print_step "Configuring Anthropic API key..."

API_KEY=""
API_KEY_SOURCE=""

# Check for Claude Code credentials
CLAUDE_CREDS="$HOME/.claude/.credentials.json"
if [ -f "$CLAUDE_CREDS" ]; then
    print_success "Found Claude Code credentials at $CLAUDE_CREDS"

    # Try to extract API key using jq
    if command_exists jq; then
        EXTRACTED_KEY=$(jq -r '.apiKey // .api_key // empty' "$CLAUDE_CREDS" 2>/dev/null || true)

        if [ -n "$EXTRACTED_KEY" ] && [ "$EXTRACTED_KEY" != "null" ]; then
            echo ""
            echo "Found API key in Claude Code credentials:"
            echo "  ${EXTRACTED_KEY:0:20}..."
            echo ""
            read -p "Use this API key for BMO? (Y/n): " -n 1 -r
            echo ""

            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                API_KEY="$EXTRACTED_KEY"
                API_KEY_SOURCE="Claude Code"
                print_success "Using API key from Claude Code!"
            fi
        fi
    fi
fi

# If we don't have an API key yet, check environment variable
if [ -z "$API_KEY" ] && [ -n "$ANTHROPIC_API_KEY" ]; then
    echo ""
    echo "Found ANTHROPIC_API_KEY in environment:"
    echo "  ${ANTHROPIC_API_KEY:0:20}..."
    echo ""
    read -p "Use this API key for BMO? (Y/n): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        API_KEY="$ANTHROPIC_API_KEY"
        API_KEY_SOURCE="Environment variable"
        print_success "Using API key from environment!"
    fi
fi

# If still no API key, prompt user
if [ -z "$API_KEY" ]; then
    echo ""
    echo "No API key found. You can get one from:"
    echo "  ${CYAN}https://console.anthropic.com/${NC}"
    echo ""
    echo "Please paste your Anthropic API key (starts with 'sk-ant-'):"
    read -r API_KEY

    if [ -z "$API_KEY" ]; then
        print_error "No API key provided. Exiting."
        exit 1
    fi

    # Basic validation
    if [[ ! "$API_KEY" =~ ^sk-ant- ]]; then
        print_warning "API key doesn't start with 'sk-ant-'. This might not be valid."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    API_KEY_SOURCE="Manual entry"
    print_success "API key received!"
fi

echo ""

# ============================================
# Step 5: Install BMO function
# ============================================
print_step "Installing BMO function..."

BMO_SOURCE="$SCRIPT_DIR/bmo.fish"
BMO_DEST="$FISH_FUNCTIONS_DIR/bmo.fish"

# Check if bmo.fish exists in script directory
if [ ! -f "$BMO_SOURCE" ]; then
    # Try alternative location (if bmo.fish is in ~/.config/fish/functions already)
    ALT_BMO="/home/$USER/.config/fish/functions/bmo.fish"
    if [ -f "$ALT_BMO" ]; then
        print_success "BMO function already installed at $BMO_DEST"
    else
        print_error "Could not find bmo.fish source file at $BMO_SOURCE"
        echo ""
        echo "Please ensure bmo.fish is in the same directory as this setup script."
        exit 1
    fi
else
    # Copy bmo.fish to functions directory
    cp "$BMO_SOURCE" "$BMO_DEST"
    print_success "BMO function installed to $BMO_DEST"
fi

echo ""

# ============================================
# Step 6: Configure Fish config file
# ============================================
print_step "Configuring Fish shell..."

# Create config file if it doesn't exist
touch "$FISH_CONFIG_FILE"

# Check if API key is already in config
if grep -q "ANTHROPIC_API_KEY" "$FISH_CONFIG_FILE" 2>/dev/null; then
    print_warning "ANTHROPIC_API_KEY already exists in config.fish"
    echo ""
    read -p "Replace existing API key? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove old API key line(s)
        sed -i.bak '/ANTHROPIC_API_KEY/d' "$FISH_CONFIG_FILE"
        echo "" >> "$FISH_CONFIG_FILE"
        echo "# BMO CLI Assistant - API Key ($API_KEY_SOURCE)" >> "$FISH_CONFIG_FILE"
        echo "set -gx ANTHROPIC_API_KEY '$API_KEY'" >> "$FISH_CONFIG_FILE"
        print_success "API key updated in config.fish"
    else
        print_warning "Keeping existing API key configuration"
    fi
else
    # Add API key to config
    echo "" >> "$FISH_CONFIG_FILE"
    echo "# BMO CLI Assistant - API Key ($API_KEY_SOURCE)" >> "$FISH_CONFIG_FILE"
    echo "set -gx ANTHROPIC_API_KEY '$API_KEY'" >> "$FISH_CONFIG_FILE"
    print_success "API key added to config.fish"
fi

echo ""

# ============================================
# Step 7: Install BMO Fastfetch Theme
# ============================================
print_step "Installing BMO Fastfetch theme..."

FASTFETCH_DIR="$HOME/.config/fastfetch"
mkdir -p "$FASTFETCH_DIR"

# Check if fastfetch files exist in script directory
FASTFETCH_SOURCE_DIR="$SCRIPT_DIR/fastfetch"

# Copy fastfetch configuration files if they exist
if [ -f "$FASTFETCH_SOURCE_DIR/config.jsonc" ]; then
    print_success "Found fastfetch configuration files"

    # Ask if user wants to install/overwrite
    if [ -f "$FASTFETCH_DIR/config.jsonc" ]; then
        echo ""
        read -p "BMO fastfetch config already exists. Overwrite? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Skipping fastfetch theme installation"
        else
            cp "$FASTFETCH_SOURCE_DIR/config.jsonc" "$FASTFETCH_DIR/"
            cp "$FASTFETCH_SOURCE_DIR/ascii.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
            cp "$FASTFETCH_SOURCE_DIR/bmo_eyes.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
            cp "$FASTFETCH_SOURCE_DIR/bmo_mouths.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
            cp "$FASTFETCH_SOURCE_DIR/bmo_sayings.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
            cp "$FASTFETCH_SOURCE_DIR/random_eyes.sh" "$FASTFETCH_DIR/" 2>/dev/null || true
            cp "$FASTFETCH_SOURCE_DIR/random_saying.sh" "$FASTFETCH_DIR/" 2>/dev/null || true
            cp "$FASTFETCH_SOURCE_DIR/color_wave.sh" "$FASTFETCH_DIR/" 2>/dev/null || true
            chmod +x "$FASTFETCH_DIR"/*.sh 2>/dev/null || true
            print_success "BMO Fastfetch theme installed!"
        fi
    else
        cp "$FASTFETCH_SOURCE_DIR/config.jsonc" "$FASTFETCH_DIR/"
        cp "$FASTFETCH_SOURCE_DIR/ascii.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
        cp "$FASTFETCH_SOURCE_DIR/bmo_eyes.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
        cp "$FASTFETCH_SOURCE_DIR/bmo_mouths.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
        cp "$FASTFETCH_SOURCE_DIR/bmo_sayings.txt" "$FASTFETCH_DIR/" 2>/dev/null || true
        cp "$FASTFETCH_SOURCE_DIR/random_eyes.sh" "$FASTFETCH_DIR/" 2>/dev/null || true
        cp "$FASTFETCH_SOURCE_DIR/random_saying.sh" "$FASTFETCH_DIR/" 2>/dev/null || true
        cp "$FASTFETCH_SOURCE_DIR/color_wave.sh" "$FASTFETCH_DIR/" 2>/dev/null || true
        chmod +x "$FASTFETCH_DIR"/*.sh 2>/dev/null || true
        print_success "BMO Fastfetch theme installed!"
    fi
else
    print_warning "Fastfetch configuration files not found in $FASTFETCH_SOURCE_DIR"
    print_warning "Skipping fastfetch theme installation"
fi

echo ""

# ============================================
# Step 8: Configure shell profiles for fastfetch
# ============================================
print_step "Configuring shell profiles to run fastfetch..."

# Add fastfetch to Fish config
if ! grep -q "fastfetch" "$FISH_CONFIG_FILE" 2>/dev/null; then
    echo "" >> "$FISH_CONFIG_FILE"
    echo "# BMO Fastfetch - Show system info on shell start" >> "$FISH_CONFIG_FILE"
    echo "if status is-interactive" >> "$FISH_CONFIG_FILE"
    echo "    # Randomize BMO's expression before running fastfetch" >> "$FISH_CONFIG_FILE"
    echo "    bash ~/.config/fastfetch/random_eyes.sh 2>/dev/null" >> "$FISH_CONFIG_FILE"
    echo "    fastfetch" >> "$FISH_CONFIG_FILE"
    echo "end" >> "$FISH_CONFIG_FILE"
    print_success "Fastfetch configured for Fish shell"
else
    print_warning "Fastfetch already configured in Fish config"
fi

# Add fastfetch to bash profile if it exists
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "fastfetch" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# BMO Fastfetch - Show system info on shell start" >> "$HOME/.bashrc"
        echo "if [ -t 0 ]; then" >> "$HOME/.bashrc"
        echo "    # Randomize BMO's expression before running fastfetch" >> "$HOME/.bashrc"
        echo "    bash ~/.config/fastfetch/random_eyes.sh 2>/dev/null" >> "$HOME/.bashrc"
        echo "    fastfetch" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
        print_success "Fastfetch configured for Bash shell"
    else
        print_warning "Fastfetch already configured in Bash config"
    fi
fi

# Add fastfetch to zsh profile if it exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "fastfetch" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# BMO Fastfetch - Show system info on shell start" >> "$HOME/.zshrc"
        echo "if [[ -o interactive ]]; then" >> "$HOME/.zshrc"
        echo "    # Randomize BMO's expression before running fastfetch" >> "$HOME/.zshrc"
        echo "    bash ~/.config/fastfetch/random_eyes.sh 2>/dev/null" >> "$HOME/.zshrc"
        echo "    fastfetch" >> "$HOME/.zshrc"
        echo "fi" >> "$HOME/.zshrc"
        print_success "Fastfetch configured for Zsh shell"
    else
        print_warning "Fastfetch already configured in Zsh config"
    fi
fi

echo ""

# ============================================
# Step 9: Verify installation
# ============================================
print_step "Verifying installation..."

# Check if files exist
if [ -f "$BMO_DEST" ] && grep -q "ANTHROPIC_API_KEY" "$FISH_CONFIG_FILE"; then
    print_success "All files configured correctly!"
else
    print_error "Installation verification failed"
    exit 1
fi

echo ""

# ============================================
# Success!
# ============================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║  🤖 BMO is ready to help you, friend!  🤖  ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Start Fish shell (or restart your terminal):"
echo -e "   ${CYAN}fish${NC}"
echo ""
echo "2. Try BMO with a simple command:"
echo -e "   ${CYAN}bmo list files in current directory${NC}"
echo ""
echo "3. More examples:"
echo -e "   ${CYAN}bmo show disk usage${NC}"
echo -e "   ${CYAN}bmo find all python files${NC}"
echo -e "   ${CYAN}bmo count lines of code${NC}"
echo ""

echo -e "${YELLOW}Making Fish your default shell (optional):${NC}"
echo -e "   ${CYAN}chsh -s \$(which fish)${NC}"
echo ""

echo -e "${YELLOW}Documentation:${NC}"
if [ -f "$SCRIPT_DIR/BMO_CLI_SETUP.md" ]; then
    echo "   See BMO_CLI_SETUP.md for detailed usage guide"
else
    echo "   Check ~/.config/fish/functions/bmo.fish for details"
fi
echo ""

echo -e "${GREEN}Have fun with BMO! 🎮${NC}"
echo ""
