local AgoraController = class("AgoraController", import("Mod.Island.Core.controller.IslandController"))

function AgoraController:Init()
	AgoraController.super.Init(self)

	local var_1_0, var_1_1 = self:CreateAgora(self.island)

	self.agora = var_1_0
	self.placedData = var_1_1
	self.isEditing = false
	self.selectedData = nil
	self.editCdTime = 0
	self.toUpdateTileList = {}
	self.dataComparator = AgoraDataComparator.New(self.agora)
	self.reloading = false
	self.baseReloadingCd = pg.island_set.agora_reloading_base_cd.key_value_int
	self.nextReloadingEndTime = 0
	self.isCleanLayerMode = false
end

function AgoraController:GetDefaultFoundation()
	if pg.island_set.island_pre_placement.key_value_varchar[1] then
		local var_2_0 = AgoraFurniture.New({
			id = AgoraCalc.GetUniqueId(pg.island_set.island_pre_placement.key_value_varchar[1][1], 1),
			configId = pg.island_set.island_pre_placement.key_value_varchar[1][1]
		})

		var_2_0:UpdatePosition((Vector2(pg.island_set.island_pre_placement.key_value_varchar[1][2][1], pg.island_set.island_pre_placement.key_value_varchar[1][2][2])))

		return var_2_0
	end

	return nil
end

function AgoraController:GetDefaultBuilding()
	if pg.island_set.island_default_building.key_value_varchar[1] then
		local var_3_0 = AgoraFurniture.New({
			id = AgoraCalc.GetUniqueId(pg.island_set.island_default_building.key_value_varchar[1], 1),
			configId = pg.island_set.island_default_building.key_value_varchar[1]
		})

		var_3_0:UpdatePosition((AgoraCalc.WorldPosition2MapPosition(BuildVector3(pg.island_set.island_default_building.key_value_varchar[2]))))

		return var_3_0
	end

	return nil
end

function AgoraController:Update()
	AgoraController.super.Update(self)
	self:CheckReloadFinish()
end

function AgoraController:CheckReloadFinish()
	if not self.reloading then
		return
	end

	if pg.TimeMgr.GetInstance():GetServerTime() < self.nextReloadingEndTime then
		return
	end

	if self:GetView():IsLoaded() then
		self:NotifiyAgora(ISLAND_AGORA_EVT.RELOADING_FINISH)

		self.reloading = false
	end
end

function AgoraController:SetUp()
	AgoraController.super.SetUp(self)
	self:NotifiyAgora(ISLAND_AGORA_EVT.START_LOAD_ITEMS)
	self:NotifiyAgora(ISLAND_AGORA_EVT.MAP_SIZE_UPDATE, self.agora:GetSize())

	local var_6_0 = self.placedData.foundation or self:GetDefaultFoundation()

	if var_6_0 then
		self:PlaceItem(var_6_0.id, var_6_0:GetPosition(), Vector3.zero)
	end

	local var_6_1 = self.placedData.building or self:GetDefaultBuilding()

	if var_6_1 then
		self:PlaceItem(var_6_1.id, var_6_1:GetPosition(), Vector3.zero)
	end

	local var_6_2 = {}

	for iter_6_0, iter_6_1 in pairs(self.placedData.placedlist) do
		table.insert(var_6_2, function(arg_7_0)
			self:PlaceItem(iter_6_1.id, iter_6_1:GetPosition(), iter_6_1:GetRotation())

			if iter_6_0 % 3 == 0 then
				onNextTick(arg_7_0)
			else
				arg_7_0()
			end
		end)
	end

	seriesAsync(var_6_2, function()
		self:NotifiyAgora(ISLAND_AGORA_EVT.END_LOAD_ITEMS, var_6_1:GetPosition())
	end)
end

function AgoraController:OnCoreInitFinish()
	self:PaveLayers(self.placedData.placedFloor, self.placedData.placedTile)
	AgoraController.super.OnCoreInitFinish(self)
end

function AgoraController:InitSyncMgr()
	self.islandSyncMgr:Init(self:GetCore().view.player)
end

function AgoraController:PaveLayers(arg_11_1, arg_11_2)
	for iter_11_0, iter_11_1 in pairs(arg_11_1) do
		self:PaveFloorLayer(iter_11_1.id, iter_11_1:GetShapeId(), iter_11_1:GetPosition())
	end

	for iter_11_2, iter_11_3 in pairs(arg_11_2) do
		self:PaveTileLayer(iter_11_3.id, iter_11_3:GetShapeId(), iter_11_3:GetPosition())
	end
end

function AgoraController:GetAgora()
	return self.agora
end

function AgoraController:CanEnterEditMode()
	return pg.TimeMgr.GetInstance():GetServerTime() >= self.editCdTime
end

function AgoraController:AnySelected()
	return self.selectedData ~= nil
end

function AgoraController:NotifiyAgora(arg_15_1, ...)
	self.agora:DispatchEvent(arg_15_1, ...)
end

function AgoraController:CheckChange()
	if self:AnySelected() then
		self:UnSelectedItem()
	end

	local var_16_0, var_16_1 = self.dataComparator:AnyChanged()

	return var_16_0
end

function AgoraController:EnterEditMode()
	if not self:CanEnterEditMode() then
		self:NotifiyAgora(ISLAND_AGORA_EVT.ENTER_EDIT_FAILED)

		return
	end

	self.islandSyncMgr:SuspendAgoraInteract()

	self.isEditing = true

	self.dataComparator:TakeSample()
	self:NotifiyAgora(ISLAND_AGORA_EVT.ENTER_EDIT)
	self:NotifiyIsland(ISLAND_EX_EVT.ENTER_EDIT_AGORA)
end

function AgoraController:ExitEditMode()
	self.isEditing = false

	self.dataComparator:Abort()
	self:NotifiyAgora(ISLAND_AGORA_EVT.EXIT_EDIT)
	self:NotifiyIsland(ISLAND_EX_EVT.EXIT_EDIT_AGORA)
	self:ClearAllNew()
	self.islandSyncMgr:ResumeAgoraPresentation()
end

function AgoraController:SaveAndExit()
	self:Save(true)
	self:ExitEditMode()
end

function AgoraController:Save(arg_20_1)
	if not arg_20_1 and not self:CanEnterEditMode() then
		return
	end

	if self:AnySelected() then
		self:UnSelectedItem()
	end

	self.islandSyncMgr:ClearAgoraInteractData()

	local var_20_0, var_20_1, var_20_2 = self.agora:SerializePlacementData()

	self:NotifiyMeditor(IslandMediator.SAVE_AGORA, var_20_0, var_20_1, var_20_2)
	self.dataComparator:TakeSample()

	self.editCdTime = pg.TimeMgr.GetInstance():GetServerTime() + pg.island_set.island_build_save_time.key_value_int

	self:NotifiyAgora(ISLAND_AGORA_EVT.SAVE)
end

function AgoraController:SaveTheme(arg_21_1, arg_21_2)
	if self:AnySelected() then
		self:UnSelectedItem()
	end

	local var_21_0, var_21_1, var_21_2 = self.agora:SerializePlacementData()

	if #var_21_0 <= 0 and #var_21_1 <= 0 and #var_21_2 <= 0 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_agora_deco_empty"))

		return
	end

	self:NotifiyMeditor(IslandMediator.SAVE_AGORA_THEME, {
		id = arg_21_1,
		name = arg_21_2,
		updateList = var_21_0,
		floorList = var_21_1,
		tileList = var_21_2
	})
end

function AgoraController:ApplyTheme(arg_22_1, arg_22_2)
	local var_22_0

	if arg_22_2 then
		var_22_0 = self.agora:GetSystemTheme(arg_22_1) or self.agora:GetTheme(arg_22_1)

		if not var_22_0 then
			return
		end
	end

	self:ClearAll()
	self:NotifiyAgora(ISLAND_AGORA_EVT.START_LOAD_ITEMS)

	local var_22_1 = {}

	for iter_22_0, iter_22_1 in ipairs((var_22_0:GetPlacedData())) do
		table.insert(var_22_1, function(arg_23_0)
			if iter_22_1:IsFoundationType() then
				self:ReplaceFoundation(iter_22_1.id)
			elseif iter_22_1:IsBuildingType() then
				self:ReplaceBuilding(iter_22_1.id)
			else
				self:PlaceItem(iter_22_1.id, iter_22_1:GetPosition(), iter_22_1:GetRotation())
			end

			if iter_22_0 % 3 == 0 then
				onNextTick(arg_23_0)
			else
				arg_23_0()
			end
		end)
	end

	table.insert(var_22_1, function(arg_24_0)
		onNextTick(arg_24_0)
	end)

	for iter_22_2, iter_22_3 in ipairs((var_22_0:GetFloorData())) do
		self:PaveFloorLayer(iter_22_3.id, iter_22_3.shapeId, iter_22_3:GetPosition())
	end

	table.insert(var_22_1, function(arg_25_0)
		onNextTick(arg_25_0)
	end)

	for iter_22_4, iter_22_5 in ipairs((var_22_0:GetTileData())) do
		self:PaveTileLayer(iter_22_5.id, iter_22_5.shapeId, iter_22_5:GetPosition())
	end

	seriesAsync(var_22_1, function()
		self:NotifiyAgora(ISLAND_AGORA_EVT.END_LOAD_ITEMS)
	end)
end

function AgoraController:DeleteTheme(arg_27_1)
	self:NotifiyMeditor(IslandMediator.DEL_AGORA_THEME, arg_27_1)
