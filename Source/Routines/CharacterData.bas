          rem ChaosFight - Source/Routines/CharacterData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER DATA ACCESS ROUTINES
          rem =================================================================
          rem Provides helper routines to read character properties from
          rem data tables defined in CharacterDefinitions.bas
          rem
          rem USAGE:
          rem   temp1 = character index (0-15)
          rem   gosub GetCharacterWeight
          rem   rem Result in temp2
          rem
          rem These routines use batariBasic''s data statement access:
          rem   data TableName
          rem     value1, value2, value3, ...
          rem   end
          rem   
          rem   temp2 = data TableName + temp1
          rem =================================================================

          rem =================================================================
          rem GET CHARACTER WEIGHT
          rem =================================================================
          rem Reads weight value for a character.
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = character weight (1-255)
GetCharacterWeight
          rem Access CharacterWeights data table
          rem Using inline data read since batariBasic doesn''t have array+offset syntax
          rem We''ll use on goto to select the correct value
          on temp1 goto GetWeight0, GetWeight1, GetWeight2, GetWeight3, GetWeight4, GetWeight5, GetWeight6, GetWeight7, GetWeight8, GetWeight9, GetWeight10, GetWeight11, GetWeight12, GetWeight13, GetWeight14, GetWeight15
          
GetWeight0
          temp2 = 35 : return  : rem Bernie
GetWeight1
          temp2 = 25 : return  : rem Curling sweeper
GetWeight2
          temp2 = 20 : return  : rem Dragonet
GetWeight3
          temp2 = 15 : return  : rem EXO Pilot
GetWeight4
          temp2 = 30 : return  : rem Fat Tony
GetWeight5
          temp2 = 25 : return  : rem Grizzard Handler
GetWeight6
          temp2 = 15 : return  : rem Harpy
GetWeight7
          temp2 = 32 : return  : rem Knight Guy
GetWeight8
          temp2 = 15 : return  : rem Magical Faerie
GetWeight9
          temp2 = 20 : return  : rem Mystery Man
GetWeight10
          temp2 = 10 : return  : rem Ninjish Guy
GetWeight11
          temp2 = 30 : return  : rem Pork Chop
GetWeight12
          temp2 = 10 : return  : rem Radish Goblin
GetWeight13
          temp2 = 32 : return  : rem Robo Tito
GetWeight14
          temp2 = 30 : return  : rem Ursulo
GetWeight15
          temp2 = 25 : return  : rem Veg Dog

          rem =================================================================
          rem GET MISSILE WIDTH
          rem =================================================================
          rem Reads missile width for a character.
          rem Width of 0 indicates AOE attack (no visible missile).
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = missile width in pixels (0-4)
GetMissileWidth
          on temp1 goto GetMW0, GetMW1, GetMW2, GetMW3, GetMW4, GetMW5, GetMW6, GetMW7, GetMW8, GetMW9, GetMW10, GetMW11, GetMW12, GetMW13, GetMW14, GetMW15
          
GetMW0
          temp2 = 1 : return  : rem Bernie
GetMW1
          temp2 = 4 : return  : rem Curling sweeper (wide curling stone)
GetMW2
          temp2 = 2 : return  : rem Dragonet
GetMW3
          temp2 = 2 : return  : rem EXO Pilot
GetMW4
          temp2 = 0 : return  : rem Fat Tony (melee, no visible missile)
GetMW5
          temp2 = 0 : return  : rem Grizzard Handler (melee)
GetMW6
          temp2 = 0 : return  : rem Harpy (swoop melee)
GetMW7
          temp2 = 0 : return  : rem Knight Guy (melee)
GetMW8
          temp2 = 2 : return  : rem Magical Faerie (ranged)
GetMW9
          temp2 = 0 : return  : rem Mystery Man (melee)
GetMW10
          temp2 = 0 : return  : rem Ninjish Guy (melee)
GetMW11
          temp2 = 0 : return  : rem Pork Chop (melee)
GetMW12
          temp2 = 0 : return  : rem Radish Goblin (melee)
GetMW13
          temp2 = 0 : return  : rem Robo Tito (melee)
GetMW14
          temp2 = 2 : return  : rem Ursulo (ranged)
GetMW15
          temp2 = 0 : return  : rem Veg Dog (melee)

          rem =================================================================
          rem GET MISSILE HEIGHT
          rem =================================================================
          rem Reads missile height for a character.
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = missile height in pixels (0-4)
GetMissileHeight
          on temp1 goto GetMH0, GetMH1, GetMH2, GetMH3, GetMH4, GetMH5, GetMH6, GetMH7, GetMH8, GetMH9, GetMH10, GetMH11, GetMH12, GetMH13, GetMH14, GetMH15
          
GetMH0
          temp2 = 1 : return  : rem Bernie
