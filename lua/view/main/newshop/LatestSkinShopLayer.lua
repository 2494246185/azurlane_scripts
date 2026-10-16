local LatestSkinShopLayer = class("LatestSkinShopLayer", import("...base.BaseUI"))

LatestSkinShopLayer.MODE_OVERVIEW = 1
LatestSkinShopLayer.MODE_EXPERIENCE = 2
LatestSkinShopLayer.MODE_EXPERIENCE_FOR_ITEM = 3

local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = 3
local var_0_4 = 1
local var_0_5 = 2
local var_0_6 = 3
local var_0_7 = 4
local var_0_8 = 5
local var_0_9 = 6
local var_0_10 = 7
local var_0_11 = 8
local var_0_12 = -1
local var_0_13 = -2
local var_0_14 = -3
local var_0_15 = -4
local var_0_16 = 9999
local var_0_17 = 9997
local var_0_18 = 9998

LatestSkinShopLayer.EVT_SHOW_OR_HIDE_PURCHASE_VIEW = "NewSkinShopMainView:EVT_SHOW_OR_HIDE_PURCHASE_VIEW"
LatestSkinShopLayer.EVT_ON_PURCHASE = "NewSkinShopMainView:EVT_ON_PURCHASE"

function LatestSkinShopLayer:Ctor()
	LatestSkinShopLayer.super.Ctor(self)
end

local function var_0_19(arg_2_0)
	LatestSkinShopLayer.obtainBtnSpriteNames = LatestSkinShopLayer.obtainBtnSpriteNames or {
		[var_0_4] = "yigoumai_button",
		[var_0_5] = "goumai_button",
		[var_0_6] = "qianwanghuoqu_button",
		[var_0_7] = "item_buy",
		[var_0_8] = "furniture_shop",
		[var_0_9] = "tiyan_btn",
		[var_0_10] = "item_buy",
		[var_0_11] = "buy_with_gift"
	}

	return LatestSkinShopLayer.obtainBtnSpriteNames[arg_2_0]
end

function LatestSkinShopLayer:getUIName()
	return "LatestSkinShopUI"
end

function LatestSkinShopLayer:getGroupName()
	return "NewShopMainScene"
end

local function var_0_20(arg_5_0, arg_5_1)
	local var_5_0 = {}

	if arg_5_0 == ShopConst.NEW_SKIN_SHOP_ID then
		var_5_0 = getProxy(ShipSkinProxy):GetInTimeSkins()
	elseif arg_5_0 == ShopConst.PERMANANT_SKIN_SHOP_ID then
		var_5_0 = getProxy(ShipSkinProxy):GetPermanentSkins()
	else
		local var_5_1 = pg.shop_skin_subsheet[arg_5_0]

		for iter_5_0, iter_5_1 in ipairs(getProxy(ShipSkinProxy):GetAllSkins()) do
			if var_5_1 and table.keyof(var_5_1.param, iter_5_1.id) then
				table.insert(var_5_0, iter_5_1)
			end
		end
	end

	if LOCK_SKIN_US then
		local var_5_2 = pg.gameset.levellimit_skintype.description

		if pg.gameset.levellimit_skintype.key_value >= getProxy(PlayerProxy):getData().level then
			var_5_0 = _.filter(var_5_0, function(arg_6_0)
				return table.contains(var_5_2, pg.ship_skin_template[arg_6_0:getSkinId()].shop_type_id)
			end)
		end
	end

	if arg_5_1 == LatestSkinShopLayer.MODE_OVERVIEW then
		for iter_5_2 = #var_5_0, 1, -1 do
			if var_5_0[iter_5_2]:getConfig("genre") == ShopArgs.SkinShopTimeLimit then
				table.remove(var_5_0, iter_5_2)
			end
		end
	end

	return var_5_0
end

local function var_0_21(arg_7_0)
	local var_7_0 = {}

	for iter_7_0, iter_7_1 in ipairs(arg_7_0) do
		local var_7_1 = pg.ship_skin_template[iter_7_1:getSkinId()]

		if var_7_1 then
			table.insertto(var_7_0, ResPathSupport.GetPaintingShipYardIconListByPaintingName(var_7_1.prefab))
			table.insertto(var_7_0, ResPathSupport.GetPaintingShipYardIconListByPaintingName(var_7_1.painting))
		end

		if iter_7_1.type == Goods.TYPE_SKIN then
			local var_7_2 = Item.getConfigData(id2ItemId((iter_7_1:getConfig("resource_type"))))

			if var_7_2 and var_7_2.icon then
				table.insert(var_7_0, var_7_2.icon)
			end
		end
	end

	return var_7_0
end

local function var_0_22(arg_8_0)
	local var_8_0 = {
		arg_8_0
	}

	if not ShipSkin.IsChangeSkin(arg_8_0) then
		return var_8_0
	end

	local var_8_1 = {
		[arg_8_0] = true
	}
	local var_8_2 = arg_8_0

	for iter_8_0 = 1, 10 do
		local var_8_3 = ShipSkin.GetChangeSkinData(arg_8_0)
		local var_8_4 = var_8_3 and var_8_3.next

		if not (var_8_3 and var_8_3.next) or var_8_1[var_8_4] or not pg.ship_skin_template[var_8_4] then
			break
		end

		var_8_1[var_8_4] = true

		table.insert(var_8_0, var_8_4)

		var_8_2 = var_8_4
	end

	return var_8_0
end

local function var_0_23(arg_9_0)
	local var_9_0 = {}

	for iter_9_0, iter_9_1 in ipairs(var_0_22(arg_9_0)) do
		if pg.ship_skin_template[iter_9_1] then
			if pg.ship_skin_template[iter_9_1].skin_type ~= ShipSkin.SKIN_TYPE_TB then
				table.insertto(var_9_0, ResPathSupport.GetSpineCharListByPrefabName(pg.ship_skin_template[iter_9_1].prefab))
				table.insertto(var_9_0, ResPathSupport.GetSpineQIconListByPrefabName(pg.ship_skin_template[iter_9_1].painting))
			end

			table.insertto(var_9_0, ResPathSupport.GetPaintingListByPaintingName(pg.ship_skin_template[iter_9_1].painting))

			if pg.ship_skin_template[iter_9_1].painting and #pg.ship_skin_template[iter_9_1].painting > 0 then
				for iter_9_2, iter_9_3 in ipairs({
					"_shop",
					"_n_shop"
				}) do
					table.insert(var_9_0, string.lower(string.format(ResPathSupport.ConstPath.Painting.Base, pg.ship_skin_template[iter_9_1].painting, iter_9_3)))
				end
			end

			table.insertto(var_9_0, ResPathSupport.GetShipSkinPaintingFaceList(iter_9_1))
			table.insertto(var_9_0, ResPathSupport.GetShipSkinBgList(iter_9_1))

			if pg.ship_skin_template[iter_9_1].ship_group and pg.ship_skin_template[iter_9_1].skin_type ~= ShipSkin.SKIN_TYPE_TB then
				local var_9_1 = ShipGroup.getDefaultShipConfig(pg.ship_skin_template[iter_9_1].ship_group)

				if var_9_1 and pg.ship_data_statistics[var_9_1.id] then
					table.insertto(var_9_0, ResPathSupport.GetShipRarityBgList(var_9_1.id))
				end
			end

			if PaintingGroupConst.IsPaintingNeedCheck() and pg.ship_skin_template[iter_9_1].painting and #pg.ship_skin_template[iter_9_1].painting > 0 then
				PaintingGroupConst.AddPaintingNameWithFilteMap(var_9_0, pg.ship_skin_template[iter_9_1].painting)
			end
		end
	end

	return ResPathSupport.UniqueLuaArr(var_9_0)
end

function LatestSkinShopLayer:getResource()
	local var_10_0 = self.contextData

	local function var_10_1(arg_11_0)
		local var_11_0 = Goods.Create({
			shop_id = arg_11_0
		}, Goods.TYPE_CHARGE)
		local var_11_1 = getProxy(ShopsProxy):getChargedList()

		var_11_1 = var_11_1 or {}

		var_11_0:updateBuyCount((ChargeConst.getBuyCount(var_11_1, var_11_0.id)))

		return var_11_0
	end

	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(LatestSkinShopLayer.super.getResource(self), {
		"ui/LatestSkinShopUI",
		"ui/SkinShopUI_atlas",
		"skinicon"
	}, (var_0_21((function()
		if var_10_0.skinCommodities then
			return var_10_0.skinCommodities
		end

		if var_10_0.commodityId or var_10_0.giftPackCommodity then
			return getProxy(ShipSkinProxy):GetProbabilitySkins(((var_10_0.giftPackCommodity or var_10_1(var_10_0.commodityId)):GetSkinProbability()))
		end

		return var_0_20(var_10_0.type or ShopConst.PERMANANT_SKIN_SHOP_ID, var_10_0.mode or LatestSkinShopLayer.MODE_OVERVIEW)
	end)()))))
end

