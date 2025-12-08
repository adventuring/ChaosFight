rem_label_1_L1_dup:

;;; ChaosFight - Source/Data/CharacterThemeSongIndices.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Character Theme Song Id Mapping Table
rem_label_2_1_L7:

          ;; Maps character index (0-31) to full song ID consta

          ;; This table allows multiple characters to share the same
          ;; theme song
          ;; without duplicating song files in the Makefile.
          ;; Song ID constants in this table:
          ;; Character 0 (Bernie) → SongBernie
          ;; Character 1 (Curler) → SongOCascadia
          ;; Character 2 (DragonOfStorms) → SongRevontuli
          ;; Character 3 (ZoeRyen) → SongEXO
          ;; Character 4 (FatTony) → SongGrizzards
          ;; Character 5 (Megax) → SongGrizzards - shared with FatTony
          ;; Character 6 (Harpy) → SongRevontuli - shared with
          ;; DragonOfStorms
          ;; Character 7 (KnightGuy) → SongMagicalFairyForce
          ;; Character 8 (Frooty) → SongMagicalFairyForce - shared with
          ;; KnightGuy
          ;; Character 9 (Nefertem) → SongBolero
          ;; Character 10 (NinjishGuy) → SongLowRes
          ;; Character 11 (PorkChop) → SongMagicalFairyForce - shared
          ;; with KnightGuy
          ;; Character 12 (RadishGoblin) → SongBolero - shared with
          ;; Nefertem
          ;; Character 13 (RoboTito) → SongRoboTito
          ;; Character 14 (Ursulo) → SongSongOfTheBear
          ;; Character 15 (Shamone) → SongDucksAway
          ;; Characters 16-30: Future characters (each has own theme
          ;; placeholder)
          ;; Character 31 (MethHound) → SongDucksAway - shared with
          ;; Shamone
CharacterThemeSongIndices:
          .byte SongBernie, SongOCascadia, SongRevontuli, SongEXO, SongGrizzards, SongGrizzards, SongRevontuli, SongMagicalFairyForce, SongMagicalFairyForce, SongBolero, SongLowRes, SongMagicalFairyForce, SongBolero, SongRoboTito, SongSongOfTheBear, SongDucksAway, SongCharacter16Theme, SongCharacter17Theme, SongCharacter18Theme, SongCharacter19Theme, SongCharacter20Theme, SongCharacter21Theme, SongCharacter22Theme, SongCharacter23Theme, SongCharacter24Theme, SongCharacter25Theme, SongCharacter26Theme, SongCharacter27Theme, SongCharacter28Theme, SongCharacter29Theme, SongCharacter30Theme, SongDucksAway
CharacterThemeSongIndices_end:

