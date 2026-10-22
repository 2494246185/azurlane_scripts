local TaskScene = class("TaskScene", import("..base.BaseUI"))

TaskScene.PAGE_TYPE_SCENARIO = "scenario"
TaskScene.PAGE_TYPE_BRANCH = "branch"
TaskScene.PAGE_TYPE_ROUTINE = "routine"
TaskScene.PAGE_TYPE_WEEKLY = "weekly"
TaskScene.PAGE_TYPE_ALL = "all"
TaskScene.PAGE_TYPE_ACT = "activity"

local var_0_1 = {
	[TaskScene.PAGE_TYPE_SCENARIO] = {
		[1] = true
	},
	[TaskScene.PAGE_TYPE_BRANCH] = {
		nil,
		true,
		nil,
		nil,
		true,
		true
	},
	[TaskScene.PAGE_TYPE_ROUTINE] = {
		[3] = true,
		[36] = true
	},
	[TaskScene.PAGE_TYPE_WEEKLY] = {
		[4] = true,
		[13] = true
	},
	[TaskScene.PAGE_TYPE_ALL] = {
		true,
		true,
		true,
		true,
		true,
		true,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		true,
		[36] = true,
		[26] = true
	},
	[TaskScene.PAGE_TYPE_ACT] = {
		[36] = true,
		[6] = true,
		[26] = true,
		[16] = true
	}
}

function TaskScene:getResource()
	local var_1_0 = {
		"ui/taskui_atlas",
		"ui/iconcolorful",
		"ui/TaskEmptyListUI",
		"ui/TaskListPage",
		"ui/TaskListForWeekPage",
		"ui/ActivitybonusWindow"
	}

	table.insertto(var_1_0, self:GetTaskResourceList())

	return table.insertto(var_1_0, TaskScene.super.getResource(self))
end

function TaskScene:GetTaskResourceList()
	local var_2_0 = {}
	local var_2_1 = getProxy(TaskProxy)

	for iter_2_0, iter_2_1 in ipairs(var_2_1:getTasks()) do
		local var_2_2 = self:GetTaskResource(iter_2_1)

		if var_2_2 and not table.contains(var_2_0, var_2_2) then
			table.insert(var_2_0, var_2_2)
		end
	end

	for iter_2_2, iter_2_3 in ipairs(var_2_1:getFinishTasks()) do
		local var_2_3 = self:GetTaskResource(iter_2_3)

		if var_2_3 and not table.contains(var_2_0, var_2_3) then
			table.insert(var_2_0, var_2_3)
		end
	end

	for iter_2_4, iter_2_5 in ipairs((getProxy(AvatarFrameProxy):getAllAvatarFrame())) do
		for iter_2_6, iter_2_7 in ipairs(iter_2_5.tasks) do
			local var_2_4 = self:GetTaskResource(iter_2_7)

			if var_2_4 and not table.contains(var_2_0, var_2_4) then
				table.insert(var_2_0, var_2_4)
			end
		end
	end

	return var_2_0
end

function TaskScene:GetTaskResource(arg_3_1)
	local var_3_0 = arg_3_1:getConfig("story_id")

	if var_3_0 and var_3_0 ~= "" then
		local var_3_1 = arg_3_1:getConfig("story_icon")

		if not var_3_1 or var_3_1 == "" then
			return "memoryicon/task_icon_default"
		else
			return "shipmodels/" .. var_3_1
		end
	end
end

function TaskScene:getUIName()
	return "TaskScene"
end

function TaskScene:setTaskVOs(arg_5_1)
	self.contextData.taskVOsById = arg_5_1
end

function TaskScene:SetWeekTaskProgressInfo(arg_6_1)
	self.contextData.weekTaskProgressInfo = arg_6_1
end

function TaskScene:init()
	self._topPanel = self._tf:Find("blur_panel/adapt/top")
	self._backBtn = self._topPanel:Find("back_btn")
	self._leftLength = self._tf:Find("blur_panel/adapt/left_length")
	self._tagRoot = self._tf:Find("blur_panel/adapt/left_length/frame/tagRoot")
	self.taskIconTpl = self._tf:Find("taskTagOb/task_icon_default")
	self.weekTip = self._tagRoot:Find("weekly/tip")
	self.oneStepBtn = self._tf:Find("blur_panel/adapt/top/GetAllButton")
	self.contextData.viewComponent = self
	self.pageTF = self._tf:Find("pages")
end

function TaskScene.IsNewStyleTime()
	return pg.TimeMgr.GetInstance():parseTimeFromConfig({
		{
			2021,
			6,
			14
		},
		{
			0,
			0,
			0
		}
	}) <= pg.TimeMgr.GetInstance():GetServerTime()
