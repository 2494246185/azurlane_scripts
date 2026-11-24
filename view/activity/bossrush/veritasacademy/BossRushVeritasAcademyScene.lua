local BossRushVeritasAcademyScene = class("BossRushVeritasAcademyScene", import("view.activity.BossRush.BossRushBaseScene"))

BossRushVeritasAcademyScene.DISPLAY = {
	STORY = "Story",
	BATTLE = "Battle"
}
BossRushVeritasAcademyScene.STORY_ICON2_NODE_IDS = {
	[204] = true,
	[202] = true,
	[203] = true
}

function BossRushVeritasAcademyScene:getUIName()
	return "BossRushVeritasAcademyUI"
end

function BossRushVeritasAcademyScene:GetAtalsName()
	return "ui/" .. self:getUIName() .. "_atlas"
end

function BossRushVeritasAcademyScene:SetActivity(arg_3_1)
	self.activity = arg_3_1
end

function BossRushVeritasAcademyScene:SetPtActivity(arg_4_1)
	self.ptActivity = arg_4_1
	self.ptData = ActivityPtData.New(self.ptActivity)
end

function BossRushVeritasAcademyScene:init()
	self.top = self._tf:Find("Top")
	self.ptBtn = self.top:Find("right/pt")
	self.ptTip = self.ptBtn:Find("tip")
	self.rankBtn = self.top:Find("right/rank")
	self.taskBtn = self.top:Find("right/task")
	self.taskTip = self.taskBtn:Find("tip")
	self.rightPanel = self.top:Find("right")
	self.storyAward = self.top:Find("bottom/Award")
	self.progressText = self.storyAward:Find("desc")
	self.seriesNodes = {}

	eachChild(self._tf:Find("Battle/Nodes"), function(arg_6_0, arg_6_1)
		self.seriesNodes[arg_6_0.name] = arg_6_0
	end)

	self.nodes = {}
	self.storyScrollRect = self._tf:Find("Story/View"):GetComponent(typeof(ScrollRect))

	eachChild(self._tf:Find("Story/View/Nodes"), function(arg_7_0, arg_7_1)
		setActive(arg_7_0, false)
		eachChild(arg_7_0, function(arg_8_0, arg_8_1)
			self.nodes[arg_8_0.name] = arg_8_0
		end)
	end)

	self.switchToggle = self.top:Find("bottom/switch_toggle")
	self.ActionSequence = {}

	self:UpdateRatioScale()

	self.camEventId = pg.CameraFixMgr.GetInstance():bind(pg.CameraFixMgr.ASPECT_RATIO_UPDATE, function(arg_9_0, arg_9_1)
		self:UpdateRatioScale()
	end)
end

function BossRushVeritasAcademyScene:didEnter()
	onButton(self, self.top:Find("top/back"), function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.top:Find("top/home"), function()
		self:quickExitFunc()
	end, SFX_PANEL)
	onButton(self, self.top:Find("top/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("zhenli_series_help")
		})
	end, SFX_PANEL)
	onButton(self, self.rankBtn, function()
		self:emit(BossRushVeritasAcademyMediator.ON_EXTRA_RANK)
	end, SFX_PANEL)
	onButton(self, self.ptBtn, function()
		self:emit(BossRushVeritasAcademyMediator.GO_SCENE, SCENE.ACTIVITY, {
			id = self.ptActivity.id
		})
	end, SFX_PANEL)
	onButton(self, self.taskBtn, function()
		self:emit(BossRushVeritasAcademyMediator.GO_SCENE, SCENE.TASK)
	end, SFX_PANEL)
	onToggle(self, self.switchToggle:Find("Story"), function(arg_17_0)
		if arg_17_0 then
			self:SetDisplayMode(BossRushVeritasAcademyScene.DISPLAY.STORY)
		end
	end, SFX_PANEL)
	onToggle(self, self.switchToggle:Find("Battle"), function(arg_18_0)
		if arg_18_0 then
			self:SetDisplayMode(BossRushVeritasAcademyScene.DISPLAY.BATTLE)
		end
	end, SFX_PANEL)

	self.storyNodesDict = {}

	for iter_10_0, iter_10_1 in ipairs(self.activity:getConfig("config_client").storys) do
		self.storyNodesDict[iter_10_1] = BossRushStoryNode.New({
			id = iter_10_1
		})
	end

	triggerToggle(self.switchToggle:Find(self.contextData.displayMode or BossRushVeritasAcademyScene.DISPLAY.BATTLE), true)
