ArenaSelect1
ArenaSelect1Loop
          rem
          rem ChaosFight - Source/Routines/ArenaSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena Select - Per-frame Loop
          rem Handles the arena carousel (1-32 plus random) each frame.
          rem Called from MainLoop when gameMode = ModeArenaSelect.
          rem BeginArenaSelect performs setup; this routine processes one frame then returns.
          rem
          rem Input: selectedArena_R (global SCRAM) = current arena
          rem        controllerStatus (global) = controller detection state
          rem        fireHoldTimer_R (global SCRAM) = fire button hold
          rem        timer
          rem        joy0fire, joy1fire (hardware) = fire button states
          rem        joy0left, joy0right (hardware) = navigation button states
          rem        switchselect (hardware) = game select switch
          rem        INPT0, INPT2 (hardware) = Quadtari fire button states
          rem        playerCharacter[] (global array) = character selections
          rem        frame (global) = frame counter
          rem
          rem Output: Dispatches to ReturnToCharacterSelect, StartGame1, or returns
          rem
          rem Mutates: selectedArena_W (updated via navigation),
          rem fireHoldTimer_W (incremented/reset),
          rem         gameMode (set to ModeCharacterSelect or ModeGame)
          rem
          rem Called Routines: ArenaSelectUpdateAnimations - accesses
          rem character selections, frame,
          rem   ArenaSelectDrawCharacters - accesses character
          rem   selections, player positions,
          rem   CheckQuadtariFireHold - accesses INPT0, INPT2,
          rem   PlaySoundEffect (bank15) - plays navigation/selection
          rem   sounds,
          rem   DrawDigit (bank16) - draws arena number digits,
          rem   ChangeGameMode (bank14) - accesses game mode state
          rem
          rem Constraints: Must be colocated with ArenaSelect1Loop,
          rem CheckQuadtariFireHold,
          rem              ReturnToCharacterSelect, StartGame1,
          rem              ArenaSelectLeft, ArenaSelectRight,
          rem              DisplayRandomArena, ArenaSelectConfirm (all
          rem              called via goto)
          rem              Entry point for arena select mode (called
          rem              from MainLoop)
          gosub ArenaSelectUpdateAnimations : rem Update character idle animations
          gosub ArenaSelectDrawCharacters : rem Draw locked-in player characters
          if switchselect then ReturnToCharacterSelect : rem Check Game Select switch - return to Character Select
          
          rem Check fire button hold detection (1 second to return to
          let temp1 = 0 : rem   Character Select)
          if joy0fire then let temp1 = 1 : rem Check Player 1 fire button
          if joy1fire then let temp1 = 1 : rem Check Player 2 fire button
          if controllerStatus & SetQuadtariDetected then CheckQuadtariFireHold : rem Check Quadtari players (3 & 4) if active
          
          if temp1 then goto IncrementFireHold : rem If fire button held, increment timer
          let fireHoldTimer_W = 0 : rem Fire released, reset timer
          goto FireHoldCheckDone
          
IncrementFireHold
          let temp2 = fireHoldTimer_R
          let temp2 = temp2 + 1
          let fireHoldTimer_W = temp2
          if temp2 >= 60 then goto ReturnToCharacterSelect : rem 60 frames = 1 second @ 60fps
FireHoldCheckDone
          
          if joy0left then ArenaSelectLeft : rem Handle LEFT/RIGHT navigation for arena selection
          goto ArenaSelectSkipLeft
ArenaSelectLeft
          rem Decrement arena, wrap from 0 to RandomArena (255)
          if selectedArena_R = 0 then let selectedArena_W = RandomArena : goto ArenaSelectLeftSound
          if selectedArena_R = RandomArena then let selectedArena_W = MaxArenaID : goto ArenaSelectLeftSound
          let temp2 = selectedArena_R
          let temp2 = temp2 - 1
          let selectedArena_W = temp2
ArenaSelectLeftSound
          let temp1 = SoundMenuNavigate : rem Play navigation sound
          gosub PlaySoundEffect bank15
ArenaSelectSkipLeft
          
          if joy0right then ArenaSelectRight
          goto ArenaSelectSkipRight
ArenaSelectRight
          rem Increment arena, wrap from MaxArenaID to 0, then to
          if selectedArena_R = MaxArenaID then let selectedArena_W = RandomArena : goto ArenaSelectRightSound : rem RandomArena
          if selectedArena_R = RandomArena then let selectedArena_W = 0 : goto ArenaSelectRightSound
          let temp2 = selectedArena_R
          let temp2 = temp2 + 1
          let selectedArena_W = temp2
          if selectedArena_R > MaxArenaID && selectedArena_R < RandomArena then let selectedArena_W = 0 : rem Wrap from 255 to 0 if needed
ArenaSelectRightSound
          let temp1 = SoundMenuNavigate : rem Play navigation sound
          gosub PlaySoundEffect bank15
