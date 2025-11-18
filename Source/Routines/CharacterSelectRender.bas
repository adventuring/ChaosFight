          rem ChaosFight - Source/Routines/CharacterSelectRender.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

SelectDrawScreen
          asm
SelectDrawScreen

end
          rem Character Select drawing (sprites and HUD)
          rem Shared preview renderer used by Character Select and Arena Select flows
          rem Playfield layout is static; no runtime register writes
          let temp1 = 0
          gosub SelectRenderPlayerPreview
          let temp1 = 1
          gosub SelectRenderPlayerPreview
          if controllerStatus & SetQuadtariDetected then goto SelectDrawLowerPlayers
          gosub SelectHideLowerPlayerPreviews
          goto SelectDrawScreenDone
SelectDrawLowerPlayers
          let temp1 = 2
          gosub SelectRenderPlayerPreview
          let temp1 = 3
          gosub SelectRenderPlayerPreview
SelectDrawScreenDone
          return

SelectRenderPlayerPreview
          asm
SelectRenderPlayerPreview

end
          rem Draw character preview for the specified player and apply lock tinting
          gosub PlayerPreviewSetPosition
          gosub RenderPlayerPreview
          let temp1 = currentPlayer
          gosub GetPlayerLocked
          let temp5 = temp2
          if !temp5 then gosub SelectSetPlayerColorUnlocked
          if !temp5 then return
          if temp5 = PlayerHandicapped then gosub SelectSetPlayerColorHandicap
          if temp5 = PlayerHandicapped then return
          return

PlayerPreviewSetPosition
          asm
PlayerPreviewSetPosition
end
          rem Position player preview sprites in the four select quadrants
          if temp1 = 0 then goto PlayerPreviewSetPositionP0
          if temp1 = 1 then goto PlayerPreviewSetPositionP1
          if temp1 = 2 then goto PlayerPreviewSetPositionP2
          goto PlayerPreviewSetPositionP3
PlayerPreviewSetPositionP0
          player0x = 56
          player0y = 40
          return
PlayerPreviewSetPositionP1
          player1x = 104
          player1y = 40
          return
PlayerPreviewSetPositionP2
          player2x = 56
          player2y = 80
          return
PlayerPreviewSetPositionP3
          player3x = 104
          player3y = 80
          return

SelectHideLowerPlayerPreviews
          asm
SelectHideLowerPlayerPreviews
end
          rem Move lower-player previews off-screen when Quadtari is absent
          player2y = 200
          player3y = 200
          return

RenderPlayerPreview
          asm
RenderPlayerPreview
end
          rem Load preview sprite and base color for admin screens
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]
          if currentCharacter = NoCharacter then goto RenderPlayerPreviewDefault
          if currentCharacter = CPUCharacter then goto RenderPlayerPreviewDefault
          if currentCharacter = RandomCharacter then goto RenderPlayerPreviewDefault
          let temp4 = characterSelectPlayerAnimationFrame_R[currentPlayer]
          let temp1 = currentPlayer
          gosub GetPlayerLocked
          let temp5 = temp2
          let temp2 = temp4
          let temp3 = ActionIdle
          if temp5 = PlayerHandicapped then temp3 = ActionFallen
          goto RenderPlayerPreviewInvoke
RenderPlayerPreviewDefault
          let temp2 = 0
          let temp3 = ActionIdle
RenderPlayerPreviewInvoke
          gosub LoadCharacterSprite bank16
          let temp2 = 0
          let temp3 = 0
PlayerPreviewApplyColor
          rem Apply base color returned in temp6 to the appropriate sprite register
          if currentPlayer = 0 then COLUP0 = ColIndigo(12)
          if currentPlayer = 0 then return
          if currentPlayer = 1 then _COLUP1 = ColRed(12)
          if currentPlayer = 1 then return
          if currentPlayer = 2 then COLUP2 = ColYellow(12)
          if currentPlayer = 2 then return
          COLUP3 = ColTurquoise(12)
          return

