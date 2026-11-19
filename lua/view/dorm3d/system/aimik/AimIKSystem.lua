local AimIKSystem = class("AimIKSystem", import("view.dorm3d.Core.BaseSystem"))

AimIKSystem.GET_TIP_SHOW_INFO = "AimIKSystem.GetTipShowInfo"
AimIKSystem.ON_BEGIN_DRAG = "AimIKSystem.OnBeginDrag"
AimIKSystem.ON_DRAG = "AimIKSystem.OnDrag"
AimIKSystem.ON_END_DRAG = "AimIKSystem.OnEndDrag"
AimIKSystem.ENTER_TIMELINE_AIMIK_STATUS = "AimIKSystem.EnterTimelineAimIKStatus"
AimIKSystem.EXIT_TIMELINE_AIMIK_STATUS = "AimIKSystem.ExitTimelineAimIKStatus"
AimIKSystem.ENTER_TOUCH_AIMIK_STATUS = "AimIKSystem.EnterTouchAimIKStatus"
AimIKSystem.EXIT_TOUCH_AIMIK_STATUS = "AimIKSystem.ExitTouchAimIKStatus"
AimIKSystem.ON_EXIT_TOUCH_MODE = "AimIKSystem.OnExitTouchMode"

function AimIKSystem:OnInit()
	self.inStatus = false
	self.inExitProcessing = false
	self.exitProcessToken = 0
	self.touchProcessToken = 0
	self.inputEnabled = false
end

function AimIKSystem:RegisterEvents()
	self:Bind(AimIKSystem.GET_TIP_SHOW_INFO, function(arg_3_0, arg_3_1)
		return self:GetTipShowInfo(arg_3_1)
	end)
	self:Bind(AimIKSystem.ON_BEGIN_DRAG, function(arg_4_0, arg_4_1, arg_4_2)
		self:OnBeginDrag(arg_4_1, arg_4_2)
	end)
	self:Bind(AimIKSystem.ON_DRAG, function(arg_5_0, arg_5_1, arg_5_2)
		self:OnDrag(arg_5_1, arg_5_2)
	end)
	self:Bind(AimIKSystem.ON_END_DRAG, function(arg_6_0, arg_6_1, arg_6_2)
		self:OnEndDrag(arg_6_1, arg_6_2)
	end)
	self:Bind(AimIKSystem.ENTER_TIMELINE_AIMIK_STATUS, function(arg_7_0, arg_7_1)
		self:EnterTimelineAimIKStatus(arg_7_1)
	end)
	self:Bind(AimIKSystem.EXIT_TIMELINE_AIMIK_STATUS, function()
		self:ExitTimelineAimIKStatus()
	end)
	self:Bind(AimIKSystem.ENTER_TOUCH_AIMIK_STATUS, function(arg_9_0, arg_9_1)
		self:EnterTouchAimIKStatus(arg_9_1)
	end)
	self:Bind(AimIKSystem.EXIT_TOUCH_AIMIK_STATUS, function()
		self:ExitTouchAimIKStatus()
	end)
	self:Bind(AimIKSystem.ON_EXIT_TOUCH_MODE, function(arg_11_0, arg_11_1)
		self:ExitTouchAimIKStatus(true, arg_11_1)
	end)
end

function AimIKSystem:OnHandleNotification(arg_12_1, arg_12_2)
	if arg_12_1 == Dorm3dRoomTemplateScene.TIMELINE_END and self.statusMode == "timeline" then
		if not self.inStatus and not self.inExitProcessing then
			return
		end

		self:ForceExitTimelineAimIKStatus()
	end
end

function AimIKSystem.GetInterests()
	return {
		Dorm3dRoomTemplateScene.TIMELINE_END
	}
end

function AimIKSystem:OnDispose()
	self.touchProcessToken = self.touchProcessToken + 1

	self:InvalidateExitProcess()
	self:UnregisterTrigger()

	if self.statusMode == "touch" then
		self:ResetTouchItem()
	end

	self:FinishExitTimelineAimIKStatus()

	self.inputEnabled = false

	self:Emit(Dorm3dAimIKView.SHOW_OR_HIDE, false)

	self.statusMode = nil
	self.touchExitCallbacks = nil
end

