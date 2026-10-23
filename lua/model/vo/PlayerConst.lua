local PlayerConst = class("PlayerConst")

PlayerConst.ResGold = 1
PlayerConst.ResOil = 2
PlayerConst.ResExploit = 3
PlayerConst.ResDiamond = 4
PlayerConst.ResOilField = 5
PlayerConst.ResDormMoney = 6
PlayerConst.ResGoldField = 7
PlayerConst.ResGuildCoin = 8
PlayerConst.ResBlueprintFragment = 9
PlayerConst.ResClassField = 10
PlayerConst.ResFreeDiamond = 14
PlayerConst.ResStoreGold = 16
PlayerConst.ResStoreOil = 17
PlayerConst.ResIslandGold = 18
PlayerConst.ResIslandGem = 19
PlayerConst.ResIslandSpeedUpTicket = 20
PlayerConst.ResBattery = 101
PlayerConst.ResPT = 102

local var_0_1

local function var_0_2(arg_1_0)
	var_0_1 = var_0_1 or {
		[DROP_TYPE_RESOURCE] = function(arg_2_0)
			local var_2_0 = getProxy(PlayerProxy)

			if var_2_0 then
				var_2_0:UpdatePlayerRes({
					arg_2_0
				})
			end
		end,
		[DROP_TYPE_ITEM] = function(arg_3_0)
			local var_3_0 = getProxy(BagProxy)

			if var_3_0 then
				if arg_3_0.count > 0 then
					var_3_0:addItemById(arg_3_0.id, arg_3_0.count)
				elseif arg_3_0.count < 0 then
					var_3_0:removeItemById(arg_3_0.id, -arg_3_0.count)
				end
			end
		end,
		[DROP_TYPE_WORLD_ITEM] = function(arg_4_0)
			local var_4_0 = nowWorld()

			assert(var_4_0.type == World.TypeFull)

			local var_4_1 = var_4_0:GetInventoryProxy()

			if var_4_1 then
				if arg_4_0.count > 0 then
					var_4_1:AddItem(arg_4_0.id, arg_4_0.count)
				elseif arg_4_0.count < 0 then
					var_4_1:RemoveItem(arg_4_0.id, -arg_4_0.count)
				end
			end
		end,
		[DROP_TYPE_VITEM] = function(arg_5_0)
			local var_5_0 = getProxy(ActivityProxy):getActivityById(arg_5_0:getConfig("link_id"))

			assert(({
				[ActivityConst.ACTIVITY_TYPE_PT_BUFF] = true,
				[ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2] = true
			})[var_5_0:getConfig("type")], "error activity type for vitem drop")
			assert(arg_5_0:getConfig("virtual_type") == 103, "error virtual_type for vitem drop")

			if var_5_0 and not var_5_0:isEnd() then
				if var_5_0:getDataConfig("type") == 9 then
					var_5_0.data1 = var_5_0.data1 + math.abs(arg_5_0.count)
				end

				if var_5_0:getConfig("type") == ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2 then
					var_5_0.data4 = var_5_0.data4 + arg_5_0.count

					getProxy(ActivityProxy):UpdatePTRank({
						arg_5_0
					})
				end

				getProxy(ActivityProxy):updateActivity(var_5_0)
			end
		end
	}

	switch(arg_1_0.type, var_0_1, function(arg_6_0)
		if arg_6_0.type > DROP_TYPE_USE_ACTIVITY_DROP then
			local var_6_0 = getProxy(ActivityProxy):getActivityById(pg.activity_drop_type[arg_6_0.type].activity_id)

			if var_6_0 and not var_6_0:isEnd() then
				if arg_6_0.count > 0 then
					var_6_0:addVitemNumber(arg_6_0.id, arg_6_0.count)
				elseif arg_6_0.count < 0 then
					var_6_0:subVitemNumber(arg_6_0.id, -arg_6_0.count)
				end
			end

			getProxy(ActivityProxy):updateActivity(var_6_0)
		else
			assert(false, string.format("without drop_type_%d owner logic from id_%d", type, arg_6_0.id))
		end
	end, arg_1_0)
