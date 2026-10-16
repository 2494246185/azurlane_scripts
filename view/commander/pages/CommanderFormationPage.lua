local CommanderFormationPage = class("CommanderFormationPage", import("...base.BaseSubView"))

function CommanderFormationPage:getUIName()
	return "CommanderFormationUI"
end

function CommanderFormationPage:getResource()
	return table.insertto({
		"attricon",
		"weaponframes"
	}, CommanderFormationPage.super.getResource(self))
end

function CommanderFormationPage:getCommanderResList(arg_3_1, arg_3_2)
	local var_3_0 = {}

	local function var_3_1(arg_4_0)
		if arg_4_0 then
			table.insert(var_3_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.Commander.CommanderHrz, arg_4_0:getPainting())))

			local var_4_0 = arg_4_0:getSkills()[1]

			if var_4_0 then
				table.insert(var_3_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.Commander.CommanderSkillIcon, var_4_0:getConfig("icon"))))
			end
		end
	end

	if arg_3_1 then
		_.each(arg_3_1:getCommanders(), function(arg_5_0)
			var_3_1(arg_5_0)
		end)
	end

	_.each(arg_3_2 or {}, function(arg_6_0)
		for iter_6_0 = 1, CommanderConst.MAX_FORMATION_POS do
			var_3_1(arg_6_0:getCommanderByPos(iter_6_0))
		end
	end)

	return var_3_0
end

function CommanderFormationPage:OnInit()
	setActive(self.samllTF, true)

	self.pos1 = self.samllTF:Find("commander1")
	self.pos2 = self.samllTF:Find("commander2")

	setActive(self.descPanel, false)

	self.descFrameTF = self.descPanel:Find("frame")
	self.descPos1 = self.descFrameTF:Find("commander1/frame/info")
	self.descPos2 = self.descFrameTF:Find("commander2/frame/info")
	self.skillTFPos1 = self.descFrameTF:Find("commander1/skill_info")
	self.skillTFPos2 = self.descFrameTF:Find("commander2/skill_info")
	self.abilitysTF = UIItemList.New(self.descFrameTF:Find("atttr_panel/abilitys/mask/content"), self.descFrameTF:Find("atttr_panel/abilitys/mask/content/attr"))
	self.talentsTF = UIItemList.New(self.descFrameTF:Find("atttr_panel/talents/mask/content"), self.descFrameTF:Find("atttr_panel/talents/mask/content/attr"))
	self.abilityArr = self.descPanel:Find("frame/atttr_panel/abilitys/arr")
	self.talentsArr = self.descPanel:Find("frame/atttr_panel/talents/arr")
	self.restAllBtn = self.descFrameTF:Find("rest_all")
	self.quickBtn = self.descFrameTF:Find("quick_btn")
	self.recordCommanders = {
		self.recordPanel:Find("current/commanders/commander1/frame/info"),
		self.recordPanel:Find("current/commanders/commander2/frame/info")
	}
	self.reocrdSkills = {
		self.recordPanel:Find("current/commanders/commander1/skill_info"),
		self.recordPanel:Find("current/commanders/commander2/skill_info")
	}
	self.recordList = UIItemList.New(self.recordPanel:Find("record/content"), self.recordPanel:Find("record/content/commanders"))

	onButton(self, self.samllTF, function()
		self:openDescPanel()
	end, SFX_PANEL)
	onButton(self, self.quickBtn, function()
		self:OpenRecordPanel()
	end, SFX_PANEL)
	onButton(self, self._tf:Find("bg"), function()
		if isActive(self.recordPanel) then
			self:CloseRecordPanel()
		elseif isActive(self.descPanel) then
			self:closeDescPanel()
		end
	end, SFX_PANEL)
	onButton(self, self.restAllBtn, function()
		self:emit(FormationMediator.COMMANDER_FORMATION_OP, {
			FleetType = LevelUIConst.FLEET_TYPE_SELECT,
			data = {
				type = LevelUIConst.COMMANDER_OP_REST_ALL
			},
			fleetId = self.fleet.id
		})
	end, SFX_PANEL)
	setText(self.descPanel:Find("frame/atttr_panel/abilitys/title/Text"), i18n("commander_subtile_ablity"))
	setText(self.descPanel:Find("frame/atttr_panel/talents/title/Text"), i18n("commander_subtile_talent"))
	setText(self.recordPanel:Find("current/title/Text"), i18n("commander_formation_prefab_fleet"))
end

function CommanderFormationPage:Update(arg_12_1, arg_12_2)
	self.fleet = arg_12_1
	self.prefabFleets = arg_12_2

	SplitPackConst.DownloadByLuaArr(self:getCommanderResList(arg_12_1, arg_12_2), function()
		if self._state == CommanderFormationPage.STATES.DESTROY then
			return
		end

		self:updateAfterResDownload()
	end)
end

function CommanderFormationPage:updateAfterResDownload()
	local var_14_0 = self.fleet:getCommanders()

	for iter_14_0 = 1, CommanderConst.MAX_FORMATION_POS do
		assert(self["pos" .. iter_14_0], "pos tf can not nil")
		self:updateCommander(self["pos" .. iter_14_0], iter_14_0, var_14_0[iter_14_0])
	end

	self:updateDesc()
	self:updateRecordPanel()
end

function CommanderFormationPage:openDescPanel(arg_15_1)
	local var_15_0 = arg_15_1 or 0.2

	if LeanTween.isTweening(go(self.samllTF)) or LeanTween.isTweening(go(self.descFrameTF)) then
		return
	end

	setAnchoredPosition(self.samllTF, {
		x = 0
	})
	LeanTween.moveX(self.samllTF, 800, var_15_0):setOnComplete(System.Action(function()
		setActive(self.descPanel, true)
		setActive(self.descBg, true)
		pg.UIMgr.GetInstance():OverlayPanel(self._tf)
		setAnchoredPosition(self.descFrameTF, {
			x = 800
		})
		LeanTween.moveX(self.descFrameTF, 0, var_15_0)
	end))

	self.contextData.inDescPage = true
end

function CommanderFormationPage:closeDescPanel(arg_17_1)
	local var_17_0 = arg_17_1 or 0.2

	if LeanTween.isTweening(go(self.samllTF)) or LeanTween.isTweening(go(self.descFrameTF)) then
		return
	end

	setAnchoredPosition(self.descFrameTF, {
		x = 0
	})
	LeanTween.moveX(self.descFrameTF, 800, var_17_0):setOnComplete(System.Action(function()
		setActive(self.descPanel, false)
		setActive(self.descBg, false)
		pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
		setAnchoredPosition(self.samllTF, {
			x = 800
		})
		LeanTween.moveX(self.samllTF, 0, var_17_0)
	end))

	self.contextData.inDescPage = false
end

function CommanderFormationPage:updateDesc()
	local var_19_0 = self.fleet:getCommanders()

	for iter_19_0 = 1, CommanderConst.MAX_FORMATION_POS do
		assert(self["pos" .. iter_19_0], "pos tf can not nil")
		self:updateCommander(self["descPos" .. iter_19_0], iter_19_0, var_19_0[iter_19_0], true)
		self:updateSkillTF(var_19_0[iter_19_0], self["skillTFPos" .. iter_19_0])
	end

	self:updateAdditions()
end

function CommanderFormationPage:updateAdditions()
	local var_20_0 = _.values(self.fleet:getCommandersTalentDesc())
	local var_20_1, var_20_2 = self.fleet:getCommandersAddition()

	self.abilitysTF:make(function(arg_21_0, arg_21_1, arg_21_2)
		if arg_21_0 == UIItemList.EventUpdate then
			setText(arg_21_2:Find("name"), AttributeType.Type2Name(var_20_1[arg_21_1 + 1].attrName))
			setText(arg_21_2:Find("Text"), ("+" .. math.floor(var_20_1[arg_21_1 + 1].value * 1000) / 1000) .. "%")
			GetImageSpriteFromAtlasAsync("attricon", var_20_1[arg_21_1 + 1].attrName, arg_21_2:Find("icon"), false)
			setImageAlpha(arg_21_2:Find("bg"), arg_21_1 % 2)
		end
	end)
	self.abilitysTF:align(#var_20_1)
	setActive(self.abilityArr, #var_20_1 > 4)
	self.talentsTF:make(function(arg_22_0, arg_22_1, arg_22_2)
		if arg_22_0 == UIItemList.EventUpdate then
			local var_22_0 = var_20_0[arg_22_1 + 1]

			setScrollText(findTF(arg_22_2, "name_mask/name"), var_20_0[arg_22_1 + 1].name)
			setText(arg_22_2:Find("Text"), (var_22_0.value > 0 and "+" or "") .. var_22_0.value .. (var_22_0.type == CommanderConst.TALENT_ADDITION_RATIO and "%" or ""))
			setImageAlpha(arg_22_2:Find("bg"), arg_22_1 % 2)
		end
	end)
	self.talentsTF:align(#var_20_0)
	setActive(self.talentsArr, #var_20_0 > 4)
	Canvas.ForceUpdateCanvases()
end

function CommanderFormationPage:updateSkillTF(arg_23_1, arg_23_2)
	setActive(arg_23_2, arg_23_1)

	if arg_23_1 then
		local var_23_0 = arg_23_1:getSkills()[1]

		GetImageSpriteFromAtlasAsync("CommanderSkillIcon/" .. var_23_0:getConfig("icon"), "", arg_23_2:Find("icon"))
		setText(arg_23_2:Find("level"), "Lv." .. var_23_0:getLevel())
		onButton(self, arg_23_2, function()
			self:emit(FormationMediator.ON_CMD_SKILL, var_23_0)
		end, SFX_PANEL)
	else
		removeOnButton(arg_23_2)
	end
end

function CommanderFormationPage:updateCommander(arg_25_1, arg_25_2, arg_25_3, arg_25_4)
	local var_25_0 = arg_25_1:Find("add")
	local var_25_1 = arg_25_1:Find("info")

	if arg_25_3 then
		GetImageSpriteFromAtlasAsync("CommanderHrz/" .. arg_25_3:getPainting(), "", (arg_25_1:Find("info/mask/icon")))

		local var_25_2 = arg_25_1:Find("info/name")

		if var_25_2 then
			setText(var_25_2, arg_25_3:getName())
		end

		setImageSprite(arg_25_1:Find("info/frame"), GetSpriteFromAtlas("weaponframes", "commander_" .. Commander.rarity2Frame(arg_25_3:getRarity())))
	end

	if arg_25_4 then
		onButton(self, var_25_1, function()
			self:emit(FormationMediator.ON_SELECT_COMMANDER, arg_25_2, self.fleet.id)
		end, SFX_PANEL)
		onButton(self, var_25_0, function()
			self:emit(FormationMediator.ON_SELECT_COMMANDER, arg_25_2, self.fleet.id)
		end, SFX_PANEL)
	end

	setActive(var_25_0, not arg_25_3)
	setActive(var_25_1, arg_25_3)
end

function CommanderFormationPage:OpenRecordPanel()
	setActive(self.descFrameTF, false)
	setActive(self.recordPanel, true)
end

function CommanderFormationPage:updateRecordPanel()
	local var_29_0 = self.fleet:getCommanders()

	for iter_29_0, iter_29_1 in ipairs(self.recordCommanders) do
		self:updateCommander(iter_29_1, iter_29_0, var_29_0[iter_29_0])
		self:updateSkillTF(var_29_0[iter_29_0], self.reocrdSkills[iter_29_0])
	end

	self.recordList:make(function(arg_30_0, arg_30_1, arg_30_2)
		if arg_30_0 == UIItemList.EventUpdate then
			self:UpdatePrefabFleet(self.prefabFleets[arg_30_1 + 1], arg_30_2, var_29_0)
		end
	end)
	self.recordList:align(#self.prefabFleets)
end

function CommanderFormationPage:UpdatePrefabFleet(arg_31_1, arg_31_2, arg_31_3)
	local var_31_0 = arg_31_2:Find("fleet_name")
	local var_31_1 = arg_31_1:getName()

	onInputEndEdit(self, var_31_0, function()
		self:emit(FormationMediator.COMMANDER_FORMATION_OP, {
			FleetType = LevelUIConst.FLEET_TYPE_SELECT,
			data = {
				type = LevelUIConst.COMMANDER_OP_RENAME,
				id = arg_31_1.id,
				str = getInputText(var_31_0),
				onFailed = function()
					setInputText(var_31_0, var_31_1)
				end
			},
			fleetId = self.fleet.id
		})
	end)
	setInputText(var_31_0, var_31_1)
	onButton(self, arg_31_2:Find("use_btn"), function()
		self:emit(FormationMediator.COMMANDER_FORMATION_OP, {
			FleetType = LevelUIConst.FLEET_TYPE_SELECT,
			data = {
				type = LevelUIConst.COMMANDER_OP_USE_PREFAB,
				id = arg_31_1.id
			},
			fleetId = self.fleet.id
		})
		self:CloseRecordPanel()
	end, SFX_PANEL)
	onButton(self, arg_31_2:Find("record_btn"), function()
		self:emit(FormationMediator.COMMANDER_FORMATION_OP, {
			FleetType = LevelUIConst.FLEET_TYPE_SELECT,
			data = {
				type = LevelUIConst.COMMANDER_OP_RECORD_PREFAB,
				id = arg_31_1.id
			},
			fleetId = self.fleet.id
		})
	end, SFX_PANEL)

	local var_31_2 = {
		arg_31_2:Find("commander1/skill_info"),
		arg_31_2:Find("commander2/skill_info")
	}

	for iter_31_0, iter_31_1 in ipairs({
		arg_31_2:Find("commander1/frame/info"),
		arg_31_2:Find("commander2/frame/info")
	}) do
		local var_31_3 = arg_31_1:getCommanderByPos(iter_31_0)

		self:updateCommander(iter_31_1, iter_31_0, var_31_3)
		self:updateSkillTF(var_31_3, var_31_2[iter_31_0])
	end
end

function CommanderFormationPage:CloseRecordPanel()
	setActive(self.descFrameTF, true)
	setActive(self.recordPanel, false)
end

function CommanderFormationPage:OnDestroy()
	if self:isShowing() then
		LeanTween.cancel(go(self.samllTF))
		LeanTween.cancel(go(self.descFrameTF))

		if isActive(self.descPanel) then
			pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
		end
	end
end

return CommanderFormationPage
