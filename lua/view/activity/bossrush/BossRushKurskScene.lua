local BossRushKurskScene = class("BossRushKurskScene", import("view.base.BaseUI"))
local PoolPlural = require("Mgr/Pool/PoolPlural")

BossRushKurskScene.DISPLAY = {
	STORY = 2,
	BATTLE = 1
}

function BossRushKurskScene:getUIName()
	return "BossRushKurskUI"
end

function BossRushKurskScene:GetAtalsName()
	return "ui/BossRushKurskUI_atlas"
end

function BossRushKurskScene:getResource()
	local var_3_0 = BossRushKurskScene.super.getResource(self)

	table.insert(var_3_0, self:GetAtalsName())

	return var_3_0
end

function BossRushKurskScene:ResUISettings()
	return true
end

function BossRushKurskScene:Ctor()
	BossRushKurskScene.super.Ctor(self)

	self.loader = AutoLoader.New()
end

function BossRushKurskScene:preload(arg_6_1)
	existCall(arg_6_1)
	self.loader:LoadBundle(self:GetAtalsName())
end

function BossRushKurskScene:init()
	self.top = self._tf:Find("Top")
	self.map = self._tf:Find("Map")

	local var_7_0 = self._tf:Find("Battle/Nodes")

	self.seriesNodes = {}

	for iter_7_0 = 1, var_7_0.childCount do
		local var_7_1 = var_7_0:GetChild(iter_7_0 - 1)

		if isActive(var_7_1) then
			table.insert(self.seriesNodes, var_7_1)
		end
	end

	self.ptText = self._tf:Find("Battle/Reward/Text")
	self.nodes = {}

	for iter_7_1 = 1, self._tf:Find("Map").childCount do
		local var_7_2 = self._tf:Find("Map"):GetChild(iter_7_1 - 1)

		self.nodes[var_7_2.name] = {
			tfType = 1,
			trans = var_7_2
		}
	end

	for iter_7_2 = 1, self._tf:Find("Story/Nodes").childCount do
		local var_7_3 = self._tf:Find("Story/Nodes"):GetChild(iter_7_2 - 1)

		self.nodes[var_7_3.name] = {
			tfType = 2,
			trans = var_7_3
		}
	end

	self.pluralRoot = pg.PoolMgr.GetInstance().root

	local var_7_4 = go(self._tf:Find("Link"))

	setActive(var_7_4, false)

	self.plural = PoolPlural.New(var_7_4, 32)
	self.linksContainer = self._tf:Find("Links")
	self.links = {}
	self.storyBar = self._tf:Find("Story/StoryBar")
	self.storyAward = self._tf:Find("Story/PassLevel/Award")
	self.ActionSequence = {}

	setText(self._tf:Find("Battle/Rank/Title"), i18n("word_billboard"))
	setText(self._tf:Find("Battle/Reward/Title"), i18n("series_enemy_reward"))
	setText(self._tf:Find("Story/PassLevel/Title"), i18n("series_enemy_storyreward"))
	setText(self._tf:Find("Story/PassLevel/PT/Tips"), i18n("series_enemy_storyunlock"))
end

function BossRushKurskScene:SetActivity(arg_8_1)
	self.activity = arg_8_1
end

function BossRushKurskScene:SetPtActivity(arg_9_1)
	self.ptActivity = arg_9_1
	self.ptData = ActivityPtData.New(self.ptActivity)
end

function BossRushKurskScene:didEnter()
	onButton(self, self.top:Find("back_btn"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self.top:Find("option"), function()
		self:quickExitFunc()
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = {
				{
					info = i18n("series_enemy_help")
				}
			}
		})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Battle/Rank"), function()
		self:emit(BossRushKurskMediator.ON_EXTRA_RANK)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Battle/Reward"), function()
		self:emit(BossRushKurskMediator.GO_ACT_SHOP, self.ptData)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Battle/Story"), function()
		self:SetDisplayMode(BossRushKurskScene.DISPLAY.STORY)
	end, SFX_PANEL)
	onButton(self, self._tf:Find("Story/Battle"), function()
		self:SetDisplayMode(BossRushKurskScene.DISPLAY.BATTLE)
	end, SFX_PANEL)

	self.storyNodesDict = {}

	_.each(self.activity:getConfig("config_client").storys or {}, function(arg_18_0)
		self.storyNodesDict[arg_18_0] = BossRushStoryNode.New({
			id = arg_18_0
		})
	end)

	if #(self.activity:getConfig("config_client").tasks or {}) > 0 then
		local var_10_0 = self.activity:getConfig("config_client").tasks[1]
		local var_10_1 = getProxy(TaskProxy):getTaskVO(var_10_0)

		var_10_1 = var_10_1 or Task.New({
			submitTime = 1,
			id = var_10_0
		})
		self.storyTask = var_10_1
	end

	self.contextData.displayMode = nil

	self:SetDisplayMode(self.contextData.displayMode or BossRushKurskScene.DISPLAY.BATTLE)
end

function BossRushKurskScene:getBGM()
	if not pg.voice_bgm[self.__cname] then
		return nil
	end

	if self.contextData.displayMode == BossRushKurskScene.DISPLAY.BATTLE then
		return pg.voice_bgm[self.__cname].bgm
	elseif self.contextData.displayMode == BossRushKurskScene.DISPLAY.STORY then
		return "battle-deepecho"
	end
end

function BossRushKurskScene:SetDisplayMode(arg_20_1)
	if arg_20_1 == self.contextData.displayMode then
		return
	end

	self.contextData.displayMode = arg_20_1

	self:PlayBGM()
	self:UpdateView()
end

function BossRushKurskScene:UpdateView()
	local var_21_0 = self.contextData.displayMode == BossRushKurskScene.DISPLAY.BATTLE

	setActive(self._tf:Find("Battle"), self.contextData.displayMode == BossRushKurskScene.DISPLAY.BATTLE)
	setActive(self._tf:Find("Story"), not var_21_0)
	setActive(self._tf:Find("Links"), not var_21_0)
	self:UpdateBattle()
	self:UpdateStory()

	local var_21_1 = self.contextData.displayMode

	self:addbubbleMsgBoxList({
		function(arg_22_0)
			if self.activity:HasPassSeries(1001) then
				pg.SystemGuideMgr.GetInstance():PlayByGuideId("NG0036", nil, arg_22_0)

				return
			end

			arg_22_0()
		end,
		function(arg_23_0)
			local var_23_0

			if var_21_1 == BossRushKurskScene.DISPLAY.BATTLE then
				var_23_0 = self.activity:getConfig("config_client").openActivityStory
			elseif var_21_1 == BossRushKurskScene.DISPLAY.STORY then
				var_23_0 = self.activity:getConfig("config_client").openStory
			end

			self:PlayStory(var_23_0, arg_23_0)
		end,
		function(arg_24_0)
			if underscore.all(underscore.values(self.storyNodesDict), function(arg_25_0)
				return arg_25_0:IsReaded()
			end) then
				self:PlayStory(self.activity:getConfig("config_client").endStory, function(arg_26_0)
					arg_24_0()

					if arg_26_0 then
						self:UpdateView()
					end
				end)

				return
			end

			arg_24_0()
		end
	})
end

