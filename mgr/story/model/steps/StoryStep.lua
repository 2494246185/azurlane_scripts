local StoryStep = class("StoryStep")

StoryStep.OPTION_ANIM_ONLY_BTN = 1
StoryStep.OPTION_ANIM_ONLY_ICON = 2
StoryStep.OPTION_ANIM_BOTH = 3

function StoryStep:Ctor(arg_1_1)
	self.flashout = arg_1_1.flashout
	self.flashin = arg_1_1.flashin
	self.bgName = arg_1_1.bgName
	self.bgShadow = arg_1_1.bgShadow
	self.blackBg = arg_1_1.blackBg
	self.blackFg = arg_1_1.blackFg or 0
	self.bgGlitchArt = arg_1_1.bgNoise
	self.oldPhoto = arg_1_1.oldPhoto
	self.bgm = arg_1_1.bgm
	self.bgmDelay = arg_1_1.bgmDelay or 0
	self.bgmVolume = arg_1_1.bgmVolume or -1
	self.stopbgm = arg_1_1.stopbgm
	self.effects = arg_1_1.effects or {}
	self.blink = arg_1_1.flash
	self.blinkWithColor = arg_1_1.flashN
	self.soundeffect = arg_1_1.soundeffect
	self.seDelay = arg_1_1.seDelay or 0
	self.voice = arg_1_1.voice
	self.voiceDelay = arg_1_1.voiceDelay or 0
	self.stopVoice = defaultValue(arg_1_1.stopVoice, false)
	self.movableNode = arg_1_1.movableNode
	self.options = arg_1_1.options
	self.optionForceCenter = arg_1_1.option_force_center
	self.optionsEffect = arg_1_1.optionsEffect
	self.important = arg_1_1.important
	self.branchCode = arg_1_1.optionFlag
	self.globalBranchCode = arg_1_1.globalOptionFlag
	self.recallOption = arg_1_1.recallOption
	self.nextScriptName = arg_1_1.jumpto
	self.eventDelay = arg_1_1.eventDelay or 0
	self.bgColor = arg_1_1.bgColor or {
		0,
		0,
		0
	}
	self.location = arg_1_1.location
	self.icon = arg_1_1.icon
	self.dispatcher = arg_1_1.dispatcher
	self.shakeTime = defaultValue(arg_1_1.shakeTime, 0)
	self.code = arg_1_1.code or -1
	self.autoShowOption = defaultValue(arg_1_1.autoShowOption, false)
	self.selectedBranchCode = 0
	self.id = 0
	self.placeholderType = 0
	self.defaultTb = arg_1_1.defaultTb
	self.optionIndex = 0
	self.isExecuted = false
end

function StoryStep:MarkIsExecuted()
	self.isExecuted = true
end

function StoryStep:GetIsExecuted()
	return self.isExecuted
end

function StoryStep:GetOptionEffects()
	if not self.optionsEffect then
		return nil
	end

	local var_4_0 = self.optionsEffect[1] or 1
	local var_4_1 = self.optionsEffect[2] or 1

	return {
		string.format("StoryOptionEffect%s", var_4_0),
		string.format("StoryOptionEffect%sIcon", var_4_1)
	}, self.optionsEffect[3] or StoryStep.OPTION_ANIM_BOTH
end

function StoryStep:IsValid(arg_5_1)
	if self.code == -1 then
		return true
	end

	if type(self.code) == "string" or type(self.code) == "number" then
		return self.code == arg_5_1
	elseif type(self.code) == "table" then
		return table.contains(self.code, arg_5_1)
	end

	return false
end

function StoryStep:ShouldShake()
	return self.shakeTime > 0
end

function StoryStep:GetShakeTime()
	return self.shakeTime
end

function StoryStep:SetDefaultTb(arg_8_1)
	if not self.defaultTb or self.defaultTb <= 0 then
		self.defaultTb = arg_8_1
	end
end

function StoryStep:SetPlaceholderType(arg_9_1)
	self.placeholderType = arg_9_1
end

function StoryStep:ShouldReplacePlayer()
	return bit.band(self.placeholderType, Story.PLAYER) > 0
end

function StoryStep:ShouldReplaceTb()
	return bit.band(self.placeholderType, Story.TB) > 0
end

