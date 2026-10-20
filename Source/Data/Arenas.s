;;; Colors.s is included in Preamble.s - do not include here
Arenas_rem_label_1:

;;; ChaosFight - Source/Data/Arenas.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Arena playfield data (not generated - edit manually)
;;;
;;; Each arena occupies 24 bytes, in this order:
;;;   +0 .. +7   PF1 column bytes, rows 7..0 (bottom to top)
;;;   +8 .. +15  PF2 column bytes, rows 7..0 (bottom to top)
;;;   +16 .. +23 eight row-colour bytes (Colour mode); B&W uses ArenaColorsBW
;;; PF1 = source char 0 (bit 7) .. char 7 (bit 0)
;;; PF2 = source char 15 (bit 7) .. char 8 (bit 0)
Arenas_rem_label_2_1:

ArenaColorsBWStart
ArenaColorsBW:
          .byte 14, 14, 14, 14, 14, 14, 14, 14
ArenaColorsBW_end:
ArenaColorsBWEnd

BlankPlayfieldStart
BlankPlayfield:
Arenas_playfield_1:
          .byte 0, 0, 0, 0, 0, 0, 0, 0
          .byte 0, 0, 0, 0, 0, 0, 0, 0
BlankPlayfieldEnd

BlankPlayfieldColorsStart
BlankPlayfieldColors:
          .byte 14, 14, 14, 14, 14, 14, 14, 14
BlankPlayfieldColors_end:
BlankPlayfieldColorsEnd

Arena0PlayfieldStart

Arena0Playfield
Arena0Playfield_playfield:
          .byte $FF, $80, $80, $80
          .byte $80, $80, $80, $FF
          .byte $FF, $00, $00, $00
          .byte $00, $00, $00, $FF
Arena0Colors:
          .byte $22, $24, $26, $28, $2A, $2C, $2E, $20
Arena0Colors_end:
Arena1Playfield
Arena1Playfield_playfield:
          .byte $FF, $80, $80, $8F
          .byte $80, $80, $80, $80
          .byte $FF, $00, $00, $00
          .byte $00, $FF, $00, $00
Arena1Colors:
          .byte $94, $94, $96, $94, $96, $94, $94, $92
Arena1Colors_end:
Arena2Playfield
Arena2Playfield_playfield:
          .byte $FF, $80, $80, $F8
          .byte $00, $00, $80, $F8
          .byte $FF, $00, $00, $F0
          .byte $00, $00, $00, $00
Arena2Colors:
          .byte $94, $94, $96, $94, $96, $94, $94, $92
Arena2Colors_end:
Arena3Playfield
Arena3Playfield_playfield:
          .byte $FF, $80, $80, $80
          .byte $80, $80, $80, $80
          .byte $FF, $00, $00, $F0
          .byte $F0, $F0, $00, $00
Arena3Colors:
          .byte $C2, $C2, $C4, $C4, $C4, $C2, $C2, $C6
Arena3Colors_end:
Arena4Playfield
Arena4Playfield_playfield:
          .byte $00, $00, $00, $0F
          .byte $0F, $00, $00, $00
          .byte $00, $00, $00, $0F
          .byte $0F, $00, $00, $00
Arena4Colors:
          .byte $1C, $1C, $1C, $1E, $1E, $1C, $1C, $1C
Arena4Colors_end:
Arena5Playfield
Arena5Playfield_playfield:
          .byte $FF, $F0, $C0, $80
          .byte $80, $C0, $F0, $FC
          .byte $FF, $00, $00, $00
          .byte $00, $00, $00, $00
Arena5Colors:
          .byte $84, $84, $84, $84, $84, $84, $84, $84
Arena5Colors_end:
          ;; Arena 6: Multi-Platform (multiple small platforms)
Arena6Playfield
Arena6Playfield_playfield:
          .byte $FF, $80, $FC, $80
          .byte $83, $80, $9F, $80
          .byte $FF, $00, $00, $00
          .byte $03, $00, $00, $00
Arena6Colors:
          .byte $42, $44, $42, $46, $42, $44, $42, $48
Arena6Colors_end:
          ;; Arena 7: The Gauntlet (maze-like walls)
Arena7Playfield
Arena7Playfield_playfield:
          .byte $FF, $80, $FF, $00
          .byte $00, $E0, $81, $81
          .byte $FF, $00, $00, $00
          .byte $00, $00, $07, $07
Arena7Colors:
          .byte $F2, $F2, $F2, $F4, $F2, $F4, $F2, $F6
Arena7Colors_end:
Arena8Playfield
Arena8Playfield_playfield:
          .byte $FF, $8F, $80, $80
          .byte $80, $8F, $80, $FF
          .byte $FF, $00, $00, $0F
          .byte $00, $00, $00, $FF
Arena8Colors:
          .byte $62, $64, $66, $64, $66, $64, $66, $62
