          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1

          rem Titlescreen kernel for 48×42 bitmaps on admin screens (×2 drawing style)
          rem Include generated bitmap art files (assembly format - wrap in asm blocks)
          asm
          include "Source/Generated/Art.AtariAge.s"
          include "Source/Generated/Art.Interworldly.s"
          include "Source/Generated/Art.ChaosFight.s"
          include "Source/Titlescreen/asm/titlescreen.s"
end

          goto bank13 ColdStart

