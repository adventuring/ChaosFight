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
| Bernie             | Ground Thump (AOE) | - | - | Area-of-effect melee, hits both sides |
| Curler             | Ranged      | 4     | 4      | Wide projectile (ground-based) |
| Dragon of Storms   | Ranged      | 2     | 2      | Standard projectile (ballistic arc) |
| Zoe Ryen           | Ranged      | 4     | 1      | Wide, low-height projectile |
| Fat Tony           | Ranged      | 4     | 1      | Wide, low-height projectile |
| Megax              | Ranged      | 4     | 4      | Wide projectile (fire breath) |
| Harpy              | Ranged      | 0     | 0      | No missile sprite (diagonal swoop attack) |
| Frooty             | Ranged      | 1     | 1      | Narrow projectile (magical sparkles) |

## Summary Statistics

- **Total ranged characters**: 8
- **Characters with missile sprites** (width/height > 0): 7
- **Characters without missile sprites** (width/height = 0): 1 (Harpy)

### Width Distribution
- Width 1: 1 character (Frooty)
- Width 2: 1 character (Dragon of Storms)
- Width 4: 3 characters (Curler, Zoe Ryen, Fat Tony, Megax)
- Width 0: 2 characters (Bernie - melee, Harpy - no missile)

### Height Distribution
- Height 1: 3 characters (Zoe Ryen, Fat Tony, Frooty)
- Height 2: 1 character (Dragon of Storms)
- Height 4: 2 characters (Curler, Megax)
- Height 0: 2 characters (Bernie - melee, Harpy - no missile)

## Character-Specific Notes

### Bernie (Character #0)
- **Dimensions**: N/A (melee only)
- **Type**: No ranged attack - uses area-of-effect "Ground Thump" attack
- **Special**: Ground Thump hits nearby characters both left and right simultaneously, shoving them rapidly away from Bernie

### Curler (Character #1)
- **Dimensions**: 4×4 pixels
- **Type**: Wide, tall ground-based projectile
- **Special**: Maximum width and height (4×4 pixels), uses ground-based movement

### Dragon of Storms (Character #2)
- **Dimensions**: 2×2 pixels
- **Type**: Standard projectile with ballistic arc
- **Special**: Uses gravity flag for ballistic trajectory

### Zoe Ryen (Character #3)
- **Dimensions**: 4×1 pixels
- **Type**: Wide, low-height projectile

### Fat Tony (Character #4)
- **Dimensions**: 4×1 pixels
- **Type**: Standard projectile

### Megax (Character #5)
- **Dimensions**: 4×4 pixels
- **Type**: Wide, tall projectile (fire breath)
- **Special**: Maximum width and height (4×4 pixels), fire breath effect

### Harpy (Character #6)
- **Dimensions**: 0×0 pixels
- **Type**: No missile sprite
- **Special**: Diagonal downward swoop attack - character movement IS the attack, no separate missile

### Frooty (Character #8)
- **Dimensions**: 1×1 pixels
- **Type**: Narrow, low-height projectile (magical sparkles)
- **Special**: Smallest projectile size, visual effect should show sparkle particles in sprite graphics

## Recommendations for Review

1. **Bernie**: Ground Thump area-of-effect attack (melee only). Hits nearby characters both left and right, shoving them rapidly away. No missile dimensions needed.

2. **Harpy**: Currently has no missile sprite (0×0) but uses ranged attack. This is intentional as the character movement itself is the attack. No changes needed.

3. **Curler & Megax**: Maximum dimensions (4×4 pixels). Ensure visual effects match the large projectile size.

4. **Zoe Ryen & Fat Tony**: Wide, low-height projectiles (4×1). Ensure visual effects match the wide but flat projectile shape.

5. **Frooty**: Small projectile (1×1). Consider if this is appropriate for visibility/playability of sparkle effects.

## Related Issues

- #594: Missile multiplexing - Do not switch to blank (unused) missile
- #595: Missile multiplexing - Support separate heights for P1/P3 and P2/P4
- #596: Report on missile heights and widths (this report)

