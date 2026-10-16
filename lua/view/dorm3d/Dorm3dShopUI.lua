local Dorm3dShopUI = class("Dorm3dShopUI", import("view.base.BaseUI"))
local var_0_1 = pg.dorm3d_set
local var_0_2 = pg.dorm3d_shop_template
local var_0_3 = setmetatable({}, {
	__index = function(self, arg_1_1)
		self[arg_1_1] = ShopConst.GetShopConfig(arg_1_1)

		return self[arg_1_1]
	end
})
local var_0_4 = pg.dorm3d_rooms
local var_0_5 = pg.dorm3d_gift
local var_0_6 = pg.dorm3d_furniture_template

function Dorm3dShopUI:getUIName()
	return "Dorm3dShopUI"
end

function Dorm3dShopUI:getResource()
	local var_3_0 = {
		"weaponframes",
		"ui/shoptip_atlas"
	}

	local function var_3_1(arg_4_0)
		if noEmptyStr(arg_4_0) and not table.contains(var_3_0, arg_4_0) then
			table.insert(var_3_0, arg_4_0)
		end
	end

	local function var_3_2(arg_5_0, arg_5_1)
		if arg_5_1 then
			var_3_1(Drop.New({
				count = 0,
				type = arg_5_0,
				id = arg_5_1
			}):getIcon())
		end
	end

	for iter_3_0, iter_3_1 in ipairs(var_0_4.all or {}) do
		if var_0_4[iter_3_1] and var_0_4[iter_3_1].type == 2 and noEmptyStr(var_0_4[iter_3_1].assets_prefix) then
			var_3_1("dorm3dselect/room_icon_" .. string.lower(var_0_4[iter_3_1].assets_prefix))
		end
	end

	for iter_3_2, iter_3_3 in ipairs(var_0_2.all or {}) do
		if var_0_2[iter_3_3] then
			local var_3_3 = var_0_2[iter_3_3].banners and var_0_2[iter_3_3].banners[1]

			if noEmptyStr(var_3_3) then
				var_3_1("dorm3dbanner/" .. var_3_3 .. "_shopCard1")
				var_3_1("dorm3dbanner/" .. var_3_3 .. "_shopCard2")
			end

			if var_0_2[iter_3_3].type == 1 then
				var_3_2(DROP_TYPE_DORM3D_FURNITURE, var_0_2[iter_3_3].item_id)

				if var_0_6[var_0_2[iter_3_3].item_id] then
					if #(var_0_6[var_0_2[iter_3_3].item_id].unlock_tips or {}) > 0 then
						var_3_1("ui/shoptip_atlas")
					end
				end
			elseif var_0_2[iter_3_3].type == 2 then
				var_3_2(DROP_TYPE_DORM3D_GIFT, var_0_2[iter_3_3].item_id)

				if var_0_5[var_0_2[iter_3_3].item_id] then
					if #(var_0_5[var_0_2[iter_3_3].item_id].unlock_tips or {}) > 0 then
						var_3_1("ui/shoptip_atlas")
					end
				end
			elseif var_0_2[iter_3_3].type == 3 then
				for iter_3_4, iter_3_5 in ipairs((var_0_4[var_0_2[iter_3_3].item_id] or nil) and (var_0_4[var_0_2[iter_3_3].item_id].invite_icon or {})) do
					var_3_1(iter_3_5[2])
				end
			end
		end
	end

	return table.insertto(var_3_0, Dorm3dShopUI.super.getResource(self))
end

function Dorm3dShopUI:init()
	self.closeBtn = self.rtAdapt:Find("closeBtn")
	self.res = self.rtAdapt:Find("resourceBg/res")
	self.recommendationTg = self.rtAdapt:Find("left/recommendation")
	self.charaList = UIItemList.New(self.rtAdapt:Find("left/charaScroll/mask/list"), self.rtAdapt:Find("left/charaScroll/mask/list/tpl"))
	self.recommendationPage = self.rtAdapt:Find("pages/recommendationPage")
	self.charaPage = self.rtAdapt:Find("pages/charaPage")
	self.mask = self._tf:Find("mask")

	setText(self.rtAdapt:Find("title/Text"), i18n("dorm3d_shop_title"))
	setText(self.recommendationPage:Find("bannerCard/mask/content/item/soldOut"), i18n("dorm3d_shop_sold_out"))
	setText(self.recommendationPage:Find("giftCard/soldOut"), i18n("dorm3d_shop_sold_out"))
	setText(self.recommendationPage:Find("card1/soldOut"), i18n("dorm3d_shop_sold_out"))
	setText(self.recommendationPage:Find("card2/soldOut"), i18n("dorm3d_shop_sold_out"))
	setText(self.recommendationPage:Find("card3/soldOut"), i18n("dorm3d_shop_sold_out"))
	setText(self.charaPage:Find("scroll/Viewport/Content/card/soldOut"), i18n("dorm3d_shop_sold_out"))
	setText(self.charaPage:Find("switch/all/Text"), i18n("dorm3d_shop_all"))
	setText(self.charaPage:Find("switch/gift/Text"), i18n("dorm3d_shop_gift1"))
	setText(self.charaPage:Find("switch/furniture/Text"), i18n("dorm3d_shop_furniture"))
	setText(self.charaPage:Find("switch/others/Text"), i18n("dorm3d_shop_others"))
	setText(self.charaPage:Find("switch/all/selected/Text"), i18n("dorm3d_shop_all"))
	setText(self.charaPage:Find("switch/gift/selected/Text"), i18n("dorm3d_shop_gift1"))
	setText(self.charaPage:Find("switch/furniture/selected/Text"), i18n("dorm3d_shop_furniture"))
	setText(self.charaPage:Find("switch/others/selected/Text"), i18n("dorm3d_shop_others"))
end

function Dorm3dShopUI:didEnter()
	self:InitData()
	onButton(self, self.closeBtn, function()
		self:closeView()
	end, SFX_PANEL)
	self:ShowResUI()
	self:SetPageBtns()
	triggerToggle(self.recommendationTg, true)
end

function Dorm3dShopUI:InitData()
	self.bannerCount = var_0_1.drom3d_shop_product_panel_num.key_value_int
	self.allCommodityCfgs = {}

	for iter_9_0, iter_9_1 in ipairs(var_0_2.all) do
		table.insert(self.allCommodityCfgs, var_0_2[iter_9_1])
	end

	table.sort(self.allCommodityCfgs, function(arg_10_0, arg_10_1)
		if tonumber(arg_10_0.order) ~= tonumber(arg_10_1.order) then
			return tonumber(arg_10_0.order) < tonumber(arg_10_1.order)
		end

		return arg_10_0.id > arg_10_1.id
	end)

	self.roomCfgs = {}

	_.each(var_0_4.all, function(arg_11_0)
		if var_0_4[arg_11_0].type == 2 then
			table.insert(self.roomCfgs, var_0_4[arg_11_0])
		end
	end)
	table.sort(self.roomCfgs, function(arg_12_0, arg_12_1)
		return arg_12_0.id < arg_12_1.id
	end)

	self.selectedId = 0
