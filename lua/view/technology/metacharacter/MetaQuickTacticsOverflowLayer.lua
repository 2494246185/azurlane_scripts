local MetaQuickTacticsOverflowLayer = class("MetaQuickTacticsOverflowLayer", import("...base.BaseUI"))

function MetaQuickTacticsOverflowLayer:getUIName()
	return "MetaQuickTacticsOverflowUI"
end

function MetaQuickTacticsOverflowLayer:getGroupName()
	return "MetaCharacterScene"
end

function MetaQuickTacticsOverflowLayer:init()
	self:initData()
	self:initUI()
	self:addListener()
	self:overlayPanel(true)
end

function MetaQuickTacticsOverflowLayer:didEnter()
	return
end

function MetaQuickTacticsOverflowLayer:willExit()
	self:overlayPanel(false)
end

function MetaQuickTacticsOverflowLayer:onBackPressed()
	self:closeView()
end

function MetaQuickTacticsOverflowLayer:overlayPanel(arg_7_1)
	if arg_7_1 and self._tf then
		self:OverlayPanel(self._tf)
	elseif self._tf then
		self:UnOverlayPanel(self._tf)
	end
end

function MetaQuickTacticsOverflowLayer:initData()
	self.shipID = self.contextData.shipID
	self.skillID = self.contextData.skillID
	self.useCountDict = self.contextData.useCountDict
	self.overExp = self.contextData.overExp
end

function MetaQuickTacticsOverflowLayer:initUI()
	self.bg = self._tf:Find("BG")
	self.text = self._tf:Find("Content/Context/Text")
	self.cancelBtn = self._tf:Find("Content/CancelBtn")
	self.confirmBtn = self._tf:Find("Content/ConfirmBtn")

	setText(self.text, i18n("metaskill_overflow_tip", self.overExp))
end

function MetaQuickTacticsOverflowLayer:addListener()
	local function var_10_0()
		self:closeView()
	end

	onButton(self, self.bg, var_10_0, SFX_PANEL)
	onButton(self, self.cancelBtn, var_10_0, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		self:emit(MetaQuickTacticsOverflowMediator.USE_TACTICS_BOOK, self.shipID, self.skillID, self.useCountDict)
		self:closeView()
	end, SFX_PANEL)
end

return MetaQuickTacticsOverflowLayer
