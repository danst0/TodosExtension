#!/bin/bash
set -e

# Configuration
APP_NAME="todos_extension"
BINARY_NAME="todos_extension"
ICON_NAME="todos.png" # Based on your workspace structure
# If you prefer the assets folder as requested:
# ICON_SOURCE="./assets/icon.png" 
# But I see you have an icon folder, so I'll use that:
ICON_SOURCE="./icon/todos.png"

INSTALL_BIN_DIR="$HOME/.local/bin"
INSTALL_APP_DIR="$HOME/.local/share/applications"
INSTALL_ICON_DIR="$HOME/.local/share/icons"

echo "Building release..."
cargo build --release

echo "Creating directories..."
mkdir -p "$INSTALL_BIN_DIR"
mkdir -p "$INSTALL_APP_DIR"
mkdir -p "$INSTALL_ICON_DIR"

echo "Installing binary..."
if [ -f "./target/release/$BINARY_NAME" ]; then
    cp "./target/release/$BINARY_NAME" "$INSTALL_BIN_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_BIN_DIR/$BINARY_NAME"
    echo "Binary installed to $INSTALL_BIN_DIR/$BINARY_NAME"
else
    echo "Error: Binary not found in ./target/release/"
    exit 1
fi

echo "Installing icon..."
if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$INSTALL_ICON_DIR/$APP_NAME.png"
    echo "Icon installed to $INSTALL_ICON_DIR/$APP_NAME.png"
else
    echo "Warning: Icon not found at $ICON_SOURCE. Skipping icon installation."
fi

echo "Generating and installing .desktop file..."
TEMPLATE_FILE="./todos_extension.desktop"
FINAL_DESKTOP_FILE="$INSTALL_APP_DIR/$APP_NAME.desktop"

if [ -f "$TEMPLATE_FILE" ]; then
    # Read template and replace placeholders with absolute paths
    sed -e "s|BINARY_PATH|$INSTALL_BIN_DIR/$BINARY_NAME|g" \
        -e "s|ICON_PATH|$INSTALL_ICON_DIR/$APP_NAME.png|g" \
        "$TEMPLATE_FILE" > "$FINAL_DESKTOP_FILE"
    
    echo "Desktop file installed to $FINAL_DESKTOP_FILE"
else
    echo "Error: Template file $TEMPLATE_FILE not found."
    exit 1
fi

echo "Updating desktop database..."
update-desktop-database "$INSTALL_APP_DIR"

echo "Installation complete!"
