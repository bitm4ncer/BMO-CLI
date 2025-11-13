function bmo --description "BMO CLI Assistant - Ask BMO to help with shell commands"
    # Check if a description was provided
    if test (count $argv) -eq 0
        set_color red
        echo "🤖 BMO: Hey friend! Tell me what you want to do!"
        set_color normal
        echo "   Usage: bmo <description of what you want to do>"
        echo "   Example: bmo rename all txt files to md"
        return 1
    end

    # Check if API key is set
    if not set -q ANTHROPIC_API_KEY
        set_color red
        echo "🤖 BMO: Oh no! I need an API key to help you!"
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

    # Show BMO is thinking
    set_color yellow
    echo "🤖 BMO: Hmm, let me think about that..."
    set_color normal
    echo ""

    # Construct the API request
    # We ask Claude to respond in format: COMMAND|||EXPLANATION
    set -l system_prompt "You are BMO, a helpful and encouraging command-line assistant. When given a task description, respond with EXACTLY this format: COMMAND|||EXPLANATION

- COMMAND should be a valid Fish shell command that accomplishes the task
- EXPLANATION should be under 60 characters, friendly and encouraging
- Use Fish shell syntax (not bash)
- Do not include any other text, just: COMMAND|||EXPLANATION

Example response: for file in *.txt; mv \$file (basename \$file .txt).md; end|||Renames all .txt files to .md - let's do this!"

    set -l user_message "Task: $user_request"

    # Build JSON payload using jq for proper escaping
    set -l json_payload (jq -n \
        --arg model "claude-sonnet-4-20250514" \
        --argjson max_tokens 200 \
        --arg user_content "$user_message" \
        --arg system_content "$system_prompt" \
        '{model: $model, max_tokens: $max_tokens, messages: [{role: "user", content: $user_content}], system: $system_content}')

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
        echo "🤖 BMO: Oh no! I couldn't connect to my brain!"
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
        echo "🤖 BMO: Something went wrong! (HTTP $http_code)"
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
        echo "🤖 BMO: I got confused trying to read the response!"
        set_color normal
        echo "   Could not parse API response."
        return 1
    end

    # Split the response by ||| delimiter
    set -l parts (string split "|||" $claude_response)

    if test (count $parts) -ne 2
        set_color red
        echo "🤖 BMO: I'm a little confused... let me show you what I got:"
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
        echo "🤖 BMO: Oops! I didn't come up with a command."
        set_color normal
        return 1
    end

    # Display the command and explanation with BMO personality
    set_color yellow
    echo "🤖 BMO: $explanation"
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

    # Execute the command
    echo ""
    eval $command
    set -l exit_code $status

    # Show friendly completion message
    echo ""
    if test $exit_code -eq 0
        set_color green
        echo "🤖 BMO: All done! That was fun!"
        set_color normal
    else
        set_color yellow
        echo "🤖 BMO: Hmm, something didn't work quite right (exit code: $exit_code)"
        set_color normal
    end

    return $exit_code
end
