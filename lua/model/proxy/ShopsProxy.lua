local ShopsProxy = class("ShopsProxy", import(".NetProxy"))

ShopsProxy.MERITOROUS_SHOP_UPDATED = "ShopsProxy:MERITOROUS_SHOP_UPDATED"
ShopsProxy.SHOPPINGSTREET_UPDATE = "ShopsProxy:SHOPPINGSTREET_UPDATE"
ShopsProxy.FIRST_CHARGE_IDS_UPDATED = "ShopsProxy:FIRST_CHARGE_IDS_UPDATED"
ShopsProxy.CHARGED_LIST_UPDATED = "ShopsProxy:CHARGED_LIST_UPDATED"
ShopsProxy.NORMAL_LIST_UPDATED = "ShopsProxy:NORMAL_LIST_UPDATED"
ShopsProxy.NORMAL_GROUP_LIST_UPDATED = "ShopsProxy:NORMAL_GROUP_LIST_UPDATED"
ShopsProxy.ACTIVITY_SHOP_UPDATED = "ShopsProxy:ACTIVITY_SHOP_UPDATED"
ShopsProxy.GUILD_SHOP_ADDED = "ShopsProxy:GUILD_SHOP_ADDED"
ShopsProxy.GUILD_SHOP_UPDATED = "ShopsProxy:GUILD_SHOP_UPDATED"
ShopsProxy.SHAM_SHOP_UPDATED = "ShopsProxy:SHAM_SHOP_UPDATED"
ShopsProxy.FRAGMENT_SHOP_UPDATED = "ShopsProxy:FRAGMENT_SHOP_UPDATED"
ShopsProxy.ACTIVITY_SHOP_GOODS_UPDATED = "ShopsProxy:ACTIVITY_SHOP_GOODS_UPDATED"
ShopsProxy.META_SHOP_GOODS_UPDATED = "ShopsProxy:META_SHOP_GOODS_UPDATED"
ShopsProxy.MEDAL_SHOP_UPDATED = "ShopsProxy:MEDAL_SHOP_UPDATED"
ShopsProxy.QUOTA_SHOP_UPDATED = "ShopsProxy:QUOTA_SHOP_UPDATED"
ShopsProxy.CRUISE_SHOP_UPDATED = "ShopsProxy:CRUISE_SHOP_UPDATED"

function ShopsProxy:register()
	self.shopStreet = nil
	self.meritorousShop = nil
	self.guildShop = nil
	self.refreshChargeList = false
	self.metaShop = nil
	self.miniShop = nil

	self:on(22102, function(arg_2_0)
		getProxy(ShopsProxy):setShopStreet((ShoppingStreet.New(arg_2_0.street)))
	end)

	self.shamShop = ShamBattleShop.New()
	self.fragmentShop = FragmentShop.New()

	self:on(16200, function(arg_3_0)
		self.shamShop:update(arg_3_0.month, arg_3_0.core_shop_list)
		self.fragmentShop:update(arg_3_0.month, arg_3_0.blue_shop_list, arg_3_0.normal_shop_list)
	end)

	self.timers = {}
	self.tradeNoPrev = ""
	self.freeGiftIdList = {}

	for iter_1_0, iter_1_1 in pairs(pg.shop_template.all) do
		if pg.shop_template[iter_1_1].genre == ShopArgs.GiftPackage and pg.shop_template[iter_1_1].discount == 100 then
			table.insert(self.freeGiftIdList, iter_1_1)
		end
	end

	self.newServerShopList = {}
	self.activityShops = {}
end

function ShopsProxy:timeCall()
	return {
		[ProxyRegister.DayCall] = function(arg_5_0, arg_5_1)
			local var_5_0 = self:getShopStreet()

			if var_5_0 then
				var_5_0:resetflashCount()
				self:setShopStreet(var_5_0)
			end

			self.refreshChargeList = true

			local var_5_1 = self:getMiniShop()

			if var_5_1 and var_5_1:checkShopFlash() then
				pg.m02:sendNotification(GAME.MINI_GAME_SHOP_FLUSH)
			end

			if arg_5_0 == 1 then
				self.shamShop:update(arg_5_1.month, {})
				self:AddShamShop(self.shamShop)
				self.fragmentShop:Reset(arg_5_1.month)
				self:AddFragmentShop(self.fragmentShop)

				if not LOCK_UR_SHIP then
					getProxy(BagProxy):ClearLimitCnt(pg.gameset.urpt_chapter_max.description[1])
				end
			end

			pg.m02:sendNotification(GAME.GET_CHARGE_LIST)
		end
	}
