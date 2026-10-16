local ChargeMenuScene = class("ChargeMenuScene", import("...base.BaseUI"))

function ChargeMenuScene:getUIName()
	return "ChargeMenuUI"
end

function ChargeMenuScene:preload(arg_2_1)
	if getProxy(ShopsProxy):ShouldRefreshChargeList() then
		pg.m02:sendNotification(GAME.GET_CHARGE_LIST, {
			callback = arg_2_1
		})
	else
		arg_2_1()
	end
end

function ChargeMenuScene:getResource()
	local var_3_0 = ChargeMenuScene.super.getResource(self)
	local var_3_1 = {}

	local function var_3_2(arg_4_0)
		if noEmptyStr(arg_4_0) and not table.contains(var_3_1, arg_4_0) then
			table.insert(var_3_1, arg_4_0)
		end
	end

	local var_3_3 = getProxy(ActivityProxy)
	local var_3_4 = var_3_3 and var_3_3:getActiveBannerByType(GAMEUI_BANNER_9)

	if var_3_4 then
		var_3_2("activitybanner/" .. var_3_4.pic)
	end

	local var_3_5 = var_3_3 and var_3_3:getActiveBannerByType(GAMEUI_BANNER_11)

	if var_3_5 then
		var_3_2("activitybanner/" .. var_3_5.pic)
	end

	local var_3_6 = getProxy(ShopsProxy)

	if var_3_6 then
		for iter_3_0, iter_3_1 in ipairs(var_3_6:GetRecommendCommodities() or {}) do
			var_3_2(iter_3_1:GetIcon())
		end
	end

	var_3_2("ui/ChargeTipUI")
	var_3_2("ui/MonthCardTipWindow")
	var_3_2("ui/GiftPackageTipWindow")
	var_3_2("ui/CrusingTipWindow")

	for iter_3_2, iter_3_3 in ipairs(var_3_1) do
		if not table.contains(var_3_0, iter_3_3) then
			table.insert(var_3_0, iter_3_3)
		end
	end

	return var_3_0
end

function ChargeMenuScene:init()
	self:initData()
	self:findUI()
	self:addListener()
	self:initUIText()
	self:InitBanner()
end

function ChargeMenuScene:didEnter()
	self:updatePlayerRes()
	self:updatePanel()
	self:tryAutoOpenShop()
end

function ChargeMenuScene:ResUISettings()
	return true
end

function ChargeMenuScene:onBackPressed()
	if self.chargeTipWindow and self.chargeTipWindow:GetLoaded() and self.chargeTipWindow:isShowing() then
		self.chargeTipWindow:Hide()

		return
	end

	ChargeMenuScene.super.onBackPressed(self)
end

function ChargeMenuScene:willExit()
	if self.bannerRect then
		self.bannerRect:Dispose()

		self.bannerRect = nil
	end

	if self.chargeOrPurchaseHandler then
		self.chargeOrPurchaseHandler:Dispose()

		self.chargeOrPurchaseHandler = nil
	end

	if self.chargeTipWindow then
		self.chargeTipWindow:Destroy()

		self.chargeTipWindow = nil
	end
end

function ChargeMenuScene:initData()
	return
end

function ChargeMenuScene:initUIText()
	return
end

function ChargeMenuScene:findUI()
	self.blurTF = self._tf:Find("blur_panel")
	self.topTF = self.blurTF:Find("adapt/top")
	self.resTF = self.topTF:Find("res")
	self.backBtn = self.topTF:Find("back_button")
	self.menuTF = self._tf:Find("menu_screen")
	self.skinShopBtn = self.menuTF:Find("skin_shop")
	self.skinLockIcon = self.menuTF:Find("skin_lock")

	local var_12_0 = LOCK_SKIN_SHOP_ENTER and getProxy(PlayerProxy):getData().level < LOCK_SKIN_SHOP_ENTER_LEVEL

	setActive(self.skinShopBtn, not var_12_0)
	setActive(self.skinLockIcon, var_12_0)

	self.diamondShopBtn = self.menuTF:Find("dimond_shop")
	self.itemShopBtn = self.menuTF:Find("props")
	self.giftShopBtn = self.menuTF:Find("gift_shop")
	self.supplyShopBtn = self.menuTF:Find("supply")
	self.monthCardTag = self.diamondShopBtn:Find("monthcard_tag")
	self.giftTag = self.giftShopBtn:Find("tip")
	self.bannerRect = BannerScrollRect.New(self._tf:Find("menu_screen/banner/mask/content"), self._tf:Find("menu_screen/banner/dots"))
	self.chargeOrPurchaseHandler = ChargeOrPurchaseHandler.New()
	self.chargeTipWindow = ChargeTipWindow.New(self._tf, self.event)
end

