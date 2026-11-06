local LoveLetterGiftLevelDisplayLayer = class("LoveLetterGiftLevelDisplayLayer", import("view.base.BaseUI"))

function LoveLetterGiftLevelDisplayLayer:getUIName()
	return "LoveLetterLevelDisplayUI"
end

LoveLetterGiftLevelDisplayLayer.optionsPath = {}

function LoveLetterGiftLevelDisplayLayer:init()
	setText(self.textBg, i18n("word_click_to_close"))
	setText(self.rtLevelUpPanel:Find("adapt/range/content/Text"), i18n("loveactivity_ui_13"))
	onButton(self, self.rtBg, function()
		self:closeView()
	end, SFX_CANCEL)
	self:BlurPanel(self._tf)
end

function LoveLetterGiftLevelDisplayLayer:SetLoveLetter(arg_4_1)
	self.ll = getProxy(LoveLetterProxy):GetGroupData(arg_4_1)
end

function LoveLetterGiftLevelDisplayLayer:didEnter()
	self:UpdateDisplay()
end

function LoveLetterGiftLevelDisplayLayer:UpdateDisplay()
	self:UpdatePainting()
	self:UpdateMedalSlider()
	self:UpdateLoveLetterMedal()

	if self.contextData.isLevelUp and self.ll:GetDisplayLevel() <= #pg.lover_letter_content.get_id_list_by_ship_group[self.ll.groupId] then
		self:UpdateLevelUpPanel()
		setActive(self.rtLevelUpPanel, true)
	else
		setActive(self.rtLevelUpPanel, false)
	end

	self.contextData.isLevelUp = nil
end

function LoveLetterGiftLevelDisplayLayer:UpdatePainting()
	local var_7_0 = self.ll:GetPainting()

	if self.paint == var_7_0 then
		return
	end

	if self.paint then
		retPaintingPrefab(self.rtPainting, self.paint)

		self.paint = nil
	end

	self.paint = var_7_0

	setPaintingPrefabAsync(self.rtPainting, self.paint, "biandui")
end

function LoveLetterGiftLevelDisplayLayer:UpdateLoveLetterMedal()
	local var_8_0 = self.ll:GetPrefabName()

	if self.medalPath == var_8_0 then
		return
	end

	self.medalPath = var_8_0

	setLoveLetterMedal(self.rtNow:Find("medal"), self.ll)
end

function LoveLetterGiftLevelDisplayLayer:UpdateMedalSlider()
	local var_9_0, var_9_1 = self.ll:GetDisplayExp()

	if var_9_1 == 0 then
		setSlider(self.rtNow:Find("Slider"), 0, 1, 1)
	else
		setSlider(self.rtNow:Find("Slider"), 0, var_9_1, var_9_0)
	end

	setText(self.rtNow:Find("Text"), string.format(setColorStr("%d", "#CF90A8") .. "/%d", var_9_0, var_9_1))
end

function LoveLetterGiftLevelDisplayLayer:UpdateLevelUpPanel()
	updateDrop(self.rtIconTpl, Drop.Create(pg.lover_nation[self.ll:GetNation()].letter_icon))
	onButton(self, self.rtIconTpl, function()
		self:emit(LoveLetterGiftLevelDisplayMediator.ON_GO_COLLECTION)
	end, SFX_PANEL)
end

function LoveLetterGiftLevelDisplayLayer:willExit()
	self:UnOverlayPanel(self._tf)

	if self.paint then
		retPaintingPrefab(self.rtPainting, self.paint)

		self.paint = nil
	end

	if self.medalPath then
		returnLoveLetterMedal(self.rtNow:Find("medal"):GetChild(0))

		self.medalPath = nil
	end
end

return LoveLetterGiftLevelDisplayLayer