end

function ShopsProxy:setShopStreet(arg_6_1)
	self.shopStreet = arg_6_1

	self:sendNotification(ShopsProxy.SHOPPINGSTREET_UPDATE, {
		shopStreet = Clone(self.shopStreet)
	})
end

function ShopsProxy:UpdateShopStreet(arg_7_1)
	self.shopStreet = arg_7_1
end

function ShopsProxy:getShopStreet()
	return Clone(self.shopStreet)
end

function ShopsProxy:getMeritorousShop()
	return Clone(self.meritorousShop)
end

function ShopsProxy:addMeritorousShop(arg_10_1)
	self.meritorousShop = arg_10_1

	self:sendNotification(ShopsProxy.MERITOROUS_SHOP_UPDATED, Clone(arg_10_1))
end

function ShopsProxy:updateMeritorousShop(arg_11_1)
	self.meritorousShop = arg_11_1
end

function ShopsProxy:getMiniShop()
	return Clone(self.miniShop)
end

function ShopsProxy:setMiniShop(arg_13_1)
	self.miniShop = arg_13_1
end

function ShopsProxy:setNormalList(arg_14_1)
	self.normalList = arg_14_1 or {}
end

function ShopsProxy:GetNormalList()
	return Clone(self.normalList)
end

function ShopsProxy:GetNormalByID(arg_16_1)
	self.normalList = self.normalList or {}
	self.normalList[arg_16_1] = self.normalList[arg_16_1] or Goods.Create({
		buyCount = 0,
		id = arg_16_1
	}, Goods.TYPE_GIFT_PACKAGE)

	return self.normalList[arg_16_1]
end

function ShopsProxy:updateNormalByID(arg_17_1)
	self.normalList[arg_17_1.id] = arg_17_1
end

function ShopsProxy:checkHasFreeNormal()
	for iter_18_0, iter_18_1 in ipairs(self.freeGiftIdList) do
		if self:checkNormalCanPurchase(iter_18_1) then
			return true
		end
	end

	return false
end

function ShopsProxy:checkNormalCanPurchase(arg_19_1)
	if self.normalList[arg_19_1] ~= nil then
		if not self.normalList[arg_19_1]:inTime() then
			return false
		end

		local var_19_0 = self.normalList[arg_19_1]:getConfig("group") or 0

		if var_19_0 > 0 then
			local var_19_1 = self.normalList[arg_19_1]:getConfig("group_limit")

			return var_19_1 > 0 and self:getGroupLimit(var_19_0) < var_19_1
		elseif self.normalList[arg_19_1]:canPurchase() then
			return true
		end
	else
		return self:GetNormalByID(arg_19_1):inTime()
	end
end

function ShopsProxy:setNormalGroupList(arg_20_1)
	self.normalGroupList = arg_20_1
end

function ShopsProxy:GetNormalGroupList()
	return self.normalGroupList
end

function ShopsProxy:updateNormalGroupList(arg_22_1, arg_22_2)
	if arg_22_1 <= 0 then
		return
	end

	for iter_22_0, iter_22_1 in ipairs(self.normalGroupList) do
		if iter_22_1.shop_id == arg_22_1 then
			self.normalGroupList[iter_22_0].pay_count = (self.normalGroupList[iter_22_0].pay_count or 0) + arg_22_2

			return
		end
	end

	table.insert(self.normalGroupList, {
		shop_id = arg_22_1,
		pay_count = arg_22_2
	})
end

function ShopsProxy:getGroupLimit(arg_23_1)
	if not self.normalGroupList then
		return 0
	end

	for iter_23_0, iter_23_1 in ipairs(self.normalGroupList) do
		if iter_23_1.shop_id == arg_23_1 then
			return iter_23_1.pay_count
		end
	end

	return 0
end

function ShopsProxy:getActivityShopById(arg_24_1)
	if not self.activityShops[arg_24_1] then
		local var_24_0 = getProxy(ActivityProxy):getActivityById(arg_24_1)

		self.activityShops[arg_24_1] = var_24_0 and not var_24_0:isEnd() and ActivityShop.New(var_24_0)
	end

	return self.activityShops[arg_24_1]
