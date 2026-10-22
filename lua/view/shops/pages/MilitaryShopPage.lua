local MilitaryShopPage = class("MilitaryShopPage", import(".BaseShopPage"))

function MilitaryShopPage:GetPaintingCommodityUpdateVoice()
	return
end

function MilitaryShopPage:CanOpen(arg_2_1, arg_2_2)
	return pg.SystemOpenMgr.GetInstance():isOpenSystem(arg_2_2.level, "MilitaryExerciseMediator")
end

function MilitaryShopPage:OnUpdatePlayer()
	self:RefreshResItemList()
end

function MilitaryShopPage:GetResDataList()
	return self.shop:GetResList()
end

function MilitaryShopPage:OnSetUp()
	self:RemoveTimer()
	self:AddTimer()
end

function MilitaryShopPage:Hide()
	MilitaryShopPage.super.Hide(self)
	self:RemoveTimer()
end

function MilitaryShopPage:OnUpdateAll()
	self:InitCommodities()
	self:OnSetUp()
end

function MilitaryShopPage:OnUpdateCommodity(arg_8_1)
	local var_8_0

	for iter_8_0, iter_8_1 in pairs(self.cards) do
		if iter_8_1.goodsVO.id == arg_8_1.id then
			var_8_0 = iter_8_1

			break
		end
	end

	if var_8_0 then
		var_8_0:update(arg_8_1)
	end
end

function MilitaryShopPage:RefreshUI()
	setActive(self.tipTextGo, false)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, false)
	setActive(self.refreshBtn, true)

	local var_9_0 = pg.arena_data_shop[1]

	onButton(self, self.refreshBtn, function()
		if self.shop.refreshCount - 1 >= #var_9_0.refresh_price then
			pg.TipsMgr.GetInstance():ShowTips(i18n("shopStreet_refresh_max_count"))

			return
		end

		local var_10_0 = var_9_0.refresh_price[self.shop.refreshCount] or var_9_0.refresh_price[#var_9_0.refresh_price]

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("refresh_shopStreet_question", i18n("word_gem_icon"), var_10_0, self.shop.refreshCount - 1),
			onYes = function()
				if self.player:getTotalGem() < var_10_0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_no_resource"))

					return
				else
					self:emit(NewShopMainMediator.REFRESH_MILITARY_SHOP, true)
				end
			end
		})
	end, SFX_PANEL)
	setButtonEnabled(self.refreshBtn, true)
end

function MilitaryShopPage:OnInitItem(arg_12_1)
	local var_12_0 = GoodsCard.New(arg_12_1)

	onButton(self, var_12_0.go, function()
		if not var_12_0.goodsVO:canPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

			return
		end

		self:OnClickCommodity(var_12_0.goodsVO)
	end, SFX_PANEL)

	self.cards[arg_12_1] = var_12_0
end

function MilitaryShopPage:OnUpdateItem(arg_14_1, arg_14_2)
	if not self.cards[arg_14_2] then
		self:OnInitItem(arg_14_2)
	end

	self.cards[arg_14_2]:update(self.displays[arg_14_1 + 1])
end

function MilitaryShopPage:OnClickCommodity(arg_15_1)
	local var_15_0 = arg_15_1

	pg.MsgboxMgr.GetInstance():ShowMsgBox({
		yesText = "text_exchange",
		type = MSGBOX_TYPE_SINGLE_ITEM,
		drop = {
			id = arg_15_1:getConfig("effect_args")[1],
			type = arg_15_1:getConfig("type")
		},
		onYes = function()
			self:emit(NewShopMainMediator.BUY_ITEM, var_15_0.id, 1)
		end
	})
end

function MilitaryShopPage:AddTimer()
	local var_17_0 = self.shop.nextTime + 1

	self.timer = Timer.New(function()
		local var_18_0 = var_17_0 - pg.TimeMgr.GetInstance():GetServerTime()

		if var_18_0 <= 0 then
			self:RemoveTimer()
			self:OnTimeOut()
		else
			self.timerText.text = i18n("shop_refresh_time", (pg.TimeMgr.GetInstance():DescCDTime(var_18_0)))
		end
	end, 1, -1)

	self.timer:Start()
	self.timer.func()
end

function MilitaryShopPage:OnTimeOut()
	self:emit(NewShopMainMediator.REFRESH_MILITARY_SHOP)
end

function MilitaryShopPage:RemoveTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function MilitaryShopPage:OnDestroy()
	MilitaryShopPage.super.OnDestroy(self)
	self:RemoveTimer()
end

return MilitaryShopPage