GetMH1
          temp2 = 2 : return  : rem Curling sweeper
GetMH2
          temp2 = 2 : return  : rem Dragonet
GetMH3
          temp2 = 2 : return  : rem EXO Pilot
GetMH4
          temp2 = 0 : return  : rem Fat Tony
GetMH5
          temp2 = 0 : return  : rem Grizzard Handler
GetMH6
          temp2 = 0 : return  : rem Harpy
GetMH7
          temp2 = 0 : return  : rem Knight Guy
GetMH8
          temp2 = 2 : return  : rem Magical Faerie
GetMH9
          temp2 = 0 : return  : rem Mystery Man
GetMH10
          temp2 = 0 : return  : rem Ninjish Guy
GetMH11
          temp2 = 0 : return  : rem Pork Chop
GetMH12
          temp2 = 0 : return  : rem Radish Goblin
GetMH13
          temp2 = 0 : return  : rem Robo Tito
GetMH14
          temp2 = 2 : return  : rem Ursulo
GetMH15
          temp2 = 0 : return  : rem Veg Dog

          rem =================================================================
          rem GET MISSILE MOMENTUM X
          rem =================================================================
          rem Reads horizontal missile velocity for a character.
          rem Positive = right, negative = left, 0 = no horizontal movement.
          rem This is the BASE velocity; actual direction based on facing.
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = missile horizontal velocity (-8 to +8)
GetMissileMomentumX
          on temp1 goto GetMMX0, GetMMX1, GetMMX2, GetMMX3, GetMMX4, GetMMX5, GetMMX6, GetMMX7, GetMMX8, GetMMX9, GetMMX10, GetMMX11, GetMMX12, GetMMX13, GetMMX14, GetMMX15
          
GetMMX0
          temp2 = 5 : return  : rem Bernie
GetMMX1
          temp2 = 6 : return  : rem Curling sweeper (slides across ice)
GetMMX2
          temp2 = 4 : return  : rem Dragonet
GetMMX3
          temp2 = 6 : return  : rem EXO Pilot (fast laser)
GetMMX4
          temp2 = 0 : return  : rem Fat Tony (melee)
GetMMX5
          temp2 = 0 : return  : rem Grizzard Handler
GetMMX6
          temp2 = 5 : return  : rem Harpy (swoop)
GetMMX7
          temp2 = 0 : return  : rem Knight Guy
GetMMX8
          temp2 = 6 : return  : rem Magical Faerie (magic bolt)
GetMMX9
          temp2 = 0 : return  : rem Mystery Man
GetMMX10
          temp2 = 0 : return  : rem Ninjish Guy
GetMMX11
          temp2 = 0 : return  : rem Pork Chop
GetMMX12
          temp2 = 0 : return  : rem Radish Goblin
GetMMX13
          temp2 = 0 : return  : rem Robo Tito
GetMMX14
          temp2 = 7 : return  : rem Ursulo (powerful throw)
GetMMX15
          temp2 = 0 : return  : rem Veg Dog

          rem =================================================================
          rem GET MISSILE MOMENTUM Y
          rem =================================================================
          rem Reads vertical missile velocity for a character.
          rem Positive = down, negative = up, 0 = horizontal (arrowshot).
          rem Negative values create parabolic arcs.
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = missile vertical velocity (-8 to +8)
GetMissileMomentumY
          on temp1 goto GetMMY0, GetMMY1, GetMMY2, GetMMY3, GetMMY4, GetMMY5, GetMMY6, GetMMY7, GetMMY8, GetMMY9, GetMMY10, GetMMY11, GetMMY12, GetMMY13, GetMMY14, GetMMY15
          
GetMMY0
          temp2 = 0 : return  : rem Bernie (horizontal)
GetMMY1
          temp2 = 0 : return  : rem Curling sweeper (slides on ground)
GetMMY2
          temp2 = 252 : return  : rem Dragonet (ballistic, -4 in signed)
GetMMY3
          temp2 = 0 : return  : rem EXO Pilot (straight laser)
GetMMY4
          temp2 = 0 : return  : rem Fat Tony
GetMMY5
          temp2 = 0 : return  : rem Grizzard Handler
GetMMY6
          temp2 = 253 : return  : rem Harpy (swoops down, -3)
GetMMY7
          temp2 = 0 : return  : rem Knight Guy
GetMMY8
          temp2 = 251 : return  : rem Magical Faerie (ballistic, -5)
GetMMY9
          temp2 = 0 : return  : rem Mystery Man
GetMMY10
          temp2 = 0 : return  : rem Ninjish Guy
GetMMY11
          temp2 = 0 : return  : rem Pork Chop
GetMMY12
          temp2 = 0 : return  : rem Radish Goblin
GetMMY13
          temp2 = 0 : return  : rem Robo Tito
GetMMY14
          temp2 = 250 : return  : rem Ursulo (high arc, -6)
