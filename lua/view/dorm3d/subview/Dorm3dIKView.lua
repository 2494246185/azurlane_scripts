local Dorm3dIKView = class("Dorm3dIKView", import("view.dorm3d.Game.Dorm3dGameBaseSubView"))

Dorm3dIKView.SET_CONTROL_ACTIVE = "Dorm3dIKView.SET_CONTROL_ACTIVE"
Dorm3dIKView.SET_CAMERA_BUTTON_ACTIVE = "Dorm3dIKView.SET_CAMERA_BUTTON_ACTIVE"
Dorm3dIKView.RESET_ENTRY_MENU = "Dorm3dIKView.RESET_ENTRY_MENU"
Dorm3dIKView.SET_BACK_BUTTON_ACTIVE = "Dorm3dIKView.SET_BACK_BUTTON_ACTIVE"
Dorm3dIKView.UPDATE_TEXT_TIPS = "Dorm3dIKView.UPDATE_TEXT_TIPS"
Dorm3dIKView.UPDATE_TIPS = "Dorm3dIKView.UPDATE_TIPS"
Dorm3dIKView.SET_TIPS_ACTIVE = "Dorm3dIKView.SET_TIPS_ACTIVE"
Dorm3dIKView.SET_HAND_POSITION = "Dorm3dIKView.SET_HAND_POSITION"
Dorm3dIKView.PLAY_HAND_BEGIN = "Dorm3dIKView.PLAY_HAND_BEGIN"
Dorm3dIKView.PLAY_HAND_END = "Dorm3dIKView.PLAY_HAND_END"
Dorm3dIKView.UPDATE_HOLD_PROGRESS = "Dorm3dIKView.UPDATE_HOLD_PROGRESS"

function Dorm3dIKView:Init()
	self.uiContainer = self._tf:Find("UI")
	self.rtIKUI = self.uiContainer:Find("ik")
	self.ikControlUI = self._tf:Find("IKControl")
	self.controlLayer = self.ikControlUI:Find("ControlLayer")

	self:InitIKControlRoots()
	self:InitButtons()
	self:InitDragEvent()
	self:InitEvents()
end

function Dorm3dIKView:InitIKControlRoots()
	self.ikTipsRoot = self.ikControlUI:Find("Tips")

	setActive(self.ikTipsRoot, false)

	self.ikTouchTipsRoot = self.ikControlUI:Find("TouchTips")

	assert(not IsNil(self.ikTouchTipsRoot), "Missing IKControl/TouchTips")
	setActive(self.ikTouchTipsRoot, false)

	self.ikTouchTipTpl = self.ikTouchTipsRoot:Find("tpl")

	assert(not IsNil(self.ikTouchTipTpl), "Missing IKControl/TouchTips/tpl")
	assert(not IsNil(self.ikTouchTipTpl:Find("Click")) and not IsNil(self.ikTouchTipTpl:Find("Hold")), "TouchTips/tpl missing Click or Hold")
	setActive(self.ikTouchTipTpl, false)

	self.holdProgressRoot = self.ikControlUI:Find("HoldProgress")

	assert(not IsNil(self.holdProgressRoot), "Missing IKControl/HoldProgress")

	self.holdProgressTpl = self.holdProgressRoot:Find("tpl")

	assert(not IsNil(self.holdProgressTpl), "Missing IKControl/HoldProgress/tpl")
	setActive(self.holdProgressRoot, false)
	setActive(self.holdProgressTpl, false)

	self.ikHand = self.ikControlUI:Find("Handler")

	setActive(self.ikHand, false)
	eachChild(self.ikHand, function(arg_3_0)
		setActive(arg_3_0, false)
	end)

	self.ikTextTipsRoot = self.ikControlUI:Find("TextTips")

	setActive(self.ikTextTipsRoot, false)
	eachChild(self.ikTextTipsRoot, function(arg_4_0)
		setActive(arg_4_0, false)
	end)
	setActive(self.ikControlUI, false)
end