local function var_0_1(arg_13_0, arg_13_1, arg_13_2)
	setText(arg_13_1:Find("name"), arg_13_2:GetName())
	setText(arg_13_1:Find("desc"), arg_13_2:GetDesc())

	local var_13_0 = arg_13_2:GetDropList()
	local var_13_1 = UIItemList.New(arg_13_1:Find("items"), arg_13_1:Find("items/award"))

	var_13_1:make(function(arg_14_0, arg_14_1, arg_14_2)
		if arg_14_0 == UIItemList.EventUpdate then
			local var_14_0 = var_13_0[arg_14_1 + 1]

			updateDrop(arg_14_2, var_13_0[arg_14_1 + 1])
			onButton(arg_13_0, arg_14_2, function()
				arg_13_0:emit(BaseUI.ON_DROP, var_14_0)
			end, SFX_PANEL)
		end
	end)
	var_13_1:align(#var_13_0)

	local var_13_2 = arg_13_2:GetGem()

	setActive(arg_13_1:Find("gem"), var_13_2 > 0)
	setText(arg_13_1:Find("gem/Text"), var_13_2)

	local var_13_3, var_13_4, var_13_5 = arg_13_2:GetPrice()

	setText(arg_13_1:Find("price/Text"), var_13_4)
	setActive(arg_13_1:Find("price/Text/icon"), var_13_3 ~= RecommendCommodity.PRICE_TYPE_RMB)
	setText(arg_13_1:Find("price/Text/label"), var_13_3 == RecommendCommodity.PRICE_TYPE_RMB and GetMoneySymbol() or "")

	local var_13_6 = arg_13_1:Find("icon")

	GetSpriteFromAtlasAsync(arg_13_2:GetIcon(), "", function(arg_16_0)
		setImageSprite(var_13_6, arg_16_0)
	end)

	var_13_6.sizeDelta = Vector2(180, 180)
end

function ChargeMenuScene:InitBanner()
	for iter_17_0, iter_17_1 in ipairs((getProxy(ShopsProxy):GetRecommendCommodities())) do
		local var_17_0 = self.bannerRect:AddChild()

		var_0_1(self, var_17_0, iter_17_1)
		onButton(self, var_17_0, function()
			local var_18_0, var_18_1 = iter_17_1:IsMonthCardAndCantPurchase()

			if var_18_0 then
				pg.TipsMgr.GetInstance():ShowTips(var_18_1)

				return
			end

			self.bannerRect:Pause()

			self.lookUpIndex = iter_17_0

			pg.m02:sendNotification(GAME.TRACK, TrackConst.GetTrackData(TrackConst.SYSTEM_SHOP, TrackConst.ACTION_LOOKUP_RECOMMEND, iter_17_0))
			self.chargeOrPurchaseHandler:ChargeOrPurchaseAsyn(iter_17_1:GetRealCommodity())
		end, SFX_PANEL)
	end

	self.bannerRect:SetUp()
end

function ChargeMenuScene:FlushBanner()
	self.bannerRect:Reset()
	self:InitBanner()
end

function ChargeMenuScene:addListener()
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.skinShopBtn, function()
		self:emit(ChargeMenuMediator.GO_SKIN_SHOP)
	end, SFX_PANEL)
	onButton(self, self.diamondShopBtn, function()
		self:emit(ChargeMenuMediator.GO_CHARGE_SHOP, ChargeScene.TYPE_DIAMOND)
	end, SFX_PANEL)
	onButton(self, self.giftShopBtn, function()
		self:emit(ChargeMenuMediator.GO_CHARGE_SHOP, ChargeScene.TYPE_GIFT)
		pg.m02:sendNotification(GAME.TRACK, TrackConst.GetTrackData(TrackConst.SYSTEM_SHOP, TrackConst.ACTION_ENTER_GIFT, (isActive(self.giftTag))))
	end, SFX_PANEL)
	onButton(self, self.itemShopBtn, function()
		self:emit(ChargeMenuMediator.GO_CHARGE_SHOP, ChargeScene.TYPE_ITEM)
	end, SFX_PANEL)
	onButton(self, self.supplyShopBtn, function()
		self:emit(ChargeMenuMediator.GO_SUPPLY_SHOP, {
			warp = NewShopsScene.TYPE_ACTIVITY
		})
	end, SFX_PANEL)
end

function ChargeMenuScene:updatePlayerRes()
	return
end

function ChargeMenuScene:updatePanel()
	local var_28_0 = getProxy(ActivityProxy)
	local var_28_1 = var_28_0:getActiveBannerByType(GAMEUI_BANNER_9)

	if var_28_1 ~= nil then
		LoadImageSpriteAsync("activitybanner/" .. var_28_1.pic, self.skinShopBtn)
	end

	local var_28_2 = var_28_0:getActiveBannerByType(GAMEUI_BANNER_11)

	if var_28_2 ~= nil then
		LoadImageSpriteAsync("activitybanner/" .. var_28_2.pic, self.giftShopBtn:Find("BG"))
	end

	setActive(self.monthCardTag, (MonthCardOutDateTipPanel.GetShowMonthCardTag()))
	MonthCardOutDateTipPanel.SetMonthCardTagDate()
	TagTipHelper.SetFuDaiTagMark()
	TagTipHelper.SetSkinTagMark()
	TagTipHelper.FreeGiftTag({
		self.giftTag
	})
end

function ChargeMenuScene:tryAutoOpenShop()
	if self.contextData.warp ~= nil then
		if self.contextData.warp == ChargeScene.TYPE_DIAMOND then
			triggerButton(self.diamondShopBtn)
		elseif self.contextData.warp == ChargeScene.TYPE_GIFT then
			triggerButton(self.giftShopBtn)
		elseif self.contextData.warp == ChargeScene.TYPE_ITEM then
			triggerButton(self.itemShopBtn)
		end
	end
end

function ChargeMenuScene:OnRemoveLayer(arg_30_1)
	if arg_30_1.mediator == ChargeItemPanelMediator and self.bannerRect then
		self.bannerRect:Resume()
	end
end

function ChargeMenuScene:OnChargeSuccess(arg_31_1)
	self.chargeTipWindow:ExecuteAction("Show", arg_31_1)
end

return ChargeMenuScene
