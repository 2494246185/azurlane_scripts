local LevelInfoView = class("LevelInfoView", import("..base.BaseSubView"))

LevelInfoView.CHAPTER_GUIDE_NAME = "CHAPTER_AUTO_GUIDE"

function LevelInfoView:getUIName()
	return "LevelStageInfoView"
end

function LevelInfoView:getResource()
	return table.insertto({
		"ui/levelstageinfoview_atlas",
		"passstate"
	}, LevelInfoView.super.getResource(self))
end

function LevelInfoView:getLevelInfoViewResList(arg_3_1)
	local var_3_0 = {}
	local var_3_1 = arg_3_1 and arg_3_1:getConfigTable()

	if var_3_1 and var_3_1.icon and var_3_1.icon[1] then
		table.insert(var_3_0, (string.format(ResPathSupport.ConstPath.SpineQIcon.Base, var_3_1.icon[1], "")))
	end

	self:insertLevelInfoViewDropResList(var_3_0, arg_3_1)

	return var_3_0
end

function LevelInfoView:insertLevelInfoViewDropResList(arg_4_1, arg_4_2)
	if not arg_4_2 then
		return
	end

	_.each(LevelInfoView.getChapterAwards(arg_4_2), function(arg_5_0)
		local var_5_0 = Drop.Create(arg_5_0):getIcon()

		if noEmptyStr(var_5_0) then
			table.insert(arg_4_1, var_5_0)
		end
	end)
end

function LevelInfoView:downloadLevelInfoViewResList(arg_6_1, arg_6_2)
	SplitPackConst.DownloadByLuaArr(self:getLevelInfoViewResList(arg_6_1), function()
		if self._state == LevelInfoView.STATES.DESTROY then
			return
		end

		arg_6_2()
	end)
end

function LevelInfoView:OnInit()
	self.loader = AutoLoader.New()

	self:InitUI()
end

function LevelInfoView:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end

	self.onConfirm = nil
	self.onCancel = nil

	if self.LTid then
		LeanTween.cancel(self.LTid)

		self.LTid = nil
	end

	self.loader:Clear()
end

function LevelInfoView:Show()
	setActive(self._tf, true)
	self:BlurPanel(self._tf)
	self:CheckGuide()
end

function LevelInfoView:CheckGuide()
	if ChapterAutoProxy.IsSystemOpen() and pg.chapter_auto_statistics[self.chapter.id] then
		if pg.NewStoryMgr.GetInstance():IsPlayed(LevelInfoView.CHAPTER_GUIDE_NAME) then
			return
		end
	end

	onNextTick(function()
		if self._state == LevelInfoView.STATES.DESTROY or not self:isShowing() then
			return
		end

		if not pg.NewStoryMgr.GetInstance():IsPlayed(LevelInfoView.CHAPTER_GUIDE_NAME) then
			pg.NewGuideMgr.GetInstance():Play(LevelInfoView.CHAPTER_GUIDE_NAME)
			pg.m02:sendNotification(GAME.STORY_UPDATE, {
				storyId = LevelInfoView.CHAPTER_GUIDE_NAME
			})
		end
	end)
end

function LevelInfoView:Hide()
	self:clear()
	setActive(self._tf, false)
	self:UnOverlayPanel(self._tf, self._parentTf)
end

function LevelInfoView:setCBFunc(arg_14_1, arg_14_2)
	self.onConfirm = arg_14_1
	self.onCancel = arg_14_2
end

function LevelInfoView:InitUI()
	self.titleBG = self._tf:Find("panel/title")
	self.titleBGDecoration = self._tf:Find("panel/title/Image")
	self.titleIcon = self._tf:Find("panel/title/icon")
	self.txTitle = self._tf:Find("panel/title_form")
	self.txTitleOriginPosY = self.txTitle.anchoredPosition.y
	self.txTitleHead = self._tf:Find("panel/title_head")

	setActive(self.txTitleHead, false)

	self.txIntro = self._tf:Find("panel/intro")
	self.txCost = self._tf:Find("panel/cost/text")
	self.progressBar = self._tf:Find("panel/progress")
	self.txProgress = self._tf:Find("panel/progress/Text/value")
	self.progress = self._tf:Find("panel/progress")
	self.head = self._tf:Find("panel/head/Image")
	self.trAchieveTpl = self._tf:Find("panel/achieve")
	self.trAchieves = self._tf:Find("panel/achieves")
	self.passStateMask = self._tf:Find("panel/passState")
	self.passState = self._tf:Find("panel/passState/Image")

	setActive(self.passState, true)

	self.winCondDesc = self._tf:Find("panel/win_conditions/desc")
	self.winCondAwardBtn = self._tf:Find("panel/win_conditions/icon")
	self.loseCondDesc = self._tf:Find("panel/lose_conditions/desc")
	self.achieveList = UIItemList.New(self.trAchieves, self.trAchieveTpl)

	setActive(self.trAchieveTpl, false)

	self.trDropTpl = self._tf:Find("panel/drops/frame/list/item")
	self.trDrops = self._tf:Find("panel/drops/frame/list")
	self.dropList = UIItemList.New(self.trDrops, self.trDropTpl)

	self.dropList:make(function(arg_16_0, arg_16_1, arg_16_2)
		self:updateDrop(arg_16_0, arg_16_1, arg_16_2)
	end)
	setActive(self.trDropTpl, false)

	self.btnAuto = self._tf:Find("panel/auto_button")
	self.btnConfirm = self._tf:Find("panel/start_button")
	self.btnConfirm_l = self._tf:Find("panel/start_button_l")
	self.btnCancel = self._tf:Find("panel/btnBack")
	self.quickPlayGroup = self._tf:Find("panel/quickPlay")
	self.descQuickPlay = self.quickPlayGroup:Find("desc")
	self.toggleQuickPlay = self.quickPlayGroup:GetComponent(typeof(Toggle))
	self.bottomExtra = self._tf:Find("panel/BottomExtra")
	self.layoutView = GetComponent(self.bottomExtra:Find("LoopGroup/view"), typeof(LayoutElement))
	self.rtViewContainer = self.bottomExtra:Find("LoopGroup/view/container")

	setText(self.bottomExtra:Find("LoopGroup/Loop/Text"), i18n("autofight_farm"))

	self.loopToggle = self.bottomExtra:Find("LoopGroup/Loop/Toggle")
	self.loopOn = self.loopToggle:Find("on")
	self.loopOff = self.loopToggle:Find("off")
	self.loopHelp = self.bottomExtra:Find("ButtonHelp")
	self.costLimitTip = self.bottomExtra:Find("LoopGroup/view/container/CostLimit")

	setActive(self.costLimitTip, false)

	self.autoFightToggle = self.bottomExtra:Find("LoopGroup/view/container/AutoFight")

	setText(self.autoFightToggle:Find("Text"), i18n("autofight"))

	self.delayTween = {}
	self.doEaseIn = true
end

local var_0_1 = 525
local var_0_2 = 373

function LevelInfoView:set(arg_17_1, arg_17_2)
	local var_17_0 = getProxy(ChapterProxy):getChapterById(arg_17_1, true)

	self:downloadLevelInfoViewResList(var_17_0, function()
		self:setAfterResDownload(arg_17_1, arg_17_2, var_17_0)
	end)
end

function LevelInfoView:setAfterResDownload(arg_19_1, arg_19_2, arg_19_3)
	self:cancelTween()

	self.chapter = arg_19_3
	self.posStart = arg_19_2 or Vector3(0, 0, 0)

	local var_19_0 = getProxy(ChapterProxy):getMapById(arg_19_3:getConfig("map"))
	local var_19_1 = arg_19_3:getConfigTable()
	local var_19_2 = string.split(var_19_1.name, "|")
	local var_19_3 = arg_19_3:getPlayType() == ChapterConst.TypeDefence

	GetSpriteFromAtlasAsync("ui/levelstageinfoview_atlas", var_19_3 and "title_print_defense" or "title_print", function(arg_20_0)
		if not IsNil(self.titleBGDecoration) then
			self.titleBGDecoration:GetComponent(typeof(Image)).sprite = arg_20_0
		end
	end)
	GetSpriteFromAtlasAsync("ui/levelstageinfoview_atlas", var_19_3 and "titlebar_bg_defense" or "titlebar_bg", function(arg_21_0)
		if not IsNil(self.titleBG) then
			self.titleBG:GetComponent(typeof(Image)).sprite = arg_21_0
		end
	end)
	setActive(self.titleIcon, var_19_3)

	local var_19_4 = self.progressBar.sizeDelta

	if var_19_3 then
		var_19_4.x = var_0_2 or var_0_1
	end

	self.progressBar.sizeDelta = var_19_4

	setText(self.txTitle:Find("title_index"), var_19_1.chapter_name .. "  ")
	setText(self.txTitle:Find("title"), var_19_2[1])
	setText(self.txTitle:Find("title_en"), var_19_2[2] or "")
	setActive(self.txTitleHead, var_19_2[3] and #var_19_2[3] > 0)
	setAnchoredPosition(self.txTitle, {
		y = (var_19_2[3] and #var_19_2[3] > 0 or nil) and (self.txTitleOriginPosY or self.txTitleOriginPosY + 8)
	})
	setText(self.txTitleHead, var_19_2[3] or "")
	setText(self.winCondDesc, i18n("text_win_condition") .. "：" .. i18n(arg_19_3:getConfig("win_condition_display")))
	setText(self.loseCondDesc, i18n("text_lose_condition") .. "：" .. i18n(arg_19_3:getConfig("lose_condition_display")))
	setActive(self.winCondAwardBtn, arg_19_3:getPlayType() == ChapterConst.TypeDefence)

	if not arg_19_3:existAchieve() then
		setActive(self.passState, false)
		setActive(self.progress, false)
		setActive(self.trAchieves, false)
	else
		setActive(self.passState, true)
		setActive(self.progress, true)
		setActive(self.trAchieves, true)

		self.passState.localPosition = Vector3(-self.passState.rect.width, 0, 0)

		local var_19_5 = arg_19_3:hasMitigation()

		setActive(self.passState, var_19_5)

		if var_19_5 then
			setImageSprite(self.passState, GetSpriteFromAtlas("passstate", (arg_19_3:getRiskLevel())), true)
		end

		setWidgetText(self.progress, i18n("levelScene_threat_to_rule_out", ": "))
		table.insert(self.delayTween, LeanTween.value(go(self.progress), 0, arg_19_3.progress, 0.5):setDelay(0.15):setOnUpdate(System.Action_float(function(arg_22_0)
			setSlider(self.progress, 0, 100, arg_22_0)
			setText(self.txProgress, math.floor(arg_22_0) .. "%")
		end)).uniqueId)
		self.achieveList:align(#arg_19_3.achieves)
		self.achieveList:each(function(arg_23_0, arg_23_1)
			local var_23_0 = findTF(arg_23_1, "desc")

			setText(var_23_0, ChapterConst.GetAchieveDesc(arg_19_3.achieves[arg_23_0 + 1].type, arg_19_3))
			setTextColor(var_23_0, Color.white)
			setActive(findTF(arg_23_1, "star"), false)
			setActive(findTF(arg_23_1, "star_empty"), true)

			local var_23_1 = ChapterConst.IsAchieved(arg_19_3.achieves[arg_23_0 + 1])

			table.insert(self.delayTween, LeanTween.delayedCall(0.15 + (arg_23_0 + 1) * 0.15, System.Action(function()
				if not IsNil(arg_23_1) then
					setTextColor(findTF(arg_23_1, "desc"), (var_23_1 or nil) and (Color.yellow or Color.white))
					setActive(findTF(arg_23_1, "star"), var_23_1)
					setActive(findTF(arg_23_1, "star_empty"), not var_23_1)
				end
			end)).uniqueId)
		end)
	end

	setText(self.txIntro, var_19_1.profiles)
	setText(self.txCost, var_19_1.oil)

	if var_19_1.icon and var_19_1.icon[1] then
		setActive(self.head.parent, true)
		setImageSprite(self.head, LoadSprite("qicon/" .. var_19_1.icon[1]))
	else
		setActive(self.head.parent, false)
	end

	self.awards = LevelInfoView.getChapterAwards(self.chapter)

	self.dropList:align(#self.awards)

	local var_19_6 = arg_19_3:existLoop()

	setActive(self.bottomExtra, var_19_6)

	if var_19_6 then
		local var_19_7 = arg_19_3:canActivateLoop()
		local var_19_8 = "chapter_loop_flag_" .. arg_19_3.id
		local var_19_9 = PlayerPrefs.GetInt("chapter_loop_flag_" .. arg_19_3.id, -1)
		local var_19_10 = (var_19_9 == 1 or var_19_9 == -1) and var_19_7
		local var_19_11 = #arg_19_3:getConfig("use_oil_limit") > 0

		setActive(self.loopOn, (var_19_9 == 1 or var_19_9 == -1) and var_19_7)
		setActive(self.loopOff, not var_19_10)
		setActive(self.costLimitTip, var_19_11)
		onNextTick(function()
			Canvas.ForceUpdateCanvases()

			if var_19_10 then
				self.layoutView.preferredWidth = self.rtViewContainer.rect.width or 0
			end
		end)
		onButton(self, self.loopToggle, function()
			if not var_19_7 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_activate_loop_mode_failed"))

				return
			end

			local var_26_0 = not self.loopOn.gameObject.activeSelf

			PlayerPrefs.SetInt(var_19_8, not self.loopOn.gameObject.activeSelf and 1 or 0)
			PlayerPrefs.Save()
			setActive(self.loopOn, var_26_0)
			setActive(self.loopOff, not var_26_0)

			local var_26_1 = 0
			local var_26_2 = 0

			if var_26_0 then
				var_26_2 = self.rtViewContainer.rect.width
			else
				var_26_1 = self.rtViewContainer.rect.width
			end

			if self.LTid then
				LeanTween.cancel(self.LTid)

				self.LTid = nil
			end

			self.LTid = LeanTween.value(var_26_1, var_26_2, 0.3):setOnUpdate(System.Action_float(function(arg_27_0)
				self.layoutView.preferredWidth = arg_27_0
			end)):setOnComplete(System.Action(function()
				self.LTid = nil
			end)).uniqueId
		end, SFX_PANEL)
		onButton(self, self.loopHelp, function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = i18n("levelScene_loop_help_tip")
			})
		end)

		local var_19_12 = AutoBotCommand.autoBotSatisfied()
		local var_19_13 = "chapter_autofight_flag_" .. arg_19_3.id
		local var_19_14 = var_19_12 and PlayerPrefs.GetInt("chapter_autofight_flag_" .. arg_19_3.id, 1) == 1

		onToggle(self, self.autoFightToggle, function(arg_30_0)
			if arg_30_0 ~= var_19_14 then
				var_19_14 = arg_30_0

				PlayerPrefs.SetInt(var_19_13, var_19_14 and 1 or 0)
				PlayerPrefs.Save()
			end
		end, SFX_UI_TAG)
		triggerToggle(self.autoFightToggle, var_19_14)
		setActive(self.autoFightToggle, var_19_12)
	end

	onButton(self, self.btnConfirm, function()
		if getProxy(BayProxy):getShipCount() >= getProxy(PlayerProxy):getRawData():getMaxShipBag() then
			NoPosMsgBox(i18n("switch_to_shop_tip_noDockyard"), openDockyardClear, gotoChargeScene, openDockyardIntensify)

			return
		end

		if not self.onConfirm then
			return
		end

		self.onConfirm(arg_19_1, var_19_6 and self.loopOn.gameObject.activeSelf and 1 or 0)
	end, SFX_UI_WEIGHANCHOR_GO)
	onButton(self, self.btnConfirm_l, function()
		triggerButton(self.btnConfirm)
	end, SFX_UI_WEIGHANCHOR_GO)
	onButton(self, self.btnCancel, function()
		if self.onCancel then
			self.onCancel()
		end
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("bg"), function()
		if self.onCancel then
			self.onCancel()
		end
	end, SFX_CANCEL)

	if not arg_19_3:getConfig("risk_levels") then
		-- block empty
	end

	onButton(self, self.passState, function()
		if not arg_19_3:hasMitigation() then
			return
		end

		local var_35_0 = i18n("level_risk_level_desc", arg_19_3:getChapterState()) .. i18n("level_risk_level_mitigation_rate", arg_19_3:getRemainPassCount(), arg_19_3:getMitigationRate())

		if var_19_0:getMapType() == Map.ELITE then
			var_35_0 = var_35_0 .. "\n" .. i18n("level_diffcult_chapter_state_safety")
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			hideNo = true,
			content = var_35_0
		})
	end, SFX_PANEL)
	onButton(self, self.head, function()
		triggerButton(self.passState)
	end, SFX_PANEL)
	onButton(self, self.winCondAwardBtn, function()
		self:ShowChapterRewardPanel()
	end)
	setText(self.descQuickPlay, i18n("desc_quick_play"))

	local var_19_16 = arg_19_3:CanQuickPlay()

	setActive(self.quickPlayGroup, var_19_16)

	if var_19_16 then
		local var_19_17 = "chapter_quickPlay_flag_" .. arg_19_3.id
		local var_19_18 = PlayerPrefs.GetInt("chapter_quickPlay_flag_" .. arg_19_3.id, 1)

		onToggle(self, self.toggleQuickPlay, function(arg_38_0)
			PlayerPrefs.SetInt(var_19_17, arg_38_0 and 1 or 0)
			PlayerPrefs.Save()
		end, SFX_PANEL)
		triggerToggle(self.toggleQuickPlay, var_19_18 == 1)
	end

	if self.doEaseIn then
		local var_19_19 = self._tf:Find("panel")

		var_19_19.transform.localPosition = self.posStart

		table.insert(self.delayTween, LeanTween.move(var_19_19, Vector3.zero, 0.2).uniqueId)

		var_19_19.localScale = Vector3.zero

		table.insert(self.delayTween, LeanTween.scale(var_19_19, Vector3(1, 1, 1), 0.2).uniqueId)
		table.insert(self.delayTween, LeanTween.moveX(self.passState, 0, 0.35):setEase(LeanTweenType.easeInOutSine):setDelay(0.3).uniqueId)
	end

	self:UpdateChapterAutoBtn()
