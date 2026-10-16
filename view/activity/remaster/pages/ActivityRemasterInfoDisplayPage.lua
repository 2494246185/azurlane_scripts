local ActivityRemasterInfoDisplayPage = class("ActivityRemasterInfoDisplayPage", import("view.base.BaseSubView"))
local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = 3

function ActivityRemasterInfoDisplayPage:getUIName()
	return "ActivityRemasterInfoDisplayPage"
end

function ActivityRemasterInfoDisplayPage:OnLoaded()
	self.toggles = {
		[var_0_1] = self._tf:Find("window/middle/toggles/ship"),
		[var_0_2] = self._tf:Find("window/middle/toggles/es"),
		[var_0_3] = self._tf:Find("window/middle/toggles/other")
	}
	self.uiItemList = {
		[var_0_1] = UIItemList.New(self._tf:Find("window/middle/view/ship/content"), self._tf:Find("window/middle/view/ship/content/ship_tpl")),
		[var_0_2] = UIItemList.New(self._tf:Find("window/middle/view/es/content"), self._tf:Find("window/middle/view/es/content/ship_tpl")),
		[var_0_3] = UIItemList.New(self._tf:Find("window/middle/view/other/content"), self._tf:Find("window/middle/view/es/content/ship_tpl"))
	}

	setText(self._tf:Find("window/middle/title_bg/Text"), i18n("ActivityRemasterCore_award_preview_title"))

	self.awardPage = ActivityRemasterInfoAwardPage.New(self._tf, self.event)
end

function ActivityRemasterInfoDisplayPage:OnInit()
	self:CommonSetting({})
end

function ActivityRemasterInfoDisplayPage:Show(arg_4_1, arg_4_2, arg_4_3)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.onConfirm = arg_4_3
	self.remasterData = ActivityRemasterData.New({
		id = arg_4_1
	})

	setText(self._tf:Find("window/middle/content"), arg_4_2)
	setActive(self._tf, true)
	self:InitToggles()
	triggerToggle(self.toggles[var_0_1], true)
end

function ActivityRemasterInfoDisplayPage:Hide(arg_5_1)
	if not self._tf then
		return
	end

	setActive(self._tf, false)

	self.onConfirm = nil

	if self.awardPage and self.awardPage:GetLoaded() then
		self.awardPage:Hide()
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, pg.UIMgr.GetInstance().OverlayMain)
end

local function var_0_4(arg_6_0, arg_6_1)
	local var_6_0 = ""

	if arg_6_1 == var_0_1 then
		var_6_0 = arg_6_0:GetShipOwnStr()
	elseif arg_6_1 == var_0_2 then
		var_6_0 = arg_6_0:GetEsOwnStr()
	elseif arg_6_1 == var_0_3 then
		var_6_0 = arg_6_0:GetOtherOwnStr()
	end

	return ({
		[var_0_1] = i18n("ActivityRemasterCore_award_preview_ship", var_6_0),
		[var_0_2] = i18n("ActivityRemasterCore_award_preview_es", var_6_0),
		[var_0_3] = i18n("ActivityRemasterCore_award_preview_other", var_6_0)
	})[arg_6_1]
end

function ActivityRemasterInfoDisplayPage:InitToggles()
	for iter_7_0, iter_7_1 in pairs(self.toggles) do
		local var_7_0 = var_0_4(self.remasterData, iter_7_0)

		onToggle(self, iter_7_1, function(arg_8_0)
			setText(iter_7_1:Find("Text"), setColorStr(var_7_0, (arg_8_0 or nil) and (COLOR_WHITE or "#393a3c")))

			if arg_8_0 then
				self:SwitchPage(iter_7_0)
			end
		end, SFX_PANEL)
		setText(iter_7_1:Find("Text"), setColorStr(var_7_0, "#393a3c"))
	end
end

function ActivityRemasterInfoDisplayPage:GetDisplayData(arg_9_1)
	local var_9_0 = {}

	if arg_9_1 == var_0_1 then
		var_9_0 = self.remasterData:GetRawCollectableShipIdList()
	elseif arg_9_1 == var_0_2 then
		var_9_0 = self.remasterData:GetRawCollectableEsList()
	elseif arg_9_1 == var_0_3 then
		var_9_0 = self.remasterData:GetRawCollectableOtherList()
	end

	return var_9_0
end

