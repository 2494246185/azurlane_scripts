local SelectDorm3DScene = class("SelectDorm3DScene", import("view.base.BaseUI"))

function SelectDorm3DScene:getUIName()
	return "SelectDorm3DUI"
end

function SelectDorm3DScene:getResource()
	local var_2_0 = {}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	for iter_2_0, iter_2_1 in pairs(pg.dorm3d_rooms.get_id_list_by_in_map or {}) do
		for iter_2_2, iter_2_3 in ipairs(iter_2_1) do
			if pg.dorm3d_rooms[iter_2_3] and pg.dorm3d_rooms[iter_2_3].assets_prefix then
				var_2_1(string.format("dorm3dselect/room_icon_%s", string.lower(pg.dorm3d_rooms[iter_2_3].assets_prefix)))
			end
		end
	end

	var_2_1("weaponframes")
	var_2_1("ui/dormstyledropmsgboxui")

	local var_2_2 = getDorm3dGameset("drom3d_weekly_task")[1]
	local var_2_3 = var_2_2 and getProxy(TaskProxy):getTaskVO(var_2_2)
	local var_2_4 = var_2_3 and var_2_3:getConfig("award_display") and var_2_3:getConfig("award_display")[1]

	if var_2_4 then
		local var_2_5 = Drop.Create(var_2_4)

		if var_2_5.type == DROP_TYPE_DORM3D_GIFT then
			var_2_1(pg.dorm3d_gift[var_2_5.id] and pg.dorm3d_gift[var_2_5.id].icon)
		else
			var_2_1(var_2_5:getIcon())
		end
	end

	return table.insertto(var_2_0, SelectDorm3DScene.super.getResource(self))
end

function SelectDorm3DScene:init()
	self.rtMap = self._tf:Find("Map")
	self.rtIconTip = self.rtMap:Find("tip")

	setActive(self.rtIconTip, false)
	onButton(self, self.rtIconTip:Find("bg"), function()
		self:HideIconTipWindow()
	end, SFX_CANCEL)
	setText(self.rtIconTip:Find("window/btn_cancel/Text"), i18n("text_cancel"))
	onButton(self, self.rtIconTip:Find("window/btn_cancel"), function()
		self:HideIconTipWindow()
	end, SFX_CANCEL)
	setText(self.rtIconTip:Find("window/btn_confirm/Text"), i18n("text_confirm"))

	self.rtMain = self._tf:Find("Main")

	setText(self.rtMain:Find("title/Text"), i18n("dorm3d_role_choose"))
	onButton(self, self.rtMain:Find("btn_back"), function()
		self.clearSceneCache = true

		self:closeView()
	end, SFX_CANCEL)

	self.insBtn = Dorm3dInsBtn.New(self.rtMain:Find("btn_ins"))

	onButton(self, self.insBtn.root, function()
		self:emit(SelectDorm3DMediator.OPEN_INS_LAYER, self.insBtn.IsNewPhoneCall())
	end)
	setActive(self.rtMain:Find("btn_ins"), not DORM_LOCK_INS)

	if not pg.TimeMgr.GetInstance():IsSameWeek(pg.TimeMgr.GetInstance():GetServerTime(), PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dGiftWeekRefreshTimeStamp", 0)) then
		ApartmentProxy.RefreshGiftDailyTip()
	end

	setActive(self.rtMain:Find("btn_shop/tip"), Dorm3dShopUI.ShouldShowAllTip())
	onButton(self, self.rtMain:Find("btn_shop"), function()
		self:emit(SelectDorm3DMediator.OPEN_SHOP_LAYER, function()
			setActive(self.rtMain:Find("btn_shop/tip"), Dorm3dShopUI.ShouldShowAllTip())
		end)
	end)
	onButton(self, self.rtMain:Find("option/setting"), function()
		self:emit(SelectDorm3DMediator.OPEN_SETTING_LAYER)
	end)
	onButton(self, self.rtMain:Find("option/home"), function()
		self:emit(BaseUI.ON_HOME)
	end)

	self.rtStamina = self.rtMain:Find("stamina")
	self.rtRes = self.rtMain:Find("res")

	self:InitResBar()

	self.rtWeekTask = self.rtMain:Find("task")

	self:UpdateWeekTask()

	self.rtLayer = self._tf:Find("Layer")
	self.floorData = _.keys(pg.dorm3d_rooms.get_id_list_by_in_map)

	table.sort(self.floorData, function(arg_13_0, arg_13_1)
		return (tonumber(string.match(arg_13_0, "%d+")) or 0) < (tonumber(string.match(arg_13_1, "%d+")) or 0)
	end)
	self:SetMapSwitch()
end

function SelectDorm3DScene:didEnter()
	self:SetFloor(self.floorData[self.selectedFloorId])
	self:UpdateStamina()
	self:CheckGuide("DORM3D_GUIDE_02")
	self:FlushInsBtn()

	if not ApartmentProxy.CheckDeviceRAMEnough() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("drom3d_memory_limit_tip"))
	end
