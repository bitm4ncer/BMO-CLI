# BMO CLI Assistant

```
================================


   ___  __  __  ___  
  | _ )|  \/  |/ _ \ 
  | _ \| |\/| | (_) |
  |___/|_|  |_|\___/ CLI

  LLM driven Shell command assistant

      _______________
     |  ___________  |
     | |           | |
     | |  0     0  | |  /     
     | |     ‿     | | /
     | |___________|_|/       
    /|               |
   / |  ===          |
  /  |         ^   o |
     |    +      0   |
     |____________ __|
          |     |
    "I help you with shell commands, friend!"

================================
```

## HELLO FRIEND!

BMO here! I'm your CLI assistant. Just tell me what you want to do in plain
words, and I'll give you the perfect shell command! BMO uses Claude AI to
understand what you need.

```bash
$ bmo rename all txt files to md

[o ‿ o] BMO: Hmm, let me think about that...

[◠ ‿ ◠] BMO: Renames all .txt files to .md - let's do this!

  for file in *.txt; mv $file (basename $file .txt).md; end

Press Enter to run, or Ctrl+C to cancel:
```

--------------------------------------------------------------------------------
WHAT BMO CAN DO
--------------------------------------------------------------------------------

  🎯 Natural language commands - Just describe what you want!
  🔍 Smart suggestions - Claude Sonnet 4 powered responses
  🧠 **NEW! Conversation memory** - BMO remembers past commands for context
  🔧 **NEW! Error recovery** - Use `bmo check` to analyze and fix errors
  📜 **NEW! History tracking** - View past interactions with `bmo history`
  💾 **NEW! Session export** - Save logs with `bmo log`
  ✅ Safety first - Always shows command before running
  🎨 Pretty output - Syntax highlighting and colors
  🤖 BMO personality - Friendly and encouraging messages
  ⚡ Fast - Optimized for quick responses
  🌈 Custom Fastfetch theme - BMO greets you with random expressions!
  🗑️ Easy uninstall - Clean removal with backups

--------------------------------------------------------------------------------
QUICK INSTALL
--------------------------------------------------------------------------------

1. Run the setup wizard (BMO will help you!)

   $ chmod +x setup-bmo.sh
   $ ./setup-bmo.sh

2. Start Fish shell

   $ fish

3. Try BMO!

   $ bmo hello world

--------------------------------------------------------------------------------
WHAT THE SETUP WIZARD DOES
--------------------------------------------------------------------------------

BMO's wizard will automatically:

  ✅ Check if Fish shell is installed (offers to install!)
  ✅ Check for required tools (curl, jq, fastfetch)
  ✅ Detect existing Claude Code credentials (reuses them!)
  ✅ Install BMO function to ~/.config/fish/functions/bmo.fish
  ✅ Configure API key in ~/.config/fish/config.fish
  ✅ Install custom BMO Fastfetch theme with random expressions
  ✅ Configure fastfetch for Fish, Bash, and Zsh shells