end

function BossRushVeritasAcademyScene:getBGM()
	return self.contextData.displayMode == BossRushVeritasAcademyScene.DISPLAY.STORY and "story-richang-afterschool" or "story-enzecheng-theme"
end

function BossRushVeritasAcademyScene:getBG()
	return self.contextData.displayMode == BossRushVeritasAcademyScene.DISPLAY.BATTLE and "bg1" or "bg2"
end

function BossRushVeritasAcademyScene:SetDisplayMode(arg_21_1)
	self.contextData.displayMode = arg_21_1

	self:UpdateView()
end

function BossRushVeritasAcademyScene:UpdateRatioScale(arg_22_1)
	local var_22_0

	for iter_22_0, iter_22_1 in ipairs({
		"Mask",
		"Battle",
		"Story"
	}) do
		local var_22_1 = self._tf:Find(iter_22_1)

		var_22_0 = var_22_0 or var_22_1.rect.height > 1440 and var_22_1.rect.height / 1440 or 1

		setLocalScale(var_22_1, {
			x = var_22_0,
			y = var_22_0
		})
	end
end

function BossRushVeritasAcademyScene:UpdateView()
	local var_23_0 = self.contextData.displayMode == BossRushVeritasAcademyScene.DISPLAY.BATTLE

	setActive(self._tf:Find("Battle"), self.contextData.displayMode == BossRushVeritasAcademyScene.DISPLAY.BATTLE)
	setActive(self._tf:Find("Story"), not var_23_0)
	setActive(self.storyAward, not var_23_0)
	setActive(self.rightPanel, var_23_0)

	if var_23_0 then
		self:UpdateBattle()
	else
		self:UpdateStory()
	end

	self:UpdateStoryTask()
	self:CheckStoryTask()

	local var_23_1 = self:getBG()

	eachChild(self._tf:Find("Mask"), function(arg_24_0, arg_24_1)
		setActive(arg_24_0, arg_24_0.name == var_23_1)
	end)
	self:PlayBGM()
	setText(self.ptBtn:Find("value/Text"), self.ptActivity.data1)
	setActive(self.ptTip, Activity.IsActivityReady(self.ptActivity))

	local var_23_2 = self.contextData.displayMode

	self:addbubbleMsgBoxList({
		function(arg_25_0)
			local var_25_0

			if var_23_2 == BossRushVeritasAcademyScene.DISPLAY.BATTLE then
				var_25_0 = self.activity:getConfig("config_client").openActivityStory
			elseif var_23_2 == BossRushVeritasAcademyScene.DISPLAY.STORY then
				var_25_0 = self.activity:getConfig("config_client").openStory
			end

			self:PlayStory(var_25_0, arg_25_0)
		end,
		function(arg_26_0)
			if underscore.all(underscore.values(self.storyNodesDict), function(arg_27_0)
				return arg_27_0:IsReaded()
			end) and self.storyTask and self.storyTask:getTaskStatus() == 2 then
				self:PlayStory(self.activity:getConfig("config_client").endStory, arg_26_0)
			else
				arg_26_0()
			end
		end
	})
end

