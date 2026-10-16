local Dorm3dRoomTemplateScene = class("Dorm3dRoomTemplateScene", import("view.dorm3d.Core.Dorm3dBaseScene"))

Dorm3dRoomTemplateScene.CAMERA = {
	GIFT = 8,
	PHOTO_FREE = 11,
	FURNITURE_WATCH = 7,
	PHOTO = 10,
	AIM2 = 2,
	TALK = 4,
	POV = 12,
	IK_WATCH = 13,
	CUSTOM = 15,
	ROLE2 = 9,
	ROLE = 3,
	SKIN = 14,
	AIM = 1
}
Dorm3dRoomTemplateScene.CAMERA_MAX_OPERATION = {
	RIGHT = "right",
	DOWN = "donw",
	ZOOMIN = "zoom_in",
	ZOOMOUT = "zoom_out",
	UP = "up",
	LEFT = "left"
}
Dorm3dRoomTemplateScene.ANIM = {
	IDLE = "Idle"
}
Dorm3dRoomTemplateScene.PLAY_EXPRESSION = "Dorm3dRoomTemplateScene.PLAY_EXPRESSION"
Dorm3dRoomTemplateScene.SHOW_BLOCK = "Dorm3dRoomTemplateScene.SHOW_BLOCK"
Dorm3dRoomTemplateScene.HIDE_BLOCK = "Dorm3dRoomTemplateScene.HIDE_BLOCK"
Dorm3dRoomTemplateScene.ON_ROLEWATCH_CAMERA_MAX = "Dorm3dRoomTemplateScene.ON_ROLEWATCH_CAMERA_MAX"
Dorm3dRoomTemplateScene.ON_STICK_MOVE = "Dorm3dRoomTemplateScene.ON_STICK_MOVE"
Dorm3dRoomTemplateScene.ENABLE_SCENEBLOCK = "Dorm3dRoomTemplateScene.ENABLE_SCENEBLOCK"
Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE_BEGIN = "Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE_BEGIN"
Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE = "Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE"
Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE_END = "Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE_END"
Dorm3dRoomTemplateScene.ON_POV_STICK_VIEW = "Dorm3dRoomTemplateScene.ON_POV_STICK_VIEW"
Dorm3dRoomTemplateScene.ON_ENTER_SECTOR = "Dorm3dRoomTemplateScene.ON_ENTER_SECTOR"
Dorm3dRoomTemplateScene.ON_CHANGE_DISTANCE = "Dorm3dRoomTemplateScene.ON_CHANGE_DISTANCE"
Dorm3dRoomTemplateScene.CLICK_CHARACTER = "Dorm3dRoomTemplateScene.CLICK_CHARACTER"
Dorm3dRoomTemplateScene.DISTANCE_TRIGGER = "Dorm3dRoomTemplateScene.DISTANCE_TRIGGER"
Dorm3dRoomTemplateScene.WALK_DISTANCE_TRIGGER = "Dorm3dRoomTemplateScene.WALK_DISTANCE_TRIGGER"
Dorm3dRoomTemplateScene.CHANGE_WATCH = "Dorm3dRoomTemplateScene.CHANGE_WATCH"
Dorm3dRoomTemplateScene.PHOTO_CALL = "Dorm3dRoomTemplateScene.PHOTO_CALL"
Dorm3dRoomTemplateScene.SHIFT_ZONE_SAFE = "Dorm3dRoomTemplateScene.SHIFT_ZONE_SAFE"
Dorm3dRoomTemplateScene.TIMELINE_END = "Dorm3dRoomTemplateScene.TIMELINE_END"
Dorm3dRoomTemplateScene.TRIGGER_TIMELINE_PLAYER_EVENT = "Dorm3dRoomTemplateScene.TRIGGER_TIMELINE_PLAYER_EVENT"
Dorm3dRoomTemplateScene.EXTRA_GET_SCREEN_POSITION = "Dorm3dRoomTemplateScene.EXTRA_GET_SCREEN_POSITION"
Dorm3dRoomTemplateScene.EXTRA_CHANGE_PLAYER_POSITION = "Dorm3dRoomTemplateScene.EXTRA_CHANGE_PLAYER_POSITION"
Dorm3dRoomTemplateScene.EXTRA_CHANGE_CHARACTER_POSITION = "Dorm3dRoomTemplateScene.EXTRA_CHANGE_CHARACTER_POSITION"
Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA = "Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA"
Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA_BY_NAME = "Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA_BY_NAME"
Dorm3dRoomTemplateScene.EXTRA_REGISTER_ORBITS = "Dorm3dRoomTemplateScene.EXTRA_REGISTER_ORBITS"
Dorm3dRoomTemplateScene.EXTRA_REVERT_CAMERA_ORBIT = "Dorm3dRoomTemplateScene.EXTRA_REVERT_CAMERA_ORBIT"
Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_SCENE_ANIM = "Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_SCENE_ANIM"
Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_EXTRA_ITEM = "Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_EXTRA_ITEM"
Dorm3dRoomTemplateScene.EXTRA_HIDE_SCENE_ITEM = "Dorm3dRoomTemplateScene.EXTRA_HIDE_SCENE_ITEM"
Dorm3dRoomTemplateScene.EXTRA_RESET_SCENE_ITEM_ANIMATORS = "Dorm3dRoomTemplateScene.EXTRA_RESET_SCENE_ITEM_ANIMATORS"
Dorm3dRoomTemplateScene.EXTRA_RESET_CHARACTER_EXTRA_ITEM = "Dorm3dRoomTemplateScene.EXTRA_RESET_CHARACTER_EXTRA_ITEM"
Dorm3dRoomTemplateScene.EXTRA_RESET_TEMP_HIDE_SCENE_ITEMS = "Dorm3dRoomTemplateScene.EXTRA_RESET_TEMP_HIDE_SCENE_ITEMS"
Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE = "Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE"
Dorm3dRoomTemplateScene.EXTRA_SWITCH_ANIM = "Dorm3dRoomTemplateScene.EXTRA_SWITCH_ANIM"
Dorm3dRoomTemplateScene.EXTRA_SET_HEAD_AIM_IK = "Dorm3dRoomTemplateScene.EXTRA_SET_HEAD_AIM_IK"
Dorm3dRoomTemplateScene.EXTRA_RESET_HEAD_AIM_IK = "Dorm3dRoomTemplateScene.EXTRA_RESET_HEAD_AIM_IK"
Dorm3dRoomTemplateScene.EXTRA_PLAY_SINGLE_ACTION = "Dorm3dRoomTemplateScene.EXTRA_PLAY_SINGLE_ACTION"
Dorm3dRoomTemplateScene.EXTRA_PLAY_FACE_ANIM = "Dorm3dRoomTemplateScene.EXTRA_PLAY_FACE_ANIM"
Dorm3dRoomTemplateScene.EXTRA_PLAY_SCENE_ITEM_ANIM = "Dorm3dRoomTemplateScene.EXTRA_PLAY_SCENE_ITEM_ANIM"
Dorm3dRoomTemplateScene.EXTRA_SHOW_BLACK_SCREEN = "Dorm3dRoomTemplateScene.EXTRA_SHOW_BLACK_SCREEN"
Dorm3dRoomTemplateScene.EXTRA_TRIGGER_LADY_DISTANCE = "Dorm3dRoomTemplateScene.EXTRA_TRIGGER_LADY_DISTANCE"
Dorm3dRoomTemplateScene.EXTRA_CHECK_IN_SECTOR = "Dorm3dRoomTemplateScene.EXTRA_CHECK_IN_SECTOR"
Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE = "Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE"
Dorm3dRoomTemplateScene.ART_SCENE_CHANGED = "Dorm3dRoomTemplateScene.ART_SCENE_CHANGED"
Dorm3dRoomTemplateScene.POV_CLOSE_DISTANCE = 1.5
Dorm3dRoomTemplateScene.POV_PENDING_CLOSE_DISTANCE = 2

function Dorm3dRoomTemplateScene:getUIName()
	return nil
end

function Dorm3dRoomTemplateScene:getResource()
	local var_2_0 = Dorm3dRoomTemplateScene.super.getResource(self)
	local var_2_1 = getProxy(ApartmentProxy):getRoom(self.contextData.roomId)
	local var_2_2, var_2_3 = Dorm3dSceneMgr.ParseInfo(var_2_1:getConfig("scene_info"))

	table.insert(var_2_0, string.lower("dorm3d/scenesres/scenes/" .. var_2_3 .. "/" .. var_2_2 .. "_scene"))
	table.insert(var_2_0, string.lower("dorm3d/scenesres/scenes/" .. var_2_3 .. "/" .. var_2_2 .. "_base_scene"))

	for iter_2_0, iter_2_1 in ipairs(self.contextData.groupIds) do
		local var_2_4 = getProxy(ApartmentProxy)
		local var_2_5 = var_2_4:getApartment(iter_2_1)
		local var_2_6 = var_2_5:getConfig("asset_name")
		local var_2_7 = var_2_5:GetSkinModelID(var_2_1:getConfig("tag"))
		local var_2_8 = Dorm3dSkin.New({
			configId = var_2_4
		}):GetModelName()

		assert(var_2_8)

		for iter_2_2, iter_2_3 in ipairs(Dorm3dHxHelper.GetMaterialResources(iter_2_1)) do
			table.insert(var_2_0, iter_2_3)
		end

		table.insert(var_2_0, string.lower(string.format("dorm3d/character/%s/prefabs/%s", var_2_6, var_2_8)))

		if var_2_1:isPersonalRoom() then
			for iter_2_4, iter_2_5 in ipairs(var_2_5:GetAllModelIds()) do
				if iter_2_5 ~= var_2_7 then
					local var_2_9 = string.format("dorm3d/character/%s/prefabs/%s", var_2_6, (Dorm3dSkin.New({
						configId = iter_2_5
					}):GetModelName()))

					if checkABExist(var_2_9) then
						table.insert(var_2_0, string.lower(var_2_9))
					end
				end
			end
		end

		local var_2_10 = self.contextData.pendingDic and self.contextData.pendingDic[iter_2_1]

		if var_2_10 then
			if pg.dorm3d_welcome[var_2_10].item_prefab ~= "" then
				table.insert(var_2_0, string.lower("dorm3d/furniture/item/" .. pg.dorm3d_welcome[var_2_10].item_prefab))
			end
		end
	end

	return var_2_0
end

function Dorm3dRoomTemplateScene:forceGC()
	return true
end

function Dorm3dRoomTemplateScene:loadingQueue()
	return function(arg_5_0)
		pg.SceneAnimMgr.GetInstance():Dorm3DSceneChange(function(arg_6_0)
			return arg_5_0(arg_6_0)
		end)
	end
end

function Dorm3dRoomTemplateScene:getBGM()
	if pg.dorm3d_rooms[self.contextData.roomId].room_bgm and pg.dorm3d_rooms[self.contextData.roomId].room_bgm ~= "" then
		return pg.dorm3d_rooms[self.contextData.roomId].room_bgm
	else
		return Dorm3dRoomTemplateScene.super.getBGM(self)
	end
end

function Dorm3dRoomTemplateScene:Ctor(...)
	Dorm3dRoomTemplateScene.super.Ctor(self, ...)

	self.loader = AutoLoader.New()
	self.hxHelper = Dorm3dHxHelper.New(self.loader)
	self.scene = self
end

function Dorm3dRoomTemplateScene:SetRoom(arg_9_1)
	self.room = arg_9_1
end

function Dorm3dRoomTemplateScene:preload(arg_10_1)
	tolua.loadassembly("MagicaClothV2")
	tolua.loadassembly("ParadoxNotion")
	tolua.loadassembly("Yongshi.BLRP.Runtime")

	for iter_10_0, iter_10_1 in pairs({
		_MonoManager = "ParadoxNotion.Services.MonoManager"
	}) do
		if not GameObject.Find(iter_10_0) then
			GetOrAddComponent(GameObject.New(iter_10_0), typeof(iter_10_1))
		end
	end

	self.room = getProxy(ApartmentProxy):getRoom(self.contextData.roomId)

	local var_10_0 = {}

	table.insert(var_10_0, function(arg_11_0)
		self.dormSceneMgr = Dorm3dSceneMgr.New(self.room:getConfig("scene_info"), arg_11_0)
	end)
	table.insert(var_10_0, function(arg_12_0)
		self:LoadCharacter(self.contextData.groupIds, arg_12_0)
	end)
	seriesAsync(var_10_0, arg_10_1)
end