function LatestSkinShopLayer:init()
	self.bgs = self._tf:Find("bgs")
	self.adapt = self._tf:Find("adapt")
	self.top = self.adapt:Find("top")
	self.bottom = self.adapt:Find("bottom")
	self.right = self.adapt:Find("right")
	self.subPage = self.adapt:Find("subPage")
	self.resources = self.adapt:Find("top/resources")
	self.limitTime = self.adapt:Find("top/title/limit_time/Text")
	self.skinName = self.adapt:Find("top/title/skin_name_mask/skin_name")
	self.shipName = self.adapt:Find("top/title/name_mask/name")
	self.changeSkin = self.adapt:Find("top/change_skin")
	self.changeSkinToggle = ChangeSkinToggle.New(findTF(self.changeSkin, "toggle_ui"))
	self.showOwnBtn = self.adapt:Find("bottom/showOwnBtn")
	self.filterBtn = self.adapt:Find("bottom/filterBtn")
	self.search = self.adapt:Find("bottom/search")
	self.scrollrect = self.adapt:Find("bottom/scroll/content"):GetComponent("LScrollRect")
	self.sdTg = self.adapt:Find("right/sdTg")
	self.hideUITg = self.adapt:Find("right/hideUITg")
	self.charContainer = self.adapt:Find("right/char_container")
	self.backChara = self.charContainer:Find("bg/back/chara")
	self.charTf = self.charContainer:Find("char")
	self.furnitureContainer = self.charContainer:Find("fur")
	self.switchPreviewBtn = self.charContainer:Find("switch")
	self.dynamicToggle = self.adapt:Find("right/functionsAndTags/dynamic")
	self.dynamicIcon = self.adapt:Find("right/functionsAndTags/dynamic/icon")
	self.showBgToggle = self.adapt:Find("right/functionsAndTags/showBg")
	self.dynamicResToggle = self.adapt:Find("right/functionsAndTags/dynamic/l2d_res_state")
	self.tagList = UIItemList.New(self.adapt:Find("right/functionsAndTags/tags"), self.adapt:Find("right/functionsAndTags/tags/tag"))
	self.giftPackBtn = self.adapt:Find("right/giftPackBtn")
	self.price = self.adapt:Find("right/price")
	self.btnsList = {
		self.price:Find("normal/btns"),
		self.price:Find("charge/btns")
	}
	self.filterUI = self.adapt:Find("subPage/filterUI")
	self.filterContent = self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content")
	self.painting = self._tf:Find("painting")
	self.paintingTF = self._tf:Find("painting/paint")
	self.defaultPaintingPosition = self.paintingTF.anchoredPosition
	self.defaultPaintingScale = self.paintingTF.localScale
	self.live2dContainer = self._tf:Find("painting/paint/live2d")
	self.spTF = self._tf:Find("painting/paint/spinePainting")
	self.spBg = self._tf:Find("painting/paintBg/spinePainting")

	setActive(self.charContainer, false)
	setActive(self.filterUI, false)

	self.mainTitle = self.adapt:Find("top/mainTitle")
	self.backBtn = self.adapt:Find("top/closeBtn")
	self.homeBtn = self.adapt:Find("top/homeBtn")
	self.giftPack = self.adapt:Find("giftPack")

	setActive(self.mainTitle, false)
	setActive(self.backBtn, false)
	setActive(self.homeBtn, false)
	setActive(self.giftPack, false)

	self.downloads = {}
	self.isToggleDynamic = false
	self.isToggleShowBg = true
	self.isPreviewFurniture = false
	self.interactionPreview = BackYardInteractionPreview.New(self.furnitureContainer, Vector3(0, 0, 0))
	self.voucherMsgBox = SkinVoucherMsgBox.New(pg.UIMgr.GetInstance().OverlayMain)
	self.purchaseView = NewSkinShopPurchaseView.New(self._tf, self.event)

	self:RegisterEvent()
	setText(self._tf:Find("bgs/empty/Text"), i18n("shop_new_unfound"))
	setText(self.adapt:Find("top/mainTitle/Text"), i18n("shop_new_shop"))
	setText(self.filterBtn:Find("Text"), i18n("shop_new_sort"))
	setText(self.search:Find("holder"), i18n("shop_new_search"))

	for iter_13_0, iter_13_1 in ipairs(self.btnsList) do
		setText(iter_13_1:Find("yigoumai_button/Text"), i18n("shop_new_purchased"))
		setText(iter_13_1:Find("goumai_button/Text"), i18n("shop_new_purchase"))
		setText(iter_13_1:Find("qianwanghuoqu_button/Text"), i18n("shop_new_claim"))
		setText(iter_13_1:Find("furniture_shop/Text"), i18n("shop_new_furniture"))
		setText(iter_13_1:Find("item_buy/Text"), i18n("shop_new_discount"))
		setText(iter_13_1:Find("tiyan_btn/Text"), i18n("shop_new_try"))
		setText(iter_13_1:Find("buy_with_gift/Text"), i18n("shop_new_purchase"))
	end

	setText(self.btnsList[2]:Find("buy_charge/Text"), i18n("shop_new_purchase"))
	setText(self.price:Find("btn/tag/Text"), i18n("shop_new_gift"))
	setText(self.giftPack:Find("panel/desc"), i18n("shop_new_gem_transform"))
	setText(self.giftPack:Find("price/btns/yigoumai_button/Text"), i18n("shop_new_purchased"))
	setText(self.filterUI:Find("panelMask/panel/title"), i18n("shop_new_sort"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/own/subTitleFrame/subTitle"), i18n("shop_new_review"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/own/options/0/Text"), i18n("shop_new_all"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/own/options/1/Text"), i18n("shop_new_owned"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/own/options/2/Text"), i18n("shop_new_havent_own"))
	setScrollText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/own/options/3/mask/Text"), i18n("shop_new_unused"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/subTitleFrame/subTitle"), i18n("shop_new_type"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/options/0/Text"), i18n("shop_new_all"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/options/2/Text"), i18n("shop_new_static"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/options/3/Text"), i18n("shop_new_dynamic"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/options/4/Text"), i18n("shop_new_static_bg"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/options/5/Text"), i18n("shop_new_dynamic_bg"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/type/options/6/Text"), i18n("shop_new_bgm"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/shipHave/subTitleFrame/subTitle"), i18n("shop_new_index"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/shipHave/options/0/Text"), i18n("shop_new_all"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/shipHave/options/1/Text"), i18n("shop_new_ship_owned"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/shipHave/options/2/Text"), i18n("shop_new_ship_havent_owned"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/camp/subTitleFrame/subTitle"), i18n("shop_new_nation"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/rarity/subTitleFrame/subTitle"), i18n("shop_new_rarity"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/shipType/subTitleFrame/subTitle"), i18n("shop_new_category"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/themeType/subTitleFrame/subTitle"), i18n("shop_new_skin_theme"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/subTitleFrame/subTitle"), i18n("skin_shop_tag"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/0/Text"), i18n("skin_shop_tag_0"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/1/Text"), i18n("skin_shop_tag_1"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/2/Text"), i18n("skin_shop_tag_2"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/3/Text"), i18n("skin_shop_tag_3"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/4/Text"), i18n("skin_shop_tag_4"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/5/Text"), i18n("skin_shop_tag_5"))
	setText(self.filterUI:Find("panelMask/panel/filterScroll/Viewport/Content/tag/options/6/Text"), i18n("skin_shop_tag_6"))
	setText(self.filterUI:Find("panelMask/panel/bottom/ok/Text"), i18n("shop_new_confirm"))

	self.uiOwnOptions = self.filterContent:Find("own/options")
	self.uiTypeOptions = self.filterContent:Find("type/options")
	self.uiShipHaveOptions = self.filterContent:Find("shipHave/options")
	self.uiCampOptions = self.filterContent:Find("camp/options")
	self.uiRrarityOptions = self.filterContent:Find("rarity/options")
	self.uiShipTypeOptions = self.filterContent:Find("shipType/options")
	self.uiThemeTypeOptions = self.filterContent:Find("themeType/options")
	self.uiTagTypeOptions = self.filterContent:Find("tag/options")

	self:Overlay()
end

function LatestSkinShopLayer:Overlay()
	self:OverlayPanel(self.adapt, {
		pbList = {
			self.top:Find("title"),
			self.top:Find("title/limit_time"),
			self.top:Find("title/charaNameBg"),
			self.showOwnBtn,
			self.filterBtn,
			self.search,
			self.charContainer:Find("bg"),
			self.price:Find("normal/consume"),
			self.filterUI:Find("panelMask/panel")
		}
	})
end

function LatestSkinShopLayer:UnOverlay()
	self:UnOverlayPanel(self.adapt, self._tf)
end

function LatestSkinShopLayer:didEnter()
	self:InitData()
	self:SetFilterPanel()
	self:SetResource()

	if self.mode == LatestSkinShopLayer.MODE_EXPERIENCE or self.mode == LatestSkinShopLayer.MODE_EXPERIENCE_FOR_ITEM then
		pg.m02:sendNotification(NewShopMainScene.SHOW_OR_HIDE_UI_2, false)
		setActive(self.showOwnBtn, false)
		setActive(self.filterBtn, false)
		setActive(self.search, false)

		self.top:Find("title").anchoredPosition = Vector2(184.2, -208.3)
		self.top:Find("change_skin").anchoredPosition = Vector2(70.7, -337.8)
		self.right:Find("giftPackBtn").anchoredPosition = Vector2(-483, -446.4)
		self.right:Find("price").anchoredPosition = Vector2(-238.3, -140.7)
		self.bottom:Find("scroll").offsetMin = Vector2(17.7, 0)
		self.bottom:Find("scroll").offsetMax = Vector2(-718.7, 227.9)
	end

	self:SetGiftPackLayer()
	onDelayTick(function()
		local var_17_0 = {}

		table.insert(var_17_0, function(arg_18_0)
			self:CheckDownloadSkinList(arg_18_0)
		end)
		seriesAsync(var_17_0, function()
			self:SetSkinScroll()
			self:Refresh(true)
		end)
	end, 0.001)
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.homeBtn, function()
		self:emit(LatestSkinShopLayer.ON_HOME)
	end, SFX_CANCEL)
	onButton(self, self.filterBtn, function()
		self:OpenFilterPanel()
	end, SFX_PANEL)

	if self.mode == LatestSkinShopLayer.MODE_EXPERIENCE or self.mode == LatestSkinShopLayer.MODE_EXPERIENCE_FOR_ITEM then
		getProxy(SettingsProxy):SetNextTipTimeLimitSkinShop()
	end

	local var_16_0 = getProxy(PlayerProxy):getRawData().id

	onToggle(self, self.sdTg, function(arg_23_0)
		setActive(self.charContainer, arg_23_0)
		PlayerPrefs.SetInt("LatestSkinShopLayerSdTg" .. var_16_0, arg_23_0 and 1 or 0)
		PlayerPrefs.Save()
	end, SFX_PANEL)
	triggerToggle(self.sdTg, PlayerPrefs.GetInt("LatestSkinShopLayerSdTg" .. var_16_0, 0) == 1)
	onToggle(self, self.hideUITg, function(arg_24_0)
		setActive(self.top, not arg_24_0)
		setActive(self.bottom, not arg_24_0)
		pg.m02:sendNotification(NewShopMainScene.SHOW_OR_HIDE_UI, not arg_24_0)
	end, SFX_PANEL)
	onInputChanged(self, self.search, function()
		self:Refresh(true)
		setActive(self.search:Find("holder"), getInputText(self.search) == "")
	end)
	onButton(self, self.showOwnBtn, function()
		self:emit(LatestSkinShopMediator.OPEN_OWN_SKIN_LAYER)
	end, SFX_PANEL)
	getProxy(CommanderManualProxy):TaskProgressAdd(2021, 1)
end

function LatestSkinShopLayer:SetResource()
	setText(self.resources:Find("gem/Text"), getProxy(PlayerProxy):getRawData():getTotalGem())
	onButton(self, self.resources:Find("gem"), function()
		pg.playerResUI:ClickGem()
	end, SFX_PANEL)
end

function LatestSkinShopLayer:InitData()
	self.type = self.contextData.type or ShopConst.PERMANANT_SKIN_SHOP_ID
	self.mode = self.contextData.mode or LatestSkinShopLayer.MODE_OVERVIEW

	self:GetAllCommodities()
	self:GetGiftPackCommodities()

	self.returnSkins = getProxy(ShipSkinProxy):GetEncoreSkins()

	self:GetSkinClassify()

	self.filterValues = {
		shipHaveType = 0,
		ownType = 0,
		typeType = {
			0
		},
		campType = {
			0
		},
		rarityType = {
			0
		},
		shipType = {
			0
		},
		themeType = {
			(self.mode == LatestSkinShopLayer.MODE_EXPERIENCE or self.mode == LatestSkinShopLayer.MODE_EXPERIENCE_FOR_ITEM) and 1 or 0
		},
		tagType = {
			0
		}
	}
	self.filterValuesTemp = Clone(self.filterValues)
end

function LatestSkinShopLayer:GetAllCommodities()
	self.commodities = var_0_20(self.type, self.mode)
end

function LatestSkinShopLayer:GetGiftPackCommodities()
	self.giftPackCommodities = {}
	self.giftSkinCommodities = {}
	self.giftSkinProbabilitys = {}

	for iter_31_0, iter_31_1 in ipairs(pg.pay_data_display.all) do
		if pg.pay_data_display[iter_31_1].skin_inquire_relation ~= 0 then
			if pg.TimeMgr.GetInstance():inTime(pg.pay_data_display[iter_31_1].time) then
				local var_31_0 = getProxy(ShopsProxy):GetGiftCommodity(iter_31_1, Goods.TYPE_CHARGE)

				self.giftPackCommodities[iter_31_1] = var_31_0

				local var_31_1 = var_31_0:GetSkinProbability()

				self.giftSkinCommodities[iter_31_1] = getProxy(ShipSkinProxy):GetProbabilitySkins(var_31_1)
				self.giftSkinProbabilitys[iter_31_1] = getProxy(ShipSkinProxy):GetSkinProbabilitys(var_31_1)
			end
		end
	end
end

function LatestSkinShopLayer:SetSkinScroll()
	self.scrollrect.isNewLoadingMethod = true

	function self.scrollrect.onInitItem(arg_33_0)
		self:OnInitItem(arg_33_0)
	end

	function self.scrollrect.onUpdateItem(arg_34_0, arg_34_1)
		self:OnUpdateItem(arg_34_0, arg_34_1)
	end

	self.scrollrect.enabled = true
end

