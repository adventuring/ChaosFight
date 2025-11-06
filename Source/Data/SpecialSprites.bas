          rem
          rem ChaosFight - Source/Data/SpecialSprites.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Special Sprites - Hard-coded Data
          rem Special sprites for character selection placeholders
          rem Used when no character is selected or for CPU players
          rem 8x16 pixels, white on black

          data QuestionMarkSprite
            %00000000
            %00000000
            %00001000
            %00000000
            %00001000
            %00001000
            %00000100
            %00000010
            %00000010
            %00000001
            %01000001
            %10000001
            %10000001
            %10000001
            %10000001
            %01111110
end

          data CPUSprite
            %11111001
            %11110110
            %11110110
            %11110110
            %11010110
            %11011111
            %11001111
            %11010111
            %11001111
            %11111111
            %10001111
            %01111111
            %01111111
            %01111111
            %01111111
            %10001111
end

          data NoSprite
            %10000011
            %01111101
            %01111101
            %01111101
            %01111101
            %01111101
            %01111101
            %10000011
            %11111111
            %01111101
            %01111001
            %01110101
            %01101101
            %01011101
            %00111101
            %01111101
end
