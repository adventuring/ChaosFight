; ChaosFight - Source/Common/BuildInfo.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Build info strings embedded in ROM

; Build date string in year.julian format (YYYY.JJJ)
; Format: ASCII bytes, null-terminated
; Generated at compile time via preprocessor defines BUILD_YEAR and BUILD_DAY
BuildDateString
        .byte 0, BUILD_DATE_STRING, 0

; Game URL string for attribution
; Format: ASCII bytes, null-terminated
GameURLString
        .byte "https://interworldly.com/games/ChaosFight", 0


