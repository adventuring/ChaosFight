# Titlescreen Kernel Setup for ChaosFight

## Overview

The titlescreen kernel is integrated into Bank 9 and configured to display 48×42 pixel bitmaps on admin screens (Publisher, Author, Title). We use the **×2 drawing style** (double-height mode), where each bitmap row is displayed as 2 scanlines, resulting in a 48×84 scanline display (42 rows × 2).

## Configuration

### Minikernel Layout
    - **Source/Titlescreen/titlescreen_layout.s**: Configured to use three `48x2` minikernels (×2 = double-height drawing style)
  - `draw_48x2_1`: Publisher (AtariAge) bitmap
  - `draw_48x2_2`: Author (Interworldly) bitmap
  - `draw_48x2_3`: Title (ChaosFight) bitmap

**Note**: The `48x2` naming indicates ×2 drawing style - each bitmap row is drawn twice (as 2 scanlines), converting 42 rows into 84 scanlines for display.

### Bitmap Image Files

Each screen needs its bitmap data in the corresponding image file:

    1. **Source/Generated/Art.AtariAge.s** - AtariAge bitmap
   - Set `bmp_48x2_1_window = 42` (when Publisher screen is active)
   - Set `bmp_48x2_1_height = 42`
   - Set `bmp_48x2_2_window = 0` (hide other screens)
   - Set `bmp_48x2_3_window = 0`

    2. **Source/Generated/Art.Interworldly.s** - Interworldly bitmap
   - Set `bmp_48x2_2_window = 42` (when Author screen is active)
   - Set `bmp_48x2_2_height = 42`
   - Set `bmp_48x2_1_window = 0` (hide other screens)
   - Set `bmp_48x2_3_window = 0`

    3. **Source/Generated/Art.ChaosFight.s** - ChaosFight bitmap
   - Set `bmp_48x2_3_window = 42` (when Title screen is active)
   - Set `bmp_48x2_3_height = 42`
   - Set `bmp_48x2_1_window = 0` (hide other screens)
   - Set `bmp_48x2_2_window = 0`

### Screen-Specific Configuration

The `window` constant controls how many lines are displayed. Setting `window = 0` hides that minikernel.

**Note**: Since these are assembly constants, they must be set at compile time. For runtime switching, you would need to:
1. Use conditional assembly based on a constant
2. OR use separate bank files for each screen's image data
3. OR accept that all three bitmaps compile in, and only the active one displays

## Bitmap Data Format

Each image file should contain:
- `bmp_48x2_N_window = 42` (displayed height in rows; ×2 = 84 scanlines on screen)
- `bmp_48x2_N_height = 42` (total bitmap height in rows; ×2 = 84 scanlines when displayed)
- `bmp_48x2_N_colors`: 42 color values (one per row, in reverse order - bottom to top)
  - Each color value is used for 2 scanlines (×2 drawing style)
- `bmp_48x2_N_00` through `bmp_48x2_N_05`: Six columns of bitmap data
  - Each column: 42 bytes (one per row)
  - Rows in reverse order (bottom to top, inverted-y)
  - Each row is displayed twice (×2) as 2 scanlines on screen

## Conversion Process

Convert your 48×42 PNG files to titlescreen kernel format:
    1. Publisher: `AtariAge.png` → `Source/Generated/Art.AtariAge.s`
    2. Author: `Interworldly.png` → `Source/Generated/Art.Interworldly.s`
    3. Title: `ChaosFight.png` → `Source/Generated/Art.ChaosFight.s`

## Usage in Code

Admin screens call `gosub titledrawscreen bank9` instead of `drawscreen`:

- **PublisherPreamble**: Uses 48x2_1 minikernel
- **AuthorPreamble**: Uses 48x2_2 minikernel  
- **TitleScreenMain**: Uses 48x2_3 minikernel

## Integration Status

✅ Titlescreen kernel included in Bank 9
✅ Layout configured for three 48x2 minikernels
✅ Screen routines updated to use `titledrawscreen`
⏳ Bitmap image files need to be created/converted

