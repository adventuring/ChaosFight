          rem ChaosFight - Source/Routines/CharacterSelectRender.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

SelectDrawScreen
          rem Character Select drawing (sprites and HUD)
          rem Playfield layout is static; no runtime register writes
          rem Draw Player 1 selection (top left)
          player0x = 56 : player0y = 40
          gosub SelectDrawSprite
          rem Draw Player 2 selection (top right)
          player1x = 104 : player1y = 40
          gosub SelectDrawSprite
          if !(controllerStatus & SetQuadtariDetected) then goto SelectDrawScreenDone
          rem Draw Player 3 selection (bottom left)
          player0x = 56 : player0y = 80
          gosub SelectDrawSprite
          rem Draw Player 4 selection (bottom right)
          player1x = 104 : player1y = 80
          gosub SelectDrawSprite
SelectDrawScreenDone
          return

SelectDrawSprite
          rem Draw character sprite based on current position and playerCharacter
          temp3 = 255
          if player0x = 56 then goto SelectDeterminePlayerP0
          if player1x = 104 then goto SelectDeterminePlayerP1
          goto SelectDrawSpriteDone
SelectDeterminePlayerP0
          if player0y = 40 then temp3 = 0 : goto SelectLoadSprite
          if player0y = 80 then temp3 = 2 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
SelectDeterminePlayerP1
          if player1y = 40 then temp3 = 1 : goto SelectLoadSprite
          if player1y = 80 then temp3 = 3 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
SelectLoadSprite
          if temp3 > 3 then goto SelectDrawSpriteDone
          temp6 = temp3
          temp1 = playerCharacter[temp6]
          if temp1 = NoCharacter then goto SelectLoadSpecialSprite
          if temp1 = CPUCharacter then goto SelectLoadSpecialSprite
          if temp1 = RandomCharacter then goto SelectLoadSpecialSprite
          if characterSelectPlayerAnimationSequence_R[temp6] then goto SelectLoadWalkingSprite
          temp2 = characterSelectPlayerAnimationFrame_R[temp6]
          temp3 = 1
          temp4 = temp6
          gosub LocateCharacterArt bank10
          goto SelectLoadSpriteColor
SelectLoadSpecialSprite
          temp3 = temp6
          if temp1 = NoCharacter then temp6 = SpriteNo : goto SelectLoadSpecialSpriteCall
          if temp1 = CPUCharacter then temp6 = SpriteCPU : goto SelectLoadSpecialSpriteCall
          temp6 = SpriteQuestionMark
SelectLoadSpecialSpriteCall
          gosub LoadSpecialSprite bank10
          goto SelectLoadSpriteColor
SelectLoadWalkingSprite
          temp2 = characterSelectPlayerAnimationSequence_R[temp6]
          temp3 = 3
          temp4 = temp6
          gosub LocateCharacterArt bank10
SelectLoadSpriteColor
          temp1 = playerCharacter[temp6]
          temp2 = 0
          temp3 = temp6
          temp4 = 0
          gosub LoadCharacterColors bank10
          temp1 = temp6
          gosub GetPlayerLocked bank9
          temp5 = temp2
          temp3 = temp6
          if !temp5 then goto SelectApplyUnlockedColor
          if temp5 = PlayerHandicapped then goto SelectApplyHandicapColor
SelectDrawSpriteDone
          return
SelectApplyUnlockedColor
          gosub SelectSetPlayerColorUnlocked
          goto SelectDrawSpriteDone
SelectApplyHandicapColor
          gosub SelectSetPlayerColorHandicap
          goto SelectDrawSpriteDone


SelectSetPlayerColorUnlocked
          rem Override sprite color to indicate unlocked state (white)
          if temp3 > 3 then temp3 = 3
          on temp3 goto SelectSetPlayerColorUnlocked0 SelectSetPlayerColorUnlocked1 SelectSetPlayerColorUnlocked2 SelectSetPlayerColorUnlocked3
SelectSetPlayerColorUnlocked0
          COLUP0 = ColGrey(14)
          return
SelectSetPlayerColorUnlocked1
          _COLUP1 = ColGrey(14)
          return
SelectSetPlayerColorUnlocked2
          COLUP2 = ColGrey(14)
          return
SelectSetPlayerColorUnlocked3
          COLUP3 = ColGrey(14)
          return

