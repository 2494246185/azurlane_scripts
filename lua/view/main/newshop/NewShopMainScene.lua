local NewShopMainScene = class("NewShopMainScene", import("...base.BaseUI"))

NewShopMainScene.CLOSE_ALL_LAYER = "NewShopMainScene.CLOSE_ALL_LAYER"
NewShopMainScene.SHOW_OR_HIDE_UI = "NewShopMainScene.SHOW_OR_HIDE_UI"
NewShopMainScene.SHOW_OR_HIDE_UI_2 = "NewShopMainScene.SHOW_OR_HIDE_UI_2"
NewShopMainScene.CLOSE_VIEW = "NewShopMainScene.CLOSE_VIEW"
NewShopMainScene.TYPE_CHARGE = "charge"
NewShopMainScene.TYPE_SKIN = "skin"
NewShopMainScene.ON_CLICK_SKIN_SHOP = "NewShopMainScene::ON_CLICK_SKIN_SHOP"

function NewShopMainScene:getUIName()
	return "NewShopUI"
end

function NewShopMainScene:getResource()
	local var_2_0 = self.contextData

	local function var_2_1(arg_6_0)
		local var_6_0 = {}

		for iter_6_0, iter_6_1 in ipairs((getProxy(ShopsProxy):GetAllShowGiftPackages(arg_6_0))) do
			if iter_6_1:isChargeType() then
				table.insert(var_6_0, "chargeicon/" .. iter_6_1:getConfig("picture"))
			else
				table.insert(var_6_0, Item.getConfigData(iter_6_1:getConfig("effect_args")[1]).icon)
			end
		end

		return var_6_0
	end

	return ResPathSupport.MergeLuaArr(NewShopMainScene.super.getResource(self), {
		(function()
			return "live2d/" .. Ship.New({
				configId = 312011
			}):getPainting()
		end)(),
		"ui/ChargeDiamondShopUI",
		"ui/ChargeGiftShopUI",
		"ui/ChargeItemShopUI",
		"ui/ChargePickShopUI",
		"ui/ShopSupplyShopUI",
		"ui/iconcolorful",
		"ui/ShopsUI_atlas",
		"weaponframes",
		"props/medal",
		"shoppainting/buzhihuo_shop"
	}, (function()
		local var_4_0 = {}

		local function var_4_1(arg_5_0)
			if arg_5_0 and arg_5_0 ~= "" and not table.contains(var_4_0, arg_5_0) then
				table.insert(var_4_0, arg_5_0)
			end
		end

		for iter_4_0, iter_4_1 in ipairs(pg.pay_data_display.all) do
			var_4_1("chargeicon/" .. pg.pay_data_display[iter_4_1].picture)
		end

		return var_4_0
	end)(), var_2_1(true), var_2_1(false), (function()
		local var_7_0 = {}
		local var_7_1 = getProxy(PlayerProxy):getData()
		local var_7_2

		if var_2_0 then
			var_7_2 = var_2_0.normalGroupList or getProxy(ShopsProxy):GetNormalGroupList()
		end

		local function var_7_3(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
			local var_8_0, var_8_1, var_8_2 = ChargeConst.getGoodsLimitInfo(arg_8_0)
			local var_8_3 = false

			if arg_8_1.effect_args == "ship_bag_size" and var_8_1 and var_8_2 then
				local var_8_4 = var_7_1:getMaxShipBagExcludeGuild()

				var_8_3 = var_8_1 <= var_8_4 and var_8_4 <= var_8_2
			elseif arg_8_1.effect_args == "equip_bag_max" and var_8_1 and var_8_2 then
				local var_8_5 = var_7_1:getMaxEquipmentBag()

				var_8_3 = var_8_1 <= var_8_5 and var_8_5 <= var_8_2
			else
				var_8_3 = arg_8_1.effect_args == "commander_bag_size" and var_8_1 and var_8_2 and var_8_1 <= var_7_1.commanderBagMax and var_7_1.commanderBagMax <= var_8_2 or true
			end

			if not var_8_3 then
				return false
			end

			local var_8_6 = Goods.Create({
				count = 0,
				shop_id = arg_8_0
			}, Goods.TYPE_MILITARY)

			return var_8_6:IsShowWhenGroupSale((ChargeConst.getGroupLimit(arg_8_3, var_8_6:getConfig("group"))))
		end

		for iter_7_0, iter_7_1 in pairs(pg.shop_template.all) do
			if pg.shop_template[iter_7_1].genre == "gem_shop" and var_7_3(iter_7_1, pg.shop_template[iter_7_1], var_7_1, var_7_2) then
				table.insert(var_7_0, NewShopMainScene.GetShopTemplateDropIcon(pg.shop_template[iter_7_1]))
			end
		end

		return var_7_0
	end)(), (function()
		local var_9_0 = {}

		for iter_9_0, iter_9_1 in ipairs(pg.activity_template.get_id_list_by_type[ActivityConst.ACTIVITY_TYPE_SHOP]) do
			if pg.activity_template[iter_9_1].config_client.painting then
				if type(pg.activity_template[iter_9_1].config_client.painting) == "table" then
					for iter_9_2, iter_9_3 in ipairs(pg.activity_template[iter_9_1].config_client.painting) do
						table.insert(var_9_0, "shoppainting/" .. iter_9_3)
					end
				elseif type(pg.activity_template[iter_9_1].config_client.painting) == "string" then
					table.insert(var_9_0, "shoppainting/" .. pg.activity_template[iter_9_1].config_client.painting)
				end
			end
		end

		return ResPathSupport.UniqueLuaArr(var_9_0)
	end)())
end

function NewShopMainScene:GetShopTemplateDropIcon()
	return Drop.New(self.effect_args == "ship_bag_size" and {
		count = 1,
		type = DROP_TYPE_ITEM,
		id = Goods.SHIP_BAG_SIZE_ITEM
	} or self.effect_args == "equip_bag_size" and {
		count = 1,
		type = DROP_TYPE_ITEM,
		id = Goods.EQUIP_BAG_SIZE_ITEM
	} or self.effect_args == "commander_bag_size" and {
		count = 1,
		type = DROP_TYPE_ITEM,
		id = Goods.COMMANDER_BAG_SIZE_ITEM
	} or self.effect_args == "spweapon_bag_size" and {
		count = 1,
		type = DROP_TYPE_ITEM,
		id = Goods.SPWEAPON_BAG_SIZE_ITEM
	} or {
		type = self.type,
		id = self.effect_args[1],
		count = self.num
	}):getIcon()
end

function NewShopMainScene:setList()
	local var_11_0 = getProxy(ShopsProxy)
	local var_11_1 = var_11_0:getFirstChargeList()
	local var_11_2 = var_11_0:getChargedList()
	local var_11_3 = var_11_0:GetNormalList()
	local var_11_4 = var_11_0:GetNormalGroupList()

	if var_11_1 then
		self:setFirstChargeIds(var_11_1)
	end

	if var_11_2 then
		self:setChargedList(var_11_2)
	end

	if var_11_3 then
		self:setNormalList(var_11_3)
	end

	if var_11_4 then
		self:setNormalGroupList(var_11_4)
	end
end

function NewShopMainScene:init()
	local var_12_0 = self._tf:Find("buttonList")

	self.buttonList = var_12_0
	self.backBtn = var_12_0:Find("top/closeBtn")
	self.homeBtn = var_12_0:Find("top/homeBtn")
	self.resourcePanel = var_12_0:Find("top/resources")

	setActive(self.resourcePanel, false)

	self.goldBtn = var_12_0:Find("top/resources/gold")
	self.goldText = var_12_0:Find("top/resources/gold/Text"):GetComponent(typeof(Text))
	self.goldMax = var_12_0:Find("top/resources/gold/max"):GetComponent(typeof(Text))
	self.oilBtn = var_12_0:Find("top/resources/oil")
	self.oilText = var_12_0:Find("top/resources/oil/Text"):GetComponent(typeof(Text))
	self.oilMax = var_12_0:Find("top/resources/oil/max"):GetComponent(typeof(Text))
	self.diamondBtn = var_12_0:Find("top/resources/gem")
	self.diamondText = var_12_0:Find("top/resources/gem/Text"):GetComponent(typeof(Text))

	setText(var_12_0:Find("top/title/Text"), i18n("shop_title"))
	setText(var_12_0:Find("shop1List/recommendation/shop1Tg/name"), i18n("shop_recommend"))
	setText(var_12_0:Find("shop1List/skinShop/shop1Tg/name"), i18n("shop_skin"))
	setText(var_12_0:Find("shop1List/diamondShop/shop1Tg/name"), i18n("shop_diamond_title"))
	setText(var_12_0:Find("shop1List/specialShop/shop1Tg/name"), i18n("shop_akashi_pick_title"))
	setText(var_12_0:Find("shop1List/giftPackShop/shop1Tg/name"), i18n("shop_gift_title"))
	setText(var_12_0:Find("shop1List/functionalItemShop/shop1Tg/name"), i18n("shop_item_title"))
	setText(var_12_0:Find("shop1List/supplyShop/shop1Tg/name"), i18n("shop_supply_prop"))
	setText(var_12_0:Find("shop1List/recommendation/shop1Tg/name/en"), i18n("shop_recommend_en"))
	setText(var_12_0:Find("shop1List/skinShop/shop1Tg/name/en"), i18n("shop_skin_en"))
	setText(var_12_0:Find("shop1List/diamondShop/shop1Tg/name/en"), i18n("shop_diamond_title_en"))
	setText(var_12_0:Find("shop1List/specialShop/shop1Tg/name/en"), i18n("shop_side_lable_en"))
	setText(var_12_0:Find("shop1List/giftPackShop/shop1Tg/name/en"), i18n("shop_gift_title_en"))
	setText(var_12_0:Find("shop1List/functionalItemShop/shop1Tg/name/en"), i18n("shop_item_title_en"))
	setText(var_12_0:Find("shop1List/supplyShop/shop1Tg/name/en"), i18n("shop_supply_prop_en"))
	setText(var_12_0:Find("shop1List/supplyShop/shop2List/monthShop/name"), i18n("shop_month"))
	setText(var_12_0:Find("shop1List/supplyShop/shop2List/monthShop/selected/name"), i18n("shop_month"))
	setText(var_12_0:Find("shop1List/supplyShop/shop2List/supplyShop/name"), i18n("shop_supply"))
	setText(var_12_0:Find("shop1List/supplyShop/shop2List/supplyShop/selected/name"), i18n("shop_supply"))
	setText(var_12_0:Find("shop1List/supplyShop/shop2List/activityShop/name"), i18n("shop_activity"))
	setText(var_12_0:Find("shop1List/supplyShop/shop2List/activityShop/selected/name"), i18n("shop_activity"))

	self.frame = self._tf:Find("frame")
	self.viewContainer = self._tf:Find("viewContainer")
	self.painting = self._tf:Find("frame/painting")
	self.chat = self._tf:Find("frame/chat")
	self.chatText = self.chat:Find("Text")
	self.stamp = self._tf:Find("frame/stamp")
	self.specialTip = var_12_0:Find("shop1List/specialShop/shop1Tg/tip")
	self.giftTip = var_12_0:Find("shop1List/giftPackShop/shop1Tg/tip")

	pg.EasyRedDotMgr.GetInstance():RegisterRedDot(self.specialTip, {
		"specialShop",
		"Charge_Page_Exposure"
	}, function(arg_13_0)
		getProxy(ShopsProxy):GiftPackageRedDotTip({
			arg_13_0
		}, true)
	end)
	pg.EasyRedDotMgr.GetInstance():RegisterRedDot(self.giftTip, {
		"specialShop",
		"Charge_Page_Exposure"
	}, function(arg_14_0)
		getProxy(ShopsProxy):GiftPackageRedDotTip({
			arg_14_0
		}, false)
	end)

	self.toggleList = {
		{
			type = ChargeScene.TYPE_DIAMOND,
			go = var_12_0:Find("shop1List/diamondShop/shop1Tg")
		},
		{
			type = ChargeScene.TYPE_GIFT,
			go = var_12_0:Find("shop1List/giftPackShop/shop1Tg")
		},
		{
			type = ChargeScene.TYPE_ITEM,
			go = var_12_0:Find("shop1List/functionalItemShop/shop1Tg")
		},
		{
			type = ChargeScene.TYPE_PICK,
			go = var_12_0:Find("shop1List/specialShop/shop1Tg")
		}
	}
	GetComponent(var_12_0:Find("shop1List/supplyShop/shop2List/supplyShop"), typeof(Toggle)).isOn = true
	self.chargeTipWindow = ChargeTipWindow.New(self._tf, self.event)

	self:LoadMingshi()
	self:jpUIInit()
	self:blurView()
	self:initSubView()

	self.bulinTip = AprilFoolBulinSubView.ShowAprilFoolBulin(self, self.pageContainer, Vector2.New(-35, -90))

	if self.bulinTip then
		self.bulinTip:RegisterView(self)
		self.bulinTip:CallbackInvoke(function()
			self:OverlayPanel(self.bulinTip._tf, {
				groupDelta = 1
			})
		end)

		function self.bulinTip.destroyCall()
			if self.bulinTip:GetLoaded() then
				self:UnOverlayPanel(self.bulinTip._tf)
			end
		end
	end
end

function NewShopMainScene:setPlayer(arg_17_1)
	self.player = arg_17_1

	if self.subViewList[self.curSubViewNum] and self.subViewList[self.curSubViewNum]:IsSupplyShop() then
		self.subViewList[self.curSubViewNum]:SetPlayer(arg_17_1)
	end

	if self.goldMax then
		PlayerResUI.StaticFlush(self.player, self.goldMax, self.goldText, self.oilMax, self.oilText, self.diamondText)
	end
end

function NewShopMainScene:setFirstChargeIds(arg_18_1)
	self.firstChargeIds = arg_18_1
end

function NewShopMainScene:setChargedList(arg_19_1)
	self.chargedList = arg_19_1
end

function NewShopMainScene:setNormalList(arg_20_1)
	self.normalList = arg_20_1
end

function NewShopMainScene:setNormalGroupList(arg_21_1)
	self.normalGroupList = arg_21_1

	self:addRefreshTimer(GetZeroTime())
end

function NewShopMainScene:SetSupplyShopList(arg_22_1)
	self.supplyShopList = arg_22_1

	self:SortActivityShops()
end

function NewShopMainScene:SortActivityShops()
	for iter_23_0, iter_23_1 in pairs(self.supplyShopList) do
		if #iter_23_1 > 1 then
			table.sort(iter_23_1, function(arg_24_0, arg_24_1)
				return arg_24_0:getStartTime() > arg_24_1:getStartTime()
			end)
		end
	end
end

function NewShopMainScene:OnInitItems(arg_25_1)
	self.items = arg_25_1

	self.subViewList[ShopConst.SHOP_ID.MONTH]:OnUpdateItems(arg_25_1)
	self.subViewList[ShopConst.SHOP_ID.SUPPLY]:OnUpdateItems(arg_25_1)
	self.subViewList[ShopConst.SHOP_ID.ACTIVITY]:OnUpdateItems(arg_25_1)
end

function NewShopMainScene:OnUpdateItems(arg_26_1)
	self.items = arg_26_1

	if self.subViewList[self.curSubViewNum] and self.subViewList[self.curSubViewNum]:IsSupplyShop() then
		self.subViewList[self.curSubViewNum]:OnUpdateItems(arg_26_1)
	end
end

function NewShopMainScene:OnUpdateShop(arg_27_1, arg_27_2)
	self:SetShop(arg_27_1, arg_27_2)

	if self.subViewList[self.curSubViewNum] and self.subViewList[self.curSubViewNum]:IsSupplyShop() then
		self.subViewList[self.curSubViewNum]:OnUpdateShop(arg_27_1, arg_27_2)
	end
end

function NewShopMainScene:OnUpdateCommodity(arg_28_1, arg_28_2, arg_28_3)
	self:SetShop(arg_28_1, arg_28_2)

	if self.subViewList[self.curSubViewNum] and self.subViewList[self.curSubViewNum]:IsSupplyShop() then
		self.subViewList[self.curSubViewNum]:OnUpdateCommodity(arg_28_1, arg_28_2, arg_28_3)
	end
end

function NewShopMainScene:OnFragmentSellUpdate()
	if self.subViewList[self.curSubViewNum] and self.subViewList[self.curSubViewNum]:IsSupplyShop() then
		self.subViewList[self.curSubViewNum]:OnFragmentSellUpdate()
	end
end

function NewShopMainScene:SetShop(arg_30_1, arg_30_2)
	if not self.supplyShopList then
		return
	end

	if self.supplyShopList[arg_30_1] then
		for iter_30_0, iter_30_1 in ipairs(self.supplyShopList[arg_30_1]) do
			if iter_30_1:IsSameKind(arg_30_2) then
				self.supplyShopList[arg_30_1][iter_30_0] = arg_30_2

				break
			end
		end
	end
end

function NewShopMainScene:didEnter()
	self.eventIDList = {
		self:bind(NewShopMainScene.ON_CLICK_SKIN_SHOP, handler(self, self.OnClickSkinShop))
	}

	setActive(self.chat, false)
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.homeBtn, function()
		self:emit(NewShopMainScene.ON_HOME)
	end, SFX_CANCEL)
	onButton(self, self.goldBtn, function()
		pg.playerResUI:ClickGold()
	end, SFX_PANEL)
	onButton(self, self.oilBtn, function()
		pg.playerResUI:ClickOil()
	end, SFX_PANEL)
	onButton(self, self.diamondBtn, function()
		pg.playerResUI:ClickGem()
	end, SFX_PANEL)
	onToggle(self, self.buttonList:Find("shop1List/recommendation/shop1Tg"), function(arg_37_0)
		if arg_37_0 then
			self.contextData.shop1 = nil
			self.contextData.shop2 = nil

			if self.shop1 == "recommendation" then
				return
			end

			self.shop1 = "recommendation"
			self.shop2 = nil

			self:ShowChargeWarp(false)
			pg.m02:sendNotification(NewShopMainScene.CLOSE_ALL_LAYER)
			self:emit(NewShopMainMediator.OPEN_LAYER, NewRecommendationShopLayer, NewRecommendationShopMediator)
		end
	end, SFX_PANEL)
	self:InitSkinToggleList()

	for iter_31_0 = 1, #self.toggleList do
		local var_31_0 = self.toggleList[iter_31_0]

		onToggle(self, self.toggleList[iter_31_0].go, function(arg_38_0)
			if arg_38_0 then
				self:ShowChargeWarp(true)
				pg.m02:sendNotification(NewShopMainScene.CLOSE_ALL_LAYER)

				self.contextData.shop1 = nil
				self.contextData.shop2 = nil
				self.shop1 = nil
				self.shop2 = nil
				self.contextData.type = ShopConst.SHOP_TYPE.CHARGE
				self.contextData.warp = var_31_0.type

				self:switchSubView((self:GetShopID(ShopConst.SHOP_TYPE.CHARGE, var_31_0.type)))
			end

			local var_38_0 = switch(var_31_0.type, {
				[ChargeScene.TYPE_PICK] = function()
					return "payshop_pack_red_dot"
				end,
				[ChargeScene.TYPE_GIFT] = function()
					return "gemshop_pack_red_dot"
				end
			})

			if var_38_0 then
				if arg_38_0 then
					self.toggleMark = self.toggleMark or {}
					self.toggleMark[var_31_0.type] = defaultValue(self.toggleMark[var_31_0.type], 0) + 1
				elseif self.toggleMark and defaultValue(self.toggleMark[var_31_0.type], 0) > 0 then
					self.toggleMark[var_31_0.type] = self.toggleMark[var_31_0.type] - 1

					PlayerPrefs.SetInt(var_38_0, getGameset(var_38_0)[1])
					pg.EasyRedDotMgr.GetInstance():TriggerMarks("Charge_Page_Exposure")
				end
			end
		end, SFX_PANEL)
	end

	onToggle(self, self.buttonList:Find("shop1List/supplyShop/shop1Tg"), function(arg_41_0)
		setActive(self.buttonList:Find("shop1List/supplyShop/shop2List"), arg_41_0)

		if arg_41_0 then
			triggerToggle(self.buttonList:Find("shop1List/supplyShop/shop2List/" .. self:GetDefaultSupplyShopName()), true)
		end
	end, SFX_PANEL)

	for iter_31_1, iter_31_2 in ipairs({
		{
			type = ShopConst.CATEGORY_MONTH,
			go = self.buttonList:Find("shop1List/supplyShop/shop2List/monthShop")
		},
		{
			type = ShopConst.CATEGORY_SUPPLY,
			go = self.buttonList:Find("shop1List/supplyShop/shop2List/supplyShop")
		},
		{
			type = ShopConst.CATEGORY_ACTIVITY,
			go = self.buttonList:Find("shop1List/supplyShop/shop2List/activityShop")
		}
	}) do
		onToggle(self, iter_31_2.go, function(arg_42_0)
			if arg_42_0 then
				self:ShowChargeWarp(true)
				pg.m02:sendNotification(NewShopMainScene.CLOSE_ALL_LAYER)

				self.contextData.shop1 = nil
				self.contextData.shop2 = nil
				self.shop1 = nil
				self.shop2 = nil
				self.contextData.type = ShopConst.SHOP_TYPE.SUPPLY
				self.contextData.warp = iter_31_2.type

				self:switchSubView((self:GetShopID(ShopConst.SHOP_TYPE.SUPPLY, iter_31_2.type)))
			end
		end, SFX_PANEL)
	end

	local var_31_1 = "recommendation"

	if self.contextData.type == ShopConst.SHOP_TYPE.CHARGE then
		var_31_1 = self.contextData.warp == ChargeScene.TYPE_DIAMOND and "diamondShop" or self.contextData.warp == ChargeScene.TYPE_GIFT and "giftPackShop" or self.contextData.warp == ChargeScene.TYPE_ITEM and "functionalItemShop" or self.contextData.warp == ChargeScene.TYPE_PICK and "specialShop" or "diamondShop"
	elseif self.contextData.type == ShopConst.SHOP_TYPE.SKIN then
		var_31_1 = "skinShop"
	elseif self.contextData.type == ShopConst.SHOP_TYPE.SUPPLY then
		var_31_1 = "supplyShop"
	end

	if self.contextData.shop1 then
		var_31_1 = self.contextData.shop1
	end

	triggerToggle(self.buttonList:Find("shop1List/" .. var_31_1 .. "/shop1Tg"), true)

	if var_31_1 == "skinShop" then
		-- block empty
	elseif var_31_1 == "supplyShop" then
		triggerToggle(self.buttonList:Find("shop1List/supplyShop/shop2List/" .. self:GetDefaultSupplyShopName()), true)
	end

	onButton(self, self.painting, function()
		self:displayShipWord()
		self:emit(NewShopMainMediator.CLICK_MING_SHI)
	end, SFX_PANEL)
	onButton(self, self.stamp, function()
		getProxy(TaskProxy):dealMingshiTouchFlag(4)
	end, SFX_CONFIRM)
	self:RefreshActivityShop()
	self:updateNoRes()
	self:jpUIEnter()