function Dorm3dRoomTemplateScene:init()
	self:BindEvent()
	self:InitData()
	self:initScene()
	self:initNodeCanvas()

	if self.room:isPersonalRoom() then
		local var_13_0 = getProxy(ApartmentProxy):getApartment(self.contextData.groupIds[1]):GetCurSkinId()

		setActive(self.ladyDict[self.contextData.groupIds[1]].ladyGameObject, false)

		self.ladyDict[self.contextData.groupIds[1]].skinId = var_13_0
		self.ladyDict[self.contextData.groupIds[1]].ladyGameObject = self.skinDict[var_13_0].ladyGameObject

		setActive(self.ladyDict[self.contextData.groupIds[1]].ladyGameObject, true)
	end

	for iter_13_0, iter_13_1 in pairs(self.ladyDict) do
		self:InitCharacter(iter_13_1, iter_13_0)
	end

	if not self.room:isPersonalRoom() then
		local var_13_1 = underscore.detect(self.contextData.groupIds, function(arg_14_0)
			return self.contextData.ladyZone[arg_14_0] == self.contextData.currentZoneNodeName
		end) or self.contextData.groupIds[1]

		if var_13_1 then
			self:SyncInterestTransform(self.ladyDict[var_13_1])
		end

		if SlideExtraSystem.IsOpen(self.room) and self.contextData.currentZoneNodeName == SlideConst.SLIDE_ZONE then
			self:SyncInterestTransformByTf(self:GetZoneByName(self.contextData.currentZoneNodeName):Find("StayPoint"))
		end
	end

	self.retainCount = 0
	self.sceneBlockLayer = self._tf:Find("SceneBlock")

	setActive(self.sceneBlockLayer, false)

	self.blockLayer = self._tf:Find("Block")

	setActive(self.blockLayer, false)

	self.blackLayer = self._tf:Find("BlackScreen")

	setActive(self.blackLayer, false)

	self.holyLightRoot = self._tf:Find("HolyLightRoot")

	self:InitHolyLight()
	self:ChangePlayerPosition()

	self.cacheSceneDic = {}
	self.sceneGroupDic = {}
	self.lastSceneRootDict = {}

	pg.ClickEffectMgr.GetInstance():SetClickEffect("DORM3D")
end

