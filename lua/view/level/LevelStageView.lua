local LevelStageView = class("LevelStageView", import("..base.BaseSubView"))

function LevelStageView:Ctor(...)
	LevelStageView.super.Ctor(self, ...)

	self.isFrozen = nil

	self:bind(LevelUIConst.ON_FROZEN, function()
		self.isFrozen = true

		if self.cgComp then
			self.cgComp.blocksRaycasts = false
		end
	end)
	self:bind(LevelUIConst.ON_UNFROZEN, function()
		self.isFrozen = nil

		if self.cgComp then
			self.cgComp.blocksRaycasts = true
		end
	end)

	self.toastQueue = {}

	self:bind(LevelUIConst.ADD_TOAST_QUEUE, function(arg_4_0, arg_4_1)
		table.insert(self.toastQueue, arg_4_1)

		if #self.toastQueue > 1 then
			return
		end

		self:Toast()
	end)
end

function LevelStageView:getUIName()
	return "LevelStageView"
end

function LevelStageView:getResource()
	local var_6_0 = {
		"ui/levelstageview_atlas",
		"enemycount",
		"passstate",
		"strategyicon/submarine_approach",
		"strategyicon/range_invisible",
		"strategyicon/range_visible",
		"strategyicon/sub_dont_auto_attack",
		"strategyicon/sub_auto_attack",
		"weaponframes",
		"shiptype",
		"ui/iconcolorful"
	}

	table.insertto(var_6_0, ResList.LevelStageViewResConst.GetResource(self.contextData))

	return table.insertto(var_6_0, LevelStageView.super.getResource(self))
end

function LevelStageView:downloadStageRes(arg_7_1)
	local var_7_0 = self.contextData.chapterVO

	if self._state == LevelStageView.STATES.DESTROY or not ResList.ChapterResConst.IsActive(self.contextData.chapterVO) then
		return
	end

	SplitPackConst.DownloadByLuaArr(ResList.LevelStageViewResConst.GetResource(self.contextData), function()
		if self._state == LevelStageView.STATES.DESTROY or not ResList.ChapterResConst.IsActive(self.contextData.chapterVO) or self.contextData.chapterVO.id ~= var_7_0.id then
			return
		end

		if self.contextData.chapterVO ~= var_7_0 then
			self:downloadStageRes(arg_7_1)

			return
		end

		arg_7_1()
	end)
end

function LevelStageView:OnInit()
	self:InitUI()
	self:AddListener()

	self.loader = AutoLoader.New()
	self.cgComp = GetOrAddComponent(self._go, typeof(CanvasGroup))
	self.cgComp.blocksRaycasts = not self.isFrozen

	self:Show()
end

function LevelStageView:OnDestroy()
	if self.stageTimer then
		self.stageTimer:Stop()

		self.stageTimer = nil
	end

	self:ClearSubViews()
	self:DestroyAutoFightPanel()
	self:DestroyWinConditionPanel()
	self:DestroyToast()
	self.loader:Clear()
	self:Hide()
end

local var_0_1 = -300

function LevelStageView:InitUI()
	self.topStage = self._tf:Find("top_stage")

	setActive(self.topStage, true)

	self.bottomStage = self._tf:Find("bottom_stage")
	self.normalRole = findTF(self.bottomStage, "Normal")
	self.funcBtn = self.normalRole:Find("func_button")
	self.retreatBtn = self.normalRole:Find("retreat_button")
	self.switchBtn = self.normalRole:Find("switch_button")
	self.helpBtn = self.normalRole:Find("help_button")
	self.shengfuBtn = self.normalRole:Find("shengfu/shengfu_button")
	self.actionRole = findTF(self.bottomStage, "Action")
	self.missileStrikeRole = findTF(self.actionRole, "MissileStrike")
	self.airExpelRole = findTF(self.actionRole, "AirExpel")

	setActive(self.bottomStage, true)
	setAnchoredPosition(self.normalRole, {
		x = 0,
		y = 0
	})
	setActive(self.normalRole, true)
	setAnchoredPosition(self.actionRole, {
		x = 0,
		y = var_0_1
	})
	setActive(self.actionRole, false)
	eachChild(self.actionRole, function(arg_12_0)
		setActive(arg_12_0, false)
	end)

	self.leftStage = self._tf:Find("left_stage")

	setActive(self.leftStage, true)

	self.rightStage = self._tf:Find("right_stage")
	self.bombPanel = self.rightStage:Find("bomb_panel")
	self.panelBarrier = self.rightStage:Find("panel_barrier")
	self.strategyPanelAnimator = self.rightStage:Find("event"):GetComponent(typeof(Animator))
	self.autoBattleBtn = self.rightStage:Find("event/collapse/lock_fleet")
	self.showDetailBtn = self.rightStage:Find("event/detail/show_detail")

	setActive(self.panelBarrier, false)
	setActive(self.rightStage, true)

	self.airSupremacy = self.topStage:Find("msg_panel/air_supremacy")

	setAnchoredPosition(self.topStage, {
		y = self.topStage.rect.height
	})
	setAnchoredPosition(self.leftStage, {
		x = -self.leftStage.rect.width - 200
	})
	setAnchoredPosition(self.rightStage, {
		x = self.rightStage.rect.width + 300
	})
	setAnchoredPosition(self.bottomStage, {
		y = -self.bottomStage.rect.height
	})

	self.attachSubViews = {}
end

function LevelStageView:AddListener()
	self:bind(LevelUIConst.TRIGGER_ACTION, function()
		self:tryAutoTrigger()
	end)
	self:bind(LevelUIConst.STRATEGY_PANEL_AUTOFIGHT_ACTIVE, function(arg_15_0, arg_15_1)
		self.strategyPanelAnimator:SetBool("IsActive", arg_15_1)

		self.bottomStageInactive = arg_15_1

		self:ShiftBottomStage(not arg_15_1)
	end)
	self:bind(LevelUIConst.ON_CLICK_GRID_QUAD, function(arg_16_0, arg_16_1)
		self:ClickGridCellNormal(arg_16_1)
	end)
	onButton(self, self.topStage:Find("option"), function()
		self:emit(BaseUI.ON_HOME)
	end, SFX_CANCEL)
	onButton(self, self.topStage:Find("back_button"), function()
		self:emit(LevelUIConst.SWITCH_TO_MAP)
	end, SFX_CANCEL)
	onButton(self, self.retreatBtn, function()
		local var_19_0 = "levelScene_whether_to_retreat"

		if self.contextData.chapterVO:existOni() then
			var_19_0 = "levelScene_oni_retreat"
		elseif self.contextData.chapterVO:isPlayingWithBombEnemy() then
			var_19_0 = "levelScene_bomb_retreat"
		elseif self.contextData.chapterVO:getPlayType() == ChapterConst.TypeTransport and not self.contextData.map:isSkirmish() then
			var_19_0 = "levelScene_escort_retreat"
		elseif self.contextData.map:isRemaster() then
			var_19_0 = "archives_whether_to_retreat"
		end

		self:HandleShowMsgBox({
			content = i18n(var_19_0),
			onYes = ChapterOpCommand.PrepareChapterRetreat
		})
	end, SFX_UI_WEIGHANCHOR_WITHDRAW)
	onButton(self, self.switchBtn, function()
		local var_20_0 = self.contextData.chapterVO:getNextValidIndex()

		if var_20_0 > 0 then
			self:emit(LevelMediator2.ON_OP, {
				type = ChapterConst.OpSwitch,
				id = self.contextData.chapterVO.fleets[var_20_0].id
			})
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("formation_switch_failed"))
		end
	end, SFX_PANEL)
	onButton(self, self.autoBattleBtn, function()
		local var_21_0 = getProxy(ChapterProxy)

		var_21_0:UpdateSkipPrecombat(not var_21_0:GetSkipPrecombat())
	end, SFX_PANEL)
	onButton(self, self.showDetailBtn, function()
		self._showStrategyDetail = not self._showStrategyDetail and true

		self:updateStageStrategy()
	end, SFX_PANEL)
	onButton(self, self.funcBtn, function()
		local var_23_0 = self.contextData.chapterVO

		if not self.contextData.chapterVO:inWartime() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_time_out"))

			return
		end

		local var_23_1 = var_23_0.fleet
		local var_23_2 = var_23_0:getChapterCell(var_23_0.fleet.line.row, var_23_0.fleet.line.column)
		local var_23_3 = false

		local function var_23_4(arg_24_0)
			return pg.expedition_data_template[arg_24_0.attachmentId].dungeon_id > 0
		end

		if var_23_0:existVisibleChampion(var_23_0.fleet.line.row, var_23_0.fleet.line.column) then
			var_23_3 = true

			if chapter_skip_battle == 1 then
				if pg.SdkMgr.GetInstance():CheckPretest() then
					self:emit(LevelMediator2.ON_OP, {
						type = ChapterConst.OpSkipBattle,
						id = var_23_1.id
					})

					goto label_23_0
				end
			end

			if not var_23_4((var_23_0:getChampion(var_23_0.fleet.line.row, var_23_0.fleet.line.column))) then
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpPreClear,
					id = var_23_1.id
				})
			elseif var_23_0:IsSkipPrecombat() then
				self:emit(LevelMediator2.ON_START)
			else
				self:emit(LevelMediator2.ON_STAGE)
			end
		elseif var_23_2.attachment == ChapterConst.AttachAmbush and var_23_2.flag == ChapterConst.CellFlagAmbush then
			local var_23_5

			var_23_5 = coroutine.wrap(function()
				self:emit(LevelUIConst.DO_AMBUSH_WARNING, var_23_5)
				coroutine.yield()
				self:emit(LevelUIConst.DISPLAY_AMBUSH_INFO, var_23_5)
				coroutine.yield()
			end)

			;(nil)()

			var_23_3 = true
		elseif ChapterConst.IsEnemyAttach(var_23_2.attachment) then
			if var_23_2.flag == ChapterConst.CellFlagActive then
				var_23_3 = true

				if chapter_skip_battle == 1 then
					if pg.SdkMgr.GetInstance():CheckPretest() then
						self:emit(LevelMediator2.ON_OP, {
							type = ChapterConst.OpSkipBattle,
							id = var_23_1.id
						})

						goto label_23_0
					end
				end

				if not var_23_4(var_23_2) then
					self:emit(LevelMediator2.ON_OP, {
						type = ChapterConst.OpPreClear,
						id = var_23_1.id
					})
				elseif var_23_0:IsSkipPrecombat() then
					self:emit(LevelMediator2.ON_START)
				else
					self:emit(LevelMediator2.ON_STAGE)
				end
			end
		elseif var_23_2.attachment == ChapterConst.AttachBox then
			if var_23_2.flag == ChapterConst.CellFlagActive then
				var_23_3 = true

				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpBox,
					id = var_23_1.id
				})
			end
		elseif var_23_2.attachment == ChapterConst.AttachSupply and var_23_2.attachmentId > 0 then
			var_23_3 = true

			local var_23_6, var_23_7 = var_23_0:getFleetAmmo(var_23_0.fleet)

			if var_23_7 < var_23_6 then
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpSupply,
					id = var_23_1.id
				})
			else
				pg.TipsMgr.GetInstance():ShowTips(i18n("level_ammo_enough"))
			end
		elseif var_23_2.attachment == ChapterConst.AttachStory then
			var_23_3 = true

			local var_23_8 = pg.map_event_template[var_23_2.attachmentId].gametip

			if pg.map_event_template[var_23_2.attachmentId].memory == 0 then
				return
			end

			local var_23_9 = pg.NewStoryMgr.GetInstance():StoryId2StoryName(pg.map_event_template[var_23_2.attachmentId].memory)

			pg.ConnectionMgr.GetInstance():Send(11017, {
				story_id = pg.map_event_template[var_23_2.attachmentId].memory
			}, 11018, function(arg_26_0)
				return
			end)
			pg.NewStoryMgr.GetInstance():Play(var_23_9, function(arg_27_0, arg_27_1)
				local var_27_0 = arg_27_1 or 1

				if var_23_2.flag == ChapterConst.CellFlagActive then
					self:emit(LevelMediator2.ON_OP, {
						type = ChapterConst.OpStory,
						id = var_23_1.id,
						arg1 = var_27_0
					})
				end

				if var_23_8 ~= "" then
					local var_27_1

					for iter_27_0, iter_27_1 in ipairs(pg.memory_template.all) do
						if table.contains(pg.memory_template[iter_27_1].unlock_pre, var_23_9) then
							var_27_1 = pg.memory_template[iter_27_1].title
						end
					end

					pg.TipsMgr.GetInstance():ShowTips(i18n(var_23_8, var_27_1))
				end
			end)
		end

		::label_23_0::

		if not var_23_3 then
			if var_23_0:getRound() == ChapterConst.RoundEnemy then
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpEnemyRound
				})
			else
				pg.TipsMgr.GetInstance():ShowTips(i18n("level_click_to_move"))
			end
		end
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		if self.contextData.chapterVO then
			if self.contextData.chapterVO:existOni() then
				self:HandleShowMsgBox({
					type = MSGBOX_TYPE_HELP,
					helps = i18n("levelScene_sphunt_help_tip")
				})
			elseif self.contextData.chapterVO:isTypeDefence() then
				self:HandleShowMsgBox({
					type = MSGBOX_TYPE_HELP,
					helps = i18n("help_battle_defense")
				})
			elseif self.contextData.chapterVO:isPlayingWithBombEnemy() then
				self:HandleShowMsgBox({
					type = MSGBOX_TYPE_HELP,
					helps = i18n("levelScene_bomb_help_tip")
				})
			else
				if pg.map_event_list[self.contextData.chapterVO.id] then
					if next(noEmptyStr(pg.map_event_list[self.contextData.chapterVO.id].help_pictures) or {}) then
						local var_28_0 = {
							disableScroll = true,
							pageMode = true,
							defaultpage = 1,
							ImageMode = true,
							windowSize = {
								x = 1263,
								y = 873
							},
							windowPos = {
								y = -70
							},
							helpSize = {
								x = 1176,
								y = 1024
							}
						}

						for iter_28_0, iter_28_1 in pairs(pg.map_event_list[self.contextData.chapterVO.id].help_pictures) do
							table.insert(var_28_0, {
								icon = {
									path = "",
									atlas = iter_28_1
								}
							})
						end

						self:HandleShowMsgBox({
							type = MSGBOX_TYPE_HELP,
							helps = var_28_0
						})

						goto label_28_0
					end
				end

				self:HandleShowMsgBox({
					type = MSGBOX_TYPE_HELP,
					helps = pg.gametip.help_level_ui.tip
				})
			end
		end

		::label_28_0::
	end, SFX_PANEL)
	onButton(self, self.airSupremacy, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("help_battle_ac")
		})
	end, SFX_UI_CLICK)
	onButton(self, self.shengfuBtn, function()
		self:DisplayWinConditionPanel()
	end)
end

function LevelStageView:SetSeriesOperation(arg_31_1)
	self.seriesOperation = arg_31_1
end

function LevelStageView:SetGrid(arg_32_1)
	self.grid = arg_32_1
end

function LevelStageView:SetPlayer(arg_33_1)
	return
end

function LevelStageView:SwitchToChapter(arg_34_1)
	local var_34_0 = findTF(self.rightStage, "target")
	local var_34_1 = findTF(self.rightStage, "skip_events")

	setActive(findTF(self.topStage, "msg_panel/ambush"), arg_34_1:existAmbush())
	setActive(self.airSupremacy, OPEN_AIR_DOMINANCE and arg_34_1:getConfig("air_dominance") > 0)

	local var_34_2 = arg_34_1:isLoop()

	setActive(self.autoBattleBtn, var_34_2)

	if var_34_2 then
		self:UpdateSkipPreCombatMark()
		self:UpdateAutoFightPanel()
		self:UpdateAutoFightMark()
	end

	self.achieveOriginalY = -240

	setText(var_34_1:Find("Label"), i18n("map_event_skip"))

	local var_34_3 = "skip_events_on_" .. arg_34_1.id

	if arg_34_1:getConfig("event_skip") == 1 then
		if arg_34_1.progress > 0 or arg_34_1.defeatCount > 0 or arg_34_1.passCount > 0 then
			setActive(var_34_1, true)

			var_34_0.anchoredPosition = Vector2.New(var_34_0.anchoredPosition.x, self.achieveOriginalY - 40)
			GetComponent(var_34_1, typeof(Toggle)).isOn = PlayerPrefs.GetInt(var_34_3, 1) == 1

			onToggle(self, var_34_1, function(arg_35_0)
				PlayerPrefs.SetInt(var_34_3, arg_35_0 and 1 or 0)
			end)
		else
			setActive(var_34_1, false)

			if not PlayerPrefs.HasKey(var_34_3) then
				PlayerPrefs.SetInt(var_34_3, 0)
			end
		end
	else
		setActive(var_34_1, false)

		var_34_0.anchoredPosition = Vector2.New(var_34_0.anchoredPosition.x, self.achieveOriginalY)
	end

	setActive(var_34_0, arg_34_1:existAchieve())
	setActive(self.retreatBtn, true)
	self.seriesOperation()
end

function LevelStageView:SwitchToMap()
	self:DestroyAutoFightPanel()
end

function LevelStageView:UpdateSkipPreCombatMark()
	local var_37_0 = getProxy(ChapterProxy):GetSkipPrecombat() and "auto_battle_on" or "auto_battle_off"

	self.loader:GetOffSpriteRequest(self.autoBattleBtn)
	self.loader:GetSprite("ui/levelstageview_atlas", var_37_0, self.autoBattleBtn, true)
end

function LevelStageView:updateStageInfo()
	local var_38_0 = self.contextData.chapterVO
	local var_38_1 = findTF(self.topStage, "timer")
	local var_38_2 = findTF(self.topStage, "unlimit")

	setWidgetText(var_38_1, "--:--:--")

	if self.stageTimer then
		self.stageTimer:Stop()
	end

	if self.contextData.chapterVO:getRemainTime() > self.contextData.chapterVO:getConfig("time") or self.contextData.chapterVO:getConfig("time") >= 8640000 then
		setActive(var_38_1, false)
		setActive(var_38_2, true)
	else
		setActive(var_38_1, true)
		setActive(var_38_2, false)

		self.stageTimer = Timer.New(function()
			if IsNil(var_38_1) then
				return
			end

			setWidgetText(var_38_1, pg.TimeMgr.GetInstance():DescCDTime((var_38_0:getRemainTime())))
		end, 1, -1)

		self.stageTimer:Start()
		self.stageTimer.func()
	end
end

function LevelStageView:updateAmbushRate(arg_40_1, arg_40_2)
	local var_40_0 = self.contextData.chapterVO

	if not self.contextData.chapterVO:existAmbush() then
		return
	end

	local var_40_1 = var_40_0.fleet
	local var_40_2 = findTF(self.topStage, "msg_panel/ambush/value2")

	setText(findTF(self.topStage, "msg_panel/ambush/label1"), i18n("level_scene_title_word_1"))
	setText(findTF(self.topStage, "msg_panel/ambush/value1"), math.floor((var_40_0.fleet:getInvestSums())))
	setText(findTF(self.topStage, "msg_panel/ambush/label2"), i18n("level_scene_title_word_2"))

	if not var_40_0.activateAmbush then
		setText(var_40_2, i18n("ambush_display_none"))
		setTextColor(var_40_2, Color.New(0.4, 0.4, 0.4))
	else
		local var_40_3, var_40_4 = ChapterConst.GetAmbushDisplay((not arg_40_2 or not var_40_0:existEnemy(ChapterConst.SubjectPlayer, arg_40_1.row, arg_40_1.column)) and var_40_0:getAmbushRate(var_40_1, arg_40_1))

		setText(var_40_2, var_40_3)
		setTextColor(var_40_2, var_40_4)
	end
end

function LevelStageView:updateStageAchieve()
	if not self.contextData.chapterVO:existAchieve() then
		return
	end

	local var_41_0 = self.contextData.chapterVO.achieves
	local var_41_1 = findTF(self.rightStage, "target")

	setActive(var_41_1, true)

	local var_41_2 = findTF(var_41_1, "detail")
	local var_41_3 = findTF(var_41_2, "achieve")
	local var_41_4 = findTF(var_41_2, "achieves")
	local var_41_5 = findTF(var_41_2, "click")
	local var_41_6 = findTF(var_41_1, "collapse")
	local var_41_7 = findTF(var_41_6, "star")
	local var_41_8 = findTF(var_41_6, "stars")

	setActive(var_41_3, false)
	setActive(var_41_7, false)
	removeAllChildren(var_41_4)
	removeAllChildren(var_41_8)

	for iter_41_0, iter_41_1 in ipairs(var_41_0) do
		local var_41_9 = cloneTplTo(var_41_3, var_41_4)
		local var_41_10 = ChapterConst.IsAchieved(iter_41_1)

		setActive(findTF(var_41_9, "star"), var_41_10)

		local var_41_11 = findTF(var_41_9, "desc")

		setText(var_41_11, ChapterConst.GetAchieveDesc(iter_41_1.type, self.contextData.chapterVO))
		setTextColor(var_41_11, (var_41_10 or nil) and (Color.yellow or Color.white))

		cloneTplTo(var_41_7, var_41_8):GetComponent(typeof(Image)).enabled = var_41_10
	end

	onButton(self, var_41_5, function()
		shiftPanel(var_41_2, var_41_2.rect.width + 200, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
		shiftPanel(var_41_6, 0, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	end, SFX_PANEL)
	onButton(self, var_41_6, function()
		shiftPanel(var_41_2, 30, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
		shiftPanel(var_41_6, var_41_6.rect.width + 200, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	end, SFX_PANEL)

	if not self.isAchieveFirstInit then
		self.isAchieveFirstInit = true

		triggerButton(var_41_5)
	end
end

function LevelStageView:updateStageBarrier()
	setActive(self.panelBarrier, self.contextData.chapterVO:existOni())

	if not self.contextData.chapterVO:existOni() then
		return
	end

	local var_44_0 = self.panelBarrier:Find("btn_barrier")

	setText(var_44_0:Find("nums"), self.contextData.chapterVO.modelCount)
	onButton(self, var_44_0, function()
		if self.grid.quadState == ChapterConst.QuadStateBarrierSetting then
			self.grid:updateQuadCells(ChapterConst.QuadStateNormal)

			return
		end

		self.grid:updateQuadCells(ChapterConst.QuadStateBarrierSetting)
	end, SFX_PANEL)
end

function LevelStageView:updateBombPanel(arg_46_1)
	setActive(self.bombPanel, self.contextData.chapterVO:isPlayingWithBombEnemy())

	if self.contextData.chapterVO:isPlayingWithBombEnemy() then
		setText(self.bombPanel:Find("tx_step"), self.contextData.chapterVO:getBombChapterInfo().action_times - math.floor(self.contextData.chapterVO.roundIndex / 2))

		local var_46_0 = self.bombPanel:Find("tx_score")
		local var_46_1 = tonumber(getText(var_46_0))
		local var_46_2 = self.contextData.chapterVO.modelCount

		LeanTween.cancel(go(var_46_0))

		if arg_46_1 and var_46_1 ~= self.contextData.chapterVO.modelCount then
			LeanTween.scale(go(var_46_0), Vector3(1.5, 1.5, 1), 0.2)
			LeanTween.value(go(var_46_0), var_46_1, self.contextData.chapterVO.modelCount, (self.contextData.chapterVO.modelCount - var_46_1) * 0.1):setOnUpdate(System.Action_float(function(arg_47_0)
				setText(var_46_0, math.floor(arg_47_0))
			end)):setOnComplete(System.Action(function()
				setText(var_46_0, var_46_2)
			end)):setEase(LeanTweenType.easeInOutSine):setDelay(0.2)
			LeanTween.scale(go(var_46_0), Vector3.one, 0.3):setDelay(1 + (self.contextData.chapterVO.modelCount - var_46_1) * 0.1)
		else
			var_46_0.localScale = Vector3.one

			setText(var_46_0, self.contextData.chapterVO.modelCount)
		end
	end
end

function LevelStageView:updateFleetBuff()
	self:downloadStageRes(function()
		self:updateFleetBuffAfterDownload()
	end)
end

function LevelStageView:updateFleetBuffAfterDownload()
	local var_51_0 = self.contextData.chapterVO.fleet
	local var_51_1 = self.contextData.chapterVO:GetShowingStrategies()

	if self.contextData.chapterVO:getChapterSupportFleet() and not self.contextData.chapterVO:IsSupportSubmarineStage() then
		table.insert(var_51_1, ChapterConst.StrategyAirSupportFriendly)
	end

	local var_51_2 = {}
	local var_51_3 = self.contextData.chapterVO:GetSubmarineFleet()

	if var_51_3 then
		local var_51_4 = _.filter(var_51_3:getStrategies(), function(arg_52_0)
			return pg.strategy_data_template[arg_52_0.id].type == ChapterConst.StgTypePassive and arg_52_0.count > 0
		end)

		if var_51_4 and #var_51_4 > 0 then
			_.each(var_51_4, function(arg_53_0)
				table.insert(var_51_2, {
					id = arg_53_0.id,
					count = arg_53_0.count
				})
			end)
		end
	end

	local var_51_5 = underscore.filter(self.contextData.chapterVO:GetWeather(), function(arg_54_0)
		return noEmptyStr(pg.weather_data_template[arg_54_0].buff_icon)
	end)
	local var_51_6 = 0

	if self.contextData.chapterVO:ExistDivingChampion() then
		var_51_6 = 1
	end

	local var_51_7 = _.map(_.values(self.contextData.chapterVO.fleet:getCommanders()), function(arg_55_0)
		return arg_55_0:getSkills()[1]
	end)
	local var_51_8 = findTF(self.topStage, "icon_list/fleet_buffs")
	local var_51_9 = UIItemList.New(var_51_8, var_51_8:GetChild(0))

	var_51_9:make(function(arg_56_0, arg_56_1, arg_56_2)
		setActive(findTF(arg_56_2, "frame"), false)
		setActive(findTF(arg_56_2, "Text"), false)
		setActive(findTF(arg_56_2, "times"), false)

		if arg_56_0 == UIItemList.EventUpdate then
			local var_56_0 = GetComponent(arg_56_2, typeof(LayoutElement))

			var_56_0.preferredWidth = 64
			var_56_0.preferredHeight = 64

			if arg_56_1 + 1 <= #var_51_1 then
				local var_56_1 = pg.strategy_data_template[var_51_1[arg_56_1 + 1]]

				GetImageSpriteFromAtlasAsync("strategyicon/" .. pg.strategy_data_template[var_51_1[arg_56_1 + 1]].icon, "", arg_56_2)

				local var_56_2

				if pg.strategy_data_template[var_51_1[arg_56_1 + 1]].type == ChapterConst.StgTypeBindFleetPassive then
					var_56_2 = var_51_0:GetStrategyCount(var_51_1[arg_56_1 + 1])

					setActive(findTF(arg_56_2, "times"), true)
					setText(findTF(arg_56_2, "times"), var_56_2)
				end

				local var_56_3 = pg.strategy_data_template[var_51_1[arg_56_1 + 1]].iconSize

				if pg.strategy_data_template[var_51_1[arg_56_1 + 1]].iconSize ~= "" then
					var_56_0.preferredWidth = var_56_3[1]
					var_56_0.preferredHeight = var_56_3[2]
				end

				onButton(self, arg_56_2, function()
					self:HandleShowMsgBox({
						yesText = "text_confirm",
						hideNo = true,
						content = "",
						type = MSGBOX_TYPE_SINGLE_ITEM,
						drop = {
							type = DROP_TYPE_STRATEGY,
							id = var_56_1.id,
							cfg = var_56_1,
							count = var_56_2
						}
					})
				end, SFX_PANEL)

				return
			end

			arg_56_1 = arg_56_1 - #var_51_1

			if arg_56_1 + 1 <= #var_51_5 then
				local var_56_4 = pg.weather_data_template[var_51_5[arg_56_1 + 1]]

				GetImageSpriteFromAtlasAsync("strategyicon/" .. pg.weather_data_template[var_51_5[arg_56_1 + 1]].buff_icon, "", arg_56_2)
				onButton(self, arg_56_2, function()
					self:HandleShowMsgBox({
						hideNo = true,
						type = MSGBOX_TYPE_DROP_ITEM,
						name = var_56_4.name,
						content = var_56_4.buff_desc,
						iconPath = {
							"strategyicon/" .. var_56_4.buff_icon
						},
						yesText = pg.MsgboxMgr.TEXT_CONFIRM
					})
				end, SFX_PANEL)

				return
			end

			arg_56_1 = arg_56_1 - #var_51_5

			if arg_56_1 + 1 <= #var_51_2 then
				local var_56_5 = var_51_2[arg_56_1 + 1]
				local var_56_6 = pg.strategy_data_template[var_51_2[arg_56_1 + 1].id]

				GetImageSpriteFromAtlasAsync("strategyicon/" .. pg.strategy_data_template[var_51_2[arg_56_1 + 1].id].icon, "", arg_56_2)
				setActive(findTF(arg_56_2, "times"), true)
				setText(findTF(arg_56_2, "times"), var_51_2[arg_56_1 + 1].count)
				onButton(self, arg_56_2, function()
					self:HandleShowMsgBox({
						yesText = "text_confirm",
						hideNo = true,
						content = "",
						type = MSGBOX_TYPE_SINGLE_ITEM,
						drop = {
							type = DROP_TYPE_STRATEGY,
							id = var_56_6.id,
							cfg = var_56_6
						},
						extendDesc = string.format(i18n("word_rest_times"), var_56_5.count)
					})
				end, SFX_PANEL)

				return
			end

			arg_56_1 = arg_56_1 - #var_51_2

			if arg_56_1 + 1 <= var_51_6 then
				GetImageSpriteFromAtlasAsync("strategyicon/submarine_approach", "", arg_56_2)
				onButton(self, arg_56_2, function()
					self:HandleShowMsgBox({
						yesText = "text_confirm",
						hideNo = true,
						type = MSGBOX_TYPE_DROP_ITEM,
						name = i18n("submarine_approach"),
						content = i18n("submarine_approach_desc"),
						iconPath = {
							"strategyicon/submarine_approach"
						}
					})
				end, SFX_PANEL)

				return
			end

			arg_56_1 = arg_56_1 - var_51_6

			local var_56_7 = var_51_7[arg_56_1 + 1]

			GetImageSpriteFromAtlasAsync("commanderskillicon/" .. var_51_7[arg_56_1 + 1]:getConfig("icon"), "", arg_56_2)
			setText(findTF(arg_56_2, "Text"), "Lv." .. var_51_7[arg_56_1 + 1]:getConfig("lv"))
			setActive(findTF(arg_56_2, "Text"), true)
			setActive(findTF(arg_56_2, "frame"), true)
			onButton(self, arg_56_2, function()
				self:emit(LevelMediator2.ON_COMMANDER_SKILL, var_56_7)
			end, SFX_PANEL)
		end
	end)
	var_51_9:align(#var_51_1 + #var_51_2 + #var_51_5 + var_51_6 + #var_51_7)

	if OPEN_AIR_DOMINANCE and self.contextData.chapterVO:getConfig("air_dominance") > 0 then
		self:updateAirDominance()
	end

	self:updateEnemyCount()
	self:updateChapterBuff()
end

function LevelStageView:updateEnemyCount()
	local var_62_0 = self.contextData.chapterVO
	local var_62_1 = findTF(self.topStage, "icon_list/enemy_count")
	local var_62_2 = tobool(underscore.detect(self.contextData.chapterVO.achieves, function(arg_63_0)
		return (arg_63_0.type == ChapterConst.AchieveType3 or arg_63_0.type == ChapterConst.AchieveType6) and not ChapterConst.IsAchieved(arg_63_0)
	end))

	setActive(var_62_1, var_62_2)

	if var_62_2 then
		local var_62_3 = self.contextData.chapterVO:getDisplayEnemyCount()

		setText(var_62_1:Find("Text"), var_62_3)
		GetImageSpriteFromAtlasAsync("enemycount", var_62_3 > 0 and "danger" or "safe", var_62_1)
		onButton(self, var_62_1, function()
			if var_62_3 > 0 then
				self:HandleShowMsgBox({
					hideNo = true,
					type = MSGBOX_TYPE_DROP_ITEM,
					name = i18n("star_require_enemy_title"),
					content = i18n("star_require_enemy_text", var_62_3),
					iconPath = {
						"enemycount",
						"danger"
					},
					yesText = i18n("star_require_enemy_check"),
					onYes = function()
						local var_65_0 = var_62_0:getNearestEnemyCell()

						self.grid:focusOnCell(var_65_0)

						local var_65_1 = self.grid:GetEnemyCellView(var_65_0)

						if var_65_1 and var_65_1.TweenShining then
							var_65_1:TweenShining(2)
						end
					end
				})
			else
				self:HandleShowMsgBox({
					hideNo = true,
					type = MSGBOX_TYPE_DROP_ITEM,
					name = i18n("star_require_enemy_title"),
					content = i18n("star_require_enemy_text", var_62_3),
					iconPath = {
						"enemycount",
						"safe"
					}
				})
			end
		end, SFX_PANEL)
	end
end

function LevelStageView:updateChapterBuff()
	local var_66_0 = self.contextData.chapterVO
	local var_66_1 = findTF(self.topStage, "icon_list/chapter_buff")
	local var_66_2 = self.contextData.chapterVO:hasMitigation()

	SetActive(var_66_1, var_66_2)

	if var_66_2 then
		local var_66_3 = self.contextData.chapterVO:getRiskLevel()

		GetImageSpriteFromAtlasAsync("passstate", var_66_3 .. "_icon", var_66_1)
		onButton(self, var_66_1, function()
			if not var_66_0:hasMitigation() then
				return
			end

			self:HandleShowMsgBox({
				hideNo = true,
				type = MSGBOX_TYPE_DROP_ITEM,
				name = var_66_0:getChapterState(),
				iconPath = {
					"passstate",
					var_66_3 .. "_icon"
				},
				content = i18n("level_risk_level_mitigation_rate", var_66_0:getRemainPassCount(), var_66_0:getMitigationRate())
			})
		end, SFX_PANEL)
	end
end

function LevelStageView:updateAirDominance()
	local var_68_0, var_68_1, var_68_2 = self.contextData.chapterVO:getAirDominanceValue()

	if not var_68_2 or var_68_2 ~= var_68_1 then
		self.contextData.chapterVO:setAirDominanceStatus(var_68_1)
		getProxy(ChapterProxy):updateChapter(self.contextData.chapterVO)
	end

	self.isChange = var_68_2 and (var_68_1 == 0 and 3 or var_68_1) - (var_68_2 == 0 and 3 or var_68_2)

	self:updateAirDominanceTitle(var_68_0, var_68_1, self.isChange or 0)
end

function LevelStageView:updateAirDominanceTitle(arg_69_1, arg_69_2, arg_69_3)
	local var_69_0 = findTF(self.airSupremacy, "value2")
	local var_69_1 = findTF(self.airSupremacy, "up")
	local var_69_2 = findTF(self.airSupremacy, "down")

	setText(findTF(self.airSupremacy, "label1"), i18n("level_scene_title_word_3"))
	setText(findTF(self.airSupremacy, "label2"), i18n("level_scene_title_word_4"))
	setText(findTF(self.airSupremacy, "value1"), math.floor(arg_69_1))
	setActive(var_69_1, false)
	setActive(var_69_2, false)

	if arg_69_3 ~= 0 then
		if LeanTween.isTweening(go(var_69_0)) then
			LeanTween.cancel(go(var_69_0))
		end

		LeanTween.value(go(var_69_0), 1, 0, 0.5):setOnUpdate(System.Action_float(function(arg_70_0)
			setTextAlpha(var_69_0, arg_70_0)
		end)):setOnComplete(System.Action(function()
			setText(var_69_0, ChapterConst.AirDominance[arg_69_2].name)
			setTextColor(var_69_0, ChapterConst.AirDominance[arg_69_2].color)
			LeanTween.value(go(var_69_0), 0, 1, 0.5):setOnUpdate(System.Action_float(function(arg_72_0)
				setTextAlpha(var_69_0, arg_72_0)
			end))
		end))

		local function var_69_3(arg_73_0)
			setActive(arg_73_0, false)
		end

		var_69_1:GetComponent(typeof(DftAniEvent)):SetEndEvent(var_69_3)
		var_69_2:GetComponent(typeof(DftAniEvent)):SetEndEvent(var_69_3)
		setActive(var_69_1, arg_69_3 > 0)
		setActive(var_69_2, arg_69_3 < 0)
	else
		setText(var_69_0, ChapterConst.AirDominance[arg_69_2].name)
		setTextColor(var_69_0, ChapterConst.AirDominance[arg_69_2].color)
	end
end

function LevelStageView:UpdateDefenseStatus()
	local var_74_0 = self.contextData.chapterVO
	local var_74_1 = self.contextData.chapterVO:getPlayType() == ChapterConst.TypeDefence
	local var_74_2 = findTF(self.bottomStage, "Normal/shengfu")

	setActive(var_74_2, var_74_1)

	if not var_74_1 then
		return
	end

	findTF(var_74_2, "hp"):GetComponent(typeof(Text)).text = i18n("desc_base_hp", "<color=#92FC63>" .. tostring(var_74_0.BaseHP) .. "</color>", pg.chapter_defense[var_74_0.id].port_hp)
end

function LevelStageView:DisplayWinConditionPanel()
	if not self.winCondPanel then
		self.winCondPanel = WinConditionDisplayPanel.New(self._tf.parent, self.event, self.contextData)

		self.winCondPanel:Load()
	end

	self.winCondPanel:ActionInvoke("Enter", self.contextData.chapterVO)
end

function LevelStageView:DestroyWinConditionPanel()
	if not self.winCondPanel then
		return
	end

	self.winCondPanel:Destroy()

	self.winCondPanel = nil
end

function LevelStageView:UpdateComboPanel()
	if pg.chapter_pop_template[self.contextData.chapterVO.id] and pg.chapter_pop_template[self.contextData.chapterVO.id].combo_on then
		local var_77_0, var_77_1 = self:GetSubView("LevelStageComboPanel")

		if var_77_1 then
			var_77_0:Load()
			var_77_0.buffer:SetParent(self.leftStage, false)
		end

		var_77_0.buffer:UpdateView(getProxy(ChapterProxy):GetComboHistory(self.contextData.chapterVO.id) or self.contextData.chapterVO)
		var_77_0.buffer:UpdateViewAnimated(self.contextData.chapterVO)
	end
end

function LevelStageView:UpdateDOALinkFeverPanel(arg_78_1)
	local var_78_0 = self.contextData.chapterVO:GetBindActID()
	local var_78_1 = self.contextData.chapterVO:getConfig("levelstage_bar")

	if not var_78_1 or var_78_1 == "" then
		existCall(arg_78_1)

		return
	end

	local var_78_2, var_78_3 = self:GetSubView(var_78_1)

	if var_78_3 then
		var_78_2:Load()
		var_78_2.buffer:SetParent(self._tf, false)
	end

	var_78_2.buffer:UpdateView(self.contextData.chapterVO, arg_78_1)
end

local var_0_2 = Vector2(396, 128)
local var_0_3 = Vector2(128, 128)

function LevelStageView:updateStageStrategy()
	self:downloadStageRes(function()
		self:updateStageStrategyAfterDownload()
	end)
end

function LevelStageView:updateStageStrategyAfterDownload()
	local var_81_0 = self.contextData.chapterVO
	local var_81_1 = findTF(self.rightStage, "event")
	local var_81_2 = findTF(var_81_1, "detail")
	local var_81_3 = findTF(var_81_2, "click")
	local var_81_4 = findTF(var_81_2, "items")

	if self._showStrategyDetail then
		var_81_4:GetComponent(typeof(GridLayoutGroup)).cellSize = var_0_2 or var_0_3
	end

	local var_81_5 = findTF(var_81_4, "item")
	local var_81_6 = findTF(var_81_1, "collapse")

	setActive(var_81_5, false)

	local var_81_7 = var_81_0:GetInteractableStrategies()

	local function var_81_9(arg_82_0, arg_82_1, arg_82_2)
		if arg_82_0 ~= UIItemList.EventUpdate then
			return
		end

		local var_82_0 = arg_82_2:Find("detail")

		setActive(var_82_0, self._showStrategyDetail)

		local var_82_1 = arg_82_2:Find("icon")
		local var_82_2 = var_81_7[arg_82_1 + 1]
		local var_82_3
		local var_82_4

		if var_81_7[arg_82_1 + 1].id == ChapterConst.StrategyHuntingRange then
			var_82_3 = ChapterConst.StgTypeConst
			var_82_4 = self.contextData.huntingRangeVisibility % 2 == 1 and "range_invisible" or "range_visible"

			setText(var_82_0, i18n("help_sub_limits"))
		elseif var_82_2.id == ChapterConst.StrategySubAutoAttack then
			var_82_3 = ChapterConst.StgTypeConst
			var_82_4 = var_81_0.subAutoAttack == 0 and "sub_dont_auto_attack" or "sub_auto_attack"

			setText(var_82_0, i18n("help_sub_display"))
		else
			var_82_3 = pg.strategy_data_template[var_82_2.id].type
			var_82_4 = pg.strategy_data_template[var_82_2.id].icon

			setText(var_82_0, pg.strategy_data_template[var_82_2.id].desc)
		end

		GetImageSpriteFromAtlasAsync("strategyicon/" .. var_82_4, "", var_82_1:Find("icon"))
		onButton(self, var_82_1, function()
			if var_82_2.id == ChapterConst.StrategyHuntingRange then
				self.grid:toggleHuntingRange()
				var_81_9(arg_82_0, arg_82_1, arg_82_2)
			elseif var_82_2.id == ChapterConst.StrategySubAutoAttack then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ai_change_" .. 1 - var_81_0.subAutoAttack + 1))
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpSubState,
					arg1 = 1 - var_81_0.subAutoAttack
				})
			elseif var_82_2.id == ChapterConst.StrategyExchange then
				local var_83_0 = var_81_0:getNextValidIndex()

				if var_83_0 > 0 and var_82_2.count > 0 then
					local var_83_1 = var_81_0.fleet

					self:HandleShowMsgBox({
						content = i18n("levelScene_who_to_exchange"),
						onYes = function()
							self:emit(LevelMediator2.ON_OP, {
								type = ChapterConst.OpStrategy,
								id = var_83_1.id,
								arg1 = ChapterConst.StrategyExchange,
								arg2 = var_81_0.fleets[var_83_0].id
							})
						end
					})
				end
			elseif var_82_2.id == ChapterConst.StrategySubTeleport then
				self:SwitchSubTeleportBottomStage()
				self:SwitchBottomStagePanel(true)
				self.grid:ShowStaticHuntingRange()
				self.grid:PrepareSubTeleport()
				self.grid:updateQuadCells(ChapterConst.QuadStateTeleportSub)
			elseif var_82_2.id == ChapterConst.StrategyMissileStrike then
				if not var_81_0.fleet:canUseStrategy(var_82_2) then
					return
				end

				self:SwitchMissileBottomStagePanel()
				self:SwitchBottomStagePanel(true)
				self.grid:updateQuadCells(ChapterConst.QuadStateMissileStrike)
			elseif var_82_2.id == ChapterConst.StrategyAirSupport then
				if not var_81_0:getChapterSupportFleet():canUseStrategy(var_82_2) then
					return
				end

				self:SwitchAirSupportBottomStagePanel()
				self:SwitchBottomStagePanel(true)
				self.grid:updateQuadCells(ChapterConst.QuadStateAirSuport)
			elseif var_82_2.id == ChapterConst.StrategyExpel then
				if not var_81_0:getChapterSupportFleet():canUseStrategy(var_82_2) then
					return
				end

				self:SwitchAirExpelBottomStagePanel()
				self:SwitchBottomStagePanel(true)
				self.grid:updateQuadCells(ChapterConst.QuadStateExpel)
			elseif var_82_3 == ChapterConst.StgTypeForm then
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpStrategy,
					id = var_81_0.fleet.id,
					arg1 = ChapterConst.StrategyForms[table.indexof(ChapterConst.StrategyForms, var_82_2.id) % #ChapterConst.StrategyForms + 1]
				})
			else
				self:emit(LevelUIConst.DISPLAY_STRATEGY_INFO, var_82_2)
			end
		end, SFX_PANEL)

		if var_82_3 == ChapterConst.StgTypeForm then
			setText(var_82_1:Find("nums"), "")
			setActive(var_82_1:Find("mask"), false)
			setActive(var_82_1:Find("selected"), true)
		else
			setText(var_82_1:Find("nums"), (not var_82_2.count or nil) and "")
			setActive(var_82_1:Find("mask"), var_82_2.count == 0)
			setActive(var_82_1:Find("selected"), false)
		end
	end

	UIItemList.StaticAlign(var_81_4, var_81_5, #var_81_7, nil)
	onButton(self, var_81_3, function()
		shiftPanel(var_81_2, var_81_2.rect.width + 200, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
		shiftPanel(var_81_6, -30, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	end, SFX_PANEL)
	onButton(self, var_81_6, function()
		shiftPanel(var_81_2, 35, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
		shiftPanel(var_81_6, var_81_6.rect.width + 200, nil, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	end, SFX_PANEL)
end

function LevelStageView:GetSubView(arg_87_1)
	if self.attachSubViews[arg_87_1] then
		return self.attachSubViews[arg_87_1]
	end

	local var_87_0 = _G[arg_87_1].New(self)

	assert(var_87_0, "cant't find subview " .. (arg_87_1 or "nil"))

	self.attachSubViews[arg_87_1] = var_87_0

	return var_87_0, true
end

function LevelStageView:RemoveSubView(arg_88_1)
	if not self.attachSubViews[arg_88_1] then
		return false
	end

	self.attachSubViews[arg_88_1]:Destroy()

	self.attachSubViews[arg_88_1] = nil

	return true
end

function LevelStageView:ClearSubViews()
	for iter_89_0, iter_89_1 in pairs(self.attachSubViews) do
		iter_89_1:Destroy()
	end

	table.clear(self.attachSubViews)
end

function LevelStageView:updateStageFleet()
	local var_90_0 = findTF(self.leftStage, "fleet")
	local var_90_1 = findTF(var_90_0, "shiptpl")

	setActive(var_90_1, false)
	setText(self.topStage:Find("msg_panel/fleet_info/number"), self.contextData.chapterVO.fleet.id)

	local var_90_2 = self.contextData.chapterVO.fleet:getShips(true)

	local function var_90_3(arg_91_0, arg_91_1)
		local var_91_0 = UIItemList.New(arg_91_0, var_90_1)

		var_91_0:make(function(arg_92_0, arg_92_1, arg_92_2)
			if arg_92_0 == UIItemList.EventUpdate then
				local var_92_0 = arg_91_1[arg_92_1 + 1]

				updateShip(arg_92_2, arg_91_1[arg_92_1 + 1])

				local var_92_1 = arg_91_1[arg_92_1 + 1].hpRant
				local var_92_2 = math.floor((arg_91_1[arg_92_1 + 1].hpChange or 0) / 10000 * arg_91_1[arg_92_1 + 1]:getShipProperties()[AttributeType.Durability])
				local var_92_3 = findTF(arg_92_2, "HP_POP")

				setActive(var_92_3, true)
				setActive(findTF(var_92_3, "heal"), false)
				setActive(findTF(var_92_3, "normal"), false)

				local function var_92_4(arg_93_0, arg_93_1)
					setActive(arg_93_0, true)
					setText(findTF(arg_93_0, "text"), arg_93_1)
					setTextAlpha(findTF(arg_93_0, "text"), 0)
					LeanTween.moveY(arg_93_0, 60, 1)
					LeanTween.textAlpha(findTF(arg_93_0, "text"), 1, 0.3)
					LeanTween.textAlpha(findTF(arg_93_0, "text"), 0, 0.5):setDelay(0.7):setOnComplete(System.Action(function()
						arg_93_0.localPosition = Vector3(0, 0, 0)
					end))
				end

				if var_92_2 > 0 then
					var_92_4(findTF(var_92_3, "heal"), var_92_2)
				elseif var_92_2 < 0 then
					LeanTween.delayedCall(0.6, System.Action(function()
						LeanTween.moveX(arg_92_2, arg_92_2.transform.localPosition.x, 0.05):setEase(LeanTweenType.easeInOutSine):setLoopPingPong(4)
						LeanTween.alpha(findTF(arg_92_2, "red"), 0.5, 0.4)
						LeanTween.alpha(findTF(arg_92_2, "red"), 0, 0.4):setDelay(0.4)
						var_92_4(findTF(var_92_3, "normal"), var_92_2)
					end))
				end

				local var_92_5 = findTF(arg_92_2, "blood")
				local var_92_6 = findTF(arg_92_2, "blood/fillarea/green")
				local var_92_7 = findTF(arg_92_2, "blood/fillarea/red")
				local var_92_8 = var_92_1 < ChapterConst.HpGreen
				local var_92_9 = var_92_1 == 0

				setActive(var_92_6, not (var_92_1 < ChapterConst.HpGreen))
				setActive(var_92_7, var_92_8)

				var_92_5:GetComponent(typeof(Slider)).fillRect = var_92_8 and var_92_7 or var_92_6

				setSlider(var_92_5, 0, 10000, var_92_1)
				setActive(findTF(arg_92_2, "repairmask"), var_92_8)
				setActive(findTF(arg_92_2, "repairmask/broken"), var_92_9)
				onButton(self, arg_92_2:Find("repairmask"), function()
					self:emit(LevelUIConst.DISPLAY_REPAIR_WINDOW, var_92_0)
				end, SFX_PANEL)

				local var_92_10 = findTF(arg_92_2, "repairmask/icon").gameObject

				if not var_92_8 then
					LeanTween.cancel(var_92_10)
					setImageAlpha(var_92_10, 1)
				end

				if var_92_8 and not LeanTween.isTweening(var_92_10) then
					LeanTween.alpha(rtf(var_92_10), 0, 2):setLoopPingPong()
				end

				local var_92_11 = GetOrAddComponent(arg_92_2, "UILongPressTrigger").onLongPressed

				pg.DelegateInfo.Add(self, var_92_11)
				var_92_11:RemoveAllListeners()
				var_92_11:AddListener(function()
					self:emit(LevelMediator2.ON_STAGE_SHIPINFO, {
						shipId = var_92_0.id,
						shipVOs = var_90_2
					})
				end)
			end
		end)
		var_91_0:align(#arg_91_1)
	end

	var_90_3(var_90_0:Find("main"), self.contextData.chapterVO.fleet:getShipsByTeam(TeamType.Main, true))
	var_90_3(var_90_0:Find("vanguard"), self.contextData.chapterVO.fleet:getShipsByTeam(TeamType.Vanguard, true))
	self.contextData.chapterVO.fleet:clearShipHpChange()
end

function LevelStageView:updateSupportFleet()
	local var_98_0 = self.contextData.chapterVO:getChapterSupportFleet()
	local var_98_1 = findTF(self.leftStage, "support_fleet")

	setActive(var_98_1, tobool(var_98_0))

	if var_98_0 then
		local var_98_2 = findTF(var_98_1, "show/ship_container")

		removeAllChildren(var_98_2)

		local var_98_3 = findTF(var_98_1, "show/shiptpl")

		for iter_98_0, iter_98_1 in pairs((var_98_0:getShips())) do
			local var_98_4 = cloneTplTo(var_98_3, var_98_2)

			setActive(var_98_4, true)
			updateShip(var_98_4, iter_98_1)
		end

		local var_98_5 = var_98_1:Find("hide")
		local var_98_6 = var_98_1:Find("show")

		local function var_98_7(arg_99_0)
			setActive(var_98_5, true)
			setActive(var_98_6, true)
			shiftPanel(var_98_6, nil, arg_99_0 and -325.1 or -855, 0.3, 0, true, nil, LeanTweenType.easeOutSine, function()
				setActive(var_98_5, not arg_99_0)
				setActive(var_98_6, arg_99_0)
			end)
			shiftPanel(var_98_5, nil, arg_99_0 and -1017 or -563.97, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
		end

		onButton(self, var_98_5, function()
			var_98_7(true)
		end, SFX_PANEL)
		onButton(self, var_98_6, function()
			var_98_7(false)
		end)
	end
end

function LevelStageView:ShiftStagePanelIn(arg_103_1)
	shiftPanel(self.topStage, 0, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine, arg_103_1)
	self:ShiftBottomStage(true)
	shiftPanel(self.leftStage, 0, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	shiftPanel(self.rightStage, 0, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
end

function LevelStageView:ShiftStagePanelOut(arg_104_1)
	shiftPanel(self.topStage, 0, self.topStage.rect.height, 0.3, 0, true, nil, LeanTweenType.easeOutSine, arg_104_1)
	self:ShiftBottomStage(false)
	shiftPanel(self.leftStage, -self.leftStage.rect.width - 200, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	shiftPanel(self.rightStage, self.rightStage.rect.width + 300, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
end

function LevelStageView:ShiftBottomStage(arg_105_1)
	if not self.bottomStageInactive then
		-- block empty
	else
		arg_105_1 = false
	end

	local var_105_0

	var_105_0(self.bottomStage, 0, arg_105_1 and 0 or -self.bottomStage.rect.height, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
end

function LevelStageView:SwitchSubTeleportBottomStage()
	setActive(self.missileStrikeRole, true)
	setText(findTF(self.missileStrikeRole, "confirm_button/Text"), i18n("levelscene_deploy_submarine"))
	setText(findTF(self.missileStrikeRole, "cancel_button/Text"), i18n("levelscene_deploy_submarine_cancel"))
	onButton(self, self.missileStrikeRole:Find("confirm_button"), function()
		local var_107_0 = self.contextData.chapterVO:GetSubmarineFleet()
		local var_107_1 = self.grid.subTeleportTargetLine

		if not self.grid.subTeleportTargetLine then
			return
		end

		local var_107_2 = self.contextData.chapterVO:findPath(nil, var_107_0.startPos, self.grid.subTeleportTargetLine)

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("tips_confirm_teleport_sub", self.grid:TransformLine2PlanePos(var_107_0.startPos), self.grid:TransformLine2PlanePos(self.grid.subTeleportTargetLine), var_107_2, (math.ceil(pg.strategy_data_template[ChapterConst.StrategySubTeleport].arg[2] * #var_107_0:getShips(false) * var_107_2 - 1e-05))),
			onYes = function()
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpSubTeleport,
					id = var_107_0.id,
					arg1 = var_107_1.row,
					arg2 = var_107_1.column
				})
			end
		})
	end, SFX_UI_CLICK)
	onButton(self, self.missileStrikeRole:Find("cancel_button"), function()
		self:SwitchBottomStagePanel(false)
		self.grid:TurnOffSubTeleport()
		self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
	end, SFX_UI_CLICK)
end

function LevelStageView:SwitchMissileBottomStagePanel()
	setActive(self.missileStrikeRole, true)
	setText(findTF(self.missileStrikeRole, "confirm_button/Text"), i18n("missile_attack_area_confirm"))
	setText(findTF(self.missileStrikeRole, "cancel_button/Text"), i18n("missile_attack_area_cancel"))
	onButton(self, self.missileStrikeRole:Find("confirm_button"), function()
		local var_111_0 = self.grid.missileStrikeTargetLine

		if not self.grid.missileStrikeTargetLine then
			return
		end

		local var_111_1 = self.contextData.chapterVO.fleet

		;(function()
			self:emit(LevelMediator2.ON_OP, {
				type = ChapterConst.OpStrategy,
				id = var_111_1.id,
				arg1 = ChapterConst.StrategyMissileStrike,
				arg2 = var_111_0.row,
				arg3 = var_111_0.column
			})
		end)()
	end, SFX_UI_CLICK)
	onButton(self, self.missileStrikeRole:Find("cancel_button"), function()
		self:SwitchBottomStagePanel(false)
		self.grid:HideMissileAimingMark()
		self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
	end, SFX_UI_CLICK)
end

function LevelStageView:SwitchAirSupportBottomStagePanel()
	setActive(self.missileStrikeRole, true)
	setText(findTF(self.missileStrikeRole, "confirm_button/Text"), i18n("missile_attack_area_confirm"))
	setText(findTF(self.missileStrikeRole, "cancel_button/Text"), i18n("missile_attack_area_cancel"))
	onButton(self, self.missileStrikeRole:Find("confirm_button"), function()
		local var_115_0 = self.grid.missileStrikeTargetLine

		if not self.grid.missileStrikeTargetLine then
			return
		end

		local var_115_1 = self.contextData.chapterVO:getChapterSupportFleet()

		;(function()
			self:emit(LevelMediator2.ON_OP, {
				type = ChapterConst.OpStrategy,
				id = var_115_1.id,
				arg1 = ChapterConst.StrategyAirSupport,
				arg2 = var_115_0.row,
				arg3 = var_115_0.column
			})
		end)()
	end, SFX_UI_CLICK)
	onButton(self, self.missileStrikeRole:Find("cancel_button"), function()
		self:SwitchBottomStagePanel(false)
		self.grid:HideAirSupportAimingMark()
		self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
	end, SFX_UI_CLICK)
end

function LevelStageView:SwitchAirExpelBottomStagePanel()
	setActive(self.airExpelRole, true)
	setText(findTF(self.airExpelRole, "cancel_button/Text"), i18n("levelscene_airexpel_cancel"))
	onButton(self, self.airExpelRole:Find("cancel_button"), function()
		self:SwitchBottomStagePanel(false)
		self.grid:HideAirExpelAimingMark()
		self.grid:CleanAirSupport()
		self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
	end, SFX_UI_CLICK)
end

function LevelStageView:SwitchBottomStagePanel(arg_120_1)
	setActive(self.actionRole, true)
	setActive(self.normalRole, true)
	shiftPanel(self.actionRole, 0, arg_120_1 and 0 or var_0_1, 0.3, 0, true, true, nil, function()
		setActive(self.actionRole, arg_120_1)
	end)
	shiftPanel(self.normalRole, 0, (arg_120_1 or nil) and (var_0_1 or 0), 0.3, 0, true, true, nil, function()
		setActive(self.normalRole, not arg_120_1)

		if not arg_120_1 then
			eachChild(self.actionRole, function(arg_123_0)
				setActive(arg_123_0, false)
			end)
		end
	end)
	shiftPanel(self.leftStage, (arg_120_1 or nil) and (-self.leftStage.rect.width - 200 or 0), 0, 0.3, 0, true)
	shiftPanel(self.rightStage, (arg_120_1 or nil) and (self.rightStage.rect.width + 300 or 0), 0, 0.3, 0, true)
end

function LevelStageView:ClickGridCellNormal(arg_124_1)
	local var_124_0 = _.detect(self.contextData.chapterVO.fleets, function(arg_125_0)
		return arg_125_0:getFleetType() == FleetType.Normal and arg_125_0.line.row == arg_124_1.row and arg_125_0.line.column == arg_124_1.column
	end)

	if var_124_0 and var_124_0:isValid() and var_124_0.id ~= self.contextData.chapterVO.fleet.id then
		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpSwitch,
			id = var_124_0.id
		})

		return
	end

	if self:tryAutoTrigger(nil, true) then
		return
	end

	if arg_124_1.row == self.contextData.chapterVO.fleet.line.row and arg_124_1.column == self.contextData.chapterVO.fleet.line.column then
		return
	end

	local var_124_1 = self.contextData.chapterVO:getChapterCell(arg_124_1.row, arg_124_1.column)

	if var_124_1.attachment == ChapterConst.AttachStory and var_124_1.data == ChapterConst.StoryObstacle and var_124_1.flag == ChapterConst.CellFlagTriggerActive then
		if pg.map_event_template[var_124_1.attachmentId] and pg.map_event_template[var_124_1.attachmentId].gametip and #pg.map_event_template[var_124_1.attachmentId].gametip > 0 and self.contextData.chapterVO:getPlayType() ~= ChapterConst.TypeDefence then
			pg.TipsMgr.GetInstance():ShowTips(i18n(pg.map_event_template[var_124_1.attachmentId].gametip))
		end

		return
	elseif not self.contextData.chapterVO:considerAsStayPoint(ChapterConst.SubjectPlayer, arg_124_1.row, arg_124_1.column) then
		return
	elseif self.contextData.chapterVO:existMoveLimit() and not _.any(self.contextData.chapterVO:calcWalkableCells(ChapterConst.SubjectPlayer, self.contextData.chapterVO.fleet.line.row, self.contextData.chapterVO.fleet.line.column, self.contextData.chapterVO.fleet:getSpeed()), function(arg_126_0)
		return arg_126_0.row == arg_124_1.row and arg_126_0.column == arg_124_1.column
	end) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("destination_not_in_range"))

		return
	end

	local var_124_2 = self.contextData.chapterVO:findPath(ChapterConst.SubjectPlayer, self.contextData.chapterVO.fleet.line, {
		row = arg_124_1.row,
		column = arg_124_1.column
	})

	if var_124_2 < PathFinding.PrioObstacle then
		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpMove,
			id = self.contextData.chapterVO.fleet.id,
			arg1 = arg_124_1.row,
			arg2 = arg_124_1.column
		})
	elseif var_124_2 < PathFinding.PrioForbidden then
		pg.TipsMgr.GetInstance():ShowTips(i18n("destination_can_not_reach"))
	else
		pg.TipsMgr.GetInstance():ShowTips(i18n("destination_can_not_reach"))
	end
end

function LevelStageView:tryAutoAction(arg_127_1)
	if self.doingAutoAction then
		return
	end

	self.doingAutoAction = true

	local var_127_0 = self.contextData.chapterVO

	if not self.contextData.chapterVO then
		existCall(arg_127_1)

		return
	end

	if self:SafeCheck() then
		existCall(arg_127_1)

		return
	end

	local var_127_1 = {}
	local var_127_2 = false

	for iter_127_0, iter_127_1 in pairs(self.contextData.chapterVO.cells) do
		if iter_127_1.trait == ChapterConst.TraitLurk then
			var_127_2 = true

			break
		end
	end

	if not var_127_2 then
		for iter_127_2, iter_127_3 in ipairs(self.contextData.chapterVO.champions) do
			if iter_127_3.trait == ChapterConst.TraitLurk then
				var_127_2 = true

				break
			end
		end
	end

	if var_127_2 then
		local var_127_3 = self.contextData.chapterVO:existOni()
		local var_127_4 = self.contextData.chapterVO:isPlayingWithBombEnemy()

		if not var_127_3 and not var_127_4 then
			table.insert(var_127_1, function(arg_128_0)
				self:emit(LevelUIConst.DO_TRACKING, arg_128_0)
			end)
		else
			table.insertto(var_127_1, {
				function(arg_129_0)
					local var_129_0

					if var_127_3 then
						var_129_0 = "SpUnit"
					elseif var_127_4 then
						var_129_0 = "SpBomb"
					end

					assert(var_129_0)
					self:emit(LevelUIConst.DO_PLAY_ANIM, {
						name = var_129_0,
						callback = function(arg_130_0)
							setActive(arg_130_0, false)
							arg_129_0()
						end
					})
				end,
				function(arg_131_0)
					local var_131_0 = var_127_0:getSpAppearStory()

					if var_131_0 and #var_131_0 > 0 then
						pg.NewStoryMgr.GetInstance():Play(var_131_0, arg_131_0)

						return
					end

					arg_131_0()
				end,
				function(arg_132_0)
					local var_132_0 = var_127_0:getSpAppearGuide()

					if var_132_0 and #var_132_0 > 0 then
						pg.SystemGuideMgr.GetInstance():PlayByGuideId(var_132_0, nil, arg_132_0)

						return
					end

					arg_132_0()
				end
			})
		end

		table.insertto(var_127_1, {
			function(arg_133_0)
				parallelAsync({
					function(arg_134_0)
						self:tryPlayChapterStory(arg_134_0)
					end,
					function(arg_135_0)
						local var_135_0 = var_127_0:GetBossCell()

						if var_135_0 and var_135_0.trait == ChapterConst.TraitLurk then
							self.grid:focusOnCell(var_135_0, arg_135_0)

							return
						end

						arg_135_0()
					end
				}, arg_133_0)
			end,
			function(arg_136_0)
				self:updateTrait(ChapterConst.TraitVirgin)
				self.grid:updateAttachments()
				self.grid:updateChampions()
				self:updateTrait(ChapterConst.TraitNone)
				self:emit(LevelMediator2.ON_OVERRIDE_CHAPTER)
				Timer.New(arg_136_0, 0.5, 1):Start()
			end
		})
	end

	seriesAsync({
		function(arg_137_0)
			self:emit(LevelUIConst.FROZEN)

			local var_137_0 = getProxy(ChapterProxy):GetLastDefeatedEnemy(var_127_0.id)

			if var_137_0 then
				if var_137_0.attachment == ChapterConst.AttachAmbush then
					if ChapterConst.IsBossCell(var_137_0) then
						self.grid:PlayAttachmentEffect(var_137_0.line.row, var_137_0.line.column, ChapterConst.GetDestroyFX(var_137_0), Vector2.zero)
					end
				end
			end

			self:PopBar()
			self:UpdateComboPanel()
			arg_137_0()
		end,
		function(arg_138_0)
			if not (function()
				local var_139_0 = getProxy(ChapterProxy):GetLastDefeatedEnemy(var_127_0.id)

				if not var_139_0 then
					return
				end

				return pg.expedition_data_template[var_139_0.attachmentId] and pg.expedition_data_template[var_139_0.attachmentId].type == ChapterConst.ExpeditionTypeMulBoss
			end)() then
				return arg_138_0()
			end

			self:emit(LevelUIConst.DO_PLAY_ANIM, {
				name = "BossRetreatBar",
				callback = function(arg_140_0)
					setActive(arg_140_0, false)
					arg_138_0()
				end
			})
		end,
		function(arg_141_0)
			self:UpdateDOALinkFeverPanel(arg_141_0)
		end,
		function(arg_142_0)
			seriesAsync(var_127_1, arg_142_0)
		end,
		function(arg_143_0)
			local var_143_0, var_143_1 = var_127_0:GetAttachmentStories()

			if var_143_0 then
				table.SerialIpairsAsync(var_143_0, function(arg_144_0, arg_144_1, arg_144_2)
					if arg_144_0 <= var_143_1 and arg_144_1 and type(arg_144_1) == "number" and arg_144_1 > 0 then
						ChapterOpCommand.PlayChapterStory(pg.NewStoryMgr:StoryId2StoryName(arg_144_1), arg_144_2, var_127_0:IsAutoFight())

						return
					end

					arg_144_2()
				end, arg_143_0)

				return
			end

			arg_143_0()
		end,
		function(arg_145_0)
			local var_145_0 = getProxy(ChapterProxy):getUpdatedExtraFlags(self.contextData.chapterVO.id)

			if not var_145_0 or #var_145_0 < 1 then
				arg_145_0()

				return
			end

			for iter_145_0, iter_145_1 in ipairs(var_145_0) do
				if pg.chapter_status_effect[iter_145_1] then
					local var_145_1 = pg.chapter_status_effect[iter_145_1].camera_focus or ""

					if type(var_145_1) == "table" then
						self.grid:focusOnCell({
							row = var_145_1[1],
							column = var_145_1[2]
						}, arg_145_0)

						return
					end
				end
			end

			arg_145_0()
		end,
		function(arg_146_0)
			if self.exited then
				return
			end

			self:emit(LevelUIConst.UN_FROZEN)
			;(function()
				local var_147_0 = getProxy(ChapterProxy)
				local var_147_1 = var_147_0:getActiveChapter(true)

				if not var_147_1 then
					return
				end

				local var_147_2 = var_147_1.id

				var_147_0:RecordComboHistory(var_147_1.id, nil)
				var_147_0:RecordLastDefeatedEnemy(var_147_2, nil)
				var_147_0:extraFlagUpdated(var_147_2)
				var_147_0:RemoveExtendChapterData(var_147_2, "FleetMoveDistance")
			end)()
			arg_146_0()
		end
	}, function()
		if self.exited then
			return
		end

		self.doingAutoAction = nil

		if var_127_2 and self:TryEnterChapterStoryStage() then
			-- block empty
		else
			existCall(arg_127_1)
		end
	end)
end

function LevelStageView:tryPlayChapterStory(arg_149_1)
	local var_149_0 = self.contextData.chapterVO
	local var_149_1 = self.contextData.chapterVO:getWaveCount()

	seriesAsync({
		function(arg_150_0)
			pg.SystemGuideMgr.GetInstance():PlayChapter(var_149_0, arg_150_0)
		end,
		function(arg_151_0)
			local var_151_0 = var_149_0:getConfig("story_refresh")
			local var_151_1 = var_151_0 and var_151_0[var_149_1]

			if var_151_0 and var_151_0[var_149_1] and type(var_151_1) == "string" and var_151_1 ~= "" and not var_149_0:IsRemaster() then
				ChapterOpCommand.PlayChapterStory(var_151_1, arg_151_0, var_149_0:IsAutoFight())

				return
			end

			arg_151_0()
		end,
		function(arg_152_0)
			local var_152_0 = var_149_0:getConfig("story_refresh_boss")

			if var_152_0 and type(var_152_0) == "string" and var_152_0 ~= "" and not var_149_0:IsRemaster() and var_149_0:IsFinalBossRefreshed() then
				ChapterOpCommand.PlayChapterStory(var_152_0, arg_152_0, var_149_0:IsAutoFight())

				return
			end

			arg_152_0()
		end,
		function(arg_153_0)
			if var_149_1 == 1 and pg.map_event_list[var_149_0.id] and pg.map_event_list[var_149_0.id].help_open == 1 and PlayerPrefs.GetInt("help_displayed_on_" .. var_149_0.id, 0) == 0 then
				triggerButton(self.helpBtn)
				PlayerPrefs.SetInt("help_displayed_on_" .. var_149_0.id, 1)
			end

			arg_153_0()
		end,
		function()
			existCall(arg_149_1)
		end
	})
end

function LevelStageView:TryEnterChapterStoryStage(arg_155_1)
	local var_155_0 = self.contextData.chapterVO:getWaveCount()
	local var_155_1 = self.contextData.chapterVO:getConfig("story_refresh")
	local var_155_2 = var_155_1 and var_155_1[var_155_0]

	if var_155_1 and var_155_1[var_155_0] and type(var_155_2) == "number" and not self.contextData.chapterVO:IsRemaster() then
		if not pg.NewStoryMgr.GetInstance():IsPlayed(pg.NewStoryMgr.GetInstance():StoryId2StoryName(var_155_2)) then
			self:emit(LevelMediator2.ON_PERFORM_COMBAT, var_155_2)

			return true
		end
	end

	local var_155_3 = self.contextData.chapterVO:getConfig("story_refresh_boss")

	if var_155_3 and type(var_155_3) == "number" and not self.contextData.chapterVO:IsRemaster() and self.contextData.chapterVO:IsFinalBossRefreshed() then
		if not pg.NewStoryMgr.GetInstance():IsPlayed(pg.NewStoryMgr.GetInstance():StoryId2StoryName(var_155_3)) then
			self:emit(LevelMediator2.ON_PERFORM_COMBAT, var_155_3)

			return true
		end
	end
end

function LevelStageView:TryEnterChapterSupportSubmarineStage(arg_156_1)
	local var_156_0 = self.contextData.chapterVO:getChapterSupportFleet()

	if self.contextData.chapterVO:getChapterSupportFleet() then
		self:emit(LevelMediator2.ON_SUPPORT_SUBMARINE)
	else
		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OPSubStrike,
			arg1 = ys.Battle.BattleConst.BattleScore.C,
			callback = arg_156_1
		})
	end
end

local var_0_4 = {
	[ChapterConst.KizunaJammingDodge] = "kizunaOperationSafe",
	[ChapterConst.KizunaJammingEngage] = "kizunaOperationDanger",
	[ChapterConst.StatusDay] = "HololiveDayBar",
	[ChapterConst.StatusNight] = "HololiveNightBar",
	[ChapterConst.StatusAirportUnderControl] = "AirportCaptureBar",
	[ChapterConst.StatusSunset] = "SunsetBar",
	[ChapterConst.StatusMaze1] = "MazeBar",
	[ChapterConst.StatusMaze2] = "MazeBar",
	[ChapterConst.StatusMaze3] = "MazeBar",
	[ChapterConst.StatusMissile1] = "MissileBar",
	[ChapterConst.StatusMissileInit] = "MissileWarningBar",
	[ChapterConst.StatusMissile1B] = "MissileBar",
	[ChapterConst.StatusMissileInitB] = "MissileWarningBar",
	[ChapterConst.StatusMusashiGame1] = "MusashiGameBar_1",
	[ChapterConst.StatusMusashiGame2] = "MusashiGameBar_2",
	[ChapterConst.StatusMusashiGame3] = "MusashiGameBar_3",
	[ChapterConst.StatusMusashiGame4] = "MusashiGameBar_4",
	[ChapterConst.StatusMusashiGame5] = "MusashiGameBar_5",
	[ChapterConst.StatusMusashiGame6] = "MusashiGameBar_6",
	[ChapterConst.StatusMusashiGame7] = "MusashiGameBar_7",
	[ChapterConst.StatusMusashiGame8] = "MusashiGameBar_8"
}

function LevelStageView:PopBar()
	local var_157_0 = getProxy(ChapterProxy):getUpdatedExtraFlags(self.contextData.chapterVO.id)

	if not var_157_0 or #var_157_0 < 1 then
		return
	end

	local var_157_1 = var_0_4[var_157_0[1]]

	if not var_0_4[var_157_0[1]] then
		return
	end

	local var_157_2, var_157_3 = self:GetSubView(var_157_1)

	if var_157_3 then
		var_157_2:Load()
	end

	var_157_2.buffer:PlayAnim()
end

function LevelStageView:updateTrait(arg_158_1)
	for iter_158_0, iter_158_1 in pairs(self.contextData.chapterVO.cells) do
		if iter_158_1.trait ~= ChapterConst.TraitNone then
			iter_158_1.trait = arg_158_1
		end
	end

	for iter_158_2, iter_158_3 in ipairs(self.contextData.chapterVO.champions) do
		if iter_158_3.trait ~= ChapterConst.TraitNone then
			iter_158_3.trait = arg_158_1
		end
	end
end

function LevelStageView:CheckFleetChange()
	local var_159_0 = _.detect(self.contextData.chapterVO.fleets, function(arg_160_0)
		return not arg_160_0:isValid()
	end)

	if var_159_0 then
		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpRetreat,
			id = var_159_0.id
		})

		if var_159_0:getFleetType() == TeamType.Normal then
			getProxy(ChapterProxy):StopAutoFight(ChapterConst.AUTOFIGHT_STOP_REASON.BATTLE_FAILED)
		end
	end

	if not self.contextData.chapterVO:GetActiveFleet():isValid() then
		local var_159_1 = self.contextData.chapterVO:getNextValidIndex()

		if var_159_1 > 0 then
			local var_159_2 = self.contextData.chapterVO.fleets[var_159_1]

			local function var_159_3()
				self:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpSwitch,
					id = var_159_2.id
				})
			end

			self:HandleShowMsgBox({
				modal = true,
				hideNo = true,
				content = i18n("formation_switch_tip", self.contextData.chapterVO.fleets[var_159_1].name),
				onYes = var_159_3,
				onNo = var_159_3
			})
		end

		return true
	end

	return false
end

function LevelStageView:tryAutoTrigger(arg_162_1, arg_162_2)
	local var_162_0 = self.contextData.chapterVO

	if self:DoBreakAction() then
		return
	end

	if self:CheckFleetChange() then
		return
	end

	return ((function()
		if var_162_0:checkAnyInteractive() then
			if not arg_162_1 or var_162_0:IsAutoFight() then
				triggerButton(self.funcBtn)

				return true
			end
		elseif var_162_0:getRound() == ChapterConst.RoundEnemy then
			self:emit(LevelMediator2.ON_OP, {
				type = ChapterConst.OpEnemyRound
			})

			return true
		elseif var_162_0:getRound() == ChapterConst.RoundPlayer then
			if not arg_162_2 then
				self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
			end

			if var_162_0:IsAutoFight() then
				self:TryAutoFight()

				return true
			end
		end
	end)())
end

function LevelStageView:DoBreakAction()
	local var_164_0 = self.contextData.chapterVO
	local var_164_1, var_164_2 = self:SafeCheck()

	if var_164_1 then
		local function var_164_3(arg_165_0)
			local var_165_0

			seriesAsync({
				function(arg_166_0)
					self:emit(LevelUIConst.ADD_MSG_QUEUE, arg_166_0)
				end,
				function(arg_167_0, arg_167_1)
					var_165_0 = arg_167_1

					ChapterOpCommand.PrepareChapterRetreat(arg_167_0)
				end,
				function(arg_168_0)
					existCall(arg_165_0)
					existCall(var_165_0)
				end
			})
		end

		if var_164_2 == ChapterConst.ReasonVictory then
			seriesAsync({
				function(arg_169_0)
					var_164_3(arg_169_0)
				end,
				function(arg_170_0)
					local var_170_0 = var_164_0:getConfig("win_condition_display") and #var_170_0 > 0 and var_170_0 .. "_tip"

					if var_170_0 and pg.gametip[var_170_0] then
						pg.TipsMgr.GetInstance():ShowTips(i18n(var_170_0))
					else
						pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_chapter_win"))
					end

					arg_170_0()
				end
			})
		elseif var_164_2 == ChapterConst.ReasonDefeat then
			if self.contextData.chapterVO:getPlayType() == ChapterConst.TypeTransport then
				pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_escort_lose"))
				var_164_3()
			else
				self:HandleShowMsgBox({
					modal = true,
					hideNo = true,
					content = i18n("formation_invalide"),
					onYes = var_164_3,
					onClose = var_164_3
				})
			end
		elseif var_164_2 == ChapterConst.ReasonDefeatDefense then
			self:HandleShowMsgBox({
				modal = true,
				hideNo = true,
				content = i18n("harbour_bomb_tip"),
				onYes = var_164_3,
				onClose = var_164_3
			})
		elseif var_164_2 == ChapterConst.ReasonVictoryOni then
			var_164_3()
		elseif var_164_2 == ChapterConst.ReasonDefeatOni then
			var_164_3()
		elseif var_164_2 == ChapterConst.ReasonDefeatBomb then
			var_164_3()
		elseif var_164_2 == ChapterConst.ReasonOutTime then
			self:emit(LevelMediator2.ON_TIME_UP)
		elseif var_164_2 == ChapterConst.ReasonActivityOutTime then
			self:HandleShowMsgBox({
				modal = true,
				hideNo = true,
				content = i18n("battle_preCombatMediator_activity_timeout"),
				onYes = var_164_3,
				onClose = var_164_3
			})
		end

		return true
	end

	return var_164_1
end

function LevelStageView:SafeCheck()
	if self.contextData.chapterVO:existOni() then
		local var_171_0 = self.contextData.chapterVO:checkOniState()

		if var_171_0 == 1 then
			return true, ChapterConst.ReasonVictoryOni
		elseif var_171_0 == 2 then
			return true, ChapterConst.ReasonDefeatOni
		else
			return false
		end
	elseif self.contextData.chapterVO:isPlayingWithBombEnemy() then
		if self.contextData.chapterVO:getBombChapterInfo().action_times * 2 <= self.contextData.chapterVO.roundIndex then
			return true, ChapterConst.ReasonDefeatBomb
		else
			return false
		end
	end

	local var_171_1, var_171_2 = self.contextData.chapterVO:CheckChapterWin()

	if var_171_1 then
		return true, var_171_2
	end

	local var_171_3, var_171_4 = self.contextData.chapterVO:CheckChapterLose()

	if var_171_3 then
		return true, var_171_4
	end

	if not self.contextData.chapterVO:inWartime() then
		return true, ChapterConst.ReasonOutTime
	end

	local var_171_5 = self.contextData.chapterVO:GetBindActID()

	if not self.contextData.map:isRemaster() and var_171_5 ~= 0 then
		local var_171_6 = getProxy(ActivityProxy):getActivityById(var_171_5)

		if not var_171_6 or var_171_6:isEnd() then
			return true, ChapterConst.ReasonActivityOutTime
		end
	end

	return false
end

function LevelStageView:TryAutoFight()
	local var_172_0 = self.contextData.chapterVO

	if not self.contextData.chapterVO:IsAutoFight() then
		return
	end

	local var_172_2 = self.contextData.chapterVO:GetAllEnemies()
	local var_172_3 = _.detect(var_172_2, function(arg_173_0)
		return ChapterConst.IsBossCell(arg_173_0)
	end)
	local var_172_4 = self.contextData.chapterVO:GetFleetOfDuty(tobool(var_172_3))

	if var_172_4 and var_172_4.id ~= self.contextData.chapterVO.fleet.id then
		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpSwitch,
			id = var_172_4.id
		})
		self:tryAutoTrigger()

		return
	end

	if self.contextData.chapterVO:checkAnyInteractive() then
		self:tryAutoTrigger()

		return
	end

	local var_172_5

	for iter_172_0, iter_172_1 in ipairs(self.contextData.chapterVO:getConfig("box_auto_pick")) do
		for iter_172_2, iter_172_3 in ipairs((underscore.filter(switch(iter_172_1, {
			[ChapterConst.AttachBox] = function()
				return var_172_0:findChapterCells(iter_172_1)
			end,
			[ChapterConst.AttachSupply] = function()
				local var_175_0, var_175_1 = var_172_0:getFleetAmmo(var_172_4)

				if var_175_0 - var_175_1 < 3 then
					return {}
				else
					return underscore.filter(var_172_0:findChapterCells(iter_172_1), function(arg_176_0)
						return arg_176_0.attachmentId > 0
					end)
				end
			end
		}), function(arg_177_0)
			return arg_177_0.flag ~= ChapterConst.CellFlagDisabled
		end))) do
			local var_172_6, var_172_7 = self.contextData.chapterVO:findPath(ChapterConst.SubjectPlayer, var_172_4.line, iter_172_3)

			if var_172_6 < PathFinding.PrioObstacle then
				var_172_5 = var_172_5 or {}

				table.insert(var_172_5, {
					target = iter_172_3,
					priority = var_172_6,
					path = var_172_7
				})
			end
		end

		if var_172_5 then
			table.sort(var_172_5, CompareFuncs({
				function(arg_178_0)
					return arg_178_0.priority
				end
			}))

			break
		end
	end

	if not var_172_5 then
		if var_172_3 then
			local var_172_8, var_172_9 = self.contextData.chapterVO:FindBossPath(var_172_4.line, var_172_3)
			local var_172_10 = {}
			local var_172_11

			for iter_172_4, iter_172_5 in ipairs(var_172_9) do
				table.insert(var_172_10, iter_172_5)

				if self.contextData.chapterVO:existEnemy(ChapterConst.SubjectPlayer, iter_172_5.row, iter_172_5.column) then
					var_172_8 = iter_172_4
					var_172_11 = iter_172_5

					break
				end
			end

			var_172_5 = {
				{
					target = var_172_11 or var_172_3,
					priority = var_172_8 or 0,
					path = var_172_10
				}
			}
		else
			var_172_5 = underscore.map(var_172_2, function(arg_179_0)
				local var_179_0, var_179_1 = var_172_0:findPath(ChapterConst.SubjectPlayer, var_172_4.line, arg_179_0)

				return {
					target = arg_179_0,
					priority = var_179_0,
					path = var_179_1
				}
			end)

			local function var_172_12(arg_180_0)
				assert(pg.expedition_data_template[arg_180_0.target.attachmentId], "expedition_data_template not exist: " .. arg_180_0.target.attachmentId)

				if arg_180_0.target.flag == ChapterConst.CellFlagDisabled then
					return 0
				end

				return ChapterConst.EnemyPreference[pg.expedition_data_template[arg_180_0.target.attachmentId].type]
			end

			if self.contextData.chapterVO.id == 1604 then
				table.sort(var_172_5, CompareFuncs({
					function(arg_181_0)
						return arg_181_0.priority < PathFinding.PrioObstacle and 0 or 1
					end,
					function(arg_182_0)
						return -var_172_12(arg_182_0)
					end,
					function(arg_183_0)
						return arg_183_0.priority
					end,
					function(arg_184_0)
						return arg_184_0.target.row
					end,
					function(arg_185_0)
						return -arg_185_0.target.column
					end
				}))
			else
				table.sort(var_172_5, CompareFuncs({
					function(arg_186_0)
						return arg_186_0.priority < PathFinding.PrioObstacle and 0 or 1
					end,
					function(arg_187_0)
						return -var_172_12(arg_187_0)
					end,
					function(arg_188_0)
						return arg_188_0.priority
					end
				}))
			end
		end
	end

	if var_172_5 and #var_172_5 > 0 and var_172_5[1].priority < PathFinding.PrioObstacle then
		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpMove,
			id = var_172_4.id,
			arg1 = var_172_5[1].target.row,
			arg2 = var_172_5[1].target.column
		})
	else
		pg.TipsMgr.GetInstance():ShowTips(i18n("autofight_errors_tip"))
		getProxy(ChapterProxy):SetChapterAutoFlag(self.contextData.chapterVO.id, false)
	end
end

function LevelStageView:popStageStrategy()
	local var_189_0 = self.rightStage:Find("event/collapse")

	if var_189_0.anchoredPosition.x <= 1 then
		triggerButton(var_189_0)
	end
end

function LevelStageView:UpdateAutoFightPanel()
	if self.contextData.chapterVO:CanActivateAutoFight() then
		if not self.autoFightPanel then
			self.autoFightPanel = LevelStageAutoFightPanel.New(self.rightStage:Find("event/collapse"), self.event, self.contextData)

			self.autoFightPanel:Load()

			self.autoFightPanel.isFrozen = self.isFrozen
		end

		self.autoFightPanel.buffer:Show()
	elseif self.autoFightPanel then
		self.autoFightPanel.buffer:Hide()
	end
end

function LevelStageView:UpdateAutoFightMark()
	if not self.autoFightPanel then
		return
	end

	self.autoFightPanel.buffer:UpdateAutoFightMark()
end

function LevelStageView:DestroyAutoFightPanel()
	if not self.autoFightPanel then
		return
	end

	self.autoFightPanel:Destroy()

	self.autoFightPanel = nil
end

function LevelStageView:DestroyToast()
	if not self.toastPanel then
		return
	end

	self.toastPanel:Destroy()

	self.toastPanel = nil
end

function LevelStageView:Toast()
	self:DestroyToast()

	local var_194_0 = table.remove(self.toastQueue, 1)

	if not var_194_0 then
		return
	end

	self.toastPanel = var_194_0.Class.New(self)

	self.toastPanel:Load()

	self.toastPanel.contextData.settings = var_194_0

	self.toastPanel.buffer:Play(function()
		self:Toast()
	end)
end

function LevelStageView:HandleShowMsgBox(arg_196_1)
	pg.MsgboxMgr.GetInstance():ShowMsgBox(arg_196_1)
end

return LevelStageView