function StoryStep:ShouldReplaceDorm()
	return bit.band(self.placeholderType, Story.DORM) > 0
end

function StoryStep:ShouldReplaceCar2026()
	return bit.band(self.placeholderType, Story.CAR2026) > 0
end

function StoryStep:ReplacePlayerName(arg_14_1)
	if getProxy(PlayerProxy) then
		if not getProxy(PlayerProxy):getRawData() then
			return arg_14_1
		end
	end

	arg_14_1 = string.gsub(arg_14_1, "{playername}", (getProxy(PlayerProxy):getRawData():GetName()))

	return arg_14_1
end

function StoryStep:ReplaceTbName(arg_15_1)
	if pg.NewStoryMgr.GetInstance():IsReView() then
		return string.gsub(arg_15_1, "{tb}", i18n("child_story_name"))
	end

	if not getProxy(EducateProxy) or not getProxy(NewEducateProxy) then
		return arg_15_1
	end

	if not getProxy(NewEducateProxy):GetCurChar() then
		local var_15_0, var_15_1 = getProxy(EducateProxy):GetStoryInfo()

		arg_15_1 = string.gsub(arg_15_1, "{tb}", var_15_1)
	else
		local var_15_2, var_15_3 = getProxy(NewEducateProxy):GetStoryInfo()

		arg_15_1 = string.gsub(arg_15_1, "{tb}", var_15_3)
	end

	return arg_15_1
end

function StoryStep:ReplaceDormName(arg_16_1)
	if not self.actorName then
		return arg_16_1
	end

	local var_16_0 = getProxy(ApartmentProxy):getApartment(self.actorName)

	arg_16_1 = string.gsub(arg_16_1, "{dorm3d}", var_16_0 and var_16_0:GetCallName() or self.actorName)

	return arg_16_1
end

function StoryStep:ReplaceCar2026Name(arg_17_1)
	local var_17_0 = getProxy(ActivityProxy)
	local var_17_1 = var_17_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_MONOPOLY)
	local var_17_2 = ""

	if getProxy(PlayerProxy) then
		var_17_2 = getProxy(PlayerProxy):getRawData():GetName()
	end

	if var_17_1 then
		local var_17_3 = var_17_0:RawGetActivityById(var_17_1:getConfig("config_client").link_act)

		if var_17_3 and not var_17_3:isEnd() then
			var_17_2 = var_17_3.str_data1
		end
	end

	return string.gsub(arg_17_1, "{car2026}", var_17_2)
end

function StoryStep:ExistDispatcher()
	return self.dispatcher ~= nil
end

function StoryStep:GetDispatcher()
	return self.dispatcher
end

function StoryStep:IsRecallDispatcher()
	if not self:ExistDispatcher() then
		return false
	end

	local var_20_0 = self:GetDispatcher()

	return var_20_0.callbackData ~= nil and var_20_0.callbackData.name ~= nil
end

function StoryStep:GetDispatcherRecallName()
	if not self:IsRecallDispatcher() then
		return nil
	end

	return self:GetDispatcher().callbackData.name
end

function StoryStep:ShouldHideUI()
	if not self:IsRecallDispatcher() then
		return false
	end

	return self:GetDispatcher().callbackData.hideUI == true
end

function StoryStep:ExistIcon()
	return self.icon ~= nil
end

function StoryStep:GetIconData()
	return self.icon
end

function StoryStep:SetId(arg_25_1)
	self.id = arg_25_1
end

function StoryStep:GetId()
	return self.id
end

function StoryStep:AutoShowOption()
	self.autoShowOption = true
end

function StoryStep:SkipEventForOption()
	return self:ExistOption() and self.autoShowOption
end

function StoryStep:IsRecallOption()
	if self:ExistOption() and self:GetOptionCnt() > 1 and self.recallOption then
		return true
	end

	return false
end

function StoryStep:IsOptionForceCenter()
	return self.optionForceCenter
end

function StoryStep:SetBranchCode(arg_31_1)
	self.selectedBranchCode = arg_31_1
end

function StoryStep:GetSelectedBranchCode()
	return self.selectedBranchCode
end

function StoryStep:ExistLocation()
	return self.location ~= nil
end

function StoryStep:GetLocation()
	local var_34_0 = {}

	var_34_0.text = self.location[1] or ""
	var_34_0.time = self.location[2] or 999

	return var_34_0
end

function StoryStep:ExistMovableNode()
	return self.movableNode ~= nil and type(self.movableNode) == "table" and #self.movableNode > 0
end

function StoryStep:GetPathByString(arg_36_1, arg_36_2)
	local var_36_0 = {}
	local var_36_1 = pg.NewStoryMgr.GetInstance():GetRectSize()
	local var_36_2 = Vector3(-var_36_1.x * 0.5, var_36_1.y * 0.5, 0)
	local var_36_3 = Vector3(var_36_1.x * 0.5, var_36_1.y * 0.5, 0)
	local var_36_4 = Vector3(-var_36_1.x * 0.5, -var_36_1.y * 0.5, 0)
	local var_36_5 = Vector3(var_36_1.x * 0.5, -var_36_1.y * 0.5, 0)
	local var_36_6 = arg_36_2 or 200

	if arg_36_1 == "LTLB" then
		local var_36_7 = Vector3(var_36_6, 0, 0)

		var_36_0 = {
			var_36_2 + var_36_7,
			var_36_4 + var_36_7
		}
	elseif arg_36_1 == "LBLT" then
		local var_36_8 = Vector3(var_36_6, 0, 0)

		var_36_0 = {
			var_36_4 + var_36_8,
			var_36_2 + var_36_8
		}
	elseif arg_36_1 == "LTRT" then
		local var_36_9 = Vector3(0, -var_36_6, 0)

		var_36_0 = {
			var_36_2 + var_36_9,
			var_36_3 + var_36_9
		}
	elseif arg_36_1 == "RTLT" then
		local var_36_10 = Vector3(0, -var_36_6, 0)

		var_36_0 = {
			var_36_3 + var_36_10,
			var_36_2 + var_36_10
		}
	elseif arg_36_1 == "RTRB" then
		local var_36_11 = Vector3(var_36_6, 0, 0)

		var_36_0 = {
			var_36_3 + var_36_11,
			var_36_5 + var_36_11
		}
	elseif arg_36_1 == "RBRT" then
		local var_36_12 = Vector3(var_36_6, 0, 0)

		var_36_0 = {
			var_36_5 + var_36_12,
			var_36_3 + var_36_12
		}
	elseif arg_36_1 == "LBRB" then
		local var_36_13 = Vector3(0, -(arg_36_2 or 0), 0)

		var_36_0 = {
			var_36_4 + var_36_13,
			var_36_5 + var_36_13
		}
	elseif arg_36_1 == "RBLB" then
		local var_36_14 = Vector3(0, -(arg_36_2 or 0), 0)

		var_36_0 = {
			var_36_5 + var_36_14,
			var_36_4 + var_36_14
		}
	end

	return var_36_0
end

function StoryStep:GenMoveNode(arg_37_1)
	local var_37_0 = {}

	if type(arg_37_1.path) == "table" then
		for iter_37_0, iter_37_1 in ipairs(arg_37_1.path) do
			table.insert(var_37_0, Vector3(iter_37_1[1], iter_37_1[2], 0))
		end
	else
		var_37_0 = type(arg_37_1.path) == "string" and self:GetPathByString(arg_37_1.path, arg_37_1.offset) or self:GetPathByString("LTRT")
	end

	local var_37_1 = type(arg_37_1.spine) == "table" or arg_37_1.spine == true
	local var_37_2

	if arg_37_1.spine == true then
		var_37_2 = {
			action = "walk",
			scale = 0.5
		}
	elseif var_37_1 then
		local var_37_3 = {}

		var_37_3.action = arg_37_1.spine.action or "walk"
		var_37_3.scale = arg_37_1.spine.scale or 0.5
		var_37_2 = var_37_3
	end

	local var_37_4 = {
		name = arg_37_1.name,
		isSpine = var_37_1,
		spineData = var_37_2,
		path = var_37_0,
		time = arg_37_1.time
	}

	var_37_4.delay = arg_37_1.delay or 0
	var_37_4.easeType = arg_37_1.easeType or LeanTweenType.linear

	return var_37_4
end

function StoryStep:GetMovableNode()
	if not self:ExistMovableNode() then
		return {}
	end

	local var_38_0 = {}

	for iter_38_0, iter_38_1 in pairs(self.movableNode or {}) do
		table.insert(var_38_0, (self:GenMoveNode(iter_38_1)))
	end

	return var_38_0
