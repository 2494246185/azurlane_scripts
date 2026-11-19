local CombatUIPreviewer = class("CombatUIPreviewer")
local var_0_1 = {
	LOOP = 3,
	FILLED = 2,
	UNFILLED = 1,
	USABLE = 4
}

CombatUIPreviewer.WeaponButtonPreviewMode = var_0_1
CombatUIPreviewer.EnableLoop = true
CombatUIPreviewer.LoopWeaponButtons = {
	3
}

local var_0_2 = Vector3(0, 1, 40)
local var_0_3 = Vector3(35, 1, 40)
local var_0_4 = Vector3(30, 0, 0)
local var_0_5 = Vector3(330, 0, 0)
local var_0_6 = Vector3(-532, 157, 0)
local var_0_7 = Vector3(-665, 70, -675)
local var_0_8 = Vector3(473, 157, 0)
local var_0_9 = Vector3(-791, 70, 0)
local var_0_10 = Vector3(464, 70, -675)

function CombatUIPreviewer:Ctor(arg_1_1)
	self.rawImage = arg_1_1

	setActive(self.rawImage, false)

	self.seaCameraGO = GameObject.Find("BarrageCamera")
	self.seaCamera = self.seaCameraGO:GetComponent(typeof(Camera))
	self.seaCamera.targetTexture = self.rawImage.texture
	self.seaCamera.enabled = true
end

function CombatUIPreviewer:setDisplayWeapon(arg_2_1, arg_2_2, arg_2_3)
	self.weaponIds = arg_2_1
	self.equipSkinId = arg_2_2 or 0
end

function CombatUIPreviewer:setHeroHpBarOffset(arg_3_1)
	self.heroHpBarOffset = arg_3_1
end

function CombatUIPreviewer:setEnemyHpBarOffset(arg_4_1)
	self.enemyHpBarOffset = arg_4_1
end