end

function AgoraController:ClearAll()
	if self:AnySelected() then
		self:UnPlaceItem(self.selectedData.id)

		self.selectedData = nil
	end

	self:ClearPlaced(false)
	self:ClearLayers()
end

function AgoraController:ClearPlaced(arg_29_1)
	if arg_29_1 then
		for iter_29_0, iter_29_1 in pairs(self.agora:GetPlacedlist()) do
			self:UnPlaceItem(iter_29_1.id, true)
		end
	else
		for iter_29_2, iter_29_3 in pairs(self.agora:GetPlacedlist()) do
			if iter_29_3:CanOp() then
				self:UnPlaceItem(iter_29_3.id)
			end
		end
	end
end

function AgoraController:ClearFloorLayer()
	for iter_30_0, iter_30_1 in pairs(self.agora:GetFloorLayer()) do
		for iter_30_2, iter_30_3 in pairs(iter_30_1) do
			if not iter_30_3:IsEmpty() then
				self:UnPaveFloorLayer(iter_30_3:GetPosition())
			end
		end
	end
end

function AgoraController:ClearTileLayer()
	for iter_31_0, iter_31_1 in pairs(self.agora:GetTileLayer()) do
		for iter_31_2, iter_31_3 in pairs(iter_31_1) do
			if not iter_31_3:IsEmpty() then
				self:UnPaveTileLayer(iter_31_3:GetPosition())
			end
		end
	end
end

function AgoraController:ClearLayers()
	self:ClearFloorLayer()
	self:ClearTileLayer()
end

function AgoraController:Revert()
	local var_33_0, var_33_1 = self.dataComparator:AnyChanged()

	if not var_33_0 then
		return
	end

	local var_33_2, var_33_3, var_33_4 = self.dataComparator:GetSample()
	local var_33_5 = {}

	if bit.band(var_33_1, AgoraDataComparator.CHANGE_TYPE_PLACED) > 0 then
		self:ClearPlaced(true)

		for iter_33_0, iter_33_1 in pairs(var_33_2) do
			table.insert(var_33_5, function(arg_34_0)
				self:PlaceItem(iter_33_1.id, iter_33_1:GetPosition(), iter_33_1:GetRotation(), arg_34_0)
			end)
		end
	end

	parallelAsync(var_33_5, function()
		return
	end)

	if bit.band(var_33_1, AgoraDataComparator.CHANGE_TYPE_FLOOR) > 0 then
		self:ClearFloorLayer()

		for iter_33_2, iter_33_3 in pairs(var_33_3) do
			for iter_33_4, iter_33_5 in pairs(iter_33_3) do
				if not iter_33_5:IsEmpty() then
					self:PaveFloorLayer(iter_33_5.id, iter_33_5:GetShapeId(), iter_33_5:GetPosition())
				end
			end
		end
	end

	if bit.band(var_33_1, AgoraDataComparator.CHANGE_TYPE_TILE) > 0 then
		self:ClearTileLayer()

		for iter_33_6, iter_33_7 in pairs(var_33_4) do
			for iter_33_8, iter_33_9 in pairs(iter_33_7) do
				if not iter_33_9:IsEmpty() then
					self:PaveTileLayer(iter_33_9.id, iter_33_9:GetShapeId(), iter_33_9:GetPosition())
				end
			end
		end
	end
end

function AgoraController:RevertAndExit()
	self:Revert()
	self:ExitEditMode()
end

function AgoraController:Upgrade()
	self:NotifiyMeditor(IslandMediator.UPGRADE_AGORA)
end

function AgoraController:TrySelectItemById(arg_38_1)
	self:_TrySelectItem((self.agora:GetPlacedItem(arg_38_1)))
end

function AgoraController:TrySelectItem(arg_39_1)
	self:_TrySelectItem((self.agora:GetAnyMapItemInPosition(arg_39_1)))
end

function AgoraController:_TrySelectItem(arg_40_1)
	if not arg_40_1 then
		return
	end

	if not arg_40_1:CanSelect() then
		return
	end

	if self:AnySelected() then
		self:UnSelectedItem()
	end

	self:SelectItem(arg_40_1)
end

function AgoraController:SelectItem(arg_41_1)
	self.selectedData = {
		id = arg_41_1.id,
		position = arg_41_1:GetPosition(),
		dir = arg_41_1:GetRotation()
	}

	self.agora:RemoveItem(arg_41_1)
	self:NotifiyAgora(ISLAND_AGORA_EVT.SELECTED_ITEM, self.selectedData.id, (arg_41_1:CanOp()))
end

