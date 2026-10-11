#include "umf.lua"
local function bool(id, invert)
    id = "savegame.mod." .. id
    invert = not invert
    return function() return GetBool(id) == invert end
end

--[[local warningtext = OptionsMenu.Text ( "Legacy flight is unsupported and will have more bugs.", { condition = bool("legacy"), align = "center top", pad_bottom = 10, pad_top = 10 } )]]
OptionsMenu {
    title = "TABS Crew",

    OptionsMenu.Spacer(50),

    --OptionsMenu.Toggle {id = "legacy", name = "Legacy Flight", default = false},
	--[[function()
		UiPush()
			UiColor(1, 0.3, 0.25, 1)
			local w, h = warningtext()
			if w > 0 then
				UiTranslate( 0, -2 )
				UiRectOutline(w + 10, math.floor(h - 15), 2)
			end
		UiPop()
		return w, h
	end,]]
    --OptionsMenu.Spacer(50),

	OptionsMenu.Group {
		title = "Keybinds",

		OptionsMenu.Keybind { id = "key.Ctype", name = "Crew Type", default = "G" },
		OptionsMenu.Keybind { id = "key.rotation", name = "Crew Rotation", default = "T" },
		OptionsMenu.Keybind { id = "key.record", name = "Record preset (autosave)", default = "R" },
		OptionsMenu.Keybind { id = "key.place", name = "Place preset", default = "Y" },
		
		OptionsMenu.Toggle { id = "key.uion", name = "Kill Sound and UI", default = true },		
		OptionsMenu.Toggle { id = "key.toolenable", name = "Tool Enable", default = true },				
		--[[OptionsMenu.Keybind { id = "key.axis", name = "Change Rotation Axis", default = "rmb" },
		OptionsMenu.Keybind { id = "key.color", name = "Change Color", default = "e" },
		OptionsMenu.Keybind { id = "key.resetrot", name = "Reset Rotation", default = "mmb" },]]
	}
}

--[[function draw()
	UiFont( "regular.ttf", 26 )
	UiTranslate( UiCenter(), UiMiddle() )
	UiAlign( "center middle" )
	UiWindow( 600, 232 )
	UiAlign( "top left" )
	UiColor( .1, .1, .1, 0.6 )
	UiImageBox( "ui/common/box-solid-shadow-50.png", 600, 232, -50, -50 )

	UiColor( 1, 1, 1 )
	UiTranslate( 290, 80 )
	UiAlign( "right" )
	if SetCameraFov then
		UiPush()
		UiText( "Legacy Flight" )
		UiTranslate( 20, 0 )
		UiAlign( "left" )
		UiColor( 1, 1, 0.7 )
		local val = GetInt( "savegame.mod.legacy" )
		if val == 0 then
			if UiTextButton( "Disabled" ) then
				SetInt( "savegame.mod.legacy", 1 )
			end
		else
			if UiTextButton( "Enabled" ) then
				SetInt( "savegame.mod.legacy", 0 )
			end
		end
		UiPop()
		UiTranslate( 0, 32 )
	end
	if not SetCameraFov or GetInt( "savegame.mod.legacy" ) == 1 then
		UiPush()
		UiText( "Hybrid Noclip" )
		UiTranslate( 20, 0 )
		UiAlign( "left" )
		UiColor( 1, 1, 0.7 )
		local val = GetInt( "savegame.mod.hybrid" )
		if val == 1 then
			if UiTextButton( "Disabled" ) then
				SetInt( "savegame.mod.hybrid", 0 )
			end
		else
			if UiTextButton( "Enabled" ) then
				SetInt( "savegame.mod.hybrid", 1 )
			end
		end
		UiPop()
	else
		UiPush()
		UiText( "Ignore Slow-Mo" )
		UiTranslate( 20, 0 )
		UiAlign( "left" )
		UiColor( 1, 1, 0.7 )
		local val = GetInt( "savegame.mod.noslowmo" )
		if val == 0 then
			if UiTextButton( "Disabled" ) then
				SetInt( "savegame.mod.noslowmo", 1 )
			end
		else
			if UiTextButton( "Enabled" ) then
				SetInt( "savegame.mod.noslowmo", 0 )
			end
		end
		UiPop()
	end
	UiTranslate( 10, 80 )
	UiAlign( "center" )
	if UiTextButton( "Close" ) then
		Menu()
	end

end]]

