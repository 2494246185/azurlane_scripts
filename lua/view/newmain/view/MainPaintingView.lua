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

	function Live2dConst.UnLoadL2dPating()
		if not self.reloadOnResume and self.painting and isa(self.painting, MainLive2dPainting) then
			self.painting:SetContainerVisible(false)

			self.reloadOnResume = true
		end
	end
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

function MainPaintingView:IsLive2DState()
	return MainPaintingView.STATE_L2D == self.state
end

function MainPaintingView:IsLoading()
	if self.painting and self.painting:IsLoading() then
		return true
	end

	return false
end

function MainPaintingView:Init(arg_20_1, arg_20_2, arg_20_3)
	if self:ShouldReLoad(arg_20_1) then
		self:Reload(arg_20_1)
	else
		self.painting:Resume()
	end

	self.shift = arg_20_2 or self.shift

	assert(self.shift)

	if arg_20_3 then
		self:AdjustPositionWithAnim(arg_20_1)
	else
		self:AdjustPosition(arg_20_1)
	end

	self.painting:SetShift(self.shift)
end

function MainPaintingView:Reload(arg_21_1)
	self.ship = arg_21_1

	local var_21_0, var_21_1 = MainPaintingView.GetAssistantStatus(arg_21_1)

	if self.painting then
		self.painting:Unload()
	end

	self.paintings[var_21_0]:Load(arg_21_1)

	self.painting = self.paintings[var_21_0]
	self.state = var_21_0
	self.bgToggle = PlayerPrefs.GetInt("paint_hide_other_obj_" .. self.painting.paintingName, 0)
	self.skinId = arg_21_1:getSkinId()
end

function MainPaintingView:Refresh(arg_22_1, arg_22_2)
	self:Init(arg_22_1, arg_22_2)
end

function MainPaintingView:ShouldReLoad(arg_23_1)
	if not self.painting or not self.ship or not self.state or not self.bgToggle then
		return true
	end

	if self.skinId == self.ship:getSkinId() and arg_23_1.id == self.ship.id and self.state == MainPaintingView.GetAssistantStatus(arg_23_1) and self.bgToggle == PlayerPrefs.GetInt("paint_hide_other_obj_" .. self.painting.paintingName, 0) and arg_23_1:GetRecordPosKey() == self.ship:GetRecordPosKey() and not self.reloadOnResume then
		return false
	else
		if self.reloadOnResume then
			self.reloadOnResume = false
		end

		return true
	end
end

function MainPaintingView:SetOnceLoadedCall(arg_24_1)
	self.painting:SetOnceLoadedCall(arg_24_1)
end

function MainPaintingView:PlayChangeSkinActionIn(arg_25_1)
	self.painting:PlayChangeSkinActionIn(arg_25_1)
end

function MainPaintingView:PlayChangeSkinActionOut(arg_26_1)
	self.painting:PlayChangeSkinActionOut(arg_26_1)
end

function MainPaintingView:Disable()
	if self.painting then
		self.painting:Pause()
	end
end

function MainPaintingView:AdjustPositionWithAnim(arg_28_1)
	LeanTween.cancel(go(self._tf))
	LeanTween.cancel(go(self._bgTf))

	local var_28_0 = self:GetPositionAndScale(arg_28_1)

	LeanTween.moveLocal(go(self._tf), var_28_0, 0.3):setEase(LeanTweenType.easeInOutExpo)
	LeanTween.moveLocal(go(self._bgTf), var_28_0, 0.3):setEase(LeanTweenType.easeInOutExpo)

	local var_28_1, var_28_2 = self.shift:GetSpineShift()

	LeanTween.moveLocal(go(self.spineContainer), var_28_1, 0.3):setEase(LeanTweenType.easeInOutExpo)

	local var_28_3, var_28_4 = self.shift:GetL2dShift()

	if self.painting:IslimitYPos() then
		var_28_3.y = self.painting:GetHalfBodyOffsetY()
	end

	LeanTween.moveLocal(go(self.l2dContainer), var_28_3, 0.3):setEase(LeanTweenType.easeInOutExpo):setOnComplete(System.Action(function()
		self:AdjustPosition(arg_28_1)
	end))
end

function MainPaintingView:AdjustPosition(arg_30_1)
	local var_30_0, var_30_1 = self:GetPositionAndScale(arg_30_1)

	self._tf.anchoredPosition = var_30_0
	self._bgTf.anchoredPosition = var_30_0

	local var_30_2, var_30_3 = self.shift:GetL2dShift()

	if self.painting:IslimitYPos() then
		var_30_2.y = self.painting:GetHalfBodyOffsetY()
	end

	self.l2dContainer.anchoredPosition = var_30_2

	local var_30_4, var_30_5 = self.shift:GetSpineShift()

	self.spineContainer.anchoredPosition = var_30_4

	local var_30_6, var_30_7, var_30_8 = getProxy(SettingsProxy):getSkinPosSetting(arg_30_1)

	if var_30_8 then
		self._bgTf.localScale = Vector3(var_30_8, var_30_8, 1)
		self._tf.localScale = Vector3(var_30_8, var_30_8, 1)
	elseif self.state == MainPaintingView.STATE_L2D then
		self._bgTf.localScale = var_30_3
		self._tf.localScale = var_30_3
	elseif self.state == MainPaintingView.STATE_SPINE_PAINTING then
		self._bgTf.localScale = var_30_5
		self._tf.localScale = var_30_5
	else
		self._bgTf.localScale = var_30_1
		self._tf.localScale = var_30_1
	end
end

function MainPaintingView:GetPositionAndScale(arg_31_1)
	local var_31_0, var_31_1, var_31_2 = getProxy(SettingsProxy):getSkinPosSetting(arg_31_1)
	local var_31_3 = Vector3(0, 0, 0)
	local var_31_4 = Vector3(1, 1, 1)

	if var_31_0 then
		var_31_3 = Vector3(var_31_0, var_31_1, 0)
		var_31_4 = Vector3(var_31_2, var_31_2, 1)
	else
		local var_31_5, var_31_6 = self.shift:GetMeshImageShift()

		var_31_3 = var_31_5
		var_31_4 = var_31_6
	end

	return var_31_3, var_31_4
end

function MainPaintingView:GetAssistantStatus()
	local var_32_0 = self:getPainting()
	local var_32_1 = getProxy(SettingsProxy)
	local var_32_2 = HXSet.autoHxShiftPath("live2d/" .. var_32_0)
	local var_32_3 = MainPaintingView.Live2dIsDownload(var_32_2) and checkABExist(var_32_2)
	local var_32_4 = var_32_1:getCharacterSetting(self.id, SHIP_FLAG_BG)

	if var_32_1:getCharacterSetting(self.id, SHIP_FLAG_L2D) and var_32_3 then
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_L2D or MainPaintingView.STATE_L2D), var_32_4
	elseif var_32_1:getCharacterSetting(self.id, SHIP_FLAG_SP) and checkABExist((HXSet.autoHxShiftPath("spinepainting/" .. var_32_0))) then
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_SPINE or MainPaintingView.STATE_SPINE_PAINTING), var_32_4
	else
		return (isa(self, VirtualEducateCharShip) or nil) and (MainPaintingView.STATE_EDUCATE_CHAR or MainPaintingView.STATE_PAINTING), var_32_4
	end
end

function MainPaintingView:OnBoundChange()
	if self.painting then
		self.painting:UpdateBound()
	end
end

function MainPaintingView:Live2dIsDownload()
	local var_34_0 = GroupHelper.GetGroupMgrByName("L2D"):CheckF(self)

	return var_34_0 == DownloadState.None or var_34_0 == DownloadState.UpdateSuccess
end

function MainPaintingView:Fold(arg_35_1, arg_35_2)
	return
end

function MainPaintingView:EnableOrDisableScale(arg_36_1)
	self.painting:EnableOrDisableMove(arg_36_1)
	self.painting:OnEnablePartScale(arg_36_1)
end

function MainPaintingView:EnableOrDisableMove(arg_37_1)
	self.painting:EnableOrDisableMove(arg_37_1)

	if arg_37_1 then
		self:EnableDragAndZoom()
	else
		self:DisableDragAndZoom()
	end
end

function MainPaintingView:OnAsmrTurnning(arg_38_1)
	self.painting:OnAsmrTurnning(arg_38_1)
end

function MainPaintingView:EnableDragAndZoom()
	self.isEnableDrag = true

	local var_39_0 = self._tf.parent.gameObject
	local var_39_1 = GetOrAddComponent(self._tf.parent.gameObject, typeof(PinchZoom))
	local var_39_2 = GetOrAddComponent(self._tf.parent.gameObject, typeof(EventTriggerListener))
	local var_39_3 = Vector3(0, 0, 0)

	var_39_2:AddBeginDragFunc(function(arg_40_0, arg_40_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if var_39_1.processing then
			return
		end

		setButtonEnabled(var_39_0, false)

		if Input.touchCount > 1 then
			return
		end

		var_39_3 = self._tf.localPosition - MainPaintingView.Screen2Local(var_39_0.transform.parent, arg_40_1.position)
	end)
	var_39_2:AddDragFunc(function(arg_41_0, arg_41_1)
		if Application.isEditor and Input.GetMouseButton(2) then
			return
		end

		if var_39_1.processing then
			return
		end

		if Input.touchCount > 1 then
			return
		end

		local var_41_0 = MainPaintingView.Screen2Local(var_39_0.transform.parent, arg_41_1.position)

		self._tf.localPosition = self.painting:IslimitYPos() and Vector3(var_41_0.x, self._tf.localPosition.y, 0) + Vector3(var_39_3.x, 0, 0) or Vector3(var_41_0.x, var_41_0.y, 0) + var_39_3
		self._bgTf.localPosition = self.bgOffset + self._tf.localPosition
	end)
	var_39_2:AddDragEndFunc(function()
		setButtonEnabled(var_39_0, true)
	end)

	if not self.painting:IslimitYPos() then
		var_39_1.enabled = true
	end

	var_39_2.enabled = true
	Input.multiTouchEnabled = true
	self.cg.blocksRaycasts = false

	self:AdjustPosition(self.ship)
end

function MainPaintingView:DisableDragAndZoom()
	if self.isEnableDrag then
		local var_43_0 = self._tf.parent:GetComponent(typeof(EventTriggerListener))

		ClearEventTrigger(var_43_0)

		var_43_0.enabled = false
		self._tf.parent:GetComponent(typeof(PinchZoom)).enabled = false
		self.cg.blocksRaycasts = true
		self.isEnableDrag = false
	end

	self:AdjustPosition(self.ship)
end

function MainPaintingView:Dispose()
	MainPaintingView.super.Dispose(self)
	self:DisableDragAndZoom()

	if self.painting then
		self.painting:Unload()
	end

	self.painting = nil

	for iter_44_0, iter_44_1 in ipairs(self.paintings) do
		iter_44_1:Dispose()
	end

	self.paintings = nil
end

function MainPaintingView:Screen2Local(arg_45_1)
	local var_45_0 = GameObject.Find("UICamera")

	return Vector3(var_45_0.x, LuaHelper.ScreenToLocal(self:GetComponent("RectTransform"), arg_45_1, (var_45_0:GetComponent("Camera"))).y, 0)
end

return MainPaintingView
