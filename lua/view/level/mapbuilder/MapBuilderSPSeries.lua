local MapBuilderSPSeries = class("MapBuilderSPSeries", import(".MapBuilder"))

MapBuilderSPSeries.DISPLAY = {
	STORY = 2,
	BATTLE = 1
}
MapBuilderSPSeries.DIFFICULITY = {
	EASY = 1,
	HARD = 2
}

function MapBuilderSPSeries:GetType()
	return MapBuilder.TYPESPSERIES
end

function MapBuilderSPSeries:getUIName()
	return "LevelSelectSPSeriesUI"
end

function MapBuilderSPSeries:OnLoaded()
	setParent(self._tf, self._parentTf)
	self._tf:SetSiblingIndex(4)
end

function MapBuilderSPSeries:OnInit()
	self.battleLayer = self._tf:Find("Battle")
	self.storyLayer = self._tf:Find("Story")
	self.top = self._tf:Find("Top")
	self.itemHolder = self._tf:Find("Battle/Nodes")
	self.chapterTpl = self.itemHolder:Find("LevelTpl")
	self.storyHolder = self._tf:Find("Story/Nodes")
	self.storyNodeTpl = self.storyHolder:Find("tpl")

	setActive(self.storyNodeTpl, false)

	self.progressText = self._tf:Find("Story/Desc/Text")
	self.storyAward = self._tf:Find("Story/Award")
	self.activeItems = {}
	self.displayChapterIDs = {}
	self.chapterTFsById = {}
	self.storyNodeTFsById = {}

	self:bind(LevelUIConst.SWITCH_SPCHAPTER_DIFFICULTY, function(arg_5_0, arg_5_1)
		self:SwitchChapter(arg_5_1)
	end)
	onButton(self, self.battleLayer:Find("Story/Switch"), function()
		self:SetDisplayMode(MapBuilderSPSeries.DISPLAY.STORY)
	end, SFX_PANEL)
	onButton(self, self.storyLayer:Find("Battle/Switch"), function()
		self:SetDisplayMode(MapBuilderSPSeries.DISPLAY.BATTLE)
	end, SFX_PANEL)
	setText(self.storyLayer:Find("Desc/Desc"), i18n("series_enemy_storyreward"))
end

function MapBuilderSPSeries:OnShow()
	MapBuilderSPSeries.super.OnShow(self)
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), true)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), true)
	setActive(self.sceneParent.topChapter:Find("type_chapter"), true)

	self.needFocusStory = true
end

function MapBuilderSPSeries:UpdateButtons()
	MapBuilderSPSeries.super.UpdateButtons(self)

	local var_9_0, var_9_1 = self.contextData.map:isActivity()
	local var_9_2 = self.contextData.map:isRemaster()
	local var_9_3 = self.contextData.displayMode == MapBuilderSPSeries.DISPLAY.BATTLE

	setActive(self.sceneParent.actExchangeShopBtn, not ActivityConst.HIDE_PT_PANELS and var_9_3 and not var_9_2 and var_9_1 and self.sceneParent:IsActShopActive())

	local var_9_6

	if self.contextData.map then
		var_9_6 = getProxy(ActivityProxy):getActivityById(self.contextData.map:getConfig("on_activity")) or nil
	end

	self.sceneParent:updatePtActivity(var_9_6 and var_9_6:GetConfigClientPTActivity() or nil)

	local var_9_7 = setActive
	local var_9_8 = self.sceneParent.ptTotal

	if not ActivityConst.HIDE_PT_PANELS and not var_9_2 then
		local var_9_9

		if var_9_1 then
			::label_9_0::

			var_9_9 = self.sceneParent.ptActivity
			var_9_9 = self.sceneParent.ptActivity and (not self.sceneParent.ptActivity:isEnd() and var_9_3 or false) or true
		end
	end

	var_9_7(var_9_8, var_9_9)
end

function MapBuilderSPSeries:OnHide()
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), false)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), false)
	setActive(self.sceneParent.topChapter:Find("type_chapter"), false)
	setActive(self.sceneParent.ptTotal, false)
	setActive(self.sceneParent.actExchangeShopBtn, false)
	MapBuilderSPSeries.super.OnHide(self)
end

function MapBuilderSPSeries:UpdateMapVO(arg_11_1)
	MapBuilderSPSeries.super.UpdateMapVO(self, arg_11_1)

	self.activity = getProxy(ActivityProxy):getActivityById(arg_11_1:getConfig("on_activity"))

	local var_11_0 = getProxy(PlayerProxy):getRawData().id

	self.chapterGroups = _.map(arg_11_1:getConfig("chapterGroups"), function(arg_12_0)
		return {
			list = arg_12_0,
			index = PlayerPrefs.GetInt("spchapter_selected_" .. var_11_0 .. "_" .. arg_12_0[1], MapBuilderSPSeries.DIFFICULITY.EASY)
		}
	end)
	self.chapterGroupDict = {}

	_.each(self.chapterGroups, function(arg_13_0)
		_.each(arg_13_0.list, function(arg_14_0)
			self.chapterGroupDict[arg_14_0] = arg_13_0
		end)
	end)

	self.displayChapterIDs = _.map(self.chapterGroups, function(arg_15_0)
		return arg_15_0.list[arg_15_0.index]
	end)
	self.storyNodesDict = {}

	for iter_11_0, iter_11_1 in ipairs(self.activity:getConfig("config_client").storys) do
		self.storyNodesDict[iter_11_1] = BossRushStoryNode.New({
			id = iter_11_1
		})

		local var_11_1 = self.storyHolder:Find(tostring(iter_11_1)) or cloneTplTo(self.storyNodeTpl, self.storyHolder, iter_11_1)
		local var_11_2 = self.storyNodesDict[iter_11_1]:getConfigTable()

		setLocalPosition(var_11_1, {
			x = 1920 * tonumber(var_11_2.pos_x),
			y = 1080 * tonumber(var_11_2.pos_y)
		})
	end
end

function MapBuilderSPSeries:UpdateBonusPtIconPath()
	self.bonusPtIconPath = nil

	local var_16_0 = self.data or self.contextData.map

	if not var_16_0 then
		return
	end

	local var_16_1 = var_16_0:getConfig("on_activity")

	if not var_16_1 or var_16_1 == 0 then
		return
	end

	local var_16_2 = getProxy(ActivityProxy):getActivityById(var_16_1)

	if not var_16_2 or var_16_2:isEnd() then
		return
	end

	local var_16_3 = var_16_2:GetConfigClientPTActivity()

	if not var_16_3 then
		return
	end

	self.bonusPtIconPath = var_16_3:GetPTDrop():getIcon()
end

function MapBuilderSPSeries:SetDisplayMode(arg_17_1)
	if arg_17_1 == self.contextData.displayMode then
		return
	end

	self.contextData.displayMode = arg_17_1

	self:UpdateView()
end

function MapBuilderSPSeries:UpdateView()
	local var_18_0 = string.split(self.contextData.map:getConfig("name"), "||")

	if self.contextData.displayMode == MapBuilderSPSeries.DISPLAY.STORY then
		var_18_0 = string.split(var_18_0[1], "·")

		setText(self.sceneParent.chapterName, var_18_0[1] .. i18n("levelscene_title_story"))
	else
		setText(self.sceneParent.chapterName, var_18_0[1])
	end

	self.sceneParent.loader:GetSpriteQuiet("chapterno", "chapter" .. self.contextData.map:getMapTitleNumber(), self.sceneParent.chapterNoTitle, true)

	self.contextData.displayMode = self.contextData.displayMode or MapBuilderSPSeries.DISPLAY.BATTLE

	MapBuilderSPSeries.super.UpdateView(self)

	local var_18_1 = self.contextData.displayMode == MapBuilderSPSeries.DISPLAY.BATTLE

	setActive(self._tf:Find("Battle"), self.contextData.displayMode == MapBuilderSPSeries.DISPLAY.BATTLE)
	setActive(self._tf:Find("Story"), not var_18_1)

	local var_18_2 = getProxy(ChapterProxy):IsActivitySPChapterActive(self.contextData.map:getConfig("on_activity"))

	var_18_2 = var_18_2 and SettingsProxy.IsShowActivityMapSPTip()

	setActive(self.battleLayer:Find("Story/BattleTip"), false)
	setActive(self.storyLayer:Find("Battle/BattleTip"), var_18_2)
	self:UpdateStoryTask()

	if var_18_1 then
		self:UpdateBonusPtIconPath()
		self:UpdateBattle()
		self.sceneParent:SwitchMapBG(self.contextData.map)
		self.sceneParent:PlayBGM()
	else
		self:UpdateStory()
		self:SwitchStoryMapAndBGM()
	end

	self:TrySubmitTask()
end

function MapBuilderSPSeries:UpdateBattle()
	local var_19_0 = getProxy(ChapterProxy)
	local var_19_1 = {}

	for iter_19_0, iter_19_1 in ipairs(self.displayChapterIDs) do
		table.insert(var_19_1, (var_19_0:getChapterById(iter_19_1)))
	end

	table.clear(self.chapterTFsById)
	UIItemList.StaticAlign(self.itemHolder, self.chapterTpl, #var_19_1, function(arg_20_0, arg_20_1, arg_20_2)
		if arg_20_0 ~= UIItemList.EventUpdate then
			return
		end

		local var_20_0 = var_19_1[arg_20_1 + 1]

		self:UpdateMapItem(arg_20_2, var_19_1[arg_20_1 + 1])

		arg_20_2.name = "Chapter_" .. var_20_0.id
		self.chapterTFsById[var_20_0.id] = arg_20_2
	end)
end

function MapBuilderSPSeries:HideFloat()
	MapBuilderSPSeries.super.HideFloat(self)
	setActive(self.itemHolder, false)
end

function MapBuilderSPSeries:ShowFloat()
	MapBuilderSPSeries.super.ShowFloat(self)
	setActive(self.itemHolder, true)
end

function MapBuilderSPSeries:UpdateMapItem(arg_23_1, arg_23_2)
	local var_23_0 = arg_23_2:getConfigTable()

	setLocalPosition(arg_23_1, {
		x = 1920 * var_23_0.pos_x,
		y = 1080 * var_23_0.pos_y
	})

	local var_23_1 = findTF(arg_23_1, "main")

	setActive(var_23_1, true)

	local var_23_2 = findTF(var_23_1, "info/bk/fordark")

	setActive(findTF(var_23_1, "circle/fordark"), var_23_0.icon_outline == 1)
	setActive(var_23_2, var_23_0.icon_outline == 1)

	local var_23_3 = self.chapterGroupDict[arg_23_2.id]

	assert(self.chapterGroupDict[arg_23_2.id])

	local var_23_4 = {
		"Lock",
		"Normal",
		"Hard"
	}
	local var_23_5 = 1

	if arg_23_2:isUnlock() then
		var_23_5 = 2

		if #self.chapterGroupDict[arg_23_2.id].list > 1 then
			var_23_5 = table.indexof(self.chapterGroupDict[arg_23_2.id].list, arg_23_2.id) + 1
		elseif arg_23_2:IsSpChapter() or arg_23_2:IsEXChapter() then
			var_23_5 = 3
		elseif self.contextData.map:isHardMap() then
			var_23_5 = 3
		end
	end

	local var_23_6 = findTF(var_23_1, "circle/bk")

	for iter_23_0, iter_23_1 in ipairs(var_23_4) do
		setActive(var_23_6:Find(iter_23_1), iter_23_0 == var_23_5)
	end

	local var_23_7 = findTF(var_23_1, "circle/clear_flag")
	local var_23_8 = findTF(var_23_1, "circle/lock")
	local var_23_9 = findTF(var_23_1, "circle/progress_text")
	local var_23_10 = findTF(var_23_1, "circle/stars")
	local var_23_11 = string.split(var_23_0.name, "|")

	setText(findTF(var_23_1, "info/bk/title_form/title_index"), var_23_0.chapter_name .. "  ")
	setText(findTF(var_23_1, "info/bk/title_form/title"), var_23_11[1])
	setText(findTF(var_23_1, "info/bk/title_form/title_en"), var_23_11[2] or "")
	setFillAmount(findTF(var_23_1, "circle/progress"), arg_23_2.progress / 100)
	setText(var_23_9, string.format("%d%%", arg_23_2.progress))
	setActive(var_23_10, arg_23_2:existAchieve())

	if arg_23_2:existAchieve() then
		for iter_23_2, iter_23_3 in ipairs(arg_23_2.achieves) do
			local var_23_12 = var_23_10:GetChild(iter_23_2 - 1):Find("light")

			setActive(var_23_12, (ChapterConst.IsAchieved(iter_23_3)))

			for iter_23_4, iter_23_5 in ipairs(var_23_4) do
				if iter_23_5 ~= "Lock" then
					setActive(var_23_12:Find(iter_23_5), iter_23_4 == var_23_5)
				end
			end
		end
	end

	local var_23_13 = findTF(var_23_1, "info/bk/BG")

	for iter_23_6, iter_23_7 in ipairs(var_23_4) do
		setActive(var_23_13:Find(iter_23_7), iter_23_6 == var_23_5)
	end

	setActive(findTF(var_23_1, "HardEffect"), var_23_5 == 3)

	local var_23_14 = not arg_23_2.active and arg_23_2:isClear()
	local var_23_15 = not arg_23_2.active and not arg_23_2:isUnlock()

	setActive(var_23_7, var_23_14)
	setActive(var_23_8, var_23_15)
	setActive(var_23_9, not var_23_14 and not var_23_15)
	self:DeleteTween("fighting" .. arg_23_2.id)

	local var_23_16 = findTF(var_23_1, "circle/fighting")

	setText(findTF(var_23_16, "Text"), i18n("tag_level_fighting"))

	local var_23_17 = findTF(var_23_1, "circle/oni")

	setText(findTF(var_23_17, "Text"), i18n("tag_level_oni"))

	local var_23_18 = findTF(var_23_1, "circle/narrative")

	setText(findTF(var_23_18, "Text"), i18n("tag_level_narrative"))

	local var_23_19 = findTF(var_23_1, "circle/auto")

	setText(findTF(var_23_19, "Text"), i18n("tag_level_autoing"))
	setActive(var_23_16, false)
	setActive(var_23_17, false)
	setActive(var_23_18, false)
	setActive(var_23_19, false)

	local var_23_20

	if arg_23_2:getConfig("chapter_tag") == 1 then
		var_23_20 = var_23_18
	end

	if arg_23_2.active then
		var_23_20 = arg_23_2:existOni() and var_23_17 or var_23_16
	end

	local var_23_22 = getProxy(ChapterProxy):GetAutoChapterId()

	warning(var_23_22 and var_23_22 == arg_23_2.id)

	if var_23_22 and var_23_22 == arg_23_2.id then
		var_23_20 = var_23_19

		local var_23_23, var_23_24 = getProxy(ChapterAutoProxy):GetCntInfo()

		setText(findTF(var_23_19, "Text"), var_23_23 < var_23_24 and i18n("tag_level_autoing") or i18n("tag_level_auto_finish"))
	end

	if var_23_20 then
		setActive(var_23_20, true)

		local var_23_25 = GetOrAddComponent(var_23_20, "CanvasGroup")

		var_23_25.alpha = 1

		self:RecordTween("fighting" .. arg_23_2.id, LeanTween.alphaCanvas(var_23_25, 0, 0.5):setFrom(1):setEase(LeanTweenType.easeInOutSine):setLoopPingPong().uniqueId)
	end

	local var_23_26 = findTF(var_23_1, "triesLimit")
	local var_23_27 = arg_23_2:isTriesLimit()

	setActive(var_23_26, var_23_27)

	if var_23_27 then
		local var_23_28 = arg_23_2:getConfig("count")

		setText(var_23_26:Find("label"), i18n("levelScene_chapter_count_tip"))

		local var_23_29 = setText

		var_23_29(var_23_26:Find("Text"), setColorStr(var_23_28 - arg_23_2:getTodayDefeatCount() .. "/" .. var_23_28, (var_23_28 <= arg_23_2:getTodayDefeatCount() or nil) and (COLOR_RED or COLOR_GREEN)))

		local var_23_33 = getProxy(ChapterProxy):IsActivitySPChapterActive(pg.expedition_data_by_map[arg_23_2:getConfig("map")].on_activity)

		var_23_33 = var_23_33 and SettingsProxy.IsShowActivityMapSPTip()

		setActive(var_23_26:Find("TipRect"), var_23_33)
	end

	local var_23_34 = arg_23_2:GetDailyBonusQuota()
	local var_23_35 = findTF(var_23_1, "mark")
	local var_23_36 = var_23_35:Find("bonus")
	local var_23_37 = var_23_36:Find("icon")
	local var_23_38 = findTF(var_23_36, "icon/Image")

	setActive(var_23_36, var_23_34)
	setActive(var_23_35, var_23_34)

	if var_23_37 then
		setActive(var_23_37, var_23_34 and self.bonusPtIconPath)
	end

	if var_23_34 then
		local var_23_39 = var_23_35:GetComponent(typeof(CanvasGroup))

		self.sceneParent.loader:GetSprite("ui/levelmainscene_atlas", arg_23_2:GetDailyBonusIconName(), var_23_36)

		if var_23_37 and self.bonusPtIconPath then
			if var_23_38 then
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_23_38, true)
			else
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_23_37, true)
			end
		end

		LeanTween.cancel(go(var_23_35), true)

		local var_23_40 = var_23_35.anchoredPosition.y

		var_23_39.alpha = 0

		LeanTween.value(go(var_23_35), 0, 1, 0.2):setOnUpdate(System.Action_float(function(arg_24_0)
			var_23_39.alpha = arg_24_0
			var_23_35.anchoredPosition.y = var_23_40 * arg_24_0
			var_23_35.anchoredPosition = var_23_35.anchoredPosition
		end)):setOnComplete(System.Action(function()
			var_23_39.alpha = 1
			var_23_35.anchoredPosition.y = var_23_40
			var_23_35.anchoredPosition = var_23_35.anchoredPosition
		end)):setEase(LeanTweenType.easeOutSine):setDelay(0.7)
	end

	local var_23_41 = arg_23_2.id

	onButton(self, var_23_1, function()
		self:TryOpenChapterInfo(var_23_41, nil, var_23_3.list)
	end, SFX_UI_WEIGHANCHOR_SELECT)
	self:PlayerLevelTplAnimation(arg_23_1, {
		status = var_23_4[var_23_5],
		chapterVO = arg_23_2
	})
end

function MapBuilderSPSeries:PlayerLevelTplAnimation(arg_27_1, arg_27_2)
	return
end

function MapBuilderSPSeries:SwitchChapter(arg_28_1)
	if not self.chapterGroupDict[arg_28_1] then
		return
	end

	local var_28_0 = self.chapterGroupDict[arg_28_1].list[self.chapterGroupDict[arg_28_1].index]

	if self.chapterGroupDict[arg_28_1].list[self.chapterGroupDict[arg_28_1].index] == arg_28_1 then
		return
	end

	local var_28_1 = table.indexof(self.chapterGroupDict[arg_28_1].list, arg_28_1)

	self.chapterGroupDict[arg_28_1].index = var_28_1

	PlayerPrefs.SetInt("spchapter_selected_" .. getProxy(PlayerProxy):getRawData().id .. "_" .. self.chapterGroupDict[arg_28_1].list[1], var_28_1)

	self.chapterTFsById[var_28_0] = nil
	self.chapterTFsById[arg_28_1] = self.chapterTFsById[var_28_0]

	self:UpdateChapterTF(arg_28_1)
end

function MapBuilderSPSeries:UpdateChapterTF(arg_29_1)
	if not self.chapterGroupDict[arg_29_1] then
		return
	end

	if self.chapterTFsById[arg_29_1] then
		self:UpdateMapItem(self.chapterTFsById[arg_29_1], (getProxy(ChapterProxy):getChapterById(arg_29_1)))
	end
end

function MapBuilderSPSeries:UpdateStory()
	local var_30_1 = pg.NewStoryMgr.GetInstance()
	local var_30_2 = 0
	local var_30_3 = 0

	for iter_30_0, iter_30_1 in pairs(self.storyNodesDict) do
		local var_30_4 = self.storyHolder:Find(tostring(iter_30_1.id))

		setActive(var_30_4, (iter_30_1:IsActive(self.activity, self.sceneParent.ptActivity)))
		setText(var_30_4:Find("main/char/bg/Text"), iter_30_1:GetName())

		local var_30_5 = iter_30_1:IsReaded()

		setActive(var_30_4:Find("main/char"), not var_30_5)
		setActive(var_30_4:Find("main/talk"), var_30_5)
		onButton(self, var_30_4, function()
			if var_30_5 then
				return
			end

			self:PlayStory(iter_30_1:GetStory(), function()
				self:UpdateView()
			end)
		end)

		var_30_2 = var_30_2 + (var_30_5 and 1 or 0)
		var_30_3 = var_30_3 + 1
	end

	setText(self.progressText, var_30_2 .. "/" .. var_30_3)
	setActive(self.storyAward, tobool(self.storyTask))

	if self.storyTask then
		local var_30_6 = Drop.Create(self.storyTask:getConfig("award_display")[1])

		updateDrop(self.storyAward:GetChild(0), var_30_6)

		local var_30_7 = self.storyTask:getTaskStatus()

		setActive(self.storyAward:Find("get"), var_30_7 == 1)
		setActive(self.storyAward:Find("got"), var_30_7 == 2)
		onButton(self, self.storyAward, function()
			self:emit(BaseUI.ON_DROP, var_30_6)
		end)
	end
