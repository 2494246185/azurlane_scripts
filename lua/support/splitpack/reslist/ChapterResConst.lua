ResList = ResList or {}
ResList.ChapterResConst = {}

local var_0_0 = ResList.ChapterResConst

local function var_0_1(arg_1_0, arg_1_1, arg_1_2)
	if noEmptyStr(arg_1_2) then
		table.insert(arg_1_0, ResPathSupport.CombinePath(arg_1_1, arg_1_2))
	end
end

local var_0_2 = {
	"effect/huoqiubaozha",
	"effect/atdun_full_slg",
	"effect/dexiv4_slg_missile",
	"effect/shellhitblue",
	"effect/miwuxiaosan",
	"effect/qianting_01"
}

function ResList.ChapterResConst:IsActive()
	return self ~= nil and self.active == true
end

function ResList.ChapterResConst.GetResList(arg_3_0)
	local var_3_0 = var_0_0.GetInactiveResList(arg_3_0)

	table.insertto(var_3_0, var_0_0.GetActiveResList(arg_3_0))

	return var_3_0
end

function ResList.ChapterResConst.GetInactiveResList(arg_4_0)
	local var_4_0 = {}

	if not arg_4_0 then
		return var_4_0
	end

	table.insertto(var_4_0, var_0_0.GetThemeResList(arg_4_0))
	table.insertto(var_4_0, var_0_0.GetEffectResList(arg_4_0))
	table.insertto(var_4_0, var_0_0.GetSceneResList(arg_4_0))

	return var_4_0
end

function ResList.ChapterResConst.GetActiveResList(arg_5_0)
	local var_5_0 = {}

	if not var_0_0.IsActive(arg_5_0) then
		return var_5_0
	end

	table.insertto(var_5_0, var_0_0.GetFleetResList(arg_5_0))
	table.insertto(var_5_0, var_0_0.GetChampionResList(arg_5_0))
	table.insertto(var_5_0, var_0_0.GetCellAttachmentResList(arg_5_0))
	table.insertto(var_5_0, var_0_0.GetStrategyResList(arg_5_0))
	table.insertto(var_5_0, var_0_0.GetCommanderSkillResList(arg_5_0))
	table.insertto(var_5_0, var_0_0.GetFleetIconResList(arg_5_0))

	return var_5_0
end

function ResList.ChapterResConst:GetThemeResList()
	local var_6_0 = {}

	if not self then
		return var_6_0
	end

	local var_6_1 = self:getConfig("theme")

	if type(var_6_1) ~= "table" then
		return var_6_0
	end

	for iter_6_0, iter_6_1 in ipairs({
		1,
		10
	}) do
		if noEmptyStr(var_6_1[iter_6_1]) then
			table.insert(var_6_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.ChapterPic, var_6_1[iter_6_1]))
		end
	end

	return var_6_0
end

function ResList.ChapterResConst:GetEffectResList()
	local var_7_0 = {}

	if not self then
		return var_7_0
	end

	local var_7_1 = self:getConfig("chapter_fx")

	if type(var_7_1) == "table" then
		for iter_7_0, iter_7_1 in pairs(var_7_1) do
			if noEmptyStr(iter_7_0) then
				table.insert(var_7_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, iter_7_0))
			end
		end
	end

	local var_7_2 = self:getConfig("wall_prefab")

	if type(var_7_2) == "table" then
		for iter_7_2, iter_7_3 in ipairs(var_7_2) do
			var_0_1(var_7_0, ResPathSupport.ConstPath.UI.Effect, iter_7_3[3])
			var_0_1(var_7_0, ResPathSupport.ConstPath.UI.Effect, iter_7_3[4])
		end
	end

	for iter_7_4, iter_7_5 in ipairs(var_0_2) do
		table.insert(var_7_0, iter_7_5)
	end

	return var_7_0
end

function ResList.ChapterResConst:GetSceneResList()
	local var_8_0 = {}

	if not self then
		return var_8_0
	end

	local var_8_1 = self:getConfig("bg")

	if noEmptyStr(var_8_1) then
		table.insert(var_8_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.LevelMap, var_8_1))
	end

	table.insertto(var_8_0, var_0_0.GetUIAnimResList(self:getConfig("pop_pic")))

	local var_8_2 = self:getConfig("bgm")

	if noEmptyStr(var_8_2) then
		table.insert(var_8_0, "cue/bgm-" .. var_8_2 .. ".b")
	end

	return var_8_0
end

