local RoomTouchTriggerRunner = class("RoomTouchTriggerRunner")

RoomTouchTriggerRunner.TRIGGER_CLICK = 1
RoomTouchTriggerRunner.TRIGGER_LONG_PRESS = 2
RoomTouchTriggerRunner.HOLD_PROGRESS_SHOW_DELAY = 0.5

function RoomTouchTriggerRunner:Ctor(arg_1_1)
	self.owner = arg_1_1
end

function RoomTouchTriggerRunner:Dispose()
	self:CancelAllTouchPress()
end

function RoomTouchTriggerRunner:Update()
	self:UpdateHoldProgress()
end

function RoomTouchTriggerRunner:GetTouchPressKey(arg_4_1, arg_4_2)
	return tostring(arg_4_1) .. ":" .. tostring(arg_4_2)
end

function RoomTouchTriggerRunner:AssertTouchSource(arg_5_1, arg_5_2)
	assert(arg_5_1 == "body" or arg_5_1 == "scene_item", "Unknown touch source: " .. tostring(arg_5_1))
	assert(arg_5_2 and arg_5_2 ~= "", "Invalid touch target: " .. tostring(arg_5_2))
end

function RoomTouchTriggerRunner:GetTouchConfigSourceTarget(arg_6_1, arg_6_2)
	local var_6_0 = type(arg_6_1.scene_item) == "string" and arg_6_1.scene_item ~= ""

	assert((type(arg_6_1.body) == "string" and arg_6_1.body ~= "") ~= var_6_0, "Invalid dorm3d_ik_touch source: " .. tostring(arg_6_2 or arg_6_1.id))

	if var_6_0 then
		return "scene_item", arg_6_1.scene_item
	else
		return "body", arg_6_1.body
	end
end

function RoomTouchTriggerRunner:AssertTouchConfig(arg_7_1)
	local var_7_0 = pg.dorm3d_ik_touch[arg_7_1]

	assert(pg.dorm3d_ik_touch[arg_7_1], "Missing dorm3d_ik_touch config: " .. tostring(arg_7_1))
	assert(var_7_0.trigger_type == RoomTouchTriggerRunner.TRIGGER_CLICK or var_7_0.trigger_type == RoomTouchTriggerRunner.TRIGGER_LONG_PRESS, "Invalid dorm3d_ik_touch trigger_type: " .. tostring(arg_7_1))

	if var_7_0.trigger_type == RoomTouchTriggerRunner.TRIGGER_LONG_PRESS then
		assert(type(var_7_0.hold_time) == "number" and var_7_0.hold_time > 0, "Invalid dorm3d_ik_touch hold_time: " .. tostring(arg_7_1))
	end

	self:GetTouchConfigSourceTarget(var_7_0, arg_7_1)

	return var_7_0
end

function RoomTouchTriggerRunner:ValidateTouchConfigs(arg_8_1, arg_8_2)
	assert(type(arg_8_1) == "table", "Invalid dorm3d_ik_status touch_data: " .. tostring(arg_8_2))

	local var_8_0 = {}

	_.each(arg_8_1, function(arg_9_0)
		local var_9_0 = self:AssertTouchConfig(arg_9_0[1])
		local var_9_1, var_9_2 = self:GetTouchConfigSourceTarget(var_9_0, arg_9_0[1])
		local var_9_3 = var_9_1 .. ":" .. var_9_2 .. ":" .. tostring(var_9_0.trigger_type)

		assert(not var_8_0[var_9_3], string.format("Duplicate dorm3d_ik_touch trigger: ids=%s,%s source=%s target=%s trigger_type=%s", tostring(var_8_0[var_9_3]), tostring(arg_9_0[1]), var_9_1, var_9_2, tostring(var_9_0.trigger_type)))

		var_8_0[var_9_3] = arg_9_0[1]
	end)
end

function RoomTouchTriggerRunner:GetTouchInfos(arg_10_1, arg_10_2, arg_10_3)
	self:AssertTouchSource(arg_10_1, arg_10_2)

	local var_10_0 = self.owner:GetActiveIKTouchData()

	if not var_10_0 then
		return {}
	end

	assert(type(var_10_0) == "table", "Invalid current IK touch data")

	local var_10_1 = {}

	for iter_10_0, iter_10_1 in ipairs(var_10_0) do
		local var_10_2 = self:AssertTouchConfig(iter_10_1[1])
		local var_10_3, var_10_4 = self:GetTouchConfigSourceTarget(var_10_2, iter_10_1[1])

		if var_10_3 == arg_10_1 and var_10_4 == arg_10_2 and var_10_2.trigger_type == arg_10_3 then
			table.insert(var_10_1, iter_10_1)
		end
	end

	assert(#var_10_1 <= 1, string.format("Duplicate dorm3d_ik_touch trigger: source=%s target=%s trigger_type=%s", tostring(arg_10_1), tostring(arg_10_2), tostring(arg_10_3)))

	return var_10_1
end

function RoomTouchTriggerRunner:GetFirstLongPressInfo(arg_11_1, arg_11_2)
	return self:GetTouchInfos(arg_11_1, arg_11_2, RoomTouchTriggerRunner.TRIGGER_LONG_PRESS)[1]
end

function RoomTouchTriggerRunner:OnTouchPressDown(arg_12_1, arg_12_2, arg_12_3)
	self:AssertTouchSource(arg_12_1, arg_12_2)
	self:ClearTouchPressConsumed(arg_12_1, arg_12_2)
	self:CancelTouchPress(arg_12_1, arg_12_2)

	local var_12_0 = self:GetFirstLongPressInfo(arg_12_1, arg_12_2)

	if not var_12_0 then
		return
	end

	assert(arg_12_3, "Missing touch press screenPosition")

	local var_12_1 = self:AssertTouchConfig(var_12_0[1])
	local var_12_2 = {
		triggered = false,
		holdTime = var_12_1.hold_time,
		screenPosition = arg_12_3,
		startTime = Time.time
	}

	var_12_2.timer = Timer.New(function()
		var_12_2.triggered = true
		var_12_2.timer = nil

		self:HideHoldProgress()
		self:SetTouchPressConsumed(arg_12_1, arg_12_2)
		self.owner:TriggerTouchInfo(var_12_0)
	end, var_12_1.hold_time, 1)

	var_12_2.timer:Start()

	self.touchPressStates = self.touchPressStates or {}
	self.touchPressStates[self:GetTouchPressKey(arg_12_1, arg_12_2)] = var_12_2
end

function RoomTouchTriggerRunner:OnTouchPressUp(arg_14_1, arg_14_2)
	self:AssertTouchSource(arg_14_1, arg_14_2)

	local var_14_0 = self:GetTouchPressKey(arg_14_1, arg_14_2)

	if self.touchPressStates then
		local var_14_1 = self.touchPressStates[var_14_0] or nil
		local var_14_2

		if var_14_1 then
			var_14_2 = var_14_1.triggered or self.touchPressConsumed and self.touchPressConsumed[var_14_0]
		end
	end

	self:CancelTouchPress(arg_14_1, arg_14_2)
	self:ClearTouchPressConsumed(arg_14_1, arg_14_2)

	if var_14_2 then
		return
	end

	local var_14_3 = self:GetTouchInfos(arg_14_1, arg_14_2, RoomTouchTriggerRunner.TRIGGER_CLICK)

	if not var_14_3[1] then
		return
	end

	self.owner:TriggerTouchInfo(var_14_3[1])
end

function RoomTouchTriggerRunner:SetTouchPressConsumed(arg_15_1, arg_15_2)
	self.touchPressConsumed = self.touchPressConsumed or {}
	self.touchPressConsumed[self:GetTouchPressKey(arg_15_1, arg_15_2)] = true
end

function RoomTouchTriggerRunner:ClearTouchPressConsumed(arg_16_1, arg_16_2)
	if not self.touchPressConsumed then
		return
	end

	self.touchPressConsumed[self:GetTouchPressKey(arg_16_1, arg_16_2)] = nil
end

function RoomTouchTriggerRunner:CancelTouchPress(arg_17_1, arg_17_2)
	if not self.touchPressStates then
		return
	end

	local var_17_0 = self:GetTouchPressKey(arg_17_1, arg_17_2)

	if self.touchPressStates[var_17_0] and self.touchPressStates[var_17_0].timer then
		self.touchPressStates[var_17_0].timer:Stop()
	end

	self:HideHoldProgress()

	self.touchPressStates[var_17_0] = nil
end

function RoomTouchTriggerRunner:CancelAllTouchPress()
	self:HideHoldProgress()

	if not self.touchPressStates then
		return
	end

	for iter_18_0, iter_18_1 in pairs(self.touchPressStates) do
		if iter_18_1.timer then
			iter_18_1.timer:Stop()
		end
	end

	self.touchPressStates = nil
end

function RoomTouchTriggerRunner:HideHoldProgress()
	if not self.holdProgressActive then
		return
	end

	self.holdProgressActive = nil

	self.owner:Emit(Dorm3dIKView.UPDATE_HOLD_PROGRESS, false)
end

function RoomTouchTriggerRunner:UpdateHoldProgress()
	if not self.touchPressStates then
		self:HideHoldProgress()

		return
	end

	for iter_20_0, iter_20_1 in pairs(self.touchPressStates) do
		if not iter_20_1.triggered and iter_20_1.holdTime > RoomTouchTriggerRunner.HOLD_PROGRESS_SHOW_DELAY then
			if Time.time - iter_20_1.startTime >= RoomTouchTriggerRunner.HOLD_PROGRESS_SHOW_DELAY then
				self.holdProgressActive = true

				self.owner:Emit(Dorm3dIKView.UPDATE_HOLD_PROGRESS, true, iter_20_1.screenPosition, (Time.time - iter_20_1.startTime) / iter_20_1.holdTime)

				return
			end
		end
	end

	self:HideHoldProgress()
end

return RoomTouchTriggerRunner
