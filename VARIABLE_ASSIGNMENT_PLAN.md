# Variable Reassignment Plan

## Available Memory
- Standard RAM (a-z): 26 bytes (always available)
- SuperChip RAM (var0-var127): 128 bytes
  - ADMIN (pfres=32): var0-var127 used by playfield, NONE available
  - GAME (pfres=8): var96-var127 used by playfield, var0-var95 available

## Variable Categories

### SHARED Variables (used in both contexts - must not conflict)
- Game state, player data, character selection results
- These persist across context switches

### ADMIN Variables (only during title/select screens)
- Character select, level select, preamble, title screen

### GAME Variables (only during gameplay)
- Player positions, health, missiles, physics

## Conflicts Identified

### Standard RAM (a-z) Conflicts:
1. a: FallFrame vs Console7800Detected
2. b: FallSpeed vs ControllerStatus
3. c: FallComplete vs SystemFlags
4. f: PlayersEliminated vs PlayerAttackCooldown
5. i: PauseButtonPrev vs ReadyCount vs MissileActive
6. j: PlayerChar[0] vs Player4AttackCooldown
7. t: AnimationCounter vs SelectedChar3
8. u: CurrentAnimationFrame vs SelectedChar4
9. v: CurrentAnimationSeq vs SelectedLevel
10. w: PlayerSubpixelX vs CharSelectAnimTimer vs MissileVelX
11. x: PlayerSubpixelY vs CharSelectAnimState vs MissileVelY
12. y: PlayerVelocityX vs CharSelectAnimIndex
13. z: PlayerVelocityY vs CharSelectAnimFrame
14. k-n: PlayerDamage conflicts with PlayerChar/PlayerLocked arrays

### SuperChip RAM Conflicts:
1. var0-3: PlayerX vs LevelPreviewData/LevelScrollOffset/etc vs MissileY
2. var4-7: PlayerY vs PreambleTimer/PreambleState/etc
3. var8: PlayerState[0] vs MusicTimer
4. var20-23: PlayerMomentumX vs PlayerMomentumY (both defined but var24+ conflict noted)
5. var24-27: PlayerMomentumY vs playfield conflict
6. var28-35: TitleParade*/PlayersRemaining/GameEndTimer/etc conflicts

## Proposed Reassignment

### SHARED Variables (a-z):
- a: FallFrame
- b: FallSpeed  
- c: FallComplete
- d: ActivePlayers
- e: (reserved for MissileLifetime - GAME only, but dimmed as shared)
- f: PlayersEliminated (GAME only, but needs to persist)
- g: GameState
- h: ColorBWOverride (if not SECAM)
- i: PauseButtonPrev
- j: PlayerChar[0]
- k: PlayerChar[1]
- l: PlayerChar[2]
- m: PlayerChar[3]
- n: PlayerLocked[0]
- o: PlayerLocked[1]
- p: PlayerLocked[2]
- q: PlayerLocked[3]
- r: SelectedChar1
- s: SelectedChar2
- t: SelectedChar3
- u: SelectedChar4
- v: SelectedLevel
- w: PlayerSubpixelX[0-3] (GAME only, but defined in shared section - needs move)
- x: PlayerSubpixelY[0-3] (GAME only)
- y: PlayerVelocityX[0-3] (GAME only)
- z: PlayerVelocityY[0-3] (GAME only)

Missing: Console7800Detected, SystemFlags, ControllerStatus, AnimationCounter, CurrentAnimationFrame, CurrentAnimationSeq

### ADMIN Variables (a-z):
- i: ReadyCount (REDIM)
- w: CharSelectAnimTimer (REDIM)
- x: CharSelectAnimState (REDIM)
- y: CharSelectAnimIndex (REDIM)
- z: CharSelectAnimFrame (REDIM)

ADMIN SuperChip: var0-47 used (all available var space in ADMIN)

### GAME Variables (a-z):
- e: MissileLifetime (REDIM from unused e)
- f: PlayersEliminated
- g: GameState
- h: ColorBWOverride (if not SECAM)
- i: MissileActive (REDIM)
- j: PlayerChar[0]
- k: PlayerChar[1]
- l: PlayerChar[2]
- m: PlayerChar[3]
- n: PlayerLocked[0]
- o: PlayerLocked[1]
- p: PlayerLocked[2]
- q: PlayerLocked[3]
- r: SelectedChar1
- s: SelectedChar2
- t: SelectedChar3
- u: SelectedChar4
- v: SelectedLevel
- w: MissileVelX[0-3] (REDIM) - conflicts with PlayerSubpixelX!
- x: MissileVelY[0-3] (REDIM) - conflicts with PlayerSubpixelY!
- Also need: MissileX[0-3] = a,b,c,d
- Also need: PlayerAttackCooldown = f,g,h,j (but f conflicts!)
- Also need: PlayerDamage = k,l,m,n (but conflicts with PlayerChar/PlayerLocked!)

GAME SuperChip: var0-95 available
- var0-3: PlayerX
- var4-7: PlayerY
- var8-11: PlayerState
- var12-15: PlayerHealth
- var16-19: PlayerRecoveryFrames
- var20-23: PlayerMomentumX
- var24-27: PlayerMomentumY (but conflicts with playfield - comment says we don't use this)
- var28-35: Game state (PlayersRemaining, GameEndTimer, etc.)
- var36-47: Available
- var48-95: Available (but comments say we stay within var0-23 for safety)

## Key Insight
PlayerSubpixelX/Y and PlayerVelocityX/Y are defined as SHARED but are really GAME-only (only used during gameplay). They conflict with ADMIN variables and MissileVelX/Y. They should be moved to GAME context or use different variables.

Similarly, AnimationCounter, CurrentAnimationFrame, CurrentAnimationSeq are defined as SHARED but SelectedChar3/4/Level use the same variables - these might both be needed in ADMIN context for character select.

