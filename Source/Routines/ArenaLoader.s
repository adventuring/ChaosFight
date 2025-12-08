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
          cmp RandomArena
          bne skip_5483
          ;; TODO: LoadArenaRandom
skip_5483:


          ;; lda selectedArena_R (duplicate)
          sta temp1
          ;; Get arena index (0-15)

.pend

LoadArenaDispatch .proc
          ;; Returns: Far (return otherbank)
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DWS_GetBWMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DWS_GetBWMode-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
return_point:

          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadArenaByIndex-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadArenaByIndex-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

                    ;; if temp6 then goto LA_LoadBWColors
          ;; lda temp6 (duplicate)
          beq skip_9916
          ;; jmp LA_LoadBWColors (duplicate)
skip_9916:
          ;; Load color color table - fall through to LoadArenaColorsColor
          ;; Returns: Far (return otherbank)
          ;; jmp LA_LoadColorColors (duplicate)
.pend

LA_LoadBWColors .proc
          ;; Load B&W color table (shared routine)
          ;; Returns: Far (return otherbank)
          jsr LoadArenaColorsBW
          ;; jsr BS_return (duplicate)
.pend

LA_LoadColorColors .proc

.pend

LoadArenaColorsColor .proc

          ;; Load arena color table pointer using stride calculation
          ;; Returns: Far (return otherbank)
            ;; lda # <Arena0Colors (duplicate)
            ;; sta pfcolortable (duplicate)
            ;; lda # >Arena0Colors (duplicate)
            ;; sta pfcolortable+1 (duplicate)

                    ;; ldx temp1 (duplicate)
            ;; beq SetArenaColorPointerDone (duplicate)

AdvanceArenaColorPointer:

            clc
            ;; lda pfcolortable (duplicate)
            adc # <(Arena1Colors - Arena0Colors)
            ;; sta pfcolortable (duplicate)
            ;; lda pfcolortable+1 (duplicate)
            ;; adc # >(Arena1Colors - Arena0Colors) (duplicate)
            ;; sta pfcolortable+1 (duplicate)
            dex
            ;; bne AdvanceArenaColorPointer (duplicate)

SetArenaColorPointerDone:

          ;; jsr BS_return (duplicate)

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
            ;; lda # <ArenaColorsBW (duplicate)
            ;; sta pfcolortable (duplicate)
            ;; lda # >ArenaColorsBW (duplicate)
            ;; sta pfcolortable+1 (duplicate)
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
          ;; lda rand (duplicate)
          ;; sta temp1 (duplicate)
          ;; ;; let temp1 = temp1 & 31
          ;; lda temp1 (duplicate)
          and # 31
          ;; sta temp1 (duplicate)

          ;; lda temp1 (duplicate)
          ;; and # 31 (duplicate)
          ;; sta temp1 (duplicate)

                    ;; if temp1 > MaxArenaID then LoadArenaRandom
          ;; Fall through to LoadArenaDispatch logic (inline to avoid goto)
          ;; Cross-bank call to DWS_GetBWMode in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DWS_GetBWMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DWS_GetBWMode-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Cross-bank call to LoadArenaByIndex in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadArenaByIndex-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadArenaByIndex-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

                    ;; if temp6 then goto LAR_LoadBWColors
          ;; lda temp6 (duplicate)
          ;; beq skip_4691 (duplicate)
          ;; jmp LAR_LoadBWColors (duplicate)
skip_4691:
          ;; Load color color table (use gosub to avoid goto)
          ;; Cross-bank call to LoadArenaColorsColor in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadArenaColorsColor-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadArenaColorsColor-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; jsr BS_return (duplicate)
.pend

LAR_LoadBWColors .proc
          ;; Load B&W color table (shared routine)
          ;; Returns: Far (return otherbank)
          ;; jsr LoadArenaColorsBW (duplicate)
          ;; jsr BS_return (duplicate)
.pend

