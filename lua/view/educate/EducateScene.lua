local EducateScene = class("EducateScene", import(".base.EducateBaseUI"))

function EducateScene:getUIName()
	return "EducateUI"
end

function EducateScene:preload(arg_2_1)
	pg.PerformMgr.GetInstance():CheckLoad(function()
		arg_2_1()
	end)
end

function EducateScene:getResource()
	local var_4_0 = EducateScene.super.getResource(self)
	local var_4_1 = {
		"ui/EducateDatePanel",
		"ui/EducateFavorPanel",
		"ui/EducateResPanel",
		"ui/EducateTopPanel",
		"ui/EducateTargetPanel",
		"ui/EducateBottomPanel",
		"ui/EducateArchivePanel",
		"ui/educatecommonui_atlas"
	}

	local function var_4_2(arg_5_0)
		if noEmptyStr(arg_5_0) and not table.contains(var_4_1, arg_5_0) then
			table.insert(var_4_1, arg_5_0)
		end
	end

	local var_4_3 = getProxy(EducateProxy)
	local var_4_4 = var_4_3 and var_4_3:GetCharData()

	if var_4_4 then
		for iter_4_0, iter_4_1 in ipairs(var_4_4:getConfig("background_prefab") or {}) do
			var_4_2("bg/" .. iter_4_1)
		end

		local var_4_5 = {}

		for iter_4_2, iter_4_3 in ipairs(var_4_4:getConfig("char_prefab") or {}) do
			if noEmptyStr(iter_4_3[3]) and not var_4_5[iter_4_3[3]] then
				var_4_5[iter_4_3[3]] = true

				PaintingGroupConst.AddPaintingNameWithFilteMap(var_4_1, iter_4_3[3])
				var_4_2("paintingface/" .. iter_4_3[3])
				var_4_2("educateavatar/" .. iter_4_3[3])
				var_4_2("squareicon/" .. iter_4_3[3])
			end
		end

		for iter_4_4, iter_4_5 in ipairs(var_4_4:getConfig("bgm") or {}) do
			if type(iter_4_5) == "string" then
				var_4_2("cue/bgm-" .. iter_4_5 .. ".b")
			elseif type(iter_4_5) == "table" then
				for iter_4_6, iter_4_7 in ipairs(iter_4_5) do
					if type(iter_4_7) == "table" then
						var_4_2("cue/bgm-" .. iter_4_7[2] .. ".b")
					end
				end
			end
		end
	end

	if var_4_3 then
		for iter_4_8, iter_4_9 in ipairs(var_4_3:GetBuffList() or {}) do
			var_4_2("educateprops/" .. iter_4_9:getConfig("icon"))
		end
	end

	for iter_4_10, iter_4_11 in ipairs(var_4_1) do
		if not table.contains(var_4_0, iter_4_11) then
			table.insert(var_4_0, iter_4_11)
		end
	end

	return var_4_0
end

function EducateScene:init()
	self:initData()
	self:findUI()
	self:addListener()
end

function EducateScene:PlayBGM()
	local var_7_0 = getProxy(EducateProxy):GetCharData():GetBgm()

	if var_7_0 then
		pg.BgmMgr.GetInstance():Push(self.__cname, var_7_0)
	end
end

function EducateScene:initData()
	return
end

function EducateScene:findUI()
	self.mainAnim = self._tf:Find("anim_root"):GetComponent(typeof(Animation))
	self.bgTF = self._tf:Find("anim_root/bg")
	self.blurPanel = self._tf:Find("anim_root/blur_panel")
	self.blurPanelAnim = self.blurPanel:GetComponent(typeof(Animation))
	self.topTF = self.blurPanel:Find("top")
	self.favorBtn = self.topTF:Find("favor")
	self.favorLvTF = self.favorBtn:Find("anim_root/Text")
	self.favorMaxTF = self.favorBtn:Find("anim_root/max")
	self.favorBtnAnim = self.favorBtn:Find("anim_root"):GetComponent(typeof(Animation))
	self.favorBtnAnimEvent = self.favorBtn:Find("anim_root"):GetComponent(typeof(DftAniEvent))

	self.favorBtnAnimEvent:SetTriggerEvent(function()
		self:updateFavorBtn()
	end)

	self.mainTF = self._tf:Find("anim_root/main")
	self.paintTF = self.mainTF:Find("painting")
	self.dialogueTF = self.blurPanel:Find("dialogue")
	self.dialogueContent = self.dialogueTF:Find("content")

	setActive(self.dialogueTF, false)

	self.bubbleTF = self._tf:Find("anim_root/blur_panel/bubble")

	setActive(self.bubbleTF, false)

	self.bubbleBtn = self.bubbleTF:Find("bubble")
	self.optionsTF = self.mainTF:Find("options")
	self.chatBtn = self.optionsTF:Find("options/chat")
	self.giftBtn = self.optionsTF:Find("options/gift")

	setActive(self.optionsTF, false)

	self.bottomTF = self.blurPanel:Find("bottom")
	self.bookBtn = self.bottomTF:Find("left/btns/book")

	setText(self.bookBtn:Find("unlock/Text"), i18n("child_btn_collect"))

	self.mindBtn = self.bottomTF:Find("left/btns/mind")

	setText(self.mindBtn:Find("unlock/Text"), i18n("child_btn_mind"))

	self.bagBtn = self.bottomTF:Find("left/btns/bag")

	setText(self.bagBtn:Find("unlock/Text"), i18n("child_btn_bag"))

	self.datePanel = EducateDatePanel.New(self.topTF:Find("date"), self.event, {
		isMain = true
	})

	self.datePanel:RegisterView(self)

	self.favorPanel = EducateFavorPanel.New(self.topTF:Find("favor_panel"), self.event)

	self.favorPanel:RegisterView(self)

	self.resPanel = EducateResPanel.New(self.topTF:Find("res"), self.event)

	self.resPanel:RegisterView(self)

	self.topPanel = EducateTopPanel.New(self.topTF:Find("top_right"), self.event)

	self.topPanel:RegisterView(self)

	self.targetPanel = EducateTargetPanel.New(self.topTF:Find("target"), self.event)

	self.targetPanel:RegisterView(self)

	self.bottomPanel = EducateBottomPanel.New(self.bottomTF:Find("right"), self.event, {
		isMainEnter = self.contextData.isMainEnter
	})

	self.bottomPanel:RegisterView(self)

	self.archivePanel = EducateArchivePanel.New(self.mainTF:Find("archive_panel"), self.event, {
		isShow = true,
		isMainEnter = self.contextData.isMainEnter
	})

	self.archivePanel:RegisterView(self)
end

function EducateScene:_loadSubViews()
	self.datePanel:Load()
	self.favorPanel:Load()
	self.resPanel:Load()
	self.topPanel:Load()
	self.targetPanel:Load()
	self.bottomPanel:Load()
	self.archivePanel:Load()
	self:OverlayPanel(self.blurPanel, {
		pbList = {
			self.blurPanel:Find("bottom/left")
		}
	})
	self.mainAnim:Play(self.contextData.isMainEnter and "anim_educate_educateUI_bg_in" or "anim_educate_educateUI_bg_show")
	self.blurPanelAnim:Play(self.contextData.isMainEnter and "anim_educate_educateUI_in" or "anim_educate_educateUI_show")
end

function EducateScene:addListener()
	onButton(self, self.chatBtn, function()
		pg.TipsMgr.GetInstance():ShowTips("触发对话[待开发]...")
	end, SFX_PANEL)
	onButton(self, self.giftBtn, function()
		pg.TipsMgr.GetInstance():ShowTips("送礼(?)...")
	end, SFX_PANEL)
	onButton(self, self.favorBtn, function()
		self.favorPanel:Show()
	end, SFX_PANEL)
	onButton(self, self.bookBtn, function()
		self:emit(EducateScene.EDUCATE_GO_SUBLAYER, Context.New({
			mediator = EducateCollectEntranceMediator,
			viewComponent = EducateCollectEntranceLayer
		}))
	end, SFX_PANEL)
	onButton(self, self.mindBtn, function()
		if isActive(self.mindBtn:Find("lock")) then
			return
		end

		self:emit(EducateScene.EDUCATE_GO_SUBLAYER, Context.New({
			mediator = EducateMindMediator,
			viewComponent = EducateMindLayer,
			data = {
				onExit = function()
					self:checkBubbleShow()
				end
			}
		}))
	end, SFX_PANEL)
	onButton(self, self.bagBtn, function()
		if isActive(self.bagBtn:Find("lock")) then
			return
		end

		self:emit(EducateScene.EDUCATE_GO_SUBLAYER, Context.New({
			mediator = EducateBagMediator,
			viewComponent = EducateBagLayer
		}))
	end, SFX_PANEL)
	onButton(self, self.paintTF:Find("fitter"), function()
		self:ShowDialogue()
	end, SFX_PANEL)