function LatestSkinShopLayer:Refresh(arg_35_1)
	self:ClearCards()

	self.cards = {}
	self.displays = {}

	local var_35_0 = getInputText(self.search)

	for iter_35_0, iter_35_1 in ipairs(self.commodities) do
		if self:filterOk(iter_35_1) and self:IsSearchType(var_35_0, iter_35_1) then
			table.insert(self.displays, iter_35_1)
		end
	end

	local var_35_1 = {}

	for iter_35_2, iter_35_3 in ipairs(self.displays) do
		if not (iter_35_3.type == Goods.TYPE_ACTIVITY or iter_35_3.type == Goods.TYPE_ACTIVITY_EXTRA) then
			var_35_1[iter_35_3.id] = iter_35_3:GetPrice()
		end
	end

	table.sort(self.displays, function(arg_36_0, arg_36_1)
		return self:Sort(arg_36_0, arg_36_1, var_35_1)
	end)

	local var_35_3 = #self.displays == 0

	setActive(self.bgs:Find("default"), #self.displays == 0)
	setActive(self.bgs:Find("diffBg"), not var_35_3)
	setActive(self.bgs:Find("empty"), var_35_3)
	setActive(self._tf:Find("leftMask"), not var_35_3)
	setActive(self._tf:Find("bottomMask"), not var_35_3)
	setActive(self.painting, not var_35_3)
	setActive(self.top:Find("title"), not var_35_3)
	setActive(self.changeSkin, not var_35_3)
	setActive(self.right, not var_35_3)
	setActive(self.right, not var_35_3)
	setActive(self.bottom:Find("scroll"), not var_35_3)

	if not var_35_3 then
		if arg_35_1 then
			self.triggerFirstCard = true

			self.scrollrect:SetTotalCount(#self.displays, 0)
		else
			self.scrollrect:SetTotalCount(#self.displays)
		end
	end
end

function LatestSkinShopLayer:IsSearchType(arg_37_1, arg_37_2)
	local var_37_0

	if not arg_37_1 or arg_37_1 == "" then
		do return true end

		var_37_0 = {}
	end

	var_37_0.id = arg_37_2:getSkinId()

	return ShipSkin.New(var_37_0):IsMatchKey(arg_37_1)
end

local function var_0_24(arg_38_0, arg_38_1, arg_38_2)
	local var_38_0 = arg_38_2[arg_38_0.id]
	local var_38_1 = arg_38_2[arg_38_1.id]

	if arg_38_2[arg_38_0.id] == arg_38_2[arg_38_1.id] then
		return arg_38_0.id < arg_38_1.id
	else
		return var_38_1 < var_38_0
	end
end

function LatestSkinShopLayer:Sort(arg_39_1, arg_39_2, arg_39_3)
	local var_39_0 = arg_39_1.buyCount == 0 and 1 or 0
	local var_39_1 = arg_39_2.buyCount == 0 and 1 or 0

	if (arg_39_1.buyCount == 0 and 1 or 0) == (arg_39_2.buyCount == 0 and 1 or 0) then
		local var_39_2 = arg_39_1:getConfig("order")
		local var_39_3 = arg_39_2:getConfig("order")

		if var_39_2 == var_39_3 then
			return var_0_24(arg_39_1, arg_39_2, arg_39_3)
		else
			return var_39_2 < var_39_3
		end
	else
		return var_39_1 < var_39_0
	end
end

function LatestSkinShopLayer:filterOk(arg_40_1)
	local var_40_0 = arg_40_1:getSkinId()
	local var_40_1 = ShipSkin.New({
		id = var_40_0
	})
	local var_40_2 = var_40_1:GetDefaultShipConfig()
	local var_40_3 = self:ToVShip(var_40_2)

	if self.filterValues.ownType ~= 0 then
		local var_40_4 = false
		local var_40_5 = getProxy(ShipSkinProxy):hasSkin(var_40_0)

		if self.filterValues.ownType == 1 and var_40_5 then
			var_40_4 = true
		end

		if self.filterValues.ownType == 2 and not var_40_5 then
			var_40_4 = true
		end

		if not ((self.filterValues.ownType == 3 and var_40_5 and var_40_1:NoUse() or nil) and true) then
			return false
		end
	end

	if self.filterValues.typeType[1] ~= 0 then
		local var_40_6 = false

		for iter_40_0, iter_40_1 in ipairs(self.filterValues.typeType) do
			if iter_40_1 == 1 and (var_40_1:IsLive2d() or var_40_1:IsLive2dPlus()) then
				var_40_6 = true
			end

			if iter_40_1 == 2 and not var_40_1:IsLive2d() and not var_40_1:IsLive2dPlus() and not var_40_1:IsSpine() and not var_40_1:IsSpinePlus() then
				var_40_6 = true
			end

			if iter_40_1 == 3 and (var_40_1:IsSpine() or var_40_1:IsSpinePlus()) then
				var_40_6 = true
			end

			if iter_40_1 == 4 and var_40_1:IsBG() then
				var_40_6 = true
			end

			if iter_40_1 == 5 and var_40_1:IsDbg() then
				var_40_6 = true
			end

			if iter_40_1 == 6 and var_40_1:isBgm() then
				var_40_6 = true
			end

			if var_40_6 then
				break
			end
		end

		if not var_40_6 then
			return false
		end
	end

	if self.filterValues.shipHaveType ~= 0 then
		local var_40_7 = false
		local var_40_8 = var_40_1:CantUse()

		if self.filterValues.shipHaveType == 1 and not var_40_8 then
			var_40_7 = true
		end

		if not ((self.filterValues.shipHaveType == 2 and var_40_8 or nil) and true) then
			return false
		end
	end

	if self.filterValues.campType[1] ~= 0 then
		if not var_40_2 then
			return false
		end

		local var_40_9 = false

		for iter_40_2, iter_40_3 in ipairs(self.filterValues.campType) do
			for iter_40_4, iter_40_5 in ipairs(ShipIndexCfg.camp[iter_40_3 + 1].types) do
				if iter_40_5 == Nation.LINK then
					if var_40_3:getNation() >= Nation.LINK then
						var_40_9 = true
					end
				elseif iter_40_5 == var_40_3:getNation() then
					var_40_9 = true
				end
			end

			if var_40_9 then
				break
			end
		end

		if not var_40_9 then
			return false
		end
	end

	if self.filterValues.rarityType[1] ~= 0 then
		if not var_40_2 then
			return false
		end

		local var_40_10 = false

		for iter_40_6, iter_40_7 in ipairs(self.filterValues.rarityType) do
			if table.contains(ShipIndexCfg.rarity[iter_40_7 + 1].types, var_40_3:getRarity()) then
				var_40_10 = true
			end

			if var_40_10 then
				break
			end
		end

		if not var_40_10 then
			return false
		end
	end

	if self.filterValues.shipType[1] ~= 0 then
		if not var_40_2 then
			return false
		end

		local var_40_11 = false

		for iter_40_8, iter_40_9 in ipairs(self.filterValues.shipType) do
			if iter_40_9 + 1 < 4 then
				if table.contains(ShipIndexCfg.type[iter_40_9 + 1].types, var_40_3:getShipType()) then
					var_40_11 = true
				end

				if table.contains(ShipIndexCfg.type[iter_40_9 + 1].types, var_40_3:getTeamType()) then
					var_40_11 = true
				end
			elseif table.contains(ShipIndexCfg.type[iter_40_9 + 1].types, var_40_3:getShipType()) then
				var_40_11 = true
			end

			if var_40_11 then
				break
			end
		end

		if not var_40_11 then
			return false
		end
	end

	if self.filterValues.themeType[1] ~= 0 then
		local var_40_13 = false

		for iter_40_10, iter_40_11 in ipairs(self.filterValues.themeType) do
			local var_40_14 = self.classifyIds[iter_40_11 + 1]

			if arg_40_1:getConfig("genre") == ShopArgs.SkinShopTimeLimit then
				var_40_13 = self.mode == LatestSkinShopLayer.MODE_EXPERIENCE_FOR_ITEM and var_40_14 == var_0_15 and self:ExitSkinExperienceItem(arg_40_1.id) or var_40_14 == var_0_13
			elseif var_40_14 == var_0_12 then
				var_40_13 = true
			elseif var_40_14 == var_0_14 and table.contains(self.returnSkins, arg_40_1.id) then
				var_40_13 = true
			else
				local var_40_15 = self:GetShopTypeIdBySkinId(var_40_0)

				var_40_13 = ((var_40_15 == 0 or nil) and (var_0_16 or var_40_15)) == var_40_14
			end

			if var_40_13 then
				break
			end
		end

		if not var_40_13 then
			return false
		end
	end

	if self.filterValues.tagType[1] ~= 0 then
		if table.keyof(self.filterValues.tagType, (NewShopSkinCard.GetTagId(arg_40_1, (table.contains(self.returnSkins, arg_40_1.id))))) then
			return true
		else
			return false
		end
	end

	return true
end

function LatestSkinShopLayer:ToVShip(arg_41_1)
	if not self.vship then
		self.vship = {}

		function self.vship.getNation()
			return self.vship.config.nationality
		end

		function self.vship.getShipType()
			return self.vship.config.type
		end

		function self.vship.getTeamType()
			return ShipType.GetTeamFromShipType(self.vship.config.type)
		end

		function self.vship.getRarity()
			return self.vship.config.rarity
		end
	end

	self.vship.config = arg_41_1

	return self.vship
end

function LatestSkinShopLayer:ExitSkinExperienceItem(arg_46_1)
	self.cacheSkinExperienceItems = self.cacheSkinExperienceItems or getProxy(BagProxy):GetSkinExperienceItems()

	return _.any(self.cacheSkinExperienceItems, function(arg_47_0)
		return arg_47_0:CanUseForShop(arg_46_1)
	end)
end

function LatestSkinShopLayer:RegisterEvent()
	self:bind(LatestSkinShopLayer.EVT_SHOW_OR_HIDE_PURCHASE_VIEW, function(arg_49_0, arg_49_1)
		self:AdjustPainting(arg_49_1)
		setActive(self.top, not arg_49_1)
		setActive(self.bottom, not arg_49_1)
		setActive(self.right, not arg_49_1)

		if self.live2dChar then
			self.live2dChar:setPurchaseOffset(arg_49_1)
		end

		if self.spineChar then
			if arg_49_1 then
				if pg.ship_skin_template[self.skinId].purchase_offset and #pg.ship_skin_template[self.skinId].purchase_offset >= 3 then
					self.spineChar:SetLocalPosition(Vector3(pg.ship_skin_template[self.skinId].purchase_offset[1], pg.ship_skin_template[self.skinId].purchase_offset[2], pg.ship_skin_template[self.skinId].purchase_offset[3]))
				end

				if pg.ship_skin_template[self.skinId].purchase_offset and #pg.ship_skin_template[self.skinId].purchase_offset >= 4 then
					self.spineChar:SetLocalScale(Vector3(pg.ship_skin_template[self.skinId].purchase_offset[4], pg.ship_skin_template[self.skinId].purchase_offset[4], pg.ship_skin_template[self.skinId].purchase_offset[4]))
				end
			else
				self.spineChar:SetLocalScale(Vector3(0.9, 0.9, 1))
				self.spineChar:SetLocalPosition(Vector3(0, 0, 0))
			end
		end

		pg.m02:sendNotification(NewShopMainScene.SHOW_OR_HIDE_UI, not arg_49_1)
	end)
	self:bind(LatestSkinShopLayer.EVT_ON_PURCHASE, function(arg_50_0, arg_50_1)
		self:OnClickBtn(self:GetObtainBtnState(arg_50_1), arg_50_1)
	end)
	onButton(self, self.changeSkin, function()
		if ShipSkin.IsChangeSkin(self.skinId) then
			self.changeSkinId = ShipSkin.GetChangeSkinNextId(self.skinId)

			self:UpdateMainView(self.showingCommodity)
		end
	end, SFX_PANEL)
end

function LatestSkinShopLayer:OnInitItem(arg_52_1)
	local var_52_0 = NewShopSkinCard.New(arg_52_1)

	onButton(self, var_52_0._go, function()
		if not var_52_0.commodity then
			return
		end

		for iter_53_0, iter_53_1 in pairs(self.cards) do
			iter_53_1:UpdateSelected(false)
		end

		self.selectedId = var_52_0.commodity.id

		var_52_0:UpdateSelected(true)
		self:UpdateMainView(var_52_0.commodity)
		self:GCHandle()
	end, SFX_PANEL)

	self.cards[arg_52_1] = var_52_0
end

function LatestSkinShopLayer:OnUpdateItem(arg_54_1, arg_54_2)
	local var_54_0 = self.cards[arg_54_2]

	if not self.cards[arg_54_2] then
		self:OnInitItem(arg_54_2)

		var_54_0 = self.cards[arg_54_2]
	end

	local var_54_1 = self.displays[arg_54_1 + 1]
	local var_54_2

	if not self.displays[arg_54_1 + 1] then
		do return end

		var_54_2 = table.contains(self.returnSkins, var_54_1.id)
	end

	var_54_0:Update(var_54_1, self.selectedId == var_54_1.id, var_54_2)

	if self.pendingSelectId and self.pendingSelectId == var_54_1.id then
		self.pendingSelectId = nil

		triggerButton(var_54_0._go)
	end

	if self.triggerFirstCard and arg_54_1 == 0 then
		self.triggerFirstCard = false

		triggerButton(var_54_0._go)
	end
end

function LatestSkinShopLayer:UpdateMainView(arg_55_1)
	self.mainViewToken = (self.mainViewToken or 0) + 1

	local var_55_1 = self.mainViewToken

	SplitPackConst.DownloadByLuaArr(var_0_23(arg_55_1:getSkinId()), function()
		if self.exited or var_55_1 ~= self.mainViewToken then
			return
		end

		self:RefreshMainView(arg_55_1)
	end)
end

function LatestSkinShopLayer:RefreshMainView(arg_57_1)
	self.skinId = arg_57_1:getSkinId()

	local var_57_0 = ShipSkin.IsChangeSkin(self.skinId)

	setActive(self.changeSkin, var_57_0)

	if var_57_0 then
		self:FlushChangeSkin(arg_57_1)
	end

	self.shipSkin = ShipSkin.New({
		id = self.skinId
	})

	self:FlushName()
	self:FlushPreviewBtn(arg_57_1)
	self:FlushTimeLimit(arg_57_1)
	self:SwitchPreview(arg_57_1, self.isPreviewFurniture)
	self:FlushPaintingToggle(arg_57_1)
	self:FlushTag()
	self:FlushBG(arg_57_1)
	self:FlushPainting(arg_57_1)
	self:FlushPrice(arg_57_1)
	self:FlushObtainBtn(arg_57_1)
	self:FlushGifgPackBtn(arg_57_1)

	self.showingCommodity = arg_57_1
end

function LatestSkinShopLayer:FlushChangeSkin(arg_58_1)
	local var_58_0 = ShipSkin.GetChangeSkinGroupId(self.skinId)
	local var_58_1 = ShipSkin.GetChangeSkinCustomDataId(self.skinId, "hide_shop")
	local var_58_2 = pg.gameset.changeskin_switch_block
	local var_58_3 = false
	local var_58_4 = false
	local var_58_5 = not not self.changeSkinToggle:IsAsmrSkin()

	if pg.gameset.changeskin_switch_block and var_58_2.description and table.contains(var_58_2.description, var_58_0) and HXSet.isHx() then
		var_58_4 = true
	end

	if var_58_1 and var_58_1 == 1 then
		var_58_3 = true
	end

	if not self.changeSkinId then
		self.changeSkinId = self.skinId
	elseif ShipSkin.GetChangeSkinGroupId(self.changeSkinId) == var_58_0 then
		self.skinId = self.changeSkinId
	else
		self.changeSkinId = self.skinId
	end

	self.changeSkinToggle:setSkinData(self.skinId)

	if var_58_3 or var_58_4 or var_58_5 then
		setActive(self.changeSkin, false)
	else
		setActive(self.changeSkin, true)
	end
end

function LatestSkinShopLayer:GCHandle()
	LatestSkinShopLayer.GCCNT = (LatestSkinShopLayer.GCCNT or 0) + 1

	if LatestSkinShopLayer.GCCNT == 3 then
		gcAll()

		LatestSkinShopLayer.GCCNT = 0
	end
end

function LatestSkinShopLayer:FlushName()
	setScrollText(self.skinName, SwitchSpecialChar(pg.ship_skin_template[self.skinId].name, true))

	if pg.ship_skin_template[self.skinId].skin_type == ShipSkin.SKIN_TYPE_TB then
		setScrollText(self.shipName, NewEducateHelper.GetShipNameBySecId(NewEducateHelper.GetSecIdBySkinId(self.skinId)))
	else
		setScrollText(self.shipName, ShipGroup.getDefaultShipConfig(pg.ship_skin_template[self.skinId].ship_group).name)
	end
end

function LatestSkinShopLayer:FlushPreviewBtn(arg_61_1)
	local var_61_0 = Goods.ExistFurniture(arg_61_1.id)

	removeOnButton(self.switchPreviewBtn)

	if not var_61_0 and self.isPreviewFurniture then
		self.isPreviewFurniture = false
	end

	setActive(self.switchPreviewBtn, var_61_0)

	if var_61_0 then
		onButton(self, self.switchPreviewBtn, function()
			self.isPreviewFurniture = not self.isPreviewFurniture

			self:SwitchPreview(arg_61_1, self.isPreviewFurniture)
			self:FlushPrice(arg_61_1)
			self:FlushObtainBtn(arg_61_1)
		end, SFX_PANEL)
	end
end

function LatestSkinShopLayer:SwitchPreview(arg_63_1, arg_63_2)
	if pg.ship_skin_template[self.skinId].skin_type == ShipSkin.SKIN_TYPE_TB then
		setActive(self.charContainer, false)

		return
	end

	setActive(self.charContainer, PlayerPrefs.GetInt("LatestSkinShopLayerSdTg" .. getProxy(PlayerProxy):getRawData().id, 0) == 1)
	setActive(self.charTf, not arg_63_2)
	setActive(self.furnitureContainer, arg_63_2)

	if not arg_63_2 then
		self:FlushChar(pg.ship_skin_template[self.skinId].prefab, pg.ship_skin_template[self.skinId].id)
		GetImageSpriteFromAtlasAsync("qicon/" .. pg.ship_skin_template[self.skinId].painting, "", self.backChara)
	else
		local var_63_0 = Goods.GetFurnitureConfig(arg_63_1.id)

		self.interactionPreview:Flush(self.skinId, Goods.Id2FurnitureId(arg_63_1.id), var_63_0.scale[2] or 1, var_63_0.position[2])
	end
end

function LatestSkinShopLayer:FlushChar(arg_64_1, arg_64_2)
	if self.prefabName and self.prefabName == arg_64_1 then
		return
	end

	self:ReturnChar()

	self.prefabName = arg_64_1

	local var_64_0 = SpineAnimChar.New()

	var_64_0:SetPaint(arg_64_1)
	var_64_0:Load(true, function(arg_65_0)
		if self.prefabName ~= arg_64_1 then
			arg_65_0:Dispose()

			return
		end

		self.spineChar = arg_65_0

		if pg.skinshop_spine_scale[arg_64_2] then
			self.spineChar:SetLocalScale(Vector3(pg.skinshop_spine_scale[arg_64_2].skinshop_scale, pg.skinshop_spine_scale[arg_64_2].skinshop_scale, 1))
		else
			self.spineChar:SetLocalScale(Vector3(0.9, 0.9, 1))
		end

		self.spineChar:SetLocalPosition(Vector3(0, 0, 0))
		self.spineChar:SetLayer(Layer.UI)
		self.spineChar:SetParent(self.charTf)
		self.spineChar:SetAction("normal", 0)
	end)
end

function LatestSkinShopLayer:ReturnChar()
	if self.spineChar then
		self.spineChar:Dispose()

		self.spineChar = nil
		self.prefabName = nil
	end
end

function LatestSkinShopLayer:ClearCards()
	if not self.cards then
		return
	end

	for iter_67_0, iter_67_1 in pairs(self.cards) do
		iter_67_1:Dispose()
	end

	self.cards = nil
end

function LatestSkinShopLayer:FlushTimeLimit(arg_68_1)
	local var_68_0 = false
	local var_68_1

	if arg_68_1:IsActivityExtra() and arg_68_1:ShowMaintenanceTime() then
		local var_68_2, var_68_3 = arg_68_1:GetMaintenanceMonthAndDay()

		function var_68_1()
			return i18n("limit_skin_time_before_maintenance", var_68_2, var_68_3)
		end

		var_68_0 = true
	elseif arg_68_1:getConfig("genre") == ShopArgs.SkinShopTimeLimit then
		local var_68_4 = getProxy(ShipSkinProxy):getSkinById(self.skinId)

		var_68_0 = var_68_4 and var_68_4:isExpireType() and not var_68_4:isExpired()

		if var_68_0 then
			function var_68_1()
				return skinTimeStamp(var_68_4:getRemainTime())
			end
		end
	else
		local var_68_5, var_68_6 = pg.TimeMgr.GetInstance():inTime(arg_68_1:getConfig("time"))

		var_68_0 = var_68_6

		if var_68_6 then
			local var_68_7 = pg.TimeMgr.GetInstance():Table2ServerTime(var_68_6)

			function var_68_1()
				return skinCommdityTimeStamp(var_68_7)
			end
		end
	end

	setActive(self.top:Find("title/limit_time"), var_68_0)
	self:ClearTimer()

	if var_68_0 then
		self:AddTimer(var_68_1)
	end
end

function LatestSkinShopLayer:AddTimer(arg_72_1)
	self.timer = Timer.New(function()
		setText(self.limitTime, arg_72_1())
	end, 1, -1)

	self.timer.func()
	self.timer:Start()
end

function LatestSkinShopLayer:ClearTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function LatestSkinShopLayer:FlushPaintingToggle(arg_75_1)
	removeOnToggle(self.dynamicToggle)
	removeOnToggle(self.showBgToggle)

	local var_75_0 = checkABExist("painting/" .. self.shipSkin:getConfig("painting") .. "_n")

	if self.isToggleShowBg and not var_75_0 then
		triggerToggle(self.showBgToggle, false)

		self.isToggleShowBg = false
	elseif var_75_0 then
		triggerToggle(self.showBgToggle, true)

		self.isToggleShowBg = true
	end

	local var_75_1 = self.shipSkin:IsSpine() or self.shipSkin:IsLive2d() or self.shipSkin:IsSpinePlus() or self.shipSkin:IsLive2dPlus()
	local var_75_2 = self.shipSkin:IsHxDynamicPreview()

	if var_75_1 and not var_75_2 then
		if PlayerPrefs.GetInt("skinShop#l2dPreViewToggle" .. getProxy(PlayerProxy):getRawData().id, 0) == 1 then
			self.isToggleDynamic = true
		end
	end

	if var_75_1 then
		local var_75_3 = 0

		if self.shipSkin:IsSpine() then
			var_75_3 = 6
		elseif self.shipSkin:IsLive2d() then
			var_75_3 = 1
		elseif self.shipSkin:IsSpinePlus() then
			var_75_3 = 7
		elseif self.shipSkin:IsLive2dPlus() then
			var_75_3 = 9
		end

		LoadImageSpriteAtlasAsync("SkinIcon", "type_" .. ShipSkin.Tag2Name(var_75_3) .. "_off", self.dynamicToggle)
		LoadImageSpriteAtlasAsync("SkinIcon", "type_" .. ShipSkin.Tag2Name(var_75_3), self.dynamicToggle:Find("select"))
	end

	if var_75_2 and self.isToggleDynamic then
		triggerToggle(self.dynamicToggle, false)

		self.isToggleDynamic = false
	end

	if self.isToggleDynamic and not var_75_1 then
		triggerToggle(self.dynamicToggle, false)

		self.isToggleDynamic = false
	elseif self.isToggleDynamic and not self.dynamicToggle:GetComponent(typeof(Toggle)).isOn then
		if (self.shipSkin:IsLive2d() or self.shipSkin:IsLive2dPlus()) and Live2dConst.GetLive2DArm32MatchAble() then
			self.isToggleDynamic = false

			PlayerPrefs.SetInt("skinShop#l2dPreViewToggle" .. getProxy(PlayerProxy):getRawData().id, 0)
			PlayerPrefs.Save()
			triggerToggle(self.dynamicToggle, false)
		else
			triggerToggle(self.dynamicToggle, true)

			self.isToggleDynamic = true
		end
	end

	if var_75_0 then
		onToggle(self, self.showBgToggle, function(arg_76_0)
			self.isToggleShowBg = arg_76_0

			self:FlushPainting(arg_75_1)
			self:FlushBG(arg_75_1)
		end, SFX_PANEL)
	end

	if self.shipSkin:IsSpine() or self.shipSkin:IsLive2d() or self.shipSkin:IsSpinePlus() or self.shipSkin:IsLive2dPlus() then
		onToggle(self, self.dynamicToggle, function(arg_77_0)
			if arg_77_0 and self.shipSkin:IsHxDynamicPreview() then
				pg.TipsMgr.GetInstance():ShowTips(i18n("shop_tag_control_tip"))
				triggerToggle(self.dynamicToggle, false)
				setActive(self.dynamicResToggle, false)

				return
			end

			if arg_77_0 and Live2dConst.GetLive2DArm32MatchAble() and (self.shipSkin:IsLive2d() or self.shipSkin:IsLive2dPlus()) then
				Live2dConst.ShowLive2DArm32Tips()
				triggerToggle(self.dynamicToggle, false)

				return
			end

			self.isToggleDynamic = arg_77_0

			setActive(self.showBgToggle, not arg_77_0 and var_75_0)
			self:FlushPainting(arg_75_1)
			self:FlushDynamicPaintingResState(arg_75_1)
			self:RecordFlag(arg_77_0)
		end, SFX_PANEL)
	end

	setActive(self.dynamicIcon, true)

	if self.isToggleDynamic then
		self:FlushDynamicPaintingResState(arg_75_1)
	elseif var_75_2 then
		setActive(self.dynamicResToggle, false)
		setActive(self.dynamicIcon, false)
	end

	setActive(self.dynamicToggle, var_75_1)
	setActive(self.showBgToggle, not self.isToggleDynamic and var_75_0)
end

function LatestSkinShopLayer:FlushTag()
	local var_78_0 = Clone(pg.ship_skin_template[self.skinId].tag)

	for iter_78_0 = #var_78_0, 1, -1 do
		if var_78_0[iter_78_0] == 1 or var_78_0[iter_78_0] == 6 or var_78_0[iter_78_0] == 7 or var_78_0[iter_78_0] == 9 then
			table.remove(var_78_0, iter_78_0)
		end
	end

	local var_78_3 = checkABExist("painting/" .. self.shipSkin:getConfig("painting") .. "_n")

	self.tagList:make(function(arg_79_0, arg_79_1, arg_79_2)
		if arg_79_0 == UIItemList.EventUpdate then
			LoadSpriteAtlasAsync("SkinIcon", "type_" .. ShipSkin.Tag2Name(var_78_0[arg_79_1 + 1]), function(arg_80_0)
				if self.exited then
					return
				end

				arg_79_2:GetComponent(typeof(Image)).sprite = arg_80_0
			end)
		end
	end)
	setActive(self.adapt:Find("right/functionsAndTags/tags"), #var_78_0 > 0)
	self.tagList:align(#var_78_0)
end

function LatestSkinShopLayer:FlushPainting(arg_81_1)
	local var_81_0 = self:GetPaintingState(arg_81_1)
	local var_81_1 = pg.ship_skin_template[self.skinId].painting
	local var_81_2 = not not ShipSkin.GetChangeSkinData(self.skinId)

	if var_81_0 == var_0_2 and not self:ExistL2dRes(var_81_1) or var_81_0 == var_0_3 and not self:ExistSpineRes(var_81_1) then
		var_81_0 = var_0_1
	end

	if self.paintingState and self.paintingState.state == var_81_0 and self.paintingState.id == arg_81_1.id and self.paintingState.showBg == self.isToggleShowBg and self.paintingState.purchaseFlag == arg_81_1.buyCount and not var_81_2 then
		return
	end

	self:ClearPainting()

	if var_81_0 == var_0_1 then
		self:LoadMeshPainting(arg_81_1, self.isToggleShowBg)
	elseif var_81_0 == var_0_2 then
		self:LoadL2dPainting(arg_81_1)
	elseif var_81_0 == var_0_3 then
		self:LoadSpinePainting(arg_81_1)
	end

	self.paintingState = {
		state = var_81_0,
		id = arg_81_1.id,
		showBg = self.isToggleShowBg,
		purchaseFlag = arg_81_1.buyCount
	}

	self:AdjustPainting(false)
end

function LatestSkinShopLayer:ClearPainting()
	if not self.paintingState then
		return
	end

	if self.paintingState.state == var_0_1 then
		self:ClearMeshPainting()
	elseif self.paintingState.state == var_0_2 then
		self:ClearL2dPainting()
	elseif self.paintingState.state == var_0_3 then
		self:ClearSpinePainting()
	end

	self.paintingState = nil
end

function LatestSkinShopLayer:LoadMeshPainting(arg_83_1, arg_83_2)
	local var_83_0 = findTF(self.paintingTF, "fitter")
	local var_83_1 = GetOrAddComponent(var_83_0, "PaintingScaler")

	var_83_1.FrameName = "chuanwu"
	var_83_1.Tween = 1

	local var_83_2 = pg.ship_skin_template[self.skinId].painting
	local var_83_3 = pg.ship_skin_template[self.skinId].painting

	if not arg_83_2 and checkABExist("painting/" .. var_83_2 .. "_n") then
		var_83_2 = var_83_2 .. "_n"
	end

	if not checkABExist("painting/" .. var_83_2) then
		return
	end

	if PLATFORM_CODE == PLATFORM_CH and checkABExist("painting/" .. var_83_2 .. "_shop") then
		var_83_2 = var_83_2 .. "_shop"
	end

	pg.UIMgr.GetInstance():LoadingOn()
	PoolMgr.GetInstance():GetPainting(var_83_2, true, function(arg_84_0)
		pg.UIMgr.GetInstance():LoadingOff()
		setParent(arg_84_0, var_83_0, false)
		ShipExpressionHelper.SetExpression(var_83_0:GetChild(0), var_83_3)

		self.paintingName = var_83_2

		if self.paintingState and self.paintingState.id ~= arg_83_1.id then
			self:ClearMeshPainting()
		end

		self:CheckShowShopHx((arg_84_0.transform:Find("shop_hx")))
		self:CheckShowShopHx((arg_84_0.transform:Find("shop_hx_ch" .. pg.SdkMgr.GetInstance():GetChannelUIDIncludeHarmony())))
	end)
end

function LatestSkinShopLayer:ClearMeshPainting()
	local var_85_0 = self.paintingTF:Find("fitter")

	if self.paintingName and var_85_0.childCount > 0 then
		local var_85_1 = var_85_0:GetChild(0).gameObject

		self:RevertShopHx((var_85_1.transform:Find("shop_hx")))
		PoolMgr.GetInstance():ReturnPainting(self.paintingName, var_85_1)
	end

	self.paintingName = nil
end

function LatestSkinShopLayer:LoadL2dPainting(arg_86_1)
	local var_86_0

	if pg.ship_skin_template[self.skinId].skin_type == ShipSkin.SKIN_TYPE_TB then
		var_86_0 = VirtualEducateCharShip.New(NewEducateHelper.GetSecIdBySkinId(self.skinId))
	else
		local var_86_1 = {
			noChangeSkin = true
		}

		var_86_1.configId = ShipGroup.getDefaultShipConfig(pg.ship_skin_template[self.skinId].ship_group).id
		var_86_1.skin_id = self.skinId
		var_86_0 = Ship.New(var_86_1)
	end

	local var_86_2 = Live2DPainting.GenerateData({
		ship = var_86_0,
		position = Vector3(0, 0, -1),
		parent = self.live2dContainer,
		offset = var_86_0:GetSkinConfig().shop_offset
	})

	var_86_2.shopPreView = true

	pg.UIMgr.GetInstance():LoadingOn()

	self.live2dChar = Live2DPainting.New(var_86_2, function(arg_87_0)
		arg_87_0:IgonreReactPos(true)
		self:CheckShowShopHxForL2d(arg_87_0, arg_86_1)

		if self.paintingState and self.paintingState.id ~= arg_86_1.id then
			self:ClearL2dPainting()
		end

		arg_87_0:setSortingLayer(LayerWeightConst.L2D_DEFAULT_LAYER)
		pg.UIMgr.GetInstance():LoadingOff()
	end)
end

function LatestSkinShopLayer:ClearL2dPainting()
	if self.live2dChar then
		self:RevertShopHxForL2d(self.live2dChar)
		self.live2dChar:Dispose()

		self.live2dChar = nil
	end
end

function LatestSkinShopLayer:LoadSpinePainting(arg_89_1)
	local var_89_0

	if pg.ship_skin_template[self.skinId].skin_type == ShipSkin.SKIN_TYPE_TB then
		var_89_0 = VirtualEducateCharShip.New(NewEducateHelper.GetSecIdBySkinId(self.skinId))
	else
		local var_89_1 = {
			noChangeSkin = true
		}

		var_89_1.configId = ShipGroup.getDefaultShipConfig(pg.ship_skin_template[self.skinId].ship_group).id
		var_89_1.skin_id = self.skinId
		var_89_0 = Ship.New(var_89_1)
	end

	local var_89_2 = SpinePainting.GenerateData({
		ship = var_89_0,
		position = Vector3(0, 0, 0),
		parent = self.spTF,
		effectParent = self.spBg,
		offset = var_89_0:GetSkinConfig().shop_offset
	})

	pg.UIMgr.GetInstance():LoadingOn()

	self.spinePainting = SpinePainting.New(var_89_2, function(arg_90_0)
		arg_90_0:SetShopHx(true)

		if self.paintingState and self.paintingState.id ~= arg_89_1.id then
			self:ClearSpinePainting()
		end

		self:CheckShowShopHx((arg_90_0._tf:Find("shop_hx")))
		self:CheckShowShopHx((arg_90_0._tf:Find("shop_hx_ch" .. pg.SdkMgr.GetInstance():GetChannelUIDIncludeHarmony())))
		pg.UIMgr.GetInstance():LoadingOff()
	end)
end

function LatestSkinShopLayer:ClearSpinePainting()
	if self.spinePainting and self.spinePainting._tf then
		local var_91_0 = self.spinePainting._tf:Find("shop_hx")

		self:RevertShopHx(self.shopHx)
		self.spinePainting:Dispose()

		self.spinePainting = nil
	end
end

function LatestSkinShopLayer:CheckShowShopHx(arg_92_1)
	if IsNil(arg_92_1) then
		return
	end

	setActive(arg_92_1, false)

	if PLATFORM_CODE ~= PLATFORM_CH then
		return
	end

	if not HXSet.isHx() then
		return
	end

	setActive(arg_92_1, true)
end

function LatestSkinShopLayer:RevertShopHx(arg_93_1)
	if not IsNil(arg_93_1) then
		setActive(arg_93_1, false)
	end
end

function LatestSkinShopLayer:CheckShowShopHxForL2d(arg_94_1, arg_94_2)
	if PLATFORM_CODE ~= PLATFORM_CH then
		return
	end

	if not HXSet.isHx() then
		return
	end

	arg_94_1:changeParamaterValue("shop_hx", 1)
end

function LatestSkinShopLayer:RevertShopHxForL2d(arg_95_1)
	arg_95_1:changeParamaterValue("shop_hx", 0)
end

function LatestSkinShopLayer:AdjustPainting(arg_96_1)
	if pg.ship_skin_newmainui_shift[self.skinId] then
		local var_96_0 = pg.ship_skin_newmainui_shift[self.skinId].skin_shop_shift

		self.paintingTF.anchoredPosition = arg_96_1 and Vector2(var_96_0[1] - 440, var_96_0[2] + self.defaultPaintingPosition.y) or Vector2(var_96_0[1] + self.defaultPaintingPosition.x, var_96_0[2] + self.defaultPaintingPosition.y)
		self.paintingTF.localScale = Vector3(var_96_0[4], var_96_0[4], 1)
	else
		self.paintingTF.anchoredPosition = Vector2(self.defaultPaintingPosition.x, self.defaultPaintingPosition.y)
		self.paintingTF.localScale = self.defaultPaintingScale
	end
end

function LatestSkinShopLayer:FlushBG(arg_97_1, arg_97_2)
	local var_97_0 = pg.ship_skin_template[self.skinId]
	local var_97_1

	if pg.ship_skin_template[self.skinId].skin_type == ShipSkin.SKIN_TYPE_TB then
		var_97_1 = VirtualEducateCharShip.New(NewEducateHelper.GetSecIdBySkinId(self.skinId))
	else
		local var_97_2 = {
			id = 999
		}

		var_97_2.configId = ShipGroup.getDefaultShipConfig(var_97_0.ship_group).id
		var_97_2.skin_id = self.skinId
		var_97_1 = Ship.New(var_97_2)
	end

	local var_97_3 = var_97_1:getShipBgPrint(true)

	if (self.isToggleShowBg or not checkABExist("painting/" .. pg.ship_skin_template[self.skinId].painting .. "_n")) and var_97_0.bg_sp ~= "" then
		var_97_3 = var_97_0.bg_sp
	end

	local var_97_4 = var_97_3 ~= var_97_1:rarity2bgPrintForGet()

	if var_97_4 then
		pg.DynamicBgMgr.GetInstance():LoadBg(self, var_97_3, self.bgs:Find("diffBg"), self.bgs:Find("diffBg/bg"), function(arg_98_0)
			if arg_97_2 then
				arg_97_2()
			end
		end, function(arg_99_0)
			if arg_97_2 then
				arg_97_2()
			end
		end)
	else
		pg.DynamicBgMgr.GetInstance():ClearBg(self:getUIName())

		if arg_97_2 then
			arg_97_2()
		end
	end

	setActive(self.bgs:Find("diffBg"), var_97_4)
	setActive(self.bgs:Find("default"), not var_97_4)
end

function LatestSkinShopLayer:FlushDynamicPaintingResState(arg_100_1)
	if not self.isToggleDynamic then
		return
	end

	local var_100_0 = self:GetPaintingState(arg_100_1)
	local var_100_1 = false
	local var_100_2 = ""

	if var_0_2 == var_100_0 then
		var_100_1, var_100_2 = self:ExistL2dRes(pg.ship_skin_template[self.skinId].painting)
	elseif var_0_3 == var_100_0 then
		var_100_1, var_100_2 = self:ExistSpineRes(pg.ship_skin_template[self.skinId].painting)
	end

	setActive(self.dynamicResToggle, not var_100_1)
	removeOnButton(self.dynamicResToggle)

	if not var_100_1 and var_100_2 ~= "" then
		onButton(self, self.dynamicResToggle, function()
			self:DownloadDynamicPainting(var_100_2, arg_100_1)
		end, SFX_PANEL)
	end
end

function LatestSkinShopLayer:DownloadDynamicPainting(arg_102_1, arg_102_2)
	local var_102_0 = self.skinId

	if self.downloads[self.skinId] then
		return
	end

	local var_102_1 = SkinShopDownloadRequest.New()

	self.downloads[self.skinId] = var_102_1

	var_102_1:Start(arg_102_1, function(arg_103_0)
		if arg_103_0 and self.paintingState and self.paintingState.id == arg_102_2.id then
			self:FlushPainting(arg_102_2)
			self:FlushDynamicPaintingResState(arg_102_2)
		end

		var_102_1:Dispose()

		self.downloads[var_102_0] = nil
	end)
end

function LatestSkinShopLayer:GetPaintingState(arg_104_1)
	if self.isToggleDynamic and (self.shipSkin:IsLive2d() or self.shipSkin:IsLive2dPlus()) then
		return var_0_2
	elseif self.isToggleDynamic and (self.shipSkin:IsSpine() or self.shipSkin:IsSpinePlus()) then
		if self.shipSkin:getConfig("spine_use_live2d") == 1 then
			return var_0_2
		end

		return var_0_3
	else
		return var_0_1
	end
end

function LatestSkinShopLayer:ExistL2dRes(arg_105_1)
	local var_105_0 = HXSet.autoHxShiftPath("live2d/" .. string.lower(arg_105_1), nil, true)

	return checkABExist(var_105_0), var_105_0
end

function LatestSkinShopLayer:ExistSpineRes(arg_106_1)
	local var_106_0 = HXSet.autoHxShiftPath("SpinePainting/" .. string.lower(arg_106_1), nil, true)

	return checkABExist(var_106_0), var_106_0
end

function LatestSkinShopLayer:RecordFlag(arg_107_1)
	PlayerPrefs.SetInt("skinShop#l2dPreViewToggle" .. getProxy(PlayerProxy):getRawData().id, arg_107_1 and 1 or 0)
	PlayerPrefs.Save()
	self:emit(LatestSkinShopMediator.ON_RECORD_ANIM_PREVIEW_BTN, arg_107_1)
end

function LatestSkinShopLayer:FlushPrice(arg_108_1)
	local var_108_0 = arg_108_1:getConfig("genre") == ShopArgs.SkinShopTimeLimit
	local var_108_1 = arg_108_1.type == Goods.TYPE_ACTIVITY or arg_108_1.type == Goods.TYPE_ACTIVITY_EXTRA

	if var_108_0 then
		if self.mode == NewSkinShopScene.MODE_EXPERIENCE_FOR_ITEM then
			self:UpdateExperiencePrice4Item(arg_108_1)
		else
			self:UpdateExperiencePrice(arg_108_1)
		end
	elseif self.isPreviewFurniture then
		self:UpdateFurniturePrice(arg_108_1)
	elseif var_108_1 then
		-- block empty
	else
		self:UpdateCommodityPrice(arg_108_1)
	end

	local var_108_2 = arg_108_1.type == Goods.TYPE_SKIN

	setActive(self.price:Find("timeLimit"), var_108_0 and not var_108_1)
	setActive(self.price:Find("normal/consume"), var_108_2 and not var_108_0 and not var_108_1)
end

function LatestSkinShopLayer:UpdateExperiencePrice4Item(arg_109_1)
	local var_109_0 = arg_109_1:getConfig("resource_num")
	local var_109_1 = _.detect(getProxy(BagProxy):GetSkinExperienceItems(), function(arg_110_0)
		return arg_110_0:CanUseForShop(arg_109_1.id)
	end)
	local var_109_2

	if var_109_1 then
		var_109_2 = var_109_1.count or 0

		local var_109_3

		if var_109_2 < var_109_0 then
			var_109_3 = "<color=" .. COLOR_RED .. ">" or ""
		end
	end

	setText(self.price:Find("timeLimit/consume/Text"), (var_109_3 .. var_109_2 .. (var_109_2 < var_109_0 and "</color>" or "")) .. "/" .. var_109_0)
end

function LatestSkinShopLayer:UpdateExperiencePrice(arg_111_1)
	local var_111_0 = arg_111_1:getConfig("resource_num")
	local var_111_1 = getProxy(PlayerProxy):getRawData():getSkinTicket()

	setText(self.price:Find("timeLimit/consume/Text"), (((var_111_1 < var_111_0 or nil) and ("<color=" .. COLOR_RED .. ">" or "")) .. var_111_1 .. (var_111_1 < var_111_0 and "</color>" or "")) .. "/" .. var_111_0)
end

function LatestSkinShopLayer:UpdateCommodityPrice(arg_112_1)
	local var_112_0 = arg_112_1:GetPrice()
	local var_112_1 = arg_112_1:getConfig("resource_num")

	setText(self.price:Find("normal/consume/Text"), var_112_0)
	setText(self.price:Find("normal/consume/originalprice/Text"), var_112_1)
	setActive(self.price:Find("normal/consume/originalprice"), var_112_0 ~= var_112_1)
end

function LatestSkinShopLayer:UpdateFurniturePrice(arg_113_1)
	local var_113_0 = Furniture.New({
		id = Goods.Id2FurnitureId(arg_113_1.id)
	})
	local var_113_1 = var_113_0:getConfig("gem_price")

	setText(self.price:Find("normal/consume/originalprice/Text"), var_113_1)

	local var_113_2 = var_113_0:getPrice(PlayerConst.ResDiamond)

	setText(self.price:Find("normal/consume/Text"), var_113_2)
	setActive(self.price:Find("normal/consume/originalprice"), var_113_1 ~= var_113_2)
end

local function var_0_25(arg_114_0, arg_114_1)
	if arg_114_0 == var_0_6 or arg_114_0 == var_0_9 or arg_114_0 == var_0_8 then
		return false
	end

	return getProxy(ShopsProxy):CanPurchasedByCharge((arg_114_1:getSkinId()))
end

function LatestSkinShopLayer:UpdateChargeView(arg_115_1, arg_115_2, arg_115_3)
	local var_115_0 = self.btnsList[2]

	setActive(self.btnsList[2]:Find("buy_charge"), not (arg_115_1 == var_0_4))

	local var_115_1 = pg.pay_data_display[arg_115_3]

	assert(pg.pay_data_display[arg_115_3], "pay_data_display>>>>>>>>>>>>>" .. arg_115_3)

	local var_115_2 = GetMoneySymbol() .. GetChargePrice(var_115_1.money)

	setText(self.btnsList[2]:Find("buy_charge/value"), var_115_2)

	local var_115_3 = var_115_0.parent:Find("consume")
	local var_115_4 = var_115_0.parent:Find("rmb")

	setText(var_115_4:Find("Text"), var_115_2)
	setActive(var_115_4:Find("originalprice"), var_115_1.cash_show > var_115_1.money)
	setText(var_115_4:Find("originalprice/Text"), GetChargePrice(var_115_1.cash_show))

	local var_115_5 = arg_115_2:GetPrice()
	local var_115_6 = arg_115_2:getConfig("resource_num")

	setActive(var_115_3:Find("originalprice"), var_115_5 ~= var_115_6)
	setText(var_115_3:Find("Text"), var_115_5)
	setText(var_115_3:Find("originalprice/Text"), var_115_6)
end

function LatestSkinShopLayer:FlushObtainBtn(arg_116_1)
	local var_116_0 = self:GetObtainBtnState(arg_116_1)
	local var_116_1 = var_0_19(var_116_0)
	local var_116_2, var_116_3 = var_0_25(var_116_0, arg_116_1)

	setActive(self.btnsList[1].parent, not var_116_2)
	setActive(self.btnsList[2].parent, var_116_2)

	local var_116_4

	if var_116_2 then
		var_116_4 = self.btnsList[2] or self.btnsList[1]
	end

	for iter_116_0 = 0, var_116_4.childCount - 1 do
		local var_116_5 = var_116_4:GetChild(iter_116_0)

		setActive(var_116_5, var_116_5.name == var_116_1)
	end

	if var_116_2 then
		self:UpdateChargeView(var_116_0, arg_116_1, var_116_3)
	end

	setActive(self.price:Find("btn_charge"), var_116_2 and var_116_0 ~= var_0_4)
	setActive(self.price:Find("btn/item"), var_116_0 == var_0_11)
	setActive(self.price:Find("btn/tag"), var_116_0 == var_0_11)

	if var_116_0 == var_0_11 then
		self:FlushGift(arg_116_1)
	end

	onButton(self, self.price:Find("btn_charge"), function()
		if not var_116_2 then
			return
		end

		self:OpenChargePanel(var_116_3)
	end, SFX_PANEL)
	onButton(self, self.price:Find("btn"), function()
		local var_118_0 = {}
		local var_118_1 = SkinCouponActivity.StaticEncoreActTip(arg_116_1.id)

		if tobool(var_118_1) then
			table.insert(var_118_0, function(arg_119_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("SkinDiscount_Hint"),
					onYes = function()
						if var_118_1 and not var_118_1:isEnd() then
							self:emit(LatestSkinShopMediator.OPEN_ACTIVITY, var_118_1.id)
						end
					end,
					onNo = arg_119_0
				})
			end)
		end

		if arg_116_1:getConfig("genre") == ShopArgs.SkinShop and not arg_116_1:IsItemDiscountType() and #SkinCouponActivity.GetOvercountEncoreActs(arg_116_1.id) > 0 then
			table.insert(var_118_0, function(arg_121_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("SkinDiscount_Last_Coupon"),
					onYes = arg_121_0
				})
			end)
		end

		seriesAsync(var_118_0, function()
			if var_116_0 == var_0_5 or var_116_0 == var_0_7 or var_116_0 == var_0_11 then
				self.purchaseView:ExecuteAction("Show", arg_116_1)
			else
				self:OnClickBtn(var_116_0, arg_116_1)
			end
		end)
	end, SFX_PANEL)
end

function LatestSkinShopLayer:OpenChargePanel(arg_123_1)
	if ChargeConst.isNeedSetBirth() then
		self:emit(LatestSkinShopMediator.OPEN_CHARGE_BIRTHDAY)
	else
		pg.m02:sendNotification(GAME.CHARGE_OPERATION, {
			shopId = Goods.Create({
				shop_id = arg_123_1
			}, Goods.TYPE_CHARGE).id
		})
	end
end

function LatestSkinShopLayer:GetObtainBtnState(arg_124_1)
	if arg_124_1:getConfig("genre") == ShopArgs.SkinShopTimeLimit then
		return var_0_9
	elseif self.isPreviewFurniture then
		if getProxy(DormProxy):getRawData():HasFurniture(Goods.Id2FurnitureId(arg_124_1.id)) then
			return var_0_4
		else
			return var_0_8
		end
	elseif arg_124_1.type == Goods.TYPE_ACTIVITY or arg_124_1.type == Goods.TYPE_ACTIVITY_EXTRA then
		return var_0_6
	elseif arg_124_1.buyCount > 0 then
		return var_0_4
	elseif arg_124_1:isDisCount() and arg_124_1:IsItemDiscountType() then
		return var_0_7
	elseif arg_124_1:CanUseVoucherType() or arg_124_1:ExistExclusiveDiscountItem() then
		return var_0_10
	elseif #arg_124_1:GetGiftList() > 0 then
		return var_0_11
	else
		return var_0_5
	end
end

function LatestSkinShopLayer:FlushGift(arg_125_1)
	local var_125_0 = arg_125_1:GetGiftList()[1]

	updateDrop(self.price:Find("btn/item/mask/item"), {
		type = var_125_0.type,
		id = var_125_0.id,
		count = var_125_0.count
	})
end

function LatestSkinShopLayer:OnClickBtn(arg_126_1, arg_126_2)
	if arg_126_1 == var_0_5 or arg_126_1 == var_0_7 or arg_126_1 == var_0_11 then
		self:OnPurchase(arg_126_2)
	elseif arg_126_1 == var_0_10 then
		self:OnItemPurchase(arg_126_2)
	elseif arg_126_1 == var_0_6 then
		self:OnActivity(arg_126_2)
	elseif arg_126_1 == var_0_8 then
		self:OnBackyard(arg_126_2)
	elseif arg_126_1 == var_0_9 then
		if self.mode == NewSkinShopScene.MODE_EXPERIENCE_FOR_ITEM then
			self:OnExperience4Item(arg_126_2)
		else
			self:OnExperience(arg_126_2)
		end
	end
end

function LatestSkinShopLayer:FlushGifgPackBtn(arg_127_1)
	local var_127_0 = false
	local var_127_1
	local var_127_2
	local var_127_3

	for iter_127_0, iter_127_1 in pairs(self.giftSkinCommodities) do
		for iter_127_2, iter_127_3 in ipairs(iter_127_1) do
			if iter_127_3.id == arg_127_1.id then
				var_127_0 = true

				break
			end
		end

		if var_127_0 then
			var_127_1 = self.giftPackCommodities[iter_127_0]
			var_127_2 = self.giftSkinCommodities[iter_127_0]
			var_127_3 = self.giftSkinProbabilitys[iter_127_0]

			break
		end
	end

	if var_127_0 then
		setText(self.giftPackBtn:Find("title"), i18n("skinshop_on_sale_tip_2"))
		onButton(self, self.giftPackBtn, function()
			if not var_127_1:isChargeType() then
				return
			end

			local var_128_0 = var_127_1:GetSkinProbability()

			if #var_128_0 <= 0 or #var_128_0 ~= #getProxy(ShipSkinProxy):GetProbabilitySkins(var_128_0) then
				self:emit(LatestSkinShopMediator.OPEN_SCENE, {
					SCENE.CHARGE,
					{
						wrap = ChargeScene.TYPE_PICK
					}
				})
			else
				self:emit(LatestSkinShopMediator.OPEN_GIFT_PACK_LAYER, var_127_1, var_127_2, var_127_3)
			end
		end, SFX_PANEL)
	else
		var_127_0 = getProxy(ActivityProxy):GetFakeGiftPackActivity(arg_127_1)

		if var_127_0 then
			setText(self.giftPackBtn:Find("title"), i18n("skinshop_on_sale_tip"))
			onButton(self, self.giftPackBtn, function()
				self:emit(LatestSkinShopMediator.OPEN_GIFT_ACT_LAYER, var_127_0.id)
			end, SFX_PANEL)
		end
	end

	setActive(self.giftPackBtn, var_127_0)
end

function LatestSkinShopLayer:SetGiftPackLayer()
	return
end

function LatestSkinShopLayer:OnPurchase(arg_131_1)
	if arg_131_1.type ~= Goods.TYPE_SKIN then
		return
	end

	if arg_131_1:isDisCount() and arg_131_1:IsItemDiscountType() then
		self:emit(LatestSkinShopMediator.ON_SHOPPING_BY_ACT, arg_131_1.id, 1)
	else
		self:emit(LatestSkinShopMediator.ON_SHOPPING, arg_131_1.id, 1)
	end
end

function LatestSkinShopLayer:OnItemPurchase(arg_132_1)
	if arg_132_1.type ~= Goods.TYPE_SKIN then
		return
	end

	local var_132_0 = arg_132_1:GetVoucherIdList()
	local var_132_1 = getProxy(BagProxy):GetExclusiveDiscountItem4Shop(arg_132_1.id)

	if #var_132_0 <= 0 and #var_132_1 <= 0 then
		return
	end

	local var_132_2 = {}

	for iter_132_0, iter_132_1 in ipairs(var_132_0) do
		table.insert(var_132_2, iter_132_1)
	end

	for iter_132_2, iter_132_3 in ipairs(var_132_1) do
		table.insert(var_132_2, iter_132_3.id)
	end

	self.voucherMsgBox:ExecuteAction("Show", {
		itemList = var_132_2,
		skinId = self.skinId,
		skinName = SwitchSpecialChar(pg.ship_skin_template[self.skinId].name, true),
		price = arg_132_1:GetPrice(),
		onYes = function(arg_133_0)
			if arg_133_0 then
				self:emit(LatestSkinShopMediator.ON_ITEM_PURCHASE, arg_133_0, arg_132_1.id)
			else
				self:emit(LatestSkinShopMediator.ON_SHOPPING, arg_132_1.id, 1)
			end
		end
	})
end

function LatestSkinShopLayer:OnActivity(arg_134_1)
	local var_134_0 = arg_134_1:getConfig("activity")
	local var_134_1 = getProxy(ActivityProxy):getActivityById(var_134_0)

	if var_134_0 == 0 then
		if not pg.TimeMgr.GetInstance():inTime((arg_134_1:getConfig("time"))) then
			if var_134_1 and not var_134_1:isEnd() then
				if arg_134_1.type == Goods.TYPE_ACTIVITY then
					self:emit(LatestSkinShopMediator.GO_SHOPS_LAYER, arg_134_1:getConfig("activity"))
				elseif arg_134_1.type == Goods.TYPE_ACTIVITY_EXTRA then
					local var_134_2 = arg_134_1:getConfig("scene")

					if var_134_2 and #var_134_2 > 0 then
						self:emit(LatestSkinShopMediator.OPEN_SCENE, var_134_2)
					else
						self:emit(LatestSkinShopMediator.OPEN_ACTIVITY, var_134_0)
					end
				end

				goto label_134_0
			end
		end
	end

	pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_not_start"))

	::label_134_0::
end

function LatestSkinShopLayer:OnBackyard(arg_135_1)
	if not pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getRawData().level, "BackYardMediator") then
		pg.TipsMgr.GetInstance():ShowTips(i18n("no_open_system_tip", pg.open_systems_limited[1].name, pg.open_systems_limited[1].level))

		return
	end

	self:emit(LatestSkinShopMediator.ON_BACKYARD_SHOP)
end

function LatestSkinShopLayer:OnExperience(arg_136_1)
	local var_136_0 = getProxy(ShipSkinProxy):getSkinById(self.skinId)

	if var_136_0 and not var_136_0:isExpireType() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("already_have_the_skin"))

		return
	end

	local var_136_1 = arg_136_1:getConfig("resource_num")
	local var_136_2, var_136_3, var_136_4, var_136_5 = pg.TimeMgr.GetInstance():parseTimeFrom(arg_136_1:getConfig("time_second") * var_136_1)

	pg.MsgboxMgr.GetInstance():ShowMsgBox({
		content = i18n("exchange_limit_skin_tip", var_136_1, pg.ship_skin_template[self.skinId].name, var_136_2, var_136_3),
		onYes = function()
			if getProxy(PlayerProxy):getRawData():getSkinTicket() < var_136_1 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("common_no_item_1"))

				return
			end

			self:emit(LatestSkinShopMediator.ON_SHOPPING, arg_136_1.id, 1)
		end
	})
