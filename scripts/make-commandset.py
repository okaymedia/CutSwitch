#!/usr/bin/env python3
"""Build a Premiere-style command set from the installed FCP English default."""

import plistlib
from pathlib import Path

BASE = Path('/Applications/Final Cut Pro.app/Contents/Resources/en.lproj/Default.commandset')
OUTPUT = Path(__file__).resolve().parent.parent / 'Resources' / 'Premiere Pro.commandset'
ASSIGNMENTS = {
    'SelectToolBlade': ('c', ''),
    'SelectToolArrowOrRangeSelection': ('v', ''),
    'BladeAtPlayhead': ('k', 'command'),
    'TrimStart': ('q', ''),
    'TrimEnd': ('w', ''),
    'ZoomIn': ('=', ''),
    'ZoomOut': ('-', ''),
    'ZoomToFit': ('\\', ''),
}


def main():
    with BASE.open('rb') as source:
        commands = plistlib.load(source)
    missing = ASSIGNMENTS.keys() - commands.keys()
    if missing:
        raise SystemExit('Default command set is missing: ' + ', '.join(sorted(missing)))

    occupied = set(ASSIGNMENTS.values())
    for command, value in list(commands.items()):
        if command in ASSIGNMENTS:
            continue
        entries = value if isinstance(value, list) else [value]
        remaining = [entry for entry in entries if
                     (entry.get('characterString'), entry.get('modifiers', '')) not in occupied]
        if not remaining:
            del commands[command]
        elif len(remaining) != len(entries):
            commands[command] = remaining if isinstance(value, list) else remaining[0]

    for command, (character, modifiers) in ASSIGNMENTS.items():
        commands[command] = {'characterString': character, 'modifiers': modifiers}
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open('wb') as target:
        plistlib.dump(commands, target, fmt=plistlib.FMT_BINARY, sort_keys=True)
    print(OUTPUT)


if __name__ == '__main__':
    main()
