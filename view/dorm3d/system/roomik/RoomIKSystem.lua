local RoomIKSystem = class("RoomIKSystem", import("view.dorm3d.Core.BaseSystem"))

RoomIKSystem.ENTER_IK = "RoomIKSystem.ENTER_IK"
RoomIKSystem.REPLACE_IK_STATUS = "RoomIKSystem.REPLACE_IK_STATUS"
RoomIKSystem.EXIT_IK_WITH_RETURN = "RoomIKSystem.EXIT_IK_WITH_RETURN"
RoomIKSystem.ENTER_STOCKING_IK_MODE = "RoomIKSystem.ENTER_STOCKING_IK_MODE"
RoomIKSystem.EXIT_STOCKING_IK_MODE = "RoomIKSystem.EXIT_STOCKING_IK_MODE"
RoomIKSystem.ENTER_AIMIK_IK_MODE = "RoomIKSystem.ENTER_AIMIK_IK_MODE"
RoomIKSystem.EXIT_AIMIK_IK_MODE = "RoomIKSystem.EXIT_AIMIK_IK_MODE"
RoomIKSystem.ON_CONTROL_POINTER_DOWN = "RoomIKSystem.ON_CONTROL_POINTER_DOWN"
RoomIKSystem.ON_CONTROL_POINTER_UP = "RoomIKSystem.ON_CONTROL_POINTER_UP"
RoomIKSystem.ON_CONTROL_BEGIN_DRAG = "RoomIKSystem.ON_CONTROL_BEGIN_DRAG"
RoomIKSystem.ON_CONTROL_DRAG = "RoomIKSystem.ON_CONTROL_DRAG"
RoomIKSystem.ON_CONTROL_END_DRAG = "RoomIKSystem.ON_CONTROL_END_DRAG"
RoomIKSystem.ON_IK_STATUS_CHANGED = "RoomIKSystem.ON_IK_STATUS_CHANGED"
RoomIKSystem.ON_IK_LAYER_ACTION = "RoomIKSystem.ON_IK_LAYER_ACTION"
RoomIKSystem.SET_IK_TIMELINE_STATUS = "RoomIKSystem.SET_IK_TIMELINE_STATUS"
RoomIKSystem.EXIT_IK_TIMELINE_STATUS = "RoomIKSystem.EXIT_IK_TIMELINE_STATUS"
RoomIKSystem.CYCLE_IK_CAMERA_GROUP = "RoomIKSystem.CYCLE_IK_CAMERA_GROUP"
RoomIKSystem.SET_IK_SPECIAL_CALL = "RoomIKSystem.SET_IK_SPECIAL_CALL"
RoomIKSystem.CONSUME_IK_SPECIAL_CALL = "RoomIKSystem.CONSUME_IK_SPECIAL_CALL"
RoomIKSystem.GET_IK_BLOCK = "RoomIKSystem.GET_IK_BLOCK"
RoomIKSystem.SET_IK_BLOCK = "RoomIKSystem.SET_IK_BLOCK"
RoomIKSystem.RESET_IK_TIP_TIMER = "RoomIKSystem.RESET_IK_TIP_TIMER"
RoomIKSystem.SET_IK_SWITCH_SKIN_ID = "RoomIKSystem.SET_IK_SWITCH_SKIN_ID"
RoomIKSystem.SWITCH_IK_SKIN = "RoomIKSystem.SWITCH_IK_SKIN"
RoomIKSystem.PLAY_TOUCH_IK_MOVE = "RoomIKSystem.PLAY_TOUCH_IK_MOVE"
RoomIKSystem.IK_STATUS_DELTA = 0.5
RoomIKSystem.IK_TIP_WAIT_TIME = 5
RoomIKSystem.IK_STATUS = {
	RELEASE = 3,
	BEGIN = 1,
	TRIGGER = 4,
	DRAG = 2
}
RoomIKSystem.MODE_STATE = {
	IDLE = "idle",
	REPLACING = "replacing",
	ENTERING = "entering",
	EXITING = "exiting",
	ACTIVE = "active"
}

function RoomIKSystem:OnInit()
	self.modeState = RoomIKSystem.MODE_STATE.IDLE
	self.transitionSerial = 0
	self.pendingExitCallbacks = {}
	self.session = RoomIKSession.New()
	self.sessionBuilder = RoomIKSessionBuilder.New(self)
	self.driver = RoomIKDriver.New()
	self.input = RoomIKInput.New(self)
end

function RoomIKSystem:RegisterEvents()
	self:Bind(RoomIKSystem.ENTER_IK, function(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
		self:EnterIK(arg_3_1, arg_3_2, arg_3_3)
	end)
	self:Bind(RoomIKSystem.REPLACE_IK_STATUS, function(arg_4_0, arg_4_1, arg_4_2, arg_4_3)
		self:ReplaceIKStatus(arg_4_1, arg_4_2, arg_4_3)
	end)
	self:Bind(RoomIKSystem.EXIT_IK_WITH_RETURN, function(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
		self:ExitIKWithReturn(arg_5_1, arg_5_2, arg_5_3)
	end)
	self:Bind(RoomIKSystem.ENTER_STOCKING_IK_MODE, function(arg_6_0, arg_6_1)
		self:EnterStockingIKMode(arg_6_1)
	end)
	self:Bind(RoomIKSystem.EXIT_STOCKING_IK_MODE, function(arg_7_0, arg_7_1)
		self:ExitStockingIKMode(arg_7_1)
	end)
	self:Bind(RoomIKSystem.ENTER_AIMIK_IK_MODE, function(arg_8_0, arg_8_1)
		self:EnterAimIKMode(arg_8_1)
	end)
	self:Bind(RoomIKSystem.EXIT_AIMIK_IK_MODE, function(arg_9_0, arg_9_1)
		self:ExitAimIKMode(arg_9_1)
	end)
	self:Bind(RoomIKSystem.ON_CONTROL_POINTER_DOWN, function(arg_10_0, arg_10_1)
		self.input:OnControlPointerDown(arg_10_1)
	end)
	self:Bind(RoomIKSystem.ON_CONTROL_POINTER_UP, function(arg_11_0, arg_11_1)
		self.input:OnControlPointerUp(arg_11_1)
	end)
	self:Bind(RoomIKSystem.ON_CONTROL_BEGIN_DRAG, function(arg_12_0, arg_12_1)
		self.input:OnControlBeginDrag(arg_12_1)
	end)
	self:Bind(RoomIKSystem.ON_CONTROL_DRAG, function(arg_13_0, arg_13_1, arg_13_2)
		self.input:OnControlDrag(arg_13_1, arg_13_2)
	end)
	self:Bind(RoomIKSystem.ON_CONTROL_END_DRAG, function(arg_14_0, arg_14_1)
		self.input:OnControlEndDrag(arg_14_1)
	end)
	self:Bind(RoomIKSystem.SET_IK_TIMELINE_STATUS, function(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4)
		self:SetIKTimelineStatus(arg_15_1, arg_15_2, arg_15_3, arg_15_4)
	end)
	self:Bind(RoomIKSystem.EXIT_IK_TIMELINE_STATUS, function(arg_16_0, arg_16_1)
		self:ExitIKTimelineStatus(arg_16_1)
	end)
	self:Bind(RoomIKSystem.CYCLE_IK_CAMERA_GROUP, function()
		self:CycleIKCameraGroup()
	end)
	self:Bind(RoomIKSystem.SET_IK_SPECIAL_CALL, function(arg_18_0, arg_18_1)
		self.session.ikSpecialCall = arg_18_1
	end)
	self:Bind(RoomIKSystem.CONSUME_IK_SPECIAL_CALL, function(arg_19_0, arg_19_1)
		if arg_19_1 then
			arg_19_1.consumed = self:ConsumeIKSpecialCall()
		end
	end)
	self:Bind(RoomIKSystem.GET_IK_BLOCK, function(arg_20_0, arg_20_1)
		if arg_20_1 then
			arg_20_1.blockIK = self.session:IsBlocked()
		end
	end)
	self:Bind(RoomIKSystem.SET_IK_BLOCK, function(arg_21_0, arg_21_1)
		self.session:SetLegacyBlock(arg_21_1)
	end)
	self:Bind(RoomIKSystem.RESET_IK_TIP_TIMER, function()
		self:ResetIKTipTimer()
	end)
	self:Bind(RoomIKSystem.SET_IK_SWITCH_SKIN_ID, function(arg_23_0, arg_23_1)
		self:SetIKSwitchSkinId(arg_23_1)
	end)
	self:Bind(RoomIKSystem.SWITCH_IK_SKIN, function(arg_24_0, arg_24_1, arg_24_2, arg_24_3)
		self:SwitchIKSkin(arg_24_1, arg_24_2, arg_24_3)
	end)
	self:Bind(RoomIKSystem.PLAY_TOUCH_IK_MOVE, function(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5)
		self:PlayTouchIKMove(arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5)
	end)
end

function RoomIKSystem:OnUpdate()
	self:UpdateIKTarget()
end

function RoomIKSystem:OnDispose()
	self.transitionSerial = self.transitionSerial + 1

	local var_27_0 = self:GetCurrentLadyEnv()

	if self:IsInIKTimelineMode() then
		self:ClearIKTimelineRuntime()
	elseif self.session.active and var_27_0 then
		self:ClearIKStatusRuntime(var_27_0)
	else
		self:RestoreIKTimelineColliders()
		self:CancelControlInput()
		self.driver:Detach()
	end

	self:ReleaseIKBlock()

	self.modeState = RoomIKSystem.MODE_STATE.IDLE

	if self.input then
		self.input:Dispose()

		self.input = nil
	end

	self.pendingExitCallbacks = {}

	self.session:Invalidate()
end

function RoomIKSystem:WrapCallbackOnce(arg_28_1)
	if not arg_28_1 then
		return nil
	end

	local var_28_0 = false

	return function(...)
		if var_28_0 then
			return
		end

		var_28_0 = true

		existCall(arg_28_1, ...)
	end
end

function RoomIKSystem:FlushExitCallbacks(arg_30_1)
	existCall(arg_30_1)

	self.pendingExitCallbacks = {}

	for iter_30_0, iter_30_1 in ipairs(self.pendingExitCallbacks) do
		existCall(iter_30_1)
	end
end

function RoomIKSystem:ResolveIKConfig(arg_31_1, arg_31_2)
	warning("switchIkstatus", arg_31_2)

	local var_31_0 = pg.dorm3d_ik_status[arg_31_2]

	assert(pg.dorm3d_ik_status[arg_31_2], "Missing dorm3d_ik_status config: " .. tostring(arg_31_2))

	local function var_31_1()
		if var_31_0.skin_id ~= arg_31_1.skinId then
			local var_32_0 = _.detect(pg.dorm3d_ik_status.get_id_list_by_base[var_31_0.base], function(arg_33_0)
				return pg.dorm3d_ik_status[arg_33_0].skin_id == arg_31_1.skinId
			end)

			assert(var_32_0, string.format("Missing Status Config By Skin: %s original Status: %s", arg_31_1.skinId, arg_31_2))

			var_31_0 = pg.dorm3d_ik_status[var_32_0]
		end
	end

	if type(var_31_0.skin_id) == "table" then
		if not table.contains(var_31_0.skin_id, arg_31_1.skinId) then
			var_31_1()
		end
	else
		var_31_1()
	end

	return var_31_0
end

function RoomIKSystem:BeginIKTransition(arg_34_1)
	self.transitionSerial = self.transitionSerial + 1
	self.modeState = arg_34_1

	return self.transitionSerial
end

function RoomIKSystem:IsIKTransitionActive(arg_35_1, arg_35_2)
	return self.transitionSerial == arg_35_1 and self.modeState == arg_35_2
end

function RoomIKSystem:AcquireIKBlock()
	if self.session.uiBlockHeld then
		return
	end

	self.session.uiBlockHeld = true

	self:Emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
end

function RoomIKSystem:ReleaseIKBlock()
	if not self.session.uiBlockHeld then
		return
	end

	self.session.uiBlockHeld = false

	self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
end

function RoomIKSystem:RunIKStatusTransition(arg_38_1, arg_38_2, arg_38_3, arg_38_4, arg_38_5, arg_38_6, arg_38_7)
	arg_38_6 = arg_38_6 or {}
	arg_38_5 = self:WrapCallbackOnce(arg_38_5)

	local var_38_0 = {}

	table.insert(var_38_0, function(arg_39_0)
		if not self:IsIKTransitionActive(arg_38_4, arg_38_3) then
			return
		end

		self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE, arg_38_1, "inIK", true)
		self:AcquireIKBlock()
		self:Emit(Dorm3dIKView.SET_CAMERA_BUTTON_ACTIVE, #pg.dorm3d_ik_status.get_id_list_by_camera_group[arg_38_2.camera_group] > 1)
		self:Emit(Dorm3dIKView.SET_CONTROL_ACTIVE, true)
		arg_39_0()
	end)

	if self:GetUIState() ~= "ik" then
		table.insert(var_38_0, function(arg_40_0)
			if not self:IsIKTransitionActive(arg_38_4, arg_38_3) then
				return
			end

			self:Emit(Dorm3dRoomScene.EXTRA_SET_UI, arg_40_0, "ik")
		end)
	end

	table.insert(var_38_0, function(arg_41_0)
		if not self:IsIKTransitionActive(arg_38_4, arg_38_3) then
			return
		end

		if arg_38_3 == RoomIKSystem.MODE_STATE.REPLACING then
			self:ClearIKStatusRuntime(arg_38_1, arg_38_6)

			self.session.currentIkConfig = arg_38_2
		end

		Shader.SetGlobalFloat("_ScreenClipOff", 0)
		self:SetIKStatus(arg_38_1, arg_38_2, arg_41_0, arg_38_6, arg_38_4, arg_38_3, arg_38_7)
	end)
	table.insert(var_38_0, function(arg_42_0)
		if not self:IsIKTransitionActive(arg_38_4, arg_38_3) then
			return
		end

		self:ReleaseIKBlock()
		arg_42_0()
	end)
	seriesAsync(var_38_0, function()
		if not self:IsIKTransitionActive(arg_38_4, arg_38_3) then
			return
		end

		self.modeState = RoomIKSystem.MODE_STATE.ACTIVE

		existCall(arg_38_5)
	end)
end

function RoomIKSystem:EnterIK(arg_44_1, arg_44_2, arg_44_3)
	arg_44_2 = self:WrapCallbackOnce(arg_44_2)

	assert(self.modeState == RoomIKSystem.MODE_STATE.IDLE, string.format("Cannot enter IK from state: %s", tostring(self.modeState)))
	assert(not self:IsInIKTimelineMode(), "Cannot enter IK during timeline IK")

	local var_44_0 = self:GetCurrentLadyEnv()

	assert(var_44_0, "Missing LadyEnv when enter IK")

	local var_44_1 = self:ResolveIKConfig(var_44_0, arg_44_1)
	local var_44_2 = self.sessionBuilder:BuildNormal(var_44_0, var_44_1, function(arg_45_0)
		self:OnNormalIKLayerAction(arg_45_0)
	end)

	self:ValidateIKSpec(var_44_2)

	self.session.currentIkConfig = var_44_1

	self:RunIKStatusTransition(var_44_0, var_44_1, RoomIKSystem.MODE_STATE.ENTERING, self:BeginIKTransition(RoomIKSystem.MODE_STATE.ENTERING), arg_44_2, arg_44_3, var_44_2)
end

function RoomIKSystem:ReplaceIKStatus(arg_46_1, arg_46_2, arg_46_3)
	arg_46_2 = self:WrapCallbackOnce(arg_46_2)

	assert(self.modeState == RoomIKSystem.MODE_STATE.ACTIVE, string.format("Cannot replace IK status from state: %s", tostring(self.modeState)))

	local var_46_0 = self:GetCurrentLadyEnv()

	assert(var_46_0, "Missing LadyEnv when replace IK status")

	local var_46_1 = self:ResolveIKConfig(var_46_0, arg_46_1)
	local var_46_2 = self.sessionBuilder:BuildNormal(var_46_0, var_46_1, function(arg_47_0)
		self:OnNormalIKLayerAction(arg_47_0)
	end)

	self:ValidateIKSpec(var_46_2)

	self.session.currentIkConfig = var_46_1

	self:RunIKStatusTransition(var_46_0, var_46_1, RoomIKSystem.MODE_STATE.REPLACING, self:BeginIKTransition(RoomIKSystem.MODE_STATE.REPLACING), arg_46_2, arg_46_3, var_46_2)
end

function RoomIKSystem:ExitIK(arg_48_1, arg_48_2)
	assert(self.session.currentIkConfig, "Missing current IK config")
	self:ExitIKWithReturn({
		character_position = self.session.currentIkConfig.character_position,
		character_action = self.session.currentIkConfig.character_action
	}, arg_48_1, arg_48_2)
end

function RoomIKSystem:ExitIKWithReturn(arg_49_1, arg_49_2, arg_49_3)
	arg_49_2 = self:WrapCallbackOnce(arg_49_2)

	if self.modeState == RoomIKSystem.MODE_STATE.EXITING then
		if arg_49_2 then
			table.insert(self.pendingExitCallbacks, arg_49_2)
		end

		return
	end

	assert(self.modeState == RoomIKSystem.MODE_STATE.ACTIVE, string.format("Cannot exit IK from state: %s", tostring(self.modeState)))

	arg_49_3 = arg_49_3 or {}

	local var_49_0 = self:GetCurrentLadyEnv()

	assert(var_49_0, "Missing LadyEnv when exit IK")
	assert(self.session.currentIkConfig, "Missing current IK config when exit IK")
	assert(self:GetUIState() == "ik")

	arg_49_1 = self:BuildIKReturnInfo(arg_49_1)

	local var_49_1 = self:BeginIKTransition(RoomIKSystem.MODE_STATE.EXITING)

	seriesAsync({
		function(arg_50_0)
			if not self:IsIKTransitionActive(var_49_1, RoomIKSystem.MODE_STATE.EXITING) then
				return
			end

			self:Emit(Dorm3dIKView.SET_CONTROL_ACTIVE, false)
			self:AcquireIKBlock()
			Shader.SetGlobalFloat("_ScreenClipOff", 1)
			arg_50_0()
		end,
		function(arg_51_0)
			if not self:IsIKTransitionActive(var_49_1, RoomIKSystem.MODE_STATE.EXITING) then
				return
			end

			self:ClearIKRuntime(var_49_0, arg_49_3)
			self:ApplyIKReturn(var_49_0, arg_49_1, arg_51_0, var_49_1)
		end,
		function(arg_52_0)
			if not self:IsIKTransitionActive(var_49_1, RoomIKSystem.MODE_STATE.EXITING) then
				return
			end

			self:Emit(Dorm3dRoomScene.EXTRA_SET_UI, arg_52_0, "back")
		end,
		function(arg_53_0)
			if not self:IsIKTransitionActive(var_49_1, RoomIKSystem.MODE_STATE.EXITING) then
				return
			end

			self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE, var_49_0, "inIK", false)
			self:ReleaseIKBlock()
			arg_53_0()
		end
	}, function()
		if not self:IsIKTransitionActive(var_49_1, RoomIKSystem.MODE_STATE.EXITING) then
			return
		end

		self.modeState = RoomIKSystem.MODE_STATE.IDLE

		self:FlushExitCallbacks(arg_49_2)
	end)
end

function RoomIKSystem:EnterStockingIKMode(arg_55_1)
	assert(self:GetCurrentLadyEnv(), "Missing LadyEnv when enter stocking IK mode")
	assert(self.modeState == RoomIKSystem.MODE_STATE.ACTIVE, "Stocking mode requires active IK")
	assert(self.session.currentIkStatus, "Missing current IK status when enter stocking IK mode")

	self.session.stockingCachedIkStatus = self.session.currentIkStatus

	self:ExitIK(arg_55_1, {
		ignoreResetExtraItem = true
	})
end

function RoomIKSystem:ExitStockingIKMode(arg_56_1)
	assert(self:GetCurrentLadyEnv(), "Missing LadyEnv when exit stocking IK mode")
	assert(self.modeState == RoomIKSystem.MODE_STATE.IDLE, "Exit stocking mode requires idle IK")
	assert(self.session.stockingCachedIkStatus, "Missing cached IK status when exit stocking IK mode")

	self.session.stockingCachedIkStatus = nil

	self:EnterIK(self.session.stockingCachedIkStatus, arg_56_1)
end

function RoomIKSystem:EnterAimIKMode(arg_57_1)
	assert(self.modeState == RoomIKSystem.MODE_STATE.ACTIVE, "Touch AimIK mode requires active IK")
	assert(self.session.currentIkStatus, "Missing current IK status when enter touch AimIK mode")
	assert(not self.session.aimIKCachedIkStatus, "Touch AimIK mode is already active")

	self.session.aimIKCachedIkStatus = self.session.currentIkStatus

	self:ExitIK(arg_57_1, {
		ignoreResetExtraItem = true
	})
end

function RoomIKSystem:ExitAimIKMode(arg_58_1)
	assert(self.modeState == RoomIKSystem.MODE_STATE.IDLE, "Exit touch AimIK mode requires idle IK")
	assert(self.session.aimIKCachedIkStatus, "Missing cached IK status when exit touch AimIK mode")

	self.session.aimIKCachedIkStatus = nil

	self:EnterIK(self.session.aimIKCachedIkStatus, arg_58_1)
end

function RoomIKSystem:GetSession()
	return self.session
end

function RoomIKSystem:CancelControlInput()
	if self.input then
		self.input:Cancel()
	end
end

function RoomIKSystem:BeginIKBodyDrag(arg_61_1, arg_61_2)
	if not self:CanHandleIKInput() then
		return
	end

	if self.session:IsBlocked() or self.session.ikHandler then
		return
	end

	self.driver:BeginDrag(arg_61_1, arg_61_2)
end

function RoomIKSystem:DragIKBody(arg_62_1)
	if not self:CanHandleIKInput() then
		return
	end

	if not self.session.ikHandler then
		return
	end

	self.driver:Drag(arg_62_1)
end

function RoomIKSystem:ReleaseIKBody()
	self.driver:Release()
end

function RoomIKSystem:OnControlPointerDown(arg_64_1)
	self.input:OnControlPointerDown(arg_64_1)
end

function RoomIKSystem:OnControlPointerUp(arg_65_1)
	self.input:OnControlPointerUp(arg_65_1)
end

function RoomIKSystem:OnControlBeginDrag(arg_66_1)
	self.input:OnControlBeginDrag(arg_66_1)
end

function RoomIKSystem:OnControlDrag(arg_67_1, arg_67_2)
	self.input:OnControlDrag(arg_67_1, arg_67_2)
end

function RoomIKSystem:OnControlEndDrag(arg_68_1)
	self.input:OnControlEndDrag(arg_68_1)
end

function RoomIKSystem:GetIKRaycastTargets(arg_69_1)
	return self.input:GetIKRaycastTargets(arg_69_1)
end

function RoomIKSystem:ResolveBodyTarget(arg_70_1)
	return self.input:ResolveBodyTarget(arg_70_1)
end

function RoomIKSystem:ResolveTouchTarget(arg_71_1)
	return self.input:ResolveTouchTarget(arg_71_1)
end

function RoomIKSystem:ResolveTouchSceneItem(arg_72_1)
	return self.input:ResolveTouchSceneItem(arg_72_1)
end

function RoomIKSystem:IsTransformInHierarchy(arg_73_1)
	return RoomIKInput.IsTransformInHierarchy(self, arg_73_1)
end

function RoomIKSystem:EmitTouchPress(arg_74_1, arg_74_2, arg_74_3)
	self.input:EmitTouchPress(arg_74_1, arg_74_2, arg_74_3)
end

function RoomIKSystem:OnIKLayerActive(arg_75_1)
	self.session.ikHandler = arg_75_1

	local var_75_0 = _.detect(self.session.readyIKLayers or {}, function(arg_76_0)
		return arg_76_0:GetControllerPath() == arg_75_1.ikData:GetControllerPath()
	end)

	if not var_75_0 then
		return
	end

	self.session:AcquireBlock("drag")
	self:EnableIKLayer(var_75_0)

	self.session.ikNextCheckStamp = Time.time + RoomIKSystem.IK_STATUS_DELTA

	self:Emit(RoomIKSystem.ON_IK_STATUS_CHANGED, var_75_0:GetConfigID(), RoomIKSystem.IK_STATUS.BEGIN)
end

function RoomIKSystem:OnIKLayerDrag(arg_77_1)
	self.session.ikHandler = arg_77_1

	self:ResetIKTipTimer()
end

function RoomIKSystem:OnIKLayerDeactive(arg_78_1, arg_78_2)
	local var_78_1 = _.detect(self.session.readyIKLayers or {}, function(arg_79_0)
		return arg_79_0:GetControllerPath() == arg_78_1.ikData:GetControllerPath()
	end)

	if not var_78_1 then
		return
	end

	self:DeactiveIKLayer(var_78_1)

	self.session.ikHandler = nil

	self.session:ReleaseBlock("drag")

	if arg_78_2 then
		self.session:AcquireBlock("trigger")
	end

	self:Emit(RoomIKSystem.ON_IK_STATUS_CHANGED, var_78_1:GetConfigID(), RoomIKSystem.IK_STATUS.RELEASE)
end

function RoomIKSystem:OnIKLayerAction(arg_80_1)
	self.session:ReleaseBlock("trigger")

	local var_80_0 = _.detect(self.session.readyIKLayers or {}, function(arg_81_0)
		return arg_81_0:GetControllerPath() == arg_80_1.ikData:GetControllerPath()
	end)

	if not var_80_0 then
		return
	end

	self:OnTriggerIK(var_80_0)
	self:Emit(RoomIKSystem.ON_IK_STATUS_CHANGED, var_80_0:GetConfigID(), RoomIKSystem.IK_STATUS.TRIGGER)
end

function RoomIKSystem:GetDriverCallbacks()
	return {
		active = function(arg_83_0)
			self:OnIKLayerActive(arg_83_0)
		end,
		drag = function(arg_84_0)
			self:OnIKLayerDrag(arg_84_0)
		end,
		deactive = function(arg_85_0, arg_85_1)
			self:OnIKLayerDeactive(arg_85_0, arg_85_1)
		end,
		action = function(arg_86_0)
			self:OnIKLayerAction(arg_86_0)
		end
	}
end

function RoomIKSystem:ValidateIKSpec(arg_87_1)
	return self.sessionBuilder:ValidateSpec(arg_87_1)
end

function RoomIKSystem:ActivateIKSession(arg_88_1, arg_88_2)
	assert(arg_88_1 and arg_88_1.validated, "RoomIK session spec must be validated before activation")

	if not arg_88_1.raycaster then
		arg_88_1.raycaster = GetOrAddComponent(arg_88_1.raycastCameraTF, typeof(UnityEngine.EventSystems.PhysicsRaycaster))

		assert(arg_88_1.raycaster, "Missing RoomIK raycaster")
	end

	local var_88_0 = self.session:Start(arg_88_1.mode)

	self.session:ApplySpec(arg_88_1)

	self.session.enableIKTip = true

	self:ResetIKTipTimer()
	self:CancelControlInput()
	existCall(arg_88_2, arg_88_1)
	self:Emit(RoomTouchSystem.CANCEL_TOUCH_PRESS)

	if arg_88_1.mode == "normal" then
		self:Emit(RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA, self.session.ikTouchDatas, arg_88_1.statusId)
	else
		self:Emit(RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA, nil)
	end

	self.driver:Attach(self.session, self:GetDriverCallbacks())
	self:Emit(Dorm3dIKView.UPDATE_TEXT_TIPS, RoomIKTipBuilder.BuildTextTips(self.session.readyIKLayers))

	return var_88_0
end

function RoomIKSystem:SetIKStatus(arg_89_1, arg_89_2, arg_89_3, arg_89_4, arg_89_5, arg_89_6, arg_89_7)
	warning("Set IKStatus " .. (arg_89_2.id or "NIL"))

	if not arg_89_7 then
		arg_89_7 = self.sessionBuilder:BuildNormal(arg_89_1, arg_89_2, function(arg_90_0)
			self:OnNormalIKLayerAction(arg_90_0)
		end)

		self:ValidateIKSpec(arg_89_7)
	end

	local var_89_1 = self:GetCameras()
	local var_89_2 = self:ActivateIKSession(arg_89_7, function()
		setActive(arg_89_1.ladyCollider, false)
		_.each(arg_89_1.ladyTouchColliders, function(arg_92_0)
			setActive(arg_92_0, true)
		end)
		_.each(arg_89_7.sceneItems, function(arg_93_0)
			if IsNil(GetComponent(arg_93_0.target, typeof(UnityEngine.Collider))) then
				go(arg_93_0.target):AddComponent(typeof(UnityEngine.BoxCollider))
			end
		end)
	end)

	if var_89_1[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH] then
		setActive(var_89_1[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH], false)

		var_89_1[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH] = nil
	end

	var_89_1[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH] = arg_89_7.ikCameraTF

	self:Emit(Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA, var_89_1[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH])

	local var_89_3 = arg_89_7.ikCameraTF:GetComponent(typeof(Cinemachine.CinemachineFreeLook))

	if var_89_3 then
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_REGISTER_ORBITS, var_89_3)
	else
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_REVERT_CAMERA_ORBIT)
	end

	self:Emit(Dorm3dRoomTemplateScene.EXTRA_SWITCH_ANIM, arg_89_1, arg_89_2.character_action, nil, true)
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_HEAD_AIM_IK, arg_89_1, arg_89_2.head_track)
	arg_89_1:EnableCloth(false)
	arg_89_1:EnableCloth(arg_89_2.use_cloth, arg_89_2.cloth_colliders)
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_SCENE_ANIM, arg_89_2.enter_scene_anim, true)
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_EXTRA_ITEM, arg_89_1, arg_89_2.enter_extra_item, true)
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_HIDE_SCENE_ITEM, arg_89_2.hide_scene_item)
	onNextTick(function()
		if not self.session:IsCurrent(var_89_2) then
			return
		end

		if arg_89_5 and not self:IsIKTransitionActive(arg_89_5, arg_89_6) then
			return
		end

		arg_89_1.lady.position = arg_89_7.stayPoint.position
		arg_89_1.lady.rotation = arg_89_7.stayPoint.rotation

		existCall(arg_89_3)
	end)
end

function RoomIKSystem:ClearIKStatusRuntime(arg_95_1, arg_95_2)
	arg_95_2 = arg_95_2 or {}
	self.session.enableIKTip = false

	self:CancelControlInput()
	setActive(arg_95_1.ladyCollider, true)
	_.each(arg_95_1.ladyTouchColliders, function(arg_96_0)
		setActive(arg_96_0, false)
	end)
	self.session:ClearBlocks()
	self.driver:Detach()

	self.session.ikHandler = nil

	self:Emit(Dorm3dIKView.SET_TIPS_ACTIVE, false)
	self:Emit(RoomTouchSystem.CANCEL_TOUCH_PRESS)
	self:Emit(RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA, nil)
	self.session:ClearRuntime()
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_REVERT_CAMERA_ORBIT)

	local var_95_0 = self:GetCameras()[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH]

	if var_95_0 then
		setActive(var_95_0, false)

		self:GetCameras()[Dorm3dRoomTemplateScene.CAMERA.IK_WATCH] = nil
	end

	arg_95_1:EnableCloth(false)
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_HEAD_AIM_IK, arg_95_1)
	self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_SCENE_ITEM_ANIMATORS)

	if not arg_95_2.ignoreResetExtraItem then
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_CHARACTER_EXTRA_ITEM)
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_TEMP_HIDE_SCENE_ITEMS)
	end
end

function RoomIKSystem:ClearIKRuntime(arg_97_1, arg_97_2)
	arg_97_2 = arg_97_2 or {}

	if self.session.ikSwitchSkinId then
		arg_97_1:SwitchCharacterSkin(self:GetApartment():GetConfigID(), self.session.ikSwitchSkinId)

		self.session.ikSwitchSkinId = nil
	end

	self:ClearIKStatusRuntime(arg_97_1, arg_97_2)
end

function RoomIKSystem:BuildIKReturnInfo(arg_98_1)
	assert(type(arg_98_1) == "table", "Invalid IK return info")
	assert(type(arg_98_1.character_action) == "string", "Invalid IK return character_action")
	assert(arg_98_1.character_position == nil or type(arg_98_1.character_position) == "string" and arg_98_1.character_position ~= "", "Invalid IK return character_position")

	local var_98_0 = arg_98_1.character_position or self:GetLadyBaseZone(self:GetApartment():GetConfigID())

	assert(type(var_98_0) == "string" and var_98_0 ~= "", "Invalid IK return character_position")

	local var_98_1 = self:GetIKPointByName(var_98_0) or self:GetZoneByName(var_98_0)

	assert(var_98_1 and var_98_1:Find("StayPoint"), "Missing IK return character position: " .. var_98_0)

	return {
		character_position = var_98_0,
		character_action = arg_98_1.character_action
	}
end

function RoomIKSystem:ApplyIKReturn(arg_99_1, arg_99_2, arg_99_3, arg_99_4)
	arg_99_3 = self:WrapCallbackOnce(arg_99_3)

	self:Emit(Dorm3dRoomTemplateScene.EXTRA_SWITCH_ANIM, arg_99_1, arg_99_2.character_action)
	onNextTick(function()
		if arg_99_4 and not self:IsIKTransitionActive(arg_99_4, RoomIKSystem.MODE_STATE.EXITING) then
			return
		end

		self:Emit(Dorm3dRoomTemplateScene.EXTRA_CHANGE_CHARACTER_POSITION, arg_99_1, arg_99_2.character_position)
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_TRIGGER_LADY_DISTANCE)
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_CHECK_IN_SECTOR)
		existCall(arg_99_3)
	end)
end

function RoomIKSystem:SaveIKTimelineColliderState(arg_101_1)
	self.session.ikTimelineColliderStates = self.session.ikTimelineColliderStates or {}

	if self.session.ikTimelineColliderStates[arg_101_1] == nil then
		self.session.ikTimelineColliderStates[arg_101_1] = isActive(arg_101_1)
	end
end

function RoomIKSystem:SetIKTimelineColliderActive(arg_102_1, arg_102_2)
	self:SaveIKTimelineColliderState(arg_102_1)
	setActive(arg_102_1, arg_102_2)
end

function RoomIKSystem:RestoreIKTimelineColliders()
	if not self.session.ikTimelineColliderStates then
		return
	end

	for iter_103_0, iter_103_1 in pairs(self.session.ikTimelineColliderStates) do
		if iter_103_0 and not IsNil(iter_103_0) then
			setActive(iter_103_0, iter_103_1)
		end
	end

	self.session.ikTimelineColliderStates = nil
end

function RoomIKSystem:ClearIKTimelineRuntime()
	if not self:IsInIKTimelineMode() and not self.session.ikTimelineColliderStates then
		return
	end

	self:SetCurrentIkTimelineStatus(nil)

	self.session.enableIKTip = false

	self:CancelControlInput()
	self:Emit(Dorm3dIKView.SET_CONTROL_ACTIVE, false)
	self.session:ClearBlocks()
	self.driver:Detach()
	self.session:ClearRuntime()
	self:RestoreIKTimelineColliders()
	self:Emit(RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA, nil)
	self:Emit(Dorm3dIKView.SET_TIPS_ACTIVE, false)
end

function RoomIKSystem:SetIKTimelineStatus(arg_105_1, arg_105_2, arg_105_3, arg_105_4)
	arg_105_4 = self:WrapCallbackOnce(arg_105_4)

	if not self:CheckIkTimelineStatus(arg_105_2) then
		existCall(arg_105_4)

		return
	end

	local var_105_0 = self.sessionBuilder:BuildTimeline(arg_105_1, arg_105_2, arg_105_3, function(arg_106_0)
		self:OnTimelineIKLayerAction(arg_106_0)
	end)

	self:ValidateIKSpec(var_105_0)

	if self:IsInIKTimelineMode() then
		self:ClearIKTimelineRuntime()
	else
		assert(self.modeState == RoomIKSystem.MODE_STATE.IDLE, string.format("Cannot enter timeline IK from state: %s", tostring(self.modeState)))
	end

	warning("Set IKStatus " .. (arg_105_2 or "NIL"))
	self:ActivateIKSession(var_105_0, function()
		_.each(var_105_0.colliderChanges, function(arg_108_0)
			self:SetIKTimelineColliderActive(arg_108_0.target, arg_108_0.active)
		end)
	end)
	self:Emit(Dorm3dIKView.SET_CONTROL_ACTIVE, true)
	existCall(arg_105_4)
end

function RoomIKSystem:ExitIKTimelineStatus(arg_109_1)
	arg_109_1 = self:WrapCallbackOnce(arg_109_1)

	if not self:IsInIKTimelineMode() then
		existCall(arg_109_1)

		return
	end

	self:ClearIKTimelineRuntime()
	existCall(arg_109_1)
end

function RoomIKSystem:SetCurrentIkTimelineStatus(arg_110_1)
	self.session.currentIkTimelineStatus = arg_110_1
end

function RoomIKSystem:CheckIkTimelineStatus(arg_111_1)
	if not self.session.currentIkTimelineStatus then
		return true
	end

	return self.session.currentIkTimelineStatus ~= arg_111_1
end

function RoomIKSystem:IsInIKTimelineMode()
	return self.session.mode == "timeline"
end

function RoomIKSystem:IsIKModeActive()
	return self.modeState == RoomIKSystem.MODE_STATE.ACTIVE
end

function RoomIKSystem:CanHandleIKInput()
	return self:IsIKModeActive() or self:IsInIKTimelineMode()
end

function RoomIKSystem:EnableIKLayer(arg_115_1)
	local var_115_0 = self:GetCurrentLadyEnv()

	if #arg_115_1:GetHeadTrackPath() > 0 then
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_HEAD_AIM_IK, var_115_0, {
			2,
			arg_115_1:GetHeadTrackPath()
		}, true)
	end

	local var_115_1 = arg_115_1:GetTriggerFaceAnim()

	if #var_115_1 > 0 then
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_FACE_ANIM, var_115_0, var_115_1)
	end

	if not arg_115_1.ignoreDrag then
		self:Emit(Dorm3dIKView.PLAY_HAND_BEGIN)
	end

	if not self:IsInIKTimelineMode() then
		assert(self.session.currentIkConfig, "Missing current IK config")
		pg.m02:sendNotification(GAME.APARTMENT_TRACK, Dorm3dTrackCommand.BuildDataTouch(self:GetApartment().configId, self:GetApartment().level, self.session.currentIkConfig.character_action, arg_115_1:GetTriggerParams()[2], self:GetRoom():GetConfigID()))
	end
end

function RoomIKSystem:DeactiveIKLayer(arg_116_1)
	if not self:IsInIKTimelineMode() and #arg_116_1:GetHeadTrackPath() > 0 then
		assert(self.session.currentIkConfig, "Missing current IK config")
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_HEAD_AIM_IK, self:GetCurrentLadyEnv(), self.session.currentIkConfig.head_track)
	end

	if not arg_116_1.ignoreDrag then
		self:Emit(Dorm3dIKView.PLAY_HAND_END)
	end
end

function RoomIKSystem:ResetIKTipTimer()
	if not self.session.enableIKTip then
		return
	end

	self.session.nextTipIKTime = Time.time + RoomIKSystem.IK_TIP_WAIT_TIME
end

function RoomIKSystem:PlayTouchIKMove(arg_118_1, arg_118_2, arg_118_3, arg_118_4, arg_118_5)
	arg_118_5 = self:WrapCallbackOnce(arg_118_5)

	assert(self:IsIKModeActive(), "Touch IK move requires active IK")
	assert(type(arg_118_2) == "table" and #arg_118_2 == 2, "Invalid touch IK move point: " .. tostring(arg_118_1))
	assert(type(arg_118_3) == "number", "Invalid touch IK move step: " .. tostring(arg_118_1))
	assert(type(arg_118_4) == "number", "Invalid touch IK move time: " .. tostring(arg_118_1))
	assert(self.session.ikSettings, "Missing IK settings when play touch IK move")
	assert(self.session.ikSettings.Colliders, "Missing IK colliders when play touch IK move")

	local var_118_0 = Dorm3dIK.New({
		configId = arg_118_1
	}):GetTriggerBoneName()

	assert(self.session.ikSettings.Colliders[var_118_0], "Missing IK collider: " .. tostring(var_118_0))
	self.driver:Reset(var_118_0)
	self.driver:PlayMove(self:GetRaycastCamera():WorldToScreenPoint(self.session.ikSettings.Colliders[var_118_0].position), var_118_0, Vector2.New(unpack(arg_118_2)), arg_118_3, arg_118_4, arg_118_5)
end

function RoomIKSystem:OnNormalIKLayerAction(arg_119_1)
	if not self:IsIKModeActive() then
		return
	end

	if not self.session.currentIkConfig then
		return
	end

	local var_119_0 = self:GetCurrentLadyEnv()
	local var_119_1 = self.session.ikActionDict[arg_119_1:GetControllerPath()]

	if not var_119_1 then
		return
	end

	self.session:AcquireBlock("layer_action")
	self:Emit(RoomIKSystem.ON_IK_LAYER_ACTION, var_119_0, arg_119_1:GetConfigID(), var_119_1, (self:WrapCallbackOnce(function()
		self:ResetIKTipTimer()
		self.session:ReleaseBlock("layer_action")
	end)))
end

function RoomIKSystem:OnTimelineIKLayerAction(arg_121_1)
	if not self:IsInIKTimelineMode() then
		return
	end

	self:ExitIKTimelineStatus()

	local var_121_0 = arg_121_1:GetTimelineAction()

	if var_121_0 then
		self:GetNowTimelinePlayer():TriggerEvent(var_121_0)
	end
end

function RoomIKSystem:OnTriggerIK(arg_122_1)
	if not self:CanHandleIKInput() then
		return
	end

	local var_122_0 = self.session.spec

	if not self.session.spec or not var_122_0.onLayerAction then
		return
	end

	var_122_0.onLayerAction(arg_122_1)
end

function RoomIKSystem:UpdateIKTarget()
	if not self:CanHandleIKInput() then
		return
	end

	if not self:GetApartment() then
		return
	end

	if not self:GetCurrentLadyEnv() then
		return
	end

	if self.session.ikHandler then
		local var_123_0

		if not self.session.readyIKLayers then
			do return end

			var_123_0 = pg.UIMgr.GetInstance().uiCamera:Find("Canvas").rect
		end

		self:Emit(Dorm3dIKView.SET_HAND_POSITION, self.session.ikHandler.screenPosition - Vector2.New(var_123_0.width, var_123_0.height) * 0.5)

		if Time.time > self.session.ikNextCheckStamp then
			self.session.ikNextCheckStamp = self.session.ikNextCheckStamp + RoomIKSystem.IK_STATUS_DELTA

			self:Emit(RoomIKSystem.ON_IK_STATUS_CHANGED, _.detect(self.session.readyIKLayers, function(arg_124_0)
				return arg_124_0:GetControllerPath() == self.session.ikHandler.ikData:GetControllerPath()
			end):GetConfigID(), RoomIKSystem.IK_STATUS.DRAG)
		end
	end

	if self.session.enableIKTip then
		if not self.session.readyIKLayers or not self.session.ikSettings then
			return
		end

		self:UpdateIKTips()
	end
end

function RoomIKSystem:UpdateIKTips()
	local var_125_0

	if not self.session.nextTipIKTime then
		do return end

		function var_125_0(arg_126_0)
			local var_126_0 = {}

			self:Emit(Dorm3dRoomTemplateScene.EXTRA_GET_SCREEN_POSITION, var_126_0, arg_126_0, self.session.ikSettings.CameraRaycaster.eventCamera)

			return var_126_0.value
		end
	end

	self:Emit(Dorm3dIKView.UPDATE_TIPS, not self.session:IsBlocked() and Time.time > self.session.nextTipIKTime, RoomIKTipBuilder.BuildIKTips(self.session.readyIKLayers, self.session.ikSettings, var_125_0), RoomIKTipBuilder.BuildTouchTips(self.session.ikTouchDatas, pg.dorm3d_ik_touch, self.session.ikSettings, function(arg_127_0)
		return self:GetSceneItem(arg_127_0)
	end, var_125_0))
end

function RoomIKSystem:CycleIKCameraGroup()
	assert(self:GetCurrentLadyEnv(), "Missing LadyEnv when cycle IK camera group")
	assert(self:IsIKModeActive(), "Cycle IK camera group requires active IK")
	self.driver:ResetActiveLayers()
	assert(self.session.currentIkConfig, "Missing current IK config")
	self:ReplaceIKStatus(pg.dorm3d_ik_status.get_id_list_by_camera_group[self.session.currentIkConfig.camera_group][table.indexof(pg.dorm3d_ik_status.get_id_list_by_camera_group[self.session.currentIkConfig.camera_group], self.session.currentIkConfig.id) % #pg.dorm3d_ik_status.get_id_list_by_camera_group[self.session.currentIkConfig.camera_group] + 1])
end

function RoomIKSystem:SetIKSwitchSkinId(arg_129_1)
	self.session.ikSwitchSkinId = arg_129_1
end

function RoomIKSystem:SwitchIKSkin(arg_130_1, arg_130_2, arg_130_3)
	assert(self:IsIKModeActive(), "Switch IK skin requires active IK")
	assert(self.session.currentIkConfig, "Missing current IK config")

	local var_130_0 = self.session.currentIkConfig.id

	seriesAsync({
		function(arg_131_0)
			self:ExitIK(arg_131_0)
		end,
		function(arg_132_0)
			arg_130_1:SwitchCharacterSkin(arg_130_2, arg_130_3)
			self:EnterIK(var_130_0, arg_132_0)
		end
	})
end

function RoomIKSystem:ConsumeIKSpecialCall()
	if not self.session.ikSpecialCall then
		return false
	end

	self.session.ikSpecialCall = nil

	existCall(self.session.ikSpecialCall)

	return true
end

return RoomIKSystem
