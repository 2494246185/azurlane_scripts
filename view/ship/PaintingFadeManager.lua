local PaintingFadeManager = class("PaintingFadeManager")
local var_0_1 = 1
local var_0_2 = 0.3
local var_0_3 = 0.3

PaintingFadeManager.PAINTING_TYPE = {
	LIVE2D = 3,
	MESH = 1,
	SPINE = 2
}

function PaintingFadeManager:Ctor(arg_1_1, arg_1_2)
	self._fadeInTime = arg_1_1 or var_0_2
	self._fadeOutTime = arg_1_2 or var_0_3
	self._uiCanvasTF = GameObject.Find("UICamera/Canvas").transform

	self:CreateRawImage()
	parallelAsync({
		function(arg_2_0)
			pg.PoolMgr.GetInstance():GetPrefab("ui/paintingopacityui", "", false, function(arg_3_0)
				self._paintingOpacity = PaintingOpacity.New(arg_3_0)

				self._paintingOpacity:SetRawImage(self._rawImageCom)
				setActive(self._rawImageGo, false)
				arg_2_0()
			end)
		end,
		function(arg_4_0)
			pg.PoolMgr.GetInstance():GetPrefab("ui/paintingopacityprogressui", "", false, function(arg_5_0)
				self._progressUI = tf(arg_5_0)
				self._progressText = findTF(self._progressUI, "text")

				setActive(self._progressUI, false)
				arg_4_0()
			end)
		end
	})

	self._screenTimer = Timer.New(function()
		self:OnScreenSizeChange()
		self:UpdateContainerOffset()
		self:UpdateProgress()
	end, 0.03333333333333333, -1)

	self._screenTimer:Start()
end

function PaintingFadeManager:UpdateProgress()
	if self._progressNum and self._progressNum < 100 then
		self._progressNum = self._progressNum + math.random(3, 7)
		self._progressNum = math.min(self._progressNum, 100)
	end

	if self._progressText then
		setText(self._progressText, tostring(self._progressNum) .. "%")
	end
end

function PaintingFadeManager:OnScreenSizeChange()
	if self._paintingOpacity then
		local var_8_0 = math.ceil(self._uiCanvasTF.sizeDelta.x)
		local var_8_1 = math.ceil(self._uiCanvasTF.sizeDelta.y)

		if self._rawImageGo.transform.sizeDelta.x ~= var_8_0 or self._rawImageGo.transform.sizeDelta.y ~= var_8_1 then
			self._paintingOpacity:ResizeRenderTexture(var_8_0, var_8_1)

			self._rawImageGo.transform.sizeDelta = Vector2(var_8_0, var_8_1)
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

function PaintingFadeManager:ResetPaintingContainerOffset(arg_10_1, arg_10_2, arg_10_3)
	if self._paintingOpacity then
		self._paintingOpacity:SetPaintingContainerOffset(arg_10_1, arg_10_2, arg_10_3)
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

function PaintingFadeManager:SetLoading(arg_14_1)
	if self._isDispose then
		return
	end

	self._progressNum = math.random(0, 80)

	if arg_14_1 then
		if not self._overlay then
			self._overlay = true

			pg.UIMgr.GetInstance():OverlayPanel(self._progressUI, {
				type = LayerWeightConst.UI_TYPE_SUB
			})
		end

		setActive(self._progressUI, true)
		self:UpdateProgress()
	else
		if self._overlay then
			self._overlay = false

			pg.UIMgr.GetInstance():UnOverlayPanel(self._progressUI)
		end

		setActive(self._progressUI, false)
	end
end

function PaintingFadeManager:SetRawPaintingContainer(arg_15_1, arg_15_2)
	self._rawPaintingContiner = arg_15_1
	self._rawImageContainer = arg_15_2 or self._rawPaintingContiner.parent

	setParent(self._rawImageGo.transform, self._rawImageContainer, false)
	self:ResetRawImageOffset()
end

function PaintingFadeManager:ResetRawImageOffset()
	local var_16_0 = self._rawImageContainer:InverseTransformPoint((GameObject.Find("UICamera"):GetComponent(typeof(UnityEngine.Camera)):ScreenToWorldPoint((Vector3(Screen.width / 2, Screen.height / 2)))))

	var_16_0.z = 0
	self._rawImageGo.transform.localPosition = var_16_0
end

function PaintingFadeManager:SetOpacityPainting(arg_17_1, arg_17_2, arg_17_3, arg_17_4)
	self.type = arg_17_3

	if arg_17_3 == self.PAINTING_TYPE.MESH then
		self._paintingOpacity:SetMeshPainting(arg_17_1, arg_17_2)
	elseif arg_17_3 == self.PAINTING_TYPE.SPINE then
		self._paintingOpacity:SetSpinePainting(arg_17_1, arg_17_2)
	elseif arg_17_3 == self.PAINTING_TYPE.LIVE2D then
		self._paintingOpacity:SetLive2DPainting(arg_17_1, arg_17_2)
	end
end

function PaintingFadeManager:DisablePainting()
	if self._paintingOpacity then
		self._paintingOpacity:DisablePainting()
	end
end

function PaintingFadeManager:SetPaintingFadeOut(arg_19_1)
	if self._paintingOpacity then
		if not isActive(self._rawImageGo) then
			setActive(self._rawImageGo, true)
		end

		self._paintingOpacity:SetRawImageAlpha(1)
		self._paintingOpacity:SetPaintingAlphaTween(0, self._fadeOutTime, arg_19_1)
	elseif arg_19_1 then
		arg_19_1()

		arg_19_1 = nil
	end

	self._paintingFadeFlag = true
end

function PaintingFadeManager:SetPaintingFadeIn(arg_20_1)
	if self._paintingOpacity then
		if not isActive(self._rawImageGo) then
			setActive(self._rawImageGo, true)
		end

		self._paintingOpacity:SetRawImageAlpha(0)
		self._paintingOpacity:SetPaintingAlphaTween(1, (self.type == self.PAINTING_TYPE.LIVE2D or nil) and (var_0_1 or self._fadeInTime), arg_20_1)
	elseif arg_20_1 then
		arg_20_1()

		arg_20_1 = nil
	end

	self._paintingFadeFlag = true
end

function PaintingFadeManager:SetPaintingAlpha(arg_21_1)
	print("change painting alpha to " .. arg_21_1)

	if not isActive(self._rawImageGo) then
		setActive(self._rawImageGo, true)
	end

	self._paintingOpacity:ClearAlphaTween()
	self._paintingOpacity:SetRawImageAlpha(arg_21_1)
end

function PaintingFadeManager:SetMeshPaintingFillter(arg_22_1)
	if self._paintingOpacity then
		self._paintingOpacity:SetMeshPaintingFillter(arg_22_1)
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
