local FormationSuggestionShipInfoScene = class("FormationSuggestionShipInfoScene", import("view.base.BaseUI"))

function FormationSuggestionShipInfoScene:getUIName()
	return "FormationSuggestionShipInfoUI"
end

function FormationSuggestionShipInfoScene:init()
	setText(self.uiTitleText, i18n("formation_suggestion_info_title"))
	setText(self.uiLockText, i18n("formation_suggestion_info_not_get"))
	setText(self.uiUnLockText, i18n("formation_suggestion_info_got"))
	setText(self.uiGoDockText, i18n("formation_suggestion_info_go_dock"))
	setText(self.uiEquipTitleText1, i18n("formation_suggestion_info_equip_recommend"))
	setText(self.uiEquipTitleText2, i18n("formation_suggestion_info_equip_transitional"))
	setText(self.uiEquipTipText, i18n("formation_suggestion_info_equip_tip"))
	setText(self.uiBackText, i18n("formation_suggestion_info_back"))

	self.shipView = FormationSuggestionShipItem.New(tf(self.uiShipItem), self)
	self.equipView1 = FormationSuggestionShipEquipPanel.New(tf(self.uiEquipPanel1), self)
	self.equipView2 = FormationSuggestionShipEquipPanel.New(tf(self.uiEquipPanel2), self, true)

	onButton(self, self.uiGoDockBtn, function()
		self:emit(BaseUI.ON_GO_SCENE, SCENE.DOCKYARD, {
			mode = DockyardScene.MODE_OVERVIEW
		})
	end, SFX_PANEL)
	onButton(self, self.uiBackBtn, function()
		self:closeView()
	end, SOUND_BACK)

	self.skillList = UIItemList.New(self.uiSkillParent, self.uiSkillItem)
	self.obtainList = UIItemList.New(self.uiObtainParent, self.uiObtainItem)
end

function FormationSuggestionShipInfoScene:didEnter()
	self:OverlayPanel(self._tf, {
		pbList = {
			self.uiBlurTf
		}
	})

	self.id = self.contextData.id

	local var_5_0 = pg.chapter_suggestion_char[self.id]

	self.shipView:SetData(self.id)
	self.equipView1:SetData(var_5_0.wepaon)
	self.equipView2:SetData(var_5_0.wepaon_2)

	local var_5_1 = Ship.New({
		id = self.id,
		configId = var_5_0.char_id,
		level = var_5_0.char_lv
	})

	setText(self.uiNameText, var_5_1:GetColorName())

	local var_5_2 = pg.ship_data_template[var_5_0.char_id].group_type
	local var_5_3 = getProxy(BayProxy):findShipsByGroup(pg.ship_data_template[var_5_0.char_id].group_type)

	for iter_5_0 = #var_5_3, 1, -1 do
		if var_5_0.remoulded == 1 and not var_5_3[iter_5_0]:isRemoulded() then
			table.remove(var_5_3, iter_5_0)
		end
	end

	local var_5_4 = #var_5_3 > 0

	setActive(self.uiUnLockGo, #var_5_3 > 0)
	setActive(self.uiLockGo, not var_5_4)
	setActive(self.uiLvGo, var_5_4)

	local var_5_5 = 1

	for iter_5_1, iter_5_2 in ipairs(var_5_3) do
		var_5_5 = var_5_5 < iter_5_2.level and iter_5_2.level or var_5_5
	end

	setText(self.uiLevelText, i18n("formation_suggestion_info_level", var_5_5))
	self.skillList:make(function(arg_6_0, arg_6_1, arg_6_2)
		if arg_6_0 == UIItemList.EventUpdate then
			local var_6_0 = var_5_0.skill_lv[arg_6_1 + 1][1]
			local var_6_1 = findTF(arg_6_2, "level")

			if var_5_4 then
				local var_6_2 = var_5_1:isBluePrintShip()

				var_6_2 = var_6_2 and getProxy(TechnologyProxy):getBluePrintVOByGroupID(var_5_2)

				local var_6_3 = 1

				if var_6_2 then
					for iter_6_0, iter_6_1 in ipairs(var_5_3) do
						local var_6_4 = iter_6_1:fateSkillChange(var_6_0)

						if var_6_4 ~= var_6_0 then
							var_6_0 = var_6_4

							break
						end
					end
				end

				for iter_6_2, iter_6_3 in ipairs(var_5_3) do
					if var_5_0.remoulded == 0 then
						local var_6_5 = pg.ship_data_template[iter_6_3.configId].buff_list_display[table.keyof(pg.ship_data_template[var_5_1.configId].buff_list_display, var_6_0)]

						if iter_6_3.skills[var_6_5] then
							var_6_3 = var_6_3 < iter_6_3.skills[var_6_5].level and iter_6_3.skills[var_6_5].level or var_6_3
						end
					end

					if iter_6_3.skills[var_6_0] then
						var_6_3 = var_6_3 < iter_6_3.skills[var_6_0].level and iter_6_3.skills[var_6_0].level or var_6_3
					end
				end

				if var_6_3 >= var_5_0.skill_lv[arg_6_1 + 1][2] then
					setText(var_6_1, i18n("formation_suggestion_info_level_recommend", string.format("<color=#ffffff>Lv.%s</color>/%s", var_6_3, var_5_0.skill_lv[arg_6_1 + 1][2])))
				else
					setText(var_6_1, i18n("formation_suggestion_info_level_recommend", string.format("<color=#d53333>Lv.%s</color>/%s", var_6_3, var_5_0.skill_lv[arg_6_1 + 1][2])))
				end
			else
				setText(var_6_1, i18n("formation_suggestion_info_level_recommend", string.format("Lv.%s", var_5_0.skill_lv[arg_6_1 + 1][2])))
			end

			local var_6_6 = getSkillConfig(var_6_0)

			LoadImageSpriteAsync("skillicon/" .. var_6_6.icon, findTF(arg_6_2, "icon"))
			setScrollText(findTF(arg_6_2, "mask/name"), getSkillName(var_6_6.id))
		end
	end)
	self.skillList:align(#var_5_0.skill_lv)
	self.obtainList:make(function(arg_7_0, arg_7_1, arg_7_2)
		if arg_7_0 == UIItemList.EventUpdate then
			local var_7_0 = var_5_0.source[arg_7_1 + 1]

			setScrollText(findTF(arg_7_2, "text/text"), i18n("formation_suggestion_info_obtain", var_5_0.source[arg_7_1 + 1][2]))
			onButton(self, findTF(arg_7_2, "goBtn"), function()
				self:emit(FormationSuggestionShipInfoMediator.JUMP_TO_SCENE, var_7_0[1])
			end)
		end
	end)
	self.obtainList:align(#var_5_0.source)
end

function FormationSuggestionShipInfoScene:willExit()
	self:UnOverlayPanel(self._tf)
	self.shipView:willExit()

	self.shipView = nil

	self.skillList:Dispose()

	self.skillList = nil

	self.obtainList:Dispose()

	self.obtainList = nil

	self.equipView1:willExit()

	self.equipView1 = nil

	self.equipView2:willExit()

	self.equipView2 = nil

	pg.m02:sendNotification(GAME.FORMATION_SUGGESTION_EXIT_SHIP_INFO)
end

return FormationSuggestionShipInfoScene