function BossRushKurskScene:UpdateBattle()
	local var_27_0 = self.activity
	local var_27_1 = self.activity:GetActiveSeriesIds()

	table.Foreach(self.seriesNodes, function(arg_28_0, arg_28_1)
		local var_28_0 = BossRushSeriesData.New({
			id = var_27_1[arg_28_0],
			actId = var_27_0.id
		})
		local var_28_1 = var_28_0:IsUnlock(var_27_0)

		setActive(arg_28_1:Find("Pin/NameBG"), var_28_1)
		setActive(arg_28_1:Find("Pin/Lock"), not var_28_1)
		setText(arg_28_1:Find("Pin/ChapterName"), var_28_0:GetSeriesCode())
		setText(arg_28_1:Find("Pin/NameBG/Name"), var_28_0:GetName())

		local var_28_2 = var_28_0:GetType() == BossRushSeriesData.TYPE.SP

		setActive(arg_28_1:Find("Pin/NameBG/BonusCount"), var_28_1 and var_28_2)

		local var_28_3 = true

		if var_28_2 then
			local var_28_4 = var_27_0:GetUsedBonus()[arg_28_0] or 0
			local var_28_5 = var_28_0:GetMaxBonusCount()

			setText(arg_28_1:Find("Pin/NameBG/BonusCount"):GetChild(0), i18n("series_enemy_SP_count"))
			setText(arg_28_1:Find("Pin/NameBG/BonusCount"):GetChild(1), math.max(0, var_28_5 - var_28_4) .. "/" .. var_28_5)

			var_28_3 = var_28_5 - var_28_4 > 0
		end

		onButton(self, arg_28_1, function()
			if not var_28_1 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("series_enemy_unlock", BossRushSeriesData.New({
					id = var_28_0:GetPreSeriesId()
				}):GetName()))

				return
			end

			if not var_28_3 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("series_enemy_SP_error"))

				return
			end

			self:emit(BossRushKurskMediator.ON_FLEET_SELECT, var_28_0)
		end, SFX_PANEL)
	end)
	setActive(self._tf:Find("Battle/Reward/Tip"), self.ptData:CanGetAward())
	setText(self.ptText, self.ptActivity.data1)
end

local var_0_2 = {
	"story_bar_green",
	"story_bar_yellow",
	"story_bar_purple"
}

function BossRushKurskScene:UpdateStory()
	local var_30_0 = pg.NewStoryMgr.GetInstance()
	local var_30_1
	local var_30_2

	self:ReturnLinks()

	local var_30_3 = false

	table.Foreach(self.storyNodesDict, function(arg_31_0, arg_31_1)
		local var_31_0 = self.nodes[arg_31_1:GetIconName()].trans
		local var_31_1 = arg_31_1:IsActive(self.activity, self.ptActivity)
		local var_31_2 = arg_31_1:IsReaded()
		local var_31_3 = arg_31_1:GetType()

		if var_31_3 == BossRushStoryNode.NODE_TYPE.NORMAL then
			self.loader:GetSprite(self:GetAtalsName(), var_31_1 and "story_green_active" or "story_green", var_31_0:GetChild(0), true)
		elseif var_31_3 == BossRushStoryNode.NODE_TYPE.EVENT then
			setActive(var_31_0, var_31_1)
			self.loader:GetSprite(self:GetAtalsName(), var_31_1 and "story_yellow_active" or "story_yellow", var_31_0:GetChild(0), true)
		elseif var_31_3 == BossRushStoryNode.NODE_TYPE.BATTLE then
			-- block empty
		end

		if var_31_1 then
			setAnchoredPosition(self.storyBar, (self._tf:Find("Story"):InverseTransformPoint(var_31_0.position)))
			setText(self.storyBar:Find("Text"), arg_31_1:GetName())
			self.loader:GetSprite(self:GetAtalsName(), var_0_2[var_31_3], self.storyBar, true)
			onButton(self, self.storyBar, function()
				self:PlayStory(arg_31_1:GetStory(), function()
					self:UpdateView()
				end)
			end)

			var_30_3 = true
		end

		local var_31_4 = arg_31_1:GetActiveLink()

		;(function()
			if var_31_4 == 0 or not var_31_2 then
				return
			end

			local var_34_0 = self.nodes[self.storyNodesDict[var_31_4]:GetIconName()].trans
			local var_34_1 = self.plural:Dequeue()

			table.insert(self.links, go(var_34_1))
			setActive(var_34_1, true)
			setParent(var_34_1, self.linksContainer)

			local var_34_2 = self.linksContainer:InverseTransformPoint(var_31_0.position)
			local var_34_3 = self.linksContainer:InverseTransformPoint(var_34_0.position) - var_34_2

			tf(var_34_1).sizeDelta = Vector2(Vector2.Magnitude(var_34_3), 2)
			tf(var_34_1).anchoredPosition = var_34_2
			tf(var_34_1).localRotation = Quaternion.FromToRotation(Vector3.right, var_34_3)
		end)()
		_.each(arg_31_1:GetTriggers(), function(arg_35_0)
			if arg_35_0.type == BossRushStoryNode.TRIGGER_TYPE.PT_GOT then
				if var_31_1 then
					var_30_2 = var_30_2 and math.max(arg_35_0.value, var_30_2) or arg_35_0.value
				else
					var_30_1 = var_30_1 and math.min(arg_35_0.value, var_30_1) or arg_35_0.value
				end
			end
		end)
	end)
	setText(self._tf:Find("Story/PassLevel/PT/Text"), self.ptActivity.data1 .. "/" .. (nil or nil or ""))
	setText(self._tf:Find("Story/PassLevel/Values"):GetChild(0), 0)
	setText(self._tf:Find("Story/PassLevel/Values"):GetChild(2), 0)
	setActive(self.storyBar, false)
	setActive(self.storyAward, tobool(self.storyTask))

	if self.storyTask then
		local var_30_4 = self.storyTask:getConfig("award_display")
		local var_30_5 = {
			type = var_30_4[1][1],
			id = var_30_4[1][2],
			count = var_30_4[1][3]
		}

		updateDrop(self.storyAward:Find("Mask"):GetChild(0), var_30_5)
		onButton(self, self.storyAward:Find("Mask"):GetChild(0), function()
			self:emit(BaseUI.ON_DROP, var_30_5)
		end)

		local var_30_6 = self.storyTask:getTaskStatus()

		setActive(self.storyAward:Find("Got"), var_30_6 == 2)

		if var_30_6 == 1 then
			self:emit(BossRushKurskMediator.ON_TASK_SUBMIT, self.storyTask)
		end
	end

	setActive(self._tf:Find("Battle/Story/New"), false)
