local TianYuTianYuanCoreActivityReUI = class("TianYuTianYuanCoreActivityReUI", import("view.activity.CorePage.TianYuTianYuan.TianYuTianYuanCoreActivityUI"))

function TianYuTianYuanCoreActivityReUI:getUIName()
	return "TianYuTianYuanCoreActivityReUI"
end

function TianYuTianYuanCoreActivityReUI:init(...)
	self:AddLoginTab()
	TianYuTianYuanCoreActivityReUI.super.init(self, ...)
	self:bind(ActivityRemasterInfoAwardPage.ON_SKIP_ACT, function(arg_3_0, arg_3_1)
		if self.infoDisplayPage and self.infoDisplayPage:GetLoaded() then
			self.infoDisplayPage:Hide()
		end

		self:verifyTabs(arg_3_1)
	end)
end

function TianYuTianYuanCoreActivityReUI:AddLoginTab()
	local var_4_0 = self._tf:Find("adapt/tabs")

	cloneTplTo(var_4_0:GetChild(0), var_4_0).name = var_4_0.childCount + 1 .. ""
end

function TianYuTianYuanCoreActivityReUI:OnPageSwitchDone(arg_5_1, arg_5_2)
	if not self.awardPreviewBtn then
		self:InitAwardPreviewBtn()
	end

	setActive(self.awardPreviewBtn, arg_5_2 == 1)

	local var_5_0 = arg_5_1:GetAwardPreviewPos()

	if var_5_0 then
		setAnchoredPosition3D(self.awardPreviewBtn, BuildVector3(var_5_0))
	else
		setAnchoredPosition3D(self.awardPreviewBtn, self.initAwardPreviewBtnPos)
	end
end

function TianYuTianYuanCoreActivityReUI:InitAwardPreviewBtn()
	self.awardPreviewBtn = self._tf:Find("adapt/award_preview")

	setText(self.awardPreviewBtn:Find("Text"), i18n("ActivityRemasterCore_award_preview_btn"))

	self.initAwardPreviewBtnPos = getAnchoredPosition(self.awardPreviewBtn)

	onButton(self, self.awardPreviewBtn, function()
		self.infoDisplayPage = self.infoDisplayPage or ActivityRemasterInfoWithoutTextDisplayPage.New(self._tf, self.event)

		self.infoDisplayPage:ExecuteAction("Show", getProxy(ActivityRemasterProxy):GetActiveActID(), "")
	end, SFX_PANEL)
end

function TianYuTianYuanCoreActivityReUI:willExit()
	TianYuTianYuanCoreActivityReUI.super.willExit(self)

	if self.infoDisplayPage and self.infoDisplayPage:GetLoaded() then
		self.infoDisplayPage:Destroy()
	end

	self.infoDisplayPage = nil
end

return TianYuTianYuanCoreActivityReUI
