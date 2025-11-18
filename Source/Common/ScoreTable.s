; ChaosFight - Source/Common/ScoreTable.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Replacement for score_graphics.asm to provide scoretable label
; The multisprite kernel expects scoretable to point to 8-byte digit graphics
; Numbers.bas provides FontData with 16-byte glyphs, so we create a compatible table

; Define scoretable label early (before ORG) so it's available across banks
; The actual data will be placed at the correct location by ORG directives
scoretable = .  ; Forward reference - will be resolved when data is placed

; Place scoretable data at end of ROM (before vectors)
; For 64kSC bankswitch, place at $FF80 (before EFSC header at $FFE0)
ifconst bankswitch
  if bankswitch == 64
    ORG $FF80-bscode_length
    RORG $FF80-bscode_length
  else
    ; For other bankswitch schemes, use standard placement
    if bankswitch == 8
      ORG $2F94-bscode_length
      RORG $FF94-bscode_length
    endif
    if bankswitch == 16
      ORG $4F94-bscode_length
      RORG $FF94-bscode_length
    endif
    if bankswitch == 32
      ORG $8F94-bscode_length
      RORG $FF94-bscode_length
    endif
  endif
 else
  ORG $FF9C
 endif

; scoretable label defined above, data placed here
; Provide 8-byte digit graphics compatible with multisprite kernel
; Each digit is 8 bytes (8 pixels high)
; Digits 0-9 (10 digits × 8 bytes = 80 bytes total)
; These match the default font from score_graphics.asm

; Digit 0
 .byte %00111100
 .byte %01100110
 .byte %01100110
 .byte %01100110
 .byte %01100110
 .byte %01100110
 .byte %01100110
 .byte %00111100

; Digit 1
 .byte %01111110
 .byte %00011000
 .byte %00011000
 .byte %00011000
 .byte %00011000
 .byte %00111000
 .byte %00011000
 .byte %00001000

; Digit 2
 .byte %01111110
 .byte %01100000
 .byte %01100000
 .byte %00111100
 .byte %00000110
 .byte %00000110
 .byte %01000110
 .byte %00111100

; Digit 3
 .byte %00111100
 .byte %01000110
 .byte %00000110
 .byte %00000110
 .byte %00011100
 .byte %00000110
 .byte %01000110
 .byte %00111100

; Digit 4
 .byte %00001100
 .byte %00001100
 .byte %01111110
 .byte %01001100
 .byte %01001100
 .byte %00101100
 .byte %00011100
 .byte %00001100

; Digit 5
 .byte %00111100
 .byte %01000110
 .byte %00000110
 .byte %00000110
 .byte %00111100
 .byte %01100000
 .byte %01100000
 .byte %01111110

; Digit 6
 .byte %00111100
 .byte %01100110
 .byte %01100110
 .byte %01100110
 .byte %01111100
 .byte %01100000
 .byte %01100010
 .byte %00111100

; Digit 7
 .byte %00110000
 .byte %00110000
 .byte %00110000
 .byte %00011000
 .byte %00001100
 .byte %00000110
 .byte %01000010
 .byte %00111110

; Digit 8
 .byte %00111100
 .byte %01100110
 .byte %01100110
 .byte %01100110
 .byte %00111100
 .byte %01100110
 .byte %01100110
 .byte %00111100

; Digit 9
 .byte %00111100
 .byte %01000110
 .byte %00000110
 .byte %00000110
 .byte %00111110
 .byte %01100110
 .byte %01100110
 .byte %00111100

; Blank digit (for padding/empty score positions)
 .byte %00000000
 .byte %00000000
 .byte %00000000
 .byte %00000000
 .byte %00000000
 .byte %00000000
 .byte %00000000
 .byte %00000000

