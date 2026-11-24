local NewPlayerScene = class("NewPlayerScene", import("..base.BaseUI"))
local var_0_3 = Vector3(-380, 265, 0)
local var_0_5 = {
	101171,
	201211,
	401231
}
local var_0_6 = {
	[201211] = "biaoqiang",
	[301051] = "lingbo",
	[401231] = "z23",
	[101171] = "lafei"
}
local var_0_7 = {
	[101171] = i18n("login_newPlayerScene_word_laFei"),
	[201211] = i18n("login_newPlayerScene_word_biaoqiang"),
	[401231] = i18n("login_newPlayerScene_word_z23")
}

function NewPlayerScene:getUIName()
	return "NewPlayerUI"
end

function NewPlayerScene:getResource()
	local var_2_0 = {}
	local var_2_1 = {}
	local var_2_2 = {}

	for iter_2_0, iter_2_1 in pairs(var_0_6) do
		table.insertto(var_2_0, (ResPathSupport.GetPaintingListByPaintingName(iter_2_1)))
		table.insertto(var_2_1, (ResPathSupport.GetSkillIconList(iter_2_0)))

		local var_2_3 = Ship.New({
			configId = iter_2_0
		})

		table.insertto(var_2_2, (ResPathSupport.GetSpineCharListByPrefabName((var_2_3:getPrefab()))))
		table.insertto(var_2_2, (ResPathSupport.GetShipSkinLive2DList((var_2_3:getSkinId()))))
	end

	return table.insertto(ResPathSupport.MergeLuaArr(var_2_0, var_2_1, var_2_2), NewPlayerScene.super.getResource(self))
end

function NewPlayerScene:init()
	self.eventTriggers = {}
	self.characters = self._tf:Find("select_character/characters")
	self.propPanel = self._tf:Find("prop_panel")
	self.selectPanel = self._tf:Find("select_character")

	setActive(self.propPanel, false)
	setActive(self.selectPanel, true)

	self.confirmBtn = self.propPanel:Find("bg/qr_btn")
	self.tip = self._tf:Find("select_character/tip")
	self.skillPanel = self.propPanel:Find("bg/skill_panel")
	self.skillTpl = self:getTpl("bg/skill_panel/frame/skilltpl", self.propPanel)
	self.skillContainer = self.propPanel:Find("bg/skill_panel/frame")
	self.namedPanel = self._tf:Find("named_panel")

	setActive(self.namedPanel, false)

	self.info = self.namedPanel:Find("info")
	self.nickname = self.info:Find("nickname")
	self.qChar = self.propPanel:Find("q_char")
	self.chat = self.namedPanel:Find("info/tip/chatbgtop0/Text")
	self.propertyPanel = PropertyPanel.New(self.propPanel:Find("bg/property_panel/frame"))
	self.paintTF = self._tf:Find("prop_panel/bg/paint")
	self.nameTF = self._tf:Find("prop_panel/bg/name")
	self.nameEnTF = self._tf:Find("prop_panel/bg/english_name_bg")
	self.titleShipinfoTF = self._tf:Find("lines/hori/shipinfo_text")
	self.titleShipchooseTF = self._tf:Find("lines/hori/shipchoose_text")

	setImageAlpha(self.titleShipinfoTF, 1)
	setImageAlpha(self.titleShipchooseTF, 0)

	self.randBtn = findTF(self.info, "random_button")

	setActive(self.randBtn, PLATFORM_CODE == PLATFORM_CH)
end

function NewPlayerScene:onBackPressed()
	if LeanTween.isTweening(go(self.propPanel)) then
		return
	end

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if isActive(self.namedPanel) then
		self:closeNamedPanel()

		return
	end

	pg.SdkMgr.GetInstance():OnAndoridBackPress()
end

