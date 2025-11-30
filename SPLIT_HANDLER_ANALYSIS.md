# Split Handler Analysis: Overscan vs Vblank

## Proposed Architecture

Split mode handlers into two parts:
1. **Overscan Handler**: Input reading & sound/music updates
2. **Vblank Handler**: Mode-specific logic (physics, collisions, state updates)

## Current Flow

```
Frame N-1 ends (visible screen)
  ↓
Overscan period (~30 scanlines, ~1140 cycles)
  ↓
Mode handler runs (ALL logic: input, sound, mode-specific)
  ↓
MainLoopContinue (music update if needed)
  ↓
MainLoopDrawScreen calls drawscreen
  ↓
drawscreen: WaitForOverscanEnd → VSYNC → vblank_bB_code (empty) → WaitForVblankEnd → visible screen
```

## Proposed Flow

```
Frame N-1 ends (visible screen)
  ↓
Overscan period
  ↓
overscan_bB_code hook: Input reading & sound/music updates
  ↓
drawscreen: WaitForOverscanEnd → VSYNC → vblank_bB_code: Mode-specific logic → WaitForVblankEnd → visible screen
```

## Benefits

### 1. **Better Time Distribution**
- **Overscan**: ~1140 cycles for input/sound (currently unused)
- **Vblank**: ~2270 cycles for mode logic (currently all logic runs here)
- **Total**: ~3410 cycles available (same total, better distribution)

### 2. **Addresses Game Mode Time Budget Issue**
- Game mode currently: ~4150 cycles (exceeds budget)
- If split:
  - Overscan: ~500 cycles (input + sound) ✅
  - Vblank: ~3650 cycles (mode logic) ⚠️ Still exceeds vblank budget
- **Note**: Still exceeds total budget, but better distribution

### 3. **Clearer Separation of Concerns**
- Input/sound: Time-critical, must happen early
- Mode logic: Can use remaining vblank time
- Visible screen: Reserved for drawing only

### 4. **More Predictable Timing**
- Input reading happens at consistent time (overscan)
- Mode logic has dedicated vblank time
- Less risk of logic spilling into visible screen

## Implementation Requirements

### 1. Kernel Modifications

**MultiSprite Kernel** (`Source/Common/MultiSpriteKernel.s`):

Current:
```assembly
drawscreen
WaitForOverscanEnd
    lda INTIM
    bmi WaitForOverscanEnd
    
    ; VSYNC...
    ; vblank_bB_code (empty - just rts)
    ; WaitForVblankEnd...
    ; Draw visible screen...
```

Proposed:
```assembly
drawscreen
WaitForOverscanEnd
    lda INTIM
    bmi WaitForOverscanEnd
    
    ; NEW: overscan_bB_code hook
    jsr overscan_bB_code
    
    ; VSYNC...
    ; vblank_bB_code: Mode-specific logic
    jsr vblank_bB_code
    ; WaitForVblankEnd...
    ; Draw visible screen...
```

**Title Screen Kernel** (`Source/TitleScreen/asm/titlescreen.s`):

Would need similar modification:
```assembly
titledrawscreen
title_eat_overscan
    lda INTIM
    bmi title_eat_overscan
    
    ; NEW: overscan_bB_code hook
    jsr overscan_bB_code
    
    ; VSYNC...
    ; vblank_bB_code: Mode-specific logic
    jsr vblank_bB_code
    ; WaitForVblankEnd...
    ; Draw visible screen...
```

### 2. Mode Handler Restructuring

**Current Structure**:
```basic
GameMainLoop
    ; All logic together
    gosub ReadEnhancedButtons
    gosub HandleConsoleSwitches
    gosub InputHandleAllPlayers
    gosub UpdateSoundEffect
    ; ... all mode logic ...
    return otherbank
```