Arena8Colors_end:
Arena9Playfield
Arena9Playfield_playfield:
          .byte $FF, $80, $BC, $80
          .byte $80, $BC, $80, $FF
          .byte $FF, $00, $3C, $00
          .byte $00, $3C, $00, $FF
Arena9Colors:
          .byte $42, $44, $46, $44, $44, $46, $44, $42
Arena9Colors_end:
          ;; Arena 10: Sky Battlefield (variant of Arena 2 with
Arena10Playfield
Arena10Playfield_playfield:
          .byte $FF, $80, $80, $8F
          .byte $80, $FC, $80, $8F
          .byte $FF, $00, $00, $0F
          .byte $00, $FC, $00, $0F
Arena10Colors:
          .byte $A4, $A2, $A6, $A2, $A4, $A2, $A2, $A8
Arena10Colors_end:
          ;; Arena 11: Floating Platforms (variant of Arena 3 with four
Arena11Playfield
Arena11Playfield_playfield:
          .byte $FF, $80, $80, $BC
          .byte $BC, $BC, $BC, $80
          .byte $FF, $00, $00, $3C
          .byte $3C, $3C, $3C, $00
Arena11Colors:
          .byte $D2, $D4, $D4, $D6, $D6, $D2, $D2, $D8
Arena11Colors_end:
          ;; Arena 12: The Chasm (variant of Arena 4 with wider bridge)
Arena12Playfield
Arena12Playfield_playfield:
          .byte $00, $00, $00, $3F
          .byte $3F, $3F, $00, $00
          .byte $00, $00, $00, $3F
          .byte $3F, $3F, $00, $00
Arena12Colors:
          .byte $2C, $2C, $2E, $2E, $2E, $2C, $2C, $2C
Arena12Colors_end:
          ;; Arena 13: Fortress Walls (variant of Arena 5 with
Arena13Playfield
Arena13Playfield_playfield:
          .byte $E7, $C3, $81, $00
          .byte $00, $81, $C3, $E7
          .byte $CF, $C3, $81, $00
          .byte $00, $81, $C3, $CF
Arena13Colors:
          .byte $94, $94, $96, $92, $92, $96, $94, $94
Arena13Colors_end:
          ;; Arena 14: Floating Islands (variant of Arena 6 with more
Arena14Playfield
Arena14Playfield_playfield:
          .byte $FF, $BC, $80, $66
          .byte $80, $BC, $80, $66
          .byte $FF, $3C, $00, $66
          .byte $00, $3C, $00, $66
Arena14Colors:
          .byte $52, $50, $54, $50, $52, $50, $54, $58
Arena14Colors_end:
          ;; Arena 15: The Labyrinth (variant of Arena 7 with more
Arena15Playfield
Arena15Playfield_playfield:
          .byte $F3, $03, $30, $0F
          .byte $F0, $0C, $80, $CF
          .byte $F3, $30, $00, $F0
          .byte $00, $0C, $00, $CC
Arena15Colors:
          .byte $E2, $E2, $E4, $E6, $E6, $E4, $E2, $E8
Arena15Colors_end:
          ;; Arena 16: Danger Zone (variant of Arena 8 with alternating
Arena16Playfield
Arena16Playfield_playfield:
          .byte $D5, $D5, $80, $D5
          .byte $80, $D5, $80, $D5
          .byte $AA, $AA, $00, $AA
          .byte $00, $AA, $00, $AA
Arena16Colors:
          .byte $72, $74, $76, $74, $76, $74, $76, $78
Arena16Colors_end:
          ;; Arena 17: The Spire (vertical tower platforms)
Arena17Playfield
Arena17Playfield_playfield:
          .byte $FF, $81, $80, $81
          .byte $80, $81, $80, $FF
          .byte $FF, $01, $00, $01
          .byte $00, $01, $00, $FF
Arena17Colors:
          .byte $D2, $D4, $D6, $D4, $D6, $D4, $D2, $D8
Arena17Colors_end:
          ;; Arena 18: The Bridge (wide center platform)
Arena18Playfield
Arena18Playfield_playfield:
          .byte $00, $00, $00, $FF
          .byte $FF, $00, $00, $00
          .byte $00, $00, $00, $FF
          .byte $FF, $00, $00, $00
Arena18Colors:
          .byte $BC, $BC, $BC, $BE, $BE, $BC, $BC, $BC
Arena18Colors_end:
          ;; Arena 19: The Pits (narrow platforms with gaps)
Arena19Playfield
Arena19Playfield_playfield:
          .byte $F0, $F0, $00, $F0
          .byte $F0, $00, $F0, $F0
          .byte $F0, $F0, $00, $F0
          .byte $F0, $00, $F0, $F0
Arena19Colors:
          .byte $42, $42, $40, $42, $42, $40, $42, $44
Arena19Colors_end:
          ;; Arena 20: The Stairs (stepped platforms)
Arena20Playfield
Arena20Playfield_playfield:
          .byte $FF, $80, $80, $C0
          .byte $C0, $F0, $F0, $FF
          .byte $FF, $00, $00, $00
          .byte $00, $00, $00, $FF
Arena20Colors:
          .byte $84, $84, $84, $86, $86, $88, $88, $82
Arena20Colors_end:
          ;; Arena 21: The Grid (checkerboard pattern)
Arena21Playfield
Arena21Playfield_playfield:
          .byte $33, $33, $CC, $CC
          .byte $33, $33, $CC, $CC
          .byte $CC, $CC, $33, $33
          .byte $CC, $CC, $33, $33
Arena21Colors:
          .byte $24, $24, $26, $26, $24, $24, $26, $26
Arena21Colors_end:
          ;; Arena 22: The Columns (vertical pillars)
Arena22Playfield
Arena22Playfield_playfield:
          .byte $92, $92, $92, $92
          .byte $92, $92, $92, $92
          .byte $92, $92, $92, $92
          .byte $92, $92, $92, $92
Arena22Colors:
          .byte $44, $44, $44, $44, $44, $44, $44, $46
Arena22Colors_end:
          ;; Arena 23: The Waves (curved platforms)
Arena23Playfield
Arena23Playfield_playfield:
          .byte $FF, $FF, $F0, $F0
          .byte $FF, $F0, $F0, $FF
          .byte $FF, $FF, $00, $00
          .byte $FF, $00, $00, $FF
Arena23Colors:
          .byte $A2, $A4, $A4, $A2, $A4, $A4, $A2, $A6
Arena23Colors_end:
          ;; Arena 24: The Cross (cross-shaped platform)
Arena24Playfield
Arena24Playfield_playfield:
          .byte $F0, $F0, $F0, $FF
          .byte $FF, $F0, $F0, $F0
          .byte $0F, $0F, $0F, $FF
          .byte $FF, $0F, $0F, $0F
Arena24Colors:
          .byte $04, $04, $04, $06, $06, $04, $04, $04
Arena24Colors_end:
          ;; Arena 25: The Maze (complex wall pattern)
Arena25Playfield
Arena25Playfield_playfield:
          .byte $FF, $40, $5E, $52
          .byte $52, $5E, $40, $FF
          .byte $FF, $81, $BD, $A5
          .byte $A5, $BD, $81, $FF
Arena25Colors:
          .byte $62, $64, $66, $68, $68, $66, $64, $62
Arena25Colors_end:
          ;; Arena 26: The Islands (scattered platforms)
Arena26Playfield
Arena26Playfield_playfield:
          .byte $C0, $C0, $00, $0F
          .byte $0F, $00, $C0, $C0
          .byte $C0, $C0, $00, $03
          .byte $03, $00, $C0, $C0
Arena26Colors:
          .byte $32, $32, $30, $34, $34, $30, $32, $32
Arena26Colors_end:
          ;; Arena 27: The Rings (concentric platforms)
Arena27Playfield
Arena27Playfield_playfield:
          .byte $FF, $80, $BF, $A0
          .byte $A0, $BF, $80, $FF
          .byte $FF, $80, $BF, $A0
          .byte $A0, $BF, $80, $FF
Arena27Colors:
          .byte $12, $14, $16, $18, $18, $16, $14, $12
Arena27Colors_end:
          ;; Arena 28: The Slopes (diagonal platforms)
Arena28Playfield
Arena28Playfield_playfield:
          .byte $FF, $7F, $3F, $1F
          .byte $1F, $3F, $7F, $FF
          .byte $FF, $7F, $3F, $1F
          .byte $1F, $3F, $7F, $FF
Arena28Colors:
          .byte $D2, $D4, $D6, $D8, $D8, $D6, $D4, $D2
Arena28Colors_end:
          ;; Arena 29: The Zigzag (zigzag pattern)
Arena29Playfield
Arena29Playfield_playfield:
          .byte $F0, $3C, $0F, $03
          .byte $03, $0F, $3C, $F0
          .byte $F0, $3C, $03, $03
          .byte $03, $03, $3C, $F0
Arena29Colors:
          .byte $52, $54, $56, $54, $54, $56, $54, $52
Arena29Colors_end:
          ;; Arena 30: The Ladder (vertical rungs)
Arena30Playfield
Arena30Playfield_playfield:
          .byte $92, $92, $92, $92
          .byte $92, $92, $92, $92
          .byte $92, $92, $92, $92
          .byte $92, $92, $92, $92
Arena30Colors:
          .byte $E4, $E4, $E4, $E4, $E4, $E4, $E4, $E6
Arena30Colors_end:
          ;; Arena 31: The Final Battle (complex multi-platform)
Arena31Playfield
Arena31Playfield_playfield:
          .byte $FF, $80, $B3, $B3
          .byte $80, $B3, $B3, $FF
          .byte $FF, $80, $6C, $6C
          .byte $80, $6C, $6C, $FF
Arena31Colors:
          .byte $02, $04, $04, $06, $04, $04, $06, $08
Arena31Colors_end:

Arena31PlayfieldEnd:
Bank15AfterArenas:
