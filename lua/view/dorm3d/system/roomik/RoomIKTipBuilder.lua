local RoomIKTipBuilder = class("RoomIKTipBuilder")

function RoomIKTipBuilder:GetWorldTipPosition()
	if not self then
		return
	end

	local var_1_1 = self:GetComponent(typeof(UnityEngine.Collider))

	return (var_1_1 or nil) and var_1_1.bounds.center
end

local function var_0_1(arg_2_0, arg_2_1)
	local var_2_0 = RoomIKTipBuilder.GetWorldTipPosition(arg_2_0)

	if not var_2_0 then
		return
	end

	return arg_2_1(var_2_0)
end

function RoomIKTipBuilder:BuildTextTips()
	local var_3_0 = {}

	_.each(self or {}, function(arg_4_0)
		local var_4_0 = arg_4_0:getConfig("tip_text")

		if var_4_0 and #var_4_0 > 0 then
			table.insert(var_3_0, var_4_0)
		end
	end)

	return var_3_0
end

function RoomIKTipBuilder:BuildTouchTips(arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	local var_5_0 = {}

	if not arg_5_2 then
		return var_5_0
	end

	_.each(self or {}, function(arg_6_0)
		local var_6_0 = arg_5_1[arg_6_0[1]]

		assert(arg_5_1[arg_6_0[1]], "Missing dorm3d_ik_touch config: " .. tostring(arg_6_0[1]))

		local var_6_1
		local var_6_2 = Vector2.zero

		if var_6_0.tip_offset and var_6_0.tip_offset ~= "" then
			var_6_2 = Vector2.New(unpack(var_6_0.tip_offset))
		end

		var_6_1 = #var_6_0.scene_item > 0 and arg_5_3(var_6_0.scene_item) or arg_5_2.Colliders[var_6_0.body]

		table.insert(var_5_0, {
			active = tobool(var_6_1),
			screenPosition = var_0_1(var_6_1, arg_5_4),
			offset = var_6_2,
			triggerType = var_6_0.trigger_type
		})
	end)

	return var_5_0
end

function RoomIKTipBuilder:BuildIKTips(arg_7_1, arg_7_2)
	local var_7_0 = {}

	if not arg_7_1 then
		return var_7_0
	end

	_.each(_.filter(self or {}, function(arg_8_0)
		return not arg_8_0.ignoreDrag
	end), function(arg_9_0)
		local var_9_0 = arg_9_0:GetTriggerBoneName()
		local var_9_1

		if var_9_0 then
			var_9_1 = arg_7_1.Colliders[var_9_0] or nil
		end

		table.insert(var_7_0, {
			active = tobool(var_9_1),
			screenPosition = var_0_1(var_9_1, arg_7_2),
			offset = arg_9_0:GetIKTipOffset(),
			triggerRect = arg_9_0:GetTriggerRect()
		})
	end)

	return var_7_0
end

return RoomIKTipBuilder
