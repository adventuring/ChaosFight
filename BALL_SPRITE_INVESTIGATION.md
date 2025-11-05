# Ball Sprite Investigation for Missile System

## Issue #624: Investigate using Ball sprite for additional missile in flicker code

**Date:** 2025-11-05  
**Status:** Investigation Complete

## Executive Summary

The Atari 2600 Ball sprite is available but not currently used in ChaosFight. Using it as an additional missile would provide limited benefits due to:
- Ball sprite limitations (single pixel, fixed size)
- Current missile system already supports 4 simultaneous missiles
- Flicker code complexity would increase significantly
- Ball sprite shares color register with playfield

## Current Missile System

**Current Implementation:**
- 4 simultaneous missiles (one per player)
- Uses `missile0x`, `missile1x` for P1/P2 and P3/P4 (multisprite kernel)
- Missile positions: `missileX[0-3]` (a-d), `missileY[0-3]` (w-z)
- Active tracking: `missileActive` bit flags (1, 2, 4, 8)
- Lifetime counters: Packed nybbles in `missileLifetime` (e, f)

**Limitations:**
- Maximum 4 missiles (one per player)
- Cannot have multiple missiles from same player simultaneously
- Missile flicker code already handles 4-player multiplexing

## Ball Sprite Capabilities

### Multisprite Kernel Support

**YES - Ball sprite IS supported in multisprite kernel.**

**Available Parameters:**
- `ballx` ($82): X position (0-159)
- `bally` ($8C): Y position (0-255)
- **Width:** Fixed at 1 pixel (hardware limitation - cannot be changed)
- **Height:** Controlled via `CTRLPF` register bits (1, 2, 4, or 8 pixels)
- `ENABL` register: Enable/disable Ball sprite
- `RESBL` register: Reset Ball sprite position
- `HMBL` register: Horizontal motion Ball
- `VDELBL` register: Vertical delay Ball

**Note:** Unlike standard kernel, multisprite kernel does NOT define `ballheight` variable.
Height is controlled directly via `CTRLPF` register bits 4-5:
- `CTRLPF` bits 4-5 = %00: 1 pixel tall
- `CTRLPF` bits 4-5 = %01: 2 pixels tall  
- `CTRLPF` bits 4-5 = %10: 4 pixels tall
- `CTRLPF` bits 4-5 = %11: 8 pixels tall

**Memory Addresses (multisprite kernel):**
- `ballx = $82` (zero-page RAM)
- `bally = $8C` (zero-page RAM)
- No `ballheight` variable (use `CTRLPF` register directly)

**Limitations:**
- Single pixel wide (1xN pixels, where N = height)
- Height controlled via CTRLPF register (not a variable)
- Fixed width: Always 1 pixel (hardware limitation)
- Shares color register with playfield (`COLUPF`)
- Cannot change color independently
- Limited visual appearance (single pixel column)

## Potential Use Cases

### 1. Additional Projectile Per Player
**Pros:**
- Could allow 2 missiles per player (8 total)
- Additional visual variety

**Cons:**
- Ball sprite is single pixel wide (very small)
- Shares playfield color (cannot be distinct)
- Would require significant flicker code changes
- Ball sprite rendering is per-scanline (complex timing)

### 2. Alternative Missile Type
**Pros:**
- Could use Ball for different projectile type
- Frees up missile sprites for other uses

**Cons:**
- Ball sprite visual limitations (single pixel)
- Color constraint (must match playfield)
- Not suitable for visible projectiles
- Better suited for special effects

### 3. Special Effects
**Pros:**
- Could use Ball for particle effects
- Explosion debris, sparkles, etc.
- Doesn't interfere with missile system

**Cons:**
- Single pixel is very small
- Color limitations still apply
- May not be visible enough

## Technical Considerations

### Multisprite Kernel Implementation

**Ball Sprite Support:**
- Ball sprite is positioned in `PrePositionAllObjects` routine (multisprite_kernel.asm:170)
- Uses same positioning subroutine as other sprites
- Y position checked per scanline using `VDELBL` (vertical delay) register
- Ball sprite is drawn on every scanline if enabled (via `ENABL` register)

**Positioning:**
- `ballx` set before `PrePositionAllObjects` call
- `bally` used for scanline comparison during kernel
- Ball sprite follows same timing constraints as other sprites

### Flicker Code Integration
Current flicker code handles:
- Player sprites (P1-P4)
- Missile sprites (M0-M1 for P1/P2, M2/M3 for P3/P4)

Adding Ball sprite would require:
- Setting `ballx` and `bally` before `drawscreen`
- Configuring `CTRLPF` register for ball height
- Setting `ENABL` register to enable ball
- Color synchronization with playfield (COLUPF)
- Per-scanline timing (handled automatically by kernel)

### Memory Impact
- Ball sprite uses zero-page RAM: `ballx`, `bally`, `ballheight`
- No additional missile tracking arrays needed
- Minimal memory overhead

### Performance Impact
- Ball sprite rendering is per-scanline
- Requires additional kernel cycles
- May impact frame timing
- Flicker code complexity increases

## Recommendations

### Option 1: Do Not Use Ball Sprite for Missiles
**Rationale:**
- Current 4-missile system is sufficient
- Ball sprite visual limitations (single pixel) make it unsuitable
- Color constraint (must match playfield) reduces usefulness
- Flicker code complexity not justified

### Option 2: Use Ball Sprite for Special Effects Only
**Rationale:**
- Use Ball for particle effects, not projectiles
- Explosion debris, sparkles, hit effects
- Doesn't require complex flicker code
- Visual limitations acceptable for effects

### Option 3: Future Enhancement
**Rationale:**
- Document Ball sprite capabilities for future use
- Consider if gameplay requires more than 4 missiles
- Evaluate if special effects would benefit from Ball sprite
- Revisit if missile system limitations become problematic

## Conclusion

**Recommendation:** Do not implement Ball sprite for missiles at this time.

**Reasons:**
1. Current 4-missile system is adequate for gameplay
2. Ball sprite visual limitations (single pixel) make it unsuitable for visible projectiles
3. Color constraint (must match playfield) reduces visual distinctiveness
4. Flicker code complexity not justified for limited benefit
5. Better reserved for special effects if needed in future

**Future Consideration:**
- Monitor gameplay feedback for missile system limitations
- Consider Ball sprite for special effects (explosions, particles) if needed
- Document Ball sprite capabilities for reference

## References

- Atari 2600 TIA Hardware Manual
- batariBASIC includes: `2600basic.h` (ballx, bally, ballheight definitions)
- Current missile system: `Source/Routines/MissileSystem.bas`
- Flicker code: `Source/Routines/PlayerRendering.bas`

