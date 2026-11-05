local Dorm3dFurniture = class("Dorm3dFurniture", import("model.vo.BaseVO"))

Dorm3dFurniture.TYPE = {
	SPECIAL = 99,
	FLOOR = 2,
	DECORATION = 3,
	BED = 4,
	TABLE = 6,
	COUCH = 5,
	WALLPAPER = 1
}
Dorm3dFurniture.TYPE2NAME = {
	"dorm3d_furnitrue_type_wallpaper",
	"dorm3d_furnitrue_type_floor",
	"dorm3d_furnitrue_type_decoration",
	"dorm3d_furnitrue_type_bed",
	"dorm3d_furnitrue_type_couch",
	"dorm3d_furnitrue_type_table",
	[99] = "dorm3d_furnitrue_type_special"
}

function Dorm3dFurniture:bindConfigTable()
	return pg.dorm3d_furniture_template
end

function Dorm3dFurniture:Ctor(arg_2_1)
	Dorm3dFurniture.super.Ctor(self, arg_2_1)

	self.slotId = self.slotId or 0
end

function Dorm3dFurniture:GetSlotID()
	return self.slotId
end

function Dorm3dFurniture:SetSlotID(arg_4_1)
	self.slotId = arg_4_1
end

function Dorm3dFurniture:GetName()
	return self:getConfig("name")
end

function Dorm3dFurniture:GetType()
	return self:getConfig("type")
end

function Dorm3dFurniture:GetRarity()
	return self:getConfig("rarity")
end

function Dorm3dFurniture:GetTargetSlots()
	return self:getConfig("target_slots")
end

function Dorm3dFurniture:GetTargetSlotID()
	local var_9_0 = self:GetTargetSlots()[1]

	assert(var_9_0, "Missing Target Slot Dorm3dFurniture ID: " .. self:GetConfigID())

	return var_9_0
end

function Dorm3dFurniture:GetIcon()
	return self:getConfig("icon")
end

function Dorm3dFurniture:GetModel(arg_11_1)
	if arg_11_1 == 2 then
		local var_11_0 = self:getConfig("model_night")

		if var_11_0 and var_11_0 ~= "" then
			return var_11_0
		end
	end

	return self:getConfig("model")
end

function Dorm3dFurniture:GetAcesses()
	local var_12_0 = self:getConfig("acesses")

	if var_12_0 == nil or var_12_0 == "" then
		return {}
	end

	return var_12_0
end

function Dorm3dFurniture:GetShopID()
	return self:getConfig("shop_id")[1] or 0
end

function Dorm3dFurniture:IsValuable()
	return self:getConfig("is_exclusive") == 1
end

function Dorm3dFurniture:IsSpecial()
	return self:getConfig("is_special") == 1
end

function Dorm3dFurniture:CanRemove()
	return self:getConfig("can_remove") == 1
end

function Dorm3dFurniture:InShopTime()
	local var_17_0 = self:GetShopID()

	if var_17_0 == 0 then
		return true
	end

	return pg.TimeMgr.GetInstance():inTime(ShopConst.GetShopConfig(var_17_0).time)
end

function Dorm3dFurniture:GetEndTime()
	local var_18_0 = self:GetShopID()

	if var_18_0 == 0 then
		return 0
	end

	local var_18_1 = ShopConst.GetShopConfig(var_18_0)

	assert(var_18_1, "Missing shopCfg " .. (var_18_0 or "NIL"))

	if var_18_1.time == "always" or var_18_1.time == "stop" then
		return 0
	end

	return (pg.TimeMgr.GetInstance():parseTimeFromConfig(var_18_1.time[2]))
end

function Dorm3dFurniture:NeedViewTip()
	local var_19_0

	if self then
		var_19_0 = {}
		var_19_0[1] = getProxy(ApartmentProxy):getRoom(self)
		var_19_0 = var_19_0 or underscore.values(getProxy(ApartmentProxy).roomData)
	end

	return underscore.any(var_19_0, function(arg_20_0)
		return underscore.any(arg_20_0:GetFurnitures(), function(arg_21_0)
			return Dorm3dFurniture.GetViewedFlag(arg_21_0:GetConfigID()) == 0
		end)
	end)
