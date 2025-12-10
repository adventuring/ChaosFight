;;; ChaosFight - Source/Routines/CharacterSelectRender.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Player preview coordinate tables
SelectPreviewX:
          .byte 56, 104, 56, 104

SelectPreviewY:
          .byte 40, 40, 80, 80

          ;; Player color tables for normal and handicap lock sta

SelectPlayerColorNormal:
          .byte 12, 12, 12, 12

SelectPlayerColorHandicap_data:
          ;; TODO: ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)
SelectPlayerColorHandicap_end:
SelectPlayerColorHandicap = SelectPlayerColorHandicap_data


SelectDrawScreen .proc
          ;; Character Select drawing (sprites and HUD)
          ;; Returns: Far (return otherbank)
          ;; Shared preview renderer used by Character Select and Arena Select flows
          ;; Playfield layout is static; no runtime register writes
          lda # 2
          sta temp6
          if controllerStatus & SetQuadtariDetected then let temp6 = 4
          lda controllerStatus
          and # SetQuadtariDetected
          beq SetPlayerCount

          lda # 4
          sta temp6

SetPlayerCount:
          lda # 0
          sta temp1

.pend

SelectDrawScreenLoop .proc
          jsr SelectRenderPlayerPreview
          inc temp1
          ;; if temp1 < temp6 then goto SelectDrawScreenLoop
          lda temp1
          cmp temp6
          bcs SelectDrawScreenDone

          jmp SelectDrawScreenLoop

SelectDrawScreenDone:

          jsr BS_return

          ;; Cross-bank call to SelectHideLowerPlayerPreviews in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SelectHideLowerPlayerPreviews-1)
          pha
          lda # <(SelectHideLowerPlayerPreviews-1)
          pha
          ldx # 5
          jmp BS_jsr

return_point:

.pend

SelectRenderPlayerPreview:
          ;; Returns: Near (return thisbank)
          ;; Draw character preview for the specified player and apply lock tinting
          ;; Called same-bank from SelectDrawScreenLoop, so use return thisbank
          ;; Optimized: Combined duplicate conditionals, early return thisbank for common case
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          lda # >(return_point2-1)
          pha
          lda # <(return_point2-1)
          pha
          lda # >(PlayerPreviewSetPosition-1)
          pha
          lda # <(PlayerPreviewSetPosition-1)
          pha
          ldx # 5
          jmp BS_jsr
return_point_2:


          ;; Same-bank call to RenderPlayerPreview (defined in this file)
          ;; Cross-bank call to RenderPlayerPreview (defined later in this file, same bank)
          lda # >(return_point_render-1)
          pha
          lda # <(return_point_render-1)
          pha
          lda # >(RenderPlayerPreview-1)
          pha
          lda # <(RenderPlayerPreview-1)
          pha
          ldx # 5
          jmp BS_jsr
return_point_render:


          lda currentPlayer
          ;; Cross-bank call to GetPlayerLocked in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point_4:


          lda temp2
          sta temp5
          ;; Unlocked state (most common) - set color and return thisbank early
          jsr SelectSetPlayerColorUnlocked

          ;; Handicap state - set dimmed color and return thisbank
          jsr SelectSetPlayerColorHandicap

          ;; Normal locked state - color already set by RenderPlayerPreview
          rts
PlayerPreviewSetPosition
          ;; Returns: Far (return otherbank)
          ;; Position player preview sprites in the four select quadrants
          ;; let temp2 = SelectPreviewX[temp1]
          lda temp1
          asl
          tax
          lda SelectPreviewX,x
          sta temp2
          ;; let temp3 = SelectPreviewY[temp1]
          lda temp1
          asl
          tax
          lda SelectPreviewY,x
          sta temp3
          lda temp1
          asl
          tax
          lda SelectPreviewY,x
          sta temp3
          jsr SelectApplyPreviewPosition

SelectApplyPreviewPosition
          ;; Returns: Far (return thisbank)
          ;; Input: temp1 = player index, temp2 = X position, temp3 = y position
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          ;; Optimized: Use on...goto jump table for O(1) dispatch
          jmp SelectApplyPreviewPositionP0
SelectApplyPreviewPositionP0
          player0x = temp2
          player0y = temp3
          jsr BS_return
SelectApplyPreviewPositionP1
          player1x = temp2
          player1y = temp3
          jsr BS_return
SelectApplyPreviewPositionP2
          player2x = temp2
          player2y = temp3
          jsr BS_return
SelectApplyPreviewPositionP3
          player3x = temp2
          player3y = temp3

.pend

SelectHideLowerPlayerPreviews .proc
          ;; Move lower-player previews off-screen when Quadtari is absent
          ;; Returns: Far (return otherbank)
          player2y = 200
          player3y = 200
.pend

RenderPlayerPreview .proc
          ;; Load preview sprite and base color for admin screens
          ;; Returns: Far (return otherbank)
          lda temp1
          sta currentPlayer
          ;; let currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; if currentCharacter >= RandomCharacter then goto RenderPlayerPreviewDefault
          lda currentCharacter
          cmp RandomCharacter

          bcc GetAnimationFrame

          jmp RenderPlayerPreviewDefault