function Dorm3dIKView:InitButtons()
	onButton(self, self.rtIKUI:Find("btn_back/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("roll_gametip")
		})
	end, SFX_PANEL)
	onButton(self, self.rtIKUI:Find("Right/btn_camera"), function()
		self:emit(RoomIKSystem.CYCLE_IK_CAMERA_GROUP)
	end, SFX_PANEL)
	onButton(self, self.rtIKUI:Find("Right/MenuSmall"), function()
		setActive(self.rtIKUI:Find("Right/MenuSmall"), false)
		setActive(self.rtIKUI:Find("Right/Menu"), true)
	end, SFX_PANEL)
	onButton(self, self.rtIKUI:Find("Right/Menu/Collapse"), function()
		setActive(self.rtIKUI:Find("Right/Menu"), false)
		setActive(self.rtIKUI:Find("Right/MenuSmall"), true)
	end, SFX_PANEL)
	onButton(self, self.rtIKUI:Find("Right/Menu"), function()
		setActive(self.rtIKUI:Find("Right"), false)
		self:emit(Dorm3dRoomMediator.OPEN_SKIN_SELECT_LAYER, self.contextData.GetApartment():GetConfigID(), self.contextData.GetCurrentLadyEnv(), function(arg_11_0, arg_11_1, arg_11_2)
			self:emit(RoomIKSystem.SWITCH_IK_SKIN, arg_11_0, arg_11_1, arg_11_2)
		end, function()
			setActive(self.rtIKUI:Find("Right"), true)
		end, true)
	end, SFX_PANEL)
end

function Dorm3dIKView:InitDragEvent()
	local var_13_0 = self.controlLayer:GetComponent(typeof(SlideController))

	if var_13_0 and not IsNil(var_13_0) then
		var_13_0:ClearEvents()

		var_13_0.enabled = false
	end

	local var_13_1 = GetOrAddComponent(self.controlLayer, typeof(SlideControllerHotfix))

	var_13_1:ClearEvents()

	self.ikSlideController = var_13_1

	var_13_1:AddPointDownFunc(function(arg_14_0, arg_14_1)
		self:emit(RoomIKSystem.ON_CONTROL_POINTER_DOWN, arg_14_1.position)
	end)
	var_13_1:AddPointUpFunc(function(arg_15_0, arg_15_1)
		self:emit(RoomIKSystem.ON_CONTROL_POINTER_UP, arg_15_1.position)
	end)
	var_13_1:AddBeginDragFunc(function(arg_16_0, arg_16_1)
		self:emit(RoomIKSystem.ON_CONTROL_BEGIN_DRAG, arg_16_1.position)
	end)
	var_13_1:AddDragFunc(function(arg_17_0, arg_17_1)
		self:emit(RoomIKSystem.ON_CONTROL_DRAG, arg_17_1.position, arg_17_1.delta)
	end)
	var_13_1:AddDragEndFunc(function(arg_18_0, arg_18_1)
		self:emit(RoomIKSystem.ON_CONTROL_END_DRAG, arg_18_1.position)
	end)
end

function Dorm3dIKView:InitEvents()
	self:bind(Dorm3dIKView.SET_CONTROL_ACTIVE, function(arg_20_0, arg_20_1)
		setActive(self.ikControlUI, arg_20_1)

		if not arg_20_1 then
			self:ResetHand()
			self:ResetHoldProgress()
		end
	end)
	self:bind(Dorm3dIKView.SET_CAMERA_BUTTON_ACTIVE, function(arg_21_0, arg_21_1)
		setActive(self.rtIKUI:Find("Right/btn_camera"), arg_21_1)
	end)
	self:bind(Dorm3dIKView.RESET_ENTRY_MENU, function(arg_22_0, arg_22_1)
		setActive(self.rtIKUI:Find("Right/MenuSmall"), arg_22_1)
		setActive(self.rtIKUI:Find("Right/Menu"), false)
	end)
	self:bind(Dorm3dIKView.SET_BACK_BUTTON_ACTIVE, function(arg_23_0, arg_23_1)
		setActive(self.rtIKUI:Find("btn_back"), arg_23_1)
	end)
	self:bind(Dorm3dIKView.UPDATE_TEXT_TIPS, function(arg_24_0, arg_24_1)
		self:UpdateTextTips(arg_24_1)
	end)
	self:bind(Dorm3dIKView.UPDATE_TIPS, function(arg_25_0, arg_25_1, arg_25_2, arg_25_3)
		self:UpdateTips(arg_25_1, arg_25_2, arg_25_3)
	end)
	self:bind(Dorm3dIKView.SET_TIPS_ACTIVE, function(arg_26_0, arg_26_1)
		self:SetTipsActive(arg_26_1)
	end)
	self:bind(Dorm3dIKView.SET_HAND_POSITION, function(arg_27_0, arg_27_1)
		setAnchoredPosition(self.ikHand, arg_27_1)
	end)
	self:bind(Dorm3dIKView.PLAY_HAND_BEGIN, function()
		self:PlayHandBegin()
	end)
	self:bind(Dorm3dIKView.PLAY_HAND_END, function()
		self:PlayHandEnd()
	end)
	self:bind(Dorm3dIKView.UPDATE_HOLD_PROGRESS, function(arg_30_0, arg_30_1, arg_30_2, arg_30_3)
		self:UpdateHoldProgress(arg_30_1, arg_30_2, arg_30_3)
	end)
end

function Dorm3dIKView:UpdateTextTips(arg_31_1)
	eachChild(self.ikTextTipsRoot, function(arg_32_0)
		setActive(arg_32_0, false)
	end)
	_.each(arg_31_1 or {}, function(arg_33_0)
		local var_33_0 = self.ikTextTipsRoot:Find(arg_33_0)

		if not IsNil(var_33_0) then
			setActive(var_33_0, true)
		end
	end)
end

function Dorm3dIKView:SetTipsActive(arg_34_1)
	if arg_34_1 and self.holdProgressActive then
		arg_34_1 = false
	end

	setActive(self.ikTipsRoot, arg_34_1)
	setActive(self.ikTouchTipsRoot, arg_34_1)
	setActive(self.ikTextTipsRoot, arg_34_1)
end

function Dorm3dIKView:UpdateHoldProgress(arg_35_1, arg_35_2, arg_35_3)
	if not arg_35_1 then
		self:ResetHoldProgress()

		return
	end

	self.holdProgressActive = true

	self:SetTipsActive(false)
	setActive(self.holdProgressRoot, true)
	setActive(self.holdProgressTpl, true)
	setLocalPosition(self.holdProgressTpl, LuaHelper.ScreenToLocal(self.holdProgressRoot, arg_35_2, pg.UIMgr.GetInstance().uiCameraComp))

	local var_35_0 = self.holdProgressTpl:Find("Progress")

	if IsNil(var_35_0) then
		var_35_0 = self.holdProgressTpl
	end

	local var_35_1 = GetComponent(var_35_0, typeof(Image))

	if not IsNil(var_35_1) then
		var_35_1.fillAmount = math.clamp(arg_35_3 or 0, 0, 1)
	end
end

function Dorm3dIKView:ResetHoldProgress()
	self.holdProgressActive = nil

	setActive(self.holdProgressTpl, false)
	setActive(self.holdProgressRoot, false)
end

function Dorm3dIKView:SetTouchTipType(arg_37_1, arg_37_2)
	local var_37_0 = arg_37_1:Find("Click")
	local var_37_1 = arg_37_1:Find("Hold")

	assert(not IsNil(var_37_0) and not IsNil(var_37_1), "TouchTips/tpl item missing Click or Hold")
	setActive(var_37_0, arg_37_2 == RoomTouchSystem.TRIGGER_CLICK)
	setActive(var_37_1, arg_37_2 == RoomTouchSystem.TRIGGER_LONG_PRESS)
end

function Dorm3dIKView:GetTipLocalPosition(arg_38_1, arg_38_2)
	if not arg_38_2.active then
		return Vector2.zero
	end

	assert(arg_38_2.screenPosition, "Missing active IK tip screen position")

	return LuaHelper.ScreenToLocal(arg_38_1, arg_38_2.screenPosition, pg.UIMgr.GetInstance().uiCameraComp) + (arg_38_2.offset or Vector2.zero)
end

function Dorm3dIKView:GetIKTipRotation(arg_39_1, arg_39_2)
	local var_39_0 = arg_39_1:PointToNormalized(Vector2.zero)
	local var_39_1 = Vector2.zero

	if var_39_0.x < 0.5 and var_39_0.y < 0.5 then
		var_39_1 = arg_39_1.max
	elseif var_39_0.x >= 0.5 and var_39_0.y < 0.5 then
		var_39_1 = Vector2.New(arg_39_1.xMin, arg_39_1.yMax)
	elseif var_39_0.x < 0.5 and var_39_0.y >= 0.5 then
		var_39_1 = Vector2.New(arg_39_1.xMax, arg_39_1.yMin)
	elseif var_39_0.x >= 0.5 and var_39_0.y >= 0.5 then
		var_39_1 = arg_39_1.min
	end

	if var_39_0.x == 0.5 then
		var_39_1.x = arg_39_2.x < 0 and arg_39_1.xMax or arg_39_1.xMin
	end

	if var_39_0.y == 0.5 then
		var_39_1.y = arg_39_2.y < 0 and arg_39_1.yMax or arg_39_1.yMin
	end

	return Quaternion.LookRotation(Vector3.forward, Vector3.New((var_39_1 - arg_39_1.center).x, (var_39_1 - arg_39_1.center).y, 0))
end

function Dorm3dIKView:UpdateTouchTips(arg_40_1)
	UIItemList.StaticAlign(self.ikTouchTipsRoot, self.ikTouchTipTpl, #(arg_40_1 or {}), function(arg_41_0, arg_41_1, arg_41_2)
		if arg_41_0 ~= UIItemList.EventUpdate then
			return
		end

		arg_41_1 = arg_41_1 + 1

		self:SetTouchTipType(arg_41_2, arg_40_1[arg_41_1].triggerType)
		setLocalPosition(arg_41_2, self:GetTipLocalPosition(self.ikTouchTipsRoot, arg_40_1[arg_41_1]))
		setActive(arg_41_2, arg_40_1[arg_41_1].active)
	end)
end

function Dorm3dIKView:UpdateIKTips(arg_42_1)
	UIItemList.StaticAlign(self.ikTipsRoot, self.ikTipsRoot:GetChild(0), #(arg_42_1 or {}), function(arg_43_0, arg_43_1, arg_43_2)
		if arg_43_0 ~= UIItemList.EventUpdate then
			return
		end

		arg_43_1 = arg_43_1 + 1

		local var_43_0 = arg_42_1[arg_43_1]
		local var_43_1 = self:GetTipLocalPosition(self.ikTipsRoot, arg_42_1[arg_43_1])
		local var_43_2 = arg_42_1[arg_43_1].active and self:GetIKTipRotation(var_43_0.triggerRect, var_43_1) or Quaternion.identity

		setLocalPosition(arg_43_2, var_43_1)
		setLocalRotation(arg_43_2, var_43_2)
		setActive(arg_43_2, var_43_0.active)
	end)
end

function Dorm3dIKView:PlayHandBegin()
	setActive(self.ikHand, true)
	eachChild(self.ikHand, function(arg_45_0)
		setActive(arg_45_0, false)
	end)
	self:StopHandTimer()
	setActive(self.ikHand:Find("Begin"), true)

	self.handTimer = Timer.New(function()
		setActive(self.ikHand:Find("Begin"), false)
		setActive(self.ikHand:Find("Normal"), true)
	end, 0.5, 1)

	self.handTimer:Start()
end

function Dorm3dIKView:ResetHand()
	self:StopHandTimer()
	eachChild(self.ikHand, function(arg_48_0)
		setActive(arg_48_0, false)
	end)
	setActive(self.ikHand, false)
end

function Dorm3dIKView:PlayHandEnd()
	self:StopHandTimer()
	setActive(self.ikHand:Find("Begin"), false)
	setActive(self.ikHand:Find("Normal"), false)
	setActive(self.ikHand:Find("End"), true)

	self.handTimer = Timer.New(function()
		setActive(self.ikHand:Find("End"), false)
		setActive(self.ikHand, false)
	end, 0.5, 1)

	self.handTimer:Start()
end

function Dorm3dIKView:StopHandTimer()
	if not self.handTimer then
		return
	end

	self.handTimer:Stop()

	self.handTimer = nil
end

function Dorm3dIKView:UpdateTips(arg_52_1, arg_52_2, arg_52_3)
	if arg_52_1 then
		self:UpdateIKTips(arg_52_2 or {})
		self:UpdateTouchTips(arg_52_3 or {})
	end

	self:SetTipsActive(arg_52_1)
end

function Dorm3dIKView:Dispose()
	if self.ikSlideController then
		self.ikSlideController:ClearEvents()

		self.ikSlideController = nil
	end

	self:ResetHand()
	self:ResetHoldProgress()
	Dorm3dIKView.super.Dispose(self)
end

return Dorm3dIKView
