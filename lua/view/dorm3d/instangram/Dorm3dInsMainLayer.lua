local Dorm3dInsMainLayer = class("Dorm3dInsMainLayer", import("...base.BaseUI"))

Dorm3dInsMainLayer.OPEN_INS = "Dorm3dInsMainLayer.OPEN_INS"
Dorm3dInsMainLayer.OPEN_CHAT = "Dorm3dInsMainLayer.OPEN_CHAT"
Dorm3dInsMainLayer.OPEN_PHONE = "Dorm3dInsMainLayer.OPEN_PHONE"
Dorm3dInsMainLayer.DOWNLOAD_ROOM = "Dorm3dInsMainLayer.DOWNLOAD_ROOM"
Dorm3dInsMainLayer.DELETE_ROOM = "Dorm3dInsMainLayer.DELETE_ROOM"
Dorm3dInsMainLayer.FLUSH_LEFT = "Dorm3dInsMainLayer.FLUSH_LEFT"

local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = "PAGE_INS"
local var_0_4 = "PAGE_CHAT"
local var_0_5 = "PAGE_PHONE"
local var_0_6 = "PAGE_MAIN"
local var_0_7 = 2
local var_0_8 = 1

function Dorm3dInsMainLayer:getUIName()
	return "Dorm3dInsMainUI"
end

function Dorm3dInsMainLayer:getResource()
	local var_2_0 = {}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local var_2_2 = getProxy(Dorm3dInsProxy):GetRoomList()

	var_2_2 = var_2_2 or {}

	for iter_2_0, iter_2_1 in ipairs(var_2_2) do
		var_2_1(iter_2_1:GetIcon())
		var_2_1(iter_2_1:GetCard())
	end

	return table.insertto(var_2_0, Dorm3dInsMainLayer.super.getResource(self))
end

function Dorm3dInsMainLayer:init()
	self.bg = self._tf:Find("bg")
	self.mainTf = self._tf:Find("main")
	self.mainPages = {
		[var_0_8] = Dorm3dInsPublicPage.New(self._tf:Find("main/public_page"), self.event),
		[var_0_7] = Dorm3dInsCharPage.New(self._tf:Find("main/char_page"), self.event)
	}
	self.roomListContainer = self._tf:Find("left/scroll/mask/list")
	self.roomItemList = UIItemList.New(self.roomListContainer, self.roomListContainer:Find("tpl"))

	self.roomItemList:make(function(arg_5_0, arg_5_1, arg_5_2)
		if arg_5_0 == UIItemList.EventUpdate then
			self:UpdateRoomList(arg_5_1, arg_5_2)
		end
	end)

	self.expandPanel = self._tf:Find("expand_panel")
	self.expandListContainer = self._tf:Find("expand_panel/scroll/mask/list")
	self.expandItemList = UIItemList.New(self.expandListContainer, self.expandListContainer:Find("tpl"))

	self.expandItemList:make(function(arg_6_0, arg_6_1, arg_6_2)
		if arg_6_0 == UIItemList.EventUpdate then
			self:UpdateRoomList(arg_6_1, arg_6_2)
		end
	end)

	self.selectPanel = self._tf:Find("select_panel")
	self.selectListContainer = self._tf:Find("select_panel/list")
	self.selectItemList = UIItemList.New(self.selectListContainer, self.selectListContainer:Find("tpl"))

	self.selectItemList:make(function(arg_7_0, arg_7_1, arg_7_2)
		if arg_7_0 == UIItemList.EventInit then
			self:InitSelectItem(arg_7_1, arg_7_2)
		end
	end)

	self.selectOpen = false
	self.downloadTf = self._tf:Find("main/download")
	self.download = self.downloadTf:Find("btns/download")
	self.downloading = self.downloadTf:Find("btns/downloading")
	self.delete = self.downloadTf:Find("btns/delete")
	self.downloadProgress = self.downloadTf:Find("progress")
	self.slider = self.downloadProgress:Find("slider")

	self:BlurPanel(self._tf)
	self:InitData()
end

