          rem ChaosFight - Source/Routines/HandleUpInput.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

HandleUpInput
          asm
HandleUpInput

end
          rem
          rem Shared UP Input Handler
          rem Handles UP input from joystick direction
          rem UP = Button C = Button II (no exceptions)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem        temp2 = cached animation state (for attack blocking)
          rem Uses: joy0up/joy0down for players 0,2; joy1up/joy1down for players 1,3
          rem
          rem OUTPUT: temp3 = jump flag (1 if UP used for jump, 0 if special ability)
          rem         Character state may be modified (form switching, RoboTito latch)
          rem
          rem Mutates: temp2, temp3, temp4, temp6, playerCharacter[],
          rem         playerY[], characterStateFlags_W[]
          rem
          rem Called Routines: ProcessUpAction (thisbank) - executes character-specific behavior
          rem
          rem Constraints: Must be colocated with ProcessUpAction in same bank
          
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 & 2 = 0 then goto HUI_UseJoy0
          if !joy1up then let temp3 = 0 : return thisbank
          goto HUI_ProcessUp
          
HUI_UseJoy0
          rem Players 0,2 use joy0
          if !joy0up then let temp3 = 0 : return thisbank
          
HUI_ProcessUp
          rem Execute character-specific UP action
          rem Tail call: goto instead of gosub since ProcessUpAction returns to our caller
          goto ProcessUpAction
