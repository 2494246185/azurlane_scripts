local SkillInfoLayer = class("SkillInfoLayer", import("..base.BaseUI"))

function SkillInfoLayer:getUIName()
	return "SkillInfoUI"
end

function SkillInfoLayer:getResource()
	local var_2_0 = {}

	table.insert(var_2_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.ShipSkillIcon, getSkillConfig(self.contextData.skillId).icon)))

	return table.insertto(var_2_0, SkillInfoLayer.super.getResource(self))
end

function SkillInfoLayer:init()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.backBtn = self._tf:Find("panel/top/btnBack")
	self.skillInfoName = self._tf:Find("panel/bg/skill_name")
	self.skillInfoLv = self._tf:Find("panel/bg/skill_lv")
	self.skillInfoIntro = self._tf:Find("panel/bg/help_panel/skill_intro")
	self.skillInfoIcon = self._tf:Find("panel/bg/skill_icon")
	self.btnTypeNormal = self._tf:Find("panel/bg/btn_type_normal")
	self.btnTypeWorld = self._tf:Find("panel/bg/btn_type_world")
	self.buttonList = self._tf:Find("panel/buttonList")
	self.upgradeBtn = self._tf:Find("panel/buttonList/level_button")
	self.metaBtn = self._tf:Find("panel/buttonList/meta_button")

	setText(self.metaBtn:Find("Image"), i18n("meta_skillbtn_tactics"))
	setText(self._tf:Find("panel/top/title_list/infomation/title"), i18n("words_information"))
	setText(self.buttonList:Find("ok_button/Image"), i18n("text_confirm"))

	if PLATFORM_CODE == PLATFORM_JP then
		setText(self.buttonList:Find("level_button/Image"), i18n("msgbox_text_noPos_intensify"))
	else
		setText(self.buttonList:Find("level_button/Image"), i18n("msgbox_text_upgrade"))
	end
end

function SkillInfoLayer:didEnter()
	onButton(self, self._tf, function()
		self:emit(SkillInfoLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self.backBtn, function()
		self:emit(SkillInfoLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("panel/buttonList/ok_button"), function()
		self:emit(SkillInfoLayer.ON_CLOSE)
	end, SFX_CONFIRM)
	onButton(self, self.upgradeBtn, function()
		self:emit(SkillInfoMediator.WARP_TO_TACTIC)
	end, SFX_UI_CLICK)
	onButton(self, self.metaBtn, function()
		local var_9_0
		local var_9_1

		if self.contextData.shipId then
			var_9_1 = getProxy(BayProxy):getShipById(self.contextData.shipId)
			var_9_0 = var_9_1:isMetaShip()
		end

		if var_9_0 then
			self:emit(SkillInfoMediator.WARP_TO_META_TACTICS, var_9_1.configId)
		end
	end, SFX_PANEL)
	onButton(self, self.btnTypeNormal, function()
		self:showInfo(false)
		self:flushTypeBtn()
	end, SFX_PANEL)
	onButton(self, self.btnTypeWorld, function()
		self:showInfo(true)
		self:flushTypeBtn()
	end, SFX_PANEL)

	if tobool(pg.skill_world_display[self.contextData.skillId]) then
		self:flushTypeBtn()
	else
		setActive(self.btnTypeNormal, false)
		setActive(self.btnTypeWorld, false)
	end

	self:showBase()
	self:showInfo(false)
end

function SkillInfoLayer:flushTypeBtn()
	setActive(self.btnTypeNormal, self.isWorld)
	setActive(self.btnTypeWorld, not self.isWorld)
end

function SkillInfoLayer:showBase()
	local var_13_0 = self.contextData.skillId
	local var_13_1 = self.contextData.skillOnShip

	setText(self.skillInfoName, getSkillName(self.contextData.skillId))

	local var_13_2 = getSkillConfig(var_13_0)

	LoadImageSpriteAsync("skillicon/" .. var_13_2.icon, self.skillInfoIcon)
	setActive(self.upgradeBtn, not self.contextData.fromNewShip and var_13_1 and var_13_1.level < #var_13_2 and var_13_1.id ~= 22262 and var_13_1.id ~= 22261)

	local var_13_3

	if self.contextData.shipId then
		var_13_3 = getProxy(BayProxy):getShipById(self.contextData.shipId):isMetaShip()
	end

	setActive(self.metaBtn, var_13_3 and MetaCharacterConst.isMetaTaskSkillID(var_13_0))

	if var_13_3 then
		setActive(self.upgradeBtn, false)
	end
end

function SkillInfoLayer:showInfo(arg_14_1)
	self.isWorld = arg_14_1

	local var_14_0 = self.contextData.skillId
	local var_14_1

	if self.contextData.skillOnShip then
		var_14_1 = self.contextData.skillOnShip.level or 1
	end

	setText(self.skillInfoLv, "Lv." .. var_14_1)

	if self.contextData.fromNewShip then
		setText(self.skillInfoIntro, getSkillDescGet(var_14_0, arg_14_1))
	else
		setText(self.skillInfoIntro, getSkillDesc(var_14_0, var_14_1, arg_14_1))
	end
end

function SkillInfoLayer:close()
	self:emit(SkillInfoLayer.ON_CLOSE)
end

function SkillInfoLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.contextData.onExit then
		self.contextData.onExit()
	end
end

function SkillInfoLayer:inOutAnim(arg_17_1, arg_17_2)
	if arg_17_1 then
		local var_17_0 = self._tf:Find("panel/bg_decorations"):GetComponent(typeof(Animation))

		var_17_0:Stop()
		var_17_0:Play("anim_window_bg")

		local var_17_1 = self._tf:Find("panel/top"):GetComponent(typeof(Animation))

		var_17_1:Stop()
		var_17_1:Play("anim_top")

		local var_17_2 = self._tf:Find("panel/bg"):GetComponent(typeof(Animation))

		var_17_2:Stop()
		var_17_2:Play("anim_content")

		local var_17_3 = self._tf:Find("bg"):GetComponent(typeof(Animation))

		var_17_3:Stop()
		var_17_3:Play("anim_bg_plus")

		local var_17_4 = self._tf:Find("panel/buttonList"):GetComponent(typeof(Animation))

		var_17_4:Stop()
		var_17_4:Play("anim_button_container")
	end

	arg_17_2()
end

return SkillInfoLayer
