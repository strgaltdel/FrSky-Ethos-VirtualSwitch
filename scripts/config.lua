--- The file "config.lua" is licensed under the 3-clause BSD license (aka "new BSD")
---
-- Copyright (c) 2022, Udo Nowakowksi
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--   * Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--   * Redistributions in binary form must reproduce the above copyright
--     notice, this list of conditions and the following disclaimer in the
--     documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL SPEEDATA GMBH BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- Rev 1.0  12.12.2022      initial release             
                                    
--  ********************************************************
--  **  table which describes 
--  **  which action in which situation will be called
--  **  see defnition "FT" array for corresponding function
--  **  mainly used in "check_switchEvents"
--  ********************************************************

function define_actions(model)
    local normal    = 1
    local left      = 2
    local right     = 3
    local forward   = 4
    
    local actionArray = {}
    
    if model == "XYZ" then          -- enter dedicated model config here
    
    else                            -- standard config  
                                    -- left short                           left mid                               left long                                 right short                                right mid                                   right long
      --                        --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        actionArray[normal] =    {{"playTele",  "Altitude"  },    {"playTele",  "ESC Voltage"},  {"playTele","Dist"  },       {"playTmr",   1          },   {"playTele",  "Consumption" },    {"playTmr",   2           }  }
        actionArray[left]   =    {{"resetAlt",  nil         },    {"print",     "LEFT Lm"    },  {"resetTele", nil   },       {"resetTmr",  1          },   {"print"     ,"LEFT Rm"     },    {"resetTmr",  2           }  }
        actionArray[right]  =    {{"playTele",  "VFR"       },    {"playTele",  "GPS Alt"    },  {"print","rgt Ll"   },       {"playTele", "Dist"      },   {"playTele" , "RSSI"        },    {"print"    , "rgt RLong" }  }                                                                                                                                                   
        actionArray[forward]=    {{"toggle",    1           },    {"print",     "fwd Lm"     },  {"print","fwd Ll"   },       {"toggle",    2          },   {"print"     ,"fwd Rm"      },    {"print"    , "fwd RLong" }  }   
    end
    return(actionArray)
end
  
  
--  ********************************************************
--  **  some user specific customization
--  ********************************************************
 
 
function config_virtsw()

    local sim <const>               = false                     -- use switches A&B instead of gyro in sim mode 
                                                                -- sounds
    local soundfiles <const>        = true                      -- use personalized soundfiles in calls ("reset timer1", "your altitude is..")
                                                                -- files have to be in "/audio/'languagefolder'/"
                                                                -- ttsautomate template: "/libunow/sounds" (psv file)                                                               
    local audiofld <const>          = system.getLocale().."/"   -- lang specific folder

    -- ************      SOUNDFILES     **************
    -- you'll have to create them on your own (license agreements!)
    -- you can use ttsautomate, some psv's can be found in /libunow/audio
    -- it doesn't matter if there was no soundfile for a specific telemetry sensor etc declared, then only its value is announced
    
    --                                  label/sensor        folder              file
    local calls                         = {
                                        Altitude        =   audiofld    ..  "alti.wav" ,            -- "Alti"
                                        Dist            =   audiofld    ..  "dist.wav" ,            -- "Dist"
                                        timer1          =   audiofld    ..  "T1.wav" ,              -- "Timer"
                                        timer2          =   audiofld    ..  "T2.wav" ,
                                        timer3          =   audiofld    ..  "T3.wav" ,                                                                      
                                        resetT1         =   audiofld    ..  "reset_t1.wav" ,        -- "reset timer"
                                        resetT2         =   audiofld    ..  "reset_t2.wav" ,
                                        resetT3         =   audiofld    ..  "reset_t3.wav" ,
                                        resetAlt        =   audiofld    ..  "reset_alt.wav",
                                        resetTel        =   audiofld    ..  "reset_tel.wav",
                                        }

    return sim,soundfiles,calls
end
  
--  ********************************************************
--  **  
--  **  overview which functions can be called &
--  **  example list of sensors
--  **  
--  ********************************************************

--[[
---------
functions
---------
playTele,sensor
playTmr,timer

resetTele,  nil
resetAlt,  nil
resetTmr, timer

toggle, num (num = 1 or 2)
---------
Sensors:
---------
-- standard
RxBatt
Rx
Altitude
VSpeed

-- GPS
GPS Alt
GPS Speed
GPS Course

Air Speed


-- ESC
ESC Consumption
ESC Voltage
ESC Current
ESC RPM
ESC Temp
SBEC VFAS
SBEC AirSBEC VFAS


-- calc
Consumption
Dist

-- oXs

AccX
AccY
AccZ


]]
