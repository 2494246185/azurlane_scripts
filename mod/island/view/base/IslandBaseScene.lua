local IslandBaseScene = class("IslandBaseScene", import("view.base.BaseUI"))

IslandBaseScene.ON_SCENE_LOADED = "IslandBaseScene:ON_SCENE_LOADED"
IslandBaseScene.LINK_CORE_EVENT = "IslandBaseScene:LINK_CORE_EVENT"

function IslandBaseScene:Ctor()
	IslandBaseScene.super.Ctor(self)

	self.sceneMgr = IslandSceneMgr.New(self)
	self.__callbacks__ = {}
	self.showBalance = 1
	self.cacheAbList = {
		"ui/islandui_atlas",
		"ui/islandcommonui_atlas",
		"island/IslandInteractionBtns"
	}
end

function IslandBaseScene:getDefaultUI()
	return self._container
end

function IslandBaseScene:DontGC()
	return true
end

function IslandBaseScene:forceGC()
	return false
end

function IslandBaseScene:GCWhenAwake()
	return false
end

function IslandBaseScene:PlayBGM()
	pg.BgmMgr.GetInstance():StopPlay()
end

function IslandBaseScene:preload(arg_7_1)
	local var_7_0 = {}

	table.insert(var_7_0, function(arg_8_0)
		self:LoadUIContainer(arg_8_0)
	end)
	table.insert(var_7_0, function(arg_9_0)
		self.poolMgr = IslandPoolMgr.New(self.poolContainer)

		self.poolMgr:Init(arg_9_0)
	end)

	for iter_7_0, iter_7_1 in ipairs(self.cacheAbList) do
		table.insert(var_7_0, function(arg_10_0)
			AssetBundleHelper.StoreAssetBundle(iter_7_1, true, false, function(arg_11_0)
				arg_10_0()
			end)
		end)
	end

	seriesAsync(var_7_0, arg_7_1)
end

function IslandBaseScene:getResource()
	local var_12_0 = IslandBaseScene.super.getResource(self)

	for iter_12_0, iter_12_1 in ipairs(self.cacheAbList or {}) do
		if not table.contains(var_12_0, iter_12_1) then
			table.insert(var_12_0, iter_12_1)
		end
	end

	for iter_12_2, iter_12_3 in ipairs({
		"UI/UIIsland"
	}) do
		if noEmptyStr(iter_12_3) and not table.contains(var_12_0, iter_12_3) then
			table.insert(var_12_0, iter_12_3)
		end
	end

	return var_12_0
end

function IslandBaseScene:LoadUIContainer(arg_13_1)
	ResourceMgr.Inst:getAssetAsync("UI/UIIsland", "", typeof(GameObject), UnityEngine.Events.UnityAction_UnityEngine_Object(function(arg_14_0)
		IslandHelper.InstantiateAsyncGameObject(arg_14_0, function(arg_15_0)
			self._container = arg_15_0.transform
			self.canvasGroup = GetOrAddComponent(self._container, typeof(CanvasGroup))
			self.uiLayer1 = self._container:Find("layer1")
			self.uiLayer2 = self._container:Find("layer2")
			self.uiContainer = self._container:Find("layer1/ui")
			self.opContainer = self._container:Find("layer1/op")
			self.pageContainer = self._container:Find("layer1/page")
			self.poolContainer = self._container:Find("_pool_")
			self._container.name = "UIIsland"

			setParent(self._container, pg.UIMgr.GetInstance().UICanvas)
			arg_13_1()
		end)
	end), true, true)
end

function IslandBaseScene:SetUIParent(arg_16_1)
	arg_16_1.transform:SetParent(self.uiContainer, false)
end

function IslandBaseScene:emit(arg_17_1, ...)
	if arg_17_1 == BaseUI.ON_HOME or arg_17_1 == IslandMediator.CHANGE_SCENE then
		if ISLAND_PLAYER_TESTING then
			pg.TipsMgr.GetInstance():ShowTips(i18n("island_home_btn_cant_use"))

			return
		end

		self:ExitProcess(arg_17_1, nil, ...)
	else
		IslandBaseScene.super.emit(self, arg_17_1, ...)
	end
end

function IslandBaseScene:emitCoreController(arg_18_1, ...)
	self:emit(IslandBaseScene.LINK_CORE_EVENT, arg_18_1, ...)
end

function IslandBaseScene:emitCore(arg_19_1, ...)
	self:emit(IslandBaseScene.LINK_CORE_EVENT, IslandProxy.LINK_CORE, arg_19_1, ...)
