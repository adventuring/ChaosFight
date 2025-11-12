          rem ChaosFight - Source/Routines/ArenaSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ArenaSelect1
ArenaSelect1Loop
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
          rem Called Routines: SelectUpdateAnimations (bank6) - accesses
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
          gosub SelectUpdateAnimations bank6
          rem Update character idle animations
          gosub ArenaSelectDrawCharacters
          rem Draw locked-in player characters
          rem Check Game Select switch - return to Character Select
          if switchselect then ReturnToCharacterSelect

          rem Check fire button hold detection (1 second to return to
          let temp1 = 0
          rem   Character Select)
          rem Check Player 1 fire button
          if joy0fire then let temp1 = 1
          rem Check Player 2 fire button
          if joy1fire then let temp1 = 1
          rem Check Quadtari players (3 & 4) if active
          if controllerStatus & SetQuadtariDetected then CheckQuadtariFireHold

          rem If fire button held, increment timer

          if temp1 then goto IncrementFireHold
          let fireHoldTimer_W = 0
          rem Fire released, reset timer
          goto FireHoldCheckDone

IncrementFireHold
          let temp2 = fireHoldTimer_R
          let temp2 = temp2 + 1
          let fireHoldTimer_W = temp2
          rem FramesPerSecond frames = 1 second at current TV standard
          if temp2 >= FramesPerSecond then goto ReturnToCharacterSelect
FireHoldCheckDone

          rem Handle LEFT/RIGHT navigation for arena selection

          if joy0left then ArenaSelectLeft
          goto ArenaSelectDoneLeft
ArenaSelectLeft
          rem Decrement arena, wrap from 0 to RandomArena (255)
          if selectedArena_R = 0 then let selectedArena_W = RandomArena : goto ArenaSelectLeftSound
          if selectedArena_R = RandomArena then let selectedArena_W = MaxArenaID : goto ArenaSelectLeftSound
          let temp2 = selectedArena_R
          let temp2 = temp2 - 1
          let selectedArena_W = temp2
ArenaSelectLeftSound
          let temp1 = SoundMenuNavigate
          rem Play navigation sound
          gosub PlaySoundEffect bank15
ArenaSelectDoneLeft

          if joy0right then ArenaSelectRight
          goto ArenaSelectDoneRight
ArenaSelectRight
          rem Increment arena, wrap from MaxArenaID to 0, then to
          rem RandomArena
          if selectedArena_R = MaxArenaID then let selectedArena_W = RandomArena : goto ArenaSelectRightSound
          if selectedArena_R = RandomArena then let selectedArena_W = 0 : goto ArenaSelectRightSound
          let temp2 = selectedArena_R
          let temp2 = temp2 + 1
          let selectedArena_W = temp2
          rem Wrap from 255 to 0 if needed
          if selectedArena_R > MaxArenaID && selectedArena_R < RandomArena then let selectedArena_W = 0
ArenaSelectRightSound
          let temp1 = SoundMenuNavigate
          rem Play navigation sound
          gosub PlaySoundEffect bank15
ArenaSelectDoneRight

          rem Display arena number ( 1-32) or ?? (random)
          rem Display using player4 (tens digit) and player5 (ones
          rem   digit)
          rem Position: center of screen (X=80 for tens, X=88 for ones,
          rem   Y=20)
          rem Note: Tens digit only shown for arenas 10-32 (tensDigit >
          rem 0)
          if selectedArena_R = RandomArena then DisplayRandomArena

          rem Display arena number (selectedArena + 1 = 1-32)
          rem Convert to two-digit display: tens and ones
          rem Supports up to 32 arenas (tens digit: blank for 1-9, 1 for
          let temp1 = selectedArena_R + 1
          rem   10-19, 2 for 20-29, 3 for 30-32)
          rem arenaNumber = arena number (1-32)
          let temp2 = temp1 / 10
          rem Calculate tens digit
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
          let temp4 = temp1 - temp3
          rem multiplier = tensDigit * 10
          rem onesDigit = ones digit (0-9)

          rem Draw tens digit (player4) - only if tensDigit > 0 (for
          rem arenas 10-32)
          if temp2 > 0 then goto DrawTensDigit
          goto SkipTens
DrawTensDigit
          let temp1 = temp2
          rem Set P4 fixed position and color (arena digits)
          let player4x = 80
          let player4y = 20
          let COLUP4 = ColGrey(14)
          let temp3 = 4
          rem Use player4 for tens digit
          gosub SetFontGlyph bank16
