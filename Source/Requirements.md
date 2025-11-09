# ChaosFight 25 - Minimum Viable Product Requirements

## Cold Start Initialization

Upon cold start:

- Console detection (2600 vs 7800) runs first, before any code modifies
  $D0/$D1
Then continues into warm start:

- Common and admin vars are cleared
- Hardware registers are set up (TIA colors, audio)
- Controller detection (Mega Drive/Genesis, Joy2b+, or Quadtari) is
  performed
- COLUBK is set to black and remains black throughout

---

## Naming Conventions

- Built-in batariBasic identifiers (temp1-temp6, joy0up, frame, and
  their hardware frenemies) stay lowercase because they were here before
  we moved in.
- User-defined variables flaunt camelCase (`gameState`, `playerX`,
  `playerCharacter[0]`) so we can spot our handiwork instantly.
- Constants, enums, labels, and routines work the PascalCase runway
  (`MaxCharacter`, `ActionStanding`, `LoadCharacterSprite`) to telegraph
  their importance.
- TIA registers (`player0x`, `COLUP0`, `pf0`-`pf2`, etc.) keep their
  canonical lowercase spellings—do not “improve” them.
- Never `dim` a built-in variable; batariBasic already reserved their
  seats and will throw shade if you double-book them.

Stick to these rules and the codebase reads like a chic gossip column
instead of an anonymized police report.

---

## Game Reset Behavior

In any mode, pressing Game Reset causes an instant hard reboot:

- Calls WarmStart to clear all vars and reinitialize hardware registers
- System state is completely reset

---

## Toolchain Maintenance

- Common Lisp tooling (e.g., SkylineTool) may not be modified unless the
  change ships with new or updated automated tests that cover the
  behaviour being altered.
- Run the full existing test suite and the newly added tests locally
  before opening a review; include the command output in the change
  notes.
- If test infrastructure is missing for the affected component, build it
  first—tooling changes without executable verification are blocked.

---

## Admin Mode Controller Redetection

In any admin modes (title, preambles, arena select):

- Pressing Game Select causes controller redetection
- Toggling Color/B&W switch causes controller redetection
- Pause button (on 7800) causes controller redetection

---

## Publisher Prelude (formerly Publisher Preamble)

Displays two 48×42 px images with row-by-row color:

- AtariAge Logo
- AtariAge Text
- Both centered on black screen

Plays "Atari Today" song once. Upon song completion OR any player button
press (up to 4 players), advance to Author Prelude.

---

## Author Prelude (formerly Author Preamble)

Displays "BRP Signature" graphic ("BRP.xcf").
Plays "Interworldly" jingle once. Upon jingle completion OR any player
button press, advance to Title Screen.

---

## Title Screen

- Chaos Fight 25 logo appears near top 1/3 of screen, centered
  horizontally
- Copyright graphic appears below logo after 2 seconds.
- After 5 seconds, copyright graphic vanishes and "parade" begins
- Character Parade:
  - Without Quadtari: 2 characters at a time (alternating as one exits,
    another enters)
  - With Quadtari: 4 characters (generally 3, sometimes 4 on screen)
  - Characters walk from left edge to center, perform attack animation
    once, walk off right edge
- Title song "Chaotica" repeats
- After 3 minutes, jump to Attract mode
- Any player button press transitions to Character Select

### Attract Mode

Attract mode forms an endless wait loop. For now, Attract mode handler
simply jumps back to Publisher Prelude screen.

---

## Character Select

### Overview

Players select their fighters from 16 available characters (0-15).
Supports 2-player (standard ports) and 4-player (Quadtari adapter)
modes.
Once all active players have locked in their selections, proceed to
Arena Select.

Players 2 (and if present) 3 & 4 start "locked in" to "CPU" and "NO" and
"NO" and unlock on any action.

### Controller Support

