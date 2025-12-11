;;; ChaosFight - Source/Routines/ArenaSelect.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ArenaSelect1 .proc

.pend

ArenaSelect1Loop .proc
          ;; Arena Select - Per-frame Loop
          ;; Returns: Far (return otherbank)
          ;; Handles the arena carousel (1-32 plus random) each frame.
          ;; Called from MainLoop when gameMode = ModeArenaSelect.
          ;; BeginArenaSelect performs setup; this routine processes one frame then returns.
          ;;
          ;; Input: selectedArena_R (global SCRAM) = current arena
          ;; controllerStatus (global) = controller detection sta

          ;; fireHoldTimer_R (global SCRAM) = fire button hold
          ;; timer
          ;; joy0fire, joy1fire (hardware) = fire button sta

          ;; joy0left, joy0right (hardware) = navigation button sta

          ;; switchselect (hardware) = game select switch
          ;; INPT0, INPT2 (hardware) = Quadtari fire button sta

          ;; playerCharacter[] (global array) = character selections
          ;; frame (global) = frame counter
          ;;
          ;; Output: Dispatches to ReturnToCharacterSelect, StartGame1, or returns
          ;;
          ;; Mutates: selectedArena_W (updated via navigation),
          ;; fireHoldTimer_W (incremented/reset),
          ;; gameMode (set to ModeCharacterSelect or ModeGame)
          ;;
          ;; Called Routines: SelectUpdateAnimations (bank6) - accesses
          ;; character selections, frame,
          ;; ArenaSelectDrawCharacters - accesses character
          ;; selections, player positions,
          ;; CheckQuadtariFireHold - accesses INPT0, INPT2,
          ;; PlaySoundEffect (bank15) - plays navigation/selection
          ;; sounds,
          ;; SetGlyph (bank16) - draws arena number digits,
          ;; ChangeGameMode (bank14) - accesses game mode sta

          ;;
          ;; Constraints: Must be colocated with ArenaSelect1Loop,
          ;; CheckQuadtariFireHold,
          ;; ReturnToCharacterSelect, StartGame1,
          ;; ArenaSelectLeft, ArenaSelectRight,
          ;; DisplayRandomArena, ArenaSelectConfirm (all
          ;; called via goto)
          ;; Entry point for arena select mode (called
          ;; from MainLoop)
          ;; Update character idle animations
          ;; Cross-bank call to SelectUpdateAnimations in bank 6
          lda # >(AfterSelectUpdateAnimations-1)
          pha
          lda # <(AfterSelectUpdateAnimations-1)
          pha
          lda # >(SelectUpdateAnimations-1)
          pha
          lda # <(SelectUpdateAnimations-1)
          pha
          ldx # 5
          jmp BS_jsr

AfterSelectUpdateAnimations:

          ;; Draw locked-in player characters
          jsr ArenaSelectDrawCharacters

          ;; Check Game Select switch - return to Character Select
          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
          lda switchselect
          bne SkipReturnToCharacterSelect

          jmp ReturnToCharacterSelect

SkipReturnToCharacterSelect:

          ;; Check fire button hold detection (1 second to return to
          ;; Character Select)
          lda # 0
          sta temp1
          ;; Check Player 1 fire button
          ;; Check Player 2 fire button
          if joy0fire then let temp1 = 1
          lda joy0fire
          beq CheckJoy1Fire

          lda # 1
          sta temp1

CheckJoy1Fire:

          ;; Check Quadtari players (3 & 4) if active
          if joy1fire then let temp1 = 1
          lda joy1fire
          beq CheckQuadtariFire

          lda # 1
          sta temp1

CheckQuadtariFire:

          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
          if (controllerStatus & SetQuadtariDetected) <> 0 then goto CheckQuadtariFireHold
          lda controllerStatus
          and # SetQuadtariDetected
          beq CheckFireHoldTimer

          jmp CheckQuadtariFireHold

CheckFireHoldTimer:

          ;; If fire button held, increment timer
          ;; if temp1 then goto IncrementFireHold
          lda temp1
          beq FireHoldCheckDone

          jmp IncrementFireHold

FireHoldCheckDone:

          ;; Fire released, reset timer
          lda # 0
          sta fireHoldTimer_W
          jmp ArenaSelectNavigation

IncrementFireHold:
          lda fireHoldTimer_R
          sta temp2
          inc temp2
          ;; FramesPerSecond frames = 1 second at current TV sta

          lda temp2
          sta fireHoldTimer_W
          ;; if temp2 >= FramesPerSecond then goto ReturnToCharacterSelect
          lda temp2
          cmp # FramesPerSecond

          bcc ArenaSelectNavigation

          jmp ReturnToCharacterSelect

ArenaSelectNavigation:

          ;; Handle LEFT/RIGHT navigation for arena selection
          ;; if joy0left then goto ArenaSelectLeft
          lda joy0left
          beq ArenaSelectDoneLeft

          jmp ArenaSelectLeft

ArenaSelectDoneLeft:

.pend

ArenaSelectLeft .proc
          ;; Decrement arena, wrap from 0 to RandomArena (255)
          lda selectedArena_R
          cmp # 0
          bne CheckRandomArenaLeft
          ;; let selectedArena_W = RandomArena : goto ArenaSelectLeftSound
CheckRandomArenaLeft:

          lda selectedArena_R
          cmp # RandomArena
          bne DecrementArena

          ;; let selectedArena_W = MaxArenaID : goto ArenaSelectLeftSound
          lda # MaxArenaID
          sta selectedArena_W
          jmp ArenaSelectLeftSound

DecrementArena:

          lda selectedArena_R
          sta temp2
          dec temp2
          lda temp2
          sta selectedArena_W

.pend

ArenaSelectLeftSound .proc
          ;; Play navigation sound
          lda SoundMenuNavigate
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(AfterPlaySoundEffectLeft-1)
          pha
          lda # <(AfterPlaySoundEffectLeft-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterPlaySoundEffectLeft:

          ;; if joy0right then goto ArenaSelectRight
          lda joy0right
          beq ArenaSelectDoneLeft

          jmp ArenaSelectRight

ArenaSelectDoneLeft:

.pend

ArenaSelectRight .proc
          ;; Increment arena, wrap from MaxArenaID to 0, then to
          ;; RandomArena
          lda selectedArena_R
          cmp # MaxArenaID
          bne CheckRandomArenaRight

          ;; let selectedArena_W = RandomArena : goto ArenaSelectRightSound
          lda # RandomArena
          sta selectedArena_W
          jmp ArenaSelectRightSound

CheckRandomArenaRight:

          lda selectedArena_R
          cmp # RandomArena
          bne IncrementArena

          ;; let selectedArena_W = 0 : goto ArenaSelectRightSound
          lda # 0
          sta selectedArena_W
          jmp ArenaSelectRightSound

IncrementArena:

          lda selectedArena_R
          sta temp2
          inc temp2
          ;; Wrap from 255 to 0 if needed
          lda temp2
          sta selectedArena_W
          if selectedArena_R > MaxArenaID && selectedArena_R < RandomArena then let selectedArena_W = 0

.pend

ArenaSelectRightSound .proc
          ;; Play navigation sound
          lda # SoundMenuNavigate
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(return_point2-1)
          pha
          lda # <(return_point2-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
          ldx # 14
          jmp BS_jsr

return_point2:

          ;; Display arena number ( 1-32) or ?? (random)
          ;; Display using player4 (tens digit) and player5 (ones
          ;; digit)
          ;; Position: center of screen (X=80 for tens,x=88 for ones,
          ;; Y=20)
          ;; Note: Tens digit only shown for arenas 10-32 (tensDigit >
          ;; 0)
          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
          lda selectedArena_R
          cmp # RandomArena
          bne DisplayArenaNumber

          jmp DisplayRandomArena

DisplayArenaNumber:


          ;; Display arena number (selectedArena + 1 = 1-32)
          ;; Convert to two-digit display: tens and ones
          ;; Supports up to 32 arenas (tens digit: blank for 1-9, 1 for
          ;; 10-19, 2 for 20-29, 3 for 30-32)
          lda selectedArena_R
          clc
          adc # 1
          sta temp1
          ;; arenaNumber = arena number (1-32)
          ;; Fast BCD extraction: extract tens and ones digits using assembly
          ;; For arena numbers 1-32, extract tens (0-3) and ones (0-9) digits
          lda temp1
          ldx # 0
          jmp FastBCDStart

FastBCDOnesDigit:
          adc # 10
          sta temp4
          stx temp2
          jmp FastBCDDone

FastBCDMaxTens:
          sta temp4
          stx temp2
          jmp FastBCDDone

FastBCDStart:

FastBCDDivideBy10:
          sec
          sbc # 10
          bcc FastBCDOnesDigit

          inx
          ;; TODO: #1311 cpx #3
          beq FastBCDMaxTens

          jmp FastBCDDivideBy10

FastBCDDone:
          ;; temp2 = tens digit (0-3), temp4 = ones digit (0-9)

          ;; Draw tens digit (player4) - only if tensDigit > 0 (for
          ;; arenas 10-32)
          lda temp2
          cmp # 1
          bcc SkipTens

          jmp DrawTensDigit

SkipTens:

.pend

DrawTensDigit .proc
          ;; Set P4 fixed position and color (arena digits)
          lda temp2
          sta temp1
          lda # 80
          sta player4x
          lda # 20
          sta player4y
          lda $0E(14)
          sta COLUP4
          ;; Use player4 for tens digit
          lda # 4
          sta temp3
          ;; Cross-bank call to SetGlyph in bank 16
          lda # >(AfterSetGlyphTens-1)
          pha
          lda # <(AfterSetGlyphTens-1)
          pha
          lda # >(SetGlyph-1)
          pha
          lda # <(SetGlyph-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterSetGlyphTens:


.pend

SkipTens .proc
          ;; Draw ones digit (player5)
          lda temp4
          sta temp1
          ;; Set P5 fixed position and color (arena digits)
          lda # 88
          sta player5x
          lda # 20
          sta player5y
          lda $0E(14)
          sta COLUP5
          ;; Use player5 for ones digit
          lda # 5
          sta temp3
          ;; Cross-bank call to SetGlyph in bank 16
          lda # >(AfterSetGlyphOnes-1)
          pha
          lda # <(AfterSetGlyphOnes-1)
          pha
          lda # >(SetGlyph-1)
          pha
          lda # <(SetGlyph-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterSetGlyphOnes:


          jmp DisplayDone

.pend

DisplayRandomArena .proc
          ;; Display ?? for random arena
          ;; Use player4 and player5 for two question marks
          ;; Question mark is digit 10 (hex A) in font
          lda # 10
          sta temp1
          ;; First question mark: set P4 fixed position/color
          lda # 80
          sta player4x
          lda # 20
          sta player4y
          lda # $0E
          sta COLUP4
          ;; White
          lda # 4
          sta temp3
          ;; Use player4
          ;; Cross-bank call to SetGlyph in bank 16
          lda # >(AfterSetGlyphRandom1-1)
          pha
          lda # <(AfterSetGlyphRandom1-1)
          pha
          lda # >(SetGlyph-1)
          pha
          lda # <(SetGlyph-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterSetGlyphRandom1:

          ;; Second question mark: set P5 fixed position/color
          lda # 88
          sta player5x
          lda # 20
          sta player5y
          lda # $0E
          sta COLUP5
          ;; Use player5
          lda # 5
          sta temp3
          ;; Cross-bank call to SetGlyph in bank 16
          lda # >(AfterSetGlyphRandom2-1)
          pha
          lda # <(AfterSetGlyphRandom2-1)
          pha
          lda # >(SetGlyph-1)
          pha
          lda # <(SetGlyph-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterSetGlyphRandom2:


DisplayDone
          ;; Handle fire button press (confirm selection, start game)
          ;; if joy0fire then goto ArenaSelectConfirm
          lda joy0fire
          beq ArenaSelectDoneConfirm
          jmp ArenaSelectConfirm
ArenaSelectDoneConfirm:

          jmp ArenaSelectDoneConfirm

ArenaSelectConfirm
          ;; Play selection sound
          lda SoundMenuSelect
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(AfterPlaySoundEffectConfirm-1)
          pha
          lda # <(AfterPlaySoundEffectConfirm-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectConfirm:


          ;; tail call
          jmp StartGame1

ArenaSelectDoneConfirm
          ;; Update sound effects (active sound effects need per-frame updates)
          ;; Cross-bank call to UpdateSoundEffect in bank 15
          lda # >(AfterUpdateSoundEffect-1)
          pha
          lda # <(AfterUpdateSoundEffect-1)
          pha
          lda # >(UpdateSoundEffect-1)
          pha
          lda # <(UpdateSoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterUpdateSoundEffect:


          ;; drawscreen called by MainLoop
          jsr BS_return

CheckQuadtariFireHold
          ;; Check Player 3 and 4 fire buttons (Quadtari)
          ;;
          ;; Input: INPT0 (hardware) = Player 3 fire button sta

          ;; INPT2 (hardware) = Player 4 fire button sta

          ;;
          ;; Output: temp1 = 1 if any Quadtari fire button pressed, 0
          ;; otherwise
          ;;
          ;; Mutates: temp1 (fire pressed flag)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with ArenaSelect1 (called via goto)
          ;; Check Player 3 and 4 fire buttons (Quadtari)
          ;; Player 3 fire button (left port, odd frame)
                    if !INPT0{7} then let temp1 = 1

          ;; Player 4 fire button (right port, odd frame)
                    if !INPT2{7} then let temp1 = 1
          bit INPT2
          bmi CheckQuadtariFireHoldDone
          lda 1
          sta temp1
CheckQuadtariFireHoldDone:
          jsr BS_return

ReturnToCharacterSelect
          Return to Character Select screen
          ;;
          ;; Input: None (called from ArenaSelect1)
          ;;
          ;; Output: gameMode set to ModeCharacterSelect,
          ;; ChangeGameMode called
          ;;
          ;; Mutates: fireHoldTimer_W (reset to 0), gameMode (global)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;; Constraints: Must be colocated with ArenaSelect1
          lda # 0
          sta fireHoldTimer_W
          lda ModeCharacterSelect
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
return_point:


          jsr BS_return

.pend

StartGame1 .proc
          ;; Start game with selected arena
          ;;
          ;; Input: None (called from ArenaSelect1)
          ;;
          ;; Output: gameMode set to ModeGame, ChangeGameMode called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;; Constraints: Must be colocated with ArenaSelect1
          lda ModeGame
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
return_point:


          jsr BS_return
          ;;
          ;; Character Display and Animation

.pend

ArenaSelectDrawCharacters .proc
          ;; Draw all selected characters at their character select
          ;; positions
          ;;
          ;; Input: playerCharacter[] (global array) = character selections
          ;; controllerStatus (global) = controller detection
          ;; sta

          ;; frame (global) = frame counter
          ;;
          ;; Output: player0-3x, player0-3y (TIA registers) set,
          ;; sprites loaded via RenderPlayerPreview (bank6)
          ;;
          ;; Mutates: player0-3x, player0-3y (TIA registers),
          ;; player sprite pointers (via LocateCharacterArt),
          ;; COLUP0-COLUP3 (via PlayerPreviewApplyColor bank6)
          ;;
          ;; Called Routines: PlayerPreviewSetPosition (bank6) - sets
          ;; sprite coordinates,
          ;; RenderPlayerPreview (bank6) - loads sprite graphics and
          ;; base colors
          ;;
          ;; Constraints: Must be colocated with ArenaSelectSkipDrawP0,
          ;; ArenaSelectSkipDrawP1,
          ;; ArenaSelectSkipDrawP2,
          ;; ArenaSelectSkipDrawP23,
          ;; ArenaSelectDrawPlayerSprite
          ;; (all called via goto)
          ;; Draw all selected characters at their character select
          ;; positions
          ;; Characters remain in same positions as character select
          ;; screen

          ;; Playfield defined by ArenaSelect data; no per-frame register writes
          ;; Draw Player 1 character (top left) if selected
          ;; if playerCharacter[0] = NoCharacter then goto ArenaSelectDoneDrawP0

          ;; if playerCharacter[0] = CPUCharacter then goto ArenaSelectDoneDrawP0
          lda # 0
          asl
          tax
          lda playerCharacter,x
          cmp CPUCharacter
          bne CheckRandomCharacterP0
          jmp ArenaSelectDoneDrawP0
CheckRandomCharacterP0:

          ;; if playerCharacter[0] = RandomCharacter then goto ArenaSelectDoneDrawP0
          lda # 0
          asl
          tax
          lda playerCharacter,x
          cmp RandomCharacter
          bne DrawPlayer0Character
          jmp ArenaSelectDoneDrawP0
DrawPlayer0Character:
          lda # 0
          sta temp1
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayerPreviewSetPosition-1)
          pha
          lda # <(PlayerPreviewSetPosition-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RenderPlayerPreview-1)
          pha
          lda # <(RenderPlayerPreview-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


ArenaSelectDoneDrawP0
          ;; Skip Player 1 character drawing (not selected)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with
          ;; ArenaSelectDrawCharacters
          ;; Draw Player 2 character (top right) if selected
          ;; if playerCharacter[1] = NoCharacter then goto ArenaSelectDoneDrawP1

          ;; if playerCharacter[1] = CPUCharacter then goto ArenaSelectDoneDrawP1
          lda # 1
          asl
          tax
          lda playerCharacter,x
          cmp CPUCharacter
          bne CheckRandomCharacterP1
          jmp ArenaSelectDoneDrawP1
CheckRandomCharacterP1:

          ;; if playerCharacter[1] = RandomCharacter then goto ArenaSelectDoneDrawP1
          lda # 1
          asl
          tax
          lda playerCharacter,x
          cmp RandomCharacter
          bne DrawPlayer1Character
          jmp ArenaSelectDoneDrawP1
DrawPlayer1Character:
          lda # 1
          sta temp1
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayerPreviewSetPosition-1)
          pha
          lda # <(PlayerPreviewSetPosition-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RenderPlayerPreview-1)
          pha
          lda # <(RenderPlayerPreview-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


ArenaSelectDoneDrawP1
          ;; Skip Player 2 character drawing (not selected)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with
          ;; ArenaSelectDrawCharacters
          ;; Draw Player 3 character (bottom left) if Quadtari and
          ;; selected
          ;; No Quadtari detected; park lower previews off-screen via shared helper
          ;; Cross-bank call to SelectHideLowerPlayerPreviews in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SelectHideLowerPlayerPreviews-1)
          pha
          lda # <(SelectHideLowerPlayerPreviews-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; if playerCharacter[2] = NoCharacter then goto ArenaSelectDoneDrawP2

          ;; if playerCharacter[2] = CPUCharacter then goto ArenaSelectDoneDrawP2
          lda # 2
          asl
          tax
          lda playerCharacter,x
          cmp CPUCharacter
          bne CheckRandomCharacterP2
          jmp ArenaSelectDoneDrawP2
CheckRandomCharacterP2:

          ;; if playerCharacter[2] = RandomCharacter then goto ArenaSelectDoneDrawP2
          lda # 2
          asl
          tax
          lda playerCharacter,x
          cmp RandomCharacter
          bne DrawPlayer2Character
          jmp ArenaSelectDoneDrawP2
DrawPlayer2Character:
          lda # 2
          sta temp1
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayerPreviewSetPosition-1)
          pha
          lda # <(PlayerPreviewSetPosition-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RenderPlayerPreview-1)
          pha
          lda # <(RenderPlayerPreview-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


ArenaSelectDoneDrawP2
          ;; Skip Player 3 character drawing (not in 4-player mode or
          ;; not selected)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with
          ;; ArenaSelectDrawCharacters
          ;; Draw Player 4 character (bottom right) if Quadtari and
          ;; selected
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer3Character

          jmp ArenaSelectDoneDrawP23
CheckPlayer3Character:


          ;; if playerCharacter[3] = NoCharacter then goto ArenaSelectDoneDrawP23

          ;; if playerCharacter[3] = CPUCharacter then goto ArenaSelectDoneDrawP23
          lda # 3
          asl
          tax
          lda playerCharacter,x
          cmp CPUCharacter
          bne CheckRandomCharacterP3
          jmp ArenaSelectDoneDrawP23
CheckRandomCharacterP3:

          ;; if playerCharacter[3] = RandomCharacter then goto ArenaSelectDoneDrawP23
          lda # 3
          asl
          tax
          lda playerCharacter,x
          cmp RandomCharacter
          bne DrawPlayer3Character
          jmp ArenaSelectDoneDrawP23
DrawPlayer3Character:
          lda # 3
          sta temp1
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayerPreviewSetPosition-1)
          pha
          lda # <(PlayerPreviewSetPosition-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RenderPlayerPreview-1)
          pha
          lda # <(RenderPlayerPreview-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


ArenaSelectDoneDrawP23
          ;; Skip Player 3/4 character drawing (not in 4-player mode or
          ;; not selected)
          jsr BS_return

.pend

