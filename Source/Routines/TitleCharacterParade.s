;; ChaosFight - Source/Routines/TitleCharacterParade.bas
;; Copyright © 2025 Bruce-Robert Pocock.

UpdateCharacterParade .proc
           ;; Title Screen Character Parade
           ;; Returns: Far (return otherbank)

           ;; Manages the animated character parade that runs across the bottom of the title screen after 5 seconds (when copyright disappears).

           ;; AVAILABLE VARIABLES (from Variables.bas):
           ;; titleParadeTimer - Frame counter (increments each frame)

           ;; titleParadeCharacter - Current character index (0-MaxCharacter)

           ;; titleParadeX - X position of parade character

           ;; titleParadeActive - Boolean: parade currently running

           ;; TIMING:

           ;; - Parade starts after ~4 seconds (TitleParadeDelayFrames frames, TV-dependent)

           ;; - Each character moves at 2 pixels/frame (left to right)

           ;; - 1 second pause (FramesPerSecond frames) between characters

           ;; - Characters chosen randomly from NumCharacters available

           ;; CHARACTER INDICES:

           ;; 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=EXO, 4=FatTony,

           ;; 5=Grizzard,

           ;; 6=Harpy, 7=Knight Guy, 8=Frooty, 9=Nefertem, 10=Ninjish

           ;; Guy,

           ;; 11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo,

           ;; 15=Shamone

           ;; Update parade state (called every frame)

           ;; Manages the animated character parade that runs across the bottom of the title screen

           ;; Input: titleParadeTimer (global) = frame counter

           ;; titleParadeActive (global) = parade active flag

           ;; TitleParadeDelayFrames (constant) = delay before parade starts

           ;; Output: titleParadeTimer incremented, parade state updated

           ;; (set via StartNewParadeCharacter, MoveParadeCharacter)

           ;; titleParadeCharacter, titleParadeX (set via StartNewParadeCharacter, MoveParadeCharacter)

           ;; Constraints: Must be colocated with StartNewParadeCharacter, MoveParadeCharacter, ParadeCharacterLeft (all called via goto)

           ;; Called every frame from TitleScreenMain

           ;; Increment parade timer

           inc titleParadeTimer

           ;; Start parade after ~4 seconds (TitleParadeDelayFrames frames)

           lda titleParadeTimer

           cmp # TitleParadeDelayFrames

           bcc StartParadeNotYet

           lda titleParadeActive

           bne MoveParadeCharacter

           jmp StartNewParadeCharacter

StartParadeNotYet:

           jmp BS_return

MoveParadeCharacter:

           ;; Move 2 pixels per frame

           lda titleParadeX

           clc

           adc # 2

           sta titleParadeX

           ;; Check if character has left screen

           lda titleParadeX

           cmp # 170

           bcs ParadeCharacterLeft  ; branch if carry set (x >= 170)

UpdateCharacterParadeDone:

           jmp BS_return

ParadeCharacterLeft:

           ;; Character has left - wait 1 second (FramesPerSecond frames) before next character

           ;; Returns: Far (return otherbank)

           ;; Input: titleParadeTimer, titleParadeActive (from UpdateCharacterParade)

           ;; Output: titleParadeActive set to 0, titleParadeTimer decremented by FramesPerSecond

           lda # 0

           sta titleParadeActive

           ;; Reset timer for next character

           ;; Set titleParadeTimer = titleParadeTimer - FramesPerSecond (decremented twice for 1 second)

           lda titleParadeTimer

           sec

           sbc #FramesPerSecond

           sta titleParadeTimer

           lda titleParadeTimer

           sec

           sbc #FramesPerSecond

           sta titleParadeTimer

           jmp BS_return

.pend

StartNewParadeCharacter .proc

           jmp Roll

.pend

Roll .proc

           ;; Returns: Far (return otherbank)

           lda rand

           and #$1f

           sta titleParadeCharacter

           ;; Random character 0-MaxCharacter

           ;; Returns: Far (return otherbank)

           ;; If titleParadeCharacter > MaxCharacter, then Roll

           lda titleParadeCharacter

           cmp # MaxCharacter

           bcc CheckRollDone

           jmp Roll

CheckRollDone:

           ;; Start off-screen left

           lda # 246

           sta titleParadeX

           lda # 1

           sta titleParadeActive

           jmp BS_return

.pend

MoveParadeCharacter .proc

           ;; Move character across screen

           ;; Returns: Far (return otherbank)

           ;; Input: titleParadeX (global) = current X position

           ;; Output: titleParadeX incremented by 2, dispatches to ParadeCharacterLeft if off-screen

           ;; Mutates: titleParadeX (incremented by 2)

           lda titleParadeX

           clc

           adc # 2

           sta titleParadeX

           UpdateCharacterParadeDone:

           jmp BS_return

ParadeCharacterLeft .proc

           ;; Character has left - wait 1 second (FramesPerSecond frames) before next character

           ;; Returns: Far (return otherbank)

           lda # 0

           sta titleParadeActive

           lda titleParadeTimer

           sec

           sbc #FramesPerSecond

           sta titleParadeTimer

           lda titleParadeTimer

           sec

           sbc #FramesPerSecond

           sta titleParadeTimer

           jmp BS_return

.pend
DrawParadeCharacter .proc
           ;; Draw Parade Character
           ;; Returns: Far (return otherbank)
           ;; Render the current parade character at the bottom of the screen
           ;; Input: titleParadeCharacter, titleParadeX, controllerStatus, rand
           ;; Output: player0x, player0y set, COLUP0 set, sprite drawn
           ;; Mutates: player0x, player0y (TIA registers), COLUP0 (TIA register)
           ;; Constraints: Must be colocated with DrawParadeCharacterSprite (tail call)

           ;; Position character at bottom (y=80) and current X position
           lda titleParadeX
           sta player0x
           lda # 80
           sta player0y

           ;; Always face right while marching across the title screen
           lda # PlayerStateBitFacing
           sta REFP0

           ;; Parade render uses fixed white color
           lda # $0C
           sta COLUP0

           jmp DrawParadeCharacterSprite

.pend

DrawParadeCharacterSprite .proc
           ;; Draw Parade Character Sprite
           ;; Returns: Far (return otherbank)
           ;; Load actual character artwork for the parade sprite

           lda titleParadeCharacter
           sta currentCharacter

           lda # 0
           sta currentPlayer

           ;; Set temp2 = titleParadeTimer & 7
           lda titleParadeTimer
           and # 7
           sta temp2

           lda # ActionWalking
           sta temp3

           ;; Cross-bank call to LoadCharacterSprite in bank 15
           lda # ((>(AfterLoadCharacterSpriteParade-1)) & $0f) | $d0
           pha
           lda # <(AfterLoadCharacterSpriteParade-1)
           pha
           lda # >(LoadCharacterSprite-1)
           pha
           lda # <(LoadCharacterSprite-1)
           pha
           ldx # 15
           jmp BS_jsr
AfterLoadCharacterSpriteParade:

           jmp BS_return

.pend
