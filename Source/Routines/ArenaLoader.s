          ;;
;;; ChaosFight - Source/Routines/ArenaLoader.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


LoadArena .proc
          ;; Arena Loader
          ;; Returns: Far (return otherbank)
          ;; Loads arena playfield data and colors based on
          ;; selectedArena.
          ;; Handles Color/B&W switch: switchbw=1 (B&W/white),
          ;; switchbw=0 (Color/row colors)
          ;; SECAM always uses B&W mode regardless of switch.
          ;; NOTE: Arena data tables are provided by the bank that
          ;; includes this file (Bank1 includes Source/Data/Arenas.bas).
          ;;
          ;; Load arena playfield data and colors based on
          ;; selectedArena
          ;;
          ;; Input: selectedArena_R (global SCRAM) = selected arena
          ;; index (0-15 or RandomArena), switchbw (global) = B&W
          ;; switch state, systemFlags (global) = system flags, frame
          ;; (global) = frame counter (for random), RandomArena (global
          ;; constant) = random arena consta

          ;;
          ;; Output: Arena playfield and colors loaded
          ;;
          ;; Mutates: temp1 (arena index), temp2 (B&W scratch), temp6
          ;; (B&W flag), pf1Pointer, pf2Pointer (TIA registers) =
          ;; playfield pointers, pfColorTable (TIA register) = color
          ;; table pointer
          ;;
          ;; Called Routines: DWS_GetBWMode (bank15), LoadArenaRandom,
          ;; LoadArenaByIndex (bank16)
          ;; Constraints: None

          ;; Handle random arena selection

          lda selectedArena_R
          cmp # RandomArena
          bne LoadArenaDispatch

          jmp LoadArenaRandom

LoadArenaDispatch:

          lda selectedArena_R
          sta temp1
          ;; Get arena index (0-15)

.pend

LoadArenaDispatch .proc
          ;; Returns: Far (return otherbank)
          ;; Cross-bank call to GetBWModeWinScreen in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterDWS_GetBWModeDispatch-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterDWS_GetBWModeDispatch hi (encoded)]
          lda # <(AfterDWS_GetBWModeDispatch-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterDWS_GetBWModeDispatch hi (encoded)] [SP+0: AfterDWS_GetBWModeDispatch lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterDWS_GetBWModeDispatch hi (encoded)] [SP+1: AfterDWS_GetBWModeDispatch lo] [SP+0: GetBWModeWinScreen hi (raw)]
          lda # <(GetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterDWS_GetBWModeDispatch hi (encoded)] [SP+2: AfterDWS_GetBWModeDispatch lo] [SP+1: GetBWModeWinScreen hi (raw)] [SP+0: GetBWModeWinScreen lo]
          ldx # 14
          jmp BS_jsr

AfterDWS_GetBWModeDispatch:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterLoadArenaByIndexDispatch-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadArenaByIndexDispatch hi (encoded)]
          lda # <(AfterLoadArenaByIndexDispatch-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadArenaByIndexDispatch hi (encoded)] [SP+0: AfterLoadArenaByIndexDispatch lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadArenaByIndex-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadArenaByIndexDispatch hi (encoded)] [SP+1: AfterLoadArenaByIndexDispatch lo] [SP+0: LoadArenaByIndex hi (raw)]
          lda # <(LoadArenaByIndex-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadArenaByIndexDispatch hi (encoded)] [SP+2: AfterLoadArenaByIndexDispatch lo] [SP+1: LoadArenaByIndex hi (raw)] [SP+0: LoadArenaByIndex lo]
          ldx # 15
          jmp BS_jsr
AfterLoadArenaByIndexDispatch:

          ;; if temp6 then jmp LA_LoadBWColors
          lda temp6
          beq LA_LoadColorColors
          jmp LA_LoadBWColors
LA_LoadColorColors:
          ;; Load color color table - fall through to LoadArenaColorsColor
          ;; Returns: Far (return otherbank)
          jmp LA_LoadColorColors
.pend

LA_LoadBWColors .proc
          ;; Load B&W color table (shared routine)
          ;; Returns: Far (return otherbank)
          jsr LoadArenaColorsBW
          jmp BS_return
.pend

LA_LoadColorColors .proc

.pend

LoadArenaColorsColor .proc

          ;; Load arena color table pointer using stride calculation
          ;; Returns: Far (return otherbank)
            lda # <Arena0Colors
            sta pfColorTable
            lda # >Arena0Colors
            sta pfColorTable+1

                    ldx temp1
            beq SetArenaColorPointerDone

AdvanceArenaColorPointer:

            clc
            lda pfColorTable
            adc # <(Arena1Colors - Arena0Colors)
            sta pfColorTable
            lda pfColorTable+1
            adc # >(Arena1Colors - Arena0Colors)
            sta pfColorTable+1
            dex
            bne AdvanceArenaColorPointer

