          rem ChaosFight - Source/Routines/CharacterSelectRender.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
          let currentPlayer = 255
          if player0x = 56 then goto SelectDeterminePlayerP0
          if player1x = 104 then goto SelectDeterminePlayerP1
          goto SelectDrawSpriteDone
SelectDeterminePlayerP0
          if player0y = 40 then let currentPlayer = 0 : goto SelectLoadSprite
          if player0y = 80 then let currentPlayer = 2 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
SelectDeterminePlayerP1
          if player1y = 40 then let currentPlayer = 1 : goto SelectLoadSprite
          if player1y = 80 then let currentPlayer = 3 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
SelectLoadSprite
          if currentPlayer > 3 then goto SelectDrawSpriteDone
          let currentCharacter = playerCharacter[currentPlayer]
          if currentCharacter = NoCharacter then goto SelectUseDefaultAnimation
          if currentCharacter = CPUCharacter then goto SelectUseDefaultAnimation
          if currentCharacter = RandomCharacter then goto SelectUseDefaultAnimation
          if characterSelectPlayerAnimationSequence_R[currentPlayer] then goto SelectLoadWalkingSprite
          temp2 = characterSelectPlayerAnimationFrame_R[currentPlayer]
          temp3 = ActionIdle
          goto SelectInvokeSpriteLoad
SelectLoadWalkingSprite
          temp2 = characterSelectPlayerAnimationSequence_R[currentPlayer]
          temp3 = ActionWalking
          goto SelectInvokeSpriteLoad
SelectUseDefaultAnimation
          temp2 = 0
          temp3 = ActionIdle
SelectInvokeSpriteLoad
          gosub LoadCharacterSprite bank16
SelectLoadSpriteColor
          temp2 = 0
          temp3 = 0
          gosub LoadCharacterColors bank16
          gosub SelectApplyPlayerColor
          let temp1 = currentPlayer
          gosub GetPlayerLocked
          temp5 = temp2
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

SelectApplyPlayerColor
          rem Apply base color returned in temp6 to the appropriate sprite register
          if currentPlayer = 0 then COLUP0 = temp6 : return
          if currentPlayer = 1 then _COLUP1 = temp6 : return
          if currentPlayer = 2 then COLUP2 = temp6 : return
          COLUP3 = temp6
          return


SelectSetPlayerColorUnlocked
          rem Override sprite color to indicate unlocked state (white)
          if currentPlayer = 0 then COLUP0 = ColGrey(14) : return
          if currentPlayer = 1 then _COLUP1 = ColGrey(14) : return
          if currentPlayer = 2 then COLUP2 = ColGrey(14) : return
          COLUP3 = ColGrey(14)
          return

SelectSetPlayerColorHandicap
          rem Override sprite color to indicate handicap lock (dim player color)
          if currentPlayer = 0 then COLUP0 = ColIndigo(6) : return
          if currentPlayer = 1 then _COLUP1 = ColRed(6) : return
          if currentPlayer = 2 then COLUP2 = ColYellow(6) : return
          COLUP3 = ColTurquoise(6)
          return

SelectUpdateAnimations
          rem Update character select animations for all players
          let temp1 = 0 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer0Animation
          if playerCharacter[0] = CPUCharacter then goto SelectDonePlayer0Animation
          if playerCharacter[0] = NoCharacter then goto SelectDonePlayer0Animation
          if playerCharacter[0] = RandomCharacter then goto SelectDonePlayer0Animation
          let temp1 = 0
          gosub SelectUpdatePlayerAnimation
SelectDonePlayer0Animation
          let temp1 = 1 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer1Animation
          if playerCharacter[1] = CPUCharacter then goto SelectDonePlayer1Animation
          if playerCharacter[1] = NoCharacter then goto SelectDonePlayer1Animation
          if playerCharacter[1] = RandomCharacter then goto SelectDonePlayer1Animation
          let temp1 = 1
          gosub SelectUpdatePlayerAnimation
SelectDonePlayer1Animation
          if !(controllerStatus & SetQuadtariDetected) then goto SelectDonePlayer23Animation
          let temp1 = 2 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer2Animation
          if playerCharacter[2] = NoCharacter then goto SelectDonePlayer2Animation
          if playerCharacter[2] = RandomCharacter then goto SelectDonePlayer2Animation
          let temp1 = 2
          gosub SelectUpdatePlayerAnimation
SelectDonePlayer2Animation
          if !(controllerStatus & SetQuadtariDetected) then goto SelectDonePlayer23Animation
          let temp1 = 3 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer23Animation
          if playerCharacter[3] = NoCharacter then goto SelectDonePlayer23Animation
          if playerCharacter[3] = RandomCharacter then goto SelectDonePlayer23Animation
          let temp1 = 3
          gosub SelectUpdatePlayerAnimation
SelectDonePlayer23Animation
          return

SelectUpdatePlayerAnimation
          rem Update animation for a single player
          let temp2 = characterSelectPlayerAnimationFrame_R[temp1] + 1
          let characterSelectPlayerAnimationFrame_W[temp1] = temp2
          if characterSelectPlayerAnimationFrame_R[temp1] >= AnimationFrameDelay then goto SelectAdvanceAnimationFrame
          return
SelectAdvanceAnimationFrame
          let characterSelectPlayerAnimationFrame_W[temp1] = 0
          if !characterSelectPlayerAnimationSequence_R[temp1] then goto SelectAdvanceIdleAnimation
          let temp2 = (characterSelectPlayerAnimationSequence_R[temp1] + 1) & 3
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
          let temp6 = switchbw
          if temp6 = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub DetectControllers bank14
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
CharacterSelectDoRescan
          gosub DetectControllers bank14
CharacterSelectRescanDone
          return
