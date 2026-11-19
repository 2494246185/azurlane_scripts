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
	DormGroupConst.WithDownloadResourceSnapshot(function()
		self:SetFloor(self.floorData[self.selectedFloorId])
		self:UpdateStamina()
		self:CheckGuide("DORM3D_GUIDE_02")
		self:FlushInsBtn()

		if not ApartmentProxy.CheckDeviceRAMEnough() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("drom3d_memory_limit_tip"))
		end
	end)
end

function SelectDorm3DScene:FlushInsBtn()
	DormGroupConst.WithDownloadResourceSnapshot(function()
		self.insBtn:Flush()
	end)
end

function SelectDorm3DScene:UpdateStamina()
	setText(self.rtStamina:Find("Text"), string.format("%d/%d", getProxy(ApartmentProxy):getStamina()))
	setActive(self.rtStamina:Find("vfx_ui_stamina01"), getProxy(ApartmentProxy):getStamina() > 0)
end

function SelectDorm3DScene:SetFloor(arg_19_1)
	DormGroupConst.WithDownloadResourceSnapshot(function()
		local var_20_0

		eachChild(self.rtMap, function(arg_21_0)
			setActive(arg_21_0, arg_21_0.name == arg_19_1)

			if arg_21_0.name == arg_19_1 then
				var_20_0 = arg_21_0
			end
		end)
		assert(nil)

		self.roomDic = {}

		for iter_20_0, iter_20_1 in ipairs(pg.dorm3d_rooms.get_id_list_by_in_map[arg_19_1]) do
			self.roomDic[iter_20_1] = (nil):Find(pg.dorm3d_rooms[iter_20_1].assets_prefix)

			self:InitIconTrigger(iter_20_1)
			self:UpdateIconState(iter_20_1)
		end

		self:ReplaceSpecialRoomIcon()
	end)
end

function SelectDorm3DScene:FlushFloor()
	self:SetFloor(self.floorData[self.selectedFloorId])
end

function SelectDorm3DScene:InitIconTrigger(arg_23_1)
	local var_23_0 = self.roomDic[arg_23_1]

	GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(pg.dorm3d_rooms[arg_23_1].assets_prefix)), "", self.roomDic[arg_23_1]:Find("icon"))
	onButton(self, self.roomDic[arg_23_1], function()
		if BLOCK_DORM3D_ROOMS and table.contains(BLOCK_DORM3D_ROOMS, arg_23_1) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_system_switch"))

			return
		end

		if arg_23_1 ~= 1 then
			if getProxy(ApartmentProxy):getRoom(1) then
				if not pg.NewStoryMgr.GetInstance():IsPlayed("DORM3D_GUIDE_02") then
					if not DORM_LOCK_GUIDE then
						pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_tip"))

						return
					end
				end
			end
		end

		local var_24_0 = getProxy(ApartmentProxy):getRoom(arg_23_1)

		if pg.dorm3d_rooms[arg_23_1].type == 1 then
			if arg_23_1 ~= 4 then
				if not pg.NewStoryMgr.GetInstance():IsPlayed("DORM3D_GUIDE_06") and not DORM_LOCK_GUIDE then
					pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_guide_tip2"))

					return
				end
			end

			if not var_24_0 then
				self:emit(SelectDorm3DMediator.OPEN_ROOM_UNLOCK_WINDOW, arg_23_1)
			else
				self:TryDownloadResource({
					click = true,
					roomId = arg_23_1
				}, function()
					local var_25_0 = ApartmentProxy.GetRoomInviteList(arg_23_1)

					self:emit(SelectDorm3DMediator.OPEN_INVITE_LAYER, arg_23_1, (self:CheckGuide("DORM3D_GUIDE_06") or nil) and {}, function()
						self:FlushFloor()
					end)
				end)
			end
		elseif pg.dorm3d_rooms[arg_23_1].type == 2 then
			if not var_24_0 then
				self:ShowIconTipWindow(arg_23_1, var_23_0)
			else
				self:TryDownloadResource({
					click = true,
					roomId = arg_23_1
				}, function()
					self:emit(SelectDorm3DMediator.ON_DORM, {
						roomId = var_24_0.id,
						groupIds = var_24_0:getInviteList()
					})
				end)
			end
		else
			assert(false)
		end
	end, SFX_PANEL)
end

function SelectDorm3DScene:UpdateIconState(arg_28_1)
	local var_28_0 = self.roomDic[arg_28_1]
	local var_28_1 = getProxy(ApartmentProxy):getRoom(arg_28_1)
	local var_28_2 = var_28_1 and var_28_1:getState() or "lock"

	setActive(self.roomDic[arg_28_1]:Find("icon/mask"), var_28_2 ~= "complete")
	eachChild(var_28_0:Find("front"), function(arg_29_0)
		setActive(arg_29_0, arg_29_0.name == var_28_2)
	end)
	switch(var_28_2, {
		loading = function()
			setSlider(var_28_0:Find("front/loading/progress"), 0, DormGroupConst.DormDownloadLock.totalSize, DormGroupConst.DormDownloadLock.curSize)
		end,
		complete = function()
			local var_31_0 = var_28_0:Find("front/complete")
			local var_31_1 = var_28_1:isPersonalRoom()

			setActive(var_31_0, var_31_1)

			if var_31_1 then
				local var_31_2 = getProxy(ApartmentProxy):getApartment(var_28_1:getPersonalGroupId())
				local var_31_3 = var_31_2:getIconTip(var_28_1:GetConfigID())

				eachChild(var_31_0:Find("tip"), function(arg_32_0)
					setActive(arg_32_0, arg_32_0.name == var_31_3)
				end)
				setText(var_31_0:Find("favor/Text"), var_31_2.level)
			end
		end
	})

	if arg_28_1 == 4 then
		setActive(var_28_0:Find("inivite_tip"), PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dRoomInviteSuccess_" .. arg_28_1, 1) == 0)
	end

	setActive(var_28_0:Find("tip"), (function()
		if not var_28_1 or not var_28_1:isPersonalRoom() then
			return false
		end

		return getProxy(ApartmentProxy):HasShipGroupGiftExpireSoon(var_28_1:getConfig("character")[1])
	end)())
end

function SelectDorm3DScene:UpdateShowIcon(arg_34_1, arg_34_2)
	removeOnButton(arg_34_2)
	setActive(arg_34_2:Find("icon/mask"), false)
	eachChild(arg_34_2:Find("front"), function(arg_35_0)
		setActive(arg_35_0, false)
	end)
end

function SelectDorm3DScene:ReplaceSpecialRoomIcon()
	local var_36_0 = {}

	for iter_36_0, iter_36_1 in pairs(getProxy(ApartmentProxy):getRawData()) do
		for iter_36_2, iter_36_3 in ipairs(iter_36_1:getSpecialTalking()) do
			if self.roomDic[pg.dorm3d_dialogue_group[iter_36_3].trigger_config[1]] then
				var_36_0[pg.dorm3d_dialogue_group[iter_36_3].trigger_config[1]] = var_36_0[pg.dorm3d_dialogue_group[iter_36_3].trigger_config[1]] or {}

				table.insert(var_36_0[pg.dorm3d_dialogue_group[iter_36_3].trigger_config[1]], iter_36_3)
			end
		end
	end

	for iter_36_4, iter_36_5 in pairs(var_36_0) do
		setActive(self.roomDic[iter_36_4], false)

		local var_36_1 = cloneTplTo(self.roomDic[iter_36_4], self.roomDic[iter_36_4].parent, self.roomDic[iter_36_4].name .. "_special")

		self:UpdateShowIcon(iter_36_4, var_36_1)
		GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(pg.dorm3d_rooms[iter_36_4].assets_prefix)), "", var_36_1:Find("icon"))
		setActive(var_36_1:Find("front/complete"), true)
		setActive(var_36_1:Find("front/complete/favor"), false)
		eachChild(var_36_1:Find("front/complete/tip"), function(arg_37_0)
			setActive(arg_37_0, arg_37_0.name == "main")
		end)
		table.sort(iter_36_5)

		local var_36_2 = iter_36_5[1]
		local var_36_3 = pg.dorm3d_dialogue_group[iter_36_5[1]]

		if DORM_LOCK_GUIDE and iter_36_5[1] == 10010 then
			return
		end

		onButton(self, var_36_1, function()
			self:TryDownloadResource({
				click = true,
				roomId = var_36_3.room_id
			}, function()
				self:emit(SelectDorm3DMediator.ON_DORM, {
					roomId = var_36_3.room_id,
					groupIds = {
						var_36_3.char_id
					},
					specialId = var_36_2
				})
			end)
		end, SFX_PANEL)
	end
end

function SelectDorm3DScene:DownloadUpdate(arg_40_1, arg_40_2)
	switch(arg_40_2, {
		start = function()
			if self.roomDic[arg_40_1] then
				self:UpdateIconState(arg_40_1)
			end
		end,
		loading = function()
			if self.roomDic[arg_40_1] then
				setSlider(self.roomDic[arg_40_1]:Find("front/loading/progress"), 0, DormGroupConst.DormDownloadLock.totalSize, DormGroupConst.DormDownloadLock.curSize)
			end
		end,
		finish = function()
			DormGroupConst.WithDownloadResourceSnapshot(function()
				for iter_44_0, iter_44_1 in pairs(self.roomDic) do
					self:UpdateIconState(iter_44_0)
				end

				self:CheckGuide("DORM3D_GUIDE_02")
			end)
		end,
		delete = function()
			if self.roomDic[arg_40_1] then
				self:UpdateIconState(arg_40_1)
			end
		end
	})
end

function SelectDorm3DScene:AfterRoomUnlock(arg_46_1)
	local var_46_0 = arg_46_1.roomId

	if isActive(self.rtIconTip) then
		self:HideIconTipWindow()
	end

	eachChild(self.roomDic[arg_46_1.roomId]:Find("icon/mask"), function(arg_47_0)
		setActive(arg_47_0, true)
	end)
	quickPlayAnimation(self.roomDic[arg_46_1.roomId], "anim_Dorm3d_selectDorm_icon_unlock")
	pg.UIMgr.GetInstance():LoadingOn(false)
	LeanTween.delayedCall(1.2333333333333334, System.Action(function()
		pg.UIMgr.GetInstance():LoadingOff(false)
		self:UpdateIconState(var_46_0)
		self:TryDownloadResource(arg_46_1)
		self:CheckGuide("DORM3D_GUIDE_02")
		self:SetMapSwitch()
	end))
end

function SelectDorm3DScene:ShowIconTipWindow(arg_49_1, arg_49_2)
	setLocalPosition(self.rtIconTip:Find("window"), self.rtIconTip:InverseTransformPoint(arg_49_2.position))
	removeAllChildren(self.rtIconTip:Find("window/icon"))

	arg_49_2 = cloneTplTo(arg_49_2, self.rtIconTip:Find("window/icon"))

	self:UpdateShowIcon(arg_49_1, arg_49_2)
	setAnchoredPosition(arg_49_2, Vector2.zero)

	local var_49_0 = ApartmentRoom.New({
		id = arg_49_1
	})
	local var_49_1, var_49_2 = var_49_0:getDownloadNeedSize()

	setText(self.rtIconTip:Find("window/Text"), i18n("dorm3d_role_assets_download", ShipGroup.getDefaultShipNameByGroupID(var_49_0:getPersonalGroupId()), var_49_0:needDownload() and var_49_2 or "0B"))
	onButton(self, self.rtIconTip:Find("window/btn_confirm"), function()
		self:emit(SelectDorm3DMediator.ON_UNLOCK_DORM_ROOM, arg_49_1)
	end, SFX_CONFIRM)
	setActive(self.rtIconTip, true)
end

function SelectDorm3DScene:HideIconTipWindow()
	setActive(self.rtIconTip, false)
end

function SelectDorm3DScene:TryDownloadResource(arg_52_1, arg_52_2)
	if DormGroupConst.IsDownloading() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_now_is_downloading"))

		return
	end

	local var_52_0 = getProxy(ApartmentProxy):getRoom(arg_52_1.roomId)
	local var_52_1 = var_52_0:getDownloadNameList()

	if #var_52_1 > 0 then
		DormGroupConst.DormDownload({
			isShowBox = true,
			fileList = var_52_1,
			finishFunc = function(arg_53_0)
				if arg_53_0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_resource_download_complete"))
				end
			end,
			roomId = var_52_0.configId
		})
	else
		existCall(arg_52_2)
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
	local var_59_0 = getDorm3dGameset("drom3d_weekly_task")[1]
	local var_59_1 = getProxy(TaskProxy):getTaskVO(var_59_0)
	local var_59_2 = var_59_1:isReceive()
	local var_59_3 = var_59_2 and 3 or var_59_1:getProgress()
	local var_59_4 = self.rtWeekTask:Find("content")

	for iter_59_0 = 1, 3 do
		triggerToggle(var_59_4:Find("tpl_" .. iter_59_0), iter_59_0 <= var_59_3)
	end

	local var_59_5 = Drop.Create(var_59_1:getConfig("award_display")[1])

	updateCustomDrop(var_59_4:Find("Dorm3dIconTpl"), var_59_5)
	onButton(self, var_59_4:Find("Dorm3dIconTpl"), function()
		if not var_59_2 and var_59_1:isFinish() then
			self:emit(SelectDorm3DMediator.ON_SUBMIT_TASK, var_59_0)
		else
			self:emit(BaseUI.ON_NEW_DROP, {
				drop = var_59_5
			})
		end
	end, SFX_CONFIRM)
	setActive(var_59_4:Find("Dorm3dIconTpl/get"), not var_59_2 and var_59_1:isFinish())
	setGray(var_59_4:Find("Dorm3dIconTpl"), var_59_2)
	onButton(self, self._tf:Find("Main/task_done"), function()
		setActive(self.rtWeekTask, true)
		setActive(self._tf:Find("Main/task_done"), false)
	end)
	onButton(self, self.rtWeekTask:Find("title"), function()
		if var_59_2 then
			setActive(self.rtWeekTask, false)
			setActive(self._tf:Find("Main/task_done"), true)
		end
	end)
end

function SelectDorm3DScene:CheckGuide(arg_63_1)
	if pg.NewStoryMgr.GetInstance():IsPlayed(arg_63_1) then
		return
	end

	if DORM_LOCK_GUIDE then
		return false
	end

	return switch(arg_63_1, {
		DORM3D_GUIDE_02 = function()
			local var_64_0 = getProxy(ApartmentProxy):getApartment(20220)

			if var_64_0 and not var_64_0:needDownload() then
				pg.m02:sendNotification(GAME.STORY_UPDATE, {
					storyId = arg_63_1
				})
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(1, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_63_1)))
				pg.NewGuideMgr.GetInstance():Play(arg_63_1, nil, function()
					pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(2, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_63_1)))
				end)

				return true
			end
		end,
		DORM3D_GUIDE_06 = function()
			pg.m02:sendNotification(GAME.STORY_UPDATE, {
				storyId = arg_63_1
			})
			pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(1, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_63_1)))
			pg.NewGuideMgr.GetInstance():Play(arg_63_1, nil, function()
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(2, pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_63_1)))
			end)

			return true
		end
	}, function()
		return false
	end)
end

function SelectDorm3DScene:SetMapSwitch()
	local var_69_0 = getProxy(PlayerProxy):getRawData().id

	self.selectedFloorId = PlayerPrefs.GetInt("DORM_SELECTED_FLOOR_ID" .. var_69_0, 1)

	if pg.NewGuideMgr.GetInstance():GetCurrentGuideName() == "DORM3D_GUIDE_01" then
		self.selectedFloorId = 1
	elseif not DORM_LOCK_SELECT_NEW then
		if PlayerPrefs.GetInt("DORM_SELECTED_NEW_ROOM_FLOOR" .. var_69_0 .. pg.dorm3d_set.drom3d_new_room_remind.key_value_int, 0) == 0 then
			self.selectedFloorId = table.indexof(self.floorData, pg.dorm3d_rooms[pg.dorm3d_set.drom3d_new_room_remind.key_value_int].in_map)

			PlayerPrefs.SetInt("DORM_SELECTED_NEW_ROOM_FLOOR" .. var_69_0 .. pg.dorm3d_set.drom3d_new_room_remind.key_value_int, 1)
		end
	end

	local var_69_1 = self._tf:Find("interludeAni")
	local var_69_2 = var_69_1:GetComponent(typeof(Animation))
	local var_69_3 = var_69_1:GetComponent(typeof(DftAniEvent))

	onButton(self, self.rtMain:Find("btn_switch/left"), function()
		var_69_3:SetTriggerEvent(function()
			self:ChangeMap(self.selectedFloorId - 1)
		end)
		var_69_2:Play("anim_InterludeAni")
	end)
	onButton(self, self.rtMain:Find("btn_switch/right"), function()
		var_69_3:SetTriggerEvent(function()
			self:ChangeMap(self.selectedFloorId + 1)
		end)
		var_69_2:Play("anim_InterludeAni")
	end)
	setActive(self.rtMain:Find("btn_switch/switchPanel"), false)

	local var_69_4 = self.rtMain:Find("btn_switch/switchPanel"):GetComponent(typeof(Animation))

	self.rtMain:Find("btn_switch/switchPanel"):GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
		setActive(self.rtMain:Find("btn_switch/switchPanel"), false)
	end)
	onButton(self, self.rtMain:Find("btn_switch/switch"), function()
		setActive(self.rtMain:Find("btn_switch/switchPanel"), true)
	end)
	onButton(self, self.rtMain:Find("btn_switch/switchPanel"), function()
		var_69_4:Play("anim_switchPanel_exit")
	end)

	local var_69_5 = UIItemList.New(self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content"), self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content/floor"))

	var_69_5:make(function(arg_77_0, arg_77_1, arg_77_2)
		if arg_77_0 == UIItemList.EventUpdate then
			local var_77_0 = self.floorData[arg_77_1 + 1]
			local var_77_1 = Clone(pg.dorm3d_rooms.get_id_list_by_in_map[self.floorData[arg_77_1 + 1]])

			for iter_77_0 = #var_77_1, 1, -1 do
				if pg.dorm3d_rooms[var_77_1[iter_77_0]].is_common == 1 then
					table.remove(var_77_1, iter_77_0)
				end
			end

			setActive(arg_77_2:Find("select"), arg_77_1 + 1 == self.selectedFloorId)
			setText(arg_77_2:Find("name"), i18n("dorm3d_room_" .. var_77_0))
			table.sort(var_77_1, CompareFuncs({
				function(arg_78_0)
					local var_78_0 = getProxy(ApartmentProxy):getRoom(arg_78_0)

					return (var_78_0 and var_78_0:getState() or "lock") == "complete" and 0 or 1
				end,
				function(arg_79_0)
					return pg.dorm3d_rooms[arg_79_0].type == 2 and 0 or 1
				end
			}))

			local var_77_2 = UIItemList.New(arg_77_2:Find("rooms"), arg_77_2:Find("rooms/room"))

			var_77_2:make(function(arg_80_0, arg_80_1, arg_80_2)
				if arg_80_0 == UIItemList.EventUpdate then
					local var_80_0 = var_77_1[arg_80_1 + 1]
					local var_80_1 = pg.dorm3d_rooms[var_77_1[arg_80_1 + 1]]
					local var_80_2 = getProxy(ApartmentProxy):getRoom(var_77_1[arg_80_1 + 1])

					setActive(arg_80_2:Find("lock"), (var_80_2 and var_80_2:getState() or "lock") ~= "complete")
					GetImageSpriteFromAtlasAsync(string.format("dorm3dselect/room_icon_%s", string.lower(var_80_1.assets_prefix)), "", arg_80_2:Find("normal/mask/icon"), false)
					setText(arg_80_2:Find("roomId"), var_80_0)
				end
			end)
			var_77_2:align(#var_77_1)
			onButton(self, arg_77_2, function()
				var_69_3:SetTriggerEvent(function()
					self:ChangeMap(arg_77_1 + 1)
				end)
				var_69_2:Play("anim_InterludeAni")
				var_69_4:Play("anim_switchPanel_exit")
			end, SFX_PANEL)
		end
	end)
	var_69_5:align(#self.floorData)
	self:ChangeMap(self.selectedFloorId)
end

function SelectDorm3DScene:ChangeMap(arg_83_1)
	self.selectedFloorId = arg_83_1

	local var_83_0 = getProxy(PlayerProxy):getRawData().id

	PlayerPrefs.SetInt("DORM_SELECTED_FLOOR_ID" .. var_83_0, self.selectedFloorId)
	self:SetFloor(self.floorData[self.selectedFloorId])
	setActive(self.rtMain:Find("btn_switch/left"), self.selectedFloorId > 1)
	setActive(self.rtMain:Find("btn_switch/right"), self.selectedFloorId < #self.floorData)
	setText(self.rtMain:Find("btn_switch/switch/currentName"), i18n("dorm3d_room_" .. self.floorData[self.selectedFloorId]))

	for iter_83_0 = 0, #self.floorData - 1 do
		setActive(self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content"):GetChild(iter_83_0):Find("select"), iter_83_0 + 1 == arg_83_1)
	end

	self.floorTipFlag = {}
	self.floorRoomTipFlag = {}

	for iter_83_1, iter_83_2 in ipairs(self.floorData) do
		local var_83_1 = false
		local var_83_2 = {}

		for iter_83_3, iter_83_4 in ipairs(pg.dorm3d_rooms.get_id_list_by_in_map[iter_83_2]) do
			if pg.dorm3d_rooms[iter_83_4].is_common == 0 then
				var_83_2[iter_83_4] = false

				local var_83_3 = getProxy(ApartmentProxy):getRoom(iter_83_4)
				local var_83_4 = var_83_3 and var_83_3:getState() or "lock"

				if var_83_4 == "complete" and var_83_3:isPersonalRoom() then
					if getProxy(ApartmentProxy):getApartment(var_83_3:getPersonalGroupId()):getIconTip(var_83_3:GetConfigID()) then
						var_83_1 = true
						var_83_2[iter_83_4] = true
					end
				end

				if var_83_4 == "complete" and not var_83_3:isPersonalRoom() then
					var_83_2[iter_83_4] = PlayerPrefs.GetInt(var_83_0 .. "_dorm3dRoomInviteSuccess_" .. iter_83_4, 1) == 0
				end
			end
		end

		table.insert(self.floorTipFlag, var_83_1)
		table.insert(self.floorRoomTipFlag, var_83_2)
	end

	if self.selectedFloorId > 1 then
		setActive(self.rtMain:Find("btn_switch/left/tip"), self.floorTipFlag[self.selectedFloorId - 1])
	end

	if self.selectedFloorId < #self.floorData then
		setActive(self.rtMain:Find("btn_switch/right/tip"), self.floorTipFlag[self.selectedFloorId + 1])
	end

	setActive(self.rtMain:Find("btn_switch/switch/tip"), table.contains(self.floorTipFlag, true))

	for iter_83_5 = 0, self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content").childCount - 1 do
		local var_83_5 = self.rtMain:Find("btn_switch/switchPanel/switchScrollView/Viewport/Content"):GetChild(iter_83_5)

		for iter_83_6 = 0, var_83_5:Find("rooms").childCount - 1 do
			local var_83_6 = var_83_5:Find("rooms"):GetChild(iter_83_6)

			setActive(var_83_6:Find("normal/tip"), self.floorRoomTipFlag[iter_83_5 + 1][tonumber(var_83_6:Find("roomId"):GetComponent(typeof(Text)).text)])
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
