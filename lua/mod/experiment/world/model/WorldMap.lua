local WorldMap = class("WorldMap", import("...BaseEntity"))

WorldMap.Fields = {
	config = "table",
	valid = "boolean",
	isDelegated = "boolean",
	cells = "table",
	gid = "number",
	active = "boolean",
	findex = "number",
	top = "number",
	phaseDisplayList = "table",
	isPressing = "boolean",
	salvageAutoResult = "boolean",
	visionFlag = "boolean",
	isLoss = "boolean",
	bottom = "number",
	centerCellFOV = "table",
	typeAttachments = "table",
	isCost = "boolean",
	theme = "table",
	fleets = "table",
	left = "number",
	factionBuffs = "table",
	ports = "table",
	id = "number",
	clearFlag = "boolean",
	right = "number"
}
WorldMap.Listeners = {
	onUpdateAttachmentExist = "OnUpdateAttachmentExist"
}
WorldMap.EventUpdateActive = "WorldMap.EventUpdateActive"
WorldMap.EventUpdateFIndex = "WorldMap.EventUpdateFIndex"
WorldMap.EventUpdateMapBuff = "WorldMap.EventUpdateMapBuff"
WorldMap.EventUpdateFleetFOV = "WorldMap.EventUpdateFleetFOV"
WorldMap.EventUpdateMoveSpeed = "WorldMap.EventUpdateMoveSpeed"

function WorldMap:DebugPrint()
	return string.format("地图 [%s] [id: %s] [gid: %s] [危险度: %s] [是否委派：%s] [是否压制：%s]", self.config.name, self.id, tostring(self.gid), self:GetDanger(), self.isDelegated, self.isPressing)
end

function WorldMap:Build()
	self.cells = {}
	self.ports = {}
	self.phaseDisplayList = {}
end

function WorldMap:Dispose()
	self:UnbindFleets()
	self:DisposeTheme()
	self:DisposeGrid()
	self:DisposePort()
	self:Clear()
end

function WorldMap:Setup(arg_4_1)
	self.id = arg_4_1

	assert(pg.world_chapter_random[self.id], "world_chapter_random not exist: " .. tostring(self.id))

	self.config = setmetatable({}, {
		__index = function(arg_5_0, arg_5_1)
			return self:GetConfig(arg_5_1)
		end
	})
end

function WorldMap:GetName(arg_6_1)
	local var_6_0 = arg_6_1 and World.ReplacementMapType(arg_6_1, self)

	if var_6_0 == "sairen_chapter" or var_6_0 == "teasure_chapter" then
		return arg_6_1:GetBaseMap():GetName() .. "-" .. self.config.name
	else
		return self.config.name
	end
end

function WorldMap:GetConfig(arg_7_1)
	local var_7_0

	if pg.world_chapter_random[self.id] then
		var_7_0 = pg.world_chapter_random[self.id][arg_7_1]

		if not pg.world_chapter_random[self.id][arg_7_1] then
			if pg.world_chapter_template[self.gid] then
				var_7_0 = pg.world_chapter_template[self.gid][arg_7_1] or nil
			end
		end
	end

	assert(var_7_0 ~= nil, "can not find " .. arg_7_1 .. " in WorldMap " .. self.id)

	return var_7_0
end

WorldMap.FactionSelf = 0
WorldMap.FactionEnemy = 1

function WorldMap:UpdateGridId(arg_8_1)
	self.gid = arg_8_1

	assert(pg.world_chapter_template[self.gid], "world_chapter_template not exist: " .. tostring(self.gid))
	self:DisposeTheme()
	self:DisposeGrid()
	self:DisposePort()

	self.factionBuffs = {
		[WorldMap.FactionSelf] = {},
		[WorldMap.FactionEnemy] = {}
	}

	for iter_8_0, iter_8_1 in ipairs(self.config.world_chapter_buff) do
		local var_8_0, var_8_1, var_8_2 = unpack(iter_8_1)

		self:AddBuff(var_8_0, var_8_1, var_8_2)
	end

	self:SetupTheme()
	self:SetupGrid()
	self:SetupPort()
end

function WorldMap:SetupTheme()
	local var_9_0 = WPool:Get(WorldMapTheme)

	var_9_0:Setup(self.config.theme)

	self.theme = var_9_0
end

function WorldMap:DisposeTheme()
	if self.theme then
		WPool:Return(self.theme)

		self.theme = nil
	end
end

function WorldMap:SetupGrid(arg_11_1)
	_.each(self.config.grids, function(arg_12_0)
		local var_12_0 = WPool:Get(WorldMapCell)

		var_12_0:Setup(arg_12_0)

		if self:AlwaysInFOV() then
			var_12_0.infov = bit.bor(var_12_0.infov, WorldConst.FOVMapSight)
		end

		self.cells[WorldMapCell.GetName(var_12_0.row, var_12_0.column)] = var_12_0

		if not arg_11_1 then
			var_12_0:AddListener(WorldMapCell.EventAddAttachment, self.onUpdateAttachmentExist)
			var_12_0:AddListener(WorldMapCell.EventRemoveAttachment, self.onUpdateAttachmentExist)
		end
	end)

	self.left, self.right = 999999, 0
	self.top, self.bottom = 999999, 0

	for iter_11_0 = 0, WorldConst.MaxRow do
		local var_11_0
		local var_11_1

		for iter_11_1 = 0, WorldConst.MaxColumn do
			local var_11_2 = self:GetCell(iter_11_0, iter_11_1)

			if var_11_2 then
				if not var_11_0 then
					var_11_0 = iter_11_1
					var_11_2.dir = bit.bor(var_11_2.dir, bit.lshift(1, WorldConst.DirLeft))
				end

				var_11_1 = iter_11_1
			end
		end

		if var_11_1 then
			local var_11_3 = self:GetCell(iter_11_0, var_11_1)

			var_11_3.dir = bit.bor(var_11_3.dir, bit.lshift(1, WorldConst.DirRight))
		end

		if var_11_0 then
			self.left = math.min(self.left, var_11_0)
		end

		if var_11_1 then
			self.right = math.max(self.right, var_11_1)
		end
	end

	for iter_11_2 = 0, WorldConst.MaxColumn do
		local var_11_4
		local var_11_5

		for iter_11_3 = 0, WorldConst.MaxRow do
			local var_11_6 = self:GetCell(iter_11_3, iter_11_2)

			if var_11_6 then
				if not var_11_4 then
					var_11_4 = iter_11_3
					var_11_6.dir = bit.bor(var_11_6.dir, bit.lshift(1, WorldConst.DirUp))
				end

				var_11_5 = iter_11_3
			end
		end

		if var_11_5 then
			local var_11_7 = self:GetCell(var_11_5, iter_11_2)

			var_11_7.dir = bit.bor(var_11_7.dir, bit.lshift(1, WorldConst.DirDown))
		end

		if var_11_4 then
			self.top = math.min(self.top, var_11_4)
		end

		if var_11_5 then
			self.bottom = math.max(self.bottom, var_11_5)
		end
	end
end

function WorldMap:DisposeGrid(arg_13_1)
	if not arg_13_1 then
		for iter_13_0, iter_13_1 in pairs(self.cells) do
			iter_13_1:RemoveListener(WorldMapCell.EventAddAttachment, self.onUpdateAttachmentExist)
			iter_13_1:RemoveListener(WorldMapCell.EventRemoveAttachment, self.onUpdateAttachmentExist)
		end
	end

	WPool:ReturnMap(self.cells)

	self.cells = {}
	self.typeAttachments = {}
	self.left = nil
	self.top = nil
	self.right = nil
	self.bottom = nil
end

function WorldMap:SetupPort()
	if #self.config.port_id > 0 then
		local var_14_0 = WPool:Get(WorldMapPort)

		var_14_0:Setup(self.config.port_id[1])

		local var_14_1, var_14_2 = unpack(self.config.port_id[2])

		for iter_14_0 = var_14_1 - 1, var_14_1 + 1 do
			for iter_14_1 = var_14_2 - 1, var_14_2 + 1 do
				if iter_14_0 ~= var_14_1 or iter_14_1 ~= var_14_2 then
					local var_14_3 = self:GetCell(iter_14_0, iter_14_1)

					if var_14_3 then
						var_14_3:AddAttachment(WorldMapAttachment.MakeFakePort(iter_14_0, iter_14_1, var_14_0.id))
					end
				end
			end
		end

		table.insert(self.ports, var_14_0)
	end
end

function WorldMap:DisposePort()
	WPool:ReturnArray(self.ports)

	self.ports = {}
end

function WorldMap:IsValid()
	return self.valid
end

function WorldMap:SetValid(arg_17_1)
	self.valid = arg_17_1

	if arg_17_1 and self.fleets then
		for iter_17_0, iter_17_1 in ipairs(self:GetNormalFleets()) do
			self.centerCellFOV = {
				row = iter_17_1.row,
				column = iter_17_1.column
			}

			if self:GetFleetTerrain(iter_17_1) ~= WorldMapCell.TerrainFog then
				WorldConst.RangeCheck(iter_17_1, self:GetFOVRange(iter_17_1), function(arg_18_0, arg_18_1)
					local var_18_0 = self.cells[WorldMapCell.GetName(arg_18_0, arg_18_1)]

					if var_18_0 then
						var_18_0:ChangeInLight(true)
					end
				end)
			elseif self.findex == iter_17_0 then
				local var_17_0 = {}

				WorldConst.RangeCheck(iter_17_1, self:GetFOVRange(iter_17_1), function(arg_19_0, arg_19_1)
					local var_19_0 = WorldMapCell.GetName(arg_19_0, arg_19_1)

					if self.cells[var_19_0] then
						var_17_0[var_19_0] = true
					end
				end)

				local var_17_1 = self:IsFleetTerrainSairenFog(iter_17_1)

				for iter_17_2, iter_17_3 in pairs(self.cells) do
					iter_17_3:UpdateFog(true, var_17_0[iter_17_2], var_17_1)
				end
			end
		end
	end
end

function WorldMap:IsMapOpen()
	return nowWorld():GetProgress() >= self:GetOpenProgress()
end

function WorldMap:GetOpenProgress()
	local var_21_0 = nowWorld():GetRealm()

	return (var_21_0 > 0 or nil) and (self.config.open_stage[var_21_0] or 9999)
end

function WorldMap:RemoveAllCellDiscovered()
	for iter_22_0, iter_22_1 in pairs(self.cells) do
		iter_22_1:UpdateDiscovered(false)
	end
end

function WorldMap:GetDanger()
	return self.config.hazard_level
end

function WorldMap:BindFleets(arg_24_1)
	self.fleets = arg_24_1
end

function WorldMap:UnbindFleets()
	self.fleets = nil
end

function WorldMap:GetFleets()
	return underscore.to_array(self.fleets)
end

function WorldMap:GetFleet(arg_27_1)
	return arg_27_1 and _.detect(self.fleets, function(arg_28_0)
		return arg_28_0.id == arg_27_1
	end) or self.fleets[self.findex]
end

function WorldMap:GetNormalFleets()
	return _.filter(self.fleets, function(arg_30_0)
		return arg_30_0:GetFleetType() == FleetType.Normal
	end)
end

function WorldMap:GetSubmarineFleet()
	return _.detect(self.fleets, function(arg_32_0)
		return arg_32_0:GetFleetType() == FleetType.Submarine
	end)
end

function WorldMap:FindFleet(arg_33_1, arg_33_2)
	return _.detect(self.fleets, function(arg_34_0)
		return arg_34_0.row == arg_33_1 and arg_34_0.column == arg_33_2
	end)
end

function WorldMap:CheckFleetMovable(arg_35_1)
	return self:GetCell(arg_35_1.row, arg_35_1.column):CanLeave()
end

function WorldMap:GetFleetTerrain(arg_36_1)
	return self:GetCell(arg_36_1.row, arg_36_1.column):GetTerrain()
end

function WorldMap:IsFleetTerrainSairenFog(arg_37_1)
	return self:GetCell(arg_37_1.row, arg_37_1.column):IsTerrainSairenFog()
end

function WorldMap:RemoveFleetsCarries(arg_38_1)
	arg_38_1 = arg_38_1 or self.fleets

	_.each(arg_38_1, function(arg_39_0)
		arg_39_0:RemoveAllCarries()
	end)
end

function WorldMap:UpdateFleetIndex(arg_40_1)
	if self.findex ~= arg_40_1 then
		self:CheckSelectFleetUpdateFog(function()
			self.findex = arg_40_1
		end)
		self:DispatchEvent(WorldMap.EventUpdateFIndex)
	end
end

function WorldMap:UpdateActive(arg_42_1)
	local var_42_0 = nowWorld():GetAtlas()

	if self.active ~= arg_42_1 then
		self.active = arg_42_1

		if arg_42_1 then
			self:SetValid(false)
			var_42_0:SetActiveMap(self)

			self.isCost = true

			var_42_0:UpdateCostMap(self.id, self.isCost)
		elseif self:NeedClear() then
			self:RemoveAllCellDiscovered()

			self.clearFlag = false
			self.isCost = false

			var_42_0:UpdateCostMap(self.id, self.isCost)
		end

		self:DispatchEvent(WorldMap.EventUpdateActive)
	end
end

function WorldMap:InPort(arg_43_1, arg_43_2)
	local var_43_0 = self:GetPort()

	if not var_43_0 or arg_43_2 and var_43_0.config.port_camp ~= arg_43_2 then
		return false
	end

	local var_43_1 = self:GetFleet(arg_43_1)

	if var_43_1:GetFleetType() == FleetType.Submarine then
		return var_43_0.id
	else
		local var_43_2 = self:GetCell(var_43_1.row, var_43_1.column):GetAliveAttachment()

		if var_43_2 and var_43_2.type == WorldMapAttachment.TypePort then
			return var_43_2.id
		end
	end

	return false
end

function WorldMap:canExit()
	return self.gid and pg.world_chapter_template_reset[self.gid] ~= nil
end

function WorldMap:CheckAttachmentTransport()
	local var_45_0 = WorldConst.GetTransportBlockEvent()
	local var_45_1 = self:FindAttachments(WorldMapAttachment.TypeEvent)

	for iter_45_0, iter_45_1 in ipairs(var_45_1) do
		if iter_45_1:IsAlive() and var_45_0[iter_45_1.id] then
			return "block"
		end
	end

	local var_45_2 = WorldConst.GetTransportStoryEvent()

	for iter_45_2, iter_45_3 in ipairs(var_45_1) do
		if iter_45_3:IsAlive() and var_45_2[iter_45_3.id] then
			return "story"
		end
	end
end

function WorldMap:GetPort(arg_46_1)
	return arg_46_1 and _.detect(self.ports, function(arg_47_0)
		return arg_47_0.id == arg_46_1
	end) or self.ports[1]
end

function WorldMap:GetCell(arg_48_1, arg_48_2)
	return self.cells[WorldMapCell.GetName(arg_48_1, arg_48_2)]
end

function WorldMap:CalcTransportPos(arg_49_1, arg_49_2)
	local var_49_0 = calcPositionAngle(arg_49_1.config.area_pos[1] - arg_49_2.config.area_pos[1], arg_49_1.config.area_pos[2] - arg_49_2.config.area_pos[2])
	local var_49_1 = false

	if not self.gid then
		var_49_1 = true
		self.gid = self.config.template_id[1][1]

		self:SetupGrid(var_49_1)
	end

	local var_49_2 = {
		row = (self.top + self.bottom) / 2,
		column = (self.left + self.right) / 2
	}
	local var_49_3
	local var_49_4 = 4294967295

	for iter_49_0 = self.left + 1, self.right - 1 do
		local var_49_6 = math.abs(calcPositionAngle(iter_49_0 - var_49_2.column, var_49_2.row - self.top) - var_49_0)

		if var_49_6 < var_49_4 then
			var_49_3 = {
				row = self.top,
				column = iter_49_0
			}
			var_49_4 = var_49_6
		end

		local var_49_7 = math.abs(calcPositionAngle(iter_49_0 - var_49_2.column, var_49_2.row - self.bottom) - var_49_0)

		if var_49_7 < var_49_4 then
			var_49_3 = {
				row = self.bottom,
				column = iter_49_0
			}
			var_49_4 = var_49_7
		end
	end

	for iter_49_1 = self.top + 1, self.bottom - 1 do
		local var_49_8 = math.abs(calcPositionAngle(self.left - var_49_2.column, var_49_2.row - iter_49_1) - var_49_0)

		if var_49_8 < var_49_4 then
			var_49_3 = {
				row = iter_49_1,
				column = self.left
			}
			var_49_4 = var_49_8
		end

		local var_49_9 = math.abs(calcPositionAngle(self.right - var_49_2.column, var_49_2.row - iter_49_1) - var_49_0)

		if var_49_9 < var_49_4 then
			var_49_3 = {
				row = iter_49_1,
				column = self.right
			}
			var_49_4 = var_49_9
		end
	end

	if var_49_1 then
		self:DisposeGrid(var_49_1)

		self.gid = nil
	end

	return var_49_3
end

function WorldMap:AnyFleetInEdge()
	return self.active and _.any(self:GetNormalFleets(), function(arg_51_0)
		return arg_51_0.row == self.top or arg_51_0.row == self.bottom or arg_51_0.column == self.left or arg_51_0.column == self.right
	end)
end

function WorldMap:CheckInteractive(arg_52_1)
	local var_52_0 = self:FindAttachments(WorldMapAttachment.TypeEvent)

	for iter_52_0, iter_52_1 in ipairs(var_52_0) do
		if iter_52_1:RemainOpEffect() then
			return iter_52_1
		end
	end

	for iter_52_2, iter_52_3 in ipairs(var_52_0) do
		if iter_52_3:IsAlive() then
			local var_52_1 = iter_52_3:GetEventEffect()

			if var_52_1 and var_52_1.autoactivate > 0 then
				return iter_52_3
			end
		end
	end

	arg_52_1 = arg_52_1 or self:GetFleet()

	local var_52_2 = self:GetCell(arg_52_1.row, arg_52_1.column)

	if var_52_2.discovered then
		for iter_52_4, iter_52_5 in ipairs((var_52_2:GetAliveAttachments())) do
			if WorldMapAttachment.IsInteractiveType(iter_52_5.type) and not iter_52_5:IsTriggered() then
				if iter_52_5:IsSign() then
					return nil
				elseif iter_52_5.type == WorldMapAttachment.TypeEvent then
					local var_52_3 = iter_52_5:GetEventEffect()

					if var_52_3 and (var_52_3.effective_num <= 1 or self:CountEventEffectKeys(var_52_3) >= var_52_3.effective_num) then
						return iter_52_5
					end
				else
					return iter_52_5
				end
			end
		end
	end
end

function WorldMap:CheckDiscover()
	local var_53_0 = {}

	for iter_53_0, iter_53_1 in pairs(self.cells) do
		if not iter_53_1.discovered and iter_53_1:GetInFOV() then
			table.insert(var_53_0, {
				row = iter_53_1.row,
				column = iter_53_1.column
			})
		end
	end

	return var_53_0
end

function WorldMap:CheckDisplay(arg_54_1)
	if arg_54_1.type == WorldMapAttachment.TypeTrap then
		return true
	end

	return self:GetCell(arg_54_1.row, arg_54_1.column):GetDisplayAttachment() == arg_54_1
end

function WorldMap:GetFOVRange(arg_55_1, arg_55_2, arg_55_3)
	arg_55_2 = arg_55_2 or arg_55_1.row
	arg_55_3 = arg_55_3 or arg_55_1.column

	local var_55_0 = self:GetCell(arg_55_2, arg_55_3)

	return (var_55_0:GetTerrain() == WorldMapCell.TerrainFog or nil) and (var_55_0.terrainStrong or arg_55_1:GetFOVRange())
end

function WorldMap:UpdateVisionFlag(arg_56_1)
	self.visionFlag = arg_56_1

	self:OrderAROpenFOV(self.visionFlag)
end

function WorldMap:UpdateDeteagtedMark(arg_57_1)
	if tobool(self.isDelegated) ~= tobool(arg_57_1) then
		self.isDelegated = arg_57_1
	end
end

function WorldMap:UpdatePressingMark(arg_58_1)
	if tobool(self.isPressing) ~= tobool(arg_58_1) then
		self.isPressing = arg_58_1

		nowWorld():GetTaskProxy():doUpdateTaskByMap(self.id, arg_58_1)
	end
end

function WorldMap:ExistAny(arg_59_1, arg_59_2)
	return self:GetCell(arg_59_1, arg_59_2):GetAliveAttachment() or self:ExistFleet(arg_59_1, arg_59_2)
end

function WorldMap:ExistFleet(arg_60_1, arg_60_2)
	return tobool(self:FindFleet(arg_60_1, arg_60_2))
end

function WorldMap:CalcFleetSpeed(arg_61_1)
	local var_61_0 = arg_61_1:GetSpeed()

	if self:GetCell(arg_61_1.row, arg_61_1.column):GetTerrain() == WorldMapCell.TerrainFog then
		var_61_0 = math.min(var_61_0, 1)
	end

	return var_61_0
end

function WorldMap:FindPath(arg_62_1, arg_62_2, arg_62_3)
	local var_62_0 = WorldMap.pathFinder

	if not WorldMap.pathFinder then
		var_62_0 = PathFinding.New({}, WorldConst.MaxRow, WorldConst.MaxColumn)
		WorldMap.pathFinder = var_62_0
	end

	local var_62_1 = {}

	for iter_62_0 = 0, WorldConst.MaxRow - 1 do
		var_62_1[iter_62_0] = var_62_1[iter_62_0] or {}

		for iter_62_1 = 0, WorldConst.MaxColumn - 1 do
			local var_62_2 = PathFinding.PrioForbidden

			if self:IsWalkable(iter_62_0, iter_62_1) then
				if arg_62_3 then
					if self:GetCell(iter_62_0, iter_62_1):GetInFOV() then
						var_62_2 = PathFinding.PrioNormal

						if iter_62_0 == arg_62_2.row and iter_62_1 == arg_62_2.column then
							if not self:IsStayPoint(iter_62_0, iter_62_1) then
								var_62_2 = PathFinding.PrioObstacle
							end
						elseif self:IsObstacle(iter_62_0, iter_62_1) then
							var_62_2 = PathFinding.PrioObstacle
						end
					end
				end
			end

			var_62_1[iter_62_0][iter_62_1] = var_62_2
		end
	end

	var_62_0.cells = var_62_1

	return var_62_0:Find(arg_62_1, arg_62_2)
end

function WorldMap:FindAIPath(arg_63_1, arg_63_2)
	local var_63_0 = WorldMap.pathFinder

	if not WorldMap.pathFinder then
		var_63_0 = PathFinding.New({}, WorldConst.MaxRow, WorldConst.MaxColumn)
		WorldMap.pathFinder = var_63_0
	end

	local var_63_1 = {}

	for iter_63_0 = 0, WorldConst.MaxRow - 1 do
		var_63_1[iter_63_0] = var_63_1[iter_63_0] or {}

		for iter_63_1 = 0, WorldConst.MaxColumn - 1 do
			local var_63_2 = PathFinding.PrioForbidden

			if self:IsWalkable(iter_63_0, iter_63_1) then
				var_63_2 = PathFinding.PrioNormal

				if (iter_63_0 ~= arg_63_2.row or iter_63_1 ~= arg_63_2.column) and self:ExistFleet(iter_63_0, iter_63_1) then
					var_63_2 = PathFinding.PrioObstacle
				end
			end

			var_63_1[iter_63_0][iter_63_1] = var_63_2
		end
	end

	var_63_0.cells = var_63_1

	return var_63_0:Find(arg_63_1, arg_63_2)
end

function WorldMap:GetMoveRange(arg_64_1)
	local var_64_0 = self:CalcFleetSpeed(arg_64_1)
	local var_64_1 = {}

	for iter_64_0 = 0, WorldConst.MaxRow - 1 do
		var_64_1[iter_64_0] = var_64_1[iter_64_0] or {}

		for iter_64_1 = 0, WorldConst.MaxColumn - 1 do
			var_64_1[iter_64_0][iter_64_1] = self:IsWalkable(iter_64_0, iter_64_1)
		end
	end

	local var_64_2 = {}
	local var_64_3 = {
		{
			step = 0,
			row = arg_64_1.row,
			column = arg_64_1.column
		}
	}

	var_64_1[arg_64_1.row][arg_64_1.column] = false

	while #var_64_3 > 0 do
		local var_64_4 = table.remove(var_64_3, 1)

		table.insert(var_64_2, var_64_4)
		_.each({
			{
				row = 1,
				column = 0
			},
			{
				row = -1,
				column = 0
			},
			{
				row = 0,
				column = 1
			},
			{
				row = 0,
				column = -1
			}
		}, function(arg_65_0)
			arg_65_0.row = var_64_4.row + arg_65_0.row
			arg_65_0.column = var_64_4.column + arg_65_0.column
			arg_65_0.step = var_64_4.step + 1

			if arg_65_0.row >= 0 and arg_65_0.row < WorldConst.MaxRow and arg_65_0.column >= 0 and arg_65_0.column < WorldConst.MaxColumn and arg_65_0.step <= var_64_0 and var_64_1[arg_65_0.row][arg_65_0.column] then
				var_64_1[arg_65_0.row][arg_65_0.column] = false

				if self:IsObstacle(arg_65_0.row, arg_65_0.column) then
					table.insert(var_64_2, arg_65_0)
				else
					table.insert(var_64_3, arg_65_0)
				end
			end
		end)
	end

	var_64_2 = _.filter(var_64_2, function(arg_66_0)
		return self:IsStayPoint(arg_66_0.row, arg_66_0.column)
	end)

	return var_64_2
end

function WorldMap:BuildLongMoveInfos()
	local var_67_0 = {}

	for iter_67_0 = 0, WorldConst.MaxRow - 1 do
		var_67_0[iter_67_0] = var_67_0[iter_67_0] or {}

		for iter_67_1 = 0, WorldConst.MaxColumn - 1 do
			if self:IsWalkable(iter_67_0, iter_67_1) then
				if self:GetCell(iter_67_0, iter_67_1):GetInFOV() then
					var_67_0[iter_67_0][iter_67_1] = {
						isFinish = false,
						isMark = false,
						row = iter_67_0,
						column = iter_67_1,
						dp = {},
						last = {},
						isStayPoint = self:IsStayPoint(iter_67_0, iter_67_1),
						isObstacle = self:IsObstacle(iter_67_0, iter_67_1)
					}
				end
			end
		end
	end

	return var_67_0
end

function WorldMap:GetLongMoveRange(arg_68_1)
	local var_68_0 = self:CalcFleetSpeed(arg_68_1)
	local var_68_1 = self:BuildLongMoveInfos()
	local var_68_2 = {}
	local var_68_3 = {}
	local var_68_4 = {
		{
			row = 1,
			column = 0
		},
		{
			row = -1,
			column = 0
		},
		{
			row = 0,
			column = 1
		},
		{
			row = 0,
			column = -1
		}
	}

	local function var_68_5(arg_69_0, arg_69_1, arg_69_2)
		return arg_69_0 < arg_69_1 or arg_69_2 < arg_69_0
	end

	local function var_68_6(arg_70_0)
		if not arg_70_0 then
			return
		end

		arg_70_0.isFinish = true

		table.insert(var_68_2, arg_70_0)

		if arg_70_0.isStayPoint then
			for iter_70_0 = 1, var_68_0 do
				if arg_70_0.dp[iter_70_0] and (not arg_70_0.dp[0] or arg_70_0.dp[0] > arg_70_0.dp[iter_70_0] + 1) then
					arg_70_0.dp[0] = arg_70_0.dp[iter_70_0] + 1
					arg_70_0.last[0] = arg_70_0.last[iter_70_0]
				end
			end
		end
	end

	local var_68_7 = var_68_1[arg_68_1.row][arg_68_1.column]

	var_68_1[arg_68_1.row][arg_68_1.column].dp[0] = 0
	var_68_7.isMark = true

	var_68_6(var_68_7)

	while var_68_7 do
		_.each(var_68_4, function(arg_71_0)
			if var_68_5(var_68_7.row + arg_71_0.row, 0, WorldConst.MaxRow - 1) or var_68_5(var_68_7.column + arg_71_0.column, 0, WorldConst.MaxColumn - 1) then
				return
			end

			local var_71_0 = var_68_1[var_68_7.row + arg_71_0.row][var_68_7.column + arg_71_0.column]

			if var_68_1[var_68_7.row + arg_71_0.row][var_68_7.column + arg_71_0.column] and not var_71_0.isFinish then
				for iter_71_0 = 1, var_68_0 do
					if var_68_7.dp[iter_71_0 - 1] and (not var_71_0.dp[iter_71_0] or var_71_0.dp[iter_71_0] > var_68_7.dp[iter_71_0 - 1]) then
						var_71_0.dp[iter_71_0] = var_68_7.dp[iter_71_0 - 1]
						var_71_0.last[iter_71_0] = {
							var_68_7,
							iter_71_0 - 1
						}

						if not var_71_0.isMark then
							var_71_0.isMark = true

							table.insert(var_68_3, var_71_0)
						end
					end
				end
			end
		end)

		repeat
			var_68_7 = table.remove(var_68_3, 1)

			var_68_6(var_68_7)
		until not var_68_7 or not var_68_7.isObstacle
	end

	local var_68_8 = {}

	for iter_68_0, iter_68_1 in ipairs(var_68_2) do
		if iter_68_1.dp[0] and iter_68_1.dp[0] > 0 then
			table.insert(var_68_8, {
				row = iter_68_1.row,
				column = iter_68_1.column,
				stay = iter_68_1.dp[0]
			})
		end
	end

	return var_68_8, var_68_1
end

function WorldMap:IsWalkable(arg_72_1, arg_72_2)
	local var_72_0 = self:GetCell(arg_72_1, arg_72_2)
	local var_72_1

	if var_72_0 then
		::label_72_0::

		var_72_1 = var_72_0.walkable

		if var_72_0.walkable then
			var_72_1 = var_72_0:CanLeave()
			var_72_1 = var_72_1 or self:IsStayPoint(arg_72_1, arg_72_2)
		end
	end

	return var_72_1
end

function WorldMap:IsStayPoint(arg_73_1, arg_73_2)
	local var_73_0 = self:GetCell(arg_73_1, arg_73_2):CanArrive()

	var_73_0 = var_73_0 and not self:ExistFleet(arg_73_1, arg_73_2)

	return var_73_0
end

function WorldMap:IsObstacle(arg_74_1, arg_74_2)
	return not self:GetCell(arg_74_1, arg_74_2):CanPass()
end

function WorldMap:IsSign(arg_75_1, arg_75_2)
	return self:GetCell(arg_75_1, arg_75_2):IsSign()
end

function WorldMap:FindNearestBlankPoint(arg_76_1, arg_76_2)
	local var_76_0 = {}

	for iter_76_0 = 0, WorldConst.MaxRow - 1 do
		var_76_0[iter_76_0] = var_76_0[iter_76_0] or {}

		for iter_76_1 = 0, WorldConst.MaxColumn - 1 do
			var_76_0[iter_76_0][iter_76_1] = self:IsWalkable(iter_76_0, iter_76_1)
		end
	end

	local var_76_1 = {
		row = arg_76_1,
		column = arg_76_2
	}
	local var_76_2 = {}

	while #var_76_1 > 0 do
		local var_76_3 = table.remove(var_76_1, 1)

		table.insert(var_76_2, var_76_3)
		_.each({
			{
				row = 1,
				column = 0
			},
			{
				row = -1,
				column = 0
			},
			{
				row = 0,
				column = 1
			},
			{
				row = 0,
				column = -1
			}
		}, function(arg_77_0)
			arg_77_0.row = var_76_3.row + arg_77_0.row
			arg_77_0.column = var_76_3.column + arg_77_0.column

			if arg_77_0.row >= 0 and arg_77_0.row < WorldConst.MaxRow and arg_77_0.column >= 0 and arg_77_0.column < WorldConst.MaxColumn then
				if not (_.any(var_76_1, function(arg_78_0)
					return arg_78_0.row == arg_77_0.row and arg_78_0.column == arg_77_0.column
				end) or _.any(var_76_2, function(arg_79_0)
					return arg_79_0.row == arg_77_0.row and arg_79_0.column == arg_77_0.column
				end)) and var_76_0[arg_77_0.row][arg_77_0.column] then
					if self:ExistAny(arg_77_0.row, arg_77_0.column) then
						table.insert(var_76_1, arg_77_0)
					else
						return arg_77_0
					end
				end
			end
		end)
	end
end

function WorldMap:WriteBack(arg_80_1, arg_80_2)
	local var_80_0 = self:GetFleet()
	local var_80_1 = {}

	for iter_80_0, iter_80_1 in ipairs(var_80_0:GetShips(true)) do
		table.insert(var_80_1, iter_80_1)
	end

	if arg_80_2.statistics.submarineAid then
		local var_80_2 = self:GetSubmarineFleet()

		assert(var_80_2, "submarine fleet not exist.")

		for iter_80_2, iter_80_3 in ipairs((var_80_2:GetTeamShips(TeamType.Submarine, true))) do
			table.insert(var_80_1, iter_80_3)
		end

		var_80_2:UseAmmo()
		var_80_2:AddDefeatEnemies(arg_80_1)
	end

	var_80_0:AddDefeatEnemies(arg_80_1)
	_.each(var_80_1, function(arg_81_0)
		if arg_80_2.statistics[arg_81_0.id] then
			arg_81_0.hpRant = arg_80_2.statistics[arg_81_0.id].bp
		end

		if arg_81_0.hpRant <= 0 then
			arg_81_0:Rebirth()
		end
	end)

	local var_80_3 = self:GetCell(var_80_0.row, var_80_0.column):GetStageEnemy()

	assert(var_80_3)

	if arg_80_1 then
		var_80_3:UpdateFlag(1)

		self.phaseDisplayList = table.mergeArray(self.phaseDisplayList, var_80_3:SetHP(0))

		local var_80_4 = false

		_.each(self:GetFleets(), function(arg_82_0)
			var_80_4 = var_80_4 or arg_82_0:HasDamageLevel()

			arg_82_0:ClearDamageLevel()
		end)
	else
		self.isLoss = true

		var_80_0:IncDamageLevel(var_80_3)
		var_80_3:UpdateData(var_80_3.data - 1)

		self.phaseDisplayList = table.mergeArray(self.phaseDisplayList, var_80_3:SetHP(arg_80_2.statistics._maxBossHP))

		local var_80_5 = nowWorld()

		if var_80_5.isAutoFight then
			var_80_5:TriggerAutoFight(false)
			pg.TipsMgr.GetInstance():ShowTips(i18n("autofight_tip_bigworld_dead"))
		end
	end

	_.each(arg_80_2.hpDropInfo, function(arg_83_0)
		local var_83_0 = #self.phaseDisplayList + 1

		for iter_83_0, iter_83_1 in ipairs(self.phaseDisplayList) do
			if iter_83_1.hp < arg_83_0.hp then
				var_83_0 = iter_83_0

				break
			end
		end

		self:AddPhaseDisplay({
			hp = arg_83_0.hp,
			drops = PlayerConst.addTranDrop(arg_83_0.drop_info)
		}, var_83_0)
	end)
end

function WorldMap:AddPhaseDisplay(arg_84_1, arg_84_2)
	if arg_84_2 then
		table.insert(self.phaseDisplayList, arg_84_2, arg_84_1)
	else
		table.insert(self.phaseDisplayList, arg_84_1)
	end
end

function WorldMap:FindAttachments(arg_85_1, arg_85_2)
	local var_85_0 = {}

	for iter_85_0, iter_85_1 in pairs(self.typeAttachments) do
		if not arg_85_1 or arg_85_1 == iter_85_0 then
			for iter_85_2, iter_85_3 in ipairs(iter_85_1) do
				if not arg_85_2 or iter_85_3.id == arg_85_2 then
					table.insert(var_85_0, iter_85_3)
				end
			end
		end
	end

	return var_85_0
end

function WorldMap:FindEnemys()
	local var_86_0 = {}

	for iter_86_0, iter_86_1 in pairs(self.typeAttachments) do
		if WorldMapAttachment.IsEnemyType(iter_86_0) then
			var_86_0 = table.mergeArray(var_86_0, iter_86_1)
		end
	end

	return var_86_0
end

function WorldMap:GetMapMinMax()
	local var_87_0 = Vector2(WorldConst.MaxColumn, WorldConst.MaxRow)
	local var_87_1 = Vector2(-WorldConst.MaxColumn, -WorldConst.MaxRow)

	for iter_87_0 = 0, WorldConst.MaxRow - 1 do
		for iter_87_1 = 0, WorldConst.MaxColumn - 1 do
			if self:GetCell(iter_87_0, iter_87_1) then
				var_87_0.x = math.min(var_87_0.x, iter_87_1)
				var_87_0.y = math.min(var_87_0.y, iter_87_0)
				var_87_1.x = math.max(var_87_1.x, iter_87_1)
				var_87_1.y = math.max(var_87_1.y, iter_87_0)
			end
		end
	end

	return var_87_0.y, var_87_1.y, var_87_0.x, var_87_1.x
end

function WorldMap:GetMapSize()
	local var_88_0, var_88_1, var_88_2, var_88_3 = self:GetMapMinMax()

	return var_88_1 - var_88_0 + 1, var_88_3 - var_88_2 + 1
end

function WorldMap:CountEventEffectKeys(arg_89_1)
	local var_89_0 = 0

	for iter_89_0, iter_89_1 in ipairs(self:GetNormalFleets()) do
		local var_89_1 = self:GetCell(iter_89_1.row, iter_89_1.column):GetAliveAttachment()

		if var_89_1 and var_89_1.type == WorldMapAttachment.TypeEvent and var_89_1:GetEventEffect() == arg_89_1 then
			var_89_0 = var_89_0 + 1
		end
	end

	return var_89_0
end

function WorldMap:EventEffectOpenFOV(arg_90_1)
	assert(arg_90_1.effect_type == WorldMapAttachment.EffectEventFOV)

	local var_90_0, var_90_1 = unpack(arg_90_1.effect_paramater)
	local var_90_2 = var_90_1 >= 0

	var_90_1 = var_90_1 >= 0 and var_90_1 or math.abs(var_90_1) - 1

	_.each(self:FindAttachments(WorldMapAttachment.TypeEvent, var_90_0), function(arg_91_0)
		self.centerCellFOV = {
			row = arg_91_0.row,
			column = arg_91_0.column
		}

		for iter_91_0 = math.max(arg_91_0.row - var_90_1, 0), math.min(arg_91_0.row + var_90_1, WorldConst.MaxRow - 1) do
			for iter_91_1 = math.max(arg_91_0.column - var_90_1, 0), math.min(arg_91_0.column + var_90_1, WorldConst.MaxColumn - 1) do
				if WorldConst.InFOVRange(arg_91_0.row, arg_91_0.column, iter_91_0, iter_91_1, var_90_1) then
					local var_91_0 = self:GetCell(iter_91_0, iter_91_1)

					if var_91_0 then
						if var_90_2 then
							var_91_0:UpdateInFov(bit.bor(var_91_0.infov, WorldConst.FOVEventEffect))
						else
							var_91_0:UpdateInFov(bit.band(var_91_0.infov, WorldConst.Flag16Max - WorldConst.FOVEventEffect))
						end
					end
				end
			end
		end
	end)
end

function WorldMap:OrderAROpenFOV(arg_92_1)
	if arg_92_1 then
		local var_92_0 = self:GetFleet()

		self.centerCellFOV = {
			row = var_92_0.row,
			column = var_92_0.column
		}
	end

	for iter_92_0, iter_92_1 in pairs(self.cells) do
		if arg_92_1 then
			iter_92_1:UpdateInFov(bit.bor(iter_92_1.infov, WorldConst.FOVEventEffect))
		else
			iter_92_1:UpdateInFov(bit.band(iter_92_1.infov, WorldConst.Flag16Max - WorldConst.FOVEventEffect))
		end
	end
end

function WorldMap:GetMaxDistanceCell(arg_93_1, arg_93_2)
	local var_93_0
	local var_93_1 = 0

	for iter_93_0, iter_93_1 in pairs({
		{
			row = self.top,
			column = self.left
		},
		{
			row = self.bottom,
			column = self.left
		},
		{
			row = self.top,
			column = self.right
		},
		{
			row = self.bottom,
			column = self.right
		}
	}) do
		if var_93_1 < (iter_93_1.row - arg_93_1) * (iter_93_1.row - arg_93_1) + (iter_93_1.column - arg_93_2) * (iter_93_1.column - arg_93_2) then
			var_93_0 = iter_93_1
			var_93_1 = (iter_93_1.row - arg_93_1) * (iter_93_1.row - arg_93_1) + (iter_93_1.column - arg_93_2) * (iter_93_1.column - arg_93_2)
		end
	end

	return var_93_0, math.sqrt(var_93_1)
end

function WorldMap:GetCellsInFOV()
	local var_94_0 = {}

	for iter_94_0, iter_94_1 in pairs(self.cells) do
		if iter_94_1:GetInFOV() then
			table.insert(var_94_0, iter_94_1)
		end
	end

	return var_94_0
end

function WorldMap:AlwaysInFOV()
	return self.config.map_sight == 1
end

function WorldMap:GetEventTipWord()
	local var_96_0 = ""
	local var_96_1 = 0

	for iter_96_0, iter_96_1 in ipairs((self:FindAttachments(WorldMapAttachment.TypeEvent))) do
		if iter_96_1:IsAlive() and pg.world_event_desc[iter_96_1.id] and var_96_1 < pg.world_event_desc[iter_96_1.id].hint_pri then
			var_96_1 = pg.world_event_desc[iter_96_1.id].hint_pri
			var_96_0 = pg.world_event_desc[iter_96_1.id].hint
		end
	end

	return var_96_0, var_96_1
end

function WorldMap:GetEventPoisonRate()
	local var_97_0 = 0

	for iter_97_0, iter_97_1 in ipairs((self:FindAttachments(WorldMapAttachment.TypeEvent))) do
		if iter_97_1:IsAlive() then
			var_97_0 = var_97_0 + iter_97_1.config.infection_value
		end
	end

	return var_97_0, self.config.is_sairen
end

function WorldMap:GetPressingLevel()
	return self.config.complete_effect
end

function WorldMap:CheckMapPressing()
	return self:GetPressingLevel() > 0 and not self.isPressing and self:GetEventPoisonRate() == 0
end

function WorldMap:CheckMapPressingDisplay()
	return self:GetPressingLevel() > 1
end

function WorldMap:UpdateClearFlag(arg_101_1)
	self.clearFlag = tobool(arg_101_1)
end

function WorldMap:IsUnlockFleetMode()
	if self.config.move_switch == 1 then
		return true
	elseif self.config.move_switch == 0 then
		return false
	else
		assert(false, "config error")
	end
end

function WorldMap:CheckFleetSalvage(arg_103_1)
	local var_103_0 = underscore.detect(self:GetFleets(), function(arg_104_0)
		local var_104_0 = arg_104_0:IsCatSalvage()

		if var_104_0 then
			var_104_0 = arg_103_1 or arg_104_0:IsSalvageFinish() or self.salvageAutoResult or arg_104_0.catSalvageFrom ~= self.id
		end

		return var_104_0
	end)

	if var_103_0 then
		return var_103_0.id
	else
		self.salvageAutoResult = false
	end
end

function WorldMap:GetChapterAuraBuffs()
	local var_105_0 = {}

	for iter_105_0, iter_105_1 in ipairs(self.fleets) do
		for iter_105_2, iter_105_3 in ipairs((iter_105_1:getMapAura())) do
			table.insert(var_105_0, iter_105_3)
		end
	end

	return var_105_0
end

function WorldMap:GetChapterAidBuffs()
	local var_106_0 = {}

	for iter_106_0, iter_106_1 in ipairs(self.fleets) do
		if iter_106_0 ~= self.findex then
			for iter_106_2, iter_106_3 in pairs((iter_106_1:getMapAid())) do
				var_106_0[iter_106_2] = iter_106_3
			end
		end
	end

	return var_106_0
end

function WorldMap:getFleetBattleBuffs(arg_107_1, arg_107_2)
	local var_107_0 = {}

	underscore.each(arg_107_1:GetBuffList(), function(arg_108_0)
		if arg_108_0.config.lua_id ~= 0 then
			table.insert(var_107_0, arg_108_0.config.lua_id)
		end
	end)

	local var_107_1 = {}

	if arg_107_2 and arg_107_1:IsCatSalvage() then
		-- block empty
	else
		var_107_1 = self:BuildBattleBuffList(arg_107_1)
	end

	return var_107_0, var_107_1
end

function WorldMap:BuildBattleBuffList(arg_109_1)
	local var_109_0 = {}
	local var_109_1, var_109_2 = self:triggerSkill(arg_109_1, FleetSkill.TypeBattleBuff)

	if var_109_1 and #var_109_1 > 0 then
		local var_109_3 = {}

		for iter_109_0, iter_109_1 in ipairs(var_109_1) do
			local var_109_4 = arg_109_1:findCommanderBySkillId(var_109_2[iter_109_0].id)

			var_109_3[var_109_4] = var_109_3[var_109_4] or {}

			table.insert(var_109_3[var_109_4], iter_109_1)
		end

		for iter_109_2, iter_109_3 in pairs(var_109_3) do
			table.insert(var_109_0, {
				iter_109_2,
				iter_109_3
			})
		end
	end

	for iter_109_4, iter_109_5 in pairs((arg_109_1:getCommanders())) do
		for iter_109_6, iter_109_7 in ipairs((iter_109_5:getTalents())) do
			local var_109_5 = iter_109_7:getBuffsAddition()

			if #var_109_5 > 0 then
				local var_109_6

				for iter_109_8, iter_109_9 in ipairs(var_109_0) do
					if iter_109_9[1] == iter_109_5 then
						var_109_6 = iter_109_9[2]

						break
					end
				end

				if not var_109_6 then
					var_109_6 = {}

					table.insert(var_109_0, {
						iter_109_5,
						var_109_6
					})
				end

				for iter_109_10, iter_109_11 in ipairs(var_109_5) do
					table.insert(var_109_6, iter_109_11)
				end
			end
		end
	end

	return var_109_0
end

function WorldMap:CanLongMove(arg_110_1)
	return self:IsUnlockFleetMode() and not arg_110_1:HasTrapBuff() and self:GetFleetTerrain(arg_110_1) ~= WorldMapCell.TerrainFog
end

function WorldMap:triggerSkill(arg_111_1, arg_111_2)
	local var_111_0 = _.filter(arg_111_1:findSkills(arg_111_2), function(arg_112_0)
		return _.any(arg_112_0:GetTriggers(), function(arg_113_0)
			return arg_113_0[1] == FleetSkill.TriggerInSubTeam and arg_113_0[2] == 1
		end) == (arg_111_1:GetFleetType() == FleetType.Submarine) and _.all(arg_112_0:GetTriggers(), function(arg_114_0)
			return self:triggerCheck(arg_111_1, arg_112_0, arg_114_0)
		end)
	end)

	return _.reduce(var_111_0, nil, function(arg_115_0, arg_115_1)
		local var_115_0 = arg_115_1:GetType()
		local var_115_1 = arg_115_1:GetArgs()

		if var_115_0 == FleetSkill.TypeMoveSpeed or var_115_0 == FleetSkill.TypeHuntingLv or var_115_0 == FleetSkill.TypeTorpedoPowerUp then
			return (arg_115_0 or 0) + var_115_1[1]
		elseif var_115_0 == FleetSkill.TypeAmbushDodge or var_115_0 == FleetSkill.TypeAirStrikeDodge then
			return math.max(arg_115_0 or 0, var_115_1[1])
		elseif var_115_0 == FleetSkill.TypeAttack or var_115_0 == FleetSkill.TypeStrategy then
			arg_115_0 = arg_115_0 or {}

			table.insert(arg_115_0, var_115_1)

			return arg_115_0
		elseif var_115_0 == FleetSkill.TypeBattleBuff then
			arg_115_0 = arg_115_0 or {}

			table.insert(arg_115_0, var_115_1[1])

			return arg_115_0
		end
	end), var_111_0
end