ArenaSelectSkipRight
          
          rem Display arena number ( 1-32) or ?? (random)
          rem Display using player4 (tens digit) and player5 (ones
          rem   digit)
          rem Position: center of screen (X=80 for tens, X=88 for ones,
          rem   Y=20)
          rem Note: Tens digit only shown for arenas 10-32 (tensDigit >
          if selectedArena_R = RandomArena then DisplayRandomArena : rem   0)
          
          rem Display arena number (selectedArena + 1 = 1-32)
          rem Convert to two-digit display: tens and ones
          rem Supports up to 32 arenas (tens digit: blank for 1-9, 1 for
          let temp1 = selectedArena_R + 1 : rem   10-19, 2 for 20-29, 3 for 30-32)
          rem arenaNumber = arena number (1-32)
          let temp2 = temp1 / 10 : rem Calculate tens digit
          rem Calculate ones digit using optimized assembly
          asm
            lda temp2
            sta temp3
            asl
            asl
            asl
            clc
            adc temp3
            asl
            sta temp3
end
          let temp4 = temp1 - temp3 : rem multiplier = tensDigit * 10
          rem onesDigit = ones digit (0-9)
          
          rem Draw tens digit (player4) - only if tensDigit > 0 (for
          if temp2 > 0 then DrawTensDigit : rem   arenas 10-32)
          goto DoneTensDigit
DrawTensDigit
          let temp1 = temp2
          let temp2 = 80
          let temp3 = 20
          let temp4 = ColGrey(14)
          let temp5 = 4
          rem Use player4 for tens digit
          gosub DrawDigit bank16
DoneTensDigit
          
          let temp1 = temp4 : rem Draw ones digit (player5)
          let temp2 = 88
          let temp5 = 5
          rem Use player5 for ones digit
          gosub DrawDigit bank16
          
          goto DisplayDone
          
DisplayRandomArena
          rem Display ?? for random arena
          rem Use player4 and player5 for two question marks
          let temp1 = 10 : rem Question mark is digit 10 (hex A) in font
          let temp2 = 80 : rem Question mark digit
          let temp3 = 20 : rem X position for first ?
          let temp4 = ColGrey(14) : rem Y position
          let temp5 = 4 : rem White
          rem Use player4
          gosub DrawDigit bank16
          
          let temp2 = 88 : rem Second question mark
          let temp5 = 5 : rem X position for second ?
          rem Use player5
          gosub DrawDigit bank16
          
DisplayDone
          
          if joy0fire then ArenaSelectConfirm : rem Handle fire button press (confirm selection, start game)
          goto ArenaSelectSkipConfirm
ArenaSelectConfirm
          let temp1 = SoundMenuSelect : rem Play selection sound
          gosub PlaySoundEffect bank15
          goto StartGame1 : rem tail call
ArenaSelectSkipConfirm
          
          rem drawscreen called by MainLoop
          return
          goto ArenaSelect1Loop

CheckQuadtariFireHold
          rem Check Player 3 and 4 fire buttons (Quadtari)
          rem
          rem Input: INPT0 (hardware) = Player 3 fire button state
          rem        INPT2 (hardware) = Player 4 fire button state
          rem
          rem Output: temp1 = 1 if any Quadtari fire button pressed, 0
          rem otherwise
          rem
          rem Mutates: temp1 (fire pressed flag)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with ArenaSelect1 (called via goto)
          if !INPT0{7} then let temp1 = 1 : rem Check Player 3 and 4 fire buttons (Quadtari)
          if !INPT2{7} then let temp1 = 1 : rem Player 3 fire button (left port, odd frame)
          rem Player 4 fire button (right port, odd frame)
          return

ReturnToCharacterSelect
          rem Return to Character Select screen
          rem
          rem Input: None (called from ArenaSelect1)
          rem
          rem Output: gameMode set to ModeCharacterSelect,
          rem ChangeGameMode called
          rem
          rem Mutates: fireHoldTimer_W (reset to 0), gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          let fireHoldTimer_W = 0 : rem Constraints: Must be colocated with ArenaSelect1
          let gameMode = ModeCharacterSelect
          gosub ChangeGameMode bank14
          return

StartGame1
          rem Start game with selected arena
          rem
          rem Input: None (called from ArenaSelect1)
          rem
          rem Output: gameMode set to ModeGame, ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          let gameMode = ModeGame : rem Constraints: Must be colocated with ArenaSelect1
          gosub ChangeGameMode bank14
          return

          rem
          rem Character Display And Animation
          
