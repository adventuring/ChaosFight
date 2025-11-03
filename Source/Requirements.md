# ChaosFight 25 - Minimum Viable Product Requirements

## Cold Start Initialization

Upon cold start:
- Common and admin vars are cleared
- Hardware registers are set up (TIA colors, audio)
- Console detection (2600 vs 7800) runs first, before any code modifies $D0/$D1
- Controller detection (Mega Drive/Genesis, Joy2b+, or Quadtari) is performed
- COLUBK is set to black and remains black throughout

---

## Game Reset Behavior

In any mode, pressing Game Reset causes an instant hard reboot:
- Calls ColdStart to clear all vars and reinitialize hardware registers
- System state is completely reset

---

## Admin Mode Controller Redetection

In any admin modes (title, preambles, level select):
- Pressing Game Select causes controller redetection
- Toggling Color/B&W switch causes controller redetection  
- Pause button (on 7800) causes controller redetection

---

## Publisher Prelude (formerly Publisher Preamble)

Displays two 48×42 px images with row-by-row color:
- AtariAge Logo
- AtariAge Text
- Both centered on black screen

Plays "Atari Today" song once. Upon song completion OR any player button press (up to 4 players), advance to Author Prelude.

---

## Author Prelude (formerly Author Preamble)

Displays Interworldly graphic. Plays "Interworldly" jingle once. Upon jingle completion OR any player button press, advance to Title Screen.

---

## Title Screen

- Chaos Fight 25 logo appears near top 1/3 of screen, centered horizontally
- Copyright graphic appears below logo after a moment
- After 5 seconds, copyright graphic vanishes and "parade" begins
- Character Parade:
  - Without Quadtari: 2 characters at a time (alternating as one exits, another enters)
  - With Quadtari: 4 characters (generally 3, sometimes 4 on screen)
  - Characters walk from left edge to center, perform attack animation once, walk off right edge
- Title song "Chaotica" repeats
- After 3 minutes (10800 frames at 60fps), jump to Attract mode
- Any player button press transitions to Character Select

### Attract Mode

Attract mode forms an endless wait loop. For now, Attract mode handler simply jumps back to Publisher Prelude screen.

---

## Character Select

### Overview
Players select their fighters from 16 available characters (0-15). Supports 2-player (standard ports) and 4-player (Quadtari adapter) modes. Once all active players have locked in their selections, proceed to Level Select.

Players 2 (and if present) 3 & 4 start "locked in" to "CPU" and "NO" and "NO" and unlock on any action.

### Controller Support
- **2-player mode**: Left port (Player 1), Right port (Player 2)
- **4-player mode (Quadtari detected)**: 
  - Even frames: Left port = Player 1, Right port = Player 2
  - Odd frames: Left port = Player 3, Right port = Player 4
- Controller detection runs on entry to Character Select screen

### Input Handling
- **Left/Right**: Cycle through 16 characters (0-15), wraps from 15→0 or 0→15
- **Fire/B/I button**: Lock in current character selection
- **UP button**: Unlock current selection (returns to browsing)
- **DOWN button**: Unlock current selection (returns to browsing)
- **DOWN + Fire/B/I button**: Lock in with handicap (75% health instead of 100%)

### Character Selection States
- **PlayerChar[0-3]**: Current character index being browsed (0-15, or 255 for "NO")

Player 1 options: ? or 0 ↔ MaxCharacterID

Player 3/4 options: NO or ? or 0 ↔ MaxCharacterID

Player 2: ? or 0 ↔ MaxCharacterID and
- if either of Player 3 or Player 4 is not "NO" then "NO" is an option
- otherwise (no player 3/4) then "CPU" is the other option

- **PlayerLocked[0-3]**: Lock state:
  - 0 = Unlocked (still browsing)
  - 1 = Locked (normal health, 100%)
  - 2 = Locked (handicap mode, 75% health)

### Visual Display
- Display character preview with animations
- Show lock status for each player
- Display "NO" sprite for unselected players (participants 3-4 in 2-player mode)
- Display character sprites in screen quadrants

If no Quadtari, do not show players 3/4 at all.

### Progression Logic
- **2-player mode**: At least Player 1 must lock in selection to proceed
- **4-player mode**: At least 2 players must lock in to proceed
- "?" characters auto-select random character (once locked in)
- "CPU" selects a random character (when everyone else is locked in)
- Once all players locked in, transition to Level Select

### Sound Effects
- Menu navigation sound (SoundMenuNavigate) on left/right movement
- Menu selection sound (SoundMenuSelect) on lock/unlock
- No background music (admin screens use music, but Character Select may have SFX)

