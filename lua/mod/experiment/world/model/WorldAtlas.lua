local WorldAtlas = class("WorldAtlas", import("...BaseEntity"))

WorldAtlas.Fields = {
	config = "table",
	sairenEntranceList = "table",
	entranceDic = "table",
	replaceDic = "table",
	costMapDic = "table",
	mapDic = "table",
	areaEntranceList = "table",
	achEntranceList = "table",
	pressingMapList = "table",
	markPortDic = "table",
	portEntranceList = "table",
	activeMapId = "number",
	nShopGoodsDic = "table",
	taskMarkDic = "table",
	pressingUnlcokCount = "number",
	world = "table",
	transportDic = "table",
	treasureMarkDic = "table",
	id = "number",
	activeEntranceId = "number",
	delegatedMapDic = "table",
	mapEntrance = "table"
}
WorldAtlas.EventUpdateProgress = "WorldAtlas.EventUpdateProgress"
WorldAtlas.EventUpdateActiveEntrance = "WorldAtlas.EventUpdateActiveEntrance"
WorldAtlas.EventUpdateActiveMap = "WorldAtlas.EventUpdateActiveMap"
WorldAtlas.EventAddPressingMap = "WorldAtlas.EventAddPressingMap"
WorldAtlas.EventAddPressingEntrance = "WorldAtlas.EventAddPressingEntrance"
WorldAtlas.EventUpdatePortMark = "WorldAtlas.EventUpdatePortMark"
WorldAtlas.EventUpdateNGoodsCount = "WorldAtlas.EventUpdateNGoodsCount"
WorldAtlas.ScaleShrink = 1
WorldAtlas.ScaleFull = 2
WorldAtlas.ScaleExpand = 3
WorldAtlas.ScaleHalf = 4
WorldAtlas.Scales = {
	WorldAtlas.ScaleShrink,
	WorldAtlas.ScaleHalf,
	WorldAtlas.ScaleFull
}

function WorldAtlas:Ctor(arg_1_1)
	WorldAtlas.super.Ctor(self)

	self.id = arg_1_1

	assert(pg.world_expedition_data_by_map[self.id], "world_expedition_data_by_map missing: " .. self.id)

	self.config = pg.world_expedition_data_by_map[self.id]

	self:BuildEntranceDic()
end

function WorldAtlas:Build()
	self.entranceDic = {}
	self.mapDic = {}
	self.taskMarkDic = {}
	self.treasureMarkDic = {}
	self.sairenEntranceList = {}
	self.costMapDic = {}
	self.delegatedMapDic = {}
	self.pressingMapList = {}
	self.transportDic = {}
	self.markPortDic = {}
end

function WorldAtlas:Dispose()
	WPool:ReturnMap(self.entranceDic)
	WPool:ReturnMap(self.mapDic)
	self:Clear()
end

function WorldAtlas:NewEntrance(arg_4_1)
	local var_4_0 = WPool:Get(WorldEntrance)

	var_4_0:Setup(arg_4_1, self)

	self.entranceDic[arg_4_1] = var_4_0

	return var_4_0
end

function WorldAtlas:NewMap(arg_5_1)
	local var_5_0 = WPool:Get(WorldMap)

	var_5_0:Setup(arg_5_1)

	self.mapDic[arg_5_1] = var_5_0

	return var_5_0
end

