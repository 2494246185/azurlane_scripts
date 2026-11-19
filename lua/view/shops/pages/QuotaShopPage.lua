local QuotaShopPage = class("QuotaShopPage", import(".BaseShopPage"))

function QuotaShopPage:GetPaintingCommodityUpdateVoice()
	return
end

function QuotaShopPage:CanOpen(arg_2_1, arg_2_2)
	return pg.SystemOpenMgr.GetInstance():isOpenSystem(arg_2_2.level, "QuotaShop")
end

function QuotaShopPage:RefreshUI()
	self:UpdateTip()
	setActive(self.tipTextGo, true)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, false)
	setActive(self.refreshBtn, false)
end

function QuotaShopPage:UpdateTip()
	setText(self.tipText, i18n("quota_shop_description"))
end

function QuotaShopPage:OnUpdateItems()
	self:RefreshResItemList()
end

function QuotaShopPage:GetResDataList()
	return self.shop:GetResList()
end

function QuotaShopPage:OnUpdateCommodity(arg_7_1)
	local var_7_0

	for iter_7_0, iter_7_1 in pairs(self.cards) do
		if iter_7_1.goodsVO.id == arg_7_1.id then
			var_7_0 = iter_7_1

			break
		end
	end

	if var_7_0 then
		var_7_0:update(arg_7_1)
	end
end

function QuotaShopPage:OnInitItem(arg_8_1)
	local var_8_0 = QuotaGoodsCard.New(arg_8_1)

	onButton(self, var_8_0.tf, function()
		if not var_8_0.goodsVO:canPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

			return
		end

		self:OnClickCommodity(var_8_0.goodsVO, function(arg_10_0, arg_10_1)
			self:OnPurchase(arg_10_0, arg_10_1)
		end)
	end, SFX_PANEL)

	self.cards[arg_8_1] = var_8_0
end

function QuotaShopPage:OnUpdateItem(arg_11_1, arg_11_2)
	if not self.cards[arg_11_2] then
		self:OnInitItem(arg_11_2)
	end

	self.cards[arg_11_2]:update(self.displays[arg_11_1 + 1])
end

function QuotaShopPage:OnUpdateAll()
	self:InitCommodities()
end

function QuotaShopPage:OnPurchase(arg_13_1, arg_13_2)
	self:emit(NewShopMainMediator.ON_QUOTA_SHOPPING, arg_13_1.id, arg_13_2)
end

function QuotaShopPage:OnDestroy()
	QuotaShopPage.super.OnDestroy(self)
end

return QuotaShopPage
