          rem ChaosFight - Source/Routines/BeginFallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Begin Falling Animation

BeginFallingAnimation
          rem Setup routine for Falling In animation.
          rem Sets players in quadrant starting positions and
          rem   initializes state.
          rem
          rem Quadrant positions:
          rem   - Top-left: Player 1 (playerCharacter[0])
          rem   - Top-right: Player 2 (playerCharacter[1])
          rem   - Bottom-left: Player 3 (playerCharacter[2], if active)
          rem   - Bottom-right: Player 4 (playerCharacter[3], if active)
          rem After animation completes, players will be at row 2
          rem   positions
          rem and transition to Game Mode.
          rem Setup routine for Falling In animation - sets players in
          rem quadrant starting positions
          rem
          rem Input: playerCharacter[] (global array) = character selections
          rem        controllerStatus (global) = controller detection
          rem        state
          rem
          rem Output: fallFrame, fallSpeed, fallComplete, activePlayers
          rem initialized,
          rem         screen layout set, COLUBK set, playerX[],
          rem         playerY[] set for active players
          rem
          rem Mutates: fallFrame (set to 0), fallSpeed (set to 2),
          rem fallComplete (set to 0),
          rem         activePlayers (incremented per active player),
          rem         pfrowheight, pfrows (set via SetGameScreenLayout),
          rem         COLUBK (TIA register), playerX[0-3], playerY[0-3]
          rem         (set for active players)
          rem
          rem Called Routines: SetGameScreenLayout (bank7) - sets screen
          rem layout
          rem
          rem Constraints: Must be colocated with DonePlayer1Init,
          rem DonePlayer2Init,
          rem              DonePlayer3Init, DonePlayer4Init (all called
          rem              via goto)
          rem              Called from ChangeGameMode when entering
          rem              falling animation mode
let fallFrame = 0
          rem Initialize animation state
let fallSpeed = 2
let fallComplete = 0
let activePlayers = 0
          
gosub SetGameScreenLayout bank7
          rem Set game screen layout (32×8 for playfield scanning)
          
          COLUBK = ColGray(0)
          rem Set background color
          
          rem Initialize player positions in quadrants
          rem Player 1: Top-left quadrant (unless NO)
if playerCharacter[0] = NoCharacter then DonePlayer1Init
let playerX[0] = 16
let playerY[0] = 8
          rem Top-left X position
let activePlayers = activePlayers + 1
          rem Top-left Y position (near top)
DonePlayer1Init
          rem Player 1 initialization complete (skipped if not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginFallingAnimation
          
          rem Player 2: Top-right quadrant (unless NO)
          
if playerCharacter[1] = NoCharacter then DonePlayer2Init
let playerX[1] = 144
let playerY[1] = 8
          rem Top-right X position
let activePlayers = activePlayers + 1
          rem Top-right Y position (near top)
DonePlayer2Init
          rem Player 2 initialization complete (skipped if not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginFallingAnimation
          
          rem Player 3: Bottom-left quadrant (if Quadtari and not NO)
          
if !(controllerStatus & SetQuadtariDetected) then DonePlayer3Init
if playerCharacter[2] = NoCharacter then DonePlayer3Init
let playerX[2] = 16
let playerY[2] = 80
          rem Bottom-left X position
let activePlayers = activePlayers + 1
          rem Bottom-left Y position (near bottom)
DonePlayer3Init
          rem Player 3 initialization complete (skipped if not in
          rem 4-player mode or not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginFallingAnimation
          
          rem Player 4: Bottom-right quadrant (if Quadtari and not NO)
          
if !(controllerStatus & SetQuadtariDetected) then DonePlayer4Init
if playerCharacter[3] = NoCharacter then DonePlayer4Init
let playerX[3] = 144
let playerY[3] = 80
          rem Bottom-right X position
let activePlayers = activePlayers + 1
          rem Bottom-right Y position (near bottom)
DonePlayer4Init
return
          rem Player 4 initialization complete (skipped if not in
          rem 4-player mode or not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginFallingAnimation
          