function WorldAtlas:BuildEntranceDic()
	local var_6_0 = {
		{
			name = "step",
			field = "stage_chapter"
		},
		{
			name = "task",
			field = "task_chapter"
		},
		{
			name = "treasure",
			field = "teasure_chapter"
		}
	}

	self.mapEntrance = {}
	self.areaEntranceList = {}
	self.portEntranceList = {}
	self.achEntranceList = {}
	self.replaceDic = {
		step = {},
		task = {},
		treasure = {},
		open = {
			{},
			{}
		}
	}

	_.each(pg.world_chapter_colormask.all, function(arg_7_0)
		local var_7_0 = pg.world_chapter_colormask[arg_7_0]

		if pg.world_chapter_colormask[arg_7_0].world ~= self.id then
			return
		end

		local var_7_1 = self:NewEntrance(arg_7_0)
		local var_7_2 = var_7_1:GetAreaId()

		self.areaEntranceList[var_7_2] = self.areaEntranceList[var_7_2] or {}

		table.insert(self.areaEntranceList[var_7_2], arg_7_0)

		if var_7_1:HasPort() then
			local var_7_3 = var_7_1:GetPortId()

			self.portEntranceList[var_7_3] = self.portEntranceList[var_7_3] or {}

			table.insert(self.portEntranceList[var_7_3], arg_7_0)
		end

		for iter_7_0, iter_7_1 in ipairs(var_6_0) do
			for iter_7_2, iter_7_3 in ipairs(var_7_1.config[iter_7_1.field]) do
				if iter_7_1.name == "step" then
					for iter_7_4 = iter_7_3[1], iter_7_3[2] do
						self.replaceDic[iter_7_1.name][iter_7_4] = self.replaceDic[iter_7_1.name][iter_7_4] or {}
						self.replaceDic[iter_7_1.name][iter_7_4][arg_7_0] = var_7_1
					end
				else
					self.replaceDic[iter_7_1.name][iter_7_3[1]] = self.replaceDic[iter_7_1.name][iter_7_3[1]] or {}
					self.replaceDic[iter_7_1.name][iter_7_3[1]][arg_7_0] = var_7_1
				end
			end
		end

		local var_7_5

		if #var_7_1.config.normal_target > 0 or #var_7_1.config.cryptic_target > 0 then
			table.insert(self.achEntranceList, var_7_1)

			var_7_5 = self:NewMap(var_7_0.chapter)
		end

		self.mapEntrance[var_7_0.chapter] = var_7_1
		self.replaceDic.open[1][var_7_5.config.open_stage[1]] = self.replaceDic.open[1][var_7_5.config.open_stage[1]] or {}
		self.replaceDic.open[1][var_7_5.config.open_stage[1]][arg_7_0] = 1
		self.replaceDic.open[2][var_7_5.config.open_stage[2]] = self.replaceDic.open[2][var_7_5.config.open_stage[2]] or {}
		self.replaceDic.open[2][var_7_5.config.open_stage[2]][arg_7_0] = 1
	end)
end

function WorldAtlas:GetEntrance(arg_8_1)
	return self.entranceDic[arg_8_1]
end

function WorldAtlas:SetActiveEntrance(arg_9_1)
	if self.activeEntranceId ~= arg_9_1.id then
		self.activeEntranceId = arg_9_1.id

		self:DispatchEvent(WorldAtlas.EventUpdateActiveEntrance, arg_9_1)
	end
end

function WorldAtlas:GetActiveEntrance()
	return self.activeEntranceId and self:GetEntrance(self.activeEntranceId)
end

function WorldAtlas:GetMap(arg_11_1)
	if not self.mapDic[arg_11_1] then
		self:NewMap(arg_11_1)
	end

	return self.mapDic[arg_11_1]
end

function WorldAtlas:SetActiveMap(arg_12_1)
	if self.activeMapId ~= arg_12_1.id then
		self.activeMapId = arg_12_1.id

		self:DispatchEvent(WorldAtlas.EventUpdateActiveMap, arg_12_1)
	end
end

function WorldAtlas:GetActiveMap()
	return self.activeMapId and self:GetMap(self.activeMapId)
end

function WorldAtlas:GetDiscoverRate()
	return 0
end

function WorldAtlas:CheckMapActive(arg_15_1)
	local var_15_0 = self:GetMap(arg_15_1)

	assert(var_15_0, "map not exist: " .. arg_15_1)

	return var_15_0.active or _.any(_.values(self:GetPartMaps(arg_15_1)), function(arg_16_0)
		return arg_16_0.active
	end)
end

function WorldAtlas:GetAtlasPixelSize()
	return Vector2(self.config.size[1], self.config.size[2])
end

