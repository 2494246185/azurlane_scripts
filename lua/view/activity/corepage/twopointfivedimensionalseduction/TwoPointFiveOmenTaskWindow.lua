local TwoPointFiveOmenTaskWindow = class("TwoPointFiveOmenTaskWindow", import("view.base.BaseSubView"))

TwoPointFiveOmenTaskWindow.SKIP_TYPE_SCENE = 2
TwoPointFiveOmenTaskWindow.SKIP_TYPE_ACTIVITY = 3

function TwoPointFiveOmenTaskWindow:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TwoPointFiveOmenTaskWindow.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
end

function TwoPointFiveOmenTaskWindow:getUIName()
	return "TwoPointFiveOmenTaskWindow"
end

function TwoPointFiveOmenTaskWindow:OnLoaded()
	self.bg = self._tf:Find("bg")
	self.btnClose = self._tf:Find("window/btnClose")

	onButton(self, self.btnClose, function()
		self:Hide()
	end, SOUND_BACK)
	onButton(self, self.bg, function()
		self:Hide()
	end, SOUND_BACK)
end

function TwoPointFiveOmenTaskWindow:OnInit()
	self.page = findTF(self._tf, "window")
	self.list = findTF(self.page, "list/Viewport/Content")
	self.list_tpl = findTF(self.page, "list_tpl")

	setActive(self.list_tpl, false)

	self.uilist = UIItemList.New(self.list, self.list_tpl)

	self.uilist:make(function(arg_7_0, arg_7_1, arg_7_2)
		if arg_7_0 == UIItemList.EventUpdate then
			self:UpdateListItem(arg_7_1, arg_7_2)
		end
	end)

	self.year, self.month, self.day = ChineseCalendar.GetCurrYearMonthDay((pg.TimeMgr.GetInstance():GetServerTime()))
end

function TwoPointFiveOmenTaskWindow:Show(arg_8_1)
	TwoPointFiveOmenTaskWindow.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf, {
		staticBlur = true
	})

	self.activity = arg_8_1
	self.nday = self.activity:getNDay()
	self.taskProxy = getProxy(TaskProxy)
	self.taskGroup = self.activity:getConfig("config_client").unlock_task

	self.uilist:align(#self.taskGroup)
end

function TwoPointFiveOmenTaskWindow:UpdateListItem(arg_9_1, arg_9_2)
	local var_9_0 = findTF(arg_9_2, "default")
	local var_9_1 = findTF(var_9_0, "tasks")
	local var_9_2 = findTF(arg_9_2, "lock")
	local var_9_3 = findTF(var_9_2, "desc_bg/desc")
	local var_9_4 = arg_9_1 + 1

	LoadImageSpriteAtlasAsync("ui/twopointfiveomenpage_atlas", "day_" .. arg_9_1 + 1, findTF(var_9_0, "day"), true)

	for iter_9_0 = 0, var_9_1.childCount - 1 do
		self:UpdateTaskItem(arg_9_1 + 1, iter_9_0, (var_9_1:GetChild(iter_9_0)))
	end

	local var_9_5 = self:isTaskLock(arg_9_1 + 1)
	local var_9_6 = var_9_5 ~= 0

	setActive(var_9_2, var_9_5 ~= 0)
	switch(var_9_5, {
		function()
			local var_10_0, var_10_1 = self:getDate(self.month, self.day + var_9_4 - self.nday)

			setText(var_9_3, i18n("OutPostOmenPage_task_tip1", var_10_0, var_10_1))
		end,
		function()
			setText(var_9_3, i18n("OutPostOmenPage_task_tip2"))
		end
	})
	setActive(var_9_2:Find("mask_1"), var_9_6)
	setActive(var_9_2:Find("mask_2"), var_9_6)
	setActive(var_9_2:Find("lockItem_1"), var_9_6)
	setActive(var_9_2:Find("lockItem_2"), var_9_6)
end

function TwoPointFiveOmenTaskWindow:UpdateTaskItem(arg_12_1, arg_12_2, arg_12_3)
	local var_12_0 = arg_12_3:Find("item")
	local var_12_1 = self.taskProxy:getTaskById(self.taskGroup[arg_12_1][arg_12_2 + 1]) or self.taskProxy:getFinishTaskById(self.taskGroup[arg_12_1][arg_12_2 + 1])
	local var_12_2 = pg.task_data_template[self.taskGroup[arg_12_1][arg_12_2 + 1]]
	local var_12_3 = Drop.Create(pg.task_data_template[self.taskGroup[arg_12_1][arg_12_2 + 1]].award_display[1])

	updateDrop(var_12_0, var_12_3)
	onButton(self, var_12_0, function()
		self:emit(BaseUI.ON_DROP, var_12_3)
	end, SFX_PANEL)

	local var_12_4 = var_12_1 and var_12_1:getProgress() or 0
	local var_12_5 = var_12_2.target_num
	local var_12_6 = var_12_1 and var_12_1:getTaskStatus() == 2
	local var_12_7 = var_12_2.desc

	if utf8.len(var_12_2.desc) >= 17 then
		setScrollText(arg_12_3:Find("mask/description"), var_12_7)
	else
		setText(arg_12_3:Find("mask/description"), var_12_7)
	end

	setSlider(arg_12_3:Find("progress"), 0, var_12_5, var_12_4)
	setText(arg_12_3:Find("progressText"), var_12_4 .. "<color=#ffb1d8>/" .. var_12_5 .. "</color>")
end

function TwoPointFiveOmenTaskWindow:getDate(arg_14_1, arg_14_2)
	local var_14_0 = pg.TimeMgr.GetInstance():CalcMonthDays(self.year, arg_14_1)

	if var_14_0 < arg_14_2 then
		arg_14_2 = arg_14_2 - var_14_0
		arg_14_1 = arg_14_1 + 1

		if arg_14_1 > 12 then
			arg_14_1 = 1
			self.year = self.year + 1
		end
	end

	return arg_14_1, arg_14_2
end

function TwoPointFiveOmenTaskWindow:isTaskLock(arg_15_1)
	if arg_15_1 > self.nday then
		return 1
	end

	for iter_15_0 = 1, arg_15_1 - 1 do
		for iter_15_1, iter_15_2 in ipairs(self.taskGroup[iter_15_0]) do
			local var_15_0 = self.taskProxy:getTaskById(iter_15_2) or self.taskProxy:getFinishTaskById(iter_15_2)

			if not var_15_0 or var_15_0:getTaskStatus() ~= 2 then
				return 2
			end
		end
	end

	return 0
end

function TwoPointFiveOmenTaskWindow:Hide()
	if self:isShowing() then
		TwoPointFiveOmenTaskWindow.super.Hide(self)
		pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
	end
end

return TwoPointFiveOmenTaskWindow
