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


SelectDrawScreen .proc
          ;; Character Select drawing (sprites and HUD)
          ;; Returns: Far (return otherbank)
          ;; Shared preview renderer used by Character Select and Arena Select flows
          ;; Playfield layout is static; no runtime register writes
          lda # 2
          sta temp6
                    ;; if controllerStatus & SetQuadtariDetected then let temp6 = 4
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          beq skip_9550
          ;; lda # 4 (duplicate)
          ;; sta temp6 (duplicate)
skip_9550:
          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)
.pend

SelectDrawScreenLoop .proc
          jsr SelectRenderPlayerPreview
          inc temp1
                    ;; if temp1 < temp6 then goto SelectDrawScreenLoop
          ;; lda temp1 (duplicate)
          cmp temp6
          bcs skip_4617
          jmp SelectDrawScreenLoop
skip_4617:
          
          ;; jsr BS_return (duplicate)
          ;; Cross-bank call to SelectHideLowerPlayerPreviews in bank 6
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SelectHideLowerPlayerPreviews-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SelectHideLowerPlayerPreviews-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 5
          ;; jmp BS_jsr (duplicate)
return_point:

          ;; jsr BS_return (duplicate)

SelectRenderPlayerPreview
          ;; Returns: Near (return thisbank)
;; SelectRenderPlayerPreview (duplicate)
          ;; Draw character preview for the specified player and apply lock tinting
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectDrawScreenLoop, so use return thisbank
          ;; Optimized: Combined duplicate conditionals, early return thisbank for common case
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayerPreviewSetPosition-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_2:


          ;; Cross-bank call to RenderPlayerPreview in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RenderPlayerPreview-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_3:


          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to GetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_4:


          ;; lda temp2 (duplicate)
          ;; sta temp5 (duplicate)
          ;; Unlocked state (most common) - set color and return thisbank early
          ;; jsr SelectSetPlayerColorUnlocked (duplicate)

          ;; Handicap state - set dimmed color and return thisbank
          ;; jsr SelectSetPlayerColorHandicap (duplicate)

          ;; Normal locked state - color already set by RenderPlayerPreview
          rts
PlayerPreviewSetPosition
          ;; Returns: Far (return otherbank)
;; PlayerPreviewSetPosition (duplicate)
          ;; Position player preview sprites in the four select quadrants
          ;; Returns: Far (return otherbank)
                    ;; let temp2 = SelectPreviewX[temp1]          lda temp1          asl          tax          lda SelectPreviewX,x          sta temp2
                    ;; let temp3 = SelectPreviewY[temp1]
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda SelectPreviewY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SelectPreviewY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; jsr SelectApplyPreviewPosition (duplicate)
          ;; jsr BS_return (duplicate)

SelectApplyPreviewPosition
          ;; Returns: Far (return thisbank)
;; SelectApplyPreviewPosition (duplicate)
          ;; Input: temp1 = player index, temp2 = X position, temp3 = y position
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          ;; Optimized: Use on...goto jump table for O(1) dispatch
          ;; jmp SelectApplyPreviewPositionP0 (duplicate)
SelectApplyPreviewPositionP0
          player0x = temp2
          player0y = temp3
          ;; jsr BS_return (duplicate)
SelectApplyPreviewPositionP1
          player1x = temp2
          player1y = temp3
          ;; jsr BS_return (duplicate)
SelectApplyPreviewPositionP2
          player2x = temp2
          player2y = temp3
          ;; jsr BS_return (duplicate)
SelectApplyPreviewPositionP3
          player3x = temp2
          player3y = temp3
          ;; jsr BS_return (duplicate)

.pend

SelectHideLowerPlayerPreviews .proc
          ;; Move lower-player previews off-screen when Quadtari is absent
          ;; Returns: Far (return otherbank)
          ;; player2y = 200 (duplicate)
          ;; player3y = 200 (duplicate)
          ;; jsr BS_return (duplicate)

RenderPlayerPreview
          ;; Returns: Far (return otherbank)
;; RenderPlayerPreview (duplicate)
          ;; Load preview sprite and base color for admin screens
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; if currentCharacter >= RandomCharacter then goto RenderPlayerPreviewDefault
          ;; lda currentCharacter (duplicate)
          ;; cmp RandomCharacter (duplicate)

          bcc skip_163

          ;; jmp skip_163 (duplicate)

skip_163:
                    ;; let temp4 = characterSelectPlayerAnimationFrame_R[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterSelectPlayerAnimationFrame_R,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to GetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_5:

          ;; lda temp2 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda ActionIdle (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp5 (duplicate)
          ;; cmp PlayerHandicapped (duplicate)
          bne skip_6659
          ;; lda ActionFallen (duplicate)
          ;; sta temp3 (duplicate)
skip_6659:

          ;; jmp RenderPlayerPreviewInvoke (duplicate)
RenderPlayerPreviewDefault
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda ActionIdle (duplicate)
          ;; sta temp3 (duplicate)
RenderPlayerPreviewInvoke
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadCharacterSprite-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadCharacterSprite-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_6:

                    ;; let temp2 = SelectPlayerColorNormal[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SelectPlayerColorNormal,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; jsr SelectApplyPlayerColor (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; jsr BS_return (duplicate)

.pend

SelectApplyPlayerColor .proc
          ;; Input: currentPlayer selects target register, temp2 = color value
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectSetPlayerColorUnlocked/Handicap, so use return thisbank
          ;; Optimized: Use on...goto jump table for O(1) dispatch
          ;; jmp SelectApplyPlayerColorP0 (duplicate)
.pend

SelectApplyPlayerColorP0 .proc
          COLUP0 = temp2
          ;; rts (duplicate)
.pend

SelectApplyPlayerColorP1 .proc
          _COLUP1 = temp2
          ;; rts (duplicate)
.pend

SelectApplyPlayerColorP2 .proc
          COLUP2 = temp2
          ;; rts (duplicate)
.pend

SelectApplyPlayerColorP3 .proc
          COLUP3 = temp2
          ;; rts (duplicate)

.pend

SelectSetPlayerColorUnlocked .proc
          ;; Override sprite color to indicate unlocked state (white)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          ;; lda $0E(14) (duplicate)
          ;; sta temp2 (duplicate)
          ;; jsr SelectApplyPlayerColor (duplicate)

          ;; rts (duplicate)

.pend

SelectSetPlayerColorHandicap .proc

          ;; Override sprite color to indicate handicap lock (dim player color)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
                    ;; let temp2 = SelectPlayerColorHandicap[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SelectPlayerColorHandicap,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; jsr SelectApplyPlayerColor (duplicate)

          ;; rts (duplicate)

SelectUpdateAnimations
          ;; Returns: Far (return otherbank)
;; SelectUpdateAnimations (duplicate)
          ;; Update character select animations for all players
          ;; Returns: Far (return otherbank)
          ;; Optimized: Compact inline version to reduce code size
          ;; lda # 2 (duplicate)
          ;; sta temp6 (duplicate)
                    ;; if controllerStatus & SetQuadtariDetected then let temp6 = 4
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; beq skip_9550 (duplicate)
          ;; lda # 4 (duplicate)
          ;; sta temp6 (duplicate)
;; skip_9550: (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)
SelectUpdateAnimationLoop
          ;; Cross-bank call to GetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_7:

                    ;; if temp2 then goto SelectUpdateAnimationNext
          ;; lda temp2 (duplicate)
          ;; beq skip_6708 (duplicate)
          ;; jmp SelectUpdateAnimationNext (duplicate)
skip_6708:
                    ;; if playerCharacter[temp1] >= RandomCharacter then goto SelectUpdateAnimationNext
          ;; jsr SelectUpdatePlayerAnimation (duplicate)
SelectUpdateAnimationNext
          ;; inc temp1 (duplicate)
                    ;; if temp1 < temp6 then goto SelectUpdateAnimationLoop
          ;; lda temp1 (duplicate)
          ;; cmp temp6 (duplicate)
          ;; bcs skip_343 (duplicate)
          ;; jmp SelectUpdateAnimationLoop (duplicate)
skip_343:
          
          ;; jsr BS_return (duplicate)

SelectUpdatePlayerAnimation
          ;; Returns: Near (return thisbank)
;; SelectUpdatePlayerAnimation (duplicate)

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
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterSelectPlayerAnimationTimer_R,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta characterSelectPlayerAnimationTimer_W,x (duplicate)
          ;; rts (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta characterSelectPlayerAnimationTimer_W,x (duplicate)
                    ;; let temp3 = (characterSelectPlayerAnimationFrame_R[temp1] + 1) & 7
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta characterSelectPlayerAnimationFrame_W,x (duplicate)
          ;; rts (duplicate)
CharacterSelectCheckControllerRescan
          ;; Returns: Far (return otherbank)
;; CharacterSelectCheckControllerRescan (duplicate)
          ;; Re-detect controllers on Select/Pause/ColorB&W toggle
          ;; Returns: Far (return otherbank)
                    ;; if switchselect then goto CharacterSelectDoRescan
          ;; lda switchselect (duplicate)
          ;; beq skip_2466 (duplicate)
          ;; jmp CharacterSelectDoRescan (duplicate)
skip_2466:
          ;; lda switchbw (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; cmp colorBWPrevious_R (duplicate)
          ;; bne skip_8969 (duplicate)
          ;; jmp CharacterSelectRescanDone (duplicate)
skip_8969:

          ;; Cross-bank call to DetectPads in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DetectPads-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DetectPads-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_8:

          ;; lda switchbw (duplicate)
          ;; sta colorBWPrevious_W (duplicate)
          ;; jmp CharacterSelectRescanDone (duplicate)
.pend

CharacterSelectDoRescan .proc
          ;; Cross-bank call to DetectPads in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DetectPads-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DetectPads-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point_9:

CharacterSelectRescanDone
          ;; jsr BS_return (duplicate)



.pend

