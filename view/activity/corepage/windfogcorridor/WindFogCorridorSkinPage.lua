local WindFogCorridorSkinPage = class("WindFogCorridorSkinPage", import("view.activity.CorePage.CoreLoginTemplatePage"))

function WindFogCorridorSkinPage:OnInit()
	self.bg = self._tf:Find("bg")
	self.prog = self.bg:Find("total_progress/prog")
	self.item = self.bg:Find("item")
	self.items = self.bg:Find("items")
	self.uilist = UIItemList.New(self.items, self.item)
	self.btnDetail = self.bg:Find("btn_detail")
	self.getBtn = self.bg:Find("btn_get_pt")
	self.getBtnGray = self.bg:Find("btn_get_pt_gray")
end

function WindFogCorridorSkinPage:OnDataSetting()
	self.nday = 0
	self.taskProxy = getProxy(TaskProxy)
	self.clientConfig = self.activity:getConfig("config_client")
	self.taskGroup = self.clientConfig.unlock_task
	self.ptData = ActivityPtData.New((getProxy(ActivityProxy):getActivityById(self.clientConfig.ptActId)))

	return updateActivityTaskStatus(self.activity)
end

function WindFogCorridorSkinPage:OnFirstFlush()
	WindFogCorridorSkinPage.super.OnFirstFlush(self)
	onButton(self, self.btnDetail, function()
		self:emit(ActivityMediator.SHOW_AWARD_WINDOW, PtAwardWindow, {
			blur = true,
			isBtnActive = true,
			type = self.ptData.type,
			dropList = self.ptData.dropList,
			targets = self.ptData.targets,
			level = self.ptData.level,
			count = self.ptData.count,
			resId = self.ptData.resId,
			resDrop = Drop.New({
				type = DROP_TYPE_RESOURCE,
				id = self.ptData.resId
			}),
			unlockStamps = self.ptData:GetDayUnlockStamps(),
			ptActId = self.clientConfig.ptActId
		})
	end)
	onButton(self, self.getBtn, function()
		if not self.ptData or self.ptData:GetMaxAvailableTargetIndex() == self.ptData:GetLevel() then
			return
		end

		local var_5_0 = {}
		local var_5_1 = getProxy(PlayerProxy):getRawData()
		local var_5_3, var_5_4 = Task.StaticJudgeOverflow(var_5_1.gold, var_5_1.oil, LOCK_UR_SHIP and 0 or getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1]), true, true, (self.ptData:GetAllAvailableAwards()))

		if var_5_3 then
			table.insert(var_5_0, function(arg_6_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_ITEM_BOX,
					content = i18n("award_max_warning"),
					items = var_5_4,
					onYes = arg_6_0
				})
			end)
		end

		seriesAsync(var_5_0, function()
			self:emit(ActivityMediator.EVENT_PT_OPERATION, {
				cmd = 4,
				activity_id = self.ptData:GetId(),
				arg1 = self.ptData:GetCurrTarget()
			})
		end)
	end, SFX_PANEL)
end

function WindFogCorridorSkinPage:OnUpdateFlush()
	self.nday = self:getTaskIdx(self.activity)

	if not table.contains(self.taskGroup[self.nday], self.clientConfig.daily_task) then
		table.insert(self.taskGroup[self.nday], 2, self.clientConfig.daily_task)
	end

	if not table.contains(self.taskGroup[self.nday], self.clientConfig.once_task) then
		table.insert(self.taskGroup[self.nday], 4, self.clientConfig.once_task)
	end

	if self.prog then
		local var_8_0, var_8_1 = self:GetPtColor()

		setText(self.prog, (var_8_0 and setColorStr(self.ptData.count, var_8_0) or self.ptData.count) .. (var_8_1 and setColorStr("/" .. self.ptData:GetTotalResRequire(), var_8_1) or "/" .. self.ptData:GetTotalResRequire()))
	end

	self.uilist:align(#self.taskGroup[self.nday])
	setActive(self.getBtnGray, self.ptData:GetMaxAvailableTargetIndex() == self.ptData:GetLevel())
	setActive(self.getBtn, self.ptData:GetMaxAvailableTargetIndex() ~= self.ptData:GetLevel())
end

function WindFogCorridorSkinPage:getTaskIdx(arg_9_1)
	local var_9_0 = 1
	local var_9_1 = math.min(arg_9_1:getNDay(), #self.taskGroup)

	for iter_9_0 = 1, var_9_1 do
		if not true then
			break
		end

		var_9_0 = iter_9_0

		if iter_9_0 < var_9_1 then
			for iter_9_1, iter_9_2 in ipairs(self.taskGroup[iter_9_0]) do
				if iter_9_2 ~= self.clientConfig.daily_task and iter_9_2 ~= self.clientConfig.once_task and not self:isTaskFinished(iter_9_2) then
					break
				end
			end
		end
	end

	return math.min(var_9_0, #self.taskGroup)
end

function WindFogCorridorSkinPage:isTaskFinished(arg_10_1)
	self.taskProxy = self.taskProxy or getProxy(TaskProxy)

	local var_10_0 = self.taskProxy:getTaskById(arg_10_1) or self.taskProxy:getFinishTaskById(arg_10_1)

	originalPrint(" >>>>>>>>>> taskId = ", arg_10_1, ", isFinished = ", var_10_0 and var_10_0:getTaskStatus() == 2)

	return var_10_0 and var_10_0:getTaskStatus() == 2
end

function WindFogCorridorSkinPage:GetPtColor()
	return "#864749", "#f29b76"
end

return WindFogCorridorSkinPage