end

function addPlayerOwn(arg_7_0)
	arg_7_0.count = math.max(arg_7_0.count, 0)

	var_0_2(arg_7_0)
end

function reducePlayerOwn(arg_8_0)
	arg_8_0.count = -math.max(arg_8_0.count, 0)

	print(arg_8_0.count)
	var_0_2(arg_8_0)
end

function PlayerConst:addTranDrop(arg_9_1)
	self = underscore.map(self, function(arg_10_0)
		return Drop.New({
			type = arg_10_0.type,
			id = arg_10_0.id,
			count = arg_10_0.number
		})
	end)

	local var_9_0 = {}

	for iter_9_0, iter_9_1 in pairs((getProxy(BayProxy):getNewShip(false))) do
		if iter_9_1:isMetaShip() then
			table.insert(var_9_0, iter_9_1.configId)
		end
	end

	for iter_9_2, iter_9_3 in ipairs(self) do
		if iter_9_3.type == DROP_TYPE_SHIP and Ship.isMetaShipByConfigID(iter_9_3.id) and not Player.isMetaShipNeedToTrans(iter_9_3.id) then
			getProxy(MetaCharacterProxy):setMetaIDMark(iter_9_3.id)
		end
	end

	local var_9_1 = {}

	for iter_9_4, iter_9_5 in ipairs(self) do
		local var_9_2, var_9_3 = iter_9_5:DropTrans(var_9_0, arg_9_1)

		if var_9_2 and var_9_2.type ~= DROP_TYPE_TIMESTAMP then
			table.insert(var_9_1, var_9_2)
			pg.m02:sendNotification(GAME.ADD_ITEM, var_9_2)
		end

		if var_9_3 then
			pg.m02:sendNotification(GAME.ADD_ITEM, var_9_3)
		end
	end

	if arg_9_1 and arg_9_1.taskId and pg.task_data_template[arg_9_1.taskId].auto_commit == 1 then
		return {}
	else
		return var_9_1
	end
end

local var_0_3
local var_0_4

function PlayerConst:MergePassItemDrop()
	if not var_0_3 then
		var_0_4 = {
			[DROP_TYPE_SKIN] = 1,
			[DROP_TYPE_SHIP] = 9
		}
		var_0_3 = {}

		for iter_11_0, iter_11_1 in pairs({
			[DROP_TYPE_RESOURCE] = {
				8,
				8,
				[14] = 2
			},
			[DROP_TYPE_ITEM] = {
				[20001] = 3,
				[21101] = 12,
				[16502] = 6,
				[50006] = 10,
				[16024] = 7,
				[16004] = 7,
				[17023] = 16,
				[17024] = 11,
				[17034] = 11,
				[30015] = 13,
				[42036] = 4,
				[30025] = 13,
				[21131] = 12,
				[30035] = 13,
				[17013] = 16,
				[17003] = 16,
				[20013] = 14,
				[17044] = 11,
				[17004] = 11,
				[15008] = 15,
				[21121] = 12,
				[16014] = 7,
				[42030] = 5,
				[17014] = 11,
				[17033] = 16,
				[21111] = 12,
				[17043] = 16,
				[30045] = 13,
				[15001] = 17,
				[54007] = 5
			}
		}) do
			for iter_11_2, iter_11_3 in pairs(iter_11_1) do
				var_0_3[string.format("%d_%d", iter_11_0, iter_11_2)] = iter_11_3
			end
		end

		PlayerConst.PassItemOrder = setmetatable(var_0_3, {
			__index = function(self, arg_12_1)
				local var_12_0, var_12_1 = unpack(underscore.map(string.split(arg_12_1, "_"), function(arg_13_0)
					return tonumber(arg_13_0)
				end))

				self[arg_12_1] = var_0_4[var_12_0] and var_0_4[var_12_0] or var_12_0 == DROP_TYPE_ITEM and Item.getConfigData(var_12_1).type == 13 and 9 or 100

				return self[arg_12_1]
			end
		})
	end

	local var_11_0 = PlayerConst.MergeSameDrops(self)

	table.sort(var_11_0, CompareFuncs({
		function(arg_14_0)
			return PlayerConst.PassItemOrder[arg_14_0.type .. "_" .. arg_14_0.id]
		end,
		function(arg_15_0)
			return arg_15_0.id
		end
	}))

	return var_11_0