SelectSetPlayerColorUnlocked
          asm
SelectSetPlayerColorUnlocked
end
          rem Override sprite color to indicate unlocked state (white)
          if currentPlayer = 0 then COLUP0 = ColGrey(14)
          if currentPlayer = 0 then return
          if currentPlayer = 1 then _COLUP1 = ColGrey(14)
          if currentPlayer = 1 then return
          if currentPlayer = 2 then COLUP2 = ColGrey(14)
          if currentPlayer = 2 then return
          COLUP3 = ColGrey(14)
          return

SelectSetPlayerColorHandicap
          asm
SelectSetPlayerColorHandicap

end
          rem Override sprite color to indicate handicap lock (dim player color)
          if currentPlayer = 0 then COLUP0 = ColIndigo(6)
          if currentPlayer = 0 then return
          if currentPlayer = 1 then _COLUP1 = ColRed(6)
          if currentPlayer = 1 then return
          if currentPlayer = 2 then COLUP2 = ColYellow(6)
          if currentPlayer = 2 then return
          COLUP3 = ColTurquoise(6)
          return

SelectUpdateAnimations
          asm
SelectUpdateAnimations
end
          rem Update character select animations for all players
          let temp1 = 0
          gosub GetPlayerLocked
          if temp2 then goto SelectDonePlayer0Animation
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
          if controllerStatus & SetQuadtariDetected then goto ProcessPlayer2Animation
          goto SelectDonePlayer23Animation
ProcessPlayer2Animation
          let temp1 = 2 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer2Animation
          if playerCharacter[2] = NoCharacter then goto SelectDonePlayer2Animation
          if playerCharacter[2] = RandomCharacter then goto SelectDonePlayer2Animation
          let temp1 = 2
          gosub SelectUpdatePlayerAnimation
SelectDonePlayer2Animation
          if controllerStatus & SetQuadtariDetected then goto ProcessPlayer3Animation
          goto SelectDonePlayer23Animation
ProcessPlayer3Animation
          let temp1 = 3 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer23Animation
          if playerCharacter[3] = NoCharacter then goto SelectDonePlayer23Animation
          if playerCharacter[3] = RandomCharacter then goto SelectDonePlayer23Animation
          let temp1 = 3
          gosub SelectUpdatePlayerAnimation
SelectDonePlayer23Animation
          return

SelectUpdatePlayerAnimation
          asm
SelectUpdatePlayerAnimation

end
          rem Update character select animation counters for one player
          rem
          rem Input: temp1 = player index (0-3)
          rem        characterSelectPlayerAnimationTimer_R[] = accumulated
          rem        output-frame counts
          rem        characterSelectPlayerAnimationFrame_R[] = sprite
          rem        frame index (0-7)
          rem
          rem Output: characterSelectPlayerAnimationFrame_W[temp1] advanced
          rem        when timer reaches AnimationFrameDelay
          rem
          rem Mutates: temp2, temp3, characterSelectPlayerAnimationTimer_W[],
          rem        characterSelectPlayerAnimationFrame_W[]
          rem
          rem Called Routines: None
          rem Constraints: Admin-only usage sharing SCRAM with game mode
          let temp2 = characterSelectPlayerAnimationTimer_R[temp1] + 1
          let characterSelectPlayerAnimationTimer_W[temp1] = temp2
          if temp2 < AnimationFrameDelay then return
          let characterSelectPlayerAnimationTimer_W[temp1] = 0
          let temp3 = (characterSelectPlayerAnimationFrame_R[temp1] + 1) & 7
          let characterSelectPlayerAnimationFrame_W[temp1] = temp3
          return

CharacterSelectCheckControllerRescan
          asm
CharacterSelectCheckControllerRescan
end
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          if switchselect then goto CharacterSelectDoRescan
          let temp6 = switchbw
          if temp6 = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub DetectPads bank13
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
CharacterSelectDoRescan
          gosub DetectPads bank13
CharacterSelectRescanDone
          return