function AgoraController:ConfirmSelectedItem()
	if not self:AnySelected() then
		return
	end

	if not self.agora:IsEmptyArea((self.agora:GetPlaceableItem(self.selectedData.id))) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_agora_pos_unavailability"))

		return
	end

	local var_42_0 = self.selectedData.id

	self:UnSelectedItem()
	self:NotifiyAgora(ISLAND_AGORA_EVT.CONFIRM_SELECTED_ITEM, var_42_0)
end

function AgoraController:UnSelectedItem()
	if not self:AnySelected() then
		return
	end

	local var_43_0 = self.selectedData.id

	self:NotifiyAgora(ISLAND_AGORA_EVT.ITEM_CLEAR_OCCUPIED, self.selectedData.id)

	local var_43_1 = self.agora:GetPlaceableItem(var_43_0)

	if not self.agora:IsEmptyArea(var_43_1) then
		var_43_1:UpdatePosition(self.selectedData.position)
		var_43_1:UpdateRotation(self.selectedData.dir)
	end

	local var_43_2 = var_43_1:CanOp()

	self.agora:AddItem(var_43_1)

	self.selectedData = nil

	self:NotifiyAgora(ISLAND_AGORA_EVT.UNSELECTED_ITEM, var_43_0, var_43_2)
end

function AgoraController:BeginDragItem()
	if not self:AnySelected() then
		return
	end

	self:NotifiyAgora(ISLAND_AGORA_EVT.DRAG_ITEM_BEGIN, (self.agora:GetPlaceableItem(self.selectedData.id)))
end

function AgoraController:DragItem(arg_45_1)
	if not self:AnySelected() then
		return
	end

	local var_45_0 = self.agora:GetPlaceableItem(self.selectedData.id)

	var_45_0:UpdatePosition(self.agora:ClampRange(arg_45_1.x, arg_45_1.y, var_45_0))
	self:NotifiyAgora(ISLAND_AGORA_EVT.DRAG_ITEM, self.selectedData.id, (self.agora:IsEmptyArea(var_45_0)))

	local var_45_1 = self.agora:GetItemInArea(var_45_0:GetMapType(), (var_45_0:GetArea()))

	if var_45_1 then
		self:NotifiyAgora(ISLAND_AGORA_EVT.ITEM_OCCUPIED, var_45_1.id)
	else
		self:NotifiyAgora(ISLAND_AGORA_EVT.ITEM_CLEAR_OCCUPIED, var_45_0.id)
	end
end

function AgoraController:EndDragItem(arg_46_1)
	self:DragItem(arg_46_1)
	self:NotifiyAgora(ISLAND_AGORA_EVT.DRAG_ITEM_END, (self.agora:GetPlaceableItem(self.selectedData.id)))
end

function AgoraController:RotationItem()
	if not self:AnySelected() then
		return
	end

	self.agora:GetPlaceableItem(self.selectedData.id):Rotation()
end

function AgoraController:AgoraVirtualInterAction(arg_48_1, arg_48_2, arg_48_3)
	arg_48_3 = arg_48_3 or 1

	if not self.agora:GetVirtualInteractUnitData(arg_48_1) then
		return
	end

	local var_48_0 = self:GetIsland():GetInteractSyncAgency()

	if var_48_0:IsSpecialOccupied(arg_48_1) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_furniture_interaction_tip1"))

		return
	end

	local var_48_1 = var_48_0:GetFreeSlot(arg_48_1)

	if not var_48_1 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_agora_no_interact_point"))

		return
	end

	self.islandSyncMgr:TryControlUnit(IslandConst.SYNC_TYPE_AGORA, arg_48_1, var_48_1, arg_48_3, function(arg_49_0)
		return
	end)
end

function AgoraController:AgoraVirtualInterActionSync(arg_50_1, arg_50_2, arg_50_3, arg_50_4)
	if self.isEditing then
		return
	end

	arg_50_3 = arg_50_3 or 1

	local var_50_0 = self.agora:GetVirtualInteractUnitData(arg_50_1)

	if not var_50_0 then
		return
	end

	self:NotifiyAgora(ISLAND_AGORA_EVT.START_INTERACTION, var_50_0, arg_50_4, arg_50_2, arg_50_3, self:GetIsland():GetInteractSyncAgency():AnySlotUsing(arg_50_1))
end

function AgoraController:AgoraVirtualInterActionEnd(arg_51_1, arg_51_2)
	if not self.agora:GetVirtualInteractUnitData(arg_51_1) then
		return
	end

	self.islandSyncMgr:EndControlUnit(IslandConst.SYNC_TYPE_AGORA, arg_51_1, function(arg_52_0)
		return
	end)
end

function AgoraController:AgoraVirtualShipInterAction(arg_53_1, arg_53_2)
	if not self.agora:GetVirtualInteractUnitData(arg_53_1) then
		return
	end

	local var_53_0 = self:GetIsland():GetInteractSyncAgency()

	if var_53_0:IsLocalInteracting() then
		return
	end

	if var_53_0:HasOwner(arg_53_1, var_53_0:GetLocalPlayerId()) then
		return
	end

	if var_53_0:IsSpecialOccupied(arg_53_1) then
		return
	end

	self.islandSyncMgr:TryControlUnit(IslandConst.SYNC_TYPE_AGORA, arg_53_1, 0, 1, function(arg_54_0)
		return
	end)
end

function AgoraController:AgoraVirtualShipInterActionSync(arg_55_1, arg_55_2, arg_55_3, arg_55_4)
	arg_55_3 = arg_55_3 or 1

	local var_55_0 = self.agora:GetVirtualInteractUnitData(arg_55_1)

	if not var_55_0 then
		return
	end

	local var_55_1 = self:CollectShipInteractUnits(var_55_0)

	self.shipInteractCtx = {
		unitId = arg_55_1,
		ships = var_55_1
	}

	self:NotifiyAgora(ISLAND_AGORA_EVT.SHIP_START_INTERACTION, var_55_0, var_55_1, arg_55_2, arg_55_3)
end

function AgoraController:AgoraVirtualShipInterActionEndSync(arg_56_1, arg_56_2, arg_56_3)
	local var_56_0 = self.agora:GetVirtualInteractUnitData(arg_56_1)

	self.shipInteractCtx = nil

	if not var_56_0 then
		return
	end

	self:NotifiyAgora(ISLAND_AGORA_EVT.SHIP_END_INTERACTION, var_56_0, (self.shipInteractCtx and self.shipInteractCtx.unitId == arg_56_1 or nil) and (self.shipInteractCtx.ships or {}))
end

function AgoraController:CollectShipInteractUnits(arg_57_1)
	local var_57_0 = arg_57_1:GetSlot() - 1

	if var_57_0 <= 0 then
		return {}
	end

	local var_57_1 = {}

	for iter_57_0, iter_57_1 in ipairs(self:GetCore().view:GetUnitListByKey(IslandConst.UNIT_LIST_FOLLOW)) do
		if var_57_0 <= #var_57_1 then
			break
		end

		if iter_57_1._go and not iter_57_1:IsExitState() then
			table.insert(var_57_1, iter_57_1)
		end
	end

	return var_57_1
end

function AgoraController:AgoraVirtualInterActionEndSync(arg_58_1, arg_58_2, arg_58_3)
	if self.isEditing then
		return
	end

	local var_58_0 = self.agora:GetVirtualInteractUnitData(arg_58_1)

	if not var_58_0 or not arg_58_3 then
		return
	end

	self:NotifiyAgora(ISLAND_AGORA_EVT.END_INTERACTION, var_58_0, arg_58_3, arg_58_2, not self:GetIsland():GetInteractSyncAgency():AnySlotUsing(arg_58_1))
end

function AgoraController:AgoraVirtualInitStatus(arg_59_1, arg_59_2)
	local var_59_0 = self.agora:GetVirtualInteractUnitData(arg_59_1)

	if not var_59_0 then
		return
	end

	self:NotifiyCore(ISLAND_EVT.WORLD_OBJECT_INIT_STATUS, var_59_0, arg_59_2)
end

function AgoraController:PlaceItemRandonPosition(arg_60_1)
	local var_60_0 = self.agora:GetPlaceableItem(arg_60_1)

	if self.agora:IsMaxCapacityWhenAdd((var_60_0:GetCost())) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_agora_max_capacity"))

		return
	end

	local var_60_1 = AgoraCalc.GetCenterMapPos()

	if not var_60_1 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_agora_no_size"))

		return
	end

	if self:AnySelected() then
		self:UnSelectedItem()
	end

	var_60_0:Clear()

	local var_60_2 = self.agora:FindEmptyArea4Item(var_60_1, var_60_0)

	if not var_60_2 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("island_agora_no_size"))

		return
	end

	self:PlaceItem(arg_60_1, var_60_2, Vector3.zero)
	self:SelectItem(var_60_0)
end

function AgoraController:PlaceItem(arg_61_1, arg_61_2, arg_61_3, arg_61_4)
	self.agora:PlaceItem(arg_61_1, arg_61_2, arg_61_3, arg_61_4)
end

function AgoraController:RemovePlaceItem(arg_62_1)
	self:UnPlaceItem(arg_62_1)
	self:NotifiyAgora(ISLAND_AGORA_EVT.UNPLACE_ITEM)
end

function AgoraController:UnPlaceItem(arg_63_1, arg_63_2)
	local var_63_0

	if not arg_63_1 then
		::label_63_0::

		var_63_0 = self.selectedData and self.selectedData.id
	end

	if not var_63_0 then
		return
	end

	local var_63_1 = self.agora:GetPlaceableItem(var_63_0)

	if self:AnySelected() and self.selectedData.id == var_63_0 then
		self:UnSelectedItem()
	end

	if not var_63_1:CanOp() and not arg_63_2 then
		return
	end

	self.agora:UnPlaceItem(var_63_0)
