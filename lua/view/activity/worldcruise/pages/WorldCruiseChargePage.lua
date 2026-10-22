local WorldCruiseChargePage = class("WorldCruiseChargePage", import("view.base.BaseSubView"))

function WorldCruiseChargePage:getUIName()
	return "WorldCruiseChargePage"
end

function WorldCruiseChargePage:OnLoaded()
	return
end

function WorldCruiseChargePage:OnInit()
	self.buyWindow = self._tf:Find("buy_window")
	self.cancelBtn = self.buyWindow:Find("button_container/button_cancel")

	setText(self.cancelBtn:Find("Image"), i18n("text_cancel"))

	self.confirmBtn = self.buyWindow:Find("button_container/button_ok")
	self.priceTF = self.confirmBtn:Find("Image")

	setText(self.buyWindow:Find("left/got/desc"), i18n("battlepass_pay_acquire"))

	local var_3_0 = self.buyWindow:Find("right/items/scrollview/list")

	self.uiItemList = UIItemList.New(var_3_0, var_3_0:Find("tpl"))

	self.uiItemList:make(function(arg_4_0, arg_4_1, arg_4_2)
		arg_4_1 = arg_4_1 + 1

		if arg_4_0 == UIItemList.EventUpdate then
			local var_4_0 = self.itemList[arg_4_1]

			updateDrop(arg_4_2, self.itemList[arg_4_1])
			setText(arg_4_2:Find("name"), shortenString(self.itemList[arg_4_1]:getConfig("name"), 4))
			onButton(self, arg_4_2, function()
				self:emit(BaseUI.ON_NEW_STYLE_DROP, {
					drop = var_4_0
				})
			end, SFX_CONFIRM)
		end
	end)

	self.unlcokWindow = self._tf:Find("unlock_window")

	setText(self.unlcokWindow:Find("tip"), i18n("word_click_to_close"))

	self.unlockItem = self.unlcokWindow:Find("IconTpl")

	onButton(self, self._tf:Find("bg"), function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.cancelBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		if ChargeConst.isNeedSetBirth() then
			self:emit(WorldCruiseMediator.EVENT_OPEN_BIRTHDAY)
		else
			pg.m02:sendNotification(GAME.CHARGE_OPERATION, {
				shopId = self.passId
			})
		end
	end, SFX_PANEL)
end

function WorldCruiseChargePage:GetPassId()
	return WorldCruiseChargePage.GetPassID()
end

function WorldCruiseChargePage:ShowBuyWindow()
	setActive(self.buyWindow, true)
	setActive(self.unlcokWindow, false)
	self:Show()

	if self.passId and self.passId == self:GetPassId() then
		return
	end

	self.passId = self:GetPassId()

	local var_10_0 = Goods.Create({
		shop_id = self.passId
	}, Goods.TYPE_CHARGE)
	local var_10_1 = Drop.Create(var_10_0:getConfig("display")[1])

	LoadImageSpriteAtlasAsync(var_10_1:getIcon(), "", self.buyWindow:Find("left/got/award/icon"))
	setText(self.buyWindow:Find("left/got/award/count"), "x" .. var_10_1.count)
	setText(self.buyWindow:Find("right/tip"), var_10_0:getConfig("descrip_extra"))

	local var_10_2 = var_10_0:getConfig("money")

	if PLATFORM_CODE == PLATFORM_CHT and var_10_0:IsLocalPrice() then
		-- block empty
	else
		var_10_2 = GetMoneySymbol() .. var_10_2
	end

	setText(self.priceTF, var_10_2)

	self.itemList = var_10_0:GetExtraServiceItem()

	self.uiItemList:align(#self.itemList)
end

function WorldCruiseChargePage.GetPassID()
	local var_11_0 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_11_0 and not var_11_0:isEnd() then
		for iter_11_0, iter_11_1 in ipairs(pg.pay_data_display.all) do
			if pg.pay_data_display[iter_11_1].sub_display and type(pg.pay_data_display[iter_11_1].sub_display) == "table" and pg.pay_data_display[iter_11_1].sub_display[1] == var_11_0.id then
				return iter_11_1
			end
		end
	end
end

function WorldCruiseChargePage:ShowUnlockWindow(arg_12_1, arg_12_2)
	setActive(self.buyWindow, false)
	setActive(self.unlcokWindow, true)
	self:Show()

	local var_12_0 = Drop.Create(arg_12_1:getConfig("display")[1])

	updateDrop(self.unlockItem, var_12_0)
	onButton(self, self.unlockItem, function()
		self:emit(BaseUI.ON_NEW_STYLE_DROP, {
			drop = var_12_0
		})
	end, SFX_CONFIRM)

	self.onHide = arg_12_2
end

function WorldCruiseChargePage:Show()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	WorldCruiseChargePage.super.Show(self)
end

function WorldCruiseChargePage:Hide()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	WorldCruiseChargePage.super.Hide(self)

	if self.onHide then
		self.onHide()

		self.onHide = nil
	end
end

function WorldCruiseChargePage:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end
end

return WorldCruiseChargePage
