          rem ChaosFight - Source/Common/AssemblyConfig.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem includesfile must run before any set statements so batariBASIC keeps
          rem multispritesuperchipheader.asm (which pulls in superchip.h)
          includesfile multisprite_superchip.inc

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          rem Enable smartbranching; filter-smartbranch converts bB v1.9 guards to DASM .if/.else/.endif syntax
          set smartbranching on

          rem Assembly configuration symbols for batariBASIC-generated code
          rem These are included at the top of the generated assembly file
          rem Bankswitching configuration
          rem Note: batariBASIC automatically defines bankswitch from set romsize,
          const bankswitch = 64 : rem   but we explicitly define it here to ensure it’s available in assembler
          rem EF bankswitching (64KiB with SuperChip RAM)

          rem Kernel configuration
          rem Note: Most of these are automatically defined by batariBASIC based on
          const pfres = 8 : rem   set kernel and set romsize commands, but pfres must be defined manually
          rem Playfield resolution: 8 rows (fixed for all playfields)