function BossRushVeritasAcademyScene:UpdateBattle()
	for iter_28_0, iter_28_1 in ipairs((self.activity:GetActiveSeriesIds())) do
		local var_28_0 = self.seriesNodes[tostring(iter_28_1)]
		local var_28_1 = BossRushSeriesData.New({
			id = iter_28_1,
			actId = self.activity.id
		})
		local var_28_2 = var_28_1:IsUnlock(self.activity)

		setActive(var_28_0, var_28_2)

		local var_28_3 = var_28_0:Find("main")

		setText(var_28_3:Find("Text"), var_28_1:GetName())

		if var_28_1:GetType() == BossRushSeriesData.TYPE.SP and not IsNil(var_28_3:Find("times")) then
			local var_28_4 = self.activity:GetUsedBonus()[iter_28_0] or 0
			local var_28_5 = var_28_1:GetMaxBonusCount()

			setText(var_28_3:Find("times/Text"), i18n("series_enemy_SP_count") .. math.max(0, var_28_5 - var_28_4) .. "/" .. var_28_5)
		end

		onButton(self, var_28_0, function()
			if not var_28_2 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("series_enemy_unlock", BossRushSeriesData.New({
					id = var_28_1:GetPreSeriesId()
				}):GetName()))

				return
			end

			self:emit(BossRushVeritasAcademyMediator.ON_FLEET_SELECT, var_28_1)
		end, SFX_PANEL)
	end
end

function BossRushVeritasAcademyScene:UpdateStoryIcon(arg_30_1, arg_30_2)
	local var_30_0 = arg_30_2:Find("main/icon")
	local var_30_1 = var_30_0:Find("story")
	local var_30_2 = var_30_0:Find("battle")

	if BossRushVeritasAcademyScene.STORY_ICON2_NODE_IDS[arg_30_1.id] then
		setActive(var_30_1, true)
		setActive(var_30_2, false)
		GetImageSpriteFromAtlasAsync(self:GetAtalsName(), "icon_story_2", var_30_1)

		return
	end

	local var_30_3 = arg_30_1:GetType()

	setActive(var_30_1, var_30_3 == BossRushStoryNode.NODE_TYPE.NORMAL)
	setActive(var_30_2, var_30_3 == BossRushStoryNode.NODE_TYPE.BATTLE)
end

function BossRushVeritasAcademyScene:UpdateStory()
	local var_31_0 = pg.NewStoryMgr.GetInstance()
	local var_31_1 = 0
	local var_31_2 = 0

	for iter_31_0, iter_31_1 in pairs(self.storyNodesDict) do
		local var_31_3 = self.nodes[tostring(iter_31_1.id)]
		local var_31_4 = iter_31_1:IsActive(self.activity, self.ptActivity)

		setActive(var_31_3, var_31_4)

		if var_31_4 then
			setActive(var_31_3.parent, true)
		end

		setText(var_31_3:Find("main/Text"), iter_31_1:GetName())

		local var_31_5 = iter_31_1:IsReaded()
		local var_31_6 = iter_31_1:IsLockBranchType(self.activity, self.ptActivity)

		var_31_1 = var_31_1 + (var_31_5 and 1 or 0)
		var_31_2 = var_31_2 + 1

		setActive(var_31_3:Find("main/bg/normal"), not var_31_5 and not var_31_6)
		setActive(var_31_3:Find("main/bg/finished"), var_31_5)
		setActive(var_31_3:Find("main/bg/lock"), var_31_6)
		setActive(var_31_3:Find("main/icon"), not var_31_6)
		self:UpdateStoryIcon(iter_31_1, var_31_3)
		eachChild(var_31_3:Find("line"), function(arg_32_0, arg_32_1)
			eachChild(arg_32_0, function(arg_33_0, arg_33_1)
				setImageColor(arg_33_0, Color.NewHex(var_31_5 and "#0056b9" or "#45556f"))
				setImageAlpha(arg_33_0, var_31_6 and 0.5 or 1)
			end)
		end)
		onButton(self, var_31_3, function()
			if not var_31_4 then
				return
			end

			self:PlayStory(iter_31_1:GetStory(), function()
				self:UpdateView()
			end, iter_31_1, true)
		end)
	end

	setText(self.progressText, i18n("guaitan_story_reward_count"))
	setText(findTF(self.progressText, "progress"), setColorStr(var_31_1, "#ffffff") .. "/" .. var_31_2)
	self:UpdateStoryTask()
	scrollTo(self.storyScrollRect, 1, 0)
