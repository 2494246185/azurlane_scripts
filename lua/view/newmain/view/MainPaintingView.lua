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

	local var_18_0 = self.painting:GetPaintingTransform()

	if var_18_0 == nil then
		return
	end

	self._paintingManager:SetOpacityPainting(var_18_0, self:getPaintingContainer(), (self:getPaintingManagerType()))
	self.painting:OnPaintingFade(true)
	print("painting fade in ")

	if self._firstPaintingLoading then
		self._firstPaintingLoading = false

		self._paintingManager:RevertPaintingContainer()
		self._paintingManager:SetPaintingAlpha(1)
		self.painting:OnPaintingFade(false)
	else
		self._paintingManager:SetPaintingAlpha(0)
		self._paintingManager:SetPaintingFadeIn(function()
			self.painting:OnPaintingFade(false)
		end)
	end
end

function MainPaintingView:getPaintingManagerType()
	return (self.state == MainPaintingView.STATE_L2D or self.state == MainPaintingView.STATE_EDUCATE_L2D) and self._paintingManager.PAINTING_TYPE.LIVE2D or (self.state == MainPaintingView.STATE_SPINE_PAINTING or self.state == MainPaintingView.STATE_EDUCATE_SPINE) and self._paintingManager.PAINTING_TYPE.SPINE or self._paintingManager.PAINTING_TYPE.MESH
end

function MainPaintingView:getPaintingContainer()
	if self.state == MainPaintingView.STATE_L2D or self.state == MainPaintingView.STATE_EDUCATE_L2D then
		return self.l2dContainer
	elseif self.state == MainPaintingView.STATE_SPINE_PAINTING or self.state == MainPaintingView.STATE_EDUCATE_SPINE then
		return self.spineContainer
	else
		return self.meshContainer
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

function MainPaintingView:Init(arg_24_1, arg_24_2, arg_24_3, arg_24_4)
	print("初始化舰船 = " .. arg_24_1:getPainting())

	if self:ShouldReLoad(arg_24_1) then
		self.shift = arg_24_2 or self.shift

		assert(self.shift)

		self.ship = arg_24_1
		self.anim = arg_24_3

		local var_24_0, var_24_1 = MainPaintingView.GetAssistantStatus(arg_24_1)

		self.painting = self.paintings[var_24_0]
		self.state = var_24_0
		self.skinId = self.ship:getSkinId()
		self.bgToggle = PlayerPrefs.GetInt("paint_hide_other_obj_" .. arg_24_1:getPainting(), 0)

		self:Reload(function()
			if self._paintingManager and self.painting then
				local var_25_0 = self.painting:GetPaintingTransform()

				if var_25_0 then
					self._paintingManager:SetOpacityPainting(var_25_0, self:getPaintingContainer(), (self:getPaintingManagerType()))
					self.painting:OnPaintingFade(true)
				end
			end

			self:InitShipShift()

			if arg_24_4 then
				arg_24_4()

				arg_24_4 = nil
			end
		end)
	else
		self.painting:Resume()
		self:InitShipShift()

		if arg_24_4 then
			arg_24_4()

			arg_24_4 = nil
		end
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

function MainPaintingView:Reload(arg_27_1)
	local function var_27_0()
		print("开始加载舰船 = " .. self.ship:getPainting())

		self._paintingFadeFlag = false

		if self._loadingPainting then
			if self._paintingManager then
				self._paintingManager:DisablePainting()
			end

			self._loadingPainting:Unload()
		end

		self.painting:Load(self.ship, arg_27_1)

		self._loadingPainting = self.painting
	end

	if self._paintingManager and not self._paintingFadeFlag then
		self.painting:OnPaintingFade(true)
		self._paintingManager:SetLoading(true)
		seriesAsync({
			function(arg_29_0)
				onDelayTick(arg_29_0, 0.2)
			end,
			function(arg_30_0)
				if isa(self.painting, MainLive2dPainting) then
					pg.Live2DMgr.GetInstance():preloadL2dModelAsync(self.ship:getPainting(), arg_30_0)
				else
					arg_30_0()
				end
			end,
			function(arg_31_0)
				if self._paintingManager then
					self._paintingManager:SetLoading(false)

					self._paintingFadeFlag = true

					self._paintingManager:SetPaintingFadeOut(arg_31_0)
					self.painting:OnPaintingFade(false)
				end
			end
		}, var_27_0)
	else
		var_27_0()
	end
end

function MainPaintingView:Refresh(arg_32_1, arg_32_2, arg_32_3)
	self:Init(arg_32_1, arg_32_2, nil, arg_32_3)
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

