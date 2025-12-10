Winner_rem_label_1:

;;; ChaosFight - Source/Data/WinnerScreen.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Winner screen Winner_playfield_1 data (pfres=8, 16×8 reflecting)
          ;; MUST be in Bank16 - playfields always must be in Bank16

          ;; Winner Screen Playfield Data
          ;; 16 columns × 8 rows (pfres=8, reflecting mode)
          ;; Design: Central high podium for winner, side platforms for
          ;; 2nd/3rd
          ;; Row 4: Central high platform (winner podium)
          ;; Row 6: Left and right platforms (2nd/3rd place)

Winner_asm_1:

WinnerScreenPlayfield:
data_end_1:
WinnerScreenPlayfield
Winner_playfield_1:

            .byte 0, 0
            .byte 0, 0
            .byte 0, 15
            .byte 0, 15
            .byte 0, 15
            .byte 15, 255
            .byte 15, 255
.byte 255, 255

data_end_2:

WinnerScreenColorsColor:
WinnerScreenColorsColor:

          .byte $FE, $FC, $FA, $F8, $F6, $F4, $F2, $F2

WinnerScreenColorsColor_end:

