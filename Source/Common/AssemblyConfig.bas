          rem ChaosFight - Source/Common/AssemblyConfig.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Configuration for kernel, romsize, and other batariBASIC settings

          rem Set processor directive early so BankSwitching.s can use assembly instructions
          rem Note: Use 6502 for Atari 2600 (6507) - DASM doesn't support 6507, but they're identical
          asm
             processor 6502
end

          const multisprite = 2
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          set optimization noinlinedata
          rem no matter what happens, never turn on “smart” branching.
          set smartbranching off

          rem Assembly configuration symbols for batariBASIC-generated code
          rem These are included at the top of the generated assembly file
          rem Bankswitching configuration
          rem Note: batariBASIC automatically defines bankswitch from set romsize
          rem EF bankswitching (64KiB with SuperChip RAM)

          rem Kernel configuration
          rem Note: Most of these are automatically defined by batariBASIC based on
          const pfres = 8
          rem   set kernel and set romsize commands, but pfres must be defined manually
          rem Playfield resolution: 8 rows (fixed for all playfields)
