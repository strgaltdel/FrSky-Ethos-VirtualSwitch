-- "Master" theme templates for widgets running under Ethos 
-- (1) define themes 
-- (2) return the one which was choosen
--  udo nowakowski, 2022

-- Rev 1.0





function initTheme(choice)

	theme ={}
	local themeTemplate={}
	
	themeTemplate[1]= {								-- dark
	-- colors
		c_backgrAll 	= lcd.RGB(50,  50,   50),
		--c_backgrAll 	= lcd.RGB(  0,   0,   0),
		c_frontAll	 	= lcd.RGB( 255, 255, 255),

		
	-- Text	
		c_textStd		= lcd.RGB(255, 255, 255),
		c_textInvert	= lcd.RGB(0,   0,   0),
		c_textgrey1		= lcd.RGB(130, 130, 130),
		c_textdark		= lcd.RGB(190, 190, 190),
		c_textRed		= lcd.RGB(255,  30,  30),
		c_textGreen		= lcd.RGB(  0, 160,   0),
		
		c_textAlarm		= lcd.RGB(255,  30,  30),
		
	-- Buttons	
		c_ButRed		= lcd.RGB(230,   0,   0),
		c_ButBluestd	= lcd.RGB( 50,  50, 200),
		c_ButBlueBright	= lcd.RGB(100, 100, 200),
		c_ButGreen		= lcd.RGB(  0, 180,   0),		
		c_ButGrey		= lcd.RGB(180, 180, 180),
		}	
	
	
	themeTemplate[2] = {									-- bright
	-- colors
		c_backgrAll 	= lcd.RGB(255, 255, 255),
		--c_backgrAll 	= lcd.RGB(  0,   0,   0),
		c_frontAll	 	= lcd.RGB(  0,   0,   0),

		
	-- Text	
		c_textStd		= lcd.RGB( 0,   0,   0),
		c_textInvert	= lcd.RGB(255, 255, 255),
		c_textgrey1		= lcd.RGB(130, 130, 130),
		c_textdark		= lcd.RGB(100, 100, 100),
		c_textRed		= lcd.RGB(255,  30,  30),
		c_textGreen		= lcd.RGB(  0, 160,   0),
		
		c_textAlarm		= lcd.RGB(255,  30,  30),
		
	-- Buttons	
		c_ButRed		= lcd.RGB(230,    0,      0),
		c_ButBluestd	= lcd.RGB(  50,   50, 200),
		c_ButBlueBright	= lcd.RGB(100, 100, 200),
		c_ButGreen		= lcd.RGB(     0, 180,   0),		
		c_ButGrey		= lcd.RGB(180, 180, 180),
		}
	

	return (themeTemplate[choice])


end