ArenaSelectUpdateAnimations
          rem Update idle animations for all selected characters
          rem
          rem Input: playerCharacter[] (global array) = character selections
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        frame (global) = frame counter
          rem
          rem Output: None (updates animation state via
          rem ArenaSelectUpdatePlayerAnimation)
          rem
          rem Mutates: None (no persistent state updates)
          rem
          rem Called Routines: ArenaSelectUpdatePlayerAnimation - accesses
          rem frame counter
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectSkipPlayer0Animation, ArenaSelectSkipPlayer1Animation,
          rem              ArenaSelectSkipPlayer2Animation,
          rem              ArenaSelectSkipPlayer23Animation,
          rem ArenaSelectUpdatePlayerAnimation (all called via goto)
          rem Update idle animations for all selected characters
          rem Each player updates independently with simple frame
          rem   counter
          
          if playerCharacter[0] = NoCharacter then ArenaSelectSkipPlayer0Animation : rem Update Player 1 animation (if character selected)
          if playerCharacter[0] = CPUCharacter then ArenaSelectSkipPlayer0Animation
          if playerCharacter[0] = RandomCharacter then ArenaSelectSkipPlayer0Animation
          let temp1 = 0 : rem RandomCharacter = 253
          gosub ArenaSelectUpdatePlayerAnimation
          
ArenaSelectSkipPlayer0Animation
          rem Skip Player 1 animation update (not selected)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectUpdateAnimations
          if playerCharacter[1] = NoCharacter then ArenaSelectSkipPlayer1Animation : rem Update Player 2 animation (if character selected)
          if playerCharacter[1] = CPUCharacter then ArenaSelectSkipPlayer1Animation
          if playerCharacter[1] = RandomCharacter then ArenaSelectSkipPlayer1Animation
          let temp1 = 1
          gosub ArenaSelectUpdatePlayerAnimation
          
ArenaSelectSkipPlayer1Animation
          rem Skip Player 2 animation update (not selected)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectUpdateAnimations
          rem Update Player 3 animation (if Quadtari and character
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipPlayer23Animation : rem   selected)
          if playerCharacter[2] = NoCharacter then ArenaSelectSkipPlayer2Animation
          if playerCharacter[2] = CPUCharacter then ArenaSelectSkipPlayer2Animation
          if playerCharacter[2] = RandomCharacter then ArenaSelectSkipPlayer2Animation
          let temp1 = 2
          gosub ArenaSelectUpdatePlayerAnimation
          
ArenaSelectSkipPlayer2Animation
          rem Skip Player 3 animation update (not in 4-player mode or
          rem not selected)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectUpdateAnimations
          rem Update Player 4 animation (if Quadtari and character
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipPlayer23Animation : rem   selected)
          if playerCharacter[3] = NoCharacter then ArenaSelectSkipPlayer23Animation
          if playerCharacter[3] = CPUCharacter then ArenaSelectSkipPlayer23Animation
          if playerCharacter[3] = RandomCharacter then ArenaSelectSkipPlayer23Animation
          let temp1 = 3
          gosub ArenaSelectUpdatePlayerAnimation
          
ArenaSelectSkipPlayer23Animation
          rem Skip Player 3/4 animation updates (not in 4-player mode or
          rem not selected)
          return
ArenaSelectUpdatePlayerAnimation
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectUpdateAnimations
          rem Update idle animation frame for a single player
          rem
          rem Input: temp1 = player index (0-3)
          rem        frame (global) = frame counter
          rem
          rem Output: None (no persistent state updates, animation frame
          rem calculated from frame counter)
          rem
          rem Mutates: temp2 (internal calculation)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectUpdateAnimations
          rem Simple frame counter that cycles every 60 frames (1 second
          rem   at 60fps)
          rem Increment frame counter (stored in arenaSelectAnimationFrame
          rem   array)
          rem For now, use a simple counter that wraps every 8 frames
          rem In the future, this could use
          rem   arenaSelectAnimationFrame[playerIndex] array
          rem For simplicity, just cycle through frames 0-7 for idle
          rem   animation
          rem Frame updates every 8 frames (7.5fps at 60fps)
          let temp2 = frame & 7
          rem Simple frame-based animation (cycles every 8 frames)
          return
          
