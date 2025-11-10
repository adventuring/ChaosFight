DispatchCharacterAttack
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound (31) uses ShamoneAttack handler
          rem Use trampoline labels for cross-bank references (Bank 11)
          if temp4 >= 32 then return

          rem Characters 0-15: Implemented attacks
          if temp4 = 0 then goto GotoBernieAttack
          if temp4 = 1 then goto GotoCurlerAttack
          if temp4 = 2 then goto GotoDragonOfStormsAttack
          if temp4 = 3 then goto GotoZoeRyenAttack
          if temp4 = 4 then goto GotoFatTonyAttack
          if temp4 = 5 then goto GotoMegaxAttack
          if temp4 = 6 then goto GotoHarpyAttack
          if temp4 = 7 then goto GotoKnightGuyAttack
          if temp4 = 8 then goto GotoFrootyAttack
          if temp4 = 9 then goto GotoNefertemAttack
          if temp4 = 10 then goto GotoNinjishGuyAttack
          if temp4 = 11 then goto GotoPorkChopAttack
          if temp4 = 12 then goto GotoRadishGoblinAttack
          if temp4 = 13 then goto GotoRoboTitoAttack
          if temp4 = 14 then goto GotoUrsuloAttack
          if temp4 = 15 then goto GotoShamoneAttack

          rem Characters 16-30: Placeholder attacks (basic melee)
          if temp4 = 16 then goto GotoCharacter16Attack
          if temp4 = 17 then goto GotoCharacter17Attack
          if temp4 = 18 then goto GotoCharacter18Attack
          if temp4 = 19 then goto GotoCharacter19Attack
          if temp4 = 20 then goto GotoCharacter20Attack
          if temp4 = 21 then goto GotoCharacter21Attack
          if temp4 = 22 then goto GotoCharacter22Attack
          if temp4 = 23 then goto GotoCharacter23Attack
          if temp4 = 24 then goto GotoCharacter24Attack
          if temp4 = 25 then goto GotoCharacter25Attack
          if temp4 = 26 then goto GotoCharacter26Attack
          if temp4 = 27 then goto GotoCharacter27Attack
          if temp4 = 28 then goto GotoCharacter28Attack
          if temp4 = 29 then goto GotoCharacter29Attack
          if temp4 = 30 then goto GotoCharacter30Attack

          rem Character 31: MethHound uses ShamoneAttack handler
          if temp4 = 31 then goto GotoShamoneAttack

          return


GotoBernieAttack
          goto BernieAttack bank10

GotoCurlerAttack
          goto CurlerAttack bank10

GotoDragonOfStormsAttack
          goto DragonOfStormsAttack bank10

GotoZoeRyenAttack
          goto ZoeRyenAttack bank10

GotoFatTonyAttack
          goto FatTonyAttack bank10

GotoMegaxAttack
          goto MegaxAttack bank10

GotoHarpyAttack
          goto HarpyAttack bank10

GotoKnightGuyAttack
          goto KnightGuyAttack bank10

GotoFrootyAttack
          goto FrootyAttack bank10

GotoNefertemAttack
          goto NefertemAttack bank10

GotoNinjishGuyAttack
          goto NinjishGuyAttack bank10

GotoPorkChopAttack
          goto PorkChopAttack bank10

GotoRadishGoblinAttack
          goto RadishGoblinAttack bank10

GotoRoboTitoAttack
          goto RoboTitoAttack bank10

GotoUrsuloAttack
          goto UrsuloAttack bank10

GotoShamoneAttack
          goto ShamoneAttack bank10
          

GotoMeleeAttack
          goto PerformMeleeAttack bank7

CheckEnhancedJumpButton
          rem
          rem Shared Enhanced Button Check
          rem Checks Genesis/Joy2b+ Button C/II for jump input
          rem Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise
          rem Uses: INPT0 for players 0; INPT2 for players 1
          rem Players 2-3 cannot have enhanced controllers
          let temp3 = 0
          rem Initialize to no jump

          rem Only players 0-1 can have enhanced controllers
          rem Players 2-3 (Quadtari players) cannot have enhanced controllers
          if temp1 = 0 then CEJB_CheckPlayer0
          if temp1 = 1 then CEJB_CheckPlayer2
          rem Players 2-3 skip enhanced controller checks
          goto CEJB_Done
CEJB_CheckPlayer0
          rem Player 0: Check Genesis controller first
          if !ControllerStatus{0} then CEJB_CheckPlayer0Joy2bPlus
          goto CEJB_ReadButton0
CEJB_CheckPlayer0Joy2bPlus
          rem Player 0: Check Joy2b+ controller (fallback)
          if !ControllerStatus{1} then CEJB_Done
CEJB_ReadButton0
          rem Shared button read for Player 0 enhanced controllers (Button C/II)
          if !INPT0{7} then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer2
          rem Player 1: Check Genesis controller first
          if !(ControllerStatus & $04) then CEJB_CheckPlayer2Joy2bPlus
          goto CEJB_ReadButton2
CEJB_CheckPlayer2Joy2bPlus
          rem Player 1: Check Joy2b+ controller (fallback)
          if !(ControllerStatus & $08) then CEJB_Done
CEJB_ReadButton2
          rem Shared button read for Player 1 enhanced controllers (Button C/II)
          if !(INPT2 & $80) then temp3 = 1
          goto CEJB_Done
CEJB_Done
          rem Enhanced jump button check complete
          return
