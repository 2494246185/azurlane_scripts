local CoreActivityMainScene = class("CoreActivityMainScene", import("view.activity.ActivityMainScene"))

function CoreActivityMainScene:getUIName()
	return nil
end

function CoreActivityMainScene:getResource(arg_2_1)
	local var_2_0 = {}

	if self:IsImageTgName() then
		for iter_2_0, iter_2_1 in ipairs((getProxy(ActivityProxy):getCorePanelActivities(self.contextData.coreName))) do
			local var_2_1 = string.lower(iter_2_1:getConfig("title_res_tag"))

			table.insert(var_2_0, "coreactivityuitable/" .. var_2_1 .. "_text")
			table.insert(var_2_0, "coreactivityuitable/" .. var_2_1 .. "_text_selected")
		end
	end

	table.insertto(var_2_0, CoreActivityMainScene.super.getResource(self, arg_2_1))

	return var_2_0
end

CoreActivityMainScene.optionsPath = {
	"adapt/top/btn_home"
}

function CoreActivityMainScene:PlayBGM()
	return
end

function CoreActivityMainScene:init()
	self.btnBack = self._tf:Find("adapt/top/btn_back")
	self.btnSkin = self._tf:Find("adapt/btn_skin")
	self.pageContainer = self._tf:Find("page_list")
	self.tabs = self._tf:Find("adapt/tabs")
	self.windowList = {}
	self.awardWindow = AwardWindow.New(self._tf, self.event)
	self.chargeTipWindow = ChargeTipWindow.New(self._tf, self.event)
	self.tabsList = UIItemList.New(self.tabs, self.tabs:GetChild(0))

	self.tabsList:make(function(arg_5_0, arg_5_1, arg_5_2)
		if arg_5_0 == UIItemList.EventUpdate then
			local var_5_0 = underscore.detect(self.activities, function(arg_6_0)
				return tostring(arg_6_0:getConfig("is_show")) == arg_5_2.name
			end)

			if not var_5_0 or var_5_0:isEnd() then
				setActive(arg_5_2, false)
			elseif not self.pageDic[var_5_0.id] then
				warning(string.format("without page in act:", var_5_0.id))
			else
				local var_5_1 = arg_5_2:Find("tip")
				local var_5_2 = self.pageDic[var_5_0.id]:IsShowReminder()

				if var_5_2 == nil then
					setActive(var_5_1, var_5_0:readyToAchieve())
				else
					setActive(var_5_1, var_5_2)
				end

				onToggle(self, arg_5_2, function(arg_7_0)
					if arg_7_0 then
						self:selectActivity(var_5_0)
					end
				end, SFX_PANEL)
			end
		end
	end)

	self.switchCount = 0
end

function CoreActivityMainScene:didEnter()
	self:bind(CoreActivityMainScene.UPDATE_ACTIVITY, function(arg_9_0, arg_9_1)
		self:updateActivity(arg_9_1)
	end)
	self:bind(CoreActivityMainScene.GET_PAGE_BGM, function(arg_10_0, arg_10_1, arg_10_2)
		arg_10_2.bgm = self:getBGM(arg_10_1) or self:getBGM()
	end)
	self:bind(CoreActivityMainScene.FLUSH_TABS, function()
		self:flushTabs()
	end)
	onButton(self, self.btnBack, function()
		self:emit(CoreActivityMainScene.ON_BACK)
	end, SOUND_BACK)

	if self.btnSkin then
		onButton(self, self.btnSkin, function()
			self:emit(ActivityMediator.GO_CHANGE_SHOP)
		end, SFX_PANEL)
	end

	self:emit(ActivityMediator.SHOW_NEXT_ACTIVITY, self.contextData.coreName)
end

function CoreActivityMainScene:setActivities(arg_14_1)
	self.activities = underscore.filter(arg_14_1 or {}, function(arg_15_0)
		return not arg_15_0:isEnd()
	end)
	self.shareData = self.shareData or ActivityShareData.New()
	self.pageDic = self.pageDic or {}

	for iter_14_0, iter_14_1 in ipairs(self.activities) do
		self:instanceActivityPage(iter_14_1)
	end

	table.sort(self.activities, CompareFuncs({
		function(arg_16_0)
			return arg_16_0:getShowPriority()
		end,
		function(arg_17_0)
			return -arg_17_0.id
		end
	}))
	self:flushTabs()
end

