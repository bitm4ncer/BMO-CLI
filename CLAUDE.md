# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BMO CLI Assistant is a Fish shell function that acts as a natural language interface for shell commands. Users describe what they want to do in plain language, and BMO uses Claude AI (Sonnet 4) to generate the appropriate Fish shell command, explain it, and execute it with user confirmation.

## Core Architecture

### Main Components

1. **bmo.fish** - The primary Fish function (installed to ~/.config/fish/functions/bmo.fish)
   - Validates ANTHROPIC_API_KEY environment variable
   - Constructs API request using jq for JSON payload building
   - Makes synchronous HTTP call to Anthropic Messages API
   - Parses response expecting format: `COMMAND|||EXPLANATION`
   - Displays command with BMO-themed output and ASCII emoticons
   - Prompts for confirmation before executing via `eval`
   - Reports exit codes with friendly messages

2. **setup-bmo.sh** - Installation wizard
   - Detects/installs Fish shell and dependencies (curl, jq, fastfetch)
   - Auto-discovers API key from Claude Code credentials (~/.claude/.credentials.json) or environment
   - Installs bmo.fish to Fish functions directory
   - Configures ANTHROPIC_API_KEY in ~/.config/fish/config.fish
   - Installs custom Fastfetch theme with randomization scripts
   - Adds Fastfetch to shell startup (Fish, Bash, Zsh)

3. **uninstall-bmo.sh** - Clean removal script
   - Removes bmo.fish function
   - Removes API key from config (with backup)
   - Removes Fastfetch integration from shell configs
   - Optionally removes Fastfetch theme directory
   - Creates timestamped backups of all modified files

4. **Fastfetch Theme** (fastfetch/ directory)
   - config.jsonc - Main fastfetch configuration
   - ascii.txt - BMO ASCII art template
   - bmo_eyes.txt, bmo_mouths.txt - Expression variants
   - bmo_sayings.txt - Random BMO quotes
   - random_eyes.sh - Randomizes BMO's facial expression in ascii.txt
   - random_saying.sh - Displays random saying
   - color_wave.sh - Generates rainbow separator lines

### API Integration

- **Model**: claude-sonnet-4-20250514
- **Endpoint**: https://api.anthropic.com/v1/messages
- **Max Tokens**: 200 (optimized for concise command responses)
- **Response Format**: Claude is instructed to respond with exactly: `COMMAND|||EXPLANATION`
  - COMMAND: Valid Fish shell syntax
  - EXPLANATION: Under 60 characters, friendly and encouraging
- **Authentication**: Uses x-api-key header with ANTHROPIC_API_KEY

### Response Parsing Flow

1. curl returns response body + HTTP status code (via -w flag)
2. Split response: last line = HTTP code, rest = JSON body
3. Validate HTTP 200, extract error messages on failure
4. Use jq to parse `.content[0].text` from JSON
5. Split by "|||" delimiter into command and explanation
6. Validate both parts exist before displaying

## Development Commands

### Testing BMO Function

```bash
# Start Fish shell
fish

# Test basic functionality
bmo list files in current directory
bmo show disk usage
bmo find all python files

# Test error handling
bmo                    # Should show usage message
unset ANTHROPIC_API_KEY && bmo test  # Should show API key error
```

### Installation/Setup

```bash
# Run setup wizard
chmod +x setup-bmo.sh
./setup-bmo.sh

# Manual installation of just the function
mkdir -p ~/.config/fish/functions
cp bmo.fish ~/.config/fish/functions/
```

### Uninstallation

```bash
# Run uninstaller with backups
./uninstall-bmo.sh

# Manual removal
rm ~/.config/fish/functions/bmo.fish
# Then manually remove ANTHROPIC_API_KEY from ~/.config/fish/config.fish
```

### Testing Setup Scripts

```bash
# Test setup in clean environment
docker run -it --rm ubuntu:latest bash
# Install git, clone repo, run setup-bmo.sh

# Test uninstall
./uninstall-bmo.sh
# Verify backups created in ~/.config/fish/
```