end

function StoryStep:OldPhotoEffect()
	return self.oldPhoto
end

function StoryStep:ShouldBgGlitchArt()
	return self.bgGlitchArt
end

function StoryStep:IsSameBranch(arg_41_1)
	return not self.branchCode or self.branchCode == arg_41_1
end

function StoryStep:IsGlobalFlagHit()
	local var_42_0 = StoryStep.GetGlobalFlagKey(self.globalBranchCode.id)
	local var_42_1 = 0

	while PlayerPrefs.HasKey(var_42_0 .. 1) do
		var_42_1 = var_42_1 + PlayerPrefs.GetInt(var_42_0 .. 1)
	end

	for iter_42_0, iter_42_1 in ipairs(self.globalBranchCode.section) do
		if var_42_1 >= iter_42_1[1] and var_42_1 <= iter_42_1[2] then
			return true
		end
	end

	return false
end

function StoryStep:GetGlobalFlagKey()
	return getProxy(PlayerProxy):getRawData().id .. "GlobalStoryFlag_" .. self .. "_"
end

function StoryStep:GetMode()
	assert(false, "should override this function")
end

function StoryStep:GetFlashoutData()
	if self.flashout then
		return self.flashout.alpha[1], self.flashout.alpha[2], self.flashout.dur, self.flashout.black
	end
end

function StoryStep:GetFlashinData()
	if self.flashin then
		return self.flashin.alpha[1], self.flashin.alpha[2], self.flashin.dur, self.flashin.black, self.flashin.delay
	end
end

function StoryStep:GetBgColor()
	return Color.New(self.bgColor[1] or 0, self.bgColor[2] or 0, self.bgColor[3] or 0)
end

function StoryStep:IsBlackBg()
	return self.blackBg
end

function StoryStep:GetBgName()
	return self.bgName
end

function StoryStep:GetBgShadow()
	return self.bgShadow
end

function StoryStep:IsDialogueMode()
	return self:GetMode() == Story.MODE_DIALOGUE
end

function StoryStep:GetBgmData()
	return self.bgm, self.bgmDelay, self.bgmVolume
end

function StoryStep:ShoulePlayBgm()
	return self.bgm ~= nil
end

function StoryStep:ShouldStopBgm()
	return self.stopbgm
end

function StoryStep:GetEffects()
	return self.effects
end

function StoryStep:ShouldBlink()
	return self.blink ~= nil
end

function StoryStep:GetBlinkData()
	return self.blink
end

function StoryStep:ShouldBlinkWithColor()
	return self.blinkWithColor ~= nil
end

function StoryStep:GetBlinkWithColorData()
	return self.blinkWithColor
end

function StoryStep:ShouldPlaySoundEffect()
	return self.soundeffect ~= nil
end

function StoryStep:GetSoundeffect()
	return self.soundeffect, self.seDelay
end

function StoryStep:ShouldPlayVoice()
	return self.voice ~= nil
end

function StoryStep:ShouldStopVoice()
	return self.stopVoice
end

function StoryStep:GetVoice()
	return self.voice, self.voiceDelay
end

function StoryStep:ExistOption()
	return self.options ~= nil and #self.options > 0
end

function StoryStep:GetOptionCnt()
	if self:ExistOption() then
		return #self.options
	else
		return 0
	end
end

function StoryStep:SetOptionSelCodes(arg_67_1)
	self.optionSelCode = arg_67_1
end

function StoryStep:IsBlackFrontGround()
	return self.blackFg > 0, Mathf.Clamp01(self.blackFg)
end

function StoryStep:GetOptionIndexByAutoSel()
	local var_69_0 = 0
	local var_69_1 = 0

	for iter_69_0, iter_69_1 in ipairs(self.options) do
		if self.optionSelCode and iter_69_1.flag == self.optionSelCode then
			var_69_0 = iter_69_0

			break
		end

		if iter_69_1.autochoice and iter_69_1.autochoice == 1 then
			var_69_1 = iter_69_0
		end
	end

	if var_69_0 > 0 then
		return var_69_0
	end

	if var_69_1 > 0 then
		return var_69_1
	end

	return nil
end

function StoryStep:IsImport()
	return self.important
end

function StoryStep:SetOptionIndex(arg_71_1)
	self.optionIndex = arg_71_1
end

function StoryStep:GetOptionIndex()
	return self.optionIndex
end

function StoryStep:GetOptions()
	return _.map(self.options or {}, function(arg_74_0)
		local var_74_0 = arg_74_0.content

		if self:ShouldReplacePlayer() then
			var_74_0 = self:ReplacePlayerName(var_74_0)
		end

		if self:ShouldReplaceTb() then
			var_74_0 = self:ReplaceTbName(var_74_0)
		end

		if self:ShouldReplaceDorm() then
			var_74_0 = self:ReplaceDormName(var_74_0)
		end

		local var_74_1

		if self:ShouldReplaceCar2026() then
			var_74_0 = self:ReplaceCar2026Name(var_74_0)
			var_74_1 = {}
		end

		var_74_1[1] = HXSet.hxLan(var_74_0)
		var_74_1[2] = arg_74_0.flag
		var_74_1[3] = arg_74_0.type
		var_74_1[4] = arg_74_0.globalFlag

		return var_74_1
	end)
end

function StoryStep:ShouldJumpToNextScript()
	return self.nextScriptName ~= nil
end

function StoryStep:GetNextScriptName()
	return self.nextScriptName
end

function StoryStep:ShouldDelayEvent()
	return self.eventDelay and self.eventDelay > 0
end

function StoryStep:GetEventDelayTime()
	return self.eventDelay
end

function StoryStep:GetUsingPaintingNames()
	return {}
end

function StoryStep:GetResList()
	local var_80_0 = {}
	local var_80_1 = self:GetBgName()

	if var_80_1 then
		table.insert(var_80_0, var_80_1)
	end

	if self.GetSubBg then
		local var_80_2 = self:GetSubBg()

		if var_80_2 then
			table.insert(var_80_0, var_80_2)
		end
	end

	local var_80_3 = _.map(var_80_0, function(arg_81_0)
		return ResPathSupport.CombinePath(ResPathSupport.ConstPath.BG.Base, arg_81_0)
	end)
	local var_80_4 = {}
	local var_80_5 = {}
	local var_80_6, var_80_7, var_80_8 = self:GetBgmData()

	if var_80_6 then
		table.insert(var_80_4, var_80_6)
	end

	if self:ShouldPlaySoundEffect() then
		local var_80_9, var_80_10 = self:GetSoundeffect()

		if var_80_9 then
			local var_80_11 = pg.CriMgr.GetInstance():CheckFModeEvent(var_80_9, function()
				return
			end, function()
				return
			end)

			if var_80_11 then
				table.insert(var_80_4, var_80_11)
			end
		end
	end

	if self:ShouldPlayVoice() then
		local var_80_12, var_80_13 = self:GetVoice()

		if var_80_12 then
			local var_80_14 = pg.CriMgr.GetInstance():CheckFModeEvent(var_80_12, function()
				return
			end, function()
				return
			end)

			if var_80_14 then
				table.insert(var_80_4, var_80_14)
			end
		end
	end

	_.each(var_80_4, function(arg_86_0)
		table.insertto(var_80_5, (ResPathSupport.GetSoundResList(arg_86_0)))
	end)

	local var_80_15 = {}

	_.each(self:GetEffects(), function(arg_87_0)
		table.insert(var_80_15, arg_87_0.name)
	end)

	local var_80_16 = {}

	_.each(var_80_15, function(arg_88_0)
		table.insert(var_80_16, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Base, arg_88_0)))
		table.insert(var_80_16, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, arg_88_0)))
	end)

	local var_80_17 = {}

	if self:ExistIcon() then
		local var_80_18 = self:GetIconData()

		if var_80_18 and var_80_18.image then
			table.insert(var_80_17, var_80_18.image)
		end
	end

	local var_80_19 = {}
	local var_80_20 = StoryRecorder.New()

	var_80_20:Add(self)
	_.each(var_80_20:GetContentList(), function(arg_89_0)
		if arg_89_0.icon then
			table.insertto(var_80_19, (ResPathSupport.GetPaintingSquareIconListByPaintingName(arg_89_0.icon)))
		end
	end)

	return (ResPathSupport.MergeLuaArr(var_80_3, var_80_5, var_80_16, var_80_17, var_80_19))
end

return StoryStep
