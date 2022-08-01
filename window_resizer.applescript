use framework "AppKit"

on getScreensOrigins()
	set output to {}
	repeat with curScreen in current application's NSScreen's screens()
		set theFrame to curScreen's frame()
		set _size to item 1 of theFrame
		copy _size to the end of the output
	end repeat
	return output
end getScreensOrigins

on getScreensSizes()
	set output to {}
	repeat with curScreen in current application's NSScreen's screens()
		set theFrame to curScreen's frame()
		set _size to item 2 of theFrame
		copy _size to the end of the output
	end repeat
	return output
end getScreensSizes

on getActiveWindowSizes()
	tell application "System Events"
		set activeApp to name of first application process whose frontmost is true
		tell process activeApp
			if (name of window 1) = "Picture in Picture" then
				set activeWindow to window 2
			else
				set activeWindow to window 1
			end if
			set positionOfCurrentApp to position of activeWindow
			set sizeOfCurrentApp to size of activeWindow
		end tell
	end tell
	return {item 1 of positionOfCurrentApp, item 2 of positionOfCurrentApp, item 1 of sizeOfCurrentApp, item 2 of sizeOfCurrentApp}
end getActiveWindowSizes

on getActiveSceenIndex()
	set screensSizes to getScreensSizes()
	set screensOrigins to getScreensOrigins()
	tell application "System Events"
		set activeApp to name of first application process whose frontmost is true
		set displayName to display name of desktop 1
		tell process activeApp
			if (name of window 1) = "Picture in Picture" then
				set activeWindow to window 2
			else
				set activeWindow to window 1
			end if
			set positionOfCurrentApp to position of activeWindow
			set positionXOfCurrentApp to (item 1 of positionOfCurrentApp)
			set positionYOfCurrentApp to (item 2 of positionOfCurrentApp)
			set ScreenX to item 1 of item 1 of screensSizes
			set ScreenY to item 2 of item 1 of screensSizes
			if (positionYOfCurrentApp ² ScreenY and positionYOfCurrentApp ³ 0) and (positionXOfCurrentApp ² ScreenX and positionXOfCurrentApp ³ 0) then
				set activeScreenIndex to 1
			else
				set activeScreenIndex to 2
			end if
		end tell
	end tell
	return activeScreenIndex
end getActiveSceenIndex

on getScreenSize()
	set screensSizes to getScreensSizes()
	set activeSceenIndex to getActiveSceenIndex()
	set _width to item 1 of item activeSceenIndex of screensSizes
	set _height to item 2 of item activeSceenIndex of screensSizes
	return {_width, _height}
end getScreenSize

on getScreenOrigin()
	set screensSizes to getScreensSizes()
	set screensOrigins to getScreensOrigins()
	set activeSceenIndex to getActiveSceenIndex()
	set activeSceenHeight to item 2 of item activeSceenIndex of screensSizes
	set mainSceenHeight to item 2 of item 1 of screensSizes
	set screensHeightDiff to mainSceenHeight - activeSceenHeight
	set _x to item 1 of item activeSceenIndex of screensOrigins
	set _y to (item 2 of item activeSceenIndex of screensOrigins) - screensHeightDiff
	return {_x, _y}
end getScreenOrigin

on converttoList(delimiter, input)
	local delimiter, input, ASTID
	set ASTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set input to text items of input
	set AppleScript's text item delimiters to ASTID
	return input
end converttoList

on resizeApp(positionX, positionY, sizeX, sizeY)
	tell application "System Events"
		set activeApp to name of first application process whose frontmost is true
		tell process activeApp
		if (name of window 1) = "Picture in Picture" then
				set activeWindow to window 2
			else
				set activeWindow to window 1
			end if
			set position of activeWindow to {positionX, positionY}
			set size of activeWindow to {sizeX, sizeY}
		end tell
	end tell
end resizeApp


on run(argv)
	set query to item 1 of argv
	set screenSize to getScreenSize()
	set screenOrigin to getScreenOrigin()
	
	set screenOriginX to (item 1 of screenOrigin)
	set screenOriginY to (item 2 of screenOrigin)
	set screenSizeX to item 1 of screenSize
	set screenSizeY to item 2 of screenSize
	
	if (query = "full") then
		set positionX to screenOriginX
		set positionY to 0 - screenOriginY
		set sizeX to screenSizeX
		
		if (screenSizeY = 1200) then
			set sizeY to (93 / 100) * screenSizeY
		else
			set sizeY to (item 2 of screenSize)
		end if
	else if ({"left", "right", "up", "down", "leftalt", "rightalt"} contains query) then
		set windowPositionSize to getActiveWindowSizes()
		
		set windowLeft to (item 1 of windowPositionSize) - screenOriginX
		set windowTop to (item 2 of windowPositionSize) + screenOriginY
		set windowRight to (item 1 of screenSize) - (item 3 of windowPositionSize) - (item 1 of windowPositionSize) + screenOriginX
		set windowBottom to (item 2 of screenSize) - (item 4 of windowPositionSize) - (item 2 of windowPositionSize) - screenOriginY
		set windowSizeX to item 3 of windowPositionSize
		set windowSizeY to item 4 of windowPositionSize
		
		if (query = "leftalt") then
			set positionX to item 1 of windowPositionSize
			if windowRight < screenSizeX * 0.33 - 5 then
				set sizeX to screenSizeX * (1 - 0.33) - windowLeft
			else if windowRight < screenSizeX * 0.5 - 5 then
				set sizeX to screenSizeX * (1 - 0.5) - windowLeft
			else if windowRight < screenSizeX * 0.67 - 5 then
				set sizeX to screenSizeX * (1 - 0.67) - windowLeft
			else
				return "no space to change"
			end if
			
			set positionY to item 2 of windowPositionSize
			set sizeY to item 4 of windowPositionSize
		else if (query = "rightalt") then
			if windowLeft < screenSizeX * 0.33 - 5 then
				set positionX to screenSizeX * 0.33 + screenOriginX
			else if windowLeft < screenSizeX * 0.5 - 5 then
				set positionX to screenSizeX * 0.5 + screenOriginX
			else if windowLeft < screenSizeX * 0.67 - 5 then
				set positionX to screenSizeX * 0.67 + screenOriginX
			else
				return "no space to change"
			end if
			set sizeX to screenOriginX + screenSizeX - positionX - windowRight
			set positionY to item 2 of windowPositionSize
			set sizeY to item 4 of windowPositionSize
			
		else if (query = "left") then
			if windowLeft < 5 then
				set positionX to screenOriginX
				if windowRight < screenSizeX * 0.33 - 5 then
					set sizeX to screenSizeX * (1 - 0.33)
				else if windowRight < screenSizeX * 0.5 - 5 then
					set sizeX to screenSizeX * (1 - 0.5)
				else if windowRight < screenSizeX * 0.67 - 5 then
					set sizeX to screenSizeX * (1 - 0.67)
				else
					return "no space to change"
				end if
			else
				if windowLeft < screenSizeX * 0.33 + 5 then
					set positionX to screenOriginX
				else if windowLeft < screenSizeX * 0.5 + 5 then
					set positionX to screenSizeX * 0.33 + screenOriginX
				else if windowLeft < screenSizeX * 0.67 + 5 then
					set positionX to screenSizeX * 0.5 + screenOriginX
				else
					set positionX to screenSizeX * 0.67 + screenOriginX
				end if
				set sizeX to screenSizeX - windowRight
			end if
			set positionY to item 2 of windowPositionSize
			set sizeY to item 4 of windowPositionSize
			
		else if (query = "right") then
			if windowRight < 5 then
				if windowLeft < screenSizeX * 0.33 - 5 then
					set positionX to screenSizeX * 0.33 + screenOriginX
				else if windowLeft < screenSizeX * 0.5 - 5 then
					set positionX to screenSizeX * 0.5 + screenOriginX
				else if windowLeft < screenSizeX * 0.67 - 5 then
					set positionX to screenSizeX * 0.67 + screenOriginX
				else
					return "no space to change"
				end if
				set sizeX to screenOriginX + screenSizeX - positionX
			else
				set positionX to windowLeft + screenOriginX
				if windowRight < screenSizeX * 0.33 + 5 then
					set sizeX to screenSizeX - windowLeft
				else if windowRight < screenSizeX * 0.5 + 5 then
					set sizeX to screenSizeX * 0.67 - windowLeft
				else if windowRight < screenSizeX * 0.67 + 5 then
					set sizeX to screenSizeX * 0.5 - windowLeft
				else
					set sizeX to screenSizeX * 0.33 + screenOriginX
				end if
			end if
			set positionY to item 2 of windowPositionSize
			set sizeY to item 4 of windowPositionSize
			
		else if (query = "up") then
			if windowTop < 35 then
				set positionY to 0 - screenOriginY
				
				if (screenSizeY = 1200) and windowBottom < (0.05 * screenSizeY - 5) then
					set sizeY to (93 / 100) * screenSizeY
				else if windowBottom < (windowSizeY * 0.5 - 5) then
					set sizeY to 0.5 * screenSizeY
				else
					return "no space to change"
				end if
			else
				if windowTop > 0.5 * screenSizeY then
					set positionY to 0.5 * screenSizeY - screenOriginY
				else
					set positionY to 0 - screenOriginY
				end if
				set sizeY to screenSizeY - windowBottom - 24
				
			end if
			set positionX to item 1 of windowPositionSize
			set sizeX to item 3 of windowPositionSize
			
		else if (query = "down") then
			if ((screenSizeY = 1200) and windowBottom < 0.05 * screenSizeY + 5) or (windowBottom < 5) then
				if windowTop < (windowSizeY * 0.5 - 5 - 24) then
					set positionY to 0.5 * screenSizeY - screenOriginY
				else
					return "no space to change"
				end if
				if (screenSizeY = 1200) then
					set sizeY to 0.45 * screenSizeY
				else
					set sizeY to 0.5 * screenSizeY
				end if
			else
				set positionY to item 2 of windowPositionSize
				
				if windowBottom > 0.5 * screenSizeY then
					set sizeY to 0.5 * screenSizeY - windowTop
				else
					set fixedScreenSizeY to screenSizeY
					if (screenSizeY = 1200) then
						set fixedScreenSizeY to 0.95 * screenSizeY
					end if
					set sizeY to fixedScreenSizeY - windowTop
				end if
			end if
			
			set positionX to item 1 of windowPositionSize
			set sizeX to item 3 of windowPositionSize
			
		end if
		
	else
		set args to converttoList(" ", {query})
		set positionX to (((item 1 of args) / 100) * screenSizeX) + screenOriginX
		set positionY to (((item 2 of args) / 100) * (item 2 of screenSize)) - screenOriginY
		set sizeX to (((item 3 of args) / 100) - ((item 1 of args) / 100)) * screenSizeX
		set sizeY to (((item 4 of args) / 100) - ((item 2 of args) / 100)) * (item 2 of screenSize)
	end if
	
	if sizeX < 300 then
		return "sizeX too small"
	end if
	if sizeY < 100 then
		return "sizeY too small"
	end if
	resizeApp(positionX, positionY, sizeX, sizeY)
end run
