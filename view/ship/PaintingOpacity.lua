local PaintingOpacity = class("PaintingOpacity")
local var_0_1 = 0.03333333333333333

function PaintingOpacity:Ctor(arg_1_1)
	self._go = arg_1_1

	self._go.transform:SetParent(nil, false)

	self._camera = self._go:GetComponent(typeof(UnityEngine.Camera))
	self._canvas = findTF(self._go, "Canvas"):GetComponent(typeof(UnityEngine.Canvas))
	self._canvasTF = self._canvas.gameObject.transform
	self._paintingContainerTF = findTF(self._go, "Canvas/paint")
	self._meshContent = findTF(self._paintingContainerTF, "fitter")
	self._spineContent = findTF(self._paintingContainerTF, "spinePainting")
	self._live2dContent = findTF(self._paintingContainerTF, "live2d")
	self.timer = Timer.New(function()
		self:step()
	end, var_0_1, -1)

	self.timer:Start()
	self:SetVisible(false)
end

function PaintingOpacity:step()
	if self._delayCallbackTime and self._delayCallbackTime >= 0 then
		self._delayCallbackTime = self._delayCallbackTime - Time.deltaTime

		if self._delayCallbackTime <= 0 then
			self:InvokeDelayCallback()
		end
	end
end

function PaintingOpacity:InvokeDelayCallback()
	self._delayCallback = nil
	self._delayCallbackTime = nil

	if self._delayCallback then
		self._delayCallback()
	end
end

function PaintingOpacity:ResizeRenderTexture(arg_5_1, arg_5_2)
	if self._rt and self._rt.width == arg_5_1 and self._rt.height == arg_5_2 then
		return
	end

	self:ClearRendererTexture()

	self._rt = UnityEngine.RenderTexture.New(arg_5_1, arg_5_2, 0)
	self._camera.targetTexture = self._rt

	if self._rawImage then
		self._rawImage.texture = self._rt
	end
end

function PaintingOpacity:SetPaintingContainerOffset(arg_6_1, arg_6_2, arg_6_3)
	self._meshContent.anchoredPosition = arg_6_3
	self._spineContent.anchoredPosition = arg_6_2
	self._live2dContent.anchoredPosition = arg_6_1
end

function PaintingOpacity:SetContainerOffset(arg_7_1, arg_7_2)
	self._paintingContainerTF.anchoredPosition = arg_7_1
	self._paintingContainerTF.localScale = arg_7_2
end

function PaintingOpacity:GetContainerTF()
	return self._paintingContainerTF
end

function PaintingOpacity:GetSpinePaintingContainer()
	return self._spineContent
end

function PaintingOpacity:DisablePainting()
	print("disable painting")

	if not IsNil(self._paintingTF) and not IsNil(self._paintingPreParent) then
		SetParent(self._paintingTF, self._paintingPreParent, false)
	end

	self._paintingTF = nil
	self._paintingPreParent = nil
	self._paintingContent = nil
end

function PaintingOpacity:SetPaintingAlphaTween(arg_11_1, arg_11_2, arg_11_3)
	self:InvokeDelayCallback()

	if self._isDispose then
		if arg_11_3 then
			arg_11_3()
		end

		return
	end

	print("set painting alpha tween value = " .. arg_11_1 .. " time = " .. arg_11_2)

	self._delayCallback = arg_11_3

	local var_11_0 = 0

	self:ClearAlphaTween()
	self:SetPaitningAlphaContent()
	LeanTween.value(self._go, IsNil(self._rawImage) and arg_11_1 or self._rawImage.color.a, arg_11_1, arg_11_2):setEase(LeanTweenType.linear):setOnUpdate(System.Action_float(function(arg_12_0)
		if var_11_0 > 0 then
			self:SetRawImageAlpha(arg_12_0)
		end

		var_11_0 = var_11_0 + 1
	end)):setOnComplete(System.Action(function()
		self:SetRawImageAlpha(arg_11_1)

		if arg_11_1 == 1 then
			self:RevertPaintingContent()
		end

		self:InvokeDelayCallback()
	end))
end

function PaintingOpacity:SetPaitningAlphaContent()
	if not self:GetVisible() then
		self:SetVisible(true)
	end

	if not IsNil(self._paintingTF) and not IsNil(self._paintingContent) then
		SetParent(self._paintingTF, self._paintingContent, false)
	end
end

function PaintingOpacity:RevertPaintingContent()
	print("revert content")

	if not IsNil(self._paintingTF) and not IsNil(self._paintingPreParent) then
		SetParent(self._paintingTF, self._paintingPreParent, false)
	end
end

function PaintingOpacity:SetRawImage(arg_16_1)
	self._rawImage = arg_16_1
	self._rawImage.texture = self._rt
end

function PaintingOpacity:SetRawImageAlpha(arg_17_1)
	if IsNil(self._rawImage) then
		return
	end

	local var_17_0 = self._rawImage.color

	var_17_0.a = Mathf.Clamp01(arg_17_1)
	self._rawImage.color = var_17_0
end

function PaintingOpacity:ClearAlphaTween()
	if LeanTween.isTweening(self._go) then
		LeanTween.cancel(self._go)
	end
end

function PaintingOpacity:SetMeshPaintingFillter(arg_19_1)
	local var_19_0 = GetOrAddComponent(self._meshContent, "PaintingScaler")

	var_19_0.FrameName = arg_19_1
	var_19_0.Tween = 1
end

function PaintingOpacity:SetMeshPainting(arg_20_1, arg_20_2)
	if arg_20_1 then
		self._paintingTF = arg_20_1
		self._paintingPreParent = arg_20_2
		self._paintingContent = self._meshContent

		SetParent(arg_20_1, self._meshContent, false)
	end

	self:SetRawImageAlpha(1)
end

function PaintingOpacity:SetSpinePainting(arg_21_1, arg_21_2)
	if arg_21_1 then
		self._paintingTF = arg_21_1
		self._paintingPreParent = arg_21_2
		self._paintingContent = self._spineContent

		SetParent(arg_21_1, self._spineContent, false)
	end

	self:SetRawImageAlpha(1)
end

function PaintingOpacity:SetLive2DPainting(arg_22_1, arg_22_2)
	if arg_22_1 then
		self._paintingTF = arg_22_1
		self._paintingPreParent = arg_22_2
		self._paintingContent = self._live2dContent

		SetParent(arg_22_1, self._live2dContent, false)
	end

	self:SetRawImageAlpha(1)
end

function PaintingOpacity:ClearRendererTexture()
	if not self._rt then
		return
	end

	self._camera.targetTexture = nil

	self._rt:Release()
	UnityEngine.Object.Destroy(self._rt)

	self._rt = nil
end

function PaintingOpacity:GetCanvasTF()
	return self._canvasTF
end

function PaintingOpacity:SetVisible(arg_25_1)
	if IsNil(self._go) then
		return
	end

	setActive(self._go, arg_25_1)
	self:SetRawImageAlpha(arg_25_1 and 1 or 0)
end

function PaintingOpacity:GetVisible()
	if IsNil(self._go) then
		return false
	end

	return isActive(self._go)
end

function PaintingOpacity:Dispose()
	if self._isDispose then
		return
	end

	print("dispose opacity")

	self._isDispose = true

	self:DisablePainting()
	self:InvokeDelayCallback()

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self:ClearAlphaTween()
	self:ClearRendererTexture()
	Destroy(self._go)
end

return PaintingOpacity
