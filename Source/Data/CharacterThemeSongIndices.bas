          rem
          rem ChaosFight - Source/Data/CharacterThemeSongIndices.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Character Theme Song Id Mapping Table
          rem
          rem Maps character index (0-31) to full song ID constants
          rem This table allows multiple characters to share the same
          rem   theme song
          rem without duplicating song files in the Makefile.
          rem Song ID constants in this table:
          rem   Character 0 (Bernie) → SongBernie
          rem   Character 1 (Curler) → SongOCascadia
          rem   Character 2 (DragonOfStorms) → SongRevontuli
          rem   Character 3 (ZoeRyen) → SongEXO
          rem   Character 4 (FatTony) → SongGrizzards
          rem Character 5 (Megax) → SongGrizzards - shared with FatTony
          rem Character 6 (Harpy) → SongRevontuli - shared with
          rem   DragonOfStorms
          rem   Character 7 (KnightGuy) → SongMagicalFairyForce
          rem Character 8 (Frooty) → SongMagicalFairyForce - shared with
          rem   KnightGuy
          rem   Character 9 (Nefertem) → SongBolero
          rem   Character 10 (NinjishGuy) → SongLowRes
          rem Character 11 (PorkChop) → SongMagicalFairyForce - shared
          rem   with KnightGuy
          rem Character 12 (RadishGoblin) → SongBolero - shared with
          rem   Nefertem
          rem   Character 13 (RoboTito) → SongRoboTito
          rem   Character 14 (Ursulo) → SongSongOfTheBear
          rem   Character 15 (Shamone) → SongDucksAway
          rem Characters 16-30: Future characters (each has own theme
          rem   placeholder)
          rem Character 31 (MethHound) → SongDucksAway - shared with
          rem   Shamone
data CharacterThemeSongIndices
SongBernie, SongOCascadia, SongRevontuli, SongEXO, SongGrizzards, SongGrizzards, SongRevontuli, SongMagicalFairyForce
SongMagicalFairyForce, SongBolero, SongLowRes, SongMagicalFairyForce, SongBolero, SongRoboTito, SongSongOfTheBear, SongDucksAway
SongCharacter16Theme, SongCharacter17Theme, SongCharacter18Theme, SongCharacter19Theme, SongCharacter20Theme, SongCharacter21Theme, SongCharacter22Theme, SongCharacter23Theme
SongCharacter24Theme, SongCharacter25Theme, SongCharacter26Theme, SongCharacter27Theme, SongCharacter28Theme, SongCharacter29Theme, SongCharacter30Theme, SongDucksAway
end