function NewPlayerScene:switchPanel()
	setActive(self.propPanel, true)

	local var_5_0 = self.propPanel:GetComponent(typeof(CanvasGroup))
	local var_5_1 = self.selectPanel:GetComponent(typeof(CanvasGroup))

	LeanTween.value(go(self.propPanel), 0, 1, 0.5):setOnUpdate(System.Action_float(function(arg_6_0)
		var_5_0.alpha = arg_6_0
		var_5_1.alpha = 1 - arg_6_0
	end)):setOnComplete(System.Action(function()
		setActive(self.selectPanel, false)
	end))

	self.skillPanel.localPosition = Vector3.New(-1000, self.skillPanel.localPosition.y, self.skillPanel.localPosition.z)

	LeanTween.moveX(self.skillPanel, 339, 0.2)
	LeanTween.moveY(self._tf:Find("lines/line"), -328, 0.2)
	LeanTween.moveX(self._tf:Find("lines/hori"), -820, 0.2)

	for iter_5_0 = 1, 3 do
		local var_5_2 = self.characters:Find("character_" .. iter_5_0)
		local var_5_3 = self.propPanel:Find("bg/characters/character_" .. iter_5_0)

		setImageAlpha(var_5_2, 1)
		LeanTween.alpha(var_5_2, 0, 0.25)
		LeanTween.move(go(var_5_2), var_5_3.position, 0.3)
		setImageAlpha(self.titleShipinfoTF, 0)
		setImageAlpha(self.titleShipchooseTF, 1)
		LeanTween.alpha(self.titleShipinfoTF, 1, 0.25)
		LeanTween.alpha(self.titleShipchooseTF, 0, 0.25)
	end
end

function NewPlayerScene:initCharacters()
	self.charInitPos = {}

	for iter_8_0 = 1, 3 do
		local var_8_0 = self._tf:Find("prop_panel/bg/characters/character_" .. iter_8_0)

		onToggle(self, var_8_0, function(arg_9_0)
			if arg_9_0 then
				self:selectCharacterByIdx(var_8_0, var_0_5[iter_8_0])
				setActive(var_8_0:Find("selected"), true)

				var_8_0:GetComponent(typeof(RectTransform)).sizeDelta = Vector2(196, 196)
			else
				setActive(var_8_0:Find("selected"), false)

				var_8_0:GetComponent(typeof(RectTransform)).sizeDelta = Vector2(140, 140)
			end
		end)
	end

	local var_8_1 = {
		0.2,
		0.3,
		0.1
	}

	for iter_8_1 = 1, 3 do
		local var_8_2 = self.characters:Find("character_" .. iter_8_1)

		onButton(self, var_8_2, function()
			self:switchPanel()
			triggerToggle(self._tf:Find("prop_panel/bg/characters/character_" .. iter_8_1), true)
		end)

		var_8_2.localPosition = Vector3.New(var_8_2.localPosition.x, 912, var_8_2.localPosition.z)

		setImageAlpha(var_8_2, 0)
		LeanTween.alpha(var_8_2, 1, 0.3):setDelay(var_8_1[iter_8_1])
		LeanTween.moveY(var_8_2, 0, 0.2):setDelay(var_8_1[iter_8_1])
	end
end

function NewPlayerScene:didEnter()
	onButton(self, self.confirmBtn, function()
		self:showNamedPanel()
	end, SFX_PANEL)
	onButton(self, findTF(self.info, "random_button"), function()
		local names = require("GameCfg.names")

		setInputText(self.nickname, names[1][math.random(#names[1])] .. names[2][math.random(#names[2])] .. names[3][math.random(#names[3])] .. names[4][math.random(#names[4])])
	end, SFX_MAIN)
	onButton(self, findTF(self.info, "btn_container/enter_button"), function()
		if not self.contextData.configId then
			pg.TipsMgr.GetInstance():ShowTips(i18n("login_newPlayerScene_error_notChoiseShip"))

			return
		end

		local var_14_0 = getInputText(self.nickname)

		if var_14_0 == "" then
			pg.TipsMgr.GetInstance():ShowTips(i18n("login_newPlayerScene_inputName"))

			return
		end

		if not nameValidityCheck(var_14_0, 4, 14, {
			"spece_illegal_tip",
			"login_newPlayerScene_name_tooShort",
			"login_newPlayerScene_name_tooLong",
			"login_newPlayerScene_invalideName"
		}) then
			return
		end

		self.event:emit(NewPlayerMediator.ON_CREATE, var_14_0, self.contextData.configId)
	end, SFX_CONFIRM)
	onButton(self, findTF(self.info, "btn_container/cancel_button"), function()
		self:closeNamedPanel()
	end)
	self:initCharacters()
end

function NewPlayerScene:selectCharacterByIdx(arg_16_1, arg_16_2)
	self.inProp = true
	self.contextData.configId = arg_16_2

	self.propertyPanel:initProperty(arg_16_2)
	self:initSkills()
	setPaintingPrefab(self.paintTF, var_0_6[arg_16_2], "chuanwu")
	setText(self.nameTF:Find("name_mask/Text"), pg.ship_data_statistics[arg_16_2].name)
	setText(self.nameTF:Find("english_name"), pg.ship_data_statistics[arg_16_2].english_name)
	setText(self.nameEnTF, string.upper(pg.ship_data_statistics[arg_16_2].english_name))

	local var_16_0 = Ship.New({
		configId = self.contextData.configId
	}):getPrefab()

	if var_16_0 == self.shipPrefab then
		return
	end

	self:recycleSpineChar()
	pg.UIMgr.GetInstance():LoadingOn()
	PoolMgr.GetInstance():GetSpineChar(var_16_0, true, function(arg_17_0)
		pg.UIMgr.GetInstance():LoadingOff()

		self.shipPrefab = var_16_0
		self.shipModel = arg_17_0

		arg_17_0:GetComponent("SpineAnimUI"):SetAction("stand", 0)

		tf(arg_17_0).localScale = Vector3(0.5, 0.5, 1)
		tf(arg_17_0).localPosition = Vector3(15, -95, 0)

		pg.ViewUtils.SetLayer(tf(arg_17_0), Layer.UI)
		removeAllChildren(self.qChar)
		SetParent(arg_17_0, self.qChar, false)
	end)
end

function NewPlayerScene:initSkills()
	removeAllChildren(self.skillContainer)

	for iter_18_0, iter_18_1 in ipairs(pg.ship_data_template[self.contextData.configId].buff_list_display) do
		local var_18_0 = getSkillConfig(iter_18_1)
		local var_18_1 = cloneTplTo(self.skillTpl, self.skillContainer)

		setActive(var_18_1:Find("mask"), not table.contains(pg.ship_data_template[self.contextData.configId].buff_list, iter_18_1))
		onButton(self, var_18_1, function()
			self:emit(NewPlayerMediator.ON_SKILLINFO, var_18_0.id)
		end, SFX_PANEL)
		LoadImageSpriteAsync("skillicon/" .. var_18_0.icon, findTF(var_18_1, "icon"))
	end
end

function NewPlayerScene:showNamedPanel()
	self.qChar:SetParent(self.info)
	pg.UIMgr.GetInstance():BlurPanel(self.namedPanel)
	setActive(self.namedPanel, true)
	setInputText(self.nickname, "")
	setText(self.chat, var_0_7[self.contextData.configId])
end

function NewPlayerScene:closeNamedPanel()
	pg.UIMgr.GetInstance():UnOverlayPanel(self.namedPanel, self._tf)
	setActive(self.namedPanel, false)
	self.qChar:SetParent(self.propPanel)
end

function NewPlayerScene:recycleSpineChar()
	if self.shipPrefab and self.shipModel then
		PoolMgr.GetInstance():ReturnSpineChar(self.shipPrefab, self.shipModel)

		self.shipPrefab = nil
		self.shipModel = nil
	end
end

function NewPlayerScene:willExit()
	if self.eventTriggers then
		for iter_23_0, iter_23_1 in pairs(self.eventTriggers) do
			ClearEventTrigger(iter_23_0)
		end

		self.eventTriggers = nil
	end

	self:closeNamedPanel()
end

return NewPlayerScene
