local CommanderSkillLayer = class("CommanderSkillLayer", import("..base.BaseUI"))

function CommanderSkillLayer:getUIName()
	return "CommanderSkillUI"
end

function CommanderSkillLayer:getResource()
	local var_2_0 = {}

	if self.contextData.skill then
		table.insert(var_2_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.Commander.CommanderSkillIcon, self.contextData.skill:getConfig("icon"))))
	end

	return table.insertto(var_2_0, CommanderSkillLayer.super.getResource(self))
end

function CommanderSkillLayer:init()
	self.backBtn = self._tf:Find("top/btnBack")
	self.skillInfoName = self._tf:Find("panel/bg/skill_name")
	self.skillInfoLv = self._tf:Find("panel/bg/skill_lv")
	self.skillInfoIntro = self._tf:Find("panel/bg/help_panel/skill_intro")
	self.skillInfoIcon = self._tf:Find("panel/bg/skill_icon")
	self.buttonList = self._tf:Find("panel/buttonList")
	self.skillDescTF = self._tf:Find("panel/bg/help_panel/Viewport/content/introTF")
	self.skillDescContent = self._tf:Find("panel/bg/help_panel/Viewport/content")

	setText(self.skillInfoName, self.contextData.skill:getConfig("name"))
	setText(self.skillInfoLv, "Lv." .. self.contextData.skill:getLevel())

	self.skillDescList = UIItemList.New(self.skillDescContent, self.skillDescTF)

	GetImageSpriteFromAtlasAsync("commanderskillicon/" .. self.contextData.skill:getConfig("icon"), "", self.skillInfoIcon)
	self:SetLocaliza()
end

function CommanderSkillLayer:SetLocaliza()
	setText(self._tf:Find("top/title_list/infomation/title"), i18n("words_information"))
	setText(self._tf:Find("panel/buttonList/ok_button/Image"), i18n("word_ok"))
end

function CommanderSkillLayer:didEnter()
	onButton(self, self._tf, function()
		self:emit(CommanderSkillLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self.backBtn, function()
		self:emit(CommanderSkillLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("panel/buttonList/ok_button"), function()
		self:emit(CommanderSkillLayer.ON_CLOSE)
	end, SFX_CONFIRM)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.commonFlag = defaultValue(self.contextData.commonFlag, true)

	self:UpdateList()
end

function CommanderSkillLayer:UpdateList()
	local var_9_0 = self.contextData.skill:getConfig("lv")
	local var_9_1 = self.contextData.skill:GetSkillGroup()
	local var_9_2 = self.contextData.skill:getConfig("lv")

	self.skillDescList:make(function(arg_10_0, arg_10_1, arg_10_2)
		if arg_10_0 == UIItemList.EventUpdate then
			local var_10_0 = var_9_1[arg_10_1 + 1]
			local var_10_1 = self:GetColor(var_9_2 >= var_9_1[arg_10_1 + 1].lv)

			setText(arg_10_2, "<color=" .. var_10_1 .. ">" .. self:GetDesc(self.commonFlag, var_9_1[arg_10_1 + 1]) .. (var_9_2 < var_9_1[arg_10_1 + 1].lv and "(Lv." .. var_10_0.lv .. i18n("word_take_effect") .. ")" or "") .. "</color>")
			setText(arg_10_2:Find("level"), "<color=" .. var_10_1 .. ">" .. "Lv." .. var_10_0.lv .. "</color>")
		end
	end)
	self.skillDescList:align(#var_9_1)
end

function CommanderSkillLayer:GetDesc(arg_11_1, arg_11_2)
	if not arg_11_1 and arg_11_2.desc_world and arg_11_2.desc_world ~= "" then
		return arg_11_2.desc_world
	else
		return arg_11_2.desc
	end
end

function CommanderSkillLayer:GetColor(arg_12_1)
	return "#FFFFFFFF"
end

function CommanderSkillLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

function CommanderSkillLayer:onBackPressed()
	triggerButton(self.backBtn)
end

return CommanderSkillLayer
