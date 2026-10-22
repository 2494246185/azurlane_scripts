local RoomTouchSystem = class("RoomTouchSystem", import("view.dorm3d.Core.BaseSystem"))
local RoomTouchTriggerRunner = import("view.dorm3d.System.RoomTouch.RoomTouchTriggerRunner")

RoomTouchSystem.ENTER_TOUCH_MODE = "RoomTouchSystem.ENTER_TOUCH_MODE"
RoomTouchSystem.EXIT_TOUCH_MODE = "RoomTouchSystem.EXIT_TOUCH_MODE"
RoomTouchSystem.EXIT_HEARTBEAT_MODE = "RoomTouchSystem.EXIT_HEARTBEAT_MODE"
RoomTouchSystem.ON_TOUCH_CHARACTER_DOWN = "RoomTouchSystem.ON_TOUCH_CHARACTER_DOWN"
RoomTouchSystem.ON_TOUCH_CHARACTER_UP = "RoomTouchSystem.ON_TOUCH_CHARACTER_UP"
RoomTouchSystem.ON_TOUCH_SCENE_ITEM_DOWN = "RoomTouchSystem.ON_TOUCH_SCENE_ITEM_DOWN"
RoomTouchSystem.ON_TOUCH_SCENE_ITEM_UP = "RoomTouchSystem.ON_TOUCH_SCENE_ITEM_UP"
RoomTouchSystem.CANCEL_TOUCH_PRESS = "RoomTouchSystem.CANCEL_TOUCH_PRESS"
RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA = "RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA"
RoomTouchSystem.UPDATE_TOUCH_PANEL = "RoomTouchSystem.UPDATE_TOUCH_PANEL"
RoomTouchSystem.UPDATE_TOUCH_COUNT = "RoomTouchSystem.UPDATE_TOUCH_COUNT"
RoomTouchSystem.UPDATE_TOUCH_LEVEL = "RoomTouchSystem.UPDATE_TOUCH_LEVEL"
RoomTouchSystem.UPDATE_TOUCH_DISPLAY = "RoomTouchSystem.UPDATE_TOUCH_DISPLAY"
RoomTouchSystem.GET_TOUCH_GAME_STATE = "RoomTouchSystem.GET_TOUCH_GAME_STATE"
RoomTouchSystem.SET_TOUCH_EXIT_CALL = "RoomTouchSystem.SET_TOUCH_EXIT_CALL"
RoomTouchSystem.TRIGGER_CLICK = RoomTouchTriggerRunner.TRIGGER_CLICK
RoomTouchSystem.TRIGGER_LONG_PRESS = RoomTouchTriggerRunner.TRIGGER_LONG_PRESS
RoomTouchSystem.MODE_STATE = {
	EXITING = "exiting",
	ENTERING = "entering",
	IDLE = "idle",
	ACTIVE = "active"
}

function RoomTouchSystem:OnInit()
	self.modeState = RoomTouchSystem.MODE_STATE.IDLE
	self.transitionSerial = 0
	self.touchTriggerRunner = RoomTouchTriggerRunner.New(self)
	self.activeIkTouchData = nil
	self.touchForceMove = nil
end

function RoomTouchSystem:RegisterEvents()
	self:Bind(RoomTouchSystem.ENTER_TOUCH_MODE, function(arg_3_0, arg_3_1)
		self:EnterTouchMode(arg_3_1)
	end)
	self:Bind(RoomTouchSystem.EXIT_TOUCH_MODE, function()
		self:ExitTouchMode()
	end)
	self:Bind(RoomTouchSystem.EXIT_HEARTBEAT_MODE, function()
		self:ExitHeartbeatMode()
	end)
	self:Bind(RoomTouchSystem.ON_TOUCH_CHARACTER_DOWN, function(arg_6_0, arg_6_1, arg_6_2)
		self.touchTriggerRunner:OnTouchPressDown("body", arg_6_1, arg_6_2)
	end)
	self:Bind(RoomTouchSystem.ON_TOUCH_CHARACTER_UP, function(arg_7_0, arg_7_1)
		self.touchTriggerRunner:OnTouchPressUp("body", arg_7_1)
	end)
	self:Bind(RoomTouchSystem.ON_TOUCH_SCENE_ITEM_DOWN, function(arg_8_0, arg_8_1, arg_8_2)
		self.touchTriggerRunner:OnTouchPressDown("scene_item", arg_8_1, arg_8_2)
	end)
	self:Bind(RoomTouchSystem.ON_TOUCH_SCENE_ITEM_UP, function(arg_9_0, arg_9_1)
		self.touchTriggerRunner:OnTouchPressUp("scene_item", arg_9_1)
	end)
	self:Bind(RoomTouchSystem.CANCEL_TOUCH_PRESS, function()
		self.touchTriggerRunner:CancelAllTouchPress()
	end)
	self:Bind(RoomTouchSystem.SET_ACTIVE_IK_TOUCH_DATA, function(arg_11_0, arg_11_1, arg_11_2)
		self:SetActiveIKTouchData(arg_11_1, arg_11_2)
	end)
	self:Bind(RoomIKSystem.ON_IK_STATUS_CHANGED, function(arg_12_0, arg_12_1, arg_12_2)
		if not self:IsTouchModeActive() then
			return
		end

		self:DoTouch(arg_12_1, arg_12_2)
	end)
	self:Bind(RoomIKSystem.ON_IK_LAYER_ACTION, function(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4)
		self:TouchModeAction(arg_13_1, arg_13_2, unpack(arg_13_3))(arg_13_4)
	end)
	self:Bind(RoomTouchSystem.GET_TOUCH_GAME_STATE, function(arg_14_0, arg_14_1)
		if arg_14_1 then
			arg_14_1.inTouchGame = self.inTouchGame
		end
	end)
	self:Bind(RoomTouchSystem.SET_TOUCH_EXIT_CALL, function(arg_15_0, arg_15_1)
		self.touchExitCall = arg_15_1
	end)
end

function RoomTouchSystem:OnDispose()
	self.transitionSerial = self.transitionSerial + 1

	self.touchTriggerRunner:CancelAllTouchPress()

	self.modeState = RoomTouchSystem.MODE_STATE.IDLE
	self.activeIkTouchData = nil
	self.touchForceMove = nil

	if self.downTimer then
		self.downTimer:Stop()

		self.downTimer = nil
	end

	if self.sliderLT and LeanTween.isTweening(self.sliderLT) then
		LeanTween.cancel(self.sliderLT)

		self.sliderLT = nil
	end
end

function RoomTouchSystem:SetActiveIKTouchData(arg_17_1, arg_17_2)
	if arg_17_1 then
		self.touchTriggerRunner:ValidateTouchConfigs(arg_17_1, arg_17_2)
	end

	self.activeIkTouchData = arg_17_1
	self.touchForceMove = arg_17_1 and {} or nil
end

function RoomTouchSystem:GetActiveIKTouchData()
	return self.activeIkTouchData
end

function RoomTouchSystem:IsTouchModeActive()
	return self.modeState == RoomTouchSystem.MODE_STATE.ACTIVE
end

function RoomTouchSystem:BeginTouchTransition(arg_20_1)
	self.transitionSerial = self.transitionSerial + 1
	self.modeState = arg_20_1

	return self.transitionSerial
end

function RoomTouchSystem:IsTouchTransitionActive(arg_21_1, arg_21_2)
	return self.transitionSerial == arg_21_1 and self.modeState == arg_21_2
end

function RoomTouchSystem:OnUpdate()
	self.touchTriggerRunner:Update()
end

function RoomTouchSystem:EnterTouchMode(arg_23_1)
	local var_23_0 = self:GetCurrentLadyEnv()

	if self.modeState ~= RoomTouchSystem.MODE_STATE.IDLE then
		return
	end

	local var_23_1 = self:GetApartment():GetConfigID()

	arg_23_1 = arg_23_1 or self:GetRoom():getApartmentZoneConfig(self:GetLadyBaseZone(var_23_1), "touch_id", var_23_1)
	self.touchConfig = pg.dorm3d_touch_data[arg_23_1]

	assert(self.touchConfig, "Missing dorm3d_touch_data config: " .. tostring(arg_23_1))

	local var_23_2 = self:BeginTouchTransition(RoomTouchSystem.MODE_STATE.ENTERING)

	self.inTouchGame = self.touchConfig.heartbeat_enable > 0

	self:Emit(RoomTouchSystem.UPDATE_TOUCH_PANEL, self.inTouchGame)

	if self.inTouchGame then
		self.touchCount = 0
		self.touchLevel = 1
		self.lastCount = 0
		self.topCount = 0

		self:Emit(RoomTouchSystem.UPDATE_TOUCH_DISPLAY, self.touchLevel, self.touchCount)

		self.downTimer = Timer.New(function()
			if not self:IsTouchModeActive() then
				return
			end

			self:UpdateTouchCount((self.touchLevel > 1 or nil) and pg.dorm3d_set.reduce_heartbeat.key_value_int)
		end, 1, -1)

		self.downTimer:Start()
	end

	local var_23_3 = {}

	table.insert(var_23_3, function(arg_25_0)
		if not self:IsTouchTransitionActive(var_23_2, RoomTouchSystem.MODE_STATE.ENTERING) then
			return
		end

		self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE, var_23_0, "inTouching", true)
		self:Emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
		self:Emit(Dorm3dRoomScene.EXTRA_SET_UI, arg_25_0, "blank")
	end)
	table.insert(var_23_3, function(arg_26_0)
		if not self:IsTouchTransitionActive(var_23_2, RoomTouchSystem.MODE_STATE.ENTERING) then
			return
		end

		self:Emit(RoomIKSystem.ENTER_IK, self.touchConfig.ik_status[1], arg_26_0)
	end)
	table.insert(var_23_3, function(arg_27_0)
		if not self:IsTouchTransitionActive(var_23_2, RoomTouchSystem.MODE_STATE.ENTERING) then
			return
		end

		existCall(arg_27_0)
	end)
	seriesAsync(var_23_3, function()
		if not self:IsTouchTransitionActive(var_23_2, RoomTouchSystem.MODE_STATE.ENTERING) then
			return
		end

		self.modeState = RoomTouchSystem.MODE_STATE.ACTIVE

		Shader.SetGlobalFloat("_ScreenClipOff", 0)
		self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
	end)
end

function RoomTouchSystem:ExitTouchMode()
	local var_29_0 = self:GetCurrentLadyEnv()

	if self.modeState ~= RoomTouchSystem.MODE_STATE.ACTIVE then
		return
	end

	local var_29_1 = self:BeginTouchTransition(RoomTouchSystem.MODE_STATE.EXITING)
	local var_29_2 = {}

	self.touchTriggerRunner:CancelAllTouchPress()
	table.insert(var_29_2, function(arg_30_0)
		if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
			return
		end

		self:Emit(AimIKSystem.ON_EXIT_TOUCH_MODE, arg_30_0)
	end)

	if self.inTouchGame then
		table.insert(var_29_2, function(arg_31_0)
			if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
				return
			end

			self:Emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
			self:Emit(RoomTouchSystem.UPDATE_TOUCH_PANEL, false, true, arg_31_0)
		end)
		table.insert(var_29_2, function(arg_32_0)
			if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
				return
			end

			local var_32_0 = 0

			for iter_32_0, iter_32_1 in ipairs(self.touchConfig.heartbeat_favor) do
				if iter_32_1[1] > self.topCount then
					break
				else
					var_32_0 = iter_32_1[2]
				end
			end

			if var_32_0 > 0 then
				self:Emit(Dorm3dRoomMediator.TRIGGER_FAVOR, self:GetApartment().configId, var_32_0)
			end

			self.touchCount = nil
			self.touchLevel = nil
			self.topCount = nil

			if self.downTimer then
				self.downTimer:Stop()

				self.downTimer = nil
			end

			self.inTouchGame = false

			Shader.SetGlobalFloat("_ScreenClipOff", 1)
			arg_32_0()
		end)
	else
		table.insert(var_29_2, function(arg_33_0)
			if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
				return
			end

			self:Emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)

			if self.touchConfig.default_favor > 0 then
				self:Emit(Dorm3dRoomMediator.TRIGGER_FAVOR, self:GetApartment().configId, self.touchConfig.default_favor)
			end

			Shader.SetGlobalFloat("_ScreenClipOff", 1)
			arg_33_0()
		end)
	end

	table.insert(var_29_2, function(arg_34_0)
		if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
			return
		end

		local var_34_0 = {}

		var_34_0.character_position = self:GetLadyBaseZone(self:GetApartment():GetConfigID())
		var_34_0.character_action = self.touchConfig.finish_action

		self:Emit(Dorm3dStockingMgr.ON_EXIT_TOUCH_MODE)
		self:Emit(RoomIKSystem.EXIT_IK_WITH_RETURN, var_34_0, arg_34_0)
	end)
	table.insert(var_29_2, function(arg_35_0)
		if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
			return
		end

		self:Emit(RoomIKSystem.SET_IK_SPECIAL_CALL, nil)
		self:Emit(Dorm3dRoomScene.EXTRA_SET_UI, arg_35_0, "back")
	end)
	seriesAsync(var_29_2, function()
		if not self:IsTouchTransitionActive(var_29_1, RoomTouchSystem.MODE_STATE.EXITING) then
			return
		end

		self:Emit(Dorm3dRoomTemplateScene.EXTRA_SET_BLACKBOARD_VALUE, var_29_0, "inTouching", false)
		self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)

		self.touchConfig = nil
		self.touchExitCall = nil
		self.modeState = RoomTouchSystem.MODE_STATE.IDLE

		existCall(self.touchExitCall)
	end)
end

function RoomTouchSystem:TouchModeAction(arg_37_1, arg_37_2, arg_37_3, ...)
	return switch(arg_37_3, {
		function(arg_38_0, arg_38_1)
			return function(arg_39_0)
				seriesAsync({
					function(arg_40_0)
						if not arg_38_1 or arg_38_1 == "" then
							return arg_40_0()
						end

						self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_SINGLE_ACTION, arg_37_1, arg_38_1, arg_40_0)
					end,
					function(arg_41_0)
						self:Emit(RoomIKSystem.REPLACE_IK_STATUS, arg_38_0, arg_41_0)
					end,
					arg_39_0
				})
			end
		end,
		function()
			return function()
				local var_43_0 = {}

				self:Emit(RoomIKSystem.CONSUME_IK_SPECIAL_CALL, var_43_0)

				if var_43_0.consumed then
					return
				end

				self:ExitTouchMode()
			end
		end,
		function(arg_44_0, arg_44_1)
			return function(arg_45_0)
				self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_SINGLE_ACTION, arg_37_1, arg_44_1, arg_45_0)
			end
		end,
		function(arg_46_0, arg_46_1, arg_46_2)
			return function(arg_47_0)
				seriesAsync({
					function(arg_48_0)
						self:Emit(Dorm3dRoomScene.EXTRA_DO_TALK, arg_46_1, arg_48_0)
					end,
					function(arg_49_0)
						if not arg_46_2 or arg_46_2 == 0 then
							return arg_49_0()
						end

						self:Emit(RoomIKSystem.REPLACE_IK_STATUS, arg_46_2, arg_49_0)
					end,
					arg_47_0
				})
			end
		end,
		function(arg_50_0, arg_50_1, arg_50_2, arg_50_3)
			return function(arg_51_0)
				self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_SCENE_ITEM_ANIM, arg_50_2, arg_50_3)
				self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_SINGLE_ACTION, arg_37_1, arg_50_1, arg_51_0)
			end
		end,
		function(arg_52_0)
			return function(arg_53_0)
				if #pg.dorm3d_ik_touch[arg_37_2].scene_item == 0 then
					return
				end

				local var_53_0 = self:GetSceneItem(pg.dorm3d_ik_touch[arg_37_2].scene_item)

				if not var_53_0 then
					warning(string.format("dorm3d_ik_touch:%d without scene_item:%s", arg_37_2, pg.dorm3d_ik_touch[arg_37_2].scene_item))

					return
				end

				local var_53_1 = var_53_0:Find(arg_52_0)

				if not IsNil(var_53_1) then
					setActive(var_53_1, false)
					setActive(var_53_1, true)
				end

				arg_53_0()
			end
		end,
		function(arg_54_0)
			assert(pg.dorm3d_ik_touch_move[arg_54_0], "Missing dorm3d_ik_touch_move config: " .. tostring(arg_54_0))

			local var_54_0 = pg.dorm3d_ik_touch_move[arg_54_0].target_ik
			local var_54_1 = pg.dorm3d_ik_touch_move[arg_54_0].move_time
			local var_54_2 = pg.dorm3d_ik_touch_move[arg_54_0].ik_point
			local var_54_3 = pg.dorm3d_ik_touch_move[arg_54_0].touch_step
			local var_54_4 = self.touchForceMove

			assert(self.touchForceMove, "Missing touch force move runtime")

			self.touchForceMove[pg.dorm3d_ik_touch_move[arg_54_0].target_ik] = self.touchForceMove[pg.dorm3d_ik_touch_move[arg_54_0].target_ik] or {}
			self.touchForceMove[pg.dorm3d_ik_touch_move[arg_54_0].target_ik].count = self.touchForceMove[pg.dorm3d_ik_touch_move[arg_54_0].target_ik].count or 0

			return function(arg_55_0)
				seriesAsync({
					function(arg_56_0)
						if var_54_4[var_54_0].count >= #var_54_3 then
							return arg_56_0()
						end

						var_54_4[var_54_0].count = var_54_4[var_54_0].count + 1

						self:Emit(RoomIKSystem.PLAY_TOUCH_IK_MOVE, var_54_0, var_54_2, var_54_3[var_54_4[var_54_0].count + 1], var_54_1, function()
							var_54_4[var_54_0].count = 0

							arg_56_0()
						end)
					end,
					arg_55_0
				})
			end
		end,
		function(arg_58_0)
			return function(arg_59_0)
				self:Emit(Dorm3dStockingMgr.SET_STOCKING_STATUS, arg_58_0)
			end
		end,
		function(arg_60_0, arg_60_1)
			return function()
				self:Emit(RoomIKSystem.SET_IK_SWITCH_SKIN_ID, self:GetApartment():GetCurSkinId())
				arg_37_1:SwitchCharacterSkin(self:GetApartment():GetConfigID(), arg_60_0)
				self:Emit(RoomIKSystem.REPLACE_IK_STATUS, arg_60_1)
			end
		end,
		function(arg_62_0)
			return function()
				self:Emit(AimIKSystem.ENTER_TOUCH_AIMIK_STATUS, arg_62_0)
			end
		end
	}, function()
		return function()
			return
		end
	end, ...)
end

function RoomTouchSystem:TriggerTouchInfo(arg_66_1)
	local var_66_0 = self:GetCurrentLadyEnv()
	local var_66_1, var_66_2, var_66_3 = unpack(arg_66_1)
	local var_66_4 = self.touchTriggerRunner:AssertTouchConfig(var_66_1)

	if #var_66_4.action_emote > 0 then
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_FACE_ANIM, var_66_0, var_66_4.action_emote)
	end

	if type(var_66_4.vibrate) == "table" and VibrateMgr.Instance:IsSupport() then
		local var_66_5 = {}
		local var_66_6 = {}
		local var_66_7 = {}

		underscore.each(var_66_4.vibrate, function(arg_67_0)
			local var_67_0 = arg_67_0[1]

			if PLATFORM == PLATFORM_IPHONEPLAYER then
				var_67_0 = var_67_0 / 1000
			end

			table.insert(var_66_5, var_67_0)
			table.insert(var_66_6, arg_67_0[2])
			table.insert(var_66_7, 1)
		end)

		if PLATFORM == PLATFORM_ANDROID then
			VibrateMgr.Instance:VibrateWaveform(var_66_5, var_66_6)
		elseif PLATFORM == PLATFORM_IPHONEPLAYER then
			VibrateMgr.Instance:VibrateWaveform(var_66_5, var_66_6, var_66_7)
		end
	end

	self:Emit(RoomIKSystem.SET_IK_BLOCK, true)
	self:TouchModeAction(var_66_0, var_66_1, unpack(var_66_3))(function()
		self:Emit(RoomIKSystem.RESET_IK_TIP_TIMER)
		self:Emit(RoomIKSystem.SET_IK_BLOCK, nil)
	end)
end

function RoomTouchSystem:UpdateTouchCount(arg_69_1)
	if not self:IsTouchModeActive() then
		return
	end

	local var_69_0

	if self.touchLevel > 1 then
		arg_69_1 = math.min(0, arg_69_1)
		var_69_0 = self.touchLevel > 1 and 200 or 100
	end

	self.touchCount = math.clamp(self.touchCount + arg_69_1, self.touchLevel > 1 and 100 or 0, var_69_0)

	local var_69_1

	if self.touchLevel == 1 and self.touchCount >= 100 then
		var_69_1 = 2
	elseif self.touchLevel > 1 and self.touchCount <= 100 then
		var_69_1 = 1
	end

	if var_69_1 and var_69_1 ~= self.touchLevel then
		local var_69_2 = {}

		self:Emit(RoomIKSystem.GET_IK_BLOCK, var_69_2)

		if var_69_2.blockIK then
			self:Emit(RoomTouchSystem.UPDATE_TOUCH_COUNT, self.touchCount)

			self.topCount = math.max(self.topCount, self.touchCount)

			return
		end

		self.touchLevel = var_69_1

		local var_69_3 = self.touchConfig.ik_status[var_69_1]

		if self.touchConfig.ik_status[var_69_1] then
			if var_69_1 > 1 then
				self.touchCount = 200
			elseif var_69_1 == 1 then
				self.touchCount = 0
			end

			local var_69_4 = self:GetCurrentLadyEnv()

			seriesAsync({
				function(arg_70_0)
					self:Emit(Dorm3dRoomTemplateScene.EXTRA_SHOW_BLACK_SCREEN, true, arg_70_0)
				end,
				function(arg_71_0)
					self:Emit(RoomIKSystem.REPLACE_IK_STATUS, var_69_3, arg_71_0)

					if var_69_1 > 1 and self.touchConfig.heartbeat_enter_anim ~= "" then
						self:Emit(Dorm3dRoomTemplateScene.EXTRA_SWITCH_ANIM, var_69_4, self.touchConfig.heartbeat_enter_anim)
					end
				end,
				function(arg_72_0)
					self:Emit(Dorm3dRoomTemplateScene.EXTRA_SHOW_BLACK_SCREEN, false, arg_72_0)
				end
			})
		end

		self:Emit(RoomTouchSystem.UPDATE_TOUCH_DISPLAY, self.touchLevel, self.touchCount)
	else
		self:Emit(RoomTouchSystem.UPDATE_TOUCH_COUNT, self.touchCount)
	end

	self.topCount = math.max(self.topCount, self.touchCount)
end

function RoomTouchSystem:ExitHeartbeatMode()
	if not self.touchLevel or self.touchLevel == 1 then
		return
	end

	self.touchCount = 0

	self:UpdateTouchCount(0)
end

function RoomTouchSystem:DoTouch(arg_74_1, arg_74_2)
	if self.inTouchGame then
		switch(arg_74_2, {
			function()
				self:UpdateTouchCount(pg.dorm3d_set.rapport_heartbeat.key_value_int)
			end,
			function()
				self:UpdateTouchCount(pg.dorm3d_set.rapport_heartbeat.key_value_int)
			end,
			function()
				self:UpdateTouchCount(pg.dorm3d_set.rapport_heartbeat.key_value_int)
			end,
			function()
				self:UpdateTouchCount(pg.dorm3d_set.rapport_heartbeat_trriger.key_value_int)
			end
		})
	end
end

return RoomTouchSystem