end

function TaskScene.IsPassScenario()
	local var_9_0 = pg.gameset.task_first_daily_pre_id.key_value
	local var_9_1 = _.select(_.values((getProxy(TaskProxy):getData())), function(arg_10_0)
		return arg_10_0:getConfig("type") == 1
	end)

	if #var_9_1 > 0 then
		table.sort(var_9_1, function(arg_11_0, arg_11_1)
			return arg_11_0.id < arg_11_1.id
		end)

		return var_9_0 < var_9_1[1].id
	else
		return true
	end
end

function TaskScene:didEnter()
	local var_12_0 = TaskCommonPage.New(self.pageTF, self.event, self.contextData)
	local var_12_1 = TaskScene.IsNewStyleTime() and not self.contextData.weekTaskProgressInfo:IsMaximum() and TaskWeekPage.New(self.pageTF, self.event, self.contextData) or var_12_0

	self.emptyPage = TaskEmptyListPage.New(self._tf, self.event)
	self.pages = {
		[TaskScene.PAGE_TYPE_SCENARIO] = var_12_0,
		[TaskScene.PAGE_TYPE_BRANCH] = var_12_0,
		[TaskScene.PAGE_TYPE_ROUTINE] = var_12_0,
		[TaskScene.PAGE_TYPE_WEEKLY] = var_12_1,
		[TaskScene.PAGE_TYPE_ALL] = var_12_0,
		[TaskScene.PAGE_TYPE_ACT] = var_12_0
	}
	self.contextData.ptAwardWindow = TaskPtAwardPage.New(self._tf, self.event, self.contextData)

	onButton(self, self._backBtn, function()
		self:emit(TaskScene.ON_BACK)
	end, SFX_CANCEL)
	setActive(self._tf:Find("stamp"), getProxy(TaskProxy):mingshiTouchFlagEnabled())

	if LOCK_CLICK_MINGSHI then
		setActive(self._tf:Find("stamp"), false)
	end

	onButton(self, self._tf:Find("stamp"), function()
		getProxy(TaskProxy):dealMingshiTouchFlag(5)
	end, SFX_CONFIRM)

	self.toggles = {}

	for iter_12_0, iter_12_1 in pairs(var_0_1) do
		local var_12_2 = self._tagRoot:Find(iter_12_0)

		onToggle(self, var_12_2, function(arg_15_0)
			if arg_15_0 then
				self:UpdatePage(iter_12_0)
			end
		end, SFX_PANEL)

		self.toggles[iter_12_0] = var_12_2
	end

	local var_12_3 = self.toggles[self.contextData.page or TaskScene.PAGE_TYPE_ALL]

	if self.toggles and var_12_3 then
		triggerToggle(var_12_3, true)
	end

	self:UpdateWeekTip()
end

function TaskScene:refreshPage()
	self:UpdatePage(self._currentToggleType)
end

function TaskScene:UpdatePage(arg_17_1)
	local function var_17_0(arg_18_0, arg_18_1)
		if #arg_18_1 <= 0 then
			self.emptyPage:ExecuteAction("ShowOrHide", true)
		elseif #arg_18_1 > 0 and self.emptyPage:GetLoaded() then
			self.emptyPage:ExecuteAction("ShowOrHide", false)
		end

		self:updateOneStepBtn(arg_18_0)
	end

	if self._currentToggleType and self._currentToggleType ~= arg_17_1 then
		self.pages[self._currentToggleType]:ExecuteAction("Hide")
	end

	local var_17_1 = self.pages[arg_17_1]

	self.pages[arg_17_1]:ExecuteAction("Update", arg_17_1, var_0_1[arg_17_1], function(arg_19_0)
		var_17_0(var_17_1, arg_19_0)
	end)

	self._currentToggleType = arg_17_1
	self.contextData.page = arg_17_1
end

function TaskScene:addTask(arg_20_1)
	self.contextData.taskVOsById[arg_20_1.id] = arg_20_1

	self:UpdatePage(self._currentToggleType)
end

function TaskScene:removeTask(arg_21_1)
	self.contextData.taskVOsById[arg_21_1.id] = nil

	self:UpdatePage(self._currentToggleType)
end

function TaskScene:updateTask(arg_22_1)
	self:addTask(arg_22_1)
end

