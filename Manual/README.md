# Chaos Fight Manual - TeXinfo Template System

This directory contains the TeXinfo source files for the Chaos Fight game manual, with templating set up to match the website's visual style.

## Files

- `ChaosFight.texi` - Main manual file
- `*.texi` - Individual character description files
- `CharacterTemplate.texi` - Template for creating new character descriptions
- `texinfo.css` - Stylesheet matching the website's color scheme and layout

## Visual Template

The manual uses a CSS stylesheet (`texinfo.css`) that matches the website's visual design:

- **Color Palette**: Pastel olive (#b8c5a0), olive drab pastel (#9fa889), tan pastel (#d4c4a8)
- **Layout**: Rounded boxes with multi-directional shadows
- **Typography**: System fonts matching website
- **Character Sections**: Styled boxes matching website character-bio and character-links sections

## Building the Manual

The manual is built using the `make doc` target in the main Makefile:

```bash
make doc
```

This generates:
- `Dist/ChaosFight26.pdf` - PDF version
- `Dist/ChaosFight26.html` - HTML version with CSS styling

## Character Template

When adding new character descriptions, use `CharacterTemplate.texi` as a guide. The template ensures:

1. Consistent formatting across all characters
2. All required fields are included (Weight, Attack, Special, Original Game, Author, Purchase, Download, Forum)
3. Proper TeXinfo syntax for display blocks
4. Visual consistency with website character pages

## CSS Styling

The `texinfo.css` file is automatically included when generating HTML output via the Makefile's `--css-include` option. The stylesheet:

- Matches website color scheme exactly
- Provides rounded box styling for sections
- Styles character description blocks to match website
- Includes responsive design for mobile devices
- Maintains accessibility features

## Website Integration

The manual HTML output is designed to visually match the website pages at:
- `/games/ChaosFight/26/manual/` - Manual HTML
- `/games/ChaosFight/26/characters/` - Character pages (reference for styling)

Both use the same color palette and visual design language for consistency.