function MainPaintingView:ShouldReLoad(arg_34_1)
	if not self.painting or not self._loadingPainting or not self.ship or not self.state or not self.bgToggle then
		return true
	end

	if self.skinId == self.ship:getSkinId() and arg_34_1.id == self.ship.id and self.state == MainPaintingView.GetAssistantStatus(arg_34_1) and self.bgToggle == PlayerPrefs.GetInt("paint_hide_other_obj_" .. self._loadingPainting.paintingName, 0) and arg_34_1:GetRecordPosKey() == self.ship:GetRecordPosKey() and not self.reloadOnResume then
		print("不加载舰船 = " .. arg_34_1:getPainting())

		return false
	else
		if self.reloadOnResume then
			self.reloadOnResume = false
		end

		return true
	end
end

function MainPaintingView:SetOnceLoadedCall(arg_35_1)
	self.painting:SetOnceLoadedCall(arg_35_1)
end

function MainPaintingView:PlayChangeSkinActionIn(arg_36_1)
	self.painting:PlayChangeSkinActionIn(arg_36_1)
end

function MainPaintingView:PlayChangeSkinActionOut(arg_37_1)
	self.painting:PlayChangeSkinActionOut(arg_37_1)
end

function MainPaintingView:AdjustPositionWithAnim(arg_38_1)
	LeanTween.cancel(go(self._tf))
	LeanTween.cancel(go(self._bgTf))

	local var_38_0 = self:GetPositionAndScale(arg_38_1)

	LeanTween.moveLocal(go(self._tf), var_38_0, 0.3):setEase(LeanTweenType.easeInOutExpo)
	LeanTween.moveLocal(go(self._bgTf), var_38_0, 0.3):setEase(LeanTweenType.easeInOutExpo)

	local var_38_1, var_38_2 = self.shift:GetSpineShift()

	LeanTween.moveLocal(go(self.spineContainer), var_38_1, 0.3):setEase(LeanTweenType.easeInOutExpo)

	local var_38_3, var_38_4 = self.shift:GetL2dShift()

	if self.painting:IslimitYPos() then
		var_38_3.y = self.painting:GetHalfBodyOffsetY()
	end

	LeanTween.moveLocal(go(self.l2dContainer), var_38_3, 0.3):setEase(LeanTweenType.easeInOutExpo):setOnComplete(System.Action(function()
		self:AdjustPosition(arg_38_1)
	end))
end

function MainPaintingView:AdjustPosition(arg_40_1)
	local var_40_0, var_40_1 = self:GetPositionAndScale(arg_40_1)

	self._tf.anchoredPosition = var_40_0
	self._bgTf.anchoredPosition = var_40_0

	local var_40_2, var_40_3 = self.shift:GetL2dShift()

	if self.painting:IslimitYPos() then
		var_40_2.y = self.painting:GetHalfBodyOffsetY()
	end

	self.l2dContainer.anchoredPosition = var_40_2

	local var_40_4, var_40_5 = self.shift:GetSpineShift()

	self.spineContainer.anchoredPosition = var_40_4

	local var_40_6, var_40_7, var_40_8 = getProxy(SettingsProxy):getSkinPosSetting(arg_40_1)

	if var_40_8 then
		self._bgTf.localScale = Vector3(var_40_8, var_40_8, 1)
		self._tf.localScale = Vector3(var_40_8, var_40_8, 1)
	elseif self.state == MainPaintingView.STATE_L2D then
		self._bgTf.localScale = var_40_3
		self._tf.localScale = var_40_3
	elseif self.state == MainPaintingView.STATE_SPINE_PAINTING then
		self._bgTf.localScale = var_40_5
		self._tf.localScale = var_40_5
	else
		self._bgTf.localScale = var_40_1
		self._tf.localScale = var_40_1
	end

	if self._paintingManager then
		self._paintingManager:ResetPaintingContainerOffset(self.l2dContainer.anchoredPosition, self.spineContainer.anchoredPosition, self.meshContainer.anchoredPosition)
	end
end

function MainPaintingView:GetPositionAndScale(arg_41_1)
	local var_41_0, var_41_1, var_41_2 = getProxy(SettingsProxy):getSkinPosSetting(arg_41_1)
	local var_41_3 = Vector3(0, 0, 0)
	local var_41_4 = Vector3(1, 1, 1)

	if var_41_0 then
		var_41_3 = Vector3(var_41_0, var_41_1, 0)
		var_41_4 = Vector3(var_41_2, var_41_2, 1)
	else
		local var_41_5, var_41_6 = self.shift:GetMeshImageShift()

		var_41_3 = var_41_5
		var_41_4 = var_41_6
	end

	return var_41_3, var_41_4
end

function MainPaintingView:GetAssistantStatus()
	local var_42_0 = self:getPainting()
	local var_42_1 = getProxy(SettingsProxy)
	local var_42_2 = HXSet.autoHxShiftPath("live2d/" .. var_42_0)
	local var_42_3 = MainPaintingView.Live2dIsDownload(var_42_2) and checkABExist(var_42_2)
	local var_42_4 = var_42_1:getCharacterSetting(self.id, SHIP_FLAG_BG)

	if var_42_1:getCharacterSetting(self.id, SHIP_FLAG_L2D) and var_42_3 then
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_L2D or MainPaintingView.STATE_L2D), var_42_4
	elseif var_42_1:getCharacterSetting(self.id, SHIP_FLAG_SP) and checkABExist((HXSet.autoHxShiftPath("spinepainting/" .. var_42_0))) then
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_SPINE or MainPaintingView.STATE_SPINE_PAINTING), var_42_4
	else
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_CHAR or MainPaintingView.STATE_PAINTING), var_42_4
	end
end

function MainPaintingView:OnBoundChange()
	if self.painting then
		self.painting:UpdateBound()
	end
end

function MainPaintingView:Live2dIsDownload()
	local var_44_0 = GroupHelper.GetGroupMgrByName("L2D"):CheckF(self)

	return var_44_0 == DownloadState.None or var_44_0 == DownloadState.UpdateSuccess
end

function MainPaintingView:Fold(arg_45_1, arg_45_2)
	return
end

function MainPaintingView:EnableOrDisableScale(arg_46_1)
	self.painting:EnableOrDisableMove(arg_46_1)
	self.painting:OnEnablePartScale(arg_46_1)
end

function MainPaintingView:EnableOrDisableMove(arg_47_1)
	self.painting:EnableOrDisableMove(arg_47_1)

	if arg_47_1 then
		self:EnableDragAndZoom()
	else
		self:DisableDragAndZoom()
	end
end

function MainPaintingView:OnAsmrTurnning(arg_48_1)
	self.painting:OnAsmrTurnning(arg_48_1)
end

function MainPaintingView:EnableDragAndZoom()
	self.isEnableDrag = true

	local var_49_0 = self._tf.parent.gameObject
	local var_49_1 = GetOrAddComponent(self._tf.parent.gameObject, typeof(PinchZoom))
	local var_49_2 = GetOrAddComponent(self._tf.parent.gameObject, typeof(EventTriggerListener))
	local var_49_3 = Vector3(0, 0, 0)

	var_49_2:AddBeginDragFunc(function(arg_50_0, arg_50_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if var_49_1.processing then
			return
		end

		setButtonEnabled(var_49_0, false)

		if Input.touchCount > 1 then
			return
		end

		var_49_3 = self._tf.localPosition - MainPaintingView.Screen2Local(var_49_0.transform.parent, arg_50_1.position)
	end)
	var_49_2:AddDragFunc(function(arg_51_0, arg_51_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if var_49_1.processing then
			return
		end

		if Input.touchCount > 1 then
			return
		end

		local var_51_0 = MainPaintingView.Screen2Local(var_49_0.transform.parent, arg_51_1.position)

		self._tf.localPosition = self.painting:IslimitYPos() and Vector3(var_51_0.x, self._tf.localPosition.y, 0) + Vector3(var_49_3.x, 0, 0) or Vector3(var_51_0.x, var_51_0.y, 0) + var_49_3
		self._bgTf.localPosition = self.bgOffset + self._tf.localPosition
	end)
	var_49_2:AddDragEndFunc(function()
		setButtonEnabled(var_49_0, true)
	end)

	if not self.painting:IslimitYPos() then
		var_49_1.enabled = true
	end

	var_49_2.enabled = true
	Input.multiTouchEnabled = true
	self.cg.blocksRaycasts = false

	self:AdjustPosition(self.ship)
end

function MainPaintingView:DisableDragAndZoom()
	if self.isEnableDrag then
		local var_53_0 = self._tf.parent:GetComponent(typeof(EventTriggerListener))

		ClearEventTrigger(var_53_0)

		var_53_0.enabled = false
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

		self._paintingManager = nil
	end

	self:DisableDragAndZoom()

	if self.painting then
		self.painting:Unload()
	end

	self.painting = nil
	self._loadingPainting = nil

	for iter_54_0, iter_54_1 in ipairs(self.paintings) do
		iter_54_1:Dispose()
	end

	self.paintings = nil
end

function MainPaintingView:Screen2Local(arg_55_1)
	local var_55_0 = GameObject.Find("UICamera")

	return Vector3(var_55_0.x, LuaHelper.ScreenToLocal(self:GetComponent("RectTransform"), arg_55_1, (var_55_0:GetComponent("Camera"))).y, 0)
end

return MainPaintingView
