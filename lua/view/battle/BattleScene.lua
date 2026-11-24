local BattleScene = class("BattleScene", import("..base.BaseUI"))

BattleScene.IN_VIEW_FRIEND_SKILL_OFFSET = Vector3(-5, 0, 6)
BattleScene.IN_VIEW_FOE_SKILL_OFFSET = Vector3(-15, 0, 6)
BattleScene.FOE_SIDE_X_OFFSET = 250
BattleScene.SKILL_FLOAT_SCALE = Vector3(1.5, 1.5, 0)
BattleScene.SIDE_ALIGNMENT = {
	{
		-120,
		-7.5,
		-232.5
	},
	{
		105,
		217.5,
		330
	},
	{
		-345,
		-457.5,
		-570
	}
}

local var_0_1

function BattleScene:getUIName()
	return "CombatUI" .. ys.Battle.BattleState.GetCombatSkinKey()
end

function BattleScene:forceRatio()
	return math.max(pg.CameraFixMgr.GetInstance().targetRatio, 1.7777777777777777)
end

function BattleScene:getBGM()
	local var_3_0 = {}

	table.insert(var_3_0, self.contextData.system == SYSTEM_WORLD and checkExist(pg.world_expedition_data[self.contextData.stageId], {
		"bgm"
	}) or "")
	table.insert(var_3_0, pg.expedition_data_template[self.contextData.stageId].bgm)

	for iter_3_0, iter_3_1 in ipairs(var_3_0) do
		if iter_3_1 ~= "" then
			return iter_3_1
		end
	end

	return BattleScene.super.getBGM(self)
end

function BattleScene:getResource()
	local var_4_0 = {}
	local var_4_1 = ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Base, self:getUIName())

	table.insert(var_4_0, var_4_1)
	table.insert(var_4_0, var_4_1 .. ResPathSupport.ConstPath.UI.Atlas)

	local var_4_2 = {}

	table.insert(var_4_2, self.contextData.system == SYSTEM_WORLD and checkExist(pg.world_expedition_data[self.contextData.stageId], {
		"bgm"
	}) or "")
	table.insert(var_4_2, pg.expedition_data_template[self.contextData.stageId].bgm)
	table.insert(var_4_2, BattleScene.super.getBGM(self))
	_.each(var_4_2, function(arg_5_0)
		if arg_5_0 ~= "" then
			table.insertto(var_4_0, ResPathSupport.GetSoundResList(arg_5_0))
		end
	end)

	return var_4_0
end

function BattleScene:init()
	var_0_1 = ys.Battle.BattleVariable

	local var_6_0 = pg.UIMgr.GetInstance():GetMainCamera()

	self.uiCanvas = findTF(GameObject.Find("UICamera"), "Canvas/UIMain")
	self.skillTips = self._tf:Find("Skill_Activation")
	self.skillRoot = self._tf:Find("Skill_Activation/Root")
	self.skillTpl = self._tf:Find("Skill_Activation/mask").gameObject
	self._skillFloatPool = pg.Pool.New(self.skillRoot, self.skillTpl, 15, 10, true, false):InitSize()

	self._skillFloatPool:SetRecycleFuncs(function(arg_7_0)
		arg_7_0.transform:GetComponent(typeof(DftAniEvent)):OnDestroy()
	end)

	self.skillCMDRoot = self._tf:Find("Skill_Activation/Root_cmd")
	self.skillCMDTpl = self._tf:Find("Skill_Activation/mask_cmd").gameObject
	self._skillFloatCMDPool = pg.Pool.New(self.skillCMDRoot, self.skillCMDTpl, 2, 4, true, false):InitSize()

	self._skillFloatCMDPool:SetRecycleFuncs(function(arg_8_0)
		arg_8_0.transform:GetComponent(typeof(DftAniEvent)):OnDestroy()
	end)

	self.popupTpl = self:getTpl("popup")

	SetActive(self._go, false)

	self._skillPaintings = {}
	self._skillFloat = true
	self._cacheSkill = {}
	self._commanderSkillList = {}
	self._sideSkillFloatStateList = {}
	self._sideSkillFloatStateList[ys.Battle.BattleConfig.FRIENDLY_CODE] = {
		{},
		{},
		{}
	}
	self._sideSkillFloatStateList[ys.Battle.BattleConfig.FOE_CODE] = {
		{},
		{},
		{}
	}

	self:initPainting()

	self._fxContainerUpper = self._tf:Find("FXContainerUpper")
	self._fxContainerBottom = self._tf:Find("FXContainerBottom")

	local var_6_1 = self._tf:GetComponentInParent(typeof(UnityEngine.Canvas))

	if var_6_1 then
		self._canvasOrder = var_6_1.sortingOrder or 0
	end

	self._ratioFitter = GetComponent(self._tf, typeof(AspectRatioFitter))

	if not BATTLE_DEFAULT_UNIT_DETAIL then
		self._go:AddComponent(typeof(RectMask2D))
	end
