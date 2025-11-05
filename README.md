## Timewarrior Indicator

Simple indicators that display the current activity tracked from [timewarrior](https://timewarrior.net/)

Available for:
- **Linux**: GNOME Shell extension
- **macOS**: Native menu bar application

## Prerequisites

Timewarrior :) You can get it from here: https://timewarrior.net/

## Project overview

This is a very simple gnome-shell extension that parses the output of the __timew__ binary and returns the current activity and the duration of it. The current activity is derived from all the tags that are returned from the __timew__ command. The longest tag is used. The string is cut to be max 20 char long.

The duration is also derived from the output of the __timew__ command and is displayed in a _HH:MM_ format.

## Installation

### Linux (GNOME Shell Extension)

The extension can be installed directly from source,
either for the convenience of using git or to test the latest version.

Clone the latest version with git

    git clone https://github.com/emilianbold/timewarrior-indicator.git \
    ~/.local/share/gnome-shell/extensions/timewarrior-indicator@natsakis.com

A Shell reload is required <code>Alt+F2 r Enter</code> and extension
has to be enabled with *gnome-extensions-app* and/or *gnome-tweak-tool*

### macOS (Menu Bar Application)

See the [macOS README](macos/README.md) for detailed instructions.

Quick start:
```bash
git clone https://github.com/emilianbold/timewarrior-indicator.git
cd timewarrior-indicator/macos
./build.sh
cp -r build/TimeWarriorMenuBar.app /Applications/
open /Applications/TimeWarriorMenuBar.app
```

## Author

  * tassos (Tassos Natsakis)

## License

Copyright (C) 2017 Tassos Natsakis

> This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
> License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
> version.
> This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
> warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
> You should have received a copy of the GNU General Public License along with this program.
> If not, see http://www.gnu.org/licenses/.
