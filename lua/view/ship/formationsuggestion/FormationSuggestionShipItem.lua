local FormationSuggestionShipItem = class("FormationSuggestionShipItem", import("view.base.BasePanel"))

function FormationSuggestionShipItem:Ctor(arg_1_1, arg_1_2)
	self._go = arg_1_1.gameObject

	FormationSuggestionShipItem.super.Ctor(self, self._go)

	self._parentClass = arg_1_2

	self:attach(arg_1_2)
	self:Init()
end

function FormationSuggestionShipItem:Init()
	self.paintingDefaultAngle = self.uiPaintingTf.localEulerAngles
	self.UIlist = UIItemList.New(self.uiStartsTf, self.uiStartItem)

	setText(self.uiUnownedText, i18n("word_not_get"))
end

function FormationSuggestionShipItem:didEnter()
	return
end

function FormationSuggestionShipItem:SetData(arg_4_1, arg_4_2)
	self.id = arg_4_1

	if self.shipVO then
		retPaintingPrefab(self.uiPaintingTf, self.shipVO:getPainting())
	end

	local var_4_0 = pg.chapter_suggestion_char[self.id]
	local var_4_1 = Ship.New({
		id = self.id,
		configId = pg.chapter_suggestion_char[self.id].char_id,
		level = pg.chapter_suggestion_char[self.id].char_lv
	})

	if pg.chapter_suggestion_char[self.id].remoulded == 1 then
		var_4_1.remoulded = true

		var_4_1:updateSkinId(var_4_1:getRemouldSkinId(), 0)
	end

	setScrollText(self.uiNameText, var_4_1:GetColorName())
	setText(self.uiLevelText, string.format("Lv.%s", var_4_1.level))

	local var_4_2 = var_4_0.star

	self.UIlist:make(function(arg_5_0, arg_5_1, arg_5_2)
		if arg_5_0 == UIItemList.EventUpdate then
			setActive(arg_5_2:Find("star"), arg_5_1 < var_4_2)
		end
	end)
	self.UIlist:align((var_4_1:getMaxStar()))
	setPaintingPrefabAsync(self.uiPaintingTf, var_4_1:getPainting(), "biandui", nil, {
		skinID = var_4_1:getSkinId(),
		rotateZ = self.paintingDefaultAngle.z
	})

	local var_4_3 = var_4_1:rarity2bgPrint()

	GetImageSpriteFromAtlasAsync("bg/star_level_card_" .. var_4_3, "", self.uiRaryImage)

	local var_4_4, var_4_5 = var_4_1:GetFrameAndEffect(true)

	setRectShipCardFrame(self.uiFrameImage, var_4_3, var_4_4)
	setFrameEffect(self.uiEffectTf, var_4_5)
	setProposeMarkIcon(self.uiProposeTf, var_4_1)
	setImageSprite(self.uiTypeImage, GetSpriteFromAtlas("shiptype", shipType2print((var_4_1:getShipType()))))

	self.shipVO = var_4_1

	setActive(self.uiFlagGo, arg_4_2)

	local var_4_6 = getProxy(BayProxy):findShipsByGroup(pg.ship_data_template[var_4_0.char_id].group_type)

	for iter_4_0 = #var_4_6, 1, -1 do
		if var_4_0.remoulded == 1 and not var_4_6[iter_4_0]:isRemoulded() then
			table.remove(var_4_6, iter_4_0)
		end
	end

	setActive(self.uiUnownedGo, not (#var_4_6 > 0))
end

function FormationSuggestionShipItem:willExit()
	self:detach()

	if self.shipVO then
		retPaintingPrefab(self.uiPaintingTf, self.shipVO:getPainting())
	end
end

return FormationSuggestionShipItem
