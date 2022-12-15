--- The lua script "virtual Switch" aka virtSW is licensed under the 3-clause BSD license (aka "new BSD")
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

-- Rev 1.0      initial relase dec 2022

local translations = {en="virtSwitch", de="virtSwitch"}

-- constants:

local debugSW <const>               = false             -- print debug info
local debugSW2 <const>              = true  
local debugTele <const>             = false
local debugAtti <const>             = true              -- print tx attitude 


-- *****************************************
-- user personalized config / customizing
-- *****************************************

local BEEP_leaveNeutral <const>     = true              -- send beep in case tx atti exceeds neutral 
local BEEP_back2Neutral <const>     = false             -- send beep in case tx atti regains neutral 

-- timing
local press_short <const>           = 0.3               -- release within x seconds     >> short press detectd
local press_long <const>            = 0.8               -- release needs more then x sec    >> long press detected

-- attitude 
local X_deadzone <const>            = 600               -- deadzone roll-axis (-1024 ~ vertical if gyro is calibrated)
local Y_fwd_active <const>          = 300               -- deadzone "pitch"-axis
local Y_back_active <const>         = -2000             -- deadzone limit pitch-axis (pull back), val > 1024 = no activation

local delayStandard  <const>        = 0.7               -- standard delay time after "gyro event" is triggered; >> supress false flags; not used yet

local switch_1 <const>              = "SA"              -- tx buttons
local switch_2 <const>              = "SH"



-- **********************
-- don't change:
-- **********************
-- some "handler" / indizes

-- indexes for parametric function calls in global environment
local FUNC  <const>             = 1                     -- index function call (config.lua)
local ARGMNT  <const>           = 2                     -- index argument (config.lua)

-- attitudes
local modeIdle <const>          = 0                     -- idle
local atti_std <const>          = 1                     -- tx attitude              --                                              
local atti_lft <const>          = 2
local atti_rgt <const>          = 3
local atti_fwd <const>          = 4
local atti_bck <const>          = 5

-- ButtonHandler
local But_Idle <const>          = 0                     -- Button event
local Left_Std <const>          = 1
local Left_Mid <const>          = 2
local Left_Long <const>         = 3

local Right_Std <const>         = 4 
local Right_Mid <const>         = 5
local Right_Long <const>        = 6

local But_pressed <const>       = 10

local NumberXportSW <const>     = 2                     -- number of LSW to controlled via src value                                                                                                   

local buttonHandler

local onFirstRun                = true                  -- flag very first run

local action = {}                                       -- array which contains button config

-- global vars      
local glob = {}
    glob.GoSw1          = false         -- switch was pressed
    glob.GoSw2          = false
    
    glob.X_left         = false         -- actual attitude
    glob.X_right        = false
    glob.Y_back         = false
    glob.Y_fwd          = false
    glob.Neutral        = false
    
    
    glob.lastX_left     = false         -- remember last gyro attitude
    glob.lastX_right    = false
    glob.lastY_fwd      = false
    glob.lastY_back     = false
    glob.last_neutral   = false 
    
    glob.GoBack         = false         -- used to eval. function call
    glob.GoFwd          = false
    glob.GoLeft         = false
    glob.GoRight        = false
    glob.GoNeutral      = false
    
    glob.Go             = false         -- flag switche event was triggered
    glob.lock           = false         -- "lock" first detected attitude change

    glob.mode           = modeIdle
    glob.delay          = delayStandard
    
    glob.switchPressed      = false
    glob.breakOperations    = false
    glob.starttime_init     = 0
    glob.executed           = true  

    glob.NowWithinNeutral   = true  
    glob.OutOfNeutral       = false
    glob.switch             ={false,false}

    


local function name(widget)
  local locale = system.getLocale()
  return translations[locale] or translations["en"]
end




-- ******************************************
-- **   include virtual switch functions   **
-- ******************************************
dofile("SwFuncs.lua")
dofile("config.lua")
local sim,soundfiles,calls = config_virtsw()        -- customization


local function defActions(model)
-- ******************************************
-- **           include config file        **
-- ******************************************
    local actionArray = {}
    actionArray=define_actions(model)   
    return actionArray
end





-- *********************************
-- **   os related  "translation" **
-- **         aka     HAL         **
-- *********************************

-- the basic ones:


local function playSignal(freq,duration,option)
    system.playTone(freq,duration)
end


function playNumber(val,unit,dec)                                   -- play simple value / number
    if pcall(function()system.playNumber(val,unit,dec) end) then 
        
    else
        print("no value TO PLAY")
    end
end


function playWav(soundfile)                                 -- play soundfile
    system.playFile(soundfile)
end


function TeleVal(Telesensor)                                        -- get telemetry value
    local teleSrc = system.getSource({category=CATEGORY_TELEMETRY, name=Telesensor})
    local val
    if pcall(function() val = teleSrc:value() end) then     
        if debugTele then print("televal got",Telesensor,val) end
        return(val)
    else
        print("got no value:",Telesensor)
    end
end


function getVal(src)                                                -- get channel/Input value
    local source =  system.getSource({name=src})
    local val
    if pcall(function() val=source:value() end) then    
        return(val)
    else
        print("got no value:",Telesensor)
    end
end

function getTime()
  return os.clock()      
end

    
-- ***********************************************************************************************************
-- and now the "basic" functions:

---------------
--  check if switches were pressed
---------------
local function check_switches(glob)
    if getVal(switch_1) > 100 then                                      -- switch1 pressed detection
            glob.GoSw1 = true                                                   -- flag switch
            glob.starttime_init = getTime()                                     -- get start time
            glob.switchPressed = true                                       -- declare switch mode under Gyro event
            print("switch left initiated   ",glob.starttime_init)
    end
     if getVal(switch_2) > 100 then                                     -- switch2 pressed detection
            glob.GoSw2 = true
            glob.starttime_init = getTime()
            glob.switchPressed = true                                       -- declare switch mode under Gyro event
            print("switch right initiated   ")
    end
    if glob.GoSw1 or glob.GoSw2 then
        return true
    else
        return false
    end
end 



---------------
--  determine actual alignment
---------------
local function check_alignment(glob,gyro_x,gyro_y)
    glob.Neutral    =   math.abs(gyro_x) <  X_deadzone and  gyro_y <  Y_fwd_active 
    glob.X_left     =   gyro_x <  -X_deadzone                                   -- check transmitter gyro-alignment
    glob.X_right    =   gyro_x >   X_deadzone 
    glob.Y_back     =   gyro_y <  Y_back_active
    glob.Y_fwd      =   gyro_y >  Y_fwd_active 
    return true
end



---------------
--  determine x or y gyro event
---------------
local function check_gyro(glob) 
        
    if glob.Neutral and (not glob.last_neutral) then                                    -- changed back to neutral      glob.GoNeutral = true
        glob.lock = false                                                               -- release "atti lock"
        glob.mode = atti_std                                                            -- set mode to neutral
        if BEEP_back2Neutral then playSignal(7000,20) end
        if debugAtti then print("determined: Neutral") end
        
    elseif not(glob.Neutral) and not(glob.lock) then                                    -- tx has new attitude      
            glob.lock = true                                                                        -- so flag "lock" 
            if (glob.X_left and (not glob.lastX_left)) then                                         -- check left
                glob.GoLeft = true  
                glob.mode = atti_lft
                if debugAtti then print("determined: left") end
                if BEEP_leaveNeutral then playSignal(1000,50,10) end
                glob.OutOfNeutral = true
            elseif (glob.X_right and (not glob.lastX_right)) then                                   -- check right
                glob.GoRight = true
                glob.mode = atti_rgt
                if debugAtti then print("determined: right") end
                if BEEP_leaveNeutral then playSignal(2000,50,10) end
                glob.OutOfNeutral = true
            elseif glob.Y_fwd and (not glob.lastY_fwd) then                                         -- check forward
                glob.GoFwd = true   
                glob.mode = atti_fwd
                if debugAtti then print("determined: fwd") end
                if BEEP_leaveNeutral then playSignal(4000,50,10) end
                glob.OutOfNeutral = true
            elseif glob.Y_back and (not glob.lastY_back) then                                       -- check backward   
                glob.GoBack = true
                glob.mode = atti_bck
                if debugAtti then print("determined: back") end
                glob.OutOfNeutral = true
            end
    end                     
        
    return true                         
end 

---------------
--  determine switch events (short/mid/long press left/right button)
---------------
local function  eval_SwitchEvents(glob)
    if (glob.GoSw1 or glob.GoSw2) and getVal(switch_1) < 100 and getVal(switch_2) < 100 then        -- switch released, so do some analysis
        glob.switchDuration = getTime()-glob.starttime_init
        glob.breakOperations    = true                                                              -- flag "Go reset"
        
        if glob.switchDuration < press_short then                                                   -- duration:    SHORT
            if glob.GoSw1 then                                      
                if debugSW then print("swEvent: 1 short",glob.mode)end
                return Left_Std                     
            else                                                            
                if debugSW then print("swEvent: 2 short",glob.mode)end
                return Right_Std                                    
            end     
            
        elseif glob.switchDuration > press_short and glob.switchDuration < press_long   then        -- duration:    MID
            if glob.GoSw1 then
                if debugSW then print("swEvent: 1 mid",glob.mode)end
                return Left_Mid
            else
                if debugSW then print("swEvent: 2 mid",glob.mode)end
                return Right_Mid
            end 
            
        else                                                                                        -- duration:    LONG
            if glob.GoSw1 then
                if debugSW then print("swEvent: 1 long",glob.mode)end
                return Left_Long
            else
                if debugSW then print("swEvent: 2 long",glob.mode)end
                return Right_Long 
            end 
        end
        
    end
    return But_Idle

end





