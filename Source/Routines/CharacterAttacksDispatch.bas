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
          

GotoRadishGoblinAttack
          goto RadishGoblinAttack bank9

GotoRoboTitoAttack
          goto RoboTitoAttack bank9

GotoUrsuloAttack
          goto UrsuloAttack bank9

GotoShamoneAttack
          goto ShamoneAttack bank9
          
GotoCharacter16Attack
          rem Character 16-23 attack handlers (future characters)
          goto Character16Attack bank9

GotoCharacter17Attack
          goto Character17Attack bank9

GotoCharacter18Attack
          goto Character18Attack bank9

GotoCharacter19Attack
          goto Character19Attack bank9

GotoCharacter20Attack
          goto Character20Attack bank9

GotoCharacter21Attack
          goto Character21Attack bank9

GotoCharacter22Attack
          goto Character22Attack bank9

GotoCharacter23Attack
          goto Character23Attack bank9

GotoCharacter24Attack
          rem Character 24-30 attack handlers (future characters)
          goto Character24Attack bank9

GotoCharacter25Attack
          goto Character25Attack bank9

GotoCharacter26Attack
          goto Character26Attack bank9

GotoCharacter27Attack
          goto Character27Attack bank9

GotoCharacter28Attack
          goto Character28Attack bank9

GotoCharacter29Attack
          goto Character29Attack bank9

GotoCharacter30Attack
          goto Character30Attack bank9

CheckEnhancedJumpButton
          rem
          rem Shared Enhanced Button Check
          rem Checks Genesis/Joy2b+ Button C/II for jump input
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise
          rem Uses: INPT0 for players 0,2; INPT2 for players 1,3
          let temp3 = 0
          rem Initialize to no jump
          rem Player 0 or 2: Check INPT0
          if temp1 = 0 then CEJB_CheckPlayer0
          if temp1 = 2 then CEJB_CheckPlayer3
          rem Player 1 or 3: Check INPT2
          if temp1 = 1 then CEJB_CheckPlayer2
          if temp1 = 3 then CEJB_CheckPlayer4
          goto CEJB_Done
CEJB_CheckPlayer0
          rem Player 0: Check Genesis controller
          if !ControllerStatus{0} then CEJB_CheckPlayer0Joy2bPlus
          if !INPT0{7} then let temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer0Joy2bPlus
          rem Player 0: Check Joy2b+ controller
          if !ControllerStatus{1} then CEJB_Done
          if !INPT0{7} then let temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer3
          rem Player 3: Check Genesis controller
          if !ControllerStatus{0} then CEJB_CheckPlayer3Joy2bPlus
          if !INPT0{7} then let temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer3Joy2bPlus
          rem Player 3: Check Joy2b+ controller
          if !ControllerStatus{1} then CEJB_Done
          if !INPT0{7} then let temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer2
          rem Player 2: Check Genesis controller
          if !(ControllerStatus & $04) then CEJB_CheckPlayer2Joy2bPlus
          if !(INPT2 & $80) then let temp3 = 1
