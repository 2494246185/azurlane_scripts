local Ship = class("Ship", import(".BaseVO"))

Ship.ENERGY_MID = 40
Ship.ENERGY_LOW = 0
Ship.RECOVER_ENERGY_POINT = 2
Ship.INTIMACY_PROPOSE = 6
Ship.CONFIG_MAX_STAR = 6
Ship.BACKYARD_1F_ENERGY_ADDITION = 2
Ship.BACKYARD_2F_ENERGY_ADDITION = 3
Ship.PREFERENCE_TAG_NONE = 0
Ship.PREFERENCE_TAG_COMMON = 1

local var_0_1 = {
	vanguard = i18n("word_vanguard_fleet"),
	main = i18n("word_main_fleet")
}

Ship.LOCK_STATE_UNLOCK = 0
Ship.LOCK_STATE_LOCK = 1
Ship.WEAPON_COUNT = 3
Ship.PREFAB_EQUIP = 4
Ship.MAX_SKILL_LEVEL = 10
Ship.ENERGY_RECOVER_TIME = 360

local var_0_2 = 4
local var_0_4 = 120
local var_0_5 = pg.ship_data_strengthen
local var_0_6 = pg.ship_level
local var_0_7 = pg.equip_skin_template
local var_0_8 = pg.ship_data_breakout

function nation2print(arg_1_0)
	return Nation.Nation2Print(arg_1_0)
end

function Ship:getRecoverEnergyPoint()
	return self.propose and 3 or 2
end

function shipType2name(arg_3_0)
	return ShipType.Type2Name(arg_3_0)
end

function shipType2print(arg_4_0)
	return ShipType.Type2Print(arg_4_0)
end

function shipType2Battleprint(arg_5_0)
	return ShipType.Type2BattlePrint(arg_5_0)
end

function skinId2bgPrint(arg_6_0)
	if pg.ship_skin_template[arg_6_0].rarity_bg and pg.ship_skin_template[arg_6_0].rarity_bg ~= "" then
		return pg.ship_skin_template[arg_6_0].rarity_bg
	end
end

function Ship:useSkin(arg_7_1)
	local var_7_0 = self:getSkinId()

	if var_7_0 == arg_7_1 then
		return true
	end

	local var_7_1 = ShipSkin.GetChangeSkinGroupId(var_7_0)
	local var_7_2 = ShipSkin.GetChangeSkinGroupId(arg_7_1)

	if var_7_1 and var_7_2 and var_7_1 == var_7_2 then
		return true
	end

	return false
end

function Ship:rarity2bgPrint()
	return shipRarity2bgPrint(self:getRarity(), self:isBluePrintShip(), self:isMetaShip())
end

function Ship:rarity2bgPrintForGet()
	return skinId2bgPrint(self:getSkinId()) or self:rarity2bgPrint()
end

function Ship:getShipBgPrint(arg_10_1)
	local var_10_0 = self:getSkinId()

	assert(pg.ship_skin_template[var_10_0], "ship_skin_template not exist: " .. var_10_0)

	local var_10_1

	if not arg_10_1 and pg.ship_skin_template[var_10_0].bg_sp and pg.ship_skin_template[var_10_0].bg_sp ~= "" and PlayerPrefs.GetInt("paint_hide_other_obj_" .. pg.ship_skin_template[var_10_0].painting, 0) == 0 then
		var_10_1 = pg.ship_skin_template[var_10_0].bg_sp
	end

	if not var_10_1 or not var_10_1 then
		::label_10_0::

		local var_10_2

		if pg.ship_skin_template[var_10_0].bg and #pg.ship_skin_template[var_10_0].bg > 0 then
			var_10_2 = pg.ship_skin_template[var_10_0].bg or self:rarity2bgPrintForGet()
		end
	end

	return var_10_2
end

function Ship:getStar()
	return self:getConfig("star")
end

function Ship:getMaxStar()
	return pg.ship_data_template[self.configId].star_max
end

function Ship:getShipArmor()
	return self:getConfig("armor_type")
end

function Ship:getShipArmorName()
	return ArmorType.Type2Name((self:getShipArmor()))
end

function Ship:getGroupId()
	return pg.ship_data_template[self.configId].group_type
end

function Ship:getGroupIdByConfigId()
	return math.floor(self / 10)
end

function Ship:getTransformShipId()
	if pg.ship_data_trans[pg.ship_data_template[self].group_type] then
		for iter_17_0, iter_17_1 in ipairs(pg.ship_data_trans[pg.ship_data_template[self].group_type].transform_list) do
			for iter_17_2, iter_17_3 in ipairs(iter_17_1) do
				for iter_17_4, iter_17_5 in ipairs(pg.transform_data_template[iter_17_3[2]].ship_id) do
					if iter_17_5[1] == self then
						return iter_17_5[2]
					end
				end
			end
		end
	end
end

function Ship:getAircraftCount()
	local var_18_0 = self:getConfigTable().base_list
	local var_18_1 = self:getConfigTable().default_equip_list
	local var_18_2 = {}

	for iter_18_0 = 1, 3 do
		local var_18_3 = Equipment.getConfigData(self:getEquip(iter_18_0) and self:getEquip(iter_18_0).configId or var_18_1[iter_18_0]).type

		if table.contains(EquipType.AirDomainEquip, var_18_3) then
			var_18_2[var_18_3] = defaultValue(var_18_2[var_18_3], 0) + var_18_0[iter_18_0]
		end
	end

	return var_18_2
end

function Ship:getShipType()
	return self:getConfig("type")
end

function Ship:getEnergy()
	return self.energy
end

function Ship:getEnergeConfig()
	local var_21_0 = self:getEnergy()

	for iter_21_0, iter_21_1 in ipairs(pg.energy_template.all) do
		if type(iter_21_1) == "number" and var_21_0 >= pg.energy_template[iter_21_1].lower_bound and var_21_0 <= pg.energy_template[iter_21_1].upper_bound then
			return pg.energy_template[iter_21_1]
		end
	end

	assert(false, "疲劳配置不存在：" .. self.energy)
end

function Ship:isLowEnergy()
	return self:getEnergeConfig().id < 3
end

function Ship:getEnergyPrint()
	local var_23_0 = self:getEnergeConfig()

	return var_23_0.icon, var_23_0.desc
end

function Ship:getIntimacy()
	return self.intimacy or 0
end

function Ship:getCVIntimacy()
	return self:getIntimacy() / 100 + (self.propose and 1000 or 0)
end

function Ship:getIntimacyMax()
	if self.propose then
		return 200
	else
		return self:GetNoProposeIntimacyMax()
	end
end

function Ship:GetNoProposeIntimacyMax()
	return 100
end

function Ship:getIntimacyIcon()
	local var_28_0 = pg.intimacy_template[self:getIntimacyLevel()]
	local var_28_1 = ""

	if self:isMetaShip() then
		var_28_1 = "_meta"
	elseif self:IsXIdol() then
		var_28_1 = "_imas"
	end

	if not self.propose and math.floor(self:getIntimacy() / 100) >= self:getIntimacyMax() then
		return var_28_0.icon .. var_28_1, "heart" .. var_28_1
	else
		return var_28_0.icon .. var_28_1
	end
end

function Ship:getIntimacyDetail()
	return self:getIntimacyMax(), math.floor(self:getIntimacy() / 100)
end

function Ship:getIntimacyInfo()
	local var_30_0 = pg.intimacy_template[self:getIntimacyLevel()]

	return var_30_0.icon, var_30_0.desc
end

function Ship:getIntimacyLevel()
	local var_31_0 = 0

	for iter_31_0, iter_31_1 in pairs(pg.intimacy_template.all) do
		if type(iter_31_1) == "number" and self:getIntimacy() >= pg.intimacy_template[iter_31_1].lower_bound and self:getIntimacy() <= pg.intimacy_template[iter_31_1].upper_bound then
			var_31_0 = iter_31_1

			break
		end
	end

	if var_31_0 < self.INTIMACY_PROPOSE and self.propose then
		var_31_0 = self.INTIMACY_PROPOSE
	end

	return var_31_0
end

function Ship:getBluePrint()
	local var_32_0 = ShipBluePrint.New({
		id = self.groupId
	})
	local var_32_1 = self.strengthList[1] or {
		exp = 0,
		level = 0
	}

	var_32_0:updateInfo({
		blue_print_level = var_32_1.level,
		exp = var_32_1.exp
	})

	return var_32_0
end

function Ship:getBaseList()
	if self:isBluePrintShip() then
		local var_33_0 = self:getBluePrint()

		assert(var_33_0, "blueprint can not be nil" .. self.configId)

		return var_33_0:getBaseList(self)
	else
		return self:getConfig("base_list")
	end
end

function Ship:getPreLoadCount()
	if self:isBluePrintShip() then
		return self:getBluePrint():getPreLoadCount(self)
	else
		return self:getConfig("preload_count")
	end
end

function Ship:getNation()
	return self:getConfig("nationality")
end

function Ship:getPaintingName()
	assert(pg.ship_skin_template[pg.ship_data_statistics[self].skin_id], "ship_skin_template not exist: " .. self .. " " .. pg.ship_data_statistics[self].skin_id)

	return pg.ship_skin_template[pg.ship_data_statistics[self].skin_id].painting
end

function Ship:getName()
	if self.propose then
		if pg.PushNotificationMgr.GetInstance():isEnableShipName() then
			return self.name
		end
	end

	if self:isRemoulded() then
		return pg.ship_skin_template[self:getRemouldSkinId()].name
	end

	return pg.ship_data_statistics[self.configId].name
end

function Ship:GetDefaultName()
	if self:isRemoulded() then
		return pg.ship_skin_template[self:getRemouldSkinId()].name
	else
		return pg.ship_data_statistics[self.configId].name
	end
end

function Ship:getShipName()
	return pg.ship_data_statistics[self].name
end

function Ship:getBreakOutLevel()
	assert(self, "必须存在配置id")
	assert(pg.ship_data_statistics[self], "必须存在配置" .. self)

	return pg.ship_data_statistics[self].star
end