function CoreActivityMainScene:updateActivity(arg_18_1)
	if ActivityConst.PageIdLink[arg_18_1.id] then
		arg_18_1 = getProxy(ActivityProxy):getActivityById(ActivityConst.PageIdLink[arg_18_1.id])
	end

	if arg_18_1:isShow() and arg_18_1:isCorePage(self.contextData.coreName) and not arg_18_1:isEnd() then
		self.activities[self:getActivityIndex(arg_18_1.id) or #self.activities + 1] = arg_18_1

		table.sort(self.activities, CompareFuncs({
			function(arg_19_0)
				return arg_19_0:getShowPriority()
			end,
			function(arg_20_0)
				return -arg_20_0.id
			end
		}))

		if not self.pageDic[arg_18_1.id] then
			self:instanceActivityPage(arg_18_1)
		end

		self:flushTabs()

		if self.activity and self.activity.id == arg_18_1.id then
			self.activity = arg_18_1

			self.pageDic[arg_18_1.id]:ActionInvoke("Flush", arg_18_1)
			self:verifyTabs(self.activity.id)
		end
	end
end

function CoreActivityMainScene:instanceActivityPage(arg_21_1)
	CoreActivityMainScene.super.instanceActivityPage(self, arg_21_1)

	for iter_21_0, iter_21_1 in pairs(self.pageDic) do
		iter_21_1:SetCoreActivityUI(self)
	end
end

function CoreActivityMainScene:updateEntrances()
	return
end

function CoreActivityMainScene:flushTabs()
	self.tabsList:align(self.tabs.childCount)
end

function CoreActivityMainScene:IsImageTgName()
	return false
end

function CoreActivityMainScene:OnToggleName(arg_25_1, arg_25_2)
	local var_25_0 = arg_25_2:getConfig("title_res_tag")
	local var_25_1 = "coreactivityuitable/" .. var_25_0 .. "_text"
	local var_25_2 = "coreactivityuitable/" .. var_25_0 .. "_text_selected"

	setText(arg_25_1:Find("on/name"), i18n(var_25_0))
	setText(arg_25_1:Find("off/name"), i18n(var_25_0))

	local var_25_3 = self:IsImageTgName()
	local var_25_4 = checkABExist(var_25_1)
	local var_25_5 = checkABExist(var_25_2)

	setActive(arg_25_1:Find("off/imgName"), var_25_3 and var_25_4)
	setActive(arg_25_1:Find("off/name"), not var_25_3 or not var_25_4)
	setActive(arg_25_1:Find("on/imgName"), var_25_3 and var_25_5)
	setActive(arg_25_1:Find("on/name"), not var_25_3 or not var_25_5)

	if self:IsImageTgName() then
		local var_25_6 = string.lower(var_25_0)

		if var_25_4 then
			setImageSprite(arg_25_1:Find("off/imgName"), GetSpriteFromAtlas(var_25_1, ""), true)
		end

		if var_25_5 then
			setImageSprite(arg_25_1:Find("on/imgName"), GetSpriteFromAtlas(var_25_2, ""), true)
		end
	end
end

function CoreActivityMainScene:selectActivity(arg_26_1)
	if self.nextActivity == arg_26_1 or not self.nextActivity and self.activity and arg_26_1.id == self.activity.id then
		return
	end

	local var_26_0 = {}

	if self.activity and not self.nextActivity then
		self.switchCount = self.switchCount + 1

		table.insert(var_26_0, function(arg_27_0)
			self.pageDic[self.activity.id]:ActionInvoke("SwitchOut", function()
				self.switchCount = self.switchCount - 1

				arg_27_0()
			end)
		end)
	end

	if not self.activity or self.activity.id ~= arg_26_1.id then
		local var_26_1 = self.pageDic[arg_26_1.id]

		assert(self.pageDic[arg_26_1.id], "找不到id:" .. arg_26_1.id .. "的活动页，请检查")

		self.switchCount = self.switchCount + 1

		table.insert(var_26_0, function(arg_29_0)
			var_26_1:Load()
			var_26_1:ActionInvoke("ShowOrHide", false)
			var_26_1:CallbackInvoke(function()
				self.switchCount = self.switchCount - 1

				arg_29_0()
			end)
		end)
	end

	self.nextActivity = arg_26_1

	parallelAsync(var_26_0, function()
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
		self:OnPageSwitchDone(self.pageDic[self.activity.id], (table.indexof(self.activities, self.activity)))
	end)
end

function CoreActivityMainScene:OnPageSwitchDone(arg_32_1, arg_32_2)
	return
end

function CoreActivityMainScene:verifyTabs(arg_33_1)
	if self.activities[self:getActivityIndex(arg_33_1) or self:getActivityIndex(self:GetActiveActivity()) or 1] == nil then
		return
	end

	local var_33_0 = self.tabs:Find(tostring((self.activities[self:getActivityIndex(arg_33_1) or self:getActivityIndex(self:GetActiveActivity()) or 1]:getConfig("is_show"))))

	if var_33_0 then
		triggerToggle(var_33_0, true)
	end
end

function CoreActivityMainScene:GetActiveActivity()
	for iter_34_0, iter_34_1 in ipairs(self.activities) do
		if not iter_34_1:isEnd() then
			return iter_34_1.id
		end
	end
end

function CoreActivityMainScene:GetActivityIdByPageClass(arg_35_1)
	for iter_35_0, iter_35_1 in ipairs(self.activities or {}) do
		local var_35_1 = iter_35_1:getConfig("page_info")

		if var_35_1 and var_35_1.class_name == arg_35_1 then
			return iter_35_1.id
		end
	end

	return nil
end

function CoreActivityMainScene:onBackPressed()
	if self.pageDic[self.activity.id]:IsShowingPopWindow() then
		self.pageDic[self.activity.id]:ClosePopWindow()

		return
	end

	CoreActivityMainScene.super.onBackPressed(self)
end

function CoreActivityMainScene:getActClass(arg_37_1)
	return _G[arg_37_1]
end

return CoreActivityMainScene
