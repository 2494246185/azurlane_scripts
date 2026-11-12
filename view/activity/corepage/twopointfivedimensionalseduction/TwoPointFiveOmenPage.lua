local TwoPointFiveOmenPage = class("TwoPointFiveOmenPage", import("view.activity.CorePage.CoreLoginTemplatePage"))

function TwoPointFiveOmenPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.total = self.bg:Find("total_progress")
	self.dayTF = self.total:Find("day")
	self.maxDayTF = self.total:Find("max_day")
	self.btnDetail = self.total:Find("btn_detail")
	self.item = self.bg:Find("item")
	self.items = self.bg:Find("items")
	self.uilist = UIItemList.New(self.items, self.item)
	self.taskWindow = TwoPointFiveOmenTaskWindow.New(self._tf, self.event)
	self.finishAll = false

	setActive(self.item, false)
end

function TwoPointFiveOmenPage:OnDataSetting()
	self.taskProxy = getProxy(TaskProxy)
	self.taskGroup = self.activity:getConfig("config_client").unlock_task

	return updateActivityTaskStatus(self.activity)
end

function TwoPointFiveOmenPage:OnFirstFlush()
	TwoPointFiveOmenPage.super.OnFirstFlush(self)
	setActive(self.maxTF, #self.taskGroup)
	onButton(self, self.btnDetail, function()
		self.taskWindow:ExecuteAction("Show", self.activity)
	end, SFX_PANEL)
end

function TwoPointFiveOmenPage:lastFinish()
	return getProxy(TaskProxy):getTaskVO(self.taskGroup[#self.taskGroup][1]):getTaskStatus() == 2 and getProxy(TaskProxy):getTaskVO(self.taskGroup[#self.taskGroup][2]):getTaskStatus() == 2
end

function TwoPointFiveOmenPage:UpdateTask(arg_6_1, arg_6_2)
	local var_6_0 = arg_6_2:Find("item")
	local var_6_1 = self.taskProxy:getTaskById(self.taskGroup[self.nday][arg_6_1 + 1]) or self.taskProxy:getFinishTaskById(self.taskGroup[self.nday][arg_6_1 + 1])

	assert(var_6_1, "without this task by id: " .. self.taskGroup[self.nday][arg_6_1 + 1])

	local var_6_2 = Drop.Create(var_6_1:getConfig("award_display")[1])

	updateDrop(var_6_0, var_6_2)
	onButton(self, var_6_0, function()
		self:emit(BaseUI.ON_DROP, var_6_2)
	end, SFX_PANEL)

	local var_6_3 = var_6_1:getProgress()
	local var_6_4 = var_6_1:getConfig("target_num")
	local var_6_5 = var_6_1:getConfig("desc")

	if utf8.len(var_6_5) >= 11 then
		setScrollText(arg_6_2:Find("mask/description"), var_6_5)
	else
		setText(arg_6_2:Find("mask/description"), var_6_5)
	end

	local var_6_6, var_6_7 = self:GetProgressColor()

	setText(arg_6_2:Find("progressText"), (var_6_6 and setColorStr(var_6_3, var_6_6) or var_6_3) .. (var_6_7 and setColorStr("/" .. var_6_4, var_6_7) or "/" .. var_6_4))
	setSlider(arg_6_2:Find("progress"), 0, var_6_4, var_6_3)

	local var_6_9 = arg_6_2:Find("go_btn")
	local var_6_10 = arg_6_2:Find("get_btn")
	local var_6_11 = arg_6_2:Find("got_btn")
	local var_6_12 = var_6_1:getTaskStatus()

	setActive(var_6_9, var_6_12 == 0)
	setActive(var_6_10, var_6_12 == 1)
	setActive(var_6_11, var_6_12 == 2)
	onButton(self, var_6_9, function()
		self:emit(ActivityMediator.ON_TASK_GO, var_6_1)
	end, SFX_PANEL)
	onButton(self, var_6_10, function()
		local var_9_0 = {}
		local var_9_1 = var_6_1:getConfig("award_display")
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
			self:emit(ActivityMediator.ON_TASK_SUBMIT, var_6_1)
		end)
	end, SFX_PANEL)
end

function TwoPointFiveOmenPage:OnUpdateFlush()
	self.nday = self:getTaskIdx(self.activity)

	if self.dayTF then
		setText(self.dayTF, self.nday)
		setText(self.maxDayTF, "/" .. #self.taskGroup)
	end

	self.uilist:align(#self.taskGroup[self.nday])

	if self.taskWindow:isShowing() then
		self.taskWindow:ExecuteAction("Show", self.activity)
	end

	self:PlayStory()
end

function TwoPointFiveOmenPage:PlayStory()
	local var_13_0 = {}

	var_13_0[1] = 3

	local var_13_1 = checkExist(self.activity:getConfig("config_client").story, var_13_0, {
		1
	})

	if not var_13_1 or 3 > self.nday then
		return
	end

	for iter_13_0, iter_13_1 in ipairs(self.taskGroup[3]) do
		if not self:isTaskFinished(iter_13_1) then
			return
		end
	end

	local var_13_2 = pg.NewStoryMgr.GetInstance()

	if not var_13_2:IsPlayed(var_13_1) then
		var_13_2:Play(var_13_1)
	end
end

function TwoPointFiveOmenPage:getTaskIdx(arg_14_1)
	local var_14_0 = 1
	local var_14_1 = math.min(arg_14_1:getNDay(), #self.taskGroup)

	for iter_14_0 = 1, var_14_1 do
		if not true then
			break
		end

		var_14_0 = iter_14_0

		if iter_14_0 < var_14_1 then
			for iter_14_1, iter_14_2 in ipairs(self.taskGroup[iter_14_0]) do
				if not self:isTaskFinished(iter_14_2) then
					break
				end
			end
		end
	end

	return math.min(var_14_0, #self.taskGroup)
end

function TwoPointFiveOmenPage:isTaskFinished(arg_15_1)
	self.taskProxy = self.taskProxy or getProxy(TaskProxy)

	local var_15_0 = self.taskProxy:getTaskById(arg_15_1) or self.taskProxy:getFinishTaskById(arg_15_1)

	return var_15_0 and var_15_0:getTaskStatus() == 2
end

function TwoPointFiveOmenPage:GetProgressColor()
	return "#ff89b9", "#ffb1d8"
end

function TwoPointFiveOmenPage:OnHideFlush()
	if self.taskWindow:isShowing() then
		self.taskWindow:Hide()
	end
end

function TwoPointFiveOmenPage:OnDestroy()
	if self.taskWindow then
		self.taskWindow:Hide()
		self.taskWindow:Destroy()

		self.taskWindow = nil
	end
end

return TwoPointFiveOmenPage