end

function BossRushKurskScene:ReturnLinks(arg_37_1)
	for iter_37_0, iter_37_1 in ipairs(self.links) do
		if not self.plural:Enqueue(iter_37_1, arg_37_1) then
			setParent(iter_37_1, self.pluralRoot)
		end
	end

	table.clean(self.links)
end

function BossRushKurskScene:PlayStory(arg_38_1, arg_38_2)
	if not arg_38_1 then
		return existCall(arg_38_2)
	end

	local var_38_0 = pg.NewStoryMgr.GetInstance()
	local var_38_1 = var_38_0:IsPlayed(arg_38_1)

	seriesAsync({
		function(arg_39_0)
			if var_38_1 then
				return arg_39_0()
			end

			local var_39_0 = tonumber(arg_38_1)

			if var_39_0 and var_39_0 > 0 then
				self:emit(BossRushKurskMediator.ON_PERFORM_COMBAT, var_39_0)
			else
				var_38_0:Play(arg_38_1, arg_39_0)
			end
		end,
		function(arg_40_0, ...)
			existCall(arg_38_2, ...)
		end
	})
end

function BossRushKurskScene:UpdateTasks(arg_41_1)
	if _.any(arg_41_1, function(arg_42_0)
		return self.storyTask and self.storyTask.id == arg_42_0
	end) then
		self.storyTask.submitTime = 1

		self:UpdateView()
	end
end

function BossRushKurskScene:addbubbleMsgBoxList(arg_43_1)
	local var_43_0 = #self.ActionSequence == 0

	table.insertto(self.ActionSequence, arg_43_1)

	if not var_43_0 then
		return
	end

	self:resumeBubble()
end

function BossRushKurskScene:addbubbleMsgBox(arg_44_1)
	local var_44_0 = #self.ActionSequence == 0

	table.insert(self.ActionSequence, arg_44_1)

	if not var_44_0 then
		return
	end

	self:resumeBubble()
end

function BossRushKurskScene:resumeBubble()
	if #self.ActionSequence == 0 then
		return
	end

	local function var_45_1()
		if self.ActionSequence[1] then
			self.ActionSequence[1](function()
				table.remove(self.ActionSequence, 1)
				var_45_1()
			end)
		end
	end

	;(nil)()
end

function BossRushKurskScene:CleanBubbleMsgbox()
	table.clean(self.ActionSequence)
end

function BossRushKurskScene:willExit()
	self:ReturnLinks(true)
	self.loader:Clear()
	BossRushKurskScene.super.willExit(self)
end

return BossRushKurskScene