end

function PlayerConst:CheckResForShopping(arg_16_1)
	local var_16_0 = self.count * arg_16_1
	local var_16_1 = 0

	if self.type == DROP_TYPE_RESOURCE then
		var_16_1 = getProxy(PlayerProxy):getRawData():getResource(self.id)
	elseif self.type == DROP_TYPE_ITEM then
		var_16_1 = getProxy(BagProxy):getItemCountById(self.id)
	else
		assert(false)
	end

	return var_16_0 <= var_16_1
end

function PlayerConst:ConsumeResForShopping(arg_17_1)
	if self.type == DROP_TYPE_RESOURCE then
		local var_17_0 = getProxy(PlayerProxy):getData()

		var_17_0:consume({
			[id2res(self.id)] = self.count * arg_17_1
		})
		getProxy(PlayerProxy):updatePlayer(var_17_0)
	elseif self.type == DROP_TYPE_ITEM then
		getProxy(BagProxy):removeItemById(self.id, self.count * arg_17_1)
	else
		assert(false)
	end
end

function PlayerConst:GetTranAwards(arg_18_1)
	local var_18_0 = PlayerConst.addTranDrop(arg_18_1.award_list)

	for iter_18_0, iter_18_1 in ipairs({}) do
		if iter_18_1.type == DROP_TYPE_SHIP then
			if not getProxy(CollectionProxy):getShipGroup(pg.ship_data_template[iter_18_1.id].group_type) and Ship.inUnlockTip(iter_18_1.id) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("collection_award_ship", pg.ship_data_template[iter_18_1.id].name))
			end
		end
	end

	if self.isAwardMerge then
		var_18_0 = PlayerConst.MergeSameDrops(var_18_0)
	end

	return var_18_0
end

function PlayerConst:MergeTechnologyAward()
	for iter_19_0, iter_19_1 in ipairs(self.commons) do
		iter_19_1.riraty = true

		table.insert(self.items, iter_19_1)
	end

	for iter_19_2, iter_19_3 in ipairs(self.catchupItems) do
		iter_19_3.catchupTag = true

		table.insert(self.items, iter_19_3)
	end

	for iter_19_4, iter_19_5 in ipairs(self.catchupActItems) do
		iter_19_5.catchupActTag = true

		table.insert(self.items, iter_19_5)
	end

	return self.items
end

function PlayerConst:CanDropItem()
	local var_20_0 = getProxy(ActivityProxy)
	local var_20_1 = var_20_0:getActivityById(ActivityConst.UTAWARERU_ACTIVITY_PT_ID)

	if var_20_1 and not var_20_1:isEnd() then
		local var_20_2 = var_20_1:getConfig("config_client").pt_id
		local var_20_3 = _.detect(var_20_0:getActivitiesByType(ActivityConst.ACTIVITY_TYPE_PT_RANK), function(arg_21_0)
			return arg_21_0:getConfig("config_id") == var_20_2
		end):getData1()

		if var_20_3 >= 1500 then
			local var_20_4 = _.detect(self, function(arg_22_0)
				return arg_22_0.type == DROP_TYPE_RESOURCE and arg_22_0.id == var_20_2
			end)

			self = _.filter(self, function(arg_23_0)
				return arg_23_0.type ~= DROP_TYPE_RESOURCE or arg_23_0.id ~= var_20_2
			end)

			if var_20_4 and var_20_3 - 1500 < var_20_4.count then
				var_20_4.count = var_20_4.count - (var_20_3 - 1500)

				table.insert(self, var_20_4)
			end
		end
	end

	return table.getCount(self) > 0