function WorldMap:triggerCheck(arg_116_1, arg_116_2, arg_116_3)
	if arg_116_3[1] == FleetSkill.TriggerDDHead then
		local var_116_0 = arg_116_1:GetTeamShipVOs(TeamType.Vanguard, false)

		return #var_116_0 > 0 and ShipType.IsTypeQuZhu(var_116_0[1]:getShipType())
	elseif arg_116_3[1] == FleetSkill.TriggerVanCount then
		local var_116_1 = arg_116_1:GetTeamShipVOs(TeamType.Vanguard, false)

		return #var_116_1 >= arg_116_3[2] and #var_116_1 <= arg_116_3[3]
	elseif arg_116_3[1] == FleetSkill.TriggerShipCount then
		local var_116_2 = _.filter(arg_116_1:GetShipVOs(false), function(arg_117_0)
			return table.contains(arg_116_3[2], arg_117_0:getShipType())
		end)

		return #var_116_2 >= arg_116_3[3] and #var_116_2 <= arg_116_3[4]
	elseif arg_116_3[1] == FleetSkill.TriggerAroundEnemy then
		local var_116_3 = {
			row = arg_116_1.row,
			column = arg_116_1.column
		}
		local var_116_4 = {}

		for iter_116_0 = -arg_116_3[2], arg_116_3[2] do
			local var_116_5 = arg_116_3[2] - math.abs(iter_116_0)

			for iter_116_1 = -var_116_5, var_116_5 do
				table.insert(var_116_4, (self:GetCell(var_116_3.row + iter_116_0, var_116_3.column + iter_116_1)))
			end
		end

		return underscore.any(var_116_4, function(arg_118_0)
			local var_118_0 = arg_118_0:ExistEnemy() and arg_118_0:GetStageEnemy().config.type or nil

			return type(arg_116_3[3]) == "number" and arg_116_3[3] == var_118_0 or type(arg_116_3[3]) == "table" and table.contains(arg_116_3[3], var_118_0)
		end)
	elseif arg_116_3[1] == FleetSkill.TriggerNekoPos then
		local var_116_6 = arg_116_1:findCommanderBySkillId(arg_116_2.id)

		for iter_116_2, iter_116_3 in pairs(arg_116_1:getCommanders()) do
			if var_116_6.id == iter_116_3.id and iter_116_2 == arg_116_3[2] then
				return true
			end
		end
	elseif arg_116_3[1] == FleetSkill.TriggerAroundLand then
		local var_116_7 = {
			row = arg_116_1.row,
			column = arg_116_1.column
		}

		for iter_116_4 = -arg_116_3[2], arg_116_3[2] do
			local var_116_8 = arg_116_3[2] - math.abs(iter_116_4)

			for iter_116_5 = -var_116_8, var_116_8 do
				if self:GetCell(var_116_7.row + iter_116_4, var_116_7.column + iter_116_5) and not self:IsWalkable(var_116_7.row + iter_116_4, var_116_7.column + iter_116_5) then
					return true
				end
			end
		end

		return false
	elseif arg_116_3[1] == FleetSkill.TriggerAroundCombatAlly then
		local var_116_9 = {
			row = arg_116_1.row,
			column = arg_116_1.column
		}

		return _.any(self.fleets, function(arg_119_0)
			local var_119_0

			if arg_116_1.id ~= arg_119_0.id and arg_119_0:GetFleetType() == FleetType.Normal then
				var_119_0 = self:GetCell(arg_119_0.line.row, arg_119_0.line.column):ExistEnemy()

				if var_119_0 then
					var_119_0 = ManhattonDist(var_116_9, {
						row = arg_119_0.line.row,
						column = arg_119_0.line.column
					}) <= arg_116_3[2]
				end
			end

			return var_119_0
		end)
	elseif arg_116_3[1] == FleetSkill.TriggerInSubTeam then
		return true
	else
		assert(false, "invalid trigger type: " .. arg_116_3[1])
	end
end

function WorldMap:OnUpdateAttachmentExist(arg_120_1, arg_120_2, arg_120_3)
	self.typeAttachments[arg_120_3.type] = self.typeAttachments[arg_120_3.type] or {}

	if arg_120_1 == WorldMapCell.EventAddAttachment then
		table.insert(self.typeAttachments[arg_120_3.type], arg_120_3)
	elseif arg_120_1 == WorldMapCell.EventRemoveAttachment then
		table.removebyvalue(self.typeAttachments[arg_120_3.type], arg_120_3)
	end

	local var_120_0 = arg_120_3:GetVisionRadius()

	if var_120_0 > 0 then
		local var_120_1 = 0

		if arg_120_1 == WorldMapCell.EventAddAttachment then
			var_120_1 = var_120_1 + 1
		elseif arg_120_1 == WorldMapCell.EventRemoveAttachment then
			var_120_1 = var_120_1 - 1
		else
			assert(false, "listener event error: " .. arg_120_1)
		end

		self.centerCellFOV = {
			row = arg_120_2.row,
			column = arg_120_2.column
		}

		for iter_120_0 = arg_120_2.row - var_120_0, arg_120_2.row + var_120_0 do
			for iter_120_1 = arg_120_2.column - var_120_0, arg_120_2.column + var_120_0 do
				local var_120_2 = self:GetCell(iter_120_0, iter_120_1)

				if var_120_2 and WorldConst.InFOVRange(arg_120_2.row, arg_120_2.column, var_120_2.row, var_120_2.column, var_120_0) then
					var_120_2:ChangeInLight(var_120_1 > 0)
				end
			end
		end
	end

	local var_120_3 = arg_120_3:GetRadiationBuffs()

	if #var_120_3 > 0 then
		local var_120_4 = {}

		for iter_120_2, iter_120_3 in ipairs(var_120_3) do
			local var_120_5, var_120_6, var_120_7 = unpack(iter_120_3)

			if arg_120_1 == WorldMapCell.EventAddAttachment then
				var_120_4[var_120_5] = true

				self:AddBuff(var_120_5, var_120_6, var_120_7)
			elseif arg_120_1 == WorldMapCell.EventRemoveAttachment then
				var_120_4[var_120_5] = true

				self:RemoveBuff(var_120_5, var_120_6, var_120_7)
			end
		end

		for iter_120_4, iter_120_5 in pairs(var_120_4) do
			if iter_120_5 then
				self:FlushFaction(iter_120_4)
			end
		end
	end
end

function WorldMap:GetBGM()
	return self.config.bgm
end

function WorldMap:NeedClear()
	local var_122_0, var_122_1 = self:GetEventPoisonRate()

	return (var_122_1 <= 0 or var_122_0 ~= 0 or nil) and (self.clearFlag or self.config.is_clear > 0)
end

function WorldMap:GetBuff(arg_123_1, arg_123_2)
	if not self.factionBuffs[arg_123_1][arg_123_2] then
		self.factionBuffs[arg_123_1][arg_123_2] = WorldBuff.New()

		self.factionBuffs[arg_123_1][arg_123_2]:Setup({
			floor = 0,
			id = arg_123_2
		})
	end

	return self.factionBuffs[arg_123_1][arg_123_2]
end

function WorldMap:AddBuff(arg_124_1, arg_124_2, arg_124_3)
	self:GetBuff(arg_124_1, arg_124_2):AddFloor(arg_124_3)
end

function WorldMap:RemoveBuff(arg_125_1, arg_125_2, arg_125_3)
	if arg_125_3 then
		self:GetBuff(arg_125_1, arg_125_2):AddFloor(arg_125_3 * -1)
	else
		self.factionBuffs[arg_125_1][arg_125_2] = nil
	end
end

function WorldMap:GetBuffList(arg_126_1, arg_126_2)
	if arg_126_1 == WorldMap.FactionSelf then
		return underscore.filter(underscore.values(self.factionBuffs[arg_126_1]), function(arg_127_0)
			return arg_127_0:GetFloor() > 0
		end)
	elseif arg_126_1 == WorldMap.FactionEnemy then
		if WorldMapAttachment.IsEnemyType(arg_126_2.type) or arg_126_2.type == WorldMapAttachment.TypeEvent and arg_126_2:GetSpEventType() == WorldMapAttachment.SpEventEnemy then
			return underscore.filter(underscore.values(self.factionBuffs[arg_126_1]), function(arg_128_0)
				return arg_128_0:GetFloor() > 0
			end)
		else
			return {}
		end
	else
		assert(false, string.format("faction error: $d", arg_126_1))
	end
end

function WorldMap:FlushFaction(arg_129_1)
	if arg_129_1 == WorldMap.FactionSelf then
		underscore.each(self:GetFleets(), function(arg_130_0)
			arg_130_0:DispatchEvent(WorldMapFleet.EventUpdateBuff)
		end)
	elseif arg_129_1 == WorldMap.FactionEnemy then
		local var_129_0 = {}

		underscore.each(self:FindEnemys(), function(arg_131_0)
			var_129_0[WorldMapCell.GetName(arg_131_0.row, arg_131_0.column)] = true
		end)
		underscore.each(self:FindAttachments(WorldMapAttachment.TypeEvent), function(arg_132_0)
			if arg_132_0:GetSpEventType() == WorldMapAttachment.SpEventEnemy then
				var_129_0[WorldMapCell.GetName(arg_132_0.row, arg_132_0.column)] = true
			end
		end)

		for iter_129_0 in pairs(var_129_0) do
			self.cells[iter_129_0]:DispatchEvent(WorldMap.EventUpdateMapBuff)
		end
	else
		assert(false, string.format("faction error: $d", arg_129_1))
	end
