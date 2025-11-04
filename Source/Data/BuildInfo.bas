          rem ChaosFight - Source/Data/BuildInfo.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem BUILD INFO - Version Tracking and Attribution
          rem =================================================================
          rem Build date in year.julian format (e.g., 2025.256)
          rem Game URL: https://interworldly.com/games/ChaosFight
          rem These strings are embedded in the ROM for version tracking
          rem =================================================================
          
          rem Build date string in year.julian format (YYYY.JJJ)
          rem Format: ASCII bytes, null-terminated
          rem Generated at compile time via preprocessor defines BUILD_YEAR and BUILD_DAY
          rem Using preprocessor string substitution for BUILD_DATE_STRING
          data BuildDateString
          BUILD_DATE_STRING
          0
          end
          
          rem Game URL string for attribution
          rem Format: ASCII bytes, null-terminated
          data GameURLString
          "https://interworldly.com/games/ChaosFight"
          0
          end
