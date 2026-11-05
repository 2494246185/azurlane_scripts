local PaintingFadeManager = class("PaintingFadeManager")
local var_0_1 = 0.35
local var_0_2 = 0.35

PaintingFadeManager.PAINTING_TYPE = {
	LIVE2D = 3,
	MESH = 1,
	SPINE = 2
}

function PaintingFadeManager:Ctor(arg_1_1, arg_1_2)
	self._fadeInTime = arg_1_1 or var_0_1
	self._fadeOutTime = arg_1_2 or var_0_2
	self._uiCanvasTF = GameObject.Find("UICamera/Canvas").transform

	self:CreateRawImage()
	parallelAsync({
		function(arg_2_0)
			pg.PoolMgr.GetInstance():GetPrefab("ui/paintingopacityui", "", false, function(arg_3_0)
				self._paintingOpacity = PaintingOpacity.New(arg_3_0)

				self._paintingOpacity:SetRawImage(self._rawImageCom)
				setActive(self._rawImageGo, true)
				arg_2_0()
			end)
		end,
		function(arg_4_0)
			pg.PoolMgr.GetInstance():GetPrefab("ui/paintingopacityprogressui", "", false, function(arg_5_0)
				self._progressUI = tf(arg_5_0)

				setActive(self._progressUI, false)
				arg_4_0()
			end)
		end
	})

	self._screenTimer = Timer.New(function()
		self:OnScreenSizeChange()
		self:UpdateContainerOffset()
	end, 0.03333333333333333, -1)

	self._screenTimer:Start()
end

function PaintingFadeManager:OnScreenSizeChange()
	if self._paintingOpacity then
		local var_7_0 = math.ceil(self._uiCanvasTF.sizeDelta.x)
		local var_7_1 = math.ceil(self._uiCanvasTF.sizeDelta.y)

		if self._rawImageGo.transform.sizeDelta.x ~= var_7_0 or self._rawImageGo.transform.sizeDelta.y ~= var_7_1 then
			self._paintingOpacity:ResizeRenderTexture(var_7_0, var_7_1)

			self._rawImageGo.transform.sizeDelta = Vector2(var_7_0, var_7_1)
		end
	end
end

function PaintingFadeManager:CreateRawImage()
	self._rawImageGo = GameObject.New("PaintingRawImage")

	self._rawImageGo:AddComponent(typeof(UnityEngine.UI.RawImage))

	self._rawImageCom = GetComponent(self._rawImageGo, "UnityEngine.UI.RawImage")
	self._rawImageCom.raycastTarget = false

	setActive(self._rawImageGo, false)
end

function PaintingFadeManager:ResetPaintingContainerOffset(arg_9_1, arg_9_2, arg_9_3)
	if self._paintingOpacity then
		self._paintingOpacity:SetPaintingContainerOffset(arg_9_1, arg_9_2, arg_9_3)
	end

	self:ResetRawImageOffset()
end

function PaintingFadeManager:UpdateContainerOffset()
	if self._paintingOpacity then
		self._paintingOpacity:SetContainerOffset(self._rawPaintingContiner.anchoredPosition, self._rawPaintingContiner.localScale)
	end
end

function PaintingFadeManager:GetPaintingContainer()
	return self._paintingOpacity:GetContainerTF()
end

function PaintingFadeManager:GetSpinePaintingContainer()
	return self._paintingOpacity:GetSpinePaintingContainer()
end

function PaintingFadeManager:onLoadingCallback(arg_13_1)
	if self._isDispose then
		return
	end

	if arg_13_1 then
		if not self._overlay then
			self._overlay = true

			pg.UIMgr.GetInstance():OverlayPanel(self._progressUI, {
				type = LayerWeightConst.UI_TYPE_SUB
			})
		end

		setActive(self._progressUI, true)
	else
		if self._overlay then
			self._overlay = false

			pg.UIMgr.GetInstance():UnOverlayPanel(self._progressUI)
		end

		setActive(self._progressUI, false)
	end
end

function PaintingFadeManager:SetRawPaintingContainer(arg_14_1, arg_14_2)
	self._rawPaintingContiner = arg_14_1
	self._rawImageContainer = arg_14_2 or self._rawPaintingContiner.parent

	setParent(self._rawImageGo.transform, self._rawImageContainer, false)
	self:ResetRawImageOffset()
end

function PaintingFadeManager:ResetRawImageOffset()
	local var_15_0 = self._rawImageContainer:InverseTransformPoint((GameObject.Find("UICamera"):GetComponent(typeof(UnityEngine.Camera)):ScreenToWorldPoint((Vector3(Screen.width / 2, Screen.height / 2)))))

	var_15_0.z = 0
	self._rawImageGo.transform.localPosition = var_15_0
end

function PaintingFadeManager:SetOpacityPainting(arg_16_1, arg_16_2, arg_16_3)
	if arg_16_2 == self.PAINTING_TYPE.MESH then
		self._paintingOpacity:SetMeshPainting(arg_16_1)
	elseif arg_16_2 == self.PAINTING_TYPE.SPINE then
		self._paintingOpacity:SetSpinePainting(arg_16_1)
	elseif arg_16_2 == self.PAINTING_TYPE.LIVE2D then
		self._paintingOpacity:SetLive2DPainting(arg_16_1)
	end
end

function PaintingFadeManager:DisablePainting()
	if self._paintingOpacity then
		self._paintingOpacity:DisablePainting()
	end
end

function PaintingFadeManager:SetPaintingFadeOut(arg_18_1)
	if self._paintingOpacity then
		self._paintingOpacity:SetRawImageAlpha(1)
		self._paintingOpacity:SetPaintingAlphaTween(0, self._fadeOutTime, arg_18_1)
		self:onLoadingCallback(true)
	elseif arg_18_1 then
		arg_18_1()

		arg_18_1 = nil
	end

	self._paintingFadeFlag = true
end

function PaintingFadeManager:SetPaintingFadeIn(arg_19_1)
	if self._paintingOpacity then
		self._paintingOpacity:SetRawImageAlpha(0)
		self._paintingOpacity:SetPaintingAlphaTween(1, self._fadeInTime, arg_19_1)
	elseif arg_19_1 then
		arg_19_1()

		arg_19_1 = nil
	end

	self:onLoadingCallback(false)

	self._paintingFadeFlag = true
end

function PaintingFadeManager:SetPaintingAlpha(arg_20_1)
	print("change painting alpha to " .. arg_20_1)
	self._paintingOpacity:ClearAlphaTween()
	self._paintingOpacity:SetRawImageAlpha(arg_20_1)
	self:onLoadingCallback(arg_20_1 <= 0)
end

function PaintingFadeManager:SetMeshPaintingFillter(arg_21_1)
	if self._paintingOpacity then
		self._paintingOpacity:SetMeshPaintingFillter(arg_21_1)
	end
end

function PaintingFadeManager:RevertPaintingContainer()
	self._paintingOpacity:RevertPaintingContent()
end

function PaintingFadeManager:Dispose()
	self._isDispose = true
	self._rawPaintingContiner = nil
	self._bgContiner = nil

	if self._progressUI then
		if self._overlay then
			self._overlay = false

			pg.UIMgr.GetInstance():UnOverlayPanel(self._progressUI)
		end

		Destroy(self._progressUI)
	end

	if self._screenTimer then
		self._screenTimer:Stop()

		self._screenTimer = nil
	end

	if self._paintingOpacity then
		self._paintingOpacity:Dispose()

		self._paintingOpacity = nil
	end

	if self._rawImageGo then
		Destroy(self._rawImageGo)

		self._rawImageGo = nil
	end
end

return PaintingFadeManager