function CombatUIPreviewer:setCombatUI(arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	self.uiGO = arg_5_1
	self.hpBarGO = arg_5_2
	self.enemyBarGO = arg_5_3
	self.skinKey = arg_5_4

	local var_5_0 = arg_5_1.transform

	self.uiTF = arg_5_1.transform
	self.chatPop = var_5_0:Find("popup")
	self.chatPopGo = self.chatPop.gameObject

	setActive(self.chatPop, false)

	self.flagShipMark = var_5_0:Find("flagShipMark")
	self.timer = var_5_0:Find("Timer")

	setActive(self.timer, true)
	setText(self.timer:Find("Text"), "03:00")

	self.buttonContainer = var_5_0:Find("Weapon_button_container")
	self.weaponButtons = {}

	local var_5_1 = {
		var_0_1.UNFILLED,
		var_0_1.FILLED,
		var_0_1.LOOP
	}

	for iter_5_0 = 1, 3 do
		local var_5_2 = ys.Battle["BattleWeaponButton" .. self.skinKey] and ys.Battle["BattleWeaponButton" .. self.skinKey].New() or ys.Battle.BattleWeaponButton.New()
		local var_5_3 = cloneTplTo(var_5_0:Find("Weapon_button_progress"), self.buttonContainer)

		ys.Battle.BattleSkillView.SetSkillButtonPreferences(var_5_3, iter_5_0)
		var_5_2:ConfigSkin(var_5_3)
		var_5_2:SwitchIcon(iter_5_0, arg_5_4)
		var_5_2:SwitchIconEffect(iter_5_0, arg_5_4)
		var_5_2:SetTextActive(true)
		var_5_2:SetToCombatUIPreview(var_5_1[iter_5_0])
		table.insert(self.weaponButtons, var_5_2)

		if iter_5_0 == 3 then
			local var_5_4 = GetOrAddComponent(go(var_5_3), typeof(UnityEngine.Playables.PlayableDirector))

			if var_5_4 then
				var_5_4.enabled = true
			end
		end
	end

	self.submarineButton = (ys.Battle["BattleSubmarineButton" .. self.skinKey] or ys.Battle.BattleSubmarineButton).New()

	local var_5_5 = cloneTplTo(var_5_0:Find("Weapon_button"), self.buttonContainer)

	self.submarineButton:ConfigSkin(var_5_5)
	self.submarineButton:SwitchIcon(4, arg_5_4)
	ys.Battle.BattleSkillView.SetSkillButtonPreferences(var_5_5, 4)
	self.submarineButton:SetToCombatUIPreview(var_0_1.USABLE)

	self.heroBar = arg_5_2.transform

	setActive(self.heroBar:Find("heroBlood"), true)

	self.enemyBar = self.enemyBarGO.transform

	setActive(self.enemyBar:Find("enemyBlood"), true)
	self:updateBarPos()

	self.mainArrow = var_5_0:Find("EnemyArrowContainer/MainArrow")

	setActive(self.mainArrow, true)

	self.autoBtn = var_5_0:Find("AutoBtn")

	setActive(self.autoBtn, true)
	triggerToggle(self.autoBtn, true)

	self.enemyHPBar = var_5_0:Find("EnemyHPBar")

	setActive(self.enemyHPBar, false)

	self.bossHPBar = var_5_0:Find("BossBarContainer/heroBlood")

	setActive(self.bossHPBar, true)

	local var_5_6 = self.bossHPBar:Find("bloodBarContainer")

	for iter_5_1 = 0, var_5_6.childCount - 1 do
		var_5_6:GetChild(iter_5_1):GetComponent(typeof(Image)).fillAmount = 1
		iter_5_1 = iter_5_1 + 1
	end

	self.skillContainer = var_5_0:Find("Skill_Activation/Root")
	self.skill = var_5_0:Find("Skill_Activation/mask")

	local var_5_7 = var_5_0:Find("Stick/Area/BG/spine")

	if var_5_7 then
		var_5_7:GetComponent(typeof(SpineAnimUI)):SetAction("normal", 0)
	end

	self.stick = var_5_0:Find("Stick/Area/Stick")
	self.stickTail = self.stick:Find("tailGizmos")
end

function CombatUIPreviewer:load(arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5)
	assert(not self.loading and not self.loaded, "load function can be called only once.")

	self.loading = true
	self.shipVO = arg_6_2
	self.enemyVO = arg_6_3

	ys.Battle.BattleVariable.Init(true)
	ys.Battle.BattleVariable.UpdateCameraPositionArgs()
	ys.Battle.BattleFXPool.GetInstance():Init()

	local var_6_0 = ys.Battle.BattleResourceManager.GetInstance()

	var_6_0:Init()
	var_6_0:AddPreloadResource(var_6_0.GetUIPath("CombatHPPop" .. self.skinKey))
	var_6_0:AddPreloadResource(var_6_0.GetMapResource(arg_6_1))
	var_6_0:AddPreloadResource(var_6_0.GetDisplayCommonResource())

	if self.equipSkinId > 0 then
		var_6_0:AddPreloadResource(var_6_0.GetEquipSkinPreviewRes(self.equipSkinId))
	end

	var_6_0:AddPreloadResource(var_6_0.GetShipResource(arg_6_2.configId, arg_6_2.skinId), false)
	var_6_0:AddPreloadResource(var_6_0.GetShipResource(arg_6_3.configId, arg_6_3.skinId), false)
	var_6_0:StartPreload(function()
		self.seaView = ys.Battle.BattleMap.New(arg_6_1)

		local function var_7_0(arg_8_0)
			self.loading = false
			self.loaded = true

			pg.UIMgr.GetInstance():LoadingOff()

			local var_8_0 = ys.Battle.BattleFXPool.GetInstance()

			self.seaFXPool = var_8_0

			local var_8_1 = {}

			for iter_8_0, iter_8_1 in ipairs(ys.Battle.BattleConst.FXContainerIndex) do
				var_8_1[iter_8_0] = Vector3(pg.ship_skin_template[arg_6_2.skinId].fx_container[iter_8_0][1], pg.ship_skin_template[arg_6_2.skinId].fx_container[iter_8_0][2], pg.ship_skin_template[arg_6_2.skinId].fx_container[iter_8_0][3])
			end

			local var_8_2 = arg_6_2:getConfig("scale") / 50

			self.seaCharacter = arg_8_0

			;(function(arg_9_0, arg_9_1)
				arg_9_0.transform.localScale = arg_9_1 and Vector3(var_8_2 * -1, var_8_2, var_8_2) or Vector3(var_8_2, var_8_2, var_8_2)
				arg_9_0.transform.localEulerAngles = var_0_4

				arg_9_0.transform:GetComponent("SpineAnim"):SetAction(ys.Battle.BattleConst.ActionName.MOVE, 0, true)

				local var_9_0 = GameObject()

				var_9_0.transform:SetParent(arg_9_0.transform, false)

				var_9_0.transform.localPosition = Vector3.zero
				var_9_0.transform.localEulerAngles = var_0_5

				pg.EffectMgr.GetInstance():PlayBattleEffect(var_8_0:GetCharacterFX("movewave", {
					GetGO = function()
						return self.seaCharacter
					end,
					GetSpecificFXScale = function()
						return {}
					end,
					GetAttachPoint = function()
						return var_9_0
					end,
					GetFXOffsets = function(arg_13_0, arg_13_1)
						arg_13_1 = arg_13_1 or 1

						return var_8_1[arg_13_1]
					end
				}), Vector3.zero, true)
			end)(self.seaCharacter)

			self.seaCharacter.transform.localPosition = var_0_2

			self:SeaUpdate()
			setImageSprite(findTF(self.mainArrow, "icon"), (ys.Battle.BattleResourceManager.GetInstance():GetCharacterQIcon(self.shipVO:getPrefab())))
			setImageSprite(findTF(self.bossHPBar, "BossIcon/icon"), (ys.Battle.BattleResourceManager.GetInstance():GetCharacterSquareIcon(self.enemyVO:getPrefab())))
			setText(findTF(self.bossHPBar, "BossNameBG/BossName"), ys.Battle.BattleDataFunction.GetPlayerShipTmpDataFromID(self.enemyVO.configId).name)
			setActive(self.rawImage, true)
			pg.TimeMgr.GetInstance():ResumeBattleTimer()
			arg_6_5()
		end

		local function var_7_1(arg_14_0)
			local var_14_0 = ys.Battle.BattleFXPool.GetInstance()

			self.seaFXPool = var_14_0

			local var_14_1 = {}

			for iter_14_0, iter_14_1 in ipairs(ys.Battle.BattleConst.FXContainerIndex) do
				var_14_1[iter_14_0] = Vector3(pg.ship_skin_template[arg_6_3.skinId].fx_container[iter_14_0][1], pg.ship_skin_template[arg_6_3.skinId].fx_container[iter_14_0][2], pg.ship_skin_template[arg_6_3.skinId].fx_container[iter_14_0][3])
			end

			local var_14_2 = arg_6_3:getConfig("scale") / 50

			self.seaEnemy = arg_14_0

			;(function(arg_15_0, arg_15_1)
				arg_15_0.transform.localScale = arg_15_1 and Vector3(var_14_2 * -1, var_14_2, var_14_2) or Vector3(var_14_2, var_14_2, var_14_2)
				arg_15_0.transform.localEulerAngles = var_0_4

				arg_15_0.transform:GetComponent("SpineAnim"):SetAction(ys.Battle.BattleConst.ActionName.MOVE, 0, true)

				local var_15_0 = GameObject()

				var_15_0.transform:SetParent(arg_15_0.transform, false)

				var_15_0.transform.localPosition = Vector3.zero
				var_15_0.transform.localEulerAngles = var_0_5

				pg.EffectMgr.GetInstance():PlayBattleEffect(var_14_0:GetCharacterFX("movewave", {
					GetGO = function()
						return self.seaCharacter
					end,
					GetSpecificFXScale = function()
						return {}
					end,
					GetAttachPoint = function()
						return var_15_0
					end,
					GetFXOffsets = function(arg_19_0, arg_19_1)
						arg_19_1 = arg_19_1 or 1

						return var_14_1[arg_19_1]
					end
				}), Vector3.zero, true)
			end)(self.seaEnemy, true)

			self.seaEnemy.transform.localPosition = var_0_3
		end

		var_6_0:InstCharacter(arg_6_3:getPrefab(), function(arg_20_0)
			var_7_1(arg_20_0)
		end)
		var_6_0:InstCharacter(arg_6_2:getPrefab(), function(arg_21_0)
			var_7_0(arg_21_0)
		end)
	end, nil)
	pg.UIMgr.GetInstance():LoadingOn()
end

local var_0_11 = 0.033

function CombatUIPreviewer:loop(arg_22_1, arg_22_2)
	if self._roundTimer then
		pg.TimeMgr.GetInstance():RemoveBattleTimer(self._roundTimer)

		self._roundTimer = nil
	end

	for iter_22_0, iter_22_1 in ipairs(self.weaponButtons) do
		iter_22_1:StopCombatUIPreviewLoop()
	end

	if not arg_22_1 or #self.weaponButtons == 0 then
		return
	end

	if arg_22_1 and table.isEmpty(arg_22_2) then
		arg_22_2 = {}

		for iter_22_2, iter_22_3 in ipairs(self.weaponButtons) do
			table.insert(arg_22_2, iter_22_2)
		end
	end

	for iter_22_4, iter_22_5 in ipairs(arg_22_2) do
		self.weaponButtons[iter_22_5]:StartCombatUIPreviewLoop()
	end

	self._roundTimer = pg.TimeMgr.GetInstance():AddBattleTimer("weaponButtonRoundTimer", -1, var_0_11, function()
		for iter_23_0, iter_23_1 in ipairs(arg_22_2) do
			self.weaponButtons[iter_23_1]:UpdateCombatUIPreviewLoop(var_0_11)
		end
	end)
end

function CombatUIPreviewer:updateBarPos()
	if self.seaCharacter then
		self.heroBar.localPosition = self.heroHpBarOffset or var_0_6
		self.flagShipMark.localPosition = var_0_7
	end

	if self.seaEnemy then
		self.enemyBar.localPosition = self.enemyHpBarOffset or var_0_8
	end
end

function CombatUIPreviewer:updatePopUp()
	setActive(self.chatPop, true)

	self.chatPop.localPosition = var_0_9

	LeanTween.cancel(self.chatPop)

	if self.chatPop.transform:GetComponent(typeof(Animation)) then
		ys.Battle.BattleCharacter.ChatPopAnimation(self.chatPop, 4)
		ys.Battle.BattleCharacter.setChatText(self.chatPop, pg.ship_skin_words[100000].skill)
	else
		LeanTween.scale(rtf(self.chatPop.gameObject), Vector3.New(0, 0, 1), 0.1):setEase(LeanTweenType.easeInBack):setOnComplete(System.Action(function()
			ys.Battle.BattleCharacter.ChatPop(self.chatPop, 5)
			ys.Battle.BattleCharacter.setChatText(self.chatPop, pg.ship_skin_words[100000].skill)
		end))
	end
end

function CombatUIPreviewer:updateSkillFloat()
	setActive(self.skill, true)

	local var_27_0 = ys.Battle.BattleResourceManager.GetInstance()
	local var_27_1 = self.skinKey == "Standard" and var_27_0:GetCharacterIcon(self.shipVO:getPrefab()) or var_27_0:GetCharacterSquareIcon(self.shipVO:getPrefab())
	local var_27_2 = self.skill.transform

	self.skill.localScale = Vector3(1.5, 1.5, 0)

	local var_27_3 = var_27_2:GetComponent(typeof(Animation))

	if var_27_3 then
		local var_27_4 = 1

		while var_27_3:GetClip("anim_skinui_skill_" .. var_27_4) do
			var_27_4 = var_27_4 + 1
		end

		if var_27_4 > 1 then
			var_27_3:Play("anim_skinui_skill_" .. math.random(var_27_4 - 1))
		end
	end

	setText(findTF(var_27_2, "skill/skill_name/Text"), HXSet.hxLan(pg.skill_data_template[9033].name))

	findTF(var_27_2, "skill/icon_mask/icon"):GetComponent(typeof(Image)).sprite = var_27_1

	local var_27_5 = Color.New(1, 1, 1, 1)

	findTF(var_27_2, "skill/skill_name"):GetComponent(typeof(Image)).color = var_27_5
	findTF(var_27_2, "skill"):GetComponent(typeof(Image)).color = var_27_5

	var_27_2:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_28_0)
		setActive(self.skill, false)
	end)

	var_27_2.position = Clone(self.heroBar.position)
end

function CombatUIPreviewer:updateHPPop()
	local var_29_0

	if not self._popNumMgr then
		self._popNumMgr = ys.Battle.BattlePopNumManager.GetInstance()

		self._popNumMgr:InitialBundlePool(self.uiGO.transform:Find("HPTextCharacterContainer/container"))

		self._popNumBundle = self._popNumMgr:GetBundle()
		var_29_0 = {
			nil,
			1
		}
	end

	var_29_0[1] = math.random(1, 4)

	local var_29_1 = self._popNumBundle:GetPop(false, math.random(1, 2) > 1, false, 114, var_29_0)

	var_29_1._tf.localPosition = var_0_10

	var_29_1:Play()
end

local var_0_12 = 250
local var_0_13 = 50
local var_0_14 = 1000
local var_0_15 = 2
local var_0_16 = 3

function CombatUIPreviewer:updateStick()
	if self._stickMoveCount and self._stickMoveCount <= var_0_12 then
		self._stickMoveCount = self._stickMoveCount + 1

		if (self.stickVX + self.stick.localPosition.x) * (self.stickVX + self.stick.localPosition.x) + (self.stickVY + self.stick.localPosition.y) * (self.stickVY + self.stick.localPosition.y) > var_0_14 * 2 then
			local var_30_0 = math.atan2(self.stickVY + self.stick.localPosition.y, self.stickVX + self.stick.localPosition.x)
			local var_30_3 = math.random() * 2 * math.pi
			local var_30_4 = math.random(var_0_15, var_0_16)

			self.stickVX = math.cos(var_30_3) * var_30_4
			self.stickVY = math.sin(var_30_3) * var_30_4

			if self.stickVX * (var_0_14 * math.cos(var_30_0) / var_0_14) + self.stickVY * (var_0_14 * math.sin(var_30_0) / var_0_14) > 0 then
				self.stickVX = -self.stickVX
				self.stickVY = -self.stickVY
			end
		else
			self.stickPos.x = self.stickVX + self.stick.localPosition.x
			self.stickPos.y = self.stickVY + self.stick.localPosition.y
			self.stick.localPosition = self.stickPos
		end

		if self._stickMoveCount >= var_0_12 then
			if self.stickTail then
				setActive(self.stickTail, false)
			end

			self.stick.localPosition = Vector3.zero
			self._stickMoveCount = nil
			self._stickStopCount = 0
		end
	elseif self._stickStopCount and self._stickStopCount <= var_0_13 then
		self._stickStopCount = self._stickStopCount + 1

		if self._stickStopCount >= var_0_13 then
			if self.stickTail then
				setActive(self.stickTail, true)
			end

			local var_30_5 = math.random() * 2 * math.pi
			local var_30_6 = math.random(var_0_15, var_0_16)

			self.stickVX = math.cos(var_30_5) * var_30_6
			self.stickVY = math.cos(var_30_5) * var_30_6
			self._stickStopCount = nil
			self._stickMoveCount = 0
		end
	end
end

function CombatUIPreviewer:SeaUpdate()
	pg.TimeMgr.GetInstance():AddBattleTimer("barrageUpdateTimer", -1, 0.033, function()
		self:updateBarPos()
	end)

	self._stickStopCount = 0
	self.stickPos = Vector2.New(0, 0)

	pg.TimeMgr.GetInstance():AddBattleTimer("stickUpdateTimer", -1, 0.033, function()
		self:updateStick()
	end)
	pg.TimeMgr.GetInstance():AddBattleTimer("popupUpdateTimer", -1, 10, function()
		self:updatePopUp()
	end)
	pg.TimeMgr.GetInstance():AddBattleTimer("skillFloatUpdateTimer", -1, 10, function()
		self:updateSkillFloat()
	end)
	pg.TimeMgr.GetInstance():AddBattleTimer("HPPopUpdateTimer", -1, 3, function()
		self:updateHPPop()
	end)
	self:loop(CombatUIPreviewer.EnableLoop, CombatUIPreviewer.LoopWeaponButtons)
end

function CombatUIPreviewer:clear()
	if self.weaponButtons then
		self:loop(false)
	end

	pg.TimeMgr.GetInstance():RemoveAllBattleTimer()

	self._roundTimer = nil
	self.weaponButtons = {}
	self.submarineButton = nil

	if self.chatPop then
		LeanTween.cancel(go(self.chatPop))
	end

	Destroy(self.seaCharacter)
	Destroy(self.seaEnemy)
	Destroy(self.uiGO)
	Destroy(self.hpBarGO)
	Destroy(self.enemyBarGO)

	if self.seaView then
		self.seaView:Dispose()

		self.seaView = nil
	end

	if self._popNumMgr then
		self._popNumMgr:Clear()
	end

	if self.weaponList then
		for iter_37_0, iter_37_1 in ipairs(self.weaponList) do
			for iter_37_2, iter_37_3 in ipairs(iter_37_1.emitterList) do
				iter_37_3:Destroy()
			end
		end

		self.weaponList = nil
	end

	if self.seaFXPool then
		self.seaFXPool:Clear()

		self.seaFXPool = nil
	end

	if self.seaFXContainersPool then
		self.seaFXContainersPool:Clear()

		self.seaFXContainersPool = nil
	end

	ys.Battle.BattleResourceManager.GetInstance():Clear()

	self.seaCamera.enabled = true
	self.seaCameraGO = nil
	self.seaCamera = nil
	self.heroHpBarOffset = nil
	self.enemyHpBarOffset = nil
	self.loading = false
	self.loaded = false
end

return CombatUIPreviewer
