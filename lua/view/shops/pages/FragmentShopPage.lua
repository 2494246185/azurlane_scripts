local FragmentShopPage = class("FragmentShopPage", import(".ShamShopPage"))

function FragmentShopPage:GetPaintingCommodityUpdateVoice()
	return
end

function FragmentShopPage:CanOpen(arg_2_1, arg_2_2)
	return pg.SystemOpenMgr.GetInstance():isOpenSystem(arg_2_2.level, "FragmentShop")
end

function FragmentShopPage:init()
	FragmentShopPage.super.init(self)
end

function FragmentShopPage:CustomInit()
	onButton(self, self.resolveBtn, function()
		if not self.resolvePanel then
			self.resolvePanel = FragResolvePanel.New(self)
			self.resolvePanel.event = self.event

			self.resolvePanel:Load()
		end

		self.resolvePanel.buffer:Reset()
		self.resolvePanel.buffer:Trigger("control")
	end, SFX_PANEL)
	getProxy(CommanderManualProxy):TaskProgressAdd(2023, 1)
end

function FragmentShopPage:OnUpdatePlayer()
	self:RefreshResItemList()
end

function FragmentShopPage:OnFragmentSellUpdate()
	if self.resolvePanel then
		self.resolvePanel.buffer:Reset()
		self.resolvePanel.buffer:Trigger("control")
	end
end

function FragmentShopPage:OnUpdateItems()
	self:RefreshResItemList()
end

function FragmentShopPage:GetResDataList()
	local var_9_0 = {}

	table.insert(var_9_0, Drop.New({
		count = 0,
		type = DROP_TYPE_RESOURCE,
		id = PlayerConst.ResBlueprintFragment
	}))

	if not LOCK_UR_SHIP then
		table.insert(var_9_0, Drop.New({
			count = 0,
			type = DROP_TYPE_ITEM,
			id = pg.gameset.urpt_chapter_max.description[1]
		}))
	end

	for iter_9_0, iter_9_1 in ipairs(var_9_0) do
		iter_9_1.count = iter_9_1:getOwnedCount()
	end

	return var_9_0
end

function FragmentShopPage:OnUpdateCommodity(arg_10_1)
	local var_10_0

	for iter_10_0, iter_10_1 in pairs(self.cards) do
		if iter_10_1.goodsVO.id == arg_10_1.id then
			var_10_0 = iter_10_1

			break
		end
	end

	if var_10_0 then
		var_10_0.goodsVO = arg_10_1

		ActivityGoodsCard.StaticUpdate(var_10_0.tf, arg_10_1, FragmentShopPage.TYPE_FRAGMENT)
	end
end

function FragmentShopPage:RefreshUI()
	self:UpdateTip()
	setActive(self.tipTextGo, true)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, true)
	setActive(self.refreshBtn, false)
end

function FragmentShopPage:OnInitItem(arg_12_1)
	local var_12_0 = ActivityGoodsCard.New(arg_12_1)

	onButton(self, var_12_0.tf, function()
		if not var_12_0.goodsVO:canPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

			return
		end

		self:OnClickCommodity(var_12_0.goodsVO, function(arg_14_0, arg_14_1)
			self:OnPurchase(arg_14_0, arg_14_1)
		end)
	end, SFX_PANEL)

	self.cards[arg_12_1] = var_12_0
end

function FragmentShopPage:OnUpdateItem(arg_15_1, arg_15_2)
	local var_15_0 = self.cards[arg_15_2]

	if not self.cards[arg_15_2] then
		self:OnInitItem(arg_15_2)

		var_15_0 = self.cards[arg_15_2]
	end

	var_15_0.goodsVO = self.displays[arg_15_1 + 1]

	ActivityGoodsCard.StaticUpdate(var_15_0.tf, self.displays[arg_15_1 + 1], FragmentShopPage.TYPE_FRAGMENT)
end

function FragmentShopPage:OnPurchase(arg_16_1, arg_16_2)
	self:emit(NewShopMainMediator.ON_FRAGMENT_SHOPPING, arg_16_1.id, arg_16_2)
end

function FragmentShopPage:OnDestroy()
	FragmentShopPage.super.OnDestroy(self)

	if self.resolvePanel then
		self.resolvePanel:Destroy()

		self.resolvePanel = nil
	end
end

return FragmentShopPage
