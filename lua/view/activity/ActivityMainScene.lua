local ActivityMainScene = class("ActivityMainScene", import("..base.BaseUI"))

ActivityMainScene.LOCK_ACT_MAIN = "ActivityMainScene:LOCK_ACT_MAIN"
ActivityMainScene.UPDATE_ACTIVITY = "ActivityMainScene:UPDATE_ACTIVITY"
ActivityMainScene.GET_PAGE_BGM = "ActivityMainScene.GET_PAGE_BGM"
ActivityMainScene.FLUSH_TABS = "ActivityMainScene.FLUSH_TABS"

function ActivityMainScene:getResource()
	local var_1_0 = {
		"activitybanner",
		"activityuitable",
		"ui/ActivitybonusWindow",
		"ui/ActivitybonusWindow_nonPt",
		"ui/ChargeTipUI",
		"ui/MonthCardTipWindow",
		"ui/GiftPackageTipWindow",
		"ui/CrusingTipWindow",
		"ui/iconcolorful",
		"activitybanner/empty",
		"activityuitable/activity_text",
		"activityuitable/activity_text_selected"
	}

	local function var_1_1(arg_2_0)
		if not table.contains(var_1_0, arg_2_0) then
			table.insert(var_1_0, arg_2_0)
		end
	end

	for iter_1_0, iter_1_1 in ipairs(getProxy(ActivityProxy):getPanelActivities()) do
		local var_1_2 = iter_1_1:getConfig("title_res_tag")

		if noEmptyStr(var_1_2) then
			var_1_1("activityuitable/" .. var_1_2 .. "_text")
			var_1_1("activityuitable/" .. var_1_2 .. "_text_selected")
		end
	end

	for iter_1_2, iter_1_3 in ipairs((getProxy(ActivityPermanentProxy):getActivityIdsByType(ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY))) do
		if noEmptyStr(pg.activity_template[pg.activity_task_permanent[iter_1_3].id].title_res_tag) then
			var_1_1("activityuitable/" .. pg.activity_template[pg.activity_task_permanent[iter_1_3].id].title_res_tag .. "_text")
			var_1_1("activityuitable/" .. pg.activity_template[pg.activity_task_permanent[iter_1_3].id].title_res_tag .. "_text_selected")
		end
	end

	for iter_1_4, iter_1_5 in ipairs(ActivityMainScene.GetOnShowEntranceData()) do
		var_1_1("activitybanner/" .. iter_1_5.banner)
	end

	table.insertto(var_1_0, ActivityMainScene.super.getResource(self))

	return var_1_0
end

function ActivityMainScene:getUIName()
	return "ActivityMainUI"
end

function ActivityMainScene:PlayBGM()
	return
end

function ActivityMainScene:onBackPressed()
	if self.locked then
		return
	end

	for iter_5_0, iter_5_1 in pairs(self.windowList) do
		if isActive(iter_5_1._tf) then
			self:HideWindow(iter_5_1.class)

			return
		end
	end

	if self.awardWindow and self.awardWindow:GetLoaded() and self.awardWindow:isShowing() then
		self.awardWindow:Hide()

		return
	end

	for iter_5_2, iter_5_3 in pairs(self.pageDic) do
		if iter_5_3.onBackPressed and iter_5_3:onBackPressed() then
			return
		end
	end

	self:emit(ActivityMainScene.ON_BACK_PRESSED)
end

local var_0_1

