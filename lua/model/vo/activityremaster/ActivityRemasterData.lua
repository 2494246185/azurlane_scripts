local ActivityRemasterData = class("ActivityRemasterData", import("..BaseVO"))

ActivityRemasterData.MAINTAIN = 1

function ActivityRemasterData:Ctor(arg_1_1)
	self.id = arg_1_1.id
	self.configId = self.id
	self.isFinish = false

	local var_1_0, var_1_1, var_1_2, var_1_3 = self:BuildAllAwards()

	self.collectionFurnitures = var_1_0
	self.ships = var_1_1
	self.equipmentSkins = var_1_2
	self.other = var_1_3
end

function ActivityRemasterData:BuildAllAwards()
	local var_2_1 = {}
	local var_2_2 = {}
	local var_2_3 = {}
	local var_2_4 = {}

	for iter_2_0, iter_2_1 in ipairs(pg.activity_limit_item_guide_re.get_id_list_by_activity[self.configId] or {}) do
		local var_2_5 = ActivityRemasterAward.New(iter_2_1)

		if var_2_5:IsCollectionFurniture() then
			table.insert(var_2_1, var_2_5)
			table.insert(var_2_4, var_2_5)
		elseif var_2_5:IsShip() then
			table.insert(var_2_2, var_2_5)
		elseif var_2_5:IsEquipmentSkin() then
			table.insert(var_2_3, var_2_5)
		else
			table.insert(var_2_4, var_2_5)
		end
	end

	return var_2_1, var_2_2, var_2_3, var_2_4
end

function ActivityRemasterData:bindConfigTable()
	return pg.activity_re
end

function ActivityRemasterData:IsSpecial()
	return self:getConfig("is_special") == 1
end

function ActivityRemasterData:GetBanner()
	return self:getConfig("banner")
end

function ActivityRemasterData:IsFinish()
	return self.isFinish
end

function ActivityRemasterData:MarkFinish()
	self.isFinish = true
end

function ActivityRemasterData:GetFirstOpenActId()
	local var_8_0 = getProxy(ActivityProxy)
	local var_8_1 = _.detect(self:getConfig("act_id"), function(arg_9_0)
		local var_9_0 = var_8_0:RawGetActivityById(arg_9_0)

		return var_9_0 and not var_9_0:isEnd()
	end)

	assert(var_8_1 and var_8_1 > 0, "")

	return var_8_1
end

function ActivityRemasterData:GetActList()
	return self:getConfig("act_id")
end

function ActivityRemasterData:GetRawCollectableOtherList()
	return self.other
end

function ActivityRemasterData:GetCollectableOtherList()
	return _.map(self.other, function(arg_13_0)
		local var_13_0 = arg_13_0:GetRawDropData()

		return {
			var_13_0[1],
			var_13_0[2],
			var_13_0[3]
		}
	end)
end

function ActivityRemasterData:GetOtherOwnStr()
	local var_14_0 = self:GetCollectableOtherList()
	local var_14_1 = 0

	for iter_14_0, iter_14_1 in ipairs((_.map(var_14_0, function(arg_15_0)
		return Drop.Create(arg_15_0)
	end))) do
		if iter_14_1:getOwnedCount() > 0 then
			var_14_1 = var_14_1 + 1
		end
	end

	return var_14_1 .. "/" .. #var_14_0
end

function ActivityRemasterData:GetRawCollectableEsList()
	return self.equipmentSkins
end

function ActivityRemasterData:GetCollectableEsList()
	return _.map(self.equipmentSkins, function(arg_18_0)
		local var_18_0 = arg_18_0:GetRawDropData()

		return {
			DROP_TYPE_EQUIPMENT_SKIN,
			var_18_0[2],
			var_18_0[3]
		}
	end)
end

