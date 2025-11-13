#!/bin/bash
# Static rainbow line for fastfetch

# Number of characters per row
LENGTH=50

# Define rainbow colors using ANSI 256-color codes for smooth hue progression
colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 45 39 33 27 21 57 93 129 165 201)

# Draw the rainbow line with equals signs
for ((i=0; i<LENGTH; i++)); do
    color_index=$((i % ${#colors[@]}))
    # Use 256-color ANSI escape code with equals sign
    echo -ne "\033[38;5;${colors[$color_index]}m="
done

# Reset color (no newline - fastfetch adds it)
echo -ne "\033[0m"
