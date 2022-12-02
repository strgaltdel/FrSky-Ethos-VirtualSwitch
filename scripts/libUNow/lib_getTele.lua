--- The lua library "lib_getTele.lua" is licensed under the 3-clause BSD license (aka "new BSD")
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


-- Rev 0.3, not functional yet

function defineSensorLine(sensorX)
			local tele={}
			local bmpTmp 
			
			if not(sensorX.bmppath == nil) then 
				bmpTmp = lcd.loadBitmap(sensorX.bmppath) 
			else 
				bmpTmp =nil 
			end
		
			tele = {name = sensorX.name, 	bmp = bmpTmp,	val=sensorX.testVal , options = sensorX.options	}			
			return(tele)
end


function defineSensors(widget)
	
	local sensors = {
	-- 	label, 				name , 			bitmap path,												Option Params,	  Fieldlenght, decimals, alignV,  	alignB,		except.handle,	testvalue		
		-- Tx
		["TxBt"] 	= 	{name = "TxBt", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Batt3.png"),		options = nil,		f_lenght=5,	dec=1,	alignV=-17,	alignB=5,	xh=false,	testVal = 10.85 },		
		-- Rx
		["rssi"] 	= 	{name = "RSSI", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Ant_warn.png"),		options = nil,		f_lenght=5,	dec=0,	alignV=-17,	alignB=5,	xh=false,	testVal = 85 },
		["VFR"] 	= 	{name = "VFR", 		bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Ant_alarm.png"),		options = nil,		f_lenght=5,	dec=0,	alignV=-17,	alignB=10,	xh=false,	testVal = 98 },
		["RxBt"] 	= 	{name = "RxBt", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Ant_ok.png"),		options = nil,		f_lenght=5,	dec=1,	alignV=-17,	alignB=10,	xh=false,	testVal = 5.05 },		
		-- GPS
		["gpsLat"]	= 	{name = "GPS", 		bmp = lcd.loadBitmap("/scripts/libUNow/freepic/earth.png"),		options = LATITUDE,	f_lenght=5,	dec=6,	alignV=0,	alignB=0,	xh=true,	testVal = 50.430145 },
		["gpsLon"]	= 	{name = "GPS", 		bmp = lcd.loadBitmap("/scripts/libUNow/bmp/gps_1.png"),		options = LONGITUDE,f_lenght=5,	dec=6,	alignV=0,	alignB=0,	xh=true,	testVal = 9.935628 },
		["GAlt"]	= 	{name = "GAlt", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/alti.png"),	options =  nil,		f_lenght=5,	dec=0,	alignV=3,	alignB=0,	xh=false,	testVal = 2430 },
		["GSpd"]	= 	{name = "GSpd", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/spd2_1.png"),	options =  nil,		f_lenght=5,	dec=1,	alignV=0,	alignB=0,	xh=false,	testVal = 88.6 },
		["Dist"]	= 	{name = "Dist", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/dist_1.png"),	options =  nil,		f_lenght=5,	dec=0,	alignV=-12,	alignB=0,	xh=false,	testVal = 105 },
		["Hdg"]		= 	{name = "Hdg", 		bmp = lcd.loadBitmap("/scripts/libUNow/bmp/gps_1.png"),		options =  nil,		f_lenght=5,	dec=0,	alignV=-5,	alignB=0,	xh=false,	testVal = 242 },
		["nSat"]	= 	{name = "nSAT", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/rssi.png"),		options =  nil,		f_lenght=5,	dec=0,	alignV=-10,	alignB=0,	xh=false,	testVal = 112 },
		["HDOP"]	= 	{name = "HDOP", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/rssi.png"),		options =  nil,		f_lenght=5,	dec=0,	alignV=-10,	alignB=0,	xh=false,	testVal = 212 },

		-- ESC
		["BecA"]	= 	{name = "BecA", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/rxbat.png"),		options =  nil,		f_lenght=5,	dec=1,	alignV=-10,	alignB=5,	xh=false,	testVal = 0.45 },
		["BecV"]	= 	{name = "BecV", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/rxbat.png"),		options =  nil,		f_lenght=5,	dec=1,	alignV=-10,	alignB=5,	xh=false,	testVal = 5.67 },
		["EscA"]	= 	{name = "Curr", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/currB1.png"),	options =  nil,		f_lenght=5,	dec=1,	alignV=0,	alignB=0,	xh=false,	testVal = 40.3 },
		["EscV"]	= 	{name = "VFAS", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/voltage.png"),	options =  nil,		f_lenght=5,	dec=1,	alignV=-4,	alignB=0,	xh=false,	testVal = 16.1 },
		["Erpm"]	= 	{name = "Erpm", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Prop2b.png"),		options =  nil,		f_lenght=5,	dec=0,	alignV=1,	alignB=0,	xh=false,	testVal = 4280 },
		["Ccon"]	= 	{name = "Ccon", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Batt3.png"),		options =  nil,		f_lenght=5,	dec=0,	alignV=1,	alignB=0,	xh=false,	testVal = 1850 },
		["EscT"]	= 	{name = "TFet", 	bmp = lcd.loadBitmap("/scripts/libUNow/freepic/thermo2.png"),		options =  nil,		f_lenght=5,	dec=0,	alignV=-17,	alignB=0,	xh=false,	testVal = 50.3 },
		-- oTx
		["alti"] 	= 	{name = "ALT",		bmp = lcd.loadBitmap("/scripts/libUNow/bmp/alti.png"), 	options = nil,		f_lenght=5,	dec=0,	alignV=-12,	alignB=10,	xh=false,	testVal = 72.82 },
		["ASpd"]	= 	{name = "ASpd", 	bmp = lcd.loadBitmap("/scripts/libUNow/bmp/spd1_1.png"),	options =  nil,		f_lenght=5,	dec=1,	alignV=0,	xh=false,	testVal = 92.3}
		
	}
	
	--[[  example how to procure:
	local tmp = "alt"
	sensors.tmp = sensors[tmp]
	-- print("SENSOR:  ",sensors.tmp.name)
	]]

		

	return sensors
	
end

function getTeleValues()
	local TeleValues ={
	}
	
	-- void

end

function getTele(Telesensor)

	teleValue = system.getSource(TeleSensor)
	
	return teleValue

end
