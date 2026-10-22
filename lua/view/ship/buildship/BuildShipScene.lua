local BuildShipScene = class("BuildShipScene", import("...base.BaseUI"))

BuildShipScene.PAGE_BUILD = 1
BuildShipScene.PAGE_QUEUE = 2
BuildShipScene.PAGE_SUPPORT = 3
BuildShipScene.PAGE_UNSEAM = 4
BuildShipScene.PAGE_PRAY = 5
BuildShipScene.PAGE_NEWSERVER = 6
BuildShipScene.PROJECTS = {
	SPECIAL = "special",
	ACTIVITY = "new",
	HEAVY = "heavy",
	LIGHT = "light"
}

function BuildShipScene:getResource()
	return table.insertto({
		"ui/al_bg01"
	}, BuildShipScene.super.getResource(self))
end

function BuildShipScene:getUIName()
	return "BuildShipUI"
end

function BuildShipScene:ResUISettings()
	return true
end

function BuildShipScene:setPools(arg_4_1)
	self.pools = {}

	for iter_4_0, iter_4_1 in ipairs(arg_4_1) do
		table.insert(self.pools, iter_4_1)
	end
end

function BuildShipScene:setPlayer(arg_5_1)
	self.contextData.player = arg_5_1
end

function BuildShipScene:setUseItem(arg_6_1)
	self.contextData.itemVO = arg_6_1 or Item.New({
		count = 0,
		id = pg.ship_data_create_material[1].use_item
	})

	if self.poolsPage and self.poolsPage:GetLoaded() then
		self.poolsPage:UpdateItem(self.contextData.itemVO.count)
	end
end

function BuildShipScene:setStartCount(arg_7_1)
	self.contextData.startCount = arg_7_1
end

function BuildShipScene:setFlagShip(arg_8_1)
	self.contextData.falgShip = arg_8_1
end

function BuildShipScene:RefreshActivityBuildPool(arg_9_1)
	self.poolsPage:RefreshActivityBuildPool(arg_9_1)
end

function BuildShipScene:RefreshFreeBuildActivity()
	self.poolsPage:RefreshFreeBuildActivity()
	self.poolsPage:UpdateTicket()
end

function BuildShipScene:RefreshRegularExchangeCount()
	self.poolsPage:RefreshRegularExchangeCount()
end

function BuildShipScene:init()
	Input.multiTouchEnabled = false
	self.blurPanel = self._tf:Find("blur_panel")
	self.topPanel = self.blurPanel:Find("adapt/top")
	self.backBtn = self.topPanel:Find("back_btn")
	self.toggles = {
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/build_btn"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/queue_btn"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/support_btn"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/unseam_btn"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/pray_btn"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/other_build_btn")
	}
	self.tip = self.toggles[2]:Find("tip")
	self.contextData.msgbox = BuildShipMsgBox.New(self._tf, self.event)
	self.contextData.helpWindow = BuildShipHelpWindow.New(self._tf, self.event)
	self.poolsPage = BuildShipPoolsPage.New(self._tf, self.event, self.contextData)
	self.supportShipPoolPage = SupportShipPoolPage.New(self._tf, self.event, self.contextData)
end

function BuildShipScene:didEnter()
	self:OverlayPanel(self.blurPanel)
	onButton(self, self.backBtn, function()
		self:emit(BuildShipScene.ON_BACK)
	end, SFX_CANCEL)

	local var_13_0 = self.blurPanel:Find("adapt/left_length/stamp")

	setActive(var_13_0, getProxy(TaskProxy):mingshiTouchFlagEnabled())
	onButton(self, var_13_0, function()
		getProxy(TaskProxy):dealMingshiTouchFlag(11)
	end, SFX_CONFIRM)

	for iter_13_0, iter_13_1 in ipairs(self.toggles) do
		onToggle(self, iter_13_1, function(arg_16_0)
			self:switchPage(iter_13_0, arg_16_0)
		end, SFX_PANEL)
	end

	local var_13_1 = getProxy(ActivityProxy)
	local var_13_2 = var_13_1:getActivityById(ActivityConst.ACTIVITY_PRAY_POOL)

	if var_13_2 and not var_13_2:isEnd() then
		setActive(self.toggles[BuildShipScene.PAGE_PRAY], true)
	else
		setActive(self.toggles[BuildShipScene.PAGE_PRAY], false)
	end

	if underscore.any(self.pools, function(arg_17_0)
		return checkExist(var_13_1:getBuildPoolActivity(arg_17_0), {
			"getConfig",
			{
				"type"
			}
		}) == ActivityConst.ACTIVITY_TYPE_NEWSERVER_BUILD
	end) then
		setActive(self.toggles[BuildShipScene.PAGE_NEWSERVER], true)
	else
		setActive(self.toggles[BuildShipScene.PAGE_NEWSERVER], false)
	end

	local var_13_3 = self.contextData.page

	if not self.contextData.page then
		if pg.SeriesGuideMgr.GetInstance():isRunning() then
			var_13_3 = BuildShipScene.PAGE_BUILD or BuildShipScene.PAGE_NEWSERVER

			if not isActive(self.toggles[var_13_3]) then
				var_13_3 = BuildShipScene.PAGE_BUILD
			end
		end
	end

	triggerToggle(self.toggles[var_13_3], true)
	PoolMgr.GetInstance():GetUI("al_bg01", true, function(arg_18_0)
		arg_18_0:SetActive(true)
		setParent(arg_18_0, self._tf)
		arg_18_0.transform:SetAsFirstSibling()
	end)
	TagTipHelper.SetFreeBuildMark()

	self.bulinTip = AprilFoolBulinSubView.ShowAprilFoolBulin(self, self.blurPanel)