--------------------------------------------------------------------------------
REQUIREMENTS
--------------------------------------------------------------------------------

  - Fish Shell 3.0+ (wizard can install this)
  - curl (for API calls)
  - jq (for JSON parsing)
  - fastfetch (for BMO's welcome theme)
  - Anthropic API Key (get one at console.anthropic.com)

--------------------------------------------------------------------------------
EXAMPLES TO TRY
--------------------------------------------------------------------------------

File Operations
  $ bmo rename all txt files to md
  $ bmo find files larger than 100MB
  $ bmo create backup of all python files

Git Operations
  $ bmo show me the last 5 commits
  $ bmo stage all modified files
  $ bmo create a new branch called feature-x

System Tasks
  $ bmo show disk usage
  $ bmo list processes using port 8080
  $ bmo find my IP address

Text Processing
  $ bmo count lines in all typescript files
  $ bmo find all TODO comments
  $ bmo extract email addresses from logs

--------------------------------------------------------------------------------
SPECIAL COMMANDS (NEW IN v0.1.0!)
--------------------------------------------------------------------------------

BMO now has memory and error recovery features!

  $ bmo check
    Analyzes the last failed command and suggests fixes
    BMO will send the error details to Claude for diagnosis

  $ bmo history
    Shows your recent interactions with BMO
    Displays last 10 commands with success/failure status

  $ bmo clear
    Clears BMO's conversation memory
    Useful for starting fresh (requires confirmation)

  $ bmo log
    Exports your session to a markdown file
    Creates: BMO_log_YYYY-MM-DD_HH-MM-SS.md in current directory

Example workflow:
  $ bmo find all json files recursively
  [Command fails with error]
  $ bmo check
  [BMO analyzes the error and suggests a fix]

--------------------------------------------------------------------------------
SAFETY FEATURES
--------------------------------------------------------------------------------

BMO always keeps you safe!

  ✓ Command preview - Always see what will run before execution
  ✓ Confirmation required - Must press Enter to execute
  ✓ Exit codes - Reports success/failure of commands
  ✓ Cancel anytime - Press Ctrl+C to abort
  ✓ No blind execution - You're always in control

--------------------------------------------------------------------------------
BMO FASTFETCH THEME
--------------------------------------------------------------------------------

BMO includes a custom fastfetch theme that displays:

  • BMO ASCII art with randomized facial expressions
  • Random BMO sayings and quotes
  • Colorful rainbow separators
  • System information (OS, CPU, GPU, memory, etc.)
  • Color palette showcase

The theme is automatically configured for Fish, Bash, and Zsh shells.
Every time you open a terminal, BMO greets you with a different expression!

--------------------------------------------------------------------------------
UNINSTALLING BMO
--------------------------------------------------------------------------------

If you need to say goodbye to BMO (BMO will miss you!):

   $ ./uninstall-bmo.sh

The uninstaller will:
  • Remove the BMO Fish function
  • Remove API key configuration (with backup)
  • Remove Fastfetch theme files (with backup)
  • Remove Fastfetch shell integration
  • Create backup files of all modified configurations

You can reinstall BMO anytime by running setup-bmo.sh again!

--------------------------------------------------------------------------------
TROUBLESHOOTING
--------------------------------------------------------------------------------

Unknown command: bmo
  $ source ~/.config/fish/config.fish
  (or restart your terminal)

Oh no! I need an API key!
  $ echo $ANTHROPIC_API_KEY
  (if empty, run ./setup-bmo.sh again)

Couldn't connect to my brain!
  • Check your internet connection
  • Verify API key is valid at console.anthropic.com
  • Check if curl works: curl -I https://api.anthropic.com

Commands not working?
  • Make sure you're in Fish shell (run: fish)
  • BMO uses Fish syntax, not Bash
  • Try the command manually first to verify permissions

--------------------------------------------------------------------------------
FILES AND DIRECTORIES
--------------------------------------------------------------------------------

  setup-bmo.sh              - Installation wizard
  uninstall-bmo.sh          - Uninstaller (BMO hopes you don't need this!)
  bmo.fish                  - BMO's main function
  fastfetch/                - BMO's custom theme files
  ~/.local/share/bmo/       - Conversation history storage (NEW!)
  CHANGELOG.md              - Version history and release notes (NEW!)
  CLAUDE.md                 - AI assistant documentation (NEW!)
  BMO_CLI_SETUP.md          - Detailed setup guide

--------------------------------------------------------------------------------
DOCUMENTATION
--------------------------------------------------------------------------------

  📖 BMO_CLI_SETUP.md - Detailed setup guide with troubleshooting
  📝 CHANGELOG.md - Version history and feature changelog
  🤖 CLAUDE.md - AI assistant documentation for developers
  🐛 Report issues on GitHub: https://github.com/bitm4ncer/BMO-CLI
  💬 Fish shell docs: https://fishshell.com

--------------------------------------------------------------------------------
PRIVACY & SECURITY
--------------------------------------------------------------------------------

  • API key stored locally in ~/.config/fish/config.fish
  • Conversation history stored locally in ~/.local/share/bmo/history.json
  • Your commands and history are sent to Anthropic's API for context
  • BMO only executes after you press Enter
  • Use `bmo clear` to erase conversation history anytime
  • Review Anthropic's Privacy Policy at anthropic.com/privacy
  • Never run commands you don't understand!

--------------------------------------------------------------------------------

BMO says: "Being a robot is fun! But being a friend is better."

Have fun with BMO! 🎮

For more detailed information, check out BMO_CLI_SETUP.md

                                                        - BMO

================================================================================
