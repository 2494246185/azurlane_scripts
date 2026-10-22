local NewRecommendationShopLayer = class("NewRecommendationShopLayer", import("...base.BaseUI"))

NewRecommendationShopLayer.ACT_REMASTER_BANNER_ID = -1

local var_0_1 = pg.shop_banner_template

function NewRecommendationShopLayer:getUIName()
	return "NewRecommendationShopUI"
end

function NewRecommendationShopLayer:getGroupName()
	return "NewShopMainScene"
end

function NewRecommendationShopLayer:getResource()
	local var_3_0 = pg.TimeMgr.GetInstance()
	local var_3_1 = getProxy(ShopsProxy):getChargedList()
	local var_3_2 = getProxy(ShopsProxy)
	local var_3_3 = var_3_2:GetNormalList()
	local var_3_4 = getProxy(ShopsProxy):GetNormalGroupList()
	local var_3_5 = getProxy(PlayerProxy).getRawData(var_3_2)
	local var_3_6 = {
		{},
		{},
		{}
	}

	for iter_3_0, iter_3_1 in ipairs(var_0_1.all) do
		if var_3_0:inTime(var_0_1[iter_3_1].time) and var_0_1[iter_3_1].relation_param ~= "" then
			local var_3_7 = var_0_1[iter_3_1].relation_param[1]
			local var_3_8 = var_0_1[iter_3_1].relation_param[2]
			local var_3_9

			if var_0_1[iter_3_1].relation_param[1] == 1 then
				var_3_9 = Goods.Create({
					id = var_3_8
				}, Goods.TYPE_CHARGE)

				var_3_9:updateBuyCount(ChargeConst.getBuyCount(var_3_1, var_3_8))
			elseif var_3_7 == 2 then
				var_3_9 = Goods.Create({
					id = var_3_8
				}, Goods.TYPE_GIFT_PACKAGE)

				var_3_9:updateBuyCount(ChargeConst.getBuyCount(var_3_3, var_3_8))
				var_3_9:updateGroupCount(ChargeConst.getGroupLimit(var_3_4, var_3_9:getConfig("group") or 0))
			elseif var_3_7 == 3 then
				var_3_9 = Goods.Create({
					id = var_3_8
				}, Goods.TYPE_SKIN)

				var_3_9:updateBuyCount(ChargeConst.getBuyCount(var_3_3, var_3_8))
				var_3_9:updateGroupCount(ChargeConst.getGroupLimit(var_3_4, var_3_9:getConfig("group") or 0))
			end

			var_3_6[var_3_7][var_3_8] = var_3_9
		end
	end

	local var_3_10 = {}
	local var_3_11 = {}
	local var_3_12 = Clone(var_0_1.get_id_list_by_name)

	var_3_12.banner_big = underscore.filter(var_3_12.banner_big, function(arg_4_0)
		return ShopsProxy.SpecialBannerBlockCheck(var_0_1[arg_4_0], var_3_5)
	end)

	for iter_3_2, iter_3_3 in pairs(var_3_12) do
		table.sort(iter_3_3, CompareFuncs({
			function(arg_5_0)
				return -var_0_1[arg_5_0].order
			end,
			function(arg_6_0)
				return arg_6_0
			end
		}))

		for iter_3_4 = #iter_3_3, 1, -1 do
			if not var_3_0:inTime(var_0_1[iter_3_3[iter_3_4]].time) then
				table.remove(iter_3_3, iter_3_4)
			elseif var_0_1[iter_3_3[iter_3_4]].relation_param ~= "" then
				if var_0_1[iter_3_3[iter_3_4]].relation_param[1] == 1 then
					if not var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]] or not var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]]:inTime() or not var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]]:canPurchase() then
						table.remove(iter_3_3, iter_3_4)
					end
				elseif (var_0_1[iter_3_3[iter_3_4]].relation_param[1] == 2 or var_0_1[iter_3_3[iter_3_4]].relation_param[1] == 3) and (not var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]] or not var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]]:inTime() or not var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]]:canPurchase() or var_3_6[var_0_1[iter_3_3[iter_3_4]].relation_param[1]][var_0_1[iter_3_3[iter_3_4]].relation_param[2]]:IsGroupLimit()) then
					table.remove(iter_3_3, iter_3_4)
				end
			end
		end

		if #iter_3_3 > 1 then
			table.remove(iter_3_3, #iter_3_3)
		end

		if pg.gameset.shop_banner_capacity.key_value < #iter_3_3 then
			for iter_3_5 = #iter_3_3, pg.gameset.shop_banner_capacity.key_value + 1, -1 do
				table.remove(iter_3_3, iter_3_5)
			end
		end

		for iter_3_6, iter_3_7 in ipairs(iter_3_3) do
			if noEmptyStr(var_0_1[iter_3_7].pic) then
				table.insert(var_3_10, var_0_1[iter_3_7].pic)
			end

			if var_0_1[iter_3_7].relation_param ~= "" then
				if var_0_1[iter_3_7].relation_param[1] == 1 and var_3_6[var_0_1[iter_3_7].relation_param[1]][var_0_1[iter_3_7].relation_param[2]] then
					local var_3_13 = var_3_6[var_0_1[iter_3_7].relation_param[1]][var_0_1[iter_3_7].relation_param[2]]:getConfig("picture")

					if noEmptyStr(var_3_13) then
						table.insert(var_3_11, ResPathSupport.CombinePath("chargeicon", var_3_13))
					end
				end
			end
		end
	end

	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(NewRecommendationShopLayer.super.getResource(self), {
		"ui/NewRecommendationShopUI"
	}, var_3_10, var_3_11))