function ActivityMainScene:init()
	self.entranceList = UIItemList.New(self.entranceContent, self.entranceTpl)
	self.windowList = {}
	self.awardWindow = AwardWindow.New(self._tf, self.event)
	self.chargeTipWindow = ChargeTipWindow.New(self._tf, self.event)

	setActive(self.tab, false)
	setActive(self.lockAll, false)
	setActive(self.permanentFinshMask, false)
	setText(self.permanentFinshMask:Find("piece/Text"), i18n("activity_permanent_tips2"))
	onButton(self, self.permanentFinshMask:Find("piece/arrow/Image"), function()
		self:emit(ActivityMediator.FINISH_ACTIVITY_PERMANENT)
	end, SFX_PANEL)

	self.tabsList = UIItemList.New(self.tabs, self.tab)

	self.tabsList:make(function(arg_8_0, arg_8_1, arg_8_2)
		if arg_8_0 == UIItemList.EventUpdate then
			local var_8_0 = self.activities[arg_8_1 + 1]

			arg_8_2.name = self.activities[arg_8_1 + 1].id

			local var_8_1 = self.activities[arg_8_1 + 1]:getConfig("title_res_tag")

			if var_8_1 then
				local var_8_2 = GetSpriteFromAtlas("activityuitable/" .. var_8_1 .. "_text", "") or GetSpriteFromAtlas("activityuitable/activity_text", "")
				local var_8_3 = GetSpriteFromAtlas("activityuitable/" .. var_8_1 .. "_text_selected", "") or GetSpriteFromAtlas("activityuitable/activity_text_selected", "")

				setImageSprite(arg_8_2:Find("off/text"), var_8_2, true)
				setImageSprite(arg_8_2:Find("on/text"), var_8_3, true)
				setActive(arg_8_2:Find("red"), self.activities[arg_8_1 + 1]:readyToAchieve())
				onToggle(self, arg_8_2, function(arg_9_0)
					if arg_9_0 then
						self:selectActivity(var_8_0)
					end
				end, SFX_PANEL)
			end

			local var_8_4 = self.pageDic[self.activities[arg_8_1 + 1].id]

			onToggle(self, arg_8_2, function(arg_10_0)
				if var_8_4 then
					if arg_10_0 then
						self:selectActivity(var_8_0)
					end
				else
					self:loadActivityPanel(arg_10_0, var_8_0)
				end
			end, SFX_PANEL)
		end
	end)

	self.switchCount = 0
end

function ActivityMainScene:didEnter()
	self:bind(ActivityMainScene.LOCK_ACT_MAIN, function(arg_12_0, arg_12_1)
		self.locked = arg_12_1

		setActive(self.lockAll, arg_12_1)
	end)
	self:bind(ActivityMainScene.UPDATE_ACTIVITY, function(arg_13_0, arg_13_1)
		self:updateActivity(arg_13_1)
	end)
	self:bind(ActivityMainScene.GET_PAGE_BGM, function(arg_14_0, arg_14_1, arg_14_2)
		arg_14_2.bgm = self:getBGM(arg_14_1) or self:getBGM()
	end)
	self:bind(ActivityMainScene.FLUSH_TABS, function()
		self:flushTabs()
	end)
	getProxy(CommanderManualProxy):TaskProgressAdd(2020, 1)
	onButton(self, self.btnBack, function()
		self:emit(ActivityMainScene.ON_BACK)
	end, SOUND_BACK)
	self:updateEntrances()
	self:emit(ActivityMediator.SHOW_NEXT_ACTIVITY)

	if self.contextData.event then
		self:emit(self.contextData.event, self.contextData.data)

		self.contextData.event = nil
		self.contextData.data = nil
	end

	pg.CameraFixMgr.GetInstance():Adapt()
end

function ActivityMainScene:setPlayer(arg_17_1)
	self.shareData:SetPlayer(arg_17_1)
end

function ActivityMainScene:setFlagShip(arg_18_1)
	self.shareData:SetFlagShip(arg_18_1)
end

function ActivityMainScene:updateTaskLayers()
	if not self.activity then
		return
	end

	self:updateActivity(self.activity)
end