SkipTens

          let temp1 = temp4
          rem Draw ones digit (player5)
          rem Set P5 fixed position and color (arena digits)
          let player5x = 88
          let player5y = 20
          let COLUP5 = ColGrey(14)
          let temp3 = 5
          rem Use player5 for ones digit
gosub SetFontGlyph bank16

goto DisplayDone

DisplayRandomArena
          rem Display ?? for random arena
          rem Use player4 and player5 for two question marks
          let temp1 = 10
          rem Question mark is digit 10 (hex A) in font
          rem First question mark: set P4 fixed position/color
          let player4x = 80
          let player4y = 20
          let COLUP4 = ColGrey(14)
          let temp3 = 4
          rem White
          rem Use player4
gosub SetFontGlyph bank16

          rem Second question mark: set P5 fixed position/color
          let player5x = 88
          let player5y = 20
          let COLUP5 = ColGrey(14)
          let temp3 = 5
          rem Use player5
gosub SetFontGlyph bank16

DisplayDone

          rem Handle fire button press (confirm selection, start game)

          if joy0fire then ArenaSelectConfirm
goto ArenaSelectDoneConfirm
ArenaSelectConfirm
          let temp1 = SoundMenuSelect
          rem Play selection sound
          gosub PlaySoundEffect bank15
          goto StartGame1
          rem tail call
ArenaSelectDoneConfirm

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
          rem Check Player 3 and 4 fire buttons (Quadtari)
          if !INPT0{7} then let temp1 = 1
          rem Player 3 fire button (left port, odd frame)
          if !INPT2{7} then let temp1 = 1
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
          rem Constraints: Must be colocated with ArenaSelect1
          let fireHoldTimer_W = 0
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
          rem Constraints: Must be colocated with ArenaSelect1
          let gameMode = ModeGame
          gosub ChangeGameMode bank14
          return

          rem
          rem Character Display And Animation


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
          rem sprites loaded via RenderPlayerPreview (bank6)
          rem
          rem Mutates: player0-3x, player0-3y (TIA registers),
          rem         player sprite pointers (via LocateCharacterArt),
          rem         COLUP0-COLUP3 (via PlayerPreviewApplyColor bank6)
          rem
          rem Called Routines: PlayerPreviewSetPosition (bank6) - sets
          rem sprite coordinates,
          rem   RenderPlayerPreview (bank6) - loads sprite graphics and
          rem   base colors
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
          rem Draw Player 1 character (top left) if selected
          if playerCharacter[0] = NoCharacter then ArenaSelectDoneDrawP0
          if playerCharacter[0] = CPUCharacter then ArenaSelectDoneDrawP0
          if playerCharacter[0] = RandomCharacter then ArenaSelectDoneDrawP0
          let temp1 = 0
gosub PlayerPreviewSetPosition bank6
gosub RenderPlayerPreview bank6

ArenaSelectDoneDrawP0
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
          rem Draw Player 2 character (top right) if selected
          if playerCharacter[1] = NoCharacter then ArenaSelectDoneDrawP1
          if playerCharacter[1] = CPUCharacter then ArenaSelectDoneDrawP1
          if playerCharacter[1] = RandomCharacter then ArenaSelectDoneDrawP1
          let temp1 = 1
gosub PlayerPreviewSetPosition bank6
gosub RenderPlayerPreview bank6

ArenaSelectDoneDrawP1
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
          rem selected
          rem No Quadtari detected; park lower previews off-screen via shared helper
          if (controllerStatus & SetQuadtariDetected) = 0 then gosub SelectHideLowerPlayerPreviews bank6 : goto ArenaSelectDoneDrawP23
          if playerCharacter[2] = NoCharacter then ArenaSelectDoneDrawP2
          if playerCharacter[2] = CPUCharacter then ArenaSelectDoneDrawP2
          if playerCharacter[2] = RandomCharacter then ArenaSelectDoneDrawP2
          let temp1 = 2
gosub PlayerPreviewSetPosition bank6
gosub RenderPlayerPreview bank6

ArenaSelectDoneDrawP2
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
          rem selected
          if (controllerStatus & SetQuadtariDetected) = 0 then ArenaSelectDoneDrawP23
          if playerCharacter[3] = NoCharacter then ArenaSelectDoneDrawP23
          if playerCharacter[3] = CPUCharacter then ArenaSelectDoneDrawP23
          if playerCharacter[3] = RandomCharacter then ArenaSelectDoneDrawP23
          let temp1 = 3
gosub PlayerPreviewSetPosition bank6
gosub RenderPlayerPreview bank6

ArenaSelectDoneDrawP23
          rem Skip Player 3/4 character drawing (not in 4-player mode or
          rem not selected)
return
