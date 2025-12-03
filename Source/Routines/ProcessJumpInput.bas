          rem ChaosFight - Source/Routines/ProcessJumpInput.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

ProcessJumpInput
          rem Returns: Far (return otherbank)
          asm
ProcessJumpInput

end
          rem
          rem Returns: Far (return otherbank)
          rem Shared Jump Input Handler
          rem Handles jump input from enhanced buttons (Genesis Button C, Joy2B+ Button II)
          rem UP = Button C = Button II (no exceptions)
          rem
          rem INPUT: temp1 = player index (0-3), temp2 = cached animation state
          rem
          rem OUTPUT: Jump or character-specific behavior executed if conditions met
          rem
          rem Mutates: temp3, temp4, temp6, playerCharacter[], playerState[],
          rem         playerY[], characterStateFlags_W[]
          rem
          rem Called Routines: CheckEnhancedJumpButton (bank10), 
          rem                   ProcessUpAction (thisbank) - executes character-specific behavior
          rem
          rem Constraints: Must be colocated with ProcessUpAction in same bank
          
          rem Check enhanced button first (sets temp3 = 1 if pressed, 0 otherwise)
          rem Check Genesis/Joy2b+ Button C/II
          gosub CheckEnhancedJumpButton bank10
          
          rem If enhanced button not pressed, return (no action)
          if temp3 = 0 then return otherbank
          
          rem Execute character-specific UP action (UP = Button C = Button II)
          gosub ProcessUpAction
          
          return otherbank
