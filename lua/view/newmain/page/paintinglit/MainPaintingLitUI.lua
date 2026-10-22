local MainPaintingLitUI = class("MainPaintingLitUI")

function MainPaintingLitUI:Ctor(arg_1_1, arg_1_2)
	self._parent = arg_1_1
	self._event = arg_1_2
	self._partBtnMaxNum = 3
end

function MainPaintingLitUI:SetShip(arg_2_1)
	self._ship = arg_2_1
	self._paintingName = arg_2_1:getPainting()
	self._shipId = arg_2_1.id
	self._skinId = arg_2_1:getSkinId()
	self._uiName = nil

	local var_2_0 = SpinePaintingConst.painting_lit_data[self._paintingName] and SpinePaintingConst.painting_lit_data[self._paintingName].lit_ui

	self._uiName = var_2_0 and var_2_0 ~= "" and var_2_0 or "mainpaintinglitui"
	self._partNum = SpinePaintingConst.painting_lit_data[self._paintingName] and SpinePaintingConst.painting_lit_data[self._paintingName].part_num

	if not self._partNum or self._partNum == "" then
		self._partNum = {}
	end

	self:loadLitUI()
end

function MainPaintingLitUI:loadLitUI()
	if self._loading then
		return
	end

	if self._litUI then
		return
	end

	self._loading = true

	PoolMgr.GetInstance():GetUI(self._uiName, true, function(arg_4_0)
		if self._isDispose then
			PoolMgr.GetInstance():ReturnUI(self._uiName, arg_4_0)

			return
		end

		setParent(tf(arg_4_0), self._parent)
		self:initLitUI(tf(arg_4_0))

		self._loading = false

		if self._flushOnLoaded then
			self:Flush()
			self:Update()

			self._flushOnLoaded = false
		end

		self:SetVisible(false)
	end)
end

function MainPaintingLitUI:initLitUI(arg_5_1)
	self._tf = arg_5_1
	self._litUI = findTF(arg_5_1, "ad")
	self._partBtnsTf = findTF(self._litUI, "part_btns")
	self._btnResetTf = findTF(self._litUI, "btn_reset")
	self._btnRemindTf = findTF(self._litUI, "btn_remind")
	self._sliderTf = findTF(self._litUI, "slider")
	self._sliderShowTf = findTF(self._litUI, "slider_show")
	self._fillMask = findTF(self._litUI, "slider_show/mask")

	if self._fillMask then
		self._fillImg = GetComponent(self._fillMask, typeof(Image))
	end

	self._fillMaskR = findTF(self._litUI, "slider_show/mask_r")

	if self._fillMaskR then
		self._fillImageR = GetComponent(self._fillMaskR, typeof(Image))
	end

	self._fillBarAnimator = GetComponent(findTF(self._litUI, "slider_show/bar"), typeof(Animator))
	self._fillBarAnimatorName = self._fillBarAnimator.runtimeAnimatorController.animationClips[0].name
	self._slider = findTF(self._litUI, "slider")

	setSlider(self._slider, 0, 1, SpinePaintingConst.painting_lit_value)
	onSlider(self._event, findTF(self._litUI, "slider"), function(arg_6_0)
		self:onSliderValueUpdate(arg_6_0)
	end)
	onButton(self._event, findTF(self._litUI, "btn_reset"), function()
		self:ClickResetBtn()
	end)

	for iter_5_0 = 1, self._partBtnMaxNum do
		local var_5_0 = iter_5_0

		if iter_5_0 <= #self._partNum then
			setActive(findTF(self._litUI, "part_btns/" .. iter_5_0), true)
			onButton(self._event, findTF(self._litUI, "part_btns/" .. iter_5_0), function()
				if var_5_0 <= #self._partNum then
					SpinePaintingConst.painting_lit_value = self._partNum[var_5_0]

					SpinePaintingDrag.SetPaintingLite(self._paintingName, self._shipId, SpinePaintingConst.painting_lit_value)

					self._selectPart = var_5_0

					self:Update()
				end
			end)
		else
			setActive(findTF(self._litUI, "part_btns/" .. iter_5_0), false)
		end
	end
end

function MainPaintingLitUI:ClickResetBtn()
	if self._partNum and #self._partNum > 0 then
		triggerButton(findTF(self._litUI, "part_btns/" .. 1))
	else
		SpinePaintingConst.painting_lit_value = 0.5
		self._selectPart = 0

		SpinePaintingDrag.SetPaintingLite(self._paintingName, self._shipId, SpinePaintingConst.painting_lit_value)
		setSlider(self._slider, 0, 1, SpinePaintingConst.painting_lit_value)
		self:Update()
	end
end

function MainPaintingLitUI:onSliderValueUpdate(arg_10_1)
	LeanTween.cancel(go(self._slider))

	self._selectPart = 0

	LeanTween.value(go(self._slider), SpinePaintingConst.painting_lit_value, arg_10_1, 0.3):setOnUpdate(System.Action_float(function(arg_11_0)
		SpinePaintingConst.painting_lit_value = arg_11_0

		SpinePaintingDrag.SetPaintingLite(self._paintingName, self._shipId, arg_11_0)
		self:Update()
	end))
end

function MainPaintingLitUI:Flush()
	if self._litUI then
		self._selectPart = 0
	else
		self._flushOnLoaded = true
	end
end

function MainPaintingLitUI:SetVisible(arg_13_1)
	if not self._tf then
		return
	end

	setActive(self._tf, arg_13_1)
	LeanTween.cancel(go(self._slider))

	if arg_13_1 then
		self:Update()
	end
end

function MainPaintingLitUI:Update()
	if self._litUI then
		self:UpdateLit()
	end
end

function MainPaintingLitUI:UpdateLit()
	self:updateFillAmountBar()
	self:updateFillImage()
	self:updateFillImageR()
	self:updateSelectPartBtn()
	self:updateUIPosition()
end

function MainPaintingLitUI:updateSelectPartBtn()
	for iter_16_0 = 1, #self._partNum do
		setActive(findTF(self._litUI, "part_btns/" .. iter_16_0 .. "/text_on"), self._selectPart == iter_16_0)
		setActive(findTF(self._litUI, "part_btns/" .. iter_16_0 .. "/text_off"), self._selectPart ~= iter_16_0)
		setActive(findTF(self._litUI, "part_btns/" .. iter_16_0 .. "/bg/on"), self._selectPart == iter_16_0)
	end
end

function MainPaintingLitUI:updateUIPosition()
	self._litUI.anchoredPosition = self._parent:InverseTransformPoint((GameObject.Find("UICamera"):GetComponent(typeof(Camera)):ScreenToWorldPoint(getProxy(SettingsProxy):GetMainSceneThemeStyle() == NewMainScene.THEME_MELLOW and Vector2(Screen.width / 2, Screen.height / 2) or Vector2(Screen.width / 2 - 700, Screen.height / 2))))
end

function MainPaintingLitUI:updateFillAmountBar()
	self._fillBarAnimator:Play(self._fillBarAnimatorName, -1, math.clamp(SpinePaintingConst.painting_lit_value, 0, 1))
end

function MainPaintingLitUI:updateFillImage()
	if self._fillImg then
		self._fillImg.fillAmount = math.clamp(SpinePaintingConst.painting_lit_value, 0, 1)
	end
end

function MainPaintingLitUI:updateFillImageR()
	if self._fillImageR then
		self._fillImageR.fillAmount = math.clamp(1 - SpinePaintingConst.painting_lit_value, 0, 1)
	end
end

function MainPaintingLitUI:GetSkinId()
	return self._skinId
end

function MainPaintingLitUI:Dispose()
	if self._slider and LeanTween.isTweening(self._slider) then
		LeanTween.cancel(go(self._slider))
	end

	if self._litUI then
		PoolMgr.GetInstance():ReturnUI(self._uiName, self._tf)

		self._litUI = nil
		self._uiName = nil
	end

	self._ship = nil
	self._isDispose = true
end

return MainPaintingLitUI