end

function ShopsProxy:updateActivityShop(arg_25_1, arg_25_2)
	assert(self.activityShops, "activityShops can not be nil")

	self.activityShops[arg_25_1] = arg_25_2:sendselfNotification(ShopsProxy.ACTIVITY_SHOP_UPDATED, {
		activityId = arg_25_1,
		shop = arg_25_2:clone()
	})
end

function ShopsProxy:UpdateActivityGoods(arg_26_1, arg_26_2, arg_26_3)
	local var_26_0 = self:getActivityShopById(arg_26_1)

	var_26_0:getGoodsById(arg_26_2):addBuyCount(arg_26_3)

	self.activityShops[arg_26_1] = var_26_0

	self:sendNotification(ShopsProxy.ACTIVITY_SHOP_GOODS_UPDATED, {
		activityId = arg_26_1,
		goodsId = arg_26_2
	})
end

function ShopsProxy:setFirstChargeList(arg_27_1)
	self.firstChargeList = arg_27_1

	self:sendNotification(ShopsProxy.FIRST_CHARGE_IDS_UPDATED, Clone(arg_27_1))
end

function ShopsProxy:getFirstChargeList()
	return Clone(self.firstChargeList)
end

function ShopsProxy:setChargedList(arg_29_1)
	self.chargeList = arg_29_1

	self:sendNotification(ShopsProxy.CHARGED_LIST_UPDATED, Clone(arg_29_1))
end

function ShopsProxy:getChargedList()
	return Clone(self.chargeList)
end

local var_0_1 = 3
local var_0_2 = 10

function ShopsProxy:chargeFailed(arg_31_1, arg_31_2)
	if not self.timers[arg_31_1] then
		pg.UIMgr.GetInstance():LoadingOn()

		self.timers[arg_31_1] = Timer.New(function()
			if self.timers[arg_31_1].loop == 1 then
				pg.UIMgr.GetInstance():LoadingOff()
			end

			PaySuccess(arg_31_1, arg_31_2)
		end, var_0_1, var_0_2)

		self.timers[arg_31_1]:Start()
	end
end

function ShopsProxy:removeChargeTimer(arg_33_1)
	if self.timers[arg_33_1] then
		pg.UIMgr.GetInstance():LoadingOff()
		self.timers[arg_33_1]:Stop()

		self.timers[arg_33_1] = nil
	end
end

function ShopsProxy:addWaitTimer()
	pg.UIMgr.GetInstance():LoadingOn()

	self.waitBiliTimer = Timer.New(function()
		self:removeWaitTimer()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			hideNo = true,
			content = i18n("charge_time_out")
		})
	end, 25, 1)

	self.waitBiliTimer:Start()
end

function ShopsProxy:removeWaitTimer()
	if self.waitBiliTimer then
		pg.UIMgr.GetInstance():LoadingOff()
		self.waitBiliTimer:Stop()

		self.waitBiliTimer = nil
	end
end

function ShopsProxy:setGuildShop(arg_37_1)
	assert(isa(arg_37_1, GuildShop), "shop should instance of GuildShop")
	assert(self.guildShop == nil, "shop already exist")

	self.guildShop = arg_37_1

	self:sendNotification(ShopsProxy.GUILD_SHOP_ADDED, self.guildShop)
end

function ShopsProxy:getGuildShop()
	return self.guildShop
end

function ShopsProxy:updateGuildShop(arg_39_1, arg_39_2)
	assert(isa(arg_39_1, GuildShop), "shop should instance of GuildShop")
	assert(self.guildShop, "should exist shop")

	self.guildShop = arg_39_1

	self:sendNotification(ShopsProxy.GUILD_SHOP_UPDATED, {
		shop = self.guildShop,
		reset = arg_39_2
	})
end

function ShopsProxy:AddShamShop(arg_40_1)
	self.shamShop = arg_40_1

	self:sendNotification(ShopsProxy.SHAM_SHOP_UPDATED, arg_40_1)
end

function ShopsProxy:updateShamShop(arg_41_1)
	self.shamShop = arg_41_1
end

function ShopsProxy:getShamShop()
	return self.shamShop
end

function ShopsProxy:AddFragmentShop(arg_43_1)
	self.fragmentShop = arg_43_1

	self:sendNotification(ShopsProxy.FRAGMENT_SHOP_UPDATED, arg_43_1)
