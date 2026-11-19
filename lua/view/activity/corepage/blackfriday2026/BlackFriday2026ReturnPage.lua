local BlackFriday2026ReturnPage = class("BlackFriday2026ReturnPage", import("view.activity.CorePage.CoreLoginTemplatePage"))

function BlackFriday2026ReturnPage:OnInit()
	self.bg = self._tf:Find("bg")
	self.endAward = self.bg:Find("rule/item")
	self.taskProgress = self.bg:Find("rule/taskProgress")
	self.endGetBtn = self.bg:Find("rule/btn_get")
	self.endGotBtn = self.bg:Find("rule/btn_got")
	self.task = self.bg:Find("task")
	self.taskTouch = self.task:Find("bg")
	self.taskAward = self.task:Find("item")
	self.dayTF = self.task:Find("day")
	self.taskWindow = BlackFriday2026ReturnTaskWindow.New(self._tf, self.event)
end

function BlackFriday2026ReturnPage:OnDataSetting()
	self.nday = 0
	self.taskProxy = getProxy(TaskProxy)
	self.taskGroup = self.activity:getConfig("config_client").unlock_task

	return updateActivityTaskStatus(self.activity)
end

function BlackFriday2026ReturnPage:OnFirstFlush()
	onButton(self, self.taskTouch, function()
		self.taskWindow:ExecuteAction("Show", self.activity)
	end, SFX_PANEL)
	onButton(self, self.endGetBtn, function()
		local var_5_0 = self.activity:getConfig("config_client").extra_task
		local var_5_1 = self.taskProxy:getTaskById(var_5_0) or self.taskProxy:getFinishTaskById(var_5_0)

		if var_5_1 and var_5_1:getTaskStatus() == 1 then
			self:emit(ActivityMediator.ON_TASK_SUBMIT, var_5_1)
		end
	end, SFX_PANEL)
end

function BlackFriday2026ReturnPage:OnUpdateFlush()
	self.nday = self:getTaskIdx(self.activity)

	local var_6_0 = self.nday

	if self:GetDayTaskVo(self.nday):getTaskStatus() ~= 2 then
		var_6_0 = var_6_0 - 1
	end

	setText(self.taskProgress, setColorStr(var_6_0, "#009BBC") .. setColorStr("/" .. #self.taskGroup, "#000000"))
	setText(self.dayTF, self.nday .. "/" .. #self.taskGroup)
	self:UpdateTask()
	self:UpdateEndAward()

	if self.taskWindow:isShowing() then
		self.taskWindow:ExecuteAction("Show", self.activity)
	end
end

function BlackFriday2026ReturnPage:UpdateTask()
	self:InitAward(self.taskAward, self.nday)

	local var_7_0 = self:GetDayTaskVo(self.nday)
	local var_7_1 = var_7_0:getProgress()
	local var_7_2 = var_7_0:getConfig("target_num")

	setText(self.task:Find("description"), var_7_0:getConfig("desc"))
	setText(self.task:Find("progressText"), var_7_1 .. "/" .. var_7_2)
	setSlider(self.task:Find("progress"), 0, var_7_2, var_7_1)

	local var_7_3 = self.task:Find("go_btn")
	local var_7_4 = self.task:Find("get_btn")
	local var_7_5 = self.task:Find("got_btn")
	local var_7_6 = var_7_0:getTaskStatus()

	setActive(var_7_3, var_7_6 == 0)
	setActive(var_7_4, var_7_6 == 1)
	setActive(var_7_5, var_7_6 == 2)
	onButton(self, var_7_3, function()
		self:emit(ActivityMediator.ON_TASK_GO, var_7_0)
	end, SFX_PANEL)
	onButton(self, var_7_4, function()
		local var_9_0 = {}
		local var_9_1 = var_7_0:getConfig("award_display")
		local var_9_2 = getProxy(PlayerProxy):getRawData()
		local var_9_3, var_9_4 = Task.StaticJudgeOverflow(var_9_2.gold, var_9_2.oil, LOCK_UR_SHIP and 0 or getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1]), true, true, var_9_1)

		if var_9_3 then
			table.insert(var_9_0, function(arg_10_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_ITEM_BOX,
					content = i18n("award_max_warning"),
					items = var_9_4,
					onYes = arg_10_0
				})
			end)
		end

		seriesAsync(var_9_0, function()
			self:emit(ActivityMediator.ON_TASK_SUBMIT, var_7_0)
		end)
	end, SFX_PANEL)
end

function BlackFriday2026ReturnPage:UpdateEndAward()
	local var_12_0 = self.activity:getConfig("config_client").extra_task
	local var_12_1 = self.taskProxy:getTaskById(var_12_0) or self.taskProxy:getFinishTaskById(var_12_0)

	if var_12_1 == nil then
		warning("未获取到活动数据")

		return
	end

	local var_12_2 = var_12_1:getTaskStatus()

	setActive(self.endGetBtn, var_12_2 == 1)
	setActive(self.endGotBtn, var_12_2 == 2)

	local var_12_3 = Drop.Create(var_12_1:getConfig("award_display")[1])

	updateDrop(self.endAward, var_12_3)
	onButton(self, self.endAward, function()
		self:emit(BaseUI.ON_DROP, var_12_3)
	end, SFX_PANEL)
end

function BlackFriday2026ReturnPage:InitAward(arg_14_1, arg_14_2)
	local var_14_0 = Drop.Create(self:GetDayTaskVo(arg_14_2):getConfig("award_display")[1])

	updateDrop(arg_14_1, var_14_0)
	onButton(self, arg_14_1, function()
		self:emit(BaseUI.ON_DROP, var_14_0)
	end, SFX_PANEL)
end

function BlackFriday2026ReturnPage:GetDayTaskVo(arg_16_1)
	local var_16_0 = self.taskProxy:getTaskById(self.taskGroup[arg_16_1][1]) or self.taskProxy:getFinishTaskById(self.taskGroup[arg_16_1][1])

	assert(var_16_0, "without this task by id: " .. self.taskGroup[arg_16_1][1])

	return var_16_0
end

function BlackFriday2026ReturnPage:getTaskIdx(arg_17_1)
	local var_17_0 = 1
	local var_17_1 = math.min(arg_17_1:getNDay(), #self.taskGroup)

	for iter_17_0 = 1, var_17_1 do
		if not true then
			break
		end

		var_17_0 = iter_17_0

		if iter_17_0 < var_17_1 then
			for iter_17_1, iter_17_2 in ipairs(self.taskGroup[iter_17_0]) do
				if not self:isTaskFinished(iter_17_2) then
					break
				end
			end
		end
	end

	return math.min(var_17_0, #self.taskGroup)
end

function BlackFriday2026ReturnPage:isTaskFinished(arg_18_1)
	self.taskProxy = self.taskProxy or getProxy(TaskProxy)

	local var_18_0 = self.taskProxy:getTaskById(arg_18_1) or self.taskProxy:getFinishTaskById(arg_18_1)

	return var_18_0 and var_18_0:getTaskStatus() == 2
end

function BlackFriday2026ReturnPage:OnHideFlush()
	if self.taskWindow:isShowing() then
		self.taskWindow:Hide()
	end
end

function BlackFriday2026ReturnPage:OnDestroy()
	if self.taskWindow then
		self.taskWindow:Hide()
		self.taskWindow:Destroy()

		self.taskWindow = nil
	end
end

return BlackFriday2026ReturnPage
