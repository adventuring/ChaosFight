          rem ChaosFight - Source/Data/CharacterThemeSongIndices.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem CHARACTER THEME SONG INDEX MAPPING TABLE
          rem =================================================================
          rem Maps character index (0-31) to theme song index in GAME_THEME_SONGS
          rem This table allows multiple characters to share the same theme song
          rem without duplicating song files in the Makefile.
          rem
          rem Song indices in GAME_THEME_SONGS:
          rem   0=Bernie, 1=OCascadia, 2=Revontuli, 3=EXO, 4=Grizzards,
          rem   5=MagicalFairyForce, 6=Bolero, 7=LowRes, 8=RoboTito,
          rem   9=SongOfTheBear, 10=DucksAway,
          rem   11-25=Character16Theme-Character30Theme
          rem =================================================================

          rem Character 0-15: Main characters
          rem Character 0 (Bernie) → Song 0 (Bernie)
          rem Character 1 (Curler) → Song 1 (OCascadia)
          rem Character 2 (DragonOfStorms) → Song 2 (Revontuli)
          rem Character 3 (ZoeRyen) → Song 3 (EXO)
          rem Character 4 (FatTony) → Song 4 (Grizzards)
          rem Character 5 (Megax) → Song 4 (Grizzards) - shared with FatTony
          rem Character 6 (Harpy) → Song 2 (Revontuli) - shared with DragonOfStorms
          rem Character 7 (KnightGuy) → Song 5 (MagicalFairyForce)
          rem Character 8 (Frooty) → Song 5 (MagicalFairyForce) - shared with KnightGuy
          rem Character 9 (Nefertem) → Song 6 (Bolero)
          rem Character 10 (NinjishGuy) → Song 7 (LowRes)
          rem Character 11 (PorkChop) → Song 5 (MagicalFairyForce) - shared with KnightGuy
          rem Character 12 (RadishGoblin) → Song 6 (Bolero) - shared with Nefertem
          rem Character 13 (RoboTito) → Song 8 (RoboTito)
          rem Character 14 (Ursulo) → Song 9 (SongOfTheBear)
          rem Character 15 (Shamone) → Song 10 (DucksAway)
          rem Characters 16-30: Future characters (each has own theme placeholder)
          rem Character 31 (MethHound) → Song 10 (DucksAway) - shared with Shamone
          data CharacterThemeSongIndices
          0, 1, 2, 3, 4, 4, 2, 5, 5, 6, 7, 5, 6, 8, 9, 10,
          11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 10
          end

