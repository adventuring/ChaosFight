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
          lda # >(return_point-1)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SelectUpdateAnimations-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SelectUpdateAnimations-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Draw locked-in player characters
          jsr ArenaSelectDrawCharacters

          ;; Check Game Select switch - return to Character Select
          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
          ;; lda switchselect (duplicate)
          bne skip_5627
          ;; jmp SkipReturnToCharacterSelect (duplicate)
skip_5627:


          ;; jmp ReturnToCharacterSelect (duplicate)

SkipReturnToCharacterSelect
          ;; Check fire button hold detection (1 second to return to
          ;; Character Select)
          ;; lda # 0 (duplicate)
          sta temp1
          ;; Check Player 1 fire button
          ;; Check Player 2 fire button
                    ;; if joy0fire then let temp1 = 1          lda joy0fire          beq skip_3554
skip_3554:
          ;; jmp skip_3554 (duplicate)

          ;; Check Quadtari players (3 & 4) if active
                    ;; if joy1fire then let temp1 = 1
          ;; lda joy1fire (duplicate)
          beq skip_4728
          ;; lda 1 (duplicate)
          ;; sta temp1 (duplicate)
skip_4728:

          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
                    ;; if (controllerStatus & SetQuadtariDetected) <> 0 then goto CheckQuadtariFireHold
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; beq skip_4971 (duplicate)
          ;; jmp CheckQuadtariFireHold (duplicate)
skip_4971:

          ;; If fire button held, increment timer
                    ;; if temp1 then goto IncrementFireHold
          ;; lda temp1 (duplicate)
          ;; beq skip_68 (duplicate)
          ;; jmp IncrementFireHold (duplicate)
skip_68:

          ;; Fire released, reset timer
          ;; lda # 0 (duplicate)
          ;; sta fireHoldTimer_W (duplicate)
          ;; jmp FireHoldCheckDone (duplicate)

IncrementFireHold
          ;; lda fireHoldTimer_R (duplicate)
          ;; sta temp2 (duplicate)
          inc temp2
          ;; FramesPerSecond frames = 1 second at current TV sta

          ;; lda temp2 (duplicate)
          ;; sta fireHoldTimer_W (duplicate)
          ;; if temp2 >= FramesPerSecond then goto ReturnToCharacterSelect
          ;; lda temp2 (duplicate)
          cmp FramesPerSecond

          bcc skip_2376

          ;; jmp skip_2376 (duplicate)

          skip_2376:

FireHoldCheckDone
          ;; Handle LEFT/RIGHT navigation for arena selection
                    ;; if joy0left then goto ArenaSelectLeft
          ;; lda joy0left (duplicate)
          ;; beq skip_3919 (duplicate)
          ;; jmp ArenaSelectLeft (duplicate)
skip_3919:

          ;; jmp ArenaSelectDoneLeft (duplicate)

.pend