end

function Dorm3dShopUI:SetPageBtns()
	SetParent(self.recommendationTg, self.rtAdapt:Find("left"), false)
	self.charaList:make(function(arg_14_0, arg_14_1, arg_14_2)
		if arg_14_0 == UIItemList.EventUpdate then
			local var_14_0 = self.roomCfgs[arg_14_1 + 1]

			GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(self.roomCfgs[arg_14_1 + 1].assets_prefix)), "", arg_14_2:Find("mask/icon"), false)
			setActive(arg_14_2:Find("tip"), Dorm3dShopUI.ShouldShowSumTip((self:GetCommoditiesCfgByChara(self.roomCfgs[arg_14_1 + 1].character[1]))))
			onToggle(self, arg_14_2, function(arg_15_0)
				if arg_15_0 then
					self.selectedId = var_14_0.id

					self:SetPageBtns()
					self:RefreshPage()
				end
			end)
		end
	end)
	self.charaList:align(#self.roomCfgs)

	self.showingCommoditiesIndex = {}

	local var_13_0 = {}

	table.insertto(var_13_0, self:GetCommoditiesCfgByPanel(1, self.bannerCount))
	table.insertto(var_13_0, self:GetCommoditiesCfgByPanel(2, 1))
	table.insertto(var_13_0, self:GetCommoditiesCfgByPanel(3, 1))
	table.insertto(var_13_0, self:GetCommoditiesCfgByPanel(4, 1))
	table.insertto(var_13_0, self:GetCommoditiesCfgByPanel(5, 1))
	setActive(self.recommendationTg:Find("icon/tip"), Dorm3dShopUI.ShouldShowSumTip(var_13_0))
	onToggle(self, self.recommendationTg, function(arg_16_0)
		if arg_16_0 then
			self.selectedId = 0

			self:SetPageBtns()
			self:RefreshPage()
		end
	end)
	SetParent(self.recommendationTg, self.rtAdapt:Find("left/charaScroll/mask/list"), false)
	self.recommendationTg:SetSiblingIndex(0)
end

function Dorm3dShopUI:GetCommoditiesCfgByPanel(arg_17_1, arg_17_2)
	local var_17_0 = {}
	local var_17_1 = 0

	for iter_17_0, iter_17_1 in ipairs(self.allCommodityCfgs) do
		if not table.contains(self.showingCommoditiesIndex, iter_17_0) and table.contains(iter_17_1.panel, arg_17_1) then
			if not (self:IsCommodityOutOfDate(iter_17_1) or self:IsCommoditySoldOut(iter_17_1)) then
				var_17_1 = var_17_1 + 1

				table.insert(var_17_0, iter_17_1)
				table.insert(self.showingCommoditiesIndex, iter_17_0)
			end

			if var_17_1 == arg_17_2 then
				break
			end
		end
	end

	if var_17_1 < arg_17_2 then
		for iter_17_2, iter_17_3 in ipairs(self.allCommodityCfgs) do
			if not table.contains(self.showingCommoditiesIndex, iter_17_2) and table.contains(iter_17_3.panel, arg_17_1) then
				if not self:IsCommodityOutOfDate(iter_17_3) then
					var_17_1 = var_17_1 + 1

					table.insert(var_17_0, iter_17_3)
					table.insert(self.showingCommoditiesIndex, iter_17_2)
				end

				if var_17_1 == arg_17_2 then
					break
				end
			end
		end
	end

	return var_17_0
end

function Dorm3dShopUI:GetCommoditiesCfgByChara(arg_18_1)
	local var_18_0 = {}
	local var_18_1 = {}

	for iter_18_0, iter_18_1 in ipairs(self.allCommodityCfgs) do
		local var_18_2 = {}

		if iter_18_1.realroom_id ~= 0 then
			table.insertto(var_18_2, var_0_4[iter_18_1.realroom_id].character)
			table.insertto(var_18_2, var_0_4[iter_18_1.realroom_id].character_pay)
		end

		if iter_18_1.room_id == arg_18_1 or iter_18_1.room_id == 0 then
			if iter_18_1.realroom_id ~= 0 then
				if iter_18_1.realroom_id ~= 0 and table.contains(var_18_2, arg_18_1) then
					if not self:IsCommodityOutOfDate(iter_18_1) then
						if not self:IsCommoditySoldOut(iter_18_1) then
							table.insert(var_18_0, iter_18_1)
						else
							table.insert(var_18_1, iter_18_1)
						end
					end
				end
			end
		end
	end

	if #var_18_1 > 0 then
		table.insertto(var_18_0, var_18_1)
	end

	return var_18_0
end

function Dorm3dShopUI:IsCommodityOutOfDate(arg_19_1)
	for iter_19_0, iter_19_1 in ipairs(arg_19_1.shop_id) do
		if not pg.TimeMgr.GetInstance():inTime(var_0_3[iter_19_1].time) then
			return true
		end
	end

	return false
end

function Dorm3dShopUI:IsCommoditySoldOut(arg_20_1)
	if arg_20_1.type == 1 then
		if getProxy(ApartmentProxy):GetFurnitureShopCount(arg_20_1.item_id) > 0 then
			return true
		end
	elseif arg_20_1.type == 2 then
		return not Dorm3dGift.New({
			configId = arg_20_1.item_id
		}):CheckBuyLimit()
	elseif arg_20_1.type == 3 then
		local var_20_0 = getProxy(ApartmentProxy):getRoom(arg_20_1.item_id)

		return var_20_0 and var_20_0.unlockCharacter[arg_20_1.room_id]
	end

	return false
end

function Dorm3dShopUI:ShowResUI()
	self.goldMax = self.res:Find("gold/max"):GetComponent(typeof(Text))
	self.goldValue = self.res:Find("gold/Text"):GetComponent(typeof(Text))
	self.oilMax = self.res:Find("oil/max"):GetComponent(typeof(Text))
	self.oilValue = self.res:Find("oil/Text"):GetComponent(typeof(Text))
	self.gemValue = self.res:Find("gem/Text"):GetComponent(typeof(Text))

	PlayerResUI.StaticFlush(getProxy(PlayerProxy):getRawData(), self.goldMax, self.goldValue, self.oilMax, self.oilValue, self.gemValue)
	onButton(self, self.res:Find("gold"), function()
		pg.playerResUI:ClickGold()
	end, SFX_PANEL)
	onButton(self, self.res:Find("oil"), function()
		pg.playerResUI:ClickOil()
	end, SFX_PANEL)
	onButton(self, self.res:Find("gem"), function()
		pg.playerResUI:ClickGem()
	end, SFX_PANEL)
end

function Dorm3dShopUI:RefreshPage()
	self.showingCommoditiesIndex = {}

	setActive(self.recommendationPage, self.selectedId == 0)
	setActive(self.charaPage, self.selectedId ~= 0)

	if self.selectedId == 0 then
		self:SetBannnerCard()
		self:SetGiftCard()
		self:SetNormalCard()
	else
		self:SetCharaCard()
	end
end

function Dorm3dShopUI:SetBannnerCard()
	local var_26_0 = self.recommendationPage:Find("bannerCard")

	self.scrollSnap = self.scrollSnap or BannerScrollRectDorm3dShop.New(var_26_0:Find("mask/content"), var_26_0:Find("dots"))

	for iter_26_0, iter_26_1 in ipairs((self:GetCommoditiesCfgByPanel(1, self.bannerCount))) do
		local var_26_1 = self.scrollSnap:GetItemChild(iter_26_0) or self.scrollSnap:AddChild()
		local var_26_2 = self:IsCommoditySoldOut(iter_26_1)
		local var_26_3 = false
		local var_26_4 = false
		local var_26_5 = {}
		local var_26_6 = 0
		local var_26_7 = ""
		local var_26_8 = ""
		local var_26_9 = var_0_3[iter_26_1.shop_id[1]].group_type == 2 and i18n("dorm3d_shop_limit1") or i18n("dorm3d_shop_limit")

		if iter_26_1.type == 1 then
			local var_26_10 = var_0_6[iter_26_1.item_id]

			var_26_4 = var_0_6[iter_26_1.item_id].is_special == 1
			var_26_3 = not var_26_4 and var_26_10.is_exclusive == 1
			var_26_7 = Drop.New({
				count = 0,
				type = DROP_TYPE_DORM3D_FURNITURE,
				id = var_26_10.id
			}):getIcon()
			var_26_8 = var_26_9 .. " " .. getProxy(ApartmentProxy):GetFurnitureShopCount(iter_26_1.item_id) .. "/1"
			var_26_5 = var_26_10.unlock_tips or {}
			var_26_6 = iter_26_1.shop_id[1]
		elseif iter_26_1.type == 2 then
			local var_26_11 = var_0_5[iter_26_1.item_id]

			var_26_3 = iter_26_1.room_id ~= 0

			local var_26_12 = Dorm3dGift.New({
				configId = iter_26_1.item_id
			})
			local var_26_13 = {
				type = DROP_TYPE_DORM3D_GIFT,
				id = iter_26_1.item_id
			}

			var_26_13.count = getProxy(ApartmentProxy):getGiftCount(iter_26_1.item_id)
			var_26_7 = Drop.New(var_26_13):getIcon()

			local var_26_14 = 0

			for iter_26_2 = 1, #iter_26_1.shop_id do
				if not var_0_3[iter_26_1.shop_id[iter_26_2]].limit_args[1] and var_0_3[iter_26_1.shop_id[iter_26_2]].group_type == 0 then
					var_26_14 = 0
				elseif var_0_3[iter_26_1.shop_id[iter_26_2]].limit_args[1] and (var_0_3[iter_26_1.shop_id[iter_26_2]].limit_args[1][1] == "dailycount" or var_0_3[iter_26_1.shop_id[iter_26_2]].limit_args[1][1] == "count") then
					var_26_14 = var_0_3[iter_26_1.shop_id[iter_26_2]].limit_args[1][3]
				elseif var_0_3[iter_26_1.shop_id[iter_26_2]].group_type == 2 then
					var_26_14 = var_0_3[iter_26_1.shop_id[iter_26_2]].group_limit
				end
			end

			var_26_8 = var_26_9 .. " " .. getProxy(ApartmentProxy):GetGiftShopCount(iter_26_1.item_id) .. "/" .. var_26_14

			setText(var_26_1:Find("favor/number"), "+" .. pg.dorm3d_favor_trigger[var_0_5[iter_26_1.item_id].favor_trigger_id].num)

			var_26_1:Find("favor"):GetComponent(typeof(CanvasGroup)).alpha = var_26_2 and 0.5 or 1
			var_26_5 = var_26_11.unlock_tips or {}
			var_26_6 = var_26_12:GetShopID()
		elseif iter_26_1.type == 3 then
			var_26_3 = true

			for iter_26_3, iter_26_4 in ipairs(var_0_4[iter_26_1.item_id].invite_icon) do
				if iter_26_4[1] == iter_26_1.room_id then
					var_26_7 = iter_26_4[2]
				end
			end

			var_26_8 = var_26_9 .. " " .. (var_26_2 and 1 or 0) .. "/1"
			var_26_6 = iter_26_1.shop_id[1]
		end

		setActive(var_26_1:Find("bg/normal"), not var_26_3 and not var_26_4)
		setActive(var_26_1:Find("bg/zhuanshu"), var_26_3)
		setActive(var_26_1:Find("bg/tedian"), var_26_4)
		setActive(var_26_1:Find("normal"), not var_26_3 and not var_26_4)
		setActive(var_26_1:Find("zhuanshu"), var_26_3)
		setActive(var_26_1:Find("tedian"), var_26_4)
		setActive(var_26_1:Find("favor"), iter_26_1.type == 2)
		LoadImageSpriteAsync("dorm3dbanner/" .. iter_26_1.banners[1] .. "_shopCard1", var_26_1:Find("bannerMask/banner"), true)
		setText(var_26_1:Find("name"), iter_26_1.name)

		local var_26_15 = var_0_3[iter_26_1.shop_id[1]].time

		setActive(var_26_1:Find("timeLimit"), var_0_3[iter_26_1.shop_id[1]].time ~= "always")

		if var_26_15 ~= "always" then
			setText(var_26_1:Find("timeLimit/Text"), self:GetTimeRemain((pg.TimeMgr.GetInstance():parseTimeFromConfig(var_26_15[2]))))
		end

		self:SetBubbles(UIItemList.New(var_26_1:Find("bubbles/content"), var_26_1:Find("bubbles/content/tpl")), var_26_5)
		setActive(var_26_1:Find("consume"), not var_26_2)
		setActive(var_26_1:Find("soldOut"), var_26_2)

		local var_26_16 = CommonCommodity.New({
			id = var_26_6
		}, Goods.TYPE_SHOPSTREET)
		local var_26_17, var_26_18, var_26_19 = var_26_16:GetPrice()
		local var_26_20 = Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = var_26_16:GetResType(),
			count = var_26_17
		})

		setText(var_26_1:Find("consume/Text"), "<icon name=" .. var_26_16:GetResIcon() .. " w=0.81 h=0.81/>" .. var_26_17)
		GetImageSpriteFromAtlasAsync(var_26_7, "", var_26_1:Find("normal/Dorm3dIconTpl/icon"))
		GetImageSpriteFromAtlasAsync(var_26_7, "", var_26_1:Find("zhuanshu/Dorm3dIconTpl/icon"))
		GetImageSpriteFromAtlasAsync(var_26_7, "", var_26_1:Find("tedian/Dorm3dIconTpl/icon"))
		setText(var_26_1:Find("normal/countLimit"), var_26_8)
		setText(var_26_1:Find("zhuanshu/countLimit"), var_26_8)
		setText(var_26_1:Find("tedian/countLimit"), var_26_8)

		var_26_1:Find("normal/Dorm3dIconTpl"):GetComponent(typeof(CanvasGroup)).alpha = var_26_2 and 0.5 or 1
		var_26_1:Find("zhuanshu/Dorm3dIconTpl"):GetComponent(typeof(CanvasGroup)).alpha = var_26_2 and 0.5 or 1
		var_26_1:Find("tedian/Dorm3dIconTpl"):GetComponent(typeof(CanvasGroup)).alpha = var_26_2 and 0.5 or 1

		if not var_26_2 then
			onButton(self, var_26_1, function()
				self:ClickCommodity(iter_26_1, var_26_1:Find("tip"))
			end, SFX_PANEL)
		else
			onButton(self, var_26_1, function()
				Dorm3dShopUI.UpdateCommodtyTip(iter_26_1)
				setActive(var_26_1:Find("tip"), false)
				pg.TipsMgr.GetInstance():ShowTips(i18n("word_sell_out"))
			end, SFX_PANEL)
		end

		local var_26_21 = Dorm3dShopUI.ShouldShowCommodtyTip(iter_26_1)

		setActive(var_26_1:Find("new"), var_26_21)
		setActive(var_26_1:Find("tip"), var_26_21)
	end

	self.scrollSnap:SetUp()