---------------
--  reset global vars when handling was finished
---------------
local function reset_values()
    --glob.mode     = modeIdle  
    glob.delay              = delayStandard
    glob.button             = 0
    glob.button1            = false
    glob.button2            = false
    glob.executed           = false
    glob.Go                 = false
        
    glob.GoBack             = false
    glob.GoFwd              = false
    glob.GoLeft             = false
    glob.GoRight            = false
    glob.GoSw1              = false
    glob.GoSw2              = false
    
    glob.Go                 = true

    --glob.mode             = modeIdle  
    glob.switchPressed      = false
    glob.breakOperations    = false
    glob.starttime_init     = 0
    glob.OutOfNeutral       = false
    
    glob.lastX_left         = false                                         -- remember last gyro position
    glob.lastX_right        = false
    glob.lastY_fwd          = false
    glob.lastY_back         = false
    glob.last_neutral       =false

end



---------------
--  init source variable, used to control two LSW's
---------------
local function sourceInit(source)
    source:value(0)
    source:decimals(0)
 end

 


---------------
--  main handler
---------------
local function sourceWakeup(source)

    local noButton      = 0                                                                         -- some status defs
    local ButtonLeft    = 1
    local ButtonRight   = 2
    local BothButtons   = 3
    
    local gyro_x  = 0
    local gyro_y    =0 
    
    local switchEvent = But_Idle
    
    local delayAfterExec   = 0.3                                                                    -- pause some time after execution 
    

    action = defActions()                                                                           -- get array with all function calls dependent on tx attitude and button-press duration

    if sim then                                                                                     -- get sim sources
 
        gyro_x  = system.getSource({category= CATEGORY_SWITCH,name="SA" }):value()              
        gyro_y  = system.getSource({category= CATEGORY_SWITCH,name="SB" }):value()  
    else

        gyro_x  = system.getSource({category= 17,member = 0}):value()                               -- get gyro values
        gyro_y  = system.getSource({category= 17,member = 1}):value()
        --print("gyr",gyro_x)
        if gyro_x == nil then               -- no gyro
            gyro_x = 0
            gyro_y = 0
        end
    end


    if system.getSource({category= CATEGORY_SWITCH,name="SC" }):value() > 100 and debugAtti then        
        print("gyro",gyro_x, gyro_y)
    end


    
      ---------------
    --  start here
    --  we've to evaluate attitude before eval Button situation
    ---------------
    glob.NowWithinNeutral  = check_alignment(glob,gyro_x,gyro_y)            -- check actual alignment, return true in case within "Neutral zone" ? (and set xleft/xright,yfwd,yback stati)  
                                                                            -- return value used to detect user abort later on
    check_gyro(glob)                                                        -- check if actual alignment = last one

    if not(glob.switchPressed) then                                         -- last time no switch active, so check now
        glob.switchPressed= check_switches(glob)                            -- check_switches(glob):        check switch stati; sets GoSwX >> true, glob.switchPressed >>true; returns true if one is pressed
    end
    --          

    if  glob.switchPressed  then                                            -- if switch event was triggered: check if released and eval details
                    
        switchEvent = eval_SwitchEvents(glob)                                       -- eval kind of switch event in case button was released
        if switchEvent ~=  But_Idle then                                                
    
            local   funCtion    = action[glob.mode][switchEvent][FUNC]
            local   arGument    = action[glob.mode][switchEvent][ARGMNT]    
            if debugSW2 then
                print("event detected  (atti,switch)",glob.mode ,switchEvent,FUNC,ARGMNT)
                print("triggered:",funCtion,arGument)
            end 
                
                                                                                    -- !! exception handling for "special" functions  !! 
            if funCtion == "playTele" then                                          -- >> play telemetry value
                playTele(arGument,soundfiles,calls)
            elseif funCtion == "toggle" then                                        -- >> toggle "LSW bit"
                source:value(toggle(arGument,glob))
                if debugSW2 then print("src value",source:value()) end
            else
                -- print("state sound main",soundfiles)
                _G[funCtion](arGument,soundfiles,calls)                                             -- no exception: perform standard operations
                glob.switchPressed = false          --                              -- flag event handling is finished
            end
    
        end
    end
    




    ---------------
    --  eval if user requests a reset
    ---------------     
    --glob.NowWithinNeutral  = check_alignment(glob,gyro_x,gyro_y)                              -- load actual tx alignment
    if glob.NowWithinNeutral and glob.OutOfNeutral and not glob.executed then           -- user declared "reset" due to unintentionally movement 
        glob.breakOperations = true                                                     -- it's done by "holding" button, go back to neutral attitude & release button
        glob.executed = true                                                            -- so nothing will happen
        playSignal(300,50,20)
        if debugAtti then print("user requested neutralization") end
    end
    
    
    ---------------
    --  reset status when handling has finished due to intended action or timeout (exclude "deadzone switch handling")
    --------------- 
    if glob.breakOperations then
        reset_values()  
    end 

    
    
      -- +++++++++++   remember last tx alignment     ++++++++++++++
    glob.lastX_left     = glob.X_left
    glob.lastX_right    = glob.X_right
    glob.lastY_fwd      = glob.Y_fwd
    glob.lastY_back     = glob.Y_back
    glob.last_neutral   = glob.Neutral


end

local function init()
  system.registerSource({key="virtSW1", name=name, init=sourceInit, wakeup=sourceWakeup})
end

return {init=init}