function bmo --description "BMO CLI Assistant - Ask BMO to help with shell commands"
    # History file location
    set -l history_dir "$HOME/.local/share/bmo"
    set -l history_file "$history_dir/history.json"

    # Check if a description was provided
    if test (count $argv) -eq 0
        set_color red
        echo "[O ᴗ 0] BMO: Hey friend! Tell me what you want to do!"
        set_color normal
        echo "   Usage: bmo <description of what you want to do>"
        echo "   Example: bmo rename all txt files to md"
        echo ""
        echo "   Special commands:"
        echo "   bmo check    - Analyze and fix the last error"
        echo "   bmo history  - Show conversation history"
        echo "   bmo clear    - Clear conversation history"
        echo "   bmo log      - Export session to markdown file"
        return 1
    end

    # Initialize history file if it doesn't exist
    if not test -f "$history_file"
        mkdir -p "$history_dir"
        echo "[]" > "$history_file"
    end

    # Handle special commands
    set -l first_arg "$argv[1]"

    # BMO CLEAR - Clear conversation history
    if test "$first_arg" = "clear"
        set_color yellow
        echo "[◉ ω ◉] BMO: Are you sure you want to clear my memory?"
        set_color normal
        read -P "Type 'yes' to confirm: " -l confirm

        if test "$confirm" = "yes"
            echo "[]" > "$history_file"
            set_color green
            echo "[◠ ‿ ◠] BMO: All clear! Fresh start, friend!"
            set_color normal
        else
            set_color cyan
            echo "[o ‿ o] BMO: Okay, keeping my memories safe!"
            set_color normal
        end
        return 0
    end

    # BMO HISTORY - Show conversation history summary
    if test "$first_arg" = "history"
        set_color cyan
        echo "[◠ ᴗ ◠] BMO: Here's what we've been up to!"
        set_color normal
        echo ""

        set -l history_count (jq 'length' "$history_file")

        if test "$history_count" -eq 0
            set_color yellow
            echo "   No history yet! Let's start making some memories!"
            set_color normal
            return 0
        end

        # Show last 10 entries
        jq -r '.[-10:] | to_entries | .[] |
            "\(.key + 1). [\(.value.timestamp)] \(.value.user_request)\n   → \(.value.command)\n   Status: \(if .value.exit_code == 0 then "✓ Success" else "✗ Failed (code \(.value.exit_code))" end)\n"' \
            "$history_file"

        echo ""
        set_color cyan
        echo "Total interactions: $history_count"
        set_color normal
        return 0
    end

    # BMO LOG - Export session to markdown
    if test "$first_arg" = "log"
        set -l timestamp (date +"%Y-%m-%d_%H-%M-%S")
        set -l log_file "BMO_log_$timestamp.md"

        set_color yellow
        echo "[◠ ‿ ◠] BMO: Creating a log file for you!"
        set_color normal

        # Create markdown log
        echo "# BMO Session Log" > "$log_file"
        echo "" >> "$log_file"
        echo "Generated: "(date +"%Y-%m-%d %H:%M:%S") >> "$log_file"
        echo "" >> "$log_file"
        echo "---" >> "$log_file"
        echo "" >> "$log_file"

        # Add each history entry
        jq -r '.[] |
            "## [\(.timestamp)]\n\n**Request:** \(.user_request)\n\n**Command:**\n```fish\n\(.command)\n```\n\n**Exit Code:** \(.exit_code)\n\n**Output:**\n```\n\(.output // "No output captured")\n```\n\n---\n"' \
            "$history_file" >> "$log_file"

        set_color green
        echo "[> ω <] BMO: Log saved to: $log_file"
        set_color normal
        return 0
    end

    # BMO CHECK - Analyze last error and suggest fix
    if test "$first_arg" = "check"
        set -l last_entry (jq '.[-1]' "$history_file")

        if test "$last_entry" = "null"
            set_color yellow
            echo "[o ~ o] BMO: I don't have any previous commands to check!"
            set_color normal
            return 0
        end

        set -l last_exit_code (echo $last_entry | jq -r '.exit_code')

        if test "$last_exit_code" -eq 0
            set_color green
            echo "[◠ ‿ ◠] BMO: The last command worked perfectly!"
            set_color normal
            return 0
        end

        # Extract error details
        set -l last_request (echo $last_entry | jq -r '.user_request')
        set -l last_command (echo $last_entry | jq -r '.command')
        set -l last_output (echo $last_entry | jq -r '.output // "No output captured"')

        set_color yellow
        echo "[◉ ꞈ ◉] BMO: Let me analyze what went wrong..."
        set_color normal
        echo ""

        # This will fall through to normal API call with special context
        set argv "check: The last command failed. Original request: '$last_request'. Command: '$last_command'. Exit code: $last_exit_code. Output: $last_output. Please diagnose the issue and suggest a fix."
    end

    # Check if API key is set
    if not set -q ANTHROPIC_API_KEY
        set_color red
        echo "[° ꞈ °] BMO: Oh no! I need an API key to help you!"
        set_color normal
        echo ""
        echo "   Please set your ANTHROPIC_API_KEY environment variable:"
        echo "   Add this to your ~/.config/fish/config.fish:"
        echo ""
        set_color cyan
        echo "   set -gx ANTHROPIC_API_KEY 'your-api-key-here'"
        set_color normal
        echo ""
        return 1
    end

    # Combine all arguments into the user's request
    set -l user_request "$argv"

    # Load conversation history (last 10 interactions for context)
    set -l history_context ""
    set -l history_messages ""

    if test -f "$history_file"
        set -l history_count (jq 'length' "$history_file")
        if test "$history_count" -gt 0
            # Get last 5 interactions for context (to keep token usage manageable)
            set history_context (jq -r '.[-5:] | map("User: \(.user_request)\nCommand: \(.command)\nResult: \(if .exit_code == 0 then "Success" else "Failed (exit \(.exit_code))" end)") | join("\n---\n")' "$history_file")

            # Build messages array for API (alternating user/assistant)
            set history_messages (jq -c '.[-5:] | map([
                {role: "user", content: .user_request},
                {role: "assistant", content: "COMMAND: \(.command)\nEXIT_CODE: \(.exit_code)\nOUTPUT: \(.output // "")"}
            ]) | flatten' "$history_file")
        end
    end

    # Show BMO is thinking
    set_color yellow
    echo "[o ‿ o] BMO: Hmm, let me think about that..."
    set_color normal
    echo ""

    # Construct the API request
    # We ask Claude to respond in format: COMMAND|||EXPLANATION
    set -l system_prompt "You are BMO, a helpful and clear command-line assistant with memory of previous interactions. When given a task description, respond with EXACTLY this format: COMMAND|||EXPLANATION