end

function NewRecommendationShopLayer:init()
	self.resources = self._tf:Find("adapt/top/resources")
	self.banners = {}
	self.banners.banner_big = BannerScrollRectDorm3dShop.New(self._tf:Find("panel/banner_big/banner/mask/content"), self._tf:Find("panel/banner_big/banner/dots"))
	self.banners.banner_middle = BannerScrollRectDorm3dShop.New(self._tf:Find("panel/banner_middle/banner/mask/content"), self._tf:Find("panel/banner_middle/banner/dots"))
	self.banners.banner_small1 = BannerScrollRectDorm3dShop.New(self._tf:Find("panel/banner_small1/banner/mask/content"), self._tf:Find("panel/banner_small1/banner/dots"))
	self.banners.banner_small2 = BannerScrollRectDorm3dShop.New(self._tf:Find("panel/banner_small2/banner/mask/content"), self._tf:Find("panel/banner_small2/banner/dots"))
	self.banners.banner_small3 = BannerScrollRectDorm3dShop.New(self._tf:Find("panel/banner_small3/banner/mask/content"), self._tf:Find("panel/banner_small3/banner/dots"))

	setText(self._tf:Find("panel/banner_big/banner/mask/content/item/time/remainTime"), i18n("shop_new_during_time"))
	setText(self._tf:Find("panel/banner_small2/banner/mask/content/item/monthCard/day"), i18n("shop_new_daily"))
	setText(self._tf:Find("panel/banner_middle/banner/mask/content/item/detail/buy/Text"), i18n("shop_new_purchase"))
	setText(self._tf:Find("panel/banner_small1/banner/mask/content/item/detail/buy/Text"), i18n("shop_new_purchase"))
	setText(self._tf:Find("panel/banner_small2/banner/mask/content/item/detail/buy/Text"), i18n("shop_new_purchase"))
	setText(self._tf:Find("panel/banner_small2/banner/mask/content/item/monthCard/buy/Text"), i18n("shop_new_purchase"))
	setText(self._tf:Find("panel/banner_small3/banner/mask/content/item/detail/buy/Text"), i18n("shop_new_purchase"))
end

function NewRecommendationShopLayer:didEnter()
	self:InitData()
	self:ShowResUI()
	self:SetPanel()
	self:OverlayPanel(self._tf)
end

