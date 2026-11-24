local SpWeapon = class("SpWeapon", import(".BaseVO"))

SpWeapon.type = DROP_TYPE_SPWEAPON
SpWeapon.CONFIRM_OP_DISCARD = 0
SpWeapon.CONFIRM_OP_EXCHANGE = 1

function SpWeapon:Ctor(arg_1_1)
	SpWeapon.super.Ctor(self, arg_1_1)

	self.configId = arg_1_1.id
end

function SpWeapon:CreateByNet()
	if self.template_id == 0 then
		return
	end

	return SpWeapon.New({
		uid = self.id,
		id = self.template_id,
		attr1 = self.attr_1,
		attr2 = self.attr_2,
		attrTemp1 = self.attr_temp_1,
		attrTemp2 = self.attr_temp_2,
		pt = self.pt
	})
end

function SpWeapon:bindConfigTable()
	return pg.spweapon_data_statistics
end

function SpWeapon:GetUID()
	return self.uid
end

function SpWeapon:IsReal()
	return tobool(self:GetUID())
end

function SpWeapon:GetConfigID()
	return self.configId
end

function SpWeapon:GetOriginID()
	return self:getConfig("base") or self:GetConfigID()
end

function SpWeapon:IsImportant()
	return self:getConfig("important") == 2
end

function SpWeapon:IsUnique()
	return self:getConfig("unique") ~= 0
end

function SpWeapon:GetUniqueGroup()
	return self:getConfig("unique")
end

function SpWeapon:GetUniqueShips()
	return getProxy(BayProxy):findShipsByGroup((self:GetUniqueGroup()))
end

function SpWeapon:GetType()
	return self:getConfig("type")
end

function SpWeapon:GetName()
	return self:getConfig("name")
end

function SpWeapon:GetLevel()
	return self:getConfig("level")
end

function SpWeapon:GetTechTier()
	return self:getConfig("tech")
end

function SpWeapon:GetIconPath()
	return "SpWeapon/" .. self:getConfig("icon")
end

function SpWeapon:GetRarity()
	return self:getConfig("rarity")
end

function SpWeapon:GetPt()
	return (self:IsReal() or nil) and (self.pt or 0)
end

function SpWeapon:SetPt(arg_19_1)
	assert(arg_19_1)

	self.pt = arg_19_1 or 0
end

function SpWeapon:GetEffect()
	return self:getConfig("effect_id")
end

function SpWeapon:GetDisplayEffect()
	return self:getConfig("effect_id_display")
end

function SpWeapon:GetUpgradableSkillIds()
	return self:getConfig("skill_upgrade")
end

function SpWeapon:GetUpgradableHiddenSkillIds()
	return self:getConfig("hide_buff_upgrade")
end

function SpWeapon:GetNextUpgradeID()
	return self:getConfig("next")
end

function SpWeapon:GetPrevUpgradeID()
	return self:getConfig("prev")
end

function SpWeapon:MigrateTo(arg_26_1)
	local var_26_0 = Clone(self)

	var_26_0.id = arg_26_1
	var_26_0.configId = arg_26_1
	var_26_0.pt = 0

	return var_26_0
end

function SpWeapon:GetLabel()
	return self:getConfig("label")
end

function SpWeapon:SetShipId(arg_28_1)
	self.shipId = arg_28_1
end

function SpWeapon:GetShipId()
	return self.shipId
end

function SpWeapon:GetSkill()
	local var_30_0 = self:GetEffect()

	return var_30_0 > 0 and getSkillConfig(var_30_0) or nil
end

function SpWeapon:GetSkillInfo()
	local var_31_0 = {
		lv = 1,
		skillId = self:GetDisplayEffect()
	}

	var_31_0.unlock = var_31_0.skillId == self:GetEffect()

	local var_31_1 = self:GetShipId()

	if not var_31_1 or var_31_1 == 0 then
		var_31_0.descTrigger = true
	end

	return var_31_0
end

function SpWeapon:GetUpgradableSkillInfo()
	local var_32_0 = self:GetShipId()
	local var_32_1 = {}
	local var_32_2
	local var_32_3

	if var_32_0 then
		var_32_2 = getProxy(BayProxy):getShipById(var_32_0)
		var_32_3 = self:GetActiveUpgradableSkillList(var_32_2)
	end

	for iter_32_0, iter_32_1 in ipairs(self:GetUpgradableSkillIds()) do
		local var_32_4 = iter_32_1[2]
		local var_32_5 = 1
		local var_32_6 = false

		if var_32_2 then
			for iter_32_2, iter_32_3 in ipairs(var_32_3) do
				if iter_32_3.mapSkillID == iter_32_1[2] and iter_32_3.originalSkillID == iter_32_1[1] then
					var_32_5 = var_32_2.skills[iter_32_3.originalSkillID] and var_32_2.skills[iter_32_3.originalSkillID].level or 1
					var_32_6 = true

					break
				end
			end
		else
			var_32_6 = var_32_6 or iter_32_1[1] ~= 0
		end

		table.insert(var_32_1, {
			skillId = var_32_4,
			lv = var_32_5,
			unlock = var_32_6,
			descTrigger = not var_32_2 or nil
		})
	end

	return var_32_1
end

function SpWeapon:GetActiveUpgradableSkillList(arg_33_1)
	local var_33_0 = {}

	for iter_33_0, iter_33_1 in ipairs(arg_33_1:getSkillList()) do
		local var_33_1, var_33_2 = self:RemapSkillId(iter_33_1)

		if var_33_2 then
			table.insert(var_33_0, {
				mapSkillID = var_33_1,
				originalSkillID = iter_33_1
			})
		end
	end

	for iter_33_2, iter_33_3 in ipairs(pg.ship_data_template[arg_33_1.configId].hide_buff_list) do
		local var_33_3, var_33_4 = self:RemapSkillId(iter_33_3)

		if var_33_4 then
			table.insert(var_33_0, {
				mapSkillID = var_33_3,
				originalSkillID = iter_33_3
			})
		end
	end

	return var_33_0
end

function SpWeapon:RemapSkillId(arg_34_1)
	for iter_34_0, iter_34_1 in ipairs(self:GetUpgradableSkillIds()) do
		if iter_34_1[1] == arg_34_1 then
			return iter_34_1[2], true
		end
	end

	return arg_34_1, false
end

function SpWeapon:RemapHiddenSkillId(arg_35_1)
	for iter_35_0, iter_35_1 in ipairs(self:GetUpgradableHiddenSkillIds()) do
		if iter_35_1[1] == arg_35_1 then
			return iter_35_1[2], true
		end
	end

	return arg_35_1, false
end

function SpWeapon:GetSkillGroup()
	return {
		self:GetSkillInfo(),
		(self:GetUpgradableSkillInfo())
	}
end

function SpWeapon:GetConfigAttributes()
	return {
		self:getConfig("value_1"),
		self:getConfig("value_2")
	}
end

function SpWeapon:GetAttributesRange()
	return {
		self:getConfig("value_1_random"),
		self:getConfig("value_2_random")
	}
end

function SpWeapon:GetAttributes()
	local var_39_0 = self:GetConfigAttributes()

	if self:IsReal() then
		var_39_0[1] = var_39_0[1] + self.attr1
		var_39_0[2] = var_39_0[2] + self.attr2
	end

	return var_39_0
end

function SpWeapon:GetBaseAttributes()
	local var_40_0 = {}

	var_40_0[1] = self.attr1 or 0
	var_40_0[2] = self.attr2 or 0

	return var_40_0
end

function SpWeapon:SetBaseAttributes(arg_41_1)
	self.attr1 = arg_41_1[1]
	self.attr2 = arg_41_1[2]
end

function SpWeapon:GetAttributeOptions()
	local var_42_0 = {}

	var_42_0[1] = self.attrTemp1 or 0
	var_42_0[2] = self.attrTemp2 or 0

	return var_42_0
end

function SpWeapon:SetAttributeOptions(arg_43_1)
	self.attrTemp1 = arg_43_1[1]
	self.attrTemp2 = arg_43_1[2]
end

function SpWeapon:GetPropertiesInfo()
	local var_44_0 = {
		attrs = {}
	}
	local var_44_1 = self:GetAttributes()

	table.insert(var_44_0.attrs, {
		type = self:getConfig("attribute_1"),
		value = var_44_1[1]
	})
	table.insert(var_44_0.attrs, {
		type = self:getConfig("attribute_2"),
		value = var_44_1[2]
	})

	var_44_0.weapon = {
		sub = {}
	}
	var_44_0.equipInfo = {
		sub = {}
	}

	local var_44_2 = self:GetWearableShipTypes()

	var_44_0.part = {
		var_44_2,
		var_44_2
	}

	return var_44_0
end

function SpWeapon:GetWearableShipTypes()
	local var_45_0 = self:getConfig("usability")

	if var_45_0 and #var_45_0 > 0 then
		return var_45_0
	end

	return pg.spweapon_type[self:GetType()].ship_type
end

function SpWeapon:IsCraftable()
	return not self:IsUnCraftable() and self:GetUpgradeConfig().create_use_gold > 0
end

function SpWeapon:GetUpgradeConfig()
	return pg.spweapon_upgrade[self:getConfig("upgrade_id")]
end

function SpWeapon:IsUnCraftable()
	return self:getConfig("uncraftable") == 1
end

function SpWeapon:CalculateHistoryPt(arg_49_1)
	return (_.reduce(arg_49_1, _.reduce(self, 0, function(arg_50_0, arg_50_1)
		return arg_50_0 + Item.getConfigData(arg_50_1.id).usage_arg[1] * arg_50_1.count
	end), function(arg_51_0, arg_51_1)
		return arg_51_0 + (0 + arg_51_1:GetUpgradeConfig().upgrade_supply_pt)
	end))
end

function SpWeapon:IsMatchKey(arg_52_1)
	return EquipmentTools.IsMatchKey({
		self:getConfig("name")
	}, arg_52_1)
end

return SpWeapon