SelectSetPlayerColorHandicap
          rem Override sprite color to indicate handicap lock (dim player color)
          if temp3 > 3 then temp3 = 3
          on temp3 goto SelectSetPlayerColorHandicap0 SelectSetPlayerColorHandicap1 SelectSetPlayerColorHandicap2 SelectSetPlayerColorHandicap3
SelectSetPlayerColorHandicap0
          COLUP0 = ColIndigo(6)
          return
SelectSetPlayerColorHandicap1
          _COLUP1 = ColRed(6)
          return
SelectSetPlayerColorHandicap2
          COLUP2 = ColYellow(6)
          return
SelectSetPlayerColorHandicap3
          COLUP3 = ColTurquoise(6)
          return

SelectUpdateAnimations
          rem Update character select animations for all players
          temp1 = 0 : gosub GetPlayerLocked bank9 : if temp2 then goto SelectSkipPlayer0Animation
          if playerCharacter[0] = CPUCharacter then goto SelectSkipPlayer0Animation
          if playerCharacter[0] = NoCharacter then goto SelectSkipPlayer0Animation
          if playerCharacter[0] = RandomCharacter then goto SelectSkipPlayer0Animation
          temp1 = 0
          gosub SelectUpdatePlayerAnimation
SelectSkipPlayer0Animation
          temp1 = 1 : gosub GetPlayerLocked bank9 : if temp2 then goto SelectSkipPlayer1Animation
          if playerCharacter[1] = CPUCharacter then goto SelectSkipPlayer1Animation
          if playerCharacter[1] = NoCharacter then goto SelectSkipPlayer1Animation
          if playerCharacter[1] = RandomCharacter then goto SelectSkipPlayer1Animation
          temp1 = 1
          gosub SelectUpdatePlayerAnimation
SelectSkipPlayer1Animation
          if !(controllerStatus & SetQuadtariDetected) then goto SelectSkipPlayer23Animation
          temp1 = 2 : gosub GetPlayerLocked bank9 : if temp2 then goto SelectSkipPlayer2Animation
          if playerCharacter[2] = NoCharacter then goto SelectSkipPlayer2Animation
          if playerCharacter[2] = RandomCharacter then goto SelectSkipPlayer2Animation
          temp1 = 2
          gosub SelectUpdatePlayerAnimation
SelectSkipPlayer2Animation
          if !(controllerStatus & SetQuadtariDetected) then goto SelectSkipPlayer23Animation
          temp1 = 3 : gosub GetPlayerLocked bank9 : if temp2 then goto SelectSkipPlayer23Animation
          if playerCharacter[3] = NoCharacter then goto SelectSkipPlayer23Animation
          if playerCharacter[3] = RandomCharacter then goto SelectSkipPlayer23Animation
          temp1 = 3
          gosub SelectUpdatePlayerAnimation
SelectSkipPlayer23Animation
          return

SelectUpdatePlayerAnimation
          rem Update animation for a single player
          temp2 = characterSelectPlayerAnimationFrame_R[temp1] + 1
          let characterSelectPlayerAnimationFrame_W[temp1] = temp2
          if characterSelectPlayerAnimationFrame_R[temp1] >= AnimationFrameDelay then goto SelectAdvanceAnimationFrame
          return
SelectAdvanceAnimationFrame
          let characterSelectPlayerAnimationFrame_W[temp1] = 0
          if !characterSelectPlayerAnimationSequence_R[temp1] then goto SelectAdvanceIdleAnimation
          temp2 = (characterSelectPlayerAnimationSequence_R[temp1] + 1) & 3
          let characterSelectPlayerAnimationSequence_W[temp1] = temp2
          if characterSelectPlayerAnimationSequence_R[temp1] then return
          let characterSelectPlayerAnimationSequence_W[temp1] = 0
          goto SelectAnimationWaitForToggle
SelectAdvanceIdleAnimation
          if frame & 63 then return
          let characterSelectPlayerAnimationSequence_W[temp1] = 1
          return
SelectAnimationWaitForToggle
          return

CharacterSelectCheckControllerRescan
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          if switchselect then goto CharacterSelectDoRescan
          temp6 = switchbw
          if temp6 = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub DetectControllers bank14
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
CharacterSelectDoRescan
          gosub DetectControllers bank14
CharacterSelectRescanDone
          return
