local Dorm3dInviteLayer = class("Dorm3dInviteLayer", import("view.base.BaseUI"))

function Dorm3dInviteLayer:getUIName()
	return "Dorm3dInviteWindow"
end

function Dorm3dInviteLayer:getResource()
	local var_2_0 = {}
	local var_2_1 = self.contextData or {}

	local function var_2_2(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local var_2_3 = var_2_1.roomId and pg.dorm3d_rooms[var_2_1.roomId]
	local var_2_4 = {}

	local function var_2_5(arg_4_0)
		if arg_4_0 and not table.contains(var_2_4, arg_4_0) then
			table.insert(var_2_4, arg_4_0)
		end
	end

	if var_2_3 then
		if noEmptyStr(var_2_3.assets_prefix) then
			var_2_2("dorm3dselect/room_invite_" .. var_2_3.assets_prefix)
		end

		for iter_2_0, iter_2_1 in ipairs(var_2_3.character or {}) do
			var_2_5(iter_2_1)
		end

		for iter_2_2, iter_2_3 in ipairs(var_2_3.character_pay or {}) do
			var_2_5(iter_2_3)
		end
	end

	for iter_2_4, iter_2_5 in ipairs(var_2_1.groupIds or {}) do
		var_2_5(iter_2_5)
	end

	for iter_2_6, iter_2_7 in ipairs(var_2_4) do
		var_2_2(pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7] and pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7][1] and pg.dorm3d_resource[pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7] and pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7][1]] and (pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7] and pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7][1] and pg.dorm3d_resource[pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7] and pg.dorm3d_resource.get_id_list_by_ship_group[iter_2_7][1]]).head_Icon)

		if var_2_3 then
			local var_2_7 = Apartment.New({
				ship_group = iter_2_7
			}):GetSkinModelID(var_2_3.tag)

			if var_2_7 then
				var_2_2(string.format("dorm3dselect/room_card_apartment_%d", var_2_7))
			end

			var_2_2(string.format("dorm3dselect/room_card_apartment_name_%d", iter_2_7))
		end
	end

	return table.insertto(var_2_0, Dorm3dInviteLayer.super.getResource(self))
end

function Dorm3dInviteLayer:init()
	self.rtInvitePanel = self._tf:Find("invite_panel")

	setText(self.rtInvitePanel:Find("window/Text"), i18n("dorm3d_invite_beach_tip"))
	setText(self.rtInvitePanel:Find("window/btn_confirm/Text"), i18n("text_confirm"))
	onButton(self, self.rtInvitePanel:Find("bg"), function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.rtInvitePanel:Find("window/btn_close"), function()
		self:closeView()
	end, SFX_CANCEL)

	self.rtSelectPanel = self._tf:Find("select_panel")

	setText(self.rtSelectPanel:Find("window/character/title"), i18n("dorm3d_select_tip"))
	onButton(self, self.rtSelectPanel:Find("bg"), function()
		self:HideSelectPanel()
		self:ShowInvitePanel()
	end, SFX_CANCEL)
	setText(self.rtSelectPanel:Find("window/title/Text"), i18n("dorm3d_data_choose"))
	setText(self.rtSelectPanel:Find("window/bottom/container/btn_confirm/Text"), i18n("text_confirm"))

	self.selectCountTip = i18n("dorm3d_select_tip")
end