**Proposed Structure**:
```basic
GameMainLoopOverscan
    ; Input & sound only
    gosub ReadEnhancedButtons
    gosub HandleConsoleSwitches
    gosub InputHandleAllPlayers
    gosub UpdateSoundEffect
    return otherbank

GameMainLoopVblank
    ; Mode-specific logic only
    gosub UpdateCharacterAnimations
    gosub UpdatePlayerMovement
    gosub PhysicsApplyGravity
    ; ... rest of mode logic ...
    return otherbank
```

### 3. MainLoop Restructuring

**Current**:
```basic
MainLoop
    on gameMode gosub MainLoopModePublisherPrelude ...
MainLoopContinue
    if gameMode < 3 then gosub PlayMusic bank15
MainLoopDrawScreen
    if gameMode < 3 then gosub DrawTitleScreen bank9
    if gameMode >= 3 then drawscreen
    goto MainLoop
```

**Proposed**:
```basic
MainLoop
    ; No mode dispatch here - handled by hooks
MainLoopDrawScreen
    if gameMode < 3 then gosub DrawTitleScreen bank9
    if gameMode >= 3 then drawscreen
    goto MainLoop

; Overscan hook dispatcher
overscan_bB_code
    on gameMode gosub OverscanModePublisherPrelude ...
    return

; Vblank hook dispatcher  
vblank_bB_code
    on gameMode gosub VblankModePublisherPrelude ...
    return
```

## Challenges

### 1. **Kernel Modification Required**
- Must modify both MultiSprite and Title Screen kernels
- Need to ensure compatibility with batariBASIC compilation
- Risk of breaking existing functionality

### 2. **Mode Handler Complexity**
- Each mode needs two handlers instead of one
- Must ensure proper state management between handlers
- More complex debugging

### 3. **State Management**
- Input state must be available to vblank handler
- Sound state must be updated before vblank
- Need to ensure no race conditions

### 4. **Bank Switching**
- Overscan and vblank handlers may need different banks
- Cross-bank calls add overhead
- Must ensure proper bank state

### 5. **Game Mode Still Exceeds Budget**
- Even with split, game mode logic (~3650 cycles) exceeds vblank budget (~2270 cycles)
- Would still need optimization
- Split helps but doesn't fully solve the problem

## Alternative: Hybrid Approach

Keep current structure but optimize:

1. **Move lightweight operations to overscan** (if kernel supports it):
   - Input reading (fast)
   - Sound updates (fast)
   - Simple state checks

2. **Keep heavy operations in current location** (before drawscreen):
   - Physics calculations
   - Collision detection
   - Complex state updates

3. **Use vblank_bB_code hook for minimal operations**:
   - Final sprite position updates
   - Last-minute state fixes

## Recommendation

### Option 1: Full Split (Not Recommended)
- **Pros**: Better time distribution, clearer separation
- **Cons**: Major kernel modifications, complex restructuring, game mode still exceeds budget
- **Risk**: High - could break existing functionality
- **Effort**: Very High

### Option 2: Optimize Current Structure (Recommended)
- **Pros**: No kernel changes, lower risk, addresses root cause
- **Cons**: Requires optimization work
- **Risk**: Low - incremental improvements
- **Effort**: Medium

**Specific Optimizations**:
1. Profile actual cycle counts (not estimates)
2. Optimize collision detection (biggest win)
3. Move some systems to alternate frames
4. Reduce redundant calculations
5. Cache frequently accessed values

### Option 3: Partial Split (If Kernel Supports)
- Use overscan hook for input/sound (if available)
- Keep mode logic in current location
- **Pros**: Better time distribution without major restructuring
- **Cons**: Still need kernel modifications, game mode still exceeds budget
- **Risk**: Medium
- **Effort**: Medium-High

## Conclusion

While splitting handlers between overscan and vblank has theoretical benefits, the implementation complexity and risk outweigh the benefits, especially since:

1. Game mode would still exceed time budget (just distributed differently)
2. Requires major kernel modifications
3. Adds significant complexity to mode handlers
4. The root issue (game mode exceeding budget) is better solved through optimization

**Recommendation**: Focus on optimizing the current structure rather than splitting handlers. The time budget issue is better addressed through code optimization than architectural changes.

