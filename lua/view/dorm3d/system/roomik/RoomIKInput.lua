local RoomIKInput = class("RoomIKInput")

function RoomIKInput:Ctor(arg_1_1)
	self.system = arg_1_1
	self.controlTouchPressTarget = nil
	self.controlDragIsIK = nil
end

function RoomIKInput:GetSession()
	return self.system and self.system:GetSession()
end

function RoomIKInput:CanHandleInput()
	return self.system and self.system:CanHandleIKInput()
end

function RoomIKInput:OnControlPointerDown(arg_4_1)
	if not self:CanHandleInput() then
		return
	end

	self.controlTouchPressTarget = nil

	local var_4_0 = self:ResolveTouchTarget(arg_4_1)

	if not var_4_0 then
		return
	end

	self.controlTouchPressTarget = var_4_0

	self:EmitTouchPress(true, var_4_0, arg_4_1)
end

function RoomIKInput:OnControlPointerUp(arg_5_1)
	self.controlTouchPressTarget = nil

	if not self.controlTouchPressTarget then
		return
	end

	self:EmitTouchPress(false, self.controlTouchPressTarget, arg_5_1)
end

function RoomIKInput:OnControlBeginDrag(arg_6_1)
	if not self:CanHandleInput() then
		return
	end

	self.controlDragIsIK = nil

	local var_6_0 = self:ResolveBodyTarget(arg_6_1)

	if not var_6_0 then
		return
	end

	local var_6_1 = self:GetSession()

	if var_6_1:IsBlocked() or var_6_1.ikHandler then
		return
	end

	self.system:BeginIKBodyDrag(var_6_0, arg_6_1)

	self.controlDragIsIK = tobool(var_6_1.ikHandler)
end

function RoomIKInput:OnControlDrag(arg_7_1, arg_7_2)
	if not self:CanHandleInput() then
		return
	end

	if self:GetSession().ikHandler then
		self.system:DragIKBody(arg_7_1)

		return
	end

	if self.controlDragIsIK then
		return
	end

	self.system:Emit(Dorm3dRoomTemplateScene.ON_STICK_MOVE, arg_7_2)
end

function RoomIKInput:OnControlEndDrag(arg_8_1)
	local var_8_0 = self:GetSession()
	local var_8_1

	if var_8_0 then
		var_8_1 = var_8_0.ikHandler or self.controlDragIsIK
	end

	self.controlDragIsIK = nil

	if var_8_1 then
		self.system:ReleaseIKBody()
	end
end

function RoomIKInput:Cancel()
	self.controlTouchPressTarget = nil
	self.controlDragIsIK = nil

	if self.system then
		self.system:ReleaseIKBody()
	end
end

function RoomIKInput:Dispose()
	self:Cancel()

	self.system = nil
end

function RoomIKInput:GetIKRaycastTargets(arg_11_1)
	local var_11_0 = self:GetSession()
	local var_11_1 = var_11_0 and var_11_0.ikSettings

	if not (var_11_0 and var_11_0.ikSettings) or not var_11_1.CameraRaycaster then
		return {}
	end

	local var_11_2 = CameraMgr.instance:Raycast(var_11_1.CameraRaycaster, arg_11_1)

	return var_11_2 and var_11_2:ToTable() or {}
end

function RoomIKInput:ResolveBodyTarget(arg_12_1)
	local var_12_0 = self:GetSession()
	local var_12_1 = var_12_0 and var_12_0.ikSettings

	if not (var_12_0 and var_12_0.ikSettings) then
		return
	end

	for iter_12_0, iter_12_1 in ipairs(self:GetIKRaycastTargets(arg_12_1)) do
		local var_12_3 = table.keyof(var_12_1.Colliders or {}, iter_12_1.gameObject.transform)

		if var_12_3 then
			return var_12_3
		end
	end
end

function RoomIKInput:ResolveTouchTarget(arg_13_1)
	local var_13_0 = self:GetSession()

	if not var_13_0 or not var_13_0.ikSettings then
		return
	end

	for iter_13_0, iter_13_1 in ipairs(self:GetIKRaycastTargets(arg_13_1)) do
		local var_13_2 = table.keyof(var_13_0.ikSettings.Colliders or {}, iter_13_1.gameObject.transform)

		if var_13_2 then
			return {
				source = "body",
				target = var_13_2
			}
		end

		local var_13_3 = self:ResolveTouchSceneItem(iter_13_1.gameObject.transform)

		if var_13_3 then
			return {
				source = "scene_item",
				target = var_13_3
			}
		end
	end
end

function RoomIKInput:ResolveTouchSceneItem(arg_14_1)
	local var_14_0 = self:GetSession()

	if not var_14_0 or not var_14_0.ikTouchDatas then
		return
	end

	for iter_14_0, iter_14_1 in ipairs(var_14_0.ikTouchDatas) do
		if #pg.dorm3d_ik_touch[iter_14_1[1]].scene_item > 0 then
			local var_14_1 = self.system:GetSceneItem(pg.dorm3d_ik_touch[iter_14_1[1]].scene_item)

			if var_14_1 and RoomIKInput.IsTransformInHierarchy(arg_14_1, var_14_1) then
				return pg.dorm3d_ik_touch[iter_14_1[1]].scene_item
			end
		end
	end
end

function RoomIKInput:IsTransformInHierarchy(arg_15_1)
	while self do
		if self == arg_15_1 then
			return true
		end

		self = self.parent
	end

	return false
end

function RoomIKInput:EmitTouchPress(arg_16_1, arg_16_2, arg_16_3)
	if arg_16_2.source == "body" then
		self.system:Emit((arg_16_1 or nil) and (RoomTouchSystem.ON_TOUCH_CHARACTER_DOWN or RoomTouchSystem.ON_TOUCH_CHARACTER_UP), arg_16_2.target, arg_16_3)
	elseif arg_16_2.source == "scene_item" then
		self.system:Emit((arg_16_1 or nil) and (RoomTouchSystem.ON_TOUCH_SCENE_ITEM_DOWN or RoomTouchSystem.ON_TOUCH_SCENE_ITEM_UP), arg_16_2.target, arg_16_3)
	end
end

return RoomIKInput
