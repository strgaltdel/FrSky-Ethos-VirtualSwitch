
--- The lua script "Last GPS" is licensed under the 3-clause BSD license (aka "new BSD")
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

-- lua Source script which presents global "GPS" table with last known coordinates 
-- & save them on demand by using source variable


-- Rev 1.0 Nov 2022





local FPATH_COORD <const> = ("/scripts/SRC_Gps_UN/data/")
														--flag test run 

LastGps = {}
		LastGps.lat 			= 0												-- actual received Coord.
		LastGps.lon 			= 0												-- no lock on start
		LastGps.changed 		= false											-- new coordinates ?
		LastGps.mustPaint 	= false											-- QR must be painted
		LastGps.lastPaint	= os.clock()										-- QR was last painted at....
		LastGps.OldLat 		= 0												-- needed to detect changes
		LastGps.OldLon 		= 0
		LastGps.stored 		= false											-- "actual" coord. stored
		LastGps.fileLon		= 0												-- coord. from file
		LastGps.fileLat		= 0
		LastGps.fileTme		= 0
		LastGps.fileWasRead	= false
		
		LastGps.lock		= false
		LastGps.testmode	= false


local translations = {en="Last GPS V1.0"}

local function name(widget)
	local locale = system.getLocale()
	return translations[locale] or translations["en"]
end


local function saveGPStoFile()
	print("------------   Save Coordinates   ------------")

	local data = {}

	data[1]=LastGps.lat
	data[2]=LastGps.lon

	local fName = model.name()	
	local fileOld02	= FPATH_COORD .. fName .. ".02.txt"
	local fileOld01 	= FPATH_COORD .. fName .. ".01.txt"
	local filename	= FPATH_COORD .. fName .. ".txt"
	
	os.remove(fileOld02)
	renFile(fileOld01,fileOld02)
	renFile(filename, fileOld01)
	
	writeFile(filename,data)
	LastGps.changed		= false
	LastGps.mustPaint = false
	LastGps.stored 		= true
end


local function readGPSfromFile()
	local data = {}
	local fName = model.name()	
	filename = FPATH_COORD.. fName..".txt"

	data = ReadFile(filename)			
	LastGps.lat = tonumber(data[1])
	LastGps.lon = tonumber(data[2])
	LastGps.OldLat = LastGps.lat
	LastGps.OldLon = LastGps.lon 
	LastGps.fileLat = LastGps.lat
	LastGps.fileLon = LastGps.lon
	LastGps.fileWasRead = true
	LastGps.fileTme = os.clock()+0.4					-- add some time to give pauint handler chance to update before calc starts
	LastGps.changed		= false
	LastGps.mustPaint = true
	LastGps.stored 		= true
	print("file read ",LastGps.lat,  LastGps.lon)
end


local function sourceInit(source)
	source:value(0)													-- 0=idle  1= save coordinates into flat file
	if LastGps.testmode then
		LastGps.lat = 50.50
		LastGps.lon = 9.950950	
	else
		LastGps.lat = 0
		LastGps.lon = 0
	end
end


local function sourceWakeup(source)
	local lat= system.getSource({name="GPS", options=OPTION_LATITUDE})
	local lon= system.getSource({name="GPS", options=OPTION_LONGITUDE})
	
	if LastGps.testmode or pcall(function() if lat:value() == nil then end end)then			-- wether testMode or detect sensor was "OK"

		LastGps.lock	= true
	
		if LastGps.lat == nil then													-- ensure numbers (sensor exists, but no lock)
			LastGps.lat = 0
			LastGps.lon = 0
			LastGps.lock			= false
		end
				
		LastGps.OldLat = LastGps.lat
		LastGps.OldLon = LastGps.lon 
		
		-- testmode start 
		if LastGps.testmode then 												
			LastGps.lat = LastGps.lat + 0.00004
			LastGps.lon = LastGps.lon + 0.00001
			
			if LastGps.lat > 50.501 then
					LastGps.lat = 50.50
					LastGps.lon = 9.950950
			end
		else																	-- testmode end
			local tmpLat = lat:value()
			if tmpLat ~= nil and tmpLat ~= 0 then
				LastGps.lat = lat:value()
				LastGps.lon = lon:value()
			elseif LastGps.fileLat ~= nil and LastGps.fileLat ~= 0 then			-- no sensor but file coord
				LastGps.lat = LastGps.fileLat
				LastGps.lon = LastGps.fileLon
				LastGps.mustPaint 	= false
				LastGps.lock		= false					
			else																-- we have nothing !
				LastGps.lat = 0
				LastGps.lon = 0	
				LastGps.mustPaint 	= false
				LastGps.lock		= false				
			end
		end
		
		
		if LastGps.lat == LastGps.OldLat and LastGps.lon == LastGps.OldLon then		-- static
			LastGps.changed = false
		else
			LastGps.changed 		= true
			LastGps.stored 		= false
			LastGps.mustPaint 	= true

		end
	end
  
	if  source:value() == 1 then													-- save coordinates request
		saveGPStoFile()
		source:value(0)
	end	
	
	if  source:value() == 2 then													-- read coordinates from file request
		readGPSfromFile()
		source:value(0)
	end

end

local function init()
  system.registerSource({key="srcGPS", name=name, init=sourceInit, wakeup=sourceWakeup})
end

return {init=init}