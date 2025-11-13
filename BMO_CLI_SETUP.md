# BMO Command-Line Assistant Setup Guide

Welcome, friend! BMO is here to help you with shell commands using the power of Claude AI!

## What is BMO?

BMO is a Fish shell function that acts as your friendly command-line assistant. Just describe what you want to do, and BMO will suggest a command, explain it, and let you execute it with a single keypress!

## Installation

The BMO function has been installed to:
```
~/.config/fish/functions/bmo.fish
```

Fish shell will automatically load this function when you start a new shell session.

## Setup Your API Key

BMO needs an Anthropic API key to talk to Claude. Here's how to set it up:

### Step 1: Get Your API Key

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (it starts with `sk-ant-`)

### Step 2: Add API Key to Fish Config

Edit your Fish configuration file:
```bash
nano ~/.config/fish/config.fish
```

Add this line (replace with your actual API key):
```fish
set -gx ANTHROPIC_API_KEY 'sk-ant-api03-your-actual-key-here'
```

### Step 3: Reload Your Shell

Either restart your terminal or run:
```fish
source ~/.config/fish/config.fish
```

## Usage

### Basic Syntax
```bash
bmo <description of what you want to do>
```

### Example Commands

#### File Operations
```bash
bmo rename all txt files to md
```

```bash
bmo find all files larger than 100MB
```

```bash
bmo create backup of all python files
```

#### Git Operations
```bash
bmo show me the last 5 git commits
```

```bash
bmo stage all modified files
```

#### System Information
```bash
bmo show disk usage for current directory
```

```bash
bmo list all running processes using port 8080
```

#### Text Processing
```bash
bmo count lines in all typescript files
```

```bash
bmo find all TODO comments in my code
```

### How It Works

1. You type: `bmo <your request>`
2. BMO thinks about it and asks Claude for help
3. BMO shows you the command with a friendly explanation
4. You press Enter to run it (or Ctrl+C to cancel)
5. The command executes in your current shell
6. BMO celebrates with you!

### Example Session

```
$ bmo list all json files sorted by size

🤖 BMO: Hmm, let me think about that...

🤖 BMO: Shows all JSON files from biggest to smallest - you got this!

  ls -lhS *.json

Press Enter to run, or Ctrl+C to cancel: ▊
```

## Error Handling

BMO is smart about errors:

### No API Key Set
```
🤖 BMO: Oh no! I need an API key to help you!
```
→ Solution: Follow the setup steps above

### Network Issues
```
🤖 BMO: Oh no! I couldn't connect to my brain!
```
→ Solution: Check your internet connection

### No Description Provided
```
🤖 BMO: Hey friend! Tell me what you want to do!
```
→ Solution: Include a description after `bmo`

## Safety Features

- **Confirmation Required**: BMO always asks you to press Enter before running any command
- **Command Preview**: You see exactly what will run before it executes
- **Exit Codes**: BMO reports whether the command succeeded or failed
- **Cancellation**: Press Ctrl+C at any time to cancel

## Tips for Best Results

1. **Be Specific**: "rename all txt files to md" is better than "rename files"
2. **Use Natural Language**: Describe what you want in plain English
3. **Check Before Running**: Always review the command BMO suggests
4. **Fish Shell Syntax**: BMO uses Fish shell syntax (not Bash)

## Technical Details

- **Model**: Claude Sonnet 4 (`claude-sonnet-4-20250514`)
- **API Endpoint**: `https://api.anthropic.com/v1/messages`
- **Max Tokens**: 200 (optimized for short command responses)
- **Response Format**: `COMMAND|||EXPLANATION`

## Troubleshooting

### Function Not Found
If you get `Unknown command: bmo`, try:
```fish
source ~/.config/fish/functions/bmo.fish
```

Or restart your terminal.

### API Key Not Working
Make sure your key:
- Starts with `sk-ant-`
- Is properly quoted in the config file
- Has no extra spaces or newlines
- Is set with `set -gx` (global export)

### Commands Not Executing Properly
If commands fail:
- Check that you're using Fish shell (not Bash/Zsh)
- Verify the command works when run manually
- Make sure you have permissions for the operation

## Examples to Try

Here are some fun examples to test BMO:

```bash
# File management
bmo copy all png images to a backup folder
bmo find duplicate files in current directory
bmo compress all log files older than 7 days

# Development
bmo count total lines of code in this project
bmo find all functions named test in python files
bmo show me files modified in the last hour

# System tasks
bmo show memory usage by process
bmo find largest directories
bmo monitor CPU usage every 2 seconds

# Text processing
bmo extract all email addresses from log files
bmo convert all tabs to spaces in yaml files
bmo sort package.json dependencies alphabetically
```

## Uninstallation

If you want to remove BMO:

1. Delete the function file:
   ```bash
   rm ~/.config/fish/functions/bmo.fish
   ```

2. Remove the API key from `~/.config/fish/config.fish`

3. Restart your terminal

## Privacy & Security

- Your API key is stored locally in your Fish config
- Commands are sent to Anthropic's API for processing
- BMO only executes commands after you press Enter
- Review Anthropic's privacy policy at [anthropic.com/privacy](https://www.anthropic.com/privacy)

## Contributing

Found a bug? Have an idea? BMO loves making new friends!

The function is located at: `~/.config/fish/functions/bmo.fish`

Feel free to modify it to suit your needs!

## License

BMO is here to help everyone! This code is provided as-is for personal use.

---

**Have fun with BMO! 🤖**

Remember: BMO is your friend and wants to help, but always review commands before running them!