end

function ShopsProxy:updateFragmentShop(arg_44_1)
	self.fragmentShop = arg_44_1
end

function ShopsProxy:getFragmentShop()
	return self.fragmentShop
end

function ShopsProxy:AddMetaShop(arg_46_1)
	self.metaShop = arg_46_1
end

function ShopsProxy:GetMetaShop()
	return self.metaShop
end

function ShopsProxy:UpdateMetaShopGoods(arg_48_1, arg_48_2)
	self:GetMetaShop():getGoodsById(arg_48_1):addBuyCount(arg_48_2)
	self:sendNotification(ShopsProxy.META_SHOP_GOODS_UPDATED, {
		goodsId = arg_48_1
	})
end

function ShopsProxy:SetNewServerShop(arg_49_1, arg_49_2)
	self.newServerShopList[arg_49_1] = arg_49_2
end

function ShopsProxy:GetNewServerShop(arg_50_1)
	return self.newServerShopList[arg_50_1]
end

function ShopsProxy:SetMedalShop(arg_51_1)
	self.medalShop = arg_51_1
end

function ShopsProxy:UpdateMedalShop(arg_52_1)
	self.medalShop = arg_52_1

	self:sendNotification(ShopsProxy.MEDAL_SHOP_UPDATED, arg_52_1)
end

function ShopsProxy:GetMedalShop()
	return self.medalShop
end

function ShopsProxy:setQuotaShop(arg_54_1)
	self.quotaShop = arg_54_1
end

function ShopsProxy:getQuotaShop()
	return self.quotaShop
end

function ShopsProxy:updateQuotaShop(arg_56_1, arg_56_2)
	self.quotaShop = arg_56_1

	self:sendNotification(ShopsProxy.QUOTA_SHOP_UPDATED, {
		shop = self.quotaShop,
		reset = arg_56_2
	})
end

function ShopsProxy:SetCruiseShop(arg_57_1)
	self.cruiseShop = arg_57_1
end

function ShopsProxy:UpdateCruiseShop()
	self.cruiseShop = CruiseShop.New(self:GetNormalList(), self:GetNormalGroupList())

	self:sendNotification(ShopsProxy.CRUISE_SHOP_UPDATED, {
		shop = self.cruiseShop
	})
end

function ShopsProxy:GetCruiseShop()
	return self.cruiseShop
end

function ShopsProxy:remove()
	for iter_60_0, iter_60_1 in pairs(self.timers) do
		iter_60_1:Stop()
	end

	self.timers = nil

	self:removeWaitTimer()
end

function ShopsProxy:ShouldRefreshChargeList()
	return not self:getFirstChargeList() or not self:getChargedList() or not self:GetNormalList() or not self:GetNormalGroupList() or self.refreshChargeList
end

function ShopsProxy:GetRecommendCommodities()
	local var_62_0 = self:getChargedList()
	local var_62_1 = self:GetNormalList()
	local var_62_2 = self:GetNormalGroupList()

	if not var_62_0 or not var_62_1 or not var_62_2 then
		return {}
	end

	local var_62_3 = {}

	for iter_62_0, iter_62_1 in ipairs(pg.recommend_shop.all) do
		if pg.TimeMgr.GetInstance():inTime(pg.recommend_shop[iter_62_1].time) then
			local var_62_4 = RecommendCommodity.New({
				id = iter_62_1,
				chargedList = var_62_0,
				normalList = var_62_1,
				normalGroupList = var_62_2
			})

			if var_62_4:CanShow() then
				table.insert(var_62_3, var_62_4)
			end
		end
	end

	table.sort(var_62_3, function(arg_63_0, arg_63_1)
		return arg_63_0:GetOrder() < arg_63_1:GetOrder()
	end)

	return var_62_3
end

function ShopsProxy:GetGiftCommodity(arg_64_1, arg_64_2)
	local var_64_0 = Goods.Create({
		shop_id = arg_64_1
	}, arg_64_2)

	if var_64_0:isChargeType() then
		var_64_0:updateBuyCount((ChargeConst.getBuyCount(self.chargeList, var_64_0.id)))
	else
		var_64_0:updateBuyCount((ChargeConst.getBuyCount(self.normalList, var_64_0.id)))

		local var_64_1 = var_64_0:getConfig("group") or 0

		if var_64_1 > 0 then
			var_64_0:updateGroupCount((ChargeConst.getGroupLimit(self.normalGroupList, var_64_1)))
		end
	end

	return var_64_0