## Important Technical Details

### Fish Shell Syntax Requirements

BMO generates **Fish shell commands**, not Bash. Key differences:
- Variable setting: `set var value` (not `var=value`)
- Command substitution: `(command)` (not `$(command)` or backticks)
- Loops: `for x in *; command $x; end` (not `do...done`)
- Conditionals: `if test...; end` (not `fi`)
- String operations: `string split`, `string trim` (not parameter expansion)

### Error Handling in bmo.fish

The function handles multiple error scenarios:
- Line 13: No arguments provided
- Line 22: Missing ANTHROPIC_API_KEY
- Line 67: Network/curl failure
- Line 81: Non-200 HTTP response (extracts error message from JSON)
- Line 96: Invalid JSON response
- Line 107: Response not in COMMAND|||EXPLANATION format
- Line 122: Empty command returned
- Line 147: Command execution failure (reports exit code)

### Fastfetch Randomization System

On each shell startup (or manual `random_eyes.sh` execution):
1. Script picks random line from bmo_eyes.txt and bmo_mouths.txt
2. Uses sed to replace placeholder patterns in ascii.txt
3. Fastfetch reads modified ascii.txt for logo display
4. random_saying.sh and color_wave.sh called from config.jsonc

### Security Considerations

- API key stored in plaintext in ~/.config/fish/config.fish (mode 644 by default)
- User's natural language requests are sent to Anthropic API
- Commands always previewed before execution (confirmation required)
- No blind execution - user must press Enter
- Exit code reporting helps identify failed operations

## File Locations

### Repository Files
- [bmo.fish](bmo.fish) - Main Fish function
- [setup-bmo.sh](setup-bmo.sh) - Installation wizard
- [uninstall-bmo.sh](uninstall-bmo.sh) - Removal script
- [fastfetch/config.jsonc](fastfetch/config.jsonc) - Fastfetch configuration
- [fastfetch/*.txt](fastfetch/) - ASCII art and expression data
- [fastfetch/*.sh](fastfetch/) - Randomization scripts
- [README.md](README.md) - User-facing documentation
- [BMO_CLI_SETUP.md](BMO_CLI_SETUP.md) - Detailed setup guide

### Installed Locations (after setup)
- ~/.config/fish/functions/bmo.fish - Function loaded by Fish
- ~/.config/fish/config.fish - Contains ANTHROPIC_API_KEY
- ~/.config/fastfetch/ - Theme files and scripts
- ~/.bashrc, ~/.zshrc - Modified to run fastfetch on startup (if those shells present)

## Modifying BMO's Behavior

### Change Claude Model
Edit [bmo.fish:52](bmo.fish#L52) - modify `--arg model` value

### Adjust Response Length
Edit [bmo.fish:53](bmo.fish#L53) - modify `--argjson max_tokens` value

### Customize System Prompt
Edit [bmo.fish:39-46](bmo.fish#L39-L46) - modify the `system_prompt` variable

### Add New Facial Expressions
Add lines to [fastfetch/bmo_eyes.txt](fastfetch/bmo_eyes.txt) or [fastfetch/bmo_mouths.txt](fastfetch/bmo_mouths.txt)

### Add New Sayings
Add lines to [fastfetch/bmo_sayings.txt](fastfetch/bmo_sayings.txt)

## Dependencies

**Required:**
- Fish Shell 3.0+ (bmo.fish uses Fish syntax)
- curl (for API calls)
- jq (for JSON parsing and payload construction)
- Anthropic API key (from console.anthropic.com)

**Optional:**
- fastfetch (for BMO welcome theme)
- bash (setup/uninstall scripts use bash)

## Git Status Note

The repository currently shows:
- Modified: [bmo.fish](bmo.fish)
- No .gitignore present - consider adding one to exclude local test files

When making changes, test thoroughly in Fish shell before committing, as syntax errors in bmo.fish will break the function for all users.
