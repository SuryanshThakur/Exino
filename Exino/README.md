# Exino - Windows Game Launcher for macOS

A native macOS application that serves as a user-friendly frontend for Wine and Apple Game Porting Toolkit (GPTK) compatibility layers.

## Prerequisites

- macOS 11.0 or later
- Xcode 13.0 or later
- Homebrew (for installing dependencies)
- Wine or Wine Staging (for running Windows executables)

## Installation

### 1. Install Dependencies

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Wine
brew install --cask --no-quarantine wine-stable

# Install Xcode command line tools if not already installed
xcode-select --install
```

### 2. Build and Run

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Exino
   ```

2. Open the project in Xcode:
   ```bash
   open Package.swift
   ```
   or
   ```bash
   xed .
   ```

3. In Xcode:
   - Select the "Exino" scheme
   - Choose a destination (your Mac)
   - Click the Run button (▶️) or press Cmd+R

## Project Structure

- `Exino/` - Main application code
  - `Models/` - Data models
  - `Views/` - SwiftUI views
  - `ViewModels/` - View models
  - `Utilities/` - Helper classes and extensions

## Features

- Install and manage Windows game clients (Steam, Epic Games, GOG Galaxy)
- Run Windows games through Wine
- Console view for monitoring operations
- Dark mode support

## License

This project is licensed under the MIT License - see the LICENSE file for details.