function NewRecommendationShopLayer:InitData()
	self.shopsProxy = getProxy(ShopsProxy)

	local var_9_0 = self.shopsProxy:getChargedList()
	local var_9_1 = self.shopsProxy:GetNormalList()
	local var_9_2 = self.shopsProxy:GetNormalGroupList()

	self.commodities = {
		{},
		{},
		{}
	}

	for iter_9_0, iter_9_1 in ipairs(var_0_1.all) do
		if pg.TimeMgr.GetInstance():inTime(var_0_1[iter_9_1].time) and var_0_1[iter_9_1].relation_param ~= "" then
			local var_9_3 = var_0_1[iter_9_1].relation_param[1]
			local var_9_4 = var_0_1[iter_9_1].relation_param[2]
			local var_9_5

			if var_0_1[iter_9_1].relation_param[1] == 1 then
				var_9_5 = Goods.Create({
					id = var_9_4
				}, Goods.TYPE_CHARGE)

				var_9_5:updateBuyCount((ChargeConst.getBuyCount(var_9_0, var_9_4)))
			elseif var_9_3 == 2 then
				var_9_5 = Goods.Create({
					id = var_9_4
				}, Goods.TYPE_GIFT_PACKAGE)

				var_9_5:updateBuyCount((ChargeConst.getBuyCount(var_9_1, var_9_4)))
				var_9_5:updateGroupCount((ChargeConst.getGroupLimit(var_9_2, var_9_5:getConfig("group") or 0)))
			elseif var_9_3 == 3 then
				var_9_5 = Goods.Create({
					id = var_9_4
				}, Goods.TYPE_SKIN)

				var_9_5:updateBuyCount((ChargeConst.getBuyCount(var_9_1, var_9_4)))
				var_9_5:updateGroupCount((ChargeConst.getGroupLimit(var_9_2, var_9_5:getConfig("group") or 0)))
			end

			self.commodities[var_9_3][var_9_4] = var_9_5
		end
	end

	self.bnIds = Clone(var_0_1.get_id_list_by_name)

	local var_9_6 = getProxy(PlayerProxy):getRawData()

	self.bnIds.banner_big = underscore.filter(self.bnIds.banner_big, function(arg_10_0)
		return ShopsProxy.SpecialBannerBlockCheck(var_0_1[arg_10_0], var_9_6)
	end)

	if getProxy(ActivityRemasterProxy):ExistShopBanner() then
		self.bnIds.banner_small3 = self.bnIds.banner_small3 or {}

		table.insert(self.bnIds.banner_small3, NewRecommendationShopLayer.ACT_REMASTER_BANNER_ID)
	end

	for iter_9_2, iter_9_3 in pairs(self.bnIds) do
		table.sort(iter_9_3, CompareFuncs({
			function(arg_11_0)
				return -self:GetBannerConfig(arg_11_0).order
			end,
			function(arg_12_0)
				return arg_12_0
			end
		}))

		for iter_9_4 = #iter_9_3, 1, -1 do
			local var_9_7 = self:GetBannerConfig(iter_9_3[iter_9_4])

			if not pg.TimeMgr.GetInstance():inTime(var_9_7.time) then
				table.remove(iter_9_3, iter_9_4)
			elseif var_9_7.relation_param ~= "" then
				if var_9_7.relation_param[1] == 1 then
					if not self.commodities[var_9_7.relation_param[1]][var_9_7.relation_param[2]]:inTime() or not self.commodities[var_9_7.relation_param[1]][var_9_7.relation_param[2]]:canPurchase() then
						table.remove(iter_9_3, iter_9_4)
					end
				elseif (var_9_7.relation_param[1] == 2 or var_9_7.relation_param[1] == 3) and (not self.commodities[var_9_7.relation_param[1]][var_9_7.relation_param[2]]:inTime() or not self.commodities[var_9_7.relation_param[1]][var_9_7.relation_param[2]]:canPurchase() or self.commodities[var_9_7.relation_param[1]][var_9_7.relation_param[2]]:IsGroupLimit()) then
					table.remove(iter_9_3, iter_9_4)
				end
			end
		end

		if #iter_9_3 > 1 then
			table.remove(iter_9_3, #iter_9_3)
		end

		if pg.gameset.shop_banner_capacity.key_value < #iter_9_3 then
			for iter_9_5 = #iter_9_3, pg.gameset.shop_banner_capacity.key_value + 1, -1 do
				table.remove(iter_9_3, iter_9_5)
			end
		end
	end
end

function NewRecommendationShopLayer:ShowResUI()
	self.goldMax = self.resources:Find("gold/max"):GetComponent(typeof(Text))
	self.goldValue = self.resources:Find("gold/Text"):GetComponent(typeof(Text))
	self.oilMax = self.resources:Find("oil/max"):GetComponent(typeof(Text))
	self.oilValue = self.resources:Find("oil/Text"):GetComponent(typeof(Text))
	self.gemValue = self.resources:Find("gem/Text"):GetComponent(typeof(Text))

	PlayerResUI.StaticFlush(getProxy(PlayerProxy):getRawData(), self.goldMax, self.goldValue, self.oilMax, self.oilValue, self.gemValue)
	onButton(self, self.resources:Find("gold"), function()
		pg.playerResUI:ClickGold()
	end, SFX_PANEL)
	onButton(self, self.resources:Find("oil"), function()
		pg.playerResUI:ClickOil()
	end, SFX_PANEL)
	onButton(self, self.resources:Find("gem"), function()
		pg.playerResUI:ClickGem()
	end, SFX_PANEL)
end

function NewRecommendationShopLayer:GetBannerConfig(arg_17_1)
	if arg_17_1 == NewRecommendationShopLayer.ACT_REMASTER_BANNER_ID then
		return getProxy(ActivityRemasterProxy):GetShopBanner()
	end

	assert(var_0_1[arg_17_1], "no config >>>>>>>>>>>>>>>>>" .. arg_17_1)

	if var_0_1[arg_17_1] then
		return var_0_1[arg_17_1]
	end
end

function NewRecommendationShopLayer:SetPanel()
	for iter_18_0, iter_18_1 in pairs(self.banners) do
		for iter_18_2, iter_18_3 in ipairs(self.bnIds[iter_18_0]) do
			local var_18_0 = self:GetBannerConfig(iter_18_3)
			local var_18_1 = iter_18_1:AddChild()

			GetImageSpriteFromAtlasAsync(var_18_0.pic, "", var_18_1:Find("picture"))
			setActive(var_18_1:Find("detail"), var_18_0.relation_param ~= "")
			setActive(var_18_1:Find("time"), var_18_0.time_lable == 1)

			if iter_18_0 == "banner_small2" then
				setActive(var_18_1:Find("monthCard"), false)
				setActive(var_18_1:Find("monthCardhave"), false)
			end

			if var_18_0.relation_param ~= "" then
				local var_18_2 = var_18_0.relation_param[1]
				local var_18_3 = self.commodities[var_18_0.relation_param[1]][var_18_0.relation_param[2]]

				if iter_18_0 == "banner_small2" and var_18_2 == 1 and var_18_3:isMonthCard() then
					setActive(var_18_1:Find("detail"), false)
					setActive(var_18_1:Find("monthCard"), true)
					setText(var_18_1:Find("monthCard/name"), var_18_3:getConfig("name_display"))
					GetImageSpriteFromAtlasAsync("chargeicon/" .. var_18_3:getConfig("picture"), "", var_18_1:Find("monthCard/icon"))
					setText(var_18_1:Find("monthCard/get"), i18n("shop_new_get_now", var_18_3:GetGemCnt()))

					local var_18_4 = var_18_3:GetDropList()

					while #var_18_4 > 3 do
						table.remove(var_18_4, #var_18_4)
					end

					local var_18_5 = UIItemList.New(var_18_1:Find("monthCard/items"), var_18_1:Find("monthCard/items/item"))

					var_18_5:make(function(arg_19_0, arg_19_1, arg_19_2)
						if arg_19_0 == UIItemList.EventUpdate then
							updateDrop(arg_19_2:Find("mask/item"), var_18_4[arg_19_1 + 1])
						end
					end)
					var_18_5:align(#var_18_4)

					local var_18_6 = var_18_2 == 1 and var_18_3:getShowType() ~= ""
					local var_18_7 = var_18_3:isFree()

					setText(var_18_1:Find("monthCard/consume/icon_rmb"), GetMoneySymbol())
					setActive(var_18_1:Find("monthCard/consume/icon_rmb"), var_18_2 == 1 and not var_18_6)

					if PLATFORM_CODE == PLATFORM_CHT and var_18_3:IsLocalPrice() then
						setActive(var_18_1:Find("monthCard/consume/icon_rmb"), false)
					end

					setActive(var_18_1:Find("monthCard/consume/icon_gem"), var_18_2 ~= 1 and not var_18_7)
					setActive(var_18_1:Find("monthCard/consume/Text"), not var_18_7 and not var_18_6)

					if var_18_2 == 1 then
						setText(var_18_1:Find("monthCard/consume/Text"), var_18_3:getConfig("money"))
					elseif var_18_2 == 2 then
						setText(var_18_1:Find("monthCard/consume/Text"), var_18_3:GetPrice())
					end

					setActive(var_18_1:Find("monthCard/consume/FreeText"), var_18_7)
					setText(var_18_1:Find("monthCard/consume/FreeText"), i18n("shop_free_tag"))

					local var_18_8 = getProxy(PlayerProxy):getRawData():getCardById(VipCard.MONTH)
					local var_18_9

					if var_18_8 then
						::label_18_0::

						var_18_9 = var_18_8:GetLeftDay() > (var_18_3:getConfig("limit_arg") or 0)
					end

					setActive(var_18_1:Find("monthCardhave"), var_18_9)

					if var_18_9 then
						setText(var_18_1:Find("monthCardhave/Text"), i18n("shop_new_remaining_time", var_18_8:GetLeftDay()))
					end
				else
					if var_18_2 == 1 then
						setText(var_18_1:Find("detail/name"), var_18_3:getConfig("name_display"))
						GetImageSpriteFromAtlasAsync("chargeicon/" .. var_18_3:getConfig("picture"), "", var_18_1:Find("detail/icon"))
					elseif var_18_2 == 2 then
						setText(var_18_1:Find("detail/name"), var_18_3:GetName())
						GetImageSpriteFromAtlasAsync(var_18_3:getDropInfo():getIcon(), "", var_18_1:Find("detail/icon"))
					end

					local var_18_10 = var_18_3:GetDropList()

					while #var_18_10 > 3 do
						table.remove(var_18_10, #var_18_10)
					end

					local var_18_11 = UIItemList.New(var_18_1:Find("detail/items"), var_18_1:Find("detail/items/item"))

					var_18_11:make(function(arg_20_0, arg_20_1, arg_20_2)
						if arg_20_0 == UIItemList.EventUpdate then
							updateDrop(arg_20_2:Find("mask/item"), var_18_10[arg_20_1 + 1])
						end
					end)
					var_18_11:align(#var_18_10)

					local var_18_12 = var_18_2 == 1 and var_18_3:getShowType() ~= ""
					local var_18_13 = var_18_3:isFree()

					setText(var_18_1:Find("detail/consume/icon_rmb"), GetMoneySymbol())
					setActive(var_18_1:Find("detail/consume/icon_rmb"), var_18_2 == 1 and not var_18_12)

					if PLATFORM_CODE == PLATFORM_CHT and var_18_3:IsLocalPrice() then
						setActive(var_18_1:Find("detail/consume/icon_rmb"), false)
					end

					setActive(var_18_1:Find("detail/consume/icon_gem"), var_18_2 ~= 1 and not var_18_13)
					setActive(var_18_1:Find("detail/consume/Text"), not var_18_13 and not var_18_12)

					if var_18_2 == 1 then
						setText(var_18_1:Find("detail/consume/Text"), var_18_3:getConfig("money"))
					elseif var_18_2 == 2 then
						setText(var_18_1:Find("detail/consume/Text"), var_18_3:GetPrice())
					end

					setActive(var_18_1:Find("detail/consume/FreeText"), var_18_13)
					setText(var_18_1:Find("detail/consume/FreeText"), i18n("shop_free_tag"))
				end
			end

			if var_18_0.time_lable == 1 then
				local var_18_14 = pg.TimeMgr.GetInstance():Table2ServerTime({
					year = var_18_0.time[2][1][1],
					month = var_18_0.time[2][1][2],
					day = var_18_0.time[2][1][3],
					hour = var_18_0.time[2][2][1],
					min = var_18_0.time[2][2][2],
					sec = var_18_0.time[2][2][3]
				})

				self:StartTimer(function()
					local var_21_0 = var_18_14 - pg.TimeMgr.GetInstance():GetServerTime()
					local var_21_1 = math.floor(var_21_0 / 86400)
					local var_21_2 = math.floor(var_21_0 % 86400 / 3600)
					local var_21_3 = math.floor(var_21_0 % 86400 % 3600 / 60)

					if iter_18_0 == "banner_big" then
						setText(var_18_1:Find("time/text"), i18n("shop_countdown", var_21_1, var_21_2, var_21_3))
					elseif var_21_1 > 0 then
						setText(var_18_1:Find("time/text"), i18n("shop_new_during_day", var_21_1))
					elseif var_21_2 > 0 then
						setText(var_18_1:Find("time/text"), i18n("shop_new_during_hour", var_21_2))
					else
						setText(var_18_1:Find("time/text"), i18n("shop_new_during_minite", var_21_3))
					end
				end)
			end

			onButton(self, var_18_1, function()
				self:emit(NewRecommendationShopMediator.GO_SHOP, var_18_0.param[1], var_18_0.param[2])
			end, SFX_PANEL)
		end

		iter_18_1:SetUp()
		setActive(self._tf:Find("panel/" .. iter_18_0 .. "/banner/dots"), #self.bnIds[iter_18_0] > 1)
	end
end

function NewRecommendationShopLayer:StartTimer(arg_23_1)
	self.timers = self.timers or {}

	arg_23_1()

	local var_23_0 = Timer.New(function()
		arg_23_1()
	end, 1, -1)

	var_23_0:Start()
	table.insert(self.timers, var_23_0)
end

function NewRecommendationShopLayer:RemoveAllTimer()
	if self.timers then
		for iter_25_0, iter_25_1 in ipairs(self.timers) do
			iter_25_1:Stop()

			iter_25_1 = nil
		end

		self.timers = nil
	end
end

function NewRecommendationShopLayer:willExit()
	self:RemoveAllTimer()

	for iter_26_0, iter_26_1 in pairs(self.banners) do
		iter_26_1:Dispose()
	end

	self.banners = nil

	self:UnOverlayPanel(self._tf)
end

function NewRecommendationShopLayer:onBackPressed()
	pg.m02:sendNotification(NewShopMainScene.CLOSE_VIEW)
end

return NewRecommendationShopLayer
