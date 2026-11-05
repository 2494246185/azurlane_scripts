local ActivityRemasterAward = class("ActivityRemasterAward", import("..BaseVO"))

function ActivityRemasterAward:Ctor(arg_1_1)
	self.id = arg_1_1
	self.configId = arg_1_1
end

function ActivityRemasterAward:bindConfigTable()
	return pg.activity_limit_item_guide_re
end

function ActivityRemasterAward:GetRawDropData()
	return {
		self:getConfig("type"),
		self:getConfig("drop_id"),
		self:getConfig("count")
	}
end

function ActivityRemasterAward:GetDrop()
	if self:IsShip() then
		local var_4_0 = self:GetRawDropData()

		return Drop.Create({
			var_4_0[1],
			ShipGroup.getDefaultShipConfig(var_4_0[2]).id,
			var_4_0[3]
		})
	else
		return Drop.Create(self:GetRawDropData())
	end
end

function ActivityRemasterAward:GetOwnedCount()
	if self:IsShip() then
		return getProxy(BayProxy):getSameGroupShipCount(self:GetRawDropData()[2])
	else
		return self:GetDrop():getOwnedCount()
	end
end

function ActivityRemasterAward:GetWays()
	return self:getConfig("link_params")
end

function ActivityRemasterAward:IsCollectionFurniture()
	local var_7_0 = self:GetRawDropData()

	if var_7_0[1] == DROP_TYPE_FURNITURE then
		return pg.furniture_data_template[var_7_0[2]].type == Furniture.TYPE_COLLECTION
	end

	return false
end

function ActivityRemasterAward:IsShip()
	return self:GetRawDropData()[1] == DROP_TYPE_SHIP
end

function ActivityRemasterAward:IsEquipmentSkin()
	return self:GetRawDropData()[1] == DROP_TYPE_EQUIPMENT_SKIN
end

return ActivityRemasterAward