function ActivityMainScene:getActClass(arg_20_1)
	local var_20_0, var_20_1 = pcall(import, "view.activity.subPages." .. arg_20_1)

	if not var_20_0 then
		local var_20_2, var_20_3 = pcall(import, "view.activity.Remaster.re." .. arg_20_1)

		var_20_1 = var_20_3

		if not var_20_2 then
			error("模块未找到: " .. arg_20_1)
		end
	end

	return var_20_1
end

function ActivityMainScene:instanceActivityPage(arg_21_1)
	local var_21_0 = arg_21_1:getConfig("page_info")

	if var_21_0.class_name and not self.pageDic[arg_21_1.id] and not arg_21_1:isEnd() then
		local var_21_1 = self:getActClass(var_21_0.class_name).New(self.pageContainer, self.event, self.contextData)

		if var_21_1:UseSecondPage(arg_21_1) then
			var_21_1:SetUIName(var_21_0.ui_name2)
		else
			var_21_1:SetUIName(var_21_0.ui_name)
		end

		var_21_1:SetShareData(self.shareData)

		self.pageDic[arg_21_1.id] = var_21_1
	end
end

function ActivityMainScene:setActivities(arg_22_1)
	self.activities = underscore.filter(arg_22_1 or {}, function(arg_23_0)
		return arg_23_0:checkPageABExist()
	end)
	self.shareData = self.shareData or ActivityShareData.New()
	self.pageDic = self.pageDic or {}

	for iter_22_0, iter_22_1 in ipairs(arg_22_1) do
		self:instanceActivityPage(iter_22_1)
	end

	self.activity = nil

	table.sort(self.activities, CompareFuncs({
		function(arg_24_0)
			return -arg_24_0:getShowPriority()
		end,
		function(arg_25_0)
			return -arg_25_0.id
		end
	}))
	self:flushTabs()
end

function ActivityMainScene:getActivityIndex(arg_26_1)
	for iter_26_0, iter_26_1 in ipairs(self.activities) do
		if iter_26_1.id == arg_26_1 then
			return iter_26_0
		end
	end

	return nil
end