end

function Dorm3dShopUI:SetGiftCard()
	local var_29_0 = self.recommendationPage:Find("giftCard")
	local var_29_1 = self:GetCommoditiesCfgByPanel(2, 1)[1]
	local var_29_2 = 0
	local var_29_3 = self:IsCommoditySoldOut(var_29_1)
	local var_29_4 = ""
	local var_29_5 = false
	local var_29_6 = false
	local var_29_7 = var_0_3[var_29_1.shop_id[1]].group_type == 2 and i18n("dorm3d_shop_limit1") or i18n("dorm3d_shop_limit")

	if var_29_1.type == 1 then
		local var_29_8 = var_0_6[var_29_1.item_id]

		var_29_6 = var_0_6[var_29_1.item_id].is_special == 1
		var_29_5 = not (var_29_6 or var_29_8.is_exclusive ~= 1)

		updateCustomDrop(var_29_0:Find("Dorm3dIconTpl"), (Drop.New({
			count = 0,
			type = DROP_TYPE_DORM3D_FURNITURE,
			id = var_29_8.id
		})))

		var_29_2 = var_29_1.shop_id[1]
		var_29_4 = var_29_7 .. " " .. getProxy(ApartmentProxy):GetFurnitureShopCount(var_29_1.item_id) .. "/1"
	elseif var_29_1.type == 2 then
		var_29_5 = var_29_1.room_id ~= 0

		local var_29_10 = Dorm3dGift.New({
			configId = var_29_1.item_id
		})
		local var_29_11 = {
			type = DROP_TYPE_DORM3D_GIFT,
			id = var_29_1.item_id
		}

		var_29_11.count = getProxy(ApartmentProxy):getGiftCount(var_29_1.item_id)

		setText(var_29_0:Find("favor/number"), "+" .. pg.dorm3d_favor_trigger[var_0_5[var_29_1.item_id].favor_trigger_id].num)
		updateCustomDrop(var_29_0:Find("Dorm3dIconTpl"), (Drop.New(var_29_11)))

		var_29_2 = var_29_10:GetShopID()

		local var_29_12 = 0

		for iter_29_0 = 1, #var_29_1.shop_id do
			if not var_0_3[var_29_1.shop_id[iter_29_0]].limit_args[1] and var_0_3[var_29_1.shop_id[iter_29_0]].group_type == 0 then
				var_29_12 = 0
			elseif var_0_3[var_29_1.shop_id[iter_29_0]].limit_args[1] and (var_0_3[var_29_1.shop_id[iter_29_0]].limit_args[1][1] == "dailycount" or var_0_3[var_29_1.shop_id[iter_29_0]].limit_args[1][1] == "count") then
				var_29_12 = var_0_3[var_29_1.shop_id[iter_29_0]].limit_args[1][3]
			elseif var_0_3[var_29_1.shop_id[iter_29_0]].group_type == 2 then
				var_29_12 = var_0_3[var_29_1.shop_id[iter_29_0]].group_limit
			end
		end

		var_29_4 = var_29_7 .. " " .. getProxy(ApartmentProxy):GetGiftShopCount(var_29_1.item_id) .. "/" .. var_29_12
	elseif var_29_1.type == 3 then
		var_29_5 = true

		local var_29_13 = ""

		for iter_29_1, iter_29_2 in ipairs(var_0_4[var_29_1.item_id].invite_icon) do
			if iter_29_2[1] == var_29_1.room_id then
				var_29_13 = iter_29_2[2]
			end
		end

		GetImageSpriteFromAtlasAsync(var_29_13, "", var_29_0:Find("Dorm3dIconTpl/icon"))
		GetImageSpriteFromAtlasAsync("weaponframes", "dorm3d_" .. ItemRarity.Rarity2Print(var_29_1.rarity), var_29_0:Find("Dorm3dIconTpl"))

		var_29_4 = var_29_7 .. " " .. (var_29_3 and 1 or 0) .. "/1"
		var_29_2 = var_29_1.shop_id[1]
	end

	var_29_0:Find("Dorm3dIconTpl"):GetComponent(typeof(CanvasGroup)).alpha = var_29_3 and 0.5 or 1
	var_29_0:Find("favor"):GetComponent(typeof(CanvasGroup)).alpha = var_29_3 and 0.5 or 1

	setActive(var_29_0:Find("bg/normal"), not var_29_5 and not var_29_6)
	setActive(var_29_0:Find("bg/zhuanshu"), var_29_5)
	setActive(var_29_0:Find("bg/tedian"), var_29_6)
	setActive(var_29_0:Find("normal"), not var_29_5 and not var_29_6)
	setActive(var_29_0:Find("zhuanshu"), var_29_5)
	setActive(var_29_0:Find("tedian"), var_29_6)
	setText(var_29_0:Find("normal/countLimit"), var_29_4)
	setText(var_29_0:Find("zhuanshu/countLimit"), var_29_4)
	setText(var_29_0:Find("tedian/countLimit"), var_29_4)
	LoadImageSpriteAsync("dorm3dbanner/" .. var_29_1.banners[1] .. "_shopCard2", var_29_0:Find("mask/item"), true)
	setScrollText(var_29_0:Find("name/text"), var_29_1.name)
	setActive(var_29_0:Find("favor"), var_29_1.type == 2)
	setActive(var_29_0:Find("consume"), not var_29_3)
	setActive(var_29_0:Find("soldOut"), var_29_3)

	local var_29_14 = var_0_3[var_29_1.shop_id[1]].time

	setActive(var_29_0:Find("timeLimit"), var_0_3[var_29_1.shop_id[1]].time ~= "always")

	if var_29_14 ~= "always" then
		setText(var_29_0:Find("timeLimit/Text"), self:GetTimeRemain((pg.TimeMgr.GetInstance():parseTimeFromConfig(var_29_14[2]))))
	end

	local var_29_15 = CommonCommodity.New({
		id = var_29_2
	}, Goods.TYPE_SHOPSTREET)
	local var_29_16, var_29_17, var_29_18 = var_29_15:GetPrice()
	local var_29_19 = Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = var_29_15:GetResType(),
		count = var_29_16
	})

	setText(var_29_0:Find("consume/Text"), "<icon name=" .. var_29_15:GetResIcon() .. " w=0.81 h=0.81/>" .. var_29_16)

	if not var_29_3 then
		onButton(self, var_29_0, function()
			self:ClickCommodity(var_29_1, var_29_0:Find("tip"))
		end, SFX_PANEL)
	else
		onButton(self, var_29_0, function()
			Dorm3dShopUI.UpdateCommodtyTip(var_29_1)
			setActive(var_29_0:Find("tip"), false)
			pg.TipsMgr.GetInstance():ShowTips(i18n("word_sell_out"))
		end, SFX_PANEL)
	end

	local var_29_20 = Dorm3dShopUI.ShouldShowCommodtyTip(var_29_1)

	setActive(var_29_0:Find("new"), var_29_20)
	setActive(var_29_0:Find("tip"), var_29_20)
