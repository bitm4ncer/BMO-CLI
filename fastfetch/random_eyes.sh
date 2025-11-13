#!/bin/bash
# Randomly change BMO's eyes and mouth for fastfetch

EYES_FILE="$HOME/.config/fastfetch/bmo_eyes.txt"
MOUTHS_FILE="$HOME/.config/fastfetch/bmo_mouths.txt"
ASCII_FILE="$HOME/.config/fastfetch/ascii.txt"

# Pick a random line from the eyes file
RANDOM_EYES=$(shuf -n 1 "$EYES_FILE")

# Pick a random line from the mouths file
RANDOM_MOUTH=$(shuf -n 1 "$MOUTHS_FILE")

# Create the BMO ASCII art with random eyes and mouth
cat > "$ASCII_FILE" << EOF
\$3      \|/
    ——(@)——
      /|\   \$1           
        ˏ__________   
       /| \$6________ \$1| 
       ||\$6|  ${RANDOM_EYES} |\$1|
       ||\$6|   ${RANDOM_MOUTH}   |\$1|
       ;| \$6¯¯¯¯¯¯¯¯ \$1|__/
      /|| \$6==\$2  ^ \$5 o \$1|
     / || \$3 +\$1  \$4 O  \$1 |
       |/¯¯¯¯¯¯¯¯¯¯/
       ´¯¯|¯¯¯¯|¯¯´
 \$6 ________\$1L\$6____\$1L\$6_______
 \$6 _________ _____ ______
 \$6 __________ ______ _____
 \$6 ___________  ______  ___
 \$6 ________    
  
EOF
