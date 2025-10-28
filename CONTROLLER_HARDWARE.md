# ChaosFight Controller Hardware Documentation

## Atari 2600 Input Pin Mapping

### Standard Joystick (CX-40)
**Port 1 (Player 1):**
- SWCHA bits 4-7: UP, DOWN, LEFT, RIGHT
- INPT4 bit 7: Fire button

**Port 2 (Player 2):**
- SWCHA bits 0-3: UP, DOWN, LEFT, RIGHT  
- INPT5 bit 7: Fire button

### Genesis/Mega Drive 3-Button Controller
**Port 1:**
- SWCHA bits 4-7: D-pad (UP, DOWN, LEFT, RIGHT)
- INPT4 bit 7: Button B (attack/fire)
- Button C: Uses TH line (requires SELECT toggling via SWACNT)
- Button A, START: Not reliably detectable on Atari 2600

**Port 2:**
- SWCHA bits 0-3: D-pad (UP, DOWN, LEFT, RIGHT)
- INPT5 bit 7: Button B (attack/fire)
- Button C: Uses TH line (requires SELECT toggling via SWACNT)
- Button A, START: Not reliably detectable on Atari 2600

**Note:** Genesis controllers use multiplexed button reading via the TH (SELECT) line which requires toggling SWACNT. Button C detection requires:
1. Set SWACNT to output mode for TH
2. Toggle TH low
3. Read INPT0/INPT2 for button state
4. Restore SWACNT to input mode

### Joy2B+ Enhanced Controller
**Port 1 (Player 1):**
- SWCHA bits 4-7: Joystick/D-pad (UP, DOWN, LEFT, RIGHT)
- INPT4 bit 7: Button I (attack/primary fire)
- INPT0 bit 7: Button II (jump/secondary fire) - paddle port
- INPT1 bit 7: Button III (pause/tertiary fire) - paddle port

**Port 2 (Player 2):**
- SWCHA bits 0-3: Joystick/D-pad (UP, DOWN, LEFT, RIGHT)
- INPT5 bit 7: Button I (attack/primary fire)
- INPT2 bit 7: Button II (jump/secondary fire) - paddle port
- INPT3 bit 7: Button III (pause/tertiary fire) - paddle port

### Quadtari Adapter (4-Player)
**Frame Multiplexing:**
- Even frames: Read P1 (Port 1) and P2 (Port 2) normally
- Odd frames: Read P3 (Port 1 multiplexed) and P4 (Port 2 multiplexed)

**Detection:**
INPT4/INPT5 show alternating patterns across frames when Quadtari is connected.

**Port assignments:**
- Player 1: SWCHA bits 4-7 (even), INPT4 (even)
- Player 2: SWCHA bits 0-3 (even), INPT5 (even)
- Player 3: SWCHA bits 4-7 (odd), INPT4 (odd)
- Player 4: SWCHA bits 0-3 (odd), INPT5 (odd)

## ChaosFight Button Mapping

### Standard CX-40 Joystick
- UP: Jump
- DOWN: Guard
- LEFT/RIGHT: Move
- FIRE: Attack

### Genesis Controller
- D-pad LEFT/RIGHT: Move
- D-pad DOWN: Guard
- D-pad UP: **Not used** (jump via Button C)
- Button B (INPT4/5): Attack
- Button C (via TH): Jump (requires detection code)

### Joy2B+ Controller
- Stick/D-pad LEFT/RIGHT: Move
- Stick/D-pad DOWN: Guard
- Stick/D-pad UP: **Not used** (jump via Button II)
- Button I (INPT4/5): Attack
- Button II (INPT0/2): Jump
- Button III (INPT1/3): Pause

## Implementation Status

### ✅ Implemented
- Standard CX-40 joystick input
- Quadtari 4-player detection and multiplexing
- Basic Genesis controller compatibility (Button B as fire)
- Color/B&W switch detection

### ⚠️ Partially Implemented
- Genesis Button C detection (TH line toggling not implemented)
- Joy2B+ Button II/III detection (INPT0/1/2/3 reading not implemented)

### ❌ Not Implemented
- Joy2B+ pause functionality
- Separate jump button functionality (joy0up always used)
- Genesis/Joy2B+ detection logic
- Controller type variable tracking

## Required Implementation Changes

1. **Add controller type detection:**
   - GenesisDetected flag
   - Joy2bPlusDetected flag
   - Detection code in ControllerDetection.bas

2. **Add Genesis Button C reading:**
   - Toggle SWACNT for TH line
   - Read INPT0 (P1) / INPT2 (P2) for Button C
   - Map Button C to jump action

3. **Add Joy2B+ multi-button reading:**
   - Read INPT0/1 (P1) or INPT2/3 (P2)
   - Map Button II to jump action
   - Map Button III to pause action

4. **Update game controls:**
   - Add separate jump action variable
   - Check controller type before mapping joy0up to jump
   - Handle pause button in Joy2B+ mode

## Hardware Constraints

- **Genesis + Quadtari incompatibility:** TH line toggling conflicts with Quadtari multiplexing
- **Joy2B+ + Quadtari incompatibility:** INPT0-3 used for paddle buttons conflict with Quadtari detection
- **Standard 2-player only** for Genesis and Joy2B+ controllers
- **INPT0-3 are paddle/pot ports** and require different reading than INPT4/5 (paddle charging time vs digital read)

---

**Last Updated:** 2025-10-28

