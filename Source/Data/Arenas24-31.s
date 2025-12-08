Arena24Playfield
;;; Arena 24: The Cross (cross-shaped platform)
playfield:

          %1111000011110000
          %1111000011110000
          %1111000011110000
%1111111111111111

%1111111111111111

          %1111000011110000
          %1111000011110000
          %1111000011110000
data_end:


Arena25Playfield
          ;; Arena 25: The Maze (complex wall pattern)
;; playfield: (duplicate)

%1111111111111111

          %100000010000001
          %101111010111101
          %101001010100101
          %101001010100101
          %101111010111101
          %100000010000001
%1111111111111111

data_end_2:


Arena26Playfield
          ;; Arena 26: The Islands (scattered platforms)
;; playfield: (duplicate)

          %1100000000000011
          %1100000000000011
          %0000000000000000
          %0000111111000000
          %0000111111000000
          %0000000000000000
          %1100000000000011
          %1100000000000011
data_end_3:


Arena27Playfield
          ;; Arena 27: The Rings (concentric platforms)
;; playfield: (duplicate)

%1111111111111111

          %1000000000000001
          %1011111111111101
          %1010000000000101
          %1010000000000101
          %1011111111111101
          %1000000000000001
%1111111111111111

data_end_4:


Arena28Playfield
          ;; Arena 28: The Slopes (diagonal platforms)
;; playfield: (duplicate)

%1111111111111111

          %0111111111111110
          %0011111111111100
          %0001111111111000
          %0001111111111000
          %0011111111111100
          %0111111111111110
%1111111111111111

data_end_5:


Arena29Playfield
          ;; Arena 29: The Zigzag (zigzag pattern)
;; playfield: (duplicate)

          %1111000000001111
          %0011110000111100
          %0000111111000000
          %0000001111000000
          %0000001111000000
          %0000111111000000
          %0011110000111100
          %1111000000001111
data_end_6:


Arena30Playfield
          ;; Arena 30: The Ladder (vertical rungs)
;; playfield: (duplicate)

          %1001001001001001
          %1001001001001001
          %1001001001001001
          %1001001001001001
          %1001001001001001
          %1001001001001001
          %1001001001001001
          %1001001001001001
data_end_7:


Arena31Playfield
          ;; Arena 31: The Final Battle (complex multi-platform)
;; playfield: (duplicate)

%1111111111111111

          %1011001100110110
          %1011001100110110
          %1000000000000001
          %1011001100110110
          %1011001100110110
          %1000000000000001
%1111111111111111

data_end_8:


rem_label:

          ;; Arena Color Pointer Tables
          ;; Color pointer lookup tables for efficient arena loading
          ;; Format: 32 entries (indices 0-31) for Arena0-Arena31
          ;; Note: All arenas reference their color tables directly%0


rem_label_2:

          ;; Arena Playfield Pointer Tables
          ;; Playfield pointer lookup tables for efficient arena
          ;; loading
          ;; Format: 32 entries (indices 0-31) for Arena0-Arena31

ArenaPF1PointerL_data:
            <Arena0Playfield, <Arena1Playfield, <Arena2Playfield, <Arena3Playfield, <Arena4Playfield, <Arena5Playfield, <Arena6Playfield, <Arena7Playfield,
            <Arena8Playfield, <Arena9Playfield, <Arena10Playfield, <Arena11Playfield, <Arena12Playfield, <Arena13Playfield, <Arena14Playfield, <Arena15Playfield,
            <Arena16Playfield, <Arena17Playfield, <Arena18Playfield, <Arena19Playfield, <Arena20Playfield, <Arena21Playfield, <Arena22Playfield, <Arena23Playfield,
            <Arena24Playfield, <Arena25Playfield, <Arena26Playfield, <Arena27Playfield, <Arena28Playfield, <Arena29Playfield, <Arena30Playfield, <Arena31Playfield
ArenaPF1PointerL_data_end:

ArenaPF1PointerH_data:
            >Arena0Playfield, >Arena1Playfield, >Arena2Playfield, >Arena3Playfield, >Arena4Playfield, >Arena5Playfield, >Arena6Playfield, >Arena7Playfield,
            >Arena8Playfield, >Arena9Playfield, >Arena10Playfield, >Arena11Playfield, >Arena12Playfield, >Arena13Playfield, >Arena14Playfield, >Arena15Playfield,
            >Arena16Playfield, >Arena17Playfield, >Arena18Playfield, >Arena19Playfield, >Arena20Playfield, >Arena21Playfield, >Arena22Playfield, >Arena23Playfield,
            >Arena24Playfield, >Arena25Playfield, >Arena26Playfield, >Arena27Playfield, >Arena28Playfield, >Arena29Playfield, >Arena30Playfield, >Arena31Playfield
ArenaPF1PointerH_data_end:


