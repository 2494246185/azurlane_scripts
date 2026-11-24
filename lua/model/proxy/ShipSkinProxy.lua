local ShipSkinProxy = class("ShipSkinProxy", import(".NetProxy"))

ShipSkinProxy.SHIP_SKINS_UPDATE = "ship skins update"
ShipSkinProxy.SHIP_SKIN_EXPIRED = "ship skin expired"
ShipSkinProxy.FORBIDDEN_TYPE_HIDE = 0
ShipSkinProxy.FORBIDDEN_TYPE_SHOW = 1
ShipSkinProxy.FORBIDDEN_OVERWRITE_TYPE_TIME = 1
ShipSkinProxy.FORBIDDEN_OVERWRITE_TYPE_STOP = 2

function ShipSkinProxy:timeCall()
	return {
		[ProxyRegister.SecondCall] = function(arg_2_0)
			local var_2_0 = pg.TimeMgr.GetInstance():GetServerTime()

			for iter_2_0, iter_2_1 in ipairs(self.forbiddenSkinOverwriteList) do
				self:CheckConfigOverwrite(var_2_0, iter_2_0, iter_2_1)
			end
		end
	}
end

function ShipSkinProxy:register()
	self.skins = {}
	self.changeSkinGroupDic = {}
	self.cacheSkins = {}
	self.timers = {}
	self.forbiddenSkinList = {}
	self.forbiddenSkinOverwriteList = {}
	self.overwriteFlag = {}

	self:on(12201, function(arg_4_0)
		_.each(arg_4_0.skin_list, function(arg_5_0)
			local var_5_0 = ShipSkin.New(arg_5_0)

			self:addSkin(ShipSkin.New(arg_5_0))
		end)

		self.forbiddenSkinList = {}

		_.each(arg_4_0.forbidden_skin_list, function(arg_6_0)
			table.insert(self.forbiddenSkinList, {
				id = arg_6_0,
				type = ShipSkinProxy.FORBIDDEN_TYPE_HIDE
			})
		end)

		for iter_4_0, iter_4_1 in ipairs(arg_4_0.forbidden_skin_type) do
			self.forbiddenSkinList[iter_4_0].type = iter_4_1
		end

		for iter_4_2, iter_4_3 in ipairs(self.forbiddenSkinOverwriteList) do
			self:RemoveConfigOverwrite(iter_4_2)
		end

		self.forbiddenSkinOverwriteList = {}

		local var_4_0 = pg.TimeMgr.GetInstance():GetServerTime()

		for iter_4_4, iter_4_5 in ipairs(arg_4_0.forbidden_list) do
			if not pg.shop_template[iter_4_5.id] then
				warning("without config in shop_template:" .. iter_4_5.id)
			elseif pg.shop_template[iter_4_5.id].genre ~= ShopArgs.SkinShop then
				warning("config genre error in shop_template:" .. iter_4_5.id)
			else
				warning(iter_4_5.id, iter_4_5.type, pg.TimeMgr.GetInstance():STimeDescS(iter_4_5.start_time), pg.TimeMgr.GetInstance():STimeDescS(iter_4_5.stop_time))

				self.forbiddenSkinOverwriteList[iter_4_5.id] = {
					type = iter_4_5.type,
					range = {
						iter_4_5.start_time,
						iter_4_5.stop_time
					},
					order = iter_4_5.sort_order
				}

				self:CheckConfigOverwrite(var_4_0, iter_4_5.id, self.forbiddenSkinOverwriteList[iter_4_5.id])
			end
		end
	end)
end

function ShipSkinProxy:CheckConfigOverwrite(arg_7_1, arg_7_2, arg_7_3)
	local var_7_0 = arg_7_1 == math.clamp(arg_7_1, unpack(arg_7_3.range))

	if var_7_0 ~= tobool(self.overwriteFlag[arg_7_2]) then
		if var_7_0 then
			self:AddConfigOverwrite(arg_7_2, arg_7_3)
		else
			self:RemoveConfigOverwrite(arg_7_2)
		end
	end
end

function ShipSkinProxy:AddConfigOverwrite(arg_8_1, arg_8_2)
	if not self.overwriteFlag[arg_8_1] then
		self.overwriteFlag[arg_8_1] = true
		pg.shop_template[arg_8_1].time = switch(arg_8_2.type, {
			[ShipSkinProxy.FORBIDDEN_OVERWRITE_TYPE_TIME] = function()
				local var_9_0 = {}

				for iter_9_0, iter_9_1 in ipairs(arg_8_2.range) do
					local var_9_1 = underscore.map(string.split(pg.TimeMgr.GetInstance():STimeDescS(iter_9_1, "%Y/%m/%d/%H/%M/%S"), "/"), function(arg_10_0)
						return tonumber(arg_10_0)
					end)

					var_9_0[iter_9_0] = {
						underscore.first(var_9_1, 3),
						underscore.rest(var_9_1, 4)
					}
				end

				return var_9_0
			end,
			[ShipSkinProxy.FORBIDDEN_OVERWRITE_TYPE_STOP] = function()
				return "stop"
			end
		})

		if arg_8_2.order >= 0 then
			pg.shop_template[arg_8_1].order = arg_8_2.order
		end
	end
end

function ShipSkinProxy:RemoveConfigOverwrite(arg_12_1)
	if self.overwriteFlag[arg_12_1] then
		self.overwriteFlag[arg_12_1] = nil
		pg.shop_template[arg_12_1].time = nil
		pg.shop_template[arg_12_1].order = nil
	end
end

function ShipSkinProxy:getOverDueSkins()
	local var_13_0 = {}

	for iter_13_0, iter_13_1 in ipairs(self.cacheSkins) do
		table.insert(var_13_0, iter_13_1)
	end

	self.cacheSkins = {}

	return var_13_0
end

function ShipSkinProxy:getRawData()
	return self.skins
end

function ShipSkinProxy:getSkinList()
	return _.map(_.values(self.skins), function(arg_16_0)
		return arg_16_0.id
	end)
end

function ShipSkinProxy:addSkin(arg_17_1)
	assert(isa(arg_17_1, ShipSkin), "skin should be an instance of ShipSkin")

	self.skins[arg_17_1.id] = arg_17_1

	if ShipSkin.IsChangeSkin(arg_17_1.id) then
		self.changeSkinGroupDic[ShipSkin.GetChangeSkinGroupId(arg_17_1.id)] = true
	end

	self:addExpireTimer(arg_17_1)

	if arg_17_1:getConfig("skin_type") == ShipSkin.SKIN_TYPE_TB then
		NewEducateHelper.UpdateUnlockBySkinId(arg_17_1.id)
	end

	self.facade:sendNotification(ShipSkinProxy.SHIP_SKINS_UPDATE)
end

function ShipSkinProxy:getSkinById(arg_18_1)
	return self.skins[arg_18_1]
end

function ShipSkinProxy:addExpireTimer(arg_19_1)
	self:removeExpireTimer(arg_19_1.id)

	if not arg_19_1:isExpireType() then
		return
	end

	local function var_19_0()
		table.insert(self.cacheSkins, arg_19_1)
		self:removeSkinById(arg_19_1.id)

		local var_20_0 = getProxy(BayProxy)

		underscore.each(var_20_0:CanUseShareSkinPhantoms(arg_19_1.id), function(arg_21_0)
			if arg_21_0:getSkinId() == arg_19_1.id then
				var_20_0:updateShipSkin(arg_21_0.id, arg_21_0.phantomId, arg_21_0:getConfig("skin_id"))
			end
		end)
		self:sendNotification(GAME.SHIP_SKIN_EXPIRED)
	end

	local var_19_1 = arg_19_1:getExpireTime() - pg.TimeMgr.GetInstance():GetServerTime()

	if var_19_1 <= 0 then
		var_19_0()
	else
		self.timers[arg_19_1.id] = Timer.New(var_19_0, var_19_1, 1)

		self.timers[arg_19_1.id]:Start()
	end
end

function ShipSkinProxy:removeExpireTimer(arg_22_1)
	if self.timers[arg_22_1] then
		self.timers[arg_22_1]:Stop()

		self.timers[arg_22_1] = nil
	end
end

function ShipSkinProxy:removeSkinById(arg_23_1)
	self.skins[arg_23_1] = nil

	self:removeExpireTimer(arg_23_1)
	self.facade:sendNotification(ShipSkinProxy.SHIP_SKINS_UPDATE)
end

function ShipSkinProxy:hasSkin(arg_24_1)
	if ShipSkin.IsChangeSkin(arg_24_1) then
		return self.changeSkinGroupDic[ShipSkin.GetChangeSkinGroupId(arg_24_1)]
	end

	return self.skins[arg_24_1] ~= nil
end

function ShipSkinProxy:hasNonLimitSkin(arg_25_1)
	return self.skins[arg_25_1] ~= nil and not self.skins[arg_25_1]:isExpireType()
end

function ShipSkinProxy:getSkinCountById(arg_26_1)
	return self:hasSkin(arg_26_1) and 1 or 0
end

function ShipSkinProxy:InForbiddenSkinListAndHide(arg_27_1)
	return _.any(self.forbiddenSkinList, function(arg_28_0)
		return arg_28_0.id == arg_27_1 and arg_28_0.type == ShipSkinProxy.FORBIDDEN_TYPE_HIDE
	end)
end

function ShipSkinProxy:InForbiddenSkinListAndShow(arg_29_1)
	return _.any(self.forbiddenSkinList, function(arg_30_0)
		return arg_30_0.id == arg_29_1 and arg_30_0.type == ShipSkinProxy.FORBIDDEN_TYPE_SHOW
	end)
end

function ShipSkinProxy:InForbiddenSkinList(arg_31_1)
	return _.any(self.forbiddenSkinList, function(arg_32_0)
		return arg_32_0.id == arg_31_1
	end)
end

function ShipSkinProxy:remove()
	for iter_33_0, iter_33_1 in pairs(self.timers) do
		iter_33_1:Stop()
	end

	self.timers = nil
end

function ShipSkinProxy:GetAllCanPurchaseMeshImageSkins()
	local var_34_0 = {}

	for iter_34_0, iter_34_1 in ipairs((self:GetAllSkins())) do
		if iter_34_1.type ~= Goods.TYPE_ACTIVITY and iter_34_1.type ~= Goods.TYPE_ACTIVITY_EXTRA then
			local var_34_1 = iter_34_1:getSkinId()
			local var_34_2 = ShipSkin.New({
				id = var_34_1
			})

			if not var_34_2:IsLive2d() and not var_34_2:IsLive2dPlus() and not var_34_2:IsSpine() and not var_34_2:IsSpinePlus() then
				table.insert(var_34_0, var_34_1)
			end
		end
	end

	return var_34_0
end

function ShipSkinProxy:GetAllSkins()
	local var_35_0 = {}

	local function var_35_1(arg_36_0)
		local var_36_0 = getProxy(ShipSkinProxy):getSkinById((arg_36_0:getSkinId()))

		arg_36_0:updateBuyCount(var_36_0 and not var_36_0:isExpireType() and 1 or 0)
	end

	local function var_35_2(arg_37_0)
		local var_37_0 = Goods.Create({
			shop_id = arg_37_0
		}, Goods.TYPE_SKIN)

		var_35_1(var_37_0)

		local var_37_1 = ShopConst.GetShopConfig(arg_37_0)
		local var_37_2 = var_37_1.collaboration_skin_time == "" or table.equal(var_37_1.time, var_37_1.collaboration_skin_time)
		local var_37_3, var_37_4 = pg.TimeMgr.GetInstance():inTime(var_37_1.time)

		if var_37_2 and var_37_3 then
			table.insert(var_35_0, var_37_0)
		end
	end

	for iter_35_0, iter_35_1 in ipairs(pg.shop_template.get_id_list_by_genre[ShopArgs.SkinShop]) do
		var_35_2(iter_35_1)
	end

	for iter_35_2, iter_35_3 in ipairs(pg.shop_template.get_id_list_by_genre[ShopArgs.SkinShopTimeLimit]) do
		var_35_2(iter_35_3)
	end

	local var_35_3 = getProxy(ActivityProxy)

	for iter_35_4, iter_35_5 in ipairs(pg.activity_shop_extra.get_id_list_by_commodity_type[DROP_TYPE_SKIN]) do
		local var_35_4 = var_35_3:getActivityById(pg.activity_shop_extra[iter_35_5].activity)

		if pg.activity_shop_extra[iter_35_5].activity == 0 then
			if not pg.TimeMgr.GetInstance():inTime(pg.activity_shop_extra[iter_35_5].time) then
				if var_35_4 and not var_35_4:isEnd() then
					local var_35_5 = Goods.Create({
						shop_id = iter_35_5
					}, Goods.TYPE_ACTIVITY_EXTRA)

					var_35_1(var_35_5)
					table.insert(var_35_0, var_35_5)
				end
			end
		end
	end

	for iter_35_6, iter_35_7 in ipairs(pg.activity_shop_template.get_id_list_by_commodity_type[DROP_TYPE_SKIN]) do
		local var_35_6 = var_35_3:getActivityById(pg.activity_shop_template[iter_35_7].activity)

		if var_35_6 and not var_35_6:isEnd() then
			local var_35_7 = Goods.Create({
				shop_id = iter_35_7
			}, Goods.TYPE_ACTIVITY)

			var_35_1(var_35_7)

			if not _.any(var_35_0, function(arg_38_0)
				return arg_38_0:getSkinId() == var_35_7:getSkinId()
			end) then
				table.insert(var_35_0, var_35_7)
			end
		end
	end

	for iter_35_8 = #var_35_0, 1, -1 do
		local var_35_8 = var_35_0[iter_35_8]:getSkinId()

		if self:InForbiddenSkinList(var_35_8) or not self:InShowTime(var_35_8) then
			table.remove(var_35_0, iter_35_8)
		end
	end

	return var_35_0
end

function ShipSkinProxy:GetShopShowingSkins()
	local var_39_0 = {}

	local function var_39_1(arg_40_0)
		local var_40_0 = getProxy(ShipSkinProxy):getSkinById((arg_40_0:getSkinId()))

		arg_40_0:updateBuyCount(var_40_0 and not var_40_0:isExpireType() and 1 or 0)
	end

	local function var_39_2(arg_41_0)
		local var_41_0 = Goods.Create({
			shop_id = arg_41_0
		}, Goods.TYPE_SKIN)

		var_39_1(var_41_0)
		table.insert(var_39_0, var_41_0)
	end

	for iter_39_0, iter_39_1 in ipairs(pg.shop_template.get_id_list_by_genre[ShopArgs.SkinShop]) do
		var_39_2(iter_39_1)
	end

	for iter_39_2, iter_39_3 in ipairs(pg.shop_template.get_id_list_by_genre[ShopArgs.SkinShopTimeLimit]) do
		var_39_2(iter_39_3)
	end

	local var_39_3 = getProxy(ActivityProxy)

	for iter_39_4, iter_39_5 in ipairs(pg.activity_shop_extra.get_id_list_by_commodity_type[DROP_TYPE_SKIN]) do
		local var_39_4 = Goods.Create({
			shop_id = iter_39_5
		}, Goods.TYPE_ACTIVITY_EXTRA)

		var_39_1(var_39_4)
		table.insert(var_39_0, var_39_4)
	end

	for iter_39_6, iter_39_7 in ipairs(pg.activity_shop_template.get_id_list_by_commodity_type[DROP_TYPE_SKIN]) do
		local var_39_5 = Goods.Create({
			shop_id = iter_39_7
		}, Goods.TYPE_ACTIVITY)

		var_39_1(var_39_5)

		if not _.any(var_39_0, function(arg_42_0)
			return arg_42_0:getSkinId() == var_39_5:getSkinId()
		end) then
			table.insert(var_39_0, var_39_5)
		end
	end

	return var_39_0
end

function ShipSkinProxy:GetAllSkinForShip(arg_43_1)
	assert(isa(arg_43_1, Ship), "ship should be an instance of Ship")

	local var_43_0 = ShipGroup.getSkinList(arg_43_1.groupId)

	for iter_43_0 = #var_43_0, 1, -1 do
		if var_43_0[iter_43_0].skin_type == ShipSkin.SKIN_TYPE_NOT_HAVE_HIDE and not self:hasSkin(var_43_0[iter_43_0].id) then
			table.remove(var_43_0, iter_43_0)
		elseif not self:InShowTime(var_43_0[iter_43_0].id) then
			table.remove(var_43_0, iter_43_0)
		end
	end

	if pg.ship_data_trans[arg_43_1.groupId] and not arg_43_1:isRemoulded() then
		local var_43_1 = ShipGroup.GetGroupConfig(arg_43_1.groupId).trans_skin

		for iter_43_1 = #var_43_0, 1, -1 do
			if var_43_0[iter_43_1].id == var_43_1 then
				table.remove(var_43_0, iter_43_1)

				break
			end
		end
	end

	for iter_43_2 = #var_43_0, 1, -1 do
		if var_43_0[iter_43_2].show_time then
			if type(var_43_0[iter_43_2].show_time) ~= "string" or var_43_0[iter_43_2].show_time ~= "stop" then
				if type(var_43_0[iter_43_2].show_time) == "table" then
					if not pg.TimeMgr.GetInstance():inTime(var_43_0[iter_43_2].show_time) then
						table.remove(var_43_0, iter_43_2)
					end
				end

				if var_43_0[iter_43_2].no_showing == "1" then
					table.remove(var_43_0, iter_43_2)
				elseif PLATFORM == PLATFORM_KR and pg.ship_skin_template[var_43_0[iter_43_2].id].isHX == 1 then
					table.remove(var_43_0, iter_43_2)
				end
			end
		end
	end

	if PLATFORM_CODE == PLATFORM_CH then
		for iter_43_3 = #var_43_0, 1, -1 do
			if var_43_0[iter_43_3].skin_type == ShipSkin.SKIN_TYPE_OLD and pg.gameset.big_seven_old_skin_timestamp.key_value < arg_43_1.createTime then
				table.remove(var_43_0, iter_43_3)
			end
		end
	end

	if #self.forbiddenSkinList > 0 then
		for iter_43_4 = #var_43_0, 1, -1 do
			if not self:hasSkin(var_43_0[iter_43_4].id) and self:InForbiddenSkinListAndHide(var_43_0[iter_43_4].id) then
				table.remove(var_43_0, iter_43_4)
			end
		end
	end

	for iter_43_5 = #var_43_0, 1, -1 do
		local var_43_2 = ShipSkin.GetChangeSkinGroupId(var_43_0[iter_43_5].id)

		if var_43_2 then
			local var_43_3 = ShipSkin.GetStoreChangeSkinId(var_43_2, arg_43_1:GetShipPhantomMark())

			if not var_43_3 then
				if var_43_0[iter_43_5].change_skin.index ~= 1 then
					print("没有缓存的id ，" .. "移除了id" .. var_43_0[iter_43_5].id)
					table.remove(var_43_0, iter_43_5)
				end
			elseif var_43_3 ~= var_43_0[iter_43_5].id then
				print("有缓存的id = " .. var_43_3 .. "移除了id" .. var_43_0[iter_43_5].id)
				table.remove(var_43_0, iter_43_5)
			end
		end
	end

	return var_43_0
end

function ShipSkinProxy:GetShareSkinsForShipGroup(arg_44_1)
	if not pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[arg_44_1][1]].share_group_id or #pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[arg_44_1][1]].share_group_id <= 0 then
		return {}
	end

	local var_44_0 = {}

	for iter_44_0, iter_44_1 in ipairs(pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[arg_44_1][1]].share_group_id) do
		for iter_44_2, iter_44_3 in ipairs(pg.ship_skin_template.get_id_list_by_ship_group[iter_44_1]) do
			local var_44_1 = ShipSkin.New({
				id = iter_44_3
			})

			if var_44_1:CanShare() then
				table.insert(var_44_0, var_44_1)
			end
		end
	end

	return var_44_0
end

function ShipSkinProxy:GetShareSkinsForShip(arg_45_1)
	local var_45_0 = self:GetShareSkinsForShipGroup(arg_45_1.groupId)

	for iter_45_0 = #var_45_0, 1, -1 do
		local var_45_1 = ShipSkin.GetChangeSkinGroupId(var_45_0[iter_45_0].id)

		if var_45_1 then
			local var_45_2 = ShipSkin.GetStoreChangeSkinId(var_45_1, arg_45_1:GetShipPhantomMark())
			local var_45_3 = var_45_0[iter_45_0]:getConfig("change_skin")

			if not var_45_2 then
				if var_45_3 and var_45_3 ~= "" and var_45_3.index ~= 1 then
					table.remove(var_45_0, iter_45_0)
				end
			elseif not self:hasSkin(var_45_0[iter_45_0].id) then
				if var_45_3 and var_45_3 ~= "" and var_45_3.index ~= 1 then
					table.remove(var_45_0, iter_45_0)
				end
			elseif var_45_2 ~= var_45_0[iter_45_0].id then
				table.remove(var_45_0, iter_45_0)
			end
		end
	end

	return var_45_0
end

function ShipSkinProxy:GetAllSkinForARCamera(arg_46_1)
	local var_46_0 = ShipGroup.getSkinList(arg_46_1)

	for iter_46_0 = #var_46_0, 1, -1 do
		if var_46_0[iter_46_0].skin_type == ShipSkin.SKIN_TYPE_OLD then
			table.remove(var_46_0, iter_46_0)
		end
	end

	local var_46_1 = ShipGroup.GetGroupConfig(arg_46_1).trans_skin

	if var_46_1 ~= 0 then
		local var_46_2 = false
		local var_46_3 = getProxy(CollectionProxy):getShipGroup(arg_46_1)

		if var_46_3 then
			for iter_46_1, iter_46_2 in ipairs(var_46_0) do
				if iter_46_2.skin_type == ShipSkin.SKIN_TYPE_REMAKE and var_46_3.trans then
					var_46_2 = true

					break
				end
			end
		end

		if not var_46_2 then
			for iter_46_3 = #var_46_0, 1, -1 do
				if var_46_0[iter_46_3].id == var_46_1 then
					table.remove(var_46_0, iter_46_3)

					break
				end
			end
		end
	end

	for iter_46_4 = #var_46_0, 1, -1 do
		if var_46_0[iter_46_4].skin_type == ShipSkin.SKIN_TYPE_NOT_HAVE_HIDE and not self:hasSkin(var_46_0[iter_46_4].id) then
			table.remove(var_46_0, iter_46_4)
		elseif var_46_0[iter_46_4].no_showing == "1" then
			table.remove(var_46_0, iter_46_4)
		elseif PLATFORM == PLATFORM_KR and pg.ship_skin_template[var_46_0[iter_46_4].id].isHX == 1 then
			table.remove(var_46_0, iter_46_4)
		elseif not self:InShowTime(var_46_0[iter_46_4].id) then
			table.remove(var_46_0, iter_46_4)
		end
	end

	if #self.forbiddenSkinList > 0 then
		for iter_46_5 = #var_46_0, 1, -1 do
			if not self:hasSkin(var_46_0[iter_46_5].id) and self:InForbiddenSkinListAndHide(var_46_0[iter_46_5].id) then
				table.remove(var_46_0, iter_46_5)
			end
		end
	end

	for iter_46_6 = #var_46_0, 1, -1 do
		if var_46_0[iter_46_6] and var_46_0[iter_46_6].change_skin and var_46_0[iter_46_6].change_skin.index and var_46_0[iter_46_6].change_skin.index ~= 1 then
			table.remove(var_46_0, iter_46_6)
		end
	end

	return var_46_0