end

function MapBuilderSPSeries:SwitchStoryMapAndBGM()
	local var_34_0 = self.data:getConfig("default_background")
	local var_34_1 = self.data:getConfig("default_bgm")
	local var_34_2
	local var_34_3 = underscore.keys(self.storyNodesDict)

	table.sort(var_34_3)

	for iter_34_0 = 1, #var_34_3 do
		if self.storyNodesDict[var_34_3[iter_34_0]]:IsReaded() then
			var_34_0 = defaultValue(self.storyNodesDict[var_34_3[iter_34_0]]:GetCleanBG(), var_34_0)
			var_34_1 = defaultValue(self.storyNodesDict[var_34_3[iter_34_0]]:GetCleanBGM(), var_34_1)
			var_34_2 = defaultValue(self.storyNodesDict[var_34_3[iter_34_0]]:GetCleanAnimator(), var_34_2)
		else
			break
		end
	end

	self.sceneParent:SwitchBG({
		{
			bgPrefix = "bg",
			BG = var_34_0,
			Animator = var_34_2
		}
	})
	pg.BgmMgr.GetInstance():Push(self.__cname, var_34_1)
end

function MapBuilderSPSeries:TrySubmitTask()
	if underscore.all(underscore.values(self.storyNodesDict), function(arg_36_0)
		return arg_36_0:IsReaded()
	end) and self.storyTask and self.storyTask:getTaskStatus() == 1 then
		self:emit(LevelMediator2.ON_SUBMIT_TASK, self.storyTask.id)

		return
	end
end

function MapBuilderSPSeries:TryOpenChapter(arg_37_1)
	if self.chapterTFsById[arg_37_1] then
		triggerButton((self.chapterTFsById[arg_37_1]:Find("main")))
	end
end

function MapBuilderSPSeries:PlayStory(arg_38_1, arg_38_2, arg_38_3)
	if not arg_38_1 then
		return existCall(arg_38_2)
	end

	local var_38_0 = pg.NewStoryMgr.GetInstance()
	local var_38_1 = var_38_0:IsPlayed(arg_38_1)

	seriesAsync({
		function(arg_39_0)
			if var_38_1 and not arg_38_3 then
				return arg_39_0()
			end

			local var_39_0 = tonumber(arg_38_1)

			if var_39_0 and var_39_0 > 0 then
				self:emit(LevelMediator2.ON_PERFORM_COMBAT, var_39_0, nil, var_38_1)
			else
				var_38_0:Play(arg_38_1, arg_39_0, arg_38_3)
			end
		end,
		function(arg_40_0, ...)
			existCall(arg_38_2, ...)
		end
	})
end

function MapBuilderSPSeries:UpdateStoryTask()
	local var_41_0 = self.activity:getConfig("config_client").task_id
	local var_41_1 = getProxy(TaskProxy):getTaskVO(var_41_0)

	if not var_41_1 then
		errorMsg("Missing Activity Task ID : " .. var_41_0)
	end

	print(var_41_0)

	self.storyTask = var_41_1 or Task.New({
		id = var_41_0
	})
end

function MapBuilderSPSeries:OnSubmitTaskDone()
	self:UpdateView()
end

function MapBuilderSPSeries:OnDestroy()
	return
end

return MapBuilderSPSeries
