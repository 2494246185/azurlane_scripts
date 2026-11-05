ResList = ResList or {}
ResList.ChapterPreCombatLayerResConst = {}

local var_0_0 = ResList.ChapterPreCombatLayerResConst

function ResList.ChapterPreCombatLayerResConst.GetConstResource()
	return {
		"energy",
		"shiptype",
		"weaponframes",
		"ui/iconcolorful",
		"ui/msgbox"
	}
end

function ResList.ChapterPreCombatLayerResConst:GetShipResList()
	local var_2_0 = {}

	if not self then
		return var_2_0
	end

	local var_2_1 = self:getPainting()

	if noEmptyStr(var_2_1) then
		table.insertto(var_2_0, ResPathSupport.GetPaintingSquareIconListByPaintingName(var_2_1))
	end

	local var_2_2 = self:getPrefab()

	if noEmptyStr(var_2_2) then
		table.insertto(var_2_0, ResPathSupport.GetSpineCharListByPrefabName(var_2_2))
	end

	if self.equipments then
		for iter_2_0, iter_2_1 in pairs(self:getAttachmentPrefab()) do
			if noEmptyStr(iter_2_1.config[SpineRole.ORBIT_KEY_UI]) then
				table.insert(var_2_0, ResPathSupport.CombinePath("orbit", iter_2_1.config[SpineRole.ORBIT_KEY_UI]))
			end
		end
	end

	return var_2_0
end

function ResList.ChapterPreCombatLayerResConst:GetDropResList()
	local var_3_0 = {
		"weaponframes",
		"ui/iconcolorful"
	}

	Drop.Change(self)

	if self.type == DROP_TYPE_RESOURCE then
		table.insertto(var_3_0, var_0_0.GetDropResList({
			type = DROP_TYPE_ITEM,
			id = id2ItemId(self.id),
			count = self.count
		}))
	elseif self.type == DROP_TYPE_ITEM or self.type == DROP_TYPE_VITEM or self.type == DROP_TYPE_META_PT or self.type == DROP_TYPE_LOVE_LETTER then
		local var_3_1 = self:getSubClass()
		local var_3_2 = var_3_1.icon or var_3_1:getConfig("icon")

		if var_3_1:getConfig("type") == Item.LOVE_LETTER_TYPE then
			local var_3_3 = ShipGroup.getDefaultSkin(var_3_1.extra)

			if var_3_3 and noEmptyStr(var_3_3.painting) then
				table.insertto(var_3_0, ResPathSupport.GetPaintingSquareIconListByPaintingName(var_3_3.painting))
			end

			var_3_2 = nil
		end

		if noEmptyStr(var_3_2) then
			table.insert(var_3_0, var_3_2)
		end
	elseif self.type == DROP_TYPE_EQUIP then
		table.insert(var_3_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.Equipment.Equip, self:getSubClass():getConfig("icon")))
	elseif self.type == DROP_TYPE_SHIP or self.type == DROP_TYPE_OPERATION then
		table.insertto(var_3_0, var_0_0.GetShipResList(self.ship))
	elseif self.type == DROP_TYPE_SKIN or self.type == DROP_TYPE_SKIN_TIMELIMIT then
		table.insertto(var_3_0, var_0_0.GetShipResList(Ship.New({
			configId = tonumber(self:getConfig("ship_group") .. "1"),
			skin_id = self.id
		})))
	elseif self.type == DROP_TYPE_FURNITURE then
		table.insert(var_3_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.FurnitureIcon, self:getIcon()))
	elseif self.type == DROP_TYPE_STRATEGY then
		table.insert(var_3_0, ResPathSupport.CombinePath(self.isWorldBuff and "world/buff" or ResPathSupport.ConstPath.StrategyIcon, self:getIcon()))
	elseif self.type == DROP_TYPE_EQUIPMENT_SKIN then
		table.insert(var_3_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.Equipment.Equip, self:getConfig("icon")))
	elseif self.type == DROP_TYPE_SPWEAPON then
		table.insert(var_3_0, SpWeapon.New({
			id = self.id
		}):GetIconPath())
	else
		local var_3_4 = self:getIcon()

		if noEmptyStr(var_3_4) then
			table.insert(var_3_0, var_3_4)
		end
	end

	return var_3_0