end

function ShipSkinProxy:InShowTime(arg_47_1)
	if pg.ship_skin_template_column_time[arg_47_1] and pg.ship_skin_template_column_time[arg_47_1].time ~= "" and type(pg.ship_skin_template_column_time[arg_47_1].time) == "table" and #pg.ship_skin_template_column_time[arg_47_1].time > 0 then
		return pg.TimeMgr.GetInstance():passTime(pg.ship_skin_template_column_time[arg_47_1].time)
	end

	return true
end

function ShipSkinProxy:HasFashion(arg_48_1)
	if #self:GetShareSkinsForShip(arg_48_1) > 0 then
		return true
	end

	local var_48_0 = self:GetAllSkinForShip(arg_48_1)

	if #var_48_0 == 1 then
		return (checkABExist("painting/" .. var_48_0[1].painting .. "_n"))
	end

	return #var_48_0 > 1
end

function ShipSkinProxy:GetEncoreSkins()
	local var_49_0 = {}

	local function var_49_1(arg_50_0)
		local var_50_0 = arg_50_0:getConfig("config_client")

		if var_50_0 and var_50_0[1] and type(var_50_0[1]) == "table" then
			return pg.TimeMgr.GetInstance():parseTimeFromConfig(var_50_0[1]) <= pg.TimeMgr.GetInstance():GetServerTime()
		else
			return arg_50_0:isEnd()
		end
	end

	for iter_49_0, iter_49_1 in ipairs((getProxy(ActivityProxy):getActivitiesByTypes({
		ActivityConst.ACTIVITY_TYPE_PT_BUFF,
		ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2
	}))) do
		if iter_49_1:getDataConfig("type") == 5 and not var_49_1(iter_49_1) then
			for iter_49_2, iter_49_3 in ipairs(iter_49_1:getConfig("config_data")) do
				table.insert(var_49_0, iter_49_3)
			end
		end
	end

	for iter_49_4, iter_49_5 in ipairs((getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_SKIN_COUPON_COUNTING))) do
		if iter_49_5 and not iter_49_5:isEnd() then
			for iter_49_6, iter_49_7 in ipairs(iter_49_5:getConfig("config_data")[2]) do
				if not table.contains(var_49_0, iter_49_7) then
					table.insert(var_49_0, iter_49_7)
				end
			end
		end
	end

	return var_49_0
end

function ShipSkinProxy:GetOwnSkins()
	local var_51_0 = {}

	for iter_51_0, iter_51_1 in pairs((self:getRawData())) do
		table.insert(var_51_0, iter_51_1)
	end

	for iter_51_2, iter_51_3 in pairs(getProxy(CollectionProxy).shipGroups) do
		if iter_51_3.married == 1 then
			local var_51_1 = ShipGroup.getProposeSkin(iter_51_3.id)

			if var_51_1 then
				table.insert(var_51_0, ShipSkin.New({
					id = var_51_1.id
				}))
			end
		end

		if iter_51_3.trans then
			table.insert(var_51_0, ShipSkin.New({
				id = pg.ship_data_trans[iter_51_3.id].skin_id
			}))
		end
	end

	return var_51_0
end

function ShipSkinProxy:GetOwnAndShareSkins()
	local var_52_0 = self:GetOwnSkins()
	local var_52_1 = {}

	for iter_52_0, iter_52_1 in ipairs(var_52_0) do
		var_52_1[iter_52_1.id] = iter_52_1
	end

	for iter_52_2, iter_52_3 in pairs(getProxy(CollectionProxy).shipGroups) do
		if iter_52_3.married == 1 then
			for iter_52_4, iter_52_5 in ipairs((self:GetShareSkinsForShipGroup(iter_52_3.id))) do
				if not var_52_1[iter_52_5.id] then
					table.insert(var_52_0, iter_52_5)
				end
			end
		end
	end

	return var_52_0
end

function ShipSkinProxy:GetProbabilitySkins(arg_53_1)
	local var_53_0 = {}

	local function var_53_1(arg_54_0)
		local var_54_0 = getProxy(ShipSkinProxy):getSkinById((arg_54_0:getSkinId()))

		arg_54_0:updateBuyCount(var_54_0 and not var_54_0:isExpireType() and 1 or 0)
	end

	local function var_53_2(arg_55_0)
		local var_55_0 = Goods.Create({
			shop_id = arg_55_0
		}, Goods.TYPE_SKIN)

		var_53_1(var_55_0)

		local var_55_1, var_55_2 = pg.TimeMgr.GetInstance():inTime(ShopConst.GetShopConfig(arg_55_0).time)

		if var_55_1 then
			table.insert(var_53_0, var_55_0)
		end
	end

	local var_53_3 = {}

	for iter_53_0, iter_53_1 in ipairs((getProxy(ShipSkinProxy):GetAllSkins())) do
		if iter_53_1:getConfig("genre") ~= ShopArgs.SkinShopTimeLimit then
			var_53_3[iter_53_1:getSkinId()] = iter_53_1.id
		end
	end

	for iter_53_2, iter_53_3 in ipairs(arg_53_1) do
		if var_53_3[iter_53_3[1]] then
			var_53_2(var_53_3[iter_53_3[1]])
		end
	end

	return var_53_0
end

function ShipSkinProxy:GetSkinProbabilitys(arg_56_1)
	local var_56_0 = {}

	for iter_56_0, iter_56_1 in ipairs(arg_56_1) do
		var_56_0[iter_56_1[1]] = iter_56_1[2]
	end

	return var_56_0
end

function ShipSkinProxy:GetInTimeSkins()
	local var_57_0 = self:GetAllSkins()

	for iter_57_0 = #var_57_0, 1, -1 do
		if var_57_0[iter_57_0].type == Goods.TYPE_SKIN then
			if var_57_0[iter_57_0]:getConfig("time") == "always" then
				table.remove(var_57_0, iter_57_0)
			end
		elseif var_57_0[iter_57_0].type == Goods.TYPE_ACTIVITY_EXTRA and pg.activity_shop_extra[var_57_0[iter_57_0].id].shop_tag ~= 1 then
			table.remove(var_57_0, iter_57_0)
		end
	end

	return var_57_0
end

function ShipSkinProxy:GetPermanentSkins()
	local var_58_0 = self:GetAllSkins()

	for iter_58_0 = #var_58_0, 1, -1 do
		if var_58_0[iter_58_0].type == Goods.TYPE_SKIN then
			if var_58_0[iter_58_0]:getConfig("time") ~= "always" then
				table.remove(var_58_0, iter_58_0)
			end
		elseif var_58_0[iter_58_0].type == Goods.TYPE_ACTIVITY_EXTRA then
			if pg.activity_shop_extra[var_58_0[iter_58_0].id].shop_tag ~= 2 then
				table.remove(var_58_0, iter_58_0)
			end
		elseif var_58_0[iter_58_0].type == Goods.TYPE_ACTIVITY then
			table.remove(var_58_0, iter_58_0)
		end
	end

	return var_58_0
end

function ShipSkinProxy:GetShareSkinsForShipGroupInJuus(arg_59_1)
	if not pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[arg_59_1][1]].share_group_id or #pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[arg_59_1][1]].share_group_id <= 0 then
		return {}
	end

	local var_59_0 = {}

	for iter_59_0, iter_59_1 in ipairs(pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[arg_59_1][1]].share_group_id) do
		for iter_59_2, iter_59_3 in ipairs(pg.ship_skin_template.get_id_list_by_ship_group[iter_59_1]) do
			local var_59_1 = ShipSkin.New({
				id = iter_59_3
			})

			if var_59_1:CanShareInJuus() then
				table.insert(var_59_0, var_59_1)
			end
		end
	end

	return var_59_0
end

return ShipSkinProxy
