local MainPaintingView = class("MainPaintingView", import("..base.MainBaseView"))

MainPaintingView.STATE_PAINTING = 1
MainPaintingView.STATE_L2D = 2
MainPaintingView.STATE_SPINE_PAINTING = 3
MainPaintingView.STATE_EDUCATE_CHAR = 4
MainPaintingView.STATE_EDUCATE_SPINE = 5
MainPaintingView.STATE_EDUCATE_L2D = 6
MainPaintingView.MESH_POSITION_X_OFFSET = 145

function MainPaintingView:Ctor(arg_1_1, arg_1_2, arg_1_3)
	MainPaintingView.super.Ctor(self, arg_1_1, arg_1_3)

	self._bgTf = arg_1_2
	self._bgGo = arg_1_2.gameObject
	self.l2dContainer = arg_1_1:Find("live2d")
	self.spineContainer = arg_1_1:Find("spinePainting")
	self.meshContainer = arg_1_1:Find("fitter")
	self.bgOffset = self._bgTf.localPosition - self._tf.localPosition
	self.cg = self._tf:GetComponent(typeof(CanvasGroup))
	self.paintings = {
		MainMeshImagePainting.New(self._tf, self.event),
		MainLive2dPainting.New(self._tf, self.event),
		MainSpinePainting.New(self._tf, self.event, self._bgGo),
		MainEducateCharPainting.New(self._tf, self.event),
		MainEducateSpinePainting.New(self._tf, self.event, self._bgGo)
	}

	self:Register()
end

function MainPaintingView:Register()
	self:bind(TaskProxy.TASK_ADDED, function(arg_3_0)
		self:OnStopVoice()
	end)
	self:bind(NewMainScene.CHAT_STATE_CHANGE, function(arg_4_0, arg_4_1)
		self:OnChatStateChange(arg_4_1)
	end)
	self:bind(NewMainScene.ENABLE_PAITING_MOVE, function(arg_5_0, arg_5_1)
		self:EnableOrDisableMove(arg_5_1)
	end)
	self:bind(NewMainScene.SAVE_PART_SCALE, function(arg_6_0, arg_6_1)
		self.painting:SavePartScaleData()
	end)
	self:bind(NewMainScene.ENABLE_PAITING_SCALE, function(arg_7_0, arg_7_1)
		self:EnableOrDisableScale(arg_7_1)
	end)
	self:bind(NewMainScene.RESET_PAITING_SCALE, function(arg_8_0, arg_8_1)
		self.painting:ResetPartScale()
	end)
	self:bind(NewMainScene.ON_ENTER_DONE, function(arg_9_0)
		if self.painting then
			self.painting:TriggerEventAtFirstTime()
		end
	end)
	self:bind(NewMainScene.ENTER_SILENT_VIEW, function()
		self.cg.blocksRaycasts = false
		self.silentFlag = true

		for iter_10_0, iter_10_1 in ipairs(self.paintings) do
			iter_10_1:PauseForSilent()
		end
	end)
	self:bind(NewMainScene.EXIT_SILENT_VIEW, function()
		self.cg.blocksRaycasts = true
		self.silentFlag = false

		for iter_11_0, iter_11_1 in ipairs(self.paintings) do
			iter_11_1:ResumeForSilent()
		end
	end)
	self:bind(NewMainScene.RESET_L2D, function()
		if not self.painting then
			return
		end

		if not isa(self.painting, MainLive2dPainting) then
			return
		end

		self.painting:ResetState()
	end)
	self:bind(NewMainScene.STORY_BEGIN, function()
		if self.painting then
			self.painting:Pause()
		end
	end)
	self:bind(NewMainScene.STORY_END, function()
		if self.painting then
			self.painting:Resume()
		end
	end)
	self:bind(NewMainScene.PAINTING_LOAD_COMPLETE, function()
		self:MakePaintingFadeIn()
	end)
end

function MainPaintingView:OnChatStateChange(arg_16_1)
	if not arg_16_1 then
		self.painting:StopChatAnimtion()
	end
end

function MainPaintingView:OnStopVoice()
	if self.painting then
		self.painting:OnStopVoice()
	end
end

