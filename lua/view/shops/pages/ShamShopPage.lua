local ShamShopPage = class("ShamShopPage", import(".BaseShopPage"))

function ShamShopPage:GetPaintingCommodityUpdateVoice()
	return
end

function ShamShopPage:CanOpen(arg_2_1, arg_2_2)
	return pg.SystemOpenMgr.GetInstance():isOpenSystem(arg_2_2.level, "ShamShop")
end

function ShamShopPage:OnUpdateItems()
	self:RefreshResItemList()
end

function ShamShopPage:GetResDataList()
	return self.shop:GetResList()
end

function ShamShopPage:OnUpdateCommodity(arg_5_1)
	local var_5_0

	for iter_5_0, iter_5_1 in pairs(self.cards) do
		if iter_5_1.goodsVO.id == arg_5_1.id then
			var_5_0 = iter_5_1

			break
		end
	end

	if var_5_0 then
		var_5_0:update(arg_5_1)
	end
end

function ShamShopPage:RefreshUI()
	self:UpdateTip()
	setActive(self.tipTextGo, true)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, false)
	setActive(self.refreshBtn, false)
end

function ShamShopPage:OnInitItem(arg_7_1)
	local var_7_0 = ActivityGoodsCard.New(arg_7_1)

	onButton(self, var_7_0.tf, function()
		if not var_7_0.goodsVO:canPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

			return
		end

		self:OnClickCommodity(var_7_0.goodsVO, function(arg_9_0, arg_9_1)
			self:OnPurchase(arg_9_0, arg_9_1)
		end)
	end, SFX_PANEL)

	self.cards[arg_7_1] = var_7_0
end

function ShamShopPage:OnUpdateItem(arg_10_1, arg_10_2)
	if not self.cards[arg_10_2] then
		self:OnInitItem(arg_10_2)
	end

	self.cards[arg_10_2]:update(self.displays[arg_10_1 + 1])
end

function ShamShopPage:OnUpdateAll()
	self:InitCommodities()
	self:OnSetUp()
end

function ShamShopPage:OnSetUp()
	self:UpdateTip()
end

function ShamShopPage:UpdateTip()
	setText(self.tipText, i18n("title_limit_time") .. i18n("shops_rest_day") .. string.format("%02d", self.shop:getRestDays()) .. i18n("word_date"))
end

function ShamShopPage:OnPurchase(arg_14_1, arg_14_2)
	self:emit(NewShopMainMediator.ON_SHAM_SHOPPING, arg_14_1.id, arg_14_2)
end

function ShamShopPage:OnDestroy()
	ShamShopPage.super.OnDestroy(self)
end

return ShamShopPage