end

function ShopsProxy:GetGroupPayCount(arg_65_1)
	for iter_65_0, iter_65_1 in ipairs(self.normalGroupList) do
		if iter_65_1.shop_id == arg_65_1 then
			return self.normalGroupList[iter_65_0].pay_count or 0
		end
	end

	return 0
end

function ShopsProxy:SpecialBannerBlockCheck(arg_66_1)
	if not LOCK_SHOP_BANNER_US then
		return true
	end

	local var_66_0, var_66_1 = unpack(getGameset("levellimit_shopbanner"))

	return var_66_0 <= arg_66_1.level or self.name ~= "banner_big" or table.contains(var_66_1, self.id)
end

function ShopsProxy:GiftPackageRedDotTip(arg_67_1, arg_67_2)
	local var_67_0 = {}

	if self:ShouldRefreshChargeList() then
		table.insert(var_67_0, function(arg_68_0)
			pg.m02:sendNotification(GAME.GET_CHARGE_LIST, {
				callback = arg_68_0
			})
		end)
	end

	seriesAsync(var_67_0, function()
		local var_69_0 = underscore.any(self:GetAllShowGiftPackages(arg_67_2), function(arg_70_0)
			return arg_70_0:isTip()
		end)

		for iter_69_0, iter_69_1 in ipairs(arg_67_1) do
			setActive(iter_69_1, var_69_0)
		end
	end)
end

function ShopsProxy:GetAllShowGiftPackages(arg_71_1)
	assert(not self:ShouldRefreshChargeList())

	local var_71_0 = {}
	local var_71_1 = RefluxShopView.getAllRefluxPackID()
	local var_71_2 = getProxy(PlayerProxy):getRawData()

	for iter_71_0, iter_71_1 in pairs(pg.pay_data_display.all) do
		if not table.contains(var_71_1, iter_71_1) then
			local var_71_3 = pg.pay_data_display[iter_71_1].extra_service

			if (arg_71_1 == nil or pg.pay_data_display[iter_71_1].akashi_pick > 0 == arg_71_1) and (var_71_3 == Goods.ITEM_BOX or var_71_3 == Goods.PASS_ITEM) then
				local var_71_4 = Goods.Create({
					shop_id = iter_71_1
				}, Goods.TYPE_CHARGE)

				if self:filterLimitTypeGoods(var_71_4, var_71_2) and self:IsVaildBattlePass(var_71_4) then
					table.insert(var_71_0, var_71_4)
				end
			end
		end
	end

	for iter_71_2, iter_71_3 in ipairs(pg.shop_template.get_id_list_by_genre[ShopArgs.GiftPackage] or {}) do
		if (arg_71_1 == nil or ShopConst.GetShopConfig(iter_71_3).akashi_pick > 0 == arg_71_1) and not table.contains(var_71_1, iter_71_3) then
			table.insert(var_71_0, (Goods.Create({
				shop_id = iter_71_3
			}, Goods.TYPE_GIFT_PACKAGE)))
		end
	end

	for iter_71_4, iter_71_5 in ipairs(pg.shop_template.get_id_list_by_genre[ShopArgs.GiftActPackage] or {}) do
		if (arg_71_1 == nil or ShopConst.GetShopConfig(iter_71_5).akashi_pick > 0 == arg_71_1) and not table.contains(var_71_1, iter_71_5) then
			table.insert(var_71_0, (Goods.Create({
				shop_id = iter_71_5
			}, Goods.TYPE_GIFT_PACKAGE_ACT)))
		end
	end

	local var_71_5 = {}
	local var_71_6 = {}

	for iter_71_6, iter_71_7 in ipairs(var_71_0) do
		if iter_71_7:isChargeType() then
			iter_71_7:updateBuyCount((ChargeConst.getBuyCount(self.chargeList, iter_71_7.id)))

			if iter_71_7:canPurchase() and iter_71_7:inTime() then
				table.insert(var_71_5, iter_71_7)
			end
		elseif not iter_71_7:isLevelLimit(var_71_2.level, true) then
			iter_71_7:updateBuyCount((ChargeConst.getBuyCount(self.normalList, iter_71_7.id)))

			local var_71_7 = iter_71_7:getConfig("group") or 0
			local var_71_8 = false

			if var_71_7 > 0 then
				local var_71_9 = iter_71_7:getConfig("group_limit")
				local var_71_10 = ChargeConst.getGroupLimit(self.normalGroupList, var_71_7)

				iter_71_7:updateGroupCount(var_71_10)

				var_71_8 = var_71_9 > 0 and var_71_9 <= var_71_10
			end

			local var_71_11, var_71_12 = pg.TimeMgr.GetInstance():inTime(iter_71_7:getConfig("time"))

			if iter_71_7.id == 69999 then
				warning(PrintTable(iter_71_7:getConfig("time")), iter_71_7.__cname)
				warning(var_71_11, var_71_12, iter_71_7:canPurchase(), var_71_8)
			end

			if var_71_12 then
				table.insert(var_71_6, iter_71_7)
			end

			if var_71_11 and iter_71_7:canPurchase() and not var_71_8 then
				table.insert(var_71_5, iter_71_7)
			end
		end
	end

	return var_71_5, var_71_6
