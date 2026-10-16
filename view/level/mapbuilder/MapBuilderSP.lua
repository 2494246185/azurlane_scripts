local MapBuilderSP = class("MapBuilderSP", import(".MapBuilder"))
local PoolPlural = import("Mgr/Pool/PoolPlural")

MapBuilderSP.DISPLAY = {
	STORY = 2,
	BATTLE = 1
}
MapBuilderSP.DIFFICULITY = {
	EASY = 1,
	HARD = 2
}

function MapBuilderSP:GetType()
	return MapBuilder.TYPESP
end

function MapBuilderSP:getUIName()
	return "LevelSelectSPUI"
end

function MapBuilderSP:OnLoaded()
	setParent(self._tf, self._parentTf)
	self._tf:SetSiblingIndex(4)
end

function MapBuilderSP:OnInit()
	self.battleLayer = self._tf:Find("Battle")
	self.storyLayer = self._tf:Find("Story")
	self.top = self._tf:Find("Top")
	self.itemHolder = self._tf:Find("Battle/Nodes")
	self.chapterTpl = self.itemHolder:Find("LevelTpl")
	self.storyHolder = self._tf:Find("Story/Nodes")
	self.storyContainer = self.storyHolder:Find("Viewport/Content")
	self.nodes = {}
	self.progressText = self._tf:Find("Story/Desc/Text")
	self.storyAward = self._tf:Find("Story/Award")
	self.storyNodeTpl = self._tf:Find("Story/NodeTemplate")
	self.oneLineTpl = self._tf:Find("Story/OneLine")
	self.branchHeadTpl = self._tf:Find("Story/BranchHead")
	self.branchCenterTpl = self._tf:Find("Story/BranchCenter")
	self.branchUpTpl = self._tf:Find("Story/BranchUp")
	self.branchDownTpl = self._tf:Find("Story/BranchDown")
	self.unionTailTpl = self._tf:Find("Story/UnionTail")
	self.unionCenterTpl = self._tf:Find("Story/UnionCenter")
	self.unionUpTpl = self._tf:Find("Story/UnionUp")
	self.unionDownTpl = self._tf:Find("Story/UnionDown")
	self.unreleasedNodeTpl = self._tf:Find("Story/UnreleasedNode")

	setActive(self.storyNodeTpl, false)
	setActive(self.oneLineTpl, false)
	setActive(self.branchHeadTpl, false)
	setActive(self.branchCenterTpl, false)
	setActive(self.branchUpTpl, false)
	setActive(self.branchDownTpl, false)
	setActive(self.unionTailTpl, false)
	setActive(self.unionCenterTpl, false)
	setActive(self.unionUpTpl, false)
	setActive(self.unionDownTpl, false)
	setActive(self.unreleasedNodeTpl, false)

	self.pools = {
		[self.storyNodeTpl] = PoolPlural.New(go(self.storyNodeTpl), 0),
		[self.oneLineTpl] = PoolPlural.New(go(self.oneLineTpl), 0),
		[self.branchHeadTpl] = PoolPlural.New(go(self.branchHeadTpl), 0),
		[self.branchCenterTpl] = PoolPlural.New(go(self.branchCenterTpl), 0),
		[self.branchUpTpl] = PoolPlural.New(go(self.branchUpTpl), 0),
		[self.branchDownTpl] = PoolPlural.New(go(self.branchDownTpl), 0),
		[self.unionTailTpl] = PoolPlural.New(go(self.unionTailTpl), 0),
		[self.unionCenterTpl] = PoolPlural.New(go(self.unionCenterTpl), 0),
		[self.unionUpTpl] = PoolPlural.New(go(self.unionUpTpl), 0),
		[self.unionDownTpl] = PoolPlural.New(go(self.unionDownTpl), 0)
	}
	self.nodeTplWidth = self.storyNodeTpl.rect.width
	self.oneLineWidth = self.oneLineTpl.rect.width
	self.oneLineHeight = self.oneLineTpl.rect.height
	self.branchHeadWidth = self.branchHeadTpl.rect.width
	self.branchUpWidth = self.branchUpTpl.rect.width
	self.branchUpHeight = self.branchUpTpl.rect.height
	self.UnionTailWidth = self.unionTailTpl.rect.width
	self.activeItems = {}
	self.displayChapterIDs = {}
	self.chapterTFsById = {}
	self.storyNodeTFsById = {}

	self:bind(LevelUIConst.SWITCH_SPCHAPTER_DIFFICULTY, function(arg_5_0, arg_5_1)
		self:SwitchChapter(arg_5_1)
	end)
	onButton(self, self.battleLayer:Find("Mask/Story/Switch"), function()
		self:SetDisplayMode(MapBuilderSP.DISPLAY.STORY)

		self.needFocusStory = true

		self:Move2UnlockStory()
	end, SFX_PANEL)
	onButton(self, self.storyLayer:Find("Battle/Switch"), function()
		self:SetDisplayMode(MapBuilderSP.DISPLAY.BATTLE)
	end, SFX_PANEL)
	setText(self.storyLayer:Find("Desc/Desc"), i18n("series_enemy_storyreward"))
end

function MapBuilderSP:OnShow()
	MapBuilderSP.super.OnShow(self)
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), true)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), true)
	setActive(self.sceneParent.topChapter:Find("type_chapter"), true)

	self.needFocusStory = true
end

function MapBuilderSP:UpdateButtons()
	MapBuilderSP.super.UpdateButtons(self)

	local var_9_0, var_9_1 = self.contextData.map:isActivity()
	local var_9_2 = self.contextData.map:isRemaster()

	if var_9_2 then
		self.sceneParent:updateRemasterInfo()
	end

	local var_9_3 = self.contextData.displayMode == MapBuilderSP.DISPLAY.BATTLE

	setActive(self.sceneParent.actExchangeShopBtn, not ActivityConst.HIDE_PT_PANELS and var_9_3 and not var_9_2 and var_9_1 and self.sceneParent:IsActShopActive())

	local var_9_6

	if self.contextData.map then
		var_9_6 = getProxy(ActivityProxy):getActivityById(self.contextData.map:getConfig("on_activity")) or nil
	end

	self.sceneParent:updatePtActivity(var_9_6 and var_9_6:GetConfigClientPTActivity() or nil)
	setActive(self.sceneParent.rightChapter:Find("event_btns/tickets"), var_9_2)
	self.sceneParent:updateRemasterTicket()

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

function MapBuilderSP:OnHide()
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), false)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), false)
	setActive(self.sceneParent.topChapter:Find("type_chapter"), false)
	setActive(self.sceneParent.ptTotal, false)
	setActive(self.sceneParent.actExchangeShopBtn, false)
	MapBuilderSP.super.OnHide(self)
end

function MapBuilderSP:UpdateMapVO(arg_11_1)
	MapBuilderSP.super.UpdateMapVO(self, arg_11_1)

	self.activity = getProxy(ActivityProxy):getActivityById(arg_11_1:getConfig("on_activity"))

	local var_11_0 = getProxy(PlayerProxy):getRawData().id

	self.chapterGroups = _.map(arg_11_1:getConfig("chapterGroups"), function(arg_12_0)
		return {
			list = arg_12_0,
			index = PlayerPrefs.GetInt("spchapter_selected_" .. var_11_0 .. "_" .. arg_12_0[1], MapBuilderSP.DIFFICULITY.EASY)
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

	self:BuildStoryTree()
end

function MapBuilderSP:UpdateBonusPtIconPath()
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

function MapBuilderSP:BuildStoryTree()
	self.spStoryIDs = self.data:getConfig("story_id")
	self.spStoryNodeDict = {}
	self.spStoryNodes = {}
	self.spStoryUnreleasedNode = nil

	local var_17_0 = {}

	_.each(self.spStoryIDs, function(arg_18_0)
		local var_18_0 = ActivitySpStoryNode.New({
			configId = arg_18_0
		})

		if var_18_0:GetType() ~= ActivitySpStoryNode.NODE_TYPE.UNRELEASED then
			self.spStoryNodeDict[arg_18_0] = var_18_0

			local var_18_1 = var_17_0[self.spStoryNodeDict[arg_18_0]:GetPreEvent()] or {}

			table.insert(var_18_1, arg_18_0)

			var_17_0[self.spStoryNodeDict[arg_18_0]:GetPreEvent()] = var_18_1
		else
			self.spStoryUnreleasedNode = var_18_0
		end
	end)

	local var_17_1 = 0

	while (function()
		if not var_17_0[var_17_1] then
			return
		end

		tailList = var_17_0[var_17_1]

		local var_19_0

		_.each(tailList, function(arg_20_0)
			table.insert(self.spStoryNodes, self.spStoryNodeDict[arg_20_0])

			if var_17_0[arg_20_0] then
				var_19_0 = true
				var_17_1 = arg_20_0
			end
		end)

		return nil
	end)() do
		-- block empty
	end

	local var_17_2 = {}
	local var_17_3

	_.each(self.spStoryNodes, function(arg_21_0)
		local var_21_0 = arg_21_0:GetPreNodes()

		if #var_21_0 == 0 then
			var_17_3 = arg_21_0

			return
		end

		_.each(var_21_0, function(arg_22_0)
			var_17_2[arg_22_0] = var_17_2[arg_22_0] or {}

			table.insert(var_17_2[arg_22_0], arg_21_0)
		end)
	end)

	self.storyTree = {
		root = nil,
		childDict = var_17_2
	}
end

function MapBuilderSP:SetDisplayMode(arg_23_1)
	if arg_23_1 == self.contextData.displayMode then
		return
	end

	self.contextData.displayMode = arg_23_1

	self:UpdateView()
end

function MapBuilderSP:UpdateView()
	local var_24_0 = self.contextData.map
	local var_24_1 = string.split(self.contextData.map:getConfig("name"), "||")

	if self.contextData.displayMode == MapBuilderSP.DISPLAY.STORY then
		var_24_1 = string.split(var_24_1[1], "·")

		setText(self.sceneParent.chapterName, var_24_1[1] .. i18n("levelscene_title_story"))
	else
		setText(self.sceneParent.chapterName, var_24_1[1])
	end

	self.sceneParent.loader:GetSpriteQuiet("chapterno", "chapter" .. var_24_0:getMapTitleNumber(), self.sceneParent.chapterNoTitle, true)

	self.contextData.displayMode = self.contextData.displayMode or MapBuilderSP.DISPLAY.BATTLE

	MapBuilderSP.super.UpdateView(self)

	local var_24_2 = self.contextData.displayMode == MapBuilderSP.DISPLAY.BATTLE

	setActive(self._tf:Find("Battle"), self.contextData.displayMode == MapBuilderSP.DISPLAY.BATTLE)
	setActive(self._tf:Find("Story"), not var_24_2)

	local var_24_3 = getProxy(ChapterProxy):IsActivitySPChapterActive(var_24_0:getConfig("on_activity"))

	var_24_3 = var_24_3 and SettingsProxy.IsShowActivityMapSPTip()

	setActive(self.battleLayer:Find("Mask/Story/BattleTip"), false)
	setActive(self.storyLayer:Find("Battle/BattleTip"), var_24_3)

	if type(self.spStoryIDs) ~= "table" or #self.spStoryIDs == 0 then
		local var_24_4 = var_24_0:isRemaster()

		if var_24_4 then
			setActive(self.battleLayer:Find("Mask"), false)

			local var_24_5, var_24_6 = var_24_0:isActivity()

			setActive(self.sceneParent.remasterBtn, OPEN_REMASTER and (var_24_4 or not var_24_5 and not var_24_0:isEscort() and not var_24_0:isSkirmish()))
		else
			self.battleLayer:Find("Mask"):GetComponent(typeof(RectMask2D)).enabled = true
		end
	end

	self:UpdateStoryTask()

	if var_24_2 then
		self:UpdateBonusPtIconPath()
		self:UpdateBattle()
		self.sceneParent:SwitchMapBG(self.contextData.map)
		self.sceneParent:PlayBGM()
	else
		self:UpdateStoryNodeStatus()
		self:UpdateStory()
		self:Move2UnlockStory()
		self:SwitchStoryMapAndBGM()
	end

	self:TrySubmitTask()
end

function MapBuilderSP:UpdateBattle()
	local var_25_0 = getProxy(ChapterProxy)
	local var_25_1 = {}

	for iter_25_0, iter_25_1 in ipairs(self.displayChapterIDs) do
		table.insert(var_25_1, (var_25_0:getChapterById(iter_25_1)))
	end

	table.clear(self.chapterTFsById)
	UIItemList.StaticAlign(self.itemHolder, self.chapterTpl, #var_25_1, function(arg_26_0, arg_26_1, arg_26_2)
		if arg_26_0 ~= UIItemList.EventUpdate then
			return
		end

		local var_26_0 = var_25_1[arg_26_1 + 1]

		self:UpdateMapItem(arg_26_2, var_25_1[arg_26_1 + 1])

		arg_26_2.name = "Chapter_" .. var_26_0.id
		self.chapterTFsById[var_26_0.id] = arg_26_2
	end)
end

function MapBuilderSP:HideFloat()
	MapBuilderSP.super.HideFloat(self)
	setActive(self.itemHolder, false)
end

function MapBuilderSP:ShowFloat()
	MapBuilderSP.super.ShowFloat(self)
	setActive(self.itemHolder, true)
end

function MapBuilderSP:UpdateMapItem(arg_29_1, arg_29_2)
	local var_29_0 = arg_29_2:getConfigTable()

	setLocalPosition(arg_29_1, {
		x = 1920 * var_29_0.pos_x,
		y = 1080 * var_29_0.pos_y
	})

	local var_29_1 = findTF(arg_29_1, "main")

	setActive(var_29_1, true)

	local var_29_2 = findTF(var_29_1, "info/bk/fordark")

	setActive(findTF(var_29_1, "circle/fordark"), var_29_0.icon_outline == 1)
	setActive(var_29_2, var_29_0.icon_outline == 1)

	local var_29_3 = self.chapterGroupDict[arg_29_2.id]

	assert(self.chapterGroupDict[arg_29_2.id])

	local var_29_4 = {
		"Lock",
		"Normal",
		"Hard"
	}
	local var_29_5 = 1

	if arg_29_2:isUnlock() then
		var_29_5 = 2

		if #self.chapterGroupDict[arg_29_2.id].list > 1 then
			var_29_5 = table.indexof(self.chapterGroupDict[arg_29_2.id].list, arg_29_2.id) + 1
		elseif arg_29_2:IsSpChapter() or arg_29_2:IsEXChapter() then
			var_29_5 = 3
		elseif self.contextData.map:isHardMap() then
			var_29_5 = 3
		end
	end

	local var_29_6 = findTF(var_29_1, "circle/bk")

	for iter_29_0, iter_29_1 in ipairs(var_29_4) do
		setActive(var_29_6:Find(iter_29_1), iter_29_0 == var_29_5)
	end

	local var_29_7 = findTF(var_29_1, "circle/clear_flag")
	local var_29_8 = findTF(var_29_1, "circle/lock")
	local var_29_9 = findTF(var_29_1, "circle/progress_text")
	local var_29_10 = findTF(var_29_1, "circle/stars")
	local var_29_11 = string.split(var_29_0.name, "|")

	setText(findTF(var_29_1, "info/bk/title_form/title_index"), var_29_0.chapter_name .. "  ")
	setText(findTF(var_29_1, "info/bk/title_form/title"), var_29_11[1])
	setText(findTF(var_29_1, "info/bk/title_form/title_en"), var_29_11[2] or "")
	setFillAmount(findTF(var_29_1, "circle/progress"), arg_29_2.progress / 100)
	setText(var_29_9, string.format("%d%%", arg_29_2.progress))
	setActive(var_29_10, arg_29_2:existAchieve())

	if arg_29_2:existAchieve() then
		for iter_29_2, iter_29_3 in ipairs(arg_29_2.achieves) do
			local var_29_12 = var_29_10:GetChild(iter_29_2 - 1):Find("light")

			setActive(var_29_12, (ChapterConst.IsAchieved(iter_29_3)))

			for iter_29_4, iter_29_5 in ipairs(var_29_4) do
				if iter_29_5 ~= "Lock" then
					setActive(var_29_12:Find(iter_29_5), iter_29_4 == var_29_5)
				end
			end
		end
	end

	local var_29_13 = findTF(var_29_1, "info/bk/BG")

	for iter_29_6, iter_29_7 in ipairs(var_29_4) do
		setActive(var_29_13:Find(iter_29_7), iter_29_6 == var_29_5)
	end

	setActive(findTF(var_29_1, "HardEffect"), var_29_5 == 3)

	local var_29_14 = not arg_29_2.active and arg_29_2:isClear()
	local var_29_15 = not arg_29_2.active and not arg_29_2:isUnlock()

	setActive(var_29_7, var_29_14)
	setActive(var_29_8, var_29_15)
	setActive(var_29_9, not var_29_14 and not var_29_15)
	self:DeleteTween("fighting" .. arg_29_2.id)

	local var_29_16 = findTF(var_29_1, "circle/fighting")

	setText(findTF(var_29_16, "Text"), i18n("tag_level_fighting"))

	local var_29_17 = findTF(var_29_1, "circle/oni")

	setText(findTF(var_29_17, "Text"), i18n("tag_level_oni"))

	local var_29_18 = findTF(var_29_1, "circle/narrative")

	setText(findTF(var_29_18, "Text"), i18n("tag_level_narrative"))

	local var_29_19 = findTF(var_29_1, "circle/auto")

	setText(findTF(var_29_19, "Text"), i18n("tag_level_autoing"))
	setActive(var_29_16, false)
	setActive(var_29_17, false)
	setActive(var_29_18, false)
	setActive(var_29_19, false)

	local var_29_20

	if arg_29_2:getConfig("chapter_tag") == 1 then
		var_29_20 = var_29_18
	end

	if arg_29_2.active then
		var_29_20 = arg_29_2:existOni() and var_29_17 or var_29_16
	end

	local var_29_22 = getProxy(ChapterProxy):GetAutoChapterId()

	if var_29_22 and var_29_22 == arg_29_2.id then
		var_29_20 = var_29_19

		local var_29_23, var_29_24 = getProxy(ChapterAutoProxy):GetCntInfo()

		setText(findTF(var_29_19, "Text"), var_29_23 < var_29_24 and i18n("tag_level_autoing") or i18n("tag_level_auto_finish"))
	end

	if var_29_20 then
		setActive(var_29_20, true)

		local var_29_25 = GetOrAddComponent(var_29_20, "CanvasGroup")

		var_29_25.alpha = 1

		self:RecordTween("fighting" .. arg_29_2.id, LeanTween.alphaCanvas(var_29_25, 0, 0.5):setFrom(1):setEase(LeanTweenType.easeInOutSine):setLoopPingPong().uniqueId)
	end

	local var_29_26 = findTF(var_29_1, "triesLimit")
	local var_29_27 = arg_29_2:isTriesLimit()

	setActive(var_29_26, var_29_27)

	if var_29_27 then
		local var_29_28 = arg_29_2:getConfig("count")

		setText(var_29_26:Find("label"), i18n("levelScene_chapter_count_tip"))

		local var_29_29 = setText

		var_29_29(var_29_26:Find("Text"), setColorStr(var_29_28 - arg_29_2:getTodayDefeatCount() .. "/" .. var_29_28, (var_29_28 <= arg_29_2:getTodayDefeatCount() or nil) and (COLOR_RED or COLOR_GREEN)))

		local var_29_33 = getProxy(ChapterProxy):IsActivitySPChapterActive(pg.expedition_data_by_map[arg_29_2:getConfig("map")].on_activity)

		var_29_33 = var_29_33 and SettingsProxy.IsShowActivityMapSPTip()

		setActive(var_29_26:Find("TipRect"), var_29_33)
	end

	local var_29_34 = arg_29_2:GetDailyBonusQuota()
	local var_29_35 = findTF(var_29_1, "mark")
	local var_29_36 = var_29_35:Find("bonus")
	local var_29_37 = var_29_36:Find("icon")
	local var_29_38 = findTF(var_29_36, "icon/Image")

	setActive(var_29_36, var_29_34)
	setActive(var_29_35, var_29_34)

	if var_29_37 then
		setActive(var_29_37, var_29_34 and self.bonusPtIconPath)
	end

	if var_29_34 then
		local var_29_39 = var_29_35:GetComponent(typeof(CanvasGroup))

		self.sceneParent.loader:GetSprite("ui/levelmainscene_atlas", arg_29_2:GetDailyBonusIconName(), var_29_36)

		if var_29_37 and self.bonusPtIconPath then
			if var_29_38 then
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_29_38, true)
			else
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_29_37, true)
			end
		end

		LeanTween.cancel(go(var_29_35), true)

		local var_29_40 = var_29_35.anchoredPosition.y

		var_29_39.alpha = 0

		LeanTween.value(go(var_29_35), 0, 1, 0.2):setOnUpdate(System.Action_float(function(arg_30_0)
			var_29_39.alpha = arg_30_0
			var_29_35.anchoredPosition.y = var_29_40 * arg_30_0
			var_29_35.anchoredPosition = var_29_35.anchoredPosition
		end)):setOnComplete(System.Action(function()
			var_29_39.alpha = 1
			var_29_35.anchoredPosition.y = var_29_40
			var_29_35.anchoredPosition = var_29_35.anchoredPosition
		end)):setEase(LeanTweenType.easeOutSine):setDelay(0.7)
	end

	local var_29_41 = arg_29_2.id

	onButton(self, var_29_1, function()
		self:TryOpenChapterInfo(var_29_41, nil, var_29_3.list)
	end, SFX_UI_WEIGHANCHOR_SELECT)
end

function MapBuilderSP:SwitchChapter(arg_33_1)
	if not self.chapterGroupDict[arg_33_1] then
		return
	end

	local var_33_0 = self.chapterGroupDict[arg_33_1].list[self.chapterGroupDict[arg_33_1].index]

	if self.chapterGroupDict[arg_33_1].list[self.chapterGroupDict[arg_33_1].index] == arg_33_1 then
		return
	end

	local var_33_1 = table.indexof(self.chapterGroupDict[arg_33_1].list, arg_33_1)

	self.chapterGroupDict[arg_33_1].index = var_33_1

	PlayerPrefs.SetInt("spchapter_selected_" .. getProxy(PlayerProxy):getRawData().id .. "_" .. self.chapterGroupDict[arg_33_1].list[1], var_33_1)

	self.chapterTFsById[var_33_0] = nil
	self.chapterTFsById[arg_33_1] = self.chapterTFsById[var_33_0]

	self:UpdateChapterTF(arg_33_1)
end

function MapBuilderSP:UpdateChapterTF(arg_34_1)
	if not self.chapterGroupDict[arg_34_1] then
		return
	end

	if self.chapterTFsById[arg_34_1] then
		self:UpdateMapItem(self.chapterTFsById[arg_34_1], (getProxy(ChapterProxy):getChapterById(arg_34_1)))
	end
end

function MapBuilderSP:RecyclePools()
	for iter_35_0 = #self.activeItems, 1, -1 do
		if self.activeItems[iter_35_0].template == self.oneLineTpl then
			setSizeDelta(self.activeItems[iter_35_0].active, {
				x = self.oneLineWidth,
				y = self.oneLineHeight
			})
		end

		self.pools[self.activeItems[iter_35_0].template]:Enqueue(self.activeItems[iter_35_0].active)
	end

	table.clean(self.activeItems)

	self.storyNodeTFsById = {}
end

local var_0_2 = 1
local var_0_3 = 2
local var_0_4 = 3

function MapBuilderSP:UpdateStoryNodeStatus()
	local var_36_0 = 0
	local var_36_1 = 0
	local var_36_2 = pg.NewStoryMgr.GetInstance()
	local var_36_3 = {}

	table.Foreach(self.spStoryIDs, function(arg_37_0, arg_37_1)
		var_36_3[arg_37_1] = {}
	end)

	local var_36_4 = self.spStoryNodes

	for iter_36_0 = 1, #self.spStoryNodes do
		local var_36_5 = var_36_4[iter_36_0]
		local var_36_6 = var_36_4[iter_36_0]:GetConfigID()
		local var_36_7 = var_36_4[iter_36_0]:GetPreEvent()
		local var_36_9 = var_36_7 == 0 and true or var_36_3[var_36_7].status == var_0_4
		local var_36_10 = var_0_2
		local var_36_11 = var_36_4[iter_36_0]:GetStoryName()
		local var_36_12 = false

		if var_36_11 and var_36_11 ~= "" then
			var_36_12 = var_36_2:IsPlayed(var_36_11)
			var_36_0 = var_36_0 + (var_36_12 and 1 or 0)
			var_36_1 = var_36_1 + 1
		end

		if not var_36_12 and var_36_9 then
			local var_36_13 = {}

			_.each(var_36_5:GetUnlockConditions(), function(arg_38_0)
				local var_38_0 = true

				if arg_38_0[1] == ActivitySpStoryNode.CONDITION.TIME then
					var_38_0 = pg.TimeMgr.GetInstance():parseTimeFromConfig(arg_38_0[2]) <= pg.TimeMgr.GetInstance():GetServerTime()
				elseif arg_38_0[1] == ActivitySpStoryNode.CONDITION.PASSCHAPTER then
					var_38_0 = _.all(arg_38_0[2], function(arg_39_0)
						return getProxy(ChapterProxy):getChapterById(arg_39_0, true):isClear()
					end)
				elseif arg_38_0[1] == ActivitySpStoryNode.CONDITION.PT then
					local var_38_1 = arg_38_0[2][3]
					local var_38_2 = 0

					if arg_38_0[2][1] == DROP_TYPE_RESOURCE then
						var_38_2 = getProxy(PlayerProxy):getRawData():getResource(arg_38_0[2])
					elseif arg_38_0[2][1] == DROP_TYPE_ITEM then
						var_38_2 = getProxy(BagProxy):getItemCountById(arg_38_0[2][2])
					end

					var_38_0 = var_38_1 <= var_38_2
				end

				table.insert(var_36_13, var_38_0)

				var_36_9 = var_36_9 and var_38_0
			end)

			var_36_3[var_36_6].conditionFinishedList = var_36_13
		end

		if var_36_12 then
			var_36_10 = var_0_4
		elseif var_36_9 then
			var_36_10 = var_0_3
		end

		var_36_3[var_36_6].status = var_36_10
	end

	self.storyNodeStatus = var_36_3
	self.storyReadCount, self.storyReadMax = var_36_0, var_36_1
end

function MapBuilderSP:UpdateStory()
	self:RecyclePools()

	local var_40_0 = {
		"162443",
		"ffffff",
		"ffcb5a"
	}
	local var_40_1 = self.data:getConfig("story_inactive_color")

	if var_40_1 and #var_40_1 > 0 then
		var_40_0[1] = var_40_1
	end

	local var_40_2 = 0
	local var_40_3 = 150
	local var_40_4 = {
		{
			node = self.storyTree.root,
			nodePos = Vector2.New(150, 0)
		}
	}
	local var_40_5 = self.nodeTplWidth
	local var_40_6 = self.oneLineWidth
	local var_40_7 = self.branchHeadWidth
	local var_40_8 = self.branchUpWidth
	local var_40_9 = self.branchUpHeight
	local var_40_10 = self.UnionTailWidth
	local var_40_11 = 75
	local var_40_12 = 82
	local var_40_13 = 32

	while (function()
		local var_41_0 = table.remove(var_40_4, 1)
		local var_41_1 = var_41_0.node:GetConfigID()

		;(function()
			local var_42_0 = self:DequeItem(self.storyNodeTpl)

			var_42_0.name = var_41_1

			setAnchoredPosition(var_42_0, var_41_0.nodePos)

			self.storyNodeTFsById[var_41_1] = {
				nodeTF = tf(var_42_0)
			}
		end)()

		local var_41_2 = self.storyTree.childDict[var_41_1] or {}

		if #var_41_2 == 0 then
			var_40_2 = var_41_0.nodePos.x + var_40_5 + var_40_3
		elseif #var_41_2 == 1 then
			local var_41_3 = var_41_2[1]:GetConfigID()
			local var_41_4 = self:DequeItem(self.oneLineTpl)

			var_41_4.name = string.format("Line%s_%s", var_41_1, var_41_3)

			setAnchoredPosition(var_41_4, var_41_0.nodePos + Vector2.New(var_40_5 + var_40_13, 0))

			nextPos = tf(var_41_4).anchoredPosition + Vector2.New(var_40_6 + var_40_11, 0)

			local var_41_5 = self.storyNodeStatus[var_41_3].status

			eachChild(var_41_4, function(arg_43_0)
				setImageColor(arg_43_0, Color.NewHex(var_40_0[var_41_5]))
			end)
			table.insert(var_40_4, {
				node = var_41_2[1],
				nodePos = nextPos
			})
		elseif #var_41_2 > 1 then
			local var_41_6 = {}
			local var_41_7

			table.Ipairs(var_41_2, function(arg_44_0, arg_44_1)
				local var_44_0 = 0
				local var_44_1 = arg_44_1

				while (function()
					var_44_0 = var_44_0 + 1

					local var_45_0 = self.storyTree.childDict[var_44_1:GetConfigID()]

					if not var_45_0 then
						return false
					end

					assert(#var_45_0 <= 1)

					if var_45_0[1] and #var_45_0[1]:GetPreNodes() == 1 then
						var_44_1 = var_45_0[1]

						return true
					else
						var_41_7 = var_45_0[1]
					end
				end)() do
					-- block empty
				end

				var_41_6[arg_44_0] = 0
			end)

			local var_41_8 = _.max(var_41_6)
			local var_41_9 = var_41_8 * (var_40_5 + var_40_11 + var_40_13) + (var_41_8 - 1) * var_40_6
			local var_41_10 = var_41_0.nodePos + Vector2.New(var_40_5 + var_40_13, 0)

			;(function()
				local var_46_0 = self:DequeItem(self.branchHeadTpl)

				setAnchoredPosition(var_46_0, var_41_10)

				var_41_10 = var_41_10 + Vector2.New(var_40_7, 0)

				local var_46_1 = self.storyNodeStatus[var_41_2[1]:GetConfigID()].status

				eachChild(var_46_0, function(arg_47_0)
					setImageColor(arg_47_0, Color.NewHex(var_40_0[var_46_1]))
				end)
			end)()
			table.Ipairs(var_41_2, function(arg_48_0, arg_48_1)
				local var_48_0 = var_40_6

				if var_41_6[arg_48_0] < var_41_8 then
					var_48_0 = (var_41_9 - var_41_6[arg_48_0] * (var_40_5 + var_40_11 + var_40_13)) / (var_41_6[arg_48_0] + 1)
				end

				local var_48_1 = arg_48_1:GetConfigID()
				local var_48_2 = var_41_10

				;(function()
					local var_49_0

					if arg_48_0 == 1 then
						var_49_0 = self:DequeItem(self.branchUpTpl)

						setAnchoredPosition(var_49_0, var_48_2)

						var_48_2 = var_48_2 + Vector2.New(var_40_8, var_40_9)

						if var_41_6[arg_48_0] < var_41_8 then
							setSizeDelta(var_49_0, {
								x = var_40_8 + var_48_0,
								y = var_40_9
							})

							local var_49_1 = tf(var_49_0):Find("Line_1").sizeDelta

							var_49_1.x = var_49_1.x + var_48_0

							setSizeDelta(tf(var_49_0):Find("Line_1"), var_49_1)

							var_48_2 = var_48_2 + Vector2.New(var_48_0, 0)
						end
					elseif (arg_48_0 == 3 or arg_48_0 == 2 and #var_41_2 == 2) and self.storyTree.childDict[var_41_2[1]:GetConfigID()] then
						var_49_0 = self:DequeItem(self.branchDownTpl)

						setAnchoredPosition(var_49_0, var_48_2)

						var_48_2 = var_48_2 + Vector2.New(var_40_8, -var_40_9)

						if var_41_6[arg_48_0] < var_41_8 then
							setSizeDelta(var_49_0, {
								x = var_40_8 + var_48_0,
								y = var_40_9
							})

							local var_49_2 = tf(var_49_0):Find("Line_1").sizeDelta

							var_49_2.x = var_49_2.x + var_48_0

							setSizeDelta(tf(var_49_0):Find("Line_1"), var_49_2)

							var_48_2 = var_48_2 + Vector2.New(var_48_0, 0)
						end
					else
						var_49_0 = self:DequeItem(self.branchCenterTpl)

						setAnchoredPosition(var_49_0, var_48_2)

						var_48_2 = var_48_2 + Vector2.New(var_40_8, 0)

						if var_41_6[arg_48_0] < var_41_8 then
							local var_49_3 = tf(var_49_0).sizeDelta

							var_49_3.x = var_49_3.x + var_48_0

							setSizeDelta(var_49_0, var_49_3)

							var_48_2 = var_48_2 + Vector2.New(var_48_0, 0)
						end
					end

					var_49_0.name = string.format("Branch%s_%s", var_41_1, var_48_1)

					local var_49_4 = self.storyNodeStatus[var_48_1].status

					eachChild(var_49_0, function(arg_50_0)
						setImageColor(arg_50_0, Color.NewHex(var_40_0[var_49_4]))
					end)
				end)()

				var_48_2 = var_48_2 + Vector2.New(var_40_11, 0)

				local var_48_3 = self:DequeItem(self.storyNodeTpl)

				var_48_3.name = var_48_1

				setAnchoredPosition(var_48_3, var_48_2)

				self.storyNodeTFsById[var_48_1] = {
					nodeTF = tf(var_48_3)
				}
				var_48_2 = var_48_2 + Vector2.New(var_40_5 + var_40_13, 0)

				local var_48_4 = arg_48_1

				if self.storyTree.childDict[var_48_1] then
					local var_48_5 = self.storyTree.childDict[var_48_1][1]

					while (function()
						if not var_48_5 or var_48_5 == var_41_7 then
							return
						end

						local var_51_0 = self:DequeItem(self.oneLineTpl)

						var_51_0.name = string.format("Line%s_%s", var_48_4:GetConfigID(), var_48_5:GetConfigID())

						setAnchoredPosition(var_51_0, var_48_2)

						var_48_2 = var_48_2 + Vector2.New(var_48_0 + var_40_11, 0)

						setSizeDelta(var_51_0, {
							x = var_48_0,
							y = self.oneLineHeight
						})

						local var_51_1 = self.storyNodeStatus[var_48_5:GetConfigID()].status

						eachChild(var_51_0, function(arg_52_0)
							setImageColor(arg_52_0, Color.NewHex(var_40_0[var_51_1]))
						end)

						local var_51_2 = self:DequeItem(self.storyNodeTpl)

						var_51_2.name = var_48_5:GetConfigID()

						setAnchoredPosition(var_51_2, var_48_2)

						self.storyNodeTFsById[var_48_5:GetConfigID()] = {
							nodeTF = tf(var_51_2)
						}
						var_48_2 = var_48_2 + Vector2.New(var_40_5 + var_40_13, 0)

						local var_51_3 = self.storyTree.childDict[var_48_5:GetConfigID()]

						if not var_51_3 then
							return false
						end

						var_48_5, var_48_4 = var_51_3[1], var_48_5

						return true
					end)() do
						-- block empty
					end
				end

				if var_41_7 then
					local var_48_6

					if arg_48_0 == 1 then
						var_48_6 = self:DequeItem(self.unionUpTpl)

						setAnchoredPosition(var_48_6, var_48_2)

						if var_41_6[arg_48_0] < var_41_8 then
							setSizeDelta(var_48_6, {
								x = var_40_8 + var_48_0,
								y = var_40_9
							})

							local var_48_7 = tf(var_48_6):Find("Line_1").sizeDelta

							var_48_7.x = var_48_7.x + var_48_0

							setSizeDelta(tf(var_48_6):Find("Line_1"), var_48_7)

							var_48_2 = var_48_2 + Vector2.New(var_48_0, 0)
						end
					elseif arg_48_0 == 3 or arg_48_0 == 2 and #var_41_2 == 2 then
						var_48_6 = self:DequeItem(self.unionDownTpl)

						setAnchoredPosition(var_48_6, var_48_2)

						if var_41_6[arg_48_0] < var_41_8 then
							setSizeDelta(var_48_6, {
								x = var_40_8 + var_48_0,
								y = var_40_9
							})

							local var_48_8 = tf(var_48_6):Find("Line_1").sizeDelta

							var_48_8.x = var_48_8.x + var_48_0

							setSizeDelta(tf(var_48_6):Find("Line_1"), var_48_8)

							var_48_2 = var_48_2 + Vector2.New(var_48_0, 0)
						end
					else
						var_48_6 = self:DequeItem(self.unionCenterTpl)

						setAnchoredPosition(var_48_6, var_48_2)

						if var_41_6[arg_48_0] < var_41_8 then
							local var_48_9 = tf(var_48_6).sizeDelta

							var_48_9.x = var_48_9.x + var_48_0

							setSizeDelta(var_48_6, var_48_9)

							var_48_2 = var_48_2 + Vector2.New(var_48_0, 0)
						end
					end

					var_48_6.name = string.format("Union%s_%s", var_48_4:GetConfigID(), var_41_7:GetConfigID())

					local var_48_10 = self.storyNodeStatus[var_41_7:GetConfigID()].status

					eachChild(var_48_6, function(arg_53_0)
						setImageColor(arg_53_0, Color.NewHex(var_40_0[var_48_10]))
					end)
				end
			end)

			var_41_10 = var_41_10 + Vector2.New(var_41_8 * (var_40_5 + var_40_11 + var_40_13) + (var_41_8 - 1) * var_40_6 + var_40_8, 0)

			if nil then
				(function()
					var_41_10 = var_41_10 + Vector2.New(var_40_8, 0)

					local var_54_0 = self:DequeItem(self.unionTailTpl)

					setAnchoredPosition(var_54_0, var_41_10)

					var_41_10 = var_41_10 + Vector2.New(var_40_10 + var_40_12, 0)

					local var_54_1 = self.storyNodeStatus[var_41_7:GetConfigID()].status

					eachChild(var_54_0, function(arg_55_0)
						setImageColor(arg_55_0, Color.NewHex(var_40_0[var_54_1]))
					end)
				end)()
				table.insert(var_40_4, {
					node = nil,
					nodePos = var_41_10
				})
			else
				var_40_2 = var_41_10.x + var_40_3
			end
		end

		return next(var_40_4)
	end)() do
		-- block empty
	end

	setSizeDelta(self.storyContainer, {
		x = var_40_2
	})

	if self.spStoryUnreleasedNode then
		local var_40_14 = cloneTplTo(self.unreleasedNodeTpl, self.storyContainer)

		setAnchoredPosition(var_40_14, {
			y = 0,
			x = var_40_2
		})
		setText(var_40_14:Find("text"), self.spStoryUnreleasedNode:GetDisplayName())
		ResourceMgr.Inst:getAssetAsync("ui/" .. self.spStoryUnreleasedNode:GetCleanAnimator(), "", UnityEngine.Events.UnityAction_UnityEngine_Object(function(arg_56_0)
			local var_56_0 = Instantiate(arg_56_0)

			tf(var_56_0).localPosition = Vector3.New(-525, 0, 380)

			setParent(var_56_0, var_40_14)
		end), true, true)
	end

	local var_40_15 = self.spStoryNodes

	for iter_40_0 = 1, #self.spStoryNodes do
		local var_40_16 = var_40_15[iter_40_0]
		local var_40_17 = var_40_15[iter_40_0]:GetConfigID()
		local var_40_18 = self.storyNodeStatus[var_40_17].status
		local var_40_19 = self.storyNodeTFsById[var_40_17].nodeTF
		local var_40_20 = self.storyNodeTFsById[var_40_17].nodeTF:Find("info/bk/title_form/title")

		if self.storyNodeStatus[var_40_17].status == var_0_2 then
			local var_40_21 = var_40_16:GetUnlockDesc()
			local var_40_22 = ""

			if type(var_40_21) == "table" then
				local var_40_23 = self.storyNodeStatus[var_40_17].conditionFinishedList or {}

				var_40_22 = var_40_21[1] or ""

				for iter_40_1, iter_40_2 in ipairs(var_40_21) do
					if not var_40_23[iter_40_1] then
						var_40_22 = iter_40_2 or ""

						break
					end
				end
			else
				var_40_22 = var_40_21 or ""
			end

			setScrollText(var_40_20, HXSet.hxLan(var_40_22))
			setTextAlpha(var_40_20, 0.5)
		else
			setScrollText(var_40_20, HXSet.hxLan(var_40_16:GetDisplayName()))
			setTextAlpha(var_40_20, 1)
		end

		local var_40_24 = var_40_16:GetType()

		setActive(var_40_19:Find("circle/lock"), var_40_18 == var_0_2)

		if var_40_18 == var_0_2 then
			setActive(var_40_19:Find("circle/Story"), false)
			setActive(var_40_19:Find("circle/Battle"), false)
			setActive(var_40_19:Find("circle/Option"), false)
			setText(var_40_19:Find(""))
		elseif var_40_24 == ActivitySpStoryNode.NODE_TYPE.STORY then
			setActive(var_40_19:Find("circle/Option"), false)
			setActive(var_40_19:Find("circle/Story"), true)
			setActive(var_40_19:Find("circle/Battle"), false)
			setActive(var_40_19:Find("circle/Story/Done"), var_40_18 == var_0_4)
		elseif var_40_24 == ActivitySpStoryNode.NODE_TYPE.OPTION_BRANCH then
			setActive(var_40_19:Find("circle/Option"), true)
			setActive(var_40_19:Find("circle/Story"), false)
			setActive(var_40_19:Find("circle/Battle"), false)
			setActive(var_40_19:Find("circle/Option/Done"), var_40_18 == var_0_4)
		else
			local var_40_25
			local var_40_26

			if var_40_24 == ActivitySpStoryNode.NODE_TYPE.BATTLE then
				setActive(var_40_19:Find("circle/Story"), false)
				setActive(var_40_19:Find("circle/Option"), false)
				setActive(var_40_19:Find("circle/Battle"), var_40_24 == ActivitySpStoryNode.NODE_TYPE.BATTLE)
				setActive(var_40_19:Find("circle/Battle/Done"), var_40_18 == var_0_4)

				var_40_25 = setActive
				var_40_26 = var_40_19:Find("circle/progress")
			end
		end

		var_40_25(var_40_26, var_40_18 == var_0_4)

		local var_40_27 = var_40_16:IsRecrew()

		if var_40_27 == nil then
			setActive(var_40_19:Find("recrew"), false)
		else
			setActive(var_40_19:Find("recrew"), true)
			setActive(var_40_19:Find("recrew/recrewed"), var_40_27)
			setActive(var_40_19:Find("recrew/not_recrew"), not var_40_27)
			setText(var_40_19:Find("recrew/recrewed/label"), i18n("story_recrewed"))
			setText(var_40_19:Find("recrew/not_recrew/label"), i18n("story_not_recrew"))
		end

		onButton(self, var_40_19, function()
			if var_40_18 == var_0_2 then
				return
			end

			self:PlayStory(var_40_16:GetStoryName(), function()
				self:UpdateView()

				self.needFocusStory = true

				self:Move2UnlockStory()
			end, true)
		end)
	end

	setText(self.progressText, self.storyReadCount .. "/" .. self.storyReadMax)
	setActive(self.storyAward, tobool(self.storyTask))

	if self.storyTask then
		local var_40_28 = self.storyTask:getConfig("award_display")
		local var_40_29 = Drop.New({
			type = var_40_28[1][1],
			id = var_40_28[1][2],
			count = var_40_28[1][3]
		})

		updateDrop(self.storyAward:GetChild(0), var_40_29)

		local var_40_30 = self.storyTask:getTaskStatus()

		setActive(self.storyAward:Find("get"), var_40_30 == 1)
		setActive(self.storyAward:Find("got"), var_40_30 == 2)
		onButton(self, self.storyAward, function()
			self:emit(BaseUI.ON_DROP, var_40_29)
		end)
	end
end

function MapBuilderSP:DequeItem(arg_60_1)
	local var_60_0 = self.pools[arg_60_1]:Dequeue()

	table.insert(self.activeItems, {
		template = arg_60_1,
		active = var_60_0
	})
	setActive(var_60_0, true)
	setParent(var_60_0, self.storyContainer)

	return var_60_0
end

function MapBuilderSP:Move2UnlockStory()
	if not self.needFocusStory then
		return
	end

	self.needFocusStory = nil

	local var_61_0

	for iter_61_0 = #self.spStoryNodes, 1, -1 do
		local var_61_1 = self.spStoryNodes[iter_61_0]:GetConfigID()

		if self.storyNodeStatus[var_61_1].status > var_0_2 then
			var_61_0 = var_61_1

			break
		end
	end

	local var_61_2 = {}

	var_61_2.x = -math.clamp(self.storyNodeTFsById[var_61_0].nodeTF.anchoredPosition.x + self.storyNodeTpl.rect.width * 0.5 - self.storyContainer.parent.rect.width * 0.5, 0, math.max(0, self.storyContainer.rect.width - self.storyContainer.parent.rect.width))

	setAnchoredPosition(self.storyContainer, var_61_2)
end

function MapBuilderSP:SwitchStoryMapAndBGM()
	local var_62_0 = self.data:getConfig("default_background")
	local var_62_1 = self.data:getConfig("default_bgm")
	local var_62_2

	for iter_62_0 = 1, #self.spStoryNodes do
		if self.storyNodeStatus[self.spStoryNodes[iter_62_0]:GetConfigID()].status == var_0_4 then
			var_62_1 = self.spStoryNodes[iter_62_0]:GetCleanBGM()
			var_62_0 = self.spStoryNodes[iter_62_0]:GetCleanBG()
			var_62_2 = self.spStoryNodes[iter_62_0]:GetCleanAnimator()
		else
			break
		end
	end

	self.sceneParent:SwitchBG({
		{
			bgPrefix = "bg",
			BG = var_62_0,
			Animator = var_62_2
		}
	})
	pg.BgmMgr.GetInstance():Push(self.__cname, var_62_1)
end

function MapBuilderSP:TrySubmitTask()
	local var_63_0 = true

	for iter_63_0, iter_63_1 in ipairs(self.spStoryNodes) do
		local var_63_1 = iter_63_1:GetStoryName()

		if var_63_1 and var_63_1 ~= "" then
			var_63_0 = var_63_0 and pg.NewStoryMgr.GetInstance():IsPlayed(var_63_1)
		end

		if not var_63_0 then
			break
		end
	end

	if var_63_0 and self.storyTask and self.storyTask:getTaskStatus() == 1 then
		self:emit(LevelMediator2.ON_SUBMIT_TASK, self.storyTask.id)

		return
	end
end

function MapBuilderSP:PlayStory(arg_64_1, arg_64_2, arg_64_3)
	if not arg_64_1 then
		return existCall(arg_64_2)
	end

	local var_64_0 = pg.NewStoryMgr.GetInstance()
	local var_64_1 = var_64_0:IsPlayed(arg_64_1)

	seriesAsync({
		function(arg_65_0)
			if var_64_1 and not arg_64_3 then
				return arg_65_0()
			end

			local var_65_0 = tonumber(arg_64_1)

			if var_65_0 and var_65_0 > 0 then
				self:emit(LevelMediator2.ON_PERFORM_COMBAT, var_65_0, nil, var_64_1)
			else
				var_64_0:PlayForAcivitySpStory(arg_64_1, arg_65_0, arg_64_3)
			end
		end,
		function(arg_66_0, ...)
			existCall(arg_64_2, ...)
		end
	})
end

function MapBuilderSP:UpdateStoryTask()
	local var_67_0 = self.activity and self.activity:getConfig("config_client").task_id

	if not var_67_0 then
		return
	end

	local var_67_1 = getProxy(TaskProxy):getTaskVO(var_67_0)

	var_67_1 = var_67_1 or Task.New({
		submit_time = 1,
		id = var_67_0
	})
	self.storyTask = var_67_1
end

function MapBuilderSP:OnSubmitTaskDone()
	self:UpdateView()
end

function MapBuilderSP:OnDestroy()
	self:RecyclePools()

	for iter_69_0, iter_69_1 in pairs(self.pools) do
		iter_69_1:Clear()
	end
end

return MapBuilderSP
