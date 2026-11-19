local MedalShopPage = class("MedalShopPage", import(".MilitaryShopPage"))

function MedalShopPage:CanOpen()
	return true
end

function MedalShopPage:CustomInit()
	self.purchaseWindow = MedalShopPurchasePanel.New(self._tf, self.parent.event)
	self.multiWindow = MedalShopMultiWindow.New(self._tf, self.parent.event)
end

function MedalShopPage:UpdateShop(...)
	MedalShopPage.super.UpdateShop(self, ...)

	if self.purchaseWindow:isShowing() then
		self.purchaseWindow:ExecuteAction("Hide")
	end

	if self.multiWindow:isShowing() then
		self.multiWindow:ExecuteAction("Hide")
	end
end

function MedalShopPage:OnUpdatePlayer()
	return
end

function MedalShopPage:OnUpdateItems()
	self:RefreshResItemList()
end

function MedalShopPage:GetResDataList()
	return self.shop:GetResList()
end

function MedalShopPage:RefreshUI()
	setActive(self.tipTextGo, true)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, false)
	setActive(self.refreshBtn, false)
end

function MedalShopPage:OnInitItem(arg_8_1)
	local var_8_0 = MedalGoodsCard.New(arg_8_1)

	onButton(self, var_8_0.go, function()
		if not var_8_0.goods:CanPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

			return
		end

		self:OnCardClick(var_8_0)
	end, SFX_PANEL)

	self.cards[arg_8_1] = var_8_0
end

function MedalShopPage:OnCardClick(arg_10_1)
	if arg_10_1.goods:Selectable() then
		self.purchaseWindow:ExecuteAction("Show", {
			id = arg_10_1.goods.id,
			count = arg_10_1.goods:GetMaxCnt(),
			type = arg_10_1.goods:getConfig("type"),
			price = arg_10_1.goods:getConfig("price"),
			displays = arg_10_1.goods:getConfig("goods"),
			num = arg_10_1.goods:getConfig("num")
		})
	elseif arg_10_1.goods:getConfig("goods_type") == 1 and arg_10_1.goods:GetLimit() > 1 then
		self.multiWindow:ExecuteAction("Show", arg_10_1.goods, function(arg_11_0)
			if not arg_10_1.goods:CanPurchaseCnt(arg_11_0) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

				return
			end

			local var_11_0 = {}
			local var_11_1 = arg_10_1.goods:getConfig("goods")[1]

			for iter_11_0 = 1, arg_11_0 do
				table.insert(var_11_0, var_11_1)
			end

			self:emit(NewShopMainMediator.ON_MEDAL_SHOPPING, arg_10_1.goods.id, var_11_0)
		end)
	else
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			yesText = "text_exchange",
			content = i18n("guild_shop_exchange_tip"),
			onYes = function()
				if not arg_10_1.goods:CanPurchase() then
					pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

					return
				end

				self:emit(NewShopMainMediator.ON_MEDAL_SHOPPING, arg_10_1.goods.id, arg_10_1.goods:GetFirstDropId())
			end
		})
	end
end

function MedalShopPage:AddTimer()
	local var_13_0 = self.shop.nextTime + 1

	self.timer = Timer.New(function()
		local var_14_0 = var_13_0 - pg.TimeMgr.GetInstance():GetServerTime()

		if var_14_0 <= 0 then
			self:RemoveTimer()
			self:OnTimeOut()
		else
			setText(self.tipText, i18n("title_limit_time") .. i18n("shops_rest_day") .. string.format("%02d", 1 + math.floor((var_14_0 - 1) / 86400)) .. i18n("word_date"))
		end
	end, 1, -1)

	self.timer:Start()
	self.timer.func()
end

function MedalShopPage:OnTimeOut()
	self:emit(NewShopMainMediator.REFRESH_MEDAL_SHOP, false)
end

function MedalShopPage:OnDestroy()
	MedalShopPage.super.OnDestroy(self)
	self.purchaseWindow:Destroy()
	self.multiWindow:Destroy()
end

return MedalShopPage
