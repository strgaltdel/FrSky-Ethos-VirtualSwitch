--- The lua library "SwFuncs.lua" is licensed under the 3-clause BSD license (aka "new BSD")
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


-- Rev 1.0  Dec. 2022   initial release




-- virtual switch functions / functionality 
-- (to be configured in config.lua)
-- following six dedicated functions are callable 
-- these do support some "specialized" operations (e.g. look playTele)
-- alternatively you can use a "direct" lua function call in config array


-- 1  playTele(label)       -- plays telemetry value, dependent on "label" decimals, units etc. may be "individual" configured
-- 2  playTmr(timer)        -- play timer, timer= timer num, starting with 1 to equal ethos !
-- 3  rstTmr(timer)         -- sets timer to zero (reset upcounting timer), timer = timer num; waiting for additional lua method to reset downcounting timers
-- 4  resetAlt()            -- resets GPS & Baro Alt
-- 5  resetTele()           -- resets "ALT","Dist","GPS", "Ccon"
-- 6  toggle(switch)        -- toggles "on/off" state of a LSW, control of two LSW's supported


-- 1  playTele(label)       -- plays telemetry value, dependent on "label" decimals, units etc. may be "individual" configured
function playTele(label,soundfiles,calls)

    -- at first: determine meas. system 
    local sysunits ="metric"
    local u_units = {}                  -- used units
    local x_units = {}                  -- possible units
    x_units.metric = {                  -- metric system
        lenght      = UNIT_METER,
        temp        = UNIT_CELSIUS,
        speed       = UNIT_KPH
        }
    x_units.imperial = {                    -- imperial system
        lenght      = UNIT_FOOT,
        temp        = UNIT_FAHRENHEIT,
        speed       = UNIT_MPH  
        }
        
    if sysunits == "metric" then
        u_units = x_units.metric
    else
        u_units = x_units.imperial
    end

    if soundfiles then 
        if pcall(function() playWav(calls[label]) end) then end                 -- play prefix wav if wished & defined
    end
    -- let's play some telemetry values:
    if label == "Altitude" then
        playNumber(TeleVal("Altitude"),UNIT_METER)                              -- altitude (meters)
    elseif label == "Dist" then
        playNumber(TeleVal("Dist"),u_units.lenght)                              -- distance (meters)        
    elseif label == "Distance" then
        playNumber(TeleVal("Distance"),u_units.lenght)                              -- distance (meters)    
    elseif label == "ESC Voltage" then
        playNumber(TeleVal("ESC Voltage"),UNIT_VOLT,1)                                  -- Lipo Voltage (volt)  
    elseif label == "Ccon" then
        playNumber(TeleVal("Ccon"),UNIT_MILLIAMPERE)                            -- consumption (mAh)    (use milliAmps to shorten time)
    elseif label == "Consumption" then
        playNumber(TeleVal("Consumption"),UNIT_MILLIAMPERE)
    elseif label == "TFet" then
        playNumber(TeleVal("TFet"),u_units.temp)                                -- FET temperature (deg)    
    elseif label == "GPS Speed" then
        playNumber(TeleVal("GPS Speed"),u_units.speed)                          -- GPS speed (kmh)
    elseif label == "RxBatt" then
        playNumber(TeleVal("RxBatt"),nil,1) 
    elseif label == "RSSI" then
        playNumber(TeleVal("RSSI"),UNIT_DB)                                     -- RSSI (dB)
    elseif label == "xy" then
        playNumber(TeleVal("xy"),UNIT_DB)                                       -- add more here
    else
        playNumber(TeleVal(label))
    end
end

 

-- 2  playTmr(timer)            -- play timer, timer= timer num, starting with 1 to equal ethos !
function playTmr(tmrNum,soundfiles,calls)                                       
    local tmr, tHour, tMinute, tSecond
    print("state sound",soundfiles)
    if soundfiles then 
        if pcall(function() playWav(calls["timer"..tostring(tmrNum)]) end) then end
    end
    --if soundfiles then playWav("en/T1.wav")end
    if pcall(function () tmr  = model.getTimer(tmrNum-1) end) then
        local val = tmr:value()  

        if val ~= nil then                                          -- anonymous function neccessary
            tHour       = math.floor(val/3600)                      -- deconstruct timer value
            tMinute     = math.floor((val-tHour*3600)/60)
            tSecond     = val-  tHour*3600 -   tMinute*60               
        end
        print("Timer  " .. tHour..":" .. tMinute ..":".. tSecond)
        
        if tHour > 0 then
            playNumber(tHour,UNIT_HOUR)
        end
        
        playNumber(tMinute,UNIT_MINUTE)
        playNumber(tSecond,UNIT_SECOND)
        return true
    else
        print("Timer error")
    end
end



-- 3  rstTmr(timer)         -- sets timer to zero (reset upcounting timer), timer = timer num; waiting for additional lua method to reset downcounting timers
function resetTmr(tmrNum,soundfiles,calls)                  
    local tmr = model.getTimer(tmrNum)
    
    if soundfiles then 
        if pcall(function() playWav(calls["resetT"..tostring(tmrNum)]) end) then end
    end
    
    
    if pcall(function () tmr:value(0) end) then
    else
        print("error timer",tmrNum)
    end 
    
end


-- 4  resetAlt()            -- resets GPS & Baro Alt
function resetAlt(dummy,soundfiles,calls)   
    local sensors = {"Altitude","Dist"} 
    if soundfiles then 
        if pcall(function() playWav(calls["resetAlt"]) end) then end
    end
    
    for i=1,#sensors do
        print("reset",sensors[i])
        local sens = system.getSource(sensors[i])   
 
        if pcall(function () sens:reset() end) then
        --if pcall(function () sens:value(0) end) then
        else 
            print("error reset",sensors[i])
        end
    end
    -- rstTmr(1)                -- activate these lines in case you want to reset timer X too
end



-- 5  resetTele()           -- resets "Altitude","Dist", "Consumption", optional: (flight & throttle) timer
function resetTele(dummy,soundfiles,calls)  
    local sensors = {"Altitude","Dist", "Consumption"}  
    if soundfiles then 
        if pcall(function() playWav(calls["reset_tel"]) end) then end
    end
    
    for i=1,#sensors do
        local sens = system.getSource(sensors[i])   
        if pcall(function () sens:reset() end) then
        else 
            print("error reset",sensors[i])
        end
    end
    -- rstTmr(1)                -- activate these lines in case you want to reset timer X too
    -- rstTmr(2)
end



-- 6  toggle(switch)            -- toggles "on/off" state of a LSW, control of two LSW's supported
function toggle(switch,glob)                                    -- toggle value between -1024 / 1024
    glob.switch[switch] = not glob.switch[switch]       -- toggle
    
    local n=2
    local tmp = 0
    for i=1,2 do
        if glob.switch[i] then
            tmp = tmp +2^(i-1)                                              -- built "binary" sw state
        end
    end
    return tmp
end