end

function IslandBaseScene:ExitProcess(arg_20_1, arg_20_2, ...)
	local var_20_0 = packEx(...)
	local var_20_1 = self:GetIsland()

	seriesAsync({
		function(arg_21_0)
			self:emit(IslandBaseMediator.RECORD_PLAYER_POS)
			pg.m02:sendNotification(GAME.ISLAND_EXIT, {
				id = var_20_1.id,
				callback = arg_21_0
			})
		end
	}, function()
		IslandBaseScene.super.emit(self, arg_20_1, unpackEx(var_20_0))

		if arg_20_2 then
			arg_20_2()
		end
	end)
end

function IslandBaseScene:GetIsland()
	assert(false, "overwrite me !!!!")
end

function IslandBaseScene:onUILoaded(arg_24_1)
	IslandBaseScene.super.onUILoaded(self, arg_24_1)

	self.subViews = {
		IslandMsgBox.New(pg.UIMgr.GetInstance().OverlayMain, self.event),
		IslandToast.New(pg.UIMgr.GetInstance().OverlayToast, self.event),
		IslandStoryMgr.New(pg.UIMgr.GetInstance().OverlayToast, self.event),
		IslandAwardDisplayPage.New(pg.UIMgr.GetInstance().OverlayToast, self.event),
		IslandQueueUpMsgBox.New(pg.UIMgr.GetInstance().OverlayToast, self.event),
		IslandTimelineMgr.New(self:GetPoolMgr(), pg.UIMgr.GetInstance().OverlayToast, self.event),
		Island3dTaskAcceptPage.New(pg.UIMgr.GetInstance().OverlayToast, self.event),
		IslandSystemUnlockPage.New(pg.UIMgr.GetInstance().OverlayToast, self.event)
	}
	self.monitors = {
		IslandPlayerDataMonitor.New(self:GetIsland()),
		IslandSyncDataMonitor.New(self:GetIsland()),
		IslandCheaterTavernMonitor.New(self:GetIsland())
	}
	self.poppingQueue = IslandPoppingQueue.New(self)

	self:AddCommonListeners()
	self:AddListeners()

	for iter_24_0, iter_24_1 in pairs(self.subViews) do
		iter_24_1:RegisterView(self)
	end
end

function IslandBaseScene:AddCommonListeners()
	self:AddListener(ISLAND_EX_EVT.EMIT, self.OnEmit)
	self:AddListener(ISLAND_EX_EVT.INIT_FINISH, self.OnSceneLoaded)
	self:AddListener(ISLAND_EX_EVT.SHOW_MSG, self.OnShowMsgBox)
	self:AddListener(ISLAND_EX_EVT.OPEN_PAGE, self.OnOpenPage)
	self:AddListener(ISLAND_EX_EVT.PLAY_TIMELINE, self.OnPlayTimeline)
	self:AddListener(IslandBaseScene.LINK_CORE_EVENT, self.OnLinkCoreEvent)
	self:AddListener(ISLAND_EX_EVT.OPEN_ANIMATION_OP, self.OnOpenAnimatonOpPage)
	self:AddListener(ISLAND_EX_EVT.CLOSE_ANIMATION_OP, self.OnCloseAnimatonOpPage)
end

function IslandBaseScene:GetSubView(arg_26_1)
	for iter_26_0, iter_26_1 in ipairs(self.subViews) do
		if isa(iter_26_1, arg_26_1) then
			return iter_26_1
		end
	end

	return nil
end

function IslandBaseScene:GetPoolMgr()
	return self.poolMgr
end

function IslandBaseScene:OnOpenAnimatonOpPage()
	return
end

function IslandBaseScene:OnCloseAnimatonOpPage()
	return
end

function IslandBaseScene:OnLinkCoreEvent(arg_30_1, ...)
	self:GetIsland():DispatchEvent(arg_30_1, ...)
end

function IslandBaseScene:OnSetUpCore(arg_31_1, arg_31_2)
	return
end

function IslandBaseScene:OnOpenPage(arg_32_1, ...)
	self:OpenPage(arg_32_1, ...)
end

function IslandBaseScene:OnShowMsgBox(arg_33_1)
	self:ShowMsgbox(arg_33_1)
end

function IslandBaseScene:OnPlayTimeline(arg_34_1, arg_34_2, arg_34_3)
	self:PlayTimeline(arg_34_1, arg_34_2, arg_34_3)
