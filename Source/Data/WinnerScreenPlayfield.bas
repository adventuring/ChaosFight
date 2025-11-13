          rem
          rem ChaosFight - Source/Data/WinnerScreenPlayfield.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Winner screen playfield data (pfres=8, 16×8 reflecting)
          rem MUST be in Bank16 - playfields always must be in Bank16

          rem Winner Screen Playfield Data
          rem 16 columns × 8 rows (pfres=8, reflecting mode)
          rem Design: Central high podium for winner, side platforms for 2nd/3rd
          rem Row 4: Central high platform (winner podium)
          rem Row 6: Left and right platforms (2nd/3rd place)

WinnerScreenPlayfield
          playfield:
            ................
            ................
            ............XXXX
            ............XXXX
            ............XXXX
            ....XXXXXXXXXXXX
            ....XXXXXXXXXXXX
            XXXXXXXXXXXXXXXX
end

