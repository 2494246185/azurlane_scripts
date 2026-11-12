local Dorm3dShoppingConfirmWindow = class("Dorm3dShoppingConfirmWindow", import("view.base.BaseUI"))

Dorm3dShoppingConfirmWindow.SELECTED_WIDTH = 52
Dorm3dShoppingConfirmWindow.UNSELECTED_WIDTH = 12
Dorm3dShoppingConfirmWindow.LOOP_DURATION = 5

function Dorm3dShoppingConfirmWindow:getUIName()
	return "Dorm3dShopWindow"
end

function Dorm3dShoppingConfirmWindow:getResource()
	local var_2_0 = {
		"weaponframes",
		"ui/shoptip_atlas"
	}
	local var_2_1 = (self.contextData or {}).drop

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

	if (self.contextData or {}).drop then
		var_2_2(var_2_1:GetIcon())

		if var_2_1.__cname == "Dorm3dGift" then
			if pg.dorm3d_gift[var_2_1.configId] then
				for iter_2_0, iter_2_1 in ipairs(pg.dorm3d_gift[var_2_1.configId].unlock_banners or {}) do
					var_2_3(iter_2_1[2])
				end
			end
		elseif var_2_1.__cname == "Dorm3dFurniture" then
			var_2_3(pg.dorm3d_furniture_template[var_2_1.configId] and pg.dorm3d_furniture_template[var_2_1.configId].unlock_banners)
		elseif var_2_1.__cname == "Dorm3dSkin" then
			var_2_3(pg.dorm3d_resource[var_2_1.configId] and pg.dorm3d_resource[var_2_1.configId].unlock_banners)
		end
	end

	return table.insertto(var_2_0, Dorm3dShoppingConfirmWindow.super.getResource(self))
end

function Dorm3dShoppingConfirmWindow:init()
	self.previewTf = self._tf:Find("Window/Preview")
	self.bubbleContent = self._tf:Find("Window/Bubbles/content")
	self.bubbleTpl = self._tf:Find("Window/Bubbles/tpl")
	self.bubbleList = UIItemList.New(self.bubbleContent, self.bubbleTpl)
	self.scrollSnap = BannerScrollRect4Dorm.New(self._tf:Find("Window/banner/mask/content"), self._tf:Find("Window/banner/dots"))

	setActive(self.bubbleTpl, false)
	switch(self.contextData.drop.__cname, {
		Dorm3dGift = function()
			self.unlockTips = pg.dorm3d_gift[self.contextData.drop.configId].unlock_tips or {}

			local var_6_0 = self.contextData.groupId
			local var_6_1 = pg.dorm3d_gift[self.contextData.drop.configId].unlock_banners or {}
			local var_6_2 = table.Find(var_6_1, function(arg_7_0, arg_7_1)
				if var_6_0 == nil or arg_7_1[1] == var_6_0 then
					return true
				end
			end) or table.Find(var_6_1, function(arg_8_0)
				if arg_8_0[1] == 0 then
					return true
				end
			end)

			self.unlockBanners = var_6_2 and var_6_2[2]
			self.isExclusive = pg.dorm3d_gift[self.contextData.drop.configId].ship_group_id ~= 0
			self.addFavor = pg.dorm3d_favor_trigger[pg.dorm3d_gift[self.contextData.drop.configId].favor_trigger_id].num

			setActive(self._tf:Find("Window/Title/gift"), true)
		end,
		Dorm3dFurniture = function()
			self.unlockTips = pg.dorm3d_furniture_template[self.contextData.drop.configId].unlock_tips or {}
			self.unlockBanners = pg.dorm3d_furniture_template[self.contextData.drop.configId].unlock_banners or {}
			self.isExclusive = pg.dorm3d_furniture_template[self.contextData.drop.configId].is_exclusive == 1
			self.isSpecial = pg.dorm3d_furniture_template[self.contextData.drop.configId].is_special == 1

			setActive(self._tf:Find("Window/Title/furniture"), true)
		end,
		Dorm3dSkin = function()
			self.unlockTips = pg.dorm3d_resource[self.contextData.drop.configId].unlock_tips or {}
			self.unlockBanners = pg.dorm3d_resource[self.contextData.drop.configId].unlock_banners or {}

			setActive(self._tf:Find("Window/Title/skin"), true)
		end
	})
end

