# Changelog

All notable changes to BMO CLI Assistant will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-13

### Added - Memory & Error Recovery Features

#### Core Features
- **Conversation History System**: BMO now remembers past interactions
  - History stored at `~/.local/share/bmo/history.json`
  - Captures: timestamp, user request, command, exit code, and output
  - Rolling window of last 50 entries to prevent unbounded growth
  - Last 5 interactions included in API context for smarter suggestions

- **`bmo check` Command**: Intelligent error analysis and recovery
  - Analyzes the last failed command automatically
  - Sends full error context (command, exit code, stderr) to Claude
  - Suggests fixes and alternative approaches
  - Only activates when previous command failed

- **`bmo history` Command**: View conversation summary
  - Shows last 10 interactions with timestamps
  - Displays command, request, and success/failure status
  - Color-coded output for easy reading
  - Total interaction count

- **`bmo clear` Command**: Memory management
  - Clears conversation history with confirmation prompt
  - Gives BMO a fresh start when needed

- **`bmo log` Command**: Export session to markdown
  - Creates timestamped file: `BMO_log_YYYY-MM-DD_HH-MM-SS.md`
  - Formatted markdown with all commands, outputs, and timestamps
  - Perfect for documentation, debugging, or sharing sessions

#### Technical Improvements
- **Context-Aware AI**: BMO includes conversation history in API requests
  - Enhanced system prompt to leverage past interactions
  - Increased max tokens to 300 (from 200) for richer responses
  - Claude learns from previous mistakes and suggests improvements

- **Output Capture**: Full command output now captured
  - Captures both stdout and stderr via `tee`
  - Stores output in history for error analysis
  - Intelligent truncation (first/last 50 lines) for large outputs
  - Real-time output display maintained

- **Enhanced User Experience**
  - Updated help message shows all special commands
  - Helpful error messages with tip to use `bmo check`
  - BMO emoticons for different scenarios
  - Better feedback on command success/failure

#### Installation & Setup
- **setup-bmo.sh**: Added Step 5 to create history directory
  - Automatically creates `~/.local/share/bmo/`
  - Initializes empty `history.json` file
  - XDG Base Directory compliant

- **uninstall-bmo.sh**: Added Step 4 for history removal
  - Prompts user before removing history
  - Creates timestamped backup before deletion
  - Updated removal summary with history status

#### Documentation
- **CLAUDE.md**: Comprehensive project documentation for AI assistants
  - Complete architecture overview
  - Development commands and workflows
  - File locations and structure
  - Technical implementation details

### Changed
- **bmo.fish**: Major refactor (+240 lines)
  - Added special command routing system
  - Implemented history loading and saving functions
  - Modified API payload to include conversation context
  - Enhanced command execution with output capture

### Fixed
- Fish variable scoping issue in JSON payload construction
  - `json_payload` now declared before if/else blocks
  - Prevents "zero-length empty document" API errors

## [0.0.1] - 2025-11-13

### Added
- Initial release of BMO CLI Assistant
- Basic command generation using Claude Sonnet 4
- Fish shell integration
- BMO Fastfetch theme with randomized expressions
- Setup and uninstall scripts

---

[0.1.0]: https://github.com/yourusername/bmo-cli/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/yourusername/bmo-cli/releases/tag/v0.0.1