function Dorm3dRoomTemplateScene:BindEvent()
	self:bind(Dorm3dRoomTemplateScene.PLAY_EXPRESSION, function(arg_16_0, arg_16_1)
		self:PlayExpression(arg_16_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.SHOW_BLOCK, function()
		self.retainCount = self.retainCount + 1

		setActive(self.blockLayer, true)
	end)
	self:bind(Dorm3dRoomTemplateScene.HIDE_BLOCK, function()
		self.retainCount = math.max(self.retainCount - 1, 0)

		if self.retainCount > 0 then
			return
		end

		setActive(self.blockLayer, false)
	end)
	self:bind(Dorm3dRoomTemplateScene.ENABLE_SCENEBLOCK, function(arg_19_0, arg_19_1)
		setActive(self.sceneBlockLayer, arg_19_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.ON_STICK_MOVE, function(arg_20_0, arg_20_1)
		self:OnStickMove(arg_20_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE_BEGIN, function(arg_21_0, arg_21_1)
		if self.pinchMode then
			return
		end

		self.moveStickOrigin = arg_21_1.position
		self.moveStickPosition = self.moveStickOrigin
		self.moveStickDraging = true
	end)

	local function var_15_0()
		self.moveStickOrigin = nil
		self.moveStickPosition = nil
		self.moveStickDraging = nil

		if isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]) then
			self:emit(Dorm3dPhotoMediator.CAMERA_STICK_MOVE, Vector2.zero)
		end
	end

	self:bind(Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE_END, function(arg_23_0, arg_23_1)
		var_15_0()
	end)
	self:bind(Dorm3dRoomTemplateScene.ON_POV_STICK_MOVE, function(arg_24_0, arg_24_1)
		if self.pinchMode then
			var_15_0()

			return
		end

		if not self.moveStickDraging then
			return
		end

		self.moveStickPosition = self.moveStickPosition + arg_24_1

		if isActive(self.povLayer:Find("Guide")) then
			setActive(self.povLayer:Find("Guide"), false)
		end
	end)

	local var_15_1 = 32.4 / Screen.height

	self:bind(Dorm3dRoomTemplateScene.ON_POV_STICK_VIEW, function(arg_25_0, arg_25_1)
		if self.pinchMode then
			return
		end

		arg_25_1 = arg_25_1 * var_15_1

		local function var_25_0(arg_26_0, arg_26_1, arg_26_2)
			arg_26_0[arg_26_1].m_InputAxisValue = arg_26_2
			arg_26_0[arg_26_1] = arg_26_0[arg_26_1]
		end

		if isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]) then
			var_25_0(self.compPovAim, "m_HorizontalAxis", arg_25_1.x)
			var_25_0(self.compPovAim, "m_VerticalAxis", arg_25_1.y)
		elseif isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]) then
			local var_25_1 = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]:Find("PhotoFree Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera)):GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Aim)

			var_25_0(var_25_1, "m_HorizontalAxis", arg_25_1.x)
			var_25_0(var_25_1, "m_VerticalAxis", arg_25_1.y)
		end
	end)

	local var_15_2 = {
		PlayEnterExtraItem = true,
		EnableHeadIK = true,
		HideCharacterBylayer = true,
		RevertCharacterBylayer = true
	}

	self:bind(Dorm3dRoomTemplateScene.PHOTO_CALL, function(arg_27_0, arg_27_1, ...)
		if var_15_2[arg_27_1] then
			self[arg_27_1](self, self:GetCurrentLadyEnv(), ...)
		else
			self[arg_27_1](self, ...)
		end
	end)
	self:bind(Dorm3dRoomTemplateScene.SHIFT_ZONE_SAFE, function(arg_28_0, arg_28_1)
		self:ShiftZoneSafe(arg_28_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.TRIGGER_TIMELINE_PLAYER_EVENT, function(arg_29_0, arg_29_1)
		if not self.nowTimelinePlayer then
			warning("nowTimelinePlayer is nil, can't trigger event", arg_29_1)

			return
		end

		self.nowTimelinePlayer:TriggerEvent(arg_29_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_GET_SCREEN_POSITION, function(arg_30_0, arg_30_1, arg_30_2, arg_30_3)
		arg_30_1.value = self:GetScreenPosition(arg_30_2, arg_30_3)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_CHANGE_PLAYER_POSITION, function(arg_31_0, arg_31_1)
		self:ChangePlayerPosition(arg_31_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_CHANGE_CHARACTER_POSITION, function(arg_32_0, arg_32_1, arg_32_2)
		if arg_32_2 then
			self:SetLadyActiveZone(self:GetBlackboardValue(arg_32_1, "groupId"), arg_32_2)
		end

		self:ChangeCharacterPosition(arg_32_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA, function(arg_33_0, arg_33_1)
		self:ActiveCamera(arg_33_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA_BY_NAME, function(arg_34_0, arg_34_1)
		self:ActiveCameraByName(arg_34_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_REGISTER_ORBITS, function(arg_35_0, arg_35_1)
		self:RegisterOrbits(arg_35_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_REVERT_CAMERA_ORBIT, function()
		self:RevertCameraOrbit()
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_SCENE_ANIM, function(arg_37_0, arg_37_1, arg_37_2)
		self:PlayEnterSceneAnim(arg_37_1, arg_37_2)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_EXTRA_ITEM, function(arg_38_0, arg_38_1, arg_38_2, arg_38_3)
		self:PlayEnterExtraItem(arg_38_1, arg_38_2, nil, arg_38_3)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_HIDE_SCENE_ITEM, function(arg_39_0, arg_39_1)
		self:HideSceneItem(arg_39_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_RESET_SCENE_ITEM_ANIMATORS, function(arg_40_0, arg_40_1)
		self:ResetSceneItemAnimators(arg_40_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_RESET_CHARACTER_EXTRA_ITEM, function(arg_41_0, arg_41_1)
		self:ResetCharacterExtraItem(arg_41_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_RESET_TEMP_HIDE_SCENE_ITEMS, function(arg_42_0, arg_42_1)
		self:ResetTempHideSceneItems(arg_42_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE, function(arg_43_0, arg_43_1, arg_43_2, arg_43_3)
		self:SetBlackboardValue(arg_43_1, arg_43_2, arg_43_3)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_SET_HEAD_AIM_IK, function(arg_44_0, arg_44_1, arg_44_2, arg_44_3)
		self:SettingHeadAimIK(arg_44_1, arg_44_2, arg_44_3)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_RESET_HEAD_AIM_IK, function(arg_45_0, arg_45_1)
		self:ResetHeadAimIK(arg_45_1)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_SWITCH_ANIM, function(arg_46_0, arg_46_1, arg_46_2, arg_46_3, arg_46_4)
		self:SwitchAnim(arg_46_1, arg_46_2, arg_46_3, arg_46_4)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_PLAY_SINGLE_ACTION, function(arg_47_0, arg_47_1, arg_47_2, arg_47_3, arg_47_4)
		self:PlaySingleAction(arg_47_1, arg_47_2, arg_47_3, arg_47_4)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_PLAY_FACE_ANIM, function(arg_48_0, arg_48_1, arg_48_2, arg_48_3)
		self:PlayFaceAnim(arg_48_1, arg_48_2, arg_48_3)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_PLAY_SCENE_ITEM_ANIM, function(arg_49_0, arg_49_1, arg_49_2, arg_49_3)
		self:PlaySceneItemAnim(arg_49_1, arg_49_2, arg_49_3)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_SHOW_BLACK_SCREEN, function(arg_50_0, arg_50_1, arg_50_2)
		self:ShowBlackScreen(arg_50_1, arg_50_2)
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_TRIGGER_LADY_DISTANCE, function()
		self:TriggerLadyDistance()
	end)
	self:bind(Dorm3dRoomTemplateScene.EXTRA_CHECK_IN_SECTOR, function()
		self:CheckInSector()
	end)
end

function Dorm3dRoomTemplateScene:initScene()
	local var_53_0, var_53_1 = unpack(string.split(self.dormSceneMgr.sceneInfo, "|"))

	self:ResetSceneStructure((SceneManager.GetSceneByName(var_53_0 .. "_base")))

	self.mainCameraTF = GameObject.Find("BackYardMainCamera").transform
	self.camBrain = self.mainCameraTF:GetComponent(typeof(Cinemachine.CinemachineBrain))
	self.camBrainEvenetHandler = self.mainCameraTF:GetComponent(typeof(CameraBrainEventsHandler))
	self.raycastCamera = self.mainCameraTF:Find("CameraForRaycast"):GetComponent(typeof(Camera))
	self.sceneRaycaster = self.raycastCamera:GetComponent(typeof(UnityEngine.EventSystems.PhysicsRaycaster))
	self.player = GameObject.Find("Player").transform
	self.playerEye = self.player:Find("Eye")
	self.playerFoot = self.player:Find("Foot")

	setActive(self.playerFoot, false)

	self.playerController = self.player:GetComponent(typeof(UnityEngine.CharacterController))
	self.modelRoot = GameObject.Find("scene_root").transform
	self.slotRoot = GameObject.Find("FurnitureSlots").transform

	setActive(self.slotRoot, true)
	tolua.loadassembly("Cinemachine")

	local var_53_2 = GameObject.Find("CM Cameras").transform

	eachChild(var_53_2, function(arg_54_0)
		setActive(arg_54_0, false)
	end)

	self.camBrain.enabled = false
	self.camBrain.enabled = true
	self.cameraAim = var_53_2:Find("Aim Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
	self.cameraAim2 = var_53_2:Find("Aim2 Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
	self.cameraFree = nil
	self.cameraFurnitureWatch = nil
	self.cameraRole = var_53_2:Find("Role Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
	self.cameraRole2 = var_53_2:Find("Role2 Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
	self.cameraGift = var_53_2:Find("Gift Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))

	local var_53_3 = {
		self.cameraAim,
		self.cameraAim2,
		self.cameraRole,
		[Dorm3dRoomTemplateScene.CAMERA.TALK] = var_53_2:Find("Talk Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera)),
		[Dorm3dRoomTemplateScene.CAMERA.GIFT] = self.cameraGift,
		[Dorm3dRoomTemplateScene.CAMERA.ROLE2] = self.cameraRole2
	}

	var_53_3[Dorm3dRoomTemplateScene.CAMERA.PHOTO] = var_53_2:Find("Photo Camera"):GetComponent(typeof(Cinemachine.CinemachineFreeLook))
	var_53_3[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE] = var_53_2:Find("PhotoFree Controller")
	var_53_3[Dorm3dRoomTemplateScene.CAMERA.POV] = var_53_2:Find("FP Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))

	if self.room:isPersonalRoom() then
		var_53_3[Dorm3dRoomTemplateScene.CAMERA.SKIN] = var_53_2:Find("Skin Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera)) or nil
	end

	self.cameras = var_53_3

	setActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]:Find("PhotoFree Camera"), true)

	self.compPovAim = self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]:GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Aim)
	self.cameraRoot = var_53_2
	self.POVOriginalFOV = self:GetPOVFOV()
	self.restrictedBox = GameObject.Find("RestrictedArea").transform

	setActive(self.restrictedBox, false)

	local var_53_5 = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]:GetComponent(typeof(CharacterController)).radius

	self.isMultiFloor = self.restrictedBox.childCount > 2

	local var_53_6 = "Floor"
	local var_53_7 = "Celling"

	if self.isMultiFloor then
		self.restrictedHeightRange = {}

		for iter_53_0 = 0, math.floor(self.restrictedBox.childCount / 2) - 1 do
			table.insert(self.restrictedHeightRange, {
				self.restrictedBox:Find(iter_53_0 == 0 and var_53_6 or var_53_6 .. "_" .. iter_53_0).position.y + var_53_5,
				self.restrictedBox:Find(iter_53_0 == 0 and var_53_7 or var_53_7 .. "_" .. iter_53_0).position.y - var_53_5
			})
		end
	else
		self.restrictedHeightRange = {
			self.restrictedBox:Find(var_53_6).position.y + var_53_5,
			self.restrictedBox:Find(var_53_7).position.y - var_53_5
		}
	end

	self.ladyInterest = GameObject.Find("InterestProxy").transform

	self:InitExtraSystem({
		Dorm3dLightingSystem
	})
	self:SwitchDayNight(self.contextData.timeIndex)

	self.tfCutIn = getSceneRootTFDic(SceneManager.GetSceneByName(var_53_0 .. "_base")).CutIn

	if self.tfCutIn then
		local var_53_8 = {}

		var_53_8.lady = self.tfCutIn:Find("lady"):GetChild(0)
		var_53_8.player = self.tfCutIn:Find("player"):GetChild(0)
		self.modelCutIn = var_53_8

		setActive(self.tfCutIn, false)
	end
end

function Dorm3dRoomTemplateScene:SwitchDayNight(arg_55_1)
	self:emit(Dorm3dLightingSystem.APPLY_DAY_NIGHT, arg_55_1)
end

function Dorm3dRoomTemplateScene:ResetSceneStructure(arg_56_1)
	local var_56_0

	table.IpairsCArray(arg_56_1:GetRootGameObjects(), function(arg_57_0, arg_57_1)
		if arg_57_1.name == "Furnitures" then
			var_56_0 = tf(arg_57_1)

			eachChild(var_56_0, function(arg_58_0)
				local var_58_0 = arg_58_0:Find("FreeLook Camera")

				if var_58_0 then
					setActive(var_58_0, false)
				end

				local var_58_1 = arg_58_0:Find("RoleWatch Camera")

				if var_58_1 then
					setActive(var_58_1, false)
				end

				local var_58_2 = arg_58_0:Find("IKCamera")

				if var_58_2 then
					setActive(var_58_2, false)
				end

				local var_58_3 = arg_58_0:GetComponent(typeof(UnityEngine.Collider))

				if not var_58_3 then
					return
				end

				var_58_3.enabled = false
			end)
		end
	end)
	assert(nil, "Missing Furnitures root in Dorm3D base scene")

	self.posConfigRoot = nil
	self.zoneByName = {}
	self.ikPointByName = {}

	eachChild(self.posConfigRoot, function(arg_59_0)
		((string.match(arg_59_0.name, "^Pos%d+$") or nil) and (self.ikPointByName or self.zoneByName))[arg_59_0.name] = arg_59_0
	end)
end

function Dorm3dRoomTemplateScene:SetFloatEnable(arg_60_1)
	self.enableFloatUpdate = arg_60_1

	if arg_60_1 then
		self:UpdateFloatPosition()
	end
end

function Dorm3dRoomTemplateScene:UpdateFloatPosition()
	setLocalPosition(self.rtFloatPage:Find("lady"), (self:GetLocalPosition(self:GetScreenPosition(self:GetCurrentLadyEnv().ladyHeadCenter.position + Vector3(0, 0.2, 0)), self.rtFloatPage)))
end

function Dorm3dRoomTemplateScene:LoadCharacter(arg_62_1, arg_62_2)
	self.ladyDict = {}
	self.skinDict = {}

	local var_62_0 = {}

	for iter_62_0, iter_62_1 in ipairs(arg_62_1) do
		table.insert(var_62_0, function(arg_63_0)
			self:LoadSingleCharacter(iter_62_1, arg_63_0)
		end)
	end

	parallelAsync(var_62_0, arg_62_2)
end

function Dorm3dRoomTemplateScene:LoadCharacterAdditionally(arg_64_1, arg_64_2)
	local var_64_0 = {}

	for iter_64_0, iter_64_1 in ipairs(arg_64_1) do
		table.insert(var_64_0, function(arg_65_0)
			self:LoadSingleCharacter(iter_64_1, function()
				self:InitCharacter(self.ladyDict[iter_64_1], iter_64_1)
				arg_65_0()
			end)
		end)
	end

	parallelAsync(var_64_0, arg_64_2)
end

function Dorm3dRoomTemplateScene:LoadSingleCharacter(arg_67_1, arg_67_2)
	local var_67_0 = {}
	local var_67_1 = LadyEnv.New(self)

	self.ladyDict[arg_67_1] = var_67_1

	local var_67_2 = getProxy(ApartmentProxy)
	local var_67_3 = var_67_2:getApartment(arg_67_1)
	local var_67_4 = var_67_3:getConfig("asset_name")
	local var_67_5 = var_67_3:GetSkinModelID(self.room:getConfig("tag"))
	local var_67_6 = Dorm3dSkin.New({
		configId = var_67_2
	}):GetModelName()

	assert(var_67_6)
	table.insert(var_67_0, function(arg_68_0)
		self.hxHelper:LoadMaterials(arg_67_1, arg_68_0)
	end)

	var_67_1.skinId = var_67_5
	var_67_1.skinIdList = {
		var_67_5
	}

	table.insert(var_67_0, function(arg_69_0)
		self.loader:GetPrefab(string.format("dorm3d/character/%s/prefabs/%s", var_67_4, var_67_6), "", function(arg_70_0)
			self:MoveObjectToBaseScene(arg_70_0)

			var_67_1.ladyGameObject = arg_70_0
			self.skinDict[var_67_5] = {
				ladyGameObject = arg_70_0
			}

			arg_69_0()
		end)
	end)

	if self.room:isPersonalRoom() then
		for iter_67_0, iter_67_1 in ipairs(var_67_3:GetAllModelIds()) do
			if not table.contains(var_67_1.skinIdList, iter_67_1) then
				local var_67_7 = Dorm3dSkin.New({
					configId = iter_67_1
				})

				if not var_67_7:IsShow() then
					if iter_67_1 == 199033 then
						local var_67_9 = string.format("dorm3d/character/%s/prefabs/%s", var_67_4, (var_67_7:GetModelName()))

						if checkABExist(var_67_9) then
							table.insert(var_67_1.skinIdList, iter_67_1)
							table.insert(var_67_0, function(arg_71_0)
								self.loader:GetPrefab(var_67_9, "", function(arg_72_0)
									self:MoveObjectToBaseScene(arg_72_0)

									self.skinDict[iter_67_1] = {
										ladyGameObject = arg_72_0
									}
									GetComponent(arg_72_0, "GraphOwner").enabled = false

									setActive(arg_72_0, false)
									arg_71_0()
								end)
							end)
						end
					end
				end
			end
		end
	end

	if self.contextData.pendingDic[arg_67_1] then
		local var_67_10 = pg.dorm3d_welcome[self.contextData.pendingDic[arg_67_1]]

		if pg.dorm3d_welcome[self.contextData.pendingDic[arg_67_1]].item_prefab ~= "" then
			table.insert(var_67_0, function(arg_73_0)
				self.loader:GetPrefab(string.lower("dorm3d/furniture/item/" .. var_67_10.item_prefab), "", function(arg_74_0)
					self:MoveObjectToBaseScene(arg_74_0)

					var_67_1.tfPendintItem = arg_74_0.transform

					setActive(arg_74_0, false)
					arg_73_0()
				end)
			end)
		end
	end

	parallelAsync(var_67_0, arg_67_2)
end

function Dorm3dRoomTemplateScene:HXCharacter(arg_75_1, arg_75_2)
	self.hxHelper:Apply(arg_75_1, arg_75_2)
end

function Dorm3dRoomTemplateScene:InitHolyLight()
	local var_76_0 = {}

	for iter_76_0, iter_76_1 in pairs(self.ladyDict) do
		table.insert(var_76_0, iter_76_1.lady)
	end

	Dorm3dHxHelper.ShowHolyLight(var_76_0, self.holyLightRoot, true)
end

function Dorm3dRoomTemplateScene:InitCharacter(arg_77_1, arg_77_2)
	arg_77_1:InitCharacter(arg_77_2)
	Dorm3dHxHelper.HideCharacterPart(arg_77_1.lady)
	self:HXCharacter(arg_77_1.lady, arg_77_1.skinId)
	self:SetLadyActiveZone(arg_77_2, self:GetLadyBaseZone(arg_77_2))
	self:ChangeCharacterPosition(arg_77_1)
end

function Dorm3dRoomTemplateScene:SetCameraLady(arg_78_1)
	self.cameraAim2.LookAt = arg_78_1.ladyInterestRoot
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.TALK].Follow = arg_78_1.ladyInterestRoot
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.TALK].LookAt = arg_78_1.ladyInterestRoot
	self.cameraGift.Follow = self.ladyInterest
	self.cameraGift.LookAt = self.ladyInterest
	self.cameraRole2.LookAt = arg_78_1.ladyInterestRoot
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].Follow = self.ladyInterest
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].LookAt = self.ladyInterest
end

function Dorm3dRoomTemplateScene:initNodeCanvas()
	local var_79_0 = pg.NodeCanvasMgr.GetInstance()

	var_79_0:Active()
	var_79_0:RegisterFunc("DistanceTrigger", function(arg_80_0)
		self:emit(Dorm3dRoomTemplateScene.DISTANCE_TRIGGER, arg_80_0, self.ladyDict[arg_80_0].dis)
	end)
	var_79_0:RegisterFunc("ShortWaitAction", function(arg_81_0)
		self:DoShortWait(arg_81_0)
	end)
	var_79_0:RegisterFunc("WatchShortWaitAction", function(arg_82_0)
		self:DoShortWait(arg_82_0)
	end)
	var_79_0:RegisterFunc("WalkDistanceTrigger", function(arg_83_0)
		self:emit(Dorm3dRoomTemplateScene.WALK_DISTANCE_TRIGGER, arg_83_0, self.ladyDict[arg_83_0].dis)
	end)
	var_79_0:RegisterFunc("ChangeWatch", function(arg_84_0)
		self:emit(Dorm3dRoomTemplateScene.CHANGE_WATCH, arg_84_0)
	end)
end

function Dorm3dRoomTemplateScene:SetAllBlackbloardValue(arg_85_1, arg_85_2)
	self[arg_85_1] = arg_85_2

	for iter_85_0, iter_85_1 in pairs(self.ladyDict) do
		self:SetBlackboardValue(iter_85_1, arg_85_1, arg_85_2)
	end
end

function Dorm3dRoomTemplateScene:SetBlackboardValue(arg_86_1, arg_86_2, arg_86_3)
	arg_86_1:SetBlackboardValue(arg_86_2, arg_86_3)
end

function Dorm3dRoomTemplateScene:GetBlackboardValue(arg_87_1, arg_87_2)
	return arg_87_1:GetBlackboardValue(arg_87_2)
end

function Dorm3dRoomTemplateScene:didEnter()
	local var_88_0 = -21.6 / Screen.height

	self.joystickDelta = Vector2.zero
	self.joystickTimer = FrameTimer.New(function()
		local function var_89_0(arg_90_0, arg_90_1, arg_90_2)
			arg_90_0[arg_90_1].m_InputAxisValue = arg_90_2
			arg_90_0[arg_90_1] = arg_90_0[arg_90_1]
		end

		if self.surroudCamera and not self.pinchMode then
			var_89_0(self.surroudCamera, "m_XAxis", (self.joystickDelta * var_88_0).x)
			var_89_0(self.surroudCamera, "m_YAxis", (self.joystickDelta * var_88_0).y)
		elseif self.furniturePOV and self.cameras[Dorm3dRoomTemplateScene.CAMERA.FURNITURE_WATCH] and isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.FURNITURE_WATCH]) then
			var_89_0(self.furniturePOV, "m_HorizontalAxis", (self.joystickDelta * var_88_0).x)
			var_89_0(self.furniturePOV, "m_VerticalAxis", (self.joystickDelta * var_88_0).y)
		end

		self.joystickDelta = Vector2.zero
	end, 1, -1)

	self.joystickTimer:Start()

	local var_88_1 = 1.75

	self.moveStickTimer = FrameTimer.New(function()
		if not self.moveStickDraging then
			return
		end

		local var_91_0 = (self.moveStickPosition - self.moveStickOrigin):ClampMagnitude(200)

		self.moveStickPosition = self.moveStickOrigin + var_91_0

		local var_91_1 = self.mainCameraTF:TransformDirection((Vector3.New((var_91_0 / 200).x, 0, (var_91_0 / 200).y)))

		var_91_1.y = 0

		local var_91_2 = var_91_1:Normalize()

		var_91_2:Mul(var_88_1)

		if isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]) then
			self.playerController:SimpleMove(var_91_2)

			self.tweenFOV = true
		elseif isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]) then
			self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]:GetComponent(typeof(UnityEngine.CharacterController)):Move(var_91_2 * Time.deltaTime)
			self:emit(Dorm3dPhotoMediator.CAMERA_STICK_MOVE, (var_91_0 / 200):Normalize())
			onNextTick(function()
				local var_92_0 = self:GetRestritedHeightRange()

				self:emit(Dorm3dPhotoMediator.CAMERA_LIFT_CHANGED, (math.InverseLerp(var_92_0[1], var_92_0[2], self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE].position.y)))
			end)
		end
	end, 1, -1)

	self.moveStickTimer:Start()

	self.pinchMode = false
	self.pinchSize = 0
	self.pinchValue = 1
	self.pinchNodeOrder = 1

	GlobalClickEventMgr.Inst:AddBeginPinchFunc(function(arg_93_0, arg_93_1)
		if self.surroudCamera and isActive(self.surroudCamera) then
			self.pinchMode = true
			self.pinchSize = (arg_93_0 - arg_93_1):Magnitude()
			self.pinchNodeOrder = arg_93_1.x < arg_93_0.x and -1 or 1

			return
		end

		if isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]) then
			if (arg_93_0 - arg_93_1):Magnitude() < Screen.height * 0.5 then
				self.pinchMode = true
				self.pinchSize = (arg_93_0 - arg_93_1):Magnitude()
				self.pinchNodeOrder = arg_93_1.x < arg_93_0.x and -1 or 1
			end

			return
		end
	end)

	local var_88_3 = ((IsUnityEditor or nil) and 0.1) * 1080 / Screen.height

	GlobalClickEventMgr.Inst:AddPinchFunc(function(arg_94_0, arg_94_1)
		if not self.pinchMode then
			return
		end

		local var_94_0 = (arg_94_0 - arg_94_1):Magnitude()

		if isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]) then
			self.pinchValue = math.clamp(self.pinchValue + (self.pinchSize - var_94_0) * var_88_3 * (self.pinchNodeOrder * (arg_94_1.x < arg_94_0.x and -1 or 1)), 0.5, 1)
			self.pinchSize = var_94_0

			self:SetPOVFOV(self.POVOriginalFOV * self.pinchValue)

			self.tweenFOV = nil

			return
		end

		if isActive(self.surroudCamera) and self.surroudCamera == self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO] then
			self:SetPinchValue(math.clamp(self.pinchValue + (self.pinchSize - var_94_0) * var_88_3 * (self.pinchNodeOrder * (arg_94_1.x < arg_94_0.x and -1 or 1)), 0.5, 1))

			self.pinchSize = var_94_0

			return
		end
	end)
	GlobalClickEventMgr.Inst:AddEndPinchFunc(function()
		self.pinchMode = false
		self.pinchSize = 0
	end)

	self.cameraBlendCallbacks = {}
	self.activeCMCamera = nil

	function self.camBrainEvenetHandler.OnBlendStarted(arg_96_0)
		if self.activeCMCamera then
			self:OnCameraBlendFinished(self.activeCMCamera)
		end

		self.activeCMCamera = self.camBrain.ActiveVirtualCamera
	end

	function self.camBrainEvenetHandler.OnBlendFinished(arg_97_0)
		self.activeCMCamera = nil

		self:OnCameraBlendFinished(arg_97_0)
	end

	self.expressionDict = {}

	self:OverlayPanel(self.blockLayer)
	self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV])
	self:InitExtraSystem()

	local var_88_4
	local var_88_5
	local var_88_6 = self.resumeCallback

	function self.resumeCallback()
		var_88_5 = true

		if var_88_4 then
			existCall(var_88_6)
		end
	end

	self:RefreshSlots(nil, function()
		var_88_4 = true

		if var_88_5 then
			existCall(var_88_6)
		end
	end)

	self.updateHandler = UpdateBeat:CreateListener(function()
		xpcall(function()
			self:Update()
		end, function(...)
			errorMsg(debug.traceback(...))
		end)
	end)

	UpdateBeat:AddListener(self.updateHandler)
