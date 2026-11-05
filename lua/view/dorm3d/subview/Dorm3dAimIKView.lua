local Dorm3dAimIKView = class("Dorm3dAimIKView", import("view.dorm3d.Game.Dorm3dGameBaseSubView"))

Dorm3dAimIKView.TIP_WAIT_TIME = 5
Dorm3dAimIKView.BIND_DRAG_AREA = "Dorm3dAimIKView.BindDragArea"
Dorm3dAimIKView.SHOW_OR_HIDE = "Dorm3dAimIKView.ShowOrHide"

function Dorm3dAimIKView:Init()
	self.controlTF = self._tf:Find("AimIKControl")
	self.uiTF = self._tf:Find("UI/aimik")

	assert(not IsNil(self.controlTF) and not IsNil(self.uiTF), "AimIKControl or UI/aimik missing")

	self.tipTF = self.controlTF:Find("Tips")
	self.layer = self.controlTF:Find("ControlLayer")
	self.controller = self.layer:GetComponent(typeof(SlideController))
	self.backTF = self.uiTF:Find("btn_back")

	assert(not IsNil(self.backTF), "UI/aimik/btn_back missing")
	onButton(self, self.backTF, function()
		self:emit(AimIKSystem.EXIT_TOUCH_AIMIK_STATUS)
	end, SFX_CANCEL)
	self:InitDragEvent()
	self:InitHint()
	self:Hide()
	self:bind(Dorm3dAimIKView.BIND_DRAG_AREA, function(arg_3_0, arg_3_1)
		arg_3_1.dragArea = self.layer
	end)
	self:bind(Dorm3dAimIKView.SHOW_OR_HIDE, function(arg_4_0, arg_4_1, arg_4_2)
		if arg_4_1 then
			self:Show(arg_4_2)
		else
			self:Hide()
		end
	end)
end

function Dorm3dAimIKView:InitDragEvent()
	self.controller:AddBeginDragFunc(function(arg_6_0, arg_6_1)
		if not self.showing or not arg_6_1 then
			return
		end

		setActive(self.tipTF, false)
		self.timer:Stop()
		self:emit(AimIKSystem.ON_BEGIN_DRAG, arg_6_0, arg_6_1)
	end)
	self.controller:AddDragFunc(function(arg_7_0, arg_7_1)
		if not self.showing or not arg_7_1 then
			return
		end

		self:emit(AimIKSystem.ON_DRAG, arg_7_0, arg_7_1)
	end)
	self.controller:AddDragEndFunc(function(arg_8_0, arg_8_1)
		if self.showing then
			self.timer:Start()
		end

		self:emit(AimIKSystem.ON_END_DRAG, arg_8_0, arg_8_1)
	end)
end

function Dorm3dAimIKView:InitHint()
	self.time = Dorm3dAimIKView.TIP_WAIT_TIME
	self.timer = Timer.New(function()
		if self.time <= 0 then
			self.time = Dorm3dAimIKView.TIP_WAIT_TIME

			if isActive(self.tipTF) == false then
				setActive(self.tipTF, true)
				self:FlushHint()
			end
		else
			self.time = self.time - 0.1
		end
	end, 0.1, -1)
end

function Dorm3dAimIKView:FlushHint()
	local var_11_0 = {}

	self:emit(AimIKSystem.GET_TIP_SHOW_INFO, var_11_0)

	local var_11_1 = var_11_0[1] or {}

	UIItemList.StaticAlign(self.tipTF, self.tipTF:GetChild(0), #var_11_1, function(arg_12_0, arg_12_1, arg_12_2)
		if arg_12_0 ~= UIItemList.EventUpdate then
			return
		end

		arg_12_1 = arg_12_1 + 1

		setLocalPosition(arg_12_2, LuaHelper.ScreenToLocal(self.tipTF, var_11_1[arg_12_1].pos, pg.UIMgr.GetInstance().uiCameraComp))
	end)
end

function Dorm3dAimIKView:Show(arg_13_1)
	self.showing = true

	setActive(self.backTF, tobool(arg_13_1))
	setActive(self.controlTF, true)
	setActive(self.uiTF, tobool(arg_13_1))
	self.timer:Start()
end

function Dorm3dAimIKView:Hide()
	self.showing = false

	setActive(self.tipTF, false)
	setActive(self.controlTF, false)
	setActive(self.uiTF, false)
	self.timer:Stop()

	self.time = Dorm3dAimIKView.TIP_WAIT_TIME
end

function Dorm3dAimIKView:Dispose()
	self:Hide()
	Dorm3dAimIKView.super.Dispose(self)
end

return Dorm3dAimIKView
