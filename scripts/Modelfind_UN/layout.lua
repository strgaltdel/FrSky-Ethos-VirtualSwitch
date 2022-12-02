-- all numbers are "percent of widget x/y size"

function defineLayout(display)


	local layoutSettings = {}
	
	layoutSettings [1]= {
																			-- X20
		["type"] 		=	"X20",															

	-- offsets
		["yOffset"]	= 	0.36,						-- y placement QR
	-- placements
		--lines
		["line1"] 		= 	02,					-- x-coordinates for TopBar sub-widgets (percent of displ width)
		["line2"] 		= 	9,
		["lastline"] 	= 	94,
		-- tabs
		["tab0"] 		= 	03,
		["tab1"] 		= 	36,
		["tab2"] 		= 	52,
		["tab3"] 		= 	77,		
		["right2"] 		= 	99,
		-- button specific
		["butLine1"] 	= 	19,	
		["butHeight"] 	= 	15,	
		
	}
	
	layoutSettings [2]= {													-- X18
		["type"] 		=	"X18",	
	-- offsets
		["yOffset"]	= 	0.36,						-- y placement QR
	-- placements
		--lines	
		["line1"] 		= 	02,					-- x-coordinates for TopBar sub-widgets (percent of displ width)
		["line2"] 		= 	9,
		["lastline"] 	= 	95,
		-- tabs		
		["tab0"] 		= 	03,
		["tab1"] 		= 	36,
		["tab2"] 		= 	52,
		["tab3"] 		= 	77,		
		["right2"] 		= 	99,
		-- button specific
		["butLine1"] 	= 	18,	
		["butHeight"] 	= 	14,	
		
	}
	
	layoutSettings [3]= {														-- Horus	
		["type"] 		=	"HORUS",	
	-- offsets
		["yOffset"]	= 	0.36,						-- y placement QR
	-- placements
		--lines	
		["line1"] 		= 	00,					-- x-coordinates for TopBar sub-widgets (percent of displ width)
		["line2"] 		= 	9,
		["lastline"] 	= 	92,
		-- tabs
		["tab0"] 		= 	03,		
		["tab1"] 		= 	40,
		["tab2"] 		= 	52,
		["tab3"] 		= 	77,		
		["right2"] 		= 	99,
		-- button specific
		["butLine1"] 	= 	18,	
		["butHeight"] 	= 	14,	

	}	
		--print("LAYOUT:",display)
	return(layoutSettings [display])

end