### Special Cases
- DOWN button should NOT trigger hurt animations or hurt sounds (Issue #362)
- All navigation should use menu sound effects, not gameplay sounds

---

## Level Select

- Player 1 only can use left/right to cycle through:
  - Decimal numbers 01 up to MaxArenaID + 1 (currently 15, so 15+1=16, displayed as "01" through "16")
  - Then '??' (two question marks) for random arena
  - Then back to 01 (wraps)
  - Can go in reverse (01 down to ?? down to 16)
- Player 1 locks in selection by pressing Fire/B/I button
- Special case: If any player holds Fire/B/I for one full second, return to Character Select
- Game Select switch pressed: return to Character Select
- Four locked-in player graphics remain on screen (NO sprites not shown)
- "CPU" or "?" already have random character selected
- Digits appear in center, white-on-black

---

## Falling In Animation

- Four player graphics move from their respective quadrants (unless set to "NO")
- Move toward their "row 2" starting positions
  - "Row 2" refers to the height of one row of playfield pixel data at 32×8 display
  - Start at top of screen and continue downwards until finding clear pixels wide enough for double-width player
- Characters are positioned there
- "Nudged" down if there are playfield pixels near their fixed starting point
- Re-initialize for Game Mode and switch to it

Note: Bernie can use the same "high as I can be without being in a brick" logic when he falls off the screen and resets at the top.

---

## Game Mode

### Initialization
- Call BeginGameLoop before entering Game Mode:
  - Initialize player positions from Falling In animation final positions
  - Set player facing directions (alternating: P1 right, P2 left, P3 right, P4 left)
  - Apply handicap if selected (PlayerLocked[0-3] = 2 → 75% health, else 100%)
  - Initialize player states, timers, momentum
  - Load character types from SelectedChar1-4 variables
  - Initialize missiles and projectiles
  - Set frame counter and game state
  - Load arena/level data

### Playfield and Colors
- Set Playfield and pfcolors:
  - **Color mode + NTSC/PAL**: color-per-row (different colors for each playfield row)
  - **B&W or SECAM**: white COLUPF (single color for entire playfield)
- Playfield layout: 32×8 pixel data
- Color data defined per arena in level data files

### Game Cycle (Per Frame)
1. **Console Switch Handling**: Check pause, reset, color/B&W toggle
2. **Player Input**: Handle all player inputs (with Quadtari multiplexing if 4-player)
3. **Animation System**: Update character animations (10fps animation rate, 8-frame sequences)
4. **Movement System**: Update player movement (full 60fps movement rate)
5. **Physics**: Apply gravity (character-specific, some characters ignore gravity)
6. **Momentum & Recovery**: Apply momentum from attacks, update recovery/hitstun frames
7. **Special Movement**: Apply character-specific movement (Bernie screen wrap, Frooty flight, etc.)
8. **Boundary Collisions**: Check screen edges, wrap/stop as appropriate
9. **Player Collisions**: Check multi-player collisions, apply separation logic
10. **Player Eliminations**: Check if any players health reached 0, mark as eliminated
11. **Attack Cooldowns**: Update attack cooldown timers
12. **Missile System**: Update all active missiles (movement, gravity, lifetime)
13. **Missile Collisions**: Check missiles vs players, missiles vs playfield
14. **Sprite Positioning**: Set hardware sprite positions for all players
15. **Sprite Graphics**: Load character sprites based on animation state and facing
16. **Health Display**: Show health bars, flash sprites when health is low
17. **Screen Draw**: Render complete frame

### Player Actions
- **Walk Left/Right**: Horizontal movement based on character weight
- **Jump**: Vertical movement, character-specific jump heights based on weight
- **Guard**: Block incoming attacks, reduces damage (DOWN button or Guard button)
- **Attack**: Melee or ranged attacks based on character type
- **Special Moves**: Character-specific abilities (see Character Behaviors section)

### Physics Systems
- **Gravity**: Affects most characters (Frooty and Dragon of Storms ignore gravity - can fly)
- **Weight Effects**:
  - Heavier characters: Lower jumps, slower movement, more knockback resistance
  - Lighter characters: Higher jumps, faster movement, less knockback resistance
- **Momentum**: Horizontal and vertical momentum from attacks, knockback, collisions
- **Recovery/Hitstun**: Frames of vulnerability after being hit

### Combat System
- **Melee Attacks**: Close-range attacks with character-specific ranges
- **Ranged Attacks**: Projectile attacks with character-specific properties
- **Hit Detection**: AABB (axis-aligned bounding box) collision detection
- **Knockback**: Pushes players based on attack force and weight difference
- **Damage**: Character-specific base damage modified by weight, attack type

### Missile System
- **Missile Types**: Character-specific projectiles (size, trajectory, lifetime)
- **Movement**: Horizontal, vertical, or ballistic arcs
- **Collision**: Hit players, background, or both based on missile flags
- **Multiplexing**: In 4-player mode, 2 hardware missiles shared via frame multiplexing
  - Even frames: missile0 = Participant 1, missile1 = Participant 2
  - Odd frames: missile0 = Participant 3, missile1 = Participant 4

### Game End Condition
- Game ends when only one player remains (all others eliminated)
- Eliminated players: Health reached 0, marked in PlayersEliminated bit flags
- Transition to Winner Screen after last elimination

### Sound Effects (During Gameplay)
- Attack hit sounds
- Guard block sounds
- Jump sounds
- Player elimination sounds
- Landing sounds (safe landing vs. damaging landing)
- No background music (gameplay uses SFX only)

### Console Switches (During Game Mode)
- **Game Reset**: Instant hard reboot (calls ColdStart)
- **Game Select**: No effect (only active in admin modes)
- **Color/B&W Switch**: No effect (only active in admin modes)
- **Pause Input**: Toggle pause state
  - **Select Switch**: Pressing Select toggles pause on/off
  - **Joy2b+ Button III**: Pressing Button III on Joy2b+ controllers (left or right port) toggles pause on/off
  - **7800 Pause Button**: On Atari 7800, this is a momentary contact switch that affects playfield color mode
- **7800 Pause Button Behavior**: 
  - On 7800, the pause button is a momentary contact switch that occupies the same hardware pin as the 2600 Color/B&W switch
  - On 2600: Color/B&W switch is binary (color position vs B&W position) - determines if playfield uses color-per-row or single-white color
  - On 7800: Pause button is momentary toggle - each press toggles between White-only mode and Color-Per-Row (pfcolor) mode
  - This affects ONLY the playfield color rendering, not pause state
  - Uses colorBWOverride variable to track toggle state

---

## Winner Screen

- Display winner announcement
- Winner acknowledges victory by pressing a button
- Return to title screen after acknowledgment

---

## Character Behaviors

### Character 0: Bernie
- **Weight**: Very Heavy (35)
- **Attack Type**: Melee (hits BOTH DIRECTIONS - dual-direction AOE)
- **Missile**: None (melee only, 4-frame lifetime for visual)
- **Special Moves**:
  - No jumping
  - **Fall abilities**: 
    - Wraps from bottom to top of screen when falling off
    - Fall damage immunity
    - Can fall through 1-row floors when pressing UP (used for platform navigation)
    - Uses "high as I can be without being in a brick" logic when resetting at top
  - Ground thump affects enemies to either side (dual-direction AOE attack)

### Character 1: Curling Sweeper
- **Weight**: Medium (25)
- **Attack Type**: Ranged
- **Missile**: 4×2 pixels curling stone (from character's feet)
- **Special Moves**: 
  - **Ice physics**: Curling stone slides along ground level with ice physics (smooth sliding motion)
  - Great for hitting low targets
  - Projectile spawns at character's feet and slides horizontally across floor

### Character 2: Dragon of Storms
- **Weight**: Medium-Light (20)
- **Attack Type**: Ranged
- **Missile**: 2×2 pixels, ballistic arc (parabolic trajectory)
- **Special Moves**: 
  - **Flying character**: No gravity, can fly freely (similar to Frooty)
  - Projectile travels in parabolic arc, excellent for hitting enemies at different heights
  - Aerial mobility with full flight control

### Character 3: Zoe Ryen
- **Weight**: Light (15)
- **Attack Type**: Ranged
- **Missile**: Laser blaster (2×2 pixels, horizontal arrowshot)
- **Special Moves**: 
  - **Laser blaster**: Fires long, thin laser that travels horizontally across entire screen
  - High jumps
  - Fast horizontal laser projectile for long-range combat

### Character 4: Fat Tony
- **Weight**: Heavy (30)
- **Attack Type**: Ranged
- **Missile**: Magic ring lasers (2×2 pixels, arrowshot)
- **Special Moves**: 
  - **Laser ring**: Magic ring shoots laser projectiles
  - Geography expert
  - Magic ring wielder (laser ring weapon)

### Character 5: Megax
- **Weight**: Medium (25)
- **Attack Type**: Ranged
- **Missile**: Fire breath (ballistic arc)
- **Special Moves**: Giant monster-eating powerhouse, biggest and most powerful known, breathes fire

### Character 6: Harpy
- **Weight**: Light (15)
- **Attack Type**: Ranged (diagonal downward swoop)
- **Missile**: 0×0 (uses character sprite during swoop)
- **Special Moves**: 
  - **Flight pattern**: Can "fly" by repeatedly pressing UP (flap to maintain altitude)
  - **Attack pattern**: Swoop attack - moves diagonally down while attacking (5-frame lifetime)
  - Diagonal downward swoop combines movement and attack in single motion
  - Character sprite itself becomes the attack during swoop animation

### Character 7: Knight Guy
- **Weight**: Very Heavy (32)
- **Attack Type**: Melee
- **Missile**: None (melee only, 6-frame lifetime - longest melee duration)
- **Special Moves**: 
  - **Sword**: Melee weapon is a sword
  - Armored fighter with powerful sword attacks
  - Longest melee attack duration (6 frames)

### Character 8: Frooty
- **Weight**: Very Light (15)
- **Attack Type**: Ranged
- **Missile**: 2×2 pixels, ballistic arc (lollipop sparkle)
- **Special Moves**: 
  - **Flying character**: FREE FLIGHT - Use UP/DOWN to move vertically (no guard action)
  - No gravity, full vertical flight control
  - Cannot guard (pressing DOWN makes her fly down instead)
  - Magical sparkles from lollipop weapon
  - Complete aerial mobility like Dragon of Storms

### Character 9: Nefertem
- **Weight**: Heavy (30)
- **Attack Type**: Melee
- **Missile**: None (melee only, 5-frame lifetime)
- **Special Moves**: Loyalist to the High Council, feline reflexes

### Character 10: Ninjish Guy
- **Weight**: Very Light (10)
- **Attack Type**: Ranged (shuriken projectile)
- **Missile**: Shuriken (2×2 pixels projectile)
- **Special Moves**: 
  - **Shuriken**: Throws shuriken projectiles as ranged attack
  - Highest jumps
  - Fastest movement
  - 50% fall damage reduction
  - Ninja mobility and shuriken throwing

### Character 11: Pork Chop
- **Weight**: Heavy (30)
- **Attack Type**: Melee
- **Missile**: None (melee only, 4-frame lifetime)
- **Special Moves**: Standard heavy melee fighter

### Character 12: Radish Goblin
- **Weight**: Very Light (10)
- **Attack Type**: Melee (bouncing bite attacks)
- **Missile**: None (melee only, 3-frame lifetime)
- **Special Moves**: 
  - Highest jumps
  - Fastest movement
  - Lowest health
  - Bounces when moving

### Character 13: Robo Tito
- **Weight**: Very Heavy (32)
- **Attack Type**: Melee
- **Missile**: None (melee only, 5-frame lifetime)
- **Special Moves**: 
  - No jumping
  - Stretches vertically to ceiling (press UP to stretch and grab ceiling)
  - Can move left/right along ceiling
  - Press DOWN to return to floor
  - Fall damage immunity
  - Vulnerable entire length to collisions

### Character 14: Ursulo
- **Weight**: Heavy (30)
- **Attack Type**: Ranged
- **Missile**: 2×2 pixels, ballistic arc (strongest throw)
- **Special Moves**: 
  - Strongest throw
  - Hardest to knock back
  - Lower jump height due to weight

### Character 15: Shamone
- **Weight**: Light (15)
- **Attack Type**: Melee
- **Missile**: None (melee only, 4-frame lifetime)
- **Special Moves**: 
  - Special upward attack/jump: When attacking, simultaneously jumps upward (11 pixels) while performing melee attack
  - Form switching: Pressing UP switches between Shamone (character 15) and Meth Hound (character 31)
  - Garden protector from Ducks Away
- **Form Switching Details**:
  - Character 15 (Shamone) ↔ Character 31 (Meth Hound)
  - UP button toggles between forms
  - Both forms use same attacks, jumps, and guards
  - Meth Hound shares all gameplay mechanics with Shamone
  - Jumping must be done via enhanced buttons (Genesis/Joy2b+ Button C/II) when playing as Shamone/MethHound

---

## Terminology Standardization

Standardize on "Arena" consistently (not "Level" or "Map"):
- MaxArenaID = 15 (supporting 16 arenas, displayed as "01" through "16")
- Use "Arena Select" not "Level Select"
- Use "SelectedArena" not "SelectedLevel"