function Dorm3dInviteLayer:ShowInvitePanel()
	GetImageSpriteFromAtlasAsync("dorm3dselect/room_invite_" .. self.room:getConfig("assets_prefix"), "", self.rtInvitePanel:Find("window/Image"))
	setText(self.rtInvitePanel:Find("window/Text"), i18n("dorm3d_data_go", self.room:getRoomName()))

	local var_9_0, var_9_1 = self.room:getInteractRange()
	local var_9_2 = self.rtInvitePanel:Find("window/container")

	UIItemList.StaticAlign(var_9_2, var_9_2:GetChild(0), var_9_1, function(arg_10_0, arg_10_1, arg_10_2)
		arg_10_1 = arg_10_1 + 1

		if arg_10_0 == UIItemList.EventUpdate then
			setActive(arg_10_2:Find("empty"), not self.selectIds[arg_10_1])
			setActive(arg_10_2:Find("ship"), self.selectIds[arg_10_1])

			if self.selectIds[arg_10_1] then
				GetImageSpriteFromAtlasAsync(pg.dorm3d_resource[pg.dorm3d_resource.get_id_list_by_ship_group[self.selectIds[arg_10_1]][1]].head_Icon, "", arg_10_2:Find("ship"), true)
			end

			onButton(self, arg_10_2, function()
				self:HideInvitePanel()
				self:ShowSelectPanel()
			end, SFX_PANEL)

			if arg_10_1 == var_9_1 or not self.selectIds[arg_10_1] then
				setActive(arg_10_2:Find("tip"), PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dRoomInviteSuccess_" .. self.room.id, 1) == 0)
			end
		end
	end)
	onButton(self, self.rtInvitePanel:Find("window/btn_confirm"), function()
		if #self.selectIds < var_9_0 or #self.selectIds > var_9_1 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_data_Invite_lack"))

			return
		end

		local var_12_0 = {}

		if #self.selectIds >= 3 and not ApartmentProxy.CheckDeviceRAMEnough() then
			table.insert(var_12_0, function(arg_13_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("drom3d_beach_memory_limit_tip"),
					onYes = arg_13_0
				})
			end)
		end

		table.insert(var_12_0, function(arg_14_0)
			getProxy(ApartmentProxy):SetRoomInviteList(self.room.id, self.selectIds)
			arg_14_0()
		end)
		seriesAsync(var_12_0, function()
			self:emit(Dorm3dInviteMediator.ON_DORM, {
				roomId = self.room.id,
				groupIds = underscore.to_array(self.selectIds)
			})
		end)
	end, SFX_CONFIRM)
	pg.UIMgr.GetInstance():OverlayPanel(self.rtInvitePanel, {
		force = true
	})
	setActive(self.rtInvitePanel, true)
	pg.CriMgr.GetInstance():PlaySE_V3("ui-dorm_sidebar")
end

function Dorm3dInviteLayer:HideInvitePanel()
	pg.UIMgr.GetInstance():UnOverlayPanel(self.rtInvitePanel, self._tf)
	setActive(self.rtInvitePanel, false)
end

