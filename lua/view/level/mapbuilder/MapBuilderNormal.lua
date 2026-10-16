local MapBuilderNormal = class("MapBuilderNormal", import(".MapBuilderPermanent"))

function MapBuilderNormal:GetType()
	return MapBuilder.TYPENORMAL
end

function MapBuilderNormal:getUIName()
	return "levels"
end

function MapBuilderNormal:Load()
	if self._state ~= MapBuilderNormal.STATES.NONE then
		return
	end

	self._state = MapBuilderNormal.STATES.LOADING

	pg.UIMgr.GetInstance():LoadingOn()
	self:Loaded(self.float:Find("levels").gameObject)
	self:Init()
end

function MapBuilderNormal:Destroy()
	if self._state == MapBuilderNormal.STATES.DESTROY then
		return
	end

	if not self:GetLoaded() then
		self._state = MapBuilderNormal.STATES.DESTROY

		return
	end

	self:Hide()
	self:OnDestroy()
	pg.DelegateInfo.Dispose(self)

	self._go = nil

	self:disposeEvent()
	self:cleanManagedTween()

	self._state = MapBuilderNormal.STATES.DESTROY
end

function MapBuilderNormal:OnInit()
	self.chapterTpl = self._tf:Find("level_tpl")

	setActive(self.chapterTpl, false)

	self.storyTpl = self._tf:Find("story_tpl")

	setActive(self.storyTpl, false)

	self.itemHolder = self._tf:Find("items")
	self.storyHolder = self._tf:Find("stories")
	self.chapterTFsById = {}
	self.chaptersInBackAnimating = {}
end

function MapBuilderNormal:OnShow()
	MapBuilderNormal.super.OnShow(self)
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), true)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), true)
	setActive(self.sceneParent.topChapter:Find("type_chapter"), true)
end

function MapBuilderNormal:OnHide()
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), false)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), false)
	setActive(self.sceneParent.topChapter:Find("type_chapter"), false)
	table.clear(self.chaptersInBackAnimating)

	for iter_7_0, iter_7_1 in pairs(self.chapterTFsById) do
		LeanTween.cancel(rtf((findTF(iter_7_1, "main/info/bk"))))
	end

	MapBuilderNormal.super.OnHide(self)
end

function MapBuilderNormal:UpdateView()
	setText(self.sceneParent.chapterName, string.split(self.contextData.map:getConfig("name"), "||")[1])
	self.sceneParent.loader:GetSpriteQuiet("chapterno", "chapter" .. self.contextData.map:getMapTitleNumber(), self.sceneParent.chapterNoTitle, true)
	MapBuilderNormal.super.UpdateView(self)
end

function MapBuilderNormal:UpdateBonusPtIconPath()
	self.bonusPtIconPath = nil

	local var_9_0 = self.data or self.contextData.map

	if not var_9_0 then
		return
	end

	local var_9_1 = var_9_0:getConfig("on_activity")

	if not var_9_1 or var_9_1 == 0 then
		return
	end

	local var_9_2 = getProxy(ActivityProxy):getActivityById(var_9_1)

	if not var_9_2 or var_9_2:isEnd() then
		return
	end

	local var_9_3 = var_9_2:GetConfigClientPTActivity()

	if not var_9_3 then
		return
	end

	self.bonusPtIconPath = var_9_3:GetPTDrop():getIcon()
end

function MapBuilderNormal:UpdateMapItems()
	MapBuilderNormal.super.UpdateMapItems(self)

	local var_10_0 = self.data:GetChapterInProgress()

	if var_10_0 and isa(var_10_0, ChapterStoryGroup) then
		setActive(self.itemHolder, false)
		setActive(self.storyHolder, true)
		self:UpdateStoryGroup()

		return
	end

	setActive(self.itemHolder, true)
	setActive(self.storyHolder, false)
	self:UpdateBonusPtIconPath()

	local var_10_1 = getProxy(ChapterProxy)
	local var_10_2 = {}

	for iter_10_0, iter_10_1 in pairs(self.data:getChapters()) do
		if (iter_10_1:isUnlock() or iter_10_1:activeAlways()) and (not iter_10_1:ifNeedHide() or var_10_1:GetJustClearChapters(iter_10_1.id)) then
			table.insert(var_10_2, iter_10_1)
		end
	end

	table.clear(self.chapterTFsById)
	UIItemList.StaticAlign(self.itemHolder, self.chapterTpl, #var_10_2, function(arg_11_0, arg_11_1, arg_11_2)
		if arg_11_0 ~= UIItemList.EventUpdate then
			return
		end

		local var_11_0 = var_10_2[arg_11_1 + 1]

		self:UpdateMapItem(arg_11_2, var_10_2[arg_11_1 + 1])

		arg_11_2.name = "Chapter_" .. var_11_0.id
		self.chapterTFsById[var_11_0.id] = arg_11_2
	end)

	local var_10_3 = {}

	for iter_10_2, iter_10_3 in pairs(var_10_2) do
		local var_10_4 = iter_10_3:getConfigTable()

		var_10_3[var_10_4.pos_x] = var_10_3[var_10_4.pos_x] or {}
		var_10_3[var_10_4.pos_x][var_10_4.pos_y] = var_10_3[var_10_4.pos_x][var_10_4.pos_y] or {}

		table.insert(var_10_3[var_10_4.pos_x][var_10_4.pos_y], iter_10_3)
	end

	for iter_10_4, iter_10_5 in pairs(var_10_3) do
		for iter_10_6, iter_10_7 in pairs(iter_10_5) do
			local var_10_5 = {}

			seriesAsync({
				function(arg_12_0)
					local var_12_0 = 0

					for iter_12_0, iter_12_1 in pairs(iter_10_7) do
						if iter_12_1:ifNeedHide() and var_10_1:GetJustClearChapters(iter_12_1.id) and self.chapterTFsById[iter_12_1.id] then
							var_12_0 = var_12_0 + 1

							local var_12_1 = self.chapterTFsById[iter_12_1.id]

							setActive(self.chapterTFsById[iter_12_1.id], true)
							self:PlayChapterItemAnimationBackward(self.chapterTFsById[iter_12_1.id], iter_12_1, function()
								var_12_0 = var_12_0 - 1

								setActive(var_12_1, false)
								var_10_1:RecordJustClearChapters(iter_12_1.id, nil)

								if var_12_0 <= 0 then
									arg_12_0()
								end
							end)

							var_10_5[iter_12_1.id] = true
						elseif self.chapterTFsById[iter_12_1.id] then
							setActive(self.chapterTFsById[iter_12_1.id], false)
						end
					end

					if var_12_0 <= 0 then
						arg_12_0()
					end
				end,
				function(arg_14_0)
					local var_14_0 = 0

					for iter_14_0, iter_14_1 in pairs(iter_10_7) do
						if not var_10_5[iter_14_1.id] then
							var_14_0 = var_14_0 + 1

							setActive(self.chapterTFsById[iter_14_1.id], true)
							self:PlayChapterItemAnimation(self.chapterTFsById[iter_14_1.id], iter_14_1, function()
								var_14_0 = var_14_0 - 1

								if var_14_0 <= 0 then
									arg_14_0()
								end
							end)
						end
					end
				end
			})
		end
	end
end

function MapBuilderNormal:UpdateMapItem(arg_16_1, arg_16_2)
	local var_16_0 = arg_16_2:getConfigTable()

	setLocalPosition(arg_16_1, {
		x = 1920 * var_16_0.pos_x,
		y = 1080 * var_16_0.pos_y
	})

	local var_16_1 = findTF(arg_16_1, "main")

	setActive(var_16_1, true)

	local var_16_2 = findTF(var_16_1, "info/bk/fordark")

	setActive(findTF(var_16_1, "circle/fordark"), var_16_0.icon_outline == 1)
	setActive(var_16_2, var_16_0.icon_outline == 1)

	local var_16_3 = findTF(var_16_1, "circle/clear_flag")
	local var_16_4 = findTF(var_16_1, "circle/progress_text")
	local var_16_5 = findTF(var_16_1, "circle/stars")
	local var_16_6 = string.split(var_16_0.name, "|")

	setText(findTF(var_16_1, "info/bk/title_form/title_index"), var_16_0.chapter_name .. "  ")
	setText(findTF(var_16_1, "info/bk/title_form/title"), var_16_6[1])
	setText(findTF(var_16_1, "info/bk/title_form/title_en"), var_16_6[2] or "")
	setFillAmount(findTF(var_16_1, "circle/progress"), arg_16_2.progress / 100)
	setText(var_16_4, string.format("%d%%", arg_16_2.progress))
	setActive(var_16_5, arg_16_2:existAchieve())

	if arg_16_2:existAchieve() then
		for iter_16_0, iter_16_1 in ipairs(arg_16_2.achieves) do
			setActive(var_16_5:Find("star" .. iter_16_0 .. "/light"), (ChapterConst.IsAchieved(iter_16_1)))
		end
	end

	local var_16_7 = not arg_16_2.active and arg_16_2:isClear()

	setActive(var_16_3, var_16_7)
	setActive(var_16_4, not var_16_7)
	self:DeleteTween("fighting" .. arg_16_2.id)

	local var_16_8 = findTF(var_16_1, "circle/fighting")

	setText(findTF(var_16_8, "Text"), i18n("tag_level_fighting"))

	local var_16_9 = findTF(var_16_1, "circle/oni")

	setText(findTF(var_16_9, "Text"), i18n("tag_level_oni"))

	local var_16_10 = findTF(var_16_1, "circle/narrative")

	setText(findTF(var_16_10, "Text"), i18n("tag_level_narrative"))

	local var_16_11 = findTF(var_16_1, "circle/auto")

	setText(findTF(var_16_11, "Text"), i18n("tag_level_autoing"))
	setActive(var_16_8, false)
	setActive(var_16_9, false)
	setActive(var_16_10, false)
	setActive(var_16_11, false)

	local var_16_12

	if arg_16_2:getConfig("chapter_tag") == 1 then
		var_16_12 = var_16_10
	end

	if arg_16_2.active then
		var_16_12 = arg_16_2:existOni() and var_16_9 or var_16_8
	end

	local var_16_14 = getProxy(ChapterProxy):GetAutoChapterId()

	if var_16_14 and var_16_14 == arg_16_2.id then
		var_16_12 = var_16_11

		local var_16_15, var_16_16 = getProxy(ChapterAutoProxy):GetCntInfo()

		setText(findTF(var_16_11, "Text"), var_16_15 < var_16_16 and i18n("tag_level_autoing") or i18n("tag_level_auto_finish"))
	end

	if var_16_12 then
		setActive(var_16_12, true)

		local var_16_17 = GetOrAddComponent(var_16_12, "CanvasGroup")

		var_16_17.alpha = 1

		self:RecordTween("fighting" .. arg_16_2.id, LeanTween.alphaCanvas(var_16_17, 0, 0.5):setFrom(1):setEase(LeanTweenType.easeInOutSine):setLoopPingPong().uniqueId)
	end

	local var_16_18 = findTF(var_16_1, "triesLimit")

	setActive(var_16_18, false)

	if arg_16_2:isTriesLimit() then
		local var_16_19 = arg_16_2:getConfig("count")

		setText(var_16_18:Find("label"), i18n("levelScene_chapter_count_tip"))

		local var_16_20 = setText

		var_16_20(var_16_18:Find("Text"), setColorStr(var_16_19 - arg_16_2:getTodayDefeatCount() .. "/" .. var_16_19, (var_16_19 <= arg_16_2:getTodayDefeatCount() or nil) and (COLOR_RED or COLOR_GREEN)))

		local var_16_24 = getProxy(ChapterProxy):IsActivitySPChapterActive(pg.expedition_data_by_map[arg_16_2:getConfig("map")].on_activity)

		var_16_24 = var_16_24 and SettingsProxy.IsShowActivityMapSPTip()

		setActive(var_16_18:Find("TipRect"), var_16_24)
	end

	local var_16_25 = arg_16_2:GetDailyBonusQuota()
	local var_16_26 = findTF(var_16_1, "mark")
	local var_16_27 = var_16_26:Find("bonus")
	local var_16_28 = var_16_27:Find("icon")
	local var_16_29 = findTF(var_16_27, "icon/Image")

	setActive(var_16_27, var_16_25)
	setActive(var_16_26, var_16_25)

	if var_16_28 then
		setActive(var_16_28, var_16_25 and self.bonusPtIconPath)
	end

	if var_16_25 then
		local var_16_30 = var_16_26:GetComponent(typeof(CanvasGroup))

		self.sceneParent.loader:GetSprite("ui/levelmainscene_atlas", arg_16_2:GetDailyBonusIconName(), var_16_27)

		if var_16_28 and self.bonusPtIconPath then
			if var_16_29 then
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_16_29, true)
			else
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_16_28, true)
			end
		end

		LeanTween.cancel(go(var_16_26), true)

		local var_16_31 = var_16_26.anchoredPosition.y

		var_16_30.alpha = 0

		LeanTween.value(go(var_16_26), 0, 1, 0.2):setOnUpdate(System.Action_float(function(arg_17_0)
			var_16_30.alpha = arg_17_0
			var_16_26.anchoredPosition.y = var_16_31 * arg_17_0
			var_16_26.anchoredPosition = var_16_26.anchoredPosition
		end)):setOnComplete(System.Action(function()
			var_16_30.alpha = 1
			var_16_26.anchoredPosition.y = var_16_31
			var_16_26.anchoredPosition = var_16_26.anchoredPosition
		end)):setEase(LeanTweenType.easeOutSine):setDelay(0.7)
	end

	local var_16_32 = arg_16_2.id

	onButton(self, var_16_1, function()
		if self.chaptersInBackAnimating[var_16_32] then
			return
		end

		self:TryOpenChapterInfo(var_16_32, Vector3(arg_16_1.localPosition.x - 10, arg_16_1.localPosition.y + 150))
	end, SFX_UI_WEIGHANCHOR_SELECT)
end

function MapBuilderNormal:PlayChapterItemAnimation(arg_20_1, arg_20_2, arg_20_3)
	local var_20_0 = findTF(arg_20_1, "main")
	local var_20_1 = findTF(var_20_0, "circle")
	local var_20_2 = findTF(var_20_0, "info/bk")

	LeanTween.cancel(go(var_20_1))

	var_20_1.localScale = Vector3.zero

	self:RecordTween(LeanTween.scale(var_20_1, Vector3.one, 0.3):setDelay(0.3).uniqueId)
	LeanTween.cancel(go(var_20_2))
	setAnchoredPosition(var_20_2, {
		x = -1 * var_20_0:Find("info").rect.width
	})
	shiftPanel(var_20_2, 0, nil, 0.4, 0.4, true, true, nil, function()
		if arg_20_2:isTriesLimit() then
			setActive(findTF(var_20_0, "triesLimit"), true)
		end

		if arg_20_3 then
			arg_20_3()
		end
	end)
end

function MapBuilderNormal:PlayChapterItemAnimationBackward(arg_22_1, arg_22_2, arg_22_3)
	local var_22_0 = findTF(arg_22_1, "main")
	local var_22_1 = findTF(var_22_0, "circle")
	local var_22_2 = findTF(var_22_0, "info/bk")

	LeanTween.cancel(go(var_22_1))

	var_22_1.localScale = Vector3.one

	self:RecordTween(LeanTween.scale(go(var_22_1), Vector3.zero, 0.3):setDelay(0.3).uniqueId)

	self.chaptersInBackAnimating[arg_22_2.id] = true

	LeanTween.cancel(go(var_22_2))
	setAnchoredPosition(var_22_2, {
		x = 0
	})
	shiftPanel(var_22_2, -1 * var_22_0:Find("info").rect.width, nil, 0.4, 0.4, true, true, nil, function()
		self.chaptersInBackAnimating[arg_22_2.id] = nil

		if arg_22_3 then
			arg_22_3()
		end
	end)

	if arg_22_2:isTriesLimit() then
		setActive(findTF(var_22_0, "triesLimit"), false)
	end
end

function MapBuilderNormal:UpdateChapterTF(arg_24_1)
	if self.chapterTFsById[arg_24_1] then
		local var_24_0 = getProxy(ChapterProxy):getChapterById(arg_24_1)

		self:UpdateMapItem(self.chapterTFsById[arg_24_1], var_24_0)
		self:PlayChapterItemAnimation(self.chapterTFsById[arg_24_1], var_24_0)
	end
end

function MapBuilderNormal:TryOpenChapter(arg_25_1)
	if self.chapterTFsById[arg_25_1] then
		triggerButton((self.chapterTFsById[arg_25_1]:Find("main")))
	end
end

function MapBuilderNormal:UpdateStoryGroup()
	local var_26_0 = self.data:GetChapterInProgress():GetChapterStories()

	UIItemList.StaticAlign(self.storyHolder, self.storyTpl, #var_26_0, function(arg_27_0, arg_27_1, arg_27_2)
		if arg_27_0 ~= UIItemList.EventUpdate then
			return
		end

		local var_27_0 = var_26_0[arg_27_1 + 1]

		self:UpdateMapStory(arg_27_2, var_26_0[arg_27_1 + 1])

		arg_27_2.name = "Chapter_" .. var_27_0:GetName()
	end)
end

function MapBuilderNormal:UpdateMapStory(arg_28_1, arg_28_2)
	local var_28_0 = arg_28_2:GetPosition()

	setAnchoredPosition(arg_28_1, {
		x = self.mapWidth * var_28_0[1],
		y = self.mapHeight * var_28_0[2]
	})
	setText(arg_28_1:Find("Name"), arg_28_2:GetName())

	local var_28_1, var_28_2 = arg_28_2:GetIcon()

	self.sceneParent.loader:GetSpriteQuiet(var_28_1, var_28_2, arg_28_1:Find("Icon"), true)

	local var_28_3 = arg_28_2:GetStoryName()

	onButton(self, arg_28_1, function()
		pg.NewStoryMgr.GetInstance():Play(var_28_3, function()
			self.sceneParent:RefreshMapBG()
			self:UpdateMapItems()
		end)
	end, SFX_PANEL)
	setActive(arg_28_1, not pg.NewStoryMgr.GetInstance():IsPlayed(var_28_3))
end

function MapBuilderNormal:HideFloat()
	setActive(self.itemHolder, false)
	setActive(self.storyHolder, false)
end

function MapBuilderNormal:ShowFloat()
	setActive(self.itemHolder, true)
	setActive(self.storyHolder, true)
end

return MapBuilderNormal