function ResList.ChapterResConst:GetFleetResList()
	local var_9_0 = {}

	if not var_0_0.IsActive(self) then
		return var_9_0
	end

	_.each(self.fleets or {}, function(arg_10_0)
		if arg_10_0.getFleetType and arg_10_0:getFleetType() == FleetType.Transport then
			var_0_1(var_9_0, "enemies", arg_10_0:getPrefab())
		end

		if arg_10_0.getShips then
			_.each(arg_10_0:getShips(false), function(arg_11_0)
				table.insertto(var_9_0, var_0_0.GetShipStrikeResList(arg_11_0, arg_11_0:GetMapStrikeAnim()))
			end)
		end

		if arg_10_0.getCommanders then
			for iter_10_0, iter_10_1 in pairs(arg_10_0:getCommanders()) do
				table.insertto(var_9_0, var_0_0.GetCommanderResList(iter_10_1))
			end
		end
	end)

	return var_9_0
end

function ResList.ChapterResConst:GetChampionResList()
	local var_12_0 = {}

	if not var_0_0.IsActive(self) then
		return var_12_0
	end

	_.each(self.champions or {}, function(arg_13_0)
		if arg_13_0:getPoolType() == ChapterConst.TemplateOni then
			for iter_13_0 = 1, #(self.fleets or {}) + 1 do
				var_0_1(var_12_0, "enemies", "sp_" .. iter_13_0)
			end
		else
			if arg_13_0:getPoolType() == ChapterConst.TemplateChampion then
				table.insertto(var_12_0, var_0_0.GetEnemyStrikeResList(arg_13_0, "SubSairenTorpedoUI"))
			end

			table.insertto(var_12_0, var_0_0.GetEnemyMapResList(arg_13_0:getConfigTable()))
		end
	end)

	return var_12_0
end

function ResList.ChapterResConst:GetEnemyMapResList(arg_14_1)
	local var_14_0 = {}

	if not self then
		return var_14_0
	end

	if noEmptyStr(self.icon) then
		if self.icon_type == 1 then
			var_0_1(var_14_0, "enemies", self.icon)

			if arg_14_1 then
				var_0_1(var_14_0, "enemies", self.icon .. "_d_blue")
			end

			table.insert(var_14_0, "enemies/fogsrqz")
		else
			table.insertto(var_14_0, ResPathSupport.GetSpineCharListByPrefabName(self.icon))
		end
	end

	var_0_1(var_14_0, ResPathSupport.ConstPath.UI.Effect, self.effect_prefab)

	return var_14_0
end

function ResList.ChapterResConst:GetTransformedUIResList(arg_15_1)
	local var_15_0 = {}

	if not var_0_0.IsActive(self) or not noEmptyStr(arg_15_1) then
		return var_15_0
	end

	local var_15_1 = {
		arg_15_1
	}
	local var_15_2 = self:getConfig("ItemTransformPattern")

	if type(var_15_2) == "table" then
		for iter_15_0, iter_15_1 in ipairs(self:getExtraFlags()) do
			if var_15_2[iter_15_1] then
				local var_15_3 = {}

				for iter_15_2, iter_15_3 in ipairs(var_15_1) do
					if var_15_2[iter_15_1][3] and var_15_2[iter_15_1][3] < 1 then
						table.insert(var_15_3, iter_15_3)
					end

					if var_15_2[iter_15_1][3] then
						if var_15_2[iter_15_1][3] > 0 then
							table.insert(var_15_3, (string.gsub(iter_15_3, var_15_2[iter_15_1][1], var_15_2[iter_15_1][2])))
						end
					end
				end

				var_15_1 = var_15_3
			end
		end
	end

	for iter_15_4, iter_15_5 in ipairs(var_15_1) do
		var_0_1(var_15_0, ResPathSupport.ConstPath.UI.Base, iter_15_5)
	end

	return var_15_0
end

function ResList.ChapterResConst.GetStoryResList(arg_16_0, arg_16_1)
	local var_16_0 = {}

	if not var_0_0.IsActive(arg_16_0) or not arg_16_1 then
		return var_16_0
	end

	local var_16_1 = pg.map_event_template[arg_16_1.attachmentId]

	if not pg.map_event_template[arg_16_1.attachmentId] then
		return var_16_0
	end

	if arg_16_1.data == ChapterConst.Story then
		var_0_1(var_16_0, "boxprefab", var_16_1.icon)
	elseif arg_16_1.data == ChapterConst.StoryObstacle then
		if noEmptyStr(var_16_1.icon) then
			table.insertto(var_16_0, var_0_0.GetTransformedUIResList(arg_16_0, var_16_1.icon .. "_2"))
		end

		var_0_1(var_16_0, ResPathSupport.ConstPath.UI.Base, var_16_1.animation)
	elseif arg_16_1.data == ChapterConst.StoryTrigger and var_16_1.c_type ~= ChapterConst.EvtType_AdditionalFloor and noEmptyStr(var_16_1.icon) then
		table.insertto(var_16_0, var_0_0.GetTransformedUIResList(arg_16_0, var_16_1.icon .. "_1"))

		local var_16_2 = ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Base, var_16_1.icon .. "_1shangceng")

		if checkABExist(var_16_2) then
			table.insert(var_16_0, var_16_2)
		end
	end

	return var_16_0
end

function ResList.ChapterResConst:GetCellAttachmentResList()
	local var_17_0 = {}

	if not var_0_0.IsActive(self) then
		return var_17_0
	end

	local function var_17_1(arg_18_0)
		local var_18_0 = ChapterConst.GetDestroyFX(arg_18_0)

		if noEmptyStr(var_18_0) then
			table.insert(var_17_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, var_18_0))
		end
	end

	for iter_17_0, iter_17_1 in pairs(self.cells or {}) do
		if ChapterConst.IsEnemyAttach(iter_17_1.attachment) then
			var_17_1(iter_17_1)
			table.insertto(var_17_0, var_0_0.GetEnemyMapResList(pg.expedition_data_template[iter_17_1.attachmentId], iter_17_1.attachment ~= ChapterConst.AttachAmbush))
		elseif iter_17_1.attachment == ChapterConst.AttachStory then
			table.insertto(var_17_0, var_0_0.GetStoryResList(self, iter_17_1))
		elseif iter_17_1.attachment == ChapterConst.AttachBox then
			var_0_1(var_17_0, "boxprefab", pg.box_data_template[iter_17_1.attachmentId] and pg.box_data_template[iter_17_1.attachmentId].icon)
		elseif iter_17_1.attachment == ChapterConst.AttachBomb_Enemy then
			var_0_1(var_17_0, "enemies", pg.specialunit_template[iter_17_1.attachmentId] and pg.specialunit_template[iter_17_1.attachmentId].prefab)

			if pg.land_based_template[iter_17_1.attachmentId] and noEmptyStr(pg.land_based_template[iter_17_1.attachmentId].prefab) then
				var_0_1(var_17_0, "enemies", pg.land_based_template[iter_17_1.attachmentId].prefab .. "_d_blue")
			end
		elseif iter_17_1.attachment == ChapterConst.AttachLandbase then
			if pg.land_based_template[iter_17_1.attachmentId] and noEmptyStr(pg.land_based_template[iter_17_1.attachmentId].prefab) then
				if pg.land_based_template[iter_17_1.attachmentId].type == ChapterConst.LBCoastalGun then
					var_0_1(var_17_0, "enemies", pg.land_based_template[iter_17_1.attachmentId].prefab)
					var_0_1(var_17_0, "enemies", pg.land_based_template[iter_17_1.attachmentId].prefab .. "_d_blue")
				elseif pg.land_based_template[iter_17_1.attachmentId].type == ChapterConst.LBFogLightBase then
					var_0_1(var_17_0, "chapter", pg.land_based_template[iter_17_1.attachmentId].prefab)
					var_0_1(var_17_0, "chapter", pg.land_based_template[iter_17_1.attachmentId].prefab .. "_d_blue")
				end
			end
		end

		var_0_1(var_17_0, "chapter", iter_17_1.item)

		if iter_17_1.GetWeatherFlagList then
			for iter_17_2, iter_17_3 in ipairs(iter_17_1:GetWeatherFlagList()) do
				var_0_1(var_17_0, ResPathSupport.ConstPath.UI.Base, pg.weather_data_template[iter_17_3] and pg.weather_data_template[iter_17_3].icon)
			end
		end
	end

	for iter_17_4, iter_17_5 in pairs(self:GetChapterCellAttachemnts() or {}) do
		table.insertto(var_17_0, var_0_0.GetStoryResList(self, iter_17_5))
	end

	for iter_17_6, iter_17_7 in pairs(self.wallAssets or {}) do
		var_0_1(var_17_0, ResPathSupport.ConstPath.UI.Effect, iter_17_7[3])
		var_0_1(var_17_0, ResPathSupport.ConstPath.UI.Effect, iter_17_7[4])
	end

	local var_17_2 = getProxy(ChapterProxy):GetLastDefeatedEnemy(self.id)

	if var_17_2 then
		var_17_1(var_17_2)
	end

	return var_17_0
end

