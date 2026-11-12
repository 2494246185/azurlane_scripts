local IslandSettingsAdjustScreenPanle = class("IslandSettingsAdjustScreenPanle", import("view.Setting.panels.SettingsBasePanel"))

function IslandSettingsAdjustScreenPanle:GetUIName()
	return "IslandSettingsAdjustScreen"
end

function IslandSettingsAdjustScreenPanle:GetTitle()
	return i18n("Settings_title_AdjustScr")
end

function IslandSettingsAdjustScreenPanle:GetTitleEn()
	return "  / SCREEN SETTING"
end

function IslandSettingsAdjustScreenPanle:InitTitle()
	setText(self._tf:Find("title/title_point/title_text"), self:GetTitle())
end

function IslandSettingsAdjustScreenPanle:OnInit()
	self.notchSlider = findTF(self._tf, "slider")
end

function IslandSettingsAdjustScreenPanle:OnUpdate()
	local var_6_0 = getProxy(SettingsProxy)

	setSlider(self.notchSlider, ADAPT_MIN, math.clamp(Screen.width / Screen.height - 0.001, 1.3333333333333333, 2.3333333333333335), var_6_0:GetScreenRatio())
	OnSliderWithButton(self, self.notchSlider, function(arg_7_0)
		var_6_0:SetScreenRatio(arg_7_0)

		NotchAdapt.CheckNotchRatio = arg_7_0
	end)
end

return IslandSettingsAdjustScreenPanle
