local RoomIKSessionBuilder = class("RoomIKSessionBuilder")

local function var_0_1(arg_1_0, arg_1_1)
	if arg_1_1 then
		return arg_1_1
	end

	local var_1_0 = {}

	if not arg_1_0 or IsNil(arg_1_0) then
		return var_1_0
	end

	local var_1_1 = {}

	table.Foreach(DormConst.boneMap, function(arg_2_0, arg_2_1)
		var_1_1[arg_2_1] = arg_2_0
	end)
	table.IpairsCArray(arg_1_0:GetComponentsInChildren(typeof(Transform), true), function(arg_3_0, arg_3_1)
		if var_1_1[arg_3_1.name] then
			var_1_0[var_1_1[arg_3_1.name]] = arg_3_1
		end
	end)

	return var_1_0
end

local function var_0_2(arg_4_0, arg_4_1)
	assert(arg_4_0 and not IsNil(arg_4_0), arg_4_1)

	return arg_4_0
end

local function var_0_3(arg_5_0)
	_.each(arg_5_0.controllers, function(arg_6_0)
		local var_6_0 = arg_6_0:GetControllerPath()

		assert(type(var_6_0) == "string" and var_6_0 ~= "", "Invalid IK controller path")

		local var_6_1 = var_0_2(tf((var_0_2(var_0_2(arg_5_0.ikRoot:Find(var_6_0), "Missing IK layer: " .. var_6_0):GetComponent(typeof(RootMotion.FinalIK.IKExecutionOrder)), "Missing IKExecutionOrder: " .. var_6_0))):Find("Container/SubTargets"), "Missing IK SubTargets: " .. var_6_0)

		_.each(arg_6_0:GetSubTargets(), function(arg_7_0)
			var_0_2(arg_5_0.boneMaps[arg_7_0.name], string.format("Missing IK BoneMap: %s (%s)", tostring(arg_7_0.name), var_6_0))

			local var_7_0 = var_0_2(var_6_1:Find(arg_7_0.name), string.format("Missing IK SubTarget: %s (%s)", tostring(arg_7_0.name), var_6_0))

			var_0_2(var_0_2(var_7_0:Find("Plane"), string.format("Missing IK SubTarget Plane: %s (%s)", tostring(arg_7_0.name), var_6_0)):GetComponent(typeof(UnityEngine.MeshCollider)), string.format("Missing IK SubTarget MeshCollider: %s (%s)", tostring(arg_7_0.name), var_6_0))
			var_0_2(var_7_0:Find("Target"), string.format("Missing IK SubTarget Target: %s (%s)", tostring(arg_7_0.name), var_6_0))
		end)
	end)
end

function RoomIKSessionBuilder:Ctor(arg_8_1)
	self.system = arg_8_1
end

function RoomIKSessionBuilder:BuildNormal(arg_9_1, arg_9_2, arg_9_3)
	assert(arg_9_1, "Missing LadyEnv when building IK session")
	assert(arg_9_2, "Missing IK config when building session")

	local var_9_0 = RoomIKConfigCompiler.Compile(arg_9_2)
	local var_9_1 = self.system:GetCameraRoot()
	local var_9_2 = self.system:GetIKPointByName(arg_9_2.character_position)

	return {
		mode = "normal",
		statusId = arg_9_2.id,
		config = arg_9_2,
		ladyEnv = arg_9_1,
		compiled = var_9_0,
		layers = var_9_0.layers,
		controllers = var_9_0.controllers,
		actionDict = var_9_0.actionDict,
		touchDatas = var_9_0.touchDatas,
		sceneItems = var_9_0.sceneItems,
		ikRoot = arg_9_1.ladyIKRoot,
		boneMaps = var_0_1(arg_9_1.lady, arg_9_1.ladyBoneMaps),
		colliders = arg_9_1.ladyColliders,
		raycaster = self.system:GetSceneRaycaster(),
		ikCameraTF = var_9_1 and var_9_1:Find(arg_9_2.ik_camera),
		stayPoint = var_9_2 and var_9_2:Find("StayPoint"),
		onLayerAction = arg_9_3
	}
end

function RoomIKSessionBuilder:BuildTimeline(arg_10_1, arg_10_2, arg_10_3, arg_10_4)
	assert(arg_10_1, "Missing timeline lady GameObject")
	assert(pg.dorm3d_ik_timeline_status[arg_10_2], "Missing dorm3d_ik_timeline_status config: " .. tostring(arg_10_2))

	local var_10_0 = {}
	local var_10_1 = {}

	table.IpairsCArray(arg_10_1:GetComponentsInChildren(typeof(UnityEngine.Collider), true), function(arg_11_0, arg_11_1)
		local var_11_0 = tf(arg_11_1)

		if arg_11_1.name == "SafeCollider" then
			table.insert(var_10_1, {
				active = false,
				target = var_11_0
			})

			return
		end

		if arg_11_1:GetType():Equals(typeof(UnityEngine.MeshCollider)) then
			return
		end

		local var_11_1 = var_11_0.name
		local var_11_2 = var_11_0.name and string.find(var_11_1, "Collider") or -1

		if var_11_2 <= 0 then
			errorMsg("Wrong Name to lady Collider : " .. var_11_1)

			return
		end

		local var_11_3 = string.sub(var_11_1, 1, var_11_2 - 1)

		if var_11_3 == "Body" or var_11_3 == "Safe" then
			table.insert(var_10_1, {
				active = false,
				target = var_11_0
			})

			return
		end

		if DormConst.BONE_TO_TOUCH[var_11_3] == nil then
			return
		end

		var_10_0[var_11_3] = var_11_0

		table.insert(var_10_1, {
			active = true,
			target = var_11_0
		})
	end)

	local var_10_2 = {}

	return {
		mode = "timeline",
		statusId = arg_10_2,
		config = pg.dorm3d_ik_timeline_status[arg_10_2],
		ladyEnv = self.system:GetCurrentLadyEnv(),
		layers = var_10_2,
		controllers = _.map(pg.dorm3d_ik_timeline_status[arg_10_2].ik_id, function(arg_12_0)
			local var_12_0 = Dorm3dIK.New({
				configId = arg_12_0
			})

			table.insert(var_10_2, var_12_0)

			return RoomIKConfigCompiler.BuildController(var_12_0, {
				timelineActionEvent = var_12_0:GetTimelineAction()
			})
		end),
		actionDict = {},
		touchDatas = {},
		sceneItems = {},
		ikRoot = arg_10_1.transform and arg_10_1.transform:Find("IKLayers"),
		boneMaps = var_0_1(arg_10_1.transform),
		colliders = var_10_0,
		colliderChanges = var_10_1,
		raycaster = arg_10_3 and arg_10_3:GetComponent(typeof(UnityEngine.EventSystems.PhysicsRaycaster)),
		raycastCameraTF = arg_10_3,
		onLayerAction = arg_10_4
	}
end

function RoomIKSessionBuilder:ValidateSpec(arg_13_1)
	assert(type(arg_13_1) == "table", "Invalid RoomIK SessionSpec")
	assert(arg_13_1.mode == "normal" or arg_13_1.mode == "timeline", "Invalid RoomIK session mode: " .. tostring(arg_13_1.mode))
	assert(arg_13_1.statusId, "Missing RoomIK status id")
	assert(type(arg_13_1.layers) == "table", "Missing RoomIK layers")
	assert(arg_13_1.mode == "normal" or #arg_13_1.layers > 0, "Missing RoomIK timeline layers")
	assert(type(arg_13_1.controllers) == "table" and #arg_13_1.controllers == #arg_13_1.layers, "RoomIK layer/controller count mismatch")
	assert(type(arg_13_1.actionDict) == "table", "Missing RoomIK action dictionary")
	assert(type(arg_13_1.touchDatas) == "table", "Missing RoomIK touch data")
	assert(type(arg_13_1.sceneItems) == "table", "Missing RoomIK scene items")

	if #arg_13_1.controllers > 0 then
		var_0_2(arg_13_1.ikRoot, "Missing RoomIK IK root")
	end

	assert(type(arg_13_1.boneMaps) == "table", "Missing RoomIK BoneMap")
	assert(type(arg_13_1.colliders) == "table", "Missing RoomIK colliders")
	assert(arg_13_1.raycaster or arg_13_1.raycastCameraTF, "Missing RoomIK raycaster source")

	if arg_13_1.raycaster then
		var_0_2(arg_13_1.raycaster, "Missing RoomIK raycaster")
	else
		var_0_2(arg_13_1.raycastCameraTF, "Missing RoomIK raycast camera")
	end

	var_0_3(arg_13_1)
	_.each(arg_13_1.layers, function(arg_14_0)
		if not arg_14_0.ignoreDrag then
			local var_14_0 = arg_14_0:GetTriggerBoneName()

			var_0_2(arg_13_1.colliders[var_14_0], "Missing IK collider: " .. tostring(var_14_0))
		end
	end)
	_.each(arg_13_1.touchDatas, function(arg_15_0)
		assert(pg.dorm3d_ik_touch[arg_15_0[1]], "Missing dorm3d_ik_touch config: " .. tostring(arg_15_0[1]))

		if #pg.dorm3d_ik_touch[arg_15_0[1]].scene_item > 0 then
			var_0_2(self.system:GetSceneItem(pg.dorm3d_ik_touch[arg_15_0[1]].scene_item), "Missing IK scene item: " .. pg.dorm3d_ik_touch[arg_15_0[1]].scene_item)
		else
			var_0_2(arg_13_1.colliders[pg.dorm3d_ik_touch[arg_15_0[1]].body], "Missing IK touch collider: " .. tostring(pg.dorm3d_ik_touch[arg_15_0[1]].body))
		end
	end)

	if arg_13_1.mode == "normal" then
		var_0_2(arg_13_1.ladyEnv and arg_13_1.ladyEnv.ladyCollider, "Missing IK lady collider")
		var_0_2(arg_13_1.ikCameraTF, "Missing IK camera: " .. tostring(arg_13_1.config.ik_camera))
		var_0_2(arg_13_1.stayPoint, "Missing IK StayPoint: " .. tostring(arg_13_1.config.character_position))
		_.each(arg_13_1.sceneItems, function(arg_16_0)
			arg_16_0.target = var_0_2(self.system:GetSceneItem(arg_16_0.path), string.format("dorm3d_ik_touch:%d without scene_item:%s", arg_16_0.id, arg_16_0.path))
		end)
		_.each(arg_13_1.config.hide_scene_item or {}, function(arg_17_0)
			var_0_2(self.system:GetSceneItem(arg_17_0), "Missing IK hidden scene item: " .. tostring(arg_17_0))
		end)
		_.each(arg_13_1.config.enter_scene_anim or {}, function(arg_18_0)
			assert(pg.dorm3d_scene_animator[arg_18_0[1]], "Missing dorm3d_scene_animator config: " .. tostring(arg_18_0[1]))
			var_0_2(self.system:GetSceneItem(pg.dorm3d_scene_animator[arg_18_0[1]].item_name), "Missing IK animated scene item: " .. tostring(pg.dorm3d_scene_animator[arg_18_0[1]].item_name))
		end)
	else
		_.each(arg_13_1.colliderChanges or {}, function(arg_19_0)
			var_0_2(arg_19_0.target, "Missing timeline IK collider")
		end)
	end

	assert(type(arg_13_1.onLayerAction) == "function", "Missing RoomIK layer action callback")

	arg_13_1.validated = true

	return arg_13_1
end

return RoomIKSessionBuilder