ArenaSelectLeft .proc
          ;; Decrement arena, wrap from 0 to RandomArena (255)
          ;; lda selectedArena_R (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3849 (duplicate)
                    ;; let selectedArena_W = RandomArena : goto ArenaSelectLeftSound
skip_3849:

          ;; lda selectedArena_R (duplicate)
          ;; cmp RandomArena (duplicate)
          ;; bne skip_9093 (duplicate)
                    ;; let selectedArena_W = MaxArenaID : goto ArenaSelectLeftSound
skip_9093:

          ;; lda selectedArena_R (duplicate)
          ;; sta temp2 (duplicate)
          dec temp2
          ;; lda temp2 (duplicate)
          ;; sta selectedArena_W (duplicate)

.pend

ArenaSelectLeftSound .proc
          ;; Play navigation sound
          ;; lda SoundMenuNavigate (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


ArenaSelectDoneLeft
                    ;; if joy0right then goto ArenaSelectRight
          ;; lda joy0right (duplicate)
          ;; beq skip_1901 (duplicate)
          ;; jmp ArenaSelectRight (duplicate)
skip_1901:

          ;; jmp ArenaSelectDoneRight (duplicate)

.pend

ArenaSelectRight .proc
          ;; Increment arena, wrap from MaxArenaID to 0, then to
          ;; RandomArena
          ;; lda selectedArena_R (duplicate)
          ;; cmp MaxArenaID (duplicate)
          ;; bne skip_4092 (duplicate)
                    ;; let selectedArena_W = RandomArena : goto ArenaSelectRightSound
skip_4092:

          ;; lda selectedArena_R (duplicate)
          ;; cmp RandomArena (duplicate)
          ;; bne skip_2709 (duplicate)
                    ;; let selectedArena_W = 0 : goto ArenaSelectRightSound
skip_2709:

          ;; lda selectedArena_R (duplicate)
          ;; sta temp2 (duplicate)
          ;; inc temp2 (duplicate)
          ;; Wrap from 255 to 0 if needed
          ;; lda temp2 (duplicate)
          ;; sta selectedArena_W (duplicate)
                    ;; if selectedArena_R > MaxArenaID && selectedArena_R < RandomArena then let selectedArena_W = 0

.pend

ArenaSelectRightSound .proc
          ;; Play navigation sound
          ;; lda SoundMenuNavigate (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


ArenaSelectDoneRight
          ;; Display arena number ( 1-32) or ?? (random)
          ;; Display using player4 (tens digit) and player5 (ones
          ;; digit)
          ;; Position: center of screen (X=80 for tens,x=88 for ones,
          ;; Y=20)
          ;; Note: Tens digit only shown for arenas 10-32 (tensDigit >
          ;; 0)
          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
          ;; lda selectedArena_R (duplicate)
          ;; cmp RandomArena (duplicate)
          ;; bne skip_5275 (duplicate)
          ;; jmp DisplayRandomArena (duplicate)
skip_5275:


          ;; Display arena number (selectedArena + 1 = 1-32)
          ;; Convert to two-digit display: tens and ones
          ;; Supports up to 32 arenas (tens digit: blank for 1-9, 1 for
          ;; 10-19, 2 for 20-29, 3 for 30-32)
          ;; lda selectedArena_R (duplicate)
          clc
          adc # 1
          ;; sta temp1 (duplicate)
          ;; arenaNumber = arena number (1-32)
          ;; Fast BCD extraction: extract tens and ones digits using assembly
          ;; For arena numbers 1-32, extract tens (0-3) and ones (0-9) digits
            ;; lda temp1 (duplicate)
                    ;; ldx # 0 (duplicate)
            ;; jmp FastBCDStart (duplicate)
FastBCDOnesDigit
            ;; adc # 10 (duplicate)
            ;; sta temp4 (duplicate)
                    stx temp2
            ;; jmp FastBCDDone (duplicate)
FastBCDMaxTens
            ;; sta temp4 (duplicate)
                    ;; stx temp2 (duplicate)
            ;; jmp FastBCDDone (duplicate)
FastBCDStart
FastBCDDivideBy10
            sec
            sbc # 10
            ;; bcc FastBCDOnesDigit (duplicate)
            inx
          ;; TODO: cpx #3
            ;; beq FastBCDMaxTens (duplicate)
            ;; jmp FastBCDDivideBy10 (duplicate)
FastBCDDone
          ;; temp2 = tens digit (0-3), temp4 = ones digit (0-9)

          ;; Draw tens digit (player4) - only if tensDigit > 0 (for
          ;; arenas 10-32)
          ;; lda temp2 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcc skip_4336 (duplicate)
skip_4336:


          ;; jmp SkipTens (duplicate)

.pend

DrawTensDigit .proc
          ;; Set P4 fixed position and color (arena digits)
          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda # 80 (duplicate)
          ;; sta player4x (duplicate)
          ;; lda # 20 (duplicate)
          ;; sta player4y (duplicate)
          ;; lda $0E(14) (duplicate)
          ;; sta COLUP4 (duplicate)
          ;; Use player4 for tens digit
          ;; lda # 4 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to SetGlyph in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


.pend

SkipTens .proc
          ;; Draw ones digit (player5)
          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Set P5 fixed position and color (arena digits)
          ;; lda # 88 (duplicate)
          ;; sta player5x (duplicate)
          ;; lda # 20 (duplicate)
          ;; sta player5y (duplicate)
          ;; lda $0E(14) (duplicate)
          ;; sta COLUP5 (duplicate)
          ;; Use player5 for ones digit
          ;; lda # 5 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to SetGlyph in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp DisplayDone (duplicate)

.pend

DisplayRandomArena .proc
          ;; Display ?? for random arena
          ;; Use player4 and player5 for two question marks
          ;; Question mark is digit 10 (hex A) in font
          ;; lda # 10 (duplicate)
          ;; sta temp1 (duplicate)
          ;; First question mark: set P4 fixed position/color
          ;; lda # 80 (duplicate)
          ;; sta player4x (duplicate)
          ;; lda # 20 (duplicate)
          ;; sta player4y (duplicate)
          ;; lda $0E(14) (duplicate)
          ;; sta COLUP4 (duplicate)
          ;; White
          ;; lda # 4 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Use player4
          ;; Cross-bank call to SetGlyph in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Second question mark: set P5 fixed position/color
          ;; lda # 88 (duplicate)
          ;; sta player5x (duplicate)
          ;; lda # 20 (duplicate)
          ;; sta player5y (duplicate)
          ;; lda $0E(14) (duplicate)
          ;; sta COLUP5 (duplicate)
          ;; Use player5
          ;; lda # 5 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to SetGlyph in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetGlyph-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


DisplayDone
          ;; Handle fire button press (confirm selection, start game)
                    ;; if joy0fire then goto ArenaSelectConfirm
          ;; lda joy0fire (duplicate)
          ;; beq skip_1340 (duplicate)
          ;; jmp ArenaSelectConfirm (duplicate)
skip_1340:

          ;; jmp ArenaSelectDoneConfirm (duplicate)

ArenaSelectConfirm
          ;; Play selection sound
          ;; lda SoundMenuSelect (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; tail call
          ;; jmp StartGame1 (duplicate)

ArenaSelectDoneConfirm
          ;; Update sound effects (active sound effects need per-frame updates)
          ;; Cross-bank call to UpdateSoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdateSoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdateSoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; drawscreen called by MainLoop
          ;; jsr BS_return (duplicate)

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
                    ;; if !INPT0{7} then let temp1 = 1

          ;; Player 4 fire button (right port, odd frame)
                    ;; if !INPT2{7} then let temp1 = 1
          bit INPT2
          bmi skip_78
          ;; lda 1 (duplicate)
          ;; sta temp1 (duplicate)
skip_78:
          ;; jsr BS_return (duplicate)

ReturnToCharacterSelect
          ;; Return to Character Select screen
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
          ;; lda # 0 (duplicate)
          ;; sta fireHoldTimer_W (duplicate)
          ;; lda ModeCharacterSelect (duplicate)
          ;; sta gameMode (duplicate)
          ;; Cross-bank call to ChangeGameMode in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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
          ;; lda ModeGame (duplicate)
          ;; sta gameMode (duplicate)
          ;; Cross-bank call to ChangeGameMode in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)
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
          ;; lda # 0 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_2941 (duplicate)
          ;; jmp ArenaSelectDoneDrawP0 (duplicate)
skip_2941:

                    ;; if playerCharacter[0] = RandomCharacter then goto ArenaSelectDoneDrawP0
          ;; lda # 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_5028 (duplicate)
          ;; jmp ArenaSelectDoneDrawP0 (duplicate)
skip_5028:
          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


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
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_7826 (duplicate)
          ;; jmp ArenaSelectDoneDrawP1 (duplicate)
skip_7826:

                    ;; if playerCharacter[1] = RandomCharacter then goto ArenaSelectDoneDrawP1
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_5463 (duplicate)
          ;; jmp ArenaSelectDoneDrawP1 (duplicate)
skip_5463:
          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


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
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SelectHideLowerPlayerPreviews-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SelectHideLowerPlayerPreviews-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if playerCharacter[2] = NoCharacter then goto ArenaSelectDoneDrawP2

                    ;; if playerCharacter[2] = CPUCharacter then goto ArenaSelectDoneDrawP2
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_5567 (duplicate)
          ;; jmp ArenaSelectDoneDrawP2 (duplicate)
skip_5567:

                    ;; if playerCharacter[2] = RandomCharacter then goto ArenaSelectDoneDrawP2
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_5444 (duplicate)
          ;; jmp ArenaSelectDoneDrawP2 (duplicate)
skip_5444:
          ;; lda # 2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


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
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4430 (duplicate)
          ;; jmp ArenaSelectDoneDrawP23 (duplicate)
skip_4430:


                    ;; if playerCharacter[3] = NoCharacter then goto ArenaSelectDoneDrawP23

                    ;; if playerCharacter[3] = CPUCharacter then goto ArenaSelectDoneDrawP23
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_1993 (duplicate)
          ;; jmp ArenaSelectDoneDrawP23 (duplicate)
skip_1993:

                    ;; if playerCharacter[3] = RandomCharacter then goto ArenaSelectDoneDrawP23
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_4106 (duplicate)
          ;; jmp ArenaSelectDoneDrawP23 (duplicate)
skip_4106:
          ;; lda # 3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


ArenaSelectDoneDrawP23
          ;; Skip Player 3/4 character drawing (not in 4-player mode or
          ;; not selected)
          ;; jsr BS_return (duplicate)

.pend

