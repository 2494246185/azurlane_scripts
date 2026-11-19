local MapBuilderShinano = class("MapBuilderShinano", import(".MapBuilderPermanent"))

function MapBuilderShinano:Ctor(...)
	MapBuilderShinano.super.Ctor(self, ...)

	self.chapterTFsById = {}
	self.chaptersInBackAnimating = {}
end

function MapBuilderShinano:GetType()
	return MapBuilder.TYPESHINANO
end

function MapBuilderShinano:getUIName()
	return "Shinano_levels"
end

function MapBuilderShinano:OnInit()
	self.tpl = self._tf:Find("level_tpl")

	setActive(self.tpl, false)

	self.itemHolder = self._tf:Find("items")

	local var_4_0 = self._tf:Find("preloadResources")
	local var_4_1 = var_4_0:Find("mengjing_rumeng")

	setAnchoredPosition(self._tf:Find("rumeng"), tf(var_4_1).anchoredPosition)
	setParent(var_4_1, self._tf:Find("rumeng"))
	setAnchoredPosition(var_4_1, Vector2.zero)
	self:InitTransformMapBtn(self._tf:Find("rumeng"), 1, var_4_0:Find("mengjing_rumeng_zhuangchang"))

	local var_4_2 = var_4_0:Find("mengjing_huigui")

	setAnchoredPosition(self._tf:Find("huigui"), tf(var_4_2).anchoredPosition)
	setParent(var_4_2, self._tf:Find("huigui"))
	setAnchoredPosition(var_4_2, Vector2.zero)
	self:InitTransformMapBtn(self._tf:Find("huigui"), -1, var_4_0:Find("mengjing_huigui_zhuangchang"))
end

function MapBuilderShinano:OnShow()
	MapBuilderShinano.super.OnShow(self)
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), true)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), true)
	setActive(self.sceneParent.topChapter:Find("type_skirmish"), true)
end

function MapBuilderShinano:OnHide()
	setActive(self.sceneParent.mainLayer:Find("title_chapter_lines"), false)
	setActive(self.sceneParent.topChapter:Find("title_chapter"), false)
	setActive(self.sceneParent.topChapter:Find("type_skirmish"), false)
	table.clear(self.chaptersInBackAnimating)

	for iter_6_0, iter_6_1 in pairs(self.chapterTFsById) do
		LeanTween.cancel(rtf((findTF(iter_6_1, "main/info/bk"))))
	end

	MapBuilderShinano.super.OnHide(self)
end

function MapBuilderShinano:TrySwitchNextMap(arg_7_1)
	local var_7_0 = getProxy(ChapterProxy):getMapById(self.contextData.mapIdx + arg_7_1)

	if not var_7_0 then
		return
	end

	if var_7_0:getMapType() == Map.ELITE and not var_7_0:isEliteEnabled() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("elite_disable_unusable"))

		return
	end

	local var_7_1, var_7_2 = var_7_0:isUnlock()

	if not var_7_1 then
		pg.TipsMgr.GetInstance():ShowTips(var_7_2)

		return
	end

	return true
end

function MapBuilderShinano:InitTransformMapBtn(arg_8_1, arg_8_2, arg_8_3)
	onButton(self, arg_8_1, function()
		if self:isfrozen() then
			return
		end

		local var_9_0

		seriesAsync({
			function(arg_10_0)
				if not self:TrySwitchNextMap(arg_8_2) then
					return
				end

				pg.CriMgr.GetInstance():StopBGM()
				pg.CriMgr.GetInstance():PlaySE_V3("ui-qiehuan")

				var_9_0 = self._tf:Find(arg_8_3.name .. "(Clone)") or Instantiate(arg_8_3)

				setParent(var_9_0, self._tf)
				setAnchoredPosition(var_9_0, rtf(arg_8_1).anchoredPosition)

				local var_10_0 = Map:bindConfigTable()[self.contextData.mapIdx + arg_8_2]

				if var_10_0 and #var_10_0.bg > 0 then
					GetSpriteFromAtlasAsync("levelmap/" .. var_10_0.bg, "", function(arg_11_0)
						return
					end)
				end

				self.sceneParent:frozen()
				LeanTween.delayedCall(go(arg_8_1), 2.3, System.Action(arg_10_0))
			end,
			function(arg_12_0)
				self.sceneParent:setMap(self.contextData.mapIdx + arg_8_2)
				LeanTween.delayedCall(go(arg_8_1), 0.5, System.Action(arg_12_0))
			end,
			function(arg_13_0)
				if not IsNil(var_9_0) then
					Destroy(var_9_0)
				end

				self.sceneParent:unfrozen()
			end
		})
	end)
end

function MapBuilderShinano:UpdateView()
	setText(self.sceneParent.chapterName, string.split(self.contextData.map:getConfig("name"), "||")[1])
	self.sceneParent.loader:GetSpriteQuiet("chapterno", "chapter" .. self.contextData.map:getMapTitleNumber(), self.sceneParent.chapterNoTitle, true)
	MapBuilderShinano.super.UpdateView(self)
end

function MapBuilderShinano:UpdateButtons()
	MapBuilderShinano.super.UpdateButtons(self)
	self:UpdateCustomButtons()
end

function MapBuilderShinano:UpdateBonusPtIconPath()
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

function MapBuilderShinano:UpdateCustomButtons()
	local var_17_0 = self.contextData.map
	local var_17_1 = self.contextData.map:getConfig("type") == Map.ACT_EXTRA
	local var_17_2 = self._tf:Find("rumeng")
	local var_17_3 = self._tf:Find("huigui")

	setActive(var_17_2, false)
	setActive(var_17_3, false)

	if not var_17_1 then
		setActive(self.sceneParent.btnPrev, false)
		setActive(self.sceneParent.btnNext, false)

		local var_17_4 = getProxy(ChapterProxy):getMapById(var_17_0.id + 1)
		local var_17_5 = getProxy(ChapterProxy):getMapById(var_17_0.id - 1)

		setActive(var_17_2, var_17_4)
		setActive(var_17_3, var_17_5)
		LeanTween.cancel(go(var_17_2), true)
		LeanTween.cancel(go(var_17_3), true)

		if var_17_4 then
			local var_17_6 = tf(var_17_2).localScale
			local var_17_7 = tf(var_17_2):GetChild(0):Find("Quad"):GetComponent(typeof(MeshRenderer)).sharedMaterial
			local var_17_8 = var_17_7:GetColor("_MainColor")
			local var_17_9 = Clone(var_17_8)

			self:RecordTween("rumengAlphaTween", LeanTween.value(go(var_17_2), 0, 1, 0.8):setOnUpdate(System.Action_float(function(arg_18_0)
				var_17_9.a = var_17_8.a * arg_18_0

				var_17_7:SetColor("_MainColor", var_17_9)
			end)):setEase(LeanTweenType.easeInCubic):setOnComplete(System.Action(function()
				var_17_7:SetColor("_MainColor", var_17_8)
			end)).id)
		elseif var_17_5 then
			local var_17_10 = tf(var_17_3).localScale
			local var_17_11 = tf(var_17_3):GetChild(0):Find("Quad"):GetComponent(typeof(MeshRenderer)).sharedMaterial
			local var_17_12 = var_17_11:GetColor("_MainColor")
			local var_17_13 = Clone(var_17_12)

			self:RecordTween("huiguiAlphaTween", LeanTween.value(go(var_17_3), 0, 1, 0.8):setOnUpdate(System.Action_float(function(arg_20_0)
				var_17_13.a = var_17_12.a * arg_20_0

				var_17_11:SetColor("_MainColor", var_17_13)
			end)):setEase(LeanTweenType.easeInCubic):setOnComplete(System.Action(function()
				var_17_11:SetColor("_MainColor", var_17_12)
			end)).id)
		end
	end
end

function MapBuilderShinano:UpdateMapItems()
	MapBuilderShinano.super.UpdateMapItems(self)

	local var_22_0 = getProxy(ChapterProxy)

	self:UpdateBonusPtIconPath()
	table.clear(self.chapterTFsById)

	local var_22_1 = {}

	for iter_22_0, iter_22_1 in pairs(self.data:getChapters()) do
		if (iter_22_1:isUnlock() or iter_22_1:activeAlways()) and (not iter_22_1:ifNeedHide() or var_22_0:GetJustClearChapters(iter_22_1.id)) then
			table.insert(var_22_1, iter_22_1)
		end
	end

	UIItemList.StaticAlign(self.itemHolder, self.tpl, #var_22_1, function(arg_23_0, arg_23_1, arg_23_2)
		if arg_23_0 == UIItemList.EventUpdate then
			self:UpdateMapItem(arg_23_2, var_22_1[arg_23_1 + 1])

			arg_23_2.name = "Chapter_" .. var_22_1[arg_23_1 + 1].id
			self.chapterTFsById[var_22_1[arg_23_1 + 1].id] = arg_23_2
		end
	end)

	local var_22_2 = {}

	for iter_22_2, iter_22_3 in pairs(var_22_1) do
		local var_22_3 = iter_22_3:getConfigTable()

		var_22_2[var_22_3.pos_x] = var_22_2[var_22_3.pos_x] or {}
		var_22_2[var_22_3.pos_x][var_22_3.pos_y] = var_22_2[var_22_3.pos_x][var_22_3.pos_y] or {}

		table.insert(var_22_2[var_22_3.pos_x][var_22_3.pos_y], iter_22_3)
	end

	for iter_22_4, iter_22_5 in pairs(var_22_2) do
		for iter_22_6, iter_22_7 in pairs(iter_22_5) do
			local var_22_4 = {}

			seriesAsync({
				function(arg_24_0)
					local var_24_0 = 0

					for iter_24_0, iter_24_1 in pairs(iter_22_7) do
						if iter_24_1:ifNeedHide() and var_22_0:GetJustClearChapters(iter_24_1.id) and self.chapterTFsById[iter_24_1.id] then
							var_24_0 = var_24_0 + 1

							local var_24_1 = self.chapterTFsById[iter_24_1.id]

							setActive(self.chapterTFsById[iter_24_1.id], true)
							self:PlayChapterItemAnimationBackward(self.chapterTFsById[iter_24_1.id], iter_24_1, function()
								var_24_0 = var_24_0 - 1

								setActive(var_24_1, false)
								var_22_0:RecordJustClearChapters(iter_24_1.id, nil)

								if var_24_0 <= 0 then
									arg_24_0()
								end
							end)

							var_22_4[iter_24_1.id] = true
						elseif self.chapterTFsById[iter_24_1.id] then
							setActive(self.chapterTFsById[iter_24_1.id], false)
						end
					end

					if var_24_0 <= 0 then
						arg_24_0()
					end
				end,
				function(arg_26_0)
					local var_26_0 = 0

					for iter_26_0, iter_26_1 in pairs(iter_22_7) do
						if not var_22_4[iter_26_1.id] then
							var_26_0 = var_26_0 + 1

							setActive(self.chapterTFsById[iter_26_1.id], true)
							self:PlayChapterItemAnimation(self.chapterTFsById[iter_26_1.id], iter_26_1, function()
								var_26_0 = var_26_0 - 1

								if var_26_0 <= 0 then
									arg_26_0()
								end
							end)
						end
					end
				end
			})
		end
	end
end

function MapBuilderShinano:UpdateMapItem(arg_28_1, arg_28_2)
	local var_28_0 = arg_28_2:getConfigTable()

	setLocalPosition(arg_28_1, {
		x = 1920 * var_28_0.pos_x,
		y = 1080 * var_28_0.pos_y
	})

	local var_28_1 = findTF(arg_28_1, "main")

	setActive(var_28_1, true)
	setActive(findTF(var_28_1, "info/bk/fordark"), var_28_0.icon_outline == 1)

	local var_28_2 = findTF(var_28_1, "circle/clear_flag")
	local var_28_3 = findTF(var_28_1, "circle/lock")
	local var_28_4 = not arg_28_2.active and not arg_28_2:isUnlock()
	local var_28_5 = findTF(var_28_1, "circle/progress")
	local var_28_6 = findTF(var_28_1, "circle/progress_text")
	local var_28_7 = findTF(var_28_1, "circle/stars")
	local var_28_8 = string.split(var_28_0.name, "|")
	local var_28_9 = var_28_4 and "#737373" or "#FFFFFF"

	setText(findTF(var_28_1, "info/bk/title_form/title_index"), setColorStr(var_28_0.chapter_name .. "  ", var_28_4 and "#737373" or "#FFFFFF"))
	setText(findTF(var_28_1, "info/bk/title_form/title"), setColorStr(var_28_8[1], var_28_9))
	setText(findTF(var_28_1, "info/bk/title_form/title_en"), setColorStr(var_28_8[2] or "", var_28_9))
	setFillAmount(var_28_5, arg_28_2.progress / 100)
	setText(var_28_6, string.format("%d%%", arg_28_2.progress))
	setActive(var_28_7, arg_28_2:existAchieve())

	if arg_28_2:existAchieve() then
		for iter_28_0, iter_28_1 in ipairs(arg_28_2.achieves) do
			setActive(var_28_7:Find("star" .. iter_28_0 .. "/light"), (ChapterConst.IsAchieved(iter_28_1)))
		end
	end

	local var_28_10 = not arg_28_2.active and arg_28_2:isClear()

	setActive(var_28_2, var_28_10)
	setActive(var_28_3, var_28_4)
	setActive(var_28_6, not var_28_10 and not var_28_4)
	self:DeleteTween("fighting" .. arg_28_2.id)

	local var_28_11 = findTF(var_28_1, "circle/fighting")

	setText(findTF(var_28_11, "Text"), i18n("tag_level_fighting"))

	local var_28_12 = findTF(var_28_1, "circle/oni")

	setText(findTF(var_28_12, "Text"), i18n("tag_level_oni"))

	local var_28_13 = findTF(var_28_1, "circle/narrative")

	setText(findTF(var_28_13, "Text"), i18n("tag_level_narrative"))
	setActive(var_28_11, false)
	setActive(var_28_12, false)
	setActive(var_28_13, false)

	local var_28_14

	if arg_28_2:getConfig("chapter_tag") == 1 then
		var_28_14 = var_28_13
	end

	if arg_28_2.active then
		var_28_14 = arg_28_2:existOni() and var_28_12 or var_28_11
	end

	if var_28_14 then
		setActive(var_28_14, true)

		local var_28_16 = GetOrAddComponent(var_28_14, "CanvasGroup")

		var_28_16.alpha = 1

		self:RecordTween("fighting" .. arg_28_2.id, LeanTween.alphaCanvas(var_28_16, 0, 0.5):setFrom(1):setEase(LeanTweenType.easeInOutSine):setLoopPingPong().uniqueId)
	end

	local var_28_17 = findTF(var_28_1, "triesLimit")

	setActive(var_28_17, false)

	if arg_28_2:isTriesLimit() then
		local var_28_18 = arg_28_2:getConfig("count")

		setText(var_28_17:Find("label"), i18n("levelScene_chapter_count_tip"))

		local var_28_19 = setText

		var_28_19(var_28_17:Find("Text"), setColorStr(var_28_18 - arg_28_2:getTodayDefeatCount() .. "/" .. var_28_18, (var_28_18 <= arg_28_2:getTodayDefeatCount() or nil) and (COLOR_RED or COLOR_GREEN)))
	end

	local var_28_23 = arg_28_2:GetDailyBonusQuota()
	local var_28_24 = findTF(var_28_1, "mark")
	local var_28_25 = var_28_24:Find("bonus")
	local var_28_26 = var_28_25:Find("icon")
	local var_28_27 = findTF(var_28_25, "icon/Image")

	setActive(var_28_25, var_28_23)
	setActive(var_28_24, var_28_23)

	if var_28_26 then
		setActive(var_28_26, var_28_23 and self.bonusPtIconPath)
	end

	if var_28_23 then
		local var_28_28 = var_28_24:GetComponent(typeof(CanvasGroup))

		self.sceneParent.loader:GetSprite("ui/levelmainscene_atlas", arg_28_2:GetDailyBonusIconName(), var_28_25)

		if var_28_26 and self.bonusPtIconPath then
			if var_28_27 then
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_28_27, true)
			else
				GetImageSpriteFromAtlasAsync(self.bonusPtIconPath, "", var_28_26, true)
			end
		end

		LeanTween.cancel(go(var_28_24), true)

		local var_28_29 = var_28_24.anchoredPosition.y

		var_28_28.alpha = 0

		LeanTween.value(go(var_28_24), 0, 1, 0.2):setOnUpdate(System.Action_float(function(arg_29_0)
			var_28_28.alpha = arg_29_0
			var_28_24.anchoredPosition.y = var_28_29 * arg_29_0
			var_28_24.anchoredPosition = var_28_24.anchoredPosition
		end)):setOnComplete(System.Action(function()
			var_28_28.alpha = 1
			var_28_24.anchoredPosition.y = var_28_29
			var_28_24.anchoredPosition = var_28_24.anchoredPosition
		end)):setEase(LeanTweenType.easeOutSine):setDelay(0.7)
	end

	local var_28_30 = arg_28_2.id

	onButton(self, var_28_1, function()
		if self.chaptersInBackAnimating[var_28_30] then
			return
		end

		self:TryOpenChapterInfo(var_28_30, Vector3(arg_28_1.localPosition.x - 10, arg_28_1.localPosition.y + 150))
	end, SFX_UI_WEIGHANCHOR_SELECT)
end

function MapBuilderShinano:PlayChapterItemAnimation(arg_32_1, arg_32_2, arg_32_3)
	local var_32_0 = findTF(arg_32_1, "main")
	local var_32_1 = findTF(var_32_0, "circle")
	local var_32_2 = findTF(var_32_0, "info/bk")

	LeanTween.cancel(go(var_32_1))

	var_32_1.localScale = Vector3.zero

	self:RecordTween(LeanTween.scale(var_32_1, Vector3.one, 0.3):setDelay(0.3).uniqueId)
	LeanTween.cancel(go(var_32_2))
	setAnchoredPosition(var_32_2, {
		x = -1 * var_32_0:Find("info").rect.width
	})
	shiftPanel(var_32_2, 0, nil, 0.4, 0.4, true, true, nil, function()
		if arg_32_2:isTriesLimit() then
			setActive(findTF(var_32_0, "triesLimit"), true)
		end

		if arg_32_3 then
			arg_32_3()
		end
	end)
end

function MapBuilderShinano:PlayChapterItemAnimationBackward(arg_34_1, arg_34_2, arg_34_3)
	local var_34_0 = findTF(arg_34_1, "main")
	local var_34_1 = findTF(var_34_0, "circle")
	local var_34_2 = findTF(var_34_0, "info/bk")

	LeanTween.cancel(go(var_34_1))

	var_34_1.localScale = Vector3.one

	self:RecordTween(LeanTween.scale(go(var_34_1), Vector3.zero, 0.3):setDelay(0.3).uniqueId)

	self.chaptersInBackAnimating[arg_34_2.id] = true

	LeanTween.cancel(go(var_34_2))
	setAnchoredPosition(var_34_2, {
		x = 0
	})
	shiftPanel(var_34_2, -1 * var_34_0:Find("info").rect.width, nil, 0.4, 0.4, true, true, nil, function()
		self.chaptersInBackAnimating[arg_34_2.id] = nil

		if arg_34_3 then
			arg_34_3()
		end
	end)

	if arg_34_2:isTriesLimit() then
		setActive(findTF(var_34_0, "triesLimit"), false)
	end
end

function MapBuilderShinano:UpdateChapterTF(arg_36_1)
	if self.chapterTFsById[arg_36_1] then
		local var_36_0 = getProxy(ChapterProxy):getChapterById(arg_36_1)

		self:UpdateMapItem(self.chapterTFsById[arg_36_1], var_36_0)
		self:PlayChapterItemAnimation(self.chapterTFsById[arg_36_1], var_36_0)
	end
end

function MapBuilderShinano:TryOpenChapter(arg_37_1)
	if self.chapterTFsById[arg_37_1] then
		triggerButton((self.chapterTFsById[arg_37_1]:Find("main")))
	end
end

function MapBuilderShinano:HideFloat()
	setActive(self.itemHolder, false)
end

function MapBuilderShinano:ShowFloat()
	setActive(self.itemHolder, true)
end

return MapBuilderShinano