function WorldAtlas:GetAchEntranceList()
	return self.achEntranceList
end

function WorldAtlas:GetOpenEntranceDic(arg_19_1)
	return self.replaceDic.open[nowWorld():GetRealm()][arg_19_1] or {}
end

function WorldAtlas:GetStepDic(arg_20_1)
	return self.replaceDic.step[arg_20_1] or {}
end

function WorldAtlas:GetTaskDic(arg_21_1)
	return self.replaceDic.task[arg_21_1] or {}
end

function WorldAtlas:GetTreasureDic(arg_22_1)
	return self.replaceDic.treasure[arg_22_1] or {}
end

function WorldAtlas:UpdateProgress(arg_23_1, arg_23_2)
	local var_23_0 = {}

	for iter_23_0 = arg_23_1 + 1, arg_23_2 do
		for iter_23_1 in pairs(self:GetOpenEntranceDic(iter_23_0)) do
			var_23_0[iter_23_1] = 1
		end
	end

	self:DispatchEvent(WorldAtlas.EventUpdateProgress, var_23_0)

	local var_23_1 = {}

	for iter_23_2 in pairs(self:GetStepDic(arg_23_2)) do
		var_23_1[iter_23_2] = 1
	end

	for iter_23_3 in pairs(self:GetStepDic(arg_23_1)) do
		var_23_1[iter_23_3] = (var_23_1[iter_23_3] or 0) - 1
	end

	for iter_23_4, iter_23_5 in pairs(var_23_1) do
		if iter_23_5 ~= 0 then
			self.entranceDic[iter_23_4]:UpdateDisplayMarks("step", iter_23_5 > 0)
		end
	end
end

function WorldAtlas:UpdateTask(arg_24_1)
	local var_24_0 = arg_24_1:isAlive()
	local var_24_1 = (var_24_0 and 1 or 0) - (self.taskMarkDic[arg_24_1.id] and 1 or 0)

	self.taskMarkDic[arg_24_1.id] = var_24_0

	if var_24_1 == 0 then
		return
	end

	local var_24_2 = false

	for iter_24_0 in pairs(self:GetTaskDic(arg_24_1.id)) do
		var_24_2 = true

		if arg_24_1.config.type == 0 then
			self.entranceDic[iter_24_0]:UpdateDisplayMarks("task_main", var_24_1 > 0)
		elseif arg_24_1.config.type == 6 then
			self.entranceDic[iter_24_0]:UpdateDisplayMarks("task_collecktion", var_24_1 > 0)
		else
			self.entranceDic[iter_24_0]:UpdateDisplayMarks("task", var_24_1 > 0)
		end
	end

	local var_24_3 = arg_24_1:GetFollowingEntrance()

	if var_24_3 and not var_24_2 then
		if arg_24_1.config.type == 0 then
			self.entranceDic[var_24_3]:UpdateDisplayMarks("task_following_main", var_24_1 > 0)
		elseif arg_24_1.config.type == 7 then
			self.entranceDic[var_24_3]:UpdateDisplayMarks("task_following_boss", var_24_1 > 0)
		else
			self.entranceDic[var_24_3]:UpdateDisplayMarks("task_following", var_24_1 > 0)
		end
	end
end

function WorldAtlas:UpdateTreasure(arg_25_1)
	local var_25_0 = nowWorld()
	local var_25_1 = var_25_0:GetInventoryProxy():GetItemCount(arg_25_1)
	local var_25_2 = (var_25_1 > 0 and 1 or 0) - (self.treasureMarkDic[arg_25_1] and 1 or 0)

	self.treasureMarkDic[arg_25_1] = var_25_1 > 0

	if var_25_2 ~= 0 then
		local var_25_3 = var_25_0:FindTreasureEntrance(arg_25_1)

		if pg.world_item_data_template[arg_25_1].usage_arg[1] == 1 then
			var_25_3:UpdateDisplayMarks("treasure_sairen", var_25_2 > 0)
		else
			var_25_3:UpdateDisplayMarks("treasure", var_25_2 > 0)
		end
	end