end

function AgoraController:ReplaceBuilding(arg_64_1)
	if self:AnySelected() and self.agora:IsBuilding(self.selectedData.id) then
		self:UnSelectedItem()
	end

	local var_64_0 = self.agora:GetBuilding()
	local var_64_1 = Vector2.zero

	if var_64_0 then
		var_64_1 = var_64_0:GetPosition()

		self:UnPlaceItem(var_64_0.id, true)
	end

	self:PlaceItem(arg_64_1, var_64_1, Vector3.zero)
end

function AgoraController:ReplaceFoundation(arg_65_1)
	if self:AnySelected() and self.agora:IsFoundation(self.selectedData.id) then
		self:UnSelectedItem()
	end

	local var_65_0 = self.agora:GetFoundation()
	local var_65_1 = Vector2.zero

	if var_65_0 then
		var_65_1 = var_65_0:GetPosition()

		self:UnPlaceItem(var_65_0.id, true)
	end

	self:PlaceItem(arg_65_1, var_65_1, Vector3.zero)
end

function AgoraController:SelectedPaveItem(arg_66_1, arg_66_2)
	if self:AnySelected() then
		self:UnSelectedItem()
	end

	self.toUpdateTileList = {}
	self.selectedPaveItemId = arg_66_1
	self.paveItemShapeId = arg_66_2
	self.isCleanLayerMode = false
end

function AgoraController:UnSelectedPaveItem()
	self.toUpdateTileList = {}
	self.selectedPaveItemId = nil
	self.paveItemShapeId = nil
	self.isCleanLayerMode = false
end

function AgoraController:ChangeSelectedShape(arg_68_1)
	if not self.selectedPaveItemId then
		return
	end

	self.paveItemShapeId = arg_68_1
end

function AgoraController:ChangePaveMode(arg_69_1)
	self.isCleanLayerMode = arg_69_1
end

function AgoraController:OpLayer(arg_70_1)
	if not self.selectedPaveItemId then
		return
	end

	local var_70_0 = self.agora:GetPlaceableItem(self.selectedPaveItemId)

	if not var_70_0 then
		return
	end

	if not self.agora:InRange(arg_70_1.x, arg_70_1.y) then
		return
	end

	if not var_70_0:IsOptionalShapeType() then
		return
	end

	if self.isCleanLayerMode then
		self:UnPaveLayer(var_70_0, arg_70_1)
	else
		self:PaveLayer(var_70_0, arg_70_1)
	end
end

function AgoraController:PaveLayer(arg_71_1, arg_71_2)
	self:RecordLayer(arg_71_1, arg_71_2)

	if arg_71_1:IsFloor() then
		self:PaveFloorLayer(arg_71_1.id, self.paveItemShapeId, arg_71_2)
	elseif arg_71_1:IsTile() then
		self:PaveTileLayer(arg_71_1.id, self.paveItemShapeId, arg_71_2)
	end
end

function AgoraController:RecordLayer(arg_72_1, arg_72_2)
	if not self.toUpdateTileList[arg_72_2.x] or not self.toUpdateTileList[arg_72_2.x][arg_72_2.y] then
		local var_72_0

		if arg_72_1:IsFloor() then
			var_72_0 = self.agora:GetFloorCell(arg_72_2)
		elseif arg_72_1:IsTile() then
			var_72_0 = self.agora:GetTileCell(arg_72_2)
		end

		if var_72_0 then
			self.toUpdateTileList[arg_72_2.x] = self.toUpdateTileList[arg_72_2.x] or {}
			self.toUpdateTileList[arg_72_2.x][arg_72_2.y] = var_72_0:GetShapeId()
		end
	end
end

function AgoraController:UnPaveLayer(arg_73_1, arg_73_2)
	if arg_73_1:IsFloor() and not self.agora:HasFloorCell(arg_73_2) or arg_73_1:IsTile() and not self.agora:HasTileCell(arg_73_2) then
		return
	end

	self:RecordLayer(arg_73_1, arg_73_2)

	if arg_73_1:IsFloor() then
		self:UnPaveFloorLayer(arg_73_2)
	elseif arg_73_1:IsTile() then
		self:UnPaveTileLayer(arg_73_2)
	end
end

function AgoraController:PaveFloorLayer(arg_74_1, arg_74_2, arg_74_3)
	self.agora:PlaceFloor(arg_74_1, arg_74_2, arg_74_3)
end

function AgoraController:PaveTileLayer(arg_75_1, arg_75_2, arg_75_3)
	self.agora:PlaceTile(arg_75_1, arg_75_2, arg_75_3)