function AimIKSystem:EnterTimelineAimIKStatus(arg_15_1)
	warning("enteraimikstatus")

	if self.statusMode or self.inExitProcessing then
		warning("重复进入TimelineAimIK状态")

		return
	end

	self.inStatus = true
	self.statusMode = "timeline"

	assert(pg.dorm3d_aim_ik[arg_15_1], "AimIK config is nil for id: " .. tostring(arg_15_1))

	local var_15_0 = GameObject.Find(pg.dorm3d_aim_ik[arg_15_1].item_path)

	assert(not IsNil(var_15_0), "Timeline AimIK item not found: " .. pg.dorm3d_aim_ik[arg_15_1].item_path)
	self:InitAimIKComponents(pg.dorm3d_aim_ik[arg_15_1], Dorm3dHxHelper.GetTimelineMainCharacter(), var_15_0.transform)

	self.mainCamera = Camera.main
	self.headAimIKComp.weight = 0
	self.stickAimComp.weight = 0

	setActive(self.configRoot, true)
	self:LerpAimWeight(0, 1, self.config.fade_in, function()
		self:Emit(Dorm3dAimIKView.BIND_DRAG_AREA, self.dragComp)
		self:Emit(Dorm3dAimIKView.SHOW_OR_HIDE, true)

		self.inputEnabled = true
		self.triggerAction = System.Action(function()
			self:Emit(Dorm3dRoomTemplateScene.TRIGGER_TIMELINE_PLAYER_EVENT, {
				intParameter = 1919810,
				floatParameter = 0,
				stringParameter = "TimelineSelect"
			})
			self:ExitTimelineAimIKStatus()
		end)

		self.dragComp:RegisterOnTargetReachBoundary(self.triggerAction)
	end)
end

function AimIKSystem:ExitTimelineAimIKStatus(arg_18_1)
	if self.statusMode ~= "timeline" then
		return
	end

	warning("exitaimikstatus")

	self.inStatus = false
	self.inputEnabled = false

	self:Emit(Dorm3dAimIKView.SHOW_OR_HIDE, false)
	self:UnregisterTrigger()
	self:FadeOutAimIK(function()
		self:FinishExitTimelineAimIKStatus()

		self.statusMode = nil
	end, arg_18_1)
end

function AimIKSystem:FadeOutAimIK(arg_20_1, arg_20_2)
	if arg_20_2 then
		self:InvalidateExitProcess()
		self:StopWeightLerp()

		self.headAimIKComp.weight = 0
		self.stickAimComp.weight = 0

		existCall(arg_20_1)
	else
		self.cachedDampTime = self.cachedDampTime or {
			self.headAimIKComp.DampTime,
			self.stickAimComp.rotateDampTime,
			self.stickAimComp.followDampTime
		}

		local var_20_0 = self.headAimIKComp.weight

		self:InvalidateExitProcess()

		self.inExitProcessing = true

		local var_20_1 = self.exitProcessToken

		self:SetDampTime({
			0,
			0,
			0
		})
		self:LerpAimWeight(var_20_0, 0, self.config.fade_out, function()
			if not self:IsExitProcessValid(var_20_1) then
				return
			end

			self.inExitProcessing = false

			existCall(arg_20_1)
		end)
	end
end

function AimIKSystem:ForceExitTimelineAimIKStatus()
	if self.statusMode ~= "timeline" or not self.inStatus and not self.inExitProcessing then
		return
	end

	self:ExitTimelineAimIKStatus(true)
end

function AimIKSystem:FinishExitTimelineAimIKStatus()
	self:StopWeightLerp()

	if self.cachedDampTime then
		self:SetDampTime(self.cachedDampTime)
	end

	if self.headAimIKComp then
		self.headAimIKComp.weight = 0
	end

	if self.stickAimComp then
		self.stickAimComp.weight = 0

		if self.hasAimIKBinding then
			self.stickAimComp.bindTransform = self.cachedBindTransform
		end
	end

	if not IsNil(self.configRoot) then
		setActive(self.configRoot, false)
	end

	self.cachedDampTime = nil
	self.cachedBindTransform = nil
	self.hasAimIKBinding = false
end