end

function WorldAtlas:SetDelegatedMarkList(arg_26_1)
	for iter_26_0, iter_26_1 in pairs(self.delegatedMapDic) do
		self:GetMap(iter_26_0):UpdateDeteagtedMark(false)
	end

	self.delegatedMapDic = {}

	for iter_26_2, iter_26_3 in ipairs(arg_26_1) do
		self.delegatedMapDic[iter_26_3] = true

		self:GetMap(iter_26_3):UpdateDeteagtedMark(true)
	end
end

function WorldAtlas:SetPressingMarkList(arg_27_1)
	_.each(self.pressingMapList, function(arg_28_0)
		self:GetMap(arg_28_0):UpdatePressingMark(false)
	end)

	local var_27_0 = 0

	self.pressingMapList = arg_27_1

	_.each(self.pressingMapList, function(arg_29_0)
		self:GetMap(arg_29_0):UpdatePressingMark(true)

		if self.mapEntrance[arg_29_0] and not self.mapEntrance[arg_29_0]:HasPort() then
			var_27_0 = var_27_0 + 1
		end
	end)

	self.pressingUnlcokCount = 0

	self:BuildTransportDic()
end

function WorldAtlas:BuildTransportDic()
	self.transportDic = {}

	for iter_30_0, iter_30_1 in pairs(self.entranceDic) do
		if iter_30_1:IsPressing() then
			self.transportDic[iter_30_0] = true

			for iter_30_2 in pairs(iter_30_1.transportDic) do
				self.transportDic[iter_30_2] = true
			end
		end
	end

	if nowWorld():IsReseted() then
		self:AddPortTransportDic()
	end
end

function WorldAtlas:AddPortTransportDic()
	for iter_31_0, iter_31_1 in pairs(self.portEntranceList) do
		for iter_31_2, iter_31_3 in ipairs(iter_31_1) do
			self.transportDic[iter_31_3] = true
		end
	end
end

function WorldAtlas:MarkMapTransport(arg_32_1)
	if self.mapEntrance[arg_32_1] then
		self.transportDic[self.mapEntrance[arg_32_1].id] = true
	end
end

function WorldAtlas:AddDelegatedMap(arg_33_1)
	assert(not self.delegatedMapDic[arg_33_1], "already delegated map: " .. arg_33_1)

	self.delegatedMapDic[arg_33_1] = true
	self.costMapDic[arg_33_1] = true

	local var_33_0 = self:GetMap(arg_33_1)

	var_33_0:UpdateDeteagtedMark(true)

	var_33_0.isCost = true

	self:AddPressingMap(arg_33_1)
end

function WorldAtlas:AddPressingMap(arg_34_1)
	if _.any(self.pressingMapList, function(arg_35_0)
		return arg_35_0 == arg_34_1
	end) then
		return
	else
		self:GetMap(arg_34_1):UpdatePressingMark(true)
		table.insert(self.pressingMapList, arg_34_1)

		if self.mapEntrance[arg_34_1] then
			local var_34_0 = {}

			self.transportDic[self.mapEntrance[arg_34_1].id] = true
			var_34_0[self.mapEntrance[arg_34_1].id] = true

			for iter_34_0 in pairs(self.mapEntrance[arg_34_1].transportDic) do
				if not self.transportDic[iter_34_0] then
					self.transportDic[iter_34_0] = true
					var_34_0[iter_34_0] = true
				end
			end

			self:DispatchEvent(WorldAtlas.EventAddPressingEntrance, var_34_0)

			if not self.mapEntrance[arg_34_1]:HasPort() then
				self.pressingUnlcokCount = self.pressingUnlcokCount + 1

				self:UpdateUnlockCountPortMark()
			end
		end

		self:DispatchEvent(WorldAtlas.EventAddPressingMap, arg_34_1)
	end
end

function WorldAtlas:GetPressingUnlockCount()
	return self.pressingUnlcokCount
end