function ActivityMainScene:updateActivity(arg_27_1)
	if ActivityConst.PageIdLink[arg_27_1.id] then
		arg_27_1 = getProxy(ActivityProxy):getActivityById(ActivityConst.PageIdLink[arg_27_1.id])
	end

	if arg_27_1:isShow() then
		if arg_27_1:isCorePage(self.contextData.coreName or "") and not arg_27_1:isEnd() and arg_27_1:checkPageABExist() then
			self.activities[self:getActivityIndex(arg_27_1.id) or #self.activities + 1] = arg_27_1

			table.sort(self.activities, CompareFuncs({
				function(arg_28_0)
					return -arg_28_0:getShowPriority()
				end,
				function(arg_29_0)
					return -arg_29_0.id
				end
			}))

			if not self.pageDic[arg_27_1.id] then
				self:instanceActivityPage(arg_27_1)
			end

			self:flushTabs()

			if self.activity and self.activity.id == arg_27_1.id then
				self.activity = arg_27_1

				self.pageDic[arg_27_1.id]:ActionInvoke("Flush", arg_27_1)
				setActive(self.permanentFinshMask, pg.activity_task_permanent[arg_27_1.id] and arg_27_1:canPermanentFinish())
			end
		end
	end
end

function ActivityMainScene:removeActivity(arg_30_1)
	local var_30_0 = self:getActivityIndex(arg_30_1)

	if var_30_0 then
		table.remove(self.activities, var_30_0)
		self.pageDic[arg_30_1]:Destroy()

		self.pageDic[arg_30_1] = nil

		self:flushTabs()

		if self.activity and self.activity.id == arg_30_1 then
			self.activity = nil

			self:verifyTabs()
		end
	end
end

function ActivityMainScene.GetOnShowEntranceData()
	var_0_1 = var_0_1 or require("GameCfg.activity.EntranceData")

	assert(var_0_1, "Missing EntranceData.lua!")

	var_0_1 = var_0_1 or {}

	local var_31_0 = _.select(var_0_1, function(arg_32_0)
		return arg_32_0.isShow and arg_32_0.isShow()
	end)

	table.insertto(var_31_0, (ActivityMainScene.createEntranceData()))

	return var_31_0
end

function ActivityMainScene.createEntranceData()
	local var_33_0 = {}

	for iter_33_0, iter_33_1 in ipairs(pg.activity_entrance.all) do
		local var_33_1 = pg.activity_entrance[iter_33_1]

		if pg.TimeMgr.GetInstance():inTime(pg.activity_entrance[iter_33_1].time) then
			table.insert(var_33_0, {
				event = ActivityMediator.EVENT_GO_SCENE,
				data = {
					SCENE.ACTIVITY,
					{
						id = pg.activity_entrance[iter_33_1].act_ids[1]
					}
				},
				banner = pg.activity_entrance[iter_33_1].banner,
				isShow = function()
					for iter_34_0, iter_34_1 in ipairs(var_33_1.act_ids) do
						local var_34_0 = getProxy(ActivityProxy):getActivityById(iter_34_1)

						if var_34_0 and not var_34_0:isEnd() then
							return true
						end
					end

					return false
				end,
				isTip = function()
					for iter_35_0, iter_35_1 in ipairs(var_33_1.act_ids) do
						if Activity.IsActivityReady((getProxy(ActivityProxy):getActivityById(iter_35_1))) then
							return true
						end
					end

					return false
				end
			})
		end
	end

	return var_33_0
end

function ActivityMainScene:updateEntrances()
	local var_36_0 = ActivityMainScene.GetOnShowEntranceData()

	self.entranceList:make(function(arg_37_0, arg_37_1, arg_37_2)
		if arg_37_0 == UIItemList.EventUpdate then
			local var_37_0 = var_36_0[arg_37_1 + 1]
			local var_37_1 = "empty"

			removeOnButton(arg_37_2)

			local var_37_2 = false

			if var_36_0[arg_37_1 + 1] and table.getCount(var_36_0[arg_37_1 + 1]) ~= 0 and var_36_0[arg_37_1 + 1].isShow() then
				onButton(self, arg_37_2, function()
					self:emit(var_37_0.event, var_37_0.data[1], var_37_0.data[2])
				end, SFX_PANEL)

				var_37_1 = var_36_0[arg_37_1 + 1].banner

				if var_36_0[arg_37_1 + 1].isTip then
					var_37_2 = var_36_0[arg_37_1 + 1].isTip()
				end
			end

			setActive(arg_37_2:Find("tip"), var_37_2)
			LoadImageSpriteAsync("activitybanner/" .. var_37_1, arg_37_2)
		end
	end)
	self.entranceList:align((math.max(#var_36_0, 5)))
end

function ActivityMainScene:flushTabs()
	self.tabsList:align(#self.activities)
end

function ActivityMainScene:selectActivity(arg_40_1)
	if self.nextActivity == arg_40_1 or not self.nextActivity and self.activity and arg_40_1.id == self.activity.id then
		return
	end

	local var_40_0 = {}

	if self.activity and not self.nextActivity then
		self.switchCount = self.switchCount + 1

		table.insert(var_40_0, function(arg_41_0)
			self.pageDic[self.activity.id]:ActionInvoke("SwitchOut", function()
				self.switchCount = self.switchCount - 1

				arg_41_0()
			end)
		end)
	end

	if not self.activity or self.activity.id ~= arg_40_1.id then
		local var_40_1 = self.pageDic[arg_40_1.id]

		assert(self.pageDic[arg_40_1.id], "找不到id:" .. arg_40_1.id .. "的活动页，请检查")

		self.switchCount = self.switchCount + 1

		table.insert(var_40_0, function(arg_43_0)
			var_40_1:Load()
			var_40_1:ActionInvoke("ShowOrHide", false)
			var_40_1:CallbackInvoke(function()
				self.switchCount = self.switchCount - 1

				arg_43_0()
			end)
		end)
	end

	self.nextActivity = arg_40_1

	parallelAsync(var_40_0, function()
		if self.switchCount > 0 then
			return
		end

		if self.activity then
			self.pageDic[self.activity.id]:ActionInvoke("ShowOrHide", false)
		end

		self.activity = self.nextActivity
		self.contextData.id = self.nextActivity.id
		self.nextActivity = nil

		self.pageDic[self.activity.id]:ActionInvoke("ShowOrHide", true)
		self.pageDic[self.activity.id]:ActionInvoke("Flush", self.activity)
		setActive(self.permanentFinshMask, pg.activity_task_permanent[arg_40_1.id] and arg_40_1:canPermanentFinish())
	end)
end

function ActivityMainScene:checkAutoHideActivity()
	if self.activity and not self.activity:isShow() then
		self:removeActivity(self.activity.id)
	end
end

function ActivityMainScene:verifyTabs(arg_47_1)
	triggerToggle(self.tabs:GetChild((self:getActivityIndex(arg_47_1) or 1) - 1), true)
end

function ActivityMainScene:loadActivityPanel(arg_48_1, arg_48_2)
	local var_48_0 = arg_48_2:getConfig("type")

	if nil and arg_48_1 then
		self:emit(ActivityMediator.OPEN_LAYER, nil)
	elseif nil and not arg_48_1 then
		self:emit(ActivityMediator.CLOSE_LAYER, (nil).mediator)
	else
		originalPrint("------活动id为" .. arg_48_2.id .. "类型为" .. arg_48_2:getConfig("type") .. "的页面不存在")
	end
end

function ActivityMainScene:getBonusWindow(arg_49_1, arg_49_2)
	local var_49_0 = self._tf:Find(arg_49_1)

	if not var_49_0 then
		PoolMgr.GetInstance():GetUI("ActivitybonusWindow", true, function(arg_50_0)
			SetParent(arg_50_0, self._tf, false)

			arg_50_0.name = arg_49_1

			arg_49_2(arg_50_0)
		end)
	else
		arg_49_2(var_49_0)
	end
end

function ActivityMainScene:ShowWindow(arg_51_1, arg_51_2)
	local var_51_0 = arg_51_1.__cname

	if not self.windowList[arg_51_1.__cname] then
		self:getBonusWindow(arg_51_1.__cname, function(arg_52_0)
			self.windowList[var_51_0] = arg_51_1.New(tf(arg_52_0), self)

			self.windowList[var_51_0]:Show(arg_51_2)
		end)
	else
		self.windowList[arg_51_1.__cname]:Show(arg_51_2)
	end
end

function ActivityMainScene:HideWindow(arg_53_1)
	if not self.windowList[arg_53_1.__cname] then
		return
	end

	self.windowList[arg_53_1.__cname]:Hide()
end

function ActivityMainScene:ShowAwardWindow(arg_54_1, arg_54_2, arg_54_3, arg_54_4)
	self.awardWindow:ExecuteAction("Flush", arg_54_1, arg_54_2, arg_54_3, arg_54_4)
end

function ActivityMainScene:OnChargeSuccess(arg_55_1)
	self.chargeTipWindow:ExecuteAction("Show", arg_55_1)
end

function ActivityMainScene:willExit()
	self.switchCount = nil
	self.shareData = nil

	for iter_56_0, iter_56_1 in pairs(self.pageDic) do
		iter_56_1:Destroy()
	end

	for iter_56_2, iter_56_3 in pairs(self.windowList) do
		iter_56_3:Dispose()
	end

	if self.awardWindow then
		self.awardWindow:Destroy()

		self.awardWindow = nil
	end

	if self.chargeTipWindow then
		self.chargeTipWindow:Destroy()

		self.chargeTipWindow = nil
	end
end

return ActivityMainScene
