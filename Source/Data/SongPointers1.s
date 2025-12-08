;;; ChaosFight - Source/Data/SongPointers1.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Song Pointer Data Tables - Bank 0
          ;; Compact pointer lookup tables for songs stored in Bank 0
          ;; 23 entries: SongPointers1L, SongPointers1H
          ;; Songs in Bank 0: Song IDs Bank0MinSongID-28 (character themes plus admin music)
          ;; Index mapping: song Bank0MinSongID → index 0, song N → index (N - Bank0MinSongID)

SongPointers1L:
          .byte <Song_LowRes_Voice0, <Song_RoboTito_Voice0, <Song_SongOfTheBear_Voice0, <Song_DucksAway_Voice0, <Song_Character16Theme_Voice0, <Song_Character17Theme_Voice0, <Song_Character18Theme_Voice0, <Song_Character19Theme_Voice0, <Song_Character20Theme_Voice0, <Song_Character21Theme_Voice0, <Song_Character22Theme_Voice0, <Song_Character23Theme_Voice0, <Song_Character24Theme_Voice0, <Song_Character25Theme_Voice0, <Song_Character26Theme_Voice0, <Song_Character27Theme_Voice0, <Song_Character28Theme_Voice0, <Song_Character29Theme_Voice0, <Song_Character30Theme_Voice0, <Song_Chaotica_Voice0, <Song_AtariToday_Voice0, <Song_Interworldly_Voice0
SongPointers1L_end:
SongPointers1H:
          .byte >Song_LowRes_Voice0, >Song_RoboTito_Voice0, >Song_SongOfTheBear_Voice0, >Song_DucksAway_Voice0, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice0, >Song_Character18Theme_Voice0, >Song_Character19Theme_Voice0, >Song_Character20Theme_Voice0, >Song_Character21Theme_Voice0, >Song_Character22Theme_Voice0, >Song_Character23Theme_Voice0, >Song_Character24Theme_Voice0, >Song_Character25Theme_Voice0, >Song_Character26Theme_Voice0, >Song_Character27Theme_Voice0, >Song_Character28Theme_Voice0, >Song_Character29Theme_Voice0, >Song_Character30Theme_Voice0, >Song_Chaotica_Voice0, >Song_AtariToday_Voice0, >Song_Interworldly_Voice0
SongPointers1H_end:

          ;; Voice 1 stream pointer lookup tables for Bank 0
SongPointers1SecondL:
          .byte <Song_LowRes_Voice1, <Song_RoboTito_Voice1, <Song_SongOfTheBear_Voice1, <Song_DucksAway_Voice1, <Song_Character16Theme_Voice1, <Song_Character17Theme_Voice1, <Song_Character18Theme_Voice1, <Song_Character19Theme_Voice1, <Song_Character20Theme_Voice1, <Song_Character21Theme_Voice1, <Song_Character22Theme_Voice1, <Song_Character23Theme_Voice1, <Song_Character24Theme_Voice1, <Song_Character25Theme_Voice1, <Song_Character26Theme_Voice1, <Song_Character27Theme_Voice1, <Song_Character28Theme_Voice1, <Song_Character29Theme_Voice1, <Song_Character30Theme_Voice1, <Song_Chaotica_Voice1, <Song_AtariToday_Voice1, <Song_Interworldly_Voice1
SongPointers1SecondL_end:
SongPointers1SecondH:
          .byte >Song_LowRes_Voice1, >Song_RoboTito_Voice1, >Song_SongOfTheBear_Voice1, >Song_DucksAway_Voice1, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice1, >Song_Character18Theme_Voice1, >Song_Character19Theme_Voice1, >Song_Character20Theme_Voice1, >Song_Character21Theme_Voice1, >Song_Character22Theme_Voice1, >Song_Character23Theme_Voice1, >Song_Character24Theme_Voice1, >Song_Character25Theme_Voice1, >Song_Character26Theme_Voice1, >Song_Character27Theme_Voice1, >Song_Character28Theme_Voice1, >Song_Character29Theme_Voice1, >Song_Character30Theme_Voice1, >Song_Chaotica_Voice1, >Song_AtariToday_Voice1, >Song_Interworldly_Voice1
SongPointers1SecondH_end:



