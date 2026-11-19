local ApartmentRoom = class("ApartmentRoom", import(".BaseVO"))

function ApartmentRoom:Ctor(arg_1_1)
	self.id = arg_1_1.id
	self.configId = self.id
	self.unlockCharacter = {}

	for iter_1_0, iter_1_1 in ipairs(arg_1_1.ships or {}) do
		self.unlockCharacter[iter_1_1] = true
	end

	self.furnitures = {}

	table.Ipairs(arg_1_1.furnitures or {}, function(arg_2_0, arg_2_1)
		self.furnitures[arg_2_0] = Dorm3dFurniture.New({
			configId = arg_2_1.furniture_id,
			slotId = arg_2_1.slot_id
		})
	end)

	self.slotDic = {}

	table.Ipairs(self:GetSlotIDList(), function(arg_3_0, arg_3_1)
		self.slotDic[arg_3_1] = Dorm3dFurnitureSlot.New({
			configId = arg_3_1
		})
	end)

	self.zoneDic = {}

	table.Ipairs(self:GetZoneIDList(), function(arg_4_0, arg_4_1)
		local var_4_0 = Dorm3dZone.New({
			configId = arg_4_1
		})

		self.zoneDic[var_4_0:GetWatchCameraName()] = var_4_0

		var_4_0:SetSlots(_.map(var_4_0:GetSlotIDList(), function(arg_5_0)
			return self.slotDic[arg_5_0]
		end))
	end)
	self:UpdateFurnitureReplaceConfig()

	self.cameraZones = _.map(self:GetCameraZoneIDList(), function(arg_6_0)
		return Dorm3dCameraZone.New({
			configId = arg_6_0
		})
	end)
	self.collectItemDic = {}

	for iter_1_2, iter_1_3 in ipairs(arg_1_1.collections or {}) do
		self.collectItemDic[iter_1_3] = true
	end

	self.shipArAnimationDic = {}

	local var_1_0 = self:getConfig("ar_anim")

	if var_1_0 then
		for iter_1_4, iter_1_5 in ipairs(var_1_0) do
			self.shipArAnimationDic[iter_1_5[1]] = _.map(iter_1_5[2], function(arg_7_0)
				return Dorm3dCameraAnim.New({
					configId = arg_7_0
				})
			end)
		end
	end
end

function ApartmentRoom:bindConfigTable()
	return pg.dorm3d_rooms
end

function ApartmentRoom:getDownloadBelongList()
	local var_9_0 = string.lower(self:getConfig("resource_name"))
	local var_9_1 = self:getConfig("type")

	if var_9_1 == 1 then
		return {
			"room_" .. var_9_0,
			"common"
		}
	elseif var_9_1 == 2 then
		return {
			"room_" .. var_9_0,
			"apartment_" .. var_9_0,
			"common"
		}
	else
		assert(false, "without room type:" .. var_9_1)
	end
end

function ApartmentRoom:getDownloadNameList()
	local var_10_0 = DormGroupConst.GetDownloadResourceDic()
	local var_10_1 = {}

	for iter_10_0, iter_10_1 in ipairs(self:getDownloadBelongList()) do
		table.insertto(var_10_1, var_10_0[iter_10_1] or {})
	end

	return var_10_1
end

function ApartmentRoom:needDownload()
	local var_11_0 = DormGroupConst.GetDownloadResourceDic()

	for iter_11_0, iter_11_1 in ipairs(self:getDownloadBelongList()) do
		if var_11_0[iter_11_1] and #var_11_0[iter_11_1] > 0 then
			return true
		end
	end

	return false
end

function ApartmentRoom:getDownloadNeedSize()
	local var_12_0, var_12_1 = DormGroupConst.CalcDormListSize(self:getDownloadNameList())

	return var_12_0, var_12_1
end

function ApartmentRoom:getState()
	if DormGroupConst.DormDownloadLock and DormGroupConst.DormDownloadLock.roomId == self.configId then
		return "loading"
	elseif self:needDownload() then
		return "download"
	else
		return "complete"
	end
end

function ApartmentRoom:isPersonalRoom()
	return self:getConfig("type") == 2
end

function ApartmentRoom:getPersonalGroupId()
	assert(self:isPersonalRoom())

	return self:getConfig("character")[1]
end

function ApartmentRoom:getInviteList()
	return table.mergeArray(self:getConfig("character"), self:getConfig("character_pay"))
end

function ApartmentRoom:getInteractRange()
	local var_17_0, var_17_1 = unpack(self:getConfig("character_range"))

	var_17_1 = var_17_1 or var_17_0

	return var_17_0, var_17_1
end

function ApartmentRoom:getRoomName()
	return self:getConfig("room")
end

function ApartmentRoom:GetZoneIDList()
	return pg.dorm3d_zone_template.get_id_list_by_room_id[self.configId] or {}
end

function ApartmentRoom:GetSlotIDList()
	return pg.dorm3d_furniture_slot_template.get_id_list_by_room_id[self.configId] or {}
end

function ApartmentRoom:GetFurnitureZoneIDList()
	return self:getConfig("furniture_zones")
end

function ApartmentRoom:GetCameraZoneIDList()
	return pg.dorm3d_camera_zone_template.get_id_list_by_room_id[self.configId] or {}
end

function ApartmentRoom:GetZones()
	return underscore(self.zoneDic):chain():values():sort(CompareFuncs({
		function(arg_24_0)
			return arg_24_0.configId
		end
	})):value()
end

function ApartmentRoom:GetFurnitureZones()
	return underscore.map(self:GetFurnitureZoneIDList(), function(arg_26_0)
		return (table.Find(self.zoneDic, function(arg_27_0, arg_27_1)
			return arg_27_1:GetConfigID() == arg_26_0
		end))
	end)
end

function ApartmentRoom:GetCameraZones()
	return self.cameraZones
end

function ApartmentRoom:GetSlots()
	return underscore(self.slotDic):chain():values():sort(CompareFuncs({
		function(arg_30_0)
			return arg_30_0.configId
		end
	})):value()
end

function ApartmentRoom:GetFurnitureIDList()
	return pg.dorm3d_furniture_template.get_id_list_by_room_id[self.configId]
end

function ApartmentRoom:GetFurnitures()
	return self.furnitures
end

function ApartmentRoom:HasFurniture(arg_33_1)
	return _.any(self.furnitures, function(arg_34_0)
		return arg_34_0:GetConfigID() == arg_33_1
	end)
end

function ApartmentRoom:AddFurnitureByID(arg_35_1)
	table.insert(self.furnitures, Dorm3dFurniture.New({
		configId = arg_35_1
	}))
end

function ApartmentRoom:ReplaceFurnitures(arg_36_1)
	_.each(arg_36_1, function(arg_37_0)
		self:ReplaceFurniture(arg_37_0.slotId, arg_37_0.furnitureId)
	end)
	self:UpdateFurnitureReplaceConfig()
end

function ApartmentRoom:ReplaceFurniture(arg_38_1, arg_38_2)
	if arg_38_1 > 0 then
		local var_38_0 = _.detect(self.furnitures, function(arg_39_0)
			return arg_39_0:GetSlotID() == arg_38_1
		end)

		if var_38_0 then
			var_38_0:SetSlotID(0)
		end
	end

	if arg_38_2 > 0 then
		local var_38_1 = _.detect(self.furnitures, function(arg_40_0)
			return arg_40_0:GetConfigID() == arg_38_2 and arg_40_0:GetSlotID() == 0
		end)

		if var_38_1 then
			var_38_1:SetSlotID(arg_38_1)
		end
	end
end

