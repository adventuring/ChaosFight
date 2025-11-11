#!/usr/bin/env python3
"""
Augment the optimized batariBASIC assembly stream with global aliases.

The optimizer emits all routine/data labels using DASM's local-label
notation (e.g. ".SetPlayerLocked").  The downstream toolchain still
references the traditional global names without the leading period.
To keep both camps happy we mirror every local label with a matching
global alias (e.g. "SetPlayerLocked = .SetPlayerLocked").

Usage:  add-global-labels.py < input.s > output.s
"""

import re
import sys

LABEL_RE = re.compile(r'^(\.[A-Za-z_][A-Za-z0-9_]*)\s*(?:;.*)?$')


def main() -> None:
    seen: set[str] = set()

    for raw_line in sys.stdin:
        sys.stdout.write(raw_line)

        match = LABEL_RE.match(raw_line.strip())
        if not match:
            continue

        local_name = match.group(1)
        global_name = local_name[1:]

        if global_name in seen:
            continue

        sys.stdout.write(f"{global_name} = {local_name}\n")
        seen.add(global_name)


if __name__ == "__main__":
    main()

