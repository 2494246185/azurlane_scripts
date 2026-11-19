local IslandInteractSyncAgency = class("IslandInteractSyncAgency", import(".IslandBaseAgency"))

IslandInteractSyncAgency.OCCUPANCY_CHANGED = "IslandInteractSyncAgency:OCCUPANCY_CHANGED"
IslandInteractSyncAgency.PHASE_INIT = "init"
IslandInteractSyncAgency.PHASE_SYNC = "sync"
IslandInteractSyncAgency.PHASE_LOCAL = "local"

function IslandInteractSyncAgency:OnInit(arg_1_1)
	self.playerId = nil
	self.slotMeta = {}
	self.owners = {}
	self.status = {}
	self.lastInteract = {}
	self.localInteracting = false
end

function IslandInteractSyncAgency:Register()
	self:GetHost():AddListener(IslandAgoraAgency.PLACEMENT_UPDATE, function()
		self:RebuildAgoraSlotMeta()
	end)
end

function IslandInteractSyncAgency:ApplyMapSnapshot(arg_4_1, arg_4_2)
	self:ResetMapData()
	self:RebuildWorldSlotMeta(arg_4_2)
	self:RebuildAgoraSlotMeta()

	local var_4_0 = self:GetHost():GetVisitorAgency():GetMapVisitorList()

	for iter_4_0, iter_4_1 in ipairs(arg_4_1 or {}) do
		if self:GetSyncType(iter_4_1.id) == iter_4_1.type then
			self:ApplyServerSlots(iter_4_1.id, iter_4_1.slots, iter_4_1.status, IslandInteractSyncAgency.PHASE_INIT)

			for iter_4_2, iter_4_3 in pairs(self:GetOccupiedSlots(iter_4_1.id) or {}) do
				if iter_4_3 ~= self:GetLocalPlayerId() and var_4_0[iter_4_3] then
					self:RecordLastInteract(iter_4_3, iter_4_1.id, iter_4_1.type)
				end
			end
		end
	end
end

function IslandInteractSyncAgency:ResetMapData()
	self.slotMeta = {}
	self.owners = {}
	self.status = {}
	self.lastInteract = {}

	self:RefreshLocalInteracting()
end

function IslandInteractSyncAgency:RebuildAgoraSlotMeta()
	local var_6_0 = {}
	local var_6_1 = self:GetHost():GetAgoraAgency():GetPlacedData().placedList

	var_6_1 = var_6_1 or {}

	for iter_6_0, iter_6_1 in ipairs(var_6_1) do
		local var_6_2 = pg.island_furniture_template[AgoraCalc.RevertFormUniqueId(iter_6_1.id)]
		local var_6_3 = var_6_2 and var_6_2.interact_point

		if var_6_2 and var_6_2.interact_point and var_6_3 ~= "" and #var_6_3 > 0 then
			for iter_6_2, iter_6_3 in ipairs(var_6_3) do
				if pg.island_interact_point[iter_6_3] then
					table.insert(var_6_0, {
						id = AgoraCalc.GetVirtualInteractUnitId(iter_6_1.id, iter_6_2),
						slotCnt = pg.island_interact_point[iter_6_3].slot_cnt,
						pointId = iter_6_3
					})
				end
			end
		end
	end

	self:ResetByType(IslandConst.SYNC_TYPE_AGORA, var_6_0)
end

function IslandInteractSyncAgency:RebuildWorldSlotMeta(arg_7_1)
	local var_7_0 = {}

	for iter_7_0, iter_7_1 in ipairs(pg.island_world_objects.get_id_list_by_mapId[arg_7_1] or {}) do
		if pg.island_world_objects[iter_7_1] and pg.island_world_objects[iter_7_1].type == IslandConst.UNIT_TYPE_ITEM_INTERACT then
			if pg.island_unit_interactive_item[pg.island_world_objects[iter_7_1].unitId] then
				table.insert(var_7_0, {
					id = iter_7_1,
					slotCnt = pg.island_unit_interactive_item[pg.island_world_objects[iter_7_1].unitId].slot_cnt
				})
			end
		end
	end

	self:ResetByType(IslandConst.SYNC_TYPE_UNIT_STATIC, var_7_0)
end

function IslandInteractSyncAgency:ResetByType(arg_8_1, arg_8_2)
	for iter_8_0, iter_8_1 in pairs(self.slotMeta) do
		if iter_8_1.type == arg_8_1 then
			self.slotMeta[iter_8_0] = nil
			self.owners[iter_8_0] = nil
			self.status[iter_8_0] = nil
		end
	end

	for iter_8_2, iter_8_3 in ipairs(arg_8_2) do
		self.slotMeta[iter_8_3.id] = {
			type = arg_8_1,
			slotCnt = iter_8_3.slotCnt,
			pointId = iter_8_3.pointId
		}
		self.owners[iter_8_3.id] = {}
	end

	self:RefreshLocalInteracting()
end

function IslandInteractSyncAgency:ClearByType(arg_9_1, arg_9_2)
	for iter_9_0, iter_9_1 in pairs(self.slotMeta) do
		if iter_9_1.type == arg_9_1 then
			if not arg_9_2 then
				for iter_9_2, iter_9_3 in pairs(self.owners[iter_9_0] or {}) do
					self:DispatchEvent(IslandInteractSyncAgency.OCCUPANCY_CHANGED, iter_9_0, iter_9_2, iter_9_3, false, IslandInteractSyncAgency.PHASE_SYNC)
				end
			end

			self.slotMeta[iter_9_0] = nil
			self.owners[iter_9_0] = nil
			self.status[iter_9_0] = nil
		end
	end

	self:RefreshLocalInteracting()
end

function IslandInteractSyncAgency:ApplyServerSlots(arg_10_1, arg_10_2, arg_10_3, arg_10_4)
	if not self.slotMeta[arg_10_1] then
		return nil
	end

	if arg_10_3 ~= nil then
		self.status[arg_10_1] = arg_10_3
	end

	local var_10_0 = self.owners[arg_10_1] or {}
	local var_10_1 = {}

	for iter_10_0, iter_10_1 in ipairs(arg_10_2 or {}) do
		var_10_1[iter_10_1.slot_id] = iter_10_1.owner_id
	end

	local var_10_2 = self:DiffOwners(var_10_0, var_10_1)

	self.owners[arg_10_1] = var_10_1

	self:DispatchChanges(arg_10_1, var_10_2, arg_10_4)
	self:RefreshLocalInteracting()

	return var_10_2
end