function Dorm3dInsMainLayer:InitData()
	self.roomDataDic = {}
	self.roomDataList = Clone(getProxy(Dorm3dInsProxy):GetRoomList())

	for iter_8_0, iter_8_1 in ipairs(self.roomDataList) do
		self.roomDataDic[iter_8_1.id] = iter_8_1
	end

	self.selectOptions = {}

	self:BuildSelectOptions()
	self:FilterRoomList(var_0_1)
	self:SortRoomList()
end

function Dorm3dInsMainLayer:BuildSelectOptions()
	table.insert(self.selectOptions, {
		mode = var_0_1,
		label = i18n("dorm3d_privatechat_screen_all")
	})

	for iter_9_0, iter_9_1 in pairs(pg.dorm3d_rooms.get_id_list_by_in_map) do
		table.insert(self.selectOptions, {
			mode = var_0_2,
			arg = iter_9_0,
			label = i18n("dorm3d_privatechat_screen_" .. iter_9_0)
		})
	end
end

function Dorm3dInsMainLayer:FilterRoomList(arg_10_1, arg_10_2)
	self.roomIdList = _.map(_.select(self.roomDataList, function(arg_11_0)
		return switch(arg_10_1, {
			[var_0_1] = function()
				return true
			end,
			[var_0_2] = function()
				return arg_11_0:GetInMap() == arg_10_2
			end
		})
	end), function(arg_14_0)
		return arg_14_0.id
	end)
end

function Dorm3dInsMainLayer:SortRoomList()
	table.sort(self.roomIdList, function(arg_16_0, arg_16_1)
		local var_16_0 = self.roomDataDic[arg_16_0]:IsCare() and 1 or 0
		local var_16_1 = self.roomDataDic[arg_16_1]:IsCare() and 1 or 0

		if var_16_0 ~= var_16_1 then
			return var_16_1 < var_16_0
		end

		local var_16_2 = self.roomDataDic[arg_16_0]:GetType()
		local var_16_3 = self.roomDataDic[arg_16_1]:GetType()

		if var_16_2 ~= var_16_3 then
			return var_16_3 < var_16_2
		end

		return arg_16_0 < arg_16_1
	end)
end

function Dorm3dInsMainLayer:ClosePrePage()
	switch(self.curPage, {
		[var_0_3] = function()
			self:emit(Dorm3dInsMainMediator.CLOSE_JUUS)
		end,
		[var_0_4] = function()
			self:emit(Dorm3dInsMainMediator.CLOSE_CHAT)
		end,
		[var_0_5] = function()
			self:emit(Dorm3dInsMainMediator.CLOSE_PHONE)
		end,
		[var_0_6] = function()
			setActive(self.mainTf, false)
		end
	})

	self.curPage = nil
end

