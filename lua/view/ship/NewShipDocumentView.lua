local NewShipDocumentView = class("NewShipDocumentView", import("..base.BaseSubView"))

function NewShipDocumentView:getUIName()
	return "NewShipDocumentView"
end

function NewShipDocumentView:getResource()
	local var_2_0 = {}

	if self.contextData.ship then
		_.each(pg.ship_data_template[self.contextData.ship:getMaxConfigId()].buff_list_display, function(arg_3_0)
			table.insert(var_2_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.ShipSkillIcon, getSkillConfig(arg_3_0).icon)))
		end)
	end

	return table.insertto(var_2_0, NewShipDocumentView.super.getResource(self))
end

function NewShipDocumentView:OnInit()
	self:InitUI()
	self:AddListener()
	setActive(self._tf, true)
	LeanTween.move(rtf(self._tf), Vector3(-30, 0, 0), 0.3)
end

function NewShipDocumentView:OnDestroy()
	self._shipVO = nil
	self.confirmFunc = nil
end

function NewShipDocumentView:InitUI()
	self.skillContainer = self._tf:Find("bg/skill_panel/frame/skill_list/viewport")
	self.skillTpl = self:getTpl("bg/skill_panel/frame/skilltpl", self._tf)
	self.emptyTpl = self:getTpl("bg/skill_panel/frame/emptytpl", self._tf)
	self.addTpl = self:getTpl("bg/skill_panel/frame/addtpl", self._tf)
end

function NewShipDocumentView:AddListener()
	onButton(self, self._tf:Find("qr_btn"), function()
		self.confirmFunc()
	end, SFX_CONFIRM)
end

function NewShipDocumentView:initSkills()
	local var_9_0 = 1

	for iter_9_0, iter_9_1 in ipairs(pg.ship_data_template[self._shipVO:getMaxConfigId()].buff_list_display) do
		local var_9_1 = getSkillConfig(iter_9_1)
		local var_9_2 = self._shipVO.skills
		local var_9_3

		if self._shipVO.skills[iter_9_1] then
			var_9_3 = cloneTplTo(self.skillTpl, self.skillContainer)

			onButton(self, var_9_3, function()
				self:emit(NewShipMediator.ON_SKILLINFO, var_9_1.id, var_9_2[iter_9_1])
			end, SFX_PANEL)
		else
			var_9_3 = cloneTplTo(self.emptyTpl, self.skillContainer)

			setActive(var_9_3:Find("mask"), true)
			onButton(self, var_9_3, function()
				self:emit(NewShipMediator.ON_SKILLINFO, var_9_1.id)
			end, SFX_PANEL)
		end

		var_9_0 = var_9_0 + 1

		LoadImageSpriteAsync("skillicon/" .. var_9_1.icon, findTF(var_9_3, "icon"))
	end

	for iter_9_2 = var_9_0, 3 do
		cloneTplTo(self.addTpl, self.skillContainer)
	end
end

function NewShipDocumentView:UpdatePropertyPanel()
	self.propertyPanel = PropertyPanel.New(self._tf:Find("bg/property_panel/frame"))

	self.propertyPanel:initProperty(self._shipVO.configId)
end

function NewShipDocumentView:getTpl(arg_13_1, arg_13_2)
	local var_13_0 = arg_13_2:Find(arg_13_1)

	var_13_0:SetParent(self._tf, false)
	SetActive(var_13_0, false)

	return var_13_0
end

function NewShipDocumentView:SetParams(arg_14_1, arg_14_2)
	self._shipVO = arg_14_1
	self.confirmFunc = arg_14_2
end

function NewShipDocumentView:RefreshUI()
	self:initSkills()
	self:UpdatePropertyPanel()
end

return NewShipDocumentView