end

function BattleScene:initPainting()
	local var_9_0 = ys.Battle.BattleResourceManager.GetInstance():InstSkillPaintingUI()

	setParent(var_9_0, self.uiCanvas, false)

	self._paintingUI = var_9_0
	self._paintingAnimator = var_9_0:GetComponent(typeof(Animator))
	self._paintingAnimator.enabled = false
	self._paintingParticleContainer = findTF(var_9_0, "particleContainer")
	self._paintingParticles = findTF(self._paintingParticleContainer, "effect")
	self._paintingParticleSystem = self._paintingParticles:GetComponent(typeof(ParticleSystem))

	self._paintingParticleSystem:Stop(true)

	self._paintingFitter = findTF(var_9_0, "hero/fitter")

	removeAllChildren(self._paintingFitter)

	local var_9_1 = GetOrAddComponent(self._paintingFitter, "PaintingScaler")

	var_9_1.FrameName = "lihuisha"
	var_9_1.Tween = 1

	var_9_0:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_10_0)
		if self._currentPainting then
			setActive(self._currentPainting, false)

			self._currentPainting = nil
		end
	end)
end

function BattleScene:EnableSkillFloat(arg_11_1)
	if arg_11_1 == self._skillFloat then
		return
	end

	self._skillFloat = arg_11_1

	if self._skillFloat then
		for iter_11_0, iter_11_1 in ipairs(self._cacheSkill) do
			self:SkillHrzPop(iter_11_1.skillName, iter_11_1.caster, iter_11_1.commander, iter_11_1.hrzIcon)
		end

		self._cacheSkill = {}
	else
		self._skillFloatPool:AllRecycle()
		self._skillFloatCMDPool:AllRecycle()

		self._preCommanderSkillTF = nil
		self._preSkillTF = nil
	end

	SetActive(self.skillTips, arg_11_1)
end

function BattleScene:SkillHrzPop(arg_12_1, arg_12_2, arg_12_3, arg_12_4)
	if not self._skillFloat then
		table.insert(self._cacheSkill, {
			skillName = arg_12_1,
			caster = arg_12_2,
			commander = arg_12_3,
			hrzIcon = arg_12_4
		})

		return
	end

	local var_12_0 = ys.Battle.BattleResourceManager.GetInstance()
	local var_12_1
	local var_12_2

	if arg_12_3 then
		if self._commanderSkillList[arg_12_3] and self._commanderSkillList[arg_12_3][arg_12_1] then
			return
		end

		var_12_1 = self._skillFloatCMDPool
		var_12_2 = ys.Battle.BattleState.GetCombatSkinKey() == "Standard" and var_12_0:GetCommanderHrzIcon(arg_12_3) or var_12_0:GetCommanderIcon(arg_12_3)
	else
		var_12_1 = self._skillFloatPool

		if arg_12_2:GetUnitType() == ys.Battle.BattleConst.UnitType.PLAYER_UNIT then
			local var_12_3 = arg_12_4 or arg_12_2:GetTemplate().painting

			var_12_2 = ys.Battle.BattleState.GetCombatSkinKey() == "Standard" and var_12_0:GetCharacterIcon(var_12_3) or var_12_0:GetCharacterSquareIcon(var_12_3)
		else
			var_12_2 = ys.Battle.BattleState.GetCombatSkinKey() == "Standard" and var_12_0:GetCharacterIcon(pg.enemy_data_statistics[arg_12_2:GetTemplateID()].icon) or var_12_0:GetCharacterSquareIcon(pg.enemy_data_statistics[arg_12_2:GetTemplateID()].icon)
		end
	end

	local var_12_4 = var_12_1:GetObject()
	local var_12_5 = var_12_4.transform

	var_12_5.localScale = BattleScene.SKILL_FLOAT_SCALE

	setText(findTF(var_12_5, "skill/skill_name/Text"), SwitchSpecialChar(HXSet.hxLan(arg_12_1)))

	local var_12_6 = findTF(var_12_5, "skill/skill_name")
	local var_12_7 = var_12_5:GetComponent(typeof(Animation))

	if var_12_7 then
		local var_12_8 = 1

		while var_12_7:GetClip("anim_skinui_skill_" .. var_12_8) do
			var_12_8 = var_12_8 + 1
		end

		if var_12_8 > 1 then
			var_12_7:Play("anim_skinui_skill_" .. math.random(var_12_8 - 1))
		end
	end

	findTF(var_12_5, "skill/icon_mask/icon"):GetComponent(typeof(Image)).sprite = var_12_2

	local var_12_9, var_12_10 = arg_12_2:GetIFF()

	var_12_10 = arg_12_2:GetIFF() == ys.Battle.BattleConfig.FRIENDLY_CODE and Color.New(1, 1, 1, 1) or Color.New(1, 0.33, 0.33, 1)
	var_12_6:GetComponent(typeof(Image)).color = var_12_10
	findTF(var_12_5, "skill"):GetComponent(typeof(Image)).color = var_12_10

	if arg_12_3 then
		self:commanderSkillFloat(arg_12_3, arg_12_1, var_12_4)
	else
		local var_12_11 = var_0_1.CameraPosToUICamera(arg_12_2:GetPosition():Clone())
		local var_12_12 = ys.Battle.BattleCameraUtil.GetInstance():GetCharacterArrowBarPosition(var_12_11)
		local var_12_13 = arg_12_2:GetMainUnitIndex()

		if var_12_12 == nil or var_12_12 == nil and table.contains(ShipType.SubShipType, arg_12_2:GetTemplate().type) and not arg_12_2:IsMainFleetUnit() then
			var_12_11 = var_12_9 == ys.Battle.BattleConfig.FRIENDLY_CODE and var_0_1.CameraPosToUICamera(arg_12_2:GetPosition():Clone():Add(BattleScene.IN_VIEW_FRIEND_SKILL_OFFSET)) or var_0_1.CameraPosToUICamera(arg_12_2:GetPosition():Clone():Add(BattleScene.IN_VIEW_FOE_SKILL_OFFSET))
			var_12_5.position = Vector3(var_12_11.x, var_12_11.y, -2)

			if Screen.width * 0.5 < rtf(var_12_5).rect.width * 0.5 + var_12_5.anchoredPosition.x then
				var_12_5.anchoredPosition.x = var_12_5.anchoredPosition.x - rtf(var_12_5).rect.width
				var_12_5.anchoredPosition = var_12_5.anchoredPosition
			end

			if self._preSkillTF then
				self.handleSkillFloatCld(self._preSkillTF, var_12_5)
			end

			self._preSkillTF = var_12_5

			var_12_5:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_13_0)
				self._preSkillTF = nil

				var_12_1:Recycle(var_12_4)
			end)
		else
			local var_12_14
			local var_12_15 = self._sideSkillFloatStateList[var_12_9][var_12_13]

			for iter_12_0 = 1, #self._sideSkillFloatStateList[var_12_9][var_12_13] do
				if self._sideSkillFloatStateList[var_12_9][var_12_13][iter_12_0] then
					var_12_14 = iter_12_0

					break
				end
			end

			if var_12_14 == nil then
				var_12_14 = #self._sideSkillFloatStateList[var_12_9][var_12_13] + 1
			end

			self._sideSkillFloatStateList[var_12_9][var_12_13][var_12_14] = false
			var_12_5.position = Vector3(var_12_12.x, var_12_12.y, -2)
			var_12_5.anchoredPosition.y = BattleScene.SIDE_ALIGNMENT[var_12_13][var_12_14]

			if var_12_9 == ys.Battle.BattleConfig.FOE_CODE then
				var_12_5.anchoredPosition.x = BattleScene.FOE_SIDE_X_OFFSET
			end

			var_12_5.anchoredPosition = var_12_5.anchoredPosition

			var_12_5:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_14_0)
				var_12_15[var_12_14] = true

				var_12_1:Recycle(var_12_4)
			end)
		end
	end
end

function BattleScene:SkillHrzPopCover(arg_15_1, arg_15_2, arg_15_3)
	self:SkillHrzPop(arg_15_1, arg_15_2, nil, arg_15_3)
end

function BattleScene:handleSkillFloatCld(arg_16_1)
	if math.floor(math.abs(arg_16_1.anchoredPosition.y - self.anchoredPosition.y)) <= 112.5 then
		arg_16_1.anchoredPosition.y = self.anchoredPosition.y + 112.5
		arg_16_1.anchoredPosition = arg_16_1.anchoredPosition
	end
end

function BattleScene:handleSkillSinkCld(arg_17_1)
	return
end

function BattleScene:commanderSkillFloat(arg_18_1, arg_18_2, arg_18_3)
	self._commanderSkillList[arg_18_1] = self._commanderSkillList[arg_18_1] or {}
	self._commanderSkillList[arg_18_1][arg_18_2] = true
	arg_18_3.transform.anchoredPosition.x = 0
	arg_18_3.transform.anchoredPosition.y = 0
	arg_18_3.transform.anchoredPosition = arg_18_3.transform.anchoredPosition

	if self._preCommanderSkillTF then
		if math.floor(math.abs(arg_18_3.transform.anchoredPosition.y - self._preCommanderSkillTF.anchoredPosition.y)) <= 97.5 then
			arg_18_3.transform.anchoredPosition.y = self._preCommanderSkillTF.anchoredPosition.y - 97.5
		end
	end

	arg_18_3.transform.anchoredPosition = arg_18_3.transform.anchoredPosition
	self._preCommanderSkillTF = arg_18_3.transform

	arg_18_3.transform:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_19_0)
		self._commanderSkillList[arg_18_1][arg_18_2] = nil
		self._preCommanderSkillTF = nil

		self._skillFloatCMDPool:Recycle(arg_18_3)
	end)
end

function BattleScene:CutInPainting(arg_20_1, arg_20_2, arg_20_3, arg_20_4)
	if self._currentPainting then
		self._paintingAnimator.enabled = false

		setActive(self._currentPainting, false)
	end

	local var_20_0

	if not arg_20_4 then
		::label_20_0::

		var_20_0 = arg_20_1.painting or arg_20_1.prefab
	end

	if self._skillPaintings[var_20_0] == nil then
		local var_20_1 = ys.Battle.BattleResourceManager.GetInstance():InstPainting(var_20_0)

		self._skillPaintings[var_20_0] = var_20_1

		setParent(var_20_1, self._paintingFitter, false)
	end

	self._currentPainting = self._skillPaintings[var_20_0]

	setActive(self._currentPainting, true)
	LuaHelper.SetParticleSpeed(self._paintingUI, arg_20_2)

	local var_20_2 = Vector3(arg_20_3, 1, 1)

	self._paintingUI.transform.localScale = var_20_2
	self._paintingParticleContainer.transform.localScale = var_20_2
	self._paintingParticles.transform.localEulerAngles = Vector3(0, 90 * arg_20_3, 0)

	self._paintingParticleSystem:Play(true)

	self._paintingAnimator.speed = arg_20_2
	self._paintingAnimator.enabled = true

	self._paintingAnimator:Play("skill_painting", -1, 0)
end

function BattleScene:CutInPaintingDAL(arg_21_1, arg_21_2, arg_21_3, arg_21_4)
	local var_21_0 = ys.Battle.BattleResourceManager.GetInstance():InstSkillPaintingDALUI()

	setParent(var_21_0, self.uiCanvas, false)

	local var_21_1 = findTF(var_21_0, "hero/fitter")
	local var_21_2 = GetOrAddComponent(var_21_1, "PaintingScaler")

	var_21_2.FrameName = "lihuisha"
	var_21_2.Tween = 1

	setParent(ys.Battle.BattleResourceManager.GetInstance():InstPainting(arg_21_4.cutin_cover_DAL), var_21_1, false)
	var_21_0:GetComponent(typeof(Animator)):Play("skill_painting", -1, 0)
	setText(findTF(var_21_0, "pop/text"), arg_21_4.cutin_script)
	var_21_0:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_22_0)
		setActive(var_21_0, false)
	end)
end

function BattleScene:didEnter()
	setActive(self._tf, false)

	self._ratioFitter.enabled = true
	self._ratioFitter.aspectRatio = pg.CameraFixMgr.GetInstance():GetBattleUIRatio()
	self.camEventId = pg.CameraFixMgr.GetInstance():bind(pg.CameraFixMgr.ASPECT_RATIO_UPDATE, function(arg_24_0, arg_24_1)
		self._ratioFitter.aspectRatio = pg.CameraFixMgr.GetInstance():GetBattleUIRatio()
	end)

	local var_23_0 = ys.Battle.BattleState.GetInstance()

	var_23_0:SetBattleUI(self)
	onButton(self, self._tf:Find("PauseBtn"), function()
		self:emit(BattleMediator.ON_PAUSE)
	end, SFX_CONFIRM)

	self._chatBtn = self._tf:Find("chatBtnContainer/chatBtn")

	local var_23_1 = self._chatBtn:GetComponent(typeof(Animation))

	onButton(self, self._chatBtn, function()
		self:emit(BattleMediator.ON_CHAT, self._tf:Find("chatContainer"))

		if not var_23_1 then
			setActive(self._chatBtn, false)
		else
			var_23_1:Play("chatbtn_out")
		end
	end)
	onToggle(self, self._tf:Find("AutoBtn"), function(arg_27_0)
		local var_27_0 = var_23_0:GetBattleType()

		self:emit(BattleMediator.ON_AUTO, {
			isOn = not arg_27_0,
			toggle = self._tf:Find("AutoBtn"),
			system = var_27_0
		})
		var_23_0:ActiveBot(ys.Battle.BattleState.IsAutoBotActive(var_27_0))

		if var_23_0:ChatUseable() then
			setActive(self._chatBtn, true)

			if var_23_1 then
				var_23_1:Play("chatbtn_in")
			end
		elseif var_23_1 then
			var_23_1:Play("chatbtn_out")
		else
			setActive(self._chatBtn, false)
		end
	end, SFX_PANEL, SFX_PANEL)
	onButton(self, self._tf:Find("CardPuzzleConsole/relic/bg"), function()
		self:emit(BattleMediator.ON_PUZZLE_RELIC, {
			relicList = var_23_0:GetProxyByName(ys.Battle.BattleDataProxy.__name):GetFleetByIFF(ys.Battle.BattleConfig.FRIENDLY_CODE):GetCardPuzzleComponent():GetRelicList()
		})
	end, SFX_CONFIRM)
	onButton(self, self._tf:Find("CardPuzzleConsole/deck/bg"), function()
		local var_29_0 = var_23_0:GetProxyByName(ys.Battle.BattleDataProxy.__name):GetFleetByIFF(ys.Battle.BattleConfig.FRIENDLY_CODE):GetCardPuzzleComponent()

		self:emit(BattleMediator.ON_PUZZLE_CARD, {
			card = var_29_0:GetDeck():GetCardList(),
			hand = var_29_0:GetHand():GetCardList()
		})
	end, SFX_CONFIRM)
	var_23_0:ConfigBattleEndFunc(function(arg_30_0)
		self:clear()
		self:emit(BattleMediator.ON_BATTLE_RESULT, arg_30_0)
	end)

	local var_23_2 = {
		ys.Battle.BattleConst.BuffEffectType.ON_START_GAME,
		ys.Battle.BattleConst.BuffEffectType.ON_FLAG_SHIP,
		ys.Battle.BattleConst.BuffEffectType.ON_CONSORT,
		ys.Battle.BattleConst.BuffEffectType.ON_LEADER,
		ys.Battle.BattleConst.BuffEffectType.ON_REAR,
		ys.Battle.BattleConst.BuffEffectType.ON_SUB_LEADER,
		ys.Battle.BattleConst.BuffEffectType.ON_SUB_CONSORT
	}

	local function var_23_3(arg_31_0)
		local var_31_0 = 0

		for iter_31_0, iter_31_1 in ipairs(arg_31_0) do
			var_31_0 = var_31_0 + ys.Battle.BattleDataFunction.GetShipSkillTriggerCount(iter_31_1, var_23_2)
		end

		return var_31_0
	end

	self._skillFloatPool = pg.Pool.New(self.skillRoot, self.skillTpl, 0 + var_23_3(self.contextData.battleData.MainUnitList) + var_23_3(self.contextData.battleData.VanguardUnitList) + var_23_3(self.contextData.battleData.SubUnitList) + 4, 10, true, false):InitSize()

	self._skillFloatPool:SetRecycleFuncs(function(arg_32_0)
		arg_32_0.transform:GetComponent(typeof(DftAniEvent)):OnDestroy()
	end)
	self:emit(BattleMediator.ENTER)
	self:initPauseWindow()

	if self.contextData.prePause then
		triggerButton(self._tf:Find("PauseBtn"))
	end

	setActive(self._chatBtn, var_23_0:ChatUseable())
end

function BattleScene:onBackPressed()
	if isActive(self.pauseWindow) then
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
		triggerButton(self.continueBtn)
	end
end

function BattleScene:activeBotHelp(arg_34_1)
	local var_34_0 = getProxy(PlayerProxy)

	if not arg_34_1 then
		if self.autoBotHelp then
			pg.MsgboxMgr.GetInstance():hide()
		end

		return
	end

	if var_34_0.botHelp then
		return
	end

	self.autoBotHelp = true

	pg.MsgboxMgr.GetInstance():ShowMsgBox({
		type = MSGBOX_TYPE_HELP,
		helps = i18n("help_battle_auto"),
		custom = {
			{
				text = "text_iknow",
				sound = SFX_CANCEL
			}
		},
		onClose = function()
			self.autoBotHelp = false
		end
	})

	var_34_0.botHelp = true
end

function BattleScene:exitBattle(arg_36_1)
	if not arg_36_1 then
		self:emit(BattleMediator.ON_QUIT_BATTLE_MANUALLY)
		self:emit(BattleMediator.ON_BACK_PRE_SCENE)
	elseif arg_36_1 == "kick" then
		-- block empty
	end
end

function BattleScene:setChapter(arg_37_1)
	self._chapter = arg_37_1
end

function BattleScene:setFleet(arg_38_1, arg_38_2, arg_38_3)
	self._mainShipVOs = arg_38_1
	self._vanShipVOs = arg_38_2
	self._subShipVOs = arg_38_3
end

function BattleScene:initPauseWindow()
	self.pauseWindow = self._tf:Find("Msgbox")
	self.LeftTimeContainer = self.pauseWindow:Find("window/LeftTime")
	self.LeftTime = self.pauseWindow:Find("window/LeftTime/Text")
	self.mainTFs = {}
	self.vanTFs = {}

	setText(self.LeftTimeContainer:Find("label"), i18n("battle_battleMediator_remainTime"))
	setText(self.pauseWindow:Find("window/van/power/title"), i18n("word_vanguard_fleet"))
	setText(self.pauseWindow:Find("window/main/power/title"), i18n("word_main_fleet"))

	local function var_39_0(arg_40_0, arg_40_1, arg_40_2)
		for iter_40_0 = 1, 3 do
			local var_40_0 = arg_40_1:Find("ship_" .. iter_40_0)

			setActive(var_40_0, arg_40_2 and iter_40_0 <= #arg_40_2)

			if arg_40_2 and iter_40_0 <= #arg_40_2 then
				updateShip(var_40_0, arg_40_2[iter_40_0])
			end

			table.insert(arg_40_0, var_40_0)
		end

		if arg_40_2 then
			local var_40_1 = 0

			for iter_40_1, iter_40_2 in ipairs(arg_40_2) do
				var_40_1 = var_40_1 + iter_40_2:getShipCombatPower()
			end

			setText(arg_40_1:Find("power/value"), var_40_1)
		end
	end

	local var_39_1 = ys.Battle.BattleState.GetInstance()
	local var_39_2 = var_39_1:GetBattleType()

	if self._mainShipVOs then
		var_39_0(self.mainTFs, self.pauseWindow:Find("window/main"), self._mainShipVOs)
		var_39_0(self.vanTFs, self.pauseWindow:Find("window/van"), self._vanShipVOs)
	elseif var_39_2 == SYSTEM_SCENARIO_SUB_STRIKE then
		self.subTFs = {}

		local var_39_3 = self.pauseWindow:Find("window/main")

		setActive(self.pauseWindow:Find("window/van"), false)
		setActive(self.pauseWindow:Find("window/bg_fleet/Image (1)"), false)
		var_39_0(self.subTFs, var_39_3, self._subShipVOs)
		setText(var_39_3:Find("power/title"), i18n("index_shipType_qianTing"))

		var_39_3.localPosition = Vector3(0, var_39_3.localPosition.y, 0)
	end

	local var_39_4 = findTF(self.pauseWindow, "window/Chapter")
	local var_39_5 = findTF(self.pauseWindow, "window/Chapter/Text")

	self.continueBtn = self.pauseWindow:Find("window/button_container/continue")
	self.leaveBtn = self.pauseWindow:Find("window/button_container/leave")

	setText(self.continueBtn:Find("pic"), i18n("battle_battleMediator_goOnFight"))
	setText(self.leaveBtn:Find("pic"), i18n("battle_battleMediator_existFight"))

	if var_39_2 == SYSTEM_SCENARIO or var_39_2 == SYSTEM_SCENARIO_SUB_STRIKE then
		local var_39_6 = self._chapter:getConfigTable()

		setText(var_39_4, var_39_6.chapter_name)
		setText(var_39_5, string.split(var_39_6.name, "|")[1])
	elseif var_39_2 == SYSTEM_ROUTINE or var_39_2 == SYSTEM_DUEL or var_39_2 == SYSTEM_HP_SHARE_ACT_BOSS or var_39_2 == SYSTEM_BOSS_EXPERIMENT or var_39_2 == SYSTEM_ACT_BOSS or var_39_2 == SYSTEM_ACT_BOSS_SP or var_39_2 == SYSTEM_BOSS_RUSH or var_39_2 == SYSTEM_BOSS_RUSH_EX or var_39_2 == SYSTEM_BOSS_RUSH_COLLABRATE or var_39_2 == SYSTEM_LIMIT_CHALLENGE or var_39_2 == SYSTEM_BOSS_SINGLE or var_39_2 == SYSTEM_BOSS_SINGLE_VARIABLE then
		setText(var_39_4, "SP")
		setText(var_39_5, pg.expedition_data_template[var_39_1:GetProxyByName(ys.Battle.BattleDataProxy.__name):GetInitData().StageTmpId].name)
	elseif var_39_2 == SYSTEM_DEBUG then
		setText(var_39_4, "??")
		setText(var_39_5, "碧蓝梦境")
	elseif var_39_2 == SYSTEM_CHALLENGE then
		setText(var_39_4, "SP")
		setText(var_39_5, self._chapter:getNextExpedition().chapter_name[2])
		setActive(self.LeftTimeContainer, true)
	elseif var_39_2 == SYSTEM_WORLD_BOSS or var_39_2 == SYSTEM_WORLD then
		setText(var_39_4, i18n("world_battle_pause"))
		setText(var_39_5, i18n("world_battle_pause2"))

		if var_39_2 == SYSTEM_WORLD_BOSS then
			setActive(self.leaveBtn, false)
		end
	elseif var_39_2 == SYSTEM_GUILD then
		local var_39_7 = pg.guild_boss_event[var_39_1:GetProxyByName(ys.Battle.BattleDataProxy.__name):GetInitData().ActID]

		setText(var_39_4, "BOSS")
		setText(var_39_5, (var_39_7 or nil) and (var_39_7.name or ""))
	elseif var_39_2 == SYSTEM_TEST or var_39_2 == SYSTEM_SUB_ROUTINE or var_39_2 == SYSTEM_SCENARIO_SUB_STRIKE or var_39_2 == SYSTEM_PERFORM or var_39_2 == SYSTEM_PROLOGUE or var_39_2 == SYSTEM_DODGEM or var_39_2 == SYSTEM_SIMULATION or var_39_2 == SYSTEM_SUBMARINE_RUN or var_39_2 == SYSTEM_BOSS_EXPERIMENT or var_39_2 == SYSTEM_REWARD_PERFORM or var_39_2 == SYSTEM_AIRFIGHT then
		-- block empty
	elseif var_39_2 == SYSTEM_CARDPUZZLE then
		-- block empty
	else
		assert(false, "System not defined " .. (var_39_2 or "NIL"))
	end

	onButton(self, self.leaveBtn, function()
		self:emit(BattleMediator.ON_LEAVE)

		local var_41_0 = self.leaveBtn:GetComponent(typeof(Animation))

		if var_41_0 and var_41_0:GetClip("msgbox_btn_blink") then
			var_41_0:Play("msgbox_btn_blink")
		end
	end)
	onButton(self, self.continueBtn, function()
		local var_42_0 = self.continueBtn:GetComponent(typeof(Animation))

		if var_42_0 and var_42_0:GetClip("msgbox_btn_blink") then
			var_42_0:Play("msgbox_btn_blink")
		end

		local var_42_1 = self.pauseWindow:GetComponent(typeof(Animation))

		if var_42_1 then
			if var_42_1:IsPlaying("msgbox_out") then
				var_42_1:Stop("msgbox_out")
				var_42_1:Play("msgbox_in")
			else
				var_42_1:Play("msgbox_out")
				self.pauseWindow:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_43_0)
					self:ClosePauseWindow()
					var_39_1:Resume()
				end)
			end
		else
			self:ClosePauseWindow()
			var_39_1:Resume()
		end
	end)
	onButton(self, self.pauseWindow:Find("help"), function()
		if BATTLE_DEBUG and PLATFORM == 7 then
			self:ClosePauseWindow()
			var_39_1:Resume()
			var_39_1:OpenConsole()
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = i18n("help_battle_rule")
			})
		end
	end)
	onButton(self, self.pauseWindow:Find("window/top/btnBack"), function()
		triggerButton(self.continueBtn)
	end)
	onButton(self, self.pauseWindow, function()
		triggerButton(self.continueBtn)
	end)
	onButton(self, self.pauseWindow, function()
		local var_47_0 = self.pauseWindow:GetComponent(typeof(Animation))

		if var_47_0 and var_47_0:IsPlaying("msgbox_out") then
			-- block empty
		else
			triggerButton(self.continueBtn)
		end
	end)
	setActive(self.pauseWindow, false)
end

function BattleScene:updatePauseWindow()
	if not self.pauseWindow then
		return
	end

	setActive(self.pauseWindow, true)
	pg.UIMgr.GetInstance():BlurPanel(self.pauseWindow)

	local var_48_0 = ys.Battle.BattleState.GetInstance():GetProxyByName(ys.Battle.BattleDataProxy.__name)
	local var_48_1 = var_48_0:GetFleetByIFF(ys.Battle.BattleConfig.FRIENDLY_CODE)

	local function var_48_2(arg_49_0, arg_49_1)
		if not arg_49_0 then
			return
		end

		for iter_49_0 = 1, #arg_49_0 do
			if var_48_1:GetFreezeShipByID(arg_49_0[iter_49_0].id) then
				setSlider(arg_49_1[iter_49_0]:Find("blood"), 0, 1, var_48_1:GetFreezeShipByID(arg_49_0[iter_49_0].id):GetHPRate())
				SetActive(arg_49_1[iter_49_0]:Find("mask"), false)
			elseif var_48_1:GetShipByID(arg_49_0[iter_49_0].id) then
				setSlider(arg_49_1[iter_49_0]:Find("blood"), 0, 1, var_48_1:GetShipByID(arg_49_0[iter_49_0].id):GetHPRate())
				SetActive(arg_49_1[iter_49_0]:Find("mask"), false)
			else
				setSlider(arg_49_1[iter_49_0]:Find("blood"), 0, 1, 0)
				SetActive(arg_49_1[iter_49_0]:Find("mask"), true)
			end
		end
	end

	var_48_2(self._mainShipVOs, self.mainTFs)
	var_48_2(self._vanShipVOs, self.vanTFs)

	if self.subTFs then
		var_48_2(self._subShipVOs, self.subTFs)
	end

	setText(self.LeftTime, ys.Battle.BattleTimerView.formatTime(math.floor(var_48_0:GetCountDown())))
end

function BattleScene:ClosePauseWindow()
	setActive(self.pauseWindow, false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self.pauseWindow, self._tf)
end

function BattleScene:AddUIFX(arg_51_1, arg_51_2)
	if not arg_51_2 then
		arg_51_2 = 1
		arg_51_1 = tf(arg_51_1)
	end

	local var_51_0

	if arg_51_2 > 0 then
		var_51_0 = self._fxContainerUpper or self._fxContainerBottom
	end

	arg_51_1:SetParent(var_51_0)
	pg.ViewUtils.SetSortingOrder(arg_51_1, self._canvasOrder + arg_51_2)
	pg.ViewUtils.SetLayer(arg_51_1, Layer.UI)

	return var_51_0.localScale
end

function BattleScene:OnCloseChat()
	local var_52_0 = self._chatBtn:GetComponent(typeof(Animation))

	if ys.Battle.BattleState.GetInstance():IsBotActive() then
		setActive(self._chatBtn, true)

		if var_52_0 then
			var_52_0:Play("chatbtn_in")
		end
	elseif var_52_0 then
		var_52_0:Play("chatbtn_out")
	else
		setActive(self._chatBtn, false)
	end
end

function BattleScene:clear()
	self._preSkillTF = nil

	self._skillFloatPool:AllRecycle()
	self._skillFloatCMDPool:AllRecycle()

	self._preCommanderSkillTF = nil
	self._commanderSkillList = nil
	self._skillPaintings = nil
	self._currentPainting = nil

	Destroy(self._paintingUI)
end

function BattleScene:willExit()
	self._skillFloatPool:Dispose()
	self._skillFloatCMDPool:Dispose()
	ys.Battle.BattleState.GetInstance():ExitBattle()
	pg.UIMgr.GetInstance():UnOverlayPanel(self.pauseWindow, self._tf)
	ys.Battle.BattleCameraUtil.GetInstance().ActiveMainCamera(false)
	pg.CameraFixMgr.GetInstance():disconnect(self.camEventId)
end

return BattleScene
