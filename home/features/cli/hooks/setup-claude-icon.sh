#!/usr/bin/env bash

# Setup script to download Claude/Anthropic logo for notifications
ICON_DIR="$HOME/.local/share/icons"
CLAUDE_ICON="$ICON_DIR/claude-code.png"

# Create icons directory if it doesn't exist
mkdir -p "$ICON_DIR"

# Download Anthropic logo (using dark version as it works better for notifications)
if [ ! -f "$CLAUDE_ICON" ]; then
	echo "Downloading Claude icon..."

	# Try to download the SVG and convert to PNG
	if command -v convert &>/dev/null; then
		curl -s "https://mintlify.s3.us-west-1.amazonaws.com/anthropic/logo/dark.svg" |
			convert -background transparent -size 64x64 svg:- "$CLAUDE_ICON" 2>/dev/null

		if [ $? -eq 0 ]; then
			echo "Claude icon installed at $CLAUDE_ICON"
		else
			echo "Failed to convert SVG to PNG, using system icon instead"
		fi
	else
		echo "ImageMagick not available, using system icon instead"
	fi
fi

# Verify icon exists
if [ -f "$CLAUDE_ICON" ]; then
	echo "Claude icon ready: $CLAUDE_ICON"
else
	echo "Using system icon: applications-development"
fi