end

function BuildShipScene:checkPage()
	if self.contextData.msgbox and self.contextData.msgbox:GetLoaded() and self.contextData.msgbox:isShowing() then
		self.contextData.msgbox:Hide()
	end

	if self.contextData.helpWindow and self.contextData.helpWindow:GetLoaded() and self.contextData.helpWindow:isShowing() then
		self.contextData.helpWindow:Hide()
	end

	local var_19_0 = getProxy(ActivityProxy)

	if underscore.any(self.pools, function(arg_20_0)
		return checkExist(var_19_0:getBuildPoolActivity(arg_20_0), {
			"getConfig",
			{
				"type"
			}
		}) == ActivityConst.ACTIVITY_TYPE_NEWSERVER_BUILD
	end) then
		setActive(self.toggles[BuildShipScene.PAGE_NEWSERVER], true)
	else
		setActive(self.toggles[BuildShipScene.PAGE_NEWSERVER], false)
	end

	if not isActive(self.toggles[BuildShipScene.PAGE_NEWSERVER]) and self.contextData.page == BuildShipScene.PAGE_NEWSERVER then
		triggerToggle(self.toggles[BuildShipScene.PAGE_BUILD], true)
	else
		self.poolsPage:Flush(self.pools)
	end
end

function BuildShipScene:switchPage(arg_21_1, arg_21_2)
	if arg_21_2 then
		if arg_21_1 == BuildShipScene.PAGE_UNSEAM then
			self.contextData.page = BuildShipScene.PAGE_BUILD or arg_21_1
		end
	end

	if arg_21_1 == BuildShipScene.PAGE_UNSEAM then
		if arg_21_2 then
			self:emit(BuildShipMediator.OPEN_DESTROY)
		end
	elseif arg_21_1 == BuildShipScene.PAGE_QUEUE then
		if arg_21_2 then
			self:emit(BuildShipMediator.OPEN_PROJECT_LIST)
		else
			self:emit(BuildShipMediator.REMOVE_PROJECT_LIST)
		end
	elseif arg_21_1 == BuildShipScene.PAGE_SUPPORT then
		self.supportShipPoolPage:ExecuteAction("ShowOrHide", arg_21_2)

		if arg_21_2 then
			self.supportShipPoolPage:ExecuteAction("Flush")
		end
	elseif arg_21_1 == BuildShipScene.PAGE_BUILD then
		self.poolsPage:ExecuteAction("ShowOrHide", arg_21_2)

		if arg_21_2 then
			self.poolsPage:ExecuteAction("Flush", self.pools, false)
		end
	elseif arg_21_1 == BuildShipScene.PAGE_NEWSERVER then
		self.poolsPage:ExecuteAction("ShowOrHide", arg_21_2)

		if arg_21_2 then
			self.poolsPage:ExecuteAction("Flush", self.pools, true)
		end
	elseif arg_21_1 == BuildShipScene.PAGE_PRAY then
		if arg_21_2 then
			self:emit(BuildShipMediator.OPEN_PRAY_PAGE)
		else
			self:emit(BuildShipMediator.CLOSE_PRAY_PAGE)
		end
	end
end

function BuildShipScene:updateQueueTip(arg_22_1)
	setActive(self.tip, arg_22_1 > 0)
end

function BuildShipScene:onBackPressed()
	if self.contextData.helpWindow:GetLoaded() and self.contextData.helpWindow:isShowing() then
		self.contextData.helpWindow:Hide()

		return
	end

	if self.contextData.msgbox:GetLoaded() and self.contextData.msgbox:isShowing() then
		self.contextData.msgbox:Hide()

		return
	end

	self:emit(BuildShipScene.ON_BACK_PRESSED)
end

function BuildShipScene:willExit()
	Input.multiTouchEnabled = true

	self.contextData.msgbox:Destroy()
	self.contextData.helpWindow:Destroy()
	self.poolsPage:Destroy()
	self.supportShipPoolPage:Destroy()
	self:UnOverlayPanel(self.blurPanel, self._tf)
end

return BuildShipScene