end

function Dorm3dShopUI:SetNormalCard()
	for iter_32_0 = 1, 3 do
		local var_32_0 = self.recommendationPage:Find("card" .. iter_32_0)
		local var_32_1 = self:GetCommoditiesCfgByPanel(iter_32_0 + 2, 1)[1]
		local var_32_2 = false
		local var_32_3 = false
		local var_32_4 = self:IsCommoditySoldOut(var_32_1)
		local var_32_5 = {}
		local var_32_6 = 0
		local var_32_7 = ""
		local var_32_8 = var_0_3[var_32_1.shop_id[1]].group_type == 2 and i18n("dorm3d_shop_limit1") or i18n("dorm3d_shop_limit")

		if var_32_1.type == 1 then
			local var_32_9 = var_0_6[var_32_1.item_id]

			var_32_2 = var_0_6[var_32_1.item_id].is_special == 1
			var_32_3 = not var_32_2 and var_32_9.is_exclusive == 1
			var_32_7 = Drop.New({
				count = 0,
				type = DROP_TYPE_DORM3D_FURNITURE,
				id = var_32_9.id
			}):getIcon()

			setText(var_32_0:Find("countLimit/Text"), var_32_8 .. " " .. getProxy(ApartmentProxy):GetFurnitureShopCount(var_32_1.item_id) .. "/1")

			var_32_5 = var_32_9.unlock_tips or {}
			var_32_6 = var_32_1.shop_id[1]
		elseif var_32_1.type == 2 then
			local var_32_10 = var_0_5[var_32_1.item_id]

			var_32_3 = var_32_1.room_id ~= 0

			local var_32_11 = Dorm3dGift.New({
				configId = var_32_1.item_id
			})
			local var_32_12 = {
				type = DROP_TYPE_DORM3D_GIFT,
				id = var_32_1.item_id
			}

			var_32_12.count = getProxy(ApartmentProxy):getGiftCount(var_32_1.item_id)
			var_32_7 = Drop.New(var_32_12):getIcon()

			local var_32_13 = 0

			for iter_32_1 = 1, #var_32_1.shop_id do
				if not var_0_3[var_32_1.shop_id[iter_32_1]].limit_args[1] and var_0_3[var_32_1.shop_id[iter_32_1]].group_type == 0 then
					var_32_13 = 0
				elseif var_0_3[var_32_1.shop_id[iter_32_1]].limit_args[1] and (var_0_3[var_32_1.shop_id[iter_32_1]].limit_args[1][1] == "dailycount" or var_0_3[var_32_1.shop_id[iter_32_1]].limit_args[1][1] == "count") then
					var_32_13 = var_0_3[var_32_1.shop_id[iter_32_1]].limit_args[1][3]
				elseif var_0_3[var_32_1.shop_id[iter_32_1]].group_type == 2 then
					var_32_13 = var_0_3[var_32_1.shop_id[iter_32_1]].group_limit
				end
			end

			setText(var_32_0:Find("countLimit/Text"), var_32_8 .. " " .. getProxy(ApartmentProxy):GetGiftShopCount(var_32_1.item_id) .. "/" .. var_32_13)
			setText(var_32_0:Find("normal/favor/number"), "+" .. pg.dorm3d_favor_trigger[var_0_5[var_32_1.item_id].favor_trigger_id].num)
			setText(var_32_0:Find("zhuanshu/favor/number"), "+" .. pg.dorm3d_favor_trigger[var_0_5[var_32_1.item_id].favor_trigger_id].num)
			setText(var_32_0:Find("tedian/favor/number"), "+" .. pg.dorm3d_favor_trigger[var_0_5[var_32_1.item_id].favor_trigger_id].num)

			var_32_5 = var_32_10.unlock_tips or {}
			var_32_6 = var_32_11:GetShopID()
		elseif var_32_1.type == 3 then
			var_32_3 = true

			for iter_32_2, iter_32_3 in ipairs(var_0_4[var_32_1.item_id].invite_icon) do
				if iter_32_3[1] == var_32_1.room_id then
					var_32_7 = iter_32_3[2]
				end
			end

			setText(var_32_0:Find("countLimit/Text"), var_32_8 .. " " .. (var_32_4 and 1 or 0) .. "/1")

			var_32_6 = var_32_1.shop_id[1]
		end

		setActive(var_32_0:Find("bg/normal"), not var_32_3 and not var_32_2)
		setActive(var_32_0:Find("bg/zhuanshu"), var_32_3)
		setActive(var_32_0:Find("bg/tedian"), var_32_2)
		setActive(var_32_0:Find("normal"), not var_32_3 and not var_32_2)
		setActive(var_32_0:Find("zhuanshu"), var_32_3)
		setActive(var_32_0:Find("tedian"), var_32_2)
		setActive(var_32_0:Find("normal/favor"), var_32_1.type == 2)
		setActive(var_32_0:Find("zhuanshu/favor"), var_32_1.type == 2)
		setActive(var_32_0:Find("tedian/favor"), var_32_1.type == 2)
		setText(var_32_0:Find("name"), var_32_1.name)
		self:SetBubbles(UIItemList.New(var_32_0:Find("bubbles/content"), var_32_0:Find("bubbles/content/tpl")), var_32_5)
		setActive(var_32_0:Find("consume"), not var_32_4)
		setActive(var_32_0:Find("soldOut"), var_32_4)

		local var_32_14 = CommonCommodity.New({
			id = var_32_6
		}, Goods.TYPE_SHOPSTREET)
		local var_32_15, var_32_16, var_32_17 = var_32_14:GetPrice()
		local var_32_18 = Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = var_32_14:GetResType(),
			count = var_32_15
		})

		setText(var_32_0:Find("consume/Text"), "<icon name=" .. var_32_14:GetResIcon() .. " w=0.81 h=0.81/>" .. var_32_15)
		GetImageSpriteFromAtlasAsync(var_32_7, "", var_32_0:Find("normal/mask/Dorm3dIconTpl/icon"))
		GetImageSpriteFromAtlasAsync(var_32_7, "", var_32_0:Find("zhuanshu/mask/Dorm3dIconTpl/icon"))
		GetImageSpriteFromAtlasAsync(var_32_7, "", var_32_0:Find("tedian/mask/Dorm3dIconTpl/icon"))

		if not var_32_4 then
			onButton(self, var_32_0, function()
				self:ClickCommodity(var_32_1, var_32_0:Find("tip"))
			end, SFX_PANEL)
		else
			onButton(self, var_32_0, function()
				pg.TipsMgr.GetInstance():ShowTips(i18n("word_sell_out"))
				Dorm3dShopUI.UpdateCommodtyTip(var_32_1)
				setActive(var_32_0:Find("tip"), false)
			end, SFX_PANEL)
		end

		local var_32_19 = Dorm3dShopUI.ShouldShowCommodtyTip(var_32_1)

		setActive(var_32_0:Find("new"), var_32_19)
		setActive(var_32_0:Find("tip"), var_32_19)
	end