end

function IslandBaseScene:OnSceneLoaded()
	self:emit(IslandBaseScene.ON_SCENE_LOADED)
end

function IslandBaseScene:OnEmit(arg_36_1, ...)
	self:emit(arg_36_1, ...)
end

function IslandBaseScene:StartCore()
	self:emit(IslandBaseMediator.SET_UP)
end

function IslandBaseScene:setVisible(arg_38_1)
	local var_38_0 = GetOrAddComponent(self._tf, typeof(CanvasGroup))

	var_38_0.alpha = arg_38_1 and 1 or 0
	var_38_0.blocksRaycasts = arg_38_1

	if arg_38_1 then
		self:OnVisible()
	else
		self:OnDisVisible()
	end
end

function IslandBaseScene:TryVisible()
	self.showBalance = self.showBalance + 1

	if self.showBalance == 1 then
		self:setVisible(true)
	end
end

function IslandBaseScene:TryDisVisible()
	self.showBalance = self.showBalance - 1

	if self.showBalance == 0 then
		self:setVisible(false)
	end
end

function IslandBaseScene:OpenPage(arg_41_1, ...)
	IslandGuideChecker.CheckOnOpenPage(arg_41_1.__cname)

	return self.sceneMgr:OpenPage(self, arg_41_1, ...)
end

function IslandBaseScene:ClosePage(arg_42_1)
	self.sceneMgr:ClosePage(arg_42_1)
end

function IslandBaseScene:GetPage(arg_43_1)
	return self.sceneMgr:GetPage(arg_43_1)
end

function IslandBaseScene:GetSubPage(arg_44_1)
	return self.sceneMgr:GetSubPage(arg_44_1)
end

function IslandBaseScene:ShowToast(arg_45_1)
	self:GetSubView(IslandToast):ExecuteAction("Show", arg_45_1)
end

function IslandBaseScene:DisplayAward(arg_46_1)
	self:GetSubView(IslandAwardDisplayPage):ExecuteAction("Show", arg_46_1)
end

function IslandBaseScene:PlayTimeline(arg_47_1, arg_47_2, arg_47_3)
	self:GetSubView(IslandTimelineMgr):ExecuteAction("Show", arg_47_1, arg_47_2, arg_47_3)
end

function IslandBaseScene:PlayGetShipTimeline(arg_48_1, arg_48_2)
	self:PlayTimeline(2, {
		arg_48_1
	}, arg_48_2)
end

function IslandBaseScene:PlayStory(arg_49_1)
	self.poppingQueue:Enqueue(IslandPoppingQueue.STORY, arg_49_1)
end

function IslandBaseScene:ShowMsgbox(arg_50_1)
	self.poppingQueue:Enqueue(IslandPoppingQueue.MSGBOX, arg_50_1)
end

function IslandBaseScene:PlayPerformance(arg_51_1)
	self.poppingQueue:Enqueue(IslandPoppingQueue.PERFORMANCE, arg_51_1)
end

function IslandBaseScene:DisplaySystemUnlock(arg_52_1, arg_52_2)
	if not arg_52_1 or #arg_52_1 <= 0 then
		arg_52_2()

		return
	end

	local var_52_0 = _.select(arg_52_1, function(arg_53_0)
		return pg.island_ability_template[arg_53_0.id].show_pop == 1
	end)

	if #var_52_0 <= 0 then
		arg_52_2()

		return
	end

	local var_52_1 = {}

	for iter_52_0, iter_52_1 in ipairs(var_52_0) do
		table.insert(var_52_1, function(arg_54_0)
			self:GetSubView(IslandSystemUnlockPage):ExecuteAction("Show", iter_52_1.id, function()
				onNextTick(arg_54_0)
			end)
		end)
	end

	seriesAsync(var_52_1, arg_52_2)
end

function IslandBaseScene:HandleAwardDisplay(arg_56_1, arg_56_2, arg_56_3)
	self.poppingQueue:Enqueue(IslandPoppingQueue.DISPLAY_AWARD, {
		dropData = arg_56_1,
		callback = arg_56_2,
		displayType = arg_56_3
	})
end

function IslandBaseScene:ShowTaskAcceptPage(arg_57_1)
	self.poppingQueue:Enqueue(IslandPoppingQueue.TASK_ACCEPT_PAGE, arg_57_1)
end

