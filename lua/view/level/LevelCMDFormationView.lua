local LevelCMDFormationView = class("LevelCMDFormationView", import("..base.BaseSubView"))

function LevelCMDFormationView:getUIName()
	return "LevelCommanderView"
end

function LevelCMDFormationView:getResource()
	return table.insertto({
		"attricon",
		"weaponframes"
	}, LevelCMDFormationView.super.getResource(self))
end

function LevelCMDFormationView:getLevelCMDFormationViewResList(arg_3_1, arg_3_2)
	local var_3_0 = {}

	local function var_3_1(arg_4_0)
		if not arg_4_0 then
			return
		end

		local var_4_0 = arg_4_0:getPainting()

		if noEmptyStr(var_4_0) then
			table.insert(var_3_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.Commander.CommanderHrz, var_4_0)))
		end

		local var_4_1 = arg_4_0:getSkills()[1]
		local var_4_2 = var_4_1 and var_4_1:getConfig("icon")

		if noEmptyStr(var_4_2) then
			table.insert(var_3_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.Commander.CommanderSkillIcon, var_4_2)))
		end
	end

	if arg_3_1 then
		_.each(arg_3_1:getCommanders(), var_3_1)
	end

	_.each(arg_3_2 or {}, function(arg_5_0)
		if arg_5_0 then
			for iter_5_0 = 1, CommanderConst.MAX_FORMATION_POS do
				var_3_1(arg_5_0:getCommanderByPos(iter_5_0))
			end
		end
	end)

	return var_3_0
end

function LevelCMDFormationView:downloadLevelCMDFormationViewResList(arg_6_1, arg_6_2, arg_6_3)
	SplitPackConst.DownloadByLuaArr(self:getLevelCMDFormationViewResList(arg_6_1, arg_6_2), function()
		if self._state == LevelCMDFormationView.STATES.DESTROY then
			return
		end

		arg_6_3()
	end)
end

function LevelCMDFormationView:OnInit()
	self:InitUI()
end

function LevelCMDFormationView:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end

	self.callback = nil
end

function LevelCMDFormationView:Show()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	setActive(self._tf, true)
end

function LevelCMDFormationView:Hide()
	setActive(self._go, false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

function LevelCMDFormationView:InitUI()
	self.descFrameTF = self._tf:Find("frame")
	self.descPos1 = self.descFrameTF:Find("commander1/frame/info")
	self.descPos2 = self.descFrameTF:Find("commander2/frame/info")
	self.skillTFPos1 = self.descFrameTF:Find("commander1/skill_info")
	self.skillTFPos2 = self.descFrameTF:Find("commander2/skill_info")
	self.abilitysTF = UIItemList.New(self.descFrameTF:Find("atttr_panel/abilitys/mask/content"), self.descFrameTF:Find("atttr_panel/abilitys/mask/content/attr"))
	self.talentsTF = UIItemList.New(self.descFrameTF:Find("atttr_panel/talents/mask/content"), self.descFrameTF:Find("atttr_panel/talents/mask/content/attr"))
	self.abilityArr = self._tf:Find("frame/atttr_panel/abilitys/arr")
	self.talentsArr = self._tf:Find("frame/atttr_panel/talents/arr")
	self.restAllBtn = self.descFrameTF:Find("rest_all")
	self.quickBtn = self.descFrameTF:Find("quick_btn")
	self.recordPanel = self._tf:Find("record_panel")
	self.recordCommanders = {
		self.recordPanel:Find("current/commanders/commander1/frame/info"),
		self.recordPanel:Find("current/commanders/commander2/frame/info")
	}
	self.reocrdSkills = {
		self.recordPanel:Find("current/commanders/commander1/skill_info"),
		self.recordPanel:Find("current/commanders/commander2/skill_info")
	}
	self.recordList = UIItemList.New(self.recordPanel:Find("record/content"), self.recordPanel:Find("record/content/commanders"))

	onButton(self, self.restAllBtn, function()
		self.callback({
			type = LevelUIConst.COMMANDER_OP_REST_ALL
		})
	end, SFX_PANEL)
	onButton(self, self.quickBtn, function()
		self:OpenRecordPanel()
	end, SFX_PANEL)
	onButton(self, self.recordPanel:Find("back"), function()
		self:CloseRecordPanel()
	end, SFX_PANEL)
	onButton(self, self._tf:Find("bg"), function()
		self:Hide()
	end, SFX_PANEL)
end

function LevelCMDFormationView:setCallback(arg_17_1)
	self.callback = arg_17_1
end

function LevelCMDFormationView:update(arg_18_1, arg_18_2)
	self:downloadLevelCMDFormationViewResList(arg_18_1, arg_18_2, function()
		self:updateFleet(arg_18_1)
		self:updatePrefabs(arg_18_2)
	end)
end

function LevelCMDFormationView:updateFleet(arg_20_1)
	self.fleet = arg_20_1

	self:updateDesc()
	self:updateRecordFleet()
end

function LevelCMDFormationView:updatePrefabs(arg_21_1)
	self.prefabFleets = arg_21_1

	self:updateRecordPanel()
end

function LevelCMDFormationView:updateRecordFleet()
	local var_22_0 = self.fleet:getCommanders()

	for iter_22_0, iter_22_1 in ipairs(self.recordCommanders) do
		self:updateCommander(iter_22_1, iter_22_0, var_22_0[iter_22_0])
		self:updateSkillTF(var_22_0[iter_22_0], self.reocrdSkills[iter_22_0])
	end
end

function LevelCMDFormationView:updateRecordPanel()
	local var_23_0 = self.fleet:getCommanders()

	self.recordList:make(function(arg_24_0, arg_24_1, arg_24_2)
		if arg_24_0 == UIItemList.EventUpdate then
			self:UpdatePrefabFleet(self.prefabFleets[arg_24_1 + 1], arg_24_2, var_23_0)
		end
	end)
	self.recordList:align(#self.prefabFleets)
end

function LevelCMDFormationView:UpdatePrefabFleet(arg_25_1, arg_25_2, arg_25_3)
	local var_25_0 = arg_25_2:Find("fleet_name")
	local var_25_1 = arg_25_1:getName()

	onInputEndEdit(self, var_25_0, function()
		self.callback({
			type = LevelUIConst.COMMANDER_OP_RENAME,
			id = arg_25_1.id,
			str = getInputText(var_25_0),
			onFailed = function()
				setInputText(var_25_0, var_25_1)
			end
		})
	end)
	setInputText(var_25_0, var_25_1)
	onButton(self, arg_25_2:Find("use_btn"), function()
		self.callback({
			type = LevelUIConst.COMMANDER_OP_USE_PREFAB,
			id = arg_25_1.id
		})
		self:CloseRecordPanel()
	end, SFX_PANEL)
	onButton(self, arg_25_2:Find("record_btn"), function()
		self.callback({
			type = LevelUIConst.COMMANDER_OP_RECORD_PREFAB,
			id = arg_25_1.id
		})
	end, SFX_PANEL)

	local var_25_2 = {
		arg_25_2:Find("commander1/skill_info"),
		arg_25_2:Find("commander2/skill_info")
	}

	for iter_25_0, iter_25_1 in ipairs({
		arg_25_2:Find("commander1/frame/info"),
		arg_25_2:Find("commander2/frame/info")
	}) do
		local var_25_3 = arg_25_1:getCommanderByPos(iter_25_0)

		self:updateCommander(iter_25_1, iter_25_0, var_25_3)
		self:updateSkillTF(var_25_3, var_25_2[iter_25_0])
	end
end

function LevelCMDFormationView:updateDesc()
	local var_30_0 = self.fleet:getCommanders()

	for iter_30_0 = 1, CommanderConst.MAX_FORMATION_POS do
		self:updateCommander(self["descPos" .. iter_30_0], iter_30_0, var_30_0[iter_30_0], true)
		self:updateSkillTF(var_30_0[iter_30_0], self["skillTFPos" .. iter_30_0])
	end

	self:updateAdditions()
end

function LevelCMDFormationView:updateAdditions()
	local var_31_0 = _.values(self.fleet:getCommandersTalentDesc())
	local var_31_1, var_31_2 = self.fleet:getCommandersAddition()

	self.abilitysTF:make(function(arg_32_0, arg_32_1, arg_32_2)
		if arg_32_0 == UIItemList.EventUpdate then
			setText(arg_32_2:Find("name"), AttributeType.Type2Name(var_31_1[arg_32_1 + 1].attrName))
			setText(arg_32_2:Find("Text"), string.format("%0.3f", var_31_1[arg_32_1 + 1].value) .. "%")
			GetImageSpriteFromAtlasAsync("attricon", var_31_1[arg_32_1 + 1].attrName, arg_32_2:Find("icon"), false)
			setImageAlpha(arg_32_2:Find("bg"), arg_32_1 % 2)
		end
	end)
	self.abilitysTF:align(#var_31_1)
	setActive(self.abilityArr, #var_31_1 > 4)
	self.talentsTF:make(function(arg_33_0, arg_33_1, arg_33_2)
		if arg_33_0 == UIItemList.EventUpdate then
			local var_33_0 = var_31_0[arg_33_1 + 1]

			setScrollText(findTF(arg_33_2, "name_mask/name"), var_31_0[arg_33_1 + 1].name)
			setText(arg_33_2:Find("Text"), var_33_0.value .. (var_33_0.type == CommanderConst.TALENT_ADDITION_RATIO and "%" or ""))
			setImageAlpha(arg_33_2:Find("bg"), arg_33_1 % 2)
		end
	end)
	self.talentsTF:align(#var_31_0)
	setActive(self.talentsArr, #var_31_0 > 4)
end

function LevelCMDFormationView:updateSkillTF(arg_34_1, arg_34_2)
	setActive(arg_34_2, arg_34_1)

	if arg_34_1 then
		local var_34_0 = arg_34_1:getSkills()[1]

		GetImageSpriteFromAtlasAsync("CommanderSkillIcon/" .. var_34_0:getConfig("icon"), "", arg_34_2:Find("icon"))
		setText(arg_34_2:Find("level"), "Lv." .. var_34_0:getLevel())
		onButton(self, arg_34_2, function()
			self.callback({
				type = LevelUIConst.COMMANDER_OP_SHOW_SKILL,
				skill = var_34_0
			})
		end, SFX_PANEL)
	else
		removeOnButton(arg_34_2)
	end
end

function LevelCMDFormationView:updateCommander(arg_36_1, arg_36_2, arg_36_3, arg_36_4)
	local var_36_0 = arg_36_1:Find("add")
	local var_36_1 = arg_36_1:Find("info")

	if arg_36_3 then
		GetImageSpriteFromAtlasAsync("CommanderHrz/" .. arg_36_3:getPainting(), "", (arg_36_1:Find("info/mask/icon")))

		local var_36_2 = arg_36_1:Find("info/name")

		if var_36_2 then
			setText(var_36_2, arg_36_3:getName())
		end

		setImageSprite(arg_36_1:Find("info/frame"), GetSpriteFromAtlas("weaponframes", "commander_" .. Commander.rarity2Frame(arg_36_3:getRarity())))
	end

	if arg_36_4 then
		onButton(self, var_36_1, function()
			self.callback({
				type = LevelUIConst.COMMANDER_OP_ADD,
				pos = arg_36_2
			})
		end, SFX_PANEL)
		onButton(self, var_36_0, function()
			self.callback({
				type = LevelUIConst.COMMANDER_OP_ADD,
				pos = arg_36_2
			})
		end, SFX_PANEL)
	end

	setActive(var_36_0, not arg_36_3)
	setActive(var_36_1, arg_36_3)
end

function LevelCMDFormationView:OpenRecordPanel()
	setActive(self.descFrameTF, false)
	setActive(self.recordPanel, true)
end

function LevelCMDFormationView:CloseRecordPanel()
	setActive(self.descFrameTF, true)
	setActive(self.recordPanel, false)
end

return LevelCMDFormationView