end

function Dorm3dShopUI:SetCharaCard()
	local var_35_0 = self:GetCommoditiesCfgByChara(var_0_4[self.selectedId].character[1])
	local var_35_1 = UIItemList.New(self.charaPage:Find("scroll/Viewport/Content"), self.charaPage:Find("scroll/Viewport/Content/card"))
	local var_35_2 = {}

	var_35_1:make(function(arg_36_0, arg_36_1, arg_36_2)
		if arg_36_0 == UIItemList.EventInit then
			local var_36_0 = var_35_0[arg_36_1 + 1]

			table.insert(var_35_2, {
				var_35_0[arg_36_1 + 1].type,
				arg_36_2
			})

			local var_36_1 = self:IsCommoditySoldOut(var_36_0)
			local var_36_2 = false
			local var_36_3 = false
			local var_36_4 = ""
			local var_36_5 = {}
			local var_36_6 = 0
			local var_36_7 = var_0_3[var_36_0.shop_id[1]].group_type == 2 and i18n("dorm3d_shop_limit1") or i18n("dorm3d_shop_limit")

			if var_36_0.type == 1 then
				local var_36_8 = var_0_6[var_36_0.item_id]

				var_36_3 = var_0_6[var_36_0.item_id].is_special == 1
				var_36_2 = not var_36_3 and var_36_8.is_exclusive == 1
				var_36_4 = Drop.New({
					count = 0,
					type = DROP_TYPE_DORM3D_FURNITURE,
					id = var_36_8.id
				}):getIcon()

				setText(arg_36_2:Find("descScroll/Viewport/Content/desc"), var_36_8.desc)
				setText(arg_36_2:Find("countLimit"), var_36_7 .. " " .. getProxy(ApartmentProxy):GetFurnitureShopCount(var_36_0.item_id) .. "/1")

				var_36_5 = var_36_8.unlock_tips or {}
				var_36_6 = var_36_0.shop_id[1]
			elseif var_36_0.type == 2 then
				local var_36_9 = var_0_5[var_36_0.item_id]

				var_36_2 = var_36_0.room_id ~= 0

				local var_36_10 = Dorm3dGift.New({
					configId = var_36_0.item_id
				})
				local var_36_11 = {
					type = DROP_TYPE_DORM3D_GIFT,
					id = var_36_0.item_id
				}

				var_36_11.count = getProxy(ApartmentProxy):getGiftCount(var_36_0.item_id)
				var_36_4 = Drop.New(var_36_11):getIcon()

				setText(arg_36_2:Find("descScroll/Viewport/Content/desc"), var_36_9.display)

				local var_36_12 = 0

				for iter_36_0 = 1, #var_36_0.shop_id do
					if not var_0_3[var_36_0.shop_id[iter_36_0]].limit_args[1] and var_0_3[var_36_0.shop_id[iter_36_0]].group_type == 0 then
						var_36_12 = 0
					elseif var_0_3[var_36_0.shop_id[iter_36_0]].limit_args[1] and (var_0_3[var_36_0.shop_id[iter_36_0]].limit_args[1][1] == "dailycount" or var_0_3[var_36_0.shop_id[iter_36_0]].limit_args[1][1] == "count") then
						var_36_12 = var_0_3[var_36_0.shop_id[iter_36_0]].limit_args[1][3]
					elseif var_0_3[var_36_0.shop_id[iter_36_0]].group_type == 2 then
						var_36_12 = var_0_3[var_36_0.shop_id[iter_36_0]].group_limit
					end
				end

				setText(arg_36_2:Find("countLimit"), var_36_7 .. " " .. getProxy(ApartmentProxy):GetGiftShopCount(var_36_0.item_id) .. "/" .. var_36_12)
				setText(arg_36_2:Find("favor/number"), "+" .. pg.dorm3d_favor_trigger[var_0_5[var_36_0.item_id].favor_trigger_id].num)

				var_36_5 = var_36_9.unlock_tips or {}
				var_36_6 = var_36_10:GetShopID()
			elseif var_36_0.type == 3 then
				var_36_2 = true

				for iter_36_1, iter_36_2 in ipairs(var_0_4[var_36_0.item_id].invite_icon) do
					if iter_36_2[1] == var_36_0.room_id then
						var_36_4 = iter_36_2[2]
					end
				end

				setText(arg_36_2:Find("descScroll/Viewport/Content/desc"), var_0_4[var_36_0.item_id].room_des)
				setText(arg_36_2:Find("countLimit"), var_36_7 .. " " .. (var_36_1 and 1 or 0) .. "/1")

				var_36_6 = var_36_0.shop_id[1]
			end

			setActive(arg_36_2:Find("bg/normal"), not var_36_1)
			setActive(arg_36_2:Find("bg/soldOut"), var_36_1)
			setActive(arg_36_2:Find("normal"), not var_36_2 and not var_36_3)
			setActive(arg_36_2:Find("zhuanshu"), var_36_2)
			setActive(arg_36_2:Find("tedian"), var_36_3)
			GetImageSpriteFromAtlasAsync(var_36_4, "", arg_36_2:Find("mask/Dorm3dIconTpl/icon"))
			setActive(arg_36_2:Find("favor"), var_36_0.type == 2)
			setScrollText(arg_36_2:Find("name/text"), var_36_0.name)
			self:SetBubbles(UIItemList.New(arg_36_2:Find("bubbles/content"), arg_36_2:Find("bubbles/content/tpl")), var_36_5)

			local var_36_13 = CommonCommodity.New({
				id = var_36_6
			}, Goods.TYPE_SHOPSTREET)
			local var_36_14, var_36_15, var_36_16 = var_36_13:GetPrice()
			local var_36_17 = Drop.New({
				type = DROP_TYPE_RESOURCE,
				id = var_36_13:GetResType(),
				count = var_36_14
			})

			setText(arg_36_2:Find("consume/Text"), "<icon name=" .. var_36_13:GetResIcon() .. " w=0.81 h=0.81/>" .. var_36_14)
			setActive(arg_36_2:Find("consume"), not var_36_1)
			setActive(arg_36_2:Find("soldOut"), var_36_1)

			local var_36_18 = var_0_3[var_36_0.shop_id[1]].time

			setActive(arg_36_2:Find("timeLimit"), var_0_3[var_36_0.shop_id[1]].time ~= "always")

			if var_36_18 ~= "always" then
				setText(arg_36_2:Find("timeLimit/Text"), self:GetTimeRemain((pg.TimeMgr.GetInstance():parseTimeFromConfig(var_36_18[2]))))
			end

			if not var_36_1 then
				onButton(self, arg_36_2, function()
					self:ClickCommodity(var_36_0, arg_36_2:Find("tip"))
				end, SFX_PANEL)
			else
				onButton(self, arg_36_2, function()
					Dorm3dShopUI.UpdateCommodtyTip(var_36_0)
					setActive(arg_36_2:Find("tip"), false)
					pg.TipsMgr.GetInstance():ShowTips(i18n("word_sell_out"))
				end, SFX_PANEL)
			end

			local var_36_19 = Dorm3dShopUI.ShouldShowCommodtyTip(var_36_0)

			setActive(arg_36_2:Find("new"), var_36_19)
			setActive(arg_36_2:Find("tip"), var_36_19)
		end
	end)
	var_35_1:align(#var_35_0)

	self.filterIndex = 1

	for iter_35_0 = 1, 4 do
		local var_35_3 = self.charaPage:Find("switch"):GetChild(iter_35_0 - 1)

		onToggle(self, var_35_3, function(arg_39_0)
			if arg_39_0 then
				self.filterIndex = iter_35_0

				if iter_35_0 == 1 then
					for iter_39_0, iter_39_1 in ipairs(var_35_2) do
						setActive(iter_39_1[2], true)
					end
				elseif iter_35_0 == 2 then
					for iter_39_2, iter_39_3 in ipairs(var_35_2) do
						setActive(iter_39_3[2], iter_39_3[1] == 2)
					end
				elseif iter_35_0 == 3 then
					for iter_39_4, iter_39_5 in ipairs(var_35_2) do
						setActive(iter_39_5[2], iter_39_5[1] == 1)
					end
				else
					for iter_39_6, iter_39_7 in ipairs(var_35_2) do
						setActive(iter_39_7[2], iter_39_7[1] == 3)
					end
				end

				for iter_39_8 = 1, 4 do
					setActive(self.charaPage:Find("switch"):GetChild(iter_39_8 - 1):Find("selected"), iter_39_8 == iter_35_0)
				end
			end
		end)

		if iter_35_0 == 1 then
			triggerToggle(var_35_3, true)
		end
	end
end

function Dorm3dShopUI:ClickCommodity(arg_40_1, arg_40_2)
	self.showCount = 1

	if arg_40_1.room_id ~= 0 then
		local var_40_0 = 0

		for iter_40_0, iter_40_1 in pairs(var_0_4) do
			if iter_40_1.type == 2 and iter_40_1.character[1] == arg_40_1.room_id then
				var_40_0 = iter_40_1.id
			end
		end

		if not getProxy(ApartmentProxy):getRoom(var_40_0) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_role_locked"))

			return
		end
	end

	if arg_40_1.realroom_id ~= 0 then
		if not getProxy(ApartmentProxy):getRoom(arg_40_1.realroom_id) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_publicroom_unlock") .. "：" .. pg.dorm3d_rooms[arg_40_1.realroom_id].room)

			return
		end
	end

	Dorm3dShopUI.UpdateCommodtyTip(arg_40_1)

	if arg_40_2 then
		setActive(arg_40_2, false)
	end

	if arg_40_1.type == 1 then
		local var_40_1 = Dorm3dFurniture.New({
			configId = arg_40_1.item_id
		})
		local var_40_2 = CommonCommodity.New({
			id = arg_40_1.shop_id[1]
		}, Goods.TYPE_SHOPSTREET)
		local var_40_3, var_40_4, var_40_5 = var_40_2:GetPrice()

		self:emit(Dorm3dShopMediator.SHOW_SHOPPING_CONFIRM_WINDOW, {
			content = {
				icon = "<icon name=" .. var_40_2:GetResIcon() .. " w=1.1 h=1.1/>",
				off = var_40_4,
				cost = Drop.New({
					type = DROP_TYPE_RESOURCE,
					id = var_40_2:GetResType(),
					count = var_40_3
				}).count,
				old = var_40_5,
				name = arg_40_1.name
			},
			tip = i18n("dorm3d_shop_gift_tip"),
			drop = var_40_1,
			endTime = var_40_1:GetEndTime(),
			onYes = function()
				if not var_40_1:InShopTime() then
					pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_purchase_outtime"))

					return
				end

				self:emit(GAME.SHOPPING, {
					silentTip = true,
					count = 1,
					shopId = arg_40_1.shop_id[1]
				})
			end
		})
	elseif arg_40_1.type == 2 then
		local var_40_6 = 0

		for iter_40_2 = 1, #arg_40_1.shop_id do
			if not var_0_3[arg_40_1.shop_id[iter_40_2]].limit_args[1] and var_0_3[arg_40_1.shop_id[iter_40_2]].group_type == 0 then
				var_40_6 = 0
			elseif var_0_3[arg_40_1.shop_id[iter_40_2]].limit_args[1] and (var_0_3[arg_40_1.shop_id[iter_40_2]].limit_args[1][1] == "dailycount" or var_0_3[arg_40_1.shop_id[iter_40_2]].limit_args[1][1] == "count") then
				var_40_6 = var_0_3[arg_40_1.shop_id[iter_40_2]].limit_args[1][3]
			elseif var_0_3[arg_40_1.shop_id[iter_40_2]].group_type == 2 then
				var_40_6 = var_0_3[arg_40_1.shop_id[iter_40_2]].group_limit
			end
		end

		if var_40_6 > 1 then
			self:emit(Dorm3dShopMediator.OPEN_DETAIL, arg_40_1, (self.selectedId ~= 0 or nil) and var_0_4[self.selectedId].character[1], function(arg_42_0)
				self.showCount = arg_42_0
			end)
		else
			local var_40_8 = Dorm3dGift.New({
				configId = arg_40_1.item_id
			})
			local var_40_9 = CommonCommodity.New({
				id = var_40_8:GetShopID()
			}, Goods.TYPE_SHOPSTREET)
			local var_40_10, var_40_11, var_40_12 = var_40_9:GetPrice()
			local var_40_13
			local var_40_14 = 0

			_.each(var_40_8:getConfig("shop_id"), function(arg_43_0)
				if var_0_3[arg_43_0].group_type == 2 then
					var_40_14 = math.max(var_0_3[arg_43_0].group_limit, var_40_14)
				end
			end)

			if 0 > 0 then
				local var_40_15 = {}

				var_40_15[1] = getProxy(ApartmentProxy):GetGiftShopCount(var_40_8:GetConfigID())
				var_40_15[2] = 0
				var_40_13 = var_40_15
			end

			self:emit(Dorm3dShopMediator.SHOW_SHOPPING_CONFIRM_WINDOW, {
				content = {
					icon = "<icon name=" .. var_40_9:GetResIcon() .. " w=1.1 h=1.1/>",
					off = var_40_11,
					cost = Drop.New({
						type = DROP_TYPE_RESOURCE,
						id = var_40_9:GetResType(),
						count = var_40_10
					}).count,
					old = var_40_12,
					name = arg_40_1.name,
					weekLimit = var_40_13
				},
				tip = i18n("dorm3d_shop_gift_tip"),
				drop = var_40_8,
				groupId = arg_40_1.room_id,
				onYes = function()
					self:emit(GAME.SHOPPING, {
						silentTip = true,
						count = 1,
						shopId = var_40_8:GetShopID()
					})
				end
			})
		end
	elseif arg_40_1.type == 3 then
		local var_40_16
		local var_40_17 = getProxy(ApartmentProxy):getRoom(arg_40_1.item_id)

		if not var_40_17 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_role_locked"))

			return
		end

		if not var_40_17.unlockCharacter[arg_40_1.room_id] then
			var_40_16 = "lock"
		elseif not getProxy(ApartmentProxy):getApartment(arg_40_1.room_id) then
			var_40_16 = "room"
		elseif Apartment.New({
			ship_group = arg_40_1.room_id
		}):needDownload() then
			var_40_16 = "download"
		end

		if var_40_16 == "lock" then
			self:emit(Dorm3dShopMediator.OPEN_ROOM_UNLOCK_WINDOW, arg_40_1.item_id, arg_40_1.room_id)
		elseif var_40_16 == "room" then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_role_locked"))
		elseif var_40_16 == "download" then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_beach_tip"))
		end
	end
end

function Dorm3dShopUI:SetBubbles(arg_45_1, arg_45_2)
	arg_45_1:make(function(arg_46_0, arg_46_1, arg_46_2)
		if arg_46_0 == UIItemList.EventInit then
			LoadImageSpriteAtlasAsync("ui/shoptip_atlas", "icon_" .. arg_45_2[arg_46_1 + 1], arg_46_2:Find("icon/icon"), true)
			setText(arg_46_2:Find("bubble/Text"), i18n("dorm3d_shop_tag" .. arg_45_2[arg_46_1 + 1]))
			setActive(arg_46_2:Find("bubble"), false)
			onToggle(self, arg_46_2, function(arg_47_0)
				setActive(arg_46_2:Find("icon/select"), arg_47_0)
				setActive(arg_46_2:Find("icon/unselect"), not arg_47_0)
				setActive(arg_46_2:Find("bubble"), arg_47_0)
				setActive(self.mask, arg_47_0)
				onButton(self, self.mask, function()
					triggerToggle(arg_46_2, false)
				end, SFX_PANEL)
			end)
		end
	end)
	arg_45_1:align(#arg_45_2)
end

function Dorm3dShopUI:GetTimeRemain(arg_49_1)
	local var_49_0 = pg.TimeMgr.GetInstance()
	local var_49_1 = math.max(arg_49_1 - var_49_0:GetServerTime(), 0)

	if var_49_0 > 0 then
		return math.floor(var_49_1 / 86400) .. i18n("word_date")
	else
		local var_49_2 = math.floor(var_49_1 / 3600)

		if var_49_2 > 0 then
			return var_49_2 .. i18n("word_hour")
		else
			local var_49_3 = math.floor(var_49_1 / 60)

			if var_49_3 > 0 then
				return var_49_3 .. i18n("word_minute")
			else
				return var_49_1 .. i18n("word_second")
			end
		end
	end
end

function Dorm3dShopUI:ShouldShowCommodtyTip()
	if self.room_id ~= 0 then
		local var_50_0 = 0

		for iter_50_0, iter_50_1 in ipairs(var_0_4.all) do
			if var_0_4[iter_50_1].type == 2 and var_0_4[iter_50_1].character[1] == self.room_id then
				var_50_0 = iter_50_1
			end
		end

		if not getProxy(ApartmentProxy):getRoom(var_50_0) then
			return false
		end
	end

	if self.realroom_id ~= 0 then
		if not getProxy(ApartmentProxy):getRoom(self.realroom_id) then
			return false
		end
	end

	if self.type == 1 then
		return Dorm3dFurniture.NeedViewTipByFurnitureId(self.item_id)
	elseif self.type == 2 then
		return Dorm3dGift.NeedViewTipByGiftId(self.item_id) or var_0_3[self.shop_id[1]].group ~= 0 and PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dGiftWeekViewed_" .. self.item_id, 0) == 0
	end

	return false
end

function Dorm3dShopUI:ShouldShowSumTip()
	for iter_51_0, iter_51_1 in ipairs(self) do
		if Dorm3dShopUI.ShouldShowCommodtyTip(iter_51_1) then
			return true
		end
	end

	return false
end

function Dorm3dShopUI.ShouldShowAllTip()
	local var_52_0 = {}

	for iter_52_0, iter_52_1 in ipairs(var_0_2.all) do
		local var_52_1 = false

		for iter_52_2, iter_52_3 in ipairs(var_0_2[iter_52_1].shop_id) do
			if not pg.TimeMgr.GetInstance():inTime(var_0_3[iter_52_3].time) then
				var_52_1 = true

				break
			end
		end

		if not var_52_1 then
			table.insert(var_52_0, var_0_2[iter_52_1])
		end
	end

	return Dorm3dShopUI.ShouldShowSumTip(var_52_0)
end

function Dorm3dShopUI:UpdateCommodtyTip()
	if self.type == 1 then
		Dorm3dFurniture.SetViewedFlag(self.item_id)
	elseif self.type == 2 then
		Dorm3dGift.SetViewedFlag(self.item_id)

		if var_0_3[self.shop_id[1]].group ~= 0 then
			PlayerPrefs.SetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dGiftWeekViewed_" .. self.item_id, 1)
		end
	end
end

function Dorm3dShopUI:UpdateSumTip()
	for iter_54_0, iter_54_1 in ipairs(self) do
		Dorm3dShopUI.UpdateCommodtyTip(iter_54_1)
	end
end

function Dorm3dShopUI:willExit()
	self.scrollSnap:Dispose()

	self.scrollSnap = nil
end

function Dorm3dShopUI:onBackPressed()
	self:closeView()
end

return Dorm3dShopUI
