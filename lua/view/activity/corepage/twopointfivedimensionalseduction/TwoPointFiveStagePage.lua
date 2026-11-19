local TwoPointFiveStagePage = class("TwoPointFiveStagePage", import("view.activity.CorePage.CoreActivityPage"))

function TwoPointFiveStagePage:OnInit()
	self.bg = self._tf:Find("panel")
	self.chainTFList = {}
	self.stageTFList = {}

	local var_1_0 = self.bg:Find("stages")
	local var_1_1 = self.bg:Find("progress_chain")

	for iter_1_0 = 1, 2 do
		table.insert(self.stageTFList, var_1_0:Find("stage_" .. iter_1_0))
		table.insert(self.chainTFList, var_1_1:Find("chain_mark_" .. iter_1_0))
	end

	table.insert(self.stageTFList, var_1_0:Find("stage_3"))
end

function TwoPointFiveStagePage:flushTaskData()
	self._taskList = {}

	for iter_2_0, iter_2_1 in ipairs(self.activity:getConfig("config_client").task) do
		local var_2_0 = getProxy(TaskProxy):getTaskById(iter_2_1)

		var_2_0 = var_2_0 or getProxy(TaskProxy):getFinishTaskById(iter_2_1)

		table.insert(self._taskList, var_2_0)
	end
end

function TwoPointFiveStagePage:GetClearEnemyList()
	local var_3_0 = {}

	for iter_3_0, iter_3_1 in ipairs(self.activity.data2_list) do
		table.insert(var_3_0, self.activity:GetEnemyDataByStageId(iter_3_1).id)
	end

	return var_3_0
end

function TwoPointFiveStagePage:IsStageUnlock(arg_4_1, arg_4_2)
	return arg_4_1:GetPreChapterId() == 0 or table.contains(arg_4_2, arg_4_1:GetPreChapterId())
end

function TwoPointFiveStagePage:UpdateAwardState(arg_5_1, arg_5_2, arg_5_3)
	local var_5_0 = arg_5_2:Find("award")

	if not self._taskList[arg_5_1] then
		return
	end

	local var_5_1 = self._taskList[arg_5_1]:getConfig("award_display")[1]
	local var_5_2 = {
		type = var_5_1[1],
		id = var_5_1[2],
		count = var_5_1[3]
	}
	local var_5_3 = var_5_0:Find("got")
	local var_5_4 = self._taskList[arg_5_1]:getTaskStatus()

	self:UpdateCharacter(arg_5_2, var_5_4, arg_5_3)
	updateDrop(findTF(var_5_0, "mask"), var_5_2)

	if var_5_3 then
		setActive(var_5_3, arg_5_3 and var_5_4 == 2)
	end

	onButton(self, var_5_0, function()
		self:emit(BaseUI.ON_DROP, var_5_2)
	end)
end

function TwoPointFiveStagePage:UpdateCharacter(arg_7_1, arg_7_2, arg_7_3)
	local var_7_0 = arg_7_2 == 2
	local var_7_1 = arg_7_1:Find("character")

	setActive(var_7_1:Find("desc/finish"), arg_7_2 == 2)
	setActive(var_7_1:Find("desc/unfinish"), not var_7_0)
	setActive(var_7_1:Find("lock"), not arg_7_3)
end

function TwoPointFiveStagePage:RefreshAwardStates()
	local var_8_0 = self.activity:getConfig("config_data")
	local var_8_1 = self:GetClearEnemyList()

	for iter_8_0, iter_8_1 in ipairs(self.stageTFList) do
		self:UpdateAwardState(iter_8_0, iter_8_1, (self:IsStageUnlock(self.activity:GetEnemyDataById(var_8_0[iter_8_0]), var_8_1)))
	end
end

function TwoPointFiveStagePage:OnFirstFlush()
	local var_9_0 = self.activity:getConfig("config_data")
	local var_9_1 = self:GetClearEnemyList()

	self:flushTaskData()

	for iter_9_0, iter_9_1 in ipairs(self.stageTFList) do
		local var_9_3 = self.activity:GetEnemyDataById(var_9_0[iter_9_0])

		setText(iter_9_1:Find("name/text"), var_9_3:getConfig("name"))

		local var_9_4 = self:IsStageUnlock(var_9_3, var_9_1)

		self:UpdateAwardState(iter_9_0, iter_9_1, var_9_4)

		if var_9_4 then
			onButton(self, iter_9_1, function()
				self.fleetEditPanel = self:GetFleetEditPanel()

				self.fleetEditPanel.buffer:SetFleets((getProxy(FleetProxy):GetRegularFleets()))
				self.fleetEditPanel.buffer:SetSettings(1, 0, var_9_3:GetExpeditionId(), SYSTEM_REWARD_PERFORM, self.activity.configId)
				self.fleetEditPanel.buffer:UpdateView()
				self.fleetEditPanel.buffer:Show()
			end)

			if self.chainTFList[iter_9_0] then
				self:setChianMark(iter_9_0, true)
			end
		elseif self.chainTFList[iter_9_0] then
			self:setChianMark(iter_9_0, false)
		end
	end
end

function TwoPointFiveStagePage:GetFleetEditPanel()
	if not self.fleetEditPanel then
		self.fleetEditPanel = BossSingleBattleFleetSelectSubPanelLite.New(self)

		self.fleetEditPanel:Load()
	end

	return self.fleetEditPanel
end

function TwoPointFiveStagePage:setChianMark(arg_12_1, arg_12_2)
	setActive(self.chainTFList[arg_12_1]:Find("finish"), arg_12_2)
	setActive(self.chainTFList[arg_12_1]:Find("unfinish"), not arg_12_2)
end

function TwoPointFiveStagePage:OnUpdateFlush()
	self:flushTaskData()
	self:RefreshAwardStates()

	for iter_13_0, iter_13_1 in ipairs(self._taskList) do
		if iter_13_1:getTaskStatus() == 1 then
			self:emit(ActivityMediator.ON_TASK_SUBMIT, iter_13_1, function()
				self:flushTaskData()
				self:RefreshAwardStates()
			end)
		end
	end
end

function TwoPointFiveStagePage:OnDestroy()
	if self.fleetEditPanel then
		self.fleetEditPanel:OnHide()
	end
end

return TwoPointFiveStagePage