- **2-player mode**: Left port (Player 1), Right port (Player 2)
- **4-player mode (Quadtari detected)**:
  - Even frames: Left port = Player 1, Right port = Player 2
  - Odd frames: Left port = Player 3, Right port = Player 4
- Controller detection runs on entry to Character Select screen

### Input Handling

- **Left/Right**: Cycle through 16 characters (0-15), wraps from 15→0 or
  0→15
  (but when wrapping, presents "?" (Random) and either "CPU" or "NO"
  (Player
  2, depending on player 3/4 state) or "NO" (player 3 or 4). Player 1
  has
  only "?" and the 16 characters (NumCharacters)

- **Fire/B/I button**: Lock in current character selection
- **Up**: Unlock current selection (returns to browsing)
- **Down**: Hold to prepare for handicapping. Character shows
  "recovering
  from a hard fall" animation while held.

- **Down + Fire/B/I button**: Lock in with handicap (75% health instead
  of
  100%; character remains in "recovering from a hard fall" state
  visually

### Character Selection States

- **playerCharacter[0-3]**: Current character index being browsed (0-15,
  or 255 for "NO")

Player 1 options: ? or 0 ↔ MaxCharacterID

Player 3/4 options: NO or ? or 0 ↔ MaxCharacterID

Player 2: ? or 0 ↔ MaxCharacterID and

- if either of Player 3 or Player 4 is not "NO" then "NO" is an option
- otherwise (no player 3/4) then "CPU" is the other option

- **playerLocked[0-3]**: Lock state:
  - Must use enumerated constants
  - 0 = Unlocked (still browsing) = PlayerLockedUnlocked
  - 1 = Locked (normal health, 100%) = PlayerLockedNormal
  - 2 = handicap mode, 75% health = PlayerHandicapped
  - 3 = Locked in handicap mode = PlayerLockedNormal | PlayerHandicapped

### Visual Display

- Display character preview with idle animation
- Show lock status for each player --- if locked, character color is
  player
  color; if unlocked, character color is white.

- Display no sprite (blank) for players 3/4 if no Quadtari detected
- Display character sprites in screen quadrants

### Progression Logic

- All players must lock in some selection to proceed, but player 2 (and
  3/4,
  when present) start locked, so player must take some action to switch
  their characters from "CPU" or "NO" setting.

- "?" characters auto-select random character (once locked in)
- "CPU" selects a random character (when everyone else is locked in)
- Once all players locked in, transition to Arena Select

### Sound Effects

- Menu navigation sound (SoundMenuNavigate) on left/right movement
- Menu selection sound (SoundMenuSelect) on lock/unlock
- No background music (some admin screens may use music, but Character
  Select
  uses sound effects instead)

### Special Cases

- All navigation should use menu sound effects, not gameplay sounds

---

## Arena Select

- Player 1 only can use left/right to cycle through:
  - Decimal numbers " 1" up to MaxArenaID + 1 (currently 15, so 15+1=16,
    displayed as " 1" through "16")
  - Then "??" (two question marks) for random arena
  - Then back to " 1" (wraps)
  - Can go in reverse (" 1" down to "??" down to "16")
- Player 1 locks in selection by pressing Fire/B/I button
- Special case: If any player holds Fire/B/I for one full second, return
  to Character Select
- Game Select switch pressed: return to Character Select
- Up to four locked-in player graphics remain on screen (blank if no
  player
  or locked in at "NO")

- "CPU" or "?" already have random character selected
- Digits appear in center, white-on-black, use virtual sprites 5-6

---

## Falling In Animation

- Four player graphics move from their respective quadrants (unless set
  to "NO")
- Move toward their "row 2" starting positions
  - "Row 2" refers to the height of one row of playfield pixel data at
    32×8 display
  - Start at top of screen and continue downwards until finding clear
    pixels wide enough for double-width player
- Characters are positioned there
- "Nudged" down if there are playfield pixels near their fixed starting
  point
- Re-initialize for Game Mode and switch to it

Note: Bernie can use the same "high as I can be without being in a
brick" logic when he falls off the screen and resets at the top.

---

## Game Mode

### Initialization

- Call BeginGameLoop before entering Game Mode:
  - Initialize player positions from Falling In animation final
    positions
  - Set player facing directions (alternating: P1 right, P2 left, P3
    right, P4 left)
  - Apply handicap if selected (playerLocked[0-3] &
    PlayerCharacterHandicapped → 75% health, else 100%)
  - Initialize player states, timers, momentum
  - Load character types from playerCharacter[0-3] array
  - Initialize missiles and projectiles
  - Set frame counter and game state
  - Load arena data

### Playfield and Colors

- Set Playfield and pfcolors:
  - **Color mode + NTSC/PAL**: color-per-row (different colors for each
    playfield row)
  - **B&W or SECAM**: white COLUPF (single color for entire playfield)
- Playfield layout: 32×8 pixel data (mirrored 16×8)
- Color data defined per arena in area data files (pfcolors)

### Game Cycle (Per Frame)

1. **Console Switch Handling**: Check select, reset, color/B&W/pause,
   right
   difficulty (if CPU running player 2)

2. **Player Input**: Handle all player inputs (with Quadtari
   multiplexing if 4-player)
   **CPU Input**: Allow CPU players to contribute by controlling their
   own
   sprite

3. **Animation System**: Update character animations (10fps animation
   rate, 8-frame sequences)
4. **Movement System**: Update player movement (full 60fps movement
   rate)
5. **Physics**: Apply gravity (character-specific, some characters
   ignore gravity)
6. **Momentum & Recovery**: Apply momentum from attacks, update
   recovery/hitstun frames
7. **Special Movement**: Apply character-specific movement (Bernie
   screen wrap, Frooty flight, etc.)
8. **Boundary Collisions**: Check screen edges, wrap/stop as appropriate
9. **Player Collisions**: Check multi-player collisions, apply
   separation logic
10. **Player Eliminations**: Check if any players health reached 0, mark
    as eliminated
11. **Attack Cooldowns**: Update attack cooldown timers
12. **Missile System**: Update all active missiles (movement, gravity,
    lifetime)
13. **Missile Collisions**: Check missiles vs players, missiles vs
    playfield
14. **Sprite Positioning**: Set hardware sprite positions for all
    players
15. **Sprite Graphics**: Load character sprites based on animation state
    and facing
16. **Health Display**: Show health bars, flash sprites when health is
    low
17. **Screen Draw**: Render complete frame

### Player Actions

- **Walk Left/Right**: Horizontal movement based on character weight
- **Jump**: Vertical movement, character-specific jump heights based on
  weight
- **Guard**: Block incoming attacks, reduces damage (stick Down)
- **Attack**: Melee or ranged attacks based on character type (Fire/B/I
  button)
- **Special Moves**: Character-specific abilities (see Character
  Behaviors section)
- Button C/II is Jump, so is stick Up.
- Button III toggles game paused state, so does Game Select.

### Physics Systems

- **Gravity**: Affects most characters (Frooty and Dragon of Storms
  ignore gravity - can fly)
- **Weight Effects**:
  - Heavier characters: Lower jumps, slower movement, more knockback
    resistance
  - Lighter characters: Higher jumps, faster movement, less knockback
    resistance
- **Momentum**: Horizontal and vertical momentum from attacks,
  knockback, collisions
- **Recovery/Hitstun**: Frames of vulnerability after being hit

### Combat System

- **Melee Attacks**: Close-range attacks with character-specific ranges
- **Ranged Attacks**: Projectile attacks with character-specific
  properties
- **Hit Detection**: AABB (axis-aligned bounding box) collision
  detection
- **Knockback**: Pushes players based on attack force and weight
  difference
- **Damage**: Character-specific base damage modified by weight, attack
  type

#### Damage Application Process

1. **Hurt Animation**: Player enters the hurt state with knockback
   applied
2. **Recovery Frames**: Player enters recovery frames count (damage / 2,
   clamped 10-30 frames)
3. **Color Dimming**: Player color dims during recovery (or magenta on
   SECAM TV standard)
4. **Health Check**:
   - If player health ≥ damage amount: Decrement health by damage amount
   - If player health < damage amount: Player dies (instantly vanishes)
5. **Death Handling**: Dead players instantly vanish (sprite hidden,
   elimination effects triggered)

### Missile System

- **Missile Types**: Character-specific projectiles (size, trajectory,
  lifetime)
- **Movement**: Horizontal, vertical, or ballistic arcs
- **Collision**: Hit players, background, or both based on missile flags
- **Multiplexing**: In 4-player mode, 2 hardware missiles shared via
  frame multiplexing
  - Even frames: missile0 = Participant 1, missile1 = Participant 2
  - Odd frames: missile0 = Participant 3, missile1 = Participant 4
  - **No blank missiles**: Only switches to missiles that are actually
    active (no visual artifacts)
  - **Separate heights**: Each player's missile height is set correctly
    when multiplexing (P1/P3 and P2/P4 can have different heights)

#### Character Attack Types and Missile Dimensions

- **Bernie**: Melee only - "Ground Thump" area-of-effect attack hits
  both left and right simultaneously, shoving enemies away rapidly (no
  missile)
- **Curler**: Ranged - 4×4 pixel wide, tall ground-based projectile
- **Dragon of Storms**: Ranged - 2×2 pixel standard projectile with
  ballistic arc (gravity)
- **Zoe Ryen**: Ranged - 4×1 pixel wide, low-height projectile
- **Fat Tony**: Ranged - 4×1 pixel wide, low-height projectile
- **Megax**: Melee - Uses missile to decorate melee attack (fire
  breath). Missile never moves.
- **Harpy**: Melee (diagonal swoop, special case) - No missile sprite,
  character movement IS the attack
- **Frooty**: Ranged - 1×1 pixel narrow projectile (magical sparkles)
- **Other characters**: Melee attacks only (no projectiles)

### Missile Spawn Offsets

Per-character missile spawn offsets are defined in
`CharacterDefinitions.bas`:

- `CharacterMissileSpawnOffsetRight[]` – pixels added to `playerX` when
  the character faces right
- `CharacterMissileSpawnOffsetLeft[]` – pixels added to `playerX` when
  the character faces left (values that represent negative offsets use
  8-bit two’s complement, e.g. `251` = −5)
- `CharacterMissileEmissionHeights[]` – vertical offset (in pixels)
  added to `playerY`

| Character | Facing Right Offset | Facing Left Offset | Vertical Offset | Notes |
|-----------|--------------------:|-------------------:|----------------:|-------|
| Bernie (0) | — | — | — | Melee only |
| Curler (1) | +17 | −5 | +12 | Stone spawns with 1px horizontal gap, bottoms aligned |
| Dragon of Storms (2) | +18 | −4 | +4 | Fireball spawns 2px ahead, 4px below sprite top |
| Zoe Ryen (3) | +18 | −6 | +7 | Laser originates 2px ahead at shoulder height |
| Fat Tony (4) | +18 | −6 | +7 | Magic ray (shares offsets with Zoe, tuned independently) |
| Megax (5) | +17 | −5 | +4 | Fire breath anchored near mouth (stationary) |
| Harpy (6) | — | — | — | No missile |
| Knight Guy (7) | +8 | +8 | +10 | Sword swing handled via `HandleKnightGuyMissile` |
| Frooty (8) | +20 | −5 | +6 | Sparkle projectile with 4px horizontal gap |
| Nefertem (9) | — | — | — | No missile |
| Ninjish Guy (10) | +20 | −6 | +9 | Shuriken spawns 4px ahead |
| Pork Chop (11) | — | — | — | Melee only |
| Radish Goblin (12) | — | — | — | Melee only |
| Robo Tito (13) | +6 | +6 | +16 | Trunk drops vertically |
| Ursulo (14) | — | — | — | Melee only |
| Shamone (15) | — | — | — | Melee only |

Knight Guy's sword starts at −2px overlap and animates out to +1px gap,
then back.

Robo Tito's trunk occupies pixels x=6–9 beneath sprite, ending 1px above
ground.new

These offsets guarantee that missiles spawn at artist-authored
positions; adjusting a single character’s values will not affect others.

### Game End Condition

- Game ends when only one player remains (all others eliminated)
- Eliminated players: Health reached 0, marked in playersEliminated bit
  flags
- Transition to Winner Screen after last elimination

### Sound Effects (During Gameplay)

- Attack hit sounds
- Guard block sounds
- Jump sounds
- Player elimination sounds
- Landing sounds (safe landing vs. damaging landing)
- No background music (gameplay uses SFX only)

### Console Switches (During Game Mode)

- **Game Reset**: Instant hard reboot (calls WarmStart)
- **Game Select**: toggles pause
- **Color/B&W Switch**: in "Color" position (PAL/NTSC only) pfcolors are
  per-row, in "B&W" position the arena is white-on-black. Does not
  affect
  players' colors.

- **Pause Input**: Toggle pause state
  - **Select Switch**: Pressing Select toggles pause on/off
  - **Joy2b+ Button III**: Pressing Button III on Joy2b+ controllers
    (left or right port) toggles pause on/off
- **7800 Pause Button Behavior**:
  - On 7800, the pause button is a momentary contact switch that
    occupies the same hardware pin as the 2600 Color/B&W switch
  - On 2600: Color/B&W switch is binary (color position vs B&W position)
    - determines if playfield uses color-per-row
    or single-white color

  - On 7800: Pause button is momentary toggle - each press toggles
    between White-only mode and Color-Per-Row (pfcolor) mode
  - This affects ONLY the playfield color rendering, not pause state
  - Uses colorBWOverride variable to track toggle state

---

## Winner Screen

- Display winner announcement
- Winner acknowledges victory by pressing a button
- Return to title screen after acknowledgment

- If a two-player game, only the winner appears.
- Music plays the winner's character theme song (regardless of human or
  CPU).

- If a 3- or 4-player game, all but the last player
  appear. The winner (last man standing) appears in the top-center.
  The runner-up (last eliminated) appears at the mid-left.
  The second runner-up (next-to-last eliminated) appears at the
  mid-right.
  The last place (if 4 players) appears at the bottom-left.

- Playfield pattern represents "steps" upon which the
  characters are "standing"

---

## Character Behaviors

### Character Weight Table

All weights use a logarithmic scale mapping real-world weights to game
units (5-100 range):

| Character | Real-World Weight | Game Unit | Notes |
|-----------|------------------|-----------|-------|
| Bernie | 10 lbs (4.5 kg) | 5 | Lightest character |
| Curler | 190 lbs (86.2 kg) | 53 | Medium weight |
| Dragon of Storms | 3500 lbs (1588 kg) | 100 | Heaviest (rhino) |
| Zoe Ryen | 145 lbs (65.8 kg) | 48 | Medium-light |
| Fat Tony | 240 lbs (108.9 kg) | 57 | Heavy |
| Megax | 3500 lbs (1588 kg) | 100 | Heaviest (rhino) |
| Harpy | 30 lbs (13.6 kg) | 23 | Light |
| Knight Guy | 250 lbs (113.4 kg) | 57 | Heavy (with armor) |
| Frooty | 120 lbs (54.4 kg) | 45 | Medium-light |
| Nefertem | 440 lbs (199.6 kg) | 66 | Very heavy (lion) |
| Ninjish Guy | 130 lbs (59.0 kg) | 47 | Medium |
| Pork Chop | 250 lbs (113.4 kg) | 57 | Heavy |
| Radish Goblin | 50 lbs (22.7 kg) | 31 | Light |
| Robo Tito | 300 lbs (136.1 kg) | 60 | Very heavy (dumpster) |
| Ursulo | 220 lbs (100 kg) | 55 | Medium-heavy (1.67m tall walking polar bear) |
| Shamone | 65 lbs (29.5 kg) | 35 | Medium-light |

**Weight Effects**:

- Jump height (higher weight = lower jump)
- Movement speed (higher weight = slower)
- Momentum (higher weight = more momentum when moving)
- Impact resistance (higher weight = less knocked back)
- Melee force (higher weight = more damage/knockback to opponents)

### Character 0: Bernie

- **Weight**: 10 lbs (4.5 kg) - Game Unit: 5
- **Attack Type**: Melee (hits BOTH DIRECTIONS - dual-direction AOE)
- **Missile**: None (melee only, 4-frame lifetime for visual)
- **Special Moves**:
  - No jumping
  - **Fall abilities**:
    - Wraps from bottom to top of screen when falling off
    - Fall damage immunity
    - Can fall through 1-row floors when pressing UP (used for platform
      navigation)
    - Uses "high as I can be without being in a brick" logic when
      resetting at top
  - Ground thump affects enemies to either side (dual-direction AOE
    attack)

### Character 1: Curling Sweeper

- **Weight**: 190 lbs (86.2 kg) - Game Unit: 53
- **Attack Type**: Ranged
- **Missile**: 4×2 pixels curling stone (from character's feet)
- **Missile Properties**:
  - Emission height: 14 pixels (from feet)
  - Momentum X: 6 pixels/frame (horizontal)
  - Momentum Y: 0 (slides along ground)
  - Flags: HitBackground|HitPlayer|Gravity|Bounce|Friction (ice physics)
  - Lifetime: 255 frames (until collision)
- **Special Moves**:
  - **Ice physics**: Curling stone slides along ground level with ice
    physics (smooth sliding motion)
  - Great for hitting low targets
  - Projectile spawns at character's feet and slides horizontally across
    floor

### Character 2: Dragon of Storms

- **Weight**: 3500 lbs (1588 kg) - Game Unit: 100
- **Attack Type**: Ranged
- **Missile**: 2×2 pixels, ballistic arc (parabolic trajectory)
- **Missile Properties**:
  - Emission height: 4 pixels
  - Momentum X: 4 pixels/frame
  - Momentum Y: -4 pixels/frame (upward arc)
  - Flags: HitBackground
  - Lifetime: 255 frames (until collision)
- **Special Moves**:
  - **Flying character**: No gravity, can fly freely (similar to Frooty)
  - Projectile travels in parabolic arc, excellent for hitting enemies
    at different heights
  - Aerial mobility with full flight control

### Character 3: Zoe Ryen

- **Weight**: 145 lbs (65.8 kg) - Game Unit: 48
- **Attack Type**: Ranged
- **Missile**: Laser blaster (2×2 pixels, horizontal arrowshot)
- **Missile Properties**:
  - Emission height: 4 pixels
  - Momentum X: 6 pixels/frame (horizontal)
  - Momentum Y: 0 (horizontal only)
  - Flags: None
  - Lifetime: 255 frames (until collision)
- **Special Moves**:
  - **Laser blaster**: Fires long, thin laser that travels horizontally
    across entire screen
  - High jumps
  - Fast horizontal laser projectile for long-range combat

### Character 4: Fat Tony

- **Weight**: 240 lbs (108.9 kg) - Game Unit: 57
- **Attack Type**: Ranged
- **Missile**: Magic ring lasers (2×2 pixels, arrowshot)
- **Missile Properties**:
  - Emission height: 3 pixels
  - Momentum X: 0 pixels/frame (stationary spawn)
  - Momentum Y: 0
  - Flags: None
  - Lifetime: 255 frames (until collision)
  - Force: 4
- **Special Moves**:
  - **Laser ring**: Magic ring shoots laser projectiles
  - Geography expert
  - Magic ring wielder (laser ring weapon)

### Character 5: Megax

- **Weight**: 3500 lbs (1588 kg) - Game Unit: 100
- **Attack Type**: Ranged
- **Missile**: Fire breath (4×2 pixels, ballistic arc)
- **Missile Properties**:
  - Emission height: 4 pixels (from mouth)
  - Momentum X: 0 pixels/frame
  - Momentum Y: 0
  - Flags: None
  - Lifetime: 4 frames (brief visual)
- **Special Moves**: Giant monster-eating powerhouse, biggest and most
  powerful known, breathes fire

### Character 6: Harpy

- **Weight**: 30 lbs (13.6 kg) - Game Unit: 23
- **Attack Type**: Ranged (diagonal downward swoop)
- **Missile**: 0×0 (uses character sprite during swoop - no visible
  missile)
- **Missile Properties**:
  - Emission height: 4 pixels
  - Momentum X: 5 pixels/frame
  - Momentum Y: 4 pixels/frame (downward)
  - Flags: None
  - Lifetime: 5 frames (swoop duration)
- **Special Moves**:
  - **Flight pattern**: Can "fly" by repeatedly pressing UP (flap to
    maintain altitude)
  - **Attack pattern**: Swoop attack - moves diagonally down while
    attacking (5-frame lifetime)
  - Diagonal downward swoop combines movement and attack in single
    motion
  - Character sprite itself becomes the attack during swoop animation

### Character 7: Knight Guy

- **Weight**: 250 lbs (113.4 kg) - Game Unit: 57
- **Attack Type**: Melee
- **Missile**: None (melee only, 6-frame lifetime - longest melee
  duration)
- **Special Moves**:
  - **Sword**: Melee weapon is a sword
  - Armored fighter with powerful sword attacks
  - Longest melee attack duration (6 frames)

### Character 8: Frooty

- **Weight**: 120 lbs (54.4 kg) - Game Unit: 45
- **Attack Type**: Ranged
- **Missile**: 2×2 pixels, ballistic arc (lollipop sparkle)
- **Missile Properties**:
  - Emission height: 3 pixels
  - Momentum X: 6 pixels/frame
  - Momentum Y: -5 pixels/frame (upward arc)
  - Flags: HitBackground
  - Lifetime: 255 frames (until collision)
- **Special Moves**:
  - **Flying character**: FREE FLIGHT - Use UP/DOWN to move vertically
    (no guard action)
  - No gravity, full vertical flight control
  - Cannot guard (pressing DOWN makes her fly down instead)
  - Magical sparkles from lollipop weapon
  - Complete aerial mobility like Dragon of Storms

### Character 9: Nefertem

- **Weight**: 440 lbs (199.6 kg) - Game Unit: 66
- **Attack Type**: Melee
- **Missile**: None (melee only, 5-frame lifetime)
- **Special Moves**: Loyalist to the High Council, feline reflexes

### Character 10: Ninjish Guy

- **Weight**: 130 lbs (59.0 kg) - Game Unit: 47
- **Attack Type**: Melee
- **Missile**: None (melee only, 4-frame lifetime)
- **Special Moves**:
  - Highest jumps
  - Fastest movement
  - 50% fall damage reduction
  - Ninja mobility with melee attacks

### Character 11: Pork Chop

- **Weight**: 250 lbs (113.4 kg) - Game Unit: 57
- **Attack Type**: Melee
- **Missile**: None (melee only, 4-frame lifetime)
- **Special Moves**: Standard heavy melee fighter

### Character 12: Radish Goblin

- **Weight**: 50 lbs (22.7 kg) - Game Unit: 31
- **Attack Type**: Melee (bouncing bite attacks)
- **Missile**: None (melee only, 3-frame lifetime)
- **Special Moves**:
  - Highest jumps
  - Fastest movement
  - Lowest health
  - Bounces when moving

### Character 13: Robo Tito

- **Weight**: 300 lbs (136.1 kg) - Game Unit: 60
- **Attack Type**: Melee
- **Missile**: None (melee only, 5-frame lifetime)
- **Special Moves**:
  - No jumping
  - Stretches vertically to ceiling (press UP to stretch and grab
    ceiling)
  - Can move left/right along ceiling
  - Press DOWN to return to floor
  - Fall damage immunity
  - Vulnerable entire length to collisions

### Character 14: Ursulo

- **Weight**: 220 lbs (100 kg) - Game Unit: 55
- **Attack Type**: Melee (claw swipe)
- **Missile**: None (melee only, 5-frame lifetime)
- **Missile Properties**:
  - No missile (0×0) - melee attack uses character sprite
  - Changed from ranged to melee (claw swipe attack)
- **Special Moves**:
  - Strongest throw
  - Melee claw swipe attack

### Character 15: Shamone

- **Weight**: 65 lbs (29.5 kg) - Game Unit: 35
- **Attack Type**: Melee
- **Missile**: None (melee only, 4-frame lifetime)
- **Special Moves**:
  - Special upward attack/jump: When attacking, simultaneously jumps
    upward while performing
    mel\e'e attack

  - Form switching: Pressing UP switches between Shamone (character 15)
    and Meth Hound (character 31)
  - Garden protector from Ducks Away
- **Form Switching Details**:
  - Character 15 (Shamone) ↔ Character 31 (Meth Hound)
  - UP button toggles between forms
  - Both forms use same attacks, jumps, and guards
  - Meth Hound shares all gameplay mechanics with Shamone
  - Jumping must be done via attack buttons (Fire/B/I) when playing as
    Shamone/MethHound

---

## Terminology Standardization

Standardize on "Arena" consistently (not "Level" or "Map"):

- MaxArenaID = 15 (supporting 16 arenas, displayed as "01" through "16")
- Use "Arena Select" not "Level Select"
- Use "SelectedArena" not "SelectedLevel"

## Memory

- Reserve 1 full bank for sound effects
- Reserve 1 full bank for music
- Bank 1 now hosts the music system (StartMusic/UpdateMusic, song tables
  for
  songs 4-28, build info)

- Bank 15 holds the low-ID themes (songs 0-3: Bernie, EXO, OCascadia,
  Revontuli) alongside the shared sound-effect tables

- Bank 16 carries MainLoop, drawscreen, ArenaLoader, FontRendering, and
  the
  `game` entry point because the multisprite kernel insists the hot loop
  lives
  in the final bank

- Reserve 4 banks for character art (2,3,4,5)
- Reserve slots for 32 characters and 32 arenas

## SCRAM Variable Access Rules

SuperChip RAM (SCRAM) variables have separate read (`r000`-`r127`) and
write (`w000`-`w127`) ports that map to the same physical 128-byte RAM.
To ensure correct operation and code clarity:

- **MUST use `_R` suffix for all read operations** (e.g.,
  `selectedArena_R`)
- **MUST use `_W` suffix for all write operations** (e.g.,
  `selectedArena_W`)
- **Convenience aliases are NOT permitted** - do not declare `dim
  selectedArena = w014` without `_R`/`_W` suffix
- All SCRAM variable declarations must include both `_R` and `_W`
  variants
- Code must explicitly use the appropriate port for each operation

**Rationale**: SCRAM has separate read/write ports. Using convenience
aliases makes it unclear which port is accessed, which can lead to bugs
where writes are attempted via read ports or reads via write ports.
Explicit `_R`/`_W` usage makes the code intent clear and prevents
errors.