function TaskScene:ResetWeekTaskPage()
	if TaskScene.IsNewStyleTime() and isa(self.pages[TaskScene.PAGE_TYPE_WEEKLY], TaskCommonPage) then
		if self.pages[TaskScene.PAGE_TYPE_WEEKLY]:GetLoaded() and self.pages[TaskScene.PAGE_TYPE_WEEKLY]:isShowing() then
			self.pages[TaskScene.PAGE_TYPE_WEEKLY]:Hide()
		end

		self.pages[TaskScene.PAGE_TYPE_WEEKLY] = TaskWeekPage.New(self.pageTF, self.event, self.contextData)
	end

	self:RefreshWeekTaskPage()

	if self._currentToggleType ~= TaskScene.PAGE_TYPE_WEEKLY then
		self:UpdatePage(self._currentToggleType)
	end
end

function TaskScene:RefreshWeekTaskPage()
	if self._currentToggleType == TaskScene.PAGE_TYPE_WEEKLY then
		self:UpdatePage(self._currentToggleType)
		self:UpdateWeekTip()
	end
end

function TaskScene:RefreshWeekTaskPageBefore(arg_25_1)
	if self._currentToggleType == TaskScene.PAGE_TYPE_WEEKLY then
		self.pages[self._currentToggleType]:RefreshWeekTaskPageBefore(arg_25_1)
	end
end

function TaskScene:RefreshWeekTaskProgress()
	if isa(self.pages[self._currentToggleType], TaskWeekPage) and self.contextData.weekTaskProgressInfo:IsMaximum() then
		self.pages[self._currentToggleType]:Destroy()

		self.pages[TaskScene.PAGE_TYPE_WEEKLY] = self.pages[TaskScene.PAGE_TYPE_SCENARIO]

		self:UpdatePage(TaskScene.PAGE_TYPE_WEEKLY)
	elseif self._currentToggleType == TaskScene.PAGE_TYPE_WEEKLY and isa(self.pages[self._currentToggleType], TaskWeekPage) then
		self.pages[self._currentToggleType]:ExecuteAction("RefreshWeekProgress")
		self:UpdateWeekTip()
	end
end

function TaskScene:UpdateWeekTip()
	local var_27_0 = false

	if TaskScene.IsPassScenario() and TaskScene.IsNewStyleTime() then
		for iter_27_0, iter_27_1 in pairs(self.contextData.taskVOsById) do
			if (iter_27_1:getConfig("type") == 4 or iter_27_1:getConfig("type") == 13) and iter_27_1:isFinish() and not iter_27_1:isReceive() and iter_27_1:ShowOnTaskScene() then
				var_27_0 = true

				break
			end
		end

		if not var_27_0 then
			if self.contextData.weekTaskProgressInfo:CanUpgrade() or self.contextData.weekTaskProgressInfo:AnySubTaskCanSubmit() then
				var_27_0 = true
			end
		end
	end

	setActive(self.weekTip, var_27_0)
end

function TaskScene:GoToFilter(arg_28_1)
	triggerToggle(self._tagRoot:Find(arg_28_1), true)
end

function TaskScene:onSubmit(arg_29_1)
	if self.onShowAwards then
		return
	end

	self:emit(TaskMediator.ON_TASK_SUBMIT, arg_29_1)
end

function TaskScene:onSubmitForWeek(arg_30_1)
	if self.onShowAwards then
		return
	end

	self:emit(TaskMediator.ON_SUBMIT_WEEK_TASK, arg_30_1)
end

function TaskScene:onSubmitForAvatar(arg_31_1)
	if self.onShowAwards then
		return
	end

	self:emit(TaskMediator.ON_SUBMIT_AVATAR_TASK, arg_31_1)
end

function TaskScene:onGo(arg_32_1)
	if self.onShowAwards then
		return
	end

	if isa(arg_32_1, AvatarFrameTask) and arg_32_1:IsActEnd() then
		pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

		return
	end

	self:emit(TaskMediator.ON_TASK_GO, arg_32_1)
end

function TaskScene:willExit()
	for iter_33_0, iter_33_1 in pairs(self.pages) do
		iter_33_1:Destroy()
	end

	if self.emptyPage then
		self.emptyPage:Destroy()

		self.emptyPage = nil
	end

	self.pages = nil

	self.contextData.ptAwardWindow:Destroy()

	self.contextData.ptAwardWindow = nil
	self.contextData.taskVOsById = nil
	self.contextData.weekTaskProgressInfo = nil
	self.contextData.viewComponent = nil
end

function TaskScene:updateOneStepBtn(arg_34_1)
	arg_34_1 = arg_34_1 or self.pages[self._currentToggleType]

	local var_34_0 = #arg_34_1:GetWaitToCheckList() >= 2

	if var_34_0 then
		onButton(self, self.oneStepBtn, function()
			arg_34_1:ExecuteOneStepSubmit()
		end, SFX_PANEL)
	else
		removeOnButton(self.oneStepBtn)
	end

	setActive(self.oneStepBtn, var_34_0)
end

return TaskScene