function IslandBaseScene:ShowQueueUpMsgBox(arg_58_1, arg_58_2)
	self:GetSubView(IslandQueueUpMsgBox):ExecuteAction("Show", arg_58_1, arg_58_2)
end

function IslandBaseScene:AddListener(arg_59_1, arg_59_2)
	local function var_59_0(arg_60_0, ...)
		arg_59_2(self, ...)
	end

	self.__callbacks__[arg_59_1] = self:bind(arg_59_1, var_59_0)

	self:GetIsland():AddListener(arg_59_1, var_59_0)
end

function IslandBaseScene:RemoveListener(arg_61_1, arg_61_2)
	if self.__callbacks__[arg_61_1] then
		self:GetIsland():RemoveListener(arg_61_1, self.eventStore[self.__callbacks__[arg_61_1]].callback)
		self:disconnect(self.__callbacks__[arg_61_1])

		self.__callbacks__[arg_61_1] = nil
	end
end

function IslandBaseScene:onBackPressed()
	local var_62_0 = self:GetSubView(IslandTimelineMgr)

	if var_62_0:GetLoaded() and var_62_0:isShowing() then
		return
	end

	if self:GetSubView(IslandStoryMgr):onBackPressed() then
		return
	end

	for iter_62_0, iter_62_1 in ipairs(self.subViews) do
		if iter_62_1:GetLoaded() and iter_62_1:isShowing() then
			if isa(iter_62_1, IslandMsgBox) then
				iter_62_1:HideWindow()
			else
				iter_62_1:Hide()
			end

			return
		end
	end

	if self.sceneMgr:OnBackPressed() then
		return
	end

	IslandBaseScene.super.onBackPressed(self)
end

function IslandBaseScene:RemoveCommonListeners()
	self:RemoveListener(ISLAND_EX_EVT.EMIT, self.OnEmit)
	self:RemoveListener(ISLAND_EX_EVT.INIT_FINISH, self.OnSceneLoaded)
	self:RemoveListener(ISLAND_EX_EVT.SHOW_MSG, self.OnShowMsgBox)
	self:RemoveListener(ISLAND_EX_EVT.OPEN_PAGE, self.OnOpenPage)
	self:RemoveListener(ISLAND_EX_EVT.PLAY_TIMELINE, self.OnPlayTimeline)
	self:RemoveListener(IslandBaseScene.LINK_CORE_EVENT, self.OnLinkCoreEvent)
	self:RemoveListener(ISLAND_EX_EVT.OPEN_ANIMATION_OP, self.OnOpenAnimatonOpPage)
	self:RemoveListener(ISLAND_EX_EVT.CLOSE_ANIMATION_OP, self.OnCloseAnimatonOpPage)
end

function IslandBaseScene:exit()
	self:RemoveListeners()
	self:RemoveCommonListeners()

	for iter_64_0, iter_64_1 in ipairs(self.cacheAbList) do
		AssetBundleHelper.UnstoreAssetBundle(iter_64_1, true)
	end

	for iter_64_2, iter_64_3 in ipairs(self.subViews) do
		if iter_64_3:GetLoaded() then
			iter_64_3:Destroy()
		end
	end

	for iter_64_4, iter_64_5 in ipairs(self.monitors) do
		iter_64_5:Dispose()
	end

	self:GetIsland():ClearListeners()
	self.poolMgr:Dispose()
	self.poppingQueue:Dispose()
	self:disposeEvent()
	self.sceneMgr:Dispose()
	getProxy(IslandProxy):ClearAllPlayerDataCache()
	getProxy(IslandProxy):ClearAllGiftTagInfo()

	self.subViews = nil
	self.cacheAbList = nil
	self.poppingQueue = nil
	self.sceneMgr = nil
	self.poolMgr = nil
	self.monitors = nil
	self.uiContainer = nil
	self.opContainer = nil
	self.pageContainer = nil
	IslandSceneLoader.lastMapId = nil
	self.contextData = {}

	GraphicsInterface.Instance:ReleaseAsyncLoadedResources()
	IslandBaseScene.super.exit(self)
end

function IslandBaseScene:detach(arg_65_1)
	IslandBaseScene.super.detach(self, arg_65_1)

	if not IsNil(self._container) then
		Object.Destroy(self._container.gameObject)

		self._container = nil
	end
end

function IslandBaseScene:AddListeners()
	return
end

function IslandBaseScene:RemoveListeners()
	return
end

function IslandBaseScene:OnUnloadScene()
	return
end

return IslandBaseScene
