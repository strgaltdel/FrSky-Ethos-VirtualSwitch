-- **************************************************************************************
-- *******************          Ethos file i/o            		**************************
-- **************************************************************************************

--- The lua library "lib_FileIO.lua" is licensed under the 3-clause BSD license (aka "new BSD")
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

function renFile(oldName,newName)
	if os.rename(oldName,newName) then
		return true
	else
		return false
	end

end


-- get 2-dim array and write each line into new file
function writeFile(filename,data)
	local numData = #data
	if numData >0 then
		file = io.open(filename , "w")
		local tmpData = data[1].."\r\n"
		if numData >1 then
			for i=2,numData do
				tmpData = tmpData..data[i].."\r\n"
			end
		io.write(file,tmpData)
		end
		io.close(file)
		return true
	else
		print("no data to write in File")
		return false
	end
end	



-- read complete file and return array
function ReadFile(filename)
	if pcall(function() file = io.open(filename , "r") end)then
		local data = {}
		local i = 1
		local line	
		repeat
			if pcall(function()line = io.read(file,"L") end)then
				data[i] = line
				i=i+1
			else
				print("ReadError",i)
				line = nil
			end
		until line == nil
		io.close(file)
		return data
	else
		print("open File error",filename)
	end

end