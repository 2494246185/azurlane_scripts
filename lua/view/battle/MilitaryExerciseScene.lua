local MilitaryExerciseScene = class("MilitaryExerciseScene", import("..base.BaseUI"))

MilitaryExerciseScene.TYPE_SHOP = 1

function MilitaryExerciseScene:getUIName()
	return "MilitaryExerciseUI"
end

function MilitaryExerciseScene:getResource()
	local var_2_0 = {
		"weaponframes",
		"shiptype",
		"bg/star_level_card_1",
		"bg/star_level_card_2",
		"bg/star_level_card_3",
		"bg/star_level_card_3_1",
		"bg/star_level_card_4",
		"bg/star_level_card_4_0",
		"bg/star_level_card_4_1",
		"bg/star_level_card_5",
		"bg/star_level_card_5_0",
		"bg/star_level_card_5_1"
	}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local function var_2_2(arg_4_0, arg_4_1)
		local var_4_0 = SeasonInfo.getEmblem(arg_4_0, arg_4_1)

		if noEmptyStr(var_4_0) then
			var_2_1("emblem/" .. var_4_0)
			var_2_1("emblem/n_" .. var_4_0)
		end
	end

	local var_2_3 = getProxy(MilitaryExerciseProxy):RawGetSeasonInfo()

	if var_2_3 then
		var_2_2(var_2_3.score, var_2_3.rank)

		local var_2_4 = getProxy(BayProxy)

		local function var_2_5(arg_5_0)
			for iter_5_0, iter_5_1 in ipairs(arg_5_0 or {}) do
				local var_5_0 = var_2_4:RawGetShipById(iter_5_1)

				if var_5_0 then
					var_2_1("SquareIcon/" .. var_5_0:getPainting())
				end
			end
		end

		var_2_5(checkExist(var_2_3, {
			"fleet",
			"mainShips"
		}))
		var_2_5(checkExist(var_2_3, {
			"fleet",
			"vanguardShips"
		}))

		for iter_2_0, iter_2_1 in ipairs(var_2_3.rivals or {}) do
			var_2_2(iter_2_1.score, iter_2_1.rank)

			local var_2_6 = checkExist(pg.ship_skin_template, {
				iter_2_1.skinId,
				"painting"
			})

			if var_2_6 then
				var_2_1("SquareIcon/" .. var_2_6.painting)
			end
		end
	end

	for iter_2_2, iter_2_3 in ipairs(pg.arena_data_rank.all or {}) do
		for iter_2_4, iter_2_5 in ipairs(pg.arena_data_rank[iter_2_3].award_list or {}) do
			if iter_2_5[1] ~= nil then
				var_2_1(Drop.Create(iter_2_5):getIcon())
			end
		end
	end

	return table.insertto(var_2_0, MilitaryExerciseScene.super.getResource(self))
end

function MilitaryExerciseScene:ResUISettings()
	return true
end

function MilitaryExerciseScene:setShips(arg_7_1)
	self.ships = arg_7_1
end

function MilitaryExerciseScene:setFleet(arg_8_1)
	self.fleet = arg_8_1
end

function MilitaryExerciseScene:setRivals(arg_9_1)
	table.sort(arg_9_1, function(arg_10_0, arg_10_1)
		return arg_10_0.rank < arg_10_1.rank
	end)

	self.rivalVOs = arg_9_1
end

function MilitaryExerciseScene:setExerciseCount(arg_11_1)
	self.exerciseCount = arg_11_1
end

function MilitaryExerciseScene:setSeasonTime(arg_12_1)
	self.seasonTime = arg_12_1
end

function MilitaryExerciseScene:setRecoverTime(arg_13_1)
	self.recoverTime = arg_13_1
end

function MilitaryExerciseScene:setActivity(arg_14_1)
	self.activity = arg_14_1

	self:setSeasonTime(arg_14_1.stopTime)
end

function MilitaryExerciseScene:updateSeaInfoVO(arg_15_1)
	self.seasonInfo = arg_15_1

	self:setFleet(arg_15_1.fleet)
	self:setRivals(arg_15_1.rivals)
	self:setExerciseCount(arg_15_1.fightCount)
	self:setRecoverTime(arg_15_1.resetTime)
