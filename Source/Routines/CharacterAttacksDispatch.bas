DispatchCharacterAttack
          asm
DispatchCharacterAttack

end
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound (31) uses ShamoneAttack handler
          rem Direct cross-bank gotos route to character-specific logic or the
          rem shared PerformMeleeAttack/PerformRangedAttack helpers
          if temp4 >= 32 then return

          rem Characters 0-15: Implemented attacks
          rem Bernie (0): dual-direction ground thump
          if temp4 = 0 then goto BernieAttack bank10
          rem Curler (1): ranged curling stone along ground
          if temp4 = 1 then goto PerformRangedAttack bank7
          rem Dragon of Storms (2): ranged ballistic fireball
          if temp4 = 2 then goto PerformRangedAttack bank7
          rem Zoe Ryen (3): rapid laser blast
          if temp4 = 3 then goto PerformRangedAttack bank7
          rem Fat Tony (4): stationary magic ring laser
          if temp4 = 4 then goto PerformRangedAttack bank7
          rem Megax (5): heavy melee breath strike (generic melee tables)
          if temp4 = 5 then goto PerformMeleeAttack bank7
          rem Harpy (6): diagonal swoop attack
          if temp4 = 6 then goto HarpyAttack bank10
          rem Knight Guy (7): sword melee swing
          if temp4 = 7 then goto PerformMeleeAttack bank7
          rem Frooty (8): ranged sparkle projectile
          if temp4 = 8 then goto PerformRangedAttack bank7
          rem Nefertem (9): melee paw strike
          if temp4 = 9 then goto PerformMeleeAttack bank7
          rem Ninjish Guy (10): ranged shuriken
          if temp4 = 10 then goto PerformRangedAttack bank7
          rem Pork Chop (11): melee
          if temp4 = 11 then goto PerformMeleeAttack bank7
          rem Radish Goblin (12): melee bite lunge
          if temp4 = 12 then goto PerformMeleeAttack bank7
          rem Robo Tito (13): melee trunk slam
          if temp4 = 13 then goto PerformMeleeAttack bank7
          rem Ursulo (14): claw swipe with melee tables
          if temp4 = 14 then goto UrsuloAttack bank10
          rem Shamone (15): jump + melee special
          if temp4 = 15 then goto ShamoneAttack bank10

          rem Characters 16-30: Placeholder attacks (basic melee)
          rem Characters 16-30: placeholder melee entries
          if temp4 >= 16 && temp4 <= 30 then goto PerformMeleeAttack bank7

          rem Character 31: MethHound uses ShamoneAttack handler
          if temp4 = 31 then goto ShamoneAttack bank10

          return

CheckEnhancedJumpButton
          asm
CheckEnhancedJumpButton

end
          rem
          rem Shared Enhanced Button Check
          rem Checks Genesis/Joy2b+ Button C/II for jump input
          rem Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)
          rem
          rem INPUT: currentPlayer (global) = player index (0-3)
          rem
          rem OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise
          rem Uses: INPT0 for players 0; INPT2 for players 1
          rem Players 2-3 cannot have enhanced controllers
          let temp3 = 0
          rem Initialize to no jump

          rem Only players 0-1 can have enhanced controllers
          rem Players 2-3 (Quadtari players) cannot have enhanced controllers
          if currentPlayer = 0 then CEJB_CheckPlayer0
          if currentPlayer = 1 then CEJB_CheckPlayer2
          rem Players 2-3 skip enhanced controller checks
          goto CEJB_Done
CEJB_CheckPlayer0
          rem Player 0: Check Genesis controller first
          if !ControllerStatus{0} then CEJB_CheckPlayer0Joy2bPlus
CEJB_ReadButton0
          rem Shared button read for Player 0 enhanced controllers (Button C/II)
          if !INPT0{7} then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer0Joy2bPlus
          rem Player 0: Check Joy2b+ controller (fallback)
          if !ControllerStatus{1} then CEJB_Done
          goto CEJB_ReadButton0
CEJB_CheckPlayer2
          rem Player 1: Check Genesis controller first
          if (ControllerStatus & $04) = 0 then CEJB_CheckPlayer2Joy2bPlus
CEJB_ReadButton2
          rem Shared button read for Player 1 enhanced controllers (Button C/II)
          if (INPT2 & $80) = 0 then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer2Joy2bPlus
          rem Player 1: Check Joy2b+ controller (fallback)
          if (ControllerStatus & $08) = 0 then CEJB_Done
          goto CEJB_ReadButton2
CEJB_Done
          rem Enhanced jump button check complete
          return