function IslandInteractSyncAgency:ApplyLocalOccupy(arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	if not self.owners[arg_11_1] then
		return nil
	end

	if arg_11_4 ~= nil then
		self.status[arg_11_1] = arg_11_4
	end

	local var_11_0 = self.owners[arg_11_1][arg_11_2]

	self.owners[arg_11_1][arg_11_2] = arg_11_3

	local var_11_1 = {
		added = {
			{
				slotId = arg_11_2,
				ownerId = arg_11_3
			}
		},
		removed = {}
	}

	if var_11_0 ~= nil and var_11_0 ~= arg_11_3 then
		table.insert(var_11_1.removed, {
			slotId = arg_11_2,
			ownerId = var_11_0
		})
	end

	self:DispatchChanges(arg_11_1, var_11_1, IslandInteractSyncAgency.PHASE_LOCAL)
	self:RefreshLocalInteracting()

	return var_11_1
end

function IslandInteractSyncAgency:ApplyLocalRelease(arg_12_1, arg_12_2, arg_12_3)
	local var_12_0 = self.owners[arg_12_1]
	local var_12_1 = self.owners[arg_12_1] ~= nil and var_12_0[arg_12_2] ~= nil

	if self.owners[arg_12_1] ~= nil and var_12_0[arg_12_2] ~= nil and arg_12_3 ~= nil and var_12_0[arg_12_2] ~= arg_12_3 then
		return nil
	end

	if var_12_1 then
		var_12_0[arg_12_2] = nil
	end

	local var_12_2 = {
		added = {},
		removed = {
			{
				slotId = arg_12_2,
				ownerId = arg_12_3 or self:GetLocalPlayerId()
			}
		}
	}

	self:DispatchChanges(arg_12_1, var_12_2, IslandInteractSyncAgency.PHASE_LOCAL)
	self:RefreshLocalInteracting()

	return var_12_2
end

function IslandInteractSyncAgency:RemoveOwner(arg_13_1)
	local var_13_0 = {}

	for iter_13_0, iter_13_1 in pairs(self.owners) do
		for iter_13_2, iter_13_3 in pairs(iter_13_1) do
			if iter_13_3 == arg_13_1 then
				iter_13_1[iter_13_2] = nil

				table.insert(var_13_0, {
					unitId = iter_13_0,
					slotId = iter_13_2
				})
				self:DispatchEvent(IslandInteractSyncAgency.OCCUPANCY_CHANGED, iter_13_0, iter_13_2, arg_13_1, false, IslandInteractSyncAgency.PHASE_SYNC)
			end
		end
	end

	self:RefreshLocalInteracting()

	return var_13_0
end

function IslandInteractSyncAgency:SetStatus(arg_14_1, arg_14_2)
	if self.slotMeta[arg_14_1] then
		self.status[arg_14_1] = arg_14_2
	end
end

function IslandInteractSyncAgency:GetStatus(arg_15_1)
	return self.status[arg_15_1]
end

function IslandInteractSyncAgency:OnVisitorExit(arg_16_1)
	self.lastInteract[arg_16_1] = nil

	return self.lastInteract[arg_16_1]
end

function IslandInteractSyncAgency:RecordLastInteract(arg_17_1, arg_17_2, arg_17_3)
	self.lastInteract[arg_17_1] = {
		id = arg_17_2,
		type = arg_17_3
	}
end

function IslandInteractSyncAgency:ClearLastInteract(arg_18_1)
	self.lastInteract[arg_18_1] = nil
end

function IslandInteractSyncAgency:IsLocalInteracting()
	return self.localInteracting
end

function IslandInteractSyncAgency:GetLocalPlayerId()
	self.playerId = self.playerId or getProxy(PlayerProxy):getPlayerId()

	return self.playerId
end

function IslandInteractSyncAgency:RefreshLocalInteracting()
	local var_21_0 = self:GetLocalPlayerId()

	for iter_21_0, iter_21_1 in pairs(self.owners) do
		for iter_21_2, iter_21_3 in pairs(iter_21_1) do
			if iter_21_3 == var_21_0 then
				self.localInteracting = true

				return
			end
		end
	end

	self.localInteracting = false
end

function IslandInteractSyncAgency:GetSyncType(arg_22_1)
	return (self.slotMeta[arg_22_1] or nil) and (self.slotMeta[arg_22_1].type or nil)
end

function IslandInteractSyncAgency:GetPointId(arg_23_1)
	return (self.slotMeta[arg_23_1] or nil) and (self.slotMeta[arg_23_1].pointId or nil)
end

function IslandInteractSyncAgency:GetUnitIdsByType(arg_24_1)
	local var_24_0 = {}

	for iter_24_0, iter_24_1 in pairs(self.slotMeta) do
		if iter_24_1.type == arg_24_1 then
			table.insert(var_24_0, iter_24_0)
		end
	end

	return var_24_0
end

function IslandInteractSyncAgency:GetAllUnitIds()
	local var_25_0 = {}

	for iter_25_0 in pairs(self.slotMeta) do
		table.insert(var_25_0, iter_25_0)
	end

	return var_25_0
end

function IslandInteractSyncAgency:GetSlotCnt(arg_26_1)
	return (self.slotMeta[arg_26_1] or nil) and (self.slotMeta[arg_26_1].slotCnt or 0)
end

function IslandInteractSyncAgency:GetOccupiedSlots(arg_27_1)
	return self.owners[arg_27_1]
end

function IslandInteractSyncAgency:AnySlotUsing(arg_28_1)
	return self.owners[arg_28_1] ~= nil and next(self.owners[arg_28_1]) ~= nil
end

function IslandInteractSyncAgency:GetFreeSlot(arg_29_1)
	if not self.slotMeta[arg_29_1] or not self.owners[arg_29_1] then
		return nil
	end

	for iter_29_0 = 1, self.slotMeta[arg_29_1].slotCnt do
		if self.owners[arg_29_1][iter_29_0] == nil then
			return iter_29_0
		end
	end

	return nil
end

function IslandInteractSyncAgency:GetSlotByOwner(arg_30_1, arg_30_2)
	if not self.owners[arg_30_1] then
		return nil
	end

	for iter_30_0, iter_30_1 in pairs(self.owners[arg_30_1]) do
		if iter_30_1 == arg_30_2 then
			return iter_30_0
		end
	end

	return nil
end

function IslandInteractSyncAgency:GetUnitsByOwner(arg_31_1)
	local var_31_0 = {}

	for iter_31_0, iter_31_1 in pairs(self.owners) do
		for iter_31_2, iter_31_3 in pairs(iter_31_1) do
			if iter_31_3 == arg_31_1 then
				table.insert(var_31_0, iter_31_0)

				break
			end
		end
	end

	return var_31_0
end

function IslandInteractSyncAgency:HasOwner(arg_32_1, arg_32_2)
	if not self.owners[arg_32_1] then
		return false
	end

	for iter_32_0, iter_32_1 in pairs(self.owners[arg_32_1]) do
		if iter_32_1 ~= arg_32_2 then
			return true
		end
	end

	return false
end

function IslandInteractSyncAgency:IsSpecialOccupied(arg_33_1)
	return self.owners[arg_33_1] ~= nil and self.owners[arg_33_1][0] ~= nil
end

function IslandInteractSyncAgency:CanAcquireNormalSlot(arg_34_1)
	return not self:IsSpecialOccupied(arg_34_1) and self:GetFreeSlot(arg_34_1) ~= nil
end

function IslandInteractSyncAgency:DiffOwners(arg_35_1, arg_35_2)
	local var_35_0 = {
		added = {},
		removed = {}
	}

	for iter_35_0, iter_35_1 in pairs(arg_35_2) do
		if arg_35_1[iter_35_0] ~= iter_35_1 then
			table.insert(var_35_0.added, {
				slotId = iter_35_0,
				ownerId = iter_35_1
			})
		end
	end

	for iter_35_2, iter_35_3 in pairs(arg_35_1) do
		if arg_35_2[iter_35_2] == nil then
			table.insert(var_35_0.removed, {
				slotId = iter_35_2,
				ownerId = iter_35_3
			})
		end
	end

	return var_35_0
end

function IslandInteractSyncAgency:DispatchChanges(arg_36_1, arg_36_2, arg_36_3)
	for iter_36_0, iter_36_1 in ipairs(arg_36_2.removed) do
		self:DispatchEvent(IslandInteractSyncAgency.OCCUPANCY_CHANGED, arg_36_1, iter_36_1.slotId, iter_36_1.ownerId, false, arg_36_3)
	end

	for iter_36_2, iter_36_3 in ipairs(arg_36_2.added) do
		self:DispatchEvent(IslandInteractSyncAgency.OCCUPANCY_CHANGED, arg_36_1, iter_36_3.slotId, iter_36_3.ownerId, true, arg_36_3)
	end
end

function IslandInteractSyncAgency:Clear()
	self.slotMeta = {}
	self.owners = {}
	self.status = {}
	self.lastInteract = {}

	self:RefreshLocalInteracting()
end

return IslandInteractSyncAgency
