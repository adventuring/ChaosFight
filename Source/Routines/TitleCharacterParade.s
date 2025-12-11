;;; ChaosFight - Source/Routines/TitleCharacterParade.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




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

          ;; Manages the animated character parade that runs across the

          ;; bottom of the title screen

          ;;
          ;; Input: titleParadeTimer (global) = frame counter

          ;; titleParadeActive (global) = parade active flag

          ;; TitleParadeDelayFrames (constant) = delay before

          ;; parade sta


          ;;
          ;; Output: titleParadeTimer incremented, parade state updated

          ;;
          ;; Mutates: titleParadeTimer (incremented), titleParadeActive

          ;; (set via StartNewParadeCharacter),

          ;; titleParadeCharacter, titleParadeX (set via

          ;; StartNewParadeCharacter, MoveParadeCharacter)

          ;;
          ;; Called Routines: StartNewParadeCharacter - accesses rand,

          ;; MaxCharacter,

          ;; MoveParadeCharacter - accesses titleParadeX

          ;;
          ;; Constraints: Must be colocated with

          ;; StartNewParadeCharacter, MoveParadeCharacter,

          ;; ParadeCharacterLeft (all called via goto)

          ;; Called every frame from TitleScreenMain

          ;; Increment parade timer

          inc titleParadeTimer



          ;; Start parade after ~4 seconds (TitleParadeDelayFrames frames)

          jmp BS_return



          ;; Check if we need to start a new character

          lda titleParadeActive
          bne MoveParadeCharacter
          jmp StartNewParadeCharacter
MoveParadeCharacter:




          ;; Move character across screen (if active)

          jmp MoveParadeCharacter



.pend

StartNewParadeCharacter .proc

          ;; Start new character parade
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: rand (global) = random number generator,

          ;; MaxCharacter (constant) = maximum character index

          ;;
          ;; Output: titleParadeCharacter set to random character,

          ;; titleParadeX set to 246, titleParadeActive set to 1

          ;;
          ;; Mutates: titleParadeCharacter (set to random 0-MaxCharacter),

          ;; titleParadeX (set to 246),

          ;; titleParadeActive (set to 1)

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with UpdateCharacterParade

.pend

Roll .proc
          ;; Returns: Far (return otherbank)

          lda rand
          and #$1f
          sta titleParadeCharacter

          ;; Random character 0-MaxCharacter
          ;; Returns: Far (return otherbank)

                    if titleParadeCharacter > MaxCharacter then Roll

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

          ;;
          ;; Input: titleParadeX (global) = current X position

          ;;
          ;; Output: titleParadeX incremented by 2, dispatches to

          ;; ParadeCharacterLeft if off-screen

          ;;
          ;; Mutates: titleParadeX (incremented by 2)

          ;;
          ;; Called Routines: None (dispatcher only)

          ;; Constraints: Must be colocated with UpdateCharacterParade, ParadeCharacterLeft

          ;; Move 2 pixels per frame

          lda titleParadeX
          clc
          adc # 2
          sta titleParadeX



          ;; Check if character has left screen

          lda titleParadeX
          cmp # 171
          bcc UpdateCharacterParadeDone
          jmp ParadeCharacterLeft
UpdateCharacterParadeDone:


          jmp BS_return

.pend

ParadeCharacterLeft .proc

          ;; Character has left - wait 1 second (FramesPerSecond frames) before next
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: titleParadeTimer, titleParadeActive (from

          ;; UpdateCharacterParade)

          ;;
          ;; Output: titleParadeActive set to 0, titleParadeTimer

          ;; decremented by FramesPerSecond

          ;;
          ;; Mutates: titleParadeActive (set to 0), titleParadeTimer

          ;; (decremented by FramesPerSecond)

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with UpdateCharacterParade

          lda # 0
          sta titleParadeActive

          ;; Reset timer for next character

          ;; let titleParadeTimer = titleParadeTimer - FramesPerSecond          lda titleParadeTimer          sec          sbc FramesPerSecond          sta titleParadeTimer
          lda titleParadeTimer
          sec
          sbc FramesPerSecond
          sta titleParadeTimer

          lda titleParadeTimer
          sec
          sbc FramesPerSecond
          sta titleParadeTimer


          jmp BS_return

.pend

DrawParadeCharacter .proc




          ;;
          ;; Returns: Far (return otherbank)

          ;; Draw Parade Character

          ;; Render the current parade character at the bottom of the screen.

          ;; Input: titleParadeCharacter, titleParadeX, controllerStatus, rand

          ;;
          ;; Output: player0x, player0y set, COLUP0 set, sprite drawn

          ;; via DrawParadeCharacterSprite

          ;;
          ;; Mutates: player0x, player0y (TIA registers),

          ;; COLUP0 (TIA register), currentCharacter, currentPlayer,

          ;; temp2-temp3 (LoadCharacterSprite parameters)

          ;;
          ;; Called Routines: DrawParadeCharacterSprite (bank14, colocated) - draws

          ;; character sprite

          ;;
          ;; Constraints: Must be colocated with DrawParadeCharacterSprite

          ;; (tail call)

          ;; Position character at bottom (y=80) and current X position

          player0x = titleParadeX

          player0y = 80



          ;; Always face right while marching across the title screen

          REFP0 = PlayerStateBitFacing



          ;; Parade render uses fixed white color

          COLUP0 = ColGray(12)



.pend

DrawParadeCharacterSprite .proc

          ;;
          ;; Returns: Far (return otherbank)

          ;; Draw Parade Character Sprite

          ;; Load actual character artwork for the parade sprite using

          ;; the character art system.

          ;;
          ;; Input: titleParadeTimer (animation timing), titleParadeCharacter

          ;; Output: Player 0 sprite data populated in SCRAM buffers

          ;; Uses default walking animation for parade march

          lda titleParadeCharacter
          sta currentCharacter

          lda # 0
          sta currentPlayer

          ;; let temp2 = titleParadeTimer & 7
          lda titleParadeTimer
          and # 7
          sta temp2

          lda titleParadeTimer
          and # 7
          sta temp2


          lda ActionWalking
          sta temp3

          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(return_point-1)
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