function AimIKSystem:InitAimIKComponents(arg_24_1, arg_24_2, arg_24_3)
	assert(not IsNil(arg_24_2), "AimIK character not found")
	assert(not IsNil(arg_24_3), "AimIK item not found: " .. tostring(arg_24_1.item_path))
	assert(type(arg_24_1.fade_in) == "number" and arg_24_1.fade_in >= 0, "Invalid AimIK fade_in")
	assert(type(arg_24_1.fade_out) == "number" and arg_24_1.fade_out >= 0, "Invalid AimIK fade_out")

	local var_24_0 = arg_24_2:Find("AimIKLayers/" .. arg_24_1.layer_config)

	assert(not IsNil(var_24_0), "AimIK config root not found: " .. arg_24_1.layer_config)

	local var_24_1 = var_24_0:Find("plane")
	local var_24_2 = var_24_0:Find("headAim")
	local var_24_3 = var_24_0:Find("stickAim")

	assert(not IsNil(var_24_1) and not IsNil(var_24_2) and not IsNil(var_24_3), "AimIK layer nodes missing")

	local var_24_4 = var_24_1:GetComponent(typeof(CanvasRectDragTarget))
	local var_24_5 = var_24_2:GetComponent(typeof(HeadAimIKHotfix))
	local var_24_6 = var_24_3:GetComponent(typeof(StickAim))

	assert(not IsNil(var_24_4) and not IsNil(var_24_5) and not IsNil(var_24_6), "AimIK layer components missing")
	assert(not IsNil(var_24_4.target), "AimIK drag target missing")

	self.config, self.character, self.configRoot = arg_24_1, arg_24_2, var_24_0
	self.dragGo, self.dragComp = var_24_1, var_24_4
	self.headAimIKGo, self.headAimIKComp = var_24_2, var_24_5
	self.stickAimGo, self.stickAimComp = var_24_3, var_24_6
	self.stickSceneGo = arg_24_3.gameObject
	self.cachedBindTransform = var_24_6.bindTransform
	self.hasAimIKBinding = true
	var_24_6.bindTransform = arg_24_3
end

function AimIKSystem:UnregisterTrigger()
	if not self.triggerAction or not self.dragComp then
		return
	end

	if self.statusMode == "touch" then
		self.dragComp:UnregisterOnDragOutOfUI(self.triggerAction)
	else
		self.dragComp:UnregisterOnTargetReachBoundary(self.triggerAction)
	end

	self.triggerAction = nil
end

function AimIKSystem:IsTouchProcessValid(arg_26_1)
	return self.statusMode == "touch" and self.touchProcessToken == arg_26_1
end

function AimIKSystem:EnterTouchAimIKStatus(arg_27_1)
	if self.statusMode or self.inExitProcessing then
		return
	end

	local var_27_0 = pg.dorm3d_aim_ik_touch[arg_27_1]

	assert(pg.dorm3d_aim_ik_touch[arg_27_1], "Missing dorm3d_aim_ik_touch config: " .. tostring(arg_27_1))

	local var_27_1 = self:GetCurrentLadyEnv()

	assert(var_27_1, "Touch AimIK character not found")
	assert(self:GetApartment():GetConfigID() == var_27_0.character_id, "Touch AimIK character mismatch")
	assert(var_27_1.skinId == var_27_0.skin_id, "Touch AimIK skin mismatch")
	assert(type(var_27_0.item_path) == "string" and var_27_0.item_path ~= "", "Touch AimIK item_path is empty")
	assert(pg.dorm3d_dialogue_group[var_27_0.trigger_talk], "Touch AimIK feedback dialogue missing")

	local var_27_2 = self:GetSceneItem(var_27_0.item_path)

	self:InitAimIKComponents(var_27_0, var_27_1.lady, var_27_2)

	local var_27_3 = self:GetIKPointByName(var_27_0.character_position)

	assert(not IsNil(var_27_3) and not IsNil(var_27_3:Find("StayPoint")), "Touch AimIK StayPoint missing")

	local var_27_4 = self:GetCameraRoot():Find(var_27_0.camera)

	assert(not IsNil(var_27_4), "Touch AimIK camera missing: " .. var_27_0.camera)

	self.statusMode, self.touchState, self.inStatus = "touch", "entering", true
	self.touchProcessToken = self.touchProcessToken + 1

	local var_27_5 = self.touchProcessToken

	self.ladyEnv = var_27_1
	self.mainCamera = self:GetMainCameraTF():GetComponent(typeof(Camera))
	self.touchExitRequested = false
	self.touchExitCallbacks = {}

	self:Emit(RoomIKSystem.ENTER_AIMIK_IK_MODE, function()
		if not self:IsTouchProcessValid(var_27_5) then
			return
		end

		self:Emit(Dorm3dRoomScene.EXTRA_SET_UI, function()
			if not self:IsTouchProcessValid(var_27_5) then
				return
			end

			self:ResetTouchLady()
			self:Emit(Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA_BY_NAME, var_27_0.camera)

			local var_29_0 = var_27_4:GetComponent(typeof(Cinemachine.CinemachineFreeLook))

			if var_29_0 then
				self:Emit(Dorm3dRoomTemplateScene.EXTRA_REGISTER_ORBITS, var_29_0)
			end

			self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_SCENE_ANIM, var_27_0.enter_scene_anim)
			self:Emit(Dorm3dRoomTemplateScene.EXTRA_PLAY_ENTER_EXTRA_ITEM, var_27_1, var_27_0.enter_extra_item)
			self:Emit(Dorm3dRoomTemplateScene.EXTRA_HIDE_SCENE_ITEM, var_27_0.hide_scene_item)

			self.touchItemPosition, self.touchItemRotation = var_27_2.localPosition, var_27_2.localRotation

			setActive(var_27_1.ladyCollider, false)
			_.each(var_27_1.ladyTouchColliders, function(arg_30_0)
				setActive(arg_30_0, false)
			end)

			self.touchState = "recovering"

			if self.touchExitRequested then
				self:ExitTouchAimIKStatus(true)
			else
				self:EnableTouchAimIK(var_27_5)
			end
		end, "aimik")
	end)
end

function AimIKSystem:ResetTouchLady()
	local var_31_0 = self:GetIKPointByName(self.config.character_position):Find("StayPoint")

	self.ladyEnv:SetPosition(var_31_0.position)
	self.ladyEnv:SetRotation(var_31_0.rotation)
	self.ladyEnv:PlaySingleAction(self.config.character_action)
end

function AimIKSystem:ResetTouchItem()
	if self.touchItemPosition and not IsNil(self.stickSceneGo) then
		self.stickSceneGo.transform.localPosition = self.touchItemPosition
		self.stickSceneGo.transform.localRotation = self.touchItemRotation
	end
end

function AimIKSystem:EnableTouchAimIK(arg_33_1)
	if not self:IsTouchProcessValid(arg_33_1) then
		return
	end

	if self.cachedDampTime then
		self:SetDampTime(self.cachedDampTime)

		self.cachedDampTime = nil
	end

	self.headAimIKComp.weight, self.stickAimComp.weight = 0, 0

	setActive(self.configRoot, false)
	setActive(self.configRoot, true)
	self:Emit(Dorm3dAimIKView.BIND_DRAG_AREA, self.dragComp)
	self:LerpAimWeight(0, 1, self.config.fade_in, function()
		if not self:IsTouchProcessValid(arg_33_1) then
			return
		end

		self.touchState, self.inputEnabled = "active", true
		self.triggerAction = System.Action(function()
			self:TriggerTouchFeedback()
		end)

		self.dragComp:RegisterOnDragOutOfUI(self.triggerAction)
		self:Emit(Dorm3dAimIKView.SHOW_OR_HIDE, true, true)
	end)
end

function AimIKSystem:TriggerTouchFeedback()
	if self.touchState ~= "active" or not self.inputEnabled then
		return
	end

	local var_36_0 = self.touchProcessToken

	self.touchState, self.inputEnabled = "feedback", false

	self.dragComp:OnPointerUp(nil)
	self:UnregisterTrigger()
	self:Emit(Dorm3dAimIKView.SHOW_OR_HIDE, false)
	self:FadeOutAimIK(function()
		if not self:IsTouchProcessValid(var_36_0) then
			return
		end

		setActive(self.configRoot, false)
		self:ResetTouchItem()
		self:ResetTouchLady()

		self.touchState = "story"

		self:Emit(Dorm3dRoomScene.EXTRA_DO_TALK, self.config.trigger_talk, function()
			if not self:IsTouchProcessValid(var_36_0) then
				return
			end

			self.touchState = "recovering"

			if self.touchExitRequested then
				self:ExitTouchAimIKStatus(true)
			else
				self:ResetTouchLady()
				self:ResetTouchItem()
				self:Emit(Dorm3dRoomTemplateScene.EXTRA_ACTIVE_CAMERA_BY_NAME, self.config.camera)
				self:EnableTouchAimIK(var_36_0)
			end
		end)
	end)
end

function AimIKSystem:ExitTouchAimIKStatus(arg_39_1, arg_39_2)
	if self.statusMode ~= "touch" then
		existCall(arg_39_2)

		return
	end

	if arg_39_2 then
		table.insert(self.touchExitCallbacks, arg_39_2)
	end

	self.touchExitRequested = true

	if self.touchState == "entering" or self.touchState == "story" or self.touchState == "exiting" then
		return
	end

	self.touchState, self.inputEnabled, self.inStatus = "exiting", false, false

	local var_39_0 = self.touchProcessToken

	self.dragComp:OnPointerUp(nil)
	self:UnregisterTrigger()
	self:Emit(Dorm3dAimIKView.SHOW_OR_HIDE, false)
	self:FadeOutAimIK(function()
		if not self:IsTouchProcessValid(var_39_0) then
			return
		end

		self:ResetTouchItem()
		self:FinishExitTimelineAimIKStatus()
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_SCENE_ITEM_ANIMATORS)
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_CHARACTER_EXTRA_ITEM)
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_RESET_TEMP_HIDE_SCENE_ITEMS)
		self:Emit(Dorm3dRoomTemplateScene.EXTRA_REVERT_CAMERA_ORBIT)
		self:Emit(Dorm3dRoomScene.EXTRA_SET_UI, function()
			if not self:IsTouchProcessValid(var_39_0) then
				return
			end

			self:Emit(RoomIKSystem.EXIT_AIMIK_IK_MODE, function()
				if not self:IsTouchProcessValid(var_39_0) then
					return
				end

				self.statusMode, self.touchState = nil
				self.touchItemPosition, self.touchItemRotation = nil
				self.touchExitCallbacks, self.touchExitRequested = nil

				for iter_42_0, iter_42_1 in ipairs(self.touchExitCallbacks) do
					iter_42_1()
				end
			end)
		end, "back")
	end, arg_39_1)
end

function AimIKSystem:InvalidateExitProcess()
	self.exitProcessToken = (self.exitProcessToken or 0) + 1
	self.inExitProcessing = false
end

function AimIKSystem:IsExitProcessValid(arg_44_1)
	return self.inExitProcessing and self.exitProcessToken == arg_44_1
end

function AimIKSystem:OnBeginDrag(arg_45_1, arg_45_2)
	if not self.inputEnabled or not arg_45_2 then
		return
	end

	self.dragComp:OnPointerDown(arg_45_2)
end

function AimIKSystem:OnDrag(arg_46_1, arg_46_2)
	if not self.inputEnabled or not arg_46_2 then
		return
	end

	self.dragComp:OnDrag(arg_46_2)
end

function AimIKSystem:OnEndDrag(arg_47_1, arg_47_2)
	if not self.inputEnabled then
		return
	end

	self.dragComp:OnPointerUp(arg_47_2)
end

function AimIKSystem:GetTipShowInfo(arg_48_1)
	local var_48_0 = {}

	if not self.inputEnabled or IsNil(self.stickSceneGo) then
		if arg_48_1 then
			table.insert(arg_48_1, var_48_0)
		end

		return var_48_0
	end

	local var_48_1 = {}

	self:Emit(Dorm3dRoomTemplateScene.EXTRA_GET_SCREEN_POSITION, var_48_1, self.stickSceneGo.transform.position, self.mainCamera)
	table.insert(var_48_0, {
		pos = var_48_1.value
	})

	if arg_48_1 then
		table.insert(arg_48_1, var_48_0)
	end

	return var_48_0
end

function AimIKSystem:StopWeightLerp()
	if not self.weightLerpTweenId then
		return
	end

	if LeanTween.isTweening(self.weightLerpTweenId) then
		LeanTween.cancel(self.weightLerpTweenId)
	end

	self.weightLerpTweenId = nil
end

function AimIKSystem:LerpAimWeight(arg_50_1, arg_50_2, arg_50_3, arg_50_4)
	self:StopWeightLerp()

	local function var_50_0(arg_51_0)
		self.headAimIKComp.weight = arg_51_0
		self.stickAimComp.weight = arg_51_0
	end

	var_50_0(arg_50_1)

	if arg_50_3 <= 0 then
		var_50_0(arg_50_2)
		existCall(arg_50_4)

		return
	end

	self.weightLerpTweenId = LeanTween.value(go(self.configRoot), arg_50_1, arg_50_2, arg_50_3):setEase(LeanTweenType.easeInOutSine):setOnUpdate(System.Action_float(function(arg_52_0)
		var_50_0(arg_52_0)
	end)):setOnComplete(System.Action(function()
		self.weightLerpTweenId = nil

		var_50_0(arg_50_2)

		if arg_50_4 then
			arg_50_4()
		end
	end)).uniqueId
end

function AimIKSystem:SetDampTime(arg_54_1)
	self.headAimIKComp.DampTime = arg_54_1[1]
	self.stickAimComp.rotateDampTime = arg_54_1[2]
	self.stickAimComp.followDampTime = arg_54_1[3]
end

return AimIKSystem
