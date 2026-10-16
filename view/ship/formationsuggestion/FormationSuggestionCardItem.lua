local FormationSuggestionCardItem = class("FormationSuggestionCardItem", import("view.base.BasePanel"))

function FormationSuggestionCardItem:Ctor(arg_1_1, arg_1_2)
	self._go = arg_1_1.gameObject

	FormationSuggestionCardItem.super.Ctor(self, self._go)

	self._parentClass = arg_1_2

	self:attach(arg_1_2)
	self:Init()
end

function FormationSuggestionCardItem:Init()
	onButton(self, self.uiBtn, function()
		if self.id == nil or type(self.id) == "string" or pg.chapter_suggestion_char[self.id] == nil then
			return
		end

		self:emit(FormationSuggestionScene.OPEN_SHIP_INFO, self.id)
	end, SFX_PANEL)

	self.shipView = FormationSuggestionShipItem.New(tf(self.uiContentGo), self)
end

function FormationSuggestionCardItem:didEnter()
	return
end

function FormationSuggestionCardItem:SetData(arg_5_1, arg_5_2)
	self.id = arg_5_1

	if arg_5_1 == nil then
		self:ShowLock(true)

		return
	end

	self:ShowLock(false)

	if arg_5_1 == 0 then
		self:ShowEmpty()

		return
	end

	if type(arg_5_1) == "string" then
		self:ShowBundle()

		return
	end

	if pg.chapter_suggestion_char[arg_5_1] == nil then
		self:ShowAnyType()

		return
	end

	self:ShowShip(arg_5_2 == 1)
end

function FormationSuggestionCardItem:ShowLock(arg_6_1)
	setActive(self.uiLockGo, arg_6_1)
	setActive(self.uiUnLockGo, not arg_6_1)
end

function FormationSuggestionCardItem:ShowEmpty()
	setActive(self.uiAnyGo, false)
	setActive(self.uiEmptyGo, true)
	setActive(self.uiContentGo, false)
end

function FormationSuggestionCardItem:ShowBundle()
	setActive(self.uiAnyGo, true)
	setActive(self.uiEmptyGo, true)
	setActive(self.uiContentGo, false)
	setImageSprite(self.uiAnyTypeImage, GetSpriteFromAtlas("shiptype", shipType2print(ShipType.BundleList[self.id][1])))

	local var_8_0 = ""

	for iter_8_0, iter_8_1 in ipairs(ShipType.BundleList[self.id]) do
		if iter_8_0 > 1 then
			var_8_0 = var_8_0 .. "/"
		end

		var_8_0 = var_8_0 .. pg.ship_data_by_type[iter_8_1].type_name
	end

	setScrollText(self.uiAnyText, i18n("formation_suggestion_any_type_ship", var_8_0))
end

function FormationSuggestionCardItem:ShowAnyType()
	setActive(self.uiAnyGo, true)
	setActive(self.uiEmptyGo, true)
	setActive(self.uiContentGo, false)
	setImageSprite(self.uiAnyTypeImage, GetSpriteFromAtlas("shiptype", shipType2print(self.id)))
	setScrollText(self.uiAnyText, i18n("formation_suggestion_any_type_ship", pg.ship_data_by_type[self.id].type_name))
end

function FormationSuggestionCardItem:ShowShip(arg_10_1)
	setActive(self.uiAnyGo, false)
	setActive(self.uiEmptyGo, false)
	setActive(self.uiContentGo, true)
	self.shipView:SetData(self.id, arg_10_1)
end

function FormationSuggestionCardItem:willExit()
	self.shipView:willExit()

	self.shipView = nil

	self:detach()
end

return FormationSuggestionCardItem
