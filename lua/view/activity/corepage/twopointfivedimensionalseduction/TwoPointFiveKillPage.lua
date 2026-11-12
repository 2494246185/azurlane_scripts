local TwoPointFiveKillPage = class("TwoPointFiveKillPage", import("..CoreActivityPage"))

function TwoPointFiveKillPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.rtTask = self.bg:Find("task")
	self.step = self.rtTask:Find("step")
	self.nowday = self.step:Find("nowday")
	self.aimday = self.step:Find("aimday")
	self.progress = self.rtTask:Find("progress")
	self.slider = self.progress:Find("slider")
	self.awardTF = self.progress:Find("award")
	self.progressStep = self.progress:Find("step")
	self.progressRule = self.progress:Find("rule")
	self.BtnGroup = self.rtTask:Find("BtnGroup")
	self.displayBtn = self.BtnGroup:Find("Check_btn")
	self.battleBtn = self.BtnGroup:Find("battle_btn")
	self.getBtn = self.BtnGroup:Find("get_btn")
	self.gotBtn = self.BtnGroup:Find("got_btn")
end

function TwoPointFiveKillPage:OnDataSetting()
	if self.ptData then
		self.ptData:Update(self.activity)
	else
		self.ptData = ActivityPtData.New(self.activity)
	end
end

function TwoPointFiveKillPage:InitBtn()
	onButton(self, self.displayBtn, function()
		self:emit(ActivityMediator.SHOW_AWARD_WINDOW, PtAwardWindow, {
			blur = true,
			type = self.ptData.type,
			dropList = self.ptData.dropList,
			targets = self.ptData.targets,
			level = self.ptData.level,
			count = self.ptData.count,
			resId = self.ptData.resId,
			unlockStamps = self.ptData:GetDayUnlockStamps()
		})
	end, SFX_PANEL)
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.GO_Activity_level)
	end, SFX_PANEL)
	onButton(self, self.getBtn, function()
		local var_6_0 = {}
		local var_6_1 = self.ptData:GetAward()
		local var_6_2 = getProxy(PlayerProxy):getRawData()
		local var_6_3, var_6_4 = Task.StaticJudgeOverflow(var_6_2.gold, var_6_2.oil, LOCK_UR_SHIP and 0 or getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1]), true, true, {
			{
				var_6_1.type,
				var_6_1.id,
				var_6_1.count
			}
		})

		if var_6_3 then
			table.insert(var_6_0, function(arg_7_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_ITEM_BOX,
					content = i18n("award_max_warning"),
					items = var_6_4,
					onYes = arg_7_0
				})
			end)
		end

		seriesAsync(var_6_0, function()
			local var_8_0, var_8_1 = self.ptData:GetResProgress()

			self:emit(ActivityMediator.EVENT_PT_OPERATION, {
				cmd = 1,
				activity_id = self.ptData:GetId(),
				arg1 = var_8_1
			})
		end)
	end, SFX_PANEL)
end

function TwoPointFiveKillPage:OnFirstFlush()
	self:InitBtn()
end

function TwoPointFiveKillPage:OnUpdateFlush()
	setText(self.progressRule, i18n("nier_core_task_desc"))

	local var_10_0 = self.ptData:getTargetLevel()
	local var_10_1, var_10_2, var_10_3 = self.ptData:GetLevelProgress()

	setText(self.nowday, string.format("%s", var_10_1))
	setText(self.aimday, string.format("/%s", var_10_2))

	local var_10_4, var_10_5, var_10_6 = self.ptData:GetResProgress()

	setText(self.progressStep, string.format("%s<color=#bdbad1>/%s</color>", var_10_6 >= 1 and setColorStr(var_10_4, COLOR_GREEN) or var_10_4, var_10_5))
	setSlider(self.slider, 0, 1, var_10_6)

	local var_10_7 = self.ptData:CanGetAward()
	local var_10_8 = self.ptData:CanGetNextAward()

	setActive(self.battleBtn, self.ptData:CanGetMorePt() and not var_10_7 and var_10_8)
	setActive(self.getBtn, var_10_7)
	setActive(self.gotBtn, not var_10_8)

	local var_10_9 = self.ptData:GetAward()

	updateDrop(self.awardTF, var_10_9)
	onButton(self, self.awardTF, function()
		self:emit(BaseUI.ON_DROP, var_10_9)
	end, SFX_PANEL)
end

function TwoPointFiveKillPage:OnDestroy()
	return
end

function TwoPointFiveKillPage:GetWorldPtData(arg_13_1)
	if arg_13_1 <= pg.TimeMgr.GetInstance():GetServerTime() - (ActivityMainScene.Data2Time or 0) then
		ActivityMainScene.Data2Time = pg.TimeMgr.GetInstance():GetServerTime()

		self:emit(ActivityMediator.EVENT_PT_OPERATION, {
			cmd = 2,
			activity_id = self.ptData:GetId()
		})
	end
end

return TwoPointFiveKillPage