function WorldAtlas:GetPressingUnlockRecordCount(arg_37_1)
	return PlayerPrefs.GetInt(string.format("world_new_shop_unlock_count_in_port_%d_%d_%d", getProxy(PlayerProxy):getRawData().id, nowWorld().activateCount, arg_37_1), -1)
end

function WorldAtlas:SetPressingUnlockRecordCount(arg_38_1, arg_38_2)
	return PlayerPrefs.SetInt(string.format("world_new_shop_unlock_count_in_port_%d_%d_%d", getProxy(PlayerProxy):getRawData().id, nowWorld().activateCount, arg_38_1), arg_38_2)
end

function WorldAtlas:SetSairenEntranceList(arg_39_1)
	_.each(self.sairenEntranceList, function(arg_40_0)
		local var_40_0 = self:GetEntrance(arg_40_0)

		var_40_0:UpdateSairenMark(false)
		var_40_0:UpdateDisplayMarks("sairen", false)
	end)

	self.sairenEntranceList = arg_39_1

	_.each(self.sairenEntranceList, function(arg_41_0)
		local var_41_0 = self:GetEntrance(arg_41_0)

		var_41_0:UpdateSairenMark(true)
		var_41_0:UpdateDisplayMarks("sairen", true)
	end)
end

function WorldAtlas:RemoveSairenEntrance(arg_42_1)
	local var_42_0 = table.indexof(self.sairenEntranceList, arg_42_1.id)

	if var_42_0 then
		table.remove(self.sairenEntranceList, var_42_0)
		arg_42_1:UpdateSairenMark(false)
		arg_42_1:UpdateDisplayMarks("sairen", false)
	end
end

function WorldAtlas:SetCostMapList(arg_43_1)
	for iter_43_0, iter_43_1 in pairs(self.costMapDic) do
		self:GetMap(iter_43_0).isCost = false
	end

	self.costMapDic = {}

	_.each(arg_43_1, function(arg_44_0)
		self.costMapDic[arg_44_0.random_id] = true
		self:GetMap(arg_44_0.random_id).isCost = true
	end)
end

function WorldAtlas:UpdateCostMap(arg_45_1, arg_45_2)
	if not self.costMapDic[arg_45_1] and arg_45_2 then
		nowWorld():ClearAllFleetDefeatEnemies()
	end

	self.costMapDic[arg_45_1] = arg_45_2
end

function WorldAtlas:SetPortMarkList(arg_46_1, arg_46_2)
	self.markPortDic.goods = {}

	for iter_46_0, iter_46_1 in ipairs(arg_46_1) do
		self.markPortDic.goods[iter_46_1] = true
	end

	self.markPortDic.new = {}

	for iter_46_2, iter_46_3 in ipairs(arg_46_2) do
		self.markPortDic.new[iter_46_3] = true
	end
end

function WorldAtlas:UpdatePortMark(arg_47_1, arg_47_2, arg_47_3)
	if not self.portEntranceList[arg_47_1] then
		return
	end

	local var_47_0

	if arg_47_2 ~= nil and tobool(self.markPortDic.goods[arg_47_1]) ~= arg_47_2 then
		self.markPortDic.goods[arg_47_1] = arg_47_2
		var_47_0 = var_47_0 or {}

		for iter_47_0, iter_47_1 in ipairs(self.portEntranceList[arg_47_1]) do
			var_47_0[iter_47_1] = true
		end
	end

	if arg_47_3 ~= nil and tobool(self.markPortDic.new[arg_47_1]) ~= arg_47_3 then
		self.markPortDic.new[arg_47_1] = arg_47_3
		var_47_0 = var_47_0 or {}

		for iter_47_2, iter_47_3 in ipairs(self.portEntranceList[arg_47_1]) do
			var_47_0[iter_47_3] = true
		end
	end

	if var_47_0 then
		if not nowWorld():UsePortNShop() then
			self:DispatchEvent(WorldAtlas.EventUpdatePortMark, var_47_0)
		end
	end
end

