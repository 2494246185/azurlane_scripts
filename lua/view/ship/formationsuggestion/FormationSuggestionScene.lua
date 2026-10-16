local FormationSuggestionScene = class("FormationSuggestionScene", import("view.base.BaseUI"))

FormationSuggestionScene.OPEN_SHIP_INFO = "FormationSuggestionScene::OPEN_SHIP_INFO"
FormationSuggestionScene.SUGGESTION_TYPE = {
	NORMAL = 1,
	SUBMARINE = 3,
	PRO = 2
}

function FormationSuggestionScene:getUIName()
	return "FormationSuggestionUI"
end

function FormationSuggestionScene:init()
	onButton(self, self.uiBackBtn, function()
		if not isActive(self.uiTeamGo) then
			self:emit(FormationSuggestionMediator.ON_CLOSE_SHIP_INFO)
		else
			self:closeView()
		end
	end, SOUND_BACK)
	onButton(self, self.uiPrevBtn, function()
		if self.selectedIndex > 1 then
			self.uiList:SwitchToPage(self.selectedIndex - 1)

			for iter_4_0, iter_4_1 in pairs(self.uiList:GetItemList()) do
				iter_4_1:OnPlayAnimation()
			end
		end
	end, SFX_PANEL)
	onButton(self, self.uiNextBtn, function()
		if self.selectedIndex < #self.mapIDList then
			self.uiList:SwitchToPage(self.selectedIndex + 1)

			for iter_5_0, iter_5_1 in pairs(self.uiList:GetItemList()) do
				iter_5_1:OnPlayAnimation()
			end
		end
	end, SFX_PANEL)
	onToggle(self, self.uiToggle1, function(arg_6_0)
		if arg_6_0 and self.isInitOver then
			self:OnSwitchToggle(FormationSuggestionScene.SUGGESTION_TYPE.NORMAL)
			self:emit(FormationSuggestionMediator.ON_CLOSE_SHIP_INFO)
		end
	end, SFX_PANEL)
	onToggle(self, self.uiToggle2, function(arg_7_0)
		if arg_7_0 and self.isInitOver then
			self:OnSwitchToggle(FormationSuggestionScene.SUGGESTION_TYPE.PRO)
			self:emit(FormationSuggestionMediator.ON_CLOSE_SHIP_INFO)
		end
	end, SFX_PANEL)
	onToggle(self, self.uiToggle3, function(arg_8_0)
		if arg_8_0 and self.isInitOver then
			self:OnSwitchToggle(FormationSuggestionScene.SUGGESTION_TYPE.SUBMARINE)
			self:emit(FormationSuggestionMediator.ON_CLOSE_SHIP_INFO)
		end
	end, SFX_PANEL)
	onToggle(self, self.uiNormalToggle, function(arg_9_0)
		if arg_9_0 then
			self:OnSwitchHardMod(not arg_9_0)
		end
	end)
	onToggle(self, self.uiHardToggle, function(arg_10_0)
		if arg_10_0 then
			self:OnSwitchHardMod(arg_10_0)
		end
	end)

	self.uiList = LuaList.New(self, handler(self, self.IndexItem), self.uiListTf, FormationSuggestionTeamItem)

	self.uiList:SetPageChangeHandler(handler(self, self.OnPageChanged))
	self.uiList:SetItemRecycleHandler(handler(self, self.OnScrollHideItem))
	setText(self.uiTipsText, i18n("formation_suggestion_tip"))
	setText(self.uiFleetTitleText, i18n("formation_suggestion_tip_title"))
	setText(self.uiNormalText1, i18n("word_normal_junhe"))
	setText(self.uiNormalText2, i18n("word_normal_junhe"))
	setText(self.uiHardText1, i18n("word_hard"))
	setText(self.uiHardText1, i18n("word_hard"))
	setText(self.uiPrevText, i18n("formation_suggestion_prev_chapter"))
	setText(self.uiNextText, i18n("formation_suggestion_next_chapter"))
end

function FormationSuggestionScene:didEnter()
	self:OverlayPanel(tf(self.uiTeamGo), {
		pbList = {
			self.uiBlurTf
		}
	})

	self.selectedType = self.contextData.selectedType or FormationSuggestionScene.SUGGESTION_TYPE.NORMAL

	local var_11_0 = self.contextData.mapID or LevelTools.GetMaxFormationSuggestionID()

	self.mapIDList = LevelTools.GetSuggestionMapIDList(var_11_0)
	self.selectedIndex = self:GetMapIndex(self.mapIDList, var_11_0)
	self.contextData.mapID = self.mapIDList[self.selectedIndex]

	if self.selectedType == FormationSuggestionScene.SUGGESTION_TYPE.NORMAL then
		triggerToggle(self.uiToggle1, true)
	elseif self.selectedType == FormationSuggestionScene.SUGGESTION_TYPE.PRO then
		triggerToggle(self.uiToggle2, true)
	elseif self.selectedType == FormationSuggestionScene.SUGGESTION_TYPE.SUBMARINE then
		triggerToggle(self.uiToggle3, true)
	end

	self.eventIDList = {
		self:bind(FormationSuggestionScene.OPEN_SHIP_INFO, handler(self, self.OnClickShipCard))
	}

	setActive(self.uiDifficultyGo, LevelTools.HasUnlockSuggestionHardMap())

	self.contextData.mapID = pg.expedition_data_by_map[self.contextData.mapID].bind_map

	if pg.expedition_data_by_map[self.contextData.mapID].type == 1 then
		triggerToggle(self.uiNormalToggle, true)
	else
		triggerToggle(self.uiHardToggle, true)
	end

	self.isInitOver = true
