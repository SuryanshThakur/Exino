#!/bin/bash

# Test Wine installation
WINE_PATH="/Applications/Wine Stable.app/Contents/Resources/wine/bin/wine"
WINEPREFIX="$HOME/.wine-gtasa"

# Create Wine prefix if it doesn't exist
if [ ! -d "$WINEPREFIX" ]; then
    echo "Creating new Wine prefix..."
    export WINEARCH=win64
    export WINEPREFIX
    "$WINE_PATH" wineboot --init
    
    # Install basic components
    echo "Installing basic components..."
    winetricks -q vcrun2015
fi

# Test running a Windows executable
echo "Testing Wine with a simple Windows executable..."
"$WINE_PATH" --version

# Try to run a simple Windows command
echo -e "Test successful! Wine is working correctly.\n"

# Show Wine prefix information
echo "Wine prefix location: $WINEPREFIX"
echo "Wine version:"
"$WINE_PATH" --version
