local LoveLetterDisplayLayer = class("LoveLetterDisplayLayer", import("view.base.BaseUI"))

function LoveLetterDisplayLayer:getUIName()
	return "LoveLetterDisplayUI"
end

function LoveLetterDisplayLayer:preload(arg_2_1)
	pg.PoolMgr.GetInstance():GetPrefab("LoveLetterStyle/" .. self.contextData.prefab, "", true, function(arg_3_0)
		self.rtStyle = arg_3_0.transform

		arg_2_1()
	end)
end

function LoveLetterDisplayLayer:getResource()
	local var_4_0 = LoveLetterDisplayLayer.super.getResource(self)
	local var_4_1 = {}

	local function var_4_2(arg_5_0)
		if noEmptyStr(arg_5_0) and not table.contains(var_4_1, arg_5_0) then
			table.insert(var_4_1, arg_5_0)
		end
	end

	var_4_2("LoveLetterStyle/" .. self.contextData.prefab)
	var_4_2("loveletteranim/loveletteranim")
	var_4_2("bg/" .. self.contextData.bg)
	var_4_2("loveletterstyleatlas/mail_" .. self.contextData.prefab)

	local var_4_3 = getProxy(LoveLetterProxy)
	local var_4_4 = var_4_3 and var_4_3:GetGroupData(self.contextData.groupId)

	if var_4_4 then
		local var_4_5 = var_4_4:GetDisplayInfo()

		if var_4_5 then
			var_4_2("loveletterstyleatlas/" .. var_4_5.hand)
			var_4_2("loveletterstyleatlas/" .. var_4_5.kiss)
		end

		local var_4_6 = var_4_4:GetPainting()

		if noEmptyStr(var_4_6) then
			PaintingGroupConst.AddPaintingNameWithFilteMap(var_4_1, var_4_6)
		end
	end

	for iter_4_0, iter_4_1 in ipairs(var_4_1) do
		if noEmptyStr(iter_4_1) and not table.contains(var_4_0, iter_4_1) then
			table.insert(var_4_0, iter_4_1)
		end
	end

	return var_4_0
end

LoveLetterDisplayLayer.optionsPath = {}

function LoveLetterDisplayLayer:SetLoveLetter(arg_6_1)
	self.ll = getProxy(LoveLetterProxy):GetGroupData(arg_6_1)
	self.letterIds = self.ll:GetDisplayLetterList()

	self:ShowLetter(self.contextData.letterId or self.letterIds[1])
end

function LoveLetterDisplayLayer:init()
	setParent(self.rtStyle, self.rtPanel)
	onButton(self, self.rtBg, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.rtStyle:Find("before"), function()
		self:emit(LoveLetterDisplayMediator.ON_UNLOCK_LETTER, self.letterId)
	end, SFX_PANEL)
	self:addRingDragListenter()
	self:BlurPanel(self._tf)
end

function LoveLetterDisplayLayer:didEnter()
	setText(self.rtStyle:Find("after/bg/paper_root/name"), self.ll:GetName())
end

function LoveLetterDisplayLayer:ChangeLetter(arg_11_1)
	local var_11_0 = table.indexof(self.letterIds, self.letterId) + arg_11_1

	if var_11_0 ~= math.clamp(var_11_0, 1, #self.letterIds) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("loveactivity_ui_15"))
	else
		self:ShowLetter(self.letterIds[var_11_0])
	end
end

function LoveLetterDisplayLayer:ShowLetter(arg_12_1)
	self.letterId = arg_12_1
	self.contextData.letterId = self.letterId

	setText(self.rtStyle:Find("after/bg/paper_root/content"), getProxy(LoveLetterProxy):GetLoveLetterContent(arg_12_1))

	local var_12_0 = table.indexof(self.letterIds, self.letterId)

	UIItemList.StaticAlign(self.rtPointsContainer, self.rtPointsTpl, #self.letterIds, function(arg_13_0, arg_13_1, arg_13_2)
		arg_13_1 = arg_13_1 + 1

		if arg_13_0 == UIItemList.EventUpdate then
			setActive(arg_13_2:Find("short"), arg_13_1 ~= var_12_0)
			setActive(arg_13_2:Find("long"), arg_13_1 == var_12_0)
			setActive(arg_13_2:Find("short/pick_up"), not self.ll:GetLetterUnlock(self.letterIds[arg_13_1]))
		end
	end)
	self:UpdateLetterDisplay(self.ll:GetLetterUnlock(self.letterId))
end

function LoveLetterDisplayLayer:DoOpenLetter()
	onButton(self, self.rtAnim:Find("click"), function()
		self.clickCall = nil

		existCall(self.clickCall)
	end, SFX_PANEL)

	GetOrAddComponent(self._tf, "EventTriggerListener").enabled = false

	setActive(self.rtPointsContainer, false)
	pg.UIMgr.GetInstance():LoadingOn()

	local var_14_0 = {}

	table.insert(var_14_0, function(arg_16_0)
		local var_16_0 = self.ll:GetDisplayInfo()

		parallelAsync({
			function(arg_17_0)
				pg.PoolMgr.GetInstance():GetPrefab("loveletteranim/loveletteranim", "", true, function(arg_18_0)
					self.rtAnimation = arg_18_0.transform

					arg_17_0()
				end)
			end,
			function(arg_19_0)
				LoadSpriteAtlasAsync("bg/" .. self.contextData.bg, "", function(arg_20_0)
					self.spriteBg = arg_20_0

					arg_19_0()
				end)
			end,
			function(arg_21_0)
				LoadSpriteAtlasAsync("loveletterstyleatlas/mail_" .. self.contextData.prefab, "", function(arg_22_0)
					self.spriteMail = arg_22_0

					arg_21_0()
				end)
			end,
			function(arg_23_0)
				LoadSpriteAtlasAsync("loveletterstyleatlas/" .. var_16_0.hand, "", function(arg_24_0)
					self.spriteHand = arg_24_0

					arg_23_0()
				end)
			end,
			function(arg_25_0)
				LoadSpriteAtlasAsync("loveletterstyleatlas/" .. var_16_0.kiss, "", function(arg_26_0)
					self.spriteKiss = arg_26_0

					arg_25_0()
				end)
			end
		}, function()
			setParent(self.rtAnimation, self.rtAnim:Find("content"))
			setImageSprite(self.rtAnimation:Find("bg_root/bg"), self.spriteBg)
			setImageSprite(self.rtAnimation:Find("fx_letter_in/deco_letter/deco_letter_1"), self.spriteMail)
			setImageSprite(self.rtAnimation:Find("fx_letter_in/deco_letter/lip_01"), self.spriteKiss, true)
			setImageSprite(self.rtAnimation:Find("hand/hand_deco"), self.spriteHand, true)
			self.rtAnimation:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_28_0)
				self.nextCall = nil

				existCall(self.nextCall, arg_28_0)
			end)
			eachChild(self.rtAnimation:Find("letter_style/root"), function(arg_29_0, arg_29_1)
				setActive(arg_29_0, arg_29_0.name == self.contextData.prefab)

				if arg_29_0.name == self.contextData.prefab then
					setText(arg_29_0:Find("after/bg/paper_root/name"), self.ll:GetName())
					setText(arg_29_0:Find("after/bg/paper_root/content"), getProxy(LoveLetterProxy):GetLoveLetterContent(self.contextData.letterId))
				end
			end)
			arg_16_0()
		end)
	end)
	table.insert(var_14_0, function(arg_30_0)
		setPaintingPrefab(self.rtAnimation:Find("painting_root/paint"), self.ll:GetPainting(), "mainNormal", nil, nil, arg_30_0)
	end)
	table.insert(var_14_0, function(arg_31_0)
		pg.UIMgr.GetInstance():LoadingOff()
		setActive(self.rtAnim, true)

		function self.nextCall()
			setActive(self.rtAnim:Find("click"), true)
		end

		self.clickCall = arg_31_0

		setActive(self.rtAnim:Find("click"), false)
		quickPlayAnimation(self.rtAnimation, "anim_LoveLetterDisplayUI_fadein_01")
	end)
	table.insert(var_14_0, function(arg_33_0)
		setActive(self.rtAnim, true)

		function self.nextCall()
			setActive(self.rtAnim:Find("click"), true)
		end

		self.clickCall = arg_33_0

		setActive(self.rtAnim:Find("click"), false)
		quickPlayAnimation(self.rtAnimation, "anim_LoveLetterDisplayUI_fadein_02")
	end)
	table.insert(var_14_0, function(arg_35_0)
		setActive(self.rtAnim, true)

		self.nextCall = arg_35_0

		setActive(self.rtAnim:Find("click"), false)
		quickPlayAnimation(self.rtAnimation, "anim_LoveLetterDisplayUI_fadeout_01")
	end)
	seriesAsync(var_14_0, function()
		setActive(self.rtAnim, false)
		setActive(self.rtPointsContainer, true)
		self:UpdateLetterDisplay(true)

		GetOrAddComponent(self._tf, "EventTriggerListener").enabled = true
	end)
end

function LoveLetterDisplayLayer:UpdateLetterDisplay(arg_37_1)
	setActive(self.rtStyle:Find("after"), arg_37_1)
	setActive(self.rtStyle:Find("before"), not arg_37_1)
	setButtonEnabled(self.rtStyle:Find("before"), not arg_37_1)

	if not arg_37_1 then
		setLoveLetterMedal(self.rtStyle:Find("before/medal"), setmetatable({
			level = table.indexof(pg.lover_letter_content.get_id_list_by_ship_group[self.ll.groupId], self.contextData.letterId)
		}, {
			__index = self.ll
		}))
	end
end

function LoveLetterDisplayLayer:addRingDragListenter()
	local var_38_0 = GetOrAddComponent(self._tf, "EventTriggerListener")
	local var_38_1
	local var_38_2 = 0

	var_38_0:AddBeginDragFunc(function()
		var_38_2 = 0
		var_38_1 = nil
	end)
	var_38_0:AddDragFunc(function(arg_40_0, arg_40_1)
		var_38_1 = var_38_1 or arg_40_1.position
		var_38_2 = arg_40_1.position.x - var_38_1.x
	end)
	var_38_0:AddDragEndFunc(function(arg_41_0, arg_41_1)
		if self.isBlock then
			return
		end

		if var_38_2 < -50 then
			self:ChangeLetter(1)
		elseif var_38_2 > 50 then
			self:ChangeLetter(-1)
		end
	end)
end

function LoveLetterDisplayLayer:willExit()
	if self.rtStyle then
		eachChild(self.rtStyle:Find("before/medal"), function(arg_43_0, arg_43_1)
			returnLoveLetterMedal(arg_43_0)
		end)
		pg.PoolMgr.GetInstance():ReturnPrefab("LoveLetterStyle/" .. self.contextData.prefab, "", self.rtStyle.gameObject)

		self.rtStyle = nil
	end

	if self.rtAnimation then
		retPaintingPrefab(self.rtAnimation:Find("painting_root/paint"), self.ll:GetPainting(), "mainNormal")
		pg.PoolMgr.GetInstance():ReturnPrefab("loveletteranim/loveletteranim", "", self.rtAnimation.gameObject)

		self.rtAnimation = nil
	end
end

return LoveLetterDisplayLayer