end

function ShopsProxy:IsVaildBattlePass(arg_72_1)
	if not arg_72_1:isPassItem() then
		return true
	end

	local var_72_0 = arg_72_1:getConfig("sub_display")[1]
	local var_72_1 = getProxy(ActivityProxy):RawGetActivityById(var_72_0)

	if var_72_1 and not var_72_1:isEnd() then
		return true
	end

	local var_72_2, var_72_3 = PrevPeriodCrusingActivity.StaticExistPrevPeriodCrusingActivity()

	if var_72_2 and var_72_0 == var_72_3 then
		return true
	end

	return false
end

function ShopsProxy:filterLimitTypeGoods(arg_73_1, arg_73_2)
	return switch(arg_73_1:getConfig("limit_type"), {
		[3] = function()
			if arg_73_1:getConfig("limit_arg") ~= 0 or arg_73_1:isLevelLimit(arg_73_2.level, true) then
				return false
			end

			local var_74_0

			for iter_74_0, iter_74_1 in ipairs(arg_73_1:getSameLimitGroupTecGoods()) do
				local var_74_1

				if iter_74_1:getConfig("limit_arg") == 1 then
					var_74_1 = iter_74_1
				elseif iter_74_1:getConfig("limit_arg") == 2 then
					var_74_0 = iter_74_1
				elseif iter_74_1:getConfig("limit_arg") == 3 then
					-- block empty
				end
			end

			if ChargeConst.getBuyCount(self.chargeList, (nil).id) > 0 then
				return false
			elseif ChargeConst.getBuyCount(self.chargeList, var_74_0.id) > 0 and ChargeConst.getBuyCount(self.chargeList, (nil).id) > 0 then
				return false
			else
				return true
			end
		end,
		[5] = function()
			if arg_73_1:getConfig("limit_arg") ~= 0 or arg_73_1:isLevelLimit(arg_73_2.level, true) then
				return false
			end

			for iter_75_0, iter_75_1 in ipairs(arg_73_1:getSameLimitGroupTecGoods()) do
				if iter_75_1:getConfig("limit_arg") ~= 0 and ChargeConst.getBuyCount(self.chargeList, iter_75_1.id) > 0 then
					return false
				end
			end

			return true
		end
	}, function()
		return true
	end)
end

function ShopsProxy:CanPurchasedByCharge(arg_77_1)
	for iter_77_0, iter_77_1 in ipairs(pg.pay_data_display.get_id_list_by_extra_service[Goods.NON_MAIL] or {}) do
		for iter_77_2, iter_77_3 in ipairs((type(pg.pay_data_display[iter_77_1].extra_service_item) == "string" or nil) and {}) do
			if iter_77_3[1] == DROP_TYPE_SKIN and iter_77_3[2] == arg_77_1 then
				return true, iter_77_1
			end
		end
	end

	return false
end

function ShopsProxy:IsSkinTypeCharge(arg_78_1)
	assert(pg.pay_data_display[arg_78_1], "pay_data_display" .. arg_78_1)

	for iter_78_0, iter_78_1 in ipairs((type(pg.pay_data_display[arg_78_1].extra_service_item) == "string" or nil) and {}) do
		if iter_78_1[1] == DROP_TYPE_SKIN then
			return true, iter_78_1[2]
		end
	end

	return false
end

return ShopsProxy