end

function EducateScene:didEnter()
	if self.contextData.onEnter then
		self.contextData.onEnter()

		self.contextData.onEnter = nil
	end

	self:updatePaintingUI()
	self:updateUnlockBtns()
	self:updateNewTips()
	self:updateMindTip()
	self:updateFavorBtn()
	self:SeriesCheck()
end

function EducateScene:SeriesCheck()
	local var_22_0 = {}

	table.insert(var_22_0, function(arg_23_0)
		self:CheckNewChar(arg_23_0)
	end)
	table.insert(var_22_0, function(arg_24_0)
		if getProxy(EducateProxy):GetPlanProxy():CheckExcute() then
			self:emit(EducateMediator.ON_EXECTUE_PLANS)
		else
			arg_24_0()
		end
	end)
	table.insert(var_22_0, function(arg_25_0)
		self:CheckTips(arg_25_0)
	end)
	table.insert(var_22_0, function(arg_26_0)
		if getProxy(EducateProxy):GetEventProxy():NeedGetHomeEventData() then
			self:emit(EducateMediator.ON_GET_EVENT, arg_26_0)
		else
			arg_26_0()
		end
	end)
	self:checkBubbleShow()
	table.insert(var_22_0, function(arg_27_0)
		if not self.contextData.ingoreGuideCheck then
			EducateGuideSequence.CheckGuide(self.__cname, arg_27_0)
		else
			self.contextData.ingoreGuideCheck = nil

			arg_27_0()
		end
	end)
	seriesAsync(var_22_0, function()
		return
	end)
end

function EducateScene:OnCheckGuide(arg_29_1)
	EducateGuideSequence.CheckGuide(self.__cname, function()
		existCall(arg_29_1)
	end)
end

function EducateScene:CheckTips(arg_31_1)
	local var_31_0 = {}

	for iter_31_0, iter_31_1 in ipairs(EducateTipHelper.GetSystemUnlockTips()) do
		table.insert(var_31_0, function(arg_32_0)
			self:emit(EducateScene.EDUCATE_ON_UNLOCK_TIP, {
				type = EducateUnlockTipLayer.UNLOCK_TYPE_SYSTEM,
				single = iter_31_1,
				onExit = arg_32_0
			})
		end)
	end

	seriesAsync(var_31_0, function()
		arg_31_1()
	end)
end

function EducateScene:CheckNewChar(arg_34_1)
	if getProxy(EducateProxy):GetCharData():GetCallName() == "" then
		setActive(self._tf, false)

		local var_34_0 = {}

		table.insert(var_34_0, function(arg_35_0)
			pg.PerformMgr.GetInstance():PlayGroup(EducateConst.FIRST_ENTER_PERFORM_IDS, arg_35_0)
		end)
		table.insert(var_34_0, function(arg_36_0)
			self:emit(EducateScene.EDUCATE_GO_SUBLAYER, Context.New({
				mediator = EducateNewCharMediator,
				viewComponent = EducateNewCharLayer,
				data = {
					callback = arg_36_0
				}
			}))
		end)
		table.insert(var_34_0, function(arg_37_0)
			pg.PerformMgr.GetInstance():PlayOne(EducateConst.AFTER_SET_CALLNAME_PERFORM_ID, arg_37_0)
		end)
		seriesAsync(var_34_0, function()
			setActive(self._tf, true)
			self:_loadSubViews()
			arg_34_1()
		end)
	else
		self:_loadSubViews()
		arg_34_1()
	end
end

function EducateScene:showBubble(arg_39_1)
	setActive(self.bubbleTF, true)
	onButton(self, self.bubbleBtn, function()
		arg_39_1()
		setActive(self.bubbleTF, false)
	end, SFX_PANEL)
end

function EducateScene:PlayPerformWithDrops(arg_41_1, arg_41_2, arg_41_3)
	local var_41_0 = EducateHelper.GetCommonShowDrops(arg_41_2)

	local function var_41_1()
		if #var_41_0 > 0 then
			self:emit(EducateScene.EDUCATE_ON_AWARD, {
				items = var_41_0,
				removeFunc = function()
					if arg_41_3 then
						arg_41_3()
					end
				end
			})
		elseif arg_41_3 then
			arg_41_3()
		end
	end

	if #arg_41_1 > 0 then
		pg.PerformMgr.GetInstance():PlayGroup(arg_41_1, var_41_1, (EducateHelper.GetDialogueShowDrops(arg_41_2)))
	elseif var_41_1 then
		var_41_1()
	end
end

function EducateScene:ShowFavorUpgrade(arg_44_1, arg_44_2, arg_44_3)
	self:PlayPerformWithDrops(arg_44_2, arg_44_1, function()
		if #arg_44_1 > 0 then
			self:emit(EducateScene.EDUCATE_ON_AWARD, {
				items = arg_44_1,
				removeFunc = function()
					self.favorBtnAnim:Play("anim_educate_favor_levelup")

					if arg_44_3 then
						arg_44_3()
					end
				end
			})
		else
			self.favorBtnAnim:Play("anim_educate_favor_levelup")

			if arg_44_3 then
				arg_44_3()
			end
		end
	end)
end

function EducateScene:ShowSpecialEvent(arg_47_1, arg_47_2, arg_47_3)
	self:PlayPerformWithDrops(pg.child_event_special[arg_47_1].performance, arg_47_2, function()
		if #arg_47_2 > 0 then
			self:emit(EducateScene.EDUCATE_ON_AWARD, {
				items = arg_47_2,
				removeFunc = function()
					if arg_47_3 then
						arg_47_3()
					end
				end
			})
		elseif arg_47_3 then
			arg_47_3()
		end
	end)
end

function EducateScene:checkBubbleShow()
	local var_50_0 = getProxy(EducateProxy):GetEventProxy():GetHomeSpecEvents()

	if #var_50_0 > 0 then
		setActive(self.bubbleBtn:Find("Text"), true)
		setActive(self.bubbleBtn:Find("Image"), false)
		self:showBubble(function()
			self:emit(EducateMediator.ON_SPECIAL_EVENT_TRIGGER, {
				id = var_50_0[1].id,
				callback = function()
					self:checkBubbleShow()
					EducateGuideSequence.CheckGuide(self.__cname, function()
						return
					end)
				end
			})
		end)
	elseif getProxy(EducateProxy):GetCharData():CheckFavor() then
		setActive(self.bubbleBtn:Find("Text"), false)
		setActive(self.bubbleBtn:Find("Image"), true)
		self:showBubble(function()
			self:emit(EducateMediator.ON_UPGRADE_FAVOR, function()
				self:checkBubbleShow()
				EducateGuideSequence.CheckGuide(self.__cname, function()
					return
				end)
			end)
		end)
	else
		setActive(self.bubbleTF, false)
		removeOnButton(self.bubbleTF)
	end
end

function EducateScene:updateResPanel()
	self.resPanel:Flush()
end

function EducateScene:updateArchivePanel()
	self.archivePanel:Flush()
end

function EducateScene:showArchivePanel()
	self.archivePanel:showPanel()
end

function EducateScene:updateDatePanel()
	self.datePanel:Flush()
	self:updateUnlockBtns()
end

function EducateScene:updateUnlockBtns()
	local var_61_0 = EducateHelper.IsSystemUnlock(EducateConst.SYSTEM_MEMORY)

	setActive(self.bookBtn:Find("lock"), not var_61_0)
	setActive(self.bookBtn:Find("unlock"), var_61_0)

	local var_61_1 = EducateHelper.IsSystemUnlock(EducateConst.SYSTEM_BAG)

	setActive(self.bagBtn:Find("lock"), not var_61_1)
	setActive(self.bagBtn:Find("unlock"), var_61_1)

	local var_61_2 = EducateHelper.IsSystemUnlock(EducateConst.SYSTEM_FAVOR_AND_MIND)

	setActive(self.mindBtn:Find("lock"), not var_61_2)
	setActive(self.mindBtn:Find("unlock"), var_61_2)
	setActive(self.favorBtn, var_61_2)
end

function EducateScene:updateMindTip()
	setActive(self.mindBtn:Find("unlock/tip"), getProxy(EducateProxy):GetTaskProxy():IsShowMindTasksTip())
end

function EducateScene:updateWeekDay(arg_63_1)
	self.datePanel:UpdateWeekDay(arg_63_1)
end

function EducateScene:updateFavorBtn()
	local var_64_0 = getProxy(EducateProxy):GetCharData()
	local var_64_1 = var_64_0:GetFavor()

	setText(self.favorLvTF, var_64_1.lv)
	setActive(self.favorMaxTF, var_64_1.lv == var_64_0:GetFavorMaxLv())
end

function EducateScene:updateTargetPanel()
	self.targetPanel:Flush()
end

function EducateScene:updateBottomPanel()
	self.bottomPanel:Flush()
end

function EducateScene:updatePaintingUI()
	local var_67_0 = getProxy(EducateProxy):GetCharData()

	self.bgName = var_67_0:GetBGName()
	self.paintingName = var_67_0:GetPaintingName()
	self.wordList, self.faceList = var_67_0:GetMainDialogueInfo()

	setImageSprite(self.bgTF, LoadSprite("bg/" .. self.bgName), false)
	setPaintingPrefab(self.paintTF, self.paintingName, "yangcheng")
end

function EducateScene:ShowDialogue()
	if LeanTween.isTweening(self.dialogueTF) then
		return
	end

	local var_68_0 = math.random(#self.wordList)

	self.callName = self.callName or getProxy(EducateProxy):GetCharData():GetCallName()

	setText(self.dialogueContent, (string.gsub(pg.child_word[self.wordList[var_68_0]].word, "$1", self.callName)))

	local var_68_1 = GetSpriteFromAtlas("paintingface/" .. self.paintingName, self.faceList[var_68_0])
	local var_68_2 = self.paintTF:Find("fitter"):GetChild(0):Find("face")

	if var_68_2 and var_68_1 then
		setImageSprite(var_68_2, var_68_1)
		setActive(var_68_2, true)
	end

	self.dialogueTF.localScale = Vector3.zero

	setActive(self.dialogueTF, true)
	LeanTween.scale(self.dialogueTF, Vector3.one, 0.3):setEase(LeanTweenType.easeOutBack):setOnComplete(System.Action(function()
		LeanTween.scale(self.dialogueTF, Vector3.zero, 0.3):setEase(LeanTweenType.easeInBack):setDelay(3):setOnComplete(System.Action(function()
			setActive(self.dialogueTF, false)

			if var_68_2 then
				setActive(var_68_2, false)
			end
		end))
	end))
end

function EducateScene:updateNewTips()
	self:updateBookNewTip()
	self:updateMindNewTip()
end

function EducateScene:updateBookNewTip()
	setActive(self.bookBtn:Find("unlock/new"), underscore.any(pg.child_memory.all, function(arg_73_0)
		return EducateTipHelper.IsShowNewTip(EducateTipHelper.NEW_MEMORY, arg_73_0)
	end) or EducateTipHelper.IsShowNewTip(EducateTipHelper.NEW_POLAROID))
end

function EducateScene:updateMindNewTip()
	setActive(self.mindBtn:Find("unlock/new"), EducateTipHelper.IsShowNewTip(EducateTipHelper.NEW_MIND_TASK))
end

function EducateScene:FlushView()
	self.datePanel:Flush()
	self.favorPanel:Flush()
	self.resPanel:Flush()
	self.targetPanel:Flush()
	self.bottomPanel:Flush()
	self.archivePanel:Flush()
	self:updatePaintingUI()
	self:updateUnlockBtns()
	self:updateNewTips()
	self:updateMindTip()
	self:updateFavorBtn()
	self:SeriesCheck()
end

function EducateScene:onBackPressed()
	self:emit(EducateScene.EDUCATE_GO_SCENE, SCENE.NEW_EDUCATE_SELECT, {
		isTb1 = true
	})
end

function EducateScene:willExit()
	self.contextData.isMainEnter = nil

	self.datePanel:Destroy()

	self.datePanel = nil

	self.favorPanel:Destroy()

	self.favorPanel = nil

	self.resPanel:Destroy()

	self.resPanel = nil

	self.topPanel:Destroy()

	self.topPanel = nil

	self.targetPanel:Destroy()

	self.targetPanel = nil

	self.bottomPanel:Destroy()

	self.bottomPanel = nil

	self.archivePanel:Destroy()

	self.archivePanel = nil

	if LeanTween.isTweening(self.dialogueTF) then
		LeanTween.cancel(self.dialogueTF)
	end

	self:UnOverlayPanel(self.blurPanel, self._tf)
end

return EducateScene