end

function LatestSkinShopLayer:OnExperience4Item(arg_138_1)
	local var_138_0 = getProxy(ShipSkinProxy):getSkinById(self.skinId)

	if var_138_0 and not var_138_0:isExpireType() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("already_have_the_skin"))

		return
	end

	local var_138_1 = arg_138_1:getConfig("resource_num")
	local var_138_2, var_138_3, var_138_4, var_138_5 = pg.TimeMgr.GetInstance():parseTimeFrom(arg_138_1:getConfig("time_second") * var_138_1)
	local var_138_6 = _.detect(getProxy(BagProxy):GetSkinExperienceItems(), function(arg_139_0)
		return arg_139_0:CanUseForShop(arg_138_1.id)
	end)

	pg.MsgboxMgr.GetInstance():ShowMsgBox({
		content = i18n("exchange_limit_skin_tip", var_138_1, pg.ship_skin_template[self.skinId].name, var_138_2, var_138_3),
		onYes = function()
			if not var_138_6 or var_138_6.count < var_138_1 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("common_no_item_1"))

				return
			end

			self:emit(LatestSkinShopMediator.ON_ITEM_EXPERIENCE, var_138_6.id, arg_138_1.id, 1)
		end
	})
end

function LatestSkinShopLayer:SetFilterPanel()
	local var_141_0 = self.filterContent:Find("camp/options")
	local var_141_1 = self.filterContent:Find("rarity/options")
	local var_141_2 = self.filterContent:Find("shipType/options")
	local var_141_3 = self.filterContent:Find("themeType/options")

	self:SetOptionList(var_141_0, ShipIndexConst.CampNames, true)
	self:SetOptionList(var_141_1, ShipIndexConst.RarityNames, true)
	self:SetOptionList(var_141_2, ShipIndexConst.TypeNames, true)
	self:SetOptionList(var_141_3, self.classifyNames)
	self:SetSingleOptions(self.filterContent:Find("own/options"), "ownType")
	self:SetMultiOptions(self.filterContent:Find("type/options"), "typeType")
	self:SetSingleOptions(self.filterContent:Find("shipHave/options"), "shipHaveType")
	self:SetMultiOptions(var_141_0, "campType")
	self:SetMultiOptions(var_141_1, "rarityType")
	self:SetMultiOptions(var_141_2, "shipType")
	self:SetMultiOptions(var_141_3, "themeType")
	self:SetMultiOptions(self.filterContent:Find("tag/options"), "tagType")
	self:HideEmptyOptions()
	onButton(self, self.filterUI:Find("bg"), function()
		for iter_142_0, iter_142_1 in pairs(self.filterValues) do
			self.filterValuesTemp[iter_142_0] = Clone(self.filterValues[iter_142_0])
		end

		setActive(self.filterUI, false)
	end, SFX_PANEL)
	onButton(self, self.filterUI:Find("panelMask/panel/closeBtn"), function()
		for iter_143_0, iter_143_1 in pairs(self.filterValues) do
			self.filterValuesTemp[iter_143_0] = Clone(self.filterValues[iter_143_0])
		end

		setActive(self.filterUI, false)
	end, SFX_PANEL)
	onButton(self, self.filterUI:Find("panelMask/panel/bottom/ok"), function()
		for iter_144_0, iter_144_1 in pairs(self.filterValues) do
			self.filterValues[iter_144_0] = Clone(self.filterValuesTemp[iter_144_0])
		end

		setActive(self.filterUI, false)
		self:Refresh(true)
	end, SFX_PANEL)
