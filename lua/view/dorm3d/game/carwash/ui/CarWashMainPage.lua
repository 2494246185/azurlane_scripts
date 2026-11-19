local CarWashMainPage = class("CarWashMainPage", import("view.dorm3d.Game.Dorm3dGameBaseSubView"))

CarWashMainPage.SHOW_BLACK_SCREEN = "CarWashMainPage.SHOW_BLACK_SCREEN"
CarWashMainPage.SHOW_HELP_BOX = "CarWashMainPage.SHOW_HELP_BOX"
CarWashMainPage.SHOW_EXPRESSION_HUD = "CarWashMainPage.SHOW_EXPRESSION_HUD"
CarWashMainPage.ENABLE_BLOCK = "CarWashMainPage.ENABLE_BLOCK"
CarWashMainPage.EXPRESSION_TYPE = {
	LIKE = "LIKE",
	HATE = "HATE"
}

function CarWashMainPage:Init()
	self:InitUI()
	self:BindEvent()
end

function CarWashMainPage:InitUI()
	onButton(self, self._tf:Find("btn_back"), function()
		self:emit(BaseUI.ON_BACK)
	end)
	onButton(self, self._tf:Find("btn_help"), function()
		self:ShowHelpBox()
	end)

	self.expressionRoot = self._tf:Find("expression_root")
	self.expressionLike = self.expressionRoot:Find("vfx_car_aixin01")
	self.expressionHate = self.expressionRoot:Find("vfx_car_xixian01")

	setActive(self.expressionLike, false)
	setActive(self.expressionHate, false)

	self.blockLayer = self._tf:Find("block")

	self:EnableBlock(false)

	self.blackLayer = self._tf:Find("BlackScreen")
	self.povLayer = self._tf:Find("POVControl")

	self:UpdatePOV()
end

function CarWashMainPage:BindEvent()
	self:bind(CarWashMainPage.SHOW_BLACK_SCREEN, self.ShowBlackScreen)
	self:bind(CarWashMainPage.SHOW_HELP_BOX, function(arg_6_0, arg_6_1)
		self:ShowHelpBox(arg_6_1)
	end)
	self:bind(CarWashLadySystem.UPDATE_EXPRESSION_HUD_POSITION, function(arg_7_0, arg_7_1)
		self:UpdateExpressionHUDPosition(arg_7_1)
	end)
	self:bind(CarWashMainPage.SHOW_EXPRESSION_HUD, function(arg_8_0, arg_8_1)
		local var_8_0 = switch(arg_8_1, {
			[CarWashMainPage.EXPRESSION_TYPE.LIKE] = function()
				return self.expressionLike
			end,
			[CarWashMainPage.EXPRESSION_TYPE.HATE] = function()
				return self.expressionHate
			end
		}, function()
			assert(false, "CarWashMainPage: unknown expression type: " .. tostring(arg_8_1))

			return nil
		end)

		setActive(var_8_0, false)
		setActive(var_8_0, true)
	end)
	self:bind(CarWashTimelineSystem.TIMELINE_SEQUENCE_BEGIN, function(arg_12_0, arg_12_1)
		if arg_12_1 and arg_12_1.data and arg_12_1.data.hideUI == false then
			return
		end

		self:SetTimelineUIVisible(false)
	end)
	self:bind(CarWashTimelineSystem.TIMELINE_SEQUENCE_END, function(arg_13_0, arg_13_1)
		if arg_13_1 and arg_13_1.data and arg_13_1.data.hideUI == false then
			return
		end

		self:SetTimelineUIVisible(true)
	end)
	self:bind(CarWashTimelineSystem.TRANSITION_BEGIN, function()
		self:EnableBlock(true)
	end)
	self:bind(CarWashTimelineSystem.TRANSITION_END, function()
		self:EnableBlock(false)
	end)
end

function CarWashMainPage:SetTimelineUIVisible(arg_16_1)
	if arg_16_1 then
		for iter_16_0, iter_16_1 in ipairs(self.timelineUIGroups or {}) do
			iter_16_1.group.alpha = iter_16_1.alpha
			iter_16_1.group.interactable = iter_16_1.interactable
			iter_16_1.group.blocksRaycasts = iter_16_1.blocksRaycasts
		end

		self.timelineUIGroups = nil

		return
	end

	if self.timelineUIGroups then
		return
	end

	self.timelineUIGroups = {}

	eachChild(self._tf, function(arg_17_0)
		if arg_17_0.name == "HolyLightRoot" or arg_17_0.name == "block" then
			return
		end

		local var_17_0 = GetOrAddComponent(arg_17_0, typeof(CanvasGroup))

		table.insert(self.timelineUIGroups, {
			group = var_17_0,
			alpha = var_17_0.alpha,
			interactable = var_17_0.interactable,
			blocksRaycasts = var_17_0.blocksRaycasts
		})

		var_17_0.alpha = 0
		var_17_0.interactable = false
		var_17_0.blocksRaycasts = false
	end)
end

function CarWashMainPage:UpdatePOV()
	local var_18_0 = self.povLayer:Find("Move"):GetComponent(typeof(SlideController))

	var_18_0:AddBeginDragFunc(function(arg_19_0, arg_19_1)
		self:emit(CarWashPovControlSystem.ON_STICK_MOVE_BEGIN, arg_19_1)
	end)
	var_18_0:SetStickFunc(function(arg_20_0)
		self:emit(CarWashPovControlSystem.ON_STICK_MOVE, arg_20_0)
	end)
	var_18_0:AddDragEndFunc(function(arg_21_0, arg_21_1)
		self:emit(CarWashPovControlSystem.ON_STICK_MOVE_END, arg_21_1)
	end)
	self.povLayer:Find("View"):GetComponent(typeof(SlideController)):SetStickFunc(function(arg_22_0)
		self:emit(CarWashPovControlSystem.ON_STICK_VIEW, arg_22_0)
	end)
end

function CarWashMainPage:Flush()
	return
end

function CarWashMainPage:UpdateExpressionHUDPosition(arg_24_1)
	if not arg_24_1 then
		return
	end

	setActive(self.expressionRoot, arg_24_1.visible)

	if arg_24_1.visible then
		setLocalPosition(self.expressionRoot, LuaHelper.ScreenToLocal(self.expressionRoot.parent, arg_24_1.screenPosition, pg.UIMgr.GetInstance().uiCameraComp))
	end
end

function CarWashMainPage:ShowHelpBox(arg_25_1)
	pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_MSGBOX, {
		title = i18n("dorm3d_carwash_title"),
		contentText = i18n("dorm3d_carwash_tiiiiiip"),
		onConfirm = function()
			existCall(arg_25_1)
		end,
		onClose = function()
			existCall(arg_25_1)
		end
	})
end

function CarWashMainPage:EnableBlock(arg_28_1)
	setActive(self.blockLayer, arg_28_1)
end

function CarWashMainPage:ShowBlackScreen(arg_29_1, arg_29_2)
	local var_29_0 = {
		color = "#000000",
		time = 0.3,
		delay = arg_29_1 and 0 or 0.3
	}

	setImageColor(self.blackLayer, Color.NewHex(var_29_0.color))
	setActive(self.blackLayer, true)
	setCanvasGroupAlpha(self.blackLayer, arg_29_1 and 0 or 1)
	self:managedTween(LeanTween.alphaCanvas, function()
		if not arg_29_1 then
			setActive(self.blackLayer, false)
		end

		existCall(arg_29_2)
	end, GetComponent(self.blackLayer, typeof(CanvasGroup)), arg_29_1 and 1 or 0, var_29_0.time):setDelay(var_29_0.delay)
end

return CarWashMainPage
