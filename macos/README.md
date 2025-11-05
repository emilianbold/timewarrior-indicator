# TimeWarrior MenuBar for macOS

A native macOS menu bar application that displays your current [timewarrior](https://timewarrior.net/) activity.

## Features

- 🕐 Displays current activity and duration in the menu bar
- ⏱️ Shows daily total time
- ▶️ Quick restart tracking from menu
- ⏹️ Quick stop tracking from menu
- 🔄 Automatic refresh every 10 seconds
- 🎯 Lightweight native Swift application

## Prerequisites

- macOS 12 (Monterey) or later
- [Timewarrior](https://timewarrior.net/) installed
- Swift compiler (comes with Xcode Command Line Tools) - only needed for building from source

### Installing Timewarrior

```bash
# Using Homebrew
brew install timewarrior

# Or download from https://timewarrior.net/
```

### Installing Xcode Command Line Tools

```bash
xcode-select --install
```

## Installation

### Option 1: Download Pre-built Binary (Recommended)

Download the latest universal binary (works on both Intel and Apple Silicon Macs) from the [Releases page](https://github.com/emilianbold/timewarrior-indicator/releases).

1. Download `TimeWarriorMenuBar.zip` or `TimeWarriorMenuBar.dmg`
2. Extract the ZIP or open the DMG
3. Drag `TimeWarriorMenuBar.app` to your Applications folder
4. Launch the application

**Note:** The first time you run the app, you may need to right-click and select "Open" to bypass Gatekeeper.

### Option 2: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/emilianbold/timewarrior-indicator.git
   cd timewarrior-indicator/macos
   ```

2. Build the application:
   ```bash
   # Build for your current architecture
   ./build.sh

   # Or build universal binary (Intel + Apple Silicon)
   ./build.sh --universal

   # Or build for specific architecture
   ./build.sh --arch arm64
   ./build.sh --arch x86_64
   ```

3. Copy to Applications folder:
   ```bash
   cp -r build/TimeWarriorMenuBar.app /Applications/
   ```

4. Launch the application:
   ```bash
   open /Applications/TimeWarriorMenuBar.app
   ```

5. (Optional) Add to Login Items:
   - Open System Preferences → Users & Groups
   - Select your user and go to "Login Items"
   - Click "+" and add TimeWarriorMenuBar.app

## Configuration

The app automatically detects the `timew` binary location using `which timew`. If not found, it falls back to common locations:
- `/usr/local/bin/timew` (Homebrew Intel)
- `/opt/homebrew/bin/timew` (Homebrew Apple Silicon)
- `/usr/bin/timew` (System)

To customize other settings, edit the `Config` struct in `TimeWarriorMenuBar.swift`:

```swift
struct Config {
    static var updateInterval: TimeInterval = 10.0  // Update interval in seconds
    static var tagLimit = 20                        // Max characters for tag display
    static var defaultTag = "Work"                  // Default tag when none exists
}
```

**Note**: The `timewPath` is now automatically detected and doesn't need manual configuration!

## Usage

### Menu Bar Display

When timewarrior is tracking, the menu bar shows:
```
[Tag] HH:MM ⌛ Daily Total
```

When not tracking:
```
⏱️ No activity
```

### Menu Options

- **▶️ Restart tracking**: Resume the last activity (Cmd+R)
- **⏹️ Stop tracking**: Stop current tracking (Cmd+S)
- **Quit**: Close the application (Cmd+Q)

### Mouse Interactions

- **Left-click**: Refresh the display immediately
- **Right-click**: Open the menu

## Building from Source

### Local Build

```bash
cd macos

# Build for current architecture
./build.sh

# Build universal binary (recommended for distribution)
./build.sh --universal

# Build for specific architecture
./build.sh --arch arm64  # Apple Silicon
./build.sh --arch x86_64 # Intel
```

The compiled app bundle will be in `build/TimeWarriorMenuBar.app`.

### Package for Distribution

To create ZIP and DMG distribution files:

```bash
cd macos

# First build the app
./build.sh --universal

# Then package it
./package-release.sh v1.0

# Or use a custom version number
./package-release.sh v1.2.3
```

Distribution files will be created in `build/dist/`.

### Automated Builds

The project uses GitHub Actions to automatically build universal binaries (Intel + Apple Silicon) on every push to the main branch and for all tagged releases.

**CI/CD Features:**
- Builds for both x86_64 (Intel) and arm64 (Apple Silicon)
- Creates universal binary using `lipo`
- Optional code signing (if configured)
- Packages as both ZIP and DMG
- Automatically creates GitHub releases for version tags

**To create a new release:**
1. Tag your commit: `git tag -a v1.0.0 -m "Release v1.0.0"`
2. Push the tag: `git push origin v1.0.0`
3. GitHub Actions will automatically build and create a release with ZIP and DMG files

**Download build artifacts:**
- For tagged releases: Visit the [Releases page](https://github.com/emilianbold/timewarrior-indicator/releases)
- For branch builds: Go to [Actions](https://github.com/emilianbold/timewarrior-indicator/actions) and download artifacts from recent workflow runs

## Code Signing

To distribute your app without Gatekeeper warnings, you should code sign it with your Apple Developer certificate.

### Local Signing

```bash
# Build and sign in one command
./build.sh --universal --sign "Developer ID Application: Your Name (TEAM_ID)"
```

### GitHub Actions Signing

Add these secrets to your repository (**Settings → Secrets and variables → Actions**):

- `MACOS_CERTIFICATE`: Base64-encoded .p12 certificate
- `MACOS_CERTIFICATE_PWD`: Certificate password
- `MACOS_SIGNING_IDENTITY`: Your developer identity (e.g., "Developer ID Application: Your Name")

The workflow will automatically sign builds when these secrets are configured.

**For complete code signing and notarization instructions, see [CODE_SIGNING.md](CODE_SIGNING.md)**

## Troubleshooting

### "Cannot find timew binary"

The app automatically detects `timew` using `which`. Make sure timewarrior is installed:

```bash
which timew
```

If `timew` is not in your PATH, create a symlink to a standard location:

```bash
# Example for custom installation
sudo ln -s /path/to/your/timew /usr/local/bin/timew
```

### Menu bar doesn't update

Try left-clicking the menu bar item to force a refresh. Check that timewarrior is working:

```bash
timew
```

### Permission issues

The app needs permission to execute external commands. If you get permission errors, check System Preferences → Security & Privacy → Privacy → Automation.

### "App is damaged and can't be opened"

This happens when downloading from the internet and the app isn't signed/notarized.

**Solution 1**: Right-click the app and select "Open" (first time only)

**Solution 2**: Remove quarantine attribute:
```bash
xattr -cr /Applications/TimeWarriorMenuBar.app
```

**Solution 3**: Build from source or use a signed release

## Development

The application is written in Swift and uses:
- `NSApplication` for the main app
- `NSStatusBar` for menu bar integration
- `Process` for executing timewarrior commands
- `Timer` for periodic updates
- `JSONDecoder` for parsing timewarrior JSON output

## License

Copyright (C) 2025

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Credits

- [Timewarrior](https://timewarrior.net/) by GothenburgBitFactory
