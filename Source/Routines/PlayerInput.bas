          rem ChaosFight - Source/Routines/PlayerInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER INPUT HANDLING
          rem =================================================================
          rem All input handling for the four players, with character-specific
          rem control logic dispatched to character-specific subroutines.
          rem
          rem QUADTARI MULTIPLEXING:
          rem   Even frames (qtcontroller=0): joy0=Player1, joy1=Player2
          rem   Odd frames (qtcontroller=1): joy0=Player3, joy1=Player4
          rem
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   PlayerX[0-3] - X positions
          rem   PlayerY[0-3] - Y positions
          rem   PlayerState[0-3] - State flags (attacking, guarding, jumping, etc.)
          rem   PlayerChar[0-3] - Character type indices (0-15)
          rem   PlayerMomentumX[0-3] - Horizontal momentum
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)
          rem
          rem STATE FLAGS (in PlayerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (disabled during hitstun)
          rem   Bits 4-7: Animation state
          rem
          rem CHARACTER INDICES (0-15):
          rem   0=Bernie, 1=Curling, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Magical Faerie, 9=Mystery, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem Main input handler for all players
HandleAllPlayerInput
          if qtcontroller then goto HandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2
          if !IsPlayerRecovery(PlayerState[0]) then gosub HandlePlayer1Input
          if !IsPlayerRecovery(PlayerState[1]) then gosub HandlePlayer2Input
          
          qtcontroller = 1  : rem Switch to odd frame
          return

HandleQuadtariPlayers
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected)
          if QuadtariDetected && SelectedChar3 != 0 then
                    if !IsPlayerRecovery(PlayerState[2]) then gosub HandlePlayer3Input
          endif
          if QuadtariDetected && SelectedChar4 != 0 then
                    if !IsPlayerRecovery(PlayerState[3]) then gosub HandlePlayer4Input
          endif
          
          qtcontroller = 0  : rem Switch back to even frame
          return

          rem =================================================================
          rem PLAYER 1 INPUT (joy0 on even frames)
          rem =================================================================
          rem INPUTS: joy0left, joy0right, joy0up, joy0down, joy0fire
          rem USES: PlayerX[0], PlayerY[0], PlayerState[0], PlayerChar[0]
HandlePlayer1Input
          if joy0left then
                    PlayerX[0] = PlayerX[0] - 1
                    PlayerState[0] = PlayerState[0] & ~1  : rem Face left
                    PlayerMomentumX[0] = -1
          endif
          if joy0right then
                    PlayerX[0] = PlayerX[0] + 1
                    PlayerState[0] = PlayerState[0] | 1   : rem Face right
                    PlayerMomentumX[0] = 1
          endif

          rem Jump - check traditional UP or enhanced Button C/II
          temp2 = 0  : rem Player index for CheckEnhancedJump
          gosub CheckEnhancedJump
          if temp1 && !IsPlayerJumping(PlayerState[0]) then
                    temp1 = 0  : rem Player index
                    temp4 = PlayerChar[0]  : rem Character type
                    on temp4 goto BernieJump, CurlingJump, DragonetJump, EXOJump, FatTonyJump, GrizzardJump, HarpyJump, KnightJump, MagicalFaerieJump, MysteryJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, VegDogJump
          endif

          rem Down - dispatch to character-specific handler
          if joy0down then
                    temp1 = 0
                    temp4 = PlayerChar[0]
                    on temp4 goto BernieDown, CurlingDown, DragonetDown, EXODown, FatTonyDown, GrizzardDown, HarpyDown, KnightDown, MagicalFaerieDown, MysteryDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, VegDogDown
          else
                    PlayerState[0] = PlayerState[0] & ~2  : rem Clear guard
          endif
          
          rem Fire - dispatch to character attack
          if joy0fire && !IsPlayerAttacking(PlayerState[0]) then
                    temp1 = 0
                    temp4 = PlayerChar[0]
                    on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, GrizzardHandlerAttack, HarpyAttack, KnightGuyAttack, MagicalFaerieAttack, MysteryManAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
          endif
          return

          rem =================================================================
          rem PLAYER 2 INPUT (joy1 on even frames)
          rem =================================================================
          rem INPUTS: joy1left, joy1right, joy1up, joy1down, joy1fire
          rem USES: PlayerX[1], PlayerY[1], PlayerState[1], PlayerChar[1]
