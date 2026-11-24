local CityRebuildTasksLayer = class("CityRebuildTasksLayer", import("view.base.BaseUI"))

function CityRebuildTasksLayer:getUIName()
	return "CityRebuildTasksUI"
end

function CityRebuildTasksLayer:init()
	self.bg = self:findTF("BG")
	self.Close = self.bg:Find("close")
	self.list = self.bg:Find("panel/list")
	self.frame = self.bg:Find("frame")
	self.white_closebtn = self:findTF("white_close")
	self.UIlist = UIItemList.New(self.list, self.frame)
	self.getall = self.bg:Find("get_all")
end

function CityRebuildTasksLayer:findTF(arg_3_1, arg_3_2)
	return findTF(arg_3_2 or self._tf, arg_3_1)
end

function CityRebuildTasksLayer:didEnter()
	self:InitData()
	setActive(self.frame, false)
	onButton(self, self.Close, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.white_closebtn, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.getall, function()
		self:GetAllAward()
	end)
	setText(self.getall:Find("Text"), i18n("other_world_task_get_all"))
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function CityRebuildTasksLayer.ShouldShowTip()
	local var_8_0 = getProxy(TaskProxy)
	local var_8_1 = getProxy(ActivityProxy):getActivityById(ActivityConst.NINJA_CITY_SP_TASK)
	local var_8_2 = var_8_1:getConfig("config_data")

	if var_8_1.data3 then
		return false
	end

	local var_8_3 = var_8_1.data3

	if var_8_1.data3 == 0 or var_8_3 == nil then
		return false
	end

	for iter_8_0 = 1, #var_8_2[var_8_3] do
		if var_8_0:getTaskVO(var_8_2[var_8_3][iter_8_0]):getTaskStatus() == 1 then
			return true
		end
	end

	local var_8_4 = getProxy(ActivityProxy):getActivityById(ActivityConst.NINJA_CITY_NORMAL_ACTIVITY_TASK):getConfig("config_data")

	for iter_8_1 = 1, #var_8_4 do
		if var_8_0:getTaskVO(var_8_4[iter_8_1]):getTaskStatus() == 1 then
			return true
		end
	end

	return false
end

function CityRebuildTasksLayer:InitData()
	self.taskProxy = getProxy(TaskProxy)
	self.taskActivityId = ActivityConst.NINJA_CITY_SP_TASK
	self.taskActivityId_2 = ActivityConst.NINJA_CITY_NORMAL_ACTIVITY_TASK
	self.activity = getProxy(ActivityProxy):getActivityById(self.taskActivityId)
	self.activity_2 = getProxy(ActivityProxy):getActivityById(self.taskActivityId_2)
	self.data = self.activity:getConfig("config_data")
	self.data2 = self.activity_2:getConfig("config_data")

	updateActivityTaskStatus(self.activity)

	self.config_datas = {}
	self.nday = self.activity.data3

	if not self.config_datas then
		table.clean(self.config_datas)
	end

	for iter_9_0 = 1, #self.data[self.nday] do
		table.insert(self.config_datas, self.data[self.nday][iter_9_0])
	end

	for iter_9_1 = 1, #self.data2 do
		table.insert(self.config_datas, self.data2[iter_9_1])
	end

	self:OnSort()
	self:UpdateView()
end

function CityRebuildTasksLayer:OnSort()
	self.config_data = {}

	if not self.config_data then
		table.clean(self.config_data)
	end

	for iter_10_0 = 1, #self.config_datas do
		self.tasks = self.taskProxy:getTaskVO(self.config_datas[iter_10_0])

		if self.tasks:getTaskStatus() == 1 then
			table.insert(self.config_data, self.config_datas[iter_10_0])
		end
	end

	for iter_10_1 = 1, #self.config_datas do
		self.tasks = self.taskProxy:getTaskVO(self.config_datas[iter_10_1])

		if self.tasks:getTaskStatus() == 0 then
			table.insert(self.config_data, self.config_datas[iter_10_1])
		end
	end

	for iter_10_2 = 1, #self.config_datas do
		self.tasks = self.taskProxy:getTaskVO(self.config_datas[iter_10_2])

		if self.tasks:getTaskStatus() == 2 then
			table.insert(self.config_data, self.config_datas[iter_10_2])
		end
	end
end