end

function AgoraController:RevertPaveLayer()
	local function var_76_0(arg_77_0, arg_77_1, arg_77_2, arg_77_3)
		if arg_77_0 then
			self:UnPaveFloorLayer(arg_77_2)

			return
		end

		self:PaveFloorLayer(arg_77_1, arg_77_3, arg_77_2)
	end

	local function var_76_1(arg_78_0, arg_78_1, arg_78_2, arg_78_3)
		if arg_78_0 then
			self:UnPaveTileLayer(arg_78_2)

			return
		end

		self:PaveTileLayer(arg_78_1, arg_78_3, arg_78_2)
	end

	local var_76_2 = self.agora:GetPlaceableItem(self.selectedPaveItemId)

	if not var_76_2 then
		return
	end

	local var_76_3 = var_76_2.id

	for iter_76_0, iter_76_1 in pairs(self.toUpdateTileList) do
		for iter_76_2, iter_76_3 in pairs(iter_76_1) do
			local var_76_4 = Vector2(iter_76_0, iter_76_2)
			local var_76_5 = iter_76_3 < 0

			if var_76_2:IsFloor() then
				var_76_0(var_76_5, var_76_3, var_76_4, iter_76_3)
			elseif var_76_2:IsTile() then
				var_76_1(var_76_5, var_76_3, var_76_4, iter_76_3)
			end
		end
	end

	self.toUpdateTileList = {}
end

function AgoraController:UnPaveFloorLayer(arg_79_1)
	self.agora:UnPlaceFloor(arg_79_1)
end

function AgoraController:UnPaveTileLayer(arg_80_1)
	self.agora:UnPlaceTile(arg_80_1)
end

function AgoraController:AddListeners()
	AgoraController.super.AddListeners(self)
	self:AddIslandListener(IslandAgoraAgency.AGORA_UPGRADE, self.OnAgoraUpdate)
	self:AddIslandListener(IslandSignInAgency.GIFT_CNT_UPDATE, self.OnSignInGiftCntUpdate)
	self:AddIslandListener(IslandSignInAgency.SIGN_CNT_UPDATE, self.OnSignCntUpdate)
	self:AddIslandListener(IslandAgoraAgency.ADD_THEME, self.OnThemeAdded)
	self:AddIslandListener(IslandAgoraAgency.DEL_THEME, self.OnThemeDeleted)
	self:AddIslandListener(IslandAgoraAgency.PLACEMENT_UPDATE, self.OnPlacementUpdate)
	self:AddIslandListener(IslandAgoraAgency.ADD_FURNITURE, self.OnFurnitureAdded)
end

function AgoraController:RemoveListeners()
	AgoraController.super.RemoveListeners(self)
	self:RemoveIslandListener(IslandAgoraAgency.AGORA_UPGRADE, self.OnAgoraUpdate)
	self:RemoveIslandListener(IslandSignInAgency.GIFT_CNT_UPDATE, self.OnSignInGiftCntUpdate)
	self:RemoveIslandListener(IslandSignInAgency.SIGN_CNT_UPDATE, self.OnSignCntUpdate)
	self:RemoveIslandListener(IslandAgoraAgency.ADD_THEME, self.OnThemeAdded)
	self:RemoveIslandListener(IslandAgoraAgency.DEL_THEME, self.OnThemeDeleted)
	self:RemoveIslandListener(IslandAgoraAgency.PLACEMENT_UPDATE, self.OnPlacementUpdate)
	self:RemoveIslandListener(IslandAgoraAgency.ADD_FURNITURE, self.OnFurnitureAdded)
end

function AgoraController:ClearNew(arg_83_1)
	local var_83_0 = self.agora:GetPlaceableItem(arg_83_1)

	if not var_83_0 then
		return
	end

	var_83_0:ClearNew()
	self:GetIsland():GetAgoraAgency():ClearNew(var_83_0.configId)
end

function AgoraController:ClearAllNew()
	for iter_84_0, iter_84_1 in pairs((self.agora:GetPlaceableList())) do
		iter_84_1:ClearNew()
	end

	self:GetIsland():GetAgoraAgency():ClearAllNew()
end

function AgoraController:OnFurnitureAdded(arg_85_1)
	for iter_85_0 = 1, arg_85_1.count do
		self.agora:AddPlaceable((AgoraFurniture.New({
			id = AgoraCalc.GetUniqueId(arg_85_1.id, iter_85_0),
			configId = arg_85_1.id,
			time = arg_85_1.time,
			isNew = arg_85_1.isNew
		})))
	end
end

