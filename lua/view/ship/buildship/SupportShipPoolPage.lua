local SupportShipPoolPage = class("SupportShipPoolPage", import("...base.BaseSubView"))

function SupportShipPoolPage:getResource()
	local var_1_0 = {}

	if pg.gametip.honor_medal_support_tips_display.tip and noEmptyStr(pg.gametip.honor_medal_support_tips_display.tip.bg) then
		table.insert(var_1_0, pg.gametip.honor_medal_support_tips_display.tip.bg)
	end

	if self.contextData then
		local var_1_1 = self.contextData.falgShip or getProxy(BayProxy):getShipById(getProxy(PlayerProxy):getData().character)

		if var_1_1 then
			table.insertto(var_1_0, ResPathSupport.GetPaintingListByPaintingName(var_1_1:getPainting()))
		end
	end

	return table.insertto(var_1_0, SupportShipPoolPage.super.getResource(self))
end

function SupportShipPoolPage:getUIName()
	return "SupportShipPoolPageUI"
end

function SupportShipPoolPage:OnLoaded()
	self.medalCount = self._tf:Find("gallery/res_items/medal")
	self.patingTF = self._tf:Find("painting")
	self.bg = self._tf:Find("gallery/bg")
	self.tipSTxt = self.bg:Find("type_intro/mask/title"):GetComponent("ScrollText")
	self.shopBtn = self._tf:Find("gallery/shop_btn")
	self.helpBtn = self._tf:Find("gallery/help_btn")
	self.startBtn = self._tf:Find("gallery/start_btn")
end

function SupportShipPoolPage:OnInit()
	onButton(self, self.shopBtn, function()
		self:emit(BuildShipMediator.ON_SUPPORT_SHOP)
	end, SFX_PANEL)
end

function SupportShipPoolPage:Flush()
	self:UpdateMedal()

	local var_6_0 = getProxy(BuildShipProxy):getSupportShipCost()
	local var_6_1 = pg.gametip.honor_medal_support_tips_display.tip

	setText(self._tf:Find("gallery/prints/intro/text"), pg.gametip.honor_medal_support_tips_display.tip.support_tip_consume)
	setImageSprite(self.bg, GetSpriteFromAtlas(pg.gametip.honor_medal_support_tips_display.tip.bg, ""))
	self.tipSTxt:SetText(pg.gametip.honor_medal_support_tips_display.tip.support_tip_ship)

	local var_6_2 = self._tf:Find("gallery/item_bg/medal")

	setText(var_6_2:Find("name"), Drop.New({
		type = DROP_TYPE_ITEM,
		id = ITEM_ID_SILVER_HOOK
	}):getName())
	setText(var_6_2:Find("count/Text"), var_6_0)
	self:UpdateBuildPoolPaiting()
	onButton(self, self.helpBtn, function()
		self.contextData.helpWindow:ExecuteAction("Show", var_6_1, "support")
	end, SFX_CANCEL)

	local var_6_3 = getProxy(BagProxy)

	onButton(self, self.startBtn, function()
		self.contextData.msgbox:ExecuteAction("Show", {
			buildType = "medal",
			itemVO = Item.New({
				id = ITEM_ID_SILVER_HOOK,
				count = var_6_3:getItemCountById(ITEM_ID_SILVER_HOOK)
			}),
			cost = var_6_0,
			max = MAX_BUILD_WORK_COUNT,
			onConfirm = function(arg_9_0)
				self:emit(BuildShipMediator.ON_SUPPORT_EXCHANGE, arg_9_0)
			end
		})
	end, SFX_UI_BUILDING_STARTBUILDING)
end

function SupportShipPoolPage:UpdateMedal()
	setText(self.medalCount:Find("Text"), getProxy(BagProxy):getItemCountById(ITEM_ID_SILVER_HOOK))
end

function SupportShipPoolPage:UpdateBuildPoolPaiting()
	local var_11_0 = self.contextData.falgShip:getPainting()

	if self.painting ~= var_11_0 then
		pg.UIMgr.GetInstance():LoadingOn()
		setPaintingPrefabAsync(self.patingTF, var_11_0, "build", function()
			self.painting = var_11_0

			pg.UIMgr.GetInstance():LoadingOff()
		end)
	end
end

function SupportShipPoolPage:ShowOrHide(arg_13_1)
	if arg_13_1 then
		self:Show()
	else
		self:Hide()
	end
end

function SupportShipPoolPage:OnDestroy()
	return
end

return SupportShipPoolPage