end

function SelectDorm3DScene:FlushInsBtn()
	self.insBtn:Flush()
end

function SelectDorm3DScene:UpdateStamina()
	setText(self.rtStamina:Find("Text"), string.format("%d/%d", getProxy(ApartmentProxy):getStamina()))
	setActive(self.rtStamina:Find("vfx_ui_stamina01"), getProxy(ApartmentProxy):getStamina() > 0)
end

function SelectDorm3DScene:SetFloor(arg_17_1)
	local var_17_0

	eachChild(self.rtMap, function(arg_18_0)
		setActive(arg_18_0, arg_18_0.name == arg_17_1)

		if arg_18_0.name == arg_17_1 then
			var_17_0 = arg_18_0
		end
	end)
	assert(nil)

	self.roomDic = {}

	for iter_17_0, iter_17_1 in ipairs(pg.dorm3d_rooms.get_id_list_by_in_map[arg_17_1]) do
		self.roomDic[iter_17_1] = (nil):Find(pg.dorm3d_rooms[iter_17_1].assets_prefix)

		self:InitIconTrigger(iter_17_1)
		self:UpdateIconState(iter_17_1)
	end

	self:ReplaceSpecialRoomIcon()
end

function SelectDorm3DScene:FlushFloor()
	self:SetFloor(self.floorData[self.selectedFloorId])
end

function SelectDorm3DScene:InitIconTrigger(arg_20_1)
	local var_20_0 = self.roomDic[arg_20_1]

	GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(pg.dorm3d_rooms[arg_20_1].assets_prefix)), "", self.roomDic[arg_20_1]:Find("icon"))
	onButton(self, self.roomDic[arg_20_1], function()
		if BLOCK_DORM3D_ROOMS and table.contains(BLOCK_DORM3D_ROOMS, arg_20_1) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_system_switch"))

			return
		end

		if arg_20_1 ~= 1 then
			if getProxy(ApartmentProxy):getRoom(1) then
				if not pg.NewStoryMgr.GetInstance():IsPlayed("DORM3D_GUIDE_02") then
					if not DORM_LOCK_GUIDE then
						pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_tip"))

						return
					end
				end
			end
		end

		local var_21_0 = getProxy(ApartmentProxy):getRoom(arg_20_1)

		if pg.dorm3d_rooms[arg_20_1].type == 1 then
			if arg_20_1 ~= 4 then
				if not pg.NewStoryMgr.GetInstance():IsPlayed("DORM3D_GUIDE_06") and not DORM_LOCK_GUIDE then
					pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_tip2"))

					return
				end
			end

			if not var_21_0 then
				self:emit(SelectDorm3DMediator.OPEN_ROOM_UNLOCK_WINDOW, arg_20_1)
			else
				self:TryDownloadResource({
					click = true,
					roomId = arg_20_1
				}, function()
					local var_22_0 = ApartmentProxy.GetRoomInviteList(arg_20_1)

					self:emit(SelectDorm3DMediator.OPEN_INVITE_LAYER, arg_20_1, (self:CheckGuide("DORM3D_GUIDE_06") or nil) and {}, function()
						self:FlushFloor()
					end)
				end)
			end
		elseif pg.dorm3d_rooms[arg_20_1].type == 2 then
			if not var_21_0 then
				self:ShowIconTipWindow(arg_20_1, var_20_0)
			else
				self:TryDownloadResource({
					click = true,
					roomId = arg_20_1
				}, function()
					self:emit(SelectDorm3DMediator.ON_DORM, {
						roomId = var_21_0.id,
						groupIds = var_21_0:getInviteList()
					})
				end)
			end
		else
			assert(false)
		end
	end, SFX_PANEL)
end

function SelectDorm3DScene:UpdateIconState(arg_25_1)
	local var_25_0 = self.roomDic[arg_25_1]
	local var_25_1 = getProxy(ApartmentProxy):getRoom(arg_25_1)
	local var_25_2 = var_25_1 and var_25_1:getState() or "lock"

	setActive(self.roomDic[arg_25_1]:Find("icon/mask"), var_25_2 ~= "complete")
	eachChild(var_25_0:Find("front"), function(arg_26_0)
		setActive(arg_26_0, arg_26_0.name == var_25_2)
	end)
	switch(var_25_2, {
		loading = function()
			setSlider(var_25_0:Find("front/loading/progress"), 0, DormGroupConst.DormDownloadLock.totalSize, DormGroupConst.DormDownloadLock.curSize)
		end,
		complete = function()
			local var_28_0 = var_25_0:Find("front/complete")
			local var_28_1 = var_25_1:isPersonalRoom()

			setActive(var_28_0, var_28_1)

			if var_28_1 then
				local var_28_2 = getProxy(ApartmentProxy):getApartment(var_25_1:getPersonalGroupId())
				local var_28_3 = var_28_2:getIconTip(var_25_1:GetConfigID())

				eachChild(var_28_0:Find("tip"), function(arg_29_0)
					setActive(arg_29_0, arg_29_0.name == var_28_3)
				end)
				setText(var_28_0:Find("favor/Text"), var_28_2.level)
			end
		end
	})

	if arg_25_1 == 4 then
		setActive(var_25_0:Find("inivite_tip"), PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dRoomInviteSuccess_" .. arg_25_1, 1) == 0)
	end

	setActive(var_25_0:Find("tip"), (function()
		if not var_25_1 or not var_25_1:isPersonalRoom() then
			return false
		end

		return getProxy(ApartmentProxy):HasShipGroupGiftExpireSoon(var_25_1:getConfig("character")[1])
	end)())
end

function SelectDorm3DScene:UpdateShowIcon(arg_31_1, arg_31_2)
	removeOnButton(arg_31_2)
	setActive(arg_31_2:Find("icon/mask"), false)
	eachChild(arg_31_2:Find("front"), function(arg_32_0)
		setActive(arg_32_0, false)
	end)
end

function SelectDorm3DScene:ReplaceSpecialRoomIcon()
	local var_33_0 = {}

	for iter_33_0, iter_33_1 in pairs(getProxy(ApartmentProxy):getRawData()) do
		for iter_33_2, iter_33_3 in ipairs(iter_33_1:getSpecialTalking()) do
			if self.roomDic[pg.dorm3d_dialogue_group[iter_33_3].trigger_config[1]] then
				var_33_0[pg.dorm3d_dialogue_group[iter_33_3].trigger_config[1]] = var_33_0[pg.dorm3d_dialogue_group[iter_33_3].trigger_config[1]] or {}

				table.insert(var_33_0[pg.dorm3d_dialogue_group[iter_33_3].trigger_config[1]], iter_33_3)
			end
		end
	end

	for iter_33_4, iter_33_5 in pairs(var_33_0) do
		setActive(self.roomDic[iter_33_4], false)

		local var_33_1 = cloneTplTo(self.roomDic[iter_33_4], self.roomDic[iter_33_4].parent, self.roomDic[iter_33_4].name .. "_special")

		self:UpdateShowIcon(iter_33_4, var_33_1)
		GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(pg.dorm3d_rooms[iter_33_4].assets_prefix)), "", var_33_1:Find("icon"))
		setActive(var_33_1:Find("front/complete"), true)
		setActive(var_33_1:Find("front/complete/favor"), false)
		eachChild(var_33_1:Find("front/complete/tip"), function(arg_34_0)
			setActive(arg_34_0, arg_34_0.name == "main")
		end)
		table.sort(iter_33_5)

		local var_33_2 = iter_33_5[1]
		local var_33_3 = pg.dorm3d_dialogue_group[iter_33_5[1]]

		if DORM_LOCK_GUIDE and iter_33_5[1] == 10010 then
			return
		end

		onButton(self, var_33_1, function()
			self:TryDownloadResource({
				click = true,
				roomId = var_33_3.room_id
			}, function()
				self:emit(SelectDorm3DMediator.ON_DORM, {
					roomId = var_33_3.room_id,
					groupIds = {
						var_33_3.char_id
					},
					specialId = var_33_2
				})
			end)
		end, SFX_PANEL)
	end
end

function SelectDorm3DScene:DownloadUpdate(arg_37_1, arg_37_2)
	switch(arg_37_2, {
		start = function()
			if self.roomDic[arg_37_1] then
				self:UpdateIconState(arg_37_1)
			end
		end,
		loading = function()
			if self.roomDic[arg_37_1] then
				setSlider(self.roomDic[arg_37_1]:Find("front/loading/progress"), 0, DormGroupConst.DormDownloadLock.totalSize, DormGroupConst.DormDownloadLock.curSize)
			end
		end,
		finish = function()
			for iter_40_0, iter_40_1 in pairs(self.roomDic) do
				self:UpdateIconState(iter_40_0)
			end

			self:CheckGuide("DORM3D_GUIDE_02")
		end,
		delete = function()
			if self.roomDic[arg_37_1] then
				self:UpdateIconState(arg_37_1)
			end
		end
	})
end

function SelectDorm3DScene:AfterRoomUnlock(arg_42_1)
	local var_42_0 = arg_42_1.roomId

	if isActive(self.rtIconTip) then
		self:HideIconTipWindow()
	end

	eachChild(self.roomDic[arg_42_1.roomId]:Find("icon/mask"), function(arg_43_0)
		setActive(arg_43_0, true)
	end)
	quickPlayAnimation(self.roomDic[arg_42_1.roomId], "anim_Dorm3d_selectDorm_icon_unlock")
	pg.UIMgr.GetInstance():LoadingOn(false)
	LeanTween.delayedCall(1.2333333333333334, System.Action(function()
		pg.UIMgr.GetInstance():LoadingOff(false)
		self:UpdateIconState(var_42_0)
		self:TryDownloadResource(arg_42_1)
		self:CheckGuide("DORM3D_GUIDE_02")
		self:SetMapSwitch()
	end))
end

function SelectDorm3DScene:ShowIconTipWindow(arg_45_1, arg_45_2)
	setLocalPosition(self.rtIconTip:Find("window"), self.rtIconTip:InverseTransformPoint(arg_45_2.position))
	removeAllChildren(self.rtIconTip:Find("window/icon"))

	arg_45_2 = cloneTplTo(arg_45_2, self.rtIconTip:Find("window/icon"))

	self:UpdateShowIcon(arg_45_1, arg_45_2)
	setAnchoredPosition(arg_45_2, Vector2.zero)

	local var_45_0 = ApartmentRoom.New({
		id = arg_45_1
	})
	local var_45_1, var_45_2 = var_45_0:getDownloadNeedSize()

	setText(self.rtIconTip:Find("window/Text"), i18n("dorm3d_role_assets_download", ShipGroup.getDefaultShipNameByGroupID(var_45_0:getPersonalGroupId()), var_45_0:needDownload() and var_45_2 or "0B"))
	onButton(self, self.rtIconTip:Find("window/btn_confirm"), function()
		self:emit(SelectDorm3DMediator.ON_UNLOCK_DORM_ROOM, arg_45_1)
	end, SFX_CONFIRM)
	setActive(self.rtIconTip, true)
end

function SelectDorm3DScene:HideIconTipWindow()
	setActive(self.rtIconTip, false)
end

function SelectDorm3DScene:TryDownloadResource(arg_48_1, arg_48_2)
	if DormGroupConst.IsDownloading() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_now_is_downloading"))

		return
	end

	local var_48_0 = getProxy(ApartmentProxy):getRoom(arg_48_1.roomId)
	local var_48_1 = var_48_0:getDownloadNameList()

	if #var_48_1 > 0 then
		DormGroupConst.DormDownload({
			isShowBox = true,
			fileList = var_48_1,
			finishFunc = function(arg_49_0)
				if arg_49_0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_resource_download_complete"))
				end
			end,
			roomId = var_48_0.configId
		})
	else
		existCall(arg_48_2)
	end
end

function SelectDorm3DScene:InitResBar()
	self.goldMax = self.rtRes:Find("gold/max"):GetComponent(typeof(Text))
	self.goldValue = self.rtRes:Find("gold/Text"):GetComponent(typeof(Text))
	self.oilMax = self.rtRes:Find("oil/max"):GetComponent(typeof(Text))
	self.oilValue = self.rtRes:Find("oil/Text"):GetComponent(typeof(Text))
	self.gemValue = self.rtRes:Find("gem/Text"):GetComponent(typeof(Text))

	onButton(self, self.rtRes:Find("gold"), function()
		pg.playerResUI:ClickGold()
	end, SFX_PANEL)
	onButton(self, self.rtRes:Find("oil"), function()
		pg.playerResUI:ClickOil()
	end, SFX_PANEL)
	onButton(self, self.rtRes:Find("gem"), function()
		pg.playerResUI:ClickGem()
	end, SFX_PANEL)
	self:UpdateRes()
end

function SelectDorm3DScene:UpdateRes()
	PlayerResUI.StaticFlush(getProxy(PlayerProxy):getRawData(), self.goldMax, self.goldValue, self.oilMax, self.oilValue, self.gemValue)
end

function SelectDorm3DScene:UpdateWeekTask()
	local var_55_0 = getDorm3dGameset("drom3d_weekly_task")[1]
	local var_55_1 = getProxy(TaskProxy):getTaskVO(var_55_0)
	local var_55_2 = var_55_1:isReceive()
	local var_55_3 = var_55_2 and 3 or var_55_1:getProgress()
	local var_55_4 = self.rtWeekTask:Find("content")

	for iter_55_0 = 1, 3 do
		triggerToggle(var_55_4:Find("tpl_" .. iter_55_0), iter_55_0 <= var_55_3)
	end

	local var_55_5 = Drop.Create(var_55_1:getConfig("award_display")[1])

	updateCustomDrop(var_55_4:Find("Dorm3dIconTpl"), var_55_5)
	onButton(self, var_55_4:Find("Dorm3dIconTpl"), function()
		if not var_55_2 and var_55_1:isFinish() then
			self:emit(SelectDorm3DMediator.ON_SUBMIT_TASK, var_55_0)
		else
			self:emit(BaseUI.ON_NEW_DROP, {
				drop = var_55_5
			})
		end
	end, SFX_CONFIRM)
	setActive(var_55_4:Find("Dorm3dIconTpl/get"), not var_55_2 and var_55_1:isFinish())
	setGray(var_55_4:Find("Dorm3dIconTpl"), var_55_2)
	onButton(self, self._tf:Find("Main/task_done"), function()
		setActive(self.rtWeekTask, true)
		setActive(self._tf:Find("Main/task_done"), false)
	end)
	onButton(self, self.rtWeekTask:Find("title"), function()
		if var_55_2 then
			setActive(self.rtWeekTask, false)
			setActive(self._tf:Find("Main/task_done"), true)
		end
	end)
end

function SelectDorm3DScene:CheckGuide(arg_59_1)
	if pg.NewStoryMgr.GetInstance():IsPlayed(arg_59_1) then
		return
	end

	if DORM_LOCK_GUIDE then
		return false
	end

	return switch(arg_59_1, {
		DORM3D_GUIDE_02 = function()
			local var_60_0 = getProxy(ApartmentProxy):getApartment(20220)

			if var_60_0 and not var_60_0:needDownload() then
				pg.m02:sendNotification(GAME.STORY_UPDATE, {
					storyId = arg_59_1
				})
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(1, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_59_1)))
				pg.NewGuideMgr.GetInstance():Play(arg_59_1, nil, function()
					pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(2, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_59_1)))
				end)

				return true
			end
		end,
		DORM3D_GUIDE_06 = function()
			pg.m02:sendNotification(GAME.STORY_UPDATE, {
				storyId = arg_59_1
			})
			pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(1, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_59_1)))
			pg.NewGuideMgr.GetInstance():Play(arg_59_1, nil, function()
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(2, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_59_1)))
			end)

			return true
		end
	}, function()
		return false
	end)
end

function SelectDorm3DScene:SetMapSwitch()
	local var_65_0 = getProxy(PlayerProxy):getRawData().id

	self.selectedFloorId = PlayerPrefs.GetInt("DORM_SELECTED_FLOOR_ID" .. var_65_0, 1)

	if pg.NewGuideMgr.GetInstance():GetCurrentGuideName() == "DORM3D_GUIDE_01" then
		self.selectedFloorId = 1
	elseif not DORM_LOCK_SELECT_NEW then
		if PlayerPrefs.GetInt("DORM_SELECTED_NEW_ROOM_FLOOR" .. var_65_0 .. pg.dorm3d_set.drom3d_new_room_remind.key_value_int, 0) == 0 then
			self.selectedFloorId = table.indexof(self.floorData, pg.dorm3d_rooms[pg.dorm3d_set.drom3d_new_room_remind.key_value_int].in_map)

			PlayerPrefs.SetInt("DORM_SELECTED_NEW_ROOM_FLOOR" .. var_65_0 .. pg.dorm3d_set.drom3d_new_room_remind.key_value_int, 1)
		end
	end

	local var_65_1 = self._tf:Find("interludeAni")
	local var_65_2 = var_65_1:GetComponent(typeof(Animation))
	local var_65_3 = var_65_1:GetComponent(typeof(DftAniEvent))

	onButton(self, self.rtMain:Find("btn_switch/left"), function()
		var_65_3:SetTriggerEvent(function()
			self:ChangeMap(self.selectedFloorId - 1)
		end)
		var_65_2:Play("anim_InterludeAni")
	end)
	onButton(self, self.rtMain:Find("btn_switch/right"), function()
		var_65_3:SetTriggerEvent(function()
			self:ChangeMap(self.selectedFloorId + 1)
		end)
		var_65_2:Play("anim_InterludeAni")
	end)
	setActive(self.rtMain:Find("btn_switch/switchPanel"), false)

	local var_65_4 = self.rtMain:Find("btn_switch/switchPanel"):GetComponent(typeof(Animation))

	self.rtMain:Find("btn_switch/switchPanel"):GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
		setActive(self.rtMain:Find("btn_switch/switchPanel"), false)
	end)
	onButton(self, self.rtMain:Find("btn_switch/switch"), function()
		setActive(self.rtMain:Find("btn_switch/switchPanel"), true)
	end)
	onButton(self, self.rtMain:Find("btn_switch/switchPanel"), function()
		var_65_4:Play("anim_switchPanel_exit")
	end)

	local var_65_5 = UIItemList.New(self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content"), self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content/floor"))

	var_65_5:make(function(arg_73_0, arg_73_1, arg_73_2)
		if arg_73_0 == UIItemList.EventUpdate then
			local var_73_0 = self.floorData[arg_73_1 + 1]
			local var_73_1 = Clone(pg.dorm3d_rooms.get_id_list_by_in_map[self.floorData[arg_73_1 + 1]])

			for iter_73_0 = #var_73_1, 1, -1 do
				if pg.dorm3d_rooms[var_73_1[iter_73_0]].is_common == 1 then
					table.remove(var_73_1, iter_73_0)
				end
			end

			setActive(arg_73_2:Find("select"), arg_73_1 + 1 == self.selectedFloorId)
			setText(arg_73_2:Find("name"), i18n("dorm3d_room_" .. var_73_0))
			table.sort(var_73_1, CompareFuncs({
				function(arg_74_0)
					local var_74_0 = getProxy(ApartmentProxy):getRoom(arg_74_0)

					return (var_74_0 and var_74_0:getState() or "lock") == "complete" and 0 or 1
				end,
				function(arg_75_0)
					return pg.dorm3d_rooms[arg_75_0].type == 2 and 0 or 1
				end
			}))

			local var_73_2 = UIItemList.New(arg_73_2:Find("rooms"), arg_73_2:Find("rooms/room"))

			var_73_2:make(function(arg_76_0, arg_76_1, arg_76_2)
				if arg_76_0 == UIItemList.EventUpdate then
					local var_76_0 = var_73_1[arg_76_1 + 1]
					local var_76_1 = pg.dorm3d_rooms[var_73_1[arg_76_1 + 1]]
					local var_76_2 = getProxy(ApartmentProxy):getRoom(var_73_1[arg_76_1 + 1])

					setActive(arg_76_2:Find("lock"), (var_76_2 and var_76_2:getState() or "lock") ~= "complete")
					GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(var_76_1.assets_prefix)), "", arg_76_2:Find("normal/mask/icon"), false)
					setText(arg_76_2:Find("roomId"), var_76_0)
				end
			end)
			var_73_2:align(#var_73_1)
			onButton(self, arg_73_2, function()
				var_65_3:SetTriggerEvent(function()
					self:ChangeMap(arg_73_1 + 1)
				end)
				var_65_2:Play("anim_InterludeAni")
				var_65_4:Play("anim_switchPanel_exit")
			end, SFX_PANEL)
		end
	end)
	var_65_5:align(#self.floorData)
	self:ChangeMap(self.selectedFloorId)
end

function SelectDorm3DScene:ChangeMap(arg_79_1)
	self.selectedFloorId = arg_79_1

	local var_79_0 = getProxy(PlayerProxy):getRawData().id

	PlayerPrefs.SetInt("DORM_SELECTED_FLOOR_ID" .. var_79_0, self.selectedFloorId)
	self:SetFloor(self.floorData[self.selectedFloorId])
	setActive(self.rtMain:Find("btn_switch/left"), self.selectedFloorId > 1)
	setActive(self.rtMain:Find("btn_switch/right"), self.selectedFloorId < #self.floorData)
	setText(self.rtMain:Find("btn_switch/switch/currentName"), i18n("dorm3d_room_" .. self.floorData[self.selectedFloorId]))

	for iter_79_0 = 0, #self.floorData - 1 do
		setActive(self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content"):GetChild(iter_79_0):Find("select"), iter_79_0 + 1 == arg_79_1)
	end

	self.floorTipFlag = {}
	self.floorRoomTipFlag = {}

	for iter_79_1, iter_79_2 in ipairs(self.floorData) do
		local var_79_1 = false
		local var_79_2 = {}

		for iter_79_3, iter_79_4 in ipairs(pg.dorm3d_rooms.get_id_list_by_in_map[iter_79_2]) do
			if pg.dorm3d_rooms[iter_79_4].is_common == 0 then
				var_79_2[iter_79_4] = false

				local var_79_3 = getProxy(ApartmentProxy):getRoom(iter_79_4)
				local var_79_4 = var_79_3 and var_79_3:getState() or "lock"

				if var_79_4 == "complete" and var_79_3:isPersonalRoom() then
					if getProxy(ApartmentProxy):getApartment(var_79_3:getPersonalGroupId()):getIconTip(var_79_3:GetConfigID()) then
						var_79_1 = true
						var_79_2[iter_79_4] = true
					end
				end

				if var_79_4 == "complete" and not var_79_3:isPersonalRoom() then
					var_79_2[iter_79_4] = PlayerPrefs.GetInt(var_79_0 .. "_dorm3dRoomInviteSuccess_" .. iter_79_4, 1) == 0
				end
			end
		end

		table.insert(self.floorTipFlag, var_79_1)
		table.insert(self.floorRoomTipFlag, var_79_2)
	end

	if self.selectedFloorId > 1 then
		setActive(self.rtMain:Find("btn_switch/left/tip"), self.floorTipFlag[self.selectedFloorId - 1])
	end

	if self.selectedFloorId < #self.floorData then
		setActive(self.rtMain:Find("btn_switch/right/tip"), self.floorTipFlag[self.selectedFloorId + 1])
	end

	setActive(self.rtMain:Find("btn_switch/switch/tip"), table.contains(self.floorTipFlag, true))

	for iter_79_5 = 0, self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content").childCount - 1 do
		local var_79_5 = self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content"):GetChild(iter_79_5)

		for iter_79_6 = 0, var_79_5:Find("rooms").childCount - 1 do
			local var_79_6 = var_79_5:Find("rooms"):GetChild(iter_79_6)

			setActive(var_79_6:Find("normal/tip"), self.floorRoomTipFlag[iter_79_5 + 1][tonumber(var_79_6:Find("roomId"):GetComponent(typeof(Text)).text)])
		end
	end
end

function SelectDorm3DScene:onBackPressed()
	if isActive(self.rtIconTip) then
		self:HideIconTipWindow()
	else
		SelectDorm3DScene.super.onBackPressed(self)
	end
end

function SelectDorm3DScene:willExit()
	if isActive(self.rtIconTip) then
		self:HideIconTipWindow()
	end

	if self.clearSceneCache then
		-- block empty
	end
end

return SelectDorm3DScene
