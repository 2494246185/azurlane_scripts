local HurricaneTreasureGiftPage = class("HurricaneTreasureGiftPage", import("view.activity.CorePage.CoreActivityPage"))

function HurricaneTreasureGiftPage:getResource(arg_1_1)
	local var_1_0 = {
		"ui/hurricanetreasuregiftpage_atlas"
	}

	table.insertto(var_1_0, HurricaneTreasureGiftPage.super.getResource(self, arg_1_1))

	return var_1_0
end

function HurricaneTreasureGiftPage:OnInit()
	self.bg = self._tf:Find("bg")
	self.itemListTF = self.bg:Find("scrollView/Viewport/Content")
	self.itemTpl = self.bg:Find("scrollView/Viewport/Content/tpl")
	self.uiList = UIItemList.New(self.itemListTF, self.itemTpl)

	self.uiList:make(function(arg_3_0, arg_3_1, arg_3_2)
		if arg_3_0 == UIItemList.EventUpdate then
			self:UpdateGiftItem(arg_3_1 + 1, arg_3_2)
		end
	end)
end

function HurricaneTreasureGiftPage:OnDataSetting()
	if not self.idLists then
		self.idLists = self.activity:getConfig("config_client").gifts

		assert(#self.idLists[1] == #self.idLists[2])
	end

	self.nday = math.min(#self.idLists[1], self.activity:getNDay())

	local var_4_0 = getProxy(ShopsProxy)

	self.dataList = {}

	for iter_4_0 = 1, #self.idLists[1] do
		local var_4_1 = var_4_0:GetGiftCommodity(self.idLists[1][iter_4_0], Goods.TYPE_CHARGE)
		local var_4_2 = var_4_0:GetGiftCommodity(self.idLists[2][iter_4_0], Goods.TYPE_GIFT_PACKAGE)

		var_4_1.dayIdx = iter_4_0
		var_4_2.dayIdx = iter_4_0

		table.insert(self.dataList, var_4_1)
		table.insert(self.dataList, var_4_2)
	end

	table.sort(self.dataList, function(arg_5_0, arg_5_1)
		local function var_5_0(arg_6_0)
			if not arg_6_0:canPurchase() then
				return 1
			elseif arg_6_0.dayIdx > self.nday then
				return 2
			elseif arg_6_0.dayIdx == self.nday then
				return 4
			else
				return 3
			end
		end

		local var_5_1 = var_5_0(arg_5_0)
		local var_5_2 = var_5_0(arg_5_1)

		if var_5_1 ~= var_5_2 then
			return var_5_2 < var_5_1
		end

		if var_5_1 == 3 and var_5_2 == 3 and arg_5_0.dayIdx ~= arg_5_1.dayIdx then
			return arg_5_0.dayIdx > arg_5_1.dayIdx
		end

		if arg_5_0.dayIdx ~= arg_5_1.dayIdx then
			return arg_5_0.dayIdx < arg_5_1.dayIdx
		end

		local var_5_3 = arg_5_0:isChargeType() and 0 or 1
		local var_5_4 = arg_5_1:isChargeType() and 0 or 1

		if var_5_3 ~= var_5_4 then
			return var_5_4 < var_5_3
		end

		if arg_5_0.id ~= arg_5_1.id then
			return arg_5_0.id < arg_5_1.id
		end

		return arg_5_0.type < arg_5_1.type
	end)
end

function HurricaneTreasureGiftPage:OnUpdateFlush()
	self.uiList:align(#self.dataList)
end

function HurricaneTreasureGiftPage:UpdateGiftItem(arg_8_1, arg_8_2)
	local var_8_0 = self.dataList[arg_8_1]
	local var_8_1 = self:getCommodityData(self.dataList[arg_8_1])
	local var_8_2 = self.dataList[arg_8_1].dayIdx
	local var_8_3 = var_8_1.isFree and var_8_1.price == 0
	local var_8_4 = arg_8_2:Find("limit/text")
	local var_8_5 = arg_8_2:Find("lock")
	local var_8_6 = arg_8_2:Find("lock/day")
	local var_8_7 = arg_8_2:Find("lock/hour")
	local var_8_8 = arg_8_2:Find("btnGet")
	local var_8_9 = arg_8_2:Find("btnBuy")
	local var_8_10 = arg_8_2:Find("got")

	UIItemList.StaticAlign(arg_8_2:Find("awards"), arg_8_2:Find("awards/item"), #var_8_1.items, function(arg_9_0, arg_9_1, arg_9_2)
		if arg_9_0 == UIItemList.EventUpdate then
			local var_9_0 = var_8_1.items[arg_9_1 + 1]

			updateDrop(arg_9_2, var_8_1.items[arg_9_1 + 1])
			onButton(self, arg_9_2, function()
				self:emit(BaseUI.ON_DROP, var_9_0)
			end, SFX_PANEL)
		end
	end)
	setText(var_8_4, var_8_1.count)
	GetImageSpriteFromAtlasAsync("ui/hurricanetreasuregiftpage_atlas", string.format("tpl_title_%s_%d", var_8_3 and "free" or "day", var_8_2), arg_8_2:Find("title"))
	LoadSpriteAsync(var_8_3 and "chargeicon/fengfanv4_free" or "chargeicon/" .. var_8_0:getConfig("picture"), function(arg_11_0)
		local var_11_0 = arg_8_2:Find("icon")

		if arg_11_0 and not IsNil(var_11_0) then
			setImageSprite(var_11_0, arg_11_0, true)
		end
	end)

	local var_8_11 = var_8_0:canPurchase()

	setActive(var_8_8, var_8_11 and var_8_3)
	setActive(var_8_9, var_8_11 and not var_8_3)
	setActive(var_8_10, not var_8_11)

	local var_8_12 = var_8_2 <= self.nday
	local var_8_13 = pg.TimeMgr.GetInstance():STimeDescC(var_8_0:getTimeStamp(), "*t")

	setActive(var_8_5, not (var_8_2 <= self.nday))
	setText(var_8_6, var_8_13.day)
	setText(var_8_7, var_8_13.hour)
	onButton(self, var_8_3 and var_8_8 or var_8_9, function()
		if not var_8_12 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("blackfriday_pack_lock", (pg.TimeMgr.GetInstance():STimeDescC(var_8_0:getTimeStamp(), "%m.%d"))))
		elseif not var_8_0:canPurchase() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("buy_countLimit"))
		else
			self:OnCharge(var_8_0)
		end
	end, SFX_PANEL)
end

function HurricaneTreasureGiftPage:getCommodityData(arg_13_1)
	local var_13_0

	if arg_13_1:isChargeType() then
		local var_13_1 = {
			isFree = false,
			name = arg_13_1:getConfig("name_display"),
			price = arg_13_1:getConfig("money"),
			count = arg_13_1:GetLimitDesc(),
			desc = arg_13_1:getConfig("descrip"),
			free = i18n("shop_free_tag"),
			purchased = i18n("blackfriday_pack_purchased"),
			icon = "ChargeIcon/" .. arg_13_1:getConfig("picture")
		}

		var_13_1.items = underscore(arg_13_1:getConfig("display")):chain():first(3):map(function(arg_14_0)
			local var_14_0 = {}

			var_14_0.type, var_14_0.id, var_14_0.count = unpack(arg_14_0)

			return {}
		end):value()
		var_13_0 = var_13_1
	else
		local var_13_2 = Item.getConfigData(arg_13_1:getConfig("effect_args")[1])
		local var_13_3 = {
			isFree = true,
			name = var_13_2.name,
			price = arg_13_1:getConfig("resource_num"),
			count = arg_13_1:GetLimitDesc(),
			desc = var_13_2.display,
			free = i18n("shop_free_tag"),
			purchased = i18n("blackfriday_pack_purchased"),
			icon = var_13_2.icon
		}

		var_13_3.items = underscore(var_13_2.display_icon):chain():first(3):map(function(arg_15_0)
			local var_15_0 = {}

			var_15_0.type, var_15_0.id, var_15_0.count = unpack(arg_15_0)

			return {}
		end):value()
		var_13_0 = var_13_3
	end

	return var_13_0
end

function HurricaneTreasureGiftPage:OnCharge(arg_16_1)
	if arg_16_1:isChargeType() then
		local var_16_0 = {
			isChargeType = true,
			commodity = arg_16_1,
			infoTip = arg_16_1:GetInfoTip(),
			icon = "chargeicon/" .. arg_16_1:getConfig("picture"),
			name = arg_16_1:getConfig("name_display"),
			tipExtra = i18n("charge_title_getitem"),
			extraItems = arg_16_1:GetExtraServiceItem(),
			price = arg_16_1:getConfig("money"),
			isLocalPrice = arg_16_1:IsLocalPrice(),
			tagType = arg_16_1:getConfig("tag"),
			isMonthCard = arg_16_1:isMonthCard()
		}

		var_16_0.tipBonus = nil
		var_16_0.bonusItem = nil
		var_16_0.extraDrop = nil
		var_16_0.descExtra = arg_16_1:getConfig("descrip_extra")
		var_16_0.limitArgs = arg_16_1:getConfig("limit_args")

		function var_16_0.onYes()
			if ChargeConst.isNeedSetBirth() then
				self:emit(ActivityMediator.OPEN_CHARGE_BIRTHDAY)
			else
				self:emit(ActivityMediator.CHARGE, arg_16_1.id)
			end
		end

		self:emit(ActivityMediator.OPEN_CHARGE_ITEM_PANEL, var_16_0)
	else
		local var_16_1 = {}
		local var_16_2 = Item.getConfigData(arg_16_1:getConfig("effect_args")[1])

		if type(var_16_2.display_icon) == "table" then
			for iter_16_0, iter_16_1 in ipairs(var_16_2.display_icon) do
				table.insert(var_16_1, Drop.New({
					type = iter_16_1[1],
					id = iter_16_1[2],
					count = iter_16_1[3]
				}))
			end
		end

		self:emit(ActivityMediator.OPEN_CHARGE_ITEM_PANEL, {
			isLocalPrice = false,
			isChargeType = false,
			isMonthCard = false,
			commodity = arg_16_1,
			icon = var_16_2.icon,
			name = var_16_2.name,
			tipExtra = i18n("charge_title_getitem"),
			extraItems = var_16_1,
			price = arg_16_1:getConfig("resource_num"),
			tagType = arg_16_1:getConfig("tag"),
			onYes = function()
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("charge_scene_buy_confirm", arg_16_1:getConfig("resource_num"), var_16_2.name),
					onYes = function()
						self:emit(ActivityMediator.BUY_ITEM, arg_16_1.id, 1)
					end
				})
			end
		})
	end
end

function HurricaneTreasureGiftPage:OnDestroy()
	return
end

return HurricaneTreasureGiftPage