ArenaSelectDrawCharacters
          rem Draw all selected characters at their character select
          rem positions
          rem
          rem Input: playerCharacter[] (global array) = character selections
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        frame (global) = frame counter
          rem
          rem Output: player0-3x, player0-3y (TIA registers) set,
          rem sprites loaded via ArenaSelectDrawPlayerSprite
          rem
          rem Mutates: player0-3x, player0-3y (TIA registers),
          rem         player sprite pointers (via LocateCharacterArt),
          rem         COLUP0-COLUP3 (via LoadCharacterColors)
          rem
          rem Called Routines: ArenaSelectDrawPlayerSprite - accesses
          rem character selections, frame,
          rem   LocateCharacterArt (bank14) - accesses character art
          rem   data,
          rem   LoadCharacterColors (bank10) - accesses color tables
          rem
          rem Constraints: Must be colocated with ArenaSelectSkipDrawP0,
          rem ArenaSelectSkipDrawP1,
          rem              ArenaSelectSkipDrawP2,
          rem              ArenaSelectSkipDrawP23,
          rem              ArenaSelectDrawPlayerSprite
          rem (all called via goto)
          rem Draw all selected characters at their character select
          rem   positions
          rem Characters remain in same positions as character select
          rem   screen
          
          rem Playfield defined by ArenaSelect data; no per-frame register writes
          if playerCharacter[0] = NoCharacter then ArenaSelectSkipDrawP0 : rem Draw Player 1 character (top left) if selected
          if playerCharacter[0] = CPUCharacter then ArenaSelectSkipDrawP0
          if playerCharacter[0] = RandomCharacter then ArenaSelectSkipDrawP0
          player0x = 56 : player0y = 40
          let temp1 = 0
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP0
          rem Skip Player 1 character drawing (not selected)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectDrawCharacters
          if playerCharacter[1] = NoCharacter then ArenaSelectSkipDrawP1 : rem Draw Player 2 character (top right) if selected
          if playerCharacter[1] = CPUCharacter then ArenaSelectSkipDrawP1
          if playerCharacter[1] = RandomCharacter then ArenaSelectSkipDrawP1
          player1x = 104 : player1y = 40
          let temp1 = 1
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP1
          rem Skip Player 2 character drawing (not selected)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectDrawCharacters
          rem Draw Player 3 character (bottom left) if Quadtari and
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipDrawP23 : rem   selected
          if playerCharacter[2] = NoCharacter then ArenaSelectSkipDrawP2
          if playerCharacter[2] = CPUCharacter then ArenaSelectSkipDrawP2
          if playerCharacter[2] = RandomCharacter then ArenaSelectSkipDrawP2
          player2x = 56 : player2y = 80
          let temp1 = 2
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP2
          rem Skip Player 3 character drawing (not in 4-player mode or
          rem not selected)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectDrawCharacters
          rem Draw Player 4 character (bottom right) if Quadtari and
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipDrawP23 : rem   selected
          if playerCharacter[3] = NoCharacter then ArenaSelectSkipDrawP23
          if playerCharacter[3] = CPUCharacter then ArenaSelectSkipDrawP23
          if playerCharacter[3] = RandomCharacter then ArenaSelectSkipDrawP23
          player3x = 104 : player3y = 80
          let temp1 = 3
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP23
          rem Skip Player 3/4 character drawing (not in 4-player mode or
          rem not selected)
          return
ArenaSelectDrawPlayerSprite
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem ArenaSelectDrawCharacters
          rem Draw character sprite for specified player
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerCharacter[] (global array) = character selections
          rem        frame (global) = frame counter
          rem        player0-3x, player0-3y (TIA registers) = sprite
          rem        positions (set by caller)
          rem
          rem Output: Player sprite pointer set via LocateCharacterArt,
          rem COLUP0-COLUP3 set via LoadCharacterColors
          rem
          rem Mutates: temp1-temp4 (passed to LocateCharacterArt),
          rem player sprite pointers (via LocateCharacterArt),
          rem         COLUP0-COLUP3 (via LoadCharacterColors),
          rem         temp1-temp5 (LoadCharacterColors parameters)
          rem
          rem Called Routines: LocateCharacterArt (bank14) - accesses
          rem character art data, temp1-temp4,
          rem   LoadCharacterColors (bank10) - accesses color tables
          rem Constraints: Must be colocated with ArenaSelectDrawCharacters
          rem Draw character sprite for specified player
          rem
          rem Input: playerIndex = player index (0-3)
          rem Uses playerCharacter[0-3] and player positions set by caller
          
          if temp1 = 0 then let temp1 = playerCharacter[0] : rem Get character index based on player
          if temp1 = 1 then let temp1 = playerCharacter[1]
          if temp1 = 2 then let temp1 = playerCharacter[2]
          if temp1 = 3 then let temp1 = playerCharacter[3]
          
          let temp3 = 1 : rem Use idle animation (action 1 = ActionIdle)
          let temp2 = frame & 7 : rem Simple frame counter cycles 0-7
          let temp4 = temp1 : rem Player number for art system
          
          rem Load character sprite using art location system
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          rem temp3=action, temp4=player
          gosub LocateCharacterArt bank14
          
          rem Set character color based on player number
          rem LoadCharacterColors expects: temp1=character, temp2=hurt, temp3=player, temp4=flashing, temp5=mode
          let temp2 = 0 : rem Not hurt
          let temp3 = temp4 : rem Player number routed into color loader
          let temp4 = 0 : rem Not flashing
          let temp5 = 0 : rem Frame-based flashing disabled
          gosub LoadCharacterColors bank10
          
          return
