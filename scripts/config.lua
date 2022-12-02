--- The lua library "config.lua" is licensed under the 3-clause BSD license (aka "new BSD")
---
-- Copyright (c) 2022, Udo Nowakowksi
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--	 * Redistributions of source code must retain the above copyright
--	   notice, this list of conditions and the following disclaimer.
--	 * Redistributions in binary form must reproduce the above copyright
--	   notice, this list of conditions and the following disclaimer in the
--	   documentation and/or other materials provided with the distribution.
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


-- Rev 0.8	12.01.2022


--  ********************************************************
--  **  table which describes 
--  **  which action in which situation will be called
--  **  see defnition "FT" array for corresponding function
--  **  mainly used in "check_switchEvents"
--  ********************************************************

function define_actions(model)
	local normal= 1
	local left	= 2
	local right = 3
	local forward = 4
	
	local actionArray = {}
	
	if model == "XYZ" then			-- enter dedicated model config here
	
	else							-- standard config
	
									-- left short                           left mid                        left long                                 right short                                right mid                                   right long
	  --                        --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		actionArray[normal] =    {{"playTele",   "Altitude"  },    {"playTmr",         2     },  {"playTele","Dist"  },       {"playTele",  "VFR"         },    {"playTele",  "Consumption"  },    {"playTele"  ,"RSSI"      }  }
		actionArray[left] 	=    {{"resetTele",  nil         },    {"playTele",  "GPS Speed" },  {"resetAlt",  nil   },       {"playTele",  "ESC Voltage" },    {"print"     ,"lft Rm"       },    {"print"     , "lft RLong"}  }
		actionArray[right]	=    {{"playTele",   "GPS Speed" },    {"playTele",  "GPS Alt"   },  {"print","rgt Ll"   },       {"playTele",  "GPS Alt"     },    {"print"     ,"rgt Rm"       },    {"print"     , "rgt RLong"}  }                                                                                                                                                   
		actionArray[forward]=    {{"toggle",                 },    {"print",     "fwd Lm"    },  {"print","fwd Ll"   },       {"toggle",      2           },    {"print"     ,"fwd Rm"       },    {"print"     , "fwd RLong"}  }   
	end
	return(actionArray)
end



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