end

function BossRushVeritasAcademyScene:PlayStory(arg_36_1, arg_36_2, arg_36_3, arg_36_4)
	if not arg_36_1 then
		return existCall(arg_36_2)
	end

	local var_36_0 = pg.NewStoryMgr.GetInstance()

	seriesAsync({
		function(arg_37_0)
			local var_37_0 = tonumber(arg_36_1)

			if var_37_0 and var_37_0 > 0 then
				self:emit(BossRushVeritasAcademyMediator.ON_PERFORM_COMBAT, var_37_0)
			else
				var_36_0:Play(arg_36_1, function(arg_38_0, arg_38_1)
					if arg_36_3 and arg_38_1 then
						BossRushStoryNode.SetLocalBranchFlag(self.activity.id, arg_36_3.id, arg_38_1)
					end

					arg_37_0()
				end, arg_36_4)
			end
		end
	}, arg_36_2)
end

function BossRushVeritasAcademyScene:UpdateStoryTask()
	local var_39_0 = self.activity:getConfig("config_client").tasks[1]
	local var_39_1 = getProxy(TaskProxy):getTaskVO(var_39_0)

	var_39_1 = var_39_1 or Task.New({
		submit_time = 1,
		id = var_39_0
	})
	self.storyTask = var_39_1

	setActive(self.switchToggle:Find("Story/tip"), self.storyTask and self.storyTask:getTaskStatus() ~= 2)
	setActive(self.taskTip, Activity.IsActivityReady(getProxy(ActivityProxy):getActivityById(ActivityConst.VERITASACADEMY_BOSS_RUSH_TASK_ACT_ID)))

	local var_39_2 = self.storyAward:Find("award_bg")

	updateDrop(var_39_2:Find("IconTpl"), (Drop.Create(self.storyTask:getConfig("award_display")[1])))

	local var_39_3 = self.storyTask:getTaskStatus()

	setActive(var_39_2:Find("get"), var_39_3 == 1)
	setActive(var_39_2:Find("got"), var_39_3 == 2)
end

function BossRushVeritasAcademyScene:CheckStoryTask()
	if self.storyTask:getTaskStatus() == 1 then
		self:emit(BossRushVeritasAcademyMediator.ON_TASK_SUBMIT, self.storyTask)
	end
end

function BossRushVeritasAcademyScene:addbubbleMsgBoxList(arg_41_1)
	local var_41_0 = #self.ActionSequence == 0

	table.insertto(self.ActionSequence, arg_41_1)

	if not var_41_0 then
		return
	end

	self:resumeBubble()
end

function BossRushVeritasAcademyScene:addbubbleMsgBox(arg_42_1)
	local var_42_0 = #self.ActionSequence == 0

	table.insert(self.ActionSequence, arg_42_1)

	if not var_42_0 then
		return
	end

	self:resumeBubble()
end

function BossRushVeritasAcademyScene:resumeBubble()
	if #self.ActionSequence == 0 then
		return
	end

	local function var_43_1()
		if self.ActionSequence[1] then
			self.ActionSequence[1](function()
				table.remove(self.ActionSequence, 1)
				var_43_1()
			end)
		end
	end

	;(nil)()
end

function BossRushVeritasAcademyScene:CleanBubbleMsgbox()
	table.clean(self.ActionSequence)
end

function BossRushVeritasAcademyScene:willExit()
	if self.camEventId then
		pg.CameraFixMgr.GetInstance():disconnect(self.camEventId)

		self.camEventId = nil
	end
end

return BossRushVeritasAcademyScene