function CityRebuildTasksLayer:UpdateView()
	setActive(self.getall, self.ShouldShowTip())
	self.UIlist:make(function(arg_12_0, arg_12_1, arg_12_2)
		if arg_12_0 == UIItemList.EventUpdate then
			self:UpdateList(arg_12_1, arg_12_2, self.config_data)
		end
	end)
	self.UIlist:align(#self.config_data)
end

function CityRebuildTasksLayer:GetAllAward()
	self.indexTask = 0

	local var_13_0 = getProxy(PlayerProxy)
	local var_13_1 = {}
	local var_13_2 = {}

	for iter_13_0, iter_13_1 in pairs(self.config_data) do
		self.taskvo = self.taskProxy:getFinishTaskById(self.config_data[iter_13_0])
		self.task = self.taskProxy:getTaskVO(self.config_data[iter_13_0])

		if self.task:getTaskStatus() == 1 then
			for iter_13_2 = 1, #self.data2 do
				if self.task.id == self.data2[iter_13_2] then
					table.insert(var_13_1, self.config_data[iter_13_0])
				end
			end

			for iter_13_3 = 1, #self.data[self.nday] do
				if self.task.id == self.data[self.nday][iter_13_3] then
					table.insert(var_13_2, self.task.id)
				end
			end
		end
	end

	for iter_13_4 = 1, #var_13_2 do
		self:emit(CityRebuildTasksMediator.ON_SUBMIT_TASK, var_13_2[iter_13_4])
	end

	self:emit(CityRebuildTasksMediator.ON_TASK_SUBMIT_ONESTEP, self.taskActivityId_2, var_13_1)
end

function CityRebuildTasksLayer:UpdateList(arg_14_1, arg_14_2, arg_14_3)
	local var_14_0 = arg_14_2:Find("frame")
	local var_14_1 = self.taskProxy:getTaskVO(arg_14_3[arg_14_1 + 1])

	setText(arg_14_2:Find("desc"), var_14_1:getConfig("desc"))

	local var_14_2 = var_14_1:getProgress()
	local var_14_3 = var_14_1:getConfig("target_num")

	setText(arg_14_2:Find("progress"), setColorStr(var_14_2, "#000000") .. "/" .. var_14_3)
	setSlider(arg_14_2:Find("slider"), 0, var_14_3, var_14_2)
	self:updateAwards(var_14_1:getConfig("award_display"), arg_14_2:Find("awards"), (arg_14_2:GetChild(0)))

	local var_14_4 = arg_14_2:Find("go_btn")
	local var_14_5 = arg_14_2:Find("get_btn")
	local var_14_6 = arg_14_2:Find("got_btn")
	local var_14_7 = var_14_1:getTaskStatus()

	setActive(var_14_4, var_14_7 == 0)
	setActive(var_14_5, var_14_7 == 1)
	setActive(var_14_6, var_14_7 == 2)
	SetActive(arg_14_2:Find("tip"), var_14_7 == 1)
	onButton(self, var_14_5, function()
		for iter_15_0 = 1, #self.data[self.nday] do
			if var_14_1.id == self.data[self.nday][iter_15_0] then
				self:emit(CityRebuildTasksMediator.ON_SUBMIT_TASK, var_14_1.id)
			end
		end

		for iter_15_1 = 1, #self.data2 do
			if var_14_1.id == self.data2[iter_15_1] then
				self:emit(CityRebuildTasksMediator.ON_TASK_SUBMIT_ONESTEP, self.taskActivityId_2, {
					var_14_1.id
				})
			end
		end
	end, SFX_PANEL)
	onButton(self, var_14_4, function()
		self:emit(CityRebuildTasksMediator.ON_TASK_GO, var_14_1)
	end, SFX_PANEL)
end

function CityRebuildTasksLayer:updateAwards(arg_17_1, arg_17_2, arg_17_3)
	local var_17_0 = _.slice(arg_17_1, 1, 3)

	for iter_17_0 = arg_17_2.childCount, #var_17_0 - 1 do
		cloneTplTo(arg_17_3, arg_17_2)
	end

	for iter_17_1 = 1, arg_17_2.childCount do
		local var_17_1 = arg_17_2:GetChild(iter_17_1 - 1)
		local var_17_2 = iter_17_1 <= #var_17_0

		setActive(var_17_1, iter_17_1 <= #var_17_0)

		if var_17_2 then
			local var_17_3 = {
				type = var_17_0[iter_17_1][1],
				id = var_17_0[iter_17_1][2],
				count = var_17_0[iter_17_1][3]
			}

			updateDrop(findTF(var_17_1, "mask"), var_17_3)
			onButton(self, var_17_1:Find("mask"), function()
				self:emit(BaseUI.ON_DROP, var_17_3)
			end, SFX_PANEL)
		end
	end
end

return CityRebuildTasksLayer
