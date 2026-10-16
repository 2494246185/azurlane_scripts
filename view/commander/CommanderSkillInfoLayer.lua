local CommanderSkillInfoLayer = class("CommanderSkillInfoLayer", import("..base.BaseUI"))

function CommanderSkillInfoLayer:getUIName()
	return "CommanderSkillInfoUI"
end

function CommanderSkillInfoLayer:init()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.skillNameTxt = self._tf:Find("panel/bg/skill_name"):GetComponent(typeof(Text))
	self.skillLevelTxt = self._tf:Find("panel/bg/skill_lv"):GetComponent(typeof(Text))
	self.skillDescTxt = self._tf:Find("panel/bg/help_panel/skill_intro"):GetComponent(typeof(Text))
	self.skillIcon = self._tf:Find("panel/bg/skill_icon")
end

function CommanderSkillInfoLayer:didEnter()
	onButton(self, self._tf, function()
		self:emit(CommanderSkillInfoLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("panel/top/btnBack"), function()
		self:emit(CommanderSkillInfoLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("panel/ok_button"), function()
		self:emit(CommanderSkillInfoLayer.ON_CLOSE)
	end, SFX_CONFIRM)
	self:updateSkill()
end

function CommanderSkillInfoLayer:updateSkill()
	self.skillNameTxt.text = self.contextData.skill:getConfig("name")
	self.skillLevelTxt.text = "Lv." .. self.contextData.skill:getLevel()
	self.skillDescTxt.text = self.contextData.skill:getConfig("desc")

	GetImageSpriteFromAtlasAsync("CommanderSkillIcon/" .. self.contextData.skill:getConfig("icon"), "", self.skillIcon)
end

function CommanderSkillInfoLayer:close()
	self:emit(CommanderSkillInfoLayer.ON_CLOSE)
end

function CommanderSkillInfoLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return CommanderSkillInfoLayer
