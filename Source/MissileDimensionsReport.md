# Missile Dimensions Report for Projectile Characters

Generated: 2025-01-XX

## Overview

This report documents the missile dimensions (width × height) for all characters that use ranged attacks (projectiles) in ChaosFight.

## Data Source

- **File**: `Source/Common/CharacterDefinitions.bas`
- **Tables**: 
  - `CharacterMissileWidths` (line 148-149)
  - `CharacterMissileHeights` (line 157-158)
  - `CharacterAttackTypes` (line 229) - bit-packed to determine ranged vs melee

## Ranged Characters with Missile Dimensions

| Character          | Attack Type | Width | Height | Notes |
|--------------------|-------------|-------|--------|-------|
| Bernie             | Ranged      | 1     | 1      | Narrow, low-height projectile |
| Curler             | Ranged      | 4     | 2      | Wide projectile (ground-based) |
| Dragon of Storms   | Ranged      | 2     | 2      | Standard projectile (ballistic arc) |
| Zoe Ryen           | Ranged      | 2     | 2      | Standard projectile |
| Fat Tony           | Ranged      | 2     | 2      | Standard projectile |
| Megax              | Ranged      | 4     | 2      | Wide projectile (fire breath) |
| Harpy              | Ranged      | 0     | 0      | No missile sprite (diagonal swoop attack) |
| Frooty             | Ranged      | 2     | 2      | Standard projectile (magical sparkles) |

## Summary Statistics

- **Total ranged characters**: 8
- **Characters with missile sprites** (width/height > 0): 7
- **Characters without missile sprites** (width/height = 0): 1 (Harpy)

### Width Distribution
- Width 1: 1 character (Bernie)
- Width 2: 4 characters (Dragon of Storms, Zoe Ryen, Fat Tony, Frooty)
- Width 4: 2 characters (Curler, Megax)
- Width 0: 1 character (Harpy)

### Height Distribution
- Height 1: 1 character (Bernie)
- Height 2: 6 characters (Curler, Dragon of Storms, Zoe Ryen, Fat Tony, Megax, Frooty)
- Height 0: 1 character (Harpy)

## Character-Specific Notes

### Bernie (Character #0)
- **Dimensions**: 1×1 pixels
- **Type**: Narrow, low-height projectile
- **Special**: Smallest missile size

### Curler (Character #1)
- **Dimensions**: 4×2 pixels
- **Type**: Wide, ground-based projectile
- **Special**: Maximum width (4 pixels), uses ground-based movement

### Dragon of Storms (Character #2)
- **Dimensions**: 2×2 pixels
- **Type**: Standard projectile with ballistic arc
- **Special**: Uses gravity flag for ballistic trajectory

### Zoe Ryen (Character #3)
- **Dimensions**: 2×2 pixels
- **Type**: Standard projectile

### Fat Tony (Character #4)
- **Dimensions**: 2×2 pixels
- **Type**: Standard projectile

### Megax (Character #5)
- **Dimensions**: 4×2 pixels
- **Type**: Wide projectile (fire breath)
- **Special**: Maximum width (4 pixels), fire breath effect

### Harpy (Character #6)
- **Dimensions**: 0×0 pixels
- **Type**: No missile sprite
- **Special**: Diagonal downward swoop attack - character movement IS the attack, no separate missile

### Frooty (Character #8)
- **Dimensions**: 2×2 pixels
- **Type**: Standard projectile (magical sparkles)
- **Special**: Visual effect should show sparkle particles in sprite graphics

## Recommendations for Review

1. **Harpy**: Currently has no missile sprite (0×0) but uses ranged attack. This is intentional as the character movement itself is the attack. No changes needed.

2. **Bernie**: Very small missile (1×1). Consider if this is appropriate for visibility/playability.

3. **Curler & Megax**: Maximum width (4 pixels). Ensure visual effects match the wide projectile size.

4. **Consistency**: Most characters use 2×2 standard projectiles. Consider if Bernie's 1×1 should be increased for consistency.

## Related Issues

- #594: Missile multiplexing - Do not switch to blank (unused) missile
- #595: Missile multiplexing - Support separate heights for P1/P3 and P2/P4
- #596: Report on missile heights and widths (this report)