end

function ResList.ChapterPreCombatLayerResConst.GetStageDropResList(arg_4_0)
	local var_4_0 = {}

	if not pg.expedition_data_template[arg_4_0] then
		return var_4_0
	end

	local var_4_1 = Clone(pg.expedition_data_template[arg_4_0].award_display)
	local var_4_2 = checkExist(pg.expedition_activity_template[arg_4_0], {
		"pt_drop_display"
	})

	if var_4_2 and type(var_4_2) == "table" then
		local var_4_3 = getProxy(ActivityProxy)

		for iter_4_0 = #var_4_2, 1, -1 do
			local var_4_4 = var_4_3:getActivityById(var_4_2[iter_4_0][1])

			if var_4_4 and not var_4_4:isEnd() then
				table.insert(var_4_1, 1, {
					2,
					id2ItemId(var_4_2[iter_4_0][2])
				})
			end
		end
	end

	for iter_4_1 = 1, math.min(#var_4_1, 6) do
		table.insertto(var_4_0, var_0_0.GetDropResList({
			type = var_4_1[iter_4_1][1],
			id = var_4_1[iter_4_1][2],
			count = var_4_1[iter_4_1][3]
		}))
	end

	return var_4_0
end

function ResList.ChapterPreCombatLayerResConst:GetBattleFleetResList()
	local var_5_0 = {}

	local function var_5_1(arg_6_0)
		for iter_6_0, iter_6_1 in ipairs(arg_6_0) do
			table.insertto(var_5_0, var_0_0.GetShipResList(iter_6_1))
		end
	end

	var_5_1(self:getShipsByTeam(TeamType.Main, true))
	var_5_1(self:getShipsByTeam(TeamType.Vanguard, true))

	return var_5_0
end

function ResList.ChapterPreCombatLayerResConst:GetStrategyResList()
	local var_7_0 = {}
	local var_7_1 = _.detect(self:getStrategies(), function(arg_8_0)
		return arg_8_0.id == ChapterConst.StrategyRepair
	end)

	if var_7_1 then
		if pg.strategy_data_template[var_7_1.id] and noEmptyStr(pg.strategy_data_template[var_7_1.id].icon) then
			table.insert(var_7_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.StrategyIcon, pg.strategy_data_template[var_7_1.id].icon))
		end
	end

	local var_7_2 = pg.strategy_data_template[self:getFormationStg()]

	if var_7_2 and noEmptyStr(var_7_2.icon) then
		table.insert(var_7_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.StrategyIcon, var_7_2.icon))
	end

	return var_7_0
end

function ResList.ChapterPreCombatLayerResConst:GetExtraCostBuffResList()
	local var_9_0 = {}
	local var_9_1, var_9_2 = self:GetExtraCostRate()

	for iter_9_0, iter_9_1 in ipairs(var_9_2) do
		if iter_9_1.benefit_type == Chapter.OPERATION_BUFF_TYPE_DESC then
			local var_9_3 = ActivityBuff.GetBenefitCondition(iter_9_1.benefit_condition)

			if var_9_3[1] == "item" then
				table.insertto(var_9_0, var_0_0.GetDropResList({
					count = 1,
					type = DROP_TYPE_ITEM,
					id = var_9_3[2]
				}))
			end
		end
	end

	return var_9_0
end

function ResList.ChapterPreCombatLayerResConst:GetResource()
	local var_10_0 = {}

	table.insertto(var_10_0, var_0_0.GetStageDropResList((self:getStageId(self.fleet.line.row, self.fleet.line.column))))
	table.insertto(var_10_0, var_0_0.GetBattleFleetResList(self.fleet))
	table.insertto(var_10_0, var_0_0.GetStrategyResList(self.fleet))
	table.insertto(var_10_0, var_0_0.GetExtraCostBuffResList(self))

	return var_10_0
end

return ResList.ChapterPreCombatLayerResConst