end

function LevelInfoView:UpdateChapterAutoBtn()
	local var_39_0 = ChapterAutoProxy.IsSystemOpen()

	setActive(self.btnAuto, pg.chapter_auto_statistics[self.chapter.id])
	setActive(self.btnConfirm, pg.chapter_auto_statistics[self.chapter.id])
	setActive(self.btnConfirm_l, not pg.chapter_auto_statistics[self.chapter.id])

	if not pg.chapter_auto_statistics[self.chapter.id] then
		return
	end

	local var_39_2 = var_39_0 and self.chapter:isClear() and getProxy(ChapterAutoProxy):GetRecord(ChapterAutoProxy.TYPE.SLG, self.chapter.id) > 0

	setGray(self.btnAuto, not (var_39_0 and self.chapter:isClear() and getProxy(ChapterAutoProxy):GetRecord(ChapterAutoProxy.TYPE.SLG, self.chapter.id) > 0), true)
	onButton(self, self.btnAuto, function()
		if var_39_2 then
			local var_40_0 = getProxy(ChapterAutoProxy):GetCommissionDoingType()

			if not var_40_0 then
				self:ShowChapterAutoPanel()
			else
				self:CheckChapterAutoOccupied(var_40_0)
			end
		elseif var_39_0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_chapter_unlock_tip"))
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("auto_battle_unlock_tip"))
		end
	end, SFX_PANEL)
end

function LevelInfoView:CheckChapterAutoOccupied(arg_41_1)
	switch(arg_41_1, {
		[ChapterAutoProxy.TYPE.WORLD] = function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_battle_in_world"),
				onYes = function()
					pg.m02:sendNotification(GAME.GO_SCENE, SCENE.WORLD)
				end,
				yesText = i18n("auto_drop_is_activation_go"),
				noText = i18n("auto_drop_is_activation_cancle")
			})
		end
	})
end

function LevelInfoView:cancelTween()
	_.each(self.delayTween, function(arg_45_0)
		LeanTween.cancel(arg_45_0)
	end)

	self.delayTween = {}
end

function LevelInfoView:updateDrop(arg_46_1, arg_46_2, arg_46_3)
	if arg_46_1 == UIItemList.EventUpdate then
		local var_46_0 = Drop.Create(self.awards[arg_46_2 + 1])

		updateDrop(arg_46_3, var_46_0)
		onButton(self, arg_46_3, function()
			if ({
				[99] = true
			})[var_46_0:getConfig("type")] then
				self:emit(LevelMediator2.GET_CHAPTER_DROP_SHIP_LIST, self.chapter.id, function(arg_48_0)
					local var_48_0 = {}

					for iter_48_0, iter_48_1 in ipairs((var_46_0:getConfig("display_icon"))) do
						local var_48_1 = iter_48_1[2]

						var_48_0[#var_48_0 + 1] = {
							type = iter_48_1[1],
							id = iter_48_1[2],
							anonymous = iter_48_1[1] == DROP_TYPE_SHIP and not table.contains(arg_48_0, var_48_1)
						}
					end

					self:emit(BaseUI.ON_DROP_LIST, {
						item2Row = true,
						itemList = var_48_0,
						content = var_46_0:getConfig("display")
					})
					self:initTestShowDrop(var_46_0, Clone(var_48_0))
				end)
			else
				self:emit(BaseUI.ON_DROP, var_46_0)
			end
		end, SFX_PANEL)
	end
end

function LevelInfoView:getChapterAwards()
	local var_49_0 = Clone(self:getConfig("awards"))
	local var_49_1 = self:getStageExtraAwards()

	if var_49_1 then
		for iter_49_0 = #var_49_1, 1, -1 do
			table.insert(var_49_0, 1, var_49_1[iter_49_0])
		end
	end

	local function var_49_2(arg_50_0)
		return _.all(arg_50_0, function(arg_51_0)
			return #arg_51_0 >= 3
		end)
	end

	local var_49_3 = {
		self:getConfig("boss_expedition_id"),
		self:getConfig("ai_expedition_list")
	}
	local var_49_5
	local var_49_4

	if self:getPlayType() == ChapterConst.TypeMultiStageBoss then
		table.insert(var_49_3, pg.chapter_model_multistageboss[self.id].boss_expedition_id)

		var_49_4 = {}
		var_49_5 = {}
	end

	for iter_49_1, iter_49_2 in ipairs((_.flatten(var_49_3))) do
		local var_49_6 = checkExist(pg.expedition_activity_template[iter_49_2], {
			"pt_drop_display"
		})

		if var_49_6 and type(var_49_6) == "table" and var_49_2(var_49_6) then
			for iter_49_3, iter_49_4 in ipairs(var_49_6) do
				local var_49_7, var_49_8, var_49_9, var_49_10 = unpack(iter_49_4)

				if not var_49_5[var_49_8 .. "_" .. var_49_9] then
					var_49_5[var_49_8 .. "_" .. var_49_9] = {}

					table.insert(var_49_4, var_49_8 .. "_" .. var_49_9)
				end

				var_49_5[var_49_8 .. "_" .. var_49_9][var_49_7] = var_49_10
			end
		end
	end

	local var_49_11 = getProxy(ActivityProxy)

	for iter_49_5 = #var_49_4, 1, -1 do
		local var_49_12, var_49_13 = unpack(underscore.map(string.split(var_49_4[iter_49_5], "_"), function(arg_52_0)
			return tonumber(arg_52_0)
		end))

		for iter_49_6, iter_49_7 in pairs(var_49_5[var_49_4[iter_49_5]]) do
			local var_49_14 = var_49_11:getActivityById(iter_49_6)

			if var_49_14 and not var_49_14:isEnd() then
				if var_49_12 == DROP_TYPE_RESOURCE then
					table.insert(var_49_0, 1, {
						DROP_TYPE_ITEM,
						id2ItemId(var_49_13),
						iter_49_7
					})

					break
				end

				table.insert(var_49_0, 1, {
					var_49_12,
					var_49_13,
					iter_49_7
				})

				break
			end
		end
	end

	return var_49_0
end

function LevelInfoView:initTestShowDrop(arg_53_1, arg_53_2)
	if IsUnityEditor then
		local var_53_0 = pg.MsgboxMgr.GetInstance()._go
		local var_53_1 = var_53_0.transform:Find("button_test_show_drop")

		if IsNil(var_53_1) then
			var_53_1 = GameObject.New("button_test_show_drop")

			var_53_1:AddComponent(typeof(Button))
			var_53_1:AddComponent(typeof(RectTransform))
			var_53_1:AddComponent(typeof(Image))
		end

		local var_53_2 = var_53_1:GetComponent(typeof(RectTransform))

		var_53_2:SetParent(var_53_0.transform, false)

		var_53_2.anchoredPosition = Vector3(-239, 173, 0)
		var_53_2.sizeDelta = Vector2(40, 40)

		onButton(self, var_53_2, function()
			_.each(arg_53_2, function(arg_55_0)
				arg_55_0.anonymous = false
			end)
			self:emit(BaseUI.ON_DROP_LIST, {
				item2Row = true,
				itemList = arg_53_2,
				content = arg_53_1:getConfig("display")
			})
		end)
	end
end

function LevelInfoView:clearTestShowDrop()
	if IsUnityEditor then
		local var_56_0 = pg.MsgboxMgr.GetInstance()._go.transform:Find("button_test_show_drop")

		if not IsNil(var_56_0) then
			Destroy(var_56_0)
		end
	end
end

function LevelInfoView:ShowChapterRewardPanel()
	if self.rewardPanel == nil then
		self.rewardPanel = ChapterRewardPanel.New(self._tf.parent, self.event, self.contextData)

		self.rewardPanel:Load()
	end

	self.rewardPanel:ActionInvoke("Enter", self.chapter)
end

function LevelInfoView:ClearChapterRewardPanel()
	if self.rewardPanel ~= nil then
		self.rewardPanel:Destroy()

		self.rewardPanel = nil
	end
end

function LevelInfoView:ShowChapterAutoPanel()
	if self.autoPanel == nil then
		self.autoPanel = ChapterAutoPanel.New(self._tf, self.event, self.contextData)

		self.autoPanel:Load()
	end

	self.autoPanel:ActionInvoke("Enter", self.chapter)
end

function LevelInfoView:RefreshChapterAutoPanel()
	if self.autoPanel and self.autoPanel:isShowing() then
		self.autoPanel:ActionInvoke("RefreshView")
	end
end

function LevelInfoView:ClearChapterAutoPanel()
	if self.autoPanel ~= nil then
		self.autoPanel:Destroy()

		self.autoPanel = nil
	end
end

function LevelInfoView:clear()
	self:cancelTween()
	self.dropList:each(function(arg_63_0, arg_63_1)
		clearDrop(arg_63_1)
	end)
	self:clearTestShowDrop()
	self:ClearChapterRewardPanel()
	self:ClearChapterAutoPanel()
end

return LevelInfoView