HandlePlayer2Input
          if joy1left then
                    PlayerX[1] = PlayerX[1] - 1
                    PlayerState[1] = PlayerState[1] & ~1
                    PlayerMomentumX[1] = -1
          endif
          if joy1right then
                    PlayerX[1] = PlayerX[1] + 1
                    PlayerState[1] = PlayerState[1] | 1
                    PlayerMomentumX[1] = 1
          endif

          rem Jump - check traditional UP or enhanced Button C/II
          temp2 = 1  : rem Player index for CheckEnhancedJump
          gosub CheckEnhancedJump
          if temp1 && !IsPlayerJumping(PlayerState[1]) then
                    temp1 = 1  : rem Player index
                    temp4 = PlayerChar[1]
                    on temp4 goto BernieJump, CurlingJump, DragonetJump, EXOJump, FatTonyJump, GrizzardJump, HarpyJump, KnightJump, MagicalFaerieJump, MysteryJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, VegDogJump
          endif

          if joy1down then
                    temp1 = 1
                    temp4 = PlayerChar[1]
                    on temp4 goto BernieDown, CurlingDown, DragonetDown, EXODown, FatTonyDown, GrizzardDown, HarpyDown, KnightDown, MagicalFaerieDown, MysteryDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, VegDogDown
          else
                    PlayerState[1] = PlayerState[1] & ~2
          endif
          
          if joy1fire && !IsPlayerAttacking(PlayerState[1]) then
                    temp1 = 1
                    temp4 = PlayerChar[1]
                    on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, GrizzardHandlerAttack, HarpyAttack, KnightGuyAttack, MagicalFaerieAttack, MysteryManAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
          endif
          return

          rem =================================================================
          rem PLAYER 3 INPUT (joy0 on odd frames, Quadtari only)
          rem =================================================================
          rem INPUTS: joy0left, joy0right, joy0up, joy0down, joy0fire
          rem USES: PlayerX[2], PlayerY[2], PlayerState[2], PlayerChar[2]
HandlePlayer3Input
          if joy0left then
                    PlayerX[2] = PlayerX[2] - 1
                    PlayerState[2] = PlayerState[2] & ~1
                    PlayerMomentumX[2] = -1
          endif
          if joy0right then
                    PlayerX[2] = PlayerX[2] + 1
                    PlayerState[2] = PlayerState[2] | 1
                    PlayerMomentumX[2] = 1
          endif

          if joy0up && !IsPlayerJumping(PlayerState[2]) then
                    temp1 = 2
                    temp4 = PlayerChar[2]
                    on temp4 goto BernieJump, CurlingJump, DragonetJump, EXOJump, FatTonyJump, GrizzardJump, HarpyJump, KnightJump, MagicalFaerieJump, MysteryJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, VegDogJump
          endif

          if joy0down then
                    temp1 = 2
                    temp4 = PlayerChar[2]
                    on temp4 goto BernieDown, CurlingDown, DragonetDown, EXODown, FatTonyDown, GrizzardDown, HarpyDown, KnightDown, MagicalFaerieDown, MysteryDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, VegDogDown
          else
                    PlayerState[2] = PlayerState[2] & ~2
          endif
          
          if joy0fire && !IsPlayerAttacking(PlayerState[2]) then
                    temp1 = 2
                    temp4 = PlayerChar[2]
                    on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, GrizzardHandlerAttack, HarpyAttack, KnightGuyAttack, MagicalFaerieAttack, MysteryManAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
          endif
          return

          rem =================================================================
          rem PLAYER 4 INPUT (joy1 on odd frames, Quadtari only)
          rem =================================================================
          rem INPUTS: joy1left, joy1right, joy1up, joy1down, joy1fire
          rem USES: PlayerX[3], PlayerY[3], PlayerState[3], PlayerChar[3]
HandlePlayer4Input
          if joy1left then
                    PlayerX[3] = PlayerX[3] - 1
                    PlayerState[3] = PlayerState[3] & ~1
                    PlayerMomentumX[3] = -1
          endif
          if joy1right then
                    PlayerX[3] = PlayerX[3] + 1
                    PlayerState[3] = PlayerState[3] | 1
                    PlayerMomentumX[3] = 1
          endif

          if joy1up && !IsPlayerJumping(PlayerState[3]) then
                    temp1 = 3
                    temp4 = PlayerChar[3]
                    on temp4 goto BernieJump, CurlingJump, DragonetJump, EXOJump, FatTonyJump, GrizzardJump, HarpyJump, KnightJump, MagicalFaerieJump, MysteryJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, VegDogJump
          endif

          if joy1down then
                    temp1 = 3
                    temp4 = PlayerChar[3]
                    on temp4 goto BernieDown, CurlingDown, DragonetDown, EXODown, FatTonyDown, GrizzardDown, HarpyDown, KnightDown, MagicalFaerieDown, MysteryDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, VegDogDown
          else
                    PlayerState[3] = PlayerState[3] & ~2
          endif
          
          if joy1fire && !IsPlayerAttacking(PlayerState[3]) then
                    temp1 = 3
                    temp4 = PlayerChar[3]
                    on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, GrizzardHandlerAttack, HarpyAttack, KnightGuyAttack, MagicalFaerieAttack, MysteryManAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
          endif
          return

