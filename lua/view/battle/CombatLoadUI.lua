local CombatLoadUI = class("CombatLoadUI", import("..base.BaseUI"))

CombatLoadUI._loadObs = nil
CombatLoadUI.LOADING_ANIMA_DISTANCE = 1820

function CombatLoadUI:getUIName()
	return "CombatLoadUI"
end

function CombatLoadUI:getResource()
	local var_2_0 = {}
	local var_2_1
	local var_2_2

	if self.contextData.system == SYSTEM_BOSS_RUSH_COLLABRATE then
		var_2_1 = AppreciatePicConst.TYPE_GALLERY
		var_2_2 = "bg/star_level_bg_211"
	else
		local var_2_3 = AppreciatePicConst.getRandomLoadingPic()

		if var_2_3 then
			var_2_1 = var_2_3.type
			var_2_2 = var_2_3.path
		else
			var_2_1 = AppreciatePicConst.TYPE_GALLERY
			var_2_2 = "loadingbg/login"
		end
	end

	if var_2_2 then
		table.insert(var_2_0, var_2_2)
	end

	local var_2_4 = HXSet.HxPath(var_2_2)

	self.contextData._combatLoadPicData = {
		type = var_2_1,
		path = var_2_4
	}
	self._preloadPicType = var_2_1
	self._preloadPicPath = var_2_4

	local var_2_5, var_2_6, var_2_7 = CombatLoadUI.GetTotalResourceList(self.contextData)

	if var_2_5 and #var_2_5 > 0 then
		for iter_2_0, iter_2_1 in ipairs(var_2_5) do
			iter_2_1 = string.lower(iter_2_1)

			table.insert(var_2_0, iter_2_1)
		end
	end

	return table.insertto(var_2_0, CombatLoadUI.super.getResource(self))
end

function CombatLoadUI:preload(arg_3_1)
	local var_3_0 = self.contextData and self.contextData._combatLoadPicData

	if var_3_0 then
		self._preloadPicType = var_3_0.type or nil
	end

	if var_3_0 then
		self._preloadPicPath = var_3_0.path or nil
	end

	self._preloadPicSprite = nil
	self._preloadBgFitMode = PlayerPrefs.GetInt("bgFitMode", 0)

	if self._preloadPicPath then
		LoadSpriteAsync(self._preloadPicPath, function(arg_4_0)
			self._preloadPicSprite = arg_4_0

			arg_3_1()
		end)
	else
		arg_3_1()
	end
end

function CombatLoadUI:init()
	local var_5_0 = self._tf:Find("loading")

	self._loadingProgress = var_5_0:Find("loading_bar"):GetComponent(typeof(Slider))
	self._loadingProgress.value = 0
	self._loadingText = var_5_0:Find("loading_label/percent"):GetComponent(typeof(Text))
	self._loadingAnima = var_5_0:Find("loading_anima")
	self._loadingAnimaPosY = self._loadingAnima.anchoredPosition.y
	self._finishAnima = var_5_0:Find("done_anima")

	SetActive(self._loadingAnima, true)
	SetActive(self._finishAnima, false)
	self._finishAnima:GetComponent("DftAniEvent"):SetEndEvent(function(arg_6_0)
		self:emit(CombatLoadMediator.FINISH, self._loadObs)
	end)

	local var_5_1 = self._tf:Find("GalleryEnv")
	local var_5_2 = self._tf:Find("GalleryFit")
	local var_5_3 = self._preloadBgFitMode or PlayerPrefs.GetInt("bgFitMode", 0)

	self.bg = var_5_3 == 1 and var_5_2 or var_5_1

	local var_5_4 = self._tf:Find("Manga")

	self.mangaPicImg = self._tf:Find("Manga/Pic")

	if self._preloadPicType == AppreciatePicConst.TYPE_MANGA and self._preloadPicSprite then
		SetActive(var_5_1, false)
		SetActive(var_5_2, false)
		SetActive(var_5_4, true)
		setImageSprite(self.mangaPicImg, self._preloadPicSprite)
	else
		(function(arg_7_0)
			SetActive(var_5_1, var_5_3 ~= 1)
			SetActive(var_5_2, var_5_3 == 1)
			SetActive(var_5_4, false)
			setImageSprite(self.bg, arg_7_0 or LoadSprite("loadingbg/login"))
		end)(self._preloadPicSprite)
	end

	self._tipsText = var_5_0:Find("tipsText"):GetComponent(typeof(Text))
end

function CombatLoadUI:didEnter()
	self:Preload()
end

function CombatLoadUI:onBackPressed()
	return
end

function CombatLoadUI:Preload()
	PoolMgr.GetInstance():DestroyAllSprite()

	self._loadObs = {}

	ys.Battle.BattleFXPool.GetInstance():Init()

	local var_10_0 = ys.Battle.BattleResourceManager.GetInstance()

	var_10_0:Init()

	local var_10_1 = getProxy(BayProxy)
	local var_10_2, var_10_3 = CombatLoadUI.GetTotalResourceList(self.contextData)

	for iter_10_0, iter_10_1 in ipairs(var_10_2) do
		var_10_0:AddPreloadResource(iter_10_1)
	end

	for iter_10_2, iter_10_3 in ipairs(var_10_3) do
		var_10_0:AddPreloadCV(iter_10_3)
	end

	if self.contextData.system == SYSTEM_DEBUG and BATTLE_DEBUG_CUSTOM_WEAPON then
		for iter_10_4, iter_10_5 in pairs(ys.Battle.BattleUnitDetailView.BulletForger) do
			pg.TipsMgr.GetInstance():ShowTips("触发自定义子弹替换>>>" .. iter_10_4 .. "<<<，检查是否测试需要，否则联系程序")

			pg.bullet_template[iter_10_4] = iter_10_5
		end

		for iter_10_6, iter_10_7 in pairs(ys.Battle.BattleUnitDetailView.BarrageForger) do
			pg.TipsMgr.GetInstance():ShowTips("触发自定义弹幕替换>>>" .. iter_10_6 .. "<<<，检查是否测试需要，否则联系程序")

			pg.barrage_template[iter_10_6] = iter_10_7
		end

		for iter_10_8, iter_10_9 in pairs(ys.Battle.BattleUnitDetailView.AircraftForger) do
			pg.TipsMgr.GetInstance():ShowTips("触发自定义飞机替换>>>" .. iter_10_8 .. "<<<，检查是否测试需要，否则联系程序")

			pg.aircraft_template[iter_10_8] = iter_10_9
		end

		for iter_10_10, iter_10_11 in pairs(ys.Battle.BattleUnitDetailView.WeaponForger) do
			pg.TipsMgr.GetInstance():ShowTips("触发自定义武器替换>>>" .. iter_10_10 .. "<<<，检查是否测试需要，否则联系程序")

			pg.weapon_property[iter_10_10] = iter_10_11

			for iter_10_12, iter_10_13 in ipairs((var_10_0.GetWeaponResource(iter_10_10))) do
				var_10_0:AddPreloadResource(iter_10_13)
			end
		end
	end

	if BATTLE_DEBUG and BATTLE_FREE_SUBMARINE then
		local var_10_4 = {}
		local var_10_5 = getProxy(FleetProxy):getFleetById(11)

		for iter_10_14, iter_10_15 in ipairs((var_10_5:getTeamByName(TeamType.Submarine))) do
			table.insert(var_10_4, var_10_1:getShipById(iter_10_15))
		end

		local var_10_6, var_10_7 = var_10_0.GetPlayerShipResource(var_10_4, self.contextData.system)

		for iter_10_16, iter_10_17 in ipairs(var_10_6) do
			var_10_0:AddPreloadResource(iter_10_17)
		end

		for iter_10_18, iter_10_19 in ipairs(var_10_7) do
			var_10_0:AddPreloadCV(iter_10_19)
		end

		CombatLoadUI.addCommanderBuffRes(var_10_5:buildBattleBuffList())
	end

	local function var_10_8()
		SetActive(self._loadingAnima, false)
		SetActive(self._finishAnima, true)

		self._finishAnima:GetComponent("Animator").enabled = true
	end

	local var_10_9 = 0

	setActive(pg.UIMgr.GetInstance():GetMainCamera(), true)

	var_10_9 = var_10_0:StartPreload(var_10_8, function(arg_12_0)
		self._loadingProgress.value = var_10_9 == 0 and 0 or arg_12_0 / var_10_9
		self._loadingText.text = string.format("%.2f", var_12_0 * 100) .. "%"
		self._loadingAnima.anchoredPosition = Vector2(var_12_0 * CombatLoadUI.LOADING_ANIMA_DISTANCE, self._loadingAnimaPosY)
	end)
	self._tipsText.text = pg.server_language[math.random(#pg.server_language)].content
end

function CombatLoadUI:GetTotalResourceList()
	local var_13_0 = {}
	local var_13_1 = {}
	local var_13_2 = {}

	if ys.Battle.BattleGate.Gates[self.system].GetPreloadList then
		local var_13_3, var_13_4 = ys.Battle.BattleGate.Gates[self.system].GetPreloadList(self)

		for iter_13_0, iter_13_1 in ipairs(var_13_3) do
			table.insert(var_13_0, iter_13_1)
		end

		for iter_13_2, iter_13_3 in ipairs(var_13_4) do
			table.insert(var_13_1, iter_13_3)
		end
	elseif self.mainFleetId then
		for iter_13_4, iter_13_5 in ipairs((getProxy(BayProxy):getShipsByFleet((getProxy(FleetProxy):getFleetById(self.mainFleetId))))) do
			table.insert(var_13_2, iter_13_5)
		end
	end

	if self.prefabFleet then
		local var_13_6 = self.prefabFleet.vanguard_unitList or {}
		local var_13_7 = self.prefabFleet.submarine_unitList or {}

		for iter_13_6, iter_13_7 in ipairs(self.prefabFleet.main_unitList or {}) do
			table.insert(var_13_2, CombatLoadUI.generatePrefabShipData(iter_13_7))
		end

		for iter_13_8, iter_13_9 in ipairs(var_13_6) do
			table.insert(var_13_2, CombatLoadUI.generatePrefabShipData(iter_13_9))
		end

		for iter_13_10, iter_13_11 in ipairs(var_13_7) do
			table.insert(var_13_2, CombatLoadUI.generatePrefabShipData(iter_13_11))
		end
	end

	local var_13_8 = ys.Battle.BattleResourceManager.GetInstance()
	local var_13_9, var_13_10 = var_13_8.GetPlayerShipResource(var_13_2, self.system)

	for iter_13_12, iter_13_13 in ipairs(var_13_9) do
		table.insert(var_13_0, iter_13_13)
	end

	for iter_13_14, iter_13_15 in ipairs(var_13_10) do
		table.insert(var_13_1, iter_13_15)
	end

	local var_13_11 = pg.expedition_data_template[self.stageId].dungeon_id
	local var_13_12, var_13_13 = var_13_8.GetStageResource(pg.expedition_data_template[self.stageId].dungeon_id)

	for iter_13_16, iter_13_17 in ipairs(var_13_12) do
		table.insert(var_13_0, iter_13_17)
	end

	for iter_13_18, iter_13_19 in ipairs(var_13_8.GetCommonResource()) do
		table.insert(var_13_0, iter_13_19)
	end

	for iter_13_20, iter_13_21 in ipairs(var_13_8.GetBuffResource()) do
		table.insert(var_13_0, iter_13_21)
	end

	for iter_13_22, iter_13_23 in ipairs(var_13_13) do
		table.insert(var_13_1, iter_13_23)
	end

	if self.system == SYSTEM_WORLD and pg.expedition_data_template[self.stageId].difficulty == ys.Battle.BattleConst.Difficulty.WORLD then
		for iter_13_24, iter_13_25 in ipairs(var_13_8.GetMapResource(nowWorld():GetActiveMap().config.expedition_map_id)) do
			table.insert(var_13_0, iter_13_25)
		end
	else
		for iter_13_26, iter_13_27 in ipairs(pg.expedition_data_template[self.stageId].map_id) do
			for iter_13_28, iter_13_29 in ipairs(var_13_8.GetMapResource(iter_13_27[1])) do
				table.insert(var_13_0, iter_13_29)
			end
		end
	end

	if pg.battle_cost_template[self.system].global_buff_effected > 0 then
		for iter_13_30, iter_13_31 in ipairs((_.map(BuffHelper.GetBattleBuffs(), function(arg_14_0)
			return arg_14_0:getConfig("benefit_effect")
		end))) do
			iter_13_31 = tonumber(iter_13_31)

			for iter_13_32, iter_13_33 in ipairs((ys.Battle.BattleDataFunction.GetResFromBuff(iter_13_31, 1, {}))) do
				table.insert(var_13_0, iter_13_33)
			end
		end
	end

	return var_13_0, var_13_1, (var_13_8.GetStageBGM(var_13_11))
end

function CombatLoadUI:generatePrefabShipData()
	local var_15_0 = {
		configId = self.configId,
		equipments = {},
		skinId = self.skinId,
		buffs = self.skills
	}

	for iter_15_0 = 1, math.max(#self.equipment, #ys.Battle.BattleDataFunction.GetPlayerShipTmpDataFromID(self.configId).default_equip_list) do
		var_15_0.equipments[iter_15_0] = self.equipment[iter_15_0] and {
			configId = self.equipment[iter_15_0]
		} or false
	end

	function var_15_0:getActiveEquipments()
		return self.equipments
	end

	return var_15_0
end

function CombatLoadUI:addCommanderBuffRes()
	local var_17_0 = ys.Battle.BattleResourceManager.GetInstance()

	for iter_17_0, iter_17_1 in ipairs(self) do
		for iter_17_2, iter_17_3 in ipairs((var_17_0.GetCommanderResource(iter_17_1))) do
			var_17_0:AddPreloadResource(iter_17_3)
		end
	end
end

return CombatLoadUI