end

function Dorm3dRoomTemplateScene:InitData()
	if not self.contextData.ladyZone then
		self.contextData.ladyZone = {}

		local var_103_0
		local var_103_1 = self.room:getConfig("default_zone")

		for iter_103_0, iter_103_1 in ipairs(var_103_1) do
			self.contextData.ladyZone[iter_103_1[1]] = iter_103_1[2]

			if table.contains(self.contextData.groupIds, iter_103_1[1]) then
				var_103_0 = var_103_0 or self.contextData.ladyZone[iter_103_1[1]]
			end
		end

		self.contextData.currentZoneNodeName = var_103_0 or var_103_1[1][2]
	end

	self.zoneDatas = _.select(self.room:GetZones(), function(arg_104_0)
		return not arg_104_0:IsGlobal()
	end)
	self.ladyActiveZone = {}
	self.activeLady = {}
end

function Dorm3dRoomTemplateScene:Update()
	self.raycastCamera.fieldOfView = self.mainCameraTF:GetComponent(typeof(Camera)).fieldOfView

	if self.tweenFOV then
		self.pinchValue = Mathf.Lerp(self.pinchValue, 1, (Damp(1, 1, Time.deltaTime)))

		self:SetPOVFOV(self.POVOriginalFOV * self.pinchValue)

		if self.pinchValue > 0.99 then
			self.tweenFOV = nil
		end
	end

	if isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]) then
		self:TriggerLadyDistance()
	end

	if self.enableFloatUpdate then
		self:UpdateFloatPosition()
	end

	self:CheckInSector()

	if self.systemManager then
		self.systemManager:Update(Time.deltaTime)
	end
end

function Dorm3dRoomTemplateScene:CheckInSector()
	if not isActive(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]) then
		return
	end

	local var_106_0 = self.mainCameraTF.position

	for iter_106_0, iter_106_1 in pairs(self.ladyDict) do
		if iter_106_1.lady then
			local var_106_1 = tobool(self.activeLady[iter_106_0])

			if var_106_1 ~= tobool(Dorm3dRoomTemplateScene.IsPointInSector({
				Radius = 2,
				Angle = 120,
				Position = iter_106_1.lady.position,
				Rotation = iter_106_1.lady.rotation
			}, var_106_0)) then
				self.activeLady[iter_106_0] = not var_106_1

				self:emit(Dorm3dRoomTemplateScene.ON_ENTER_SECTOR, iter_106_0)
			end
		end
	end
end

function Dorm3dRoomTemplateScene:TriggerLadyDistance()
	for iter_107_0, iter_107_1 in pairs(self.ladyDict) do
		if iter_107_1.lady then
			iter_107_1.dis = (iter_107_1.lady.position - self.player.position).magnitude

			if self:GetBlackboardValue(iter_107_1, "inPending") then
				if (Dorm3dRoomTemplateScene.POV_PENDING_CLOSE_DISTANCE or Dorm3dRoomTemplateScene.POV_CLOSE_DISTANCE) > iter_107_1.dis ~= self:GetBlackboardValue(iter_107_1, "inDistance") then
					self:SetBlackboardValue(iter_107_1, "inDistance", iter_107_1.dis < Dorm3dRoomTemplateScene.POV_CLOSE_DISTANCE)
					self:emit(Dorm3dRoomTemplateScene.ON_CHANGE_DISTANCE, iter_107_0, iter_107_1.dis < Dorm3dRoomTemplateScene.POV_CLOSE_DISTANCE)
				end
			end
		end
	end
end

function Dorm3dRoomTemplateScene:OnStickMove(arg_108_1)
	self.joystickDelta = arg_108_1
end

function Dorm3dRoomTemplateScene:SetPinchValue(arg_109_1)
	self.pinchValue = arg_109_1

	self:SetCameraObrits()
end

function Dorm3dRoomTemplateScene:GetPOVFOV()
	return ReflectionHelp.RefGetField(typeof("Cinemachine.LensSettings"), "FieldOfView", self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV].m_Lens)
end

function Dorm3dRoomTemplateScene:SetPOVFOV(arg_111_1)
	ReflectionHelp.RefSetField(typeof("Cinemachine.LensSettings"), "FieldOfView", self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV].m_Lens, arg_111_1)

	self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV].m_Lens = self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV].m_Lens
end

function Dorm3dRoomTemplateScene:RefreshSlots(arg_112_1, arg_112_2)
	self:emit(FurnitureSystem.REFRESH_SLOTS, arg_112_1, arg_112_2)
end

function Dorm3dRoomTemplateScene:RefreshSlotsEmpty(arg_113_1)
	self:emit(FurnitureSystem.REFRESH_SLOTS_EMPTY, arg_113_1)
end

function Dorm3dRoomTemplateScene:CheckSceneItemActiveByPath(arg_114_1)
	return self:CheckSceneItemActive((self:GetSceneItem(arg_114_1)))
end

function Dorm3dRoomTemplateScene:CheckSceneItemActive(arg_115_1)
	local var_115_0 = self:GetExtraSystem(FurnitureSystem)

	assert(var_115_0, "FurnitureSystem is not initialized")

	return var_115_0:CheckSceneItemActive(arg_115_1)
end

function Dorm3dRoomTemplateScene:ChangeCharacterPosition(arg_116_1)
	self:ResetCharPoint(arg_116_1, self:GetLadyActiveZone((self:GetBlackboardValue(arg_116_1, "groupId"))))
	self:SyncInterestTransform(arg_116_1)
end

function Dorm3dRoomTemplateScene:SyncCurrentInterestTransform()
	self:SyncInterestTransform((self:GetCurrentLadyEnv()))
end

function Dorm3dRoomTemplateScene:SyncInterestTransform(arg_118_1)
	self.ladyInterest.position = arg_118_1.ladyInterestRoot.position
	self.ladyInterest.rotation = arg_118_1.ladyInterestRoot.rotation
end

function Dorm3dRoomTemplateScene:SyncInterestTransformByTf(arg_119_1)
	self.ladyInterest.position = arg_119_1.position
	self.ladyInterest.rotation = arg_119_1.rotation
end

function Dorm3dRoomTemplateScene:ChangePlayerPosition(arg_120_1)
	arg_120_1 = arg_120_1 or self.contextData.currentZoneNodeName
	self.player.position = (self.zoneByName[arg_120_1] or self.ikPointByName[arg_120_1]):Find("PlayerPoint").position
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV].transform.position = self.playerEye.position

	local var_120_0 = Quaternion.LookRotation(self.ladyInterest.position - self.playerEye.position).eulerAngles

	self.compPovAim.m_HorizontalAxis.Value = self:GetNearestAngle(var_120_0.y, self.compPovAim.m_HorizontalAxis.m_MinValue, self.compPovAim.m_HorizontalAxis.m_MaxValue)
	self.compPovAim.m_HorizontalAxis = self.compPovAim.m_HorizontalAxis
	self.compPovAim.m_VerticalAxis.Value = var_120_0.x
	self.compPovAim.m_VerticalAxis = self.compPovAim.m_VerticalAxis
end

function Dorm3dRoomTemplateScene:GetCurrentZoneNodeName()
	return self.contextData.currentZoneNodeName
end

function Dorm3dRoomTemplateScene:GetLadyBaseZone(arg_122_1)
	return self.contextData.ladyZone[arg_122_1]
end

function Dorm3dRoomTemplateScene:GetLadyActiveZone(arg_123_1)
	return self.ladyActiveZone[arg_123_1] or self:GetLadyBaseZone(arg_123_1)
end

function Dorm3dRoomTemplateScene:SetLadyActiveZone(arg_124_1, arg_124_2)
	self.ladyActiveZone[arg_124_1] = arg_124_2 or self:GetLadyBaseZone(arg_124_1)
end

function Dorm3dRoomTemplateScene:GetZoneByName(arg_125_1)
	return self.zoneByName[arg_125_1]
end

function Dorm3dRoomTemplateScene:GetIKPointByName(arg_126_1)
	return self.ikPointByName[arg_126_1]
end

function Dorm3dRoomTemplateScene:GetSlotByID(arg_127_1)
	local var_127_0 = self:GetExtraSystem(FurnitureSystem)

	assert(var_127_0, "FurnitureSystem is not initialized")

	return var_127_0:GetSlotByID(arg_127_1)
end

function Dorm3dRoomTemplateScene:GetScreenPosition(arg_128_1, arg_128_2)
	arg_128_2 = arg_128_2 or self.raycastCamera

	local var_128_0 = arg_128_2:WorldToScreenPoint(arg_128_1)

	if var_128_0.z < 0 then
		var_128_0.x = var_128_0.x + (var_128_0.x < 0 and -1 or 1) * Screen.width
		var_128_0.y = var_128_0.y + (var_128_0.y < 0 and -1 or 1) * Screen.height
		var_128_0.z = -var_128_0.z
	end

	return var_128_0
end

function Dorm3dRoomTemplateScene:GetLocalPosition(arg_129_1, arg_129_2)
	return LuaHelper.ScreenToLocal(arg_129_2, arg_129_1, pg.UIMgr.GetInstance().uiCameraComp)
end

function Dorm3dRoomTemplateScene:GetModelRoot()
	return self.modelRoot
end

function Dorm3dRoomTemplateScene:ShiftZoneSafe(arg_131_1)
	local var_131_0 = {}

	if self.room:isPersonalRoom() and not self:GetBlackboardValue(self:GetCurrentLadyEnv(), "inPending") then
		table.insert(var_131_0, function(arg_132_0)
			self:OutOfLazy(self.apartment:GetConfigID(), arg_132_0)
		end)
	end

	table.insert(var_131_0, function(arg_133_0)
		self:ShiftZone(arg_131_1, arg_133_0)
	end)
	seriesAsync(var_131_0, function()
		self:CheckQueue()
	end)
end

function Dorm3dRoomTemplateScene:ShiftZone(arg_135_1, arg_135_2)
	local var_135_0 = self:GetZoneByName(arg_135_1)

	if not var_135_0 then
		errorMsg(arg_135_1 .. " Not Find")
		existCall(arg_135_2)

		return
	end

	seriesAsync({
		function(arg_136_0)
			self:emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
			self:ShowBlackScreen(true, arg_136_0)
		end,
		function(arg_137_0)
			if self.shiftLady or self.room:isPersonalRoom() then
				local var_137_0 = self.shiftLady or self.apartment:GetConfigID()

				self.shiftLady = nil
				self.contextData.ladyZone[var_137_0] = var_135_0.name

				local var_137_1 = self.ladyDict[var_137_0]

				self:SetLadyActiveZone(var_137_0, self:GetLadyBaseZone(var_137_0))

				if self:GetBlackboardValue(self.ladyDict[var_137_0], "inPending") then
					self:SetOutPending(self.ladyDict[var_137_0])
					self:SwitchAnim(self.ladyDict[var_137_0], Dorm3dRoomTemplateScene.ANIM.IDLE)
					onNextTick(function()
						self:ChangeCharacterPosition(var_137_1)
						arg_137_0()
					end)
				else
					self:ChangeCharacterPosition(self.ladyDict[var_137_0])
					arg_137_0()
				end
			else
				arg_137_0()
			end
		end,
		function(arg_139_0)
			self.contextData.currentZoneNodeName = var_135_0.name

			if SlideExtraSystem.IsOpen(self.room) and self.contextData.currentZoneNodeName == SlideConst.SLIDE_ZONE then
				self:SyncInterestTransformByTf(var_135_0.transform:Find("StayPoint"))
			elseif not self.apartment then
				for iter_139_0, iter_139_1 in pairs(self.ladyDict) do
					if self:GetLadyBaseZone(iter_139_0) == self.contextData.currentZoneNodeName then
						self:SyncInterestTransform(iter_139_1)

						break
					end
				end
			end

			self:ChangePlayerPosition()
			self:TriggerLadyDistance()
			self:CheckInSector()
			arg_139_0()
		end,
		function(arg_140_0)
			self:UpdateZoneList()
			self:ShowBlackScreen(false, arg_140_0)
		end,
		function(arg_141_0)
			self:emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
			arg_141_0()
		end
	}, arg_135_2)
end

function Dorm3dRoomTemplateScene:ActiveCamera(arg_142_1)
	table.Foreach(self.cameras, function(arg_143_0, arg_143_1)
		setActive(arg_143_1, arg_143_1 == arg_142_1)
	end)

	if isActive(arg_142_1) then
		self:OnCameraBlendFinished(arg_142_1)
	end
end

function Dorm3dRoomTemplateScene:ActiveCameraByName(arg_144_1)
	local var_144_0 = self.cameraRoot:Find(arg_144_1)

	assert(var_144_0, "ActiveCameraByName: " .. arg_144_1 .. " not found")
	table.Foreach(self.cameras, function(arg_145_0, arg_145_1)
		setActive(arg_145_1, false)
	end)
	setActive(var_144_0, true)

	self.cameras[Dorm3dRoomTemplateScene.CAMERA.CUSTOM] = var_144_0:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
end

function Dorm3dRoomTemplateScene:ShowBlackScreen(arg_146_1, arg_146_2)
	local var_146_0 = self.blackSceneInfo or {
		color = "#000000",
		time = 0.3,
		delay = arg_146_1 and 0 or 0.3
	}

	setImageColor(self.blackLayer, Color.NewHex(var_146_0.color))
	setActive(self.blackLayer, true)
	setCanvasGroupAlpha(self.blackLayer, arg_146_1 and 0 or 1)
	self:managedTween(LeanTween.alphaCanvas, function()
		if not arg_146_1 then
			setActive(self.blackLayer, false)
		end

		existCall(arg_146_2)
	end, GetComponent(self.blackLayer, typeof(CanvasGroup)), arg_146_1 and 1 or 0, var_146_0.time):setDelay(var_146_0.delay)
end

function Dorm3dRoomTemplateScene:RegisterOrbits(arg_148_1)
	self = self.scene
	self.orbits = {
		original = arg_148_1.m_Orbits
	}
	self.orbits.current = _.range(3):map(function(arg_149_0)
		return Cinemachine.CinemachineFreeLook.Orbit.New(self.orbits.original[arg_149_0 - 1].m_Height, self.orbits.original[arg_149_0 - 1].m_Radius)
	end)
	self.surroudCamera = arg_148_1
end

function Dorm3dRoomTemplateScene:SetCameraObrits()
	self = self.scene

	if not self.surroudCamera then
		return
	end

	local var_150_0 = self.orbits.original[1]

	for iter_150_0 = 0, #self.orbits.current - 1 do
		self.orbits.current[iter_150_0 + 1].m_Height = math.lerp(var_150_0.m_Height, self.orbits.original[iter_150_0].m_Height, self.pinchValue)
		self.orbits.current[iter_150_0 + 1].m_Radius = self.orbits.original[iter_150_0].m_Radius * self.pinchValue
	end

	self.surroudCamera.m_Orbits = self.orbits.current
end

function Dorm3dRoomTemplateScene:RevertCameraOrbit()
	self = self.scene

	if not self.surroudCamera then
		return
	end

	for iter_151_0 = 0, #self.orbits.current - 1 do
		self.orbits.current[iter_151_0 + 1].m_Height = self.orbits.original[iter_151_0].m_Height
		self.orbits.current[iter_151_0 + 1].m_Radius = self.orbits.original[iter_151_0].m_Radius
	end

	self.surroudCamera.m_Orbits = self.orbits.current
	self.surroudCamera = nil
end

function Dorm3dRoomTemplateScene:ActiveStateCamera(arg_152_1, arg_152_2)
	local var_152_0 = {
		base = function(arg_153_0)
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV], arg_153_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV])
		end,
		watch = function(arg_154_0)
			assert(self.apartment)
			self:SyncInterestTransform(self:GetCurrentLadyEnv())
			self:SetCameraLady(self:GetCurrentLadyEnv())
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.ROLE], arg_154_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.ROLE])
		end,
		walk = function(arg_155_0)
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV], arg_155_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV])
		end,
		ik = function(arg_156_0)
			arg_156_0()
		end,
		gift = function(arg_157_0)
			assert(self.apartment)
			self:SetCameraLady(self:GetCurrentLadyEnv())
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.GIFT], arg_157_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.GIFT])
		end,
		standby = function(arg_158_0)
			assert(self.apartment)
			self:SetCameraLady(self:GetCurrentLadyEnv())

			self.cameras[Dorm3dRoomTemplateScene.CAMERA.ROLE2].transform.position = self.cameraRole.transform.position

			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.ROLE2], arg_158_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.ROLE2])
		end,
		talk = function(arg_159_0)
			assert(self.apartment)
			self:SetCameraLady(self:GetCurrentLadyEnv())
			self:SyncInterestTransform(self:GetCurrentLadyEnv())
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.TALK], arg_159_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.TALK])
		end
	}
	local var_152_1 = {}

	table.insert(var_152_1, function(arg_160_0)
		switch(arg_152_1, var_152_0, arg_160_0, arg_160_0)
	end)
	seriesAsync(var_152_1, arg_152_2)
end

function Dorm3dRoomTemplateScene:GetSceneItem(arg_161_1)
	local var_161_0

	if string.find(arg_161_1, "FurnitureSlots/") == 1 then
		arg_161_1 = string.gsub(arg_161_1, "^FurnitureSlots/", "", 1)
		var_161_0 = self.slotRoot:Find(arg_161_1)
	else
		var_161_0 = self.modelRoot:Find(arg_161_1)
	end

	if not var_161_0 then
		warning(string.format("Missing scene item path: %s", arg_161_1))
	end

	return var_161_0
end

function Dorm3dRoomTemplateScene:SetSceneAnimSpeed(arg_162_1, arg_162_2)
	table.Ipairs(arg_162_1 or {}, function(arg_163_0, arg_163_1)
		if self.sceneAnimatorDict[arg_163_1] then
			self.sceneAnimatorDict[arg_163_1].animator.speed = arg_162_2
		end
	end)
end

function Dorm3dRoomTemplateScene:SetExtraAnimSpeed(arg_164_1, arg_164_2)
	table.Ipairs(arg_164_1 or {}, function(arg_165_0, arg_165_1)
		if self.extraItems and self.extraItems[arg_165_1[1]] then
			self.extraItems[arg_165_1[1]].trans:GetComponent(typeof(Animator)).speed = arg_164_2
		end
	end)
end

function Dorm3dRoomTemplateScene:PlayEnterSceneAnim(arg_166_1, arg_166_2, arg_166_3)
	arg_166_3 = arg_166_3 or 1

	local var_166_0 = {}

	if arg_166_1 and #arg_166_1 > 0 then
		table.Ipairs(arg_166_1, function(arg_167_0, arg_167_1)
			self:PlaySceneItemAnim(arg_167_1[1], arg_167_1[2], arg_166_2)
			self:SetSceneAnimSpeed({
				arg_167_1[1]
			}, arg_166_3)
			table.insert(var_166_0, arg_167_1[1])
		end)
	end

	self:ResetSceneItemAnimators(var_166_0)
end

function Dorm3dRoomTemplateScene:PlayEnterExtraItem(arg_168_1, arg_168_2, arg_168_3, arg_168_4)
	arg_168_3 = arg_168_3 or 1

	local var_168_0 = {}

	if arg_168_2 and #arg_168_2 > 0 then
		table.Ipairs(arg_168_2, function(arg_169_0, arg_169_1)
			self:LoadCharacterExtraItem(arg_168_1, arg_169_1[1], arg_169_1[2], arg_169_1[3] and Vector3.New(unpack(arg_169_1[3])), arg_169_1[4] and Quaternion.Euler(unpack(arg_169_1[4])), (#arg_169_1 > 4 or nil) and (arg_169_1[5] or nil), arg_168_3, arg_168_4)
			table.insert(var_168_0, arg_169_1[1])
		end)
	end

	self:ResetCharacterExtraItem(var_168_0)
end

function Dorm3dRoomTemplateScene:HideSceneItem(arg_170_1)
	if arg_170_1 and #arg_170_1 > 0 then
		if self.tempHideSceneItems and #self.tempHideSceneItems > 0 then
			self:ResetTempHideSceneItems(arg_170_1)
		end

		self.tempHideSceneItems = {}

		table.Ipairs(arg_170_1, function(arg_171_0, arg_171_1)
			setActive(self:GetSceneItem(arg_171_1), false)
			table.insert(self.tempHideSceneItems, arg_171_1)
		end)
	end
end

function Dorm3dRoomTemplateScene:ResetTempHideSceneItems(arg_172_1)
	arg_172_1 = arg_172_1 or {}

	if self.tempHideSceneItems and #self.tempHideSceneItems > 0 then
		table.Ipairs(self.tempHideSceneItems, function(arg_173_0, arg_173_1)
			if table.contains(arg_172_1, arg_173_1) then
				return
			end

			setActive(self:GetSceneItem(arg_173_1), true)
		end)

		self.tempHideSceneItems = nil
	end
end

function Dorm3dRoomTemplateScene:EnableCurrentHeadIK(arg_174_1)
	self:EnableHeadIK(self:GetCurrentLadyEnv(), arg_174_1)
end

function Dorm3dRoomTemplateScene:EnableHeadIK(arg_175_1, arg_175_2)
	arg_175_1.ladyHeadIKComp.enableIk = arg_175_2
end

function Dorm3dRoomTemplateScene:SettingHeadAimIK(arg_176_1, arg_176_2, arg_176_3)
	local var_176_0

	if arg_176_2[1] == 0 then
		self:EnableHeadIK(arg_176_1, false)

		return
	elseif arg_176_2[1] == 1 then
		self:EnableHeadIK(arg_176_1, true)

		var_176_0 = self.mainCameraTF:Find("AimTarget")
	elseif arg_176_2[1] == 2 then
		self:EnableHeadIK(arg_176_1, true)
		table.IpairsCArray(arg_176_1.lady:GetComponentsInChildren(typeof(Transform), true), function(arg_177_0, arg_177_1)
			if arg_177_1.name ~= arg_176_2[2] then
				return
			end

			var_176_0 = arg_177_1
		end)
	end

	arg_176_1.ladyHeadIKComp.AimTarget = var_176_0

	if not arg_176_3 and arg_176_2[3] then
		arg_176_1.ladyHeadIKComp.BodyWeight = arg_176_2[3]
	end

	if not arg_176_3 and arg_176_2[4] then
		arg_176_1.ladyHeadIKComp.HeadWeight = arg_176_2[4]
	end
end

function Dorm3dRoomTemplateScene:ResetHeadAimIK(arg_178_1)
	self:EnableHeadIK(arg_178_1, true)

	arg_178_1.ladyHeadIKComp.AimTarget = self.mainCameraTF:Find("AimTarget")
	arg_178_1.ladyHeadIKComp.HeadWeight = arg_178_1.ladyHeadIKData.HeadWeight
	arg_178_1.ladyHeadIKComp.BodyWeight = arg_178_1.ladyHeadIKData.BodyWeight
end

function Dorm3dRoomTemplateScene:HideCharacter(arg_179_1)
	for iter_179_0, iter_179_1 in pairs(self.ladyDict) do
		if iter_179_0 ~= arg_179_1 then
			self:HideCharacterBylayer(iter_179_1)
		end
	end
end

function Dorm3dRoomTemplateScene:RevertCharacter(arg_180_1)
	for iter_180_0, iter_180_1 in pairs(self.ladyDict) do
		if iter_180_0 ~= arg_180_1 then
			self:RevertCharacterBylayer(iter_180_1)
		end
	end
end

function Dorm3dRoomTemplateScene:HideCharacterBylayer(arg_181_1)
	local var_181_0 = arg_181_1.lady:Find("all")

	for iter_181_0 = 0, var_181_0.childCount - 1 do
		local var_181_1 = var_181_0:GetChild(iter_181_0)

		if var_181_1.name ~= "Bip001" then
			pg.ViewUtils.SetLayer(var_181_1, Layer.UIHidden)
		end
	end

	if arg_181_1.tfPendintItem then
		pg.ViewUtils.SetLayer(arg_181_1.tfPendintItem, Layer.UIHidden)
	end

	if arg_181_1.ladyWatchFloat then
		pg.ViewUtils.SetLayer(arg_181_1.ladyWatchFloat, Layer.UIHidden)
	end

	Dorm3dHxHelper.SetModelHolyLightActive(arg_181_1.lady, self.holyLightRoot, false)
end

function Dorm3dRoomTemplateScene:RevertCharacterBylayer(arg_182_1)
	local var_182_0 = arg_182_1.lady:Find("all")

	for iter_182_0 = 0, var_182_0.childCount - 1 do
		local var_182_1 = var_182_0:GetChild(iter_182_0)

		if var_182_1.name ~= "Bip001" then
			pg.ViewUtils.SetLayer(var_182_1, Layer.Character3D)
		end
	end

	if arg_182_1.tfPendintItem then
		pg.ViewUtils.SetLayer(arg_182_1.tfPendintItem, Layer.Default)
	end

	if arg_182_1.ladyWatchFloat then
		pg.ViewUtils.SetLayer(arg_182_1.ladyWatchFloat, Layer.Default)
	end

	Dorm3dHxHelper.SetModelHolyLightActive(arg_182_1.lady, self.holyLightRoot, true)
end

function Dorm3dRoomTemplateScene:EnterFurnitureWatchMode()
	self:SetAllBlackbloardValue("inLockLayer", true)
	self:EnableJoystick(true)
	self:HideCharacter()
end

function Dorm3dRoomTemplateScene:ExitFurnitureWatchMode(arg_184_1)
	self:HideFurnitureSlots()

	local var_184_0 = self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV]

	seriesAsync({
		function(arg_185_0)
			self.furniturePOV = nil

			self:EnableJoystick(false)
			self:emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
			self:ShowBlackScreen(true, arg_185_0)
		end,
		function(arg_186_0)
			existCall(arg_184_1)
			self:RevertCharacter()
			self:SetAllBlackbloardValue("inLockLayer", false)
			self:RegisterCameraBlendFinished(var_184_0, arg_186_0)
			self:ActiveCamera(var_184_0)
		end,
		function(arg_187_0)
			self:ShowBlackScreen(false, arg_187_0)
		end
	}, function()
		self:emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
	end)
	self:RefreshSlots()
end

function Dorm3dRoomTemplateScene:SwitchFurnitureZone(arg_189_1)
	local var_189_0 = "FurnitureWatch" .. arg_189_1:GetWatchCameraName()
	local var_189_1 = self.cameraRoot:Find(var_189_0)

	if not var_189_1 then
		errorMsg(var_189_0 .. " Not Find Under CM Cameras")

		return
	end

	local var_189_2 = var_189_1:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))

	if self.cameraFurnitureWatch and self.cameraFurnitureWatch ~= var_189_2 then
		self:UnRegisterCameraBlendFinished(self.cameraFurnitureWatch)
		setActive(self.cameraFurnitureWatch, false)
	end

	self.cameraFurnitureWatch = var_189_2
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.FURNITURE_WATCH] = self.cameraFurnitureWatch
	self.furniturePOV = self.cameraFurnitureWatch:GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Aim)

	self:RegisterCameraBlendFinished(self.cameraFurnitureWatch, function()
		self:emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
	end)
	self:emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
	self:ActiveCamera(self.cameraFurnitureWatch)
end

function Dorm3dRoomTemplateScene:HideFurnitureSlots()
	self:emit(FurnitureSystem.HIDE_SLOTS)
end

function Dorm3dRoomTemplateScene:DisplayFurnitureSlots(arg_192_1)
	self:emit(FurnitureSystem.DISPLAY_SLOTS, arg_192_1)
end

function Dorm3dRoomTemplateScene:UpdateDisplaySlots(arg_193_1)
	self:emit(FurnitureSystem.UPDATE_DISPLAY_SLOTS, arg_193_1)
end

function Dorm3dRoomTemplateScene:EnterPhotoMode(arg_194_1, arg_194_2)
	self:SetAllBlackbloardValue("inLockLayer", true)
	self:emit(Dorm3dRoomTemplateScene.ENABLE_SCENEBLOCK, true)
	seriesAsync({
		function(arg_195_0)
			self:TempHideUI(true, arg_195_0)
		end,
		function(arg_196_0)
			self:ShowBlackScreen(true, arg_196_0)
		end,
		function(arg_197_0)
			local var_197_0 = self.apartment:GetConfigID()

			self:SwitchAnim(self.ladyDict[var_197_0], arg_194_2)
			self.ladyDict[var_197_0].ladyAnimator:Update(0)
			self:ResetCharPoint(self.ladyDict[var_197_0], arg_194_1:GetWatchCameraName())
			self:SyncInterestTransform(self.ladyDict[var_197_0])
			setActive(self.ladyDict[var_197_0].ladySafeCollider, true)
			self:HideCharacter(var_197_0)

			self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_XAxis.Value = 180
			self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_XAxis = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_XAxis
			self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_YAxis.Value = 0.7
			self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_YAxis = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_YAxis
			self.pinchValue = 1

			self:RegisterOrbits(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO])
			self:SetCameraObrits()
			setActive(self.restrictedBox, true)
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO], arg_197_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO])
		end,
		function(arg_198_0)
			self:ShowBlackScreen(false, arg_198_0)
		end
	}, function()
		self:EnableJoystick(true)
	end)
end

function Dorm3dRoomTemplateScene:ExitPhotoMode()
	self:emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
	self:EnableJoystick(false)
	seriesAsync({
		function(arg_201_0)
			self:ShowBlackScreen(true, arg_201_0)
		end,
		function(arg_202_0)
			self:RevertCameraOrbit()

			local var_202_0 = self:GetCurrentLadyEnv()

			self:SwitchAnim(var_202_0, Dorm3dRoomTemplateScene.ANIM.IDLE)
			setActive(var_202_0.ladySafeCollider, false)
			onNextTick(function()
				self:ChangeCharacterPosition(var_202_0)
			end)

			if self.contextData.photoFreeMode then
				self:EnablePOVLayer(false)

				self.contextData.photoFreeMode = nil
			end

			setActive(self.restrictedBox, false)
			self:RegisterCameraBlendFinished(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV], arg_202_0)
			self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.POV])
		end,
		function(arg_204_0)
			self:RevertCharacter(self.apartment:GetConfigID())
			self:ShowBlackScreen(false, arg_204_0)
		end
	}, function()
		self:RefreshSlots()
		self:SetAllBlackbloardValue("inLockLayer", false)
		self:emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
		self:emit(Dorm3dRoomTemplateScene.ENABLE_SCENEBLOCK, false)
		self:TempHideUI(false)
	end)
end

function Dorm3dRoomTemplateScene:SwitchCameraZone(arg_206_1, arg_206_2, arg_206_3)
	self:emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
	seriesAsync({
		function(arg_207_0)
			self:ShowBlackScreen(true, arg_207_0)
		end,
		function(arg_208_0)
			local var_208_0 = self:GetCurrentLadyEnv()

			self:SwitchAnim(var_208_0, arg_206_2)
			onNextTick(function()
				self:ResetCharPoint(var_208_0, arg_206_1:GetWatchCameraName())
				self:SyncInterestTransform(var_208_0)

				if self.contextData.photoFreeMode then
					self.camBrain.enabled = false

					self:SwitchPhotoCamera()

					self.camBrain.enabled = true

					onDelayTick(function()
						self.camBrain.enabled = false

						self:SwitchPhotoCamera()

						self.camBrain.enabled = true
					end, 0.1)
				end

				arg_208_0()
			end)
		end,
		function(arg_211_0)
			self:ShowBlackScreen(false, arg_211_0)
		end
	}, function()
		self:emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
		existCall(arg_206_3)
	end)
end

function Dorm3dRoomTemplateScene:SwitchPhotoCamera()
	if not self.contextData.photoFreeMode then
		self:EnableJoystick(false)
		self:EnablePOVLayer(true)

		local var_213_0 = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]:Find("PhotoFree Camera"):GetComponent(typeof(Cinemachine.CinemachineVirtualCamera)):GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Aim)
		local var_213_1 = self.mainCameraTF.rotation:ToEulerAngles()

		var_213_0.m_HorizontalAxis.Value = var_213_1.y
		var_213_0.m_HorizontalAxis = var_213_0.m_HorizontalAxis
		var_213_0.m_VerticalAxis.Value = self:GetNearestAngle(var_213_1.x, var_213_0.m_VerticalAxis.m_MinValue, var_213_0.m_VerticalAxis.m_MaxValue)
		var_213_0.m_VerticalAxis = var_213_0.m_VerticalAxis

		local var_213_2 = self:GetRestritedHeightRange()

		self.mainCameraTF.position.y = math.clamp(self.mainCameraTF.position.y, var_213_2[1], var_213_2[2])
		self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE].transform.position = self.mainCameraTF.position

		self:emit(Dorm3dPhotoMediator.CAMERA_LIFT_CHANGED, (math.InverseLerp(var_213_2[1], var_213_2[2], self.mainCameraTF.position.y)))
		self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE])
	else
		self:EnableJoystick(true)
		self:EnablePOVLayer(false)
		self:ActiveCamera(self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO])
	end

	self.contextData.photoFreeMode = not self.contextData.photoFreeMode
end

function Dorm3dRoomTemplateScene:SetPhotoCameraHeight(arg_214_1)
	local var_214_0 = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]
	local var_214_1 = self:GetRestritedHeightRange()

	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE]:GetComponent(typeof(UnityEngine.CharacterController)):Move(Vector3.New(0, math.lerp(var_214_1[1], var_214_1[2], arg_214_1) - self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO_FREE].position.y, 0))
	onNextTick(function()
		local var_215_0 = self:GetRestritedHeightRange()

		self:emit(Dorm3dPhotoMediator.CAMERA_LIFT_CHANGED, (math.InverseLerp(var_215_0[1], var_215_0[2], var_214_0.position.y)))
	end)
end

function Dorm3dRoomTemplateScene:ResetPhotoCameraPosition()
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_XAxis.Value = 180
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_XAxis = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_XAxis
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_YAxis.Value = 0.7
	self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_YAxis = self.cameras[Dorm3dRoomTemplateScene.CAMERA.PHOTO].m_YAxis
end

function Dorm3dRoomTemplateScene:ResetCurrentCharPoint(arg_217_1)
	self:ResetCharPoint(self:GetCurrentLadyEnv(), arg_217_1)
end

function Dorm3dRoomTemplateScene:ResetCharPoint(arg_218_1, arg_218_2)
	if not self.zoneByName[arg_218_2] then
		-- block empty
	end

	local var_218_1 = self.ikPointByName[arg_218_2]:Find("StayPoint")

	arg_218_1.lady.position = var_218_1.position
	arg_218_1.lady.rotation = var_218_1.rotation
end

function Dorm3dRoomTemplateScene:GetNearestAngle(arg_219_1, arg_219_2, arg_219_3)
	if arg_219_3 < arg_219_2 then
		arg_219_3 = arg_219_3 + 360
	end

	if arg_219_2 <= arg_219_1 and arg_219_1 <= arg_219_3 then
		return arg_219_1
	end

	arg_219_1 = (arg_219_2 + arg_219_3) / 2 - Mathf.DeltaAngle(arg_219_1, (arg_219_2 + arg_219_3) / 2)
	arg_219_1 = math.clamp(arg_219_1, arg_219_2, arg_219_3)

	return arg_219_1
end

function Dorm3dRoomTemplateScene:PlayTimeline(arg_220_1, arg_220_2)
	local var_220_0 = {}

	if self.waitForTimeline then
		table.insert(var_220_0, function(arg_221_0)
			self.waitForTimeline = nil

			self.waitForTimeline()
			arg_221_0()
		end)
	end

	table.insert(var_220_0, function(arg_222_0)
		self:LoadTimelineScene(arg_220_1.name, false, nil, arg_222_0)
	end)

	if arg_220_1.scene and arg_220_1.sceneRoot then
		table.insert(var_220_0, function(arg_223_0)
			self:ChangeArtScene(arg_220_1.scene .. "|" .. arg_220_1.sceneRoot, arg_223_0)
		end)
	end

	table.insert(var_220_0, function(arg_224_0)
		local var_224_0 = Dorm3dHxHelper.GetTimelineMainCharacter()

		Dorm3dHxHelper.ShowHolyLight({
			var_224_0
		}, self.holyLightRoot)

		local var_224_1 = GameObject.Find("[actor]").transform

		table.IpairsCArray(var_224_1:GetComponentsInChildren(typeof(Animator), true), function(arg_225_0, arg_225_1)
			GetOrAddComponent(arg_225_1.transform, typeof(DftAniEvent))
		end)

		var_224_0 = var_224_0 or var_224_1:GetComponentInChildren(typeof("BLHXCharacterPropertiesController")).transform

		local var_224_2

		eachChild(GameObject.Find("[camera]").transform, function(arg_226_0)
			if arg_226_0.tag == "MainCamera" then
				var_224_2 = arg_226_0
			end
		end)
		assert(var_224_2, "Missing MainCamera")

		self.nowTimelinePlayer = TimelinePlayer.New(GameObject.Find("[sequence]").transform)

		TimelineSupport.InitSubtitle(self.nowTimelinePlayer.comDirector, self.apartment:GetCallName())
		self.nowTimelinePlayer:Register(arg_220_1.time, function(arg_227_0, arg_227_1, arg_227_2)
			switch(arg_227_1.stringParameter, {
				TimelinePause = function()
					arg_227_0:SetSpeed(0)
				end,
				TimelineResume = function()
					arg_227_0:SetSpeed(1)
				end,
				TimelinePlayOnTime = function()
					if arg_227_1.intParameter == 0 or arg_227_1.intParameter == arg_227_2.selectIndex then
						arg_227_0:SetTime(arg_227_1.floatParameter)
					end
				end,
				TimelineSelectStart = function()
					arg_227_2.selectIndex = nil

					if arg_220_1.options then
						local var_231_0 = arg_220_1.options[arg_227_1.intParameter]

						self:DoTimelineOption(arg_220_1.options[arg_227_1.intParameter], function(arg_232_0)
							arg_227_2.selectIndex = arg_232_0
							arg_227_2.optionIndex = var_231_0[arg_232_0].flag

							arg_227_0:Play()
						end)
					end
				end,
				TimelineTouchStart = function()
					arg_227_2.selectIndex = nil

					if arg_220_1.touchs then
						local var_233_0 = arg_220_1.touchs[arg_227_1.intParameter]

						self:DoTimelineTouch(arg_220_1.touchs[arg_227_1.intParameter], function(arg_234_0)
							arg_227_2.selectIndex = arg_234_0
							arg_227_2.optionIndex = var_233_0[arg_234_0].flag
						end)
					end
				end,
				TimelineSelectLoop = function()
					if not arg_227_2.selectIndex then
						arg_227_0:RawSetTime(arg_227_1.floatParameter)
					end
				end,
				TimelineSelect = function()
					arg_227_2.selectIndex = arg_227_1.intParameter
				end,
				TimelineAccompanyJump = function()
					if self.canTriggerAccompanyPerformance then
						self.canTriggerAccompanyPerformance = false

						arg_227_0:SetTime(arg_220_1.accompanys[arg_227_1.intParameter][math.random(#arg_220_1.accompanys[arg_227_1.intParameter])])
					end
				end,
				TimelineIKStart = function()
					arg_227_2.selectIndex = nil

					self:emit(RoomIKSystem.SET_IK_TIMELINE_STATUS, var_224_0.gameObject, arg_227_1.intParameter, var_224_2)
				end,
				TimelineEnd = function()
					arg_227_2.finish = true

					arg_227_0:SetSpeed(0)
				end,
				TimelineAimIKStart = function()
					arg_227_2.selectIndex = nil

					self:emit(AimIKSystem.ENTER_TIMELINE_AIMIK_STATUS, arg_227_1.intParameter)
				end
			}, function()
				warning("other event trigger:" .. arg_227_1.stringParameter)
			end)

			if arg_227_2.finish then
				self.timelineMark = arg_227_2
				self.timelineFinishCall = nil

				pg.m02:sendNotification(Dorm3dRoomTemplateScene.TIMELINE_END)
				self:emit(RoomIKSystem.EXIT_IK_TIMELINE_STATUS)
				arg_224_0()
			end
		end)

		function self.timelineFinishCall()
			self.nowTimelinePlayer:TriggerEvent({
				stringParameter = "TimelineEnd"
			})
		end

		self:HideCharacter()
		setActive(self.mainCameraTF, false)
		setActive(var_224_2, true)
		eachChild(self.rtTimelineScreen, function(arg_243_0)
			setActive(arg_243_0, false)
		end)
		setActive(self.rtTimelineScreen, true)
		setActive(self.rtTimelineScreen:Find("btn_skip"), self.inReplayTalk)
		self.nowTimelinePlayer:Start()
	end)
	table.insert(var_220_0, function(arg_244_0)
		self:ShowBlackScreen(true, function()
			self.nowTimelinePlayer:Stop()
			self.nowTimelinePlayer:Dispose()

			self.nowTimelinePlayer = nil

			self:UnloadTimelineScene(arg_220_1.name, false, arg_244_0)
		end)
	end)

	local var_220_1 = self.dormSceneMgr.artSceneInfo

	table.insert(var_220_0, function(arg_246_0)
		self:RevertArtScene(var_220_1, arg_246_0)
	end)
	seriesAsync(var_220_0, function()
		setActive(self.rtTimelineScreen, false)
		self:RevertCharacter()
		setActive(self.mainCameraTF, true)
		self:InitHolyLight()

		self.timelineMark = nil

		existCall(arg_220_2, self.timelineMark, function(arg_248_0)
			self:ShowBlackScreen(false, arg_248_0)
		end)
	end)
end

function Dorm3dRoomTemplateScene:GetCurrentLadyEnv()
	if not self.apartment then
		return nil
	end

	return self.ladyDict[self.apartment:GetConfigID()]
end

function Dorm3dRoomTemplateScene:PlayCurrentSingleAction(...)
	return self:PlaySingleAction(self:GetCurrentLadyEnv(), ...)
end

function Dorm3dRoomTemplateScene:PlaySingleAction(arg_251_1, arg_251_2, arg_251_3, arg_251_4)
	arg_251_1:PlaySingleAction(arg_251_2, arg_251_3, arg_251_4)
end

function Dorm3dRoomTemplateScene:SwitchCurrentAnim(...)
	return self:SwitchAnim(self:GetCurrentLadyEnv(), ...)
end

function Dorm3dRoomTemplateScene:SwitchAnim(arg_253_1, arg_253_2, arg_253_3, arg_253_4)
	arg_253_1:SwitchAnim(arg_253_2, arg_253_3, arg_253_4)
end

function Dorm3dRoomTemplateScene:PlayFaceAnim(arg_254_1, arg_254_2, arg_254_3)
	arg_254_1:PlayFaceAnim(arg_254_2, arg_254_3)
end

function Dorm3dRoomTemplateScene:RegisterAnimCallback(arg_255_1, arg_255_2)
	self:GetCurrentLadyEnv().animCallbacks[arg_255_1] = arg_255_2
end

function Dorm3dRoomTemplateScene:SetCharacterAnimSpeed(arg_256_1)
	local var_256_0 = self:GetCurrentLadyEnv()

	var_256_0.ladyAnimator.speed = arg_256_1
	var_256_0.ladyHeadIKComp.blinkSpeed = var_256_0.ladyHeadIKData.blinkSpeed * arg_256_1
	var_256_0.ladyHeadIKComp.DampTime = arg_256_1 > 0 and var_256_0.ladyHeadIKData.DampTime / arg_256_1 or var_256_0.ladyHeadIKData.DampTime * math.huge
end

function Dorm3dRoomTemplateScene:OnAnimationEvent(arg_257_1)
	if arg_257_1.animatorClipInfo.weight < 0.5 then
		return
	end

	existCall((table.removebykey(self.animEventCallbacks, arg_257_1.stringParameter)))
end

function Dorm3dRoomTemplateScene:RegisterAnimEventCallback(arg_258_1, arg_258_2)
	self.animEventCallbacks[arg_258_1] = arg_258_2
end

function Dorm3dRoomTemplateScene:PlaySceneItemAnim(arg_259_1, arg_259_2, arg_259_3)
	self.sceneAnimatorDict = self.sceneAnimatorDict or {}

	if not self.sceneAnimatorDict[arg_259_1] then
		local var_259_0 = self:GetSceneItem(pg.dorm3d_scene_animator[arg_259_1].item_name)

		assert(var_259_0, "Missing Scene Animator in pg.dorm3d_scene_animator: " .. arg_259_1 .. " " .. pg.dorm3d_scene_animator[arg_259_1].item_name)

		if not var_259_0 then
			return
		end

		local var_259_1 = var_259_0:GetComponent(typeof(Animator))

		if not var_259_1 then
			return
		end

		self.sceneAnimatorDict[arg_259_1] = {
			trans = var_259_0,
			animator = var_259_1
		}
	end

	if not arg_259_3 then
		if self.sceneAnimatorDict[arg_259_1].animator:GetCurrentAnimatorStateInfo(0):IsName(arg_259_2) then
			return
		end
	end

	self.sceneAnimatorDict[arg_259_1].animator:PlayInFixedTime(arg_259_2, -1, arg_259_3 and 0 or -math.huge)
end

function Dorm3dRoomTemplateScene:ResetSceneItemAnimators(arg_260_1)
	if not self.sceneAnimatorDict then
		return
	end

	table.Foreach(self.sceneAnimatorDict, function(arg_261_0, arg_261_1)
		if arg_260_1 and table.contains(arg_260_1, arg_261_0) then
			return
		end

		setActive(arg_261_1.trans, false)
		setActive(arg_261_1.trans, true)

		self.sceneAnimatorDict[arg_261_0] = nil
	end)
end

function Dorm3dRoomTemplateScene:LoadCharacterExtraItem(arg_262_1, arg_262_2, arg_262_3, arg_262_4, arg_262_5, arg_262_6, arg_262_7, arg_262_8)
	local function var_262_0(arg_263_0)
		if arg_262_6 then
			local var_263_0 = arg_263_0:GetComponent(typeof(Animator))

			if var_263_0 then
				var_263_0:Play(arg_262_6, -1, arg_262_8 and 0 or -math.huge)

				var_263_0.speed = arg_262_7
			end
		end
	end

	self.extraItems = self.extraItems or {}

	local var_262_1

	if arg_262_3 == "" then
		var_262_1 = arg_262_1.lady
	elseif arg_262_3 == "scene_root" then
		var_262_1 = self.modelRoot
	else
		table.IpairsCArray(arg_262_1.lady:GetComponentsInChildren(typeof(Transform), true), function(arg_264_0, arg_264_1)
			if arg_264_1.name == arg_262_3 then
				var_262_1 = arg_264_1
			end
		end)
	end

	if not var_262_1 then
		return
	end

	local var_262_2 = self.extraItems[arg_262_2]

	if self.extraItems[arg_262_2] then
		if var_262_2.handler == var_262_1 then
			var_262_0(var_262_2.trans)

			return
		end

		self.loader:ReturnPrefab(var_262_2.trans.gameObject)

		self.extraItems[arg_262_2] = nil
	end

	self.loader:GetPrefab(string.lower("dorm3d/" .. arg_262_2), "", function(arg_265_0)
		setParent(arg_265_0, var_262_1)

		if arg_262_4 then
			setLocalPosition(arg_265_0, arg_262_4)
		end

		if arg_262_5 then
			setLocalRotation(arg_265_0, arg_262_5)
		end

		var_262_0(arg_265_0)

		self.extraItems[arg_262_2] = {
			trans = arg_265_0.transform,
			handler = var_262_1
		}
	end)
end

function Dorm3dRoomTemplateScene:ResetCharacterExtraItem(arg_266_1)
	if not self.extraItems then
		return
	end

	table.Foreach(self.extraItems, function(arg_267_0, arg_267_1)
		if arg_266_1 and table.contains(arg_266_1, arg_267_0) then
			return
		end

		self.loader:ReturnPrefab(arg_267_1.trans.gameObject)

		self.extraItems[arg_267_0] = nil
	end)
end

function Dorm3dRoomTemplateScene:RegisterCameraBlendFinished(arg_268_1, arg_268_2)
	self.cameraBlendCallbacks[arg_268_1] = arg_268_2
end

function Dorm3dRoomTemplateScene:UnRegisterCameraBlendFinished(arg_269_1)
	self.cameraBlendCallbacks[arg_269_1] = nil
end

function Dorm3dRoomTemplateScene:OnCameraBlendFinished(arg_270_1)
	if not arg_270_1 then
		return
	end

	existCall((table.removebykey(self.cameraBlendCallbacks, arg_270_1)))
end

function Dorm3dRoomTemplateScene:PlayHeartFX(arg_271_1)
	setActive(self.ladyDict[arg_271_1].effectHeart, false)
	setActive(self.ladyDict[arg_271_1].effectHeart, true)
	pg.CriMgr.GetInstance():PlaySE_V3("ui-dorm_joyful")
end

function Dorm3dRoomTemplateScene:PlayExpression(arg_272_1)
	local var_272_0 = arg_272_1.name

	if self.expressionDict[arg_272_1.name] then
		self.expressionDict[arg_272_1.name].timer:Reset(nil, 5)
		self.expressionDict[arg_272_1.name].timer:Start()

		if self.expressionDict[arg_272_1.name].instance then
			setActive(self.expressionDict[arg_272_1.name].instance, false)
			setActive(self.expressionDict[arg_272_1.name].instance, true)
		end

		return
	end

	local var_272_1 = {
		name = arg_272_1.name,
		timer = Timer.New(function()
			self:RemoveExpression(var_272_0)
		end, 5, 1, true)
	}

	self.expressionDict[arg_272_1.name] = var_272_1

	self.loader:GetPrefab("dorm3D/effect/prefab/expression/" .. arg_272_1.name, arg_272_1.name, function(arg_274_0)
		var_272_1.instance = arg_274_0

		onNextTick(function()
			setParent(arg_274_0, self:GetCurrentLadyEnv().ladyHeadCenter)
		end)
		setLocalPosition(arg_274_0, Vector3(0, 0, -0.2))
		setActive(arg_274_0, false)
		setActive(arg_274_0, true)
	end, var_272_1)
end

function Dorm3dRoomTemplateScene:RemoveExpression(arg_276_1)
	if not self.expressionDict[arg_276_1] then
		return
	end

	self.loader:ClearRequest(self.expressionDict[arg_276_1])

	if self.expressionDict[arg_276_1].instance then
		self.loader:ReturnPrefab(self.expressionDict[arg_276_1].instance)
	end

	self.expressionDict[arg_276_1] = nil
end

function Dorm3dRoomTemplateScene:ShowOrHideCanWatchMark(arg_277_1, arg_277_2)
	setActive(arg_277_1.ladyWatchFloat, arg_277_2)
end

function Dorm3dRoomTemplateScene:GetCameraSettings()
	local var_278_0 = self:GetExtraSystem(Dorm3dLightingSystem)

	assert(var_278_0, "Dorm3dLightingSystem is not initialized")

	return var_278_0:GetCameraSettings()
end

function Dorm3dRoomTemplateScene:onBackPressed()
	if self.exited or self.retainCount > 0 then
		-- block empty
	else
		self:closeView()
	end
end

function Dorm3dRoomTemplateScene:LoadTimelineScene(arg_280_1, arg_280_2, arg_280_3, arg_280_4)
	self.dormSceneMgr:LoadTimelineScene({
		name = arg_280_1,
		assetRootName = self.apartment:getConfig("asset_name"),
		isCache = arg_280_2,
		waitForTimeline = arg_280_3,
		loadSceneFunc = function(arg_281_0, arg_281_1)
			local var_281_0 = Dorm3dHxHelper.GetTimelineMainCharacter()

			Dorm3dHxHelper.HideCharacterPart(var_281_0, nil, true)
			self:HXCharacter(var_281_0)
		end
	}, arg_280_4)
end

function Dorm3dRoomTemplateScene:UnloadTimelineScene(arg_282_1, arg_282_2, arg_282_3)
	self.dormSceneMgr:UnloadTimelineScene(arg_282_1, arg_282_2, arg_282_3)
end

function Dorm3dRoomTemplateScene:ChangeArtScene(arg_283_1, arg_283_2)
	if Dorm3dSceneMgr.IsSameSceneInfo(arg_283_1, self.dormSceneMgr.artSceneInfo) then
		existCall(arg_283_2)

		return
	end

	local var_283_0 = Dorm3dSceneMgr.IsSameSceneInfo(arg_283_1, self.dormSceneMgr.sceneInfo)
	local var_283_1 = {}

	table.insert(var_283_1, function(arg_284_0)
		self:emit(Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE, arg_283_1, var_283_0)
		arg_284_0()
	end)
	table.insert(var_283_1, function(arg_285_0)
		self.dormSceneMgr:ChangeArtScene(arg_283_1, arg_285_0)
	end)
	table.insert(var_283_1, function(arg_286_0)
		self:RefreshArtSceneRefs()
		self:emit(Dorm3dRoomTemplateScene.ART_SCENE_CHANGED, arg_283_1, var_283_0)
		arg_286_0()
	end)
	table.insert(var_283_1, function(arg_287_0)
		setActive(self.slotRoot, false)
		arg_287_0()
	end)
	warning(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", arg_283_1, self.dormSceneMgr.sceneInfo, Dorm3dSceneMgr.IsSameSceneInfo(arg_283_1, self.dormSceneMgr.sceneInfo))

	if Dorm3dSceneMgr.IsSameSceneInfo(arg_283_1, self.dormSceneMgr.sceneInfo) then
		table.insert(var_283_1, function(arg_288_0)
			self:SwitchDayNight(1)
			self:emit(CollectionSystem.TEMP_HIDE, true)
			arg_288_0()
		end)
	end

	seriesAsync(var_283_1, arg_283_2)
end

function Dorm3dRoomTemplateScene:RefreshArtSceneRefs()
	local var_289_0 = GameObject.Find("scene_root")

	assert(var_289_0, "Missing scene_root after art scene change")

	self.modelRoot = var_289_0.transform
end

function Dorm3dRoomTemplateScene:MoveObjectToBaseScene(arg_290_1)
	arg_290_1.transform:SetParent(nil)
	SceneManager.MoveGameObjectToScene(arg_290_1, (SceneManager.GetSceneByName(Dorm3dSceneMgr.ParseInfo(self.dormSceneMgr.sceneInfo) .. "_base")))
end

function Dorm3dRoomTemplateScene:RevertArtScene(arg_291_1, arg_291_2)
	local var_291_0 = {}

	table.insert(var_291_0, function(arg_292_0)
		self:ChangeArtScene(arg_291_1, arg_292_0)
	end)
	table.insert(var_291_0, function(arg_293_0)
		setActive(self.slotRoot, true)
		arg_293_0()
	end)
	table.insert(var_291_0, function(arg_294_0)
		self:SwitchDayNight(self.contextData.timeIndex)
		onNextTick(function()
			self:RefreshSlots()
			self:emit(CollectionSystem.TEMP_HIDE, false)
			arg_294_0()
		end)
	end)
	seriesAsync(var_291_0, arg_291_2)
end

function Dorm3dRoomTemplateScene:ChangeSubScene(arg_296_1, arg_296_2)
	local var_296_0 = {}

	table.insert(var_296_0, function(arg_297_0)
		self.dormSceneMgr:ChangeSubScene(arg_296_1, arg_297_0)
	end)

	local var_296_1 = self:GetCurrentLadyEnv()
	local var_296_2 = self:GetBlackboardValue(var_296_1, "groupId")

	table.insert(var_296_0, function(arg_298_0)
		if Dorm3dSceneMgr.IsSameSceneInfo(arg_296_1, self.dormSceneMgr.sceneInfo) then
			self:SetLadyActiveZone(var_296_2, var_296_1.walkBornPoint or self:GetLadyBaseZone(var_296_2))
		else
			self:SetLadyActiveZone(var_296_2, var_296_1.walkBornPoint or "Default")
		end

		arg_298_0()
	end)

	if not Dorm3dSceneMgr.IsSameSceneInfo(arg_296_1, self.dormSceneMgr.subSceneInfo) then
		table.insert(var_296_0, function(arg_299_0)
			local var_299_0, var_299_1 = Dorm3dSceneMgr.ParseInfo(arg_296_1)

			self:ResetSceneStructure(SceneManager.GetSceneByName(var_299_0 .. "_base"))

			if Dorm3dSceneMgr.IsSameSceneInfo(arg_296_1, self.dormSceneMgr.sceneInfo) then
				self:RefreshSlots()
			else
				self:SwitchAnim(var_296_1, Dorm3dRoomTemplateScene.ANIM.IDLE)
			end

			if not Dorm3dSceneMgr.IsSameSceneInfo(self.dormSceneMgr.subSceneInfo, self.dormSceneMgr.sceneInfo) then
				self:RefreshSlotsEmpty()
			end

			arg_299_0()
		end)
	end

	table.insert(var_296_0, function(arg_300_0)
		onNextTick(function()
			self:ChangeCharacterPosition(var_296_1)
			self:ChangePlayerPosition(self:GetLadyActiveZone(var_296_2))
			self:TriggerLadyDistance()
			self:CheckInSector()
			arg_300_0()
		end)
	end)
	seriesAsync(var_296_0, arg_296_2)
end

function Dorm3dRoomTemplateScene:IsPointInSector(arg_302_1)
	local var_302_0 = arg_302_1 - self.Position

	if (arg_302_1 - self.Position).y > self.Radius then
		return false
	end

	var_302_0.y = 0

	if var_302_0.magnitude > self.Radius then
		return false
	end

	return Vector3.Angle(self.Rotation * Vector3.forward, var_302_0) <= self.Angle / 2
end

function Dorm3dRoomTemplateScene:GetRestritedHeightRange()
	if not self.isMultiFloor then
		return self.restrictedHeightRange
	else
		for iter_303_0 = #self.restrictedHeightRange, 1, -1 do
			if self.mainCameraTF.position.y >= self.restrictedHeightRange[iter_303_0][1] then
				return self.restrictedHeightRange[iter_303_0]
			end
		end

		return self.restrictedHeightRange[1]
	end
end

function Dorm3dRoomTemplateScene:willExit()
	Dorm3dRoomTemplateScene.super.willExit(self)
	self.joystickTimer:Stop()
	self.moveStickTimer:Stop()
	UpdateBeat:RemoveListener(self.updateHandler)

	if self.moveTimer then
		self.moveTimer:Stop()

		self.moveTimer = nil
	end

	if self.moveWaitTimer then
		self.moveWaitTimer:Stop()

		self.moveWaitTimer = nil
	end

	GlobalClickEventMgr.Inst:RemoveBeginPinchFunc()
	GlobalClickEventMgr.Inst:RemovePinchFunc()
	GlobalClickEventMgr.Inst:RemoveEndPinchFunc()
	pg.IKMgr.GetInstance():ResetActiveIKs()

	for iter_304_0, iter_304_1 in pairs(self.ladyDict) do
		GetComponent(iter_304_1.lady, typeof(EventTriggerListener)):ClearEvents()
	end

	self.camBrainEvenetHandler.OnBlendStarted = nil
	self.camBrainEvenetHandler.OnBlendFinished = nil

	self:UnOverlayPanel(self.blockLayer, self._tf)
	table.Foreach(self.expressionDict, function(arg_305_0)
		self:RemoveExpression(arg_305_0)
	end)
	self.loader:Clear()

	self.hxHelper = nil

	pg.ClickEffectMgr.GetInstance():SetClickEffect("NORMAL")
	pg.NodeCanvasMgr.GetInstance():Clear()
	self.dormSceneMgr:Dispose()

	self.dormSceneMgr = nil

	ReflectionHelp.RefSetProperty(typeof("UnityEngine.LightmapSettings"), "lightmaps", nil, nil)

	if self.transformFilter then
		self.transformFilter:Dispose()
	end
end

return Dorm3dRoomTemplateScene
