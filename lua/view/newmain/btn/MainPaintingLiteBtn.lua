local MainPaintingLiteBtn = class("MainPaintingLiteBtn", import(".MainBaseBtn"))

function MainPaintingLiteBtn:Ctor(arg_1_1, arg_1_2)
	MainPaintingLiteBtn.super.Ctor(self, arg_1_1, arg_1_2)
	setActive(self._tf, false)
	pg.DelegateInfo.New(self)
	self:bind(NewMainScene.ENTER_SILENT_VIEW, function()
		self:changeLitOn(false)
	end)
	onButton(self, findTF(self._tf, "btn"), function()
		self:OnClickBtn()
	end)

	function SpinePaintingConst.painting_lit_action_callback()
		if self._litUI then
			self._litUI:SetVisible(self._liteOn and not SpinePaintingConst.spine_painting_action)
		end
	end

	self:changeLitOn(false)
end

function MainPaintingLiteBtn:OnClick()
	return
end

function MainPaintingLiteBtn:OnClickBtn()
	self:changeLitOn(not self._liteOn)
end

function MainPaintingLiteBtn:changeLitOn(arg_7_1)
	self._liteOn = arg_7_1
	SpinePaintingConst.painting_lit_opening = self._liteOn

	if self._litUI then
		self._litUI:SetVisible(self._liteOn and not SpinePaintingConst.spine_painting_action)
	end

	self:updateUI()
end

function MainPaintingLiteBtn:Flush(arg_8_1)
	self:FlushUI()
end

function MainPaintingLiteBtn:FlushUI()
	local var_9_0 = getProxy(PlayerProxy):getRawData():GetFlagShip()

	self._paintingName = var_9_0:getPainting()
	self._shipId = var_9_0.id

	local var_9_1 = getProxy(SettingsProxy):getCharacterSetting(var_9_0.id, SHIP_FLAG_SP)

	SpinePaintingConst.painting_lit_value = SpinePaintingDrag.GetPaintingLite(self._paintingName, self._shipId)

	local var_9_2

	if SpinePaintingConst.painting_lit_data[self._paintingName] then
		var_9_2 = SpinePaintingConst.painting_lit_data[self._paintingName].classes or "MainPaintingLitUI"
	end

	if var_9_0:isLightSkin() and var_9_1 then
		if self._litUI and self._litUI:GetSkinId() ~= var_9_0:getSkinId() then
			self._litUI:Dispose()

			self._litUI = nil
		end

		if not self._litUI then
			self._litUI = ((var_9_2 and _G[var_9_2] or nil) and _G[var_9_2]).New(self._tf, self)

			self._litUI:SetShip(var_9_0)
		end

		setActive(self._tf, true)
		self:changeLitOn(false)
	else
		setActive(self._tf, false)
	end

	if self._litUI then
		self._litUI:Flush()
	end

	self:updateUI()
end

function MainPaintingLiteBtn:updateUI()
	setActive(findTF(self._tf, "btn/on"), self._liteOn)
	setActive(findTF(self._tf, "btn/off"), not self._liteOn)

	if self._litUI then
		self._litUI:Update()
	end
end

function MainPaintingLiteBtn:IsFixed()
	return true
end

function MainPaintingLiteBtn:Dispose()
	pg.DelegateInfo.Dispose(self)
	MainPaintingLiteBtn.super.Dispose(self)
end

return MainPaintingLiteBtn
