local EducateCharProfileScene = class("EducateCharProfileScene", import("view.base.BaseUI"))

function EducateCharProfileScene:getUIName()
	return "EducateCharProfileUI"
end

function EducateCharProfileScene:getResource(arg_2_1)
	return ResPathSupport.MergeLuaArr({
		"ui/educatecharprofileui",
		"cue/story-richang-8.b"
	}, (function()
		local var_3_0 = {}

		for iter_3_0, iter_3_1 in ipairs(pg.secretary_special_ship.all) do
			if pg.secretary_special_ship[iter_3_1].painting then
				table.insert(var_3_0, "painting/" .. pg.secretary_special_ship[iter_3_1].painting)
				table.insert(var_3_0, "paintingface/" .. pg.secretary_special_ship[iter_3_1].painting)
			end
		end

		return var_3_0
	end)())
end

function EducateCharProfileScene:init()
	self.backBtn = self._tf:Find("adapt/top/back")
	self.homeBtn = self._tf:Find("adapt/top/home")
	self.paintingTr = self._tf:Find("main/mask/painting")
	self.chatTf = self._tf:Find("main/chat")
	self.chatTxt = self.chatTf:Find("Text"):GetComponent(typeof(Text))
	self.toggleUIItemList = UIItemList.New(self._tf:Find("main/tag"), self._tf:Find("main/tag/tpl"))
	self.wordUIItemList = UIItemList.New(self._tf:Find("main/list/content"), self._tf:Find("main/list/content/tpl"))
	self.tabItemList = UIItemList.New(self._tf:Find("tab/list"), self._tf:Find("tab/list/tpl"))
	self.cvLoader = EducateCharCvLoader.New()
	self.animation = self._tf:GetComponent(typeof(Animation))
	self.timers = {}
end

function EducateCharProfileScene:didEnter()
	onButton(self, self.backBtn, function()
		self:emit(EducateCharProfileScene.ON_BACK)
	end, SFX_PANEL)
	onButton(self, self.homeBtn, function()
		self:emit(EducateCharProfileScene.ON_HOME)
	end, SFX_PANEL)
	self:InitTabs()
	self:InitToggles()
end

function EducateCharProfileScene:InitTabs()
	self.characterList = NewEducateHelper.GetEducateCharacterList()
	self.selectedCharacterId = self.contextData.selectedCharacterId

	self.tabItemList:make(function(arg_9_0, arg_9_1, arg_9_2)
		local var_9_0 = arg_9_1 + 1
		local var_9_1 = self.characterList[arg_9_1 + 1]

		if arg_9_0 == UIItemList.EventUpdate then
			setActive(arg_9_2:Find("lock"), self.characterList[arg_9_1 + 1]:IsLock())
			setActive(arg_9_2:Find("border/selected"), arg_9_1 + 1 == self.selectedCharacterId)
			setActive(arg_9_2:Find("border/normal"), arg_9_1 + 1 ~= self.selectedCharacterId)
		elseif arg_9_0 == UIItemList.EventInit then
			GetImageSpriteFromAtlasAsync("qicon/" .. self.characterList[arg_9_1 + 1]:GetDefaultFrame(), "", arg_9_2:Find("frame"))
			onButton(self, arg_9_2, function()
				if var_9_1:IsLock() then
					pg.TipsMgr.GetInstance():ShowTips(i18n("secretary_special_character_unlock"))

					return
				end

				if var_9_0 ~= self.selectedCharacterId then
					self.selectedCharacterId = var_9_0

					self.tabItemList:align(#self.characterList)
					self:InitToggles()
				end
			end)
		end
	end)
	self.tabItemList:align(#self.characterList)
end

function EducateCharProfileScene:InitToggles()
	local var_11_0 = self.characterList[self.selectedCharacterId]:GetGroupList()

	table.sort(var_11_0, function(arg_12_0, arg_12_1)
		return arg_12_0:GetSortWeight() < arg_12_1:GetSortWeight()
	end)
	self.toggleUIItemList:make(function(arg_13_0, arg_13_1, arg_13_2)
		if arg_13_0 == UIItemList.EventUpdate then
			self:UpdateToggle(arg_13_2, var_11_0[arg_13_1 + 1])

			if arg_13_1 == 0 then
				self.isInit = true

				triggerToggle(arg_13_2, true)
			end
		end
	end)
	self.toggleUIItemList:align(#var_11_0)

	self.isInit = false
end

function EducateCharProfileScene:UpdateToggle(arg_14_1, arg_14_2)
	setImageSprite(arg_14_1:Find("sel/Text"), GetSpriteFromAtlas("ui/EducateCharProfileUI_atlas", arg_14_2:GetSpriteName()), true)
	setImageSprite(arg_14_1:Find("Text"), GetSpriteFromAtlas("ui/EducateCharProfileUI_atlas", arg_14_2:GetSpriteName()), true)
	setActive(arg_14_1:Find("lock"), arg_14_2:IsLock())
	onToggle(self, arg_14_1, function(arg_15_0)
		if arg_15_0 then
			if not self.isInit then
				self.animation:Play("anim_educate_profile_change")

				self.isInit = nil
			end

			local var_15_0 = arg_14_2:GetShowId()

			self:ClearCurrentWord()
			self:InitPainting(var_15_0)
			self:InitWordList(var_15_0)
		end
	end, SFX_PANEL)
end

function EducateCharProfileScene:GetWordList(arg_16_1)
	local var_16_0 = {}

	for iter_16_0, iter_16_1 in ipairs(pg.character_voice_special.all) do
		if EducateCharWordHelper.ExistWord(arg_16_1, (string.find(iter_16_1, ShipWordHelper.WORD_TYPE_MAIN) or nil) and ShipWordHelper.WORD_TYPE_MAIN .. "_" .. string.gsub(iter_16_1, ShipWordHelper.WORD_TYPE_MAIN, "")) then
			table.insert(var_16_0, iter_16_1)
		end
	end

	return var_16_0
end

function EducateCharProfileScene:InitWordList(arg_17_1)
	local var_17_0 = self:GetWordList(arg_17_1)

	self:RemoveAllTimer()
	self.wordUIItemList:make(function(arg_18_0, arg_18_1, arg_18_2)
		if arg_18_0 == UIItemList.EventUpdate then
			self:UpdateWordCard(arg_18_2, arg_17_1, var_17_0[arg_18_1 + 1], arg_18_1)
		end
	end)
	self.wordUIItemList:align(#var_17_0)
end

function EducateCharProfileScene:UpdateWordCard(arg_19_1, arg_19_2, arg_19_3, arg_19_4)
	local var_19_0 = arg_19_1:Find("bg")
	local var_19_1 = pg.character_voice_special[arg_19_3]

	setText(var_19_0:Find("Text"), pg.character_voice_special[arg_19_3].voice_name)

	local var_19_2 = -1

	onButton(self, var_19_0, function()
		if self.chatting then
			return
		end

		local var_20_0, var_20_1, var_20_2, var_20_3 = EducateCharWordHelper.GetWordAndCV(arg_19_2, var_19_1.resource_key)

		seriesAsync({
			function(arg_21_0)
				self:OnChatStart(var_19_0, var_20_2, arg_21_0)
			end,
			function(arg_22_0)
				self:UpdateExpression(arg_19_2, var_19_1.resource_key)
				self:PlayCV(var_20_3, var_20_0, function(arg_23_0)
					var_19_2 = arg_23_0

					arg_22_0()
				end)
			end,
			function(arg_24_0)
				self:StartCharAnimation(var_19_2, arg_24_0)
			end
		}, function()
			self:OnChatEnd()
		end)
	end, SFX_PANEL)
	setActive(var_19_0, false)

	self.timers[arg_19_4] = Timer.New(function()
		setActive(var_19_0, true)
		arg_19_1:GetComponent(typeof(Animation)):Play("anim_educate_profile_tpl")
	end, math.max(1e-05, arg_19_4 * 0.066), 1)

	self.timers[arg_19_4]:Start()
end

function EducateCharProfileScene:RemoveAllTimer()
	for iter_27_0, iter_27_1 in pairs(self.timers) do
		iter_27_1:Stop()

		iter_27_1 = nil
	end

	self.timers = {}
end

function EducateCharProfileScene:OnChatStart(arg_28_1, arg_28_2, arg_28_3)
	self.chatting = true
	self.chatTxt.text = arg_28_2

	triggerToggle(arg_28_1:Find("state"), true)

	self.selectedCard = arg_28_1

	arg_28_3()
end

function EducateCharProfileScene:UpdateExpression(arg_29_1, arg_29_2)
	local var_29_0 = EducateCharWordHelper.GetExpression(arg_29_1, arg_29_2)

	if var_29_0 and var_29_0 ~= "" then
		ShipExpressionHelper.UpdateExpression(findTF(self.paintingTr, "fitter"):GetChild(0), self.paintingName, var_29_0)
	else
		ShipExpressionHelper.UpdateExpression(findTF(self.paintingTr, "fitter"):GetChild(0), self.paintingName, "")
	end
end

function EducateCharProfileScene:OnChatEnd()
	self:ClearCurrentWord()
end

function EducateCharProfileScene:PlayCV(arg_31_1, arg_31_2, arg_31_3)
	self.cvLoader:Play(arg_31_1, arg_31_2, 0, arg_31_3)
end

function EducateCharProfileScene:StartCharAnimation(arg_32_1, arg_32_2)
	local var_32_0 = 0.3
	local var_32_1 = arg_32_1 > 0 and arg_32_1 or 3

	LeanTween.scale(rtf(self.chatTf.gameObject), Vector3.New(1, 1, 1), 0.3):setEase(LeanTweenType.easeOutBack):setOnComplete(System.Action(function()
		LeanTween.scale(rtf(self.chatTf.gameObject), Vector3.New(0, 0, 1), var_32_0):setEase(LeanTweenType.easeInBack):setDelay(var_32_0 + var_32_1):setOnComplete(System.Action(arg_32_2))
	end))
end

function EducateCharProfileScene:InitPainting(arg_34_1)
	self:ReturnPainting()
	setPaintingPrefabAsync(self.paintingTr, pg.secretary_special_ship[arg_34_1].painting, "tb3")

	self.paintingName = pg.secretary_special_ship[arg_34_1].painting
end

function EducateCharProfileScene:ReturnPainting()
	if self.paintingName then
		retPaintingPrefab(self.paintingTr, self.paintingName)

		self.paintingName = nil
	end
end

function EducateCharProfileScene:ClearCurrentWord()
	self.chatting = nil

	LeanTween.cancel(self.chatTf.gameObject)

	self.chatTf.localScale = Vector3.zero

	self.cvLoader:Stop()

	if not self.selectedCard then
		return
	end

	self.selectedCard = nil

	triggerToggle(self.selectedCard:Find("state"), false)
end

function EducateCharProfileScene:onBackPressed()
	EducateCharProfileScene.super.onBackPressed(self)
end

function EducateCharProfileScene:willExit()
	self:ClearCurrentWord()
	self:RemoveAllTimer()
	self:ReturnPainting()

	if self.cvLoader then
		self.cvLoader:Dispose()

		self.cvLoader = nil
	end
end

return EducateCharProfileScene
