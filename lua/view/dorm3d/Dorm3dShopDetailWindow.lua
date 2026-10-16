local Dorm3dShopDetailWindow = class("Dorm3dShopDetailWindow", import("view.base.BaseUI"))

Dorm3dShopDetailWindow.SELECTED_WIDTH = 52
Dorm3dShopDetailWindow.UNSELECTED_WIDTH = 12
Dorm3dShopDetailWindow.LOOP_DURATION = 5

function Dorm3dShopDetailWindow:getUIName()
	return "Dorm3dShopDetailWindow"
end

function Dorm3dShopDetailWindow:getResource()
	local var_2_0 = {
		"weaponframes",
		"ui/shoptip_atlas"
	}
	local var_2_1 = (self.contextData or {}).shopCfg

	local function var_2_2(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local function var_2_3(arg_4_0)
		for iter_4_0, iter_4_1 in ipairs(arg_4_0 or {}) do
			var_2_2("dorm3dbanner/" .. iter_4_1)
		end
	end

	if (self.contextData or {}).shopCfg then
		var_2_3(var_2_1.banners)

		if pg.dorm3d_gift[var_2_1.item_id] then
			for iter_2_0, iter_2_1 in ipairs(pg.dorm3d_gift[var_2_1.item_id].unlock_banners or {}) do
				var_2_3(iter_2_1[2])
			end
		end

		var_2_2(Drop.New({
			count = 0,
			type = DROP_TYPE_DORM3D_GIFT,
			id = var_2_1.item_id
		}):getIcon())
	end

	return table.insertto(var_2_0, Dorm3dShopDetailWindow.super.getResource(self))
end

function Dorm3dShopDetailWindow:init()
	self.previewTf = self._tf:Find("Window/Preview")
	self.bubbleContent = self._tf:Find("Window/Bubbles/content")
	self.bubbleTpl = self._tf:Find("Window/Bubbles/tpl")
	self.bubbleList = UIItemList.New(self.bubbleContent, self.bubbleTpl)
	self.scrollSnap = BannerScrollRect4Dorm.New(self._tf:Find("Window/banner/mask/content"), self._tf:Find("Window/banner/dots"))

	setActive(self.bubbleTpl, false)

	self.minusBtn = self._tf:Find("Window/countList/minusBtn")
	self.addBtn = self._tf:Find("Window/countList/addBtn")
	self.maxBtn = self._tf:Find("Window/countList/maxBtn")
	self.countText = self._tf:Find("Window/countList/count/Text")
	self.shopCfg = self.contextData.shopCfg
	self.unlockTips = pg.dorm3d_gift[self.shopCfg.item_id].unlock_tips or {}

	local var_5_0 = self.shopCfg.room_id

	self.unlockBanners = self.shopCfg.banners

	if self.contextData.groupId ~= 0 then
		var_5_0 = self.contextData.groupId

		local var_5_1 = table.Find(pg.dorm3d_gift[self.shopCfg.item_id].unlock_banners or {}, function(arg_6_0, arg_6_1)
			if arg_6_1[1] == var_5_0 then
				return true
			end
		end)

		self.unlockBanners = var_5_1 and var_5_1[2]
	end

	self.isExclusive = pg.dorm3d_gift[self.shopCfg.item_id].ship_group_id ~= 0
	self.isSpecial = false
	self.addFavor = pg.dorm3d_favor_trigger[pg.dorm3d_gift[self.shopCfg.item_id].favor_trigger_id].num

	setActive(self._tf:Find("Window/Title/gift"), true)

	self.curCount = 1
	self.buyCount = getProxy(ApartmentProxy):GetGiftShopCount(self.shopCfg.item_id)
end

function Dorm3dShopDetailWindow:didEnter()
	onButton(self, self._tf:Find("Window/Cancel"), function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Mask"), function()
		self:closeView()
	end)
	self:InitUIList()
	self:InitDropIcon()
	self:InitBanner()

	local var_7_0 = Dorm3dGift.New({
		configId = self.shopCfg.item_id
	})
	local var_7_1 = CommonCommodity.New({
		id = var_7_0:GetShopID()
	}, Goods.TYPE_SHOPSTREET)
	local var_7_2, var_7_3, var_7_4 = var_7_1:GetPrice()
	local var_7_5 = Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = var_7_1:GetResType(),
		count = var_7_2
	})
	local var_7_6 = i18n("dorm3d_shop_buy_tips", "<icon name=" .. var_7_1:GetResIcon() .. " w=1.1 h=1.1/>", "x" .. var_7_5.count, "x" .. var_7_5.count, self.shopCfg.name)
	local var_7_7
	local var_7_8 = 0

	_.each(var_7_0:getConfig("shop_id"), function(arg_10_0)
		local var_10_0 = ShopConst.GetShopConfig(arg_10_0)

		if var_10_0.group_type == 2 then
			var_7_8 = math.max(var_10_0.group_limit, var_7_8)
		end
	end)

	if 0 > 0 then
		var_7_7 = {
			self.buyCount,
			0
		}
	end

	if var_7_7 then
		var_7_6 = var_7_6 .. i18n("dorm3d_purchase_weekly_limit", var_7_7[1], var_7_7[2])
	end

	setText(self._tf:Find("Window/Content"), var_7_6)
	setText(self._tf:Find("Window/Confirm/Text"), i18n("msgbox_text_confirm"))
	setText(self._tf:Find("Window/Cancel/Text"), i18n("msgbox_text_cancel"))
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)

	local var_7_9 = var_7_0:GetShopID()

	self.itemList = {
		var_7_9
	}
	self.sumPrice = self:GetGoodPrice(var_7_9)

	setText(self.countText, self.curCount)

	local var_7_10 = 1

	if var_7_7 then
		var_7_10 = var_7_7[2] - var_7_7[1]
	end

	local function var_7_11(arg_11_0)
		arg_11_0 = math.max(arg_11_0, 1)
		arg_11_0 = math.min(arg_11_0, var_7_10)
		self.curCount = arg_11_0

		setText(self.countText, arg_11_0)

		self.sumPrice = 0

		for iter_11_0 = self.buyCount, self.buyCount + self.curCount - 1 do
			self.sumPrice = self.sumPrice + self:GetGoodPrice(self:GetShopId(iter_11_0))
		end

		local var_11_0 = i18n("dorm3d_shop_buy_tips", "<icon name=" .. var_7_1:GetResIcon() .. " w=1.1 h=1.1/>", "x" .. self:GetGoodPrice((self:GetShopId(self.buyCount + self.curCount - 1))), "x" .. self.sumPrice, self.shopCfg.name)

		if var_7_7 then
			var_11_0 = var_11_0 .. i18n("dorm3d_purchase_weekly_limit", var_7_7[1], var_7_7[2])
		end

		setText(self._tf:Find("Window/Content"), var_11_0)
		self.contextData.changeCount(arg_11_0)
	end

	onButton(self, self.minusBtn, function()
		if self.curCount - 1 > 0 then
			table.remove(self.itemList, #self.itemList)
		end

		var_7_11(self.curCount - 1)
	end, SFX_PANEL)
	onButton(self, self.addBtn, function()
		if self.buyCount + self.curCount + 1 <= var_7_8 then
			table.insert(self.itemList, self:GetShopId(self.buyCount + self.curCount))
		end

		var_7_11(self.curCount + 1)
	end, SFX_PANEL)
	onButton(self, self.maxBtn, function()
		self.itemList = {}

		for iter_14_0 = self.buyCount, var_7_8 - 1 do
			table.insert(self.itemList, self:GetShopId(iter_14_0))
		end

		var_7_11(var_7_10)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Window/Confirm"), function()
		local var_15_0 = getProxy(PlayerProxy):getData()
		local var_15_1 = ShopConst.GetShopConfig(self.itemList[1])

		if var_15_0[id2res(var_15_1.resource_type)] < self.sumPrice then
			if var_15_1.resource_type == 1 then
				GoShoppingMsgBox(i18n("switch_to_shop_tip_2", i18n("word_gold")), ChargeScene.TYPE_ITEM, {
					{
						59001,
						self.sumPrice - var_15_0[id2res(var_15_1.resource_type)],
						self.sumPrice
					}
				})
			elseif var_15_1.resource_type == 4 or var_15_1.resource_type == 14 then
				GoShoppingMsgBox(i18n("switch_to_shop_tip_3", i18n("word_gem")), ChargeScene.TYPE_DIAMOND)
			elseif not ItemTipPanel.ShowItemTip(DROP_TYPE_RESOURCE, var_15_1.resource_type) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("buyProp_noResource_error", (Drop.New({
					type = DROP_TYPE_RESOURCE,
					id = var_15_1.resource_type
				}):getName())))
			end

			self:closeView()

			return
		end

		for iter_15_0, iter_15_1 in ipairs(self.itemList) do
			self:emit(Dorm3dShopDetailMediator.SHOPPING, {
				silentTip = true,
				count = 1,
				shopId = iter_15_1
			})
		end

		self:closeView()
	end, SFX_PANEL)