function ResList.ChapterResConst:GetStrategyResList()
	local var_19_0 = {}

	if not var_0_0.IsActive(self) then
		return var_19_0
	end

	local function var_19_1(arg_20_0)
		if pg.strategy_data_template[arg_20_0] and noEmptyStr(pg.strategy_data_template[arg_20_0].icon) then
			table.insert(var_19_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.StrategyIcon, pg.strategy_data_template[arg_20_0].icon))
		end
	end

	_.each(self:GetShowingStrategies(), var_19_1)
	_.each(self.fleets or {}, function(arg_21_0)
		if arg_21_0.getStrategies then
			_.each(arg_21_0:getStrategies(), function(arg_22_0)
				var_19_1(arg_22_0.id)
			end)
		end
	end)

	if self:getChapterSupportFleet() and not self:IsSupportSubmarineStage() then
		var_19_1(ChapterConst.StrategyAirSupportFriendly)
	end

	_.each(self:GetWeather(), function(arg_23_0)
		if pg.weather_data_template[arg_23_0] and noEmptyStr(pg.weather_data_template[arg_23_0].buff_icon) then
			table.insert(var_19_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.StrategyIcon, pg.weather_data_template[arg_23_0].buff_icon))
		end
	end)

	for iter_19_0, iter_19_1 in pairs(self.cells or {}) do
		if iter_19_1.attachment == ChapterConst.AttachStrategy then
			local var_19_2 = ChapterStrategy.New(pg.strategy_data_template[iter_19_1.attachmentId])

			if var_19_2 and var_19_2.count > 0 then
				var_19_1(var_19_2.id)
			end
		end
	end

	_.each(self:GetInteractableStrategies(), function(arg_24_0)
		if arg_24_0.id ~= ChapterConst.StrategyHuntingRange and arg_24_0.id ~= ChapterConst.StrategySubAutoAttack then
			var_19_1(arg_24_0.id)
		end
	end)

	return var_19_0
end

function ResList.ChapterResConst:GetCommanderSkillResList()
	local var_25_0 = {}

	if not var_0_0.IsActive(self) then
		return var_25_0
	end

	_.each(self.fleets or {}, function(arg_26_0)
		if arg_26_0.getCommanders then
			for iter_26_0, iter_26_1 in pairs(arg_26_0:getCommanders()) do
				local var_26_0 = iter_26_1:getSkills()[1]
				local var_26_1 = var_26_0 and var_26_0:getConfig("icon")

				if noEmptyStr(var_26_1) then
					table.insert(var_25_0, "commanderskillicon/" .. var_26_1)
				end
			end
		end
	end)

	return var_25_0
end

function ResList.ChapterResConst:GetFleetIconResList()
	local var_27_0 = {}

	if not var_0_0.IsActive(self) then
		return var_27_0
	end

	_.each(self.fleets or {}, function(arg_28_0)
		if arg_28_0.getShips then
			_.each(arg_28_0:getShips(true), function(arg_29_0)
				table.insertto(var_27_0, ResPathSupport.GetPaintingSquareIconListByPaintingName(arg_29_0:getPainting()))
				table.insertto(var_27_0, ResPathSupport.GetSpineQIconListByPrefabName(arg_29_0:getPrefab()))
			end)
		end
	end)

	return var_27_0
end

function ResList.ChapterResConst.GetUIAnimResList(arg_30_0)
	local var_30_0 = {}

	if noEmptyStr(arg_30_0) then
		table.insert(var_30_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Base, arg_30_0))
	end

	return var_30_0
end

function ResList.ChapterResConst:GetShipStrikeResList(arg_31_1)
	local var_31_0 = var_0_0.GetUIAnimResList(arg_31_1)

	if self then
		local var_31_1 = self:getPainting()

		if noEmptyStr(var_31_1) then
			table.insertto(var_31_0, ResPathSupport.GetPaintingListByPaintingName(var_31_1))
		end

		table.insertto(var_31_0, ResPathSupport.GetSpineCharListByPrefabName(self:getPrefab()))
	end

	return var_31_0
end

function ResList.ChapterResConst:GetEnemyStrikeResList(arg_32_1)
	local var_32_0 = var_0_0.GetUIAnimResList(arg_32_1)

	if self then
		table.insertto(var_32_0, ResPathSupport.GetSpineCharListByPrefabName(self:getPrefab()))
	end

	return var_32_0
end

function ResList.ChapterResConst:GetCommanderResList()
	local var_33_0 = {}

	if self then
		local var_33_1 = self:getConfig("painting")

		if noEmptyStr(var_33_1) then
			table.insert(var_33_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.Commander.CommanderHrz, var_33_1))
		end
	end

	return var_33_0
end

return ResList.ChapterResConst
