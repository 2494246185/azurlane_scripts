local Dorm3dRoomUnlockWindow = class("Dorm3dRoomUnlockWindow", import("view.base.BaseUI"))

function Dorm3dRoomUnlockWindow:getUIName()
	return "Dorm3dRoomUnlockWindow"
end

function Dorm3dRoomUnlockWindow:getResource()
	local var_2_0 = {}
	local var_2_1 = self.contextData or {}

	local function var_2_2(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local var_2_3 = var_2_1.roomId and ApartmentRoom.New({
		id = var_2_1.roomId
	})

	if var_2_1.groupId then
		var_2_2("ui/shoptip_atlas")

		for iter_2_0, iter_2_1 in ipairs(var_2_3 and Apartment.getGroupConfig(var_2_1.groupId, var_2_3:getConfig("invite_banner")) or {}) do
			var_2_2("dorm3dbanner/" .. iter_2_1)
		end
	elseif var_2_3 then
		var_2_2("dorm3dbanner/" .. string.lower(var_2_3:getConfig("assets_prefix")))
	end

	return table.insertto(var_2_0, Dorm3dRoomUnlockWindow.super.getResource(self))
end

function Dorm3dRoomUnlockWindow:init()
	self.bubbleContent = self._tf:Find("Window/Bubbles/content")
	self.bubbleTpl = self._tf:Find("Window/Bubbles/tpl")
	self.bubbleList = UIItemList.New(self.bubbleContent, self.bubbleTpl)
	self.scrollSnap = BannerScrollRect4Dorm.New(self._tf:Find("Window/banner/mask/content"), self._tf:Find("Window/banner/dots"))

	setActive(self.bubbleTpl, false)
end

function Dorm3dRoomUnlockWindow:didEnter()
	onButton(self, self._tf:Find("Window/Confirm"), function()
		if self.contextData.groupId then
			self:emit(Dorm3dRoomUnlockWindowMediator.ON_UNLOCK_ROOM_INVITE, self.contextData.roomId, self.contextData.groupId)
		else
			self:emit(Dorm3dRoomUnlockWindowMediator.ON_UNLOCK_DORM_ROOM, self.contextData.roomId)
		end
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Window/Cancel"), function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("bg"), function()
		self:closeView()
	end)
	setActive(self._tf:Find("Window/Title/unlock"), not self.contextData.groupId)
	setActive(self._tf:Find("Window/Title/invite"), self.contextData.groupId)

	if self.contextData.groupId then
		local var_5_0 = getProxy(ApartmentProxy)
		local var_5_1 = var_5_0:getRoom(self.contextData.roomId)
		local var_5_2 = CommonCommodity.New({
			id = Apartment.getGroupConfig(self.contextData.groupId, var_5_1:getConfig("invite_cost"))
		}, Goods.TYPE_SHOPSTREET)
		local var_5_3, var_5_4, var_5_5 = var_5_2.GetPrice(var_5_0)
		local var_5_6 = Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = var_5_2:GetResType(),
			count = var_5_3
		})

		if var_5_6.count == 0 then
			setText(self._tf:Find("Window/Content"), i18n("dorm3d_invite_confirm_free", "<icon name=" .. var_5_2:GetResIcon() .. " w=1.1 h=1.1/>", var_5_5, ShipGroup.getDefaultShipNameByGroupID(self.contextData.groupId), var_5_1:getConfig("room")))
		elseif var_5_4 > 0 then
			setText(self._tf:Find("Window/Content"), i18n("dorm3d_invite_confirm_discount", "<icon name=" .. var_5_2:GetResIcon() .. " w=1.1 h=1.1/>", var_5_6.count, var_5_5, ShipGroup.getDefaultShipNameByGroupID(self.contextData.groupId), var_5_1:getConfig("room")))
		else
			setText(self._tf:Find("Window/Content"), i18n("dorm3d_invite_confirm_original", "<icon name=" .. var_5_2:GetResIcon() .. " w=1.1 h=1.1/>", var_5_6.count, ShipGroup.getDefaultShipNameByGroupID(self.contextData.groupId), var_5_1:getConfig("room")))
		end

		setText(self._tf:Find("Window/Download"), "")
		setActive(self._tf:Find("Window/Preview"), false)

		self.bannerConfig = Apartment.getGroupConfig(self.contextData.groupId, var_5_1:getConfig("invite_banner"))
		self.markConfig = Apartment.getGroupConfig(self.contextData.groupId, var_5_1:getConfig("invite_mark"))

		self:InitBanner()
		self:InitUIList()
	else
		local var_5_7 = ApartmentRoom.New({
			id = self.contextData.roomId
		})

		setText(self._tf:Find("Window/Content"), i18n("dorm3d_beach_buy", table.concat(underscore.map(var_5_7:getConfig("unlock_item"), function(arg_9_0)
			local var_9_0 = Drop.Create(arg_9_0)

			return string.format("%s*%d", var_9_0:getName(), var_9_0.count)
		end)), var_5_7:getConfig("room")))

		if var_5_7:needDownload() then
			local var_5_8, var_5_9 = var_5_7:getDownloadNeedSize()

			setText(self._tf:Find("Window/Download"), i18n("dorm3d_beach_download", var_5_9))
		else
			setText(self._tf:Find("Window/Download"), "")
		end

		GetImageSpriteFromAtlasAsync("dorm3dbanner/" .. string.lower(var_5_7:getConfig("assets_prefix")), "", self._tf:Find("Window/Preview/Image"))
	end

	setText(self._tf:Find("Window/Confirm/Text"), i18n("msgbox_text_confirm"))
	setText(self._tf:Find("Window/Cancel/Text"), i18n("msgbox_text_cancel"))
	pg.UIMgr.GetInstance():OverlayPanel(self._tf)
end

function Dorm3dRoomUnlockWindow:InitBanner()
	for iter_10_0 = 1, #self.bannerConfig do
		LoadImageSpriteAsync("dorm3dbanner/" .. self.bannerConfig[iter_10_0], (self.scrollSnap:AddChild()))
	end

	self.scrollSnap:SetUp()
end

function Dorm3dRoomUnlockWindow:InitUIList()
	self.bubbleList:make(function(arg_12_0, arg_12_1, arg_12_2)
		if arg_12_0 == UIItemList.EventInit then
			LoadImageSpriteAtlasAsync("ui/shoptip_atlas", "icon_" .. self.markConfig[arg_12_1 + 1], arg_12_2:Find("icon/icon"), true)
			setText(arg_12_2:Find("bubble/Text"), i18n("dorm3d_shop_tag" .. self.markConfig[arg_12_1 + 1]))
			setActive(arg_12_2:Find("bubble"), false)
			onToggle(self, arg_12_2, function(arg_13_0)
				setActive(arg_12_2:Find("icon/select"), arg_13_0)
				setActive(arg_12_2:Find("icon/unselect"), not arg_13_0)
				setActive(arg_12_2:Find("bubble"), arg_13_0)
			end)
		end
	end)
	self.bubbleList:align(#self.markConfig)
end

function Dorm3dRoomUnlockWindow:willExit()
	self.scrollSnap:Dispose()

	self.scrollSnap = nil

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return Dorm3dRoomUnlockWindow