function Ship:Ctor(arg_41_1)
	self.id = arg_41_1.id
	self.configId = arg_41_1.template_id or arg_41_1.configId
	self.level = arg_41_1.level
	self.exp = arg_41_1.exp
	self.energy = arg_41_1.energy
	self.lockState = arg_41_1.is_locked
	self.intimacy = arg_41_1.intimacy
	self.propose = arg_41_1.propose and arg_41_1.propose > 0
	self.proposeTime = arg_41_1.propose

	if self.intimacy and self.intimacy > 10000 and not self.propose then
		self.intimacy = 10000
	end

	self.renameTime = arg_41_1.change_name_timestamp

	if arg_41_1.name and arg_41_1.name ~= "" then
		self.name = arg_41_1.name
	else
		assert(pg.ship_data_statistics[self.configId], "必须存在配置" .. self.configId)

		self.name = pg.ship_data_statistics[self.configId].name
	end

	self.groupId = pg.ship_data_template[self.configId].group_type
	self.bluePrintFlag = pg.ship_data_group[pg.ship_data_group.get_id_list_by_group_type[self.groupId][1]].handbook_type == 2
	self.strengthList = {}

	for iter_41_0, iter_41_1 in ipairs(arg_41_1.strength_list or {}) do
		if not self:isBluePrintShip() then
			self.strengthList[ShipModAttr.ID_TO_ATTR[iter_41_1.id]] = iter_41_1.exp
		else
			table.insert(self.strengthList, {
				level = iter_41_1.id,
				exp = iter_41_1.exp
			})
		end
	end

	self.equipmentSkins = {}
	self.equipments = {}

	if arg_41_1.equip_info_list then
		for iter_41_2, iter_41_3 in ipairs(arg_41_1.equip_info_list or {}) do
			self.equipments[iter_41_2] = iter_41_3.id > 0 and Equipment.New({
				count = 1,
				id = iter_41_3.id,
				config_id = iter_41_3.id,
				skinId = iter_41_3.skinId
			}) or false

			if iter_41_3.skinId > 0 then
				self.equipmentSkins[iter_41_2] = iter_41_3.skinId or 0
			end

			self:reletiveEquipSkin(iter_41_2)
		end
	end

	self.spWeapon = nil

	if arg_41_1.spweapon then
		self:UpdateSpWeapon(SpWeapon.CreateByNet(arg_41_1.spweapon))
	end

	self.skills = {}

	for iter_41_4, iter_41_5 in ipairs(arg_41_1.skill_id_list or {}) do
		self:updateSkill(iter_41_5)
	end

	self.star = self:getConfig("rarity")
	self.transforms = {}

	for iter_41_6, iter_41_7 in ipairs(arg_41_1.transform_list or {}) do
		self.transforms[iter_41_7.id] = {
			id = iter_41_7.id,
			level = iter_41_7.level
		}
	end

	self.createTime = arg_41_1.create_time or 0

	local var_41_2 = getProxy(CollectionProxy)

	self.virgin = var_41_2 and var_41_2.shipGroups[self.groupId] == nil

	local var_41_3 = table.indexof({
		pg.gameset.test_ship_config_1.key_value,
		pg.gameset.test_ship_config_2.key_value,
		pg.gameset.test_ship_config_3.key_value
	}, self.configId)

	self.testShip = var_41_3 == 1 and {
		2,
		3,
		4
	} or var_41_3 == 2 and {
		5
	} or var_41_3 == 3 and {
		6
	} or nil
	self.maxIntimacy = pg.intimacy_template[#pg.intimacy_template.all].upper_bound

	local var_41_4 = 0

	if not HXSet.isHxSkin() then
		var_41_4 = arg_41_1.skin_id or 0
	end

	self.phantomDic = {}

	self:updateSkinId(var_41_4, 0)

	for iter_41_8, iter_41_9 in ipairs(arg_41_1.skin_shadow_list or {}) do
		self:updateSkinId(iter_41_9.value, iter_41_9.key)
	end

	self.noChangeSkin = arg_41_1.noChangeSkin or false
	self.phantomRandomFlag = {}

	for iter_41_10, iter_41_11 in ipairs(arg_41_1.char_random_flag or {}) do
		self:updateRandomFlag(1, iter_41_11)
	end

	self.name = arg_41_1.name and arg_41_1.name ~= "" and arg_41_1.name or self:isRemoulded() and pg.ship_skin_template[self:getRemouldSkinId()].name or pg.ship_data_statistics[self.configId].name
	self.maxLevel = arg_41_1.max_level
	self.proficiency = arg_41_1.proficiency or 0
	self.preferenceTag = arg_41_1.common_flag
	self.hpRant = 10000
	self.strategies = {}
	self.triggers = {}
	self.commanderId = arg_41_1.commanderid or 0
	self.activityNpc = arg_41_1.activity_npc or 0

	if Ship.isMetaShipByConfigID(self.configId) then
		self.metaCharacter = MetaCharacter.New({
			id = MetaCharacterConst.GetMetaShipGroupIDByConfigID(self.configId),
			repair_attr_info = arg_41_1.meta_repair_list
		}, self)
	end
end

function Ship:isMetaShipByConfigID()
	local var_42_0 = false

	if pg.ship_meta_breakout.all[1] <= self then
		for iter_42_0, iter_42_1 in ipairs(pg.ship_meta_breakout.all) do
			if self == iter_42_1 then
				var_42_0 = true

				break
			end
		end
	end

	return var_42_0
end

function Ship:isMetaShip()
	return self.metaCharacter ~= nil
end

function Ship:getMetaCharacter()
	return self.metaCharacter
end

function Ship:unlockActivityNpc(arg_45_1)
	self.activityNpc = arg_45_1
end

function Ship:isActivityNpc()
	return self.activityNpc > 0
end

function Ship:getActiveEquipments()
	local var_47_0 = Clone(self.equipments)

	for iter_47_0 = #var_47_0, 1, -1 do
		if var_47_0[iter_47_0] then
			for iter_47_1 = 1, iter_47_0 - 1 do
				if var_47_0[iter_47_1] and var_47_0[iter_47_0]:getConfig("equip_limit") ~= 0 and var_47_0[iter_47_1]:getConfig("equip_limit") == var_47_0[iter_47_0]:getConfig("equip_limit") then
					var_47_0[iter_47_0] = false
				end
			end
		end
	end

	return var_47_0
end

function Ship:getAllEquipments()
	return self.equipments
end

function Ship:isBluePrintShip()
	return self.bluePrintFlag
end

function Ship:isLightSkin(arg_50_1)
	return ShipSkin.IsLightSkin((self:getPhantomSkin(arg_50_1 or 0)))
end

function Ship:getSkinId(arg_51_1)
	local var_51_0 = self:getPhantomSkin(arg_51_1 or 0)

	if not self.noChangeSkin and tobool(self.id) and ShipSkin.IsChangeSkin(var_51_0) then
		local var_51_1 = ShipSkin.GetStoreChangeSkinId(ShipSkin.GetChangeSkinGroupId(var_51_0), self:GetShipPhantomMark())

		if var_51_1 then
			return var_51_1
		end
	end

	return var_51_0
end

function Ship:RevertAsmrSkin()
	local var_52_0 = self:getSkinId()

	if not self.noChangeSkin and tobool(self.id) and ShipSkin.IsChangeSkin(var_52_0) then
		if ShipSkin.GetChangeSkinCustomDataId(var_52_0, "asmr") == 1 and ShipSkin.GetChangeSkinCustomDataId(var_52_0, "index") ~= 1 then
			ShipSkin.SetStoreChangeSkinId(ShipSkin.GetChangeSkinMainId(var_52_0), self:GetShipPhantomMark())
		end
	end
end

function Ship:getPhantomSkin(arg_53_1)
	if not arg_53_1 or arg_53_1 == 0 then
		return self.skinId
	else
		return self.phantomDic[self.phantomId] or self:getConfig("skin_id")
	end
end

function Ship:updateSkinId(arg_54_1, arg_54_2)
	if not arg_54_1 or arg_54_1 == 0 then
		arg_54_1 = self:getConfig("skin_id")
	end

	if arg_54_2 == 0 then
		self.skinId = arg_54_1
	else
		self.phantomDic[arg_54_2] = arg_54_1
	end
end

function Ship:getAllShipPhantomMarks()
	local var_55_0 = {}

	for iter_55_0 = 0, getGameset("technology_shadow_num")[1] do
		if iter_55_0 == 0 or self.phantomDic[iter_55_0] then
			table.insert(var_55_0, ShipPhantom.PackMark(self.id, iter_55_0))
		end
	end

	return var_55_0
end

function Ship:getAllShipPhantom()
	local var_56_0 = {}

	for iter_56_0 = 0, getGameset("technology_shadow_num")[1] do
		if iter_56_0 == 0 or self.phantomDic[iter_56_0] then
			table.insert(var_56_0, ShipPhantom.Create(self, iter_56_0))
		end
	end

	return var_56_0
end

function Ship:updateRandomFlag(arg_57_1, arg_57_2)
	arg_57_2 = defaultValue(arg_57_2, 0)
	self.phantomRandomFlag[arg_57_2] = arg_57_1
end

function Ship:getRandomFlag(arg_58_1)
	return defaultValue(self.phantomRandomFlag[arg_58_1 or 0], 0) > 0
end

function Ship:getRandomFlagShipPhantomMarks()
	local var_59_0 = {}

	for iter_59_0 = 0, getGameset("technology_shadow_num")[1] do
		if defaultValue(self.phantomRandomFlag[iter_59_0], 0) > 0 then
			table.insert(var_59_0, self:GetShipPhantomMark(iter_59_0))
		end
	end

	return var_59_0
end

function Ship:updateName()
	if self.name ~= pg.ship_data_statistics[self.configId].name then
		return
	end

	self.name = self:isRemoulded() and pg.ship_skin_template[self:getRemouldSkinId()].name or pg.ship_data_statistics[self.configId].name
end

function Ship:isRemoulded()
	if self.remoulded then
		return true
	end

	if pg.ship_data_trans[self.groupId] then
		for iter_61_0, iter_61_1 in ipairs(pg.ship_data_trans[self.groupId].transform_list) do
			for iter_61_2, iter_61_3 in ipairs(iter_61_1) do
				if pg.transform_data_template[iter_61_3[2]].skin_id ~= 0 and self.transforms[iter_61_3[2]] and self.transforms[iter_61_3[2]].level == pg.transform_data_template[iter_61_3[2]].max_level then
					return true
				end
			end
		end
	end

	return false
end

function Ship:getRemouldSkinId()
	local var_62_0 = ShipGroup.getModSkin(self.groupId)

	if var_62_0 then
		return var_62_0.id
	end

	return nil
end

function Ship:hasEquipmentSkinInPos(arg_63_1)
	return self.equipments[arg_63_1] and self.equipments[arg_63_1]:hasSkin()
end

function Ship:getPrefab(arg_64_1)
	local var_64_0 = self:getSkinId()

	if self:hasEquipmentSkinInPos(var_0_2) then
		local var_64_1 = var_0_7[self:getEquip(var_0_2):getSkinId()].ship_skin_id

		var_64_0 = var_64_1 ~= 0 and var_64_1 or var_64_0
	end

	local var_64_2 = pg.ship_skin_template[var_64_0]

	assert(pg.ship_skin_template[var_64_0], "ship_skin_template not exist: " .. self.configId .. " " .. var_64_0)

	if var_64_2.double_char and var_64_2.double_char == 1 and arg_64_1 ~= nil then
		if arg_64_1 == 1 then
			return var_64_2.prefab .. "_L"
		elseif arg_64_1 == 2 then
			return var_64_2.prefab .. "_R"
		end
	end

	return var_64_2.prefab
end

function Ship:IsDoubleSkin()
	local var_65_0 = self:getSkinId()
	local var_65_1 = pg.ship_skin_template[var_65_0]

	assert(pg.ship_skin_template[var_65_0], "ship_skin_template not exist: " .. self.configId .. " " .. var_65_0)

	return var_65_1.double_char and var_65_1.double_char == 1 or false
end

function Ship:getAttachmentPrefab()
	local var_66_0 = {}

	for iter_66_0, iter_66_1 in ipairs(self.equipments) do
		if iter_66_1 and iter_66_1:hasSkinOrbit() then
			local var_66_1 = iter_66_1:getSkinId()

			var_66_0[var_66_1] = {
				config = var_0_7[var_66_1],
				index = iter_66_0
			}
		end
	end

	return var_66_0
end

function Ship:getPainting()
	local var_67_0 = self:getSkinId()

	assert(pg.ship_skin_template[var_67_0], "ship_skin_template not exist: " .. self.configId .. " " .. var_67_0)

	return pg.ship_skin_template[var_67_0].painting
end

function Ship:GetSkinConfig(arg_68_1)
	local var_68_0 = self:getSkinId()

	assert(pg.ship_skin_template[var_68_0], "ship_skin_template not exist: " .. self.configId .. " " .. var_68_0)

	return pg.ship_skin_template[var_68_0]
end

function Ship:getRemouldPainting()
	local var_69_0 = self:getRemouldSkinId()

	assert(pg.ship_skin_template[var_69_0], "ship_skin_template not exist: " .. self.configId .. " " .. var_69_0)

	return pg.ship_skin_template[var_69_0].painting
end

function Ship:isTestShip()
	return self.testShip
end

function Ship:canUseTestShip(arg_71_1)
	assert(self.testShip, "ship is not TestShip")

	return table.contains(self.testShip, arg_71_1)
end

function Ship:updateEquip(arg_72_1, arg_72_2)
	assert(arg_72_2 == nil or arg_72_2.count == 1)

	local var_72_0 = self.equipments[arg_72_1]

	self.equipments[arg_72_1] = arg_72_2 and Clone(arg_72_2) or false

	local function var_72_2(arg_73_0)
		arg_73_0 = CreateShell(arg_73_0)
		arg_73_0.shipId = self.id
		arg_73_0.shipPos = arg_72_1

		return arg_73_0
	end

	if var_72_0 then
		getProxy(EquipmentProxy):OnShipEquipsRemove(var_72_0, self.id, arg_72_1)
		var_72_0:setSkinId(0)
		pg.m02:sendNotification(BayProxy.SHIP_EQUIPMENT_REMOVED, var_72_2(var_72_0))
	end

	if arg_72_2 then
		getProxy(EquipmentProxy):OnShipEquipsAdd(arg_72_2, self.id, arg_72_1)
		self:reletiveEquipSkin(arg_72_1)
		pg.m02:sendNotification(BayProxy.SHIP_EQUIPMENT_ADDED, var_72_2(arg_72_2))
	end
end

function Ship:reletiveEquipSkin(arg_74_1)
	if self.equipments[arg_74_1] and self.equipmentSkins[arg_74_1] ~= 0 then
		if table.contains(pg.equip_skin_template[self.equipmentSkins[arg_74_1]].equip_type, (self.equipments[arg_74_1]:getType())) then
			self.equipments[arg_74_1]:setSkinId(self.equipmentSkins[arg_74_1])
		else
			self.equipments[arg_74_1]:setSkinId(0)
		end
	elseif self.equipments[arg_74_1] then
		self.equipments[arg_74_1]:setSkinId(0)
	end
end

function Ship:updateEquipmentSkin(arg_75_1, arg_75_2)
	if not arg_75_1 then
		return
	end

	if arg_75_2 and arg_75_2 > 0 then
		local var_75_0 = pg.equip_skin_template[arg_75_2].equip_type
		local var_75_1 = false

		for iter_75_0, iter_75_1 in ipairs((self:getSkinTypes(arg_75_1))) do
			for iter_75_2, iter_75_3 in ipairs(var_75_0) do
				if iter_75_1 == iter_75_3 then
					var_75_1 = true

					break
				end
			end
		end

		if not var_75_1 then
			assert(var_75_1, "部位" .. arg_75_1 .. " 无法穿戴皮肤 " .. arg_75_2)

			return
		end

		local var_75_2 = self.equipments[arg_75_1] and self.equipments[arg_75_1]:getType() or false

		self.equipmentSkins[arg_75_1] = arg_75_2

		if var_75_2 and table.contains(var_75_0, var_75_2) then
			self.equipments[arg_75_1]:setSkinId(self.equipmentSkins[arg_75_1])
		elseif var_75_2 and not table.contains(var_75_0, var_75_2) then
			self.equipments[arg_75_1]:setSkinId(0)
		end
	else
		self.equipmentSkins[arg_75_1] = 0

		if self.equipments[arg_75_1] then
			self.equipments[arg_75_1]:setSkinId(0)
		end
	end
end

function Ship:getEquip(arg_76_1)
	return Clone(self.equipments[arg_76_1])
end

function Ship:getEquipSkins()
	return Clone(self.equipmentSkins)
end

function Ship:getEquipSkin(arg_78_1)
	return self.equipmentSkins[arg_78_1]
end

function Ship:getCanEquipSkin(arg_79_1)
	local var_79_0 = self:getSkinTypes(arg_79_1)

	if var_79_0 and #var_79_0 then
		for iter_79_0, iter_79_1 in ipairs(var_79_0) do
			if pg.equip_data_by_type[iter_79_1].equip_skin == 1 then
				return true
			end
		end
	end

	return false
end

function Ship:checkCanEquipSkin(arg_80_1, arg_80_2)
	if not arg_80_1 or not arg_80_2 then
		return
	end

	for iter_80_0, iter_80_1 in ipairs((self:getSkinTypes(arg_80_1))) do
		if table.contains(pg.equip_skin_template[arg_80_2].equip_type, iter_80_1) then
			return true
		end
	end

	return false
end

function Ship:getSkinTypes(arg_81_1)
	return pg.ship_data_template[self.configId]["equip_" .. arg_81_1] or {}
end

function Ship:addSkillExp(arg_82_1, arg_82_2)
	local var_82_0 = self.skills[arg_82_1] or {
		exp = 0,
		level = 1,
		id = arg_82_1
	}
	local var_82_1

	if var_82_0.level then
		var_82_1 = var_82_0.level or 1
	end

	local var_82_2 = pg.skill_need_exp.all[#pg.skill_need_exp.all]

	if var_82_1 == pg.skill_need_exp.all[#pg.skill_need_exp.all] then
		return
	end

	local var_82_3

	if var_82_0.exp then
		var_82_3 = arg_82_2 + var_82_0.exp or 0 + arg_82_2

		while var_82_3 >= pg.skill_need_exp[var_82_1].exp do
			var_82_3 = var_82_3 - pg.skill_need_exp[var_82_1].exp
			var_82_1 = var_82_1 + 1

			if var_82_1 == var_82_2 then
				var_82_3 = 0

				break
			end
		end
	end

	self:updateSkill({
		id = var_82_0.id,
		level = var_82_1,
		exp = var_82_3
	})
end

function Ship:upSkillLevelForMeta(arg_83_1)
	local var_83_0 = self.skills[arg_83_1]
	local var_83_1

	if not self.skills[arg_83_1] then
		var_83_0 = {
			exp = 0,
			level = 0,
			id = arg_83_1
		}
		var_83_1 = var_83_0.level
	end

	if not self:isSkillLevelMax(arg_83_1) then
		var_83_1 = var_83_1 + 1
	end

	self:updateSkill({
		exp = 0,
		id = var_83_0.id,
		level = var_83_1
	})
end

function Ship:getMetaSkillLevelBySkillID(arg_84_1)
	return (self.skills[arg_84_1] or {
		exp = 0,
		level = 0,
		id = arg_84_1
	}).level
end

function Ship:isSkillLevelMax(arg_85_1)
	local var_85_0 = self.skills[arg_85_1] or {
		exp = 0,
		level = 1,
		id = arg_85_1
	}

	return ((var_85_0.level or nil) and (var_85_0.level or 1)) >= pg.skill_data_template[arg_85_1].max_level
end

function Ship:isAllMetaSkillLevelMax()
	local var_86_0 = true

	for iter_86_0, iter_86_1 in ipairs((MetaCharacterConst.getTacticsSkillIDListByShipConfigID(self.configId))) do
		if not self:isSkillLevelMax(iter_86_1) then
			var_86_0 = false

			break
		end
	end

	return var_86_0
end

function Ship:isAllMetaSkillLock()
	local var_87_0 = true

	for iter_87_0, iter_87_1 in ipairs((MetaCharacterConst.getTacticsSkillIDListByShipConfigID(self.configId))) do
		if self:getMetaSkillLevelBySkillID(iter_87_1) > 0 then
			var_87_0 = false

			break
		end
	end

	return var_87_0
end

function Ship:bindConfigTable()
	return pg.ship_data_statistics
end

function Ship:isAvaiable()
	return true
end

Ship.PROPERTIES = {
	AttributeType.Durability,
	AttributeType.Cannon,
	AttributeType.Torpedo,
	AttributeType.AntiAircraft,
	AttributeType.Air,
	AttributeType.Reload,
	AttributeType.Armor,
	AttributeType.Hit,
	AttributeType.Dodge,
	AttributeType.Speed,
	AttributeType.Luck,
	AttributeType.AntiSub
}
Ship.PROPERTIES_ENHANCEMENT = {
	AttributeType.Durability,
	AttributeType.Cannon,
	AttributeType.Torpedo,
	AttributeType.AntiAircraft,
	AttributeType.Air,
	AttributeType.Reload,
	AttributeType.Hit,
	AttributeType.Dodge,
	AttributeType.Speed,
	AttributeType.Luck,
	AttributeType.AntiSub
}
Ship.DIVE_PROPERTIES = {
	AttributeType.OxyMax,
	AttributeType.OxyCost,
	AttributeType.OxyRecovery,
	AttributeType.OxyRecoveryBench,
	AttributeType.OxyRecoverySurface,
	AttributeType.OxyAttackDuration,
	AttributeType.OxyRaidDistance
}
Ship.SONAR_PROPERTIES = {
	AttributeType.SonarRange
}

function Ship:intimacyAdditions(arg_90_1)
	local var_90_0 = pg.intimacy_template[self:getIntimacyLevel()].attr_bonus * 0.0001

	for iter_90_0, iter_90_1 in pairs(arg_90_1) do
		if iter_90_0 == AttributeType.Durability or iter_90_0 == AttributeType.Cannon or iter_90_0 == AttributeType.Torpedo or iter_90_0 == AttributeType.AntiAircraft or iter_90_0 == AttributeType.AntiSub or iter_90_0 == AttributeType.Air or iter_90_0 == AttributeType.Reload or iter_90_0 == AttributeType.Hit or iter_90_0 == AttributeType.Dodge then
			arg_90_1[iter_90_0] = arg_90_1[iter_90_0] * (var_90_0 + 1)
		end
	end
end

function Ship:getShipProperties()
	local var_91_0 = self:getBaseProperties()

	if self:isBluePrintShip() then
		local var_91_1 = self:getBluePrint()

		assert(var_91_1, "blueprint can not be nil" .. self.configId)

		for iter_91_0, iter_91_1 in pairs((var_91_1:getTotalAdditions())) do
			var_91_0[iter_91_0] = var_91_0[iter_91_0] + calcFloor(iter_91_1)
		end

		self:intimacyAdditions(var_91_0)
	elseif self:isMetaShip() then
		assert(self.metaCharacter)

		for iter_91_2, iter_91_3 in pairs(var_91_0) do
			var_91_0[iter_91_2] = var_91_0[iter_91_2] + self.metaCharacter:getAttrAddition(iter_91_2)
		end

		self:intimacyAdditions(var_91_0)
	else
		local var_91_2 = var_0_5[pg.ship_data_template[self.configId].strengthen_id]

		for iter_91_4, iter_91_5 in pairs(self.strengthList) do
			var_91_0[iter_91_4] = var_91_0[iter_91_4] + calcFloor(math.min(iter_91_5, var_91_2.durability[ShipModAttr.ATTR_TO_INDEX[iter_91_4]] * var_91_2.level_exp[ShipModAttr.ATTR_TO_INDEX[iter_91_4]]) / math.max(self:getModExpRatio(iter_91_4), 1))
		end

		self:intimacyAdditions(var_91_0)

		for iter_91_6, iter_91_7 in pairs(self.transforms) do
			for iter_91_8 = 1, iter_91_7.level do
				local var_91_3 = pg.transform_data_template[iter_91_7.id].effect[iter_91_8] or {}

				for iter_91_9, iter_91_10 in pairs(var_91_0) do
					if var_91_3[iter_91_9] then
						var_91_0[iter_91_9] = var_91_0[iter_91_9] + var_91_3[iter_91_9]
					end
				end
			end
		end
	end

	return var_91_0
end

function Ship:getTechNationAddition(arg_92_1)
	local var_92_0 = getProxy(TechnologyNationProxy)
	local var_92_1 = self:getConfig("type")

	if var_92_1 == ShipType.DaoQuV or var_92_1 == ShipType.DaoQuM then
		var_92_1 = ShipType.QuZhu
	end

	return var_92_0:getShipAddition(var_92_1, arg_92_1)
end

function Ship:getTechNationMaxAddition(arg_93_1)
	return getProxy(TechnologyNationProxy):getShipMaxAddition(self:getConfig("type"), arg_93_1)
end

function Ship:getEquipProficiencyByPos(arg_94_1)
	return self:getEquipProficiencyList()[arg_94_1]
end

function Ship:getEquipProficiencyList()
	local var_95_0 = Clone(self:getConfigTable().equipment_proficiency)

	if self:isBluePrintShip() then
		local var_95_1 = self:getBluePrint()

		assert(var_95_1, "blueprint can not be nil >>>" .. self.groupId)

		var_95_0 = var_95_1:getEquipProficiencyList(self)
	else
		for iter_95_0, iter_95_1 in ipairs(var_95_0) do
			local var_95_2 = 0

			for iter_95_2, iter_95_3 in pairs(self.transforms) do
				for iter_95_4 = 1, iter_95_3.level do
					local var_95_3 = pg.transform_data_template[iter_95_3.id].effect[iter_95_4] or {}

					if var_95_3["equipment_proficiency_" .. iter_95_0] then
						var_95_2 = var_95_2 + var_95_3["equipment_proficiency_" .. iter_95_0]
					end
				end
			end

			var_95_0[iter_95_0] = iter_95_1 + var_95_2
		end
	end

	return var_95_0
end

function Ship:getBaseProperties()
	local var_96_0 = self:getConfigTable()

	assert(var_96_0, "配置表没有这艘船" .. self.configId)

	local var_96_1 = {}
	local var_96_2 = {}

	for iter_96_0, iter_96_1 in ipairs(Ship.PROPERTIES) do
		var_96_1[iter_96_1] = self:getGrowthForAttr(iter_96_1)
		var_96_2[iter_96_1] = var_96_1[iter_96_1]
	end

	for iter_96_2, iter_96_3 in ipairs(self:getConfig("lock")) do
		var_96_2[iter_96_3] = var_96_1[iter_96_3]
	end

	for iter_96_4, iter_96_5 in ipairs(Ship.DIVE_PROPERTIES) do
		var_96_2[iter_96_5] = var_96_0[iter_96_5]
	end

	for iter_96_6, iter_96_7 in ipairs(Ship.SONAR_PROPERTIES) do
		var_96_2[iter_96_7] = 0
	end

	return var_96_2
end

function Ship:getGrowthForAttr(arg_97_1)
	local var_97_0 = self:getConfigTable()
	local var_97_1 = table.indexof(Ship.PROPERTIES, arg_97_1)
	local var_97_2 = var_97_0.attrs[var_97_1] + (self.level - 1) * var_97_0.attrs_growth[var_97_1] / 1000

	if pg.gameset.extra_attr_level_limit.key_value < self.level then
		var_97_2 = var_97_2 + (self.level - pg.gameset.extra_attr_level_limit.key_value) * var_97_0.attrs_growth_extra[var_97_1] / 1000
	end

	return var_97_2
end

function Ship:isMaxStar()
	return self:getStar() >= self:getMaxStar()
end

function Ship:IsMaxStarByTmpID()
	return pg.ship_data_template[self].star >= pg.ship_data_template[self].star_max
end

function Ship:IsSpweaponUnlock()
	if not self:CanAccumulateExp() then
		return false, "spweapon_tip_locked"
	else
		return true
	end
end

function Ship:getModProperties(arg_101_1)
	return self.strengthList[arg_101_1] or 0
end

function Ship:addModAttrExp(arg_102_1, arg_102_2)
	local var_102_0 = self:getModAttrTopLimit(arg_102_1)

	if var_102_0 == 0 then
		return
	end

	local var_102_1 = self:getModExpRatio(arg_102_1)
	local var_102_2 = self:getModProperties(arg_102_1)

	self.strengthList[arg_102_1] = var_102_2 + arg_102_2 > var_102_0 * var_102_1 and var_102_0 * var_102_1 or var_102_2 + arg_102_2
end

function Ship:getNeedModExp()
	local var_103_0 = {}

	for iter_103_0, iter_103_1 in pairs(ShipModAttr.ID_TO_ATTR) do
		local var_103_1 = self:getModAttrTopLimit(iter_103_1)

		var_103_0[iter_103_1] = var_103_1 == 0 and 0 or var_103_1 * self:getModExpRatio(iter_103_1) - self:getModProperties(iter_103_1)
	end

	return var_103_0
end

function Ship:attrVertify()
	if not BayProxy.checkShiplevelVertify(self) then
		return false
	end

	for iter_104_0, iter_104_1 in ipairs(self.equipments) do
		if iter_104_1 and not iter_104_1:vertify() then
			return false
		end
	end

	return true
end

function Ship:getEquipmentProperties()
	local var_105_0 = {}
	local var_105_1 = {}

	for iter_105_0, iter_105_1 in ipairs(Ship.PROPERTIES) do
		var_105_0[iter_105_1] = 0
	end

	for iter_105_2, iter_105_3 in ipairs(Ship.DIVE_PROPERTIES) do
		var_105_0[iter_105_3] = 0
	end

	for iter_105_4, iter_105_5 in ipairs(Ship.SONAR_PROPERTIES) do
		var_105_0[iter_105_5] = 0
	end

	for iter_105_6, iter_105_7 in ipairs(Ship.PROPERTIES_ENHANCEMENT) do
		var_105_1[iter_105_7] = 0
	end

	var_105_0[AttributeType.AirDominate] = 0
	var_105_0[AttributeType.AntiSiren] = 0

	for iter_105_8, iter_105_9 in ipairs((self:getActiveEquipments())) do
		if iter_105_9 then
			for iter_105_10, iter_105_11 in ipairs((iter_105_9:GetAttributes())) do
				if iter_105_11 and var_105_0[iter_105_11.type] then
					var_105_0[iter_105_11.type] = var_105_0[iter_105_11.type] + iter_105_11.value
				end
			end

			for iter_105_12, iter_105_13 in pairs((iter_105_9:GetPropertyRate())) do
				var_105_1[iter_105_12] = math.max(var_105_1[iter_105_12], iter_105_13)
			end

			local var_105_2 = iter_105_9:GetSonarProperty()

			if var_105_2 then
				for iter_105_14, iter_105_15 in pairs(var_105_2) do
					var_105_0[iter_105_14] = var_105_0[iter_105_14] + iter_105_15
				end
			end

			local var_105_3 = iter_105_9:GetAntiSirenPower()

			if var_105_3 then
				var_105_0[AttributeType.AntiSiren] = var_105_0[AttributeType.AntiSiren] + var_105_3 / 10000
			end
		end
	end

	;(function()
		local var_106_0 = self:GetSpWeapon()

		if not var_106_0 then
			return
		end

		for iter_106_0, iter_106_1 in ipairs(var_106_0:GetPropertiesInfo().attrs) do
			if iter_106_1 and var_105_0[iter_106_1.type] then
				var_105_0[iter_106_1.type] = var_105_0[iter_106_1.type] + iter_106_1.value
			end
		end
	end)()

	for iter_105_16, iter_105_17 in pairs(var_105_1) do
		var_105_1[iter_105_16] = iter_105_17 + 1
	end

	return var_105_0, var_105_1
end

function Ship:getSkillEffects()
	local var_107_0 = self:getShipSkillEffects()

	_.each(self:getEquipmentSkillEffects(), function(arg_108_0)
		table.insert(var_107_0, arg_108_0)
	end)

	return var_107_0
end

function Ship:getShipSkillEffects()
	local var_109_0 = {}

	for iter_109_0, iter_109_1 in ipairs((self:getSkillList())) do
		self:FilterActiveSkill(var_109_0, pg.buffCfg["buff_" .. self:RemapSkillId(iter_109_1, true)], self.skills[iter_109_1])
	end

	return var_109_0
end

function Ship:getEquipmentSkillEffects()
	local var_110_0 = {}

	for iter_110_0, iter_110_1 in ipairs((self:getActiveEquipments())) do
		local var_110_2 = iter_110_1 and iter_110_1:getConfig("skill_id")[1] and iter_110_1:getConfig("skill_id")[1][1]

		self:FilterActiveSkill(var_110_0, (var_110_2 or nil) and pg.buffCfg["buff_" .. var_110_2])
	end

	;(function()
		local var_111_0 = self:GetSpWeapon()
		local var_111_1 = var_111_0 and var_111_0:GetEffect() or 0

		self:FilterActiveSkill(var_110_0, (var_111_1 > 0 or nil) and pg.buffCfg["buff_" .. var_111_1])
	end)()

	return var_110_0
end

function Ship:FilterActiveSkill(arg_112_1, arg_112_2, arg_112_3)
	if not arg_112_2 or not arg_112_2.const_effect_list then
		return
	end

	for iter_112_0 = 1, #arg_112_2.const_effect_list do
		local var_112_0 = arg_112_2.const_effect_list[iter_112_0].trigger
		local var_112_1 = arg_112_2.const_effect_list[iter_112_0].arg_list
		local var_112_2 = 1

		if arg_112_3 then
			var_112_2 = arg_112_3.level

			if arg_112_2[arg_112_3.level].const_effect_list and arg_112_2[arg_112_3.level].const_effect_list[iter_112_0] then
				var_112_0 = arg_112_2[arg_112_3.level].const_effect_list[iter_112_0].trigger or var_112_0
				var_112_1 = arg_112_2[arg_112_3.level].const_effect_list[iter_112_0].arg_list or var_112_1
			end
		end

		local var_112_3 = true

		for iter_112_1, iter_112_2 in pairs(var_112_0) do
			if self.triggers[iter_112_1] ~= iter_112_2 then
				var_112_3 = false

				break
			end
		end

		if var_112_3 then
			table.insert(arg_112_1, {
				type = arg_112_2.const_effect_list[iter_112_0].type,
				arg_list = var_112_1,
				level = var_112_2
			})
		end
	end
end

function Ship:getEquipmentGearScore()
	local var_113_0 = 0

	for iter_113_0, iter_113_1 in ipairs((self:getActiveEquipments())) do
		if iter_113_1 then
			var_113_0 = var_113_0 + iter_113_1:GetGearScore()
		end
	end

	return var_113_0
end

function Ship:getProperties(arg_114_1, arg_114_2, arg_114_3, arg_114_4)
	local var_114_0 = arg_114_1 or {}
	local var_114_1 = self:getConfig("nationality")
	local var_114_2 = self:getConfig("type")
	local var_114_3 = self:getShipProperties()
	local var_114_4, var_114_5 = self:getEquipmentProperties()
	local var_114_6
	local var_114_7
	local var_114_8

	if arg_114_3 and self:getFlag("inWorld") then
		local var_114_9 = WorldConst.FetchWorldShip(self.id)

		var_114_6, var_114_7 = var_114_9:GetShipBuffProperties()
		var_114_8 = var_114_9:GetShipPowerBuffProperties()
	end

	for iter_114_0, iter_114_1 in ipairs(Ship.PROPERTIES) do
		local var_114_10 = 0
		local var_114_11 = 0

		for iter_114_2, iter_114_3 in pairs(var_114_0) do
			var_114_10 = var_114_10 + iter_114_3:getAttrRatioAddition(iter_114_1, var_114_1, var_114_2) / 100
			var_114_11 = var_114_11 + iter_114_3:getAttrValueAddition(iter_114_1, var_114_1, var_114_2)
		end

		local var_114_12 = var_114_10 + (var_114_5[iter_114_1] or 1)
		local var_114_13

		if var_114_7 then
			var_114_13 = var_114_7[iter_114_1] or 1

			local var_114_14

			if var_114_6 then
				var_114_14 = var_114_6[iter_114_1] or 0

				if iter_114_1 == AttributeType.Speed then
					var_114_3[iter_114_1] = var_114_3[iter_114_1] * var_114_12 * var_114_13 + var_114_11 + var_114_4[iter_114_1] + var_114_14

					goto label_114_0
				end
			end
		end

		var_114_3[iter_114_1] = calcFloor(calcFloor(var_114_3[iter_114_1]) * var_114_12 * var_114_13) + var_114_11 + var_114_4[iter_114_1] + var_114_14

		::label_114_0::
	end

	if not arg_114_2 and self:isMaxStar() then
		for iter_114_4, iter_114_5 in pairs(var_114_3) do
			var_114_3[iter_114_4] = var_114_3[iter_114_4] + (arg_114_4 and self:getTechNationMaxAddition(iter_114_4) or self:getTechNationAddition(iter_114_4))
		end
	end

	for iter_114_6, iter_114_7 in ipairs(Ship.DIVE_PROPERTIES) do
		var_114_3[iter_114_7] = var_114_3[iter_114_7] + var_114_4[iter_114_7]
	end

	for iter_114_8, iter_114_9 in ipairs(Ship.SONAR_PROPERTIES) do
		var_114_3[iter_114_9] = var_114_3[iter_114_9] + var_114_4[iter_114_9]
	end

	if arg_114_3 then
		var_114_3[AttributeType.AntiSiren] = (var_114_3[AttributeType.AntiSiren] or 0) + var_114_4[AttributeType.AntiSiren]
	end

	if var_114_8 then
		for iter_114_10, iter_114_11 in pairs(var_114_8) do
			if var_114_3[iter_114_10] then
				var_114_3[iter_114_10] = iter_114_10 == AttributeType.Speed and var_114_3[iter_114_10] * iter_114_11 or math.floor(var_114_3[iter_114_10] * iter_114_11)
			end
		end
	end

	return var_114_3
end

function Ship:getTransGearScore()
	local var_115_0 = 0

	for iter_115_0, iter_115_1 in pairs(self.transforms) do
		for iter_115_2 = 1, iter_115_1.level do
			var_115_0 = var_115_0 + (pg.transform_data_template[iter_115_1.id].gear_score[iter_115_2] or 0)
		end
	end

	return var_115_0
end

function Ship:getShipCombatPower(arg_116_1)
	local var_116_0 = self:getProperties(arg_116_1, nil, nil, true)

	return math.floor(var_116_0[AttributeType.Durability] / 5 + var_116_0[AttributeType.Cannon] + var_116_0[AttributeType.Torpedo] + var_116_0[AttributeType.AntiAircraft] + var_116_0[AttributeType.Air] + var_116_0[AttributeType.AntiSub] + var_116_0[AttributeType.Reload] + var_116_0[AttributeType.Hit] * 2 + var_116_0[AttributeType.Dodge] * 2 + var_116_0[AttributeType.Speed] + self:getEquipmentGearScore() + self:getTransGearScore())
end

function Ship:cosumeEnergy(arg_117_1)
	self:setEnergy(math.max(self:getEnergy() - arg_117_1, 0))
end

function Ship:addEnergy(arg_118_1)
	self:setEnergy(self:getEnergy() + arg_118_1)
end

function Ship:setEnergy(arg_119_1)
	self.energy = arg_119_1
end

function Ship:setLikability(arg_120_1)
	assert(arg_120_1 >= 0 and arg_120_1 <= self.maxIntimacy, "intimacy value invaild" .. arg_120_1)
	self:setIntimacy(arg_120_1)
end

function Ship:addLikability(arg_121_1)
	self:setIntimacy((Mathf.Clamp(self:getIntimacy() + arg_121_1, 0, self.maxIntimacy)))
end

function Ship:setIntimacy(arg_122_1)
	if arg_122_1 > 10000 and not self.propose then
		arg_122_1 = 10000
	end

	self.intimacy = arg_122_1

	if not self:isActivityNpc() then
		getProxy(CollectionProxy).shipGroups[self.groupId]:updateMaxIntimacy(self:getIntimacy())
	end
end

function Ship:getLevelExpConfig(arg_123_1)
	if self:getConfig("rarity") == ShipRarity.SSR then
		local var_123_0 = Clone(getConfigFromLevel1(var_0_6, arg_123_1 or self.level))

		var_123_0.exp = var_123_0.exp_ur
		var_123_0.exp_start = var_123_0.exp_ur_start
		var_123_0.exp_interval = var_123_0.exp_ur_interval
		var_123_0.exp_end = var_123_0.exp_ur_end

		return var_123_0
	else
		return getConfigFromLevel1(var_0_6, arg_123_1 or self.level)
	end
end

function Ship:getExp()
	if self.level == self:getMaxLevel() and LOCK_FULL_EXP then
		return 0
	end

	return self.exp
end

function Ship:getProficiency()
	return self.proficiency
end

function Ship:addExp(arg_126_1, arg_126_2)
	local var_126_0 = self:getMaxLevel()

	if self.level == var_126_0 then
		if self.exp >= pg.gameset.exp_overflow_max.key_value then
			return
		end

		if LOCK_FULL_EXP or not arg_126_2 or not self:CanAccumulateExp() then
			arg_126_1 = 0
		end
	end

	self.exp = self.exp + arg_126_1

	local var_126_1 = false

	while self:canLevelUp() do
		self.exp = self.exp - self:getLevelExpConfig().exp_interval
		self.level = math.min(self.level + 1, var_126_0)
		var_126_1 = true
	end

	if self.level == var_126_0 then
		if arg_126_2 and self:CanAccumulateExp() then
			self.exp = math.min(self.exp, pg.gameset.exp_overflow_max.key_value)
		elseif var_126_1 then
			self.exp = 0
		end
	end
end

function Ship:getMaxLevel()
	return self.maxLevel
end

function Ship:canLevelUp()
	return self:getLevelExpConfig(self.level + 1) and self:getLevelExpConfig().exp_interval <= self.exp and self:getMaxLevel() > self.level
end

function Ship:getConfigMaxLevel()
	return var_0_6.all[#var_0_6.all]
end

function Ship:isConfigMaxLevel()
	return self.level == self:getConfigMaxLevel()
end

function Ship:updateMaxLevel(arg_131_1)
	self.maxLevel = math.max(math.min(self:getConfigMaxLevel(), arg_131_1), self.maxLevel)
end

function Ship:getNextMaxLevel()
	for iter_132_0 = self:getMaxLevel() + 1, self:getConfigMaxLevel() do
		if var_0_6[iter_132_0].level_limit == 1 then
			return iter_132_0
		end
	end
end

function Ship:canUpgrade()
	if self:isBluePrintShip() then
		return false
	end

	if self:isMetaShip() then
		local var_133_0 = self:getMetaCharacter()

		if not var_133_0 then
			return false
		end

		local var_133_1 = var_133_0:getBreakOutInfo()

		if not var_133_1:hasNextInfo() then
			return false
		end

		local var_133_2, var_133_3 = var_133_1:getLimited()

		if var_133_2 > self.level then
			return false
		end

		return true
	else
		local var_133_4 = var_0_8[self.configId]

		assert(var_0_8[self.configId], "不存在配置" .. self.configId)

		return not self:isMaxStar() and self.level >= var_133_4.level
	end
end

function Ship:isReachNextMaxLevel()
	return self.level == self:getMaxLevel() and self:CanAccumulateExp() and self:getNextMaxLevel() ~= nil
end

function Ship:isAwakening()
	return self:isReachNextMaxLevel() and self.level < var_0_4
end

function Ship:isAwakening2()
	return self:isReachNextMaxLevel() and self.level >= var_0_4
end

function Ship:notMaxLevelForFilter()
	return self.level ~= self:getMaxLevel()
end

function Ship:getNextMaxLevelConsume()
	local var_138_0 = var_0_6[self:getMaxLevel()]["need_item_rarity" .. self:getConfig("rarity")]

	assert(var_138_0, "items  can not be nil")

	return _.map(var_138_0, function(arg_139_0)
		return {
			type = arg_139_0[1],
			id = arg_139_0[2],
			count = arg_139_0[3]
		}
	end)
end

function Ship:canUpgradeMaxLevel()
	if not self:isReachNextMaxLevel() then
		return false, i18n("upgrade_to_next_maxlevel_failed")
	else
		local var_140_0 = getProxy(PlayerProxy):getData()
		local var_140_1 = getProxy(BagProxy)

		for iter_140_0, iter_140_1 in pairs((self:getNextMaxLevelConsume())) do
			if iter_140_1.type == DROP_TYPE_RESOURCE then
				if var_140_0:getResById(iter_140_1.id) < iter_140_1.count then
					return false, i18n("common_no_resource")
				end
			elseif iter_140_1.type == DROP_TYPE_ITEM and var_140_1:getItemCountById(iter_140_1.id) < iter_140_1.count then
				return false, i18n("common_no_item_1")
			end
		end
	end

	return true
end

function Ship:CanAccumulateExp()
	return pg.ship_data_template[self.configId].can_get_proficency == 1
end

function Ship:getTotalExp()
	return self:getLevelExpConfig().exp_start + self.exp
end

function Ship:getStartBattleExpend()
	if table.contains(ShipType.SubShipType, self:getShipType()) then
		return 0
	else
		return pg.ship_data_template[self.configId].oil_at_start
	end
end

function Ship:getEndBattleExpend()
	return (math.floor(pg.ship_data_template[self.configId].oil_at_end * self:getLevelExpConfig().fight_oil_ratio / 10000))
end

function Ship:getBattleTotalExpend()
	return self:getStartBattleExpend() + self:getEndBattleExpend()
end

function Ship:getShipAmmo()
	local var_146_0 = self:getConfig(AttributeType.Ammo)

	for iter_146_0, iter_146_1 in pairs(self:getAllSkills()) do
		local var_146_1 = pg.skill_benefit_template[tonumber(iter_146_0 .. string.format("%.2d", iter_146_1.level))]

		if var_146_1 and self:IsBenefitSkillActive(var_146_1) and (var_146_1.type == Ship.BENEFIT_EQUIP or var_146_1.type == Ship.BENEFIT_SKILL) then
			var_146_0 = var_146_0 + defaultValue(var_146_1.effect[1], 0)
		end
	end

	for iter_146_2, iter_146_3 in ipairs((self:getActiveEquipments())) do
		local var_146_2 = iter_146_3 and iter_146_3:getConfig("equip_parameters").ammo

		if var_146_2 then
			var_146_0 = var_146_0 + var_146_2
		end
	end

	return var_146_0
end

function Ship:getHuntingLv()
	local var_147_0 = self:getConfig("huntingrange_level")

	for iter_147_0, iter_147_1 in pairs(self:getAllSkills()) do
		local var_147_1 = pg.skill_benefit_template[tonumber(iter_147_0 .. string.format("%.2d", iter_147_1.level))]

		if var_147_1 and self:IsBenefitSkillActive(var_147_1) and (var_147_1.type == Ship.BENEFIT_EQUIP or var_147_1.type == Ship.BENEFIT_SKILL) then
			var_147_0 = var_147_0 + defaultValue(var_147_1.effect[2], 0)
		end
	end

	for iter_147_2, iter_147_3 in ipairs((self:getActiveEquipments())) do
		local var_147_2 = iter_147_3 and iter_147_3:getConfig("equip_parameters").hunting_lv

		if var_147_2 then
			var_147_0 = var_147_0 + var_147_2
		end
	end

	return (math.min(var_147_0, self:getMaxHuntingLv()))
end

function Ship:getMapAuras()
	local var_148_0 = {}

	for iter_148_0, iter_148_1 in pairs(self:getAllSkills()) do
		local var_148_1 = pg.skill_benefit_template[tonumber(iter_148_0 .. string.format("%.2d", iter_148_1.level))]

		if var_148_1 and self:IsBenefitSkillActive(var_148_1) and var_148_1.type == Ship.BENEFIT_MAP_AURA then
			table.insert(var_148_0, {
				id = var_148_1.effect[1],
				level = iter_148_1.level
			})
		end
	end

	return var_148_0
end

function Ship:getMapAids()
	local var_149_0 = {}

	for iter_149_0, iter_149_1 in pairs(self:getAllSkills()) do
		local var_149_1 = pg.skill_benefit_template[tonumber(iter_149_0 .. string.format("%.2d", iter_149_1.level))]

		if var_149_1 and self:IsBenefitSkillActive(var_149_1) and var_149_1.type == Ship.BENEFIT_AID then
			table.insert(var_149_0, {
				id = var_149_1.effect[1],
				level = iter_149_1.level
			})
		end
	end

	return var_149_0
end

Ship.BENEFIT_SKILL = 2
Ship.BENEFIT_EQUIP = 3
Ship.BENEFIT_MAP_AURA = 4
Ship.BENEFIT_AID = 5

function Ship:IsBenefitSkillActive(arg_150_1)
	local var_150_0 = false

	if arg_150_1.type == Ship.BENEFIT_SKILL then
		if not arg_150_1.limit[1] or arg_150_1.limit[1] == self.triggers.TeamNumbers then
			var_150_0 = true
		end
	elseif arg_150_1.type == Ship.BENEFIT_EQUIP then
		for iter_150_0, iter_150_1 in ipairs((self:getAllEquipments())) do
			if iter_150_1 and table.contains(arg_150_1.limit, iter_150_1:getConfig("id")) then
				var_150_0 = true

				break
			end
		end
	elseif arg_150_1.type == Ship.BENEFIT_MAP_AURA then
		if self.hpRant and self.hpRant > 0 then
			return true
		end
	elseif arg_150_1.type == Ship.BENEFIT_AID and self.hpRant and self.hpRant > 0 then
		return true
	end

	return var_150_0
end

function Ship:getMaxHuntingLv()
	return #self:getConfig("hunting_range")
end

function Ship:getHuntingRange(arg_152_1)
	local var_152_0 = self:getConfig("hunting_range")
	local var_152_1 = Clone(var_152_0[1])

	for iter_152_0 = 2, math.min(arg_152_1 or self:getHuntingLv(), self:getMaxHuntingLv()) do
		_.each(var_152_0[iter_152_0], function(arg_153_0)
			table.insert(var_152_1, {
				arg_153_0[1],
				arg_153_0[2]
			})
		end)
	end

	return var_152_1
end

function Ship:getTriggerSkills()
	local var_154_0 = {}

	_.each(self:getSkillEffects(), function(arg_155_0)
		if arg_155_0.type == "AddBuff" and arg_155_0.arg_list and arg_155_0.arg_list.buff_id then
			var_154_0[arg_155_0.arg_list.buff_id] = {
				id = arg_155_0.arg_list.buff_id,
				level = arg_155_0.level
			}
		end
	end)

	return var_154_0
end

function Ship:GetEquipmentSkills()
	local var_156_0 = {}

	for iter_156_0, iter_156_1 in ipairs((self:getActiveEquipments())) do
		if iter_156_1 and iter_156_1:getConfig("skill_id")[1] then
			local var_156_1, var_156_2 = unpack(iter_156_1:getConfig("skill_id")[1])

			var_156_0[var_156_1] = {
				id = var_156_1,
				level = var_156_2
			}
		end
	end

	;(function()
		local var_157_0 = self:GetSpWeapon()
		local var_157_1 = var_157_0 and var_157_0:GetEffect() or 0

		if var_157_1 > 0 then
			var_156_0[var_157_1] = {
				level = 1,
				id = var_157_1
			}
		end
	end)()

	return var_156_0
end

function Ship:getAllSkills()
	local var_158_0 = Clone(self.skills)

	for iter_158_0, iter_158_1 in pairs(self:GetEquipmentSkills()) do
		var_158_0[iter_158_0] = iter_158_1
	end

	for iter_158_2, iter_158_3 in pairs(self:getTriggerSkills()) do
		var_158_0[iter_158_2] = iter_158_3
	end

	return var_158_0
end

function Ship:isSameKind(arg_159_1)
	return pg.ship_data_template[self.configId].group_type == pg.ship_data_template[arg_159_1.configId].group_type
end

function Ship:GetLockState()
	return self.lockState
end

function Ship:IsLocked()
	return self.lockState == Ship.LOCK_STATE_LOCK
end

function Ship:SetLockState(arg_162_1)
	self.lockState = arg_162_1
end

function Ship:GetPreferenceTag()
	return self.preferenceTag or 0
end

function Ship:IsPreferenceTag()
	return self:GetPreferenceTag() == Ship.PREFERENCE_TAG_COMMON
end

function Ship:SetPreferenceTag(arg_165_1)
	self.preferenceTag = arg_165_1
end

function Ship:calReturnRes()
	return pg.ship_data_by_type[self:getShipType()].distory_resource_gold_ratio, 0, pg.ship_data_by_star[self:getConfig("rarity")].destory_item
end

function Ship:getRarity()
	local var_167_0 = self:getConfig("rarity")

	if self:isRemoulded() then
		var_167_0 = var_167_0 + 1
	end

	return var_167_0
end

function Ship:updateSkill(arg_168_1)
	local var_168_0 = arg_168_1.skill_id or arg_168_1.id
	local var_168_1 = arg_168_1.skill_lv or arg_168_1.lv or arg_168_1.level
	local var_168_2 = arg_168_1.skill_exp or arg_168_1.exp

	self.skills[var_168_0] = {
		id = var_168_0,
		level = var_168_1,
		exp = var_168_2
	}
end

function Ship:canEquipAtPos(arg_169_1, arg_169_2)
	local var_169_0, var_169_1 = self:isForbiddenAtPos(arg_169_1, arg_169_2)

	if var_169_0 then
		return false, var_169_1
	end

	for iter_169_0, iter_169_1 in ipairs(self.equipments) do
		if iter_169_1 and iter_169_0 ~= arg_169_2 and iter_169_1:getConfig("equip_limit") ~= 0 and arg_169_1:getConfig("equip_limit") == iter_169_1:getConfig("equip_limit") then
			return false, i18n("ship_equip_same_group_equipment")
		end
	end

	return true
end

function Ship:isForbiddenAtPos(arg_170_1, arg_170_2)
	assert(pg.ship_data_template[self.configId], "can not find ship in ship_data_templtae: " .. self.configId)

	if not table.contains(pg.ship_data_template[self.configId]["equip_" .. arg_170_2], arg_170_1:getConfig("type")) then
		return true, i18n("common_limit_equip")
	end

	if table.contains(arg_170_1:getConfig("ship_type_forbidden"), self:getShipType()) then
		return true, i18n("common_limit_equip")
	end

	return false
end

function Ship:canEquipCommander(arg_171_1)
	if arg_171_1:getShipType() ~= self:getShipType() then
		return false, i18n("commander_type_unmatch")
	end

	return true
end

function Ship:upgrade()
	if pg.ship_data_transform[self.configId].trans_id and pg.ship_data_transform[self.configId].trans_id > 0 then
		self.configId = pg.ship_data_transform[self.configId].trans_id
		self.star = self:getConfig("star")
	end
end

function Ship:getTeamType()
	return ShipType.GetTeamFromShipType(self:getShipType())
end

function Ship:getFleetName()
	return var_0_1[self:getTeamType()]
end

function Ship:getMaxConfigId()
	local var_175_0

	for iter_175_0 = 4, 1, -1 do
		local var_175_1 = tonumber(self.groupId .. iter_175_0)

		if pg.ship_data_template[var_175_1] then
			var_175_0 = var_175_1

			break
		end
	end

	return var_175_0
end

function Ship:getFlag(arg_176_1, arg_176_2)
	return pg.ShipFlagMgr.GetInstance():GetShipFlag(self.id, arg_176_1, arg_176_2)
end

function Ship:hasAnyFlag(arg_177_1)
	return _.any(arg_177_1, function(arg_178_0)
		return self:getFlag(arg_178_0)
	end)
end

function Ship:isBreakOut()
	return self.configId % 10 > 1
end

function Ship:fateSkillChange(arg_180_1)
	if not self.skillChangeList then
		if self:isBluePrintShip() then
			self.skillChangeList = self:getBluePrint():getChangeSkillList() or {}
		end
	end

	for iter_180_0, iter_180_1 in ipairs(self.skillChangeList) do
		if iter_180_1[1] == arg_180_1 and self.skills[iter_180_1[2]] then
			return iter_180_1[2]
		end
	end

	return arg_180_1
end

function Ship:RemapSkillId(arg_181_1, arg_181_2)
	local var_181_0 = self:GetSpWeapon()

	if var_181_0 then
		if table.contains(pg.ship_data_template[self.configId].hide_buff_list, arg_181_1) then
			return var_181_0:RemapHiddenSkillId(arg_181_1)
		elseif arg_181_2 then
			local var_181_1 = var_181_0:RemapHiddenSkillId(arg_181_1)

			if var_181_1 == arg_181_1 then
				var_181_1 = var_181_0:RemapSkillId(arg_181_1)
			end

			return var_181_1
		else
			return var_181_0:RemapSkillId(arg_181_1)
		end
	end

	return arg_181_1
end

function Ship:getSkillList()
	local var_182_0 = Clone(pg.ship_data_template[self.configId].buff_list)

	if pg.ship_data_trans[self.groupId] and pg.ship_data_trans[self.groupId].skill_id ~= 0 then
		if self.transforms[pg.ship_data_trans[self.groupId].skill_id] and pg.transform_data_template[pg.ship_data_trans[self.groupId].skill_id].skill_id ~= 0 then
			table.insert(var_182_0, pg.transform_data_template[pg.ship_data_trans[self.groupId].skill_id].skill_id)
		end
	end

	local var_182_2 = {}

	for iter_182_0, iter_182_1 in ipairs((Clone(pg.ship_data_template[self.configId].buff_list_display))) do
		for iter_182_2, iter_182_3 in ipairs(var_182_0) do
			if iter_182_1 == iter_182_3 then
				table.insert(var_182_2, self:fateSkillChange(iter_182_1))
			end
		end
	end

	return var_182_2
end

function Ship:getModAttrTopLimit(arg_183_1)
	return calcFloor((3 + 7 * (math.min(self.level, 100) / 100)) * pg.ship_data_strengthen[pg.ship_data_template[self.configId].strengthen_id].durability[ShipModAttr.ATTR_TO_INDEX[arg_183_1]] * 0.1)
end

function Ship:leftModAdditionPoint(arg_184_1)
	return math.max(0, self:getModAttrTopLimit(arg_184_1) - calcFloor(self:getModProperties(arg_184_1) / self:getModExpRatio(arg_184_1)))
end

function Ship:getModAttrBaseMax(arg_185_1)
	if not table.contains(self:getConfig("lock"), arg_185_1) then
		return calcFloor(self:getShipProperties()[arg_185_1] + self:leftModAdditionPoint(arg_185_1))
	else
		return 0
	end
end

function Ship:getModExpRatio(arg_186_1)
	if not table.contains(self:getConfig("lock"), arg_186_1) then
		assert(pg.ship_data_strengthen[pg.ship_data_template[self.configId].strengthen_id], "ship_data_strengthen>>>>>>" .. pg.ship_data_template[self.configId].strengthen_id)

		return math.max(pg.ship_data_strengthen[pg.ship_data_template[self.configId].strengthen_id].level_exp[ShipModAttr.ATTR_TO_INDEX[arg_186_1]], 1)
	else
		return 1
	end
end

function Ship:inUnlockTip()
	return table.contains(pg.gameset.tip_unlock_shipIds.description[0], self)
end

function Ship:proposeSkinOwned(arg_188_1)
	local var_188_0

	if arg_188_1 then
		::label_188_0::

		var_188_0 = self.propose and arg_188_1.skin_type == ShipSkin.SKIN_TYPE_PROPOSE
	end

	return var_188_0
end

function Ship:getProposeSkin()
	return ShipSkin.GetSkinByType(self.groupId, ShipSkin.SKIN_TYPE_PROPOSE)
end

function Ship:getDisplaySkillIds()
	return _.map(pg.ship_data_template[self.configId].buff_list_display, function(arg_191_0)
		return self:fateSkillChange(arg_191_0)
	end)
end

function Ship:isFullSkillLevel()
	for iter_192_0, iter_192_1 in pairs(self.skills) do
		if pg.skill_data_template[iter_192_1.id].max_level ~= iter_192_1.level then
			return false
		end
	end

	return true
end

function Ship:setEquipmentRecord(arg_193_1, arg_193_2)
	PlayerPrefs.SetString("equipment_record" .. "_" .. arg_193_1 .. "_" .. self.id, table.concat(_.flatten(arg_193_2), ":"))
	PlayerPrefs.Save()
end

function Ship:getEquipmentRecord(arg_194_1)
	if not self.equipmentRecords then
		local var_194_0 = string.split(PlayerPrefs.GetString("equipment_record" .. "_" .. arg_194_1 .. "_" .. self.id) or "", ":")
		local var_194_1 = {}

		for iter_194_0 = 1, 3 do
			var_194_1[iter_194_0] = _.map(_.slice(var_194_0, 5 * iter_194_0 - 4, 5), function(arg_195_0)
				return tonumber(arg_195_0)
			end)
		end

		self.equipmentRecords = var_194_1
	end

	return self.equipmentRecords
end

function Ship:SetSpWeaponRecord(arg_196_1, arg_196_2)
	PlayerPrefs.SetString("spweapon_record" .. "_" .. arg_196_1 .. "_" .. self.id, table.concat(_.map({
		1,
		2,
		3
	}, function(arg_197_0)
		if arg_196_2[arg_197_0] then
			return (arg_196_2[arg_197_0]:GetUID() or 0) .. "," .. arg_196_2[arg_197_0]:GetConfigID()
		else
			return "0,0"
		end
	end), ":"))
	PlayerPrefs.Save()
end

function Ship:GetSpWeaponRecord(arg_198_1)
	return (_.map(string.split(PlayerPrefs.GetString("spweapon_record" .. "_" .. arg_198_1 .. "_" .. self.id, ""), ":"), function(arg_199_0)
		local var_199_0 = string.split(arg_199_0, ",")

		assert(var_199_0)

		local var_199_1 = tonumber(var_199_0[1])
		local var_199_2 = tonumber(var_199_0[2])

		if not var_199_2 or var_199_2 == 0 then
			return false
		end

		return (SpWeapon.New({
			id = var_199_2
		}))
	end))
end

function Ship:hasEquipEquipmentSkin()
	for iter_200_0, iter_200_1 in ipairs(self.equipments) do
		if iter_200_1 and iter_200_1:hasSkin() then
			return true
		end
	end

	return false
end

function Ship:hasCommander()
	return self.commanderId and self.commanderId ~= 0
end

function Ship:getCommander()
	return self.commanderId
end

function Ship:setCommander(arg_203_1)
	self.commanderId = arg_203_1
end

function Ship:getSkillIndex(arg_204_1)
	for iter_204_0, iter_204_1 in ipairs((self:getSkillList())) do
		if arg_204_1 == iter_204_1 then
			return iter_204_0
		end
	end
end

function Ship:getTactics()
	return 1, "tactics_attack"
end

function Ship:IsBgmSkin()
	return table.contains(self:GetSkinConfig().tag, ShipSkin.WITH_BGM)
end

function Ship:GetSkinBgm()
	if self:IsBgmSkin() then
		return self:GetSkinConfig().bgm
	end
end

function Ship:isIntensifyMax()
	local var_208_0 = intProperties(self:getShipProperties())

	if self:isBluePrintShip() then
		return true
	end

	for iter_208_0, iter_208_1 in pairs(ShipModAttr.ID_TO_ATTR) do
		if self:getModAttrBaseMax(iter_208_1) ~= var_208_0[iter_208_1] then
			return false
		end
	end

	return true
end

function Ship:isRemouldable()
	return not self:isTestShip() and not self:isBluePrintShip() and pg.ship_data_trans[self.groupId]
end

function Ship:isAllRemouldFinish()
	assert(pg.ship_data_trans[self.groupId], "this ship group without remould config:" .. self.groupId)

	for iter_210_0, iter_210_1 in ipairs(pg.ship_data_trans[self.groupId].transform_list) do
		for iter_210_2, iter_210_3 in ipairs(iter_210_1) do
			if #pg.transform_data_template[iter_210_3[2]].edit_trans > 0 then
				-- block empty
			elseif not self.transforms[iter_210_3[2]] or self.transforms[iter_210_3[2]].level < pg.transform_data_template[iter_210_3[2]].max_level then
				return false
			end
		end
	end

	return true
end

function Ship:isSpecialFilter()
	assert(pg.ship_data_statistics[self.configId], "this ship without statistics:" .. self.configId)

	for iter_211_0, iter_211_1 in ipairs(pg.ship_data_statistics[self.configId].tag_list) do
		if iter_211_1 == "special" then
			return true
		end
	end

	return false
end

function Ship:hasAvailiableSkin()
	local var_212_0 = getProxy(ShipSkinProxy)
	local var_212_1 = var_212_0:getRawData()
	local var_212_2 = 0

	for iter_212_0, iter_212_1 in ipairs((var_212_0:GetAllSkinForShip(self))) do
		if self:proposeSkinOwned(iter_212_1) or var_212_1[iter_212_1.id] or var_212_0:hasSkin(iter_212_1.id) then
			var_212_2 = var_212_2 + 1
		end
	end

	return var_212_2 > 0
end

function Ship:hasProposeSkin()
	local var_213_0 = getProxy(ShipSkinProxy)

	for iter_213_0, iter_213_1 in ipairs((var_213_0:GetAllSkinForShip(self))) do
		if iter_213_1.skin_type == ShipSkin.SKIN_TYPE_PROPOSE then
			return true
		end
	end

	for iter_213_2, iter_213_3 in ipairs((var_213_0:GetShareSkinsForShip(self))) do
		if iter_213_3.skin_type == ShipSkin.SKIN_TYPE_PROPOSE then
			return true
		end
	end

	return false
end

function Ship:HasUniqueSpWeapon()
	return tobool(pg.spweapon_data_statistics.get_id_list_by_unique[self:getGroupId()])
end

function Ship:getAircraftReloadCD()
	local var_215_0 = self:getConfigTable().base_list
	local var_215_1 = self:getConfigTable().default_equip_list
	local var_215_2 = 0
	local var_215_3 = 0

	for iter_215_0 = 1, 3 do
		local var_215_4 = self:getEquip(iter_215_0)
		local var_215_5

		if var_215_4 then
			var_215_5 = var_215_4.configId or var_215_1[iter_215_0]
		end

		local var_215_6 = Equipment.getConfigData(var_215_5).type

		if underscore.any(EquipType.AirEquipTypes, function(arg_216_0)
			return var_215_6 == arg_216_0
		end) then
			var_215_2 = var_215_2 + Equipment.GetEquipReloadStatic(var_215_5) * var_215_0[iter_215_0]
			var_215_3 = var_215_3 + var_215_0[iter_215_0]
		end
	end

	return {
		name = i18n("equip_info_31"),
		type = AttributeType.CD,
		value = var_215_2 / var_215_3 * (ys.Battle.BattleConfig.AIR_ASSIST_RELOAD_RATIO * pg.bfConsts.PERCENT)
	}
end

function Ship:IsTagShip(arg_217_1)
	return table.contains(self:getConfig("tag_list"), arg_217_1)
end

function Ship:setReMetaSpecialItemVO(arg_218_1)
	self.reMetaSpecialItemVO = arg_218_1
end

function Ship:getReMetaSpecialItemVO(arg_219_1)
	return self.reMetaSpecialItemVO
end

function Ship:getProposeType()
	if self:isMetaShip() then
		return "meta"
	elseif self:IsXIdol() then
		return "imas"
	else
		return "default"
	end
end

function Ship:IsXIdol()
	return self:getNation() == Nation.IDOL_LINK
end

function Ship:getSpecificType()
	return pg.ship_data_template[self.configId].specific_type
end

function Ship:GetSpWeapon()
	return self.spWeapon
end

function Ship:UpdateSpWeapon(arg_224_1)
	local var_224_1 = (arg_224_1 and arg_224_1:GetUID() or 0) == (self.spWeapon and self.spWeapon:GetUID() or 0)

	self.spWeapon = arg_224_1

	if arg_224_1 then
		arg_224_1:SetShipId(self.id)
	end

	if var_224_1 then
		pg.m02:sendNotification(EquipmentProxy.SPWEAPONS_UPDATED)
	end
end

function Ship:CanEquipSpWeapon(arg_225_1)
	local var_225_0, var_225_1 = self:IsSpWeaponForbidden(arg_225_1)

	if var_225_0 then
		return false, var_225_1
	end

	return true
end

function Ship:IsSpWeaponForbidden(arg_226_1)
	if not table.contains(arg_226_1:GetWearableShipTypes(), (self:getShipType())) then
		return true, i18n("spweapon_tip_group_error")
	end

	local var_226_0 = arg_226_1:GetUniqueGroup()

	if var_226_0 ~= 0 and var_226_0 ~= self:getGroupId() then
		return true, i18n("spweapon_tip_group_error")
	end

	return false
end

function Ship:GetMapStrikeAnim()
	local var_227_0
	local var_227_1 = self:getShipType()

	switch(ShipType.GetTeamFromShipType(var_227_1), {
		[TeamType.Main] = function()
			var_227_0 = ShipType.IsTypeQuZhu(var_227_1) and "SubTorpedoUI" or ShipType.ContainInLimitBundle(ShipType.BundleAircraftCarrier, var_227_1) and "AirStrikeUI" or ShipType.ContainInLimitBundle(ShipType.BundleBattleShip, var_227_1) and "CannonUI" or "CannonUI"
		end,
		[TeamType.Vanguard] = function()
			if ShipType.IsTypeQuZhu(var_227_1) then
				var_227_0 = "SubTorpedoUI"
			end
		end,
		[TeamType.Submarine] = function()
			var_227_0 = self:getNation() == Nation.MOT and "CannonUI" or "SubTorpedoUI"
		end
	})

	return nil
end

function Ship:IsDefaultSkin()
	local var_231_0 = self:getSkinId()

	return var_231_0 == 0 or var_231_0 == self:getConfig("skin_id")
end

function Ship:IsMatchKey(arg_232_1)
	if not arg_232_1 or arg_232_1 == "" then
		return true
	end

	arg_232_1 = string.lower(string.gsub(arg_232_1, "%.", "%%."))

	return underscore.any({
		pg._ship_data_statistics[self.configId].name,
		self:GetDefaultName(),
		(self:getName())
	}, function(arg_233_0)
		return string.find(string.lower(arg_233_0), arg_232_1)
	end)
end

function Ship:IsOwner()
	return tobool(self.id)
end

function Ship:GetUniqueId()
	return self.id
end

function Ship:ShowPropose()
	if not self.propose then
		return false
	else
		local var_236_0

		if HXSet.isHxPropose() then
			var_236_0 = self:IsOwner()

			if var_236_0 then
				var_236_0 = self:GetUniqueId() == getProxy(PlayerProxy):getRawData():GetProposeShipId()
			end
		end

		return var_236_0
	end
end

function Ship:GetColorName(arg_237_1)
	arg_237_1 = arg_237_1 or self:getName()

	if PlayerPrefs.GetInt("SHIP_NAME_COLOR", PLATFORM_CODE == PLATFORM_CH and 1 or 0) == 1 and self.propose then
		return setColorStr(arg_237_1, "#FFAACEFF")
	else
		return arg_237_1
	end
end

local var_0_9 = {
	effect = {
		"duang_meta_jiehun",
		"duang_6_jiehun_tuzhi",
		"duang_6_jiehun",
		"duang_meta_%s",
		"duang_6"
	},
	frame = {
		"prop4_1",
		"prop%s",
		"prop"
	}
}

function Ship:GetFrameAndEffect(arg_238_1)
	arg_238_1 = tobool(arg_238_1)

	local var_238_0
	local var_238_1

	if self.propose then
		if self:isMetaShip() then
			var_238_1 = string.format(var_0_9.effect[1])
			var_238_0 = string.format(var_0_9.frame[1])
		elseif self:isBluePrintShip() then
			var_238_1 = string.format(var_0_9.effect[2])
			var_238_0 = string.format(var_0_9.frame[2], self:rarity2bgPrint())
		else
			var_238_1 = string.format(var_0_9.effect[3])
			var_238_0 = string.format(var_0_9.frame[3])
		end

		if not self:ShowPropose() then
			var_238_0 = nil
		end
	elseif self:isMetaShip() then
		var_238_1 = string.format(var_0_9.effect[4], self:rarity2bgPrint())
	elseif self:getRarity() == ShipRarity.SSR then
		var_238_1 = string.format(var_0_9.effect[5])
	end

	if arg_238_1 then
		var_238_1 = var_238_1 and var_238_1 .. "_1"
	end

	return var_238_0, var_238_1
end

function Ship:GetRecordPosKey()
	return self:getSkinId()
end

function Ship:GetShipPhantomMark(arg_240_1)
	return ShipPhantom.PackMark(self.id, arg_240_1)
end

function Ship:GetSelectMark()
	return self.id
end

return Ship