function Dorm3dInsMainLayer:didEnter()
	onButton(self, self.bg, function()
		if self.curPage then
			self:ClosePrePage()
		end

		self:closeView()
	end, SFX_PANEL)
	onButton(self, self._tf:Find("left/btn_select"), function()
		self:OpenOrCloseSelectPanel()
	end)
	onButton(self, self.selectPanel:Find("back"), function()
		self:OpenOrCloseSelectPanel()
	end)
	onButton(self, self._tf:Find("left/btn_expand"), function()
		setActive(self.expandPanel, true)
		self.expandPanel:SetAsLastSibling()
	end)
	onButton(self, self.expandPanel:Find("btn_close"), function()
		setActive(self.expandPanel, false)
	end)
	onButton(self, self.downloadTf, function()
		self:OnClickDownload(self.selectedId)
	end)

	local function var_22_0(arg_29_0)
		if not self.roomDataDic[self.selectedId]:IsDownloaded() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_privatechat_room_unlock"))
		else
			existCall(arg_29_0)
		end
	end

	self:bind(Dorm3dInsMainLayer.OPEN_INS, function(arg_30_0)
		var_22_0(function()
			self:ClosePrePage()

			self.curPage = var_0_3

			self:emit(Dorm3dInsMainMediator.OPEN_JUUS, self.roomDataDic[self.selectedId].groupId)
		end)
	end)
	self:bind(Dorm3dInsMainLayer.OPEN_CHAT, function(arg_32_0)
		var_22_0(function()
			self:ClosePrePage()

			self.curPage = var_0_4

			self:emit(Dorm3dInsMainMediator.OPEN_CHAT, self.roomDataDic[self.selectedId].groupId)
		end)
	end)
	self:bind(Dorm3dInsMainLayer.OPEN_PHONE, function(arg_34_0)
		var_22_0(function()
			if DORM_LOCK_INS_PHONE then
				pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_privatechat_telephone"))

				return
			end

			self:ClosePrePage()

			self.curPage = var_0_5

			self:emit(Dorm3dInsMainMediator.OPEN_PHONE, self.roomDataDic[self.selectedId].groupId)
		end)
	end)
	self:bind(Dorm3dInsMainLayer.FLUSH_LEFT, function(arg_36_0)
		self:SortRoomList()
		self.roomItemList:align(#self.roomIdList)
	end)

	self.selectedId = self.roomIdList[1]

	self.selectItemList:align(#self.selectOptions)

	self.curPage = var_0_6

	self:Flush()

	if self.contextData.isPhone then
		-- block empty
	end
end

function Dorm3dInsMainLayer:UpdateRoomList(arg_37_1, arg_37_2)
	local var_37_0 = self.roomDataDic[self.roomIdList[arg_37_1 + 1]]

	setActive(arg_37_2:Find("selected"), self.roomDataDic[self.roomIdList[arg_37_1 + 1]].id == self.selectedId)
	setActive(arg_37_2:Find("like"), var_37_0:IsCare())
	GetImageSpriteFromAtlasAsync(var_37_0:GetIcon(), "", arg_37_2:Find("mask/icon"), true)
	setActive(arg_37_2:Find("tip"), var_37_0:ShouldTip())
	onButton(self, arg_37_2, function()
		self.selectedId = var_37_0.id

		if self.curPage ~= var_0_6 then
			self:OpenMain()
		end

		self:Flush()
	end)
end

function Dorm3dInsMainLayer:OpenMain()
	self:ClosePrePage()
	setActive(self.mainTf, true)
	self:Flush()

	self.curPage = var_0_6
end

function Dorm3dInsMainLayer:Flush()
	local var_40_0 = self.roomDataDic[self.selectedId]:GetType()

	self.mainPages[(function(arg_41_0)
		return #self.mainPages - arg_41_0 + 1
	end)(var_40_0)]:Hide()
	self.mainPages[var_40_0]:Show()
	self.mainPages[var_40_0]:Flush(self.roomDataDic[self.selectedId])
	self.roomItemList:align(#self.roomIdList)
	self.expandItemList:align(#self.roomIdList)
	self:FlushDownload()
end

function Dorm3dInsMainLayer:FlushLeft()
	self.roomItemList:align(#self.roomIdList)
end

function Dorm3dInsMainLayer:InitSelectItem(arg_43_1, arg_43_2)
	local var_43_0 = self.selectOptions[arg_43_1 + 1]

	setText(arg_43_2:Find("label"), self.selectOptions[arg_43_1 + 1].label)
	onButton(self, arg_43_2, function()
		self:FilterRoomList(var_43_0.mode, var_43_0.arg)
		self:SortRoomList()
		self.roomItemList:align(#self.roomIdList)
		self.expandItemList:align(#self.roomIdList)
	end)
end

function Dorm3dInsMainLayer:OpenOrCloseSelectPanel()
	self.selectOpen = not self.selectOpen

	setActive(self.selectPanel, self.selectOpen)

	if self.selectOpen then
		self.selectPanel:SetAsLastSibling()
	end
end

local var_0_9 = 1
local var_0_10 = 2
local var_0_11 = 3

function Dorm3dInsMainLayer:CheckCurrentDownloadState(arg_46_1)
	if DormGroupConst.DormDownloadLock and DormGroupConst.DormDownloadLock.roomId == arg_46_1 then
		return var_0_11
	end

	return (self.roomDataDic[arg_46_1]:IsDownloaded() or nil) and (var_0_10 or var_0_9)
end

function Dorm3dInsMainLayer:FlushDownload(arg_47_1)
	arg_47_1 = arg_47_1 or self:CheckCurrentDownloadState(self.selectedId)

	setActive(self.download, arg_47_1 == var_0_9)
	setActive(self.delete, arg_47_1 == var_0_10)
	setActive(self.downloading, arg_47_1 == var_0_11)
	self:FlushDownloadSlider(arg_47_1)
end

function Dorm3dInsMainLayer:FlushDownloadSlider(arg_48_1)
	setActive(self.downloadProgress, arg_48_1 == var_0_11)

	if arg_48_1 == var_0_11 then
		setSlider(self.slider, 0, DormGroupConst.DormDownloadLock.totalSize, DormGroupConst.DormDownloadLock.curSize)
	end
end

function Dorm3dInsMainLayer:DownloadUpdate(arg_49_1, arg_49_2)
	if arg_49_1 ~= self.selectedId then
		return
	end

	switch(arg_49_2, {
		start = function()
			self:FlushDownload(var_0_11)
		end,
		loading = function()
			self:FlushDownloadSlider(var_0_11)
		end,
		finish = function()
			self:FlushDownload(var_0_10)
		end,
		delete = function()
			self:FlushDownload(var_0_9)
		end
	})
end

function Dorm3dInsMainLayer:OnClickDownload(arg_54_1)
	if getProxy(ApartmentProxy):getRoom(1) then
		if not pg.NewStoryMgr.GetInstance():IsPlayed("DORM3D_GUIDE_02") then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_tip"))

			return
		end
	end

	switch(self:CheckCurrentDownloadState(arg_54_1), {
		[var_0_10] = function()
			self:DeleteRoom(arg_54_1)
		end,
		[var_0_9] = function()
			if not getProxy(ApartmentProxy):getRoom(arg_54_1) then
				if self.roomDataDic[arg_54_1]:GetType() == 1 then
					self:emit(Dorm3dInsMainMediator.OPEN_ROOM_UNLOCK_WINDOW, arg_54_1)
				elseif self.roomDataDic[arg_54_1]:GetType() == 2 then
					self:emit(Dorm3dInsMainMediator.ON_UNLOCK_DORM_ROOM, arg_54_1)
				end
			else
				self:TryDownloadResource({
					roomId = arg_54_1
				})
			end
		end,
		[var_0_11] = function()
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_now_is_downloading"))
		end
	})
end

function Dorm3dInsMainLayer:TryDownloadResource(arg_58_1, arg_58_2)
	if DormGroupConst.IsDownloading() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_now_is_downloading"))

		return
	end

	local var_58_0 = getProxy(ApartmentProxy):getRoom(arg_58_1.roomId)
	local var_58_1 = var_58_0:getDownloadNameList()

	if #var_58_1 > 0 then
		DormGroupConst.DormDownload({
			isShowBox = true,
			fileList = var_58_1,
			finishFunc = function(arg_59_0)
				if arg_59_0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_resource_download_complete"))
				end
			end,
			roomId = var_58_0.configId
		})
	else
		existCall(arg_58_2)
	end
end

function Dorm3dInsMainLayer:DeleteRoom(arg_60_1)
	self:TryDownloadResource({
		roomId = arg_60_1
	}, function()
		local var_61_0 = getProxy(ApartmentProxy):getRoom(arg_60_1)
		local var_61_1 = var_61_0:getConfig("room")

		if var_61_0:isPersonalRoom() then
			var_61_1 = ShipGroup.getDefaultShipNameByGroupID(var_61_0:getPersonalGroupId())
		end

		local var_61_2 = var_61_0:isPersonalRoom() and DormGroupConst.GetDelRoomSize(string.lower(var_61_0:getConfig("resource_name")), {
			"room",
			"apartment"
		}) or DormGroupConst.GetDelRoomSize(string.lower(var_61_0:getConfig("resource_name")), {
			"room"
		})

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("dorm3d_role_assets_delete", var_61_1, var_61_2),
			onYes = function()
				if IsUnityEditor then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_no_open"))

					return
				end

				if var_61_0:isPersonalRoom() then
					DormGroupConst.DelRoom(string.lower(var_61_0:getConfig("resource_name")), {
						"room",
						"apartment"
					})
				else
					DormGroupConst.DelRoom(string.lower(var_61_0:getConfig("resource_name")), {
						"room"
					})
				end

				pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_delete_finish"))
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataDownload(var_61_0.id, 3))
				self:emit(Dorm3dInsMainMediator.NotifyDormDelete, arg_60_1)
			end
		})
	end)
end

return Dorm3dInsMainLayer
