local TwoPointFiveScenarioPage = class("TwoPointFiveScenarioPage", import("view.activity.CorePage.CoreScenarioTemplatePage"))

TwoPointFiveScenarioPage.LINE_COLOR = {
	"97D2E1",
	"ffffff",
	"FB3F95"
}
TwoPointFiveScenarioPage.TITLE_COLOR = {
	"ffffff",
	"ffffffff",
	"ffffffff"
}
TwoPointFiveScenarioPage.TITLE_ALPHA = {
	0.5,
	1,
	1
}
TwoPointFiveScenarioPage.NODE_SPACING = 20
TwoPointFiveScenarioPage.TAIL_SPACING = 20

function TwoPointFiveScenarioPage:getUIName()
	return "TwoPointFiveScenarioPage"
end

function TwoPointFiveScenarioPage:OnInit()
	TwoPointFiveScenarioPage.super.OnInit(self)

	self.resTime = self._tf:Find("TopPage/top/resTime/Text")

	self:refreshTime(self.activity)
end

function TwoPointFiveScenarioPage:Show()
	TwoPointFiveScenarioPage.super.Show(self)
	Canvas.ForceUpdateCanvases()
	self:UpdateStory(true)
	Canvas.ForceUpdateCanvases()
	self:Move2UnlockStory()
end

function TwoPointFiveScenarioPage:Hide()
	TwoPointFiveScenarioPage.super.Hide(self)

	if self.viewComponent and not self.viewComponent.exited then
		self.viewComponent:ActiveScenarioLayer(false)
		self.coreStoryPage:emit(ActivityMainScene.FLUSH_TABS)
	end
end

function TwoPointFiveScenarioPage:UpdateStory(arg_5_1)
	TwoPointFiveScenarioPage.super.UpdateStory(self, arg_5_1)
	setText(self.progressText, "<color=#27c5ff>" .. self.storyReadCount .. "</color><color=#c7c7c7>/" .. self.storyReadMax .. "</color>")
end

function TwoPointFiveScenarioPage:RefreshNodeTitle(arg_6_1, arg_6_2)
	setScrollText(arg_6_1:Find("info/bk/title_form/title"), arg_6_2)
	setActive(arg_6_1:Find("conditionBg"), false)
end

function TwoPointFiveScenarioPage:RefreshUnlockDesc(arg_7_1, arg_7_2, arg_7_3)
	setScrollText(arg_7_1:Find("info/bk/title_form/title"), arg_7_2)
	setActive(arg_7_1:Find("conditionBg"), true)
	setScrollText(arg_7_1:Find("conditionBg/Text"), arg_7_3)
end

function TwoPointFiveScenarioPage:refreshTime(arg_8_1)
	local var_8_0 = arg_8_1.stopTime - pg.TimeMgr.GetInstance():GetServerTime()

	setText(self.resTime, i18n("nier_core_countdown", math.floor(var_8_0 / 86400), math.floor(var_8_0 % 86400 / 3600)))
end

return TwoPointFiveScenarioPage