end

function MilitaryExerciseScene:setSeasonInfo(arg_16_1)
	self:updateSeaInfoVO(arg_16_1)
	self:setFleet(arg_16_1.fleet)
	self:setRivals(arg_16_1.rivals)
	self:setExerciseCount(arg_16_1.fightCount)
	self:setRecoverTime(arg_16_1.resetTime)
	self:updateSeasonTime()
	self:initPlayerFleet()
	self:initPlayerInfo()
	self:updateRivals()
end

function MilitaryExerciseScene:init()
	self.backBtn = self._tf:Find("blur_panel/adapt/top/backBtn")
	self._normalUIMain = pg.UIMgr.GetInstance().UIMain
	self._overlayUIMain = pg.UIMgr.GetInstance().OverlayMain
	self.top = findTF(self._tf, "blur_panel/adapt/top")
	self.awardPanel = self._tf:Find("award_info_panel")

	setActive(self.awardPanel, false)

	self.rivalList = self._tf:Find("center/rival_list")
	self.bottomPanel = self._tf:Find("bottom")
	self.shipTpl = self:getTpl("fleet_info/shiptpl", self.bottomPanel)
	self.emptyTpl = self:getTpl("fleet_info/emptytpl", self.bottomPanel)
	self.mainContainer = self.bottomPanel:Find("fleet_info/main")
	self.vanguardContainer = self.bottomPanel:Find("fleet_info/vanguard")
	self.rankCfg = pg.arena_data_rank

	self:uiStartAnimating()
end

function MilitaryExerciseScene:updatePlayer(arg_18_1)
	self.player = arg_18_1

	setText(findTF(self._tf:Find("bottom/player_info"), "statistics_panel/exploit_bg/score"), arg_18_1.exploit)
end

function MilitaryExerciseScene:uiStartAnimating()
	setAnchoredPosition(self.bottomPanel, {
		y = self.bottomPanel.localPosition.y - 308
	})
	shiftPanel(self.bottomPanel, nil, self.bottomPanel.localPosition.y, 0.3, 0, true, true)
end

function MilitaryExerciseScene:uiExitAnimating()
	shiftPanel(self.bottomPanel, nil, self.bottomPanel.localPosition.y - 308, 0.3, 0, true, true)
end

function MilitaryExerciseScene:didEnter()
	onButton(self, self.backBtn, function()
		if self.isOpenRivalInfoPanel then
			self:closeRivalInfoPanel()
		else
			self:emit(MilitaryExerciseScene.ON_BACK)
		end
	end, SFX_CANCEL)
	setActive(self._tf:Find("stamp"), getProxy(TaskProxy):mingshiTouchFlagEnabled())

	if LOCK_CLICK_MINGSHI then
		setActive(self._tf:Find("stamp"), false)
	end

	onButton(self, self._tf:Find("stamp"), function()
		getProxy(TaskProxy):dealMingshiTouchFlag(10)
	end, SFX_CONFIRM)
	onButton(self, self._tf:Find("bottom/buttons/rank_btn"), function()
		self:emit(MilitaryExerciseMediator.OPEN_RANK)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("bottom/buttons/shop_btn"), function()
		self:emit(MilitaryExerciseMediator.OPEN_SHOP)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("bottom/buttons/award_btn"), function()
		self.isOpenAwards = true

		pg.UIMgr.GetInstance():BlurPanel(self.awardPanel)

		if not self.isInitAward then
			self:initAwards()

			self.isInitAward = true
		else
			setActive(self.awardPanel, true)
		end
	end, SFX_PANEL)
	onButton(self, findTF(self._tf, "center/replace_rival_btn"), function()
		self:emit(MilitaryExerciseMediator.REPLACE_RIVALS)
	end, SFX_PANEL)

	if self.contextData.mode == MilitaryExerciseScene.TYPE_SHOP then
		triggerToggle(self.shopBtn, true)
	end
end

function MilitaryExerciseScene:updateSeasonTime()
	self.seasonInfoPanel = self._tf:Find("center/season_info")

	self:updateSeasonLeftTime(self.seasonTime)
	self:updateRecoverTime(self.recoverTime)
	self:updateExerciseCount()
end

function MilitaryExerciseScene:updateExerciseCount()
	setText(findTF(self.seasonInfoPanel, "count"), math.max(self.exerciseCount or 0, 0) .. "/" .. SeasonInfo.MAX_FIGHTCOUNT)
end

function MilitaryExerciseScene:updateSeasonLeftTime(arg_30_1)
	if self.leftTimeTimer then
		self.leftTimeTimer:Stop()

		self.leftTimeTimer = nil
	end

	local var_30_0 = findTF(self.seasonInfoPanel, "left_time_container/day")
	local var_30_1 = findTF(self.seasonInfoPanel, "left_time_container/time")

	self.leftTimeTimer = Timer.New(function()
		local var_31_0 = arg_30_1 - pg.TimeMgr.GetInstance():GetServerTime()

		if var_31_0 > 0 then
			local var_31_1, var_31_2, var_31_3, var_31_4 = pg.TimeMgr.GetInstance():parseTimeFrom(var_31_0)

			setText(var_30_0, var_31_1)
			setText(var_30_1, string.format("%02d:%02d:%02d", var_31_2, var_31_3, var_31_4))
		else
			setText(var_30_0, 0)
			setText(var_30_1, string.format("%02d:%02d:%02d", 0, 0, 0))
			self.leftTimeTimer:Stop()

			self.leftTimeTimer = nil
		end
	end, 1, -1)

	self.leftTimeTimer:Start()
	self.leftTimeTimer.func()
end

function MilitaryExerciseScene:updateRecoverTime(arg_32_1)
	if self.recoverTimer then
		self.recoverTimer:Stop()

		self.recoverTimer = nil
	end

	local var_32_0 = findTF(self.seasonInfoPanel, "recover_container/time")

	if arg_32_1 == 0 then
		setText(var_32_0, "")

		return
	end

	self.recoverTimer = Timer.New(function()
		local var_33_0 = arg_32_1 - pg.TimeMgr.GetInstance():GetServerTime()

		if var_33_0 > 0 then
			setText(var_32_0, i18n("exercise_count_recover_tip", pg.TimeMgr.GetInstance():DescCDTime(var_33_0)))
		else
			self.recoverTimer:Stop()

			self.recoverTimer = nil
		end
	end, 1, -1)

	self.recoverTimer:Start()
	self.recoverTimer.func()
end

function MilitaryExerciseScene:initPlayerFleet()
	local function var_34_0(arg_35_0, arg_35_1, arg_35_2)
		local var_35_0 = cloneTplTo(self.shipTpl, arg_35_1)

		updateShip(var_35_0, arg_35_0, {
			initStar = true
		})
		setText(findTF(var_35_0, "icon_bg/lv/Text"), arg_35_0.level)
		onButton(self, var_35_0, function()
			self:emit(MilitaryExerciseMediator.OPEN_DOCKYARD, arg_35_2, arg_35_0.id)
		end, SFX_PANEL)
	end

	removeAllChildren(self.mainContainer)
	removeAllChildren(self.vanguardContainer)

	for iter_34_0 = 1, 3 do
		if self.fleet.mainShips[iter_34_0] then
			if self.ships[self.fleet.mainShips[iter_34_0]] then
				var_34_0(self.ships[self.fleet.mainShips[iter_34_0]], self.mainContainer, TeamType.Main)
			end
		else
			onButton(self, findTF(cloneTplTo(self.emptyTpl, self.mainContainer), "icon_bg"), function()
				self:emit(MilitaryExerciseMediator.OPEN_DOCKYARD, TeamType.Main, 0)
			end, SFX_PANEL)
		end
	end

	for iter_34_1 = 1, 3 do
		if self.fleet.vanguardShips[iter_34_1] then
			if self.ships[self.fleet.vanguardShips[iter_34_1]] then
				var_34_0(self.ships[self.fleet.vanguardShips[iter_34_1]], self.vanguardContainer, TeamType.Vanguard)
			end
		else
			onButton(self, findTF(cloneTplTo(self.emptyTpl, self.vanguardContainer), "icon_bg"), function()
				self:emit(MilitaryExerciseMediator.OPEN_DOCKYARD, TeamType.Vanguard, 0)
			end, SFX_PANEL)
		end
	end
end

function MilitaryExerciseScene:initPlayerInfo()
	local var_39_0 = self._tf:Find("bottom/player_info")

	setText(findTF(var_39_0, "statistics_panel/score_bg/score"), self.seasonInfo.score)
	setText(findTF(var_39_0, "statistics_panel/rank_bg/score"), self.seasonInfo.rank)

	local var_39_1 = findTF(var_39_0, "upgrade_rank_tip/level")

	assert(SeasonInfo.getMilitaryRank(self.seasonInfo.score, self.seasonInfo.rank), ">>>" .. self.seasonInfo.score .. "--" .. self.seasonInfo.rank)

	local var_39_2 = SeasonInfo.getEmblem(self.seasonInfo.score, self.seasonInfo.rank)

	LoadImageSpriteAsync("emblem/" .. var_39_2, findTF(var_39_0, "medal_bg/medal"), true)
	LoadImageSpriteAsync("emblem/n_" .. var_39_2, findTF(var_39_0, "medal_bg/Text"), true)

	local var_39_3 = findTF(var_39_0, "exp_slider"):GetComponent("Slider")
	local var_39_4, var_39_5, var_39_6 = SeasonInfo.getNextMilitaryRank(self.seasonInfo.score, self.seasonInfo.rank)
	local var_39_7 = math.min(var_39_5, self.seasonInfo.score)

	setText(findTF(var_39_0, "upgrade_tip/level"), var_39_4)
	setText(findTF(var_39_0, "upgrade_score_tip/level"), var_39_5)
	setText(var_39_1, var_39_6 > 0 and var_39_6 or "-")

	var_39_3.value = var_39_7 / var_39_5
end

