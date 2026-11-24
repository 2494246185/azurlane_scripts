local StoryPlayer = class("StoryPlayer", import("..animation.StoryAnimtion"))
local var_0_1 = 0
local var_0_2 = 1
local var_0_3 = 2
local var_0_4 = 3
local var_0_5 = 4
local var_0_6 = 5
local var_0_7 = 6
local var_0_8 = 7
local var_0_9 = 0
local var_0_10 = 1
local var_0_11 = 2

function StoryPlayer:Ctor(arg_1_1)
	StoryPlayer.super.Ctor(self)
	pg.DelegateInfo.New(self)

	self._go = arg_1_1
	self._tf = arg_1_1.transform
	self.animationPlayer = self._tf:GetComponent(typeof(Animation))
	self.front = self._tf:Find("front")
	self.actorTr = self._tf:Find("actor")
	self.frontTr = self._tf:Find("front")
	self.backPanel = self._tf:Find("back")
	self.goCG = GetOrAddComponent(self._tf, typeof(CanvasGroup))
	self.asidePanel = self._tf:Find("front/aside_panel")
	self.bgGlitch = self._tf:Find("back/bg_glitch")
	self.oldPhoto = self._tf:Find("front/oldphoto"):GetComponent(typeof(Image))
	self.bgPanel = self._tf:Find("back/bg")
	self.bgPanelCg = self.bgPanel:GetComponent(typeof(CanvasGroup))

	setActive(self._tf:Find("back/bg/sub"), false)

	self.bgImage = self.bgPanel:Find("image"):GetComponent(typeof(Image))
	self.mainImg = self._tf:GetComponent(typeof(Image))
	self.castPanel = self._tf:Find("front/cast_panel")
	self.spAnimPanel = self._tf:Find("front/sp_anim_panel")
	self.centerPanel = self._tf:Find("center")
	self.actorPanel = self._tf:Find("actor")
	self.dialoguePanel = self._tf:Find("front/dialogue")
	self.effectPanel = self._tf:Find("front/effect")
	self.movePanel = self._tf:Find("front/move_layer")
	self.curtain = self._tf:Find("back/curtain")
	self.curtainCg = self.curtain:GetComponent(typeof(CanvasGroup))
	self.flash = self._tf:Find("front/flash")
	self.flashImg = self.flash:GetComponent(typeof(Image))
	self.flashCg = self.flash:GetComponent(typeof(CanvasGroup))
	self.curtainF = self._tf:Find("back/curtain_front")
	self.curtainFCg = self.curtainF:GetComponent(typeof(CanvasGroup))
	self.locationTr = self._tf:Find("front/location")
	self.locationTxt = self._tf:Find("front/location/Text"):GetComponent(typeof(Text))
	self.locationTrPos = self.locationTr.localPosition
	self.locationAnim = self.locationTr:GetComponent(typeof(Animation))
	self.locationAniEvent = self.locationTr:GetComponent(typeof(DftAniEvent))
	self.iconImage = self._tf:Find("front/icon"):GetComponent(typeof(Image))
	self.topEffectTr = self._tf:Find("top/effect")
	self.dialogueWin = nil
	self.bgs = {}
	self.branchCodeList = {}
	self.stop = false
	self.pause = false
end

function StoryPlayer:Disable()
	setActive(self._tf, false)
end

function StoryPlayer:Enable()
	setActive(self._tf, true)
end

function StoryPlayer:StoryStart(arg_4_1)
	self.branchCodeList = {}

	eachChild(self.dialoguePanel, function(arg_5_0)
		setActive(arg_5_0, false)
	end)

	self.dialogueWin = self.dialoguePanel:Find(arg_4_1:GetDialogueStyleName())

	setActive(self.dialogueWin, true)

	self.optionLUIlist = UIItemList.New(self.dialogueWin:Find("options_panel/options_l"), self.dialogueWin:Find("options_panel/options_l/option_tpl"))
	self.optionCUIlist = UIItemList.New(self.dialogueWin:Find("options_panel/options_c"), self.dialogueWin:Find("options_panel/options_c/option_tpl"))
	self.optionsCg = self.dialogueWin:Find("options_panel"):GetComponent(typeof(CanvasGroup))

	self:OnStart(arg_4_1)
end

function StoryPlayer:GetOptionContainer(arg_6_1)
	if self.script:IsDialogueStyle2() then
		setActive(self.optionLUIlist.container, true)
		setActive(self.optionCUIlist.container, false)

		return self.optionLUIlist, true
	end

	if arg_6_1:GetOptionCnt() <= 3 or arg_6_1:IsOptionForceCenter() then
		setActive(self.optionLUIlist.container, false)
		setActive(self.optionCUIlist.container, true)

		return self.optionCUIlist, false
	else
		setActive(self.optionLUIlist.container, true)
		setActive(self.optionCUIlist.container, false)

		return self.optionLUIlist, true
	end
end

function StoryPlayer:Pause()
	self.pause = true

	self:PauseAllAnimation()
	pg.ViewUtils.SetLayer(self.effectPanel, Layer.UIHidden)
end

function StoryPlayer:Resume()
	self.pause = false

	self:ResumeAllAnimation()
	pg.ViewUtils.SetLayer(self.effectPanel, Layer.UI)
end

function StoryPlayer:Stop()
	self.stop = true

	self:NextOneImmediately()
end

function StoryPlayer:Play(arg_10_1, arg_10_2, arg_10_3)
	if not arg_10_1 then
		arg_10_3()

		return
	end

	if arg_10_1:GetNextScriptName() or self.stop then
		arg_10_3()

		return
	end

	local var_10_0 = arg_10_1:GetStepByIndex(arg_10_2)

	if not var_10_0 then
		arg_10_3()

		return
	end

	if var_10_0:GetMode() == Story.MODE_SUBPAGE and not var_10_0:ShouldShowSubPage() then
		arg_10_3()

		return
	end

	pg.NewStoryMgr.GetInstance():AddRecord(var_10_0)

	if var_10_0:ShouldJumpToNextScript() then
		arg_10_1:SetNextScriptName(var_10_0:GetNextScriptName())
		arg_10_3()

		return
	end

	local var_10_1 = arg_10_1:ShouldSkipAll()

	if var_10_1 then
		self:ClearEffects()
	end

	local var_10_2 = false

	if var_10_1 and var_10_0:IsImport() then
		if not pg.NewStoryMgr.GetInstance():IsReView() then
			var_10_2 = true

			goto label_10_0
		end
	end

	if var_10_1 then
		arg_10_3()

		return
	end

	::label_10_0::

	self.script = arg_10_1
	self.callback = arg_10_3
	self.step = var_10_0
	self.autoNext = arg_10_1:GetAutoPlayFlag()
	self.stage = var_0_1

	local var_10_3 = arg_10_1:GetTriggerDelayTime()

	var_10_0:MarkIsExecuted()

	if self.autoNext and var_10_0:IsImport() and not var_10_0.optionSelCode then
		self.autoNext = nil
	end

	self:SetTimeScale(1 - arg_10_1:GetPlaySpeed() * 0.1)

	local var_10_4 = arg_10_1:GetPrevStep(arg_10_2)

	seriesAsync({
		function(arg_11_0)
			if not self:NextStage(var_0_2) then
				return
			end

			parallelAsync({
				function(arg_12_0)
					self:Reset(var_10_0, var_10_4, arg_12_0)
					self:UpdateBg(var_10_0)
					self:PlayBgm(var_10_0)
				end,
				function(arg_13_0)
					self:LoadEffects(var_10_0, arg_13_0)
				end,
				function(arg_14_0)
					self:ApplyEffects(var_10_0, arg_14_0)
				end,
				function(arg_15_0)
					self:flashin(var_10_0, arg_15_0)
				end
			}, arg_11_0)
		end,
		function(arg_16_0)
			if var_10_2 then
				arg_10_1:StopSkip()
			end

			var_10_2 = false

			arg_16_0()
		end,
		function(arg_17_0)
			if not self:NextStage(var_0_3) then
				return
			end

			parallelAsync({
				function(arg_18_0)
					self:OnInit(var_10_0, var_10_4, arg_18_0)
				end,
				function(arg_19_0)
					self:PlaySoundEffect(var_10_0)
					self:StartUIAnimations(var_10_0, arg_19_0)
				end,
				function(arg_20_0)
					self:OnEnter(var_10_0, var_10_4, arg_20_0)
				end,
				function(arg_21_0)
					self:StartMoveNode(var_10_0, arg_21_0)
				end,
				function(arg_22_0)
					self:UpdateIcon(var_10_0, arg_22_0)
				end,
				function(arg_23_0)
					self:SetLocation(var_10_0, arg_23_0)
				end,
				function(arg_24_0)
					if self:DispatcherEvent(var_10_0, arg_24_0) then
						self.autoNext = true
						var_10_3 = 0
					end
				end
			}, arg_17_0)
		end,
		function(arg_25_0)
			self:ClearCheckDispatcher()

			if not self:NextStage(var_0_4) then
				return
			end

			if not var_10_0:ShouldDelayEvent() then
				arg_25_0()

				return
			end

			self:DelayCall(var_10_0:GetEventDelayTime(), arg_25_0)
		end,
		function(arg_26_0)
			if not self:NextStage(var_0_5) then
				return
			end

			if self.skipOption then
				arg_26_0()

				return
			end

			if var_10_0:SkipEventForOption() then
				arg_26_0()

				return
			end

			if self:ShouldAutoTrigger() then
				self:UnscaleDelayCall(var_10_3, arg_26_0)

				return
			end

			self:RegisetEvent(var_10_0, arg_26_0)
			self:TriggerEventIfAuto(var_10_3)
		end,
		function(arg_27_0)
			if not self:NextStage(var_0_6) then
				return
			end

			if not var_10_0:ExistOption() then
				arg_27_0()

				return
			end

			if self.skipOption then
				self.skipOption = false

				arg_27_0()

				return
			end

			self:InitBranches(arg_10_1, var_10_0, function(arg_28_0)
				arg_27_0()
			end, function()
				self:TriggerOptionIfAuto(var_10_3, var_10_0)
			end)
		end,
		function(arg_30_0)
			if not self:NextStage(var_0_7) then
				return
			end

			self.autoNext = nil

			local var_30_0 = arg_10_1:GetNextStep(arg_10_2)

			seriesAsync({
				function(arg_31_0)
					self:ClearAnimation()
					self:ClearApplyEffect()
					self:OnWillExit(var_10_0, var_30_0, arg_31_0)
				end,
				function(arg_32_0)
					parallelAsync({
						function(arg_33_0)
							if not var_30_0 then
								arg_33_0()

								return
							end

							self:Flashout(var_30_0, arg_33_0)
						end,
						function(arg_34_0)
							if var_30_0 then
								arg_34_0()

								return
							end

							self:FadeOutStory(self.script, arg_34_0)
						end
					}, arg_32_0)
				end
			}, arg_30_0)
		end,
		function(arg_35_0)
			if not self:NextStage(var_0_8) then
				return
			end

			self:OnWillClear(var_10_0)
			self:Clear(arg_35_0)
		end
	}, arg_10_3)
end

function StoryPlayer:NextStage(arg_36_1)
	if self.stage == arg_36_1 - 1 then
		self.stage = arg_36_1

		return true
	end

	return false
end

function StoryPlayer:ApplyEffects(arg_37_1, arg_37_2)
	if arg_37_1:ShouldShake() then
		self:ApplyShakeEffect(arg_37_1)
	end

	arg_37_2()
end

function StoryPlayer:ApplyShakeEffect(arg_38_1)
	if not arg_38_1:ShouldShake() then
		return
	end

	self.animationPlayer:Play("anim_storyrecordUI_shake_loop")

	self.playingShakeAnim = true

	self:DelayCall(arg_38_1:GetShakeTime(), function()
		self:ClearShakeEffect()
	end)
end

function StoryPlayer:ClearShakeEffect()
	if self.playingShakeAnim then
		self.animationPlayer:Play("anim_storyrecordUI_shake_reset")

		self.playingShakeAnim = nil
	end
end

function StoryPlayer:ClearApplyEffect()
	self:ClearShakeEffect()
end

function StoryPlayer:DispatcherEvent(arg_42_1, arg_42_2)
	if not arg_42_1:ExistDispatcher() then
		arg_42_2()

		return
	end

	local var_42_0 = arg_42_1:GetDispatcher()

	pg.NewStoryMgr.GetInstance():ClearStoryEvent()

	local var_42_1 = {
		data = var_42_0.data,
		callbackData = var_42_0.callbackData
	}

	var_42_1.flags = self.branchCodeList[arg_42_1:GetId()] or {}

	pg.m02:sendNotification(var_42_0.name, var_42_1)

	if arg_42_1:ShouldHideUI() then
		setActive(self._tf, false)
	end

	if arg_42_1:IsRecallDispatcher() then
		self:CheckDispatcher(arg_42_1, arg_42_2)
	else
		arg_42_2()
	end

	return var_42_0.nextOne
end

function StoryPlayer:WaitForEvent()
	return self.checkTimer ~= nil
end

