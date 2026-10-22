local WindFogCorridorCoreActivityUI = class("WindFogCorridorCoreActivityUI", import("view.activity.CorePage.StarsCity.StarsCityCoreActivityUI"))

function WindFogCorridorCoreActivityUI:getResource(arg_1_1)
	local var_1_0 = {
		"coreactivityuitable/windfogcorridorcoreactivityui_subtitle_1_text",
		"coreactivityuitable/windfogcorridorcoreactivityui_subtitle_1_text_selected"
	}

	table.insertto(var_1_0, WindFogCorridorCoreActivityUI.super.getResource(self, arg_1_1))

	return var_1_0
end

function WindFogCorridorCoreActivityUI:getUIName()
	return "WindFogCorridorCoreActivityUI"
end

return WindFogCorridorCoreActivityUI