function Dorm3dInviteLayer:ShowSelectPanel()
	local var_17_0 = self.room:getInviteList()
	local var_17_1, var_17_2 = self.room:getInteractRange()
	local var_17_3 = {}
	local var_17_4 = {}

	for iter_17_0, iter_17_1 in ipairs(var_17_0) do
		var_17_4[iter_17_1] = not self.room.unlockCharacter[iter_17_1] and "lock" or not getProxy(ApartmentProxy):getApartment(iter_17_1) and "room" or Apartment.New({
			ship_group = iter_17_1
		}):needDownload() and "download" or nil
	end

	local var_17_5 = getProxy(PlayerProxy):getRawData().id
	local var_17_6 = self.rtSelectPanel:Find("window/character/container")

	UIItemList.StaticAlign(var_17_6, var_17_6:GetChild(0), #var_17_0, function(arg_18_0, arg_18_1, arg_18_2)
		arg_18_1 = arg_18_1 + 1

		if arg_18_0 == UIItemList.EventUpdate then
			local var_18_0 = var_17_0[arg_18_1]

			setActive(arg_18_2:Find("base"), var_17_0[arg_18_1])
			setActive(arg_18_2:Find("empty"), not var_18_0)

			if not var_18_0 then
				arg_18_2.name = "null"

				setText(arg_18_2:Find("empty/Text"), i18n("dorm3d_waiting"))
			else
				arg_18_2.name = tostring(var_18_0)

				self:UpdateSelectableCard(arg_18_2:Find("base"), var_18_0, function(arg_19_0)
					table.removebyvalue(var_17_3, var_18_0, true)

					if arg_19_0 then
						table.insert(var_17_3, var_18_0)
					end

					setText(self.rtSelectPanel:Find("window/bottom/title/Text"), self.selectCountTip .. #var_17_3 .. "/" .. var_17_2)
				end)
				triggerToggle(arg_18_2:Find("base"), table.contains(self.selectIds, var_18_0))
				setActive(arg_18_2:Find("base/mask"), var_17_4[var_18_0])
				onButton(self, arg_18_2:Find("base/mask"), function()
					if var_17_4[var_18_0] == "lock" then
						self:HideSelectPanel()
						self:emit(Dorm3dInviteMediator.OPEN_ROOM_UNLOCK_WINDOW, self.room:GetConfigID(), var_18_0)
					elseif var_17_4[var_18_0] == "room" then
						pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_role_locked"))
					elseif var_17_4[var_18_0] == "download" then
						pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_beach_tip"))
					end
				end, SFX_PANEL)
				eachChild(arg_18_2:Find("base/operation"), function(arg_21_0)
					setActive(arg_21_0, arg_21_0.name == var_17_4[var_18_0])
				end)
			end

			setActive(arg_18_2:Find("tip"), PlayerPrefs.GetInt(var_17_5 .. "_dorm3dRoomInviteSuccess_" .. self.room.id .. "_" .. var_18_0, 1) == 0)
			PlayerPrefs.SetInt(var_17_5 .. "_dorm3dRoomInviteSuccess_" .. self.room.id .. "_" .. var_18_0, 1)
		end
	end)
	PlayerPrefs.SetInt(var_17_5 .. "_dorm3dRoomInviteSuccess_" .. self.room.id, 1)
	onButton(self, self.rtSelectPanel:Find("window/bottom/container/btn_confirm"), function()
		if #var_17_3 > var_17_2 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_data_Invite_lack"))

			return
		end

		self.selectIds = var_17_3

		self:HideSelectPanel()
		self:ShowInvitePanel()
	end, SFX_CONFIRM)
	pg.UIMgr.GetInstance():OverlayPanel(self.rtSelectPanel, {
		force = true,
		pbList = {
			self.rtSelectPanel:Find("window")
		}
	})
	setActive(self.rtSelectPanel, true)
end

function Dorm3dInviteLayer:UpdateSelectableCard(arg_23_1, arg_23_2, arg_23_3)
	GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_card_apartment_%d", (Apartment.New({
		ship_group = arg_23_2
	}):GetSkinModelID(self.room:getConfig("tag")))), "", arg_23_1:Find("Image"))
	GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_card_apartment_name_%d", arg_23_2), "", arg_23_1:Find("name"))

	local var_23_0 = getProxy(ApartmentProxy):getApartment(arg_23_2)
	local var_23_1 = not var_23_0 or var_23_0:needDownload()

	setActive(arg_23_1:Find("lock"), var_23_1)
	setActive(arg_23_1:Find("mask"), var_23_1)
	setActive(arg_23_1:Find("unlock"), not var_23_1)
	setActive(arg_23_1:Find("favor_level"), var_23_0)

	if var_23_0 then
		setText(arg_23_1:Find("favor_level/Text"), var_23_0.level)
	end

	onToggle(self, arg_23_1, function(arg_24_0)
		arg_23_3(arg_24_0)

		if arg_24_0 then
			if not var_23_0 then
				pg.TipsMgr.GetInstance():ShowTips(string.format("need unlock apartment{%d}", arg_23_2))
				triggerToggle(arg_23_1, false)
			elseif var_23_0:needDownload() then
				pg.TipsMgr.GetInstance():ShowTips(string.format("need download resource{%d}", arg_23_2))
				triggerToggle(arg_23_1, false)
			end
		end
	end, SFX_UI_CLICK)
end

function Dorm3dInviteLayer:HideSelectPanel()
	pg.UIMgr.GetInstance():UnOverlayPanel(self.rtSelectPanel, self._tf)
	setActive(self.rtSelectPanel, false)
end

function Dorm3dInviteLayer:UpdateRoom(arg_26_1)
	self.room = arg_26_1
end

function Dorm3dInviteLayer:didEnter()
	self.selectIds = underscore.filter(self.contextData.groupIds or {}, function(arg_28_0)
		local var_28_0 = self.room.unlockCharacter[arg_28_0]

		if self.room.unlockCharacter[arg_28_0] then
			var_28_0 = tobool(getProxy(ApartmentProxy):getApartment(arg_28_0))

			if var_28_0 then
				var_28_0 = not Apartment.New({
					ship_group = arg_28_0
				}):needDownload()
			end
		end

		return var_28_0
	end)
	self.contextData.groupIds = nil

	self:ShowInvitePanel()
end

function Dorm3dInviteLayer:onBackPressed()
	if isActive(self.rtSelectPanel) then
		self:HideSelectPanel()
		self:ShowInvitePanel()
	else
		self:closeView()
	end
end

function Dorm3dInviteLayer:willExit()
	if isActive(self.rtSelectPanel) then
		self:HideSelectPanel()
	else
		self:HideInvitePanel()
	end
end

return Dorm3dInviteLayer
