local LevelScene = class("LevelScene", import("..base.BaseUI"))
local var_0_1 = 0.5
local var_0_2 = 1
local var_0_3 = 2
local var_0_4 = 3

function LevelScene:forceGC()
	return true
end

function LevelScene:getUIName()
	return "LevelMainScene"
end

function LevelScene:getResource()
	return table.insertto(ResList.LevelSceneResConst.GetResource(self), LevelScene.super.getResource(self))
end

function LevelScene:downloadChapterRes(arg_4_1, arg_4_2)
	if self.exited or not ResList.ChapterResConst.IsActive(arg_4_1) then
		return
	end

	SplitPackConst.DownloadByLuaArr(ResList.ChapterResConst.GetResList(arg_4_1), function()
		if self.exited or not ResList.ChapterResConst.IsActive(self.contextData.chapterVO) or self.contextData.chapterVO.id ~= arg_4_1.id then
			return
		end

		if self.contextData.chapterVO ~= arg_4_1 then
			self:downloadChapterRes(self.contextData.chapterVO, arg_4_2)

			return
		end

		arg_4_2()
	end, {
		showMask = true
	})
end

function LevelScene:ResUISettings()
	return {
		groupDelta = 1,
		showType = PlayerResUI.TYPE_ALL
	}
end

function LevelScene:getBGM()
	for iter_7_0, iter_7_1 in ipairs({
		(function()
			return checkExist(self.contextData.chapterVO, {
				"getConfig",
				{
					"bgm"
				}
			}) or ""
		end)(),
		(function()
			if not self.contextData.map then
				return
			end

			local var_9_0 = self.contextData.map:getConfig("ani_controller")
			local var_9_1 = getProxy(ChapterProxy)

			if var_9_0 and #var_9_0 > 0 then
				for iter_9_0, iter_9_1 in ipairs(var_9_0) do
					for iter_9_2, iter_9_3 in ipairs((_.rest(iter_9_1[2], 2))) do
						if string.find(iter_9_3, "^bgm_") and iter_9_1[1] == var_0_3 then
							local var_9_2 = false

							for iter_9_4, iter_9_5 in ipairs(iter_9_1[2][1]) do
								local var_9_3 = var_9_1:GetChapterItemById(iter_9_5)

								if var_9_3 and var_9_3:isClear() then
									var_9_2 = true

									break
								end
							end

							if not var_9_2 then
								return string.sub(iter_9_3, 5)
							end
						end
					end
				end
			end

			return checkExist(self.contextData.map, {
				"getConfig",
				{
					"bgm"
				}
			}) or ""
		end)()
	}) do
		if iter_7_1 ~= "" then
			return iter_7_1
		end
	end

	return LevelScene.super.getBGM(self)
end

LevelScene.optionsPath = {
	"top/top_chapter/option"
}

function LevelScene:preload(arg_10_1)
	if self.contextData.mapIdx and self.contextData.chapterId then
		local var_10_0 = getProxy(ChapterProxy):getChapterById(self.contextData.chapterId)

		if var_10_0:getConfig("map") == self.contextData.mapIdx then
			self.contextData.chapterVO = var_10_0

			if var_10_0.active then
				assert(not self.contextData.openChapterId or self.contextData.openChapterId == self.contextData.chapterId)

				self.contextData.openChapterId = nil
			end
		end
	end

	local var_10_1, var_10_2 = self:GetInitializeMap()

	if self.contextData.entranceStatus == nil then
		self.contextData.entranceStatus = not var_10_2
	end

	arg_10_1()
end

function LevelScene:GetInitializeMap()
	local var_11_0 = (function()
		if self.contextData.chapterVO and self.contextData.chapterVO.active then
			return self.contextData.chapterVO:getConfig("map")
		end

		if self.contextData.mapIdx then
			return self.contextData.mapIdx
		end

		local var_12_0

		if self.contextData.targetChapter and self.contextData.targetMap then
			self.contextData.openChapterId = self.contextData.targetChapter
			var_12_0 = self.contextData.targetMap.id
			self.contextData.targetChapter = nil
			self.contextData.targetMap = nil
		elseif self.contextData.eliteDefault then
			local var_12_1 = getProxy(ChapterProxy):getUseableMaxEliteMap()

			var_12_0 = var_12_1 and var_12_1.id or nil
			self.contextData.eliteDefault = nil
		end

		return var_12_0
	end)()
	local var_11_1 = var_11_0 and getProxy(ChapterProxy):getMapById(var_11_0)

	if var_11_1 then
		local var_11_2, var_11_3 = var_11_1:isUnlock()

		if not var_11_2 then
			pg.TipsMgr.GetInstance():ShowTips(var_11_3)

			var_11_0 = getProxy(ChapterProxy):getLastUnlockMap().id
			self.contextData.mapIdx = var_11_0
		end
	else
		var_11_0 = nil
	end

	return var_11_0 or getProxy(ChapterProxy):GetLastNormalMap(), tobool(var_11_0)
end

function LevelScene:init()
	self:initData()
	self:initUI()
	self:initEvents()
	self:updateClouds()
end

function LevelScene:initData()
	self.tweens = {}
	self.mapWidth, self.mapHeight = self._tf.rect.size.x, self._tf.rect.size.y
	self.levelCamIndices = 1
	self.frozenCount = 0
	self.currentBG = nil
	self.mbDict = {}
	self.mapGroup = {}
	self.contextData.huntingRangeVisibility = self.contextData.huntingRangeVisibility or 2
end

function LevelScene:initUI()
	self.topPanel = self._tf:Find("top")
	self.canvasGroup = self.topPanel:GetComponent("CanvasGroup")
	self.canvasGroup.blocksRaycasts = not self.canvasGroup.blocksRaycasts
	self.canvasGroup.blocksRaycasts = not self.canvasGroup.blocksRaycasts
	self.entranceLayer = self._tf:Find("entrance")
	self.ptBonus = EventPtBonus.New(self.entranceLayer:Find("btns/btn_task/bonusPt"))
	self.entranceBg = self._tf:Find("entrance_bg")
	self.topChapter = self.topPanel:Find("top_chapter")

	setActive(self.topChapter:Find("title_chapter"), false)
	setActive(self.topChapter:Find("type_chapter"), false)
	setActive(self.topChapter:Find("type_escort"), false)
	setActive(self.topChapter:Find("type_skirmish"), false)

	self.chapterName = self.topChapter:Find("title_chapter/name")
	self.chapterNoTitle = self.topChapter:Find("title_chapter/chapter")
	self.resChapter = self.topChapter:Find("resources")

	setActive(self.topChapter, true)

	self._voteBookBtn = self.topChapter:Find("vote_book")
	self.leftChapter = self._tf:Find("main/left_chapter")

	setActive(self.leftChapter, true)

	self.leftCanvasGroup = self.leftChapter:GetComponent(typeof(CanvasGroup))
	self.btnPrev = self.leftChapter:Find("btn_prev")
	self.btnPrevCol = self.leftChapter:Find("btn_prev/prev_image")
	self.eliteBtn = self.leftChapter:Find("buttons/btn_elite")
	self.normalBtn = self.leftChapter:Find("buttons/btn_normal")
	self.actNormalBtn = self.leftChapter:Find("buttons/btn_act_normal")
	self.actEliteBtn = self.leftChapter:Find("buttons/btn_act_elite")
	self.actExtraBtn = self.leftChapter:Find("buttons/btn_act_extra")
	self.actExtraBtnAnim = self.actExtraBtn:Find("usm")
	self.remasterBtn = self.leftChapter:Find("buttons/btn_remaster")
	self.escortBar = self.leftChapter:Find("escort_bar")
	self.eliteQuota = self.leftChapter:Find("elite_quota")
	self.skirmishBar = self.leftChapter:Find("left_times")
	self.suggestionBtn = self.leftChapter:Find("suggestionBtn")

	setText(self.leftChapter:Find("suggestionBtn/Text"), i18n("formation_suggestion"))

	self.mainLayer = self._tf:Find("main")

	setActive(self.mainLayer:Find("title_chapter_lines"), false)

	self.rightChapter = self._tf:Find("main/right_chapter")
	self.rightCanvasGroup = self.rightChapter:GetComponent(typeof(CanvasGroup))
	self.eventContainer = self.rightChapter:Find("event_btns/event_container")
	self.btnSpecial = self.eventContainer:Find("btn_task")
	self.challengeBtn = self.eventContainer:Find("btn_challenge")
	self.dailyBtn = self.eventContainer:Find("btn_daily")
	self.militaryExerciseBtn = self.eventContainer:Find("btn_pvp")
	self.activityBtn = self.rightChapter:Find("event_btns/activity_btn")
	self.ptTotal = self.rightChapter:Find("event_btns/pt_text")
	self.ticketTxt = self.rightChapter:Find("event_btns/tickets/Text")
	self.remasterAwardBtn = self.rightChapter:Find("btn_remaster_award")
	self.btnNext = self.rightChapter:Find("btn_next")
	self.btnNextCol = self.rightChapter:Find("btn_next/next_image")
	self.countDown = self.rightChapter:Find("event_btns/count_down")

	setActive(self.rightChapter:Find("event_btns/BottomList"), true)

	self.actExchangeShopBtn = self.rightChapter:Find("event_btns/BottomList/btn_exchange")
	self.actAtelierBuffBtn = self.rightChapter:Find("event_btns/BottomList/btn_control_center")
	self.actAtelierYumiaBuffBtn = self.rightChapter:Find("event_btns/BottomList/btn_yumia_buff")
	self.actExtraRank = self.rightChapter:Find("event_btns/BottomList/act_extra_rank")

	setActive(self.rightChapter, true)

	self.damageTextTemplate = go(self.topPanel:Find("damage"))

	setActive(self.damageTextTemplate, false)

	self.damageTextPool = {
		self.damageTextTemplate
	}
	self.damageTextActive = {}
	self.mapHelpBtn = self.topPanel:Find("help_button")
	self.avoidText = self.topPanel:Find("text_avoid")
	self.commanderTinkle = self.topPanel:Find("neko_tinkle")

	setActive(self.commanderTinkle, false)

	self.spResult = self.topPanel:Find("sp_result")

	setActive(self.spResult, false)

	self.helpPage = self.topPanel:Find("help_page")
	self.helpImage = self.helpPage:Find("icon")

	setActive(self.helpPage, false)

	self.curtain = self.topPanel:Find("curtain")

	setActive(self.curtain, false)

	self.map = self._tf:Find("maps")
	self.mapTFs = {
		self._tf:Find("maps/map1"),
		self._tf:Find("maps/map2")
	}

	for iter_15_0, iter_15_1 in ipairs(self.mapTFs) do
		iter_15_1:GetComponent(typeof(Image)).enabled = false
	end

	self.UIFXList = self._tf:Find("maps/UI_FX_list")

	for iter_15_2, iter_15_3 in ipairs((self.UIFXList:GetComponentsInChildren(typeof(Renderer)):ToTable())) do
		iter_15_3.sortingOrder = -1
	end

	self.rtRightPanel = self._tf:Find("entrance/enters/right_panel")
	self.actBtnTpl = self.rtRightPanel:Find("content/tpl")

	local var_15_0 = pg.UIMgr.GetInstance()

	self.levelCam = var_15_0.levelCamera:GetComponent(typeof(Camera))
	self.uiMain = var_15_0.LevelMain

	setActive(self.uiMain, false)

	self.uiCam = var_15_0.uiCamera:GetComponent(typeof(Camera))
	self.levelGrid = self.uiMain:Find("LevelGrid")

	setActive(self.levelGrid, true)

	self.dragLayer = self.levelGrid:Find("DragLayer")
	self.float = self._tf:Find("float")
	self.clouds = self.float:Find("clouds")

	setActive(self.clouds, true)
	setActive(self.float:Find("levels"), false)

	self.resources = self._tf:Find("resources")
	self.arrowTarget = self.resources:Find("Tpl_Arrow_Target")
	self.destinationMarkTpl = self.resources:Find("Tpl_Destination_Mark")
	self.championTpl = self.resources:Find("Tpl_Champion")
	self.deadTpl = self.resources:Find("Tpl_Dead")
	self.enemyTpl = self.resources:Find("Tpl_Enemy")
	self.oniTpl = self.resources:Find("Tpl_Oni")
	self.shipTpl = self.resources:Find("Tpl_Ship")
	self.subTpl = self.resources:Find("Tpl_Sub")
	self.transportTpl = self.resources:Find("Tpl_Transport")

	setText(tf(self.enemyTpl):Find("fighting/Text"), i18n("ui_word_levelui2_inevent"))
	self:HideBtns()
	setAnchoredPosition(self.topChapter, {
		y = 0
	})
	setAnchoredPosition(self.leftChapter, {
		x = 0
	})
	setAnchoredPosition(self.rightChapter, {
		x = 0
	})

	self.bubbleMsgBoxes = {}
	self.loader = AutoLoader.New()
	self.levelFleetView = LevelFleetView.New(self.topPanel, self.event, self.contextData)
	self.levelInfoView = LevelInfoView.New(self.topPanel, self.event, self.contextData)

	self.levelInfoView:RegisterView(self)
	self.levelFleetView:RegisterView(self)
	self:buildCommanderPanel()

	self.levelRemasterView = LevelRemasterView.New(self.topPanel, self.event, self.contextData)
	self.chapterAutoDetailPanel = ChapterAutoDetailPanel.New(self.topPanel, self.event, self.contextData)

	self.chapterAutoDetailPanel:RegisterView(self)
	self:SwitchMapBuilder(MapBuilder.TYPENORMAL)
end

function LevelScene:LoadEntranceActivityBg()
	local var_16_0 = self.entranceActivity:getConfig("config_client").entrance_bg

	if not var_16_0 then
		return
	end

	if string.sub(var_16_0, 1, #"activitybanner") == "activitybanner" then
		var_16_0 = "MainUIBanner" .. string.sub(var_16_0, #"activitybanner" + 1)
	end

	self.entranceActivityBgPath = var_16_0

	pg.PoolMgr.GetInstance():GetPrefab(var_16_0, "", true, function(arg_17_0)
		if self.exited then
			pg.PoolMgr.GetInstance():ReturnPrefab(var_16_0, "", arg_17_0)

			return
		end

		self.entranceActivityBg = arg_17_0

		setParent(arg_17_0.transform, self.entranceLayer:Find("enters/enter_ready/activity"))
		setText(arg_17_0.transform:Find("Text"), self.entranceActivity:GetActivityTimeStr(true))

		arg_17_0.transform.anchorMin = Vector2.zero
		arg_17_0.transform.anchorMax = Vector2.one
		arg_17_0.transform.offsetMin = Vector2.zero
		arg_17_0.transform.offsetMax = Vector2.zero
	end)
end

function LevelScene:initEvents()
	self:bind(LevelUIConst.OPEN_COMMANDER_PANEL, function(arg_19_0, arg_19_1, arg_19_2, arg_19_3)
		self:openCommanderPanel(arg_19_1, arg_19_2, arg_19_3)
	end)
	self:bind(LevelUIConst.HANDLE_SHOW_MSG_BOX, function(arg_20_0, arg_20_1)
		self:HandleShowMsgBox(arg_20_1)
	end)
	self:bind(LevelUIConst.DO_AMBUSH_WARNING, function(arg_21_0, arg_21_1)
		self:doAmbushWarning(arg_21_1)
	end)
	self:bind(LevelUIConst.DISPLAY_AMBUSH_INFO, function(arg_22_0, arg_22_1)
		self:displayAmbushInfo(arg_22_1)
	end)
	self:bind(LevelUIConst.DISPLAY_STRATEGY_INFO, function(arg_23_0, arg_23_1)
		self:displayStrategyInfo(arg_23_1)
	end)
	self:bind(LevelUIConst.FROZEN, function(arg_24_0)
		self:frozen()
	end)
	self:bind(LevelUIConst.UN_FROZEN, function(arg_25_0)
		self:unfrozen()
	end)
	self:bind(LevelUIConst.DO_TRACKING, function(arg_26_0, arg_26_1)
		self:doTracking(arg_26_1)
	end)
	self:bind(LevelUIConst.SWITCH_TO_MAP, function()
		if self:isfrozen() then
			return
		end

		self:switchToMap()
	end)
	self:bind(LevelUIConst.DISPLAY_REPAIR_WINDOW, function(arg_28_0, arg_28_1)
		self:displayRepairWindow(arg_28_1)
	end)
	self:bind(LevelUIConst.DO_PLAY_ANIM, function(arg_29_0, arg_29_1)
		self:doPlayAnim(arg_29_1.name, arg_29_1.callback, arg_29_1.onStart)
	end)
	self:bind(LevelUIConst.HIDE_FLEET_SELECT, function()
		self:hideFleetSelect()
	end)
	self:bind(LevelUIConst.HIDE_FLEET_EDIT, function(arg_31_0)
		self:hideFleetEdit()
	end)
	self:bind(LevelUIConst.ADD_MSG_QUEUE, function(arg_32_0, arg_32_1)
		self:addbubbleMsgBox(arg_32_1)
	end)
	self:bind(LevelUIConst.SET_MAP, function(arg_33_0, arg_33_1)
		self:setMap(arg_33_1)
	end)
end

function LevelScene:onZeroHourRefresh()
	if self.levelInfoView:isShowing() then
		self.levelInfoView:RefreshChapterAutoPanel()
	end

	if self.levelInfoSPView and self.levelInfoSPView:isShowing() then
		self.levelInfoView:RefreshChapterAutoPanel()
	end
end

function LevelScene:addbubbleMsgBox(arg_35_1)
	table.insert(self.bubbleMsgBoxes, arg_35_1)

	if #self.bubbleMsgBoxes > 1 then
		return
	end

	local function var_35_1()
		if self.bubbleMsgBoxes[1] then
			self.bubbleMsgBoxes[1](function()
				table.remove(self.bubbleMsgBoxes, 1)
				var_35_1()
			end)
		end
	end

	;(nil)()
end

function LevelScene:CleanBubbleMsgbox()
	table.clean(self.bubbleMsgBoxes)
end

function LevelScene:updatePtActivity(arg_39_1)
	self.ptActivity = arg_39_1

	if not self.ptActivity then
		return
	end

	self:updateActivityRes()
end

function LevelScene:updateActivityRes()
	local var_40_0 = findTF(self.ptTotal, "Text")
	local var_40_1 = findTF(self.ptTotal, "icon/Image")

	if var_40_0 and var_40_1 and self.ptActivity then
		setText(var_40_0, "x" .. self.ptActivity:GetTotalPtCount())

		local var_40_2 = self.ptActivity:GetPTDrop():getIcon()

		GetImageSpriteFromAtlasAsync(var_40_2, "", var_40_1, true)
		GetImageSpriteFromAtlasAsync(var_40_2, "", self.actExchangeShopBtn:Find("icon"), true)
	end
end

function LevelScene:setCommanderPrefabs(arg_41_1)
	self.commanderPrefabs = arg_41_1
end

function LevelScene:didEnter()
	self.openedCommanerSystem = not LOCK_COMMANDER and pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "CommanderCatMediator")

	onButton(self, self.topChapter:Find("back_button"), function()
		if self:isfrozen() then
			return
		end

		local var_43_0 = self.contextData.map

		if self.contextData.map and (var_43_0:isActivity() or var_43_0:isEscort()) then
			self:emit(LevelMediator2.ON_SWITCH_NORMAL_MAP)

			return
		elseif var_43_0 and var_43_0:isSkirmish() then
			self:emit(LevelScene.ON_BACK)
		elseif not self.contextData.entranceStatus then
			self:ShowEntranceUI(true)
		else
			self:emit(LevelScene.ON_BACK)
		end
	end, SFX_CANCEL)
	onButton(self, self.btnSpecial, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.ON_OPEN_EVENT_SCENE)
	end, SFX_PANEL)
	onButton(self, self.dailyBtn, function()
		if self:isfrozen() then
			return
		end

		DailyLevelProxy.dailyLevelId = nil

		self:updatDailyBtnTip()
		self:emit(LevelMediator2.ON_DAILY_LEVEL)
	end, SFX_PANEL)
	onButton(self, self.challengeBtn, function()
		if self:isfrozen() then
			return
		end

		local var_46_0, var_46_1 = self:checkChallengeOpen()

		if var_46_0 == false then
			pg.TipsMgr.GetInstance():ShowTips(var_46_1)
		else
			self:emit(LevelMediator2.CLICK_CHALLENGE_BTN)
		end
	end, SFX_PANEL)
	onButton(self, self.militaryExerciseBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.ON_OPEN_MILITARYEXERCISE)
	end, SFX_PANEL)
	onButton(self, self.normalBtn, function()
		if self:isfrozen() then
			return
		end

		self:setMap(self.contextData.map:getBindMapId())
	end, SFX_PANEL)
	onButton(self, self.eliteBtn, function()
		if self:isfrozen() then
			return
		end

		if self.contextData.map:getBindMapId() == 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("elite_disable_unusable"))

			local var_49_0 = getProxy(ChapterProxy):getUseableMaxEliteMap()

			if var_49_0 then
				self:setMap(var_49_0.configId)
				pg.TipsMgr.GetInstance():ShowTips(i18n("elite_warp_to_latest_map"))
			end
		elseif self.contextData.map:isEliteEnabled() then
			self:setMap(self.contextData.map:getBindMapId())
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("elite_disable_unsatisfied"))
		end
	end, SFX_UI_WEIGHANCHOR_HARD)
	onButton(self, self.remasterBtn, function()
		if self:isfrozen() then
			return
		end

		self:displayRemasterPanel()
		getProxy(ChapterProxy):setRemasterTip(false)
		self:updateRemasterBtnTip()
	end, SFX_PANEL)
	onButton(self, self.entranceLayer:Find("enters/enter_main"), function()
		if self:isfrozen() then
			return
		end

		self:ShowSelectedMap(self:GetInitializeMap())
	end, SFX_PANEL)
	setText(self.entranceLayer:Find("enters/enter_main/Text"), getProxy(ChapterProxy):getLastUnlockMap():getLastUnlockChapterName())
	onButton(self, self.entranceLayer:Find("enters/enter_world/enter"), function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.ENTER_WORLD)
	end, SFX_PANEL)
	onButton(self, self.entranceLayer:Find("enters/enter_ready/activity"), function()
		if self:isfrozen() then
			return
		end

		switch(self.entranceActivity:getConfig("type"), {
			[ActivityConst.ACTIVITY_TYPE_ZPROJECT] = function()
				self:emit(LevelMediator2.ON_ACTIVITY_MAP, self.entranceActivity.id)
			end,
			[ActivityConst.ACTIVITY_TYPE_BOSS_BATTLE_MARK_2] = function()
				self:emit(LevelMediator2.ON_OPEN_ACT_BOSS_BATTLE)
			end,
			[ActivityConst.ACTIVITY_TYPE_BOSSRUSH] = function()
				self:emit(LevelMediator2.ON_BOSSRUSH_MAP)
			end,
			[ActivityConst.ACTIVITY_TYPE_BOSSSINGLE] = function()
				self:emit(LevelMediator2.ON_BOSSSINGLE_MAP, {
					mode = OtherworldMapScene.MODE_BATTLE
				})
			end,
			[ActivityConst.ACTIVITY_TYPE_BOSSSINGLE_VARIABLE] = function()
				self:emit(LevelMediator2.ON_CLUE_MAP)
			end,
			[ActivityConst.ACTIVITY_TYPE_BOSS_RUSH_DAL_COLLAB] = function()
				self:emit(LevelMediator2.ON_COLLAB_BOSSRUSH_MAP)
			end
		})
	end, SFX_PANEL)
	onButton(self, self.entranceLayer:Find("btns/btn_remaster"), function()
		if self:isfrozen() then
			return
		end

		self:displayRemasterPanel()
		getProxy(ChapterProxy):setRemasterTip(false)
		self:updateRemasterBtnTip()
	end, SFX_PANEL)
	setActive(self.entranceLayer:Find("btns/btn_remaster"), OPEN_REMASTER)
	onButton(self, self.entranceLayer:Find("btns/btn_challenge"), function()
		if self:isfrozen() then
			return
		end

		local var_61_0, var_61_1 = self:checkChallengeOpen()

		if var_61_0 == false then
			pg.TipsMgr.GetInstance():ShowTips(var_61_1)
		else
			self:emit(LevelMediator2.CLICK_CHALLENGE_BTN)
		end
	end, SFX_PANEL)
	onButton(self, self.entranceLayer:Find("btns/btn_pvp"), function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.ON_OPEN_MILITARYEXERCISE)
	end, SFX_PANEL)
	onButton(self, self.entranceLayer:Find("btns/btn_daily"), function()
		if self:isfrozen() then
			return
		end

		DailyLevelProxy.dailyLevelId = nil

		self:updatDailyBtnTip()
		self:emit(LevelMediator2.ON_DAILY_LEVEL)
	end, SFX_PANEL)
	onButton(self, self.entranceLayer:Find("btns/btn_task"), function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.ON_OPEN_EVENT_SCENE)
	end, SFX_PANEL)
	setActive(self.entranceLayer:Find("enters/enter_world/enter"), not WORLD_ENTER_LOCK)
	setActive(self.entranceLayer:Find("enters/enter_world/nothing"), WORLD_ENTER_LOCK)
	setActive(self.entranceLayer:Find("enters/enter_world/enter/tip"), getProxy(ChapterAutoProxy):IsAllCommissionFinish(ChapterAutoProxy.TYPE.WORLD))

	self.entranceActivity = getProxy(ActivityProxy):getEnterReadyActivity()[1]

	setActive(self.entranceLayer:Find("enters/enter_ready/nothing"), not tobool(self.entranceActivity))
	setActive(self.entranceLayer:Find("enters/enter_ready/activity"), tobool(self.entranceActivity))

	if tobool(self.entranceActivity) then
		self:LoadEntranceActivityBg()
	end

	self:updateRightPanel()

	local var_42_0 = pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "EventMediator")

	setActive(self.btnSpecial:Find("lock"), not var_42_0)
	setActive(self.entranceLayer:Find("btns/btn_task/lock"), not var_42_0)

	local var_42_1 = pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "DailyLevelMediator")

	setActive(self.dailyBtn:Find("lock"), not var_42_1)
	setActive(self.entranceLayer:Find("btns/btn_daily/lock"), not var_42_1)

	local var_42_2 = pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "MilitaryExerciseMediator")

	setActive(self.militaryExerciseBtn:Find("lock"), not var_42_2)
	setActive(self.entranceLayer:Find("btns/btn_pvp/lock"), not var_42_2)
	setActive(self.entranceLayer:Find("enters/enter_world/enter/lock"), not pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "WorldMediator"))

	local var_42_3 = LimitChallengeConst.IsOpen()

	setActive(self.challengeBtn:Find("lock"), not var_42_3)
	setActive(self.entranceLayer:Find("btns/btn_challenge/lock"), not var_42_3)

	local var_42_4 = LimitChallengeConst.IsInAct()

	setActive(self.challengeBtn, var_42_4)
	setActive(self.entranceLayer:Find("btns/btn_challenge"), var_42_4)
	setActive(self.entranceLayer:Find("btns/btn_challenge/tip"), (LimitChallengeConst.IsShowRedPoint()))
	self:initMapBtn(self.btnPrev, -1)
	self:initMapBtn(self.btnNext, 1)
	onButton(self, self.suggestionBtn, function()
		self:emit(BaseUI.ON_GO_SCENE, SCENE.FORMATION_SUGGESTION, {
			selectedIndex = table.keyof(LevelTools.GetSuggestionMapIDList(self.contextData.mapIdx), self.contextData.mapIdx),
			mapID = self.contextData.mapIdx
		})
	end)
	self:registerActBtn()

	if self.contextData.editEliteChapter then
		self:displayFleetEdit((getProxy(ChapterProxy):getChapterById(self.contextData.editEliteChapter)))

		self.contextData.editEliteChapter = nil
	elseif self.contextData.selectedChapterVO then
		self:displayFleetSelect(self.contextData.selectedChapterVO)

		self.contextData.selectedChapterVO = nil
	end

	if not self.contextData.chapterVO or not self.contextData.chapterVO.active then
		self:tryPlaySubGuide()
	end

	self:updateRemasterBtnTip()
	self:updatDailyBtnTip()

	if self.contextData.open_remaster then
		self:displayRemasterPanel(self.contextData.isSP)

		self.contextData.open_remaster = nil
	end

	self:ShowEntranceUI(self.contextData.entranceStatus)

	if not self.contextData.entranceStatus then
		self:emit(LevelMediator2.ON_ENTER_MAINLEVEL, self:GetInitializeMap())
	end

	self:emit(LevelMediator2.ON_DIDENTER)
end

function LevelScene:updateRightPanel()
	self.rightActivityBtns = defaultValue(self.rightActivityBtns, {
		LevelSecondMapBtn.New(self.actBtnTpl, self.event, false)
	})

	local var_66_0 = {}
	local var_66_1 = {}

	for iter_66_0, iter_66_1 in ipairs(self.rightActivityBtns) do
		if iter_66_1:InShowTime() then
			table.insert(var_66_0, iter_66_1)
		else
			table.insert(var_66_1, iter_66_1)
		end
	end

	table.sort(var_66_0, CompareFuncs({
		function(arg_67_0)
			return arg_67_0.config.group_id
		end
	}))

	for iter_66_2, iter_66_3 in ipairs(var_66_0) do
		iter_66_3:Init(iter_66_2)
	end

	for iter_66_4, iter_66_5 in ipairs(var_66_1) do
		iter_66_5:Clear()
	end
end

function LevelScene:checkChallengeOpen()
	return pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getRawData().level, "ChallengeMainMediator")
end

function LevelScene:tryPlaySubGuide()
	if self.contextData.map and self.contextData.map:isSkirmish() then
		return
	end

	pg.SystemGuideMgr.GetInstance():Play(self)
end

function LevelScene:onBackPressed()
	if self:isfrozen() then
		return
	end

	if self.levelAmbushView then
		return
	end

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if self.chapterAutoDetailPanel:isShowing() then
		self:HideChapterAutoDetailPanel()
	end

	if self.levelInfoView:isShowing() then
		self:hideChapterPanel()

		return
	end

	if self.levelInfoSPView and self.levelInfoSPView:isShowing() then
		self:HideLevelInfoSPPanel()

		return
	end

	if self.levelFleetView:isShowing() then
		self:hideFleetEdit()

		return
	end

	if self.levelStrategyView then
		self:hideStrategyInfo()

		return
	end

	if self.levelRepairView then
		self:hideRepairWindow()

		return
	end

	if self.levelRemasterView:isShowing() then
		self:hideRemasterPanel()

		return
	end

	if self.contextData.map and self.contextData.map:getConfig("ui_type") == MapBuilder.TYPEEXSP and self.mapBuilder.personalPage:IsActive() then
		self.mapBuilder.personalPage:Hide()

		return
	end

	if isActive(self.helpPage) then
		setActive(self.helpPage, false)

		return
	end

	if self.contextData.chapterVO and getProxy(ChapterProxy):getActiveChapter() then
		self:switchToMap()

		return
	end

	triggerButton(self.topChapter:Find("back_button"))
end

function LevelScene:ShowEntranceUI(arg_71_1)
	setActive(self.entranceLayer, arg_71_1)
	setActive(self.entranceBg, arg_71_1)
	setActive(self.map, not arg_71_1)
	setActive(self.float, not arg_71_1)
	setActive(self.mainLayer, not arg_71_1)
	setActive(self.topChapter:Find("type_entrance"), arg_71_1)

	self.contextData.entranceStatus = tobool(arg_71_1)

	if arg_71_1 then
		setActive(self.topChapter:Find("title_chapter"), false)
		setActive(self.topChapter:Find("type_chapter"), false)
		setActive(self.topChapter:Find("type_escort"), false)
		setActive(self.topChapter:Find("type_skirmish"), false)

		if self.newChapterCDTimer then
			self.newChapterCDTimer:Stop()

			self.newChapterCDTimer = nil
		end

		self:RecordLastMapOnExit()

		self.contextData.mapIdx = nil
		self.contextData.map = nil
	end

	self:PlayBGM()
end

function LevelScene:PreloadLevelMainUI(arg_72_1, arg_72_2)
	if self.preloadLevelDone then
		existCall(arg_72_2)

		return
	end

	table.ParallelIpairsAsync(self:GetMapBG((getProxy(ChapterProxy):getMapById(arg_72_1))), function(arg_74_0, arg_74_1, arg_74_2)
		GetSpriteFromAtlasAsync("levelmap/" .. arg_74_1.BG, "", arg_74_2)
	end, function()
		if not self.exited then
			self.preloadLevelDone = true

			existCall(arg_72_2)
		end
	end)
end

function LevelScene:setShips(arg_75_1)
	self.shipVOs = arg_75_1
end

function LevelScene:updateRes(arg_76_1)
	if self.levelStageView then
		self.levelStageView:ActionInvoke("SetPlayer", arg_76_1)
	end

	self.player = arg_76_1
end

function LevelScene:setEliteQuota(arg_77_1, arg_77_2)
	local var_77_0 = self.eliteQuota:Find("bg/Text"):GetComponent(typeof(Text))

	var_77_0.color = arg_77_1 == arg_77_2 and Color.red or Color.New(0.47, 0.89, 0.27)
	var_77_0.text = arg_77_2 - arg_77_1 .. "/" .. arg_77_2
end

function LevelScene:updateEvent(arg_78_1)
	local var_78_0 = arg_78_1:hasFinishState()

	setActive(self.btnSpecial:Find("tip"), var_78_0)
	setActive(self.entranceLayer:Find("btns/btn_task/tip"), var_78_0)
end

function LevelScene:updateFleet(arg_79_1)
	self.fleets = arg_79_1
end

function LevelScene:updateChapterVO(arg_80_1, arg_80_2)
	if self.contextData.chapterVO and self.contextData.chapterVO.id == arg_80_1.id and arg_80_1.active then
		self:setChapter(arg_80_1)
	end

	if self.contextData.chapterVO and self.contextData.chapterVO.id == arg_80_1.id and arg_80_1.active and self.levelStageView and self.grid then
		local var_80_0 = false
		local var_80_1 = false
		local var_80_2 = false

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyFleet) > 0 then
			self.levelStageView:updateStageFleet()
			self.levelStageView:updateAmbushRate(arg_80_1.fleet.line, true)

			var_80_2 = true

			if self.grid then
				self.grid:RefreshFleetCells()
				self.grid:UpdateFloor()
				self.grid:UpdateWeatherCells()

				var_80_0 = true
			end
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyChampion) > 0 then
			var_80_2 = true

			if self.grid then
				self.grid:UpdateFleets()
				self.grid:clearChampions()
				self.grid:initChampions()

				var_80_1 = true
			end
		elseif bit.band(arg_80_2, ChapterConst.DirtyChampionPosition) > 0 then
			var_80_2 = true

			if self.grid then
				self.grid:UpdateFleets()
				self.grid:updateChampions()

				var_80_1 = true
			end
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyAchieve) > 0 then
			self.levelStageView:updateStageAchieve()
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyAttachment) > 0 then
			self.levelStageView:updateAmbushRate(arg_80_1.fleet.line, true)

			if self.grid then
				if arg_80_2 >= 0 and bit.band(arg_80_2, ChapterConst.DirtyFleet) <= 0 then
					self.grid:updateFleet(arg_80_1.fleets[arg_80_1.findex].id)
				end

				self.grid:updateAttachments()

				if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyAutoAction) > 0 then
					self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
				else
					var_80_0 = true
				end
			end
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyStrategy) > 0 then
			self.levelStageView:updateStageStrategy()

			var_80_2 = true

			self.levelStageView:updateStageBarrier()
			self.levelStageView:UpdateAutoFightPanel()
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyAutoAction) > 0 then
			-- block empty
		elseif var_80_0 then
			self.grid:updateQuadCells(ChapterConst.QuadStateNormal)
		elseif var_80_1 then
			self.grid:updateQuadCells(ChapterConst.QuadStateFrozen)
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyCellFlag) > 0 then
			self.grid:UpdateFloor()
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyBase) > 0 then
			self.levelStageView:UpdateDefenseStatus()
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyFloatItems) > 0 then
			self.grid:UpdateItemCells()
		end

		if arg_80_2 < 0 or bit.band(arg_80_2, ChapterConst.DirtyWeather) > 0 then
			self.grid:UpdateWeatherCells()
		end

		if var_80_2 then
			self.levelStageView:updateFleetBuff()
		end
	end
end

function LevelScene:updateClouds()
	self.cloudRTFs = {}
	self.cloudRects = {}
	self.cloudTimer = {}

	for iter_81_0 = 1, 6 do
		local var_81_0 = rtf((self.clouds:Find("cloud_" .. iter_81_0)))

		table.insert(self.cloudRTFs, var_81_0)
		table.insert(self.cloudRects, var_81_0.rect.width)
	end

	self:initCloudsPos()

	for iter_81_1, iter_81_2 in ipairs(self.cloudRTFs) do
		local var_81_1 = self.cloudRects[iter_81_1]
		local var_81_2 = self.initPositions[iter_81_1] or Vector2(0, 0)
		local var_81_3 = 30 - var_81_2.y / 20
		local var_81_4

		var_81_4 = LeanTween.moveX(iter_81_2, self.mapWidth, (self.mapWidth + self.cloudRects[iter_81_1]) / (30 - var_81_2.y / 20)):setRepeat(-1):setOnCompleteOnRepeat(true):setOnComplete(System.Action(function()
			var_81_1 = self.cloudRects[iter_81_1]
			iter_81_2.anchoredPosition = Vector2(-var_81_1, var_81_2.y)

			var_81_4:setFrom(-var_81_1):setTime((self.mapWidth + var_81_1) / var_81_3)
		end))
		var_81_4.passed = math.random() * ((self.mapWidth + self.cloudRects[iter_81_1]) / (30 - var_81_2.y / 20))
		self.cloudTimer[iter_81_1] = var_81_4.uniqueId
	end
end

function LevelScene:RefreshMapBG()
	self:PlayBGM()
	self:SwitchMapBG(self.contextData.map, nil, true)
end

function LevelScene:updateCouldAnimator(arg_84_1, arg_84_2)
	if not arg_84_1 then
		return
	end

	local var_84_0 = self.contextData.map:getConfig("ani_controller")

	local function var_84_1(arg_85_0)
		arg_85_0 = tf(arg_85_0)

		if arg_85_0.rect.width > 0 and arg_85_0.rect.height > 0 then
			Vector3.one.x = arg_85_0.parent.rect.width / arg_85_0.rect.width
			Vector3.one.y = arg_85_0.parent.rect.height / arg_85_0.rect.height
		end

		arg_85_0.localScale = Vector3.one

		if var_84_0 and #var_84_0 > 0 then
			local var_85_0 = getProxy(ChapterProxy)

			;(function()
				for iter_86_0, iter_86_1 in ipairs(var_84_0) do
					local var_86_0 = false

					for iter_86_2, iter_86_3 in ipairs(iter_86_1[2][1]) do
						local var_86_1 = var_85_0:GetChapterItemById(iter_86_3)

						if var_86_1 and var_86_1:isClear() then
							var_86_0 = true

							break
						end
					end

					if iter_86_1[1] == var_0_2 then
						for iter_86_4, iter_86_5 in ipairs((_.rest(iter_86_1[2], 2))) do
							local var_86_2 = arg_85_0:Find(iter_86_5)

							if not IsNil(var_86_2) and not var_86_0 then
								setActive(var_86_2, false)
							end
						end
					elseif iter_86_1[1] == var_0_3 then
						for iter_86_6, iter_86_7 in ipairs((_.rest(iter_86_1[2], 2))) do
							local var_86_3 = arg_85_0:Find(iter_86_7)

							if not IsNil(var_86_3) and not var_86_0 then
								setActive(var_86_3, true)

								return
							end
						end
					elseif iter_86_1[1] == var_0_4 then
						for iter_86_8, iter_86_9 in ipairs((_.rest(iter_86_1[2], 2))) do
							local var_86_4 = arg_85_0:Find(iter_86_9)

							if not IsNil(var_86_4) and not var_86_0 then
								setActive(var_86_4, true)
							end
						end
					end
				end
			end)()
		end
	end

	table.insert(self.mapGroup, (self.loader:GetPrefab("ui/" .. arg_84_1, arg_84_1, function(arg_87_0)
		arg_87_0:SetActive(true)
		setParent(arg_87_0, self.mapTFs[arg_84_2])
		pg.ViewUtils.SetSortingOrder(arg_87_0, ChapterConst.LayerWeightMap + arg_84_2 * 2 - 1)
		var_84_1(arg_87_0)
	end)))
end

function LevelScene:HideBtns()
	setActive(self.btnPrev, false)
	setActive(self.eliteQuota, false)
	setActive(self.escortBar, false)
	setActive(self.skirmishBar, false)
	setActive(self.normalBtn, false)
	setActive(self.actNormalBtn, false)
	setActive(self.eliteBtn, false)
	setActive(self.actEliteBtn, false)
	setActive(self.actExtraBtn, false)
	setActive(self.remasterBtn, false)
	setActive(self.btnNext, false)
	setActive(self.remasterAwardBtn, false)
	setActive(self.eventContainer, false)
	setActive(self.activityBtn, false)
	setActive(self.ptTotal, false)
	setActive(self.ticketTxt.parent, false)
	setActive(self.countDown, false)
	setActive(self.actAtelierBuffBtn, false)
	setActive(self.actAtelierYumiaBuffBtn, false)
	setActive(self.actExtraRank, false)
	setActive(self.actExchangeShopBtn, false)
	setActive(self.mapHelpBtn, false)
end

function LevelScene:updateDifficultyBtns()
	local var_89_0 = self.contextData.map:getConfig("type")

	setActive(self.normalBtn, var_89_0 == Map.ELITE)
	setActive(self.eliteQuota, var_89_0 == Map.ELITE)
	setActive(self.eliteBtn, var_89_0 == Map.SCENARIO)

	local var_89_1 = getProxy(ActivityProxy):getActivityById(ActivityConst.ELITE_AWARD_ACTIVITY_ID)

	setActive(self.eliteBtn:Find("pic_activity"), var_89_1 and not var_89_1:isEnd())
end

function LevelScene:updateActivityBtns()
	local var_90_0 = self.contextData.map
	local var_90_1, var_90_2 = self.contextData.map:isActivity()
	local var_90_3 = var_90_0:isRemaster()
	local var_90_4 = var_90_0:isSkirmish()
	local var_90_5 = var_90_0:isEscort()
	local var_90_6 = var_90_0:getConfig("type")
	local var_90_7 = setmetatable({}, MainActMapBtn)
	local var_90_8 = var_90_7:InShowTime() and not var_90_1 and not var_90_4 and not var_90_5

	self.activityBtnLinkAct = var_90_7:GetActivity()

	if var_90_8 then
		var_90_7.image = self.activityBtn:Find("Image"):GetComponent(typeof(Image))
		var_90_7.subImage = self.activityBtn:Find("sub_Image"):GetComponent(typeof(Image))
		var_90_7.tipTr = self.activityBtn:Find("Tip"):GetComponent(typeof(Image))
		var_90_7.tipTxt = self.activityBtn:Find("Tip/Text"):GetComponent(typeof(Text))
		var_90_8 = var_90_7:InShowTime()

		if var_90_8 then
			var_90_7:InitTipImage()
			var_90_7:InitSubImage()
			var_90_7:InitImage(function()
				return
			end)
			var_90_7:OnInit()
		end
	end

	setActive(self.activityBtn, var_90_8)
	self:updateRemasterInfo()

	if var_90_1 and var_90_2 then
		local var_90_9 = var_90_0:isRemaster() and getProxy(ChapterProxy):getRemasterMaps(var_90_0.remasterId) or getProxy(ChapterProxy):getMapsByActivities(var_90_0:getConfig("on_activity"))

		setActive(self.actExtraBtn, underscore.any(var_90_9, function(arg_92_0)
			return arg_92_0:isActExtra()
		end) and var_90_6 ~= Map.ACT_EXTRA)

		if isActive(self.actExtraBtn) then
			if underscore.all(underscore.filter(var_90_9, function(arg_93_0)
				local var_93_0 = arg_93_0:getMapType()

				return var_93_0 == Map.ACTIVITY_EASY or var_93_0 == Map.ACTIVITY_HARD
			end), function(arg_94_0)
				return arg_94_0:isAllChaptersClear()
			end) then
				setActive(self.actExtraBtnAnim, true)
			else
				setActive(self.actExtraBtnAnim, false)
			end

			local var_90_10 = setActive
			local var_90_11 = getProxy(ChapterProxy):IsActivitySPChapterActive(var_90_0:getConfig("on_activity"))

			var_90_11 = var_90_11 and SettingsProxy.IsShowActivityMapSPTip()

			var_90_10(self.actExtraBtn:Find("Tip"), var_90_11)
		end

		setActive(self.actEliteBtn, checkExist(var_90_0:getBindMap(), {
			"isHardMap"
		}) and var_90_6 ~= Map.ACTIVITY_HARD)
		setActive(self.actNormalBtn, var_90_6 ~= Map.ACTIVITY_EASY)

		local var_90_12 = setActive
		local var_90_13 = self.actExtraRank
		local var_90_14 = var_90_6 == Map.ACT_EXTRA and _.any(getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_EXTRA_CHAPTER_RANK), function(arg_95_0)
			if not arg_95_0 or arg_95_0:isEnd() then
				return
			end

			local var_95_0 = arg_95_0:getConfig("config_data")[1]

			return _.any(var_90_0:getChapters(), function(arg_96_0)
				if not arg_96_0:IsEXChapter() then
					return false
				end

				return table.contains(arg_96_0:getConfig("boss_expedition_id"), var_95_0)
			end)
		end) or false

		var_90_12(var_90_13, (false or nil) and true)
		setActive(self.actExchangeShopBtn, not ActivityConst.HIDE_PT_PANELS and not var_90_3 and var_90_2 and self:IsActShopActive())

		local var_90_15

		if self.contextData.map then
			var_90_15 = getProxy(ActivityProxy):getActivityById(self.contextData.map:getConfig("on_activity")) or nil
		end

		self:updatePtActivity(var_90_15 and var_90_15:GetConfigClientPTActivity() or nil)

		local var_90_16 = setActive
		local var_90_17 = self.ptTotal
		local var_90_18

		if not ActivityConst.HIDE_PT_PANELS and not var_90_3 then
			if var_90_2 then
				::label_90_0::

				var_90_18 = self.ptActivity and not self.ptActivity:isEnd()

				goto label_90_1
			end
		end

		::label_90_1::

		var_90_16(var_90_17, true)
	else
		setActive(self.actExtraBtn, false)
		setActive(self.actEliteBtn, false)
		setActive(self.actNormalBtn, false)
		setActive(self.actExtraRank, false)
		setActive(self.actExchangeShopBtn, false)
		setActive(self.actAtelierBuffBtn, false)
		setActive(self.actAtelierYumiaBuffBtn, false)
		setActive(self.ptTotal, false)
	end

	setActive(self.eventContainer, (not var_90_1 or not var_90_2) and not var_90_5)
	setActive(self.remasterBtn, OPEN_REMASTER and (var_90_3 or not var_90_1 and not var_90_5 and not var_90_4))
	setActive(self.ticketTxt.parent, var_90_3)
	self:updateRemasterTicket()
	self:updateCountDown()
end