SetArenaColorPointerDone:

          jmp BS_return

.pend

LoadArenaColorsBW .proc
          ;; Shared B&W color table loader
          ;; Returns: Near (return thisbank)
          ;;
          ;; Input: None
          ;;
          ;; Output: pfColorTable pointer set to ArenaColorsBW
          ;;
          ;; Mutates: pfColorTable (playfield color table pointer)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with LoadArena
            lda # <ArenaColorsBW
            sta pfColorTable
            lda # >ArenaColorsBW
            sta pfColorTable+1
          rts
.pend

LoadArenaRandom .proc
          ;; Select random arena (0-31) using proper random number
          ;; Returns: Far (return otherbank)
          ;; generator
          ;;
          ;; Input: rand (global) = random number generator
          ;;
          ;; Output: Random arena loaded via LoadArenaByIndex
          ;;
          ;; Mutates: temp1 (temp1 set to random value), rand
          ;; (global) = random number generator sta

          ;;
          ;; Called Routines: LoadArenaByIndex (tail call) - loads
          ;; selected random arena
          ;;
          ;; Constraints: None
          ;; Select random arena (0-31) using proper RNG
          ;; Get random value (0-255)
          lda rand
          sta temp1
          ;; Set temp1 = temp1 & 31
          lda temp1
          and # 31
          sta temp1

          lda temp1
          and # 31
          sta temp1

          ;; If temp1 > MaxArenaID, then LoadArenaRandom
          lda temp1
          cmp # MaxArenaID
          bcc LoadArenaDispatch
          jmp LoadArenaRandom
LoadArenaDispatch:
          ;; Fall through to LoadArenaDispatch logic (inline to avoid goto)
          ;; Cross-bank call to GetBWModeWinScreen in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterDWS_GetBWModeRandom-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterDWS_GetBWModeRandom hi (encoded)]
          lda # <(AfterDWS_GetBWModeRandom-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterDWS_GetBWModeRandom hi (encoded)] [SP+0: AfterDWS_GetBWModeRandom lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterDWS_GetBWModeRandom hi (encoded)] [SP+1: AfterDWS_GetBWModeRandom lo] [SP+0: GetBWModeWinScreen hi (raw)]
          lda # <(GetBWModeWinScreen-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterDWS_GetBWModeRandom hi (encoded)] [SP+2: AfterDWS_GetBWModeRandom lo] [SP+1: GetBWModeWinScreen hi (raw)] [SP+0: GetBWModeWinScreen lo]
          ldx # 14
          jmp BS_jsr
AfterDWS_GetBWModeRandom:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterLoadArenaByIndexRandom-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadArenaByIndexRandom hi (encoded)]
          lda # <(AfterLoadArenaByIndexRandom-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadArenaByIndexRandom hi (encoded)] [SP+0: AfterLoadArenaByIndexRandom lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadArenaByIndex-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadArenaByIndexRandom hi (encoded)] [SP+1: AfterLoadArenaByIndexRandom lo] [SP+0: LoadArenaByIndex hi (raw)]
          lda # <(LoadArenaByIndex-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadArenaByIndexRandom hi (encoded)] [SP+2: AfterLoadArenaByIndexRandom lo] [SP+1: LoadArenaByIndex hi (raw)] [SP+0: LoadArenaByIndex lo]
          ldx # 15
          jmp BS_jsr
AfterLoadArenaByIndexRandom:

          ;; if temp6 then jmp LAR_LoadBWColors
          lda temp6
          beq LoadArenaColorsColorLabel
          jmp LAR_LoadBWColors
LoadArenaColorsColorLabel:
          ;; Load color color table (use cross-bank call to to avoid goto)
          ;; Cross-bank call to LoadArenaColorsColor in bank 16
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterLoadArenaColorsColorRandom-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadArenaColorsColorRandom hi (encoded)]
          lda # <(AfterLoadArenaColorsColorRandom-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadArenaColorsColorRandom hi (encoded)] [SP+0: AfterLoadArenaColorsColorRandom lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadArenaColorsColor-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadArenaColorsColorRandom hi (encoded)] [SP+1: AfterLoadArenaColorsColorRandom lo] [SP+0: LoadArenaColorsColor hi (raw)]
          lda # <(LoadArenaColorsColor-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadArenaColorsColorRandom hi (encoded)] [SP+2: AfterLoadArenaColorsColorRandom lo] [SP+1: LoadArenaColorsColor hi (raw)] [SP+0: LoadArenaColorsColor lo]
          ldx # 15
          jmp BS_jsr
AfterLoadArenaColorsColorRandom:

          jmp BS_return
.pend

LAR_LoadBWColors .proc
          ;; Load B&W color table (shared routine)
          ;; Returns: Far (return otherbank)
          jsr LoadArenaColorsBW
          jmp BS_return
.pend

