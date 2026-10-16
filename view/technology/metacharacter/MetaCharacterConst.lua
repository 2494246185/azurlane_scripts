MetaCharacterConst = {}

local var_0_0 = MetaCharacterConst

MetaCharacterConst.Meta_Type_Act_PT = 1
MetaCharacterConst.Meta_Type_Build = 2
MetaCharacterConst.Meta_Type_Pass = 3
MetaCharacterConst.REPAIR_ATTRS = {
	AttributeType.Cannon,
	AttributeType.Torpedo,
	AttributeType.Air,
	AttributeType.Reload
}
MetaCharacterConst.ENERGY_ATTRS = {
	AttributeType.Durability,
	AttributeType.Cannon,
	AttributeType.Torpedo,
	AttributeType.AntiAircraft,
	AttributeType.Air,
	AttributeType.AntiSub,
	AttributeType.Expend
}
MetaCharacterConst.UIConfig = {}

setmetatable(MetaCharacterConst.UIConfig, {
	__index = function(arg_1_0, arg_1_1)
		if pg.ship_strengthen_meta[arg_1_1].uiconfig then
			return pg.ship_strengthen_meta[arg_1_1].uiconfig
		else
			return var_0_0.UIConfig[970701]
		end
	end
})

MetaCharacterConst.META_ART_RESOURCE_PERFIX = "metaship/"
MetaCharacterConst.META_ACTIVE_LASTFIX = "_active"
MetaCharacterConst.META_DISACTIVE_LASTFIX = "_disactive"
MetaCharacterConst.META_BANNER_PERFIX = "banner_"
MetaCharacterConst.META_NAME_PERFIX = "name_"
MetaCharacterConst.META_TOAST_PERFIX = "toast_"
MetaCharacterConst.HX_TAG = "_hx"

function MetaCharacterConst.GetMetaCharacterPaintPath(arg_2_0, arg_2_1)
	if not HXSet.isHx() then
		if arg_2_1 == true then
			return var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX, arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX
		else
			return var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX, arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX
		end
	elseif arg_2_1 == true then
		local var_2_0 = arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX .. var_0_0.HX_TAG
		local var_2_1 = var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX .. var_0_0.HX_TAG

		if not checkABExist(var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX .. var_0_0.HX_TAG) then
			var_2_0 = arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX
			var_2_1 = var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_ACTIVE_LASTFIX
		end

		return var_2_1, var_2_0
	else
		local var_2_2 = arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX .. var_0_0.HX_TAG
		local var_2_3 = var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX .. var_0_0.HX_TAG

		if not checkABExist(var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX .. var_0_0.HX_TAG) then
			var_2_2 = arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX
			var_2_3 = var_0_0.META_ART_RESOURCE_PERFIX .. arg_2_0 .. var_0_0.META_DISACTIVE_LASTFIX
		end

		return var_2_3, var_2_2
	end
end

function MetaCharacterConst.GetMetaCharacterBannerPath(arg_3_0)
	return var_0_0.META_ART_RESOURCE_PERFIX .. var_0_0.META_BANNER_PERFIX .. arg_3_0, var_0_0.META_BANNER_PERFIX .. arg_3_0
end

function MetaCharacterConst.GetMetaCharacterNamePath(arg_4_0)
	return var_0_0.META_ART_RESOURCE_PERFIX .. var_0_0.META_NAME_PERFIX .. arg_4_0, var_0_0.META_NAME_PERFIX .. arg_4_0
end

function MetaCharacterConst.GetMetaCharacterToastPath(arg_5_0)
	return var_0_0.META_ART_RESOURCE_PERFIX .. var_0_0.META_TOAST_PERFIX .. arg_5_0, var_0_0.META_TOAST_PERFIX .. arg_5_0
end

function MetaCharacterConst.GetMetaShipGroupIDByConfigID(arg_6_0)
	return math.floor(arg_6_0 / 10)
end

function MetaCharacterConst.isMetaRepairRedTag(arg_7_0)
	if not arg_7_0 then
		return false
	end

	local var_7_0 = getProxy(BayProxy):getMetaShipByGroupId(arg_7_0)

	if not var_7_0 then
		return false
	end

	local var_7_1 = var_7_0:getMetaCharacter()

	if not var_7_1 then
		return false
	end

	local var_7_2 = false

	for iter_7_0, iter_7_1 in ipairs(MetaCharacterConst.REPAIR_ATTRS) do
		var_7_2 = var_7_1:getAttrVO(iter_7_1):isCanRepair()

		if var_7_2 == true then
			break
		end
	end

	return var_7_2
end

function MetaCharacterConst.isMetaEnergyRedTag(arg_8_0)
	if not arg_8_0 then
		return false
	end

	local var_8_0 = getProxy(BayProxy):getMetaShipByGroupId(arg_8_0)

	if not var_8_0 then
		return false
	end

	local var_8_1 = var_8_0:getMetaCharacter()

	if not var_8_1 then
		return false
	end

	local var_8_2 = true
	local var_8_3 = var_8_1:getBreakOutInfo()

	if not var_8_3:hasNextInfo() then
		var_8_2 = false
	end

	local var_8_4, var_8_5 = var_8_3:getLimited()

	if var_8_4 > var_8_0.level or var_8_5 > var_8_1:getCurRepairExp() then
		var_8_2 = false
	end

	local var_8_6, var_8_7 = var_8_3:getConsume()

	if var_8_7[1].count > getProxy(BagProxy):getItemCountById(var_8_7[1].itemId) then
		var_8_2 = false
	end

	return (var_8_6 > getProxy(PlayerProxy):getData().gold or nil) and false
end

function MetaCharacterConst.isMetaTacticsRedTag(arg_9_0)
	return getProxy(MetaCharacterProxy):getRedTag(arg_9_0)
end

function MetaCharacterConst.isMetaSynRedTag(arg_10_0)
	if not arg_10_0 then
		return false
	end

	local var_10_0 = getProxy(BayProxy):getMetaShipByGroupId(arg_10_0)

	if not var_10_0 then
		return false
	end

	if not var_10_0:getMetaCharacter() then
		return false
	end

	local var_10_1 = getProxy(MetaCharacterProxy):getMetaProgressVOByID(arg_10_0)

	if var_10_1:isPassType() or var_10_1:isBuildType() then
		return false
	end

	if not var_10_1:isShow() then
		return false
	end

	return (var_10_1.metaPtData or nil) and var_10_1.metaPtData:CanGetAward()
end

function MetaCharacterConst.isMetaMainSceneRedTag(arg_11_0)
	if not arg_11_0 then
		return false
	end

	if getProxy(BayProxy):getMetaShipByGroupId(arg_11_0) then
		return false
	end

	local var_11_0 = getProxy(MetaCharacterProxy):getMetaProgressVOByID(arg_11_0)

	if var_11_0:isPassType() or var_11_0:isBuildType() then
		return false
	end

	if not var_11_0:isShow() then
		return false
	end

	local var_11_1 = var_11_0:getMetaProgressPTState()

	if var_11_1 == MetaProgress.STATE_CAN_FINISH or var_11_1 == MetaProgress.STATE_CAN_AWARD then
		return true
	end
end

function MetaCharacterConst.isMetaMainEntRedPoint()
	for iter_12_0, iter_12_1 in ipairs((getProxy(MetaCharacterProxy):getMetaProgressVOList())) do
		if (var_0_0.isMetaMainSceneRedTag(iter_12_1.id) or var_0_0.isMetaSynRedTag(iter_12_1.id)) == true then
			return true
		end
	end

	return false
end

function MetaCharacterConst.isMetaBannerRedPoint(arg_13_0)
	local var_13_0 = var_0_0.isMetaTacticsRedTag(arg_13_0) or var_0_0.isMetaSynRedTag(arg_13_0)
	local var_13_1 = getProxy(BayProxy):getMetaShipByGroupId(arg_13_0)

	if var_13_1 then
		var_13_0 = var_13_0 or getProxy(MetaCharacterProxy):getMetaTacticsInfoByShipID(var_13_1.id):getTacticsStateForShow() == MetaTacticsInfo.States.LearnAble
	else
		local var_13_2 = getProxy(MetaCharacterProxy):getMetaProgressVOByID(arg_13_0)

		if var_13_2:isPtType() then
			var_13_0 = var_13_0 or var_13_2.metaPtData:CanGetAward()
		end
	end

	return var_13_0
end

function MetaCharacterConst.getFinalSkillIDListByMetaGroupID(arg_14_0)
	local var_14_0

	for iter_14_0 = 1, 4 do
		if pg.ship_data_template[arg_14_0 * 10 + iter_14_0] then
			var_14_0 = arg_14_0 * 10 + iter_14_0
		end

		break
	end

	local var_14_1 = {}

	for iter_14_1, iter_14_2 in ipairs(pg.ship_data_template[var_14_0].buff_list_display) do
		table.insert(var_14_1, iter_14_2)
	end

	return var_14_1
end

function MetaCharacterConst.getTacticsSkillIDListByShipConfigID(arg_15_0)
	local var_15_0 = {}

	for iter_15_0, iter_15_1 in ipairs(pg.ship_data_template[arg_15_0].buff_list_display) do
		if MetaCharacterConst.isMetaTaskSkillID(iter_15_1) then
			table.insert(var_15_0, iter_15_1)
		end
	end

	return var_15_0
end

function MetaCharacterConst.getMetaSkillTacticsConfig(arg_16_0, arg_16_1)
	for iter_16_0, iter_16_1 in ipairs(pg.ship_meta_skilltask.all) do
		if pg.ship_meta_skilltask[iter_16_1].skill_ID == arg_16_0 and pg.ship_meta_skilltask[iter_16_1].level == arg_16_1 then
			return pg.ship_meta_skilltask[iter_16_1]
		end
	end
end

function MetaCharacterConst:addReMetaTransItem(arg_17_1)
	if not self.virgin and self:isMetaShip() and Player.isMetaShipNeedToTrans(self.configId) then
		local var_17_0 = Player.metaShip2Res(self.configId)
		local var_17_1

		if not arg_17_1 then
			for iter_17_0, iter_17_1 in ipairs(var_17_0) do
				pg.m02:sendNotification(GAME.ADD_ITEM, (Drop.New({
					type = iter_17_1.type,
					id = iter_17_1.id,
					count = iter_17_1.count
				})))
			end

			var_17_1 = {}
		end

		var_17_1.type = var_17_0[1].type
		var_17_1.id = var_17_0[1].id
		var_17_1.count = var_17_0[1].count

		return (Drop.New(var_17_1))
	end
end

function MetaCharacterConst:getReMetaTransItem()
	local var_18_0 = Player.metaShip2Res(self.configId)

	return (Drop.New({
		type = var_18_0[1].type,
		id = var_18_0[1].id,
		count = var_18_0[1].count
	}))
end

function MetaCharacterConst.isMetaTaskSkillID(arg_19_0)
	for iter_19_0, iter_19_1 in ipairs(pg.ship_meta_skilltask.all) do
		if pg.ship_meta_skilltask[iter_19_1].skill_ID == arg_19_0 then
			return true
		end
	end

	return false
end

function MetaCharacterConst.isMetaInArchive(arg_20_0)
	local var_20_0 = getProxy(MetaCharacterProxy):getMetaProgressVOByID(arg_20_0)

	if var_20_0:isPtType() and var_20_0:isInArchive() then
		return true
	else
		return false
	end
end

function MetaCharacterConst.getRepairAbleMetaProgressVOList()
	local var_21_0 = {}

	for iter_21_0, iter_21_1 in ipairs((getProxy(MetaCharacterProxy):getMetaProgressVOList())) do
		if iter_21_1.metaShipVO then
			local var_21_1 = iter_21_1.metaShipVO:getMetaCharacter()

			if var_21_1 and var_21_1:getRepairRate() < 1 then
				table.insert(var_21_0, iter_21_1)
			end
		end
	end

	return var_21_0
end

function MetaCharacterConst.getTacticsAbleMetaProgressVOList()
	local var_22_0 = {}

	for iter_22_0, iter_22_1 in ipairs((getProxy(MetaCharacterProxy):getMetaProgressVOList())) do
		if iter_22_1.metaShipVO and not iter_22_1.metaShipVO:isAllMetaSkillLevelMax() then
			table.insert(var_22_0, iter_22_1)
		end
	end

	return var_22_0
end

function MetaCharacterConst.getEnergyAbleMetaProgressVOList()
	local var_23_0 = {}

	for iter_23_0, iter_23_1 in ipairs((getProxy(MetaCharacterProxy):getMetaProgressVOList())) do
		if iter_23_1.metaShipVO and not iter_23_1.metaShipVO:isMaxStar() then
			table.insert(var_23_0, iter_23_1)
		end
	end

	return var_23_0
end

function MetaCharacterConst:filteMetaByType(arg_24_1)
	if not arg_24_1 or arg_24_1 == ShipIndexConst.TypeAll then
		return true
	end

	local function var_24_0(arg_25_0)
		local var_25_0

		for iter_25_0 = 1, 4 do
			if pg.ship_data_template[arg_25_0 * 10 + iter_25_0] then
				var_25_0 = arg_25_0 * 10 + iter_25_0
			end

			break
		end

		return pg.ship_data_statistics[var_25_0].type
	end

	local function var_24_1(arg_26_0)
		return ShipType.GetTeamFromShipType(arg_26_0)
	end

	for iter_24_0 = 2, #ShipIndexCfg.type do
		if bit.band(bit.lshift(1, iter_24_0 - 2), arg_24_1) > 0 then
			if iter_24_0 < 4 then
				local var_24_2 = var_24_0(self.id)
				local var_24_3 = var_24_1(var_24_2)

				if table.contains(ShipIndexCfg.type[iter_24_0].shipTypes, var_24_2) then
					return true
				end

				if table.contains(ShipIndexCfg.type[iter_24_0].types, var_24_3) then
					return true
				end
			elseif table.contains(ShipIndexCfg.type[iter_24_0].types, (var_24_0(self.id))) then
				return true
			end
		end
	end

	return false
end

function MetaCharacterConst:filteMetaByRarity(arg_27_1)
	if not arg_27_1 or arg_27_1 == ShipIndexConst.RarityAll then
		return true
	end

	local function var_27_0(arg_28_0)
		local var_28_0

		for iter_28_0 = 1, 4 do
			if pg.ship_data_template[arg_28_0 * 10 + iter_28_0] then
				var_28_0 = arg_28_0 * 10 + iter_28_0
			end

			break
		end

		return pg.ship_data_statistics[var_28_0].rarity
	end

	for iter_27_0 = 2, #ShipIndexCfg.rarity do
		if bit.band(bit.lshift(1, iter_27_0 - 2), arg_27_1) > 0 and table.contains(ShipIndexCfg.rarity[iter_27_0].types, var_27_0(self.id)) then
			return true
		end
	end

	return false
end

function MetaCharacterConst.filteMetaExtra(arg_29_0, arg_29_1)
	if not arg_29_1 or arg_29_1 == ShipIndexConst.MetaExtraAll then
		return true
	end

	if ShipIndexConst.MetaExtraRepair == arg_29_1 then
		return var_0_0.filteMetaRepairAble(arg_29_0)
	elseif ShipIndexConst.MetaExtraTactics == arg_29_1 then
		return var_0_0.filteMetaTacticsAble(arg_29_0)
	elseif ShipIndexConst.MetaExtraEnergy == arg_29_1 then
		return var_0_0.filteMetaEnergyAble(arg_29_0)
	else
		return false
	end
end

function MetaCharacterConst:filteMetaRepairAble()
	if self.metaShipVO then
		local var_30_0 = self.metaShipVO:getMetaCharacter()

		if var_30_0 and var_30_0:getRepairRate() < 1 then
			return true
		end
	end

	return false
end

function MetaCharacterConst:filteMetaTacticsAble()
	if self.metaShipVO and not self.metaShipVO:isAllMetaSkillLevelMax() then
		return true
	end

	return false
end

function MetaCharacterConst:filteMetaEnergyAble()
	if self.metaShipVO and not self.metaShipVO:isMaxStar() then
		return true
	end

	return false
end

function MetaCharacterConst:filteMetaSynAble()
	if self:isPtType() then
		return not self:IsGotAllAwards()
	else
		return false
	end
end

return MetaCharacterConst