function LevelScene:updateRemasterTicket()
	setText(self.ticketTxt, getProxy(ChapterProxy).remasterTickets .. " / " .. pg.gameset.reactivity_ticket_max.key_value)
	self:emit(LevelUIConst.FLUSH_REMASTER_TICKET)
end

function LevelScene:updateRemasterBtnTip()
	local var_98_0 = getProxy(ChapterProxy)
	local var_98_1 = var_98_0:ifShowRemasterTip() or var_98_0:anyRemasterAwardCanReceive()

	SetActive(self.remasterBtn:Find("tip"), var_98_1)
	SetActive(self.entranceLayer:Find("btns/btn_remaster/tip"), var_98_1)
end

function LevelScene:updatDailyBtnTip()
	local var_99_0 = getProxy(DailyLevelProxy):ifShowDailyTip()

	SetActive(self.dailyBtn:Find("tip"), var_99_0)
	SetActive(self.entranceLayer:Find("btns/btn_daily/tip"), var_99_0)
end

function LevelScene:updateRemasterInfo()
	self:emit(LevelUIConst.FLUSH_REMASTER_INFO)

	if not self.contextData.map then
		return
	end

	local var_100_0 = getProxy(ChapterProxy)
	local var_100_1 = BossRushChapterRemasterHelper.ChapterAwardInfo((self.contextData.map:getRemaster()))

	setActive(self.remasterAwardBtn, var_100_1)

	if var_100_1 then
		local var_100_2 = var_100_1[1]
		local var_100_3, var_100_4, var_100_5, var_100_6, var_100_7 = unpack(var_100_1[2])
		local var_100_8 = var_100_1[3]
		local var_100_9 = var_100_0:getRemasterInfo(var_100_1[3], var_100_3, var_100_1[1])

		setText(self.remasterAwardBtn:Find("Text"), var_100_9.count .. "/" .. var_100_6)
		updateDrop(self.remasterAwardBtn:Find("IconTpl"), {
			type = var_100_4,
			id = var_100_5
		})
		setActive(self.remasterAwardBtn:Find("tip"), var_100_6 <= var_100_9.count)
		onButton(self, self.remasterAwardBtn, function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				hideYes = true,
				hideNo = true,
				type = MSGBOX_TYPE_SINGLE_ITEM,
				drop = {
					type = var_100_4,
					id = var_100_5
				},
				remaster = {
					word = i18n("level_remaster_tip4", (BossRushChapterRemasterHelper.GetAwardName(var_100_8, var_100_3))),
					number = var_100_9.count .. "/" .. var_100_6,
					btn_text = i18n(var_100_9.count < var_100_6 and "level_remaster_tip2" or "level_remaster_tip3"),
					btn_call = function()
						if var_100_9.count < var_100_6 then
							if var_100_8 and var_100_8 > 0 then
								self:emit(LevelMediator2.ON_BOSSRUSH_REMASTER_ACTIVITY, var_100_8)

								return
							end

							local var_102_0 = pg.chapter_template[var_100_3].map
							local var_102_1, var_102_2 = var_100_0:getMapById(pg.chapter_template[var_100_3].map):isUnlock()

							if not var_102_1 then
								pg.TipsMgr.GetInstance():ShowTips(var_102_2)
							else
								self:ShowSelectedMap(var_102_0)
							end
						else
							self:emit(LevelMediator2.ON_CHAPTER_REMASTER_AWARD, var_100_3, var_100_2, var_100_8)
						end
					end
				}
			})
		end, SFX_PANEL)
	end
end

function LevelScene:updateCountDown()
	if self.newChapterCDTimer then
		self.newChapterCDTimer:Stop()

		self.newChapterCDTimer = nil
	end

	local var_103_0 = 0

	if self.contextData.map:isActivity() and not self.contextData.map:isRemaster() then
		_.each(getProxy(ChapterProxy):getMapsByActivities(self.contextData.map:getConfig("on_activity")), function(arg_104_0)
			local var_104_0 = arg_104_0:getChapterTimeLimit()

			var_103_0 = var_103_0 == 0 and var_104_0 or math.min(var_103_0, var_104_0)
		end)
		setActive(self.countDown, var_103_0 > 0)
		setText(self.countDown:Find("title"), i18n("levelScene_new_chapter_coming"))
	else
		setActive(self.countDown, false)
	end

	if var_103_0 > 0 then
		setText(self.countDown:Find("time"), pg.TimeMgr.GetInstance():DescCDTime(var_103_0))

		self.newChapterCDTimer = Timer.New(function()
			var_103_0 = var_103_0 - 1

			if var_103_0 <= 0 then
				self:updateCountDown()

				if not self.contextData.chapterVO then
					self:setMap(self.contextData.mapIdx)
				end
			else
				setText(self.countDown:Find("time"), pg.TimeMgr.GetInstance():DescCDTime(var_103_0))
			end
		end, 1, -1)

		self.newChapterCDTimer:Start()
	else
		setText(self.countDown:Find("time"), "")
	end
end

function LevelScene:registerActBtn()
	onButton(self, self.actExtraRank, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.ON_EXTRA_RANK)
	end, SFX_PANEL)
	onButton(self, self.activityBtn, function()
		if self:isfrozen() then
			return
		end

		if self.activityBtnLinkAct then
			local var_108_0 = self.activityBtnLinkAct:getConfig("type")

			if var_108_0 == ActivityConst.ACTIVITY_TYPE_BOSSRUSH then
				pg.m02:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_MAIN)

				return
			elseif var_108_0 == ActivityConst.ACTIVITY_TYPE_BOSS_RUSH_DAL_COLLAB then
				pg.m02:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_DAL_COLLAB)

				return
			elseif self.activityBtnLinkAct.id == ActivityConst.OTHER_WORLD_TERMINAL_BATTLE_ID then
				pg.m02:sendNotification(GAME.GO_SCENE, SCENE.OTHERWORLD_MAP)

				return
			elseif var_108_0 == ActivityConst.ACTIVITY_TYPE_BOSS_BATTLE_MARK_2 then
				pg.m02:sendNotification(GAME.GO_SCENE, SCENE.ZHANG_WU_BOSS)

				return
			end
		end

		self:emit(LevelMediator2.ON_ACTIVITY_MAP)
	end, SFX_UI_CLICK)
	onButton(self, self.actExchangeShopBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.GO_ACT_SHOP)
	end, SFX_UI_CLICK)
	onButton(self, self.actAtelierBuffBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.SHOW_ATELIER_BUFF)
	end, SFX_UI_CLICK)
	onButton(self, self.actAtelierYumiaBuffBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelMediator2.SHOW_ATELIER_BUFF, true)
	end, SFX_UI_CLICK)

	local var_106_0 = getProxy(ChapterProxy)

	local function var_106_1(arg_112_0, arg_112_1, arg_112_2)
		local var_112_0 = _.select(arg_112_0:isRemaster() and var_106_0:getRemasterMaps(arg_112_0.remasterId) or var_106_0:getMapsByActivities(arg_112_0:getConfig("on_activity")), function(arg_113_0)
			return arg_113_0:getMapType() == arg_112_1
		end)

		table.sort(var_112_0, function(arg_114_0, arg_114_1)
			return arg_114_0.id < arg_114_1.id
		end)

		local var_112_2 = table.indexof(underscore.map(var_112_0, function(arg_115_0)
			return arg_115_0.id
		end), arg_112_2) or #var_112_0

		while not var_112_0[var_112_2]:isUnlock() do
			if var_112_2 > 1 then
				var_112_2 = var_112_2 - 1
			else
				break
			end
		end

		return var_112_0[var_112_2]
	end

	self:bind(LevelUIConst.SWITCH_ACT_MAP, function(arg_116_0, arg_116_1, arg_116_2)
		arg_116_2 = arg_116_2 or switch(arg_116_1, {
			[Map.ACTIVITY_EASY] = function()
				return self.contextData.map:getBindMapId()
			end,
			[Map.ACTIVITY_HARD] = function()
				return self.contextData.map:getBindMapId()
			end,
			[Map.ACT_EXTRA] = function()
				return PlayerPrefs.GetInt("ex_mapId", 0)
			end
		})

		local var_116_0 = var_106_1(self.contextData.map, arg_116_1, arg_116_2)
		local var_116_1, var_116_2 = var_116_0:isUnlock()

		if var_116_1 then
			self:setMap(var_116_0.id)
		else
			pg.TipsMgr.GetInstance():ShowTips(var_116_2)
		end
	end)
	onButton(self, self.actNormalBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelUIConst.SWITCH_ACT_MAP, Map.ACTIVITY_EASY)
	end, SFX_PANEL)
	onButton(self, self.actEliteBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelUIConst.SWITCH_ACT_MAP, Map.ACTIVITY_HARD)
	end, SFX_PANEL)
	onButton(self, self.actExtraBtn, function()
		if self:isfrozen() then
			return
		end

		self:emit(LevelUIConst.SWITCH_ACT_MAP, Map.ACT_EXTRA)
	end, SFX_PANEL)
end

function LevelScene:initCloudsPos(arg_123_1)
	self.initPositions = {}

	for iter_123_0, iter_123_1 in ipairs(self.cloudRTFs) do
		if pg.expedition_data_by_map[arg_123_1 or 1].clouds_pos[iter_123_0] then
			iter_123_1.anchoredPosition = Vector2(pg.expedition_data_by_map[arg_123_1 or 1].clouds_pos[iter_123_0][1], pg.expedition_data_by_map[arg_123_1 or 1].clouds_pos[iter_123_0][2])

			table.insert(self.initPositions, iter_123_1.anchoredPosition)
		else
			setActive(iter_123_1, false)
		end
	end
end

function LevelScene:initMapBtn(arg_124_1, arg_124_2)
	onButton(self, arg_124_1, function()
		if self:isfrozen() then
			return
		end

		local var_125_0 = self.contextData.mapIdx + arg_124_2
		local var_125_1 = getProxy(ChapterProxy):getMapById(self.contextData.mapIdx + arg_124_2)

		if not var_125_1 then
			return
		end

		if var_125_1:getMapType() == Map.ELITE and not var_125_1:isEliteEnabled() then
			var_125_1 = var_125_1:getBindMap()
			var_125_0 = var_125_1.id

			pg.TipsMgr.GetInstance():ShowTips(i18n("elite_disable_unusable"))
		end

		local var_125_2, var_125_3 = var_125_1:isUnlock()

		if arg_124_2 > 0 and not var_125_2 then
			pg.TipsMgr.GetInstance():ShowTips(var_125_3)

			return
		end

		self:setMap(var_125_0)
	end, SFX_PANEL)
end

function LevelScene:ShowSelectedMap(arg_126_1, arg_126_2)
	seriesAsync({
		function(arg_127_0)
			if self.contextData.entranceStatus then
				self:frozen()

				self.nextPreloadMap = arg_126_1

				self:PreloadLevelMainUI(arg_126_1, function()
					self:unfrozen()

					if self.nextPreloadMap ~= arg_126_1 then
						return
					end

					self:ShowEntranceUI(false)
					self:emit(LevelMediator2.ON_ENTER_MAINLEVEL, arg_126_1)
					arg_127_0()
				end)
			else
				self:setMap(arg_126_1)
				arg_127_0()
			end
		end
	}, arg_126_2)
end

function LevelScene:setMap(arg_129_1)
	local var_129_0 = self.contextData.mapIdx

	self.contextData.mapIdx = arg_129_1
	self.contextData.map = getProxy(ChapterProxy):getMapById(arg_129_1)

	assert(self.contextData.map, "map cannot be nil " .. arg_129_1)

	if self.contextData.map:getMapType() == Map.ACT_EXTRA then
		PlayerPrefs.SetInt("ex_mapId", self.contextData.map.id)
		PlayerPrefs.Save()
	elseif self.contextData.map:isRemaster() then
		PlayerPrefs.SetInt("remaster_lastmap_" .. self.contextData.map.remasterId, arg_129_1)
		PlayerPrefs.Save()
	end

	self:RecordLastMapOnExit()
	self:updateMap(var_129_0)
	self:tryPlayMapStory()
end

local MapBuilder = import("view.level.MapBuilder.MapBuilder")
local var_0_6 = {
	[MapBuilder.TYPENORMAL] = "MapBuilderNormal",
	[MapBuilder.TYPEESCORT] = "MapBuilderEscort",
	[MapBuilder.TYPESHINANO] = "MapBuilderShinano",
	[MapBuilder.TYPESKIRMISH] = "MapBuilderSkirmish",
	[MapBuilder.TYPEBISMARCK] = "MapBuilderBismarck",
	[MapBuilder.TYPESSSS] = "MapBuilderSSSS",
	[MapBuilder.TYPEATELIER] = "MapBuilderAtelier",
	[MapBuilder.TYPESENRANKAGURA] = "MapBuilderSenrankagura",
	[MapBuilder.TYPESP] = "MapBuilderSP",
	[MapBuilder.TYPESPFULL] = "MapBuilderSPFull",
	[MapBuilder.TYPESPSERIES] = "MapBuilderSPSeries",
	[MapBuilder.TYPESPSERIESFULL] = "MapBuilderSPSeriesFull",
	[MapBuilder.TYPEATELIERYUMIA] = "MapBuilderAtelierYumia",
	[MapBuilder.TYPEEXSP] = "MapBuilderEXSP",
	[MapBuilder.TYPESPSERIESRECREW] = "MapBuilderSPSeriesRecrew"
}

function LevelScene:SwitchMapBuilder(arg_130_1)
	if self.mapBuilder and self.mapBuilder:GetType() ~= arg_130_1 then
		self.mapBuilder.buffer:Hide()
	end

	local var_130_0 = self:GetMapBuilderInBuffer(arg_130_1)

	self.mapBuilder = var_130_0

	var_130_0.buffer:Show()
end

function LevelScene:GetMapBuilderInBuffer(arg_131_1)
	if not self.mbDict[arg_131_1] then
		assert(_G[var_0_6[arg_131_1]], "Missing MapBuilder of type " .. (arg_131_1 or "NIL"))

		self.mbDict[arg_131_1] = _G[var_0_6[arg_131_1]].New(self._tf, self)
		self.mbDict[arg_131_1].isFrozen = self:isfrozen()

		self.mbDict[arg_131_1]:Load()
	end

	return self.mbDict[arg_131_1]
end

function LevelScene:updateMap(arg_132_1)
	local var_132_0 = self.contextData.map
	local var_132_1 = self.contextData.map:getConfig("anchor")

	self.map.pivot = var_132_1 == "" and Vector2(0.5, 0.5) or Vector2(unpack(var_132_1))

	local var_132_3 = var_132_0:getConfig("uifx")

	for iter_132_0 = 1, self.UIFXList.childCount do
		local var_132_4 = self.UIFXList:GetChild(iter_132_0 - 1)

		setActive(var_132_4, var_132_4.name == var_132_3)
	end

	self:SwitchMapBG(var_132_0, arg_132_1)
	self:PlayBGM()
	self:SwitchMapBuilder((self.contextData.map:getConfig("ui_type")))
	seriesAsync({
		function(arg_133_0)
			self.mapBuilder:CallbackInvoke(arg_133_0)
		end,
		function(arg_134_0)
			self.mapBuilder:UpdateMapVO(var_132_0)
			self.mapBuilder:UpdateView()
			self.mapBuilder:UpdateMapItems()
			self.mapBuilder:PlayEnterAnim()
		end
	})
	setActive(self.suggestionBtn, table.keyof(LevelTools.GetSuggestionMapIDList(var_132_0.id), var_132_0.id) ~= nil)
end

function LevelScene:UpdateSwitchMapButton()
	local var_135_0 = getProxy(ChapterProxy)
	local var_135_1 = var_135_0:getMapById(self.contextData.map.id - 1)
	local var_135_2 = var_135_0:getMapById(self.contextData.map.id + 1)

	setActive(self.btnPrev, tobool(var_135_1))
	setActive(self.btnNext, tobool(var_135_2))

	local var_135_3 = Color.New(0.5, 0.5, 0.5, 1)

	setImageColor(self.btnPrevCol, (var_135_1 or nil) and (Color.white or var_135_3))
	setImageColor(self.btnNextCol, (var_135_2 and var_135_2:isUnlock() or nil) and (Color.white or var_135_3))
end

function LevelScene:tryPlayMapStory()
	if IsUnityEditor and not ENABLE_GUIDE then
		return
	end

	seriesAsync({
		function(arg_137_0)
			local var_137_0 = self.contextData.map:getConfig("enter_story")

			if var_137_0 and var_137_0 ~= "" then
				if not pg.NewStoryMgr.GetInstance():IsPlayed(var_137_0) and not self.contextData.map:isRemaster() and not pg.SystemOpenMgr.GetInstance().active then
					local var_137_1 = tonumber(var_137_0)

					if var_137_1 and var_137_1 > 0 then
						self:emit(LevelMediator2.ON_PERFORM_COMBAT, var_137_1)
					else
						pg.NewStoryMgr.GetInstance():Play(var_137_0, arg_137_0)
					end

					return
				end
			end

			arg_137_0()
		end,
		function(arg_138_0)
			local var_138_0 = self.contextData.map:getConfig("guide_id")

			if var_138_0 and var_138_0 ~= "" then
				pg.SystemGuideMgr.GetInstance():PlayByGuideId(var_138_0, nil, arg_138_0)

				return
			end

			arg_138_0()
		end,
		function(arg_139_0)
			if self.actAtelierBuffBtn ~= nil and isActive(self.actAtelierBuffBtn) then
				if getProxy(ActivityProxy):AtelierActivityAllSlotIsEmpty() then
					if getProxy(ActivityProxy):OwnAtelierActivityItemCnt(34, 1) then
						pg.SystemGuideMgr.GetInstance():PlayByGuideId("NG0034", PlayerPrefs.GetInt("first_enter_ryza_buff_" .. getProxy(PlayerProxy):getRawData().id, 0) == 0 and {
							1,
							2
						} or {
							1
						})

						goto label_139_0
					end
				end
			end

			arg_139_0()

			::label_139_0::
		end,
		function(arg_140_0)
			if self.exited then
				return
			end

			pg.SystemOpenMgr.GetInstance():notification(self.player.level)

			if pg.SystemOpenMgr.GetInstance().active then
				getProxy(ChapterProxy):StopAutoFight()
			end
		end
	})
end

function LevelScene:DisplaySPAnim(arg_141_1, arg_141_2, arg_141_3)
	self.uiAnims = self.uiAnims or {}

	local var_141_0 = self.uiAnims[arg_141_1]

	local function var_141_1()
		self.playing = true

		self:frozen()
		var_141_0:SetActive(true)

		local var_142_0 = tf(var_141_0)

		pg.UIMgr.GetInstance():OverlayPanel(var_142_0)

		if arg_141_3 then
			arg_141_3(var_141_0)
		end

		var_142_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_143_0)
			self.playing = false

			if arg_141_2 then
				arg_141_2(var_141_0)
			end

			self:unfrozen()
		end)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WARNING)
	end

	if not self.uiAnims[arg_141_1] then
		PoolMgr.GetInstance():GetUI(arg_141_1, true, function(arg_144_0)
			arg_144_0:SetActive(true)

			self.uiAnims[arg_141_1] = arg_144_0
			var_141_0 = self.uiAnims[arg_141_1]

			var_141_1()
		end)
	else
		var_141_1()
	end
end

function LevelScene:displaySpResult(arg_145_1, arg_145_2)
	setActive(self.spResult, true)
	self:DisplaySPAnim(arg_145_1 == 1 and "SpUnitWin" or "SpUnitLose", function(arg_146_0)
		onButton(self, arg_146_0, function()
			removeOnButton(arg_146_0)
			setActive(arg_146_0, false)
			pg.UIMgr.GetInstance():UnOverlayPanel(arg_146_0, self._tf)
			self:hideSpResult()
			arg_145_2()
		end, SFX_PANEL)
	end)
end

function LevelScene:hideSpResult()
	setActive(self.spResult, false)
end

function LevelScene:displayBombResult(arg_149_1)
	setActive(self.spResult, true)
	self:DisplaySPAnim("SpBombRet", function(arg_150_0)
		onButton(self, arg_150_0, function()
			removeOnButton(arg_150_0)
			setActive(arg_150_0, false)
			pg.UIMgr.GetInstance():UnOverlayPanel(arg_150_0, self._tf)
			self:hideSpResult()
			arg_149_1()
		end, SFX_PANEL)
	end, function(arg_152_0)
		setText(arg_152_0.transform:Find("right/name_bg/en"), self.contextData.chapterVO.modelCount)
	end)
end

function LevelScene:OnLevelInfoPanelConfirm(arg_153_1, arg_153_2)
	self.contextData.chapterLoopFlag = arg_153_2

	local var_153_0 = getProxy(ChapterProxy):getChapterById(arg_153_1, true)

	if var_153_0:getConfig("type") == Chapter.CustomFleet then
		self:displayFleetEdit(var_153_0)

		return
	end

	if #var_153_0:getNpcShipByType(1) > 0 then
		self:emit(LevelMediator2.ON_TRACKING, arg_153_1)

		return
	end

	self:displayFleetSelect(var_153_0)
end

function LevelScene:DisplayLevelInfoPanel(arg_154_1, arg_154_2)
	seriesAsync({
		function(arg_155_0)
			if not self.levelInfoView:GetLoaded() then
				self:frozen()
				self.levelInfoView:Load()
				self.levelInfoView:CallbackInvoke(function()
					self:unfrozen()
					arg_155_0()
				end)

				return
			end

			arg_155_0()
		end,
		function(arg_157_0)
			local function var_157_0(arg_158_0, arg_158_1)
				self:hideChapterPanel()
				self:OnLevelInfoPanelConfirm(arg_158_0, arg_158_1)
			end

			local var_157_1 = getProxy(ChapterProxy):getChapterById(arg_154_1, true)

			if getProxy(ChapterProxy):getMapById(var_157_1:getConfig("map")):isSkirmish() and #var_157_1:getNpcShipByType(1) > 0 then
				var_157_0(false)

				return
			end

			self.levelInfoView:set(arg_154_1, arg_154_2)
			self.levelInfoView:setCBFunc(var_157_0, function()
				self:hideChapterPanel()
			end)
			self.levelInfoView:Show()
		end
	})
end

function LevelScene:hideChapterPanel()
	if self.levelInfoView:isShowing() then
		self.levelInfoView:Hide()
	end
end

function LevelScene:destroyChapterPanel()
	self.levelInfoView:Destroy()

	self.levelInfoView = nil
end

function LevelScene:DisplayLevelInfoSPPanel(arg_162_1, arg_162_2, arg_162_3)
	seriesAsync({
		function(arg_163_0)
			if not self.levelInfoSPView then
				self.levelInfoSPView = LevelInfoSPView.New(self.topPanel, self.event, self.contextData)

				self.levelInfoSPView:RegisterView(self)
				self:frozen()
				self.levelInfoSPView:Load()
				self.levelInfoSPView:CallbackInvoke(function()
					self:unfrozen()
					arg_163_0()
				end)

				return
			end

			arg_163_0()
		end,
		function(arg_165_0)
			self.levelInfoSPView:SetChapterGroupInfo(arg_162_2)
			self.levelInfoSPView:set(arg_162_1, arg_162_3)
			self.levelInfoSPView:setCBFunc(function(arg_166_0, arg_166_1)
				self:HideLevelInfoSPPanel()
				self:OnLevelInfoPanelConfirm(arg_166_0, arg_166_1)
			end, function()
				self:HideLevelInfoSPPanel()
			end)
			self.levelInfoSPView:Show()
		end
	})
end

function LevelScene:HideLevelInfoSPPanel()
	if self.levelInfoSPView and self.levelInfoSPView:isShowing() then
		self.levelInfoSPView:Hide()
	end
end

function LevelScene:DestroyLevelInfoSPPanel()
	if not self.levelInfoSPView then
		return
	end

	self.levelInfoSPView:Destroy()

	self.levelInfoSPView = nil
end

function LevelScene:displayFleetSelect(arg_170_1)
	local var_170_0 = self.contextData.selectedFleetIDs or arg_170_1:GetDefaultFleetIndex()

	arg_170_1 = Clone(arg_170_1)
	arg_170_1.loopFlag = self.contextData.chapterLoopFlag

	self.levelFleetView:updateSpecialOperationTickets(self.spTickets)
	self.levelFleetView:Load()
	self.levelFleetView:ActionInvoke("setHardShipVOs", self.shipVOs)
	self.levelFleetView:ActionInvoke("setOpenCommanderTag", self.openedCommanerSystem)
	self.levelFleetView:ActionInvoke("set", arg_170_1, self.fleets, var_170_0)
	self.levelFleetView:ActionInvoke("Show")
end

function LevelScene:hideFleetSelect()
	if self.levelCMDFormationView:isShowing() then
		self.levelCMDFormationView:Hide()
	end

	if self.levelFleetView then
		self.levelFleetView:Hide()
	end
end

function LevelScene:buildCommanderPanel()
	self.levelCMDFormationView = LevelCMDFormationView.New(self.topPanel, self.event, self.contextData)
end

function LevelScene:destroyFleetSelect()
	if not self.levelFleetView then
		return
	end

	self.levelFleetView:Destroy()

	self.levelFleetView = nil
end

function LevelScene:displayFleetEdit(arg_174_1)
	arg_174_1 = Clone(arg_174_1)
	arg_174_1.loopFlag = self.contextData.chapterLoopFlag

	self.levelFleetView:updateSpecialOperationTickets(self.spTickets)
	self.levelFleetView:Load()
	self.levelFleetView:ActionInvoke("setOpenCommanderTag", self.openedCommanerSystem)
	self.levelFleetView:ActionInvoke("setHardShipVOs", self.shipVOs)
	self.levelFleetView:ActionInvoke("setOnHard", arg_174_1)
	self.levelFleetView:ActionInvoke("Show")
end

function LevelScene:hideFleetEdit()
	self:hideFleetSelect()
end

function LevelScene:destroyFleetEdit()
	self:destroyFleetSelect()
end

function LevelScene:RefreshFleetSelectView(arg_177_1)
	if not self.levelFleetView then
		return
	end

	assert(self.levelFleetView:GetLoaded())

	local var_177_0

	if self.levelFleetView:IsSelectMode() then
		self.levelFleetView:ActionInvoke("set", arg_177_1 or self.levelFleetView.chapter, self.fleets, self.levelFleetView:getSelectIds())

		if self.levelCMDFormationView:isShowing() then
			var_177_0 = self.fleets[self.levelCMDFormationView.fleet.id]
		end
	else
		self.levelFleetView:ActionInvoke("setOnHard", arg_177_1 or self.levelFleetView.chapter)

		if self.levelCMDFormationView:isShowing() then
			var_177_0 = arg_177_1:wrapEliteFleet(self.levelCMDFormationView.fleet.id)
		end
	end

	if var_177_0 then
		self.levelCMDFormationView:ActionInvoke("updateFleet", var_177_0)
	end
end

function LevelScene:setChapter(arg_178_1)
	if arg_178_1 then
		self.contextData.chapterId = arg_178_1.id
	end

	self.contextData.chapterVO = arg_178_1
end

function LevelScene:switchToChapter(arg_179_1)
	if not ResList.ChapterResConst.IsActive(arg_179_1) then
		return
	end

	if self.contextData.mapIdx ~= arg_179_1:getConfig("map") then
		self:setMap(arg_179_1:getConfig("map"))
	end

	self:setChapter(arg_179_1)

	self.leftCanvasGroup.blocksRaycasts = false
	self.rightCanvasGroup.blocksRaycasts = false

	assert(not self.levelStageView, "LevelStageView Exists On SwitchToChapter")
	self:DestroyLevelStageView()

	if not self.levelStageView then
		self.levelStageView = LevelStageView.New(self.topPanel, self.event, self.contextData)

		self.levelStageView:Load()

		self.levelStageView.isFrozen = self:isfrozen()
	end

	self:frozen()
	self.levelStageView:ActionInvoke("SetSeriesOperation", function()
		seriesAsync({
			function(arg_181_0)
				self:downloadChapterRes(arg_179_1, arg_181_0)
			end,
			function(arg_182_0)
				self.mapBuilder:CallbackInvoke(arg_182_0)
			end,
			function(arg_183_0)
				setActive(self.clouds, false)
				self.mapBuilder:HideFloat()
				self:BlurPanel(self.topPanel, {
					blurCamList = {
						pg.UIMgr.CameraUI
					}
				})
				self.levelStageView:updateStageInfo()
				self.levelStageView:updateAmbushRate(arg_179_1.fleet.line, true)
				self.levelStageView:updateStageAchieve()
				self.levelStageView:updateStageBarrier()
				self.levelStageView:updateBombPanel()
				self.levelStageView:UpdateDefenseStatus()
				onNextTick(arg_183_0)
			end,
			function(arg_184_0)
				if self.exited then
					return
				end

				self.levelStageView:updateStageStrategy()

				self.canvasGroup.blocksRaycasts = self.frozenCount == 0

				onNextTick(arg_184_0)
			end,
			function(arg_185_0)
				if self.exited then
					return
				end

				self.levelStageView:updateStageFleet()
				self.levelStageView:updateSupportFleet()
				self.levelStageView:updateFleetBuff()
				onNextTick(arg_185_0)
			end,
			function(arg_186_0)
				if self.exited then
					return
				end

				parallelAsync({
					function(arg_187_0)
						local var_187_0 = arg_179_1:getConfig("scale")

						self:RecordTween("mapScale", LeanTween.value(go(self.map), self.map.localScale, Vector3.New(var_187_0[3], var_187_0[3], 1), var_0_1):setOnUpdateVector3(function(arg_188_0)
							self.map.localScale = arg_188_0
							self.float.localScale = arg_188_0
						end):setOnComplete(System.Action(function()
							self.mapBuilder:ShowFloat()
							self.mapBuilder:Hide()
							arg_187_0()
						end)):setEase(LeanTweenType.easeOutSine).uniqueId)

						local var_187_1 = LeanTween.value(go(self.map), self.map.pivot, Vector2.New(math.clamp(var_187_0[1] - 0.5, 0, 1), math.clamp(var_187_0[2] - 0.5, 0, 1)), var_0_1)

						var_187_1:setOnUpdateVector2(function(arg_190_0)
							self.map.pivot = arg_190_0
							self.float.pivot = arg_190_0
						end):setEase(LeanTweenType.easeOutSine)
						self:RecordTween("mapPivot", var_187_1.uniqueId)
						shiftPanel(self.leftChapter, -self.leftChapter.rect.width - 200, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
						shiftPanel(self.rightChapter, self.rightChapter.rect.width + 200, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
						shiftPanel(self.topChapter, 0, self.topChapter.rect.height, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
						self.levelStageView:ShiftStagePanelIn()
					end,
					function(arg_191_0)
						self:PlayBGM()

						local var_191_0 = {}
						local var_191_1 = arg_179_1:getConfig("bg")

						if var_191_1 and #var_191_1 > 0 then
							var_191_0[1] = {
								BG = var_191_1
							}
						end

						self:SwitchBG(var_191_0, arg_191_0)
					end
				}, function()
					onNextTick(arg_186_0)
				end)
			end,
			function(arg_193_0)
				if self.exited then
					return
				end

				setActive(self.topChapter, false)
				setActive(self.leftChapter, false)
				setActive(self.rightChapter, false)

				self.leftCanvasGroup.blocksRaycasts = true
				self.rightCanvasGroup.blocksRaycasts = true

				self:initGrid(arg_193_0)
			end,
			function(arg_194_0)
				if self.exited then
					return
				end

				self.levelStageView:SetGrid(self.grid)

				self.contextData.huntingRangeVisibility = self.contextData.huntingRangeVisibility - 1

				self.grid:toggleHuntingRange()

				local var_194_0 = arg_179_1:getConfig("pop_pic")

				if var_194_0 and #var_194_0 > 0 and self.FirstEnterChapter == arg_179_1.id then
					self:doPlayAnim(var_194_0, function(arg_195_0)
						setActive(arg_195_0, false)

						if self.exited then
							return
						end

						arg_194_0()
					end)
				else
					arg_194_0()
				end
			end,
			function(arg_196_0)
				self.levelStageView:tryAutoAction(arg_196_0)
			end,
			function(arg_197_0)
				if self.exited then
					return
				end

				self:unfrozen()

				if self.FirstEnterChapter then
					self:emit(LevelMediator2.ON_RESUME_SUBSTATE, arg_179_1.subAutoAttack)
				end

				self.FirstEnterChapter = nil

				arg_197_0()
			end,
			function(arg_198_0)
				if arg_179_1:NeedSupportSubmarineStage() then
					self.levelStageView:TryEnterChapterSupportSubmarineStage(arg_198_0)
				else
					arg_198_0()
				end
			end
		}, function()
			self.levelStageView:tryAutoTrigger(true)
		end)
	end)
	self.levelStageView:ActionInvoke("SetPlayer", self.player)
	self.levelStageView:ActionInvoke("SwitchToChapter", arg_179_1)
end

function LevelScene:switchToMap(arg_200_1)
	self:frozen()
	self:destroyGrid()
	self:setChapter(nil)
	LeanTween.cancel(go(self.map))
	self:RecordTween("mapScale", LeanTween.value(go(self.map), self.map.localScale, Vector3.one, var_0_1):setOnUpdateVector3(function(arg_201_0)
		self.map.localScale = arg_201_0
		self.float.localScale = arg_201_0
	end):setOnComplete(System.Action(function()
		self:unfrozen()
		self.mapBuilder:PlayEnterAnim()
		existCall(arg_200_1)
	end)):setEase(LeanTweenType.easeOutSine).uniqueId)

	local var_200_0 = self.contextData.map:getConfig("anchor")
	local var_200_2 = LeanTween.value(go(self.map), self.map.pivot, var_200_0 == "" and Vector2(0.5, 0.5) or Vector2(unpack(var_200_0)), var_0_1)

	var_200_2:setOnUpdateVector2(function(arg_203_0)
		self.map.pivot = arg_203_0
		self.float.pivot = arg_203_0
	end):setEase(LeanTweenType.easeOutSine)
	self:RecordTween("mapPivot", var_200_2.uniqueId)
	setActive(self.topChapter, true)
	setActive(self.leftChapter, true)
	setActive(self.rightChapter, true)
	shiftPanel(self.leftChapter, 0, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	shiftPanel(self.rightChapter, 0, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	shiftPanel(self.topChapter, 0, 0, 0.3, 0, true, nil, LeanTweenType.easeOutSine)
	assert(self.levelStageView, "LevelStageView Doesnt Exist On SwitchToMap")

	if self.levelStageView then
		self.levelStageView:ActionInvoke("ShiftStagePanelOut", function()
			self:DestroyLevelStageView()
		end)
		self.levelStageView:ActionInvoke("SwitchToMap")
	end

	self:SwitchMapBG(self.contextData.map)
	self:PlayBGM()
	seriesAsync({
		function(arg_205_0)
			self.mapBuilder:CallbackInvoke(arg_205_0)
		end,
		function(arg_206_0)
			self.mapBuilder:Show()
			self.mapBuilder:UpdateView()
			self.mapBuilder:UpdateMapItems()
		end
	})
	self:UnOverlayPanel(self.topPanel, self._tf)

	self.canvasGroup.blocksRaycasts = self.frozenCount == 0
	self.canvasGroup.interactable = true

	if self.ambushWarning and self.ambushWarning.activeSelf then
		self.ambushWarning:SetActive(false)
		self:unfrozen()
	end
end

function LevelScene:SwitchBG(arg_207_1, arg_207_2, arg_207_3)
	if not arg_207_1 or #arg_207_1 <= 0 then
		existCall(arg_207_2)

		return
	elseif arg_207_3 then
		-- block empty
	elseif table.equal(self.currentBG, arg_207_1) then
		return
	end

	self.currentBG = arg_207_1

	for iter_207_0, iter_207_1 in ipairs(self.mapGroup) do
		self.loader:ClearRequest(iter_207_1)
	end

	table.clear(self.mapGroup)

	local var_207_0 = {}

	table.ParallelIpairsAsync(arg_207_1, function(arg_208_0, arg_208_1, arg_208_2)
		table.insert(self.mapGroup, (self.loader:GetSpriteDirect(((arg_208_1.bgPrefix or nil) and (arg_208_1.bgPrefix .. "/" or "levelmap/")) .. arg_208_1.BG, "", function(arg_209_0)
			var_207_0[arg_208_0] = arg_209_0

			arg_208_2()
		end, self.mapTFs[arg_208_0])))
		self:updateCouldAnimator(arg_208_1.Animator, arg_208_0)
	end, function()
		for iter_210_0, iter_210_1 in ipairs(self.mapTFs) do
			setImageSprite(iter_210_1, var_207_0[iter_210_0])
			setActive(iter_210_1, arg_207_1[iter_210_0])
			SetCompomentEnabled(iter_210_1, typeof(Image), true)
		end

		existCall(arg_207_2)
	end)
end

local var_0_7 = {
	1520001,
	1520002,
	1520011,
	1520012
}
local var_0_8 = {
	{
		1420008,
		"map_1420008",
		1420021,
		"map_1420001"
	},
	{
		1420018,
		"map_1420018",
		1420031,
		"map_1420011"
	}
}
local var_0_9 = {
	1420001,
	1420011
}

function LevelScene:ClearMapTransitions()
	if not self.mapTransitions then
		return
	end

	for iter_211_0, iter_211_1 in pairs(self.mapTransitions) do
		if iter_211_1 then
			PoolMgr.GetInstance():ReturnPrefab("ui/" .. iter_211_0, iter_211_0, iter_211_1, true)
		else
			PoolMgr.GetInstance():DestroyPrefab("ui/" .. iter_211_0, iter_211_0)
		end
	end

	self.mapTransitions = nil
end

function LevelScene:SwitchMapBG(arg_212_1, arg_212_2, arg_212_3)
	local var_212_0, var_212_1, var_212_2 = self:GetMapBG(arg_212_1, arg_212_2)
	local var_212_3 = {}

	if var_212_1 then
		table.insert(var_212_3, function(arg_213_0)
			self:PlayMapTransition("LevelMapTransition_" .. var_212_1, var_212_2, arg_213_0)
		end)
	end

	seriesAsync(var_212_3, function()
		self:SwitchBGMapType(arg_212_1:getConfig("pos_type"))
		self:SwitchBG(var_212_0, nil, arg_212_3)
	end)
end

function LevelScene:SwitchBGMapType(arg_215_1)
	if self.posType == arg_215_1 then
		return
	end

	for iter_215_0, iter_215_1 in ipairs({
		self.map,
		self.float
	}) do
		local var_215_0 = GetOrAddComponent(iter_215_1, typeof(AspectRatioFitter))

		var_215_0.aspectRatio = 1.7777777777777777
		var_215_0.enabled = arg_215_1 == 0

		if arg_215_1 == 1 then
			iter_215_1.anchorMin = Vector2(0.5, 0.5)
			iter_215_1.anchorMax = Vector2(0.5, 0.5)

			setSizeDelta(var_215_0, {
				x = 2520,
				y = 1440
			})
		end
	end
end

function LevelScene:GetMapBG(arg_216_1, arg_216_2)
	if not table.contains(var_0_7, arg_216_1.id) then
		return {
			self:GetMapElement(arg_216_1)
		}
	end

	local var_216_0 = arg_216_1.id
	local var_216_1 = table.indexof(var_0_7, arg_216_1.id) - 1
	local var_216_2 = bit.lshift(bit.rshift(var_216_1, 1), 1) + 1
	local var_216_3 = _.map({
		var_0_7[var_216_2],
		var_0_7[var_216_2 + 1]
	}, function(arg_217_0)
		return getProxy(ChapterProxy):getMapById(arg_217_0)
	end)

	if _.all(var_216_3, function(arg_218_0)
		return arg_218_0:isAllChaptersClear()
	end) then
		local var_216_4 = {
			self:GetMapElement(arg_216_1)
		}
		local var_216_6
		local var_216_5

		if not arg_216_2 or math.abs(var_216_0 - arg_216_2) ~= 1 then
			do return var_216_4 end

			var_216_5 = bit.band(var_216_1, 1) == 1
			var_216_6 = var_216_4
		end

		return var_216_6, var_0_9[bit.rshift(var_216_2 - 1, 1) + 1], var_216_5
	else
		local var_216_7 = 0

		;(function()
			for iter_219_0, iter_219_1 in ipairs((var_216_3[1]:getChapters())) do
				if not iter_219_1:isClear() then
					return
				end

				var_216_7 = var_216_7 + 1
			end

			if not var_216_3[2]:isAnyChapterUnlocked(true) then
				return
			end

			var_216_7 = var_216_7 + 1

			for iter_219_2, iter_219_3 in ipairs((var_216_3[2]:getChapters())) do
				if not iter_219_3:isClear() then
					return
				end

				var_216_7 = var_216_7 + 1
			end
		end)()

		local var_216_8

		if var_216_7 > 0 then
			local var_216_9 = var_0_8[bit.rshift(var_216_2 - 1, 1) + 1]

			var_216_8 = {
				{
					BG = "map_" .. var_216_9[1],
					Animator = var_216_9[2]
				},
				{
					BG = "map_" .. var_216_9[3] + var_216_7,
					Animator = var_216_9[4]
				}
			}
		else
			var_216_8 = {
				self:GetMapElement(arg_216_1)
			}
		end

		return var_216_8
	end
end

function LevelScene:GetMapElement(arg_220_1)
	local var_220_0 = arg_220_1:getConfig("bg")
	local var_220_1 = arg_220_1:getConfig("ani_controller")

	if var_220_1 and #var_220_1 > 0 then
		(function()
			local var_221_0 = getProxy(ChapterProxy)

			for iter_221_0, iter_221_1 in ipairs(var_220_1) do
				for iter_221_2, iter_221_3 in ipairs((_.rest(iter_221_1[2], 2))) do
					if string.find(iter_221_3, "^map_") and iter_221_1[1] == var_0_3 then
						local var_221_1 = false

						for iter_221_4, iter_221_5 in ipairs(iter_221_1[2][1]) do
							local var_221_2 = var_221_0:GetChapterItemById(iter_221_5)

							if var_221_2 and var_221_2:isClear() then
								var_221_1 = true

								break
							end
						end

						if not var_221_1 then
							var_220_0 = iter_221_3

							return
						end
					end
				end
			end
		end)()
	end

	local var_220_2 = {
		BG = var_220_0
	}

	var_220_2.Animator, var_220_2.AnimatorController = self:GetMapAnimator(arg_220_1)

	return var_220_2
end

function LevelScene:GetMapAnimator(arg_222_1)
	local var_222_0 = arg_222_1:getConfig("ani_name")

	if arg_222_1:getConfig("animtor") == 1 and var_222_0 and #var_222_0 > 0 then
		local var_222_1 = arg_222_1:getConfig("ani_controller")

		if var_222_1 and #var_222_1 > 0 then
			(function()
				local var_223_0 = getProxy(ChapterProxy)

				for iter_223_0, iter_223_1 in ipairs(var_222_1) do
					for iter_223_2, iter_223_3 in ipairs((_.rest(iter_223_1[2], 2))) do
						if string.find(iter_223_3, "^effect_") and iter_223_1[1] == var_0_3 then
							local var_223_1 = false

							for iter_223_4, iter_223_5 in ipairs(iter_223_1[2][1]) do
								local var_223_2 = var_223_0:GetChapterItemById(iter_223_5)

								if var_223_2 and var_223_2:isClear() then
									var_223_1 = true

									break
								end
							end

							if not var_223_1 then
								var_222_0 = "map_" .. string.sub(iter_223_3, 8)

								return
							end
						end
					end
				end
			end)()
		end

		return var_222_0, var_222_1
	end
end

function LevelScene:PlayMapTransition(arg_224_1, arg_224_2, arg_224_3, arg_224_4)
	self.mapTransitions = self.mapTransitions or {}

	local var_224_0

	local function var_224_1()
		self:frozen()
		existCall(arg_224_3, var_224_0)
		var_224_0:SetActive(true)

		local var_225_0 = tf(var_224_0)

		pg.UIMgr.GetInstance():OverlayPanel(var_225_0)
		var_224_0:GetComponent(typeof(Animator)):Play(arg_224_2 and "Sequence" or "Inverted", -1, 0)
		var_225_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_226_0)
			pg.UIMgr.GetInstance():UnOverlayPanel(var_225_0, self._tf)
			existCall(arg_224_4, var_224_0)
			PoolMgr.GetInstance():ReturnPrefab("ui/" .. arg_224_1, arg_224_1, var_224_0)

			self.mapTransitions[arg_224_1] = false

			self:unfrozen()
		end)
	end

	PoolMgr.GetInstance():GetPrefab("ui/" .. arg_224_1, arg_224_1, true, function(arg_227_0)
		var_224_0 = arg_227_0
		self.mapTransitions[arg_224_1] = arg_227_0

		var_224_1()
	end)
end

function LevelScene:DestroyLevelStageView()
	if self.levelStageView then
		self.levelStageView:Destroy()

		self.levelStageView = nil
	end
end

function LevelScene:displayAmbushInfo(arg_229_1)
	self.levelAmbushView = LevelAmbushView.New(self.topPanel, self.event, self.contextData)

	self.levelAmbushView:Load()
	self.levelAmbushView:ActionInvoke("SetFuncOnComplete", arg_229_1)
end

function LevelScene:hideAmbushInfo()
	if self.levelAmbushView then
		self.levelAmbushView:Destroy()

		self.levelAmbushView = nil
	end
end

function LevelScene:doAmbushWarning(arg_231_1)
	self:frozen()

	local function var_231_0()
		self.ambushWarning:SetActive(true)

		local var_232_0 = tf(self.ambushWarning)

		var_232_0:SetParent(pg.UIMgr.GetInstance().OverlayMain.transform, false)
		var_232_0:SetSiblingIndex(1)

		local var_232_1 = var_232_0:GetComponent("DftAniEvent")

		var_232_1:SetTriggerEvent(function(arg_233_0)
			arg_231_1()
		end)
		var_232_1:SetEndEvent(function(arg_234_0)
			self.ambushWarning:SetActive(false)
			self:unfrozen()
		end)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WARNING)
		Timer.New(function()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WARNING)
		end, 1, 1):Start()
	end

	if not self.ambushWarning then
		PoolMgr.GetInstance():GetUI("ambushwarnui", true, function(arg_236_0)
			arg_236_0:SetActive(true)

			self.ambushWarning = arg_236_0

			var_231_0()
		end)
	else
		var_231_0()
	end
end

function LevelScene:destroyAmbushWarn()
	if self.ambushWarning then
		PoolMgr.GetInstance():ReturnUI("ambushwarnui", self.ambushWarning)

		self.ambushWarning = nil
	end
end

function LevelScene:displayStrategyInfo(arg_238_1)
	self.levelStrategyView = LevelStrategyView.New(self.topPanel, self.event, self.contextData)

	self.levelStrategyView:Load()
	self.levelStrategyView:ActionInvoke("set", arg_238_1)
	self.levelStrategyView:ActionInvoke("setCBFunc", function()
		if not self.contextData.chapterVO.fleet:canUseStrategy(arg_238_1) then
			return
		end

		local var_239_0 = self.contextData.chapterVO.fleet:getNextStgUser(arg_238_1.id)

		if pg.strategy_data_template[arg_238_1.id].type == ChapterConst.StgTypeForm then
			self:emit(LevelMediator2.ON_OP, {
				type = ChapterConst.OpStrategy,
				id = var_239_0,
				arg1 = arg_238_1.id
			})
		elseif pg.strategy_data_template[arg_238_1.id].type == ChapterConst.StgTypeConsume then
			self:emit(LevelMediator2.ON_OP, {
				type = ChapterConst.OpStrategy,
				id = var_239_0,
				arg1 = arg_238_1.id
			})
		end

		self:hideStrategyInfo()
	end, function()
		self:hideStrategyInfo()
	end)
end

function LevelScene:hideStrategyInfo()
	if self.levelStrategyView then
		self.levelStrategyView:Destroy()

		self.levelStrategyView = nil
	end
end

function LevelScene:displayRepairWindow(arg_242_1)
	local var_242_0 = self.contextData.chapterVO
	local var_242_1 = getProxy(ChapterProxy).repairTimes
	local var_242_3, var_242_4, var_242_5 = ChapterConst.GetRepairParams()

	self.levelRepairView = LevelRepairView.New(self.topPanel, self.event, self.contextData)

	self.levelRepairView:Load()
	self.levelRepairView:ActionInvoke("set", var_242_1, nil, nil, nil)
	self.levelRepairView:ActionInvoke("setCBFunc", function()
		if var_242_3 - math.min(var_242_1, var_242_3) == 0 and self.player:getTotalGem() < var_242_5 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_no_rmb"))

			return
		end

		self:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpRepair,
			id = var_242_0.fleet.id,
			arg1 = arg_242_1.id
		})
		self:hideRepairWindow()
	end, function()
		self:hideRepairWindow()
	end)
end

function LevelScene:hideRepairWindow()
	if self.levelRepairView then
		self.levelRepairView:Destroy()

		self.levelRepairView = nil
	end
end

function LevelScene:displayRemasterPanel(arg_246_1)
	self.levelRemasterView:Load()
	self.levelRemasterView:ActionInvoke("Show")
	self.levelRemasterView:ActionInvoke("set", function(arg_247_0)
		self:ShowSelectedMap(arg_247_0)
	end, arg_246_1)
end

function LevelScene:hideRemasterPanel()
	if self.levelRemasterView:isShowing() then
		self.levelRemasterView:ActionInvoke("Hide")
	end
end

function LevelScene:initGrid(arg_249_1)
	if not self.contextData.chapterVO then
		return
	end

	self:enableLevelCamera()
	setActive(self.uiMain, true)

	self.levelGrid.localEulerAngles = Vector3(self.contextData.chapterVO.theme.angle, 0, 0)
	self.grid = LevelGrid.New(self.dragLayer)

	self.grid:attach(self)
	self.grid:ExtendItem("shipTpl", self.shipTpl)
	self.grid:ExtendItem("subTpl", self.subTpl)
	self.grid:ExtendItem("transportTpl", self.transportTpl)
	self.grid:ExtendItem("enemyTpl", self.enemyTpl)
	self.grid:ExtendItem("championTpl", self.championTpl)
	self.grid:ExtendItem("oniTpl", self.oniTpl)
	self.grid:ExtendItem("arrowTpl", self.arrowTarget)
	self.grid:ExtendItem("destinationMarkTpl", self.destinationMarkTpl)

	function self.grid.onShipStepChange(arg_250_0)
		self.levelStageView:updateAmbushRate(arg_250_0)
	end

	self.grid:initAll(arg_249_1)
end

function LevelScene:destroyGrid()
	if self.grid then
		self.grid:detach()

		self.grid = nil

		self:disableLevelCamera()
		setActive(self.dragLayer, true)
		setActive(self.uiMain, false)
	end
end

function LevelScene:doTracking(arg_252_1)
	self:frozen()

	local function var_252_0()
		self.radar:SetActive(true)

		local var_253_0 = tf(self.radar)

		var_253_0:SetParent(self.topPanel, false)
		var_253_0:SetSiblingIndex(1)
		var_253_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_254_0)
			self.radar:SetActive(false)
			self:unfrozen()
			arg_252_1()
		end)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WEIGHANCHOR_SEARCH)
	end

	if not self.radar then
		PoolMgr.GetInstance():GetUI("RadarEffectUI", true, function(arg_255_0)
			arg_255_0:SetActive(true)

			self.radar = arg_255_0

			var_252_0()
		end)
	else
		var_252_0()
	end
end

function LevelScene:destroyTracking()
	if self.radar then
		PoolMgr.GetInstance():ReturnUI("RadarEffectUI", self.radar)

		self.radar = nil
	end
end

function LevelScene:doPlayAirStrike(arg_257_1, arg_257_2, arg_257_3)
	local function var_257_0()
		self.playing = true

		self:frozen()
		self.airStrike:SetActive(true)

		local var_258_0 = tf(self.airStrike)

		var_258_0:SetParent(pg.UIMgr.GetInstance().OverlayMain.transform, false)
		var_258_0:SetAsLastSibling()
		setActive(var_258_0:Find("words/be_striked"), arg_257_1 == ChapterConst.SubjectChampion)
		setActive(var_258_0:Find("words/strike_enemy"), arg_257_1 == ChapterConst.SubjectPlayer)

		local function var_258_1()
			self.playing = false

			SetActive(self.airStrike, false)

			if arg_257_3 then
				arg_257_3()
			end

			self:unfrozen()
		end

		var_258_0:GetComponent("DftAniEvent"):SetEndEvent(var_258_1)

		if arg_257_2 then
			onButton(self, var_258_0, var_258_1, SFX_PANEL)
		else
			removeOnButton(var_258_0)
		end

		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WARNING)
	end

	if not self.airStrike then
		PoolMgr.GetInstance():GetUI("AirStrike", true, function(arg_260_0)
			arg_260_0:SetActive(true)

			self.airStrike = arg_260_0

			var_257_0()
		end)
	else
		var_257_0()
	end
end

function LevelScene:destroyAirStrike()
	if self.airStrike then
		self.airStrike:GetComponent("DftAniEvent"):SetEndEvent(nil)
		PoolMgr.GetInstance():ReturnUI("AirStrike", self.airStrike)

		self.airStrike = nil
	end
end

function LevelScene:doPlayAnim(arg_262_1, arg_262_2, arg_262_3)
	self.uiAnims = self.uiAnims or {}

	local var_262_0 = self.uiAnims[arg_262_1]

	local function var_262_1()
		self.playing = true

		self:frozen()
		var_262_0:SetActive(true)

		local var_263_0 = tf(var_262_0)

		pg.UIMgr.GetInstance():OverlayPanel(var_263_0)

		if arg_262_3 then
			arg_262_3(var_262_0)
		end

		var_263_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_264_0)
			self.playing = false

			pg.UIMgr.GetInstance():UnOverlayPanel(var_263_0, self._tf)

			if arg_262_2 then
				arg_262_2(var_262_0)
			end

			self:unfrozen()
		end)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WARNING)
	end

	if not self.uiAnims[arg_262_1] then
		PoolMgr.GetInstance():GetUI(arg_262_1, true, function(arg_265_0)
			arg_265_0:SetActive(true)

			self.uiAnims[arg_262_1] = arg_265_0
			var_262_0 = self.uiAnims[arg_262_1]

			var_262_1()
		end)
	else
		var_262_1()
	end
end

function LevelScene:destroyUIAnims()
	if self.uiAnims then
		for iter_266_0, iter_266_1 in pairs(self.uiAnims) do
			pg.UIMgr.GetInstance():UnOverlayPanel(tf(iter_266_1), self._tf)
			iter_266_1:GetComponent("DftAniEvent"):SetEndEvent(nil)
			PoolMgr.GetInstance():ReturnUI(iter_266_0, iter_266_1)
		end

		self.uiAnims = nil
	end
end

function LevelScene:doPlayTorpedo(arg_267_1)
	local function var_267_0()
		self.playing = true

		self:frozen()
		self.torpetoAni:SetActive(true)

		local var_268_0 = tf(self.torpetoAni)

		var_268_0:SetParent(self.topPanel, false)
		var_268_0:SetAsLastSibling()
		var_268_0:GetComponent("DftAniEvent"):SetEndEvent(function(arg_269_0)
			self.playing = false

			SetActive(self.torpetoAni, false)

			if arg_267_1 then
				arg_267_1()
			end

			self:unfrozen()
		end)
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_WARNING)
	end

	if not self.torpetoAni then
		PoolMgr.GetInstance():GetUI("Torpeto", true, function(arg_270_0)
			arg_270_0:SetActive(true)

			self.torpetoAni = arg_270_0

			var_267_0()
		end)
	else
		var_267_0()
	end
end

function LevelScene:destroyTorpedo()
	if self.torpetoAni then
		self.torpetoAni:GetComponent("DftAniEvent"):SetEndEvent(nil)
		PoolMgr.GetInstance():ReturnUI("Torpeto", self.torpetoAni)

		self.torpetoAni = nil
	end
end

function LevelScene:doPlayStrikeAnim(arg_272_1, arg_272_2, arg_272_3)
	self.strikeAnims = self.strikeAnims or {}

	local var_272_0
	local var_272_1
	local var_272_2

	local function var_272_3()
		if coroutine.status(var_272_2) == "suspended" then
			local var_273_0, var_273_1 = coroutine.resume(var_272_2)

			assert(var_273_0, debug.traceback(var_272_2, var_273_1))
		end
	end

	var_272_2 = coroutine.create(function()
		self.playing = true

		self:frozen()
		setActive(self.strikeAnims[arg_272_2], true)

		local var_274_0 = tf(self.strikeAnims[arg_272_2])
		local var_274_1 = findTF(var_274_0, "mask/painting")
		local var_274_2 = findTF(var_274_0, "ship")

		setParent(var_272_0, var_274_1:Find("fitter"), false)
		var_272_1:SetParent(var_274_2)
		setActive(var_274_2, false)
		setActive(findTF(var_274_0, "torpedo"), false)
		var_274_0:SetParent(pg.UIMgr.GetInstance().OverlayMain.transform, false)
		var_274_0:SetAsLastSibling()

		local var_274_3 = var_274_0:GetComponent("DftAniEvent")
		local var_274_4 = var_272_1:GetSkeletonGraphic()

		var_274_3:SetStartEvent(function(arg_275_0)
			var_272_1:SetAction("attack", 0)

			var_274_4.freeze = true
		end)
		var_274_3:SetTriggerEvent(function(arg_276_0)
			var_274_4.freeze = false

			var_272_1:SetActionCallBack(function(arg_277_0)
				if arg_277_0 == "action" then
					-- block empty
				elseif arg_277_0 == "finish" then
					var_274_4.freeze = true
				end
			end)
		end)
		var_274_3:SetEndEvent(function(arg_278_0)
			var_274_4.freeze = false

			var_272_3()
		end)
		onButton(self, var_274_0, var_272_3, SFX_CANCEL)
		coroutine.yield()
		retPaintingPrefab(var_274_1, arg_272_1:getPainting())
		var_272_1:SetActionCallBack(nil)

		var_274_4.freeze = false

		var_272_1:Dispose()
		setActive(self.strikeAnims[arg_272_2], false)

		self.playing = false

		self:unfrozen()

		if arg_272_3 then
			arg_272_3()
		end
	end)

	local function var_272_4()
		if self.strikeAnims[arg_272_2] and var_272_0 and var_272_1 then
			var_272_3()
		end
	end

	PoolMgr.GetInstance():GetPainting(arg_272_1:getPainting(), true, function(arg_280_0)
		var_272_0 = arg_280_0

		ShipExpressionHelper.SetExpression(var_272_0, arg_272_1:getPainting())
		var_272_4()
	end)

	var_272_1 = SpineAnimChar.New()

	var_272_1:SetPaint(arg_272_1:getPrefab())
	var_272_1:Load(true, function(arg_281_0)
		var_272_1:SetLocalScale(Vector3.one)
		var_272_4()
	end)

	if not self.strikeAnims[arg_272_2] then
		PoolMgr.GetInstance():GetUI(arg_272_2, true, function(arg_282_0)
			self.strikeAnims[arg_272_2] = arg_282_0

			var_272_4()
		end)
	end
end

function LevelScene:destroyStrikeAnim()
	if self.strikeAnims then
		for iter_283_0, iter_283_1 in pairs(self.strikeAnims) do
			iter_283_1:GetComponent("DftAniEvent"):SetEndEvent(nil)
			PoolMgr.GetInstance():ReturnUI(iter_283_0, iter_283_1)
		end

		self.strikeAnims = nil
	end
end

function LevelScene:doPlayEnemyAnim(arg_284_1, arg_284_2, arg_284_3)
	self.strikeAnims = self.strikeAnims or {}

	local var_284_0
	local var_284_1

	local function var_284_2()
		if coroutine.status(var_284_1) == "suspended" then
			local var_285_0, var_285_1 = coroutine.resume(var_284_1)

			assert(var_285_0, debug.traceback(var_284_1, var_285_1))
		end
	end

	var_284_1 = coroutine.create(function()
		self.playing = true

		self:frozen()
		setActive(self.strikeAnims[arg_284_2], true)

		local var_286_0 = tf(self.strikeAnims[arg_284_2])
		local var_286_1 = findTF(var_286_0, "ship")

		var_284_0:SetParent(var_286_1)
		setActive(var_286_1, false)
		setActive(findTF(var_286_0, "torpedo"), false)
		var_286_0:SetParent(pg.UIMgr.GetInstance().OverlayMain.transform, false)
		var_286_0:SetAsLastSibling()

		local var_286_2 = var_286_0:GetComponent("DftAniEvent")
		local var_286_3 = var_284_0:GetSkeletonGraphic()

		var_286_2:SetStartEvent(function(arg_287_0)
			var_284_0:SetAction("attack", 0)

			var_286_3.freeze = true
		end)
		var_286_2:SetTriggerEvent(function(arg_288_0)
			var_286_3.freeze = false

			var_284_0:SetActionCallBack(function(arg_289_0)
				if arg_289_0 == "action" then
					-- block empty
				elseif arg_289_0 == "finish" then
					var_286_3.freeze = true
				end
			end)
		end)
		var_286_2:SetEndEvent(function(arg_290_0)
			var_286_3.freeze = false

			var_284_2()
		end)
		onButton(self, var_286_0, var_284_2, SFX_CANCEL)
		coroutine.yield()
		var_284_0:SetActionCallBack(nil)

		var_286_3.freeze = false

		var_284_0:Dispose()
		setActive(self.strikeAnims[arg_284_2], false)

		self.playing = false

		self:unfrozen()

		if arg_284_3 then
			arg_284_3()
		end
	end)

	local function var_284_3()
		if self.strikeAnims[arg_284_2] and var_284_0 then
			var_284_2()
		end
	end

	var_284_0 = SpineAnimChar.New()

	;(nil):SetPaint(arg_284_1:getPrefab())
	var_284_0:Load(true, function(arg_292_0)
		arg_292_0:SetLocalScale(Vector3.one)
		var_284_3()
	end)

	if not self.strikeAnims[arg_284_2] then
		PoolMgr.GetInstance():GetUI(arg_284_2, true, function(arg_293_0)
			self.strikeAnims[arg_284_2] = arg_293_0

			var_284_3()
		end)
	end
end

function LevelScene:doPlayCommander(arg_294_1, arg_294_2)
	self:frozen()
	setActive(self.commanderTinkle, true)

	local var_294_0 = arg_294_1:getSkills()

	setText(self.commanderTinkle:Find("name"), #var_294_0 > 0 and var_294_0[1]:getConfig("name") or "")
	setImageSprite(self.commanderTinkle:Find("icon"), GetSpriteFromAtlas("commanderhrz/" .. arg_294_1:getConfig("painting"), ""))

	local var_294_1 = self.commanderTinkle:GetComponent(typeof(CanvasGroup))

	var_294_1.alpha = 0

	local var_294_2 = Vector2(248, 237)

	LeanTween.value(go(self.commanderTinkle), 0, 1, 0.5):setOnUpdate(System.Action_float(function(arg_295_0)
		self.commanderTinkle.localPosition.x = var_294_2.x + -100 * (1 - arg_295_0)
		self.commanderTinkle.localPosition = self.commanderTinkle.localPosition
		var_294_1.alpha = arg_295_0
	end)):setEase(LeanTweenType.easeOutSine)
	LeanTween.value(go(self.commanderTinkle), 0, 1, 0.3):setDelay(0.7):setOnUpdate(System.Action_float(function(arg_296_0)
		self.commanderTinkle.localPosition.x = var_294_2.x + 100 * arg_296_0
		self.commanderTinkle.localPosition = self.commanderTinkle.localPosition
		var_294_1.alpha = 1 - arg_296_0
	end)):setOnComplete(System.Action(function()
		if arg_294_2 then
			arg_294_2()
		end

		self:unfrozen()
	end))
end

function LevelScene:strikeEnemy(arg_298_1, arg_298_2, arg_298_3)
	local var_298_0 = self.grid:shakeCell(arg_298_1)

	if not var_298_0 then
		arg_298_3()

		return
	end

	self:easeDamage(var_298_0, arg_298_2, function()
		arg_298_3()
	end)
end

function LevelScene:easeDamage(arg_300_1, arg_300_2, arg_300_3)
	self:frozen()

	local var_300_0 = tf(self:GetDamageText())

	var_300_0.position = self.uiCam:ScreenToWorldPoint((self.levelCam:WorldToScreenPoint(arg_300_1.position)))

	local var_300_1 = var_300_0.localPosition

	var_300_0.localPosition.y = var_300_0.localPosition.y + 40
	var_300_0.localPosition.z = 0

	setText(var_300_0, arg_300_2)

	var_300_0.localPosition = var_300_0.localPosition

	LeanTween.value(go(var_300_0), 0, 1, 1):setOnUpdate(System.Action_float(function(arg_301_0)
		var_300_0.localPosition.y = var_300_1.y + 60 * arg_301_0
		var_300_0.localPosition = var_300_0.localPosition

		setTextAlpha(var_300_0, 1 - arg_301_0)
	end)):setOnComplete(System.Action(function()
		self:ReturnDamageText(var_300_0)
		self:unfrozen()

		if arg_300_3 then
			arg_300_3()
		end
	end))
end

function LevelScene:easeAvoid(arg_303_1, arg_303_2)
	self:frozen()

	self.avoidText.position = self.uiCam:ScreenToWorldPoint((self.levelCam:WorldToScreenPoint(arg_303_1)))

	local var_303_0 = self.avoidText.localPosition

	self.avoidText.localPosition.z = 0
	self.avoidText.localPosition = self.avoidText.localPosition

	setActive(self.avoidText, true)

	local var_303_1 = self.avoidText:Find("avoid")

	LeanTween.value(go(self.avoidText), 0, 1, 1):setOnUpdate(System.Action_float(function(arg_304_0)
		self.avoidText.localPosition.y = var_303_0.y + 100 * arg_304_0
		self.avoidText.localPosition = self.avoidText.localPosition

		setImageAlpha(self.avoidText, 1 - arg_304_0)
		setImageAlpha(var_303_1, 1 - arg_304_0)
	end)):setOnComplete(System.Action(function()
		setActive(self.avoidText, false)
		self:unfrozen()

		if arg_303_2 then
			arg_303_2()
		end
	end))
end

function LevelScene:GetDamageText()
	local var_306_0 = table.remove(self.damageTextPool)

	if not var_306_0 then
		var_306_0 = Instantiate(self.damageTextTemplate)

		setParent(var_306_0, tf(self.damageTextTemplate).parent)
		tf(var_306_0):SetSiblingIndex(tf(self.damageTextTemplate):GetSiblingIndex() + 1)
	end

	table.insert(self.damageTextActive, var_306_0)
	setActive(var_306_0, true)

	return var_306_0
end

function LevelScene:ReturnDamageText(arg_307_1)
	assert(arg_307_1)

	if not arg_307_1 then
		return
	end

	arg_307_1 = go(arg_307_1)

	table.removebyvalue(self.damageTextActive, arg_307_1)
	table.insert(self.damageTextPool, arg_307_1)
	setActive(arg_307_1, false)
end

function LevelScene:resetLevelGrid()
	self.dragLayer.localPosition = Vector3.zero
end

function LevelScene:ShowCurtains(arg_309_1)
	setActive(self.curtain, arg_309_1)
end

function LevelScene:frozen()
	self.frozenCount = self.frozenCount + 1
	self.canvasGroup.blocksRaycasts = self.frozenCount == 0

	if self.frozenCount == 0 and self.frozenCount ~= 0 then
		self:emit(LevelUIConst.ON_FROZEN)
	end
end

function LevelScene:unfrozen(arg_311_1)
	if self.exited then
		return
	end

	self.frozenCount = self.frozenCount - ((arg_311_1 == -1 or nil) and (self.frozenCount or arg_311_1 or 1))
	self.canvasGroup.blocksRaycasts = self.frozenCount == 0

	if self.frozenCount ~= 0 and self.frozenCount == 0 then
		self:emit(LevelUIConst.ON_UNFROZEN)
	end
end

function LevelScene:isfrozen()
	return self.frozenCount > 0
end

function LevelScene:enableLevelCamera()
	self.levelCamIndices = math.max(self.levelCamIndices - 1, 0)

	if self.levelCamIndices == 0 then
		self.levelCam.enabled = true

		pg.LayerWeightMgr.GetInstance():CreateRefreshHandler()
	end
end

function LevelScene:disableLevelCamera()
	self.levelCamIndices = self.levelCamIndices + 1

	if self.levelCamIndices > 0 then
		self.levelCam.enabled = false

		pg.LayerWeightMgr.GetInstance():CreateRefreshHandler()
	end
end

function LevelScene:RecordTween(arg_315_1, arg_315_2)
	self.tweens[arg_315_1] = arg_315_2
end

function LevelScene:DeleteTween(arg_316_1)
	if self.tweens[arg_316_1] then
		LeanTween.cancel(self.tweens[arg_316_1])

		self.tweens[arg_316_1] = nil
	end
end

function LevelScene:openCommanderPanel(arg_317_1, arg_317_2, arg_317_3)
	local var_317_0 = arg_317_2.id

	self.levelCMDFormationView:setCallback(function(arg_318_0)
		if not arg_317_3 then
			if arg_318_0.type == LevelUIConst.COMMANDER_OP_SHOW_SKILL then
				self:emit(LevelMediator2.ON_COMMANDER_SKILL, arg_318_0.skill)
			elseif arg_318_0.type == LevelUIConst.COMMANDER_OP_ADD then
				self.contextData.commanderSelected = {
					chapterId = var_317_0,
					fleetId = arg_317_1.id
				}

				self:emit(LevelMediator2.ON_SELECT_COMMANDER, arg_318_0.pos, arg_317_1.id, arg_317_2)
				self:closeCommanderPanel()
			else
				self:emit(LevelMediator2.ON_COMMANDER_OP, {
					FleetType = LevelUIConst.FLEET_TYPE_SELECT,
					data = arg_318_0,
					fleetId = arg_317_1.id,
					chapterId = var_317_0
				}, arg_317_2)
			end
		elseif arg_318_0.type == LevelUIConst.COMMANDER_OP_SHOW_SKILL then
			self:emit(LevelMediator2.ON_COMMANDER_SKILL, arg_318_0.skill)
		elseif arg_318_0.type == LevelUIConst.COMMANDER_OP_ADD then
			self.contextData.eliteCommanderSelected = {
				index = arg_317_3,
				pos = arg_318_0.pos,
				chapterId = var_317_0
			}

			self:emit(LevelMediator2.ON_SELECT_ELITE_COMMANDER, arg_317_3, arg_318_0.pos, arg_317_2)
			self:closeCommanderPanel()
		else
			self:emit(LevelMediator2.ON_COMMANDER_OP, {
				FleetType = LevelUIConst.FLEET_TYPE_EDIT,
				data = arg_318_0,
				index = arg_317_3,
				chapterId = var_317_0
			}, arg_317_2)
		end
	end)
	self.levelCMDFormationView:Load()
	self.levelCMDFormationView:ActionInvoke("update", arg_317_1, self.commanderPrefabs)
	self.levelCMDFormationView:ActionInvoke("Show")
end

function LevelScene:updateCommanderPrefab()
	if self.levelCMDFormationView:isShowing() then
		self.levelCMDFormationView:ActionInvoke("updatePrefabs", self.commanderPrefabs)
	end
end

function LevelScene:closeCommanderPanel()
	self.levelCMDFormationView:ActionInvoke("Hide")
end

function LevelScene:destroyCommanderPanel()
	self.levelCMDFormationView:Destroy()

	self.levelCMDFormationView = nil
end

function LevelScene:setSpecialOperationTickets(arg_322_1)
	self.spTickets = arg_322_1
end

function LevelScene:HandleShowMsgBox(arg_323_1)
	pg.MsgboxMgr.GetInstance():ShowMsgBox(arg_323_1)
end

function LevelScene:updatePoisonAreaTip()
	local var_324_0 = self.contextData.chapterVO
	local var_324_1 = (function(arg_325_0)
		local var_325_0 = {}
		local var_325_1 = pg.map_event_list[var_324_0.id] or {}

		for iter_325_0, iter_325_1 in ipairs(var_324_0:isLoop() and (var_325_1.event_list_loop or {}) or var_325_1.event_list or {}) do
			if pg.map_event_template[iter_325_1].c_type == arg_325_0 then
				table.insert(var_325_0, pg.map_event_template[iter_325_1])
			end
		end

		return var_325_0
	end)(ChapterConst.EvtType_Poison)

	if var_324_1 then
		for iter_324_0, iter_324_1 in ipairs(var_324_1) do
			if iter_324_1.round_gametip ~= nil and iter_324_1.round_gametip ~= "" and self.contextData.chapterVO:getRoundNum() == iter_324_1.round_gametip[1] then
				pg.TipsMgr.GetInstance():ShowTips(i18n(iter_324_1.round_gametip[2]))
			end
		end
	end
end

function LevelScene:updateVoteBookBtn()
	setActive(self._voteBookBtn, false)
end

function LevelScene:RecordLastMapOnExit()
	local var_327_0 = getProxy(ChapterProxy)

	if var_327_0 and not self.contextData.noRecord then
		if not self.contextData.map then
			return
		end

		if self.contextData.map:NeedRecordMap() then
			var_327_0:recordLastMap(ChapterProxy.LAST_MAP, self.contextData.map.id)
		end

		if self.contextData.map:isActivity() and not self.contextData.map:isActExtra() then
			var_327_0:recordLastMap(ChapterProxy.LAST_MAP_FOR_ACTIVITY, self.contextData.map.id)
		end
	end
end

function LevelScene:IsActShopActive()
	local var_328_0

	if self.contextData.map then
		var_328_0 = getProxy(ActivityProxy):getActivityById(self.contextData.map:getConfig("on_activity")) or nil
	end

	local var_328_1 = var_328_0 and not var_328_0:isEnd() and var_328_0:GetConfigClientSetting("PTID")
	local var_328_2 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_LOTTERY)

	if var_328_2 and not var_328_2:isEnd() and var_328_2:getConfig("config_client").resId == var_328_1 then
		return true
	end

	local var_328_3 = var_328_0 and var_328_0:GetConfigClientPTActivity() or nil

	if var_328_3 then
		if getProxy(ActivityProxy):GetShopActivityByRes(var_328_3:GetPTDrop()) or nil then
			return true
		end
	end
end

function LevelScene:OnStartChapterAuto(arg_329_1)
	if self.levelInfoView:isShowing() then
		self:hideChapterPanel()
	end

	if self.levelInfoSPView and self.levelInfoSPView:isShowing() then
		self:HideLevelInfoSPPanel()
	end
end

function LevelScene:OnEndChapterAuto(arg_330_1)
	return
end

function LevelScene:OnAddChapterAutoTimeDone()
	if self.levelInfoView:isShowing() then
		self.levelInfoView:RefreshChapterAutoPanel()
	end

	if self.levelInfoSPView and self.levelInfoSPView:isShowing() then
		self.levelInfoView:RefreshChapterAutoPanel()
	end
end

function LevelScene:ShowChapterAutoDetailPanel(arg_332_1)
	self.chapterAutoDetailPanel:Load()
	self.chapterAutoDetailPanel:ActionInvoke("Enter", arg_332_1)
end

function LevelScene:HideChapterAutoDetailPanel()
	if self.chapterAutoDetailPanel:isShowing() then
		self.chapterAutoDetailPanel:Hide()
	end
end

function LevelScene:DestroyChapterAutoDetailPanel()
	if self.chapterAutoDetailPanel then
		self.chapterAutoDetailPanel:Destroy()

		self.chapterAutoDetailPanel = nil
	end
end

function LevelScene:willExit()
	self:ClearMapTransitions()
	self.loader:Clear()

	if self.entranceActivityBg then
		pg.PoolMgr.GetInstance():ReturnPrefab(self.entranceActivityBgPath, "", self.entranceActivityBg)

		self.entranceActivityBg = nil
		self.entranceActivityBgPath = nil
	end

	if self.contextData.chapterVO then
		self:UnOverlayPanel(self.topPanel, self._tf)
	end

	if self.levelFleetView and self.levelFleetView.selectIds then
		self.contextData.selectedFleetIDs = {}

		for iter_335_0, iter_335_1 in pairs(self.levelFleetView.selectIds) do
			for iter_335_2, iter_335_3 in pairs(iter_335_1) do
				self.contextData.selectedFleetIDs[#self.contextData.selectedFleetIDs + 1] = iter_335_3
			end
		end
	end

	self:destroyChapterPanel()
	self:DestroyLevelInfoSPPanel()
	self:destroyFleetEdit()
	self:destroyCommanderPanel()
	self:DestroyLevelStageView()
	self:hideRepairWindow()
	self:hideStrategyInfo()
	self:hideRemasterPanel()
	self:hideSpResult()
	self:destroyGrid()
	self:destroyAmbushWarn()
	self:destroyAirStrike()
	self:destroyTorpedo()
	self:destroyStrikeAnim()
	self:destroyTracking()
	self:destroyUIAnims()
	self:DestroyChapterAutoDetailPanel()
	PoolMgr.GetInstance():DestroyPrefab("chapter/cell_quad_mark", "")
	PoolMgr.GetInstance():DestroyPrefab("chapter/cell_quad", "")
	PoolMgr.GetInstance():DestroyPrefab("chapter/cell", "")
	PoolMgr.GetInstance():DestroyPrefab("chapter/plane", "")

	for iter_335_4, iter_335_5 in pairs(self.mbDict) do
		iter_335_5:Destroy()
	end

	self.mbDict = nil

	for iter_335_6, iter_335_7 in pairs(self.tweens) do
		LeanTween.cancel(iter_335_7)
	end

	self.tweens = nil

	if self.cloudTimer then
		_.each(self.cloudTimer, function(arg_336_0)
			LeanTween.cancel(arg_336_0)
		end)

		self.cloudTimer = nil
	end

	if self.newChapterCDTimer then
		self.newChapterCDTimer:Stop()

		self.newChapterCDTimer = nil
	end

	for iter_335_8, iter_335_9 in ipairs(self.damageTextActive) do
		LeanTween.cancel(iter_335_9)
	end

	LeanTween.cancel(go(self.avoidText))

	self.map.localScale = Vector3.one
	self.map.pivot = Vector2(0.5, 0.5)
	self.float.localScale = Vector3.one
	self.float.pivot = Vector2(0.5, 0.5)

	for iter_335_10, iter_335_11 in ipairs(self.mapTFs) do
		clearImageSprite(iter_335_11)
	end

	_.each(self.cloudRTFs, function(arg_337_0)
		clearImageSprite(arg_337_0)
	end)
	Destroy(self.enemyTpl)
	self:RecordLastMapOnExit()
	self.levelRemasterView:Destroy()
end

return LevelScene
