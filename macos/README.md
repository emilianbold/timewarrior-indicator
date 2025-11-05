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

- macOS 10.13 (High Sierra) or later
- [Timewarrior](https://timewarrior.net/) installed
- Swift compiler (comes with Xcode Command Line Tools)

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

1. Clone this repository:
   ```bash
   git clone https://github.com/emilianbold/timewarrior-indicator.git
   cd timewarrior-indicator/macos
   ```

2. Build the application:
   ```bash
   ./build.sh
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

Edit the `Config` struct in `TimeWarriorMenuBar.swift` to customize:

```swift
struct Config {
    static var timewPath = "/usr/local/bin/timew"  // Path to timew binary
    static var updateInterval: TimeInterval = 10.0  // Update interval in seconds
    static var tagLimit = 20                        // Max characters for tag display
    static var defaultTag = "Work"                  // Default tag when none exists
}
```

If you installed timewarrior via Homebrew, the path might be `/opt/homebrew/bin/timew` (Apple Silicon) or `/usr/local/bin/timew` (Intel).

To find your timew path:
```bash
which timew
```

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

```bash
cd macos
./build.sh
```

The compiled app bundle will be in `build/TimeWarriorMenuBar.app`.

## Troubleshooting

### "Cannot find timew binary"

Make sure timewarrior is installed and the path in the Config is correct:

```bash
which timew
```

Update `Config.timewPath` in `TimeWarriorMenuBar.swift` with the correct path.

### Menu bar doesn't update

Try left-clicking the menu bar item to force a refresh. Check that timewarrior is working:

```bash
timew
```

### Permission issues

The app needs permission to execute external commands. If you get permission errors, check System Preferences → Security & Privacy → Privacy → Automation.

## Development

The application is written in Swift and uses:
- `NSApplication` for the main app
- `NSStatusBar` for menu bar integration
- `Process` for executing timewarrior commands
- `Timer` for periodic updates
- `JSONDecoder` for parsing timewarrior JSON output

## License

Copyright (C) 2025

Based on the GNOME Shell extension by Tassos Natsakis (2017)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Credits

- Original GNOME Shell extension: [Tassos Natsakis](https://github.com/tassos/timewarrior-indicator)
- macOS port: 2025
- [Timewarrior](https://timewarrior.net/) by GothenburgBitFactory
