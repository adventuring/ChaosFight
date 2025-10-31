; ChaosFight - Generated assembly wrapper template
; This file is processed by cpp with TV_STANDARD defined
; TV_STANDARD is a macro that gets replaced with NTSC/PAL/SECAM

#define STRINGIFY(x) #x
#define EXPAND_STRINGIFY(x) STRINGIFY(x)

          include "Source/Common/AssemblyConfig.s"
          include EXPAND_STRINGIFY(Source/Common/AssemblyConfig.TV_STANDARD.s)
          include EXPAND_STRINGIFY(Source/Generated/ChaosFight.TV_STANDARD.body.s)
          include "Source/Common/AssemblyFooter.s"

