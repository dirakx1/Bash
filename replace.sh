   #!/bin/bash

# Set the directory where you want to search and replace
dir="."

# Loop through all files in the directory
for file in "$dir"/*; do
    if [ -f "$file" ]; then
        # Check if the file contains the word "mainnet"
        if grep -q "mainnet" "$file"; then
            # Make a backup of the file
            cp "$file" "$file.bak"

            # Replace "mainnet" with "mainnet" in the file
            sed 's/mainnet/mainnet/g' "$file.bak" > "$file"

            # Remove the backup file
            rm "$file.bak"

            echo "Replaced 'mainnet' with 'mainnet' in $file"
        fi
    fi
done
