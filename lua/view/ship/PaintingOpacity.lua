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
end

function PaintingOpacity:step()
	if self._delayCallbackTime and self._delayCallbackTime >= 0 then
		self._delayCallbackTime = self._delayCallbackTime - Time.deltaTime

		if self._delayCallbackTime <= 0 then
			if self._delayCallback then
				self._delayCallback = nil

				self._delayCallback()
			end

			self._delayCallbackTime = nil
		end
	end
end

function PaintingOpacity:ResizeRenderTexture(arg_4_1, arg_4_2)
	if self._rt and self._rt.width == arg_4_1 and self._rt.height == arg_4_2 then
		return
	end

	self:ClearRendererTexture()

	self._rt = UnityEngine.RenderTexture.New(arg_4_1, arg_4_2, 0)
	self._camera.targetTexture = self._rt

	if self._rawImage then
		self._rawImage.texture = self._rt
	end
end

function PaintingOpacity:SetPaintingContainerOffset(arg_5_1, arg_5_2, arg_5_3)
	self._meshContent.anchoredPosition = arg_5_3
	self._spineContent.anchoredPosition = arg_5_2
	self._live2dContent.anchoredPosition = arg_5_1
end

function PaintingOpacity:SetContainerOffset(arg_6_1, arg_6_2)
	self._paintingContainerTF.anchoredPosition = arg_6_1
	self._paintingContainerTF.localScale = arg_6_2
end

function PaintingOpacity:GetContainerTF()
	return self._paintingContainerTF
end

function PaintingOpacity:GetSpinePaintingContainer()
	return self._spineContent
end

function PaintingOpacity:DisablePainting()
	if self._paintingTF then
		SetParent(self._paintingTF, self._paintingPreParent, false)

		self._paintingTF = nil
		self._paintingPreParent = nil
	end
end

function PaintingOpacity:SetPaintingAlphaTween(arg_10_1, arg_10_2, arg_10_3)
	if self._delayCallback then
		self._delayCallback()

		self._delayCallback = nil
		self._delayCallbackTime = nil
	end

	print("set painting alpha tween value = " .. arg_10_1 .. " time = " .. arg_10_2)

	self._delayCallback = arg_10_3
	self._delayCallbackTime = arg_10_2

	local var_10_0 = 0

	self:ClearAlphaTween()
	self:SetPaitningAlphaContent()
	LeanTween.value(self._go, self._rawImage.color.a, arg_10_1, arg_10_2):setEase(LeanTweenType.linear):setOnUpdate(System.Action_float(function(arg_11_0)
		if var_10_0 > 0 then
			self:SetRawImageAlpha(arg_11_0)
		end

		var_10_0 = var_10_0 + 1
	end)):setOnComplete(System.Action(function()
		self:SetRawImageAlpha(arg_10_1)

		if arg_10_1 == 1 then
			self:RevertPaintingContent()
		end

		if self._delayCallback then
			self._delayCallback()

			self._delayCallback = nil
			self._delayCallbackTime = nil
		end
	end))
end

function PaintingOpacity:SetPaitningAlphaContent()
	if self._paintingTF and self._paintingContent then
		SetParent(self._paintingTF, self._paintingContent, false)
	end
end

function PaintingOpacity:RevertPaintingContent()
	if self._paintingTF and self._paintingPreParent then
		SetParent(self._paintingTF, self._paintingPreParent, false)
	end
end

function PaintingOpacity:SetRawImage(arg_15_1)
	self._rawImage = arg_15_1
	self._rawImage.texture = self._rt
end

function PaintingOpacity:SetRawImageAlpha(arg_16_1)
	self._rawImage.color.a = Mathf.Clamp01(arg_16_1)
	self._rawImage.color = self._rawImage.color
end

function PaintingOpacity:ClearAlphaTween()
	if LeanTween.isTweening(self._go) then
		LeanTween.cancel(self._go)
	end
end

function PaintingOpacity:SetMeshPaintingFillter(arg_18_1)
	local var_18_0 = GetOrAddComponent(self._meshContent, "PaintingScaler")

	var_18_0.FrameName = arg_18_1
	var_18_0.Tween = 1
end

function PaintingOpacity:SetMeshPainting(arg_19_1)
	if arg_19_1 then
		self._paintingTF = arg_19_1
		self._paintingPreParent = arg_19_1.parent
		self._paintingContent = self._meshContent

		SetParent(arg_19_1, self._meshContent, false)
	end

	self:SetRawImageAlpha(1)
end

function PaintingOpacity:SetSpinePainting(arg_20_1)
	if arg_20_1 then
		self._paintingTF = arg_20_1

		if arg_20_1.parent then
			self._paintingPreParent = arg_20_1.parent
		end

		self._paintingContent = self._spineContent

		SetParent(arg_20_1, self._spineContent, false)
	end

	self:SetRawImageAlpha(1)
end

function PaintingOpacity:SetLive2DPainting(arg_21_1)
	if arg_21_1 then
		self._paintingTF = arg_21_1

		if arg_21_1.parent then
			self._paintingPreParent = arg_21_1.parent
		end

		self._paintingContent = self._live2dContent

		SetParent(arg_21_1, self._live2dContent, false)
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

function PaintingOpacity:Dispose()
	if self._delayCallback then
		self._delayCallback = nil

		self._delayCallback()
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self:ClearAlphaTween()
	self:ClearRendererTexture()
	Destroy(self._go)
end

return PaintingOpacity