GetAnimationFrame:
          ;; let temp4 = characterSelectPlayerAnimationFrame_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda characterSelectPlayerAnimationFrame_R,x
          sta temp4
          lda currentPlayer
          ;; Cross-bank call to GetPlayerLocked in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point_5:

          lda temp2
          sta temp5
          lda temp4
          sta temp2
          lda ActionIdle
          sta temp3
          lda temp5
          cmp PlayerHandicapped
          bne RenderPlayerPreviewInvoke
          lda ActionFallen
          sta temp3
RenderPlayerPreviewInvoke:

          jmp RenderPlayerPreviewInvoke
RenderPlayerPreviewDefault
          lda # 0
          sta temp2
          lda ActionIdle
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point_6:

          ;; let temp2 = SelectPlayerColorNormal[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda SelectPlayerColorNormal,x
          sta temp2
          jsr SelectApplyPlayerColor
          lda # 0
          sta temp2
          lda # 0
          sta temp3

.pend

SelectApplyPlayerColor .proc
          ;; Input: currentPlayer selects target register, temp2 = color value
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectSetPlayerColorUnlocked/Handicap, so use return thisbank
          ;; Optimized: Use on...goto jump table for O(1) dispatch
          jmp SelectApplyPlayerColorP0
.pend

SelectApplyPlayerColorP0 .proc
          COLUP0 = temp2
          rts
.pend

SelectApplyPlayerColorP1 .proc
          _COLUP1 = temp2
.pend

SelectApplyPlayerColorP2 .proc
          COLUP2 = temp2
.pend

SelectApplyPlayerColorP3 .proc
          COLUP3 = temp2

.pend

SelectSetPlayerColorUnlocked .proc
          ;; Override sprite color to indicate unlocked state (white)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          lda # 14
          sta temp2
          jsr SelectApplyPlayerColor


.pend

SelectSetPlayerColorHandicap .proc

          ;; Override sprite color to indicate handicap lock (dim player color)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          ;; let temp2 = SelectPlayerColorHandicap[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda SelectPlayerColorHandicap,x
          sta temp2


          ;; Returns: Far (return otherbank)
          ;; Update character select animations for all players
          ;; Returns: Far (return otherbank)
          ;; Optimized: Compact inline version to reduce code size
          lda # 2
          sta temp6
          ;; if controllerStatus & SetQuadtariDetected then let temp6 = 4
          lda controllerStatus
          and SetQuadtariDetected
          beq SetPlayerCount
          lda # 4
          sta temp6
SetPlayerCount:
          lda # 0
          sta temp1
SelectUpdateAnimationLoop
          ;; Cross-bank call to GetPlayerLocked in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point_7:

          ;; if temp2 then goto SelectUpdateAnimationNext
          lda temp2
          beq UpdatePlayerAnimation
          jmp SelectUpdateAnimationNext
UpdatePlayerAnimation:
          ;; if playerCharacter[temp1] >= RandomCharacter then goto SelectUpdateAnimationNext
          jsr SelectUpdatePlayerAnimation
SelectUpdateAnimationNext
          ;; if temp1 < temp6 then goto SelectUpdateAnimationLoop
          lda temp1
          cmp temp6
          bcs SelectUpdateAnimationsDone
          jmp SelectUpdateAnimationLoop
SelectUpdateAnimationsDone:
          

SelectUpdatePlayerAnimation
          ;; Returns: Near (return thisbank)
          ;; Update character select animation counters for one player
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectUpdateAnimations, so use return thisbank
          ;;
          ;; Input: temp1 = player index (0-3)
          ;; characterSelectPlayerAnimationTimer_R[] = accumulated
          ;; output-frame counts
          ;; characterSelectPlayerAnimationFrame_R[] = sprite
          ;; frame index (0-7)
          ;;
          ;; Output: characterSelectPlayerAnimationFrame_W[temp1] advanced
          ;; when timer reaches AnimationFrameDelay
          ;;
          ;; Mutates: temp2, temp3, characterSelectPlayerAnimationTimer_W[],
          ;; characterSelectPlayerAnimationFrame_W[]
          ;;
          ;; Called Routines: None
          ;; Constraints: Admin-only usage sharing SCRAM with game mode
          ;; let temp2 = characterSelectPlayerAnimationTimer_R[temp1] + 1
          lda temp1
          asl
          tax
          lda characterSelectPlayerAnimationTimer_R,x
          sta temp2
          lda temp1
          asl
          tax
          lda temp2
          sta characterSelectPlayerAnimationTimer_W,x

          lda temp1
          asl
          tax
          lda 0
          sta characterSelectPlayerAnimationTimer_W,x
          ;; let temp3 = (characterSelectPlayerAnimationFrame_R[temp1] + 1) & 7
          lda temp1
          asl
          tax
          lda temp3
          sta characterSelectPlayerAnimationFrame_W,x
          rts
          ;; Returns: Far (return otherbank)
          ;; Re-detect controllers on Select/Pause/ColorB&W toggle
          ;; Returns: Far (return otherbank)
          ;; if switchselect then goto CharacterSelectDoRescan
          lda INPT4
          beq CheckColorBWToggle
          jmp CharacterSelectDoRescan
CheckColorBWToggle:
          lda switchbw
          sta temp6
          lda temp6
          cmp colorBWPrevious_R
          bne TriggerRescan
          jsr BS_return
TriggerRescan:

          ;; Cross-bank call to DetectPads in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point_8:

          lda switchbw
          sta colorBWPrevious_W
          jsr BS_return
.pend

CharacterSelectDoRescan .proc
          ;; Cross-bank call to DetectPads in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point_9:

CharacterSelectRescanDone:



.pend