end

local var_0_5

local function var_0_6(arg_24_0)
	var_0_5 = var_0_5 or {
		[DROP_TYPE_SHIP] = true,
		[DROP_TYPE_OPERATION] = true,
		[DROP_TYPE_LOVE_LETTER] = true
	}

	if var_0_5[arg_24_0.type] then
		return true
	elseif arg_24_0.type == DROP_TYPE_ITEM and tobool(arg_24_0.extra) then
		return true
	else
		return false
	end
end

function PlayerConst:MergeSameDrops()
	local var_25_0 = {}
	local var_25_1 = {}

	for iter_25_0, iter_25_1 in ipairs(self) do
		if not var_25_1[iter_25_1.type .. "_" .. iter_25_1.id] then
			if var_0_6(iter_25_1) then
				-- block empty
			else
				var_25_1[iter_25_1.type .. "_" .. iter_25_1.id] = iter_25_1
			end

			table.insert(var_25_0, iter_25_1)
		else
			var_25_1[iter_25_1.type .. "_" .. iter_25_1.id].count = var_25_1[iter_25_1.type .. "_" .. iter_25_1.id].count + iter_25_1.count
		end
	end

	return var_25_0
end

function PlayerConst.CheckMedalAllCollectionTrack()
	local var_26_0, var_26_1 = unpack(getGameset("live_streaming26_data2")[2])
	local var_26_2 = 0
	local var_26_3 = getProxy(PlayerProxy):getRawData()

	for iter_26_0, iter_26_1 in pairs(pg.activity_medal_template.get_id_list_by_group) do
		if iter_26_0 == math.clamp(iter_26_0, var_26_0, var_26_1) then
			if not var_26_3.activityMedalGroupList[iter_26_0] or not var_26_3.activityMedalGroupList[iter_26_0]:GetAll() then
				var_26_2 = -1

				break
			else
				var_26_2 = var_26_2 + 1
			end
		end
	end

	local var_26_4 = getProxy(PlayerProxy):getRawData().id

	if var_26_2 > PlayerPrefs.GetInt("MEDAL_ALL_COLLECTION:" .. var_26_4, 0) then
		PlayerPrefs.SetInt("MEDAL_ALL_COLLECTION:" .. var_26_4, var_26_2)
		pg.GameTrackerMgr.GetInstance():Record(GameTrackerBuilder.BuildAllCollection(20001, var_26_2))
	end
end

function PlayerConst:UpdateLinkActivity()
	local var_27_0 = getProxy(ActivityProxy)

	for iter_27_0, iter_27_1 in ipairs((underscore.filter(var_27_0:getActivitiesByType(ActivityConst.ACTIVITY_TYPE_LINK_COLLECT), function(arg_28_0)
		return not arg_28_0:isEnd()
	end))) do
		assert(pg.activity_limit_item_guide.get_id_list_by_activity[iter_27_1.id], "activity_limit_item_guide not exist activity id: " .. iter_27_1.id)

		for iter_27_2, iter_27_3 in ipairs(pg.activity_limit_item_guide.get_id_list_by_activity[iter_27_1.id]) do
			for iter_27_4, iter_27_5 in ipairs(self) do
				if iter_27_5.type == pg.activity_limit_item_guide[iter_27_3].type and iter_27_5.id == pg.activity_limit_item_guide[iter_27_3].drop_id then
					iter_27_1:updateKVPList(1, pg.activity_limit_item_guide[iter_27_3].id, iter_27_1:getKVPList(1, pg.activity_limit_item_guide[iter_27_3].id) + iter_27_5.count)
				end
			end
		end

		var_27_0:updateActivity(iter_27_1)
	end
end

return PlayerConst