function StoryPlayer:CheckDispatcher(arg_44_1, arg_44_2)
	local var_44_0 = arg_44_1:GetDispatcherRecallName()

	self:ClearCheckDispatcher()

	self.checkTimer = Timer.New(function()
		if pg.NewStoryMgr.GetInstance():CheckStoryEvent(var_44_0) then
			local var_45_0 = pg.NewStoryMgr.GetInstance():GetStoryEventArg(var_44_0)

			if var_45_0 then
				existCall(var_45_0.notifiCallback)
			end

			if var_45_0 and var_45_0.optionIndex then
				self:SetBranchCode(self.script, arg_44_1, var_45_0.optionIndex)

				self.skipOption = true
			end

			if arg_44_1:ShouldHideUI() then
				setActive(self._tf, true)
			end

			self:ClearCheckDispatcher()
			arg_44_2()
		end
	end, 1, -1)

	self.checkTimer:Start()
	self.checkTimer.func()
end

function StoryPlayer:ClearCheckDispatcher()
	if self.checkTimer then
		self.checkTimer:Stop()

		self.checkTimer = nil
	end
end

function StoryPlayer:TriggerEventIfAuto(arg_47_1)
	if not self:ShouldAutoTrigger() then
		return
	end

	self:UnscaleDelayCall(arg_47_1, function()
		if not self.autoNext then
			setButtonEnabled(self._go, true)

			return
		end

		triggerButton(self._go)
	end)
end

function StoryPlayer:TriggerOptionIfAuto(arg_49_1, arg_49_2)
	if not self:ShouldAutoTrigger() then
		return
	end

	if not arg_49_2 or not arg_49_2:ExistOption() then
		return
	end

	self:UnscaleDelayCall(arg_49_1, function()
		if not self.autoNext then
			return
		end

		local var_50_0 = arg_49_2:GetOptionIndexByAutoSel()

		if var_50_0 ~= nil then
			triggerButton((self:GetOptionContainer(arg_49_2).container:GetChild(var_50_0 - 1)))
		end
	end)
end

function StoryPlayer:ShouldAutoTrigger()
	if self.pause or self.stop then
		return false
	end

	return self.autoNext
end

function StoryPlayer:CanSkip()
	return self.step and not self.step:IsImport()
end

function StoryPlayer:CancelAuto()
	self.autoNext = false
end

function StoryPlayer:NextOne()
	self.timeScale = 0.0001

	if self.stage == var_0_1 then
		self.autoNext = true
	elseif self.stage == var_0_5 then
		self.autoNext = true

		self:TriggerEventIfAuto(0)
	elseif self.stage == var_0_6 then
		self:TriggerOptionIfAuto(0, self.step)
	end
end

function StoryPlayer:NextOneImmediately()
	if self.callback then
		self:ClearAnimation()
		self:Clear()
		self.callback()
	end
end

function StoryPlayer:SetLocation(arg_56_1, arg_56_2)
	if not arg_56_1:ExistLocation() then
		self.locationAniEvent:SetEndEvent(nil)
		arg_56_2()

		return
	end

	setActive(self.locationTr, true)

	local var_56_0 = arg_56_1:GetLocation()

	self.locationTxt.text = var_56_0.text

	local function var_56_1()
		self:DelayCall(var_56_0.time, function()
			self.locationAnim:Play("anim_newstoryUI_iocation_out")

			self.locationStatus = var_0_11
		end)
	end

	self.locationAniEvent:SetEndEvent(function()
		if self.locationStatus == var_0_10 then
			var_56_1()
			arg_56_2()
		elseif self.locationStatus == var_0_11 then
			setActive(self.locationTr, false)

			self.locationStatus = var_0_9
		end
	end)
	self.locationAnim:Play("anim_newstoryUI_iocation_in")

	self.locationStatus = var_0_10
end

function StoryPlayer:UpdateIcon(arg_60_1, arg_60_2)
	if not arg_60_1:ExistIcon() then
		setActive(self.iconImage.gameObject, false)
		arg_60_2()

		return
	end

	local var_60_0 = arg_60_1:GetIconData()

	self.iconImage.sprite = LoadSprite(var_60_0.image)

	self.iconImage:SetNativeSize()

	local var_60_1 = self.iconImage.gameObject.transform

	var_60_1.localPosition = var_60_0.pos and Vector3(var_60_0.pos[1], var_60_0.pos[2], 0) or Vector3.one
	var_60_1.localScale = Vector3(var_60_0.scale or 1, var_60_0.scale or 1, 1)

	setActive(self.iconImage.gameObject, true)
	arg_60_2()
end

function StoryPlayer:UpdateOptionTxt(arg_61_1, arg_61_2, arg_61_3, arg_61_4)
	local var_61_0 = arg_61_2:GetComponent(typeof(LayoutElement))
	local var_61_1 = arg_61_2:Find("content")

	if arg_61_1 then
		local var_61_2 = arg_61_2:Find("content_max")
		local var_61_3 = GetPerceptualSize(arg_61_3) >= 17
		local var_61_4 = var_61_3 and var_61_2 or var_61_1

		setActive(var_61_1, not var_61_3)
		setActive(var_61_2, var_61_3)
		setText(var_61_4:Find("Text"), arg_61_3)

		var_61_0.preferredHeight = var_61_4.rect.height
	else
		setText(var_61_1:Find("Text"), arg_61_3)

		var_61_0.preferredHeight = var_61_1.rect.height
	end

	self:UpdateOptionBGWithTB(var_61_1, arg_61_4)
end

function StoryPlayer:UpdateOptionBGWithTB(arg_62_1, arg_62_2)
	local var_62_0 = getProxy(NewEducateProxy):GetCurChar()
	local var_62_1 = arg_62_1:Find("type1")
	local var_62_2 = arg_62_1:Find("type2")

	if var_62_1 then
		setActive(var_62_1, false)
	end

	if var_62_2 then
		setActive(var_62_2, false)
	end

	if var_62_0 and var_62_1 then
		local var_62_3 = arg_62_2 and arg_62_2 == 1

		if arg_62_2 and arg_62_2 == 1 then
			LoadImageSpriteAsync("neweducateicon/" .. var_62_0:GetPersonalityTagOptionBg(arg_62_2), var_62_1)
		end

		setActive(var_62_1, var_62_3)
	end

	if var_62_0 and var_62_2 then
		local var_62_4 = arg_62_2 and arg_62_2 == 2

		if arg_62_2 and arg_62_2 == 2 then
			LoadImageSpriteAsync("neweducateicon/" .. var_62_0:GetPersonalityTagOptionBg(arg_62_2), var_62_2)
		end

		setActive(var_62_2, var_62_4)
	end

	if arg_62_1:Find("type3") then
		if arg_62_2 and arg_62_2 == 3 then
			arg_62_1:Find("Text").localPosition = Vector2(20, 0)

			setActive(arg_62_1:Find("type3"), true)
		else
			arg_62_1:Find("Text").localPosition = Vector2.zero

			setActive(arg_62_1:Find("type3"), false)
		end
	end

	if arg_62_2 and arg_62_2 == 3 and arg_62_1:Find("icon") then
		setActive(arg_62_1:Find("icon"), false)
		setImageSprite(arg_62_1, (GetSpriteFromAtlas("ui/story_atlas", "option_bg_left_global")))
	end
end

function StoryPlayer:InitBranches(arg_63_1, arg_63_2, arg_63_3, arg_63_4)
	local var_63_0 = false
	local var_63_1 = arg_63_2:GetOptions()
	local var_63_2, var_63_3 = self:GetOptionContainer(arg_63_2)
	local var_63_4 = self.branchCodeList[arg_63_2:GetId()] or {}
	local var_63_5 = GetOrAddComponent(var_63_2.container, typeof(CanvasGroup))

	var_63_5.blocksRaycasts = true
	self.selectedBranchID = nil

	var_63_2:make(function(arg_64_0, arg_64_1, arg_64_2)
		if arg_64_0 == UIItemList.EventUpdate then
			local var_64_0 = arg_64_2
			local var_64_1 = var_63_1[arg_64_1 + 1][1]
			local var_64_2 = var_63_1[arg_64_1 + 1][2]
			local var_64_4 = var_63_1[arg_64_1 + 1][4]
			local var_64_5 = table.contains(var_63_4, var_63_1[arg_64_1 + 1][2])

			onButton(self, arg_64_2, function()
				if self.pause or self.stop then
					return
				end

				if not var_63_0 then
					return
				end

				var_63_0 = false

				seriesAsync({
					function(arg_66_0)
						self:PlayOptionEffect(arg_63_1, arg_63_2, arg_64_1, arg_64_2, var_64_1, var_64_2, var_64_4, var_63_5, var_63_0, arg_66_0)
					end
				}, function()
					pg.m02:sendNotification(STORY_EVENT.OPTION_SELECTED, {
						optionalFlag = var_64_2
					})
					arg_63_3(var_64_1)
				end)
			end, SFX_PANEL)
			setButtonEnabled(var_64_0, not var_64_5)

			GetOrAddComponent(arg_64_2, typeof(CanvasGroup)).alpha = var_64_5 and 0.5 or 1

			self:UpdateOptionTxt(var_63_3, var_64_0, var_64_1, (var_64_4 or nil) and 3)

			if self.script:IsDialogueStyle2() then
				setActive(var_64_0, arg_64_1 == 0)

				if arg_64_1 > 0 then
					LeanTween.delayedCall(0.066 * arg_64_1, System.Action(function()
						setActive(var_64_0, true)
					end))
				end
			end
		end
	end)
	var_63_2:align(#var_63_1)
	self:ShowBranches(arg_63_2, function()
		var_63_0 = true

		if arg_63_4 then
			arg_63_4()
		end
	end)
end

function StoryPlayer:PlayOptionEffect(arg_70_1, arg_70_2, arg_70_3, arg_70_4, arg_70_5, arg_70_6, arg_70_7, arg_70_8, arg_70_9, arg_70_10)
	local var_70_0, var_70_1 = arg_70_2:GetOptionEffects()

	if not var_70_0 or #var_70_0 <= 0 then
		self:OnBranchSelected(arg_70_1, arg_70_2, arg_70_3, arg_70_4, arg_70_5, arg_70_6, arg_70_7, arg_70_8, arg_70_9, arg_70_10)

		return
	end

	local var_70_2 = var_70_0[1]
	local var_70_3 = var_70_0[2]
	local var_70_4 = var_70_1 == StoryStep.OPTION_ANIM_ONLY_ICON or var_70_1 == StoryStep.OPTION_ANIM_BOTH
	local var_70_5 = PoolMgr.GetInstance()

	local function var_70_6(arg_71_0, arg_71_1, arg_71_2)
		var_70_5:GetUI(arg_71_0, true, function(arg_72_0)
			setParent(arg_72_0.transform, arg_71_1, false)

			local var_72_0 = arg_72_0.transform:GetComponent(typeof(DftAniEvent))

			var_72_0:SetEndEvent(function()
				var_72_0:SetEndEvent(nil)
				var_70_5:ReturnUI(arg_71_0, arg_72_0)
				arg_71_2()
			end)
			setActive(arg_72_0.transform, true)
		end)
	end

	local var_70_7 = {}

	if var_70_1 == StoryStep.OPTION_ANIM_ONLY_BTN or var_70_1 == StoryStep.OPTION_ANIM_BOTH then
		table.insert(var_70_7, function(arg_74_0)
			var_70_6(var_70_2, arg_70_4, arg_74_0)
		end)
	end

	table.insert(var_70_7, function(arg_75_0)
		self:OnBranchSelected(arg_70_1, arg_70_2, arg_70_3, arg_70_4, arg_70_5, arg_70_6, arg_70_7, arg_70_8, arg_70_9, arg_75_0)
	end)

	local var_70_8 = {
		function(arg_76_0)
			seriesAsync(var_70_7, arg_76_0)
		end
	}

	if var_70_4 then
		table.insert(var_70_8, function(arg_77_0)
			var_70_6(var_70_3, self.frontTr, arg_77_0)
		end)
	end

	arg_70_8.blocksRaycasts = false

	parallelAsync(var_70_8, function()
		arg_70_8.blocksRaycasts = true

		arg_70_10()
	end)
end

function StoryPlayer:OnBranchSelected(arg_79_1, arg_79_2, arg_79_3, arg_79_4, arg_79_5, arg_79_6, arg_79_7, arg_79_8, arg_79_9, arg_79_10)
	self.selectedBranchID = arg_79_3

	self:SetBranchCode(arg_79_1, arg_79_2, arg_79_6)

	if arg_79_7 then
		self:SetGlobalOptionFlag(arg_79_7)
	end

	pg.NewStoryMgr.GetInstance():TrackingOption(arg_79_2:GetOptionIndex(), arg_79_6)

	local var_79_0 = arg_79_4:GetComponent(typeof(Animation))

	if var_79_0 then
		arg_79_8.blocksRaycasts = false

		var_79_0:Play(self.script:GetAnimPrefix() .. "confirm")
		arg_79_4:GetComponent(typeof(DftAniEvent)):SetEndEvent(function()
			setActive(self.optionsCg.gameObject, false)

			arg_79_8.blocksRaycasts = true

			self:HideBranchesWithoutSelected(arg_79_2)
			arg_79_10()
		end)
	else
		setActive(self.optionsCg.gameObject, false)
		self:HideBranchesWithoutSelected(arg_79_2)
		arg_79_10()
	end
end

function StoryPlayer:SetBranchCode(arg_81_1, arg_81_2, arg_81_3)
	arg_81_2:SetBranchCode(arg_81_3)
	arg_81_1:SetBranchCode(arg_81_3)

	local var_81_0 = arg_81_2:GetId()

	self.branchCodeList[var_81_0] = self.branchCodeList[var_81_0] or {}

	table.insert(self.branchCodeList[var_81_0], arg_81_3)
end

function StoryPlayer:SetGlobalOptionFlag(arg_82_1)
	PlayerPrefs.SetInt(StoryStep.GetGlobalFlagKey(arg_82_1.flagID) .. arg_82_1.flagIndex, arg_82_1.flagValue)
end

function StoryPlayer:ShowBranches(arg_83_1, arg_83_2)
	setActive(self.optionsCg.gameObject, true)

	local var_83_0 = self:GetOptionContainer(arg_83_1)

	for iter_83_0 = 0, var_83_0.container.childCount - 1 do
		local var_83_1 = var_83_0.container:GetChild(iter_83_0):GetComponent(typeof(Animation))

		if var_83_1 then
			var_83_1:Play(self.script:GetAnimPrefix() .. "in")
		end
	end

	arg_83_2()
end

function StoryPlayer:HideBranchesWithoutSelected(arg_84_1)
	local var_84_0 = self:GetOptionContainer(arg_84_1)

	for iter_84_0 = 0, var_84_0.container.childCount - 1 do
		if iter_84_0 ~= self.selectedBranchID then
			local var_84_1 = var_84_0.container:GetChild(iter_84_0):GetComponent(typeof(Animation))

			if var_84_1 then
				var_84_1:Play(self.script:GetAnimPrefix() .. "unselected")
			end
		end
	end
end

function StoryPlayer:StartMoveNode(arg_85_1, arg_85_2)
	if not arg_85_1:ExistMovableNode() then
		arg_85_2()

		return
	end

	local var_85_0 = arg_85_1:GetMovableNode()
	local var_85_1 = {}
	local var_85_2 = {}

	for iter_85_0, iter_85_1 in pairs(var_85_0) do
		table.insert(var_85_1, function(arg_86_0)
			self:LoadMovableNode(iter_85_1, function(arg_87_0)
				var_85_2[iter_85_0] = arg_87_0

				arg_86_0()
			end)
		end)
	end

	parallelAsync(var_85_1, function()
		self:MoveAllNode(arg_85_1, var_85_2, var_85_0)
		arg_85_2()
	end)
end

function StoryPlayer:MoveAllNode(arg_89_1, arg_89_2, arg_89_3)
	local var_89_0 = {}

	for iter_89_0, iter_89_1 in pairs(arg_89_2) do
		table.insert(var_89_0, function(arg_90_0)
			self:moveLocalPath(iter_89_1, arg_89_3[iter_89_0].path, arg_89_3[iter_89_0].time, arg_89_3[iter_89_0].delay, arg_89_3[iter_89_0].easeType, arg_90_0)
		end)
	end

	self.moveTargets = arg_89_2

	parallelAsync(var_89_0, function()
		self:ClearMoveNodes(arg_89_1)
	end)
end

local function var_0_12(arg_92_0, arg_92_1, arg_92_2, arg_92_3, arg_92_4)
	arg_92_0.spineChar = SpineAnimChar.New()

	arg_92_0.spineChar:SetPaint(arg_92_1)
	arg_92_0.spineChar:Load(true, function(arg_93_0)
		arg_93_0:SetParent(arg_92_0.movePanel)
		arg_93_0:SetLocalScale(Vector3(arg_92_2.scale, arg_92_2.scale, 0))
		arg_93_0:SetLocalPosition(arg_92_3)
		arg_93_0:SetAction(arg_92_2.action, 0)
		arg_93_0:SetName(arg_92_1)

		if arg_92_4 then
			arg_92_4(arg_92_0.spineChar:GetModel())
		end
	end)
end

local function var_0_13(arg_94_0, arg_94_1, arg_94_2, arg_94_3)
	local var_94_0 = GameObject.New("movable")

	var_94_0.transform:SetParent(arg_94_0.movePanel)

	var_94_0.transform.localScale = Vector3.zero

	local var_94_1 = GetOrAddComponent(var_94_0, typeof(RectTransform))
	local var_94_2 = GetOrAddComponent(var_94_0, typeof(Image))

	LoadSpriteAsync(arg_94_1, function(arg_95_0)
		var_94_2.sprite = arg_95_0

		var_94_2:SetNativeSize()

		var_94_1.localScale = Vector3.one
		var_94_1.localPosition = arg_94_2

		arg_94_3(var_94_1.gameObject)
	end)
end

function StoryPlayer:LoadMovableNode(arg_96_1, arg_96_2)
	local var_96_0 = arg_96_1.path[1] or Vector3.zero

	if arg_96_1.isSpine then
		var_0_12(self, arg_96_1.name, arg_96_1.spineData, var_96_0, arg_96_2)
	else
		var_0_13(self, arg_96_1.name, var_96_0, arg_96_2)
	end
end

function StoryPlayer:ClearMoveNodes(arg_97_1)
	if not arg_97_1:ExistMovableNode() then
		return
	end

	if self.movePanel.childCount <= 0 then
		return
	end

	for iter_97_0, iter_97_1 in ipairs(self.moveTargets or {}) do
		if iter_97_1:GetComponent(typeof(SpineAnimUI)) ~= nil then
			PoolMgr.GetInstance():ReturnSpineChar(iter_97_1.name, iter_97_1.gameObject)
		else
			Destroy(self.movePanel:GetChild(iter_97_0 - 1))
		end
	end

	self.moveTargets = {}
end

function StoryPlayer:FadeOutStory(arg_98_1, arg_98_2)
	if not arg_98_1:ShouldFadeout() then
		arg_98_2()

		return
	end

	local var_98_0 = arg_98_1:GetFadeoutTime()

	if not arg_98_1:ShouldWaitFadeout() then
		self:fadeTransform(self._go, 1, 0.3, var_98_0, true)
		arg_98_2()
	else
		self:fadeTransform(self._go, 1, 0.3, var_98_0, true, arg_98_2)
	end
end

function StoryPlayer:GetFadeColor(arg_99_1)
	local var_99_0 = {}
	local var_99_1 = {}

	for iter_99_0, iter_99_1 in ipairs((arg_99_1:GetComponentsInChildren(typeof(Image)):ToTable())) do
		local var_99_2 = {
			name = "_Color",
			color = Color.white
		}

		if iter_99_1.material.shader.name == "UI/GrayScale" then
			var_99_2 = {
				name = "_GrayScale",
				color = Color.New(0.21176470588235294, 0.7137254901960784, 0.07058823529411765)
			}
		elseif iter_99_1.material.shader.name == "UI/Line_Add_Blue" then
			var_99_2 = {
				name = "_GrayScale",
				color = Color.New(1, 1, 1, 0.5882352941176471)
			}
		end

		table.insert(var_99_1, var_99_2)

		if iter_99_1.material == iter_99_1.defaultGraphicMaterial then
			iter_99_1.material = Material.Instantiate(iter_99_1.defaultGraphicMaterial)
		end

		table.insert(var_99_0, iter_99_1.material)
	end

	return var_99_0, var_99_1
end

function StoryPlayer:_SetFadeColor(arg_100_1, arg_100_2, arg_100_3)
	for iter_100_0, iter_100_1 in ipairs(arg_100_1) do
		if not IsNil(iter_100_1) then
			iter_100_1:SetColor(arg_100_2[iter_100_0].name, arg_100_2[iter_100_0].color * Color.New(arg_100_3, arg_100_3, arg_100_3))
		end
	end
end

function StoryPlayer:SetFadeColor(arg_101_1, arg_101_2)
	local var_101_0, var_101_1 = self:GetFadeColor(arg_101_1)

	self:_SetFadeColor(var_101_0, var_101_1, arg_101_2)
end

function StoryPlayer:_RevertFadeColor(arg_102_1, arg_102_2)
	self:_SetFadeColor(arg_102_1, arg_102_2, 1)
end

function StoryPlayer:RevertFadeColor(arg_103_1)
	local var_103_0, var_103_1 = self:GetFadeColor(arg_103_1)

	self:_RevertFadeColor(var_103_0, var_103_1)
end

function StoryPlayer:fadeTransform(arg_104_1, arg_104_2, arg_104_3, arg_104_4, arg_104_5, arg_104_6)
	if arg_104_4 <= 0 then
		if arg_104_6 then
			arg_104_6()
		end

		return
	end

	local var_104_0, var_104_1 = self:GetFadeColor(arg_104_1)

	LeanTween.value(go(arg_104_1), arg_104_2, arg_104_3, arg_104_4):setOnUpdate(System.Action_float(function(arg_105_0)
		self:_SetFadeColor(var_104_0, var_104_1, arg_105_0)
	end)):setOnComplete(System.Action(function()
		if arg_104_5 then
			self:_RevertFadeColor(var_104_0, var_104_1)
		end

		if arg_104_6 then
			arg_104_6()
		end
	end))
end

function StoryPlayer:setPaintingAlpha(arg_107_1, arg_107_2)
	local var_107_0 = {}
	local var_107_1 = {}

	for iter_107_0, iter_107_1 in ipairs((arg_107_1:GetComponentsInChildren(typeof(Image)):ToTable())) do
		local var_107_2 = {
			name = "_Color",
			color = Color.white
		}

		if iter_107_1.material.shader.name == "UI/GrayScale" then
			var_107_2 = {
				name = "_GrayScale",
				color = Color.New(0.21176470588235294, 0.7137254901960784, 0.07058823529411765)
			}
		elseif iter_107_1.material.shader.name == "UI/Line_Add_Blue" then
			var_107_2 = {
				name = "_GrayScale",
				color = Color.New(1, 1, 1, 0.5882352941176471)
			}
		end

		table.insert(var_107_1, var_107_2)

		if iter_107_1.material == iter_107_1.defaultGraphicMaterial then
			iter_107_1.material = Material.Instantiate(iter_107_1.defaultGraphicMaterial)
		end

		table.insert(var_107_0, iter_107_1.material)
	end

	for iter_107_2, iter_107_3 in ipairs(var_107_0) do
		if not IsNil(iter_107_3) then
			iter_107_3:SetColor(var_107_1[iter_107_2].name, var_107_1[iter_107_2].color * Color.New(arg_107_2, arg_107_2, arg_107_2))
		end
	end
end

function StoryPlayer:RegisetEvent(arg_108_1, arg_108_2)
	setButtonEnabled(self._go, not self.autoNext)
	onButton(self, self._go, function()
		if self.pause or self.stop then
			return
		end

		removeOnButton(self._go)
		arg_108_2()
	end, SFX_PANEL)
end

function StoryPlayer:flashEffect(arg_110_1, arg_110_2, arg_110_3, arg_110_4, arg_110_5, arg_110_6)
	self.flashImg.color = arg_110_4 and Color(0, 0, 0) or Color(1, 1, 1)
	self.flashCg.alpha = arg_110_1

	setActive(self.flash, true)
	self:TweenValueForcanvasGroup(self.flashCg, arg_110_1, arg_110_2, arg_110_3, arg_110_5, arg_110_6)
end

function StoryPlayer:Flashout(arg_111_1, arg_111_2)
	local var_111_0, var_111_1, var_111_2, var_111_3 = arg_111_1:GetFlashoutData()

	if not var_111_0 then
		arg_111_2()

		return
	end

	self:flashEffect(var_111_0, var_111_1, var_111_2, var_111_3, 0, arg_111_2)
end

function StoryPlayer:flashin(arg_112_1, arg_112_2)
	local var_112_0, var_112_1, var_112_2, var_112_3, var_112_4 = arg_112_1:GetFlashinData()

	if not var_112_0 then
		arg_112_2()

		return
	end

	self:flashEffect(var_112_0, var_112_1, var_112_2, var_112_3, var_112_4, arg_112_2)
end

function StoryPlayer:UpdateBg(arg_113_1)
	if arg_113_1:ShouldBgGlitchArt() then
		self:SetBgGlitchArt(arg_113_1)
	else
		local var_113_0 = arg_113_1:GetBgName()

		if var_113_0 then
			setActive(self.bgPanel, true)

			self.bgPanelCg.alpha = 1
			self.bgImage.color = Color.New(1, 1, 1)
			self.bgImage.sprite = self:GetBg(var_113_0)
		end

		local var_113_1 = arg_113_1:GetBgShadow()

		if var_113_1 then
			local var_113_2 = self.bgImage

			self:TweenValue(self.bgImage, var_113_1[1], var_113_1[2], var_113_1[3], 0, function(arg_114_0)
				var_113_2.color = Color.New(arg_114_0, arg_114_0, arg_114_0)
			end, nil)
		end

		if arg_113_1:IsBlackBg() then
			setActive(self.curtain, true)

			self.curtainCg.alpha = 1
		end

		local var_113_3, var_113_4 = arg_113_1:IsBlackFrontGround()

		if var_113_3 then
			self.curtainFCg.alpha = var_113_4
		end

		setActive(self.curtainF, var_113_3)
	end

	self:ApplyOldPhotoEffect(arg_113_1)
	self:OnBgUpdate(arg_113_1)

	self.curtain:GetComponent(typeof(Image)).color = arg_113_1:GetBgColor()
end

function StoryPlayer:ApplyOldPhotoEffect(arg_115_1)
	local var_115_0 = arg_115_1:OldPhotoEffect()
	local var_115_1 = var_115_0 ~= nil

	setActive(self.oldPhoto.gameObject, var_115_0 ~= nil)

	if var_115_1 then
		self.oldPhoto.color = type(var_115_0) == "table" and Color.New(var_115_0[1], var_115_0[2], var_115_0[3], var_115_0[4]) or Color.New(0.62, 0.58, 0.14, 0.36)
	end
end

function StoryPlayer:SetBgGlitchArt(arg_116_1)
	setActive(self.bgPanel, false)
	setActive(self.bgGlitch, true)
end

function StoryPlayer:GetBg(arg_117_1)
	self.bgs[arg_117_1] = self.bgs[arg_117_1] or LoadSprite("bg/" .. arg_117_1)

	return self.bgs[arg_117_1]
end

function StoryPlayer:LoadEffects(arg_118_1, arg_118_2)
	local var_118_0 = arg_118_1:GetEffects()

	if #var_118_0 <= 0 then
		arg_118_2()

		return
	end

	local var_118_1 = {}

	for iter_118_0, iter_118_1 in ipairs(var_118_0) do
		local var_118_2 = iter_118_1.name
		local var_118_3 = iter_118_1.active
		local var_118_4 = iter_118_1.interlayer
		local var_118_5 = iter_118_1.center
		local var_118_6 = iter_118_1.adapt
		local var_118_7 = self.effectPanel:Find(iter_118_1.name) or self.centerPanel:Find(var_118_2)

		if var_118_7 then
			setActive(var_118_7, var_118_3)
			setParent(var_118_7, (iter_118_1.center or nil) and (self.centerPanel or self.effectPanel.transform))

			if var_118_4 then
				self:UpdateEffectInterLayer(var_118_2, var_118_7)
			end

			if not var_118_3 then
				self:ClearEffectInterlayer(var_118_2)
			elseif isActive(var_118_7) then
				setActive(var_118_7, false)
				setActive(var_118_7, true)
			end

			if var_118_6 then
				self:AdaptEffect(var_118_7)
			end
		else
			local var_118_8 = ""

			if checkABExist("ui/" .. var_118_2) then
				var_118_8 = "ui"
			elseif checkABExist("effect/" .. var_118_2) then
				var_118_8 = "effect"
			end

			if var_118_8 and var_118_8 ~= "" then
				table.insert(var_118_1, function(arg_119_0)
					LoadAndInstantiateAsync(var_118_8, var_118_2, function(arg_120_0)
						setParent(arg_120_0, (var_118_5 or nil) and (self.centerPanel or self.effectPanel.transform))

						arg_120_0.transform.localScale = Vector3.one

						setActive(arg_120_0, var_118_3)

						arg_120_0.name = var_118_2

						if var_118_4 then
							self:UpdateEffectInterLayer(var_118_2, arg_120_0)
						end

						if var_118_3 == false then
							self:ClearEffectInterlayer(var_118_2)
						end

						if var_118_6 then
							self:AdaptEffect(arg_120_0)
						end

						arg_119_0()
					end)
				end)
			else
				originalPrint("not found effect", var_118_2)
			end
		end
	end

	parallelAsync(var_118_1, arg_118_2)
end

function StoryPlayer:AdaptEffect(arg_121_1)
	local var_121_0 = pg.UIMgr.GetInstance().OverlayMain.parent.sizeDelta
	local var_121_1 = 1

	var_121_1 = 1.7777777777777777 < var_121_0.x / var_121_0.y and var_121_0.x / var_121_0.y / 1.7777777777777777 or 1.7777777777777777 / (var_121_0.x / var_121_0.y)
	tf(arg_121_1).localScale = Vector3(var_121_1, var_121_1, var_121_1)
end

function StoryPlayer:UpdateEffectInterLayer(arg_122_1, arg_122_2)
	local var_122_0 = self._go:GetComponent(typeof(Canvas)).sortingOrder

	for iter_122_0, iter_122_1 in ipairs((arg_122_2:GetComponentsInChildren(typeof("UnityEngine.ParticleSystemRenderer")):ToTable())) do
		local var_122_1 = ReflectionHelp.RefGetProperty(typeof("UnityEngine.ParticleSystemRenderer"), "sortingOrder", iter_122_1)

		if var_122_0 < var_122_1 then
			var_122_0 = var_122_1
		end
	end

	local var_122_2 = GetOrAddComponent(self.actorTr, typeof(Canvas))

	var_122_2.overrideSorting = true
	var_122_2.sortingOrder = var_122_0 + 1

	local var_122_3 = GetOrAddComponent(self.frontTr, typeof(Canvas))

	var_122_3.overrideSorting = true
	var_122_3.sortingOrder = var_122_0 + 1 + 10
	self.activeInterLayer = arg_122_1

	GetOrAddComponent(self.frontTr, typeof(GraphicRaycaster))
end

function StoryPlayer:ClearEffectInterlayer(arg_123_1)
	if self.activeInterLayer == arg_123_1 then
		RemoveComponent(self.frontTr, "GraphicRaycaster")
		RemoveComponent(self.actorTr, "Canvas")
		RemoveComponent(self.frontTr, "Canvas")

		self.activeInterLayer = nil
	end
end

function StoryPlayer:ClearEffects()
	removeAllChildren(self.effectPanel)
	removeAllChildren(self.centerPanel)

	if self.activeInterLayer ~= nil then
		self:ClearEffectInterlayer(self.activeInterLayer)
	end
end

function StoryPlayer:PlaySoundEffect(arg_125_1)
	if arg_125_1:ShouldPlaySoundEffect() then
		local var_125_0, var_125_1 = arg_125_1:GetSoundeffect()

		self:DelayCall(var_125_1, function()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(var_125_0)
		end)
	end

	if arg_125_1:ShouldPlayVoice() then
		self:PlayVoice(arg_125_1)
	elseif arg_125_1:ShouldStopVoice() then
		self:StopVoice()
	end
end

function StoryPlayer:StopVoice()
	if self.currentVoice then
		self.currentVoice:Stop(true)

		self.currentVoice = nil
	end
end

function StoryPlayer:PlayVoice(arg_128_1)
	if self.voiceDelayTimer then
		self.voiceDelayTimer:Stop()

		self.voiceDelayTimer = nil
	end

	self:StopVoice()

	local var_128_0, var_128_1 = arg_128_1:GetVoice()
	local var_128_2

	var_128_2 = self:CreateDelayTimer(var_128_1, function()
		if var_128_2 then
			var_128_2:Stop()
		end

		if self.voiceDelayTimer then
			self.voiceDelayTimer = nil
		end

		pg.CriMgr.GetInstance():PlaySoundEffect_V3(var_128_0, function(arg_130_0)
			if arg_130_0 then
				self.currentVoice = arg_130_0.playback
			end
		end)
	end)
	self.voiceDelayTimer = nil
end

function StoryPlayer:Reset(arg_131_1, arg_131_2, arg_131_3)
	setActive(self.spAnimPanel, false)
	setActive(self.castPanel, false)
	setActive(self.bgPanel, false)
	setActive(self.frontTr, true)

	if arg_131_1 and arg_131_1:IsDialogueMode() and arg_131_2 and arg_131_2:IsDialogueMode() then
		-- block empty
	else
		setActive(self.dialoguePanel, false)
	end

	setActive(self.asidePanel, false)
	setActive(self.curtain, false)
	setActive(self.flash, false)
	setActive(self.optionsCg.gameObject, false)
	setActive(self.bgGlitch, false)
	setActive(self.locationTr, false)

	self.locationTr.localPosition = self.locationTrPos
	self.locationStatus = var_0_9
	self.flashCg.alpha = 1
	self.goCG.alpha = 1

	self.animationPlayer:Stop()
	self:OnReset(arg_131_1, arg_131_2, arg_131_3)
end

function StoryPlayer:Clear(arg_132_1)
	if self.step then
		self:ClearMoveNodes(self.step)
	end

	self.bgs = {}
	self.skipOption = nil
	self.step = nil
	self.goCG.alpha = 1
	self.callback = nil
	self.autoNext = nil
	self.script = nil
	self.bgImage.sprite = nil

	self:OnClear()

	if arg_132_1 then
		arg_132_1()
	end

	pg.DelegateInfo.New(self)
end

function StoryPlayer:StoryEnd(arg_133_1)
	setActive(self.iconImage.gameObject, false)

	self.iconImage.sprite = nil
	self.branchCodeList = {}
	self.stop = false
	self.pause = false

	if self.voiceDelayTimer then
		self.voiceDelayTimer:Stop()

		self.voiceDelayTimer = nil
	end

	if self.currentVoice then
		self.currentVoice:Stop(true)

		self.currentVoice = nil
	end

	self:ClearCheckDispatcher()
	self:ClearEffects()
	self:Clear()
	self:OnEnd(arg_133_1)
end

function StoryPlayer:PlayBgm(arg_134_1)
	if arg_134_1:ShouldStopBgm() then
		self:StopBgm()
	end

	if arg_134_1:ShoulePlayBgm() then
		local var_134_0, var_134_1, var_134_2 = arg_134_1:GetBgmData()

		self:DelayCall(var_134_1, function()
			self:RevertBgmVolume()
			pg.BgmMgr.GetInstance():TempPlay(var_134_0)
		end)

		if var_134_2 and var_134_2 > 0 then
			self.defaultBgmVolume = pg.CriMgr.GetInstance():getBGMVolume()

			pg.CriMgr.GetInstance():setBGMVolume(var_134_2)
		end
	end
end

function StoryPlayer:StopBgm(arg_136_1)
	self:RevertBgmVolume()
	pg.BgmMgr.GetInstance():StopPlay()
end

function StoryPlayer:RevertBgmVolume()
	if self.defaultBgmVolume then
		pg.CriMgr.GetInstance():setBGMVolume(self.defaultBgmVolume)

		self.defaultBgmVolume = nil
	end
end

function StoryPlayer:StartUIAnimations(arg_138_1, arg_138_2)
	parallelAsync({
		function(arg_139_0)
			self:StartBlinkAnimation(arg_138_1, arg_139_0)
		end,
		function(arg_140_0)
			self:StartBlinkWithColorAnimation(arg_138_1, arg_140_0)
		end,
		function(arg_141_0)
			self:OnStartUIAnimations(arg_138_1, arg_141_0)
		end
	}, arg_138_2)
end

function StoryPlayer:StartBlinkAnimation(arg_142_1, arg_142_2)
	if arg_142_1:ShouldBlink() then
		local var_142_0 = arg_142_1:GetBlinkData()
		local var_142_1 = var_142_0.number
		local var_142_2 = var_142_0.dur
		local var_142_4 = var_142_0.alpha[1]
		local var_142_5 = var_142_0.alpha[2]
		local var_142_6 = var_142_0.wait

		self.flashImg.color = var_142_0.black and Color(0, 0, 0) or Color(1, 1, 1)

		setActive(self.flash, true)

		local var_142_8 = {}

		for iter_142_0 = 1, var_142_1 do
			table.insert(var_142_8, function(arg_143_0)
				self:TweenAlpha(self.flash, var_142_4, var_142_5, var_142_2 / 2, 0, function()
					self:TweenAlpha(self.flash, var_142_5, var_142_4, var_142_2 / 2, var_142_6, arg_143_0)
				end)
			end)
		end

		seriesAsync(var_142_8, function()
			setActive(self.flash, false)
		end)
	end

	arg_142_2()
end

function StoryPlayer:StartBlinkWithColorAnimation(arg_146_1, arg_146_2)
	if arg_146_1:ShouldBlinkWithColor() then
		local var_146_0 = arg_146_1:GetBlinkWithColorData()

		self.flashImg.color = Color(var_146_0.color[1], var_146_0.color[2], var_146_0.color[3], var_146_0.color[4])

		setActive(self.flash, true)

		local var_146_1 = {}

		for iter_146_0, iter_146_1 in ipairs(var_146_0.alpha) do
			local var_146_2 = iter_146_1[1]
			local var_146_3 = iter_146_1[2]
			local var_146_4 = iter_146_1[3]
			local var_146_5 = iter_146_1[4]

			table.insert(var_146_1, function(arg_147_0)
				self:TweenValue(self.flash, var_146_2, var_146_3, var_146_4, var_146_5, function(arg_148_0)
					self.flashCg.alpha = arg_148_0
				end, arg_147_0)
			end)
		end

		parallelAsync(var_146_1, function()
			setActive(self.flash, false)
		end)
	end

	arg_146_2()
end

function StoryPlayer:OnStart(arg_150_1)
	return
end

function StoryPlayer:OnReset(arg_151_1, arg_151_2, arg_151_3)
	arg_151_3()
end

function StoryPlayer:OnBgUpdate(arg_152_1)
	return
end

function StoryPlayer:OnInit(arg_153_1, arg_153_2, arg_153_3)
	if arg_153_3 then
		arg_153_3()
	end
end

function StoryPlayer:OnStartUIAnimations(arg_154_1, arg_154_2)
	if arg_154_2 then
		arg_154_2()
	end
end

function StoryPlayer:OnEnter(arg_155_1, arg_155_2, arg_155_3)
	if arg_155_3 then
		arg_155_3()
	end
end

function StoryPlayer:OnWillExit(arg_156_1, arg_156_2, arg_156_3)
	arg_156_3()
end

function StoryPlayer:OnWillClear(arg_157_1)
	return
end

function StoryPlayer:OnClear()
	return
end

function StoryPlayer:OnEnd(arg_159_1)
	return
end

return StoryPlayer