function ActivityRemasterInfoDisplayPage:SwitchPage(arg_10_1)
	local var_10_0 = self:GetDisplayData(arg_10_1)

	self.uiItemList[arg_10_1]:make(function(arg_11_0, arg_11_1, arg_11_2)
		if arg_11_0 == UIItemList.EventUpdate then
			if arg_10_1 == var_0_1 then
				self:UpdateShipCard(arg_11_2, var_10_0[arg_11_1 + 1])
			elseif arg_10_1 == var_0_2 or arg_10_1 == var_0_3 then
				self:UpdateItemCard(arg_11_2, var_10_0[arg_11_1 + 1])
			end
		end
	end)
	self.uiItemList[arg_10_1]:align(#var_10_0)
	scrollToBottom(self.uiItemList[arg_10_1].container.parent)
end

function ActivityRemasterInfoDisplayPage:UpdateShipCard(arg_12_1, arg_12_2)
	local var_12_0 = arg_12_2:GetRawDropData()[2]
	local var_12_1 = ShipGroup.getDefaultShipConfig(var_12_0)

	GetImageSpriteFromAtlasAsync("shipYardIcon/" .. pg.ship_skin_template[var_12_1.skin_id].painting, pg.ship_skin_template[var_12_1.skin_id].painting, arg_12_1:Find("tpl/ico"))
	setActive(arg_12_1:Find("tpl/mask"), (getProxy(CollectionProxy):getShipGroup(var_12_0)))
	setScrollText(arg_12_1:Find("name/mask/Text"), var_12_1.name)
	onButton(self, arg_12_1, function()
		self:OpenDesc(arg_12_2)
	end, SFX_PANEL)
end

function ActivityRemasterInfoDisplayPage:UpdateItemCard(arg_14_1, arg_14_2)
	local var_14_0 = Drop.Create(arg_14_2:GetRawDropData())

	updateDrop(arg_14_1:Find("award"), var_14_0)
	setScrollText(arg_14_1:Find("name/mask/Text"), var_14_0.cfg.name)
	setActive(arg_14_1:Find("award/mask"), var_14_0:getOwnedCount() > 0)
	onButton(self, arg_14_1, function()
		self:OpenDesc(arg_14_2)
	end, SFX_PANEL)
end

function ActivityRemasterInfoDisplayPage:OpenDesc(arg_16_1)
	return
end

function ActivityRemasterInfoDisplayPage:CommonSetting(arg_17_1)
	setText(self._tf:Find("window/top/title"), arg_17_1.title or i18n("words_information"))

	function self.hideCall()
		self.hideCall = nil

		existCall(arg_17_1.onClose)
	end

	onButton(self, self._tf:Find("bg"), function()
		existCall(self.hideCall)
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("window/top/btn_close"), function()
		existCall(self.hideCall)
		self:Hide()
	end, SFX_CANCEL)

	function self.confirmCall()
		self.confirmCall = nil

		existCall(self.onConfirm)
	end

	local var_17_1 = arg_17_1.btnList or {
		{
			type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.cancel,
			name = i18n("msgbox_text_cancel"),
			func = function()
				existCall(self.hideCall)
			end,
			sound = SFX_CANCEL
		},
		{
			type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.confirm,
			name = i18n("msgbox_text_confirm"),
			func = function()
				existCall(self.confirmCall)
			end,
			sound = SFX_CONFIRM
		}
	}
	local var_17_2 = self._tf:Find("window/bottom/button_container")

	eachChild(var_17_2, function(arg_24_0)
		setActive(arg_24_0, false)
	end)

	for iter_17_0, iter_17_1 in ipairs(var_17_1) do
		local var_17_3 = var_17_2:Find(iter_17_1.type)

		if var_17_3:GetSiblingIndex() < var_17_2.childCount - iter_17_0 + 1 then
			var_17_3:SetAsLastSibling()
			setActive(var_17_3, true)
		else
			var_17_3 = cloneTplTo(var_17_3, var_17_2, var_17_3.name)
		end

		setText(var_17_3:Find("Text"), iter_17_1.name)
		onButton(self, var_17_3, function()
			existCall(iter_17_1.func)
			self:Hide()
		end, iter_17_1.sound or SFX_CONFIRM)
	end
end

function ActivityRemasterInfoDisplayPage:onBackPressed()
	if self.awardPage and self.awardPage:GetLoaded() and self.awardPage:isShowing() then
		self.awardPage:Hide()

		return
	end

	self:Hide()
end

function ActivityRemasterInfoDisplayPage:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end

	if self.awardPage and self.awardPage:GetLoaded() then
		self.awardPage:Destroy()
	end

	self.awardPage = nil
end

return ActivityRemasterInfoDisplayPage