end

function FormationSuggestionScene:RefreshText()
	local var_12_0 = pg.chapter_suggestion_formation[pg.chapter_suggestion_formation.get_id_list_by_chapter[self.mapIDList[self.selectedIndex]][self.selectedType]]

	setText(self.uiTitleText, pg.chapter_suggestion_formation[pg.chapter_suggestion_formation.get_id_list_by_chapter[self.mapIDList[self.selectedIndex]][self.selectedType]].page_title)
	setScrollText(self.uiFleetTipsText, var_12_0.describe)
	setGray(self.uiPrevBtn, self.selectedIndex == 1)
	setGray(self.uiNextBtn, self.selectedIndex == #self.mapIDList)
	self:emit(FormationSuggestionTeamItem.ON_REFRESH_CARD_ITEM, var_12_0.id)
end

function FormationSuggestionScene:OnSwitchToggle(arg_13_1)
	self.selectedType = arg_13_1
	self.contextData.selectedType = arg_13_1

	self:RefreshUI()
end

function FormationSuggestionScene:OnSwitchHardMod(arg_14_1)
	if self.selectedHard == arg_14_1 then
		return
	end

	self.selectedHard = arg_14_1
	self.mapIDList = LevelTools.GetSuggestionMapIDList(pg.expedition_data_by_map[self.contextData.mapID].bind_map)
	self.selectedIndex = self:GetMapIndex(self.mapIDList, pg.expedition_data_by_map[self.contextData.mapID].bind_map)
	self.contextData.mapID = pg.expedition_data_by_map[self.contextData.mapID].bind_map

	self:RefreshText()
	self.uiList:StartScroll(#self.mapIDList, self.selectedIndex, true)
	self.uiList:Refresh()
end

function FormationSuggestionScene:RefreshUI()
	self:RefreshText()
	self.uiList:Refresh()
end

function FormationSuggestionScene:GetMapIndex(arg_16_1, arg_16_2)
	local var_16_0 = 1

	for iter_16_0 = 2, #arg_16_1 do
		if arg_16_2 < arg_16_1[iter_16_0] then
			return var_16_0
		else
			var_16_0 = iter_16_0
		end
	end

	return var_16_0
end

function FormationSuggestionScene:IndexItem(arg_17_1, arg_17_2)
	arg_17_2:SetID(pg.chapter_suggestion_formation.get_id_list_by_chapter[self.mapIDList[arg_17_1]][self.selectedType])
end

function FormationSuggestionScene:OnPageChanged(arg_18_1)
	self.selectedIndex = arg_18_1
	self.contextData.mapID = self.mapIDList[self.selectedIndex]

	self:RefreshText()
end

function FormationSuggestionScene:OnScrollHideItem(arg_19_1, arg_19_2)
	self:emit(FormationSuggestionTeamItem.ON_HIDE_CARD_ITEM, arg_19_2)
end

function FormationSuggestionScene:OnClickShipCard(arg_20_1, arg_20_2)
	self:emit(BaseUI.ON_ADD_SUBLAYER, Context.New({
		viewComponent = FormationSuggestionShipInfoScene,
		mediator = FormationSuggestionShipInfoMediator,
		data = {
			id = arg_20_2
		}
	}))
end

function FormationSuggestionScene:OnOpenShipInfo()
	setActive(self.uiTeamGo, false)
	setActive(self.uiDifficultyGo, false)
end

function FormationSuggestionScene:OnCloseShipInfo()
	setActive(self.uiTeamGo, true)
	self.uiList:StartScroll(#self.mapIDList, self.selectedIndex, true)
	setActive(self.uiDifficultyGo, (LevelTools.HasUnlockSuggestionHardMap()))
end

function FormationSuggestionScene:willExit()
	self:UnOverlayPanel(tf(self.uiTeamGo), self._tf)

	for iter_23_0, iter_23_1 in ipairs(self.eventIDList) do
		self:disconnect(iter_23_1)
	end

	self.eventIDList = nil

	self.uiList:Dispose()

	self.uiList = nil
end

return FormationSuggestionScene
