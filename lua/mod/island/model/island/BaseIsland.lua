local BaseIsland = class("BaseIsland", import("Mod.Island.IslandDispatcher"))

function BaseIsland:Ctor(arg_1_1)
	BaseIsland.super.Ctor(self)

	self.id = arg_1_1.id
	self.level = arg_1_1.level or 1
	self.configId = self.level
	self.exp = arg_1_1.exp or 0
	self.name = arg_1_1.name or "1"
	self.prosperity = arg_1_1.prosperity or 0
	self.manifesto = arg_1_1.signature or ""
	self.prosperityList = {}

	for iter_1_0, iter_1_1 in ipairs(arg_1_1.prosperity_rewarded or {}) do
		self.prosperityList[iter_1_1] = true
	end

	self.ablityAgency = IslandAblityAgency.New(self, arg_1_1)
	self.characterAgency = IslandCharacterAgency.New(self, arg_1_1)
	self.visitorAgency = IslandVisitorAgency.New(self, arg_1_1)
	self.technologyAgency = IslandTechnologyAgency.New(self, arg_1_1)
	self.signInAgency = IslandSignInAgency.New(self, arg_1_1)
	self.taskAgency = IslandTaskAgency.New(self, arg_1_1)
	self.accessAgency = IslandAccessAgency.New(self, arg_1_1)
	self.gatherCollectAgency = IslandGatherCollectAgency.New(self, arg_1_1)
	self.buildingAgency = IslandBuildingAgency.New(self, arg_1_1)
	self.followerAgency = IslandFollowerAgency.New(self)
	self.activityNpcAgency = IslandActivityNpcAgency.New(self)
	self.tradeAgency = IslandTradegency.New(self, arg_1_1)
	self.agoraAgency = IslandAgoraAgency.New(self, arg_1_1)
	self.manageAgency = IslandManageAgecny.New(self, arg_1_1)
	self.cheaterTavernAgency = IslandCheaterTavernAgency.New(self)
	self.interactSyncAgency = IslandInteractSyncAgency.New(self)
	self.mapID = pg.island_set.initial_scene.key_value_int
	self.lastExitPosition = {
		mapId = 0,
		position = Vector3.zero,
		rotation = Vector3.zero
	}

	if not self.taskAgency:IsFinishTask(IslandGuideChecker.MOVE_TASK_ID) then
		self:SetSpawnPointId(pg.island_set.initial_spawn_point.key_value_int)
	end
end

function BaseIsland:GetTradeAgency()
	return self.tradeAgency
end

function BaseIsland:GetActivityNpcAgency()
	return self.activityNpcAgency
end

function BaseIsland:GetFollowerAgency()
	return self.followerAgency
end

function BaseIsland:GetAccessAgency()
	return self.accessAgency
end

function BaseIsland:IsPrivate()
	return false
end

function BaseIsland:GetVisitorAgency()
	return self.visitorAgency
end

function BaseIsland:GetAgoraAgency()
	return self.agoraAgency
end

function BaseIsland:GetCharacterAgency()
	return self.characterAgency
end

function BaseIsland:GetTechnologyAgency()
	return self.technologyAgency
end

function BaseIsland:GetAblityAgency()
	return self.ablityAgency
end

function BaseIsland:GetSignInAgency()
	return self.signInAgency
end

function BaseIsland:GetTaskAgency()
	return self.taskAgency
end

function BaseIsland:GetCheaterTavernAgency()
	return self.cheaterTavernAgency
end

function BaseIsland:GetManageAgency()
	return self.manageAgency
end

function BaseIsland:GetWildCollectAgency()
	return self.gatherCollectAgency
end

function BaseIsland:GetInteractSyncAgency()
	return self.interactSyncAgency
end

function BaseIsland:GetBuildingAgency()
	return self.buildingAgency
end

function BaseIsland:SetSpawnPointId(arg_19_1)
	self.spawnPointId = arg_19_1
end

function BaseIsland:GetSpawnPointId()
	self.spawnPointId = nil

	return self.spawnPointId
end

function BaseIsland:SetLastExitPosition(arg_21_1, arg_21_2, arg_21_3)
	if arg_21_1 <= 0 then
		return
	end

	self.lastExitPosition = {
		mapId = arg_21_1,
		position = arg_21_2,
		rotation = arg_21_3
	}
end

function BaseIsland:GetLastExitPosition()
	return self.lastExitPosition
end

function BaseIsland:GetMapId()
	return self.mapID
end

function BaseIsland:SetMapId(arg_24_1)
	if not pg.island_map[arg_24_1] then
		return
	end

	if not pg.TimeMgr.GetInstance():inTime(pg.island_map[arg_24_1].time) then
		return
	end

	self.mapID = arg_24_1
end

function BaseIsland:GetUnlockBuildingList()
	if self:IsMaxLevel() then
		return {}
	end

	return pg.island_level[self.level].island_level_award
end

function BaseIsland:IsNew()
	return self.name == ""
end

function BaseIsland:CanModifyName()
	return true
end

function BaseIsland:SetName(arg_28_1)
	self.name = arg_28_1
end

function BaseIsland:GetName()
	if self.name == "" then
		return i18n("island_default_name", getProxy(PlayerProxy):getRawData().name)
	else
		return self.name
	end
end

function BaseIsland:SetManifesto(arg_30_1)
	self.manifesto = arg_30_1
end

function BaseIsland:GetManifesto()
	return self.manifesto
end

function BaseIsland:AddExp(arg_32_1)
	if self:IsMaxLevel() then
		return
	end

	self.exp = self.exp + arg_32_1
end

function BaseIsland:Upgrade()
	if self:IsMaxLevel() then
		return
	end

	if self:CanLevelUp() then
		self.exp = self:IsMaxLevel() and 0 or self.exp - self:GetTargeExp()

		self:LevelUp()
	end
end

function BaseIsland:LevelUp()
	self.level = self.level + 1
	self.configId = self.level
end

function BaseIsland:GetTargeExp()
	assert(pg.island_level[self.level])

	return pg.island_level[self.level].island_exp
end

function BaseIsland:CanLevelUp()
	if self:IsMaxLevel() then
		return false
	end

	return self:GetTargeExp() <= self.exp
end

function BaseIsland:IsMaxLevel()
	return pg.island_level.all[#pg.island_level.all] <= self.level
end

function BaseIsland:StaticIsMaxLevel(arg_38_1)
	return arg_38_1 >= pg.island_level.all[#pg.island_level.all]
end

function BaseIsland:GetLevel()
	return self.level
end

function BaseIsland:GetExp()
	return self.exp
end

function BaseIsland:GetUpgradeAwardsByLevel(arg_41_1)
	if self:StaticIsMaxLevel(arg_41_1) then
		return {}
	end

	local var_41_0 = pg.island_level[arg_41_1]

	assert(pg.island_level[arg_41_1])

	local var_41_1 = {}

	for iter_41_0, iter_41_1 in ipairs(var_41_0.island_level_award) do
		table.insert(var_41_1, {
			DROP_TYPE_ISLAND_ITEM,
			iter_41_1[1],
			iter_41_1[2]
		})
	end

	return var_41_1
end

function BaseIsland:GetUpgradeAwards()
	return (self:GetUpgradeAwardsByLevel(self.level))
end

function BaseIsland:AddProsperity(arg_43_1)
	if not self:CanAddProsperity() then
		return
	end

	self.prosperity = self.prosperity + arg_43_1
end

function BaseIsland:CanAddProsperity()
	return pg.island_prosperity[self:GetMaxProsperityLevel()].prosperity > self.prosperity
end

function BaseIsland:GetProsperity()
	return self.prosperity
end

function BaseIsland:GetMaxProsperityLevel()
	return pg.island_prosperity.all[#pg.island_prosperity.all]
end

function BaseIsland:GetTargetProsperityByLevel(arg_47_1)
	assert(pg.island_prosperity[arg_47_1])

	return pg.island_prosperity[arg_47_1].prosperity
end

function BaseIsland:GetTargetProsperity()
	local var_48_0 = self:GetProsperity()

	for iter_48_0, iter_48_1 in ipairs(pg.island_prosperity.all) do
		local var_48_1 = self:GetTargetProsperityByLevel(iter_48_1)

		if var_48_0 < var_48_1 then
			return var_48_1
		end
	end

	return 0
end

function BaseIsland:GetProsperityLevel()
	local var_49_0 = self:GetProsperity()

	for iter_49_0, iter_49_1 in ipairs(pg.island_prosperity.all) do
		if var_49_0 < self:GetTargetProsperityByLevel(iter_49_1) then
			return iter_49_1
		end
	end

	return self:GetMaxProsperityLevel()
end

function BaseIsland:CanGetProsperityAwards(arg_50_1)
	if self:IsReceiveProsperityAwards(arg_50_1) then
		return false
	end

	local var_50_0 = pg.island_prosperity[arg_50_1]

	if not pg.island_prosperity[arg_50_1] then
		return false
	end

	return var_50_0.prosperity <= self:GetProsperity()
end

function BaseIsland:AnyProsperityAwardCanGet()
	for iter_51_0, iter_51_1 in ipairs(pg.island_prosperity.all) do
		if self:CanGetProsperityAwards(iter_51_1) then
			return true
		end
	end

	return false
end

function BaseIsland:IsReceiveProsperityAwards(arg_52_1)
	return self.prosperityList[arg_52_1] == true
end

function BaseIsland:ReceiveProsperityAwards(arg_53_1)
	self.prosperityList[arg_53_1] = true
end

function BaseIsland:GetProsperityAward(arg_54_1)
	return pg.island_prosperity[arg_54_1].award_display
end

function BaseIsland:getConfig(arg_55_1)
	return pg.island_level[self.configId][arg_55_1]
end

function BaseIsland:UpdatePerDay()
	self:GetSignInAgency():ResetSignInCnt()
	self:GetAccessAgency():ResetFreshInviteCodeFlag()
	self:GetCharacterAgency():ResetShipSkillUsed()
end

function BaseIsland:UpdatePerSecond()
	if self.buildingAgency then
		self.buildingAgency:UpdatePerSecond()
	end
end

function BaseIsland:UpdatePerHour(arg_58_1)
	self:GetTradeAgency():UpdatePerHour(arg_58_1)
end

return BaseIsland
