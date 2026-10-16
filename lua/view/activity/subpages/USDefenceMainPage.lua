local USDefenceMainPage = class("USDefenceMainPage", import(".TemplatePage.PreviewTemplatePage"))

function USDefenceMainPage:OnInit()
	USDefenceMainPage.super.OnInit(self)
	self:initUI()
end

function USDefenceMainPage:OnFirstFlush()
	USDefenceMainPage.super.OnFirstFlush(self)
	self:initData()
	self:submitFinishedTask()
end

function USDefenceMainPage:OnDataSetting()
	return
end

function USDefenceMainPage:OnUpdateFlush()
	self:updateAwardBtn()
end

function USDefenceMainPage:OnDestroy()
	return
end

function USDefenceMainPage:initData()
	self.finalTaskID = self.activity:getConfig("config_client")[1]
	self.taskIDList = Clone(pg.task_data_template[self.finalTaskID].target_id)
	self.taskProxy = getProxy(TaskProxy)
	self.taskListView = USDefTaskWindowView.New(self.subViewContainer, self.event, self.activity)
end

function USDefenceMainPage:initUI()
	self.awardTF = self.bg:Find("Item")
	self.activeTF = self.awardTF:Find("Active")
	self.finishedTF = self.awardTF:Find("Finished")
	self.achievedTF = self.awardTF:Find("Achieved")

	setActive(self.activeTF, false)
	setActive(self.finishedTF, false)
	setActive(self.achievedTF, false)

	self.achievementBtn = self.bg:Find("AchieveMentBtn")
	self.subViewContainer = self._tf:Find("SubViewContainer")
end

function USDefenceMainPage:updateAwardBtn()
	local var_8_0 = self:getFinalTaskStatus()

	if var_8_0 == 0 then
		setActive(self.activeTF, true)
		setActive(self.finishedTF, false)
		setActive(self.achievedTF, false)
		onButton(self, self.awardTF, function()
			self.taskListView:Load()
		end, SFX_PANEL)
		onButton(self, self.achievementBtn, function()
			self.taskListView:Load()
		end, SFX_PANEL)
	elseif var_8_0 == 1 then
		setActive(self.activeTF, false)
		setActive(self.finishedTF, true)
		setActive(self.achievedTF, false)
		onButton(self, self.awardTF, function()
			self:emit(ActivityMediator.ON_TASK_SUBMIT, (self.taskProxy:getTaskVO(self.finalTaskID)))
		end, SFX_PANEL)
		onButton(self, self.achievementBtn, function()
			self:emit(ActivityMediator.ON_TASK_SUBMIT, (self.taskProxy:getTaskVO(self.finalTaskID)))
		end, SFX_PANEL)
	elseif var_8_0 == 2 then
		setActive(self.activeTF, false)
		setActive(self.finishedTF, false)
		setActive(self.achievedTF, true)
		setButtonEnabled(self.awardTF, false)
		setButtonEnabled(self.achievementBtn, false)
	end
end

function USDefenceMainPage:submitFinishedTask()
	for iter_13_0, iter_13_1 in ipairs(self.taskIDList) do
		local var_13_0 = self.taskProxy:getTaskById(iter_13_1)

		if var_13_0 and var_13_0:isFinish() then
			self:emit(ActivityMediator.ON_TASK_SUBMIT, var_13_0)
		end
	end
end

function USDefenceMainPage:getFinalTaskStatus()
	return self.taskProxy:getTaskVO(self.finalTaskID):getTaskStatus()
end

return USDefenceMainPage