GetMMY15
          temp2 = 0 : return  : rem Veg Dog

          rem =================================================================
          rem GET MISSILE FLAGS
          rem =================================================================
          rem Reads behavior flags for a character''s missile.
          rem Bit 0: Hit background (1=disappear on wall)
          rem Bit 1: Hit player (1=disappear on player hit)
          rem Bit 2: Apply gravity (1=affected by gravity)
          rem Bit 3: Bounce off walls (1=bounce, 0=stop)
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = missile flags byte
GetMissileFlags
          on temp1 goto GetMF0, GetMF1, GetMF2, GetMF3, GetMF4, GetMF5, GetMF6, GetMF7, GetMF8, GetMF9, GetMF10, GetMF11, GetMF12, GetMF13, GetMF14, GetMF15
          
GetMF0
          temp2 = %00000000 : return  : rem Bernie (pass through)
GetMF1
          temp2 = %00000011 : return  : rem Curling (hit bg + player)
GetMF2
          temp2 = %00000101 : return  : rem Dragonet (hit bg + gravity)
GetMF3
          temp2 = %00000010 : return  : rem EXO Pilot (hit player only)
GetMF4
          temp2 = %00000000 : return  : rem Fat Tony
GetMF5
          temp2 = %00000000 : return  : rem Grizzard Handler
GetMF6
          temp2 = %00000000 : return  : rem Harpy
GetMF7
          temp2 = %00000000 : return  : rem Knight Guy
GetMF8
          temp2 = %00000101 : return  : rem Magical Faerie (hit bg + gravity)
GetMF9
          temp2 = %00000000 : return  : rem Mystery Man
GetMF10
          temp2 = %00000000 : return  : rem Ninjish Guy
GetMF11
          temp2 = %00000000 : return  : rem Pork Chop
GetMF12
          temp2 = %00000000 : return  : rem Radish Goblin
GetMF13
          temp2 = %00000000 : return  : rem Robo Tito
GetMF14
          temp2 = %00000101 : return  : rem Ursulo (hit bg + gravity)
GetMF15
          temp2 = %00000000 : return  : rem Veg Dog

          rem =================================================================
          rem GET MISSILE LIFETIME
          rem =================================================================
          rem Reads how many frames a missile/attack visual persists.
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = lifetime (1-13 frames, 14=until collision, 15=until off-screen)
GetMissileLifetime
          on temp1 goto GetML0, GetML1, GetML2, GetML3, GetML4, GetML5, GetML6, GetML7, GetML8, GetML9, GetML10, GetML11, GetML12, GetML13, GetML14, GetML15
          
GetML0
          temp2 = 4 : return   : rem Bernie (melee, 4 frames)
GetML1
          temp2 = 14 : return  : rem Curling (until collision)
GetML2
          temp2 = 14 : return  : rem Dragonet (until collision)
GetML3
          temp2 = 14 : return  : rem EXO Pilot (until collision)
GetML4
          temp2 = 4 : return   : rem Fat Tony (melee)
GetML5
          temp2 = 4 : return   : rem Grizzard Handler (melee)
GetML6
          temp2 = 5 : return   : rem Harpy (swoop melee)
GetML7
          temp2 = 6 : return   : rem Knight Guy (sword melee)
GetML8
          temp2 = 14 : return  : rem Magical Faerie (until collision)
GetML9
          temp2 = 5 : return   : rem Mystery Man (melee)
GetML10
          temp2 = 4 : return   : rem Ninjish Guy (fast melee)
GetML11
          temp2 = 4 : return   : rem Pork Chop (melee)
GetML12
          temp2 = 3 : return   : rem Radish Goblin (quick melee)
GetML13
          temp2 = 5 : return   : rem Robo Tito (melee)
GetML14
          temp2 = 14 : return  : rem Ursulo (until collision)
GetML15
          temp2 = 4 : return   : rem Veg Dog (melee)

          rem =================================================================
          rem GET BASE DAMAGE
          rem =================================================================
          rem Calculates base damage for a character based on weight.
          rem Heavier characters do more damage.
          rem
          rem INPUT:
          rem   temp1 = character index (0-15)
          rem
          rem OUTPUT:
          rem   temp2 = base damage (5-15 points)
GetBaseDamage
          rem Get character weight first
          gosub GetCharacterWeight
          rem temp2 now contains weight
          
          rem Calculate damage: weight / 4 + 2
          rem Light (10): 10/4 + 2 = 4
          rem Average (20): 20/4 + 2 = 7
          rem Heavy (30): 30/4 + 2 = 9
          temp2 = temp2 / 4
          temp2 = temp2 + 2
          
          rem Clamp to reasonable range (5-15)
          if temp2 < 5 then temp2 = 5
          if temp2 > 15 then temp2 = 15
          
          return

