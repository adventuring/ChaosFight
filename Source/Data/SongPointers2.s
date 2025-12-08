;;; ChaosFight - Source/Data/SongPointers2.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Song Pointer Data Tables - Bank 2
          ;; Compact pointer lookup tables for songs stored in Bank 14
          ;; Format: data SongPointers2L, SongPointers2H (7 entries)
          ;; Songs in Bank 14: IDs 0-Bank14MaxSongID (currently Bernie, OCascadia, Revontuli, EXO, Grizzards, MagicalFairyForce, Bolero)
          ;; Index mapping: song ID maps directly (index = songID)

SongPointers2L:
          .byte <Song_Bernie_Voice0, <Song_OCascadia_Voice0, <Song_Revontuli_Voice0, <Song_EXO_Voice0, <Song_Grizzards_Voice0, <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0
SongPointers2L_end:
SongPointers2H:
          .byte >Song_Bernie_Voice0, >Song_OCascadia_Voice0, >Song_Revontuli_Voice0, >Song_EXO_Voice0, >Song_Grizzards_Voice0, >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0
SongPointers2H_end:

          ;; Voice 1 stream pointer lookup tables for Bank 14
SongPointers2SecondL:
          .byte <Song_Bernie_Voice1, <Song_OCascadia_Voice1, <Song_Revontuli_Voice1, <Song_EXO_Voice1, <Song_Grizzards_Voice1, <Song_MagicalFairyForce_Voice1, <Song_Bolero_Voice1
SongPointers2SecondL_end:
SongPointers2SecondH:
          .byte >Song_Bernie_Voice1, >Song_OCascadia_Voice1, >Song_Revontuli_Voice1, >Song_EXO_Voice1, >Song_Grizzards_Voice1, >Song_MagicalFairyForce_Voice1, >Song_Bolero_Voice1
SongPointers2SecondH_end:


