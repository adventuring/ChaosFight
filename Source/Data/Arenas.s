.include "Source/Common/Colors.s"
  ;;; Commented out - Colors.s already included via Preamble.s
Arenas_rem_label_1:

;;; ChaosFight - Source/Data/Arenas%0bas
;;; Copyright © 2025 Bruce-Robert Pocock%0
          ;; Arena Arenas_playfield_1 data (not generated - edit manually)
Arenas_rem_label_2_1:

          ;; high (pfres=8)
          ;; (var96-var127)
          ;; Use × for solid, %0 = empty
          ;; Each arena has:
          ;; - Arena%1Playfield: Arenas_playfield_1 pixel data
rem_label_3:

          ;; - Arena%1ColorsColor: row colors for Color mode
          ;; (switchbw=0)
          ;; All arenas share ArenaColorsBW for B&W mode
          ;; Shared B&w Color Definition
          ;; All arenas use the same B&W colors (all white)
rem_label_4:

          ;; Suppress pointer-setting code to maintain 24-byte alignment
          ;; LoadArenaByIndex routine handles pointer calculation dynamically
_suppress_pf_pointer_code = 1

ArenaColorsBWStart
data_end:
ArenaColorsBW:
          .byte 14, 14, 14, 14, 14, 14, 14, 14
ArenaColorsBW_end:

ArenaColorsBWEnd

rem_label_5:

          ;; Blank Arenas_playfield_1 for score/transition frames%0
          ;; This does not participate in the indexed Arena0-31 system and is
          ;; loaded explicitly when we want a neutral background behind the
          ;; score/kernel%0

BlankPlayfieldStart
BlankPlayfield

BlankPlayfield
Arenas_playfield_1:
data_end_6:

BlankPlayfieldEnd

BlankPlayfieldColorsStart
BlankPlayfieldColors
BlankPlayfieldColors:
          .byte 14, 14, 14, 14, 14, 14, 14, 14
BlankPlayfieldColors_end:

BlankPlayfieldColorsEnd
Arena0PlayfieldStart

rem_label_6:

          ;; Arena Playfields (32 Arenas: Indices 0-31)
          
Arena0Playfield
Arena0Playfield_playfield:
data_end_11:
Arena0Colors
Arena0Colors:
          .byte $22, $24, $26, $28, $2A, $2C, $2E, $20
Arena0Colors_end:
Arena1Playfield
Arena1Playfield_playfield:
data_end_13:
Arena1Colors
Arena1Colors:
          .byte $94, $94, $96, $94, $96, $94, $94, $92
Arena1Colors_end:
Arena2Playfield
Arena2Playfield_playfield:
data_end_15:
Arena2Colors
Arena2Colors:
          .byte $94, $94, $96, $94, $96, $94, $94, $92
Arena2Colors_end:
Arena3Playfield
Arena3Playfield_playfield:
data_end_17:
Arena3Colors
Arena3Colors:
          .byte $CC, 2, $CC, 2, $CC, 4, $CC, 4, $CC, 4, $CC, 2, $CC, 2, $CC, 6
Arena3Colors_end:
Arena4Playfield
Arena4Playfield_playfield:
data_end_19:
Arena4Colors
Arena4Colors:
          .byte $1C, $1C, $1C, $1E, $1E, $1C, $1C, $1C
Arena4Colors_end:
Arena5Playfield
Arena5Playfield_playfield:
data_end_21:
Arena5Colors
Arena5Colors:
          .byte $8C, 4, $8C, 4, $8C, 4, $8C, 4, $8C, 4, $8C, 4, $8C, 4, $8C, 4
Arena5Colors_end:
Arena6Playfield
          ;; Arena 6: Multi-Platform (multiple small platforms)
Arena6Playfield_playfield:
data_end_23:
Arena6Colors
Arena6Colors:
          .byte 142, 144, 142, 146, 142, 144, 142, 148
Arena6Colors_end:
Arena7Playfield
          ;; Arena 7: The Gauntlet (maze-like walls)
Arena7Playfield_playfield:
data_end_25:
Arena7Colors
Arena7Colors:
          .byte $F2, $F2, $F2, $F4, $F2, $F4, $F2, $F6
Arena7Colors_end:
Arena8Playfield
Arena8Playfield_playfield:
data_end_27:
Arena8Colors
Arena8Colors:
          .byte $62, $64, $66, $64, $66, $64, $66, $62
Arena8Colors_end:
Arena9Playfield
Arena9Playfield_playfield:
data_end_29:
Arena9Colors
Arena9Colors:
          .byte 142, 144, 146, 144, 144, 146, 144, 142
Arena9Colors_end:
Arena10Playfield
          ;; Arena 10: Sky Battlefield (variant of Arena 2 with
          ;; elevated platforms)
Arena10Playfield_playfield:
data_end_31:
Arena10Colors
Arena10Colors:
          .byte $AC, 4, $AC, 2, $AC, 6, $AC, 2, $AC, 4, $AC, 2, $AC, 2, $AC, 8
Arena10Colors_end:
          ;; Arena color/playfield pointers computed at runtime to save ROM
Arena11Playfield
          ;; Arena 11: Floating Platforms (variant of Arena 3 with four
          ;; floating blocks when mirrored)
Arena11Playfield_playfield:
data_end_33:
Arena11Colors
Arena11Colors:
          .byte $D2, $D4, $D4, $D6, $D6, $D2, $D2, $D8
Arena11Colors_end:
Arena12Playfield
          ;; Arena 12: The Chasm (variant of Arena 4 with wider bridge)
Arena12Playfield_playfield:
data_end_35:
Arena12Colors
Arena12Colors:
          .byte $2C, $2C, $2E, $2E, $2E, $2C, $2C, $2C
Arena12Colors_end:
Arena13Playfield
          ;; Arena 13: Fortress Walls (variant of Arena 5 with
          ;; symmetrical corners)
Arena13Playfield_playfield:
data_end_37:
Arena13Colors
Arena13Colors:
          .byte $94, $94, $96, $92, $92, $96, $94, $94
Arena13Colors_end:
Arena14Playfield
          ;; Arena 14: Floating Islands (variant of Arena 6 with more
          ;; platforms)
Arena14Playfield_playfield:
data_end_39:
Arena14Colors
Arena14Colors:
          .byte $52, $50, $54, $50, $52, $50, $54, $58
Arena14Colors_end:
Arena15Playfield
          ;; Arena 15: The Labyrinth (variant of Arena 7 with more
          ;; complex maze)
Arena15Playfield_playfield:
data_end_41:
Arena15Colors
Arena15Colors:
          .byte $E2, $E2, $E4, $E6, $E6, $E4, $E2, $E8
Arena15Colors_end:
Arena16Playfield
          ;; Arena 16: Danger Zone (variant of Arena 8 with alternating
          ;; obsta

Arena16Playfield_playfield:
data_end_43:
Arena16Colors
Arena16Colors:
          .byte $7C, 2, $7C, 4, $7C, 6, $7C, 4, $7C, 6, $7C, 4, $7C, 6, $7C, 8
Arena16Colors_end:
Arena17Playfield
          ;; Arena 17: The Spire (vertical tower platforms)
Arena17Playfield_playfield:
data_end_45:
Arena17Colors
Arena17Colors:
          .byte $D2, $D4, $D6, $D4, $D6, $D4, $D2, $D8
Arena17Colors_end:
Arena18Playfield
          ;; Arena 18: The Bridge (wide center platform)
Arena18Playfield_playfield:
data_end_47:
Arena18Colors
Arena18Colors:
          .byte $BC, 12, $BC, 12, $BC, 12, $BC, 14, $BC, 14, $BC, 12, $BC, 12, $BC, 12
Arena18Colors_end:
Arena19Playfield
          ;; Arena 19: The Pits (narrow platforms with gaps)
Arena19Playfield_playfield:
data_end_49:
Arena19Colors
Arena19Colors:
          .byte 142, 142, 140, 142, 142, 140, 142, 144
Arena19Colors_end:
Arena20Playfield
          ;; Arena 20: The Stairs (stepped platforms)
Arena20Playfield_playfield:
data_end_51:
Arena20Colors
Arena20Colors:
          .byte $8C, 4, $8C, 4, $8C, 4, $8C, 6, $8C, 6, $8C, 8, $8C, 8, $8C, 2
Arena20Colors_end:
Arena21Playfield
          ;; Arena 21: The Grid (checkerboard pattern)
Arena21Playfield_playfield:
data_end_53:
Arena21Colors
Arena21Colors:
          .byte $24, $24, $26, $26, $24, $24, $26, $26
Arena21Colors_end:
Arena22Playfield
          ;; Arena 22: The Columns (vertical pillars)
Arena22Playfield_playfield:
data_end_55:
Arena22Colors
Arena22Colors:
          .byte 144, 144, 144, 144, 144, 144, 144, 146
Arena22Colors_end:
Arena23Playfield
          ;; Arena 23: The Waves (curved platforms)
Arena23Playfield_playfield:
data_end_57:
Arena23Colors
Arena23Colors:
          .byte $AC, 2, $AC, 4, $AC, 4, $AC, 2, $AC, 4, $AC, 4, $AC, 2, $AC, 6
Arena23Colors_end:
Arena24Playfield
          ;; Arena 24: The Cross (cross-shaped platform)
Arena24Playfield_playfield:
data_end_59:
Arena24Colors
Arena24Colors:
          .byte $0E, 4, $0E, 4, $0E, 4, $0E, 6, $0E, 6, $0E, 4, $0E, 4, $0E, 4
Arena24Colors_end:
Arena25Playfield
          ;; Arena 25: The Maze (complex wall pattern)
Arena25Playfield_playfield:
data_end_61:
Arena25Colors
Arena25Colors:
          .byte $62, $64, $66, $68, $68, $66, $64, $62
Arena25Colors_end:
Arena26Playfield
          ;; Arena 26: The Islands (scattered platforms)
Arena26Playfield_playfield:
data_end_63:
Arena26Colors
Arena26Colors:
          .byte $3C, 2, $3C, 2, $3C, 0, $3C, 4, $3C, 4, $3C, 0, $3C, 2, $3C, 2
Arena26Colors_end:
Arena27Playfield
          ;; Arena 27: The Rings (concentric platforms)
Arena27Playfield_playfield:
data_end_65:
Arena27Colors
Arena27Colors:
          .byte $12, $14, $16, $18, $18, $16, $14, $12
Arena27Colors_end:
Arena28Playfield
          ;; Arena 28: The Slopes (diagonal platforms)
Arena28Playfield_playfield:
data_end_67:
Arena28Colors
Arena28Colors:
          .byte $D2, $D4, $D6, $D8, $D8, $D6, $D4, $D2
Arena28Colors_end:
Arena29Playfield
          ;; Arena 29: The Zigzag (zigzag pattern)
Arena29Playfield_playfield:
data_end_69:
Arena29Colors
Arena29Colors:
          .byte $52, $54, $56, $54, $54, $56, $54, $52
Arena29Colors_end:
Arena30Playfield
          ;; Arena 30: The Ladder (vertical rungs)
Arena30Playfield_playfield:
data_end_71:
Arena30Colors
Arena30Colors:
          .byte $E4, $E4, $E4, $E4, $E4, $E4, $E4, $E6
Arena30Colors_end:
Arena31Playfield
          ;; Arena 31: The Final Battle (complex multi-platform)
Arena31Playfield_playfield:
data_end_73:
Arena31Colors
Arena31Colors:
          .byte $0E, 2, $0E, 4, $0E, 4, $0E, 6, $0E, 4, $0E, 4, $0E, 6, $0E, 8
Arena31Colors_end:

Arena31PlayfieldEnd:
Bank15AfterArenas:
