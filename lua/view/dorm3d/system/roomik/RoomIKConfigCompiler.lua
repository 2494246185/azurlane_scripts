local RoomIKConfigCompiler = class("RoomIKConfigCompiler")

local function var_0_1(arg_1_0)
	return switch(arg_1_0[1], {
		function(arg_2_0, arg_2_1)
			return 0
		end,
		function()
			return 0
		end,
		function(arg_4_0, arg_4_1)
			return arg_4_0
		end,
		function(arg_5_0, arg_5_1)
			return arg_5_0
		end,
		function(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
			return arg_6_0
		end,
		function(arg_7_0)
			return 0
		end
	}, function(arg_8_0)
		return type(arg_8_0) == "number" and arg_8_0 or 0
	end, unpack(arg_1_0, 2))
end

function RoomIKConfigCompiler:BuildSubTargets()
	local var_9_0 = self:GetSubTargets()
	local var_9_1 = self:GetPlaneRotations()
	local var_9_2 = self:GetPlaneScales()

	return _.map(_.range(#var_9_0), function(arg_10_0)
		return {
			name = var_9_0[arg_10_0][1],
			planeRot = var_9_1[arg_10_0],
			planeScale = var_9_2[arg_10_0]
		}
	end)
end

function RoomIKConfigCompiler:BuildController(arg_11_1)
	arg_11_1 = arg_11_1 or {}

	local var_11_0 = {
		triggerName = self:getConfig("trigger_param")[2],
		controllerName = self:GetControllerPath(),
		subTargets = RoomIKConfigCompiler.BuildSubTargets(self),
		actionType = self:GetActionTriggerParams()[1],
		controlRect = self:GetRect(),
		actionRect = self:GetTriggerRect()
	}

	var_11_0.backTime = arg_11_1.backTime or self:GetRevertTime()
	var_11_0.actionRevertTime = arg_11_1.actionRevertTime or self:GetActionRevertTime()
	var_11_0.timelineActionEvent = arg_11_1.timelineActionEvent
	var_11_0.ignoreDrag = arg_11_1.ignoreDrag or false

	return Dorm3dIKController.New(var_11_0)
end

local function var_0_2(arg_12_0, arg_12_1, arg_12_2)
	local var_12_0 = arg_12_2.target_ik

	if _.detect(arg_12_0, function(arg_13_0)
		return arg_13_0[1] == var_12_0
	end) then
		return
	end

	arg_12_1[arg_12_2.target_ik] = {
		back_time = arg_12_2.back_time
	}

	local var_12_1 = {
		arg_12_2.target_ik,
		0,
		{}
	}

	if arg_12_2.trigger_dialogue > 0 then
		var_12_1[3] = {
			4,
			0,
			arg_12_2.trigger_dialogue
		}
	end

	table.insert(arg_12_0, var_12_1)
end

local function var_0_3(arg_14_0, arg_14_1)
	local var_14_0 = Dorm3dIK.New({
		configId = arg_14_0[1]
	})
	local var_14_1 = var_0_1(arg_14_0[3])
	local var_14_2 = var_14_0:GetRevertTime()
	local var_14_3 = arg_14_1[var_14_0:GetConfigID()]
	local var_14_4 = tobool(var_14_3)

	if var_14_4 then
		var_14_1 = var_14_3.back_time
		var_14_2 = var_14_3.back_time
		var_14_0.ignoreDrag = true
	end

	return {
		ikData = var_14_0,
		link = arg_14_0[3],
		controller = RoomIKConfigCompiler.BuildController(var_14_0, {
			backTime = var_14_2,
			actionRevertTime = var_14_1,
			ignoreDrag = var_14_4
		})
	}
end

function RoomIKConfigCompiler:Compile()
	assert(type(self) == "table", "Invalid IK status config")
	assert(type(self.ik_id) == "table", "Invalid IK status ik_id: " .. tostring(self.id))
	assert(type(self.touch_data) == "table", "Invalid IK status touch_data: " .. tostring(self.id))

	local var_15_0 = table.shallowCopy(self.ik_id)
	local var_15_1 = {}

	_.each(self.touch_data, function(arg_16_0)
		assert(type(arg_16_0) == "table" and type(arg_16_0[3]) == "table", "Invalid IK touch link in status: " .. tostring(self.id))

		if arg_16_0[3][1] == 7 then
			assert(arg_16_0[3][2], "Missing IK touch move id in status: " .. tostring(self.id))
			assert(pg.dorm3d_ik_touch_move[arg_16_0[3][2]], "Missing dorm3d_ik_touch_move config: " .. tostring(arg_16_0[3][2]))
			var_0_2(var_15_0, var_15_1, pg.dorm3d_ik_touch_move[arg_16_0[3][2]])
		end
	end)

	local var_15_2 = {}
	local var_15_3 = {}
	local var_15_4 = {}

	_.each(var_15_0, function(arg_17_0)
		local var_17_0 = var_0_3(arg_17_0, var_15_1)

		table.insert(var_15_2, var_17_0.ikData)
		table.insert(var_15_3, var_17_0.controller)

		var_15_4[var_17_0.ikData:GetControllerPath()] = var_17_0.link
	end)

	local var_15_5 = {}
	local var_15_6 = {}

	_.each(self.touch_data, function(arg_18_0)
		assert(pg.dorm3d_ik_touch[arg_18_0[1]], "Missing dorm3d_ik_touch config: " .. tostring(arg_18_0[1]))

		if #pg.dorm3d_ik_touch[arg_18_0[1]].scene_item > 0 and not var_15_6[pg.dorm3d_ik_touch[arg_18_0[1]].scene_item] then
			var_15_6[pg.dorm3d_ik_touch[arg_18_0[1]].scene_item] = true

			table.insert(var_15_5, {
				id = arg_18_0[1],
				path = pg.dorm3d_ik_touch[arg_18_0[1]].scene_item
			})
		end
	end)

	return {
		touchDatas = self.touch_data,
		layers = var_15_2,
		controllers = var_15_3,
		actionDict = var_15_4,
		sceneItems = var_15_5
	}
end

return RoomIKConfigCompiler
