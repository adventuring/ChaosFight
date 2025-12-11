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
          ;; (B&W flag), PF1pointer, PF2pointer (TIA registers) =
          ;; playfield pointers, pfcolortable (TIA register) = color
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
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          lda # >(AfterDWS_GetBWModeDispatch-1)
          pha
          lda # <(AfterDWS_GetBWModeDispatch-1)
          pha
          lda # >(DWS_GetBWMode-1)
          pha
          lda # <(DWS_GetBWMode-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterDWS_GetBWModeDispatch:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          lda # >(AfterLoadArenaByIndexDispatch-1)
          pha
          lda # <(AfterLoadArenaByIndexDispatch-1)
          pha
          lda # >(LoadArenaByIndex-1)
          pha
          lda # <(LoadArenaByIndex-1)
          pha
          ldx # 15
          jmp BS_jsr
AfterLoadArenaByIndexDispatch:

          ;; if temp6 then goto LA_LoadBWColors
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
            sta pfcolortable
            lda # >Arena0Colors
            sta pfcolortable+1

                    ldx temp1
            beq SetArenaColorPointerDone

AdvanceArenaColorPointer:

            clc
            lda pfcolortable
            adc # <(Arena1Colors - Arena0Colors)
            sta pfcolortable
            lda pfcolortable+1
            adc # >(Arena1Colors - Arena0Colors)
            sta pfcolortable+1
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
          ;; Output: pfcolortable pointer set to ArenaColorsBW
          ;;
          ;; Mutates: pfcolortable (playfield color table pointer)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with LoadArena
            lda # <ArenaColorsBW
            sta pfcolortable
            lda # >ArenaColorsBW
            sta pfcolortable+1
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
          ;; let temp1 = temp1 & 31
          lda temp1
          and # 31
          sta temp1

          lda temp1
          and # 31
          sta temp1

                    if temp1 > MaxArenaID then LoadArenaRandom
          ;; Fall through to LoadArenaDispatch logic (inline to avoid goto)
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          lda # >(AfterDWS_GetBWModeRandom-1)
          pha
          lda # <(AfterDWS_GetBWModeRandom-1)
          pha
          lda # >(DWS_GetBWMode-1)
          pha
          lda # <(DWS_GetBWMode-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterDWS_GetBWModeRandom:

          lda temp2
          sta temp6
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          lda # >(AfterLoadArenaByIndexRandom-1)
          pha
          lda # <(AfterLoadArenaByIndexRandom-1)
          pha
          lda # >(LoadArenaByIndex-1)
          pha
          lda # <(LoadArenaByIndex-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadArenaByIndexRandom:

          ;; if temp6 then goto LAR_LoadBWColors
          lda temp6
          beq LoadArenaColorsColor
          jmp LAR_LoadBWColors
LoadArenaColorsColor:
          ;; Load color color table (use gosub to avoid goto)
          ;; Cross-bank call to LoadArenaColorsColor in bank 16
          lda # >(AfterLoadArenaColorsColorRandom-1)
          pha
          lda # <(AfterLoadArenaColorsColorRandom-1)
          pha
          lda # >(LoadArenaColorsColor-1)
          pha
          lda # <(LoadArenaColorsColor-1)
          pha
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