end

function NewShopMainScene:GetDefaultSupplyShopName()
	if self.contextData.type ~= ShopConst.SHOP_TYPE.SUPPLY then
		return "supplyShop"
	end

	local var_45_0 = self.contextData.warp

	if type(self.contextData.warp) == "string" then
		self.contextData.warp = ShopConst.SHOP_NAME_LIST[var_45_0][1]
		self.contextData.shopID = ShopConst.SHOP_NAME_LIST[var_45_0][2]
	elseif type(var_45_0) == "number" and self.contextData.shopID == nil then
		for iter_45_0, iter_45_1 in pairs(ShopConst.SUPPLY_SHOP_LIST) do
			for iter_45_2, iter_45_3 in pairs(iter_45_1) do
				if iter_45_3 == var_45_0 then
					self.contextData.warp = iter_45_0
					self.contextData.shopID = iter_45_3

					break
				end
			end
		end
	end

	return self.contextData.warp == ShopConst.CATEGORY_MONTH and "monthShop" or self.contextData.warp == ShopConst.CATEGORY_SUPPLY and "supplyShop" or self.contextData.warp == ShopConst.CATEGORY_ACTIVITY and #self.supplyShopList[ShopConst.TYPE_ACTIVITY] > 0 and "activityShop" or "supplyShop"