function WorldAtlas:InitPortMarkNShopList()
	local var_48_0 = self:GetPressingUnlockCount()

	self.markPortDic.newGoods = {}

	for iter_48_0, iter_48_1 in pairs(self.nShopGoodsDic) do
		local var_48_1 = Goods.Create({
			id = iter_48_0,
			count = iter_48_1
		}, Goods.TYPE_WORLD_NSHOP)
		local var_48_2 = var_48_1:getConfig("port_id")
		local var_48_3 = var_48_1:getConfig("unlock_num")

		if var_48_1:canPurchase() and self:GetPressingUnlockRecordCount(var_48_2) < var_48_3 and var_48_3 <= var_48_0 then
			self.markPortDic.newGoods[var_48_2] = true
		end
	end
end

function WorldAtlas:UpdateUnlockCountPortMark()
	if not nowWorld():UsePortNShop() then
		return
	end

	local var_49_0 = self.markPortDic.newGoods

	self:InitPortMarkNShopList()

	for iter_49_0, iter_49_1 in ipairs(underscore.keys(self.portEntranceList)) do
		if tobool(var_49_0[iter_49_1]) ~= tobool(self.markPortDic.newGoods[iter_49_1]) then
			local var_49_1 = {}

			for iter_49_2, iter_49_3 in ipairs(self.portEntranceList[iter_49_1]) do
				var_49_1[iter_49_3] = true
			end
		end
	end

	if changeDic then
		self:DispatchEvent(WorldAtlas.EventUpdatePortMark, changeDic)
	end
end

function WorldAtlas:UpdatePortMarkNShop(arg_50_1, arg_50_2)
	if not self.portEntranceList[arg_50_1] then
		return
	end

	if tobool(self.markPortDic.newGoods[arg_50_1]) ~= arg_50_2 then
		self.markPortDic.newGoods[arg_50_1] = arg_50_2

		if nowWorld():UsePortNShop() then
			local var_50_0 = {}

			for iter_50_0, iter_50_1 in ipairs(self.portEntranceList[arg_50_1]) do
				var_50_0[iter_50_1] = true
			end

			self:DispatchEvent(WorldAtlas.EventUpdatePortMark, var_50_0)
		end
	end
end

function WorldAtlas:GetAnyPortMarkNShop()
	for iter_51_0, iter_51_1 in pairs(self.markPortDic.newGoods) do
		if iter_51_1 then
			return true
		end
	end

	return false
end

function WorldAtlas:InitWorldNShopGoods(arg_52_1)
	self.nShopGoodsDic = {}

	for iter_52_0, iter_52_1 in ipairs(pg.world_newshop_data.all) do
		self.nShopGoodsDic[iter_52_1] = 0
	end

	for iter_52_2, iter_52_3 in ipairs(arg_52_1) do
		assert(self.nShopGoodsDic[iter_52_3.goods_id], "without this good in id " .. iter_52_3.goods_id)

		self.nShopGoodsDic[iter_52_3.goods_id] = self.nShopGoodsDic[iter_52_3.goods_id] + iter_52_3.count
	end
end

function WorldAtlas:UpdateNShopGoodsCount(arg_53_1, arg_53_2)
	assert(self.nShopGoodsDic[arg_53_1], "without this goods:" .. arg_53_1)

	if arg_53_2 ~= 0 then
		self.nShopGoodsDic[arg_53_1] = self.nShopGoodsDic[arg_53_1] + arg_53_2

		self:DispatchEvent(WorldAtlas.EventUpdateNGoodsCount, arg_53_1, self.nShopGoodsDic[arg_53_1])
	end
end

function WorldAtlas:GetEntrancePortInfo(arg_54_1)
	local var_54_0 = self:GetEntrance(arg_54_1)
	local var_54_1 = var_54_0:GetPortId()

	if nowWorld():UsePortNShop() then
		return self.transportDic[var_54_0.id], self.markPortDic.newGoods[var_54_1], self.markPortDic.newGoods[var_54_1]
	else
		return self.transportDic[var_54_0.id], self.markPortDic.goods[var_54_1], self.markPortDic.new[var_54_1]
	end
end

return WorldAtlas
