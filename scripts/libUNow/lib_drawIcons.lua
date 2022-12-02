-- **************************************************************************************
-- *******************          draw specific icons            **************************
-- **************************************************************************************

--- The lua library "lib_drawIcons.lua" is licensed under the 3-clause BSD license (aka "new BSD")
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


-- Rev 0.8, Oct 2022

function drawBat_H(x,y,width,height,thick,frameX,batmin,batmax,data)					-- display telemetry values; sizing in standard 2x4 arrangement (2 cols / 4 rows)
	local col_frame		= lcd.RGB(255, 255, 255)
	local col_warn 		= lcd.RGB(240, 10, 10)
	local col_prewarn 	= lcd.RGB(255, 160, 0)
	local col_OKOK		= lcd.RGB(50, 255, 50)
	local col_OK		= lcd.RGB(0, 100, 0)

	lcd.color(col_frame)
	
	local leng=0.9*width
	local pole=0.5
	
	local deltax = 100 * thick/frameX.w
	local deltay = 100 * thick/frameX.h

	local cap = (data-batmin)/(batmax-batmin)*(0.92*leng)	-- cap in %
	frame.drawRectangle2(x,y,leng,height, frameX, thick)
	frame.drawFilledRectangle(x+leng,y+pole*height/2,width-leng,pole*height, frameX)		-- batpole
	lcd.color(col_warn)	
	frame.drawFilledRectangle(x+deltax,y+deltay,cap,height-2*deltay, frameX)

end



function drawBat_V(x,y,width,height,thick,frameX,batmin,batmax,data)					-- display telemetry values; sizing in standard 2x4 arrangement (2 cols / 4 rows)
	if batOK_bmp== nil then 
		batOK_bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Batt1.png")
		batWarn_bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Batt3.png")
		batAlarm_bmp = lcd.loadBitmap("/scripts/libUNow/bmp/Batt3.png")
	end
	local percent = (data-batmin)/(batmax-batmin)*100										-- "capacity" in percent

	--print("draw BatV",x,y,percent)
	if percent <15 then
		frame.drawBitmap(x,y,batAlarm_bmp,10,95, frameX)
	elseif percent < 30 then
		frame.drawBitmap(x,y,batWarn_bmp,10,95, frameX)
	else
		frame.drawBitmap(x,y,batOK_bmp,10,95, frameX)
	end
end


function drawBat_V2(x,y,width,height,thick,frameX,batmin,batmax,data)					-- display telemetry values; sizing in standard 2x4 arrangement (2 cols / 4 rows)
	local col_frame		= lcd.RGB(255, 255, 255)
	local col_warn 		= lcd.RGB(240, 10, 10)
	local col_prewarn 	= lcd.RGB(255, 160, 0)
	local col_OKOK		= lcd.RGB(50, 255, 50)
	local col_OK		= lcd.RGB(0, 100, 0)

	lcd.color(col_frame)
	
	local hght=0.9*height
	local pole=0.5
	
	local deltax = 100 * thick/frameX.w		-- undercut "thickness" (%)
	local deltay = 100 * thick/frameX.h

	local cap = (data-batmin)/(batmax-batmin)*(0.92*hght)	-- cap in %
	frame.drawRectangle2(x,y+(height-hght),width,hght, frameX, thick)
	frame.drawFilledRectangle(x+pole*width/2,y,pole*width,height-hght, frameX)		-- batpole
	
	lcd.color(col_warn)	
	frame.drawFilledRectangle(x+deltax,y+ height-cap-deltay,width - 2*deltax,cap, frameX)
	

end
