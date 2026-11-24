local TeleportSystem = class("TeleportSystem", import("view.dorm3d.Core.BaseSystem"))

TeleportSystem.MAX_DISTANCE = 1.5

function TeleportSystem:OnInit()
	local var_1_0 = self:GetRoom().id

	warning("TeleportSystem Init for room:", var_1_0)

	self.configs = pg.dorm3d_teleport.get_id_list_by_room_id[var_1_0] or {}
	self.boundTriggers = {}

	self:BindClickFunc()
end

function TeleportSystem:BindClickFunc()
	self:ClearClickBindings()
	_.each(self.configs, function(arg_3_0)
		warning(pg.dorm3d_teleport[arg_3_0])

		local var_3_0 = self:GetSceneItem(pg.dorm3d_teleport[arg_3_0].item_path)

		if not var_3_0 then
			return
		end

		local var_3_1 = pg.dorm3d_zone_template[pg.dorm3d_teleport[arg_3_0].teleport_zone]

		if pg.dorm3d_zone_template[pg.dorm3d_teleport[arg_3_0].teleport_zone] then
			var_3_1 = pg.dorm3d_zone_template[pg.dorm3d_teleport[arg_3_0].teleport_zone].watch_camera
		end

		assert(var_3_1, "invalid zone:" .. tostring(pg.dorm3d_teleport[arg_3_0].teleport_zone))

		local var_3_2 = GetOrAddComponent(var_3_0, typeof(EventTriggerListener))

		var_3_2:AddPointClickFunc(function(arg_4_0, arg_4_1)
			if self:GetIsInFurnitureSelect() then
				return
			end

			local var_4_0 = CameraMgr.instance:Raycast(self:GetSceneRaycaster(), arg_4_1.position):ToTable()

			if #var_4_0 > 0 then
				if var_4_0[1].gameObject.transform ~= var_3_0.transform then
					return
				end

				if Vector3.Distance(self:GetPlayer().transform.position, var_3_0.transform.position) > TeleportSystem.MAX_DISTANCE then
					return
				end

				self:Emit(Dorm3dRoomTemplateScene.SHIFT_ZONE_SAFE, var_3_1)
			end
		end)

		self.boundTriggers[var_3_0] = var_3_2
	end)
end

function TeleportSystem:RegisterEvents()
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE, function()
		self:ClearClickBindings()
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_CHANGED, function(arg_7_0, arg_7_1, arg_7_2)
		if arg_7_2 then
			self:BindClickFunc()
		end
	end)
end

function TeleportSystem:OnHandleNotification(arg_8_1, arg_8_2)
	return
end

function TeleportSystem.GetInterests()
	return {}
end

function TeleportSystem:OnDispose()
	self:ClearClickBindings()
end

function TeleportSystem:ClearClickBindings()
	for iter_11_0, iter_11_1 in pairs(self.boundTriggers or {}) do
		iter_11_1:RemovePointClickFunc()
	end

	self.boundTriggers = {}
end

return TeleportSystem
