local ActivityRemasterCoreActivityAdaptUI = class("ActivityRemasterCoreActivityAdaptUI", import("view.activity.CorePage.CoreActivityMainScene"))

function ActivityRemasterCoreActivityAdaptUI:getUIName()
	return "ActivityRemasterCoreActivityAdaptUI"
end

function ActivityRemasterCoreActivityAdaptUI:didEnter()
	ActivityRemasterCoreActivityAdaptUI.super.didEnter(self)
	onButton(self, self._tf:Find("adapt/TopPage/top/btn_home"), function()
		self:emit(BaseUI.ON_HOME)
	end, SOUND_BACK)
	self:bind(ActivityRemasterInfoAwardPage.ON_SKIP_ACT, function(arg_4_0, arg_4_1)
		if self.infoDisplayPage and self.infoDisplayPage:GetLoaded() then
			self.infoDisplayPage:Hide()
		end

		self:verifyTabs(arg_4_1)
	end)
	setText(self._tf:Find("adapt/TopPage/top/deco/Text"), i18n("ActivityRemasterCoreActivityAdaptUI_TITLE"))
	setText(self._tf:Find("adapt/TopPage/top/deco/Text/Text_1"), i18n("ActivityRemasterCoreActivityAdaptUI_TITLE_EN"))
end

function ActivityRemasterCoreActivityAdaptUI:flushTabs()
	ActivityRemasterCoreActivityAdaptUI.super.flushTabs(self)

	for iter_5_0, iter_5_1 in ipairs(self.activities) do
		if iter_5_1 then
			local var_5_0 = self.tabsList.container:Find((iter_5_1:getConfig("is_show")))
			local var_5_1 = i18n((iter_5_1:getConfig("title_res_tag")))

			setText(var_5_0:Find("name"), var_5_1)
			setText(var_5_0:Find("on/name"), var_5_1)
		end
	end
end

function ActivityRemasterCoreActivityAdaptUI:init(...)
	self:AddLoginTab()
	ActivityRemasterCoreActivityAdaptUI.super.init(self, ...)

	self.btnBack = self._tf:Find("adapt/TopPage/top/btn_back")
end

function ActivityRemasterCoreActivityAdaptUI:AddLoginTab()
	local var_7_0 = self._tf:Find("adapt/tabs")

	cloneTplTo(var_7_0:GetChild(0), var_7_0).name = var_7_0.childCount + 1 .. ""
end

function ActivityRemasterCoreActivityAdaptUI:OnPageSwitchDone(arg_8_1, arg_8_2)
	if not self.awardPreviewBtn then
		self:InitAwardPreviewBtn()
	end

	setActive(self.awardPreviewBtn, arg_8_2 == 1)

	local var_8_0 = arg_8_1:GetAwardPreviewPos()

	if var_8_0 then
		setAnchoredPosition3D(self.awardPreviewBtn, BuildVector3(var_8_0))
	else
		setAnchoredPosition3D(self.awardPreviewBtn, self.initAwardPreviewBtnPos)
	end
end

function ActivityRemasterCoreActivityAdaptUI:InitAwardPreviewBtn()
	self.awardPreviewBtn = self._tf:Find("adapt/award_preview")

	setText(self.awardPreviewBtn:Find("Text"), i18n("ActivityRemasterCore_award_preview_btn"))

	self.initAwardPreviewBtnPos = getAnchoredPosition(self.awardPreviewBtn)

	onButton(self, self.awardPreviewBtn, function()
		self.infoDisplayPage = self.infoDisplayPage or ActivityRemasterInfoWithoutTextDisplayPage.New(self._tf, self.event)

		self.infoDisplayPage:ExecuteAction("Show", getProxy(ActivityRemasterProxy):GetActiveActID(), "")
	end, SFX_PANEL)
end

function ActivityRemasterCoreActivityAdaptUI:willExit()
	ActivityRemasterCoreActivityAdaptUI.super.willExit(self)

	if self.infoDisplayPage and self.infoDisplayPage:GetLoaded() then
		self.infoDisplayPage:Destroy()
	end

	self.infoDisplayPage = nil
end

return ActivityRemasterCoreActivityAdaptUI
