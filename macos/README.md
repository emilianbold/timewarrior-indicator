# TimeWarrior MenuBar for macOS

A native macOS menu bar application that displays your current [timewarrior](https://timewarrior.net/) activity.

<!-- TODO: Add screenshot here -->

## Requirements

- macOS 12 (Monterey) or later
- [Timewarrior](https://timewarrior.net/) installed

## Installation

### Download

Download the latest release from the [Releases page](https://github.com/emilianbold/timewarrior-indicator/releases).

### Build from Source

```bash
cd macos
./build.sh
cp -r build/TimeWarriorMenuBar.app /Applications/
```

### Code Signing

To sign the app after building (or after downloading from GitHub Actions):

```bash
./sign.sh "Developer ID Application: Your Name (TEAM_ID)"
```

## License

Copyright (C) 2025

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

