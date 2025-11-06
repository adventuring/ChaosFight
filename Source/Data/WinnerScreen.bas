          rem ChaosFight - Source/Data/WinnerScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Winner screen playfield data (pfres=8, 8 rows)

          rem Winner Screen Playfield Data
          rem
          rem 8 rows (pfres=8)
          rem Design: Central high podium for winner, side platforms for
          rem   2nd/3rd
          rem Row 4: Central high platform (winner podium)
          rem Row 6: Left and right platforms (2nd/3rd place)
          rem ==========================================================

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

WinnerScreenColorsColor
          pfcolors:
          ColGold(14)
          ColGold(12)
          ColGold(10)
          ColGold(8)
          ColGold(6)
          ColGold(4)
          ColGold(2)
          ColGold(2)
end


