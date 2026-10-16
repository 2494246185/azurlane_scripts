local NewFrameTemplatePage = class("NewFrameTemplatePage", import("view.base.BaseActivityPage"))

function NewFrameTemplatePage:OnInit()
	self.bg = self._tf:Find("AD")
	self.battleBtn = self.bg:Find("battle_btn")
	self.getBtn = self.bg:Find("get_btn")
	self.gotBtn = self.bg:Find("got_btn")
	self.switchBtn = self._tf:Find("AD/switch_btn")
	self.phases = {
		self._tf:Find("AD/switcher/phase1"),
		self._tf:Find("AD/switcher/phase2")
	}
	self.bar = self._tf:Find("AD/switcher/phase2/Image/barContent/bar")
	self.cur = self._tf:Find("AD/switcher/phase2/Image/step")
	self.target = self._tf:Find("AD/switcher/phase2/Image/progress")
	self.gotTag = self._tf:Find("AD/switcher/phase2/Image/got")
end

function NewFrameTemplatePage:OnDataSetting()
	self.avatarConfig = pg.activity_event_avatarframe[self.activity:getConfig("config_id")]

	if self.avatarConfig.start_time == "stop" then
		self.timeStamp = nil
	else
		self.timeStamp = pg.TimeMgr.GetInstance():parseTimeFromConfig(self.avatarConfig.start_time)
	end
end

function NewFrameTemplatePage:OnFirstFlush()
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.TASK)
	end, SFX_PANEL)
	onButton(self, self.getBtn, function()
		self:emit(ActivityMediator.EVENT_OPERATION, {
			cmd = 1,
			activity_id = self.activity.id
		})
	end, SFX_PANEL)
	onToggle(self, self.switchBtn, function(arg_6_0)
		if self.isSwitching then
			return
		end

		self:Switch(arg_6_0)
	end, SFX_PANEL)
	self:CheckSwitch2Phase2()

	if not IsNil(self.gotTag:Find("Text")) then
		setText(self.gotTag:Find("Text"), i18n("avatarframe_got"))
	end
end

function NewFrameTemplatePage:CheckSwitch2Phase2(...)
	self.inPhase2 = self.timeStamp and pg.TimeMgr.GetInstance():GetServerTime() - self.timeStamp > 0

	triggerToggle(self.switchBtn, self.inPhase2)
end

function NewFrameTemplatePage:OnUpdateFlush()
	local var_8_0 = self.activity.data1
	local var_8_1 = self.avatarConfig.target

	var_8_0 = self.avatarConfig.target < self.activity.data1 and var_8_1 or var_8_0

	local var_8_2 = var_8_0 / var_8_1

	setText(self.cur, var_8_0 / var_8_1 >= 1 and var_8_0 or var_8_0)
	setText(self.target, "/" .. var_8_1)
	setFillAmount(self.bar, var_8_2)

	local var_8_3 = var_8_1 <= var_8_0
	local var_8_4 = self.activity.data2 >= 1

	setActive(self.battleBtn, self.inPhase2 and not var_8_3)
	setActive(self.getBtn, self.inPhase2 and not var_8_4 and var_8_3)
	setActive(self.gotBtn, self.inPhase2 and var_8_4)
	setActive(self.gotTag, self.inPhase2 and var_8_4)
	setActive(self.cur, not var_8_4)
	setActive(self.target, not var_8_4)
end

function NewFrameTemplatePage:Switch(arg_9_1)
	self.isSwitching = true

	setToggleEnabled(self.switchBtn, false)

	local var_9_0
	local var_9_1

	if arg_9_1 then
		var_9_1 = self.phases[2]
		var_9_0 = self.phases[1]
	else
		var_9_1 = self.phases[1]
		var_9_0 = self.phases[2]
	end

	local var_9_2 = GetOrAddComponent(var_9_0, typeof(CanvasGroup))

	var_9_1:SetAsLastSibling()
	setActive(var_9_0:Find("Image"), false)
	LeanTween.moveLocal(go(var_9_0), var_9_1.localPosition, 0.4):setOnComplete(System.Action(function()
		setActive(var_9_0:Find("label"), true)
	end))
	LeanTween.value(go(var_9_0), 0, 1, 0.4):setOnUpdate(System.Action_float(function(arg_11_0)
		var_9_2.alpha = arg_11_0
	end))
	setActive(var_9_1:Find("Image"), true)

	local var_9_3 = GetOrAddComponent(var_9_1, typeof(CanvasGroup))

	LeanTween.value(go(var_9_1), 0, 1, 0.4):setOnUpdate(System.Action_float(function(arg_12_0)
		var_9_3.alpha = arg_12_0
	end))
	setActive(var_9_1:Find("label"), false)
	LeanTween.moveLocal(go(var_9_1), var_9_0.localPosition, 0.4):setOnComplete(System.Action(function()
		self.isSwitching = nil

		setToggleEnabled(self.switchBtn, true)
	end))
end

return NewFrameTemplatePage
