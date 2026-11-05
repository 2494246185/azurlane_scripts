local Dorm3dRoomScene = class("Dorm3dRoomScene", import("view.dorm3d.Dorm3dRoomTemplateScene"))

Dorm3dRoomScene.NOTIFY_UI_STATE = "Dorm3dRoomScene.NOTIFY_UI_STATE"
Dorm3dRoomScene.EXTRA_SET_UI = "Dorm3dRoomScene.EXTRA_SET_UI"
Dorm3dRoomScene.EXTRA_DO_TALK = "Dorm3dRoomScene.EXTRA_DO_TALK"

function Dorm3dRoomScene:getUIName()
	return "Dorm3dMainUI"
end

function Dorm3dRoomScene:SetApartment(arg_2_1)
	self.apartment = arg_2_1

	self:UpdateFavorDisplay()
end

function Dorm3dRoomScene:InitSubViews()
	self.videoPlayer = VoiceChatLoader.New(self._tf)
	self.stockingView = Dorm3dStockingView.New(self._tf, self.event, setmetatable({}, {
		__index = self.contextData
	}))
	self.rtRoleTouchSubView = Dorm3dRTRoleTouchSubView.New(self.rtRole:Find("Touch"), self.event, setmetatable({
		onClick = function(arg_4_0)
			self:emit(RoomTouchSystem.ENTER_TOUCH_MODE, arg_4_0)
		end
	}, {
		__index = self.contextData
	}))
	self.aimIKView = Dorm3dAimIKView.New(self._tf, self.event, setmetatable({}, {
		__index = self.contextData
	}))
	self.ikView = Dorm3dIKView.New(self._tf, self.event, {
		GetApartment = function()
			return self.apartment
		end,
		GetCurrentLadyEnv = function()
			return self:GetCurrentLadyEnv()
		end,
		GetSceneItem = function(arg_7_0)
			return self:GetSceneItem(arg_7_0)
		end,
		GetScreenPosition = function(arg_8_0, arg_8_1)
			return self:GetScreenPosition(arg_8_0, arg_8_1)
		end,
		GetLocalPosition = function(arg_9_0, arg_9_1)
			return self:GetLocalPosition(arg_9_0, arg_9_1)
		end
	})
	self.touchView = Dorm3dTouchView.New(self._tf, self.event, {})
end

function Dorm3dRoomScene:init()
	Dorm3dRoomScene.super.init(self)
	Shader.SetGlobalFloat("_ScreenClipOff", 1)

	self.pendingStateDic = {}
	self.uiContainer = self._tf:Find("UI")

	local var_10_0 = self.uiContainer:Find("base")

	onButton(self, var_10_0:Find("btn_back"), function()
		self:emit(BaseUI.ON_BACK)
	end, SFX_DORM_BACK)
	onButton(self, var_10_0:Find("btn_back/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_dorm3d_info.tip
		})
	end, SFX_PANEL)

	self.rtFavorLevel = var_10_0:Find("top/favor_level")

	setActive(self.rtFavorLevel, self.room:isPersonalRoom())
	onButton(self, self.rtFavorLevel, function()
		self:emit(Dorm3dRoomMediator.OPEN_LEVEL_LAYER, {
			apartment = self.apartment,
			timeIndex = self.contextData.timeIndex,
			baseCamera = self.mainCameraTF,
			roomId = self.room:GetConfigID()
		})
	end, SFX_PANEL)
	onButton(self, var_10_0:Find("top/setting"), function()
		self:emit(Dorm3dRoomMediator.OPEN_SETTING_LAYER)
	end)
	onButton(self, var_10_0:Find("left/btn_photograph"), function()
		if #self.contextData.groupIds == 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("dorm3d_photo_no_role"))

			return
		end

		local var_15_0, var_15_1 = self:CheckSystemOpen("Photo")

		if not var_15_0 then
			pg.TipsMgr.GetInstance():ShowTips(var_15_1)

			return
		end

		if not self.apartment then
			local var_15_2 = self.contextData.groupIds[1]

			for iter_15_0 in pairs(self.ladyDict) do
				if self:GetLadyBaseZone(iter_15_0) == self:GetCurrentZoneNodeName() then
					var_15_2 = iter_15_0

					break
				end
			end

			self:SetApartment(getProxy(ApartmentProxy):getApartment(var_15_2))
		end

		getProxy(Dorm3dChatProxy):TriggerEvent({
			{
				value = 1,
				event_type = self.contextData.timeIndex == 1 and 114 or 119,
				ship_id = self.apartment:GetConfigID()
			}
		})
		self:OutOfLazy(self.apartment:GetConfigID(), function()
			self.emit(self, Dorm3dRoomMediator.OPEN_CAMERA_LAYER, self, self.apartment:GetConfigID())
		end)
	end, SFX_PANEL)
	onButton(self, var_10_0:Find("left/btn_collection"), function()
		local var_17_0, var_17_1 = self:CheckSystemOpen("Collection")

		if not var_17_0 then
			pg.TipsMgr.GetInstance():ShowTips(var_17_1)

			return
		end

		setActive(var_10_0:Find("left/btn_collection/tip"), false)
		PlayerPrefs.SetInt("apartment_collection_item", 0)
		PlayerPrefs.SetInt("apartment_collection_recall", 0)
		self:emit(Dorm3dRoomMediator.OPEN_COLLECTION_LAYER, self.room:GetConfigID())
	end, SFX_PANEL)
	onButton(self, var_10_0:Find("left/btn_furniture"), function()
		local var_18_0, var_18_1 = self:CheckSystemOpen("Furniture")

		if not var_18_0 then
			pg.TipsMgr.GetInstance():ShowTips(var_18_1)

			return
		end

		self:RemoveExtraSystem({
			SlideExtraSystem
		})
		self:emit(Dorm3dRoomMediator.OPEN_FURNITURE_SELECT, {
			apartment = self.apartment
		})

		self.isInFurnitureSelect = true
	end, SFX_PANEL)

	if not self.room:isPersonalRoom() then
		local var_10_1 = self:CheckSystemOpen("Furniture")

		setActive(var_10_0:Find("left/line_furniture"), var_10_1)
		setActive(var_10_0:Find("left/btn_furniture"), var_10_1)
	end

	onButton(self, var_10_0:Find("left/btn_accompany"), function()
		local var_19_0, var_19_1 = self:CheckSystemOpen("Accompany")

		if not var_19_0 then
			pg.TipsMgr.GetInstance():ShowTips(var_19_1)

			return
		end

		local var_19_2 = self.apartment:GetConfigID()
		local var_19_3

		self:emit(Dorm3dRoomMediator.OPEN_ACCOMPANY_WINDOW, {
			groupId = var_19_2,
			confirmFunc = function(arg_20_0)
				var_19_3 = arg_20_0
			end
		}, function()
			if var_19_3 then
				self:OutOfLazy(var_19_2, function()
					self:EnterAccompanyMode(var_19_3)
				end)
			else
				self:CheckQueue()
			end
		end)
	end, SFX_PANEL)

	if not self.room:isPersonalRoom() then
		setActive(var_10_0:Find("left/line_accompany"), false)
		setActive(var_10_0:Find("left/btn_accompany"), false)
	end

	onButton(self, var_10_0:Find("left/btn_skin"), function()
		self:ActiveCamera(self.cameras[Dorm3dRoomScene.CAMERA.SKIN])
		self:emit(Dorm3dRoomMediator.OPEN_SKIN_SELECT_LAYER, self.apartment:GetConfigID(), self:GetCurrentLadyEnv(), nil, function()
			self:ChangePlayerPosition()
			self:ActiveCamera(self.cameras[Dorm3dRoomScene.CAMERA.POV])
		end, false)
	end)

	if not self.room:isPersonalRoom() then
		setActive(var_10_0:Find("left/line_skin"), false)
		setActive(var_10_0:Find("left/btn_skin"), false)
	end

	onButton(self, var_10_0:Find("left/btn_invite"), function()
		self:emit(Dorm3dRoomMediator.OPEN_INVITE_WINDOW, self.room:GetConfigID(), underscore.to_array(self.contextData.groupIds))
	end, SFX_PANEL)

	if self.room:isPersonalRoom() then
		setActive(var_10_0:Find("left/line_invite"), false)
		setActive(var_10_0:Find("left/btn_invite"), false)
	end

	self.btnZone = var_10_0:Find("right/Zone")
	self.rtZoneList = var_10_0:Find("right/Zone/List")

	setActive(self.rtZoneList, false)
	onButton(self, self.btnZone, function()
		setActive(self.rtZoneList, not isActive(self.rtZoneList))
	end, SFX_PANEL)
	UIItemList.StaticAlign(self.rtZoneList, self.rtZoneList:GetChild(0), #self.zoneDatas, function(arg_27_0, arg_27_1, arg_27_2)
		if arg_27_0 ~= UIItemList.EventUpdate then
			return
		end

		arg_27_1 = arg_27_1 + 1

		local var_27_0 = self.zoneDatas[arg_27_1]:GetWatchCameraName()

		arg_27_2.name = var_27_0

		setText(arg_27_2:Find("Name"), self.zoneDatas[arg_27_1]:GetName())
		setActive(arg_27_2:Find("Line"), arg_27_1 < #self.zoneDatas)
		onButton(self, arg_27_2, function()
			if self.uiState ~= "base" then
				return
			end

			setActive(self.rtZoneList, false)
			self:ShiftZoneSafe(var_27_0)
		end, SFX_PANEL)
	end)
	onButton(self, self.uiContainer:Find("accompany"):Find("btn_back"), function()
		self:ExitAccompanyMode()
	end, SFX_DORM_BACK)

	self.unlockList = {}
	self.rtFavorUp = self._tf:Find("Toast/favor_up")

	self.rtFavorUp:GetComponent("DftAniEvent"):SetEndEvent(function(arg_30_0)
		setActive(self.rtFavorUp, false)

		if #self.unlockList > 0 then
			setText(self.rtFavorUp:Find("Text"), table.remove(self.unlockList, 1))
			setActive(self.rtFavorUp, true)
		end
	end)
	setActive(self.rtFavorUp, false)

	self.rtFavorUpDaily = self._tf:Find("Toast/favor_up_daily")

	setActive(self.rtFavorUpDaily, false)

	self.rtStaminaPop = self._tf:Find("Toast/stamina")

	local var_10_2 = self.rtStaminaPop:GetComponent("DftAniEvent")

	var_10_2:SetTriggerEvent(function(arg_31_0)
		local var_31_0, var_31_1 = getProxy(ApartmentProxy):getStamina()

		setText(self.rtStaminaPop:Find("Text"), string.format("%d/%d", var_31_0, var_31_1))
	end)
	var_10_2:SetEndEvent(function(arg_32_0)
		setActive(self.rtStaminaPop, false)
	end)
	setActive(self.rtStaminaPop, false)

	self.rtLevelUpWindow = self._tf:Find("LevelUpWindow")

	setActive(self.rtLevelUpWindow, false)
	onButton(self, self.rtLevelUpWindow:Find("bg"), function()
		if self.isLock then
			return
		end

		self.isLock = true

		quickPlayAnimation(self.rtLevelUpWindow, "anim_dorm3d_levelup_out")
		LeanTween.delayedCall(0.2, System.Action(function()
			self.isLock = false

			setActive(self.rtLevelUpWindow, false)
			self:UnOverlayPanel(self.rtLevelUpWindow, self._tf)
			existCall(self.levelUpCallback)
		end))
	end, SFX_PANEL)

	local var_10_3 = self.uiContainer:Find("watch")

	onButton(self, var_10_3:Find("btn_back"), function()
		self:ExitWatchMode()
	end, SFX_DORM_BACK)
	onButton(self, var_10_3:Find("btn_back/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("roll_gametip")
		})
	end, SFX_PANEL)

	self.rtStaminaDisplay = var_10_3:Find("stamina")
	self.rtRole = self.uiContainer:Find("watch/Role")

	onButton(self, self.rtRole:Find("Talk"), function()
		local var_37_0 = self.apartment:getFurnitureTalking(self.room:GetConfigID(), (self:GetLadyBaseZone(self.apartment:GetConfigID())))

		if #var_37_0 == 0 then
			pg.TipsMgr.GetInstance():ShowTips("without topic")

			return
		end

		self:DoTalk(var_37_0[math.random(#var_37_0)], function()
			self:emit(Dorm3dRoomMediator.TRIGGER_FAVOR, self.apartment.configId, getDorm3dGameset("drom3d_favir_trigger_talk")[1])
		end)
	end, SFX_DORM_CLICK)
	setText(self.rtRole:Find("Talk/bg/Text"), i18n("dorm3d_talk"))
	onButton(self, self.rtRole:Find("Gift"), function()
		self:emit(self.SHOW_BLOCK)
		self:ActiveStateCamera("gift", function()
			self:emit(self.HIDE_BLOCK)
		end)
		self:emit(Dorm3dRoomMediator.OPEN_GIFT_LAYER, {
			groupId = self.apartment:GetConfigID(),
			baseCamera = self.mainCameraTF
		})
	end, SFX_DORM_CLICK)
	setText(self.rtRole:Find("Gift/bg/Text"), i18n("dorm3d_gift"))
	onButton(self, self.rtRole:Find("MiniGame"), function()
		assert(not self.nowMiniGameId)

		self.nowMiniGameId = self.room:getMiniGames()[1]

		local var_41_0 = pg.dorm3d_minigame[self.nowMiniGameId]
		local var_41_1 = self:GetCurrentLadyEnv()

		getProxy(Dorm3dChatProxy):TriggerEvent({
			{
				value = 1,
				event_type = self.contextData.timeIndex == 1 and 112 or 117,
				ship_id = self.apartment:GetConfigID()
			},
			{
				value = 1,
				event_type = 158,
				ship_id = self.apartment:GetConfigID()
			}
		})

		local var_41_2 = {}

		table.insert(var_41_2, function(arg_42_0)
			self:SetAllBlackbloardValue("inLockLayer", true)
			self:TempHideUI(true, arg_42_0)
		end)

		if var_41_0.area ~= "" and self:GetLadyBaseZone(self.apartment:GetConfigID()) ~= var_41_0.area then
			table.insert(var_41_2, function(arg_43_0)
				self:ShiftZone(var_41_0.area, arg_43_0)
			end)
		end

		local var_41_3
		local var_41_4

		if var_41_0.action ~= "" then
			var_41_3, var_41_4 = unpack(var_41_0.action)
		end

		table.insert(var_41_2, function(arg_44_0)
			parallelAsync({
				function(arg_45_0)
					if var_41_3 then
						self:PlaySingleAction(var_41_1, var_41_3, arg_45_0)
					else
						arg_45_0()
					end
				end,
				function(arg_46_0)
					self:ActiveStateCamera("talk", arg_46_0)
				end
			}, arg_44_0)
		end)
		table.insert(var_41_2, function(arg_47_0)
			pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataMiniGame(1))
			self:HandleGameNotification(Dorm3dMiniGameMediator.OPERATION, {
				operationCode = "BEFORE_OPEN_GAME",
				miniGameId = self.nowMiniGameId
			})
			self:EnableMiniGameCutIn()
			self:emit(Dorm3dRoomMediator.OPEN_MINIGAME_WINDOW, {
				isDorm3d = true,
				minigameId = self.nowMiniGameId
			}, arg_47_0)
		end)
		table.insert(var_41_2, function(arg_48_0)
			self:DisableMiniGameCutIn()

			if var_41_4 then
				self:PlaySingleAction(var_41_1, var_41_4, arg_48_0)
			else
				arg_48_0()
			end
		end)
		seriesAsync(var_41_2, function()
			self:SetAllBlackbloardValue("inLockLayer", false)
			self:TempHideUI(false)

			self.nowMiniGameId = nil
		end)
	end, SFX_DORM_CLICK)
	setText(self.rtRole:Find("MiniGame/bg/Text"), i18n("dorm3d_minigame_button1"))

	if not self.room:isPersonalRoom() then
		onButton(self, self.rtRole:Find("PublicGame"), switch(self.room.id, {
			[4] = function()
				return function()
					self:emit(Dorm3dRoomMediator.ENTER_VOLLEYBALL, self.apartment:GetConfigID())
				end
			end,
			[16] = function()
				return function()
					self:emit(Dorm3dRoomMediator.ENTER_DANCE, self.apartment:GetConfigID())
				end
			end,
			[26] = function()
				return function()
					self:emit(Dorm3dRoomMediator.ENTER_CARWASH, self.apartment:GetConfigID())
				end
			end
		}), SFX_DORM_CLICK)
		setText(self.rtRole:Find("PublicGame/bg/Text"), switch(self.room.id, {
			[4] = function()
				return i18n("dorm3d_volleyball_button")
			end,
			[16] = function()
				return i18n("dorm3d_dance_button")
			end,
			[26] = function()
				return i18n("dorm3d_carwash_button")
			end
		}))
	end

	onButton(self, self.rtRole:Find("Performance"), function()
		self:DoTalk(20500, function()
			pg.TipsMgr.GetInstance():ShowTips("Success!")
		end)
	end, SFX_DORM_CLICK)

	self.rtFloatPage = self._tf:Find("FloatPage")
	self.tplFloat = self.rtFloatPage:Find("tpl")

	setActive(self.tplFloat, false)
	eachChild(cloneTplTo(self.tplFloat, self.rtFloatPage, "lady"), function(arg_61_0)
		setActive(arg_61_0, arg_61_0.name == "walk")
	end)

	self._joystick = self._tf:Find("Stick")

	setActive(self._joystick, false)
	self._joystick:GetComponent(typeof(SlideController)):SetStickFunc(function(arg_62_0)
		self:emit(self.ON_STICK_MOVE, arg_62_0)
	end)

	self.povLayer = self._tf:Find("POVControl")

	setActive(self.povLayer, false)
	;(function()
		local var_63_0 = self.povLayer:Find("Move"):GetComponent(typeof(SlideController))

		var_63_0:AddBeginDragFunc(function(arg_64_0, arg_64_1)
			self:emit(self.ON_POV_STICK_MOVE_BEGIN, arg_64_1)
		end)
		var_63_0:SetStickFunc(function(arg_65_0)
			self:emit(self.ON_POV_STICK_MOVE, arg_65_0)
		end)
		var_63_0:AddDragEndFunc(function(arg_66_0, arg_66_1)
			self:emit(self.ON_POV_STICK_MOVE_END, arg_66_1)
		end)
		self.povLayer:Find("View"):GetComponent(typeof(SlideController)):SetStickFunc(function(arg_67_0)
			self:emit(self.ON_POV_STICK_VIEW, arg_67_0)
		end)
	end)()

	self.rtExtraScreen = self._tf:Find("ExtraScreen")
	self.rtTimelineScreen = self.rtExtraScreen:Find("TimelineScreen")

	onButton(self, self.rtTimelineScreen:Find("btn_skip"), function()
		existCall(self.timelineFinishCall)
	end, SFX_CANCEL)
	self:InitSubViews()

	self.uiStack = {}
	self.uiStore = {}
end

function Dorm3dRoomScene:BindEvent()
	Dorm3dRoomScene.super.BindEvent(self)
	self:bind(Dorm3dRoomScene.EXTRA_SET_UI, function(arg_70_0, arg_70_1, ...)
		self:SetUI(arg_70_1, ...)
	end)
	self:bind(Dorm3dRoomScene.EXTRA_DO_TALK, function(arg_71_0, arg_71_1, arg_71_2)
		self:DoTalk(arg_71_1, arg_71_2)
	end)
	self:bind(self.CLICK_CHARACTER, function(arg_72_0, arg_72_1)
		if self.uiState ~= "base" or not self.ladyDict[arg_72_1].nowCanWatchState then
			return
		end

		local var_72_0 = {}

		if self:GetBlackboardValue(self.ladyDict[arg_72_1], "inPending") then
			table.insert(var_72_0, function(arg_73_0)
				self:OutOfPending(arg_72_1, arg_73_0)
			end)
		else
			table.insert(var_72_0, function(arg_74_0)
				self:OutOfLazy(arg_72_1, arg_74_0)
			end)
		end

		seriesAsync(var_72_0, function()
			if not self.room:isPersonalRoom() then
				self:SetApartment(getProxy(ApartmentProxy):getApartment(arg_72_1))
			end

			self:EnterWatchMode()
		end)
		pg.CriMgr.GetInstance():PlaySE_V3("ui-dorm_touch_v1")
	end)
	self:bind(self.DISTANCE_TRIGGER, function(arg_76_0, arg_76_1, arg_76_2)
		if self.uiState == "base" then
			self:CheckDistanceTalk(arg_76_1, arg_76_2)
		end
	end)
	self:bind(self.WALK_DISTANCE_TRIGGER, function(arg_77_0, arg_77_1, arg_77_2)
		if self.apartment and self.apartment:GetConfigID() == arg_77_1 then
			existCall(self.walkNearCallback, arg_77_2)
		end
	end)
	self:bind(self.CHANGE_WATCH, function(arg_78_0, arg_78_1)
		self:ChangeCanWatchState(self.ladyDict[arg_78_1])
	end)
	self:bind(self.ON_ENTER_SECTOR, function(arg_79_0, arg_79_1)
		self:ChangeCanWatchState(self.ladyDict[arg_79_1])
	end)
	self:bind(self.ON_CHANGE_DISTANCE, function(arg_80_0, arg_80_1, arg_80_2)
		self:ChangeCanWatchState(self.ladyDict[arg_80_1])
	end)
end

function Dorm3dRoomScene:didEnter()
	self.resumeCallback = self.contextData.resumeCallback
	self.contextData.resumeCallback = nil

	Dorm3dRoomScene.super.didEnter(self)
	self:UpdateZoneList()
	self:SetUI(function()
		self:didEnterCheck()
	end, "base")
end

function Dorm3dRoomScene:FinishEnterResume()
	if not self.resumeCallback then
		return
	end

	self.resumeCallback = nil

	return self.resumeCallback()
end

function Dorm3dRoomScene:EnableJoystick(arg_84_1)
	setActive(self._joystick, arg_84_1)
end

function Dorm3dRoomScene:EnablePOVLayer(arg_85_1)
	setActive(self.povLayer, arg_85_1)

	if not arg_85_1 then
		self:emit(self.ON_POV_STICK_MOVE_END)
	end
end

function Dorm3dRoomScene:SetUIStore(arg_86_1, ...)
	table.insertto(self.uiStore, {
		...
	})
	existCall(arg_86_1)
end

function Dorm3dRoomScene:SetUI(arg_87_1, ...)
	warning("SetUI", ...)

	while rawget(self, "class") ~= Dorm3dRoomScene do
		self = getmetatable(self).__index
	end

	table.insertto(self.uiStore, {
		...
	})

	for iter_87_0, iter_87_1 in ipairs(self.uiStore) do
		if iter_87_1 == "back" then
			assert(#self.uiStack > 0)

			self.uiState = table.remove(self.uiStack)
		elseif iter_87_1 == self.uiState and iter_87_1 == "ik" then
			-- block empty
		else
			table.insert(self.uiStack, self.uiState)

			self.uiState = iter_87_1
		end
	end

	pg.m02:sendNotification(Dorm3dRoomScene.NOTIFY_UI_STATE, self.uiState)

	self.uiStore = {}

	eachChild(self.uiContainer, function(arg_88_0)
		setActive(arg_88_0, arg_88_0.name == self.uiState)
	end)
	self:EnablePOVLayer(self.uiState == "base" or self.uiState == "walk")
	self:SetFloatEnable(self.uiState == "walk")
	setActive(self.rtFloatPage, self.uiState == "walk")

	if self.uiState ~= "stocking" then
		self.stockingView:Hide()
	end

	warning("SetUI to ", self.uiState)
	switch(self.uiState, {
		base = function()
			if not self.room:isPersonalRoom() then
				self:SetApartment(nil)
			end

			self:UpdateBtnState()
		end,
		watch = function()
			eachChild(self.rtRole, function(arg_91_0)
				setActive(arg_91_0, false)
			end)

			for iter_90_0, iter_90_1 in ipairs((underscore.filter({
				"Talk",
				"Touch",
				"Gift",
				"MiniGame",
				"PublicGame",
				"Performance"
			}, function(arg_92_0)
				return self:CheckSystemOpen(arg_92_0)
			end))) do
				LeanTween.delayedCall(0.05, System.Action(function()
					setActive(self.rtRole:Find(iter_90_1), true)

					if iter_90_1 == "Touch" then
						local var_93_0 = self.apartment:GetConfigID()

						self.rtRoleTouchSubView:Flush(self.room, var_93_0, self:GetLadyBaseZone(var_93_0))
					end
				end))
			end

			local var_90_1 = self.apartment:GetConfigID()
			local var_90_2 = Dorm3dGift.NeedViewTip(var_90_1)

			var_90_2 = var_90_2 or getProxy(ApartmentProxy):HasShipGroupGiftExpireSoon(var_90_1)

			setActive(self.rtRole:Find("Gift/bg/Tip"), var_90_2)
		end,
		ik = function()
			self:emit(Dorm3dIKView.RESET_ENTRY_MENU, self.room:isPersonalRoom() and not self.performanceInfo)
		end,
		walk = function()
			setText(self.uiContainer:Find("walk/dialogue/content"), i18n("dorm3d_removable", self.apartment:getConfig("name")))
		end,
		stocking = function()
			self.stockingView:Show()
		end
	})
	self:ActiveStateCamera(self.uiState, function()
		if arg_87_1 then
			arg_87_1()
		elseif self.uiState == "base" then
			self:CheckQueue()
		end
	end)
end

function Dorm3dRoomScene:EnterWatchMode()
	local var_98_0 = self.apartment:GetConfigID()

	seriesAsync({
		function(arg_99_0)
			self:emit(self.SHOW_BLOCK)
			self:SetBlackboardValue(self.ladyDict[var_98_0], "inWatchMode", true)
			self:SetUI(arg_99_0, "watch")
		end,
		function(arg_100_0)
			self:emit(self.HIDE_BLOCK)
		end
	})
end

function Dorm3dRoomScene:ExitWatchMode()
	local var_101_0 = self.apartment:GetConfigID()

	seriesAsync({
		function(arg_102_0)
			self:emit(self.SHOW_BLOCK)
			self:SetUI(arg_102_0, "back")
		end,
		function(arg_103_0)
			self:SetBlackboardValue(self.ladyDict[var_101_0], "inWatchMode", false)
			self:emit(self.HIDE_BLOCK)
			self:CheckQueue()
		end
	})
end

function Dorm3dRoomScene:SetInPending(arg_104_1, arg_104_2)
	local var_104_0 = self:GetBlackboardValue(arg_104_1, "groupId")
	local var_104_1 = pg.dorm3d_welcome[arg_104_2]

	self:SetBlackboardValue(arg_104_1, "inPending", true)
	self:ChangeCanWatchState(arg_104_1)
	self:EnableHeadIK(arg_104_1, false)

	self.contextData.ladyZone[var_104_0] = pg.dorm3d_welcome[arg_104_2].area

	self:SetLadyActiveZone(var_104_0, pg.dorm3d_welcome[arg_104_2].welcome_staypoint)
	self:ChangeCharacterPosition(arg_104_1)

	local var_104_2 = self.pendingStateDic[var_104_0]

	if not self.pendingStateDic[var_104_0] then
		var_104_2 = {
			hideItems = {}
		}
		self.pendingStateDic[var_104_0] = var_104_2
	end

	local var_104_3 = var_104_2.hideItems

	if pg.dorm3d_welcome[arg_104_2].item_shield ~= "" then
		for iter_104_0, iter_104_1 in ipairs(pg.dorm3d_welcome[arg_104_2].item_shield) do
			local var_104_4 = self.modelRoot:Find(iter_104_1)

			if not var_104_4 then
				warning(string.format("welcome:%d without hide item:%s", arg_104_2, iter_104_1))
			else
				if var_104_3[iter_104_1] == nil then
					local var_104_5 = isActive(var_104_4)

					for iter_104_2, iter_104_3 in pairs(self.pendingStateDic) do
						if iter_104_2 ~= var_104_0 and iter_104_3.hideItems[iter_104_1] ~= nil then
							var_104_5 = iter_104_3.hideItems[iter_104_1]

							break
						end
					end

					var_104_3[iter_104_1] = var_104_5
				end

				setActive(var_104_4, false)
			end
		end
	end

	onNextTick(function()
		if arg_104_1.tfPendintItem then
			setActive(arg_104_1.tfPendintItem, true)
		end

		self:SwitchAnim(arg_104_1, var_104_1.welcome_idle)
	end)

	var_104_2.talkId = pg.dorm3d_welcome[arg_104_2].welcome_talk
end

function Dorm3dRoomScene:SetOutPending(arg_106_1)
	local var_106_0 = self:GetBlackboardValue(arg_106_1, "groupId")

	self:SetBlackboardValue(arg_106_1, "inPending", false)
	self:ChangeCanWatchState(arg_106_1)
	self:EnableHeadIK(arg_106_1, true)

	if arg_106_1.tfPendintItem then
		setActive(arg_106_1.tfPendintItem, false)
	end

	if self.pendingStateDic[var_106_0] and self.pendingStateDic[var_106_0].hideItems then
		for iter_106_0, iter_106_1 in pairs(self.pendingStateDic[var_106_0] and self.pendingStateDic[var_106_0].hideItems) do
			local var_106_1 = false

			for iter_106_2, iter_106_3 in pairs(self.pendingStateDic) do
				if iter_106_2 ~= var_106_0 and iter_106_3.hideItems[iter_106_0] ~= nil then
					var_106_1 = true

					break
				end
			end

			if not var_106_1 then
				setActive(self.modelRoot:Find(iter_106_0), iter_106_1)
			end
		end
	end

	self.pendingStateDic[var_106_0] = nil
end

function Dorm3dRoomScene:IsModeInHidePending(arg_107_1)
	for iter_107_0, iter_107_1 in pairs(self.pendingStateDic) do
		if iter_107_1.hideItems[arg_107_1] ~= nil then
			return true
		end
	end

	return false
end

function Dorm3dRoomScene:EnterAccompanyMode(arg_108_1)
	local var_108_0 = pg.dorm3d_accompany[arg_108_1]
	local var_108_1
	local var_108_2

	if pg.dorm3d_accompany[arg_108_1].sceneInfo ~= "" then
		var_108_1, var_108_2 = unpack(string.split(pg.dorm3d_accompany[arg_108_1].sceneInfo, "|"))
	end

	local var_108_3 = {
		type = "timeline",
		name = pg.dorm3d_accompany[arg_108_1].timeline,
		scene = var_108_1,
		sceneRoot = var_108_2,
		accompanys = {}
	}

	for iter_108_0, iter_108_1 in ipairs(pg.dorm3d_accompany[arg_108_1].jump_trigger) do
		local var_108_4, var_108_5 = unpack(iter_108_1)

		var_108_3.accompanys[var_108_4] = var_108_5
	end

	local var_108_6, var_108_7 = unpack(pg.dorm3d_accompany[arg_108_1].favor)

	getProxy(Dorm3dChatProxy):TriggerEvent({
		{
			value = 1,
			event_type = 161,
			ship_id = self.apartment:GetConfigID()
		}
	})
	getProxy(ApartmentProxy):RecordAccompanyTime()
	pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataAccompany(1, pg.dorm3d_accompany[arg_108_1].ship_id, pg.dorm3d_accompany[arg_108_1].performance_time, 0, var_108_1 or self.dormSceneMgr.artSceneInfo))

	local var_108_8 = {}

	table.insert(var_108_8, function(arg_109_0)
		self:SetUI(arg_109_0, "blank", "accompany")
	end)
	table.insert(var_108_8, function(arg_110_0)
		self.accompanyFavorCount = 0
		self.accompanyFavorTimer = Timer.New(function()
			self.accompanyFavorCount = self.accompanyFavorCount + 1
		end, var_108_6, -1)

		self.accompanyFavorTimer:Start()

		self.accompanyPerformanceTimer = Timer.New(function()
			self.canTriggerAccompanyPerformance = true
		end, var_108_0.performance_time, -1)

		self.accompanyPerformanceTimer:Start()
		self:PlayTimeline(var_108_3, function(arg_113_0, arg_113_1)
			arg_113_1()
			arg_110_0()
		end)
	end)
	seriesAsync(var_108_8, function()
		assert(self.accompanyFavorTimer)
		self.accompanyFavorTimer:Stop()

		self.accompanyFavorTimer = nil

		assert(self.accompanyPerformanceTimer)
		self.accompanyPerformanceTimer:Stop()

		self.accompanyPerformanceTimer = nil
		self.canTriggerAccompanyPerformance = nil

		local var_114_0 = math.min(self.accompanyFavorCount, getProxy(ApartmentProxy):getStamina())

		if var_114_0 > 0 then
			warning(var_108_7[var_114_0])
			self:emit(Dorm3dRoomMediator.TRIGGER_FAVOR, self.apartment.configId, var_108_7[var_114_0])
		end

		local var_114_2 = getProxy(ApartmentProxy):GetAccompanyTime()

		pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataAccompany(2, var_108_0.ship_id, var_108_0.performance_time, (var_114_2 or nil) and pg.TimeMgr.GetInstance():GetServerTime() - var_114_2, var_108_1 or self.dormSceneMgr.artSceneInfo))
		self:SetUI(nil, "back", "back")
	end)
end

function Dorm3dRoomScene:ExitAccompanyMode()
	existCall(self.timelineFinishCall)
end

function Dorm3dRoomScene:EnterTouchPerformance()
	local var_116_0 = self.room:getApartmentZoneConfig(self:GetLadyBaseZone(self.apartment:GetConfigID()), "touch_performance", self.apartment:GetConfigID())

	if not var_116_0 or var_116_0 == 0 then
		self:emit(RoomTouchSystem.ENTER_TOUCH_MODE)
	else
		self:DoTalk(var_116_0)
	end
end

function Dorm3dRoomScene:ChangeWalkScene(arg_117_1, arg_117_2, arg_117_3)
	local var_117_0 = self:GetCurrentLadyEnv()

	seriesAsync({
		function(arg_118_0)
			self:ChangeArtScene(arg_117_2, arg_118_0)
		end,
		function(arg_119_0)
			self:ChangeSubScene(arg_117_2, arg_119_0)
		end,
		function(arg_120_0)
			self:emit(self.SHOW_BLOCK)

			if arg_117_1 == "back" then
				self:SetUI(arg_120_0, "back")
			elseif arg_117_1 == "change" and self.uiState ~= "walk" then
				self:SetUI(arg_120_0, "walk")
			else
				arg_120_0()
			end
		end
	}, function()
		self:emit(self.HIDE_BLOCK)
		self:SetBlackboardValue(var_117_0, "inWalk", arg_117_1 == "change")
		existCall(arg_117_3)
	end)
end

function Dorm3dRoomScene:EnterWalkMode()
	local var_122_0 = self.apartment:GetConfigID()
	local var_122_1 = self.ladyDict[var_122_0]

	seriesAsync({
		function(arg_123_0)
			self:emit(self.SHOW_BLOCK)
			self:HideCharacter(var_122_0)
			self:SetBlackboardValue(var_122_1, "inWalk", true)
			self:SetUI(arg_123_0, "walk")
		end,
		function(arg_124_0)
			self:emit(self.HIDE_BLOCK)
			self:ChangeArtScene(self.walkInfo.scene .. "|" .. self.walkInfo.sceneRoot, arg_124_0)
		end,
		function(arg_125_0)
			self:LoadSubScene(self.walkInfo, arg_125_0)
		end
	}, function()
		return
	end)
end

function Dorm3dRoomScene:ExitWalkMode()
	local var_127_0 = self.apartment:GetConfigID()
	local var_127_1 = self.ladyDict[var_127_0]

	seriesAsync({
		function(arg_128_0)
			self:RevertArtScene(self.walkLastSceneInfo, arg_128_0)
		end,
		function(arg_129_0)
			self:UnloadSubScene(self.walkInfo, arg_129_0)
		end,
		function(arg_130_0)
			self:emit(self.SHOW_BLOCK)
			self:SetUI(arg_130_0, "back")
		end
	}, function()
		self:emit(self.HIDE_BLOCK)
		self:RevertCharacter(var_127_0)
		self:SetBlackboardValue(var_127_1, "inWalk", false)

		self.walkExitCall = nil
		self.walkLastSceneInfo = nil
		self.walkInfo = nil

		existCall(self.walkExitCall)
	end)
end

function Dorm3dRoomScene:EnableMiniGameCutIn()
	if not self.tfCutIn then
		return
	end

	local var_132_0 = self.rtExtraScreen:Find("MiniGameCutIn")

	setActive(var_132_0, true)

	local var_132_1 = GetOrAddComponent(var_132_0:Find("bg/mask/cut_in"), "CameraRTUI")

	setActive(var_132_1, true)
	pg.CameraRTMgr.GetInstance():Bind(var_132_1, self.tfCutIn:Find("TestCamera"):GetComponent(typeof(Camera)))
	quickPlayAnimator(self.modelCutIn.lady, "Idle")
	quickPlayAnimator(self.modelCutIn.player, "Idle")
	setActive(self.tfCutIn, true)
end

function Dorm3dRoomScene:DisableMiniGameCutIn()
	if not self.tfCutIn then
		return
	end

	local var_133_0 = self.rtExtraScreen:Find("MiniGameCutIn")

	pg.CameraRTMgr.GetInstance():Clean((GetOrAddComponent(var_133_0:Find("bg/mask/cut_in"), "CameraRTUI")))
	setActive(var_133_0, false)
	setActive(self.tfCutIn, false)
end

function Dorm3dRoomScene:DoTalk(arg_134_1, arg_134_2)
	while rawget(self, "class") ~= Dorm3dRoomScene do
		self = getmetatable(self).__index
	end

	if self.apartment and self:GetBlackboardValue(self:GetCurrentLadyEnv(), "inTalking") then
		errorMsg("Talking block:" .. arg_134_1)

		return
	end

	if not self.room:isPersonalRoom() then
		local var_134_0 = pg.dorm3d_dialogue_group[arg_134_1].char_id

		if self.apartment then
			assert(self.apartment:GetConfigID() == var_134_0)
		else
			self:SetApartment(getProxy(ApartmentProxy):getApartment(var_134_0))
		end
	end

	local var_134_1 = self:GetCurrentLadyEnv()

	if arg_134_1 == 10010 and not self.apartment.talkDic[arg_134_1] then
		self.firstTimelineTouch = true
		self.firstMoveGuide = true
	end

	getProxy(Dorm3dChatProxy):TriggerEvent({
		{
			value = 1,
			event_type = self.contextData.timeIndex == 1 and 110 or 115,
			ship_id = self.apartment:GetConfigID()
		},
		{
			value = 1,
			event_type = 155,
			ship_id = self.apartment:GetConfigID()
		}
	})

	local var_134_2 = {}

	if self:GetBlackboardValue(var_134_1, "inPending") then
		table.insert(var_134_2, function(arg_135_0)
			self:OutOfLazy(self.apartment:GetConfigID(), arg_135_0)
		end)
	end

	local var_134_3 = pg.dorm3d_dialogue_group[arg_134_1]
	local var_134_4 = pg.dorm3d_dialogue_group[arg_134_1].performance_type == 1
	local var_134_5

	table.insert(var_134_2, function(arg_136_0)
		self:emit(self.SHOW_BLOCK)
		self:SetBlackboardValue(var_134_1, var_134_4 and "inPerformance" or "inTalking", true)
		self:emit(Dorm3dRoomMediator.DO_TALK, arg_134_1, function(arg_137_0)
			var_134_5 = arg_137_0

			arg_136_0()
		end)
	end)
	table.insert(var_134_2, function(arg_138_0)
		pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataDialog(self.apartment.configId, self.apartment.level, arg_134_1, var_134_3.type, self.room:getZoneConfig(self:GetLadyBaseZone(self.apartment:GetConfigID()), "id"), var_134_3.action_type, table.CastToString(var_134_3.trigger_config), self.room:GetConfigID()))

		if pg.NewGuideMgr.GetInstance():IsBusy() then
			pg.NewGuideMgr.GetInstance():Pause()
		end

		self:SetUI(arg_138_0, "blank")
	end)

	if var_134_3.trigger_area and var_134_3.trigger_area ~= "" then
		table.insert(var_134_2, function(arg_139_0)
			self:ShiftZone(var_134_3.trigger_area, arg_139_0)
		end)
	end

	if var_134_3.performance_type == 0 then
		table.insert(var_134_2, function(arg_140_0)
			self:emit(self.HIDE_BLOCK)

			if self.contextData.isVideoTalk then
				self.videoPlayer:ExecuteAction("Play", var_134_3.story, function()
					onDelayTick(arg_140_0, 0.001)
				end)
			else
				pg.NewStoryMgr.GetInstance():ForceManualPlay(var_134_3.story, function()
					onDelayTick(arg_140_0, 0.001)
				end, true)
			end
		end)
	elseif var_134_3.performance_type == 1 then
		table.insert(var_134_2, function(arg_143_0)
			self:emit(self.HIDE_BLOCK)
			self:PerformanceQueue(var_134_3.story, arg_143_0)
		end)
	else
		assert(false)
	end

	table.insert(var_134_2, function(arg_144_0)
		self:emit(self.SHOW_BLOCK)
		arg_144_0()
	end)
	table.insert(var_134_2, function(arg_145_0)
		local var_145_0 = pg.NewStoryMgr.GetInstance():StoryName2StoryId(var_134_3.story)

		if var_145_0 then
			pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataStory(var_145_0, "1"))
		end

		if var_134_5 and #var_134_5 > 0 then
			self:emit(Dorm3dRoomMediator.OPEN_DROP_LAYER, var_134_5, arg_145_0)
		else
			arg_145_0()
		end
	end)
	table.insert(var_134_2, function(arg_146_0)
		if pg.NewGuideMgr.GetInstance():IsPause() then
			pg.NewGuideMgr.GetInstance():Resume()
		end

		self:emit(self.HIDE_BLOCK)

		if self.contextData.isVideoTalk then
			existCall(arg_146_0)
		else
			self:SetBlackboardValue(var_134_1, var_134_4 and "inPerformance" or "inTalking", false)
			self:SetUI(arg_146_0, "back")
		end
	end)
	seriesAsync(var_134_2, function()
		if arg_134_2 then
			return arg_134_2()
		else
			self:CheckQueue()
		end
	end)
end

function Dorm3dRoomScene:DoTalkTouchOption(arg_148_1, arg_148_2, arg_148_3)
	local var_148_0 = self.rtExtraScreen:Find("TalkTouchOption")
	local var_148_1
	local var_148_2 = var_148_0:Find("content")

	UIItemList.StaticAlign(var_148_2, var_148_2:Find("clickTpl"), #arg_148_1.options, function(arg_149_0, arg_149_1, arg_149_2)
		arg_149_1 = arg_149_1 + 1

		if arg_149_0 == UIItemList.EventUpdate then
			local var_149_0 = arg_148_1.options[arg_149_1]

			setAnchoredPosition(arg_149_2, NewPos(unpack(arg_148_1.options[arg_149_1].pos)))
			onButton(self, arg_149_2, function()
				var_148_1(var_149_0.flag)
			end, SFX_CONFIRM)
			setActive(arg_149_2, not table.contains(arg_148_2, arg_148_1.options[arg_149_1].flag))
		end
	end)
	setActive(var_148_0, true)

	function var_148_1(arg_151_0)
		setActive(var_148_0, false)
		arg_148_3(arg_151_0)
	end
end

function Dorm3dRoomScene:DoTimelineOption(arg_152_1, arg_152_2)
	local var_152_0 = self.rtTimelineScreen:Find("TimelineOption")
	local var_152_1
	local var_152_2 = var_152_0:Find("content")

	UIItemList.StaticAlign(var_152_2, var_152_2:Find("clickTpl"), #arg_152_1, function(arg_153_0, arg_153_1, arg_153_2)
		arg_153_1 = arg_153_1 + 1

		if arg_153_0 == UIItemList.EventUpdate then
			setText(arg_153_2:Find("Text"), HXSet.hxLan(arg_152_1[arg_153_1].content))
			onButton(self, arg_153_2, function()
				var_152_1(arg_153_1)
			end, SFX_CONFIRM)
		end
	end)
	setActive(var_152_0, true)

	function var_152_1(arg_155_0)
		setActive(var_152_0, false)
		arg_152_2(arg_155_0)
	end
end

function Dorm3dRoomScene:DoTimelineTouch(arg_156_1, arg_156_2)
	local var_156_0 = self.rtTimelineScreen:Find("TimelineTouch")
	local var_156_1
	local var_156_2 = var_156_0:Find("content")

	UIItemList.StaticAlign(var_156_2, var_156_2:Find("clickTpl"), #arg_156_1, function(arg_157_0, arg_157_1, arg_157_2)
		arg_157_1 = arg_157_1 + 1

		if arg_157_0 == UIItemList.EventUpdate then
			setAnchoredPosition(arg_157_2, NewPos(unpack(arg_156_1[arg_157_1].pos)))
			onButton(self, arg_157_2, function()
				var_156_1(arg_157_1)
			end, SFX_CONFIRM)

			if self.firstTimelineTouch then
				self.firstTimelineTouch = nil

				setActive(arg_157_2:Find("finger"), true)
			end
		end
	end)
	setActive(var_156_0, true)

	function var_156_1(arg_159_0)
		setActive(var_156_0, false)
		arg_156_2(arg_159_0)
	end
end

function Dorm3dRoomScene:DoShortWait(arg_160_1)
	local var_160_0 = self.ladyDict[arg_160_1]
	local var_160_1 = getProxy(ApartmentProxy)
	local var_160_2 = var_160_1:getApartment(arg_160_1)
	local var_160_3 = self.room:getApartmentZoneConfig(self:GetLadyBaseZone(arg_160_1), "special_action", arg_160_1)
	local var_160_4 = var_160_3 and var_160_3[math.random(#var_160_3)] or nil

	if not var_160_1 then
		return
	end

	self:PlaySingleAction(var_160_0, var_160_4)
end

function Dorm3dRoomScene:OutOfLazy(arg_161_1, arg_161_2)
	local var_161_0 = {}

	if self:GetBlackboardValue(self.ladyDict[arg_161_1], "inPending") then
		table.insert(var_161_0, function(arg_162_0)
			self.shiftLady = arg_161_1

			self:ShiftZone(self:GetLadyBaseZone(arg_161_1), arg_162_0)
		end)
	end

	seriesAsync(var_161_0, arg_161_2)
end

function Dorm3dRoomScene:OutOfPending(arg_163_1, arg_163_2)
	assert(self.pendingStateDic[arg_163_1] and self.pendingStateDic[arg_163_1].talkId)

	local var_163_0 = self.pendingStateDic[arg_163_1].talkId

	seriesAsync({
		function(arg_164_0)
			self:SetUI(arg_164_0, "blank")
		end,
		function(arg_165_0)
			self.shiftLady = arg_163_1

			self:ShiftZone(self:GetLadyBaseZone(arg_163_1), arg_165_0)
		end,
		function(arg_166_0)
			self:DoTalk(var_163_0, arg_166_0)
		end
	}, function()
		self:SetUIStore(arg_163_2, "back")
	end)
end

function Dorm3dRoomScene:ChangeCanWatchState(arg_168_1)
	local var_168_0

	if self:GetBlackboardValue(arg_168_1, "inPending") then
		var_168_0 = tobool(self:GetBlackboardValue(arg_168_1, "inDistance"))
	else
		local var_168_1 = self.activeLady[self:GetBlackboardValue(arg_168_1, "groupId")]

		var_168_1 = var_168_1 and pg.NodeCanvasMgr.GetInstance():GetBlackboradValue("canWatch", arg_168_1.ladyBlackboard)
		var_168_0 = tobool(var_168_1)
	end

	if arg_168_1.blockCanWatch then
		var_168_0 = false
	end

	if (not arg_168_1.nowCanWatchState or arg_168_1.nowCanWatchState ~= var_168_0) and arg_168_1.ladyWatchFloat then
		arg_168_1.nowCanWatchState = var_168_0

		self:ShowOrHideCanWatchMark(arg_168_1, arg_168_1.nowCanWatchState)
	end
end

function Dorm3dRoomScene:HandleGameNotification(arg_169_1, arg_169_2)
	local var_169_0 = self:GetCurrentLadyEnv()

	switch(arg_169_1, {
		[Dorm3dMiniGameMediator.OPERATION] = function()
			switch(arg_169_2.miniGameId, {
				[67] = function()
					if arg_169_2.operationCode == "GAME_HIT_AREA" then
						local var_171_0, var_171_1 = unpack(({
							{
								"Face_XYX_1",
								"zhongji"
							},
							{
								"Face_XYX_2",
								"qingji"
							},
							{
								"Face_XYX_3",
								"miss"
							}
						})[arg_169_2.index])

						self:PlayFaceAnim(var_169_0, var_171_0)

						if self.tfCutIn then
							quickPlayAnimator(self.modelCutIn.lady, var_171_1)
							quickPlayAnimator(self.modelCutIn.player, var_171_1)
						end
					elseif arg_169_2.operationCode == "GAME_RESULT" then
						if arg_169_2.win then
							self:PlayFaceAnim(var_169_0, "Face_XYX_victory")
							self:PlaySingleAction(var_169_0, "minigame_win")
						else
							self:PlayFaceAnim(var_169_0, "Face_XYX_lose")
							self:PlaySingleAction(var_169_0, "minigame_lose")
						end

						setActive(self.rtExtraScreen:Find("MiniGameCutIn"), false)
					end
				end,
				[70] = function()
					if arg_169_2.operationCode == "GAME_READY" then
						self.cameras[Dorm3dRoomScene.CAMERA.TALK].Follow = nil
						self.cameras[Dorm3dRoomScene.CAMERA.TALK].LookAt = nil

						self:PlaySingleAction(var_169_0, "shuohua_sikao")
					elseif arg_169_2.operationCode == "ROUND_RESULT" then
						seriesAsync(underscore.map(arg_169_2.success and {
							"shuohua_wenhou",
							"shuohua_sikao"
						} or {
							"shuohua_yaotou",
							"shuohua_sikao"
						}, function(arg_173_0)
							return function(arg_174_0)
								self:PlaySingleAction(var_169_0, arg_173_0, arg_174_0)
							end
						end), function()
							return
						end)
					elseif arg_169_2.operationCode == "GAME_RESULT" then
						self.cameras[Dorm3dRoomScene.CAMERA.TALK].transform.position = self.cameras[Dorm3dRoomScene.CAMERA.TALK].transform.position + self.cameras[Dorm3dRoomScene.CAMERA.TALK].transform.right * 0.11

						seriesAsync(underscore.map({
							"shuohua_gandong"
						}, function(arg_176_0)
							return function(arg_177_0)
								self:PlaySingleAction(var_169_0, arg_176_0, arg_177_0)
							end
						end), function()
							return
						end)
					end
				end,
				[75] = function()
					if arg_169_2.operationCode == "BEFORE_OPEN_GAME" then
						self.cameras[Dorm3dRoomScene.CAMERA.TALK].Follow = nil
						self.cameras[Dorm3dRoomScene.CAMERA.TALK].LookAt = nil
					elseif arg_169_2.operationCode == "GAME_RPS_RESULT" then
						if arg_169_2.index == 1 then
							self:PlaySingleAction(var_169_0, "ab_shuohua_lianxuyaotou_01")
							self:PlayFaceAnim(var_169_0, "Face_weixiao")
						elseif arg_169_2.index == 2 then
							self:PlaySingleAction(var_169_0, "ab_shuohua_lianxudiantou_01")
							self:PlayFaceAnim(var_169_0, "Face_kaixin")
						end
					elseif arg_169_2.operationCode == "GAME_RESULT" then
						if not arg_169_2.win then
							self:PlaySingleAction(var_169_0, "ab_shuohua_taibangle_01")
						end

						self:PlayFaceAnim(var_169_0, "Face_kaixin")
					end
				end
			}, function()
				warning("without miniGameId:" .. arg_169_2.miniGameId)
			end)

			if arg_169_2.operationCode == "BEFORE_OPEN_GAME" then
				local var_170_0 = getProxy(PlayerProxy):getPlayerId()

				self.highScore = (arg_169_2.miniGameId == 67 or arg_169_2.miniGameId == 70) and PlayerPrefs.GetInt("mg_new_score_" .. tostring(var_170_0) .. "_" .. arg_169_2.miniGameId, 0) or PlayerPrefs.GetInt("mg_score_" .. tostring(var_170_0) .. "_" .. arg_169_2.miniGameId, 0)
			elseif arg_169_2.operationCode == "GAME_RESULT" then
				local var_170_2 = arg_169_2.score

				if arg_169_2.score > self.highScore then
					if arg_169_2.miniGameId == 67 or arg_169_2.miniGameId == 70 then
						PlayerPrefs.SetInt("mg_new_score_" .. tostring((getProxy(PlayerProxy):getPlayerId())) .. "_" .. arg_169_2.miniGameId, var_170_2)
					end

					getProxy(Dorm3dChatProxy):TriggerEvent({
						{
							event_type = 159,
							value = var_170_2,
							ship_id = self.apartment:GetConfigID()
						}
					})
				end

				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataMiniGame(2, arg_169_2.score))
			elseif arg_169_2.operationCode == "GAME_CLOSE" and arg_169_2.doTrack == false then
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataMiniGame(3))
			end
		end
	})
end

function Dorm3dRoomScene:PerformanceQueue(arg_181_1, arg_181_2)
	local var_181_0, var_181_1 = pcall(function()
		return require("GameCfg.dorm." .. arg_181_1)
	end)

	if not var_181_0 then
		errorMsg("不存在表演ID对应的Lua:" .. arg_181_1)
		existCall(arg_181_2)

		return
	end

	warning(arg_181_1)

	self.performanceInfo = {
		name = arg_181_1
	}

	local var_181_2 = {}

	table.insert(var_181_2, function(arg_183_0)
		self:SetUI(arg_183_0, "blank")
	end)
	table.insertto(var_181_2, underscore.map(var_181_1, function(arg_184_0)
		return switch(arg_184_0.type, {
			function()
				return function(arg_186_0)
					self:DoTalk(unpack(arg_184_0.params), arg_186_0, true)
				end
			end,
			function()
				return function(arg_188_0)
					self:emit(RoomTouchSystem.SET_TOUCH_EXIT_CALL, arg_188_0)
					self:emit(RoomTouchSystem.ENTER_TOUCH_MODE)
				end
			end,
			function()
				return function(arg_190_0)
					self:PlaySingleAction(self:GetCurrentLadyEnv(), arg_184_0.name, arg_190_0)
				end
			end,
			function()
				return function(arg_192_0)
					self:emit(self.PLAY_EXPRESSION, arg_184_0)
					arg_192_0()
				end
			end,
			function()
				return function(arg_194_0)
					self:ShiftZone(arg_184_0.name, arg_194_0)
				end
			end,
			function()
				return function(arg_196_0)
					self.contextData.timeIndex = arg_184_0.params[1]

					if Dorm3dSceneMgr.IsSameSceneInfo(self.dormSceneMgr.artSceneInfo, self.dormSceneMgr.sceneInfo) then
						self:SwitchDayNight(self.contextData.timeIndex)

						if arg_184_0.params[2] or false then
							onNextTick(function()
								self:RefreshSlots()
							end)
						end
					end

					self:emit(CollectionSystem.UPDATE_CONTACT_STATE, self.contextData.timeIndex)
					onNextTick(arg_196_0)
				end
			end,
			function()
				return function(arg_199_0)
					if arg_184_0.name then
						self:ActiveCameraByName(arg_184_0.name)
						existCall(arg_199_0)
					else
						self:ActiveStateCamera(arg_184_0.params[1], arg_199_0)
					end
				end
			end,
			function()
				return function(arg_201_0)
					if arg_184_0.name == "base" then
						self:RevertArtScene(self.dormSceneMgr.sceneInfo, arg_201_0)
					else
						self:ChangeArtScene(arg_184_0.params.scene .. "|" .. arg_184_0.params.sceneRoot, arg_201_0)
					end
				end
			end,
			function()
				return function(arg_203_0)
					if arg_184_0.name == "load" then
						self:LoadTimelineScene(arg_184_0.params.name, true, tobool(arg_184_0.params.wait_timeline) and function(arg_204_0)
							self.waitForTimeline = arg_204_0
						end, arg_203_0)
					elseif arg_184_0.name == "unload" then
						self:UnloadTimelineScene(arg_184_0.params.name, true, arg_203_0)
					else
						assert(false)
					end
				end
			end,
			function()
				return function(arg_206_0)
					setActive(self.uiContainer:Find("walk/btn_back"), false)

					local var_206_0 = self:GetCurrentLadyEnv()

					if arg_184_0.name == "change" then
						var_206_0.walkBornPoint = arg_184_0.params.point or "Default"

						self:ChangeWalkScene(arg_184_0.name, arg_184_0.params.scene .. "|" .. arg_184_0.params.sceneRoot, arg_206_0)
					elseif arg_184_0.name == "back" then
						var_206_0.walkBornPoint = nil

						self:ChangeWalkScene(arg_184_0.name, self.dormSceneMgr.sceneInfo, arg_206_0)
					elseif arg_184_0.name == "set" then
						local function var_206_1()
							arg_206_0 = nil

							return existCall(arg_206_0)
						end

						for iter_206_0, iter_206_1 in pairs(arg_184_0.params) do
							switch(iter_206_0, {
								back_button_trigger = function(arg_208_0)
									onButton(self, self.uiContainer:Find("walk/btn_back"), var_206_1, SFX_DORM_BACK)
									setActive(self.uiContainer:Find("walk/btn_back"), IsUnityEditor and arg_208_0)
								end,
								near_trigger = function(arg_209_0)
									if arg_209_0 == true then
										arg_209_0 = 1.5
									end

									self.walkNearCallback = arg_209_0 and function(arg_210_0)
										if arg_210_0 < arg_209_0 then
											self.walkNearCallback = nil

											var_206_1()
										end
									end or nil
								end
							}, nil, iter_206_1)
						end

						if self.firstMoveGuide then
							setActive(self.povLayer:Find("Guide"), self.firstMoveGuide)

							self.firstMoveGuide = nil
						end
					else
						assert(false)
					end
				end
			end,
			function()
				return function(arg_212_0)
					if arg_184_0.name == "set" then
						self:emit(Dorm3dIKView.SET_BACK_BUTTON_ACTIVE, not arg_184_0.params.hide_back)
						self:emit(RoomIKSystem.SET_IK_SPECIAL_CALL, arg_212_0)
						self:emit(RoomIKSystem.ENTER_IK, arg_184_0.params.state)
					elseif arg_184_0.name == "back" then
						self:emit(RoomIKSystem.EXIT_IK_WITH_RETURN, arg_184_0.params, function()
							existCall(arg_212_0)
						end)
					else
						assert(false)
					end
				end
			end,
			function()
				return function(arg_215_0)
					self.blackSceneInfo = setmetatable((not arg_184_0.params or nil) and {}, {
						__index = {
							color = "#000000",
							time = 0.3,
							delay = arg_184_0.name == "show" and 0 or 0.5
						}
					})

					if arg_184_0.name == "show" then
						self:ShowBlackScreen(true, arg_215_0)
					elseif arg_184_0.name == "hide" then
						self:ShowBlackScreen(false, arg_215_0)
					else
						assert(false)
					end

					self.blackSceneInfo = nil
				end
			end,
			function()
				return function(arg_217_0)
					local var_217_0 = self:GetCurrentLadyEnv()

					if arg_184_0.name == "set" then
						self:emit(Dorm3dStockingMgr.SET_STOCKING_STATUS, arg_184_0.params)
					elseif arg_184_0.name == "exit" then
						self:emit(Dorm3dStockingMgr.EXIT_STOCKING_STATUS)
					end
				end
			end
		})
	end))
	table.insert(var_181_2, function(arg_218_0)
		self:SetUI(arg_218_0, "back")

		self.performanceInfo = nil
	end)
	seriesAsync(var_181_2, arg_181_2)
end

function Dorm3dRoomScene:UpdateFavorDisplay()
	local var_219_0, var_219_1 = getProxy(ApartmentProxy):getStamina()

	setText(self.rtStaminaDisplay:Find("Text"), string.format("%d/%d", var_219_0, var_219_1))
	setActive(self.rtStaminaDisplay, false)

	if self.apartment then
		setText(self.rtFavorLevel:Find("rank/Text"), self.apartment.level)

		local var_219_2, var_219_3 = self.apartment:getFavor()
		local var_219_4 = self.apartment:isMaxFavor()

		setActive(self.rtFavorLevel:Find("Max"), var_219_4)
		setActive(self.rtFavorLevel:Find("Text"), not var_219_4)
		setText(self.rtFavorLevel:Find("Text"), string.format("<color=#ff6698>%d</color>/%d", var_219_2, var_219_3))
	end

	setActive(self.rtFavorLevel:Find("red"), Dorm3dLevelLayer.IsShowRed())
end

function Dorm3dRoomScene:UpdateBtnState()
	local var_220_0 = not self.room:isPersonalRoom() or self:CheckSystemOpen("Furniture")
	local var_220_1 = Dorm3dFurniture.IsTimelimitShopTip(self.room:GetConfigID())

	setActive(self.uiContainer:Find("base/left/btn_furniture/tipTimelimit"), var_220_0 and var_220_1)
	setActive(self.uiContainer:Find("base/left/btn_furniture/tip"), var_220_0 and not var_220_1 and Dorm3dFurniture.NeedViewTip(self.room:GetConfigID()))
	setActive(self.uiContainer:Find("base/btn_back/main"), underscore(getProxy(ApartmentProxy):getRawData()):chain():values():filter(function(arg_221_0)
		return tobool(arg_221_0)
	end):any(function(arg_222_0)
		return #arg_222_0:getSpecialTalking() > 0 or arg_222_0:getIconTip() == "main"
	end):value())
	setActive(self.uiContainer:Find("base/left/btn_collection/tip"), PlayerPrefs.GetInt("apartment_collection_item", 0) > 0 or PlayerPrefs.GetInt("apartment_collection_recall", 0) > 0)
end

function Dorm3dRoomScene:AddUnlockDisplay(arg_223_1)
	table.insert(self.unlockList, arg_223_1)

	if not isActive(self.rtFavorUp) then
		setText(self.rtFavorUp:Find("Text"), table.remove(self.unlockList, 1))
		setActive(self.rtFavorUp, true)
	end
end

function Dorm3dRoomScene:PopFavorTrigger(arg_224_1)
	local var_224_0 = arg_224_1.cost
	local var_224_1 = arg_224_1.apartment
	local var_224_2 = pg.dorm3d_favor_trigger[arg_224_1.triggerId]

	if pg.dorm3d_favor_trigger[arg_224_1.triggerId].is_repeat == 0 then
		if arg_224_1.triggerId == getDorm3dGameset("drom3d_favir_trigger_onwer")[1] then
			self:AddUnlockDisplay(i18n("dorm3d_own_favor"))
		elseif arg_224_1.triggerId == getDorm3dGameset("drom3d_favir_trigger_propose")[1] then
			self:AddUnlockDisplay(i18n("dorm3d_pledge_favor"))
		else
			self:AddUnlockDisplay(string.format("unknow favor trigger:%d unlock", arg_224_1.triggerId))
		end
	elseif arg_224_1.delta > 0 then
		local var_224_3, var_224_4 = arg_224_1.apartment:getFavor()
		local var_224_5 = var_224_3 + arg_224_1.delta

		setText(self.rtFavorUpDaily:Find("bg/Text"), string.format("<size=48>+%d</size>", math.min(9999, arg_224_1.delta)))
		setSlider(self.rtFavorUpDaily:Find("bg/slider"), 0, var_224_4, var_224_3)
		setAnchoredPosition(self.rtFavorUpDaily:Find("bg"), arg_224_1.isGift and NewPos(-354, 223) or NewPos(-208, 105))

		local var_224_6 = {}
		local var_224_7 = self.rtFavorUpDaily:Find("bg/effect")

		eachChild(var_224_7, function(arg_225_0)
			setActive(arg_225_0, false)
		end)

		local var_224_8

		if var_224_2.effect and var_224_2.effect ~= "" then
			var_224_8 = var_224_7:Find(var_224_2.effect .. "(Clone)")

			if not var_224_8 then
				table.insert(var_224_6, function(arg_226_0)
					LoadAndInstantiateAsync("Dorm3D/Effect/Prefab/ExpressionUI", "uifx_dorm3d_yinfu01", function(arg_227_0)
						setParent(arg_227_0, var_224_7)

						var_224_8 = tf(arg_227_0)

						arg_226_0()
					end)
				end)
			else
				setActive(var_224_8, true)
			end
		end

		local var_224_9 = self.rtFavorUpDaily:GetComponent("DftAniEvent")

		var_224_9:SetTriggerEvent(function(arg_228_0)
			local var_228_0 = GetComponent(self.rtFavorUpDaily:Find("bg/slider"), typeof(Slider))

			LeanTween.value(var_224_3, var_224_5, 0.5):setOnUpdate(System.Action_float(function(arg_229_0)
				var_228_0.value = arg_229_0
			end)):setEase(LeanTweenType.easeInOutQuad):setDelay(0.165):setOnComplete(System.Action(function()
				LeanTween.delayedCall(0.165, System.Action(function()
					if self.exited then
						return
					end

					quickPlayAnimator(self.rtFavorUpDaily, "favor_out")
				end))
			end))
			pg.CriMgr.GetInstance():PlaySE_V3("ui-dorm_progaress_bar")
		end)
		var_224_9:SetEndEvent(function(arg_232_0)
			setActive(self.rtFavorUpDaily, false)
		end)
		seriesAsync(var_224_6, function()
			setLocalPosition(self.rtFavorUpDaily, self:GetLocalPosition(self:GetScreenPosition(self.ladyDict[var_224_1:GetConfigID()].ladyHeadCenter.position), self.rtFavorUpDaily.parent))
			setActive(self.rtFavorUpDaily, true)
			SetCompomentEnabled(self.rtFavorUpDaily, typeof(Animator), true)
			quickPlayAnimator(self.rtFavorUpDaily, "favor_open")

			if var_224_0 > 0 then
				local var_233_0, var_233_1 = getProxy(ApartmentProxy):getStamina()

				setText(self.rtStaminaPop:Find("Text/Text (1)"), "-" .. var_224_0)
				setText(self.rtStaminaPop:Find("Text"), string.format("%d/%d", var_233_0 + var_224_0, var_233_1))
				setActive(self.rtStaminaPop, true)
			end
		end)
	end
end

function Dorm3dRoomScene:PopFavorLevelUp(arg_234_1, arg_234_2, arg_234_3)
	self.isLock = true

	LeanTween.delayedCall(0.33, System.Action(function()
		self.isLock = false
	end))

	local var_234_0 = math.floor(arg_234_1.level / 10)

	GetImageSpriteFromAtlasAsync("ui/favor_atlas", math.fmod(arg_234_1.level, 10), self.rtLevelUpWindow:Find("panel/bg/item1/mark/level/digit2"))
	GetImageSpriteFromAtlasAsync("ui/favor_atlas", var_234_0, self.rtLevelUpWindow:Find("panel/bg/item1/mark/level/digit1"))
	setActive(self.rtLevelUpWindow:Find("panel/bg/item1/mark/level/digit1"), var_234_0 > 0)

	local var_234_2

	self.clientAward, var_234_2 = Dorm3dIconHelper.SplitStory(arg_234_1:getFavorConfig("levelup_client_item", arg_234_1.level))
	self.serverAward = arg_234_2

	local var_234_3 = self.rtLevelUpWindow:Find("panel/info/content/itemContent")

	if not self.levelItemList then
		self.levelItemList = UIItemList.New(var_234_3, var_234_3:Find("tpl"))

		self.levelItemList:make(function(arg_236_0, arg_236_1, arg_236_2)
			local var_236_0 = arg_236_1 + 1

			if arg_236_0 == UIItemList.EventUpdate then
				if arg_236_1 < #self.serverAward then
					updateDorm3dIcon(arg_236_2, self.serverAward[arg_236_1 + 1])
					onButton(self, arg_236_2, function()
						self:emit(BaseUI.ON_NEW_DROP, {
							style = "dorm",
							drop = self.serverAward[var_236_0]
						})
					end, SFX_PANEL)
				else
					Dorm3dIconHelper.UpdateDorm3dIcon(arg_236_2, self.clientAward[arg_236_1 + 1 - #self.serverAward])
					onButton(self, arg_236_2, function()
						self:emit(Dorm3dRoomMediator.ON_DROP_CLIENT, {
							data = self.clientAward[var_236_0 - #self.serverAward]
						})
					end, SFX_PANEL)
				end
			end
		end)
	end

	self.levelItemList:align(#self.serverAward + #self.clientAward)
	setActive(self.rtLevelUpWindow, true)
	pg.CriMgr.GetInstance():PlaySE_V3("ui-dorm_upgrade")
	self:OverlayPanel(self.rtLevelUpWindow)

	function self.levelUpCallback()
		self.levelUpCallback = nil

		if var_234_2 then
			self:PopNewStoryTip(var_234_2)
		end

		existCall(arg_234_3)
	end
end

function Dorm3dRoomScene:PopNewStoryTip(arg_240_1, arg_240_2)
	local var_240_0 = self.uiContainer:Find("base/top/story_tip")

	setActive(var_240_0, true)
	LeanTween.delayedCall(1, System.Action(function()
		setActive(var_240_0, false)
	end))
	setText(var_240_0:Find("Text"), i18n("dorm3d_story_unlock_tip", pg.dorm3d_recall[arg_240_1[2]].name))
	existCall(arg_240_2)
end

function Dorm3dRoomScene:UpdateZoneList()
	local var_242_0 = self.room:isPersonalRoom() and self:GetLadyBaseZone(self.apartment:GetConfigID()) or self:GetCurrentZoneNodeName()

	for iter_242_0, iter_242_1 in ipairs(self.zoneDatas) do
		if iter_242_1:GetWatchCameraName() == var_242_0 then
			setText(self.btnZone:Find("Text"), iter_242_1:GetName())
			setTextColor(self.rtZoneList:GetChild(iter_242_0 - 1):Find("Name"), Color.NewHex("5CCAFF"))
		else
			setTextColor(self.rtZoneList:GetChild(iter_242_0 - 1):Find("Name"), Color.NewHex("FFFFFF99"))
		end
	end
end

function Dorm3dRoomScene:TalkingEventHandle(arg_243_1)
	local var_243_0 = {}
	local var_243_1 = {}

	if arg_243_1.data.op_list then
		for iter_243_0, iter_243_1 in ipairs(arg_243_1.data.op_list) do
			table.insert(var_243_0, function(arg_244_0)
				local function var_244_0()
					arg_244_0 = nil

					return existCall(arg_244_0)
				end

				switch(iter_243_1.type, {
					action = function()
						self:PlaySingleAction(self:GetCurrentLadyEnv(), iter_243_1.name, var_244_0)
					end,
					item_action = function()
						self:PlaySceneItemAnim(iter_243_1.id, iter_243_1.name)
						var_244_0()
					end,
					extra_item_action = function()
						local var_248_0 = self.extraItems and self.extraItems[iter_243_1.name]

						warning(iter_243_1.name)

						if var_248_0 then
							warning(var_248_0.trans)
							var_248_0.trans:GetComponent(typeof(Animator)):PlayInFixedTime(iter_243_1.param)
						end

						var_244_0()
					end,
					timeline = function()
						local var_249_0 = {}

						self:emit(RoomTouchSystem.GET_TOUCH_GAME_STATE, var_249_0)

						if var_249_0.inTouchGame then
							self:emit(RoomTouchSystem.UPDATE_TOUCH_PANEL, false)
						end

						self:PlayTimeline(iter_243_1, function(arg_250_0, arg_250_1)
							self:emit(RoomTouchSystem.GET_TOUCH_GAME_STATE, var_249_0)
							self:emit(RoomTouchSystem.UPDATE_TOUCH_PANEL, var_249_0.inTouchGame)

							var_243_1.notifiCallback = arg_250_1

							var_244_0()
						end)
					end,
					clickOption = function()
						self:DoTalkTouchOption(iter_243_1, arg_243_1.flags, function(arg_252_0)
							var_243_1.optionIndex = arg_252_0

							var_244_0()
						end)
					end,
					wait = function()
						self.LTs = self.LTs or {}

						table.insert(self.LTs, LeanTween.delayedCall(iter_243_1.time, System.Action(var_244_0)).uniqueId)
					end,
					expression = function()
						self:emit(self.PLAY_EXPRESSION, iter_243_1)
						var_244_0()
					end,
					blackscreen = function()
						self.LTs = self.LTs or {}

						self:ShowBlackScreen(true, function()
							table.insert(self.LTs, LeanTween.delayedCall(iter_243_1.time, System.Action(function()
								self:ShowBlackScreen(false)
								var_244_0()
							end)).uniqueId)
						end)
					end
				}, function()
					assert(false, "op type error:", iter_243_1.type)
				end)

				if iter_243_1.skip then
					var_244_0()
				end
			end)
		end
	end

	seriesAsync(var_243_0, function()
		if arg_243_1.callbackData then
			self:emit(Dorm3dRoomMediator.TALKING_EVENT_FINISH, arg_243_1.callbackData.name, var_243_1)
		end
	end)
end

function Dorm3dRoomScene:CheckQueue()
	if self.inGuide or self.uiState ~= "base" then
		return
	end

	if self.room:GetConfigID() == 1 and self:CheckGuide() then
		-- block empty
	elseif self.room:isPersonalRoom() and self:CheckLevelUp() then
		-- block empty
	elseif self.apartment and self:CheckEnterDeal() then
		-- block empty
	elseif self.apartment and self:CheckGiftExpireSoon() then
		-- block empty
	elseif self.apartment and self:CheckActiveTalk() then
		-- block empty
	elseif self.apartment then
		self:CheckFavorTrigger()
	end

	self.contextData.hasEnterCheck = true
end

function Dorm3dRoomScene:didEnterCheck()
	local var_261_0

	if self.contextData.specialId then
		var_261_0 = self.contextData.specialId
		self.contextData.specialId = nil

		self:DoTalk(var_261_0, function()
			self:closeView()
		end)

		if self.contextData.isVideoTalk then
			self.contextData.hasEnterCheck = true
		end
	elseif not self.contextData.hasEnterCheck and self.apartment then
		for iter_261_0, iter_261_1 in ipairs(self.apartment:getForceEnterTalking(self.room:GetConfigID())) do
			var_261_0 = iter_261_1

			self:DoTalk(iter_261_1)

			break
		end
	end

	if var_261_0 and pg.dorm3d_dialogue_group[var_261_0].extend_loading > 0 then
		self.contextData.hasEnterCheck = true

		pg.SceneAnimMgr.GetInstance():RegisterDormNextCall(function()
			self:FinishEnterResume()
		end)
	else
		if self.apartment and self.contextData.pendingDic[self.apartment:GetConfigID()] then
			self.contextData.hasEnterCheck = true
		end

		for iter_261_2, iter_261_3 in pairs(self.contextData.pendingDic) do
			self:SetInPending(self.ladyDict[iter_261_2], iter_261_3)
		end

		self.contextData.pendingDic = {}

		self:FinishEnterResume()
		self:CheckQueue()
	end
end

function Dorm3dRoomScene:CheckGuide()
	if self:GetBlackboardValue(self:GetCurrentLadyEnv(), "inPending") then
		return
	end

	if DORM_LOCK_GUIDE then
		return false
	end

	for iter_264_0, iter_264_1 in ipairs({
		{
			name = "DORM3D_GUIDE_03",
			active = function()
				return true
			end
		},
		{
			name = "DORM3D_GUIDE_04",
			active = function()
				return true
			end
		},
		{
			name = "DORM3D_GUIDE_05",
			active = function()
				return self:CheckSystemOpen("Furniture")
			end
		},
		{
			name = "DORM3D_GUIDE_07",
			active = function()
				return self:CheckSystemOpen("DayNight")
			end
		}
	}) do
		if not pg.NewStoryMgr.GetInstance():IsPlayed(iter_264_1.name) and iter_264_1.active() then
			self:SetAllBlackbloardValue("inGuide", true)

			local function var_264_0()
				pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(2, pg.NewStoryMgr.GetInstance():StoryName2StoryId(iter_264_1.name)))
				self:SetAllBlackbloardValue("inGuide", false)
			end

			pg.m02:sendNotification(GAME.STORY_UPDATE, {
				storyId = iter_264_1.name
			})
			pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataGuide(1, pg.NewStoryMgr.GetInstance():StoryName2StoryId(iter_264_1.name)))
			pg.NewGuideMgr.GetInstance():Play(iter_264_1.name, nil, var_264_0, var_264_0)

			return true
		end
	end

	return false
end

function Dorm3dRoomScene:CheckGiftExpireSoon()
	if not self.room:isPersonalRoom() then
		return false
	end

	local var_270_0 = getProxy(ApartmentProxy):GetShipGroupGiftExpireSoonTipIds(self.apartment:GetConfigID())

	if #var_270_0 <= 0 then
		return false
	end

	_.each(var_270_0, function(arg_271_0)
		Dorm3dGift.SetExpireSoonTipFlag(arg_271_0)
	end)

	local function var_270_1()
		self:CheckQueue()
	end

	pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_MSGBOX, {
		title = i18n("dorm3d_gift_overtime_title"),
		contentText = i18n("dorm3d_gift_overtime"),
		btnList = {
			{
				type = pg.NewStyleMsgboxMgr.BUTTON_TYPE.confirm,
				name = i18n("msgbox_text_confirm"),
				func = var_270_1,
				sound = SFX_CONFIRM
			}
		},
		onClose = var_270_1
	})

	return true
end

function Dorm3dRoomScene:CheckFavorTrigger()
	for iter_273_0, iter_273_1 in ipairs({
		{
			triggerId = getDorm3dGameset("drom3d_favir_trigger_onwer")[1],
			active = function()
				return tobool((getProxy(CollectionProxy):getShipGroup(self.apartment.configId)))
			end
		},
		{
			triggerId = getDorm3dGameset("drom3d_favir_trigger_propose")[1],
			active = function()
				local var_275_0 = getProxy(CollectionProxy):getShipGroup(self.apartment.configId)

				return var_275_0 and var_275_0.married > 0
			end
		}
	}) do
		if self.apartment.triggerCountDic[iter_273_1.triggerId] == 0 and iter_273_1.active() then
			self:emit(Dorm3dRoomMediator.TRIGGER_FAVOR, self.apartment.configId, iter_273_1.triggerId)
		end
	end
end

function Dorm3dRoomScene:CheckEnterDeal()
	if self.contextData.hasEnterCheck then
		return false
	end

	local var_276_0 = "dorm3d_enter_count_" .. self.apartment:GetConfigID()
	local var_276_1 = pg.TimeMgr.GetInstance():CurrentSTimeDesc("%Y/%m/%d")

	if PlayerPrefs.GetString("dorm3d_enter_count_day") ~= var_276_1 then
		PlayerPrefs.SetString("dorm3d_enter_count_day", var_276_1)
		PlayerPrefs.SetInt(var_276_0, 1)
	else
		PlayerPrefs.SetInt(var_276_0, PlayerPrefs.GetInt(var_276_0, 0) + 1)
	end

	local var_276_2 = self.apartment:getEnterTalking(self.room:GetConfigID())

	PlayerPrefs.SetString("DORM3D_DAILY_ENTER", pg.TimeMgr.GetInstance():CurrentSTimeDesc("%Y/%m/%d"))

	if #var_276_2 > 0 then
		self:DoTalk(var_276_2[math.random(#var_276_2)])

		return true
	end
end

function Dorm3dRoomScene:CheckActiveTalk()
	if self:GetBlackboardValue(self:GetCurrentLadyEnv(), "inPending") then
		return false
	end

	local var_277_0 = self.apartment:getZoneTalking(self.room:GetConfigID(), self:GetLadyBaseZone(self.apartment:GetConfigID()))

	if #var_277_0 > 0 then
		self:DoTalk(var_277_0[1])

		return true
	else
		return false
	end
end

function Dorm3dRoomScene:CheckDistanceTalk(arg_278_1, arg_278_2)
	for iter_278_0, iter_278_1 in ipairs(getProxy(ApartmentProxy):getApartment(arg_278_1):getDistanceTalking(self.room:GetConfigID(), (self:GetLadyBaseZone(arg_278_1)))) do
		self:DoTalk(iter_278_1)

		return
	end
end

function Dorm3dRoomScene:CheckSystemOpen(arg_279_1)
	if self.room:isPersonalRoom() then
		return switch(arg_279_1, {
			Talk = function()
				return 1 <= self.apartment.level, i18n("apartment_level_unenough", 1)
			end,
			Touch = function()
				local var_281_0 = getDorm3dGameset("drom3d_touch_dialogue")[1]

				return var_281_0 <= self.apartment.level, i18n("apartment_level_unenough", var_281_0)
			end,
			Gift = function()
				local var_282_0 = getDorm3dGameset("drom3d_gift_dialogue")[1]

				return var_282_0 <= self.apartment.level, i18n("apartment_level_unenough", var_282_0)
			end,
			PublicGame = function()
				return false
			end,
			Photo = function()
				local var_284_0 = getDorm3dGameset("drom3d_photograph_unlock")[1]

				return var_284_0 <= self.apartment.level, i18n("apartment_level_unenough", var_284_0)
			end,
			Collection = function()
				local var_285_0 = getDorm3dGameset("drom3d_recall_unlock")[1]

				return var_285_0 <= self.apartment.level, i18n("apartment_level_unenough", var_285_0)
			end,
			Furniture = function()
				local var_286_0 = getDorm3dGameset("drom3d_furniture_unlock")[1]

				return var_286_0 <= self.apartment.level, i18n("apartment_level_unenough", var_286_0)
			end,
			DayNight = function()
				local var_287_0 = getDorm3dGameset("drom3d_time_unlock")[1]

				return var_287_0 <= self.apartment.level, i18n("apartment_level_unenough", var_287_0)
			end,
			Accompany = function()
				return 1 <= self.apartment.level, i18n("apartment_level_unenough", 1)
			end,
			MiniGame = function()
				if 1 > self.apartment.level then
					return false, i18n("apartment_level_unenough", 1)
				elseif #self.room:getMiniGames() <= 0 then
					return false, "without minigame config in room:" .. self.room.configId
				else
					return true
				end
			end,
			Invite = function()
				return false
			end,
			Performance = function()
				return IsUnityEditor
			end
		}, function()
			return true
		end)
	else
		return switch(arg_279_1, {
			Gift = function()
				return false
			end,
			PublicGame = function()
				return true
			end,
			Furniture = function()
				return #self.room:GetFurnitures() > 0 or #_.filter(self.room:GetFurnitureIDList() or {}, function(arg_296_0)
					return Dorm3dFurniture.New({
						configId = arg_296_0
					}):InShopTime()
				end) > 0
			end,
			DayNight = function()
				return false
			end,
			Accompany = function()
				return false
			end,
			MiniGame = function()
				return false
			end,
			Performance = function()
				return IsUnityEditor
			end
		}, function()
			return true
		end)
	end
end

function Dorm3dRoomScene:CheckLevelUp()
	if self.apartment:canLevelUp() then
		self:emit(Dorm3dRoomMediator.FAVOR_LEVEL_UP, self.apartment.configId)

		return true
	end

	return false
end

function Dorm3dRoomScene:TempHideUI(arg_303_1, arg_303_2)
	local var_303_0 = defaultValue(self.hideCount, 0)

	self.hideCount = var_303_0 + (arg_303_1 and 1 or -1)

	assert(self.hideCount >= 0)

	if self.hideCount * var_303_0 > 0 then
		return existCall(arg_303_2)
	elseif self.hideCount > 0 then
		self:SetUI(arg_303_2, "blank")
	else
		self:SetUI(arg_303_2, "back")
	end
end

function Dorm3dRoomScene:onBackPressed()
	if self.exited or self.retainCount > 0 then
		-- block empty
	elseif isActive(self.rtLevelUpWindow) then
		triggerButton(self.rtLevelUpWindow:Find("bg"))
	elseif self.uiState ~= "base" then
		-- block empty
	else
		self:closeView()
	end
end

function Dorm3dRoomScene:willExit()
	if self.LTs then
		underscore.map(self.LTs, function(arg_306_0)
			LeanTween.cancel(arg_306_0)
		end)

		self.LTs = nil
	end

	if self.accompanyFavorTimer then
		self.accompanyFavorTimer:Stop()

		self.accompanyFavorTimer = nil
	end

	if self.accompanyPerformanceTimer then
		self.accompanyPerformanceTimer:Stop()

		self.accompanyPerformanceTimer = nil
	end

	self.canTriggerAccompanyPerformance = nil

	self.videoPlayer:Destroy()

	if self.aimIKView then
		self.aimIKView:Dispose()

		self.aimIKView = nil
	end

	if self.ikView then
		self.ikView:Dispose()

		self.ikView = nil
	end

	if self.touchView then
		self.touchView:Dispose()

		self.touchView = nil
	end

	Dorm3dRoomScene.super.willExit(self)
end

return Dorm3dRoomScene