function MainPaintingView:MakePaintingFadeIn()
	if not self.painting then
		return
	end

	if not self._paintingManager then
		return
	end

	local var_18_0 = self.state
	local var_18_1
	local var_18_2 = self.painting:GetPaintingTransform()

	var_18_1 = (self.state == MainPaintingView.STATE_L2D or var_18_0 == MainPaintingView.STATE_EDUCATE_L2D) and self._paintingManager.PAINTING_TYPE.LIVE2D or (var_18_0 == MainPaintingView.STATE_SPINE_PAINTING or var_18_0 == MainPaintingView.STATE_EDUCATE_SPINE) and self._paintingManager.PAINTING_TYPE.SPINE or self._paintingManager.PAINTING_TYPE.MESH

	if var_18_2 == nil then
		return
	end

	self._paintingManager:SetOpacityPainting(var_18_2, var_18_1)

	if self._firstPaintingLoading then
		self._firstPaintingLoading = false

		self._paintingManager:RevertPaintingContainer()
		self._paintingManager:SetPaintingAlpha(1)
		self.painting:OnPaintingFade(false)
	else
		self._paintingManager:SetPaintingFadeIn(function()
			self.painting:OnPaintingFade(false)
		end)
	end
end

function MainPaintingView:IsLive2DState()
	return MainPaintingView.STATE_L2D == self.state
end

function MainPaintingView:IsLoading()
	if self.painting and self.painting:IsLoading() then
		return true
	end

	return false
end

function MainPaintingView:Init(arg_22_1, arg_22_2, arg_22_3)
	if not self._paintingManager then
		self._paintingManager = PaintingFadeManager.New()

		self._paintingManager:SetRawPaintingContainer(self._tf)

		for iter_22_0, iter_22_1 in pairs(self.paintings) do
			iter_22_1:SetTargetContainer(self._paintingManager:GetPaintingContainer())
		end

		self._firstPaintingLoading = true
	end

	print("初始化舰船 = " .. arg_22_1:getPainting())

	if self:ShouldReLoad(arg_22_1) then
		self.shift = arg_22_2 or self.shift

		assert(self.shift)

		self.ship = arg_22_1
		self.anim = arg_22_3

		local var_22_0, var_22_1 = MainPaintingView.GetAssistantStatus(arg_22_1)

		self.painting = self.paintings[var_22_0]
		self.state = var_22_0
		self.skinId = self.ship:getSkinId()
		self.bgToggle = PlayerPrefs.GetInt("paint_hide_other_obj_" .. arg_22_1:getPainting(), 0)

		self:Reload(function()
			self:InitShipShift()
		end)
	else
		self.painting:Resume()
		self:InitShipShift()
	end
end

function MainPaintingView:InitShipShift()
	if self.anim then
		self:AdjustPositionWithAnim(self.ship)
	else
		self:AdjustPosition(self.ship)
	end

	self.painting:SetShift(self.shift)
end

function MainPaintingView:Reload(arg_25_1)
	local function var_25_0()
		print("开始加载舰船 = " .. self.ship:getPainting())

		if self._loadingPainting then
			if self._paintingManager then
				self._paintingManager:DisablePainting()
			end

			self._loadingPainting:Unload()
		end

		self.painting:Load(self.ship, self.state)

		if arg_25_1 then
			arg_25_1()

			arg_25_1 = nil
		end

		self._loadingPainting = self.painting
	end

	if self._paintingManager then
		self.painting:OnPaintingFade(true)

		if not self._paintingFadeFlag then
			self._paintingFadeFlag = true

			self._paintingManager:SetPaintingFadeOut(function()
				self._paintingFadeFlag = false

				var_25_0()
			end)
		end
	else
		var_25_0()
	end
end

function MainPaintingView:Refresh(arg_28_1, arg_28_2)
	self:Init(arg_28_1, arg_28_2)
end

function MainPaintingView:Disable()
	if self._paintingManager then
		self._paintingManager:Dispose()

		self._paintingManager = nil
		self._paintingFadeFlag = false
	end

	if self.painting then
		self.painting:Pause()
	end
end

function MainPaintingView:ShouldReLoad(arg_30_1)
	if not self.painting or not self._loadingPainting or not self.ship or not self.state or not self.bgToggle then
		return true
	end

	if self.skinId == self.ship:getSkinId() and arg_30_1.id == self.ship.id and self.state == MainPaintingView.GetAssistantStatus(arg_30_1) and self.bgToggle == PlayerPrefs.GetInt("paint_hide_other_obj_" .. self._loadingPainting.paintingName, 0) and arg_30_1:GetRecordPosKey() == self.ship:GetRecordPosKey() and not self.reloadOnResume then
		print("不加载舰船 = " .. arg_30_1:getPainting())

		return false
	else
		if self.reloadOnResume then
			self.reloadOnResume = false
		end

		return true
	end
end

function MainPaintingView:SetOnceLoadedCall(arg_31_1)
	self.painting:SetOnceLoadedCall(arg_31_1)
end

function MainPaintingView:PlayChangeSkinActionIn(arg_32_1)
	self.painting:PlayChangeSkinActionIn(arg_32_1)
end

function MainPaintingView:PlayChangeSkinActionOut(arg_33_1)
	self.painting:PlayChangeSkinActionOut(arg_33_1)
end

function MainPaintingView:AdjustPositionWithAnim(arg_34_1)
	LeanTween.cancel(go(self._tf))
	LeanTween.cancel(go(self._bgTf))

	local var_34_0 = self:GetPositionAndScale(arg_34_1)

	LeanTween.moveLocal(go(self._tf), var_34_0, 0.3):setEase(LeanTweenType.easeInOutExpo)
	LeanTween.moveLocal(go(self._bgTf), var_34_0, 0.3):setEase(LeanTweenType.easeInOutExpo)

	local var_34_1, var_34_2 = self.shift:GetSpineShift()

	LeanTween.moveLocal(go(self.spineContainer), var_34_1, 0.3):setEase(LeanTweenType.easeInOutExpo)

	local var_34_3, var_34_4 = self.shift:GetL2dShift()

	if self.painting:IslimitYPos() then
		var_34_3.y = self.painting:GetHalfBodyOffsetY()
	end

	LeanTween.moveLocal(go(self.l2dContainer), var_34_3, 0.3):setEase(LeanTweenType.easeInOutExpo):setOnComplete(System.Action(function()
		self:AdjustPosition(arg_34_1)
	end))
end

function MainPaintingView:AdjustPosition(arg_36_1)
	local var_36_0, var_36_1 = self:GetPositionAndScale(arg_36_1)

	self._tf.anchoredPosition = var_36_0
	self._bgTf.anchoredPosition = var_36_0

	local var_36_2, var_36_3 = self.shift:GetL2dShift()

	if self.painting:IslimitYPos() then
		var_36_2.y = self.painting:GetHalfBodyOffsetY()
	end

	self.l2dContainer.anchoredPosition = var_36_2

	local var_36_4, var_36_5 = self.shift:GetSpineShift()

	self.spineContainer.anchoredPosition = var_36_4

	local var_36_6, var_36_7, var_36_8 = getProxy(SettingsProxy):getSkinPosSetting(arg_36_1)

	if var_36_8 then
		self._bgTf.localScale = Vector3(var_36_8, var_36_8, 1)
		self._tf.localScale = Vector3(var_36_8, var_36_8, 1)
	elseif self.state == MainPaintingView.STATE_L2D then
		self._bgTf.localScale = var_36_3
		self._tf.localScale = var_36_3
	elseif self.state == MainPaintingView.STATE_SPINE_PAINTING then
		self._bgTf.localScale = var_36_5
		self._tf.localScale = var_36_5
	else
		self._bgTf.localScale = var_36_1
		self._tf.localScale = var_36_1
	end

	if self._paintingManager then
		self._paintingManager:ResetPaintingContainerOffset(self.l2dContainer.anchoredPosition, self.spineContainer.anchoredPosition, self.meshContainer.anchoredPosition)
	end
end

function MainPaintingView:GetPositionAndScale(arg_37_1)
	local var_37_0, var_37_1, var_37_2 = getProxy(SettingsProxy):getSkinPosSetting(arg_37_1)
	local var_37_3 = Vector3(0, 0, 0)
	local var_37_4 = Vector3(1, 1, 1)

	if var_37_0 then
		var_37_3 = Vector3(var_37_0, var_37_1, 0)
		var_37_4 = Vector3(var_37_2, var_37_2, 1)
	else
		local var_37_5, var_37_6 = self.shift:GetMeshImageShift()

		var_37_3 = var_37_5
		var_37_4 = var_37_6
	end

	return var_37_3, var_37_4
end

function MainPaintingView:GetAssistantStatus()
	local var_38_0 = self:getPainting()
	local var_38_1 = getProxy(SettingsProxy)
	local var_38_2 = HXSet.autoHxShiftPath("live2d/" .. var_38_0)
	local var_38_3 = MainPaintingView.Live2dIsDownload(var_38_2) and checkABExist(var_38_2)
	local var_38_4 = var_38_1:getCharacterSetting(self.id, SHIP_FLAG_BG)

	if var_38_1:getCharacterSetting(self.id, SHIP_FLAG_L2D) and var_38_3 then
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_L2D or MainPaintingView.STATE_L2D), var_38_4
	elseif var_38_1:getCharacterSetting(self.id, SHIP_FLAG_SP) and checkABExist((HXSet.autoHxShiftPath("spinepainting/" .. var_38_0))) then
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_SPINE or MainPaintingView.STATE_SPINE_PAINTING), var_38_4
	else
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_CHAR or MainPaintingView.STATE_PAINTING), var_38_4
	end
end

function MainPaintingView:OnBoundChange()
	if self.painting then
		self.painting:UpdateBound()
	end
end

function MainPaintingView:Live2dIsDownload()
	local var_40_0 = GroupHelper.GetGroupMgrByName("L2D"):CheckF(self)

	return var_40_0 == DownloadState.None or var_40_0 == DownloadState.UpdateSuccess
end

function MainPaintingView:Fold(arg_41_1, arg_41_2)
	return
end

function MainPaintingView:EnableOrDisableScale(arg_42_1)
	self.painting:EnableOrDisableMove(arg_42_1)
	self.painting:OnEnablePartScale(arg_42_1)
end

function MainPaintingView:EnableOrDisableMove(arg_43_1)
	self.painting:EnableOrDisableMove(arg_43_1)

	if arg_43_1 then
		self:EnableDragAndZoom()
	else
		self:DisableDragAndZoom()
	end
end

function MainPaintingView:OnAsmrTurnning(arg_44_1)
	self.painting:OnAsmrTurnning(arg_44_1)
end

function MainPaintingView:EnableDragAndZoom()
	self.isEnableDrag = true

	local var_45_0 = self._tf.parent.gameObject
	local var_45_1 = GetOrAddComponent(self._tf.parent.gameObject, typeof(PinchZoom))
	local var_45_2 = GetOrAddComponent(self._tf.parent.gameObject, typeof(EventTriggerListener))
	local var_45_3 = Vector3(0, 0, 0)

	var_45_2:AddBeginDragFunc(function(arg_46_0, arg_46_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if var_45_1.processing then
			return
		end

		setButtonEnabled(var_45_0, false)

		if Input.touchCount > 1 then
			return
		end

		var_45_3 = self._tf.localPosition - MainPaintingView.Screen2Local(var_45_0.transform.parent, arg_46_1.position)
	end)
	var_45_2:AddDragFunc(function(arg_47_0, arg_47_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if var_45_1.processing then
			return
		end

		if Input.touchCount > 1 then
			return
		end

		local var_47_0 = MainPaintingView.Screen2Local(var_45_0.transform.parent, arg_47_1.position)

		self._tf.localPosition = self.painting:IslimitYPos() and Vector3(var_47_0.x, self._tf.localPosition.y, 0) + Vector3(var_45_3.x, 0, 0) or Vector3(var_47_0.x, var_47_0.y, 0) + var_45_3
		self._bgTf.localPosition = self.bgOffset + self._tf.localPosition
	end)
	var_45_2:AddDragEndFunc(function()
		setButtonEnabled(var_45_0, true)
	end)

	if not self.painting:IslimitYPos() then
		var_45_1.enabled = true
	end

	var_45_2.enabled = true
	Input.multiTouchEnabled = true
	self.cg.blocksRaycasts = false

	self:AdjustPosition(self.ship)
end

function MainPaintingView:DisableDragAndZoom()
	if self.isEnableDrag then
		local var_49_0 = self._tf.parent:GetComponent(typeof(EventTriggerListener))

		ClearEventTrigger(var_49_0)

		var_49_0.enabled = false
		self._tf.parent:GetComponent(typeof(PinchZoom)).enabled = false
		self.cg.blocksRaycasts = true
		self.isEnableDrag = false
	end

	self:AdjustPosition(self.ship)
end

function MainPaintingView:Dispose()
	MainPaintingView.super.Dispose(self)

	if self._paintingManager then
		self._paintingManager:Dispose()
	end

	self:DisableDragAndZoom()

	if self.painting then
		self.painting:Unload()
	end

	self.painting = nil
	self._loadingPainting = nil

	for iter_50_0, iter_50_1 in ipairs(self.paintings) do
		iter_50_1:Dispose()
	end

	self.paintings = nil
end

function MainPaintingView:Screen2Local(arg_51_1)
	local var_51_0 = GameObject.Find("UICamera")

	return Vector3(var_51_0.x, LuaHelper.ScreenToLocal(self:GetComponent("RectTransform"), arg_51_1, (var_51_0:GetComponent("Camera"))).y, 0)
end

return MainPaintingView