function Dorm3dShoppingConfirmWindow:didEnter()
	onButton(self, self._tf:Find("Window/Confirm"), function()
		self:closeView()
		existCall(self.contextData.onYes)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Window/Cancel"), function()
		self:closeView()
		existCall(self.contextData.onNo)
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Mask"), function()
		self:closeView()
		existCall(self.contextData.onClose)
	end)
	self:InitUIList()
	self:InitDropIcon()
	self:InitBanner()

	local var_11_0 = self.contextData.content.cost == 0 and i18n("dorm3d_purchase_confirm_free", self.contextData.content.icon, "x" .. self.contextData.content.cost, self.contextData.content.name) or self.contextData.content.off > 0 and i18n("dorm3d_purchase_confirm_discount", self.contextData.content.icon, "x" .. self.contextData.content.cost, self.contextData.content.old, self.contextData.content.name) or i18n("dorm3d_purchase_confirm_original", self.contextData.content.icon, "x" .. self.contextData.content.cost, self.contextData.content.name)

	switch(self.contextData.drop.__cname, {
		Dorm3dGift = function()
			if self.contextData.content.weekLimit then
				var_11_0 = var_11_0 .. i18n("dorm3d_purchase_weekly_limit", self.contextData.content.weekLimit[1], self.contextData.content.weekLimit[2])
			end
		end,
		Dorm3dFurniture = function()
			local var_16_0 = self.contextData.endTime

			if self.contextData.endTime and self.contextData.endTime > 0 then
				local function var_16_1(arg_17_0)
					local var_17_0 = pg.TimeMgr.GetInstance()
					local var_17_1 = math.max(arg_17_0 - var_17_0:GetServerTime(), 0)

					if var_17_0 > 0 then
						return math.floor(var_17_1 / 86400) .. i18n("word_date")
					else
						local var_17_2 = math.floor(var_17_1 / 3600)

						if var_17_2 > 0 then
							return var_17_2 .. i18n("word_hour")
						else
							local var_17_3 = math.floor(var_17_1 / 60)

							if var_17_3 > 0 then
								return var_17_3 .. i18n("word_minute")
							else
								return var_17_1 .. i18n("word_second")
							end
						end
					end
				end

				local var_16_2 = var_11_0

				self.timerRefreshTime = Timer.New(function()
					setText(self._tf:Find("Window/Content"), var_16_2 .. string.format("\n<size=28><color=#7c7e81>%s</color><color=#169fff>%s</color></size>", i18n("time_remaining_tip"), var_16_1(var_16_0)))
				end, 1, -1)

				self.timerRefreshTime:Start()

				var_11_0 = var_11_0 .. string.format("\n<size=28><color=#7c7e81>%s</color><color=#169fff>%s</color></size>", i18n("time_remaining_tip"), var_16_1(self.contextData.endTime))
			end
		end
	})
	setText(self._tf:Find("Window/Content"), var_11_0)
	setText(self._tf:Find("Window/Confirm/Text"), i18n("msgbox_text_confirm"))
	setText(self._tf:Find("Window/Cancel/Text"), i18n("msgbox_text_cancel"))
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)
end

function Dorm3dShoppingConfirmWindow:InitBanner()
	for iter_19_0 = 1, #self.unlockBanners do
		LoadImageSpriteAsync("dorm3dbanner/" .. self.unlockBanners[iter_19_0], (self.scrollSnap:AddChild()))
	end

	self.scrollSnap:SetUp()
end

function Dorm3dShoppingConfirmWindow:InitUIList()
	self.bubbleList:make(function(arg_21_0, arg_21_1, arg_21_2)
		if arg_21_0 == UIItemList.EventInit then
			LoadImageSpriteAtlasAsync("ui/shoptip_atlas", "icon_" .. self.unlockTips[arg_21_1 + 1], arg_21_2:Find("icon/icon"), true)
			setText(arg_21_2:Find("bubble/Text"), i18n("dorm3d_shop_tag" .. self.unlockTips[arg_21_1 + 1]))
			setActive(arg_21_2:Find("bubble"), false)
			onToggle(self, arg_21_2, function(arg_22_0)
				setActive(arg_21_2:Find("icon/select"), arg_22_0)
				setActive(arg_21_2:Find("icon/unselect"), not arg_22_0)
				setActive(arg_21_2:Find("bubble"), arg_22_0)
			end)
		end
	end)
	self.bubbleList:align(#self.unlockTips)
end

function Dorm3dShoppingConfirmWindow:InitDropIcon()
	LoadImageSpriteAtlasAsync(self.contextData.drop:GetIcon(), "", self._tf:Find("Window/Item/Dorm3dIconTpl/icon"), true)
	GetImageSpriteFromAtlasAsync("weaponframes", "dorm3d_" .. ItemRarity.Rarity2Print(self.contextData.drop:GetRarity()), self._tf:Find("Window/Item/Dorm3dIconTpl"))
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

function Dorm3dShoppingConfirmWindow:willExit()
	if self.timerRefreshTime then
		self.timerRefreshTime:Stop()

		self.timerRefreshTime = nil
	end

	self.scrollSnap:Dispose()

	self.scrollSnap = nil

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return Dorm3dShoppingConfirmWindow