function ApartmentRoom:IsFurnitureSetIn(arg_41_1)
	for iter_41_0, iter_41_1 in ipairs(self.furnitures) do
		if iter_41_1:GetConfigID() == arg_41_1 and iter_41_1.slotId > 0 then
			return true
		end
	end

	return false
end

function ApartmentRoom:UpdateFurnitureReplaceConfig()
	local var_42_0 = {}

	for iter_42_0, iter_42_1 in ipairs(self.furnitures) do
		if iter_42_1.slotId ~= 0 then
			var_42_0[iter_42_1.slotId] = iter_42_1
		end
	end
end

ApartmentRoom.ITEM_LOCK = 0
ApartmentRoom.ITEM_UNLOCK = 1
ApartmentRoom.ITEM_ACTIVE = 2
ApartmentRoom.ITEM_FIRST = 3

function ApartmentRoom:getTriggerableCollectItemDic(arg_43_1)
	local var_43_0 = {}

	for iter_43_0, iter_43_1 in ipairs(pg.dorm3d_collection_template.get_id_list_by_room_id[self.configId] or {}) do
		var_43_0[iter_43_1] = (pg.dorm3d_collection_template[iter_43_1].time ~= 0 and pg.dorm3d_collection_template[iter_43_1].time ~= arg_43_1 or not ApartmentProxy.CheckUnlockConfig(pg.dorm3d_collection_template[iter_43_1].unlock)) and ApartmentRoom.ITEM_LOCK or self.collectItemDic[iter_43_1] and ApartmentRoom.ITEM_ACTIVE or ApartmentRoom.ITEM_FIRST
	end

	return var_43_0
end

function ApartmentRoom:getNormalZoneNames()
	return underscore(self.zoneDic):chain():values():select(function(arg_45_0)
		return not arg_45_0:IsGlobal()
	end):map(function(arg_46_0)
		return arg_46_0:GetWatchCameraName()
	end):value()
end

function ApartmentRoom:getZoneConfig(arg_47_1, arg_47_2)
	return self.zoneDic[arg_47_1]:getConfig(arg_47_2)
end

function ApartmentRoom:getApartmentZoneConfig(arg_48_1, arg_48_2, arg_48_3)
	return Apartment.getGroupConfig(arg_48_3, self:getZoneConfig(arg_48_1, arg_48_2))
end

function ApartmentRoom:getAllARAnimationListByShip(arg_49_1)
	return self.shipArAnimationDic[arg_49_1]
end

function ApartmentRoom:getMiniGames()
	return underscore.rest(pg.dorm3d_minigame.get_id_list_by_room_id[self.configId] or {}, 1)
end

function ApartmentRoom:unlockAllInvite()
	for iter_51_0, iter_51_1 in ipairs(self:getConfig("character_pay")) do
		if not self.unlockCharacter[iter_51_1] then
			return false
		end
	end

	return true
end

function ApartmentRoom:GetAllTouchIDByZone(arg_52_1, arg_52_2)
	local var_52_0 = {}
	local var_52_1 = self:getApartmentZoneConfig(arg_52_1, "touch_id", arg_52_2)

	if var_52_1 then
		table.insert(var_52_0, {
			touchId = var_52_1
		})
	end

	for iter_52_0, iter_52_1 in pairs(self.furnitures) do
		if iter_52_1:GetSlotID() > 0 then
			local var_52_2 = self.slotDic[iter_52_1:GetSlotID()]

			if var_52_2 and pg.dorm3d_zone_template[var_52_2:GetZoneID()].watch_camera == arg_52_1 then
				local var_52_3 = iter_52_1:GetName()
				local var_52_4 = Apartment.getGroupConfig(arg_52_2, iter_52_1:getConfig("touch_id"))

				if var_52_3 and var_52_4 then
					table.insert(var_52_0, {
						touchId = var_52_4,
						furnitureName = var_52_3
					})
				end
			end
		end
	end

	return var_52_0
end

return ApartmentRoom
