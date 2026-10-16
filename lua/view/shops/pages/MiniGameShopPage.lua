local MiniGameShopPage = class("MiniGameShopPage", import(".BaseShopPage"))

function MiniGameShopPage:CanOpen(arg_1_1, arg_1_2)
	return pg.SystemOpenMgr.GetInstance():isOpenSystem(arg_1_2.level, "GameHallMediator")
end

function MiniGameShopPage:CustomInit()
	self.purchaseWindow = MiniGameShopPurchasePanel.New(self._tf, self.event)
	self.multiWindow = MiniGameShopMultiWindow.New(self._tf, self.event)
end

function MiniGameShopPage:OnSetUp()
	self:RefreshResItemList()
	self:RemoveTimer()
	self:AddTimer()
end

function MiniGameShopPage:Hide()
	MiniGameShopPage.super.Hide(self)
	self:RemoveTimer()
end

function MiniGameShopPage:GetResDataList()
	return self.shop:GetResList()
end

function MiniGameShopPage:OnUpdateAll()
	self:InitCommodities()
	self:OnSetUp()

	if self.purchaseWindow:isShowing() then
		self.purchaseWindow:ExecuteAction("Hide")
	end

	if self.multiWindow:isShowing() then
		self.multiWindow:ExecuteAction("Hide")
	end
end

function MiniGameShopPage:OnUpdateCommodity(arg_7_1)
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

function MiniGameShopPage:RefreshUI()
	setActive(self.tipTextGo, true)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, false)
	setActive(self.refreshBtn, false)
	setText(self.tipText, i18n("game_ticket_current_month") .. getProxy(GameRoomProxy):getMonthlyTicket() .. "/" .. pg.gameset.game_ticket_month.key_value)
end

function MiniGameShopPage:OnInitItem(arg_9_1)
	local var_9_0 = MiniGameGoodsCard.New(arg_9_1)

	onButton(self, var_9_0.go, function()
		if not var_9_0.goodsVO:CanPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

			return
		end

		self:OnClickCommodity(var_9_0.goodsVO)
	end, SFX_PANEL)

	self.cards[arg_9_1] = var_9_0
end

function MiniGameShopPage:OnUpdateItem(arg_11_1, arg_11_2)
	if not self.cards[arg_11_2] then
		self:OnInitItem(arg_11_2)
	end

	self.cards[arg_11_2]:update(self.displays[arg_11_1 + 1])
end

function MiniGameShopPage:OnClickCommodity(arg_12_1)
	local var_12_0 = arg_12_1

	if arg_12_1:Selectable() then
		self.purchaseWindow:ExecuteAction("Show", {
			id = arg_12_1.id,
			count = arg_12_1:GetMaxCnt(),
			type = arg_12_1:getConfig("type"),
			price = arg_12_1:getConfig("price"),
			displays = arg_12_1:getConfig("goods"),
			num = arg_12_1:getConfig("num"),
			confirm = function(arg_13_0, arg_13_1)
				self:emit(NewShopMainMediator.ON_MINI_GAME_SHOP_BUY, {
					id = arg_13_0,
					list = arg_13_1
				})
			end
		})
	elseif arg_12_1:getConfig("goods_type") == 1 then
		if arg_12_1:GetLimit() > 1 then
			self.multiWindow:ExecuteAction("Show", arg_12_1, function(arg_14_0)
				if not var_12_0:CanPurchaseCnt(arg_14_0) then
					pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

					return
				end

				local var_14_0 = {}

				table.insert(var_14_0, {
					num = arg_14_0,
					id = var_12_0:getConfig("goods")[1]
				})
				self:emit(NewShopMainMediator.ON_MINI_GAME_SHOP_BUY, {
					id = var_12_0.id,
					list = var_14_0
				})
			end)
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				yesText = "text_exchange",
				content = i18n("guild_shop_exchange_tip"),
				onYes = function()
					if not var_12_0:CanPurchase() then
						pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))

						return
					end

					local var_15_0 = {}
					local var_15_1 = var_12_0:GetFirstDropId()

					for iter_15_0 = 1, #var_15_1 do
						table.insert(var_15_0, {
							num = 1,
							id = var_15_1[iter_15_0]
						})
					end

					self:emit(NewShopMainMediator.ON_MINI_GAME_SHOP_BUY, {
						id = var_12_0.id,
						list = var_15_0
					})
				end
			})
		end
	end
end

function MiniGameShopPage:AddTimer()
	self.timer = Timer.New(function()
		local var_17_0 = tonumber(os.date("%d", pg.TimeMgr.GetInstance():GetServerTime()))

		if not self.flush and self.day and self.day == var_17_0 then
			self:emit(NewShopMainMediator.ON_MINI_GAME_SHOP_FLUSH)

			self.flush = true
		end

		self.day = var_17_0
	end, 1, -1)

	self.timer:Start()
end

function MiniGameShopPage:RemoveTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function MiniGameShopPage:OnDestroy()
	if self.purchaseWindow:isShowing() then
		self.purchaseWindow:ExecuteAction("Hide")
	end

	if self.multiWindow:isShowing() then
		self.multiWindow:ExecuteAction("Hide")
	end

	self:RemoveTimer()
	MiniGameShopPage.super.OnDestroy(self)
end

return MiniGameShopPage
