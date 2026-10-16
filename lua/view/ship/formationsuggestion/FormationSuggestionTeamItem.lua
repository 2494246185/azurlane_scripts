local FormationSuggestionTeamItem = class("FormationSuggestionTeamItem", import("view.base.BasePanel"))

FormationSuggestionTeamItem.ON_HIDE_CARD_ITEM = "FormationSuggestionTeamItem:ON_HIDE_CARD_ITEM"
FormationSuggestionTeamItem.ON_REFRESH_CARD_ITEM = "FormationSuggestionTeamItem:ON_REFRESH_CARD_ITEM"

function FormationSuggestionTeamItem:Ctor(arg_1_1, arg_1_2)
	self._go = arg_1_1.gameObject

	FormationSuggestionTeamItem.super.Ctor(self, self._go)

	self._parentClass = arg_1_2

	self:attach(arg_1_2)
	self:Init()

	self.eventIDList = {
		self:bind(FormationSuggestionTeamItem.ON_HIDE_CARD_ITEM, handler(self, self.OnHideCardItem)),
		self:bind(FormationSuggestionTeamItem.ON_REFRESH_CARD_ITEM, handler(self, self.OnRefreshCardItem))
	}
end

function FormationSuggestionTeamItem:Init()
	self.mainItemList = {}
	self.vanguardItemList = {}

	for iter_2_0 = 1, 3 do
		self.mainItemList[iter_2_0] = FormationSuggestionCardItem.New(self[string.format("uiMainShipTf%s", iter_2_0)], self)
		self.vanguardItemList[iter_2_0] = FormationSuggestionCardItem.New(self[string.format("uiVanguardShipTf%s", iter_2_0)], self)
	end

	self.animation = self._tf:GetComponent(typeof(Animation))
end

function FormationSuggestionTeamItem:SetID(arg_3_1)
	self.id = arg_3_1

	if pg.chapter_suggestion_formation[arg_3_1].type == FormationSuggestionScene.SUGGESTION_TYPE.SUBMARINE then
		setActive(self.uiVanguardTopGo, false)
		setText(self.uiMainText, i18n("pre_combat_submarine"))

		for iter_3_0, iter_3_1 in ipairs(pg.chapter_suggestion_formation[arg_3_1].teamid) do
			self.mainItemList[iter_3_0]:SetData(iter_3_1)
		end

		for iter_3_2, iter_3_3 in ipairs(self.vanguardItemList) do
			self.vanguardItemList[iter_3_2]:SetData(nil)
		end
	else
		setActive(self.uiVanguardTopGo, true)
		setText(self.uiMainText, i18n("pre_combat_main"))
		setText(self.uiVanguardText, i18n("pre_combat_vanguard"))

		for iter_3_4, iter_3_5 in ipairs(pg.chapter_suggestion_formation[arg_3_1].teamid) do
			self.mainItemList[iter_3_4]:SetData(iter_3_5, iter_3_4)
		end

		for iter_3_6, iter_3_7 in ipairs(pg.chapter_suggestion_formation[arg_3_1].teamid1) do
			self.vanguardItemList[iter_3_6]:SetData(iter_3_7)
		end
	end
end

function FormationSuggestionTeamItem:OnHideCardItem(arg_4_1, arg_4_2)
	if self._go == arg_4_2 then
		self.id = nil
	end
end

function FormationSuggestionTeamItem:OnRefreshCardItem(arg_5_1, arg_5_2)
	if self.id ~= arg_5_2 then
		self:OnPlayAnimation()
	end
end

function FormationSuggestionTeamItem:OnPlayAnimation()
	self.animation:Stop()
	self.animation:Play("anim_item_in")
end

function FormationSuggestionTeamItem:willExit()
	for iter_7_0, iter_7_1 in ipairs(self.eventIDList) do
		self:disconnect(iter_7_1)
	end

	self.eventIDList = nil

	for iter_7_2, iter_7_3 in ipairs(self.mainItemList) do
		iter_7_3:willExit()
	end

	self.mainItemList = nil

	for iter_7_4, iter_7_5 in ipairs(self.vanguardItemList) do
		iter_7_5:willExit()
	end

	self.vanguardItemList = nil

	self:detach()
end

return FormationSuggestionTeamItem
