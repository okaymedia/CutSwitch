#!/usr/bin/env python3
"""Build command sets from the installed FCP English default."""

from copy import deepcopy
from dataclasses import dataclass
import plistlib
from pathlib import Path

BASE = Path('/Applications/Final Cut Pro.app/Contents/Resources/en.lproj/Default.commandset')
OUTPUT_DIRECTORY = Path(__file__).resolve().parent.parent / 'Resources'


@dataclass(frozen=True)
class Assignment:
    keys: tuple[tuple[str, str], ...]
    preserve_defaults: bool = False


SETS = {
    'Premiere Pro': {
        'SelectToolBlade': Assignment((('c', ''),)),
        'SelectToolArrowOrRangeSelection': Assignment((('v', ''),)),
        'BladeAtPlayhead': Assignment((('k', 'command'),)),
        'TrimStart': Assignment((('q', ''),)),
        'TrimEnd': Assignment((('w', ''),)),
        'ZoomIn': Assignment((('=', ''),)),
        'ZoomOut': Assignment((('-', ''),)),
        'ZoomToFit': Assignment((('\\', ''),)),
    },
    'DaVinci Resolve': {
        'BladeAtPlayhead': Assignment((('\\', 'command'),), preserve_defaults=True),
        'TrimStart': Assignment((('[', 'shift'),), preserve_defaults=True),
        'TrimEnd': Assignment(((']', 'shift'),), preserve_defaults=True),
    },
}


def make_commandset(defaults, assignments):
    commands = deepcopy(defaults)
    missing = assignments.keys() - commands.keys()
    if missing:
        raise SystemExit('Default command set is missing: ' + ', '.join(sorted(missing)))

    occupied = {key for assignment in assignments.values() for key in assignment.keys}
    for command, value in list(commands.items()):
        entries = value if isinstance(value, list) else [value]
        remaining = [entry for entry in entries if
                     (entry.get('characterString'), entry.get('modifiers', '')) not in occupied]
        if not remaining:
            del commands[command]
        elif len(remaining) != len(entries):
            commands[command] = remaining if isinstance(value, list) else remaining[0]

    for command, assignment in assignments.items():
        existing = commands.get(command, []) if assignment.preserve_defaults else []
        entries = existing if isinstance(existing, list) else [existing]
        entries.extend({'characterString': character, 'modifiers': modifiers}
                       for character, modifiers in assignment.keys)
        commands[command] = entries[0] if len(entries) == 1 else entries
    return commands


def main():
    with BASE.open('rb') as source:
        defaults = plistlib.load(source)
    OUTPUT_DIRECTORY.mkdir(parents=True, exist_ok=True)
    for name, assignments in SETS.items():
        output = OUTPUT_DIRECTORY / f'{name}.commandset'
        with output.open('wb') as target:
            plistlib.dump(make_commandset(defaults, assignments), target,
                          fmt=plistlib.FMT_BINARY, sort_keys=True)
        print(output)


if __name__ == '__main__':
    main()