function ActivityRemasterData:GetEsOwnStr()
	local var_19_0 = 0
	local var_19_1 = getProxy(EquipmentProxy)

	for iter_19_0, iter_19_1 in ipairs(self.equipmentSkins) do
		if Drop.Create((iter_19_1:GetRawDropData())):getOwnedCount() > 0 then
			var_19_0 = var_19_0 + 1
		end
	end

	return var_19_0 .. "/" .. #self.equipmentSkins
end

function ActivityRemasterData:GetRawCollectableShipIdList()
	return self.ships
end

function ActivityRemasterData:GetCollectableShipIdList()
	return (_.map(self.ships, function(arg_22_0)
		return arg_22_0:GetRawDropData()[2]
	end))
end

function ActivityRemasterData:GetShipProgress()
	local var_23_0 = getProxy(CollectionProxy)
	local var_23_1 = 0

	for iter_23_0, iter_23_1 in ipairs((self:GetCollectableShipIdList())) do
		if var_23_0:RawGetShipGroup(iter_23_1) then
			var_23_1 = var_23_1 + 1
		end
	end

	return var_23_1
end

function ActivityRemasterData:GetShipTotalCnt()
	return #self:GetCollectableShipIdList()
end

function ActivityRemasterData:GetShipOwnStr()
	return self:GetShipProgress() .. "/" .. self:GetShipTotalCnt()
end

function ActivityRemasterData:GetFurnitureProgress()
	if #self.collectionFurnitures <= 0 then
		return 0
	end

	return getProxy(DormProxy):getRawData():GetOwnFurnitureCount(self.collectionFurnitures[1]:GetRawDropData()[2]) >= 1 and 1 or 0
end

function ActivityRemasterData:GetFurnitureTotalCnt()
	return 1
end

function ActivityRemasterData:GetStartTime(arg_28_1)
	return pg.TimeMgr.GetInstance():parseTimeFromConfig((self:GetStartTimeTable(arg_28_1)))
end

function ActivityRemasterData:GetStartTimeTable(arg_29_1)
	return pg.activity_re_timer[getProxy(ActivityRemasterProxy).actTimeID].timer[2]
end

function ActivityRemasterData:GetActivityTimeDesc(arg_30_1, arg_30_2)
	local var_30_0 = getProxy(ActivityRemasterProxy).actTimeID
	local var_30_1

	if not pg.activity_re_timer[var_30_0] then
		return ""
	end

	for iter_30_0, iter_30_1 in ipairs((self:getConfig("act_time"))) do
		if iter_30_1[1] == arg_30_1 then
			var_30_1 = iter_30_1

			break
		end
	end

	if not var_30_1 then
		return ""
	end

	local var_30_2 = getProxy(ActivityProxy):RawGetActivityById(arg_30_1)

	if not var_30_2 or var_30_2:isEnd() then
		return ""
	end

	local var_30_3 = string.split(pg.TimeMgr.GetInstance():STimeDescC(var_30_2.stopTime, "%Y/%m/%d/%H/%M/%S"), "/")

	return GetActTimeDesc(arg_30_2, pg.activity_re_timer[var_30_0].is_maintain == ActivityRemasterData.MAINTAIN, pg.activity_re_timer[var_30_0].timer[2][1][2], pg.activity_re_timer[var_30_0].timer[2][1][3], var_30_3[2], var_30_3[3], var_30_3[4], var_30_3[5], var_30_3[6])
end

function ActivityRemasterData:GetActivityTimeDescByBanner(arg_31_1, arg_31_2)
	local var_31_0

	for iter_31_0, iter_31_1 in ipairs((self:getConfig("act_time"))) do
		if iter_31_1[3] == arg_31_1 then
			var_31_0 = iter_31_1[1]

			break
		end
	end

	if not var_31_0 then
		return ""
	end

	return self:GetActivityTimeDesc(var_31_0, arg_31_2)
end

function ActivityRemasterData:GetName()
	return self:getConfig("name") or ""
end

return ActivityRemasterData