IMPORTANT RULES:
- COMMAND should be a valid Fish shell command that accomplishes the task
- EXPLANATION should be clear, didactic, and explain what the command does (60-80 chars)
- Be educational: briefly explain the logic and what each part does
- NO motivational endings like 'you got this!', 'let's go!', etc.
- Use Fish shell syntax (not bash)
- Do not include any other text, just: COMMAND|||EXPLANATION

SAFETY WARNINGS:
- For destructive operations (rm, dd, format, etc.), prefix command with: read -s -P 'Password: ' pass &&
- Add '[⚠️ DESTRUCTIVE]' to explanation for commands that delete/overwrite files
- For recursive deletes or system modifications, require password confirmation
- You have access to previous commands and their results for context
- If a previous command failed, learn from it and suggest improvements

Example responses:
for file in *.txt; mv \$file (basename \$file .txt).md; end|||Loops through .txt files, renames each to .md extension
read -s -P 'Password: ' pass && rm -rf ./temp|||[⚠️ DESTRUCTIVE] Requires password, then recursively deletes temp directory"

    set -l user_message "Task: $user_request"

    # Build JSON payload using jq for proper escaping
    # Include conversation history if available
    set -l json_payload
    if test -n "$history_messages"
        # Append current request to history messages
        set json_payload (jq -n \
            --arg model "claude-sonnet-4-20250514" \
            --argjson max_tokens 300 \
            --arg user_content "$user_message" \
            --arg system_content "$system_prompt" \
            --argjson history "$history_messages" \
            '{model: $model, max_tokens: $max_tokens, messages: ($history + [{role: "user", content: $user_content}]), system: $system_content}')
    else
        # No history, use single message
        set json_payload (jq -n \
            --arg model "claude-sonnet-4-20250514" \
            --argjson max_tokens 200 \
            --arg user_content "$user_message" \
            --arg system_content "$system_prompt" \
            '{model: $model, max_tokens: $max_tokens, messages: [{role: "user", content: $user_content}], system: $system_content}')
    end

    # Make API call
    set -l response (curl -s -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$json_payload" \
        https://api.anthropic.com/v1/messages 2>/dev/null)

    # Check if curl succeeded
    if test $status -ne 0
        set_color red
        echo "[@   @] BMO: Oh no! I couldn't connect to my brain!"
        set_color normal
        echo "   Network error - check your internet connection."
        return 1
    end

    # Split response and HTTP code
    # The last line contains the HTTP code, everything else is the response body
    set -l http_code (string split \n $response)[-1]
    set -l response_body (string join \n (string split \n $response)[1..-2])

    # Check HTTP status code
    if test $http_code -ne 200
        set_color red
        echo "[X ꞈ X] BMO: Something went wrong! (HTTP $http_code)"
        set_color normal
        # Try to extract error message if available
        set -l error_msg (echo $response_body | jq -r '.error.message // "Unknown error"' 2>/dev/null)
        if test -n "$error_msg"
            echo "   Error: $error_msg"
        end
        return 1
    end

    # Parse the JSON response to get Claude's text
    set -l claude_response (echo $response_body | jq -r '.content[0].text' 2>/dev/null)

    if test $status -ne 0; or test -z "$claude_response"
        set_color red
        echo "[⊙   ⊙] BMO: I got confused trying to read the response!"
        set_color normal
        echo "   Could not parse API response."
        return 1
    end

    # Split the response by ||| delimiter
    set -l parts (string split "|||" $claude_response)

    if test (count $parts) -ne 2
        set_color red
        echo "[O 3 ◉]  BMO: I'm a little confused... let me show you what I got:"
        set_color normal
        echo ""
        echo "   $claude_response"
        echo ""
        echo "   (Expected format: COMMAND|||EXPLANATION)"
        return 1
    end

    set -l command (string trim $parts[1])
    set -l explanation (string trim $parts[2])

    # Validate that we got a command
    if test -z "$command"
        set_color red
        echo "[× 〰 ×] BMO: Oops! I didn't come up with a command."
        set_color normal
        return 1
    end

    # Display the command and explanation with BMO personality
    set_color yellow
    echo "[◠ ‿ ◠] BMO: $explanation"
    set_color normal
    echo ""
    set_color green
    echo "  $command"
    set_color normal
    echo ""

    # Prompt for confirmation
    set_color cyan
    read -P "Press Enter to run, or Ctrl+C to cancel: " -l confirmation
    set_color normal

    # Execute the command and capture output
    echo ""

    # Create temporary file for output capture
    set -l output_file (mktemp)

    # Execute command and capture both stdout and stderr
    eval $command 2>&1 | tee "$output_file"
    set -l exit_code $status

    # Read captured output
    set -l cmd_output (cat "$output_file")
    rm -f "$output_file"

    # Truncate output if too long (keep first and last 50 lines)
    set -l output_lines (echo "$cmd_output" | wc -l)
    if test $output_lines -gt 100
        set -l first_part (echo "$cmd_output" | head -n 50)
        set -l last_part (echo "$cmd_output" | tail -n 50)
        set cmd_output "$first_part\n... ($output_lines lines total, showing first and last 50) ...\n$last_part"
    end

    # Save to history
    set -l timestamp (date -Iseconds)
    set -l new_entry (jq -n \
        --arg timestamp "$timestamp" \
        --arg user_request "$user_request" \
        --arg command "$command" \
        --argjson exit_code $exit_code \
        --arg output "$cmd_output" \
        '{timestamp: $timestamp, user_request: $user_request, command: $command, exit_code: $exit_code, output: $output}')

    # Append to history file
    jq --argjson entry "$new_entry" '. += [$entry]' "$history_file" > "$history_file.tmp"
    mv "$history_file.tmp" "$history_file"

    # Keep only last 50 entries to prevent file from growing too large
    jq '.[-50:]' "$history_file" > "$history_file.tmp"
    mv "$history_file.tmp" "$history_file"

    # Show friendly completion message
    echo ""
    if test $exit_code -eq 0
        set_color green
        echo "[> ω <] BMO: All done!"
        set_color normal
    else
        set_color yellow
        echo "[~ ꞈ ~] BMO: Hmm, something didn't work quite right (exit code: $exit_code)"
        set_color cyan
        echo "   Tip: Run 'bmo check' to analyze the error!"
        set_color normal
    end

    return $exit_code
end