end

function NewShopMainScene:RefreshActivityShop()
	setActive(self.buttonList:Find("shop1List/supplyShop/shop2List/activityShop"), #(self.supplyShopList[ShopConst.TYPE_ACTIVITY] or {}) > 0)
end

function NewShopMainScene:RefreshActivityEnd(arg_47_1)
	local var_47_1 = false

	for iter_47_0, iter_47_1 in pairs(self.supplyShopList[ShopConst.TYPE_ACTIVITY] or {}) do
		if iter_47_1.id == arg_47_1 then
			table.remove(self.supplyShopList[ShopConst.TYPE_ACTIVITY], iter_47_0)

			var_47_1 = true

			break
		end
	end

	if var_47_1 == false then
		return
	end

	self:RefreshActivityShop()

	if self.contextData.type == ShopConst.SHOP_TYPE.SUPPLY then
		triggerToggle(self.buttonList:Find("shop1List/supplyShop/shop2List/" .. self:GetDefaultSupplyShopName()), true)
	end
end

function NewShopMainScene:ShowOrHideUI(arg_48_1)
	self:setVisible(arg_48_1)
	setActive(self.buttonList, arg_48_1)
end

function NewShopMainScene:ShowOrHideUI2(arg_49_1)
	for iter_49_0 = 0, self._tf.childCount - 1 do
		setActive(self._tf:GetChild(iter_49_0), arg_49_1)
	end

	setActive(self.buttonList:Find("leftBg"), arg_49_1)
	setActive(self.buttonList:Find("shop1List"), arg_49_1)
	setActive(self.buttonList:Find("top"), true)
end

function NewShopMainScene:OnChargeSuccess(arg_50_1)
	self.chargeTipWindow:ExecuteAction("Show", arg_50_1, function()
		MainFetchPrevPeriodCrusingSequence.New():Execute(function()
			return
		end)
	end)
end

function NewShopMainScene:LoadMingshi()
	if Live2dConst.GetLive2DArm32MatchAble() then
		local var_53_0 = Ship.New({
			configId = 312011
		}):getPainting()

		LoadPaintingPrefabAsync(self.painting, var_53_0, var_53_0, "mainNormal", function()
			self.loading = false
		end)
	else
		self:createLive2D()
	end

	self:AddLive2dTimer()
end

function NewShopMainScene:AddLive2dTimer()
	self:StopLive2dTimer()

	self.live2dTimer = Timer.New(function()
		local var_56_0 = pg.ChargeShipTalkInfo.Actions[math.random(#pg.ChargeShipTalkInfo.Actions)]

		if self:checkBuyDone(var_56_0.action) then
			self:displayShipWord(nil, false, var_56_0.dialog_index)
		end
	end, 20, -1)

	self.live2dTimer:Start()
end

function NewShopMainScene:StopLive2dTimer()
	if self.live2dTimer then
		self.live2dTimer:Stop()

		self.live2dTimer = nil
	end
end

function NewShopMainScene:ShowChargeWarp(arg_58_1)
	setActive(self.frame, arg_58_1)
	setActive(self.viewContainer, arg_58_1)
	self:ShowResourceBar(arg_58_1)

	if self.subViewList[self.curSubViewNum] then
		if arg_58_1 == false then
			self.subViewList[self.curSubViewNum]:Destroy()

			self.curSubViewNum = 0
		else
			self.subViewList[self.curSubViewNum]:ShowPanel(arg_58_1)
		end
	end
end

function NewShopMainScene:ShowResourceBar(arg_59_1)
	if self.resourceBarFlag == arg_59_1 then
		return
	end

	self.resourceBarFlag = arg_59_1

	setActive(self.resourcePanel, arg_59_1)
end

function NewShopMainScene:willExit()
	for iter_60_0, iter_60_1 in ipairs(self.eventIDList) do
		self:disconnect(iter_60_1)
	end

	self.eventIDList = nil

	if self.bulinTip then
		self.bulinTip:Destroy()

		self.bulinTip = nil
	end

	pg.EasyRedDotMgr.GetInstance():UnRegisterRedDot(self.specialTip)
	pg.EasyRedDotMgr.GetInstance():UnRegisterRedDot(self.giftTip)

	if self.toggleMark then
		for iter_60_2, iter_60_3 in pairs(self.toggleMark) do
			if iter_60_3 > 0 then
				local var_60_0 = switch(iter_60_2, {
					[ChargeScene.TYPE_PICK] = function()
						return "payshop_pack_red_dot"
					end,
					[ChargeScene.TYPE_GIFT] = function()
						return "gemshop_pack_red_dot"
					end
				})

				PlayerPrefs.SetInt(var_60_0, getGameset(var_60_0)[1])
			end
		end

		self.toggleMark = nil
	end

	self:ShowResourceBar()
	self:unBlurView()

	if self.chargeTipWindow then
		self.chargeTipWindow:Destroy()

		self.chargeTipWindow = nil
	end

	self.contextData.singleWindow:Destroy()
	self.contextData.multiWindow:Destroy()
	self.contextData.singleWindowForESkin:Destroy()
	self.contextData.paintingView:Dispose()

	self.contextData.singleWindow = nil
	self.contextData.multiWindow = nil
	self.contextData.singleWindowForESkin = nil
	self.contextData.paintingView = nil
	self.bulinTip = nil

	for iter_60_4, iter_60_5 in pairs(self.subViewList) do
		iter_60_5:Destroy()
	end

	self.subViewList = nil

	if self.heartsTimer then
		self.heartsTimer:Stop()

		self.heartsTimer = nil
	end

	if self.live2dChar then
		self.live2dChar:Dispose()
	end

	self:StopLive2dTimer()
	self:stopCV()
	self:DisposeSkinToggleList()

	if self.giftShopView then
		self.giftShopView:OnDestroy()
	end
end

function NewShopMainScene:onBackPressed()
	if self.contextData.singleWindow:GetLoaded() and self.contextData.singleWindow:isShowing() then
		self.contextData.singleWindow:Close()

		return
	end

	if self.contextData.multiWindow:GetLoaded() and self.contextData.multiWindow:isShowing() then
		self.contextData.multiWindow:Close()

		return
	end

	if self.contextData.singleWindowForESkin:GetLoaded() and self.contextData.singleWindowForESkin:isShowing() then
		self.contextData.singleWindowForESkin:Hide()

		return
	end

	NewShopMainScene.super.onBackPressed(self)
end

function NewShopMainScene:initSubView()
	self.curSubViewNum = 0
	self.subViewList = {
		[ShopConst.SHOP_ID.DIAMOND] = ChargeDiamondShopView.New(self.viewContainer, self.event, self.contextData),
		[ShopConst.SHOP_ID.GIFT] = ChargeGiftShopView.New(self.viewContainer, self.event, self.contextData),
		[ShopConst.SHOP_ID.ITEM] = ChargeItemShopView.New(self.viewContainer, self.event, self.contextData),
		[ShopConst.SHOP_ID.PICK] = ChargePickShopView.New(self.viewContainer, self.event, self.contextData),
		[ShopConst.SHOP_ID.MONTH] = SupplyShopView.New(self.viewContainer, self.event, self.contextData, ShopConst.CATEGORY_MONTH),
		[ShopConst.SHOP_ID.SUPPLY] = SupplyShopView.New(self.viewContainer, self.event, self.contextData, ShopConst.CATEGORY_SUPPLY),
		[ShopConst.SHOP_ID.ACTIVITY] = SupplyShopView.New(self.viewContainer, self.event, self.contextData, ShopConst.CATEGORY_ACTIVITY)
	}

	for iter_64_0, iter_64_1 in pairs(self.subViewList) do
		iter_64_1:RegisterView(self)
	end

	self.contextData.singleWindow = ShopSingleWindow.New(self._tf, self.event)
	self.contextData.multiWindow = ShopMultiWindow.New(self._tf, self.event)
	self.contextData.singleWindowForESkin = EquipmentSkinInfoUIForShopWindow.New(self._tf, self.event)
	self.contextData.paintingView = ShopPaintingView.New(self._tf:Find("frame/supplyPaint"), self._tf:Find("frame/chat"))

	self.contextData.paintingView:setSecretaryPos(self._tf:Find("frame/secretaryPos"))
end

function NewShopMainScene:GetShopID(arg_65_1, arg_65_2)
	return ShopConst.SHOP_LIST[arg_65_1][arg_65_2]
end

function NewShopMainScene:switchSubView(arg_66_1)
	if arg_66_1 == self.curSubViewNum then
		return
	end

	self.subViewList[arg_66_1]:setGoodData(self.firstChargeIds, self.chargedList, self.normalList, self.normalGroupList)
	self.subViewList[arg_66_1]:Reset()
	self.subViewList[arg_66_1]:Load()

	if self.subViewList[arg_66_1].SetAllShopData then
		self.subViewList[arg_66_1]:ActionInvoke("SetAllShopData", self.supplyShopList)
	end

	if self.subViewList[self.curSubViewNum] then
		self.subViewList[self.curSubViewNum]:Destroy()
	end

	self.curSubViewNum = arg_66_1

	self:SwitchPainting(self.subViewList[arg_66_1]:IsSupplyShop())

	if PLATFORM_CODE == PLATFORM_JP then
		setActive(self.userAgreeBtn3, arg_66_1 == ChargeScene.TYPE_DIAMOND)
		setActive(self.userAgreeBtn4, arg_66_1 == ChargeScene.TYPE_DIAMOND)
	end
end

function NewShopMainScene:SwitchPainting(arg_67_1)
	self.contextData.paintingView:Show(arg_67_1)
	setActive(self.painting, not arg_67_1)

	if arg_67_1 then
		self:StopLive2dTimer()

		self.chatFlag = nil

		self:stopCV()
		setActive(self.stamp, getProxy(TaskProxy):mingshiTouchFlagEnabled())

		if LOCK_CLICK_MINGSHI then
			setActive(self.stamp, false)
		end
	else
		setActive(self.stamp, false)
		self:AddLive2dTimer()
	end
end

function NewShopMainScene:switchSubViewByTogger(arg_68_1)
	triggerToggle(self.toggleList[arg_68_1].go, true)
end

function NewShopMainScene:updateCurSubView()
	if not isActive(self.viewContainer) then
		return
	end

	local var_69_0 = self.subViewList[self.curSubViewNum]

	if self.subViewList[self.curSubViewNum] == nil then
		return
	end

	var_69_0:ActionInvoke("setGoodData", self.firstChargeIds, self.chargedList, self.normalList, self.normalGroupList)
	var_69_0:ActionInvoke("reUpdateAll")
end

function NewShopMainScene:updateNoRes(arg_70_1)
	if not arg_70_1 then
		arg_70_1 = self.contextData.noRes
	else
		self.contextData.noRes = arg_70_1
	end

	if not arg_70_1 or #arg_70_1 <= 0 then
		return
	end

	self.contextData.noRes = {}

	local var_70_0 = getProxy(BagProxy):getData()
	local var_70_1 = ""

	for iter_70_0, iter_70_1 in ipairs(arg_70_1) do
		if iter_70_1[2] > 0 then
			arg_70_1[iter_70_0][2] = iter_70_1[1] == 59001 and iter_70_1[3] - self.player.gold or iter_70_1[3] - ((var_70_0[iter_70_1[1]] or nil) and (var_70_0[iter_70_1[1]].count or 0))
		end

		if arg_70_1[iter_70_0][2] > 0 then
			table.insert(self.contextData.noRes, arg_70_1[iter_70_0])
		end
	end

	for iter_70_2, iter_70_3 in ipairs(self.contextData.noRes) do
		var_70_1 = var_70_1 .. i18n(iter_70_3[1] == 59001 and "text_noRes_info_tip" or "text_noRes_info_tip2", Item.getConfigData(iter_70_3[1]).name, iter_70_3[2])

		if iter_70_2 < #self.contextData.noRes then
			var_70_1 = var_70_1 .. i18n("text_noRes_info_tip_link")
		end
	end

	if var_70_1 == "" then
		self:displayShipWord(i18n("text_shop_enoughRes_tip"), false)
	else
		self:displayShipWord(i18n("text_shop_noRes_tip", var_70_1), true)
	end
end

function NewShopMainScene:displayShipWord(arg_71_1, arg_71_2, arg_71_3)
	if not self.chatFlag then
		if not arg_71_1 and self.contextData.noRes and #self.contextData.noRes > 0 then
			setActive(self.chat, false)

			self.chat.transform.localScale = Vector3(0, 0, 1)
		end

		self.chatFlag = true

		if not self.isInitChatPosition then
			self.isInitChatPosition = true

			self:InitChatPosition()
		end

		setActive(self.chat, true)

		local var_71_0 = arg_71_3 or math.random(1, (self.player:getChargeLevel()))
		local var_71_1 = arg_71_3 and pg.pay_level_award[var_71_0].dialog or arg_71_1 or pg.pay_level_award[var_71_0].dialog

		if not arg_71_1 then
			self:playCV(var_71_0)
		end

		setText(self.chatText, var_71_1)

		local var_71_2 = self.chatText:GetComponent(typeof(Text))

		;(function()
			local var_72_0 = 3
			local var_72_1 = 0.3

			LeanTween.scale(rtf(self.chat.gameObject), Vector3.New(1, 1, 1), 0.3):setFrom(Vector3.New(0, 0, 0)):setEase(LeanTweenType.easeOutBack):setOnComplete(System.Action(function()
				if not arg_71_2 then
					LeanTween.scale(rtf(self.chat.gameObject), Vector3.New(0, 0, 1), var_72_1):setEase(LeanTweenType.easeInBack):setDelay(var_72_1 + var_72_0):setOnComplete(System.Action(function()
						self.chatFlag = nil

						setActive(self.chat, false)

						if self.contextData.noRes and #self.contextData.noRes > 0 then
							self:updateNoRes()
						end
					end))
				else
					self.chatFlag = nil
				end
			end))
		end)()
	end
end

function NewShopMainScene:InitChatPosition()
	return
end

function NewShopMainScene:playHeartEffect()
	if self.heartsTimer then
		self.heartsTimer:Stop()
	end

	local var_76_0 = self.painting:Find("heartsfly")

	setActive(var_76_0, true)

	self.heartsTimer = Timer.New(function()
		setActive(var_76_0, false)
	end, 1, 1)

	self.heartsTimer:Start()
end

function NewShopMainScene:createLive2D()
	self.live2dChar = Live2DPainting.New(Live2DPainting.GenerateData({
		ship = Ship.New({
			configId = 312011
		}),
		offset = {
			0,
			0,
			0,
			75
		},
		position = Vector3(0, 0, 0),
		parent = self._tf:Find("frame/painting/live2d")
	}), function(arg_79_0)
		arg_79_0:setSortingLayer(LayerWeightConst.L2D_DEFAULT_LAYER)
	end)
end

function NewShopMainScene:checkBuyDone(arg_80_1)
	if not self.live2dChar or not self.live2dChar:IsLoaded() then
		return
	end

	local var_80_0

	if type(arg_80_1) == "string" then
		var_80_0 = arg_80_1 == "damonds" and "diamond" or arg_80_1
	else
		local var_80_1 = ShopConst.GetShopConfig(arg_80_1)

		if var_80_1 and var_80_1.effect_args and type(var_80_1.effect_args) == "table" then
			for iter_80_0, iter_80_1 in ipairs(var_80_1.effect_args) do
				if iter_80_1 == 1 then
					var_80_0 = "gold"
				end
			end
		end
	end

	local var_80_2 = (self.preAniName == "gold" or self.preAniName == "diamond") and (var_80_0 == "gold" or var_80_0 == "diamond") or not (self.preAniName == "gold" or self.preAniName == "diamond")

	var_80_2 = var_80_0 and self.preAniName ~= var_80_0 and var_80_2

	if var_80_2 then
		self.preAniName = var_80_0

		self.live2dChar:TriggerAction(var_80_0, nil, true)
	end

	return var_80_2
end

function NewShopMainScene:playCV(arg_81_1)
	local var_81_0

	if pg.pay_level_award[arg_81_1] and pg.pay_level_award[arg_81_1].cv_key ~= "" then
		var_81_0 = "event:/cv/chargeShop/" .. pg.pay_level_award[arg_81_1].cv_key
	end

	if var_81_0 then
		self:stopCV()

		self._currentVoice = var_81_0

		pg.CriMgr.GetInstance():PlaySoundEffect_V3(var_81_0)
	end
end

function NewShopMainScene:stopCV()
	if self._currentVoice then
		pg.CriMgr.GetInstance():UnloadSoundEffect_V3(self._currentVoice)
	end

	self._currentVoice = nil
end

function NewShopMainScene:blurView()
	self:OverlayPanel(self.buttonList, {
		pbList = {
			self.buttonList:Find("leftBg")
		}
	})
end

function NewShopMainScene:unBlurView()
	self:UnOverlayPanel(self.buttonList, self._tf)
end

function NewShopMainScene:jpUIInit()
	if PLATFORM_CODE ~= PLATFORM_JP then
		return
	end

	self.userAgreeBtn3 = self._tf:Find("frame/raw1Btn")
	self.userAgreeBtn4 = self._tf:Find("frame/raw2Btn")
end

function NewShopMainScene:jpUIEnter()
	if PLATFORM_CODE ~= PLATFORM_JP then
		return
	end

	onButton(self, self.userAgreeBtn3, function()
		self:emit(NewShopMainMediator.OPEN_USER_AGREE, require("ShareCfg.UserAgreement3") or "")
	end, SFX_PANEL)
	onButton(self, self.userAgreeBtn4, function()
		self:emit(NewShopMainMediator.OPEN_USER_AGREE, require("ShareCfg.UserAgreement4") or "")
	end, SFX_PANEL)
end

function NewShopMainScene:addRefreshTimer(arg_89_1)
	local function var_89_0()
		if self.refreshTimer then
			self.refreshTimer:Stop()

			self.refreshTimer = nil
		end
	end

	var_89_0()

	self.refreshTimer = Timer.New(function()
		if arg_89_1 + 1 - pg.TimeMgr.GetInstance():GetServerTime() <= 0 then
			var_89_0()
			self:emit(NewShopMainMediator.GET_CHARGE_LIST)
		end
	end, 1, -1)

	self.refreshTimer:Start()
	self.refreshTimer.func()
end

function NewShopMainScene:InitSkinToggleList()
	self.uiSkinToggleParent = self.buttonList:Find("shop1List/skinShop/shop2List")
	self.uiSkinToggleItem = self.buttonList:Find("shop1List/skinShop/shop2List/skinToggleItem")

	setActive(self.buttonList:Find("shop1List/skinShop/shop1Tg/timeLimit"), #getProxy(ShipSkinProxy):GetInTimeSkins() > 0)

	self.skinShopList = self:GetSkinShopList()
	self.skinShopItemList = {}

	onToggle(self, self.buttonList:Find("shop1List/skinShop/shop1Tg"), function(arg_93_0)
		setActive(self.buttonList:Find("shop1List/skinShop/shop2List"), arg_93_0)

		if arg_93_0 then
			if self.shop1 == "skinShop" then
				return
			end

			self.shop1 = "skinShop"

			local var_93_0 = self.skinShopItemList[table.keyof(self.skinShopList, self:GetDefaultSkinShop())]

			var_93_0 = self.contextData.shop1 and self.contextData.shop2 and self.skinShopItemList[table.keyof(self.skinShopList, self.contextData.shop2)] or var_93_0
			self.contextData.shop1 = "skinShop"

			var_93_0:TriggerToggle()
		end
	end, SFX_PANEL)

	for iter_92_0, iter_92_1 in ipairs(self.skinShopList) do
		self.skinShopItemList[iter_92_0] = self.skinShopItemList[iter_92_0] or NewShopMainSkinToggleItem.New(Object.Instantiate(self.uiSkinToggleItem, self.uiSkinToggleParent), self)

		self.skinShopItemList[iter_92_0]:didEnter(iter_92_1)
	end
end

function NewShopMainScene:OnClickSkinShop(arg_94_1, arg_94_2)
	self.contextData.shop2 = arg_94_2

	if self.shop2 == arg_94_2 then
		return
	end

	self.shop2 = arg_94_2

	self:ShowChargeWarp(false)
	pg.m02:sendNotification(NewShopMainScene.CLOSE_ALL_LAYER)
	self:emit(NewShopMainMediator.OPEN_LAYER, LatestSkinShopLayer, LatestSkinShopMediator, {
		type = arg_94_2,
		mode = self.contextData.mode
	})
end

function NewShopMainScene:DisposeSkinToggleList()
	for iter_95_0, iter_95_1 in ipairs(self.skinShopItemList) do
		iter_95_1:willExit()
	end

	self.skinShopItemList = nil
end

function NewShopMainScene:GetSkinShopList()
	local var_96_0 = Clone(pg.shop_skin_subsheet.get_id_list_by_type[0])

	for iter_96_0 = #var_96_0, 1, -1 do
		local var_96_1 = {}

		if var_96_0[iter_96_0] == ShopConst.NEW_SKIN_SHOP_ID then
			var_96_1 = getProxy(ShipSkinProxy):GetInTimeSkins()
		elseif var_96_0[iter_96_0] == ShopConst.PERMANANT_SKIN_SHOP_ID then
			var_96_1 = getProxy(ShipSkinProxy):GetPermanentSkins()
		end

		if LOCK_SKIN_US then
			local var_96_2 = pg.gameset.levellimit_skintype.description

			if pg.gameset.levellimit_skintype.key_value >= getProxy(PlayerProxy):getData().level then
				var_96_1 = _.filter(var_96_1, function(arg_97_0)
					return table.contains(var_96_2, pg.ship_skin_template[arg_97_0:getSkinId()].shop_type_id)
				end)
			end
		end

		if self.contextData.mode == nil or self.contextData.mode == LatestSkinShopLayer.MODE_OVERVIEW then
			for iter_96_1 = #var_96_1, 1, -1 do
				if var_96_1[iter_96_1]:getConfig("genre") == ShopArgs.SkinShopTimeLimit then
					table.remove(var_96_1, iter_96_1)
				end
			end
		end

		if #var_96_1 <= 0 then
			table.remove(var_96_0, 1)
		end
	end

	local var_96_3 = pg.TimeMgr.GetInstance()
	local var_96_4 = getProxy(ShipSkinProxy):GetAllSkins()

	for iter_96_2, iter_96_3 in ipairs(pg.shop_skin_subsheet.get_id_list_by_type[1] or {}) do
		if var_96_3:inTime(pg.shop_skin_subsheet[iter_96_3].time) then
			for iter_96_4, iter_96_5 in ipairs(var_96_4) do
				if table.keyof(pg.shop_skin_subsheet[iter_96_3].param, iter_96_5.id) then
					table.insert(var_96_0, iter_96_3)

					break
				end
			end
		end
	end

	table.sort(var_96_0, function(arg_98_0, arg_98_1)
		return pg.shop_skin_subsheet[arg_98_0].sort == pg.shop_skin_subsheet[arg_98_0].sort and arg_98_0 < arg_98_1 or pg.shop_skin_subsheet[arg_98_0].sort < pg.shop_skin_subsheet[arg_98_1].sort
	end)

	return var_96_0
end

function NewShopMainScene:GetDefaultSkinShop()
	local var_99_0 = Clone(self.skinShopList)

	table.sort(var_99_0, function(arg_100_0, arg_100_1)
		local var_100_0 = pg.shop_skin_subsheet[arg_100_0]
		local var_100_1 = pg.shop_skin_subsheet[arg_100_1]

		if pg.shop_skin_subsheet[arg_100_0].shop_skin_subsheet == pg.shop_skin_subsheet[arg_100_1].shop_skin_subsheet then
			return var_100_0.sort == var_100_1.sort and arg_100_0 < arg_100_1 or var_100_0.sort < var_100_1.sort
		else
			return var_100_0.shop_skin_subsheet < var_100_1.shop_skin_subsheet
		end
	end)

	return var_99_0[1]
end

return NewShopMainScene