end

function Dorm3dFurniture:NeedViewTipByFurnitureId()
	return Dorm3dFurniture.GetViewedFlag(self) == 0 and not (function(arg_23_0)
		local var_23_0 = getProxy(ApartmentProxy):getRoom(pg.dorm3d_furniture_template[arg_23_0].room_id)

		return var_23_0 and var_23_0:HasFurniture(arg_23_0)
	end)(self)
end

function Dorm3dFurniture:GetViewedFlag()
	return PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dFurnitureViewed_" .. self, 0)
end

function Dorm3dFurniture:SetViewedFlag()
	if Dorm3dFurniture.GetViewedFlag(self) > 0 then
		return
	end

	PlayerPrefs.SetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dFurnitureViewed_" .. self, 1)
	PlayerPrefs.Save()

	return true
end

function Dorm3dFurniture:IsTimelimitShopTip()
	local var_26_0

	if self then
		var_26_0 = {}
		var_26_0[1] = getProxy(ApartmentProxy):getRoom(self)
		var_26_0 = var_26_0 or underscore.values(getProxy(ApartmentProxy).roomData)
	end

	return underscore.any(var_26_0, function(arg_27_0)
		return _.any(pg.dorm3d_furniture_template.get_id_list_by_room_id[arg_27_0:GetConfigID()] or {}, function(arg_28_0)
			local var_28_0 = Dorm3dFurniture.New({
				configId = arg_28_0
			})

			return var_28_0:GetEndTime() > 0 and var_28_0:InShopTime() and Dorm3dFurniture.GetViewedFlag(arg_28_0) == 0
		end)
	end)
end

function Dorm3dFurniture.RecordLastTimelimitShopFurniture()
	local var_29_0 = getProxy(PlayerProxy):getRawData().id
	local var_29_1 = PlayerPrefs.GetInt(var_29_0 .. "_dorm3dTimelimitFurniture", 0)
	local var_29_2 = var_29_1

	underscore.each(underscore.values(getProxy(ApartmentProxy).roomData), function(arg_30_0)
		_.each(pg.dorm3d_furniture_template.get_id_list_by_room_id[arg_30_0:GetConfigID()] or {}, function(arg_31_0)
			local var_31_0 = Dorm3dFurniture.New({
				configId = arg_31_0
			})

			if var_31_0:GetEndTime() > 0 and var_31_0:InShopTime() then
				var_29_2 = math.max(var_29_2, arg_31_0)
			end
		end)
	end)

	if var_29_1 <= var_29_1 then
		return
	end

	PlayerPrefs.SetInt(var_29_0 .. "_dorm3dTimelimitFurniture", var_29_1)
	PlayerPrefs.Save()
end

function Dorm3dFurniture.IsOnceTimelimitShopTip()
	local var_32_0 = PlayerPrefs.GetInt(getProxy(PlayerProxy):getRawData().id .. "_dorm3dTimelimitFurniture", 0)

	return underscore.any(underscore.values(getProxy(ApartmentProxy).roomData), function(arg_33_0)
		local var_33_0 = arg_33_0:GetFurnitures()

		return _.any(pg.dorm3d_furniture_template.get_id_list_by_room_id[arg_33_0:GetConfigID()] or {}, function(arg_34_0)
			if arg_34_0 <= var_32_0 then
				return
			end

			local var_34_0 = Dorm3dFurniture.New({
				configId = arg_34_0
			})

			return var_34_0:GetEndTime() > 0 and var_34_0:InShopTime() and not _.detect(var_33_0, function(arg_35_0)
				return arg_35_0:GetConfigID() == arg_34_0
			end)
		end)
	end)
end

return Dorm3dFurniture
