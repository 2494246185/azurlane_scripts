local CrossRoadMenuUI = class("CrossRoadMenuUI")

function CrossRoadMenuUI:Ctor(arg_1_1, arg_1_2, arg_1_3)
	self._tf = arg_1_1
	self._event = arg_1_2
	self._gameVo = arg_1_3
	self.totalTimes = self._gameVo:GetTotalTimes()

	self:initUI()
end

function CrossRoadMenuUI:initUI()
	self.menuUI = findTF(self._tf, "ui/menuUI")
	self.ui = findTF(self.menuUI, "ui")

	onButton(self._event, findTF(self.menuUI, "ui/btnBack"), function()
		self:Show(false)
		self._event:emit(SimpleMGEvent.CLOSE_GAME)
	end, SFX_CANCEL)

	self.btnRule = findTF(self.menuUI, "ui/btnRule")

	onButton(self._event, self.btnRule, function()
		self._event:emit(SimpleMGEvent.SHOW_RULE, true)
	end, SFX_CANCEL)

	self.btnStart = findTF(self.menuUI, "ui/btnStart")

	onButton(self._event, self.btnStart, function()
		self:Show(false)
		self._event:emit(SimpleMGEvent.READY_START)
	end, SFX_CANCEL)
end

function CrossRoadMenuUI:Show(arg_6_1)
	local var_6_0 = pg.UIMgr.GetInstance()

	if arg_6_1 then
		setActive(self.menuUI, true)
		var_6_0:BlurPanel(self.menuUI)
	else
		var_6_0:UnOverlayPanel(self.menuUI, self._tf)
		setActive(self.menuUI, false)
	end
end

function CrossRoadMenuUI:Update()
	return
end

return CrossRoadMenuUI
