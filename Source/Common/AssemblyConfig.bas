          rem ChaosFight - Source/Common/AssemblyConfig.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Assembly configuration symbols for batariBASIC-generated
          rem code
          rem These are included at the top of the generated assembly
          rem file

          rem Bankswitching configuration
          rem Note: batariBASIC automatically defines bankswitch from
          rem set romsize,
          const bankswitch = 64 : rem   but we explicitly define it here to ensure it’s available in assembler
          rem EF bankswitching (64KiB with SuperChip RAM)

          rem Kernel configuration
          rem Note: Most of these are automatically defined by
          rem batariBASIC based on
          const pfres = 8 : rem   set kernel and set romsize commands, but pfres must be defined manually
          rem Playfield resolution: 8 rows (fixed for all playfields)