function MilitaryExerciseScene:updateRivals()
	self.rivalTFs = {}

	for iter_40_0 = 1, 4 do
		table.insert(self.rivalTFs, self.rivalList:GetChild(iter_40_0 - 1))
	end

	for iter_40_1 = 1, 4 do
		setActive(self.rivalTFs[iter_40_1], iter_40_1 <= #self.rivalVOs)

		if iter_40_1 <= #self.rivalVOs then
			self:updateRival(iter_40_1)
		end
	end
end

function MilitaryExerciseScene:updateRival(arg_41_1)
	local var_41_0 = self.rivalVOs[arg_41_1]

	assert(SeasonInfo.getMilitaryRank(self.rivalVOs[arg_41_1].score, self.rivalVOs[arg_41_1].rank), ">>>" .. self.rivalVOs[arg_41_1].score .. "--" .. self.rivalVOs[arg_41_1].rank)

	local var_41_1 = findTF(self.rivalTFs[arg_41_1], "shiptpl")
	local var_41_2 = SeasonInfo.getEmblem(self.rivalVOs[arg_41_1].score, self.rivalVOs[arg_41_1].rank)

	LoadImageSpriteAsync("emblem/" .. var_41_2, findTF(self.rivalTFs[arg_41_1], "medal"), true)
	LoadImageSpriteAsync("emblem/n_" .. var_41_2, findTF(self.rivalTFs[arg_41_1], "Text"), true)
	updateDrop(var_41_1, {
		type = DROP_TYPE_SHIP,
		id = self.rivalVOs[arg_41_1].icon,
		skinId = self.rivalVOs[arg_41_1].skinId,
		propose = self.rivalVOs[arg_41_1].proposeTime,
		remoulded = self.rivalVOs[arg_41_1].remoulded
	}, {
		initStar = true
	})
	setActive(findTF(var_41_1, "icon_bg/lv"), false)
	setText(findTF(self.rivalTFs[arg_41_1], "rank_bg/rank_container/name"), self.rivalVOs[arg_41_1].rank)
	setText(findTF(self.rivalTFs[arg_41_1], "name_container/name"), self.rivalVOs[arg_41_1].name)
	setText(findTF(self.rivalTFs[arg_41_1], "name_container/lv"), "Lv." .. self.rivalVOs[arg_41_1].level)
	setText(findTF(self.rivalTFs[arg_41_1], "comprehensive_panel/comprehensive/main_fleet/value"), self.rivalVOs[arg_41_1]:GetGearScoreSum(TeamType.Main))
	setText(findTF(self.rivalTFs[arg_41_1], "comprehensive_panel/comprehensive/vanguard_fleet/value"), self.rivalVOs[arg_41_1]:GetGearScoreSum(TeamType.Vanguard))
	onButton(self, self.rivalTFs[arg_41_1], function()
		self:emit(MilitaryExerciseMediator.OPEN_RIVAL_INFO, var_41_0)
	end, SFX_PANEL)
end

function MilitaryExerciseScene:initAwards()
	assert(not self.isInitAward, "已经初始化奖励列表")
	setActive(self.awardPanel, true)
	onButton(self, self.awardPanel:Find("top/btnBack"), function()
		self:closeAwards()
	end, SFX_CANCEL)
	setText(self.awardPanel:Find("bg/frame/content/time_panel/Text"), i18n("exercise_time_tip", "   " .. os.date("%Y.%m.%d", self.activity.data1) .. " — " .. os.date("%Y.%m.%d", self.activity.stopTime)))
	setText(self.awardPanel:Find("bg/frame/content/desc_panel/Text"), i18n("exercise_rule_tip"))

	local var_43_0 = self.awardPanel:Find("bg/frame/content/award_panel/award_list")
	local var_43_1 = self:getTpl("awardtpl", var_43_0)
	local var_43_2 = self:getTpl("awards/equipmenttpl", var_43_1)
	local var_43_3 = var_43_0:Find("linetpl")

	setText(self.awardPanel:Find("bg/frame/content/award_panel/Text"), i18n("exercise_award_tip"))

	local function var_43_4(arg_45_0, arg_45_1)
		local var_45_0 = arg_45_0:Find("awards")

		setText(findTF(arg_45_0, "Text"), self.rankCfg[arg_45_1].name .. ":")

		for iter_45_0, iter_45_1 in ipairs(self.rankCfg[arg_45_1].award_list) do
			local var_45_1 = cloneTplTo(var_43_2, var_45_0)

			updateDrop(var_45_1, {
				type = iter_45_1[1],
				id = iter_45_1[2],
				count = iter_45_1[3]
			})
			onButton(self, var_45_1:Find("icon_bg"), function()
				self:emit(BaseUI.ON_ITEM, iter_45_1[1] == 1 and id2ItemId(iter_45_1[2]) or iter_45_1[2])
			end, SFX_PANEL)
		end

		setText(findTF(arg_45_0, "upgrade_score_tip/level"), self.rankCfg[arg_45_1].point)
		setText(findTF(arg_45_0, "upgrade_rank_tip/level"), (self.rankCfg[arg_45_1].order > 0 or nil) and (self.rankCfg[arg_45_1].order or "-"))
	end

	for iter_43_0 = #self.rankCfg.all, 1, -1 do
		if #self.rankCfg[self.rankCfg.all[iter_43_0]].award_list > 0 then
			var_43_4(cloneTplTo(var_43_1, var_43_0), self.rankCfg.all[iter_43_0])
			cloneTplTo(var_43_3, var_43_0)
		end
	end
end

function MilitaryExerciseScene:closeAwards()
	if self.isOpenAwards then
		setActive(self.awardPanel, false)

		self.isOpenAwards = false

		pg.UIMgr.GetInstance():UnOverlayPanel(self.awardPanel, self._tf)
	end
end

function MilitaryExerciseScene:onBackPressed()
	if self.isOpenAwards then
		self:closeAwards()
	else
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
		self:emit(MilitaryExerciseScene.ON_BACK)
	end
end

function MilitaryExerciseScene:willExit()
	if self.tweens then
		cancelTweens(self.tweens)
	end

	if self.leftTimeTimer then
		self.leftTimeTimer:Stop()

		self.leftTimeTimer = nil
	end

	if self.recoverTimer then
		self.recoverTimer:Stop()

		self.recoverTimer = nil
	end

	self:closeAwards()
end

return MilitaryExerciseScene