end

function WorldMap:GetBattleLuaBuffs(arg_133_1, arg_133_2)
	local var_133_0 = {}

	underscore.each(self:GetBuffList(arg_133_1, arg_133_2), function(arg_134_0)
		if arg_134_0.config.lua_id > 0 then
			table.insert(var_133_0, arg_134_0.config.lua_id)
		end
	end)

	return var_133_0
end

function WorldMap:UpdateFleetLocation(arg_135_1, arg_135_2, arg_135_3)
	local var_135_0 = self:GetFleet(arg_135_1)

	assert(var_135_0, "without this fleet : " .. arg_135_1)

	if var_135_0.row ~= arg_135_2 or var_135_0.column ~= arg_135_3 then
		self:CheckFleetUpdateFOV(var_135_0, function()
			var_135_0.row = arg_135_2
			var_135_0.column = arg_135_3
		end)
		var_135_0:DispatchEvent(WorldMapFleet.EventUpdateLocation)
	end
end

function WorldMap:GetRangeDic(arg_137_1)
	local var_137_0 = {}

	WorldConst.RangeCheck(arg_137_1, self:GetFOVRange(arg_137_1), function(arg_138_0, arg_138_1)
		local var_138_0 = WorldMapCell.GetName(arg_138_0, arg_138_1)

		if self.cells[var_138_0] then
			var_137_0[var_138_0] = defaultValue(var_137_0[var_138_0], 0) + 1
		end
	end)

	return var_137_0
end

function WorldMap:CheckFleetUpdateFOV(arg_139_1, arg_139_2)
	if not self:IsValid() then
		arg_139_2()

		return
	end

	local var_139_0 = self:GetRangeDic(arg_139_1)
	local var_139_1 = self:GetFleetTerrain(arg_139_1) == WorldMapCell.TerrainFog
	local var_139_2 = self:IsFleetTerrainSairenFog(arg_139_1)
	local var_139_3 = self:CalcFleetSpeed(arg_139_1)

	arg_139_2()

	local var_139_4 = self:GetRangeDic(arg_139_1)
	local var_139_5 = self:GetFleetTerrain(arg_139_1) == WorldMapCell.TerrainFog
	local var_139_6 = self:IsFleetTerrainSairenFog(arg_139_1)
	local var_139_7 = self:CalcFleetSpeed(arg_139_1)

	self.centerCellFOV = {
		row = arg_139_1.row,
		column = arg_139_1.column
	}

	local var_139_8 = false
	local var_139_9 = false
	local var_139_10 = {}

	if not var_139_1 then
		for iter_139_0, iter_139_1 in pairs(var_139_0) do
			var_139_10[iter_139_0] = defaultValue(var_139_10[iter_139_0], 0) - iter_139_1
		end
	end

	if not var_139_5 then
		for iter_139_2, iter_139_3 in pairs(var_139_4) do
			var_139_10[iter_139_2] = defaultValue(var_139_10[iter_139_2], 0) + iter_139_3
		end
	end

	for iter_139_4, iter_139_5 in pairs(var_139_10) do
		if iter_139_5 ~= 0 then
			self.cells[iter_139_4]:ChangeInLight(iter_139_5 > 0)

			var_139_8 = true
		end
	end

	if self:GetFleet() == arg_139_1 then
		local var_139_11 = {}

		if var_139_1 then
			for iter_139_6, iter_139_7 in pairs(var_139_0) do
				var_139_11[iter_139_6] = defaultValue(var_139_11[iter_139_6], 0) - iter_139_7
			end
		end

		if var_139_5 then
			for iter_139_8, iter_139_9 in pairs(var_139_4) do
				var_139_11[iter_139_8] = defaultValue(var_139_11[iter_139_8], 0) + iter_139_9
			end
		end

		if var_139_1 ~= var_139_5 or var_139_2 ~= var_139_6 then
			for iter_139_10, iter_139_11 in pairs(self.cells) do
				iter_139_11:UpdateFog(var_139_5, (var_139_11[iter_139_10] and var_139_11[iter_139_10] ~= 0 or nil) and var_139_11[iter_139_10] > 0, var_139_6)
			end

			var_139_8 = true
		else
			for iter_139_12, iter_139_13 in pairs(var_139_11) do
				if iter_139_13 ~= 0 then
					self.cells[iter_139_12]:UpdateFog(nil, iter_139_13 > 0, nil)

					var_139_8 = true
				end
			end
		end

		if var_139_3 ~= var_139_7 then
			var_139_9 = true
		end
	end

	if var_139_8 then
		self:DispatchEvent(WorldMap.EventUpdateFleetFOV)
	end

	if var_139_9 then
		self:DispatchEvent(WorldMap.EventUpdateMoveSpeed)
	end
end

function WorldMap:CheckSelectFleetUpdateFog(arg_140_1)
	if not self:IsValid() then
		arg_140_1()

		return
	end

	local var_140_0 = self:GetFleet()
	local var_140_1 = self:GetRangeDic(var_140_0)
	local var_140_2 = self:GetFleetTerrain(var_140_0) == WorldMapCell.TerrainFog
	local var_140_3 = self:IsFleetTerrainSairenFog(var_140_0)

	arg_140_1()

	local var_140_4 = self:GetFleet()
	local var_140_5 = self:GetRangeDic(var_140_4)
	local var_140_6 = self:GetFleetTerrain(var_140_4) == WorldMapCell.TerrainFog
	local var_140_7 = self:IsFleetTerrainSairenFog(var_140_4)

	self.centerCellFOV = {
		row = var_140_4.row,
		column = var_140_4.column
	}

	local var_140_8 = {}

	if var_140_2 then
		for iter_140_0, iter_140_1 in pairs(var_140_1) do
			var_140_8[iter_140_0] = defaultValue(var_140_8[iter_140_0], 0) - iter_140_1
		end
	end

	if var_140_6 then
		for iter_140_2, iter_140_3 in pairs(var_140_5) do
			var_140_8[iter_140_2] = defaultValue(var_140_8[iter_140_2], 0) + iter_140_3
		end
	end

	if var_140_2 ~= var_140_6 or var_140_3 ~= var_140_7 then
		for iter_140_4, iter_140_5 in pairs(self.cells) do
			iter_140_5:UpdateFog(var_140_6, (var_140_8[iter_140_4] and var_140_8[iter_140_4] ~= 0 or nil) and var_140_8[iter_140_4] > 0, var_140_7)
		end
	else
		for iter_140_6, iter_140_7 in pairs(var_140_8) do
			if iter_140_7 ~= 0 then
				self.cells[iter_140_6]:UpdateFog(nil, iter_140_7 > 0, nil)
			end
		end
	end

	self:DispatchEvent(WorldMap.EventUpdateFleetFOV)
end

function WorldMap:CheckEventAutoTrigger(arg_141_1)
	if arg_141_1:GetSpEventType() == WorldMapAttachment.SpEventConsumeItem then
		return getProxy(SettingsProxy):GetWorldFlag("consume_item")
	end

	local var_141_0 = arg_141_1:GetEventEffect()

	if var_141_0 then
		local var_141_1 = self:GetFleet()

		if var_141_0.effect_type == WorldMapAttachment.EffectEventConsumeCarry then
			return not underscore.any(var_141_0.effect_paramater[1] or {}, function(arg_142_0)
				return not var_141_1:ExistCarry(arg_142_0)
			end)
		elseif var_141_0.effect_type == WorldMapAttachment.EffectEventCatSalvage then
			return var_141_1:GetDisplayCommander() and not var_141_1:IsCatSalvage()
		end
	end

	return true
end

function WorldMap:CanAutoFight()
	if self.config.is_auto > 0 then
		for iter_143_0 = 1, self.config.is_auto do
			if not nowWorld():IsSystemOpen(WorldConst["SystemAutoFight_" .. iter_143_0]) then
				return false
			end
		end

		return true
	else
		return false
	end
end

function WorldMap:CkeckTransport()
	assert(self:IsValid(), "without map info")

	if self.config.is_transfer == 0 then
		return false, i18n("world_transport_disable")
	end

	if self:CheckAttachmentTransport() == "block" then
		return false, i18n("world_movelimit_event_text")
	end

	if nowWorld():CheckTaskLockMap() then
		return false, i18n("world_task_maplock")
	end

	return true
end

return WorldMap