end

function Dorm3dShopDetailWindow:InitBanner()
	for iter_16_0 = 1, #self.unlockBanners do
		LoadImageSpriteAsync("dorm3dbanner/" .. self.unlockBanners[iter_16_0], (self.scrollSnap:AddChild()))
	end

	self.scrollSnap:SetUp()
end

function Dorm3dShopDetailWindow:InitUIList()
	self.bubbleList:make(function(arg_18_0, arg_18_1, arg_18_2)
		if arg_18_0 == UIItemList.EventInit then
			LoadImageSpriteAtlasAsync("ui/shoptip_atlas", "icon_" .. self.unlockTips[arg_18_1 + 1], arg_18_2:Find("icon/icon"), true)
			setText(arg_18_2:Find("bubble/Text"), i18n("dorm3d_shop_tag" .. self.unlockTips[arg_18_1 + 1]))
			setActive(arg_18_2:Find("bubble"), false)
			onToggle(self, arg_18_2, function(arg_19_0)
				setActive(arg_18_2:Find("icon/select"), arg_19_0)
				setActive(arg_18_2:Find("icon/unselect"), not arg_19_0)
				setActive(arg_18_2:Find("bubble"), arg_19_0)
			end)
		end
	end)
	self.bubbleList:align(#self.unlockTips)
end

function Dorm3dShopDetailWindow:InitDropIcon()
	local var_20_0 = {
		type = DROP_TYPE_DORM3D_GIFT,
		id = self.shopCfg.item_id
	}

	var_20_0.count = getProxy(ApartmentProxy):getGiftCount(self.shopCfg.item_id)

	LoadImageSpriteAtlasAsync(Drop.New(var_20_0):getIcon(), "", self._tf:Find("Window/Item/Dorm3dIconTpl/icon"), true)
	GetImageSpriteFromAtlasAsync("weaponframes", "dorm3d_" .. ItemRarity.Rarity2Print(self.shopCfg.rarity), self._tf:Find("Window/Item/Dorm3dIconTpl"))
	setActive(self._tf:Find("Window/Item/sp"), self.isExclusive or self.isSpecial)

	if self.isSpecial then
		setText(self._tf:Find("Window/Item/sp/Text"), i18n("dorm3d_purchase_label_special"))
	elseif self.isExclusive then
		setText(self._tf:Find("Window/Item/sp/Text"), i18n("dorm3d_purchase_confirm_tip"))
	end

	if self.addFavor then
		setActive(self._tf:Find("Window/Item/gift"), true)
		setText(self._tf:Find("Window/Item/gift/Text"), "+" .. self.addFavor)
	end
end

function Dorm3dShopDetailWindow:GetShopId(arg_21_1)
	for iter_21_0 = 1, #self.shopCfg.shop_id - 1 do
		local var_21_0 = ShopConst.GetShopConfig(self.shopCfg.shop_id[iter_21_0])

		if not var_21_0.limit_args[1] and var_21_0.group_type == 0 then
			return self.shopCfg.shop_id[iter_21_0]
		elseif var_21_0.limit_args[1] and (var_21_0.limit_args[1][1] == "dailycount" or var_21_0.limit_args[1][1] == "count") then
			if arg_21_1 < var_21_0.limit_args[1][3] then
				return self.shopCfg.shop_id[iter_21_0]
			end
		elseif var_21_0.group_type == 2 then
			if arg_21_1 < var_21_0.group_limit then
				return self.shopCfg.shop_id[iter_21_0]
			end
		else
			return self.shopCfg.shop_id[iter_21_0]
		end
	end

	return self.shopCfg.shop_id[#self.shopCfg.shop_id] or 0
end

function Dorm3dShopDetailWindow:GetGoodPrice(arg_22_1)
	return (CommonCommodity.New({
		id = arg_22_1
	}, Goods.TYPE_SHOPSTREET):GetPrice())
end

function Dorm3dShopDetailWindow:willExit()
	if self.timerRefreshTime then
		self.timerRefreshTime:Stop()

		self.timerRefreshTime = nil
	end

	self.scrollSnap:Dispose()

	self.scrollSnap = nil

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return Dorm3dShopDetailWindow