end

function LatestSkinShopLayer:OpenFilterPanel()
	setActive(self.filterUI, true)
	self:SetSingleOptions(self.filterContent:Find("own/options"), "ownType", true)
	self:SetMultiOptions(self.filterContent:Find("type/options"), "typeType", true)
	self:SetSingleOptions(self.filterContent:Find("shipHave/options"), "shipHaveType", true)
	self:SetMultiOptions(self.filterContent:Find("camp/options"), "campType", true)
	self:SetMultiOptions(self.filterContent:Find("rarity/options"), "rarityType", true)
	self:SetMultiOptions(self.filterContent:Find("shipType/options"), "shipType", true)
	self:SetMultiOptions(self.filterContent:Find("themeType/options"), "themeType", true)
	self:SetMultiOptions(self.filterContent:Find("tag/options"), "tagType", true)
end

function LatestSkinShopLayer:SetOptionList(arg_146_1, arg_146_2, arg_146_3)
	local var_146_0 = UIItemList.New(arg_146_1, arg_146_1:GetChild(0))

	var_146_0:make(function(arg_147_0, arg_147_1, arg_147_2)
		if arg_147_0 == UIItemList.EventUpdate then
			local var_147_0 = arg_146_2[arg_147_1 + 1]

			if arg_146_3 then
				var_147_0 = i18n(var_147_0)
			end

			arg_147_2.name = arg_147_1

			setScrollText(arg_147_2:Find("mask/Text"), var_147_0)
		end
	end)
	var_146_0:align(#arg_146_2)
end

function LatestSkinShopLayer:SetSingleOptions(arg_148_1, arg_148_2, arg_148_3)
	for iter_148_0 = 0, arg_148_1.childCount - 1 do
		local var_148_0 = arg_148_1:GetChild(iter_148_0)

		self:SetOptionSelect(arg_148_1:GetChild(iter_148_0), iter_148_0 == self.filterValuesTemp[arg_148_2])

		if not arg_148_3 then
			onButton(self, var_148_0, function()
				self.filterValuesTemp[arg_148_2] = iter_148_0

				for iter_149_0 = 0, arg_148_1.childCount - 1 do
					self:SetOptionSelect(arg_148_1:GetChild(iter_149_0), iter_149_0 == iter_148_0)
				end
			end, SFX_PANEL)
		end
	end
end

function LatestSkinShopLayer:SetMultiOptions(arg_150_1, arg_150_2, arg_150_3)
	for iter_150_0 = 0, arg_150_1.childCount - 1 do
		local var_150_0 = arg_150_1:GetChild(iter_150_0)

		self:SetOptionSelect(arg_150_1:GetChild(iter_150_0), table.contains(self.filterValuesTemp[arg_150_2], iter_150_0))

		if not arg_150_3 then
			onButton(self, var_150_0, function()
				if iter_150_0 == 0 then
					self.filterValuesTemp[arg_150_2] = {
						0
					}

					for iter_151_0 = 0, arg_150_1.childCount - 1 do
						self:SetOptionSelect(arg_150_1:GetChild(iter_151_0), iter_151_0 == 0)
					end
				else
					table.removebyvalue(self.filterValuesTemp[arg_150_2], 0)

					if table.contains(self.filterValuesTemp[arg_150_2], iter_150_0) then
						table.removebyvalue(self.filterValuesTemp[arg_150_2], iter_150_0)
					else
						table.insert(self.filterValuesTemp[arg_150_2], iter_150_0)
					end

					local var_151_0 = true

					for iter_151_1 = 1, arg_150_1.childCount - 1 do
						if not table.contains(self.filterValuesTemp[arg_150_2], iter_151_1) and arg_150_1:GetChild(iter_151_1).gameObject.activeSelf then
							var_151_0 = false

							break
						end
					end

					if (#self.filterValuesTemp[arg_150_2] == 0 or nil) and true and arg_150_2 ~= "tagType" then
						self.filterValuesTemp[arg_150_2] = {
							0
						}
					end

					for iter_151_2 = 0, arg_150_1.childCount - 1 do
						self:SetOptionSelect(arg_150_1:GetChild(iter_151_2), table.contains(self.filterValuesTemp[arg_150_2], iter_151_2))
					end
				end
			end, SFX_PANEL)
		end
	end
end

function LatestSkinShopLayer:SetOptionSelect(arg_152_1, arg_152_2)
	setActive(arg_152_1:Find("selectedFrame"), arg_152_2)

	;(IsNil(arg_152_1:Find("Text")) and arg_152_1:Find("mask/Text"):GetComponent(typeof(Text)) or arg_152_1:Find("Text"):GetComponent(typeof(Text))).color = arg_152_2 and Color.New(1, 1, 1, 1) or Color.New(0, 0, 0, 0.5)
end

function LatestSkinShopLayer:HideEmptyOptions(arg_153_1, arg_153_2)
	local var_153_0 = {
		typeType = {
			0
		},
		shipHaveType = {
			0
		},
		campType = {
			0
		},
		rarityType = {
			0
		},
		shipType = {
			0
		},
		tagType = {
			0
		}
	}

	for iter_153_0, iter_153_1 in ipairs(self.commodities) do
		local var_153_1 = ShipSkin.New({
			id = iter_153_1:getSkinId()
		})

		for iter_153_2, iter_153_3 in ipairs((self:GetSkinType(var_153_1))) do
			if not table.keyof(var_153_0.typeType, iter_153_3) then
				table.insert(var_153_0.typeType, iter_153_3)
			end
		end

		local var_153_2 = self:GetShipHave(var_153_1)

		if not table.keyof(var_153_0.shipHaveType, var_153_2) then
			table.insert(var_153_0.shipHaveType, var_153_2)
		end

		local var_153_3 = self:GetCampType(var_153_1)

		if not table.keyof(var_153_0.campType, var_153_3) then
			table.insert(var_153_0.campType, var_153_3)
		end

		local var_153_4 = self:GetRarityType(var_153_1)

		if not table.keyof(var_153_0.rarityType, var_153_4) then
			table.insert(var_153_0.rarityType, var_153_4)
		end

		local var_153_5 = self:GetShipType(var_153_1)

		if not table.keyof(var_153_0.shipType, var_153_5) then
			table.insert(var_153_0.shipType, var_153_5)
		end

		local var_153_6 = self:GetTagType(iter_153_1)

		if not table.keyof(var_153_0.tagType, var_153_6) then
			table.insert(var_153_0.tagType, var_153_6)
		end
	end

	for iter_153_4, iter_153_5 in pairs(var_153_0) do
		table.sort(iter_153_5, function(arg_154_0, arg_154_1)
			return arg_154_0 < arg_154_1
		end)
	end

	for iter_153_6 = 1, self.uiTypeOptions.childCount - 1 do
		setActive(self.uiTypeOptions:GetChild(iter_153_6), table.contains(var_153_0.typeType, iter_153_6))
	end

	for iter_153_7 = 1, self.uiShipHaveOptions.childCount - 1 do
		setActive(self.uiShipHaveOptions:GetChild(iter_153_7), table.contains(var_153_0.shipHaveType, iter_153_7))
	end

	for iter_153_8 = 1, self.uiCampOptions.childCount - 1 do
		setActive(self.uiCampOptions:GetChild(iter_153_8), table.contains(var_153_0.campType, iter_153_8))
	end

	for iter_153_9 = 1, self.uiRrarityOptions.childCount - 1 do
		setActive(self.uiRrarityOptions:GetChild(iter_153_9), table.contains(var_153_0.rarityType, iter_153_9))
	end

	for iter_153_10 = 1, self.uiShipTypeOptions.childCount - 1 do
		setActive(self.uiShipTypeOptions:GetChild(iter_153_10), table.contains(var_153_0.shipType, iter_153_10))
	end

	for iter_153_11 = 1, self.uiTagTypeOptions.childCount - 1 do
		setActive(self.uiTagTypeOptions:GetChild(iter_153_11), table.contains(var_153_0.tagType, iter_153_11))
	end
end

function LatestSkinShopLayer:GetSkinType(arg_155_1)
	local var_155_0 = {}

	if arg_155_1:IsLive2d() or arg_155_1:IsLive2dPlus() then
		table.insert(var_155_0, 1)
	end

	if not arg_155_1:IsLive2d() and not arg_155_1:IsLive2dPlus() and not arg_155_1:IsSpine() and not arg_155_1:IsSpinePlus() then
		table.insert(var_155_0, 2)
	end

	if arg_155_1:IsSpine() or arg_155_1:IsSpinePlus() then
		table.insert(var_155_0, 3)
	end

	if arg_155_1:IsBG() then
		table.insert(var_155_0, 4)
	end

	if arg_155_1:IsDbg() then
		table.insert(var_155_0, 5)
	end

	if arg_155_1:isBgm() then
		table.insert(var_155_0, 6)
	end

	return var_155_0
end

function LatestSkinShopLayer:GetShipHave(arg_156_1)
	if arg_156_1:CantUse() then
		return 2
	else
		return 1
	end
end

function LatestSkinShopLayer:GetCampType(arg_157_1)
	local var_157_0 = arg_157_1:GetDefaultShipConfig()

	if not var_157_0 then
		return 0
	end

	local var_157_1 = self:ToVShip(var_157_0):getNation()

	for iter_157_0, iter_157_1 in ipairs(ShipIndexCfg.camp) do
		for iter_157_2, iter_157_3 in ipairs(iter_157_1.types) do
			if iter_157_3 == Nation.LINK then
				if var_157_1 >= Nation.LINK then
					return iter_157_0 - 1
				end
			elseif var_157_1 == iter_157_3 then
				return iter_157_0 - 1
			end
		end
	end

	return 0
end

function LatestSkinShopLayer:GetRarityType(arg_158_1)
	local var_158_0 = arg_158_1:GetDefaultShipConfig()

	if not var_158_0 then
		return 0
	end

	local var_158_1 = self:ToVShip(var_158_0):getRarity()

	for iter_158_0, iter_158_1 in ipairs(ShipIndexCfg.rarity) do
		if table.contains(iter_158_1.types, var_158_1) then
			return iter_158_0 - 1
		end
	end

	return 0
end

function LatestSkinShopLayer:GetShipType(arg_159_1)
	local var_159_0 = arg_159_1:GetDefaultShipConfig()

	if not var_159_0 then
		return 0
	end

	local var_159_1 = self:ToVShip(var_159_0):getShipType()

	for iter_159_0, iter_159_1 in ipairs(ShipIndexCfg.type) do
		for iter_159_2, iter_159_3 in pairs(iter_159_1) do
			if table.keyof(iter_159_3, var_159_1) then
				return iter_159_0 - 1
			end
		end
	end

	return 0
end

function LatestSkinShopLayer:GetTagType(arg_160_1)
	local var_160_0 = NewShopSkinCard.GetTagId(arg_160_1, (table.contains(self.returnSkins, arg_160_1.id)))

	if var_160_0 > 0 then
		return var_160_0
	else
		return 0
	end
end

function LatestSkinShopLayer:GetSkinClassify()
	self.classifyIds = {}
	self.classifyNames = {}

	local var_161_0 = {}
	local var_161_1 = {}

	for iter_161_0, iter_161_1 in ipairs(self.commodities) do
		local var_161_2 = self:GetShopTypeIdBySkinId(iter_161_1:getSkinId())
		local var_161_3

		if var_161_2 == 0 then
			var_161_3 = var_0_16 or var_161_2
		end

		var_161_1[var_161_3] = (var_161_1[var_161_3] or 0) + 1
	end

	local var_161_4 = {}

	for iter_161_2, iter_161_3 in ipairs(self.returnSkins) do
		var_161_4[iter_161_3] = true
	end

	if underscore.any(self.commodities, function(arg_162_0)
		return var_161_4[arg_162_0.id]
	end) then
		table.insert(var_161_0, var_0_14)
	end

	for iter_161_4, iter_161_5 in ipairs(pg.skin_page_template.all) do
		if iter_161_5 ~= var_0_17 and iter_161_5 ~= var_0_18 then
			if (var_161_1[iter_161_5] or 0) > 0 then
				table.insert(var_161_0, iter_161_5)
			end
		end
	end

	if self.mode == LatestSkinShopLayer.MODE_EXPERIENCE then
		table.insert(var_161_0, 1, var_0_13)
	end

	if self.mode == LatestSkinShopLayer.MODE_EXPERIENCE_FOR_ITEM then
		table.insert(var_161_0, 1, var_0_15)
	end

	table.insert(var_161_0, 1, var_0_12)

	self.classifyIds = var_161_0

	for iter_161_6, iter_161_7 in ipairs(self.classifyIds) do
		if iter_161_7 == var_0_12 then
			table.insert(self.classifyNames, i18n("shop_filter_all"))
		elseif iter_161_7 == var_0_13 or iter_161_7 == var_0_15 then
			table.insert(self.classifyNames, i18n("shop_filter_trial"))
		elseif iter_161_7 == var_0_14 then
			table.insert(self.classifyNames, i18n("shop_filter_retro"))
		else
			table.insert(self.classifyNames, pg.skin_page_template[iter_161_7].name)
		end
	end
end

function LatestSkinShopLayer:GetShopTypeIdBySkinId(arg_163_1)
	self.shopTypeIdList = self.shopTypeIdList or {}

	if self.shopTypeIdList[arg_163_1] then
		return self.shopTypeIdList[arg_163_1]
	end

	for iter_163_0, iter_163_1 in pairs(pg.ship_skin_template.get_id_list_by_shop_type_id) do
		for iter_163_2, iter_163_3 in ipairs(iter_163_1) do
			self.shopTypeIdList[iter_163_3] = iter_163_0

			if iter_163_3 == arg_163_1 then
				return iter_163_0
			end
		end
	end
end

function LatestSkinShopLayer:OnShopping(arg_164_1)
	if not self.showingCommodity then
		return
	end

	if self.purchaseView and self.purchaseView:GetLoaded() then
		self.purchaseView:Hide()
	end

	if self.showingCommodity.id == arg_164_1 then
		self.pendingSelectId = self:GetNextCommodityIndex(arg_164_1)

		self:GetAllCommodities()
		self:Refresh(false)
	end
end

function LatestSkinShopLayer:OnFurnitureUpdate(arg_165_1)
	if not self.showingCommodity then
		return
	end

	if Goods.ExistFurniture(self.showingCommodity.id) and Goods.Id2FurnitureId(self.showingCommodity.id) == arg_165_1 then
		self:GetAllCommodities()
		self:Refresh(true)
	end
end

function LatestSkinShopLayer:CheckDownloadSkinList(arg_166_1)
	local var_166_0 = {}

	for iter_166_0, iter_166_1 in ipairs(self.commodities) do
		PaintingGroupConst.AddPaintingNameBySkinID(var_166_0, iter_166_1:getSkinId())
	end

	PaintingGroupConst.PaintingDownload({
		showMask = true,
		isShowBox = true,
		paintingNameList = var_166_0,
		finishFunc = arg_166_1
	})
end

function LatestSkinShopLayer:willExit()
	self:ClearCards()

	self.spriteCache = nil

	ClearLScrollrect(self.scrollrect)
	pg.DynamicBgMgr.GetInstance():ClearBg(self:getUIName())

	if self.live2dChar then
		self.live2dChar:Dispose()

		self.live2dChar = nil
	end

	if self.voucherMsgBox then
		self.voucherMsgBox:Destroy()

		self.voucherMsgBox = nil
	end

	if self.purchaseView then
		self.purchaseView:Destroy()

		self.purchaseView = nil
	end

	for iter_167_0, iter_167_1 in pairs(self.downloads) do
		iter_167_1:Dispose()
	end

	self.downloads = {}

	self:ClearPainting()

	if self.interactionPreview then
		self.interactionPreview:Dispose()

		self.interactionPreview = nil
	end

	self:disposeEvent()
	self:ClearTimer()
	self:ReturnChar()
	self:UnOverlay()
end

function LatestSkinShopLayer:GetNextCommodityIndex(arg_168_1)
	for iter_168_0, iter_168_1 in ipairs(self.displays) do
		if iter_168_1.id == arg_168_1 then
			if iter_168_0 == #self.displays then
				return arg_168_1
			end

			return self.displays[iter_168_0 + 1].id
		end
	end
end

function LatestSkinShopLayer:onBackPressed()
	pg.m02:sendNotification(NewShopMainScene.CLOSE_VIEW)
end

return LatestSkinShopLayer