function AgoraController:OnPlacementUpdate(arg_86_1)
	self.islandSyncMgr:StopAgoraInteraction()

	local var_86_0 = AgoraTheme.New(arg_86_1, self.agora.placeableList)
	local var_86_1, var_86_2, var_86_3 = var_86_0:GetSeparatedPlacedData()

	if var_86_2 and self.agora:GetFoundation().id ~= var_86_2.id then
		self:ReplaceFoundation(var_86_2.id)
	end

	if var_86_3 and self.agora:GetBuilding().id ~= var_86_3.id then
		self:ReplaceBuilding(var_86_3.id)
	end

	local var_86_4, var_86_5, var_86_6 = AgoraCalc.GetChangePlacementList(var_86_1, (self.agora:GetPlacedListWithoutFoundationAndBuilding()))

	for iter_86_0, iter_86_1 in ipairs(var_86_5) do
		self.agora:UnPlaceItem(iter_86_1.id)
	end

	for iter_86_2, iter_86_3 in ipairs(var_86_6) do
		self.agora:PlaceItem(iter_86_3.id, iter_86_3:GetPosition(), iter_86_3:GetRotation())
	end

	for iter_86_4, iter_86_5 in ipairs(var_86_4) do
		self.agora:UnPlaceItem(iter_86_5.id)
		self.agora:PlaceItem(iter_86_5.id, iter_86_5:GetPosition(), iter_86_5:GetRotation())
	end

	self:ClearLayers()
	self:PaveLayers(var_86_0:GetFloorData(), (var_86_0:GetTileData()))

	self.reloading = true
	self.nextReloadingEndTime = pg.TimeMgr.GetInstance():GetServerTime() + self.baseReloadingCd

	self:NotifiyAgora(ISLAND_AGORA_EVT.RELOADING)

	if (#var_86_6 > 0 or #var_86_4 > 0) and not self:IsSelfIsland() then
		self:ResetPlayerPosition()
	end
end

function AgoraController:OnThemeAdded(arg_87_1)
	self.agora:AddTheme((AgoraTheme.New(arg_87_1, self.agora.placeableList)))
end

function AgoraController:OnThemeDeleted(arg_88_1)
	self.agora:DeleteTheme(arg_88_1)
end

function AgoraController:OnSignCntUpdate(arg_89_1)
	local var_89_0 = self:GetIsland():GetSignInAgency()

	self:NotifiyCore(ISLAND_EVT.REFRESH_INTERACTION)
	self:NotifiyAgora(ISLAND_AGORA_EVT.SIGN_IN_CNT_UPDATE, arg_89_1)
end

function AgoraController:OnSignInGiftCntUpdate(arg_90_1)
	self.giftAllocator:Flush()
end

function AgoraController:OnAgoraUpdate(arg_91_1, arg_91_2)
	self.agora:UpdateSize(Vector2(IslandConst.AGORA_LEVEL_2_SIZE[arg_91_1], IslandConst.AGORA_LEVEL_2_SIZE[arg_91_1]))
	self.agora:UpdateCapacity(arg_91_2)
end

function AgoraController:CreateAgora(arg_92_1)
	local var_92_0 = arg_92_1:GetAgoraAgency()
	local var_92_1 = {}

	for iter_92_0, iter_92_1 in ipairs(var_92_0:GetFurnitures()) do
		for iter_92_2 = 1, iter_92_1.count do
			local var_92_2 = AgoraFurniture.New({
				id = AgoraCalc.GetUniqueId(iter_92_1.id, iter_92_2),
				configId = iter_92_1.id,
				time = iter_92_1.time,
				isNew = iter_92_1.isNew
			})

			var_92_1[var_92_2.id] = var_92_2
		end
	end

	local var_92_3 = AgoraTheme.New(var_92_0:GetPlacedData(), var_92_1)
	local var_92_4, var_92_5, var_92_6 = var_92_3:GetSeparatedPlacedData()
	local var_92_7 = {}

	for iter_92_3, iter_92_4 in ipairs(var_92_0:GetThemes()) do
		table.insert(var_92_7, (AgoraTheme.New(iter_92_4, var_92_1)))
	end

	local var_92_8 = {}

	for iter_92_5, iter_92_6 in ipairs(var_92_0:GetSystemThemes()) do
		table.insert(var_92_8, (AgoraSystemTheme.New(iter_92_6)))
	end

	local var_92_9 = IslandConst.AGORA_LEVEL_2_SIZE[math.clamp(var_92_0:GetLevel(), 1, #IslandConst.AGORA_LEVEL_2_SIZE)]

	return Agora.New({
		size = Vector2(var_92_9, var_92_9),
		placeableList = var_92_1,
		capacity = var_92_0:GetCapacity(),
		themes = var_92_7,
		systemThemes = var_92_8
	}), {
		placedlist = var_92_4,
		foundation = var_92_5,
		building = var_92_6,
		placedFloor = var_92_3:GetFloorData(),
		placedTile = var_92_3:GetTileData()
	}
end

return AgoraController
