local WorldScene = class("WorldScene", import("..base.BaseUI"))

WorldScene.SceneOp = "WorldScene.SceneOp"
WorldScene.Listeners = {
	onAchievementAchieved = "OnAchievementAchieved",
	onUpdateSubmarineSupport = "OnUpdateSubmarineSupport",
	onSelectFleet = "OnSelectFleet",
	onUpdateEventTips = "OnUpdateEventTips",
	onFleetSelected = "OnFleetSelected",
	onModelSelectMap = "OnModelSelectMap",
	onClearMoveQueue = "ClearMoveQueue",
	onUpdateProgress = "OnUpdateProgress",
	onUpdateScale = "OnUpdateScale",
	onUpdateDaily = "OnUpdateDaily",
	onDisposeMap = "OnDisposeMap",
	onUpdateRound = "OnUpdateRound"
}
WorldScene.optionsPath = {
	"top/adapt/top_chapter/option",
	"top/adapt/top_stage/option"
}

function WorldScene:forceGC()
	return true
end

function WorldScene:getUIName()
	return "WorldUI"
end

function WorldScene:getBGM()
	local var_3_0 = {}

	if self:GetInMap() == false then
		-- block empty
	else
		local var_3_1 = nowWorld():GetActiveMap():GetBGM()

		var_3_1 = var_3_1 or ""

		table.insert(var_3_0, var_3_1)
	end

	for iter_3_0, iter_3_1 in ipairs(var_3_0) do
		if iter_3_1 ~= "" then
			return iter_3_1
		end
	end

	return WorldScene.super.getBGM(self)
end

function WorldScene:getResource()
	return table.insertto({
		"scenes/worldmap3d",
		"model/worldmapmodel",
		"world/object/world_plane",
		"ui/darkfog",
		"ui/sairenfog",
		"world/cell/base",
		"world/object/yangliu_shang",
		"world/object/yangliu_you",
		"world/object/yangliu_xia",
		"world/object/yangliu_zuo",
		"world/object/longjuanfeng_shang",
		"world/object/longjuanfeng_you",
		"world/object/longjuanfeng_xia",
		"world/object/longjuanfeng_zuo",
		"world/object/ice",
		"world/object/poison01",
		"world/object/poison02",
		"world/object/longjuanfeng",
		"ui/san_low",
		"weaponframes",
		"shiptype"
	}, WorldScene.super.getResource(self))
end

function WorldScene:insertResToList(arg_5_1, arg_5_2)
	if noEmptyStr(arg_5_2) and not table.contains(arg_5_1, arg_5_2) then
		table.insert(arg_5_1, arg_5_2)
	end
end

function WorldScene:insertResListToList(arg_6_1, arg_6_2)
	for iter_6_0, iter_6_1 in ipairs(arg_6_2 or {}) do
		self:insertResToList(arg_6_1, iter_6_1)
	end
end

function WorldScene:insertPrefixResToList(arg_7_1, arg_7_2, arg_7_3)
	if noEmptyStr(arg_7_3) then
		self:insertResToList(arg_7_1, arg_7_2 .. arg_7_3)
	end
end

function WorldScene:insertWorldBuffIconRes(arg_8_1, arg_8_2, arg_8_3)
	if arg_8_2 and arg_8_2.config and noEmptyStr(arg_8_2.config.icon) then
		self:insertPrefixResToList(arg_8_1, arg_8_3, arg_8_2.config.icon)
	end
end

function WorldScene:downloadWorldResList(arg_9_1, arg_9_2)
	SplitPackConst.DownloadByLuaArr(arg_9_1, function()
		if self.exited then
			return
		end

		return existCall(arg_9_2)
	end)
end

function WorldScene:getAtlasResList()
	local var_11_0 = {}

	for iter_11_0, iter_11_1 in pairs(WSEntranceTpl.prefabName) do
		self:insertPrefixResToList(var_11_0, "world/mark/", iter_11_1)
	end

	self:insertResToList(var_11_0, "world/mark/dsj_srgr")

	return var_11_0
end

function WorldScene:getMapCellResList(arg_12_1)
	local var_12_0 = {}

	if not arg_12_1 then
		return var_12_0
	end

	local var_12_1 = arg_12_1:GetTerrain()

	if var_12_1 == WorldMapCell.TerrainStream or var_12_1 == WorldMapCell.TerrainWind or var_12_1 == WorldMapCell.TerrainIce or var_12_1 == WorldMapCell.TerrainPoison then
		self:insertResToList(var_12_0, (WorldConst.GetTerrainEffectRes(var_12_1, arg_12_1.terrainDir, arg_12_1.terrainStrong)))
	end

	local var_12_2 = arg_12_1:GetEmotion()

	if noEmptyStr(var_12_2) then
		self:insertResToList(var_12_0, "ui/" .. var_12_2)
	end

	return var_12_0
end

function WorldScene:getMapAttachmentResList(arg_13_1, arg_13_2)
	local var_13_0 = {}

	if not arg_13_2 then
		return var_13_0
	end

	if arg_13_2.type == WorldMapAttachment.TypeArtifact then
		local var_13_1 = arg_13_2:GetArtifaceInfo()

		if var_13_1 and noEmptyStr(var_13_1[3]) then
			self:insertPrefixResToList(var_13_0, WorldConst.ResChapterPrefab, var_13_1[3])
		end

		return var_13_0
	end

	local var_13_2 = arg_13_2.config

	if not arg_13_2.config then
		return var_13_0
	end

	if arg_13_2.type == WorldMapAttachment.TypeEvent then
		local var_13_3 = arg_13_2:GetReplaceDisplayEnemyConfig()

		if var_13_3 then
			if arg_13_2:IsAvatar() then
				self:insertPrefixResToList(var_13_0, "char/", var_13_3.icon)
			else
				self:insertPrefixResToList(var_13_0, "enemies/", var_13_3.icon)

				if noEmptyStr(var_13_3.icon) then
					self:insertResToList(var_13_0, "enemies/" .. var_13_3.icon .. "_d_blue")
				end
			end
		elseif arg_13_2:IsAvatar() then
			self:insertPrefixResToList(var_13_0, "char/", var_13_2.icon)
		elseif math.floor(var_13_2.enemyicon / 2) == 2 then
			self:insertPrefixResToList(var_13_0, WorldConst.ResChapterPrefab, var_13_2.icon)
		elseif math.floor(var_13_2.enemyicon / 2) == 0 then
			self:insertPrefixResToList(var_13_0, WorldConst.ResBoxPrefab, var_13_2.icon)
		end
	elseif arg_13_2.type == WorldMapAttachment.TypeBox then
		if arg_13_2:IsAvatar() then
			self:insertPrefixResToList(var_13_0, "char/", var_13_2.icon)
		else
			self:insertPrefixResToList(var_13_0, WorldConst.ResBoxPrefab, var_13_2.icon)
		end
	elseif WorldMapAttachment.IsEnemyType(arg_13_2.type) then
		if arg_13_2:IsAvatar() then
			self:insertPrefixResToList(var_13_0, "char/", var_13_2.icon)
		else
			self:insertPrefixResToList(var_13_0, "enemies/", var_13_2.icon)

			if noEmptyStr(var_13_2.icon) then
				self:insertResToList(var_13_0, "enemies/" .. var_13_2.icon .. "_d_blue")
			end
		end
	elseif arg_13_2.type == WorldMapAttachment.TypeTransportFleet then
		self:insertPrefixResToList(var_13_0, "enemies/", var_13_2.icon)
	elseif arg_13_2.type == WorldMapAttachment.TypeTrap then
		if arg_13_2:IsAvatar() then
			self:insertPrefixResToList(var_13_0, "char/", var_13_2.trap_fx)
		else
			self:insertPrefixResToList(var_13_0, WorldConst.ResBoxPrefab, var_13_2.trap_fx)
		end
	end

	for iter_13_0, iter_13_1 in ipairs(arg_13_2:GetBuffList()) do
		self:insertWorldBuffIconRes(var_13_0, iter_13_1, "world/buff/")
	end

	if arg_13_1 then
		local var_13_4 = arg_13_2:GetRadiationBuffs()

		if #var_13_4 > 0 then
			local var_13_5, var_13_6, var_13_7 = unpack(var_13_4[1])

			if pg.world_SLGbuff_data[var_13_6] then
				self:insertPrefixResToList(var_13_0, "world/mapbuff/", pg.world_SLGbuff_data[var_13_6].icon)
			end
		else
			for iter_13_2, iter_13_3 in ipairs(arg_13_1:GetBuffList(WorldMap.FactionEnemy, arg_13_2)) do
				self:insertWorldBuffIconRes(var_13_0, iter_13_3, "world/mapbuff/")
			end
		end
	end

	return var_13_0
end

function WorldScene:getCarryItemResList(arg_14_1)
	local var_14_0 = {}

	if arg_14_1 and arg_14_1.config then
		if arg_14_1:IsAvatar() then
			self:insertPrefixResToList(var_14_0, "char/", arg_14_1.config.icon)
		else
			self:insertPrefixResToList(var_14_0, WorldConst.ResBoxPrefab, arg_14_1.config.icon)
		end
	end

	return var_14_0
end

function WorldScene:getWorldFleetResList(arg_15_1)
	local var_15_0 = {}

	if not arg_15_1 then
		return var_15_0
	end

	self:insertPrefixResToList(var_15_0, "char/", arg_15_1:GetPrefab())

	for iter_15_0, iter_15_1 in ipairs(arg_15_1:GetBuffFxList()) do
		if type(iter_15_1) == "table" then
			for iter_15_2, iter_15_3 in ipairs(iter_15_1) do
				self:insertPrefixResToList(var_15_0, "ui/", iter_15_3)
			end
		else
			self:insertPrefixResToList(var_15_0, "ui/", iter_15_1)
		end
	end

	for iter_15_4, iter_15_5 in ipairs(arg_15_1:GetCarries()) do
		self:insertResListToList(var_15_0, self:getCarryItemResList(iter_15_5))
	end

	for iter_15_6, iter_15_7 in ipairs(arg_15_1:GetBuffList()) do
		self:insertWorldBuffIconRes(var_15_0, iter_15_7, "world/buff/")
	end

	self:insertWorldBuffIconRes(var_15_0, arg_15_1:GetDamageBuff(), "world/buff/")
	self:insertWorldBuffIconRes(var_15_0, arg_15_1:GetWatchingBuff(), "world/watchingbuff/")

	if arg_15_1:IsCatSalvage() then
		local var_15_1 = arg_15_1:GetDisplayCommander()

		if var_15_1 then
			self:insertPrefixResToList(var_15_0, "commandericon/", var_15_1:getPainting())
		end
	end

	for iter_15_8, iter_15_9 in pairs(arg_15_1:getCommanders()) do
		if iter_15_9 then
			local var_15_2 = iter_15_9:getSkills()[1]

			if var_15_2 then
				self:insertPrefixResToList(var_15_0, "commanderskillicon/", var_15_2:getConfig("icon"))
			end
		end
	end

	for iter_15_10, iter_15_11 in ipairs({
		TeamType.Main,
		TeamType.Vanguard
	}) do
		for iter_15_12, iter_15_13 in ipairs(arg_15_1:GetTeamShips(iter_15_11, true)) do
			local var_15_3 = WorldConst.FetchShipVO(iter_15_13.id)

			if var_15_3 then
				self:insertPrefixResToList(var_15_0, "SquareIcon/", var_15_3:getPainting())
			end
		end
	end

	return var_15_0
end

function WorldScene:getMapResList(arg_16_1)
	local var_16_0 = {
		"world/object/world_plane",
		"ui/darkfog",
		"ui/sairenfog",
		"world/cell/base",
		"world/object/yangliu_shang",
		"world/object/yangliu_you",
		"world/object/yangliu_xia",
		"world/object/yangliu_zuo",
		"world/object/longjuanfeng_shang",
		"world/object/longjuanfeng_you",
		"world/object/longjuanfeng_xia",
		"world/object/longjuanfeng_zuo",
		"world/object/ice",
		"world/object/poison01",
		"world/object/poison02",
		"world/object/longjuanfeng",
		"ui/san_low",
		"weaponframes",
		"shiptype"
	}

	if not arg_16_1 then
		return var_16_0
	end

	local var_16_1

	if arg_16_1.theme and noEmptyStr(arg_16_1.theme.assetSea) then
		self:insertPrefixResToList(var_16_0, "chapter/pic/", arg_16_1.theme.assetSea)

		var_16_1 = checkExist(arg_16_1, {
			"config"
		}, {
			"float_items"
		}) or {}
	end

	for iter_16_0, iter_16_1 in ipairs(var_16_1) do
		self:insertPrefixResToList(var_16_0, WorldConst.ResChapterPrefab, iter_16_1[3])
	end

	for iter_16_2, iter_16_3 in pairs(arg_16_1.cells or {}) do
		self:insertResListToList(var_16_0, self:getMapCellResList(iter_16_3))

		for iter_16_4, iter_16_5 in ipairs(iter_16_3.attachments or {}) do
			self:insertResListToList(var_16_0, self:getMapAttachmentResList(arg_16_1, iter_16_5))
		end
	end

	for iter_16_6, iter_16_7 in ipairs(arg_16_1:GetNormalFleets()) do
		self:insertResListToList(var_16_0, self:getWorldFleetResList(iter_16_7))
	end

	for iter_16_8, iter_16_9 in ipairs(nowWorld():GetWorldMapBuffs()) do
		self:insertWorldBuffIconRes(var_16_0, iter_16_9, "world/buff/")
	end

	local var_16_2 = WorldBuff.New()

	var_16_2:Setup({
		floor = 0,
		id = WorldConst.MoveLimitBuffId
	})
	self:insertWorldBuffIconRes(var_16_0, var_16_2, "world/buff/")

	return var_16_0
end

function WorldScene:getUIAnimResList(arg_17_1)
	local var_17_0 = {}

	self:insertPrefixResToList(var_17_0, "ui/", arg_17_1)

	return var_17_0
end

function WorldScene:getStrikeAnimResList(arg_18_1, arg_18_2)
	local var_18_0 = self:getUIAnimResList(arg_18_1)

	if arg_18_2 then
		self:insertPrefixResToList(var_18_0, "painting/", arg_18_2:getPainting())
		self:insertPrefixResToList(var_18_0, "char/", arg_18_2:getPrefab())
	end

	return var_18_0
end

function WorldScene:init()
	for iter_19_0, iter_19_1 in pairs(WorldScene.Listeners) do
		self[iter_19_0] = function(...)
			WorldScene[iter_19_1](self, ...)
		end
	end

	self:bind(WorldScene.SceneOp, function(arg_21_0, ...)
		self:Op(...)
	end)

	self.camera = pg.UIMgr.GetInstance().levelCamera:GetComponent(typeof(Camera))
	self.rtUIMain = pg.UIMgr.GetInstance().LevelMain

	setActive(self.rtUIMain, false)

	self.rtGrid = self.rtUIMain:Find("LevelGrid")

	setActive(self.rtGrid, true)

	self.rtDragLayer = self.rtGrid:Find("DragLayer")
	self.rtEnvBG = self._tf:Find("main/bg")
	self.rtTop = self._tf:Find("top")
	self.rtTopAtlas = self.rtTop:Find("adapt/top_chapter")

	setActive(self.rtTopAtlas, false)

	self.rtRightAtlas = self.rtTop:Find("adapt/right_chapter")

	setActive(self.rtRightAtlas, false)

	self.rtBottomAtlas = self.rtTop:Find("adapt/bottom_chapter")

	setActive(self.rtBottomAtlas, false)

	self.rtTransportAtlas = self.rtTop:Find("transport_chapter")

	setActive(self.rtTransportAtlas, false)

	self.rtTopMap = self.rtTop:Find("adapt/top_stage")

	setActive(self.rtTopMap, false)

	self.rtLeftMap = self.rtTop:Find("adapt/left_stage")

	setActive(self.rtLeftMap, false)

	self.rtRightMap = self.rtTop:Find("adapt/right_stage")

	setActive(self.rtRightMap, false)

	self.rtOutMap = self.rtTop:Find("effect_stage")

	setActive(self.rtOutMap, false)

	self.rtClickStop = self.rtTop:Find("stop_click")

	onButton(self, self.rtClickStop:Find("long_move"), function()
		if #self.moveQueue > 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("world_fleet_stop"))
			self:ClearMoveQueue()
		end
	end)
	onButton(self, self.rtClickStop:Find("auto_fight"), function()
		local var_23_0 = nowWorld()

		if var_23_0.isAutoFight then
			pg.TipsMgr.GetInstance():ShowTips(i18n("autofight_tip_bigworld_stop"))
			var_23_0:TriggerAutoFight(false)
		else
			assert(false, "stop clicker shouldn't active")
		end
	end)
	setActive(self.rtClickStop, false)

	self.resAtlas = WorldResource.New()

	self.resAtlas:setParent(self.rtTopAtlas:Find("resources"), false)

	self.resMap = WorldResource.New()

	self.resMap:setParent(self.rtTopMap:Find("resources"), false)

	self.wsPool = WSPool.New()

	self.wsPool:Setup(self._tf:Find("resources"))

	self.wsAnim = WSAnim.New()

	self.wsAnim:Setup()

	self.wsTimer = WSTimer.New()

	self.wsTimer:Setup()

	self.wsDragProxy = WSDragProxy.New()
	self.wsDragProxy.transform = self.rtDragLayer
	self.wsDragProxy.wsTimer = self.wsTimer

	self.wsDragProxy:Setup({
		clickCall = function(arg_24_0, arg_24_1)
			if self.svScannerPanel:isShowing() then
				local var_24_0, var_24_1 = self:CheckScannerEnable(self:ScreenPos2MapPos(arg_24_1.position))

				if var_24_0 then
					self.svScannerPanel:ActionInvoke("DisplayWindow", var_24_0, var_24_1)
				else
					self.svScannerPanel:ActionInvoke("HideWindow")
				end
			else
				self:OnClickMap(self:ScreenPos2MapPos(arg_24_1.position))
			end
		end,
		longPressCall = function()
			self:OnLongPressMap(self:ScreenPos2MapPos(Vector3(Input.mousePosition.x, Input.mousePosition.y)))
		end
	})

	self.wsMapCamera = WSMapCamera.New()
	self.wsMapCamera.camera = self.camera

	self.wsMapCamera:Setup()
	self:InitSubView()
	self:AddWorldListener()

	self.moveQueue = {}
	self.achievedList = {}
	self.mapOps = {}
	self.wsCommands = {}

	WSCommand.Bind(self)
	self:OpOpen()
end

function WorldScene:InitSubView()
	self.rtPanelList = self._tf:Find("panel_list")
	self.svOrderPanel = SVOrderPanel.New(self.rtPanelList, self.event, {
		wsPool = self.wsPool
	})
	self.svScannerPanel = SVScannerPanel.New(self.rtPanelList, self.event)

	self:bind(SVScannerPanel.ShowView, function(arg_27_0)
		self.wsMap:ShowScannerMap(true)
		setActive(self.wsMap.rtTop, false)
		self:HideMapUI()
	end)
	self:bind(SVScannerPanel.HideView, function(arg_28_0)
		self.wsMap:ShowScannerMap(false)
		setActive(self.wsMap.rtTop, true)
		self:DisplayMapUI()
	end)
	self:bind(SVScannerPanel.HideGoing, function(arg_29_0, arg_29_1, arg_29_2)
		self.wsMap:ShowScannerMap(false)
		setActive(self.wsMap.rtTop, true)
		self:DisplayMapUI()
		self:OnClickCell(arg_29_1, arg_29_2)
	end)

	self.svRealmPanel = SVRealmPanel.New(self.rtPanelList, self.event)
	self.svAchievement = SVAchievement.New(self.rtPanelList, self.event)

	self:bind(SVAchievement.HideView, function(arg_30_0)
		table.remove(self.achievedList, 1)

		return (#self.achievedList > 0 and function()
			self:ShowSubView("Achievement", self.achievedList[1])
		end or function()
			self:Op("OpInteractive")
		end)()
	end)

	self.svDebugPanel = SVDebugPanel.New(self.rtPanelList, self.event)
	self.svFloatPanel = SVFloatPanel.New(self.rtTop, self.event)

	self:bind(SVFloatPanel.ReturnCall, function(arg_33_0, arg_33_1)
		self:Op("OpCall", function(arg_34_0)
			arg_34_0()

			local var_34_0 = nowWorld():GetActiveEntrance()

			if arg_33_1.id == var_34_0.id then
				self.wsAtlas:UpdateSelect()
				self.wsAtlas:UpdateSelect(arg_33_1)
			else
				self:ClickAtlas(var_34_0)
			end
		end)
	end)
	self:bind(SVFloatPanel.DelegateCall, function(arg_35_0, arg_35_1)
		local var_35_0, var_35_1 = nowWorld():CanDelegate()

		if not var_35_0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n(var_35_1))

			return
		end

		self.svSingleDelegatePanel:ExecuteAction("Show", arg_35_1)
	end)

	self.svPoisonPanel = SVPoisonPanel.New(self.rtPanelList, self.event)
	self.svGlobalBuff = SVGlobalBuff.New(self.rtPanelList, self.event)

	self:bind(SVGlobalBuff.HideView, function(arg_36_0, arg_36_1)
		return existCall(arg_36_1)
	end)

	self.svBossProgress = SVBossProgress.New(self.rtPanelList, self.event)

	self:bind(SVBossProgress.HideView, function(arg_37_0, arg_37_1)
		return existCall(arg_37_1)
	end)

	self.svSalvageResult = SVSalvageResult.New(self.rtPanelList, self.event)
	self.svDelegatePanel = ChapterAutoPanelTypeWorld.New(self.rtPanelList, self.event)

	self.svDelegatePanel:RegisterView(self)

	self.svSingleDelegatePanel = ChapterAutoPanelTypeWorldSingle.New(self.rtPanelList, self.event)

	self.svSingleDelegatePanel:RegisterView(self)
end

function WorldScene:didEnter()
	self:OverlayPanel(self.rtTop)

	self.warningSairen = not self.contextData.inSave

	if getProxy(ChapterAutoProxy):HasTypeCommission(ChapterAutoProxy.TYPE.WORLD) or self.contextData.inWorld then
		self:Op("OpSetInMap", false, function()
			self.wsAtlas:UpdateSelect(nowWorld():GetActiveEntrance())
		end)
	else
		self:Op("OpSetInMap", true)
	end
end

function WorldScene:onBackPressed()
	if self.inCutIn then
		return
	elseif self.svDebugPanel:isShowing() then
		self:HideSubView("DebugPanel")
	elseif self.svAchievement:isShowing() then
		self:HideSubView("Achievement")
	elseif self.svGlobalBuff:isShowing() then
		self:HideSubView("GlobalBuff")
	elseif self.svBossProgress:isShowing() then
		self:HideSubView("BossProgress")
	elseif self.svOrderPanel:isShowing() then
		self:HideSubView("OrderPanel")
	elseif self.svScannerPanel:isShowing() then
		self:HideSubView("ScannerPanel")
	elseif self.svPoisonPanel:isShowing() then
		self:HideSubView("PoisonPanel")
	elseif self.svSalvageResult:isShowing() then
		self:HideSubView("SalvageResult")
	elseif self.svDelegatePanel:isShowing() then
		self:HideSubView("DelegatePanel")
	elseif self.svSingleDelegatePanel:isShowing() then
		self:HideSubView("SingleDelegatePanel")
	elseif self.wsMapLeft and isActive(self.wsMapLeft.toggleMask) then
		self.wsMapLeft:HideToggleMask()
	elseif not self:GetInMap() then
		triggerButton(self.rtTopAtlas:Find("back_button"))
	else
		triggerButton(self.wsMapTop.btnBack)
	end
end

function WorldScene:quickExitFunc()
	self:Op("OpCall", function(arg_42_0)
		arg_42_0()

		local var_42_0 = {}

		if nowWorld():CheckReset() then
			table.insert(var_42_0, function(arg_43_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("world_recycle_notice"),
					onYes = arg_43_0
				})
			end)
		end

		seriesAsync(var_42_0, function()
			WorldScene.super.quickExitFunc(self)
		end)
	end)
end

function WorldScene:ExitWorld(arg_45_1, arg_45_2)
	local var_45_0 = {}

	if not arg_45_2 then
		table.insert(var_45_0, function(arg_46_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("world_exit_tip"),
				onYes = arg_46_0,
				onNo = function()
					return existCall(arg_45_1)
				end
			})
		end)
	end

	if not arg_45_2 then
		if nowWorld():CheckReset() then
			table.insert(var_45_0, function(arg_48_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("world_recycle_notice"),
					onYes = arg_48_0,
					onNo = function()
						return existCall(arg_45_1)
					end
				})
			end)
		end
	end

	table.insert(var_45_0, function(arg_50_0)
		if self:GetInMap() then
			self:EaseOutMapUI(arg_50_0)
		else
			self:EaseOutAtlasUI(arg_50_0)
		end
	end)
	seriesAsync(var_45_0, function()
		existCall(arg_45_1)
		self:closeView()
	end)
end

function WorldScene:SaveState()
	self.contextData.inSave = true
	self.contextData.inWorld = self:GetInMap() == false
	self.contextData.inShop = false
	self.contextData.inPort = false
end

function WorldScene:willExit()
	self:SaveState()
	self:RemoveWorldListener()
	self:UnOverlayPanel(self.rtTop, self._tf)
	self.svOrderPanel:Destroy()
	self.svScannerPanel:Destroy()
	self.svAchievement:Destroy()
	self.svRealmPanel:Destroy()
	self.svDebugPanel:Destroy()
	self.svFloatPanel:Destroy()
	self.svPoisonPanel:Destroy()
	self.svGlobalBuff:Destroy()
	self.svBossProgress:Destroy()
	self.svDelegatePanel:Destroy()
	self.svSingleDelegatePanel:Destroy()
	self:DisposeAtlas()
	self:DisposeAtlasUI()
	self:DisposeMap()
	self:DisposeMapUI()
	self.wsPool:Dispose()

	self.wsPool = nil

	self.wsAnim:Dispose()

	self.wsAnim = nil

	self.wsTimer:Dispose()

	self.wsTimer = nil

	self.wsDragProxy:Dispose()

	self.wsDragProxy = nil

	self.wsMapCamera:Dispose()

	self.wsMapCamera = nil

	self.resAtlas:exit()

	self.resAtlas = nil

	self.resMap:exit()

	self.resMap = nil

	self:VerifyMapOp()
	self:OpDispose()
	WSCommand.Unbind(self)
	WBank:Recycle(WorldMapOp)
end

function WorldScene:SetPlayer(arg_54_1)
	self.player = arg_54_1

	self.resAtlas:setPlayer(self.player)
	self.resMap:setPlayer(self.player)
end

function WorldScene:AddWorldListener()
	local var_55_0 = nowWorld()

	var_55_0:AddListener(World.EventUpdateProgress, self.onUpdateProgress)
	var_55_0:GetTaskProxy():AddListener(WorldTaskProxy.EventUpdateDailyTaskIds, self.onUpdateDaily)
end

function WorldScene:RemoveWorldListener()
	local var_56_0 = nowWorld()

	var_56_0:RemoveListener(World.EventUpdateProgress, self.onUpdateProgress)
	var_56_0:GetTaskProxy():RemoveListener(WorldTaskProxy.EventUpdateDailyTaskIds, self.onUpdateDaily)
end

function WorldScene:SetInMap(arg_57_1, arg_57_2)
	if arg_57_1 then
		arg_57_2 = defaultValue(arg_57_2, function()
			self:Op("OpInteractive")
		end)
	end

	if self.inMap == arg_57_1 then
		return existCall(arg_57_2)
	end

	local var_57_0 = {}
	local var_57_1 = {}

	self:StopAnim()

	if self.inMap then
		table.insert(var_57_0, function(arg_59_0)
			self:Op("OpSwitchOutMap", arg_59_0)
		end)
	elseif self.inMap ~= nil then
		table.insert(var_57_0, function(arg_60_0)
			self:Op("OpSwitchOutWorld", arg_60_0)
		end)
	end

	table.insert(var_57_0, function(arg_61_0)
		self:Op("OpCall", function(arg_62_0)
			parallelAsync(var_57_1, function()
				arg_62_0()

				return arg_61_0()
			end)
		end)
	end)
	table.insert(var_57_1, function(arg_64_0)
		self:DisplayEnv(arg_64_0)
	end)
	table.insert(var_57_1, function(arg_65_0)
		self:LoadMap(nowWorld():GetActiveMap(), arg_65_0)
	end)

	if arg_57_1 then
		table.insert(var_57_0, function(arg_66_0)
			self:Op("OpSwitchInMap", arg_66_0)
		end)
	else
		table.insert(var_57_1, function(arg_67_0)
			self:LoadAtlas(arg_67_0)
		end)
		table.insert(var_57_0, function(arg_68_0)
			self:Op("OpSwitchInWorld", arg_68_0)
		end)
		table.insert(var_57_0, function(arg_69_0)
			self:CheckGuideWorld(arg_69_0)
		end)
	end

	table.insert(var_57_0, function(arg_70_0)
		self:PlayBGM()
		arg_70_0()
	end)

	self.inMap = arg_57_1

	seriesAsync(var_57_0, arg_57_2)
end

function WorldScene:CheckGuideWorld(arg_71_1)
	local var_71_0 = nowWorld()
	local var_71_1 = {}

	table.insert(var_71_1, {
		"CHAPTER_AUTO_WORLD_GUIDE",
		function()
			return var_71_0:CanDelegate()
		end
	})

	local var_71_2 = pg.NewStoryMgr.GetInstance()

	for iter_71_0, iter_71_1 in ipairs(var_71_1) do
		if not var_71_2:IsPlayed(iter_71_1[1]) and iter_71_1[2]() then
			return WorldGuider.GetInstance():PlayGuide(iter_71_1[1], nil, arg_71_1)
		end
	end

	existCall(arg_71_1)
end

function WorldScene:GetInMap()
	return self.inMap
end

function WorldScene:ShowSubView(arg_74_1, arg_74_2, arg_74_3)
	self["sv" .. arg_74_1]:Load()
	self["sv" .. arg_74_1]:ActionInvoke("Setup", unpack(arg_74_2 or {}))
	self["sv" .. arg_74_1]:ActionInvoke("Show", unpack(arg_74_3 or {}))
end

function WorldScene:HideSubView(arg_75_1, ...)
	self["sv" .. arg_75_1]:ActionInvoke("Hide", ...)
end

function WorldScene:DisplayAtlasUI()
	self:DisplayAtlasTop()
	self:DisplayAtlasRight()
	self:DisplayAtlasBottom()
	self:UpdateSystemOpen()
end

function WorldScene:HideAtlasUI()
	self:HideAtlasTop()
	self:HideAtlasRight()
	self:HideAtlasBottom()
end

function WorldScene:EaseInAtlasUI(arg_78_1)
	self:CancelAtlasUITween()
	parallelAsync({
		function(arg_79_0)
			setAnchoredPosition(self.rtTopAtlas, {
				y = self.rtTopAtlas.rect.height
			})
			self.wsTimer:AddTween(LeanTween.moveY(self.rtTopAtlas, 0, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeInSine):setOnComplete(System.Action(arg_79_0)).uniqueId)
		end,
		function(arg_80_0)
			setAnchoredPosition(self.rtBottomAtlas, {
				y = -self.rtBottomAtlas.rect.height
			})
			self.wsTimer:AddTween(LeanTween.moveY(self.rtBottomAtlas, 0, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeInSine):setOnComplete(System.Action(arg_80_0)).uniqueId)
		end,
		function(arg_81_0)
			setAnchoredPosition(self.rtRightAtlas, {
				x = self.rtRightAtlas.rect.width
			})
			self.wsTimer:AddTween(LeanTween.moveX(self.rtRightAtlas, 0, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeInSine):setOnComplete(System.Action(arg_81_0)).uniqueId)
		end
	}, function()
		return existCall(arg_78_1)
	end)
end

function WorldScene:EaseOutAtlasUI(arg_83_1)
	self:CancelAtlasUITween()
	parallelAsync({
		function(arg_84_0)
			setAnchoredPosition(self.rtTopAtlas, {
				y = 0
			})
			self.wsTimer:AddTween(LeanTween.moveY(self.rtTopAtlas, self.rtTopAtlas.rect.height, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeOutSine):setOnComplete(System.Action(arg_84_0)).uniqueId)
		end,
		function(arg_85_0)
			setAnchoredPosition(self.rtBottomAtlas, {
				y = 0
			})
			self.wsTimer:AddTween(LeanTween.moveY(self.rtBottomAtlas, -self.rtBottomAtlas.rect.height, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeOutSine):setOnComplete(System.Action(arg_85_0)).uniqueId)
		end,
		function(arg_86_0)
			setAnchoredPosition(self.rtRightAtlas, {
				x = 0
			})
			self.wsTimer:AddTween(LeanTween.moveX(self.rtRightAtlas, self.rtRightAtlas.rect.width, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeOutSine):setOnComplete(System.Action(arg_86_0)).uniqueId)
		end
	}, function()
		return existCall(arg_83_1)
	end)
end

function WorldScene:CancelAtlasUITween()
	LeanTween.cancel(go(self.rtTransportAtlas))
	LeanTween.cancel(go(self.rtTopAtlas))
	LeanTween.cancel(go(self.rtBottomAtlas))
	LeanTween.cancel(go(self.rtRightAtlas))
end

function WorldScene:DisposeAtlasUI()
	self:HideAtlasUI()
	self:DisposeAtlasTransport()
	self:DisposeAtlasTop()
	self:DisposeAtlasRight()
	self:DisposeAtlasBottom()
end

function WorldScene:DisplayAtlas()
	self.wsAtlas:SwitchArea(nowWorld():GetActiveEntrance():GetAreaId())
	self.wsAtlas:UpdateActiveMark()
	self.wsAtlas:ShowOrHide(true)
end

function WorldScene:HideAtlas()
	self.wsAtlas:UpdateSelect()
	self.wsAtlas:ShowOrHide(false)
end

function WorldScene:ClickAtlas(arg_92_1)
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_PANEL)

	local var_92_0 = arg_92_1:GetAreaId()

	if not nowWorld():CheckAreaUnlock(var_92_0) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("area_lock"))

		return
	end

	if self.wsAtlas.nowArea then
		self.wsAtlas:UpdateSelect()

		if self.wsAtlas.selectEntrance ~= arg_92_1 then
			self.wsAtlas:UpdateSelect(arg_92_1)
		end
	else
		self:EnterToModelMap(var_92_0)
	end
end

function WorldScene:LoadAtlas(arg_93_1)
	local var_93_0 = {}

	if not self.wsAtlas then
		table.insert(var_93_0, function(arg_94_0)
			self:downloadWorldResList(self:getAtlasResList(), arg_94_0)
		end)
		table.insert(var_93_0, function(arg_95_0)
			self.wsAtlas = self:NewAtlas()

			self.wsAtlas:LoadScene(function()
				self.wsAtlas:AddListener(WSAtlasWorld.EventUpdateselectEntrance, self.onModelSelectMap)
				self.wsAtlas:UpdateAtlas(nowWorld():GetAtlas())

				return arg_95_0()
			end)
		end)
	end

	seriesAsync(var_93_0, arg_93_1)
end

function WorldScene:NewAtlas()
	local var_97_0 = WSAtlasWorld.New()

	var_97_0.wsTimer = self.wsTimer

	function var_97_0.onClickColor(arg_98_0, arg_98_1)
		if self.wsAtlas:CheckIsTweening() then
			return
		end

		self:Op("OpCall", function(arg_99_0)
			arg_99_0()
			self:ClickAtlas(arg_98_0)
		end)
	end

	var_97_0:Setup()

	return var_97_0
end

function WorldScene:DisposeAtlas()
	if self.wsAtlas then
		self:HideAtlas()
		self.wsAtlas:RemoveListener(WSAtlasWorld.EventUpdateselectEntrance, self.onModelSelectMap)
		self.wsAtlas:Dispose()

		self.wsAtlas = nil
	end
end

function WorldScene:DisplayAtlasTop()
	self.wsAtlasTop = self.wsAtlasTop or self:NewAtlasTop(self.rtTopAtlas)

	setActive(self.rtTopAtlas, true)
	setActive(self.rtTopAtlas:Find("print/title_world"), true)
	setActive(self.rtTopAtlas:Find("print/title_view"), false)
	setActive(self.rtTopAtlas:Find("sairen_warning"), self.warningSairen and #nowWorld():GetAtlas().sairenEntranceList > 0)

	self.warningSairen = false
end

function WorldScene:UpdateDelegateDisplay()
	if self.svDelegatePanel:isShowing() then
		self:HideSubView("DelegatePanel")
	end

	if self.svSingleDelegatePanel:isShowing() then
		self:HideSubView("SingleDelegatePanel")
	end

	if self.wsAtlasRight then
		self.wsAtlasRight:UpdateDelegate()
	end

	if self.svFloatPanel:isShowing() then
		self.svFloatPanel:UpdatePanel()
	end
end

function WorldScene:HideAtlasTop()
	setActive(self.rtTopAtlas, false)
end

function WorldScene:NewAtlasTop(arg_104_1)
	onButton(self, arg_104_1:Find("back_button"), function()
		if getProxy(ChapterAutoProxy):HasTypeCommission(ChapterAutoProxy.TYPE.WORLD) then
			self:Op("OpCall", function(arg_106_0)
				self:ExitWorld(arg_106_0)
			end)
		else
			self:Op("OpCall", function(arg_107_0)
				arg_107_0()
				self:BackToMap()
			end)
		end
	end, SFX_CANCEL)

	return {
		transform = arg_104_1
	}
end

function WorldScene:DisposeAtlasTop()
	self.wsAtlasTop = nil
end

function WorldScene:DisplayAtlasRight()
	self.wsAtlasRight = self.wsAtlasRight or self:NewAtlasRight(self.rtRightAtlas)

	self.wsAtlasRight:SetOverSize(self.rtTop:Find("adapt").offsetMax.x)
	setActive(self.rtRightAtlas, true)
end

function WorldScene:HideAtlasRight()
	setActive(self.rtRightAtlas, false)
end

function WorldScene:NewAtlasRight(arg_111_1, arg_111_2)
	local var_111_0 = WSAtlasRight.New()

	var_111_0.transform = arg_111_1

	var_111_0:Setup()
	onButton(self, var_111_0.btnSettings, function()
		self:Op("OpOpenScene", SCENE.SETTINGS, {
			scroll = "world_settings",
			page = NewSettingsScene.PAGE_OPTION
		})
	end, SFX_PANEL)
	onButton(self, var_111_0.btnSwitch, function()
		if getProxy(ChapterAutoProxy):IsCommissionDoing() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("world_auto_plan_error_tip1"))

			return
		end

		self:Op("OpOpenLayer", Context.New({
			mediator = WorldSwitchPlanningMediator,
			viewComponent = WorldSwitchPlanningLayer
		}))
	end, SFX_CONFIRM)
	onButton(self, var_111_0.btnDelegate, function()
		local var_114_0, var_114_1 = nowWorld():CanDelegate()

		if not var_114_0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n(var_114_1))

			return
		end

		self.svDelegatePanel:ExecuteAction("Show")
	end, SFX_PANEL)
	onButton(self, var_111_0.btnDeleCancel, function()
		self:emit(WorldMediator.OnFinishDelegate)
	end, SFX_CANCEL)
	onButton(self, var_111_0.btnDeleConfirm, function()
		self:emit(WorldMediator.OnFinishDelegate)
	end, SFX_CONFIRM)

	return var_111_0
end

function WorldScene:DisposeAtlasRight()
	if self.wsAtlasRight then
		self.wsAtlasRight:Dispose()

		self.wsAtlasRight = nil
	end
end

function WorldScene:DisplayAtlasBottom()
	self.wsAtlasBottom = self.wsAtlasBottom or self:NewAtlasBottom(self.rtBottomAtlas)

	self.wsAtlasBottom:SetOverSize(self.rtTop:Find("adapt").offsetMax.x)
	self.wsAtlasBottom:UpdateScale(1)
	setActive(self.rtBottomAtlas, true)
	setActive(self.wsAtlasBottom.btnDailyTask:Find("tip"), nowWorld():GetTaskProxy():canAcceptDailyTask())
end

function WorldScene:HideAtlasBottom()
	setActive(self.rtBottomAtlas, false)
end

function WorldScene:NewAtlasBottom(arg_120_1)
	local var_120_0 = WSAtlasBottom.New()

	var_120_0.transform = arg_120_1
	var_120_0.wsTimer = self.wsTimer

	var_120_0:Setup()

	if CAMERA_MOVE_OPEN then
		var_120_0:AddListener(WSAtlasBottom.EventUpdateScale, self.onUpdateScale)
	end

	onButton(self, var_120_0.btnOverview, function()
		if self.wsAtlas:CheckIsTweening() then
			return
		end

		self:Op("OpCall", function(arg_122_0)
			self.wsAtlas:LoadModel(function()
				arg_122_0()
				self:ReturnToModelArea()
			end)
		end)
	end, SFX_PANEL)
	onButton(self, var_120_0.btnBoss, function()
		if nowWorld():GetBossProxy():IsOpen() then
			self:Op("OpOpenScene", SCENE.WORLDBOSS)
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))
		end
	end, SFX_PANEL)
	onButton(self, var_120_0.btnShop, function()
		self:Op("OpOpenLayer", Context.New({
			mediator = WorldShopMediator,
			viewComponent = WorldShopLayer
		}))
	end, SFX_PANEL)
	onButton(self, var_120_0.btnCollection, function()
		self:Op("OpOpenScene", SCENE.WORLD_COLLECTION, {
			page = WorldMediaCollectionScene.PAGE_RECORD
		})
	end, SFX_PANEL)
	onButton(self, var_120_0.btnDailyTask, function()
		local var_127_0 = nowWorld()

		if var_127_0:IsSystemOpen(WorldConst.SystemDailyTask) then
			var_127_0:GetTaskProxy():checkDailyTask(function()
				self:Op("OpOpenLayer", Context.New({
					mediator = WorldDailyTaskMediator,
					viewComponent = WorldDailyTaskLayer
				}))
			end)
		else
			pg.TipsMgr.GetInstance(i18n("world_daily_task_lock"))
		end
	end, SFX_PANEL)

	return var_120_0
end

function WorldScene:DisposeAtlasBottom()
	if self.wsAtlasBottom then
		self.wsAtlasBottom:Dispose()

		self.wsAtlasBottom = nil
	end
end

function WorldScene:DisplayAtlasTransport()
	self.wsAtlasTransport = self.wsAtlasTransport or self:NewAtlasTransport(self.rtTransportAtlas)

	setActive(self.rtTransportAtlas, true)
end

function WorldScene:HideAtlasTransport()
	setActive(self.rtTransportAtlas, false)
end

function WorldScene:NewAtlasTransport(arg_132_1)
	local var_132_0 = {
		transform = arg_132_1,
		btnBack = arg_132_1:Find("adapt/btn_back")
	}

	onButton(self, var_132_0.btnBack, function()
		assert(self.inTransportMode, "this isn't transport mode atlas")
		self:BackToMap()
	end, SFX_CANCEL)

	return var_132_0
end

function WorldScene:DisposeAtlasTransport()
	self.wsAtlasTransport = nil
end

function WorldScene:DisplayMapUI()
	self:DisplayMapTop()
	self:DisplayMapLeft()
	self:DisplayMapRight()
	self:DisplayMapOut()
	self:UpdateSystemOpen()
end

function WorldScene:HideMapUI()
	self:HideMapTop()
	self:HideMapLeft()
	self:HideMapRight()
	self:HideMapOut()
end

function WorldScene:UpdateMapUI()
	local var_137_0 = nowWorld()
	local var_137_1 = var_137_0:GetActiveEntrance()
	local var_137_2 = var_137_0:GetActiveMap()

	self.wsMapTop:Update(var_137_1, var_137_2)
	self.wsMapLeft:UpdateMap(var_137_2)
	self.wsMapRight:Update(var_137_1, var_137_2)
	self.wsMapOut:UpdateMap(var_137_2)
end

function WorldScene:EaseInMapUI(arg_138_1)
	self:CancelMapUITween()
	parallelAsync({
		function(arg_139_0)
			setAnchoredPosition(self.rtTopMap, {
				y = self.rtTopMap.rect.height
			})
			self.wsTimer:AddTween(LeanTween.moveY(self.rtTopMap, 0, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeInSine):setOnComplete(System.Action(arg_139_0)).uniqueId)
		end,
		function(arg_140_0)
			setAnchoredPosition(self.rtLeftMap, {
				x = -self.rtLeftMap.rect.width
			})
			self.wsTimer:AddTween(LeanTween.moveX(self.rtLeftMap, 0, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeInSine):setOnComplete(System.Action(arg_140_0)).uniqueId)
		end,
		function(arg_141_0)
			setAnchoredPosition(self.rtRightMap, {
				x = self.rtRightMap.rect.width
			})
			self.wsTimer:AddTween(LeanTween.moveX(self.rtRightMap, 0, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeInSine):setOnComplete(System.Action(arg_141_0)).uniqueId)
		end
	}, function()
		return existCall(arg_138_1)
	end)
end

function WorldScene:EaseOutMapUI(arg_143_1)
	self:CancelMapUITween()
	parallelAsync({
		function(arg_144_0)
			setAnchoredPosition(self.rtTopMap, {
				y = 0
			})
			self.wsTimer:AddTween(LeanTween.moveY(self.rtTopMap, self.rtTopMap.rect.height, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeOutSine):setOnComplete(System.Action(arg_144_0)).uniqueId)
		end,
		function(arg_145_0)
			setAnchoredPosition(self.rtLeftMap, {
				x = 0
			})
			self.wsTimer:AddTween(LeanTween.moveX(self.rtLeftMap, -self.rtLeftMap.rect.width, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeOutSine):setOnComplete(System.Action(arg_145_0)).uniqueId)
		end,
		function(arg_146_0)
			setAnchoredPosition(self.rtRightMap, {
				x = 0
			})
			self.wsTimer:AddTween(LeanTween.moveX(self.rtRightMap, self.rtRightMap.rect.width, WorldConst.UIEaseFasterDuration):setEase(LeanTweenType.easeOutSine):setOnComplete(System.Action(arg_146_0)).uniqueId)
		end
	}, function()
		return existCall(arg_143_1)
	end)
end

function WorldScene:CancelMapUITween()
	LeanTween.cancel(go(self.rtTopMap))
	LeanTween.cancel(go(self.rtLeftMap))
	LeanTween.cancel(go(self.rtRightMap))
end

function WorldScene:DisposeMapUI()
	self:DisposeMapTop()
	self:DisposeMapLeft()
	self:DisposeMapRight()
	self:DisposeMapOut()
end

function WorldScene:DisplayMap()
	setActive(self.rtUIMain, true)
end

function WorldScene:HideMap()
	setActive(self.rtUIMain, false)
end

function WorldScene:ShowMargin(arg_152_1)
	if self.wsMap then
		self.wsMap:UpdateTransportDisplay(arg_152_1)
	end
end

function WorldScene:LoadMap(arg_153_1, arg_153_2)
	assert(arg_153_1, "target map not exist.")

	local var_153_0 = {}

	if not arg_153_1:IsValid() then
		table.insert(var_153_0, function(arg_154_0)
			self:emit(WorldMediator.OnMapReq, arg_153_1.id, arg_154_0)
		end)
	end

	seriesAsync(var_153_0, function()
		if self.wsMap then
			return existCall(arg_153_2)
		else
			self:downloadWorldResList(self:getMapResList(arg_153_1), function()
				arg_153_1:AddListener(WorldMap.EventUpdateActive, self.onDisposeMap)
				arg_153_1:AddListener(WorldMap.EventUpdateMoveSpeed, self.onClearMoveQueue)

				self.wsMap = self:NewMap(arg_153_1)

				self.wsMap:Load(function()
					self.wsMap.transform:SetParent(self.rtDragLayer, false)
					setActive(self.wsMap.transform, true)
					self:InitMap()

					return existCall(arg_153_2)
				end)
			end)
		end
	end)
end

function WorldScene:InitMap()
	for iter_158_0, iter_158_1 in ipairs(self.wsMap.wsMapFleets) do
		onButton(self, iter_158_1.rtRetreat, function()
			self:Op("OpReqRetreat", iter_158_1.fleet)
		end, SFX_PANEL)
		iter_158_1:AddListener(WSMapFleet.EventUpdateSelected, self.onFleetSelected)
	end

	self.wsMap:AddListener(WSMap.EventUpdateEventTips, self.onUpdateEventTips)

	local var_158_0 = nowWorld()

	var_158_0:AddListener(World.EventUpdateSubmarineSupport, self.onUpdateSubmarineSupport)
	var_158_0:AddListener(World.EventAchieved, self.onAchievementAchieved)
	self.wsDragProxy:UpdateMap(self.wsMap.map)
	self.wsDragProxy:Focus(self.wsMap:GetFleet().transform.position)
	self.wsMapCamera:UpdateMap(self.wsMap.map)
	self:OnUpdateSubmarineSupport()
end

function WorldScene:NewMap(arg_160_1)
	local var_160_0 = WSMap.New()

	var_160_0.wsPool = self.wsPool
	var_160_0.wsTimer = self.wsTimer

	var_160_0:Setup(arg_160_1)

	self.rtGrid.localEulerAngles = Vector3(arg_160_1.theme.angle, 0, 0)

	return var_160_0
end

function WorldScene:DisposeMap()
	if self.wsMap then
		self.wsTimer:ClearInMapTimers()
		self.wsTimer:ClearInMapTweens()
		self:HideMap()

		local var_161_0 = nowWorld()

		var_161_0:RemoveListener(World.EventUpdateSubmarineSupport, self.onUpdateSubmarineSupport)
		var_161_0:RemoveListener(World.EventAchieved, self.onAchievementAchieved)
		self.wsMap.map:RemoveListener(WorldMap.EventUpdateActive, self.onDisposeMap)
		self.wsMap.map:RemoveListener(WorldMap.EventUpdateMoveSpeed, self.onClearMoveQueue)
		self.wsMap:Dispose()

		self.wsMap = nil
	end
end

function WorldScene:OnDisposeMap(arg_162_1, arg_162_2)
	if (arg_162_1 == WorldMap.EventUpdateActive or nil) and not arg_162_2.active then
		self:DisposeMap()
	end
end

function WorldScene:DisplayMapTop()
	self.wsMapTop = self.wsMapTop or self:NewMapTop(self.rtTopMap)

	setActive(self.rtTopMap, true)
end

function WorldScene:HideMapTop()
	setActive(self.rtTopMap, false)
end

function WorldScene:NewMapTop(arg_165_1)
	local var_165_0 = WSMapTop.New()

	var_165_0.transform = arg_165_1

	var_165_0:Setup()

	function var_165_0.cmdSkillFunc(arg_166_0)
		self:emit(WorldMediator.OnOpenLayer, Context.New({
			mediator = CommanderSkillMediator,
			viewComponent = CommanderSkillLayer,
			data = {
				isWorld = true,
				skill = arg_166_0
			}
		}))
	end

	function var_165_0.poisonFunc(arg_167_0)
		self:ShowSubView("PoisonPanel", {
			arg_167_0
		})
	end

	onButton(self, var_165_0.btnBack, function()
		self:Op("OpCall", function(arg_169_0)
			self:ExitWorld(arg_169_0)
		end)
	end, SFX_CANCEL)

	return var_165_0
end

function WorldScene:DisposeMapTop()
	if self.wsMapTop then
		self:HideMapTop()
		self.wsMapTop:Dispose()

		self.wsMapTop = nil
	end
end

function WorldScene:DisplayMapLeft()
	self.wsMapLeft = self.wsMapLeft or self:NewMapLeft(self.rtLeftMap)

	setActive(self.rtLeftMap, true)
end

function WorldScene:HideMapLeft()
	setActive(self.rtLeftMap, false)
end

function WorldScene:NewMapLeft(arg_173_1)
	local var_173_0 = WSMapLeft.New()

	var_173_0.transform = arg_173_1

	var_173_0:Setup()

	function var_173_0.onAgonyClick()
		local var_174_0 = {
			mediator = WorldInventoryMediator,
			viewComponent = WorldInventoryLayer
		}
		local var_174_1 = {}

		var_174_1.currentFleetIndex = nowWorld():GetActiveMap().findex
		var_174_0.data = var_174_1

		self:Op("OpOpenLayer", Context.New(var_174_0))
	end

	function var_173_0:onLongPress()
		self:Op("OpOpenScene", SCENE.SHIPINFO, {
			shipId = self.id,
			shipVOs = nowWorld():GetFleet(self.fleetId):GetShipVOs(true)
		})
	end

	function var_173_0.onClickSalvage(arg_176_0)
		self:Op("OpCall", function(arg_177_0)
			arg_177_0()
			self:ShowSubView("SalvageResult", {
				arg_176_0
			})
		end)
	end

	var_173_0:AddListener(WSMapLeft.EventSelectFleet, self.onSelectFleet)

	return var_173_0
end

function WorldScene:DisposeMapLeft()
	if self.wsMapLeft then
		self:HideMapLeft()
		self.wsMapLeft:RemoveListener(WSMapLeft.EventSelectFleet, self.onSelectFleet)
		self.wsMapLeft:Dispose()

		self.wsMapLeft = nil
	end
end

function WorldScene:DisplayMapRight()
	self.wsMapRight = self.wsMapRight or self:NewMapRight(self.rtRightMap)

	setActive(self.rtRightMap, true)
	self:UpdateAutoFightDisplay()
	self:UpdateAutoSwitchDisplay()
end

function WorldScene:HideMapRight()
	setActive(self.rtRightMap, false)
end

function WorldScene:HideMapRightCompass()
	return
end

function WorldScene:HideMapRightMemo()
	return
end

function WorldScene:NewMapRight(arg_183_1)
	local var_183_0 = WSMapRight.New()

	var_183_0.transform = arg_183_1
	var_183_0.wsPool = self.wsPool
	var_183_0.wsTimer = self.wsTimer

	var_183_0:Setup()
	var_183_0:OnUpdateInfoBtnTip()
	var_183_0:OnUpdateHelpBtnTip()
	onButton(self, var_183_0.btnOrder, function()
		self:Op("OpShowOrderPanel")
	end, SFX_PANEL)
	onButton(self, var_183_0.btnScan, function()
		self:Op("OpShowScannerPanel")
	end, SFX_PANEL)
	onButton(self, var_183_0.btnDefeat, function()
		var_183_0:OnUpdateHelpBtnTip(true)
		self:Op("OpOpenLayer", Context.New({
			mediator = WorldHelpMediator,
			viewComponent = WorldHelpLayer,
			data = {
				titleId = 4,
				pageId = 5
			}
		}))
	end, SFX_PANEL)
	onButton(self, var_183_0.btnDetail, function()
		local var_187_0 = {
			mediator = WorldDetailMediator,
			viewComponent = WorldDetailLayer
		}
		local var_187_1 = {}

		var_187_1.fleetId = nowWorld():GetActiveMap():GetFleet().id
		var_187_0.data = var_187_1

		self:Op("OpOpenLayer", Context.New(var_187_0))
	end, SFX_PANEL)
	onButton(self, var_183_0.btnInformation, function()
		local var_188_0 = {
			mediator = WorldInformationMediator,
			viewComponent = WorldInformationLayer
		}
		local var_188_1 = {}

		var_188_1.fleetId = nowWorld():GetActiveMap():GetFleet().id
		var_188_0.data = var_188_1

		self:Op("OpOpenLayer", Context.New(var_188_0))
	end, SFX_PANEL)
	onButton(self, var_183_0.btnInventory, function()
		local var_189_0 = {
			mediator = WorldInventoryMediator,
			viewComponent = WorldInventoryLayer
		}
		local var_189_1 = {}

		var_189_1.currentFleetIndex = nowWorld():GetActiveMap().findex
		var_189_0.data = var_189_1

		self:Op("OpOpenLayer", Context.New(var_189_0))
	end, SFX_PANEL)
	onButton(self, var_183_0.btnTransport, function()
		self:OnClickTransport()
	end, SFX_PANEL)
	onButton(self, var_183_0.btnPort, function()
		local var_191_0 = nowWorld()
		local var_191_1 = var_191_0:GetActiveMap()
		local var_191_2 = var_191_1:GetFleet()

		if var_191_1:GetCell(var_191_2.row, var_191_2.column).ExistEnemy(var_191_0) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("world_port_inbattle"))

			return
		end

		self:Op("OpReqEnterPort")
	end, SFX_PANEL)
	onButton(self, var_183_0.btnExit, function()
		local var_192_0 = nowWorld():GetActiveMap()
		local var_192_1 = {}

		if var_192_0:CheckFleetSalvage(true) then
			table.insert(var_192_1, function(arg_193_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("world_catsearch_leavemap"),
					onYes = arg_193_0
				})
			end)
		end

		seriesAsync(var_192_1, function()
			self:Op("OpReqJumpOut", var_192_0.gid)
		end)
	end, SFX_PANEL)
	onButton(self, var_183_0.btnHelp, function()
		var_183_0:OnUpdateHelpBtnTip(true)
		self:Op("OpOpenLayer", Context.New({
			mediator = WorldHelpMediator,
			viewComponent = WorldHelpLayer
		}))
	end, SFX_PANEL)
	onButton(self, var_183_0.toggleAutoFight:Find("off"), function()
		self:Op("OpCall", function(arg_197_0)
			arg_197_0()

			local var_197_0 = {}

			if PlayerPrefs.GetInt("first_auto_fight_mark", 0) == 0 then
				table.insert(var_197_0, function(arg_198_0)
					PlayerPrefs.SetInt("first_auto_fight_mark", 1)
					self:Op("OpOpenLayer", Context.New({
						mediator = WorldHelpMediator,
						viewComponent = WorldHelpLayer,
						data = {
							titleId = 2,
							pageId = 8
						},
						onRemoved = arg_198_0
					}))
				end)
			end

			local var_197_1 = nowWorld()

			if var_197_1:IsSystemOpen(WorldConst.SystemOrderSubmarine) and PlayerPrefs.GetInt("world_sub_auto_call", 0) == 1 then
				if var_197_1:GetActiveMap():GetConfig("instruction_available")[1] == 1 and var_197_1:CanCallSubmarineSupport() and not var_197_1:IsSubmarineSupporting() then
					local var_197_2 = var_197_1:CalcOrderCost(WorldConst.OpReqSub)

					if var_197_2 <= PlayerPrefs.GetInt("world_sub_call_line", 0) and var_197_2 <= var_197_1.staminaMgr:GetTotalStamina() then
						if var_197_2 > 0 then
							table.insert(var_197_0, function(arg_199_0)
								pg.MsgboxMgr.GetInstance():ShowMsgBox({
									content = i18n("world_instruction_submarine_2", setColorStr(var_197_2, COLOR_GREEN)),
									onYes = function()
										PlayerPrefs.SetInt("autoSubIsAcitve" .. AutoSubCommand.GetAutoSubMark(SYSTEM_WORLD), 1)
										self:Op("OpReqSub", arg_199_0)
									end,
									onNo = arg_199_0
								})
							end)
						else
							PlayerPrefs.SetInt("autoSubIsAcitve" .. AutoSubCommand.GetAutoSubMark(SYSTEM_WORLD), 1)
							table.insert(var_197_0, function(arg_201_0)
								self:Op("OpReqSub", arg_201_0)
							end)
						end
					end
				end
			end

			seriesAsync(var_197_0, function()
				pg.TipsMgr.GetInstance():ShowTips(i18n("autofight_tip_bigworld_begin"))
				getProxy(MetaCharacterProxy):setMetaTacticsInfoOnStart()
				PlayerPrefs.SetInt("world_skip_precombat", 1)
				PlayerPrefs.SetInt("autoBotIsAcitve" .. AutoBotCommand.GetAutoBotMark(SYSTEM_WORLD), 1)
				var_197_1:TriggerAutoFight(true)
				self:Op("OpInteractive")
			end)
		end)
	end, SFX_PANEL)
	onButton(self, var_183_0.toggleAutoFight:Find("on"), function()
		self:Op("OpCall", function(arg_204_0)
			arg_204_0()
			nowWorld():TriggerAutoFight(false)
			self:Op("OpInteractive")
		end)
	end, SFX_PANEL)
	onButton(self, var_183_0.toggleAutoSwitch:Find("off"), function()
		self:Op("OpOpenLayer", Context.New({
			mediator = WorldSwitchPlanningMediator,
			viewComponent = WorldSwitchPlanningLayer
		}))
	end, SFX_PANEL)
	onButton(self, var_183_0.toggleAutoSwitch:Find("on"), function()
		self:Op("OpCall", function(arg_207_0)
			arg_207_0()
			nowWorld():TriggerAutoFight(false)
			self:Op("OpInteractive")
		end)
	end, SFX_PANEL)

	return var_183_0
end

function WorldScene:DisposeMapRight()
	if self.wsMapRight then
		self:HideMapRight()
		self.wsMapRight:Dispose()

		self.wsMapRight = nil
	end
end

function WorldScene:DisplayMapOut()
	self.wsMapOut = self.wsMapOut or self:NewMapOut(self.rtOutMap)

	setActive(self.rtOutMap, true)
end

function WorldScene:HideMapOut()
	setActive(self.rtOutMap, false)
end

function WorldScene:NewMapOut(arg_211_1)
	local var_211_0 = WSMapOut.New()

	var_211_0.transform = arg_211_1

	var_211_0:Setup()

	return var_211_0
end

function WorldScene:DisposeMapOut()
	if self.wsMapOut then
		self:HideMapOut()
		self.wsMapOut:Dispose()

		self.wsMapOut = nil
	end
end

function WorldScene:OnUpdateProgress(arg_213_1, arg_213_2, arg_213_3, arg_213_4)
	self:UpdateSystemOpen()

	if self.wsMapRight then
		self.wsMapRight:OnUpdateHelpBtnTip()
	end
end

function WorldScene:OnUpdateScale(arg_214_1, arg_214_2, arg_214_3)
	if self.wsAtlas and not self.wsAtlasBottom:CheckIsTweening() then
		self.wsAtlas:UpdateScale(arg_214_3)
	end
end

function WorldScene:OnModelSelectMap(arg_215_1, arg_215_2, arg_215_3, arg_215_4, arg_215_5)
	if arg_215_3 then
		self:ShowSubView("FloatPanel", {
			arg_215_3,
			arg_215_4,
			arg_215_5,
			arg_215_2
		})
	else
		self:HideSubView("FloatPanel")
	end
end

function WorldScene:OnUpdateSubmarineSupport(arg_216_1)
	self.wsMap:UpdateSubmarineSupport()

	if self.wsMapLeft then
		self.wsMapLeft:OnUpdateSubmarineSupport()
	end
end

function WorldScene:OnUpdateDaily()
	if self.wsAtlasBottom then
		setActive(self.wsAtlasBottom.btnDailyTask:Find("tip"), nowWorld():GetTaskProxy():canAcceptDailyTask())
	end
end

function WorldScene:OnFleetSelected(arg_218_1, arg_218_2)
	if arg_218_2.selected then
		self.wsDragProxy:Focus(arg_218_2.transform.position, nil, LeanTweenType.easeInOutSine)
	end
end

function WorldScene:OnSelectFleet(arg_219_1, arg_219_2, arg_219_3)
	if arg_219_3 == nowWorld():GetActiveMap():GetFleet() then
		self:Op("OpMoveCamera", 0, 0.1)
	else
		self:Op("OpReqSwitchFleet", arg_219_3)
	end
end

function WorldScene:OnClickCell(arg_220_1, arg_220_2)
	local var_220_0 = nowWorld()
	local var_220_1 = var_220_0:GetActiveMap()
	local var_220_2 = var_220_1:GetFleet()
	local var_220_3 = var_220_1:GetCell(arg_220_1, arg_220_2)
	local var_220_4 = var_220_1:FindFleet(var_220_0.row, var_220_3.column)

	if var_220_4 and var_220_4 ~= var_220_2 then
		self:Op("OpReqSwitchFleet", var_220_4)
	elseif var_220_1:CheckInteractive() then
		self:Op("OpInteractive", true)
	elseif var_220_1:IsSign(arg_220_1, arg_220_2) and ManhattonDist({
		row = var_220_2.row,
		column = var_220_2.column
	}, {
		row = var_220_3.row,
		column = var_220_3.column
	}) <= 1 then
		self:Op("OpTriggerSign", var_220_2, var_220_3:GetEventAttachment(), function()
			self:Op("OpInteractive")
		end)
	elseif var_220_1:CanLongMove(var_220_2) then
		self:Op("OpLongMoveFleet", var_220_2, var_220_3.row, var_220_3.column)
	else
		self:Op("OpReqMoveFleet", var_220_2, var_220_3.row, var_220_3.column)
	end
end

function WorldScene:OnClickTransport()
	if self.svScannerPanel:isShowing() then
		return
	end

	self:Op("OpCall", function(arg_223_0)
		arg_223_0()
		self:QueryTransport(function()
			self:EnterTransportWorld()
		end)
	end)
end

function WorldScene:QueryTransport(arg_225_1)
	local var_225_0 = nowWorld()
	local var_225_1 = var_225_0:GetActiveMap()
	local var_225_2 = {}

	if not var_225_0:IsSystemOpen(WorldConst.SystemOutMap) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("word_systemClose"))

		return
	end

	if var_225_1:CheckAttachmentTransport() == "story" then
		local var_225_3 = pg.gameset.world_transfer_eventstory.description[1]

		table.insert(var_225_2, function(arg_226_0)
			self:OpRaw("OpStory", var_225_3, true, true, false, function(arg_227_0)
				if arg_227_0 == 1 then
					arg_226_0()
				end
			end)
		end)
	end

	if var_225_0:IsSubmarineSupporting() then
		if var_225_1:GetSubmarineFleet():GetAmmo() > 0 then
			table.insert(var_225_2, function(arg_228_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("world_instruction_submarine_6"),
					onYes = arg_228_0
				})
			end)
		end
	end

	if var_225_1:CheckFleetSalvage(true) then
		table.insert(var_225_2, function(arg_229_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("world_catsearch_leavemap"),
				onYes = arg_229_0
			})
		end)
	end

	local var_225_4

	for iter_225_0, iter_225_1 in ipairs(var_225_1:GetNormalFleets()) do
		for iter_225_2, iter_225_3 in ipairs(iter_225_1:GetCarries()) do
			if iter_225_3.config.out_story ~= "" then
				var_225_4 = iter_225_3.config.out_story
			end
		end
	end

	if var_225_4 then
		table.insert(var_225_2, function(arg_230_0)
			self:OpRaw("OpStory", var_225_4, true, true, false, function(arg_231_0)
				if arg_231_0 == 1 then
					arg_230_0()
				end
			end)
		end)
	end

	local var_225_5, var_225_6 = var_225_1:CkeckTransport()

	if not var_225_5 then
		table.insert(var_225_2, function(arg_232_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = var_225_6,
				onYes = arg_232_0
			})
		end)
	end

	seriesAsync(var_225_2, function()
		return arg_225_1(var_225_5)
	end)
end

function WorldScene:OnUpdateEventTips(arg_234_1, arg_234_2)
	if self.wsMapRight then
		self.wsMapRight:OnUpdateEventTips()
	end

	if self.wsMapTop then
		self.wsMapTop:OnUpdatePoison()
	end
end

function WorldScene:OnClickMap(arg_235_1, arg_235_2)
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_PANEL)

	if arg_235_1 < self.wsMap.map.top or self.wsMap.map.bottom < arg_235_1 or arg_235_2 < self.wsMap.map.left or self.wsMap.map.right < arg_235_2 then
		self:OnClickTransport()
	else
		self:OnClickCell(arg_235_1, arg_235_2)
	end
end

function WorldScene:CheckScannerEnable(arg_236_1, arg_236_2)
	if nowWorld():IsSystemOpen(WorldConst.SystemScanner) then
		local var_236_0 = self.wsMap.map:GetCell(arg_236_1, arg_236_2)

		if var_236_0 and var_236_0:GetInFOV() and not var_236_0:InFog() then
			local var_236_1 = var_236_0:GetScannerAttachment()

			if var_236_1 then
				return var_236_1, self.camera:WorldToScreenPoint(self.wsMap:GetCell(arg_236_1, arg_236_2).rtAttachments.position)
			end
		end
	end
end

function WorldScene:OnLongPressMap(arg_237_1, arg_237_2)
	if not self.svScannerPanel:isShowing() then
		local var_237_0, var_237_1 = self:CheckScannerEnable(arg_237_1, arg_237_2)

		if var_237_0 then
			self:Op("OpShowScannerPanel", var_237_0, var_237_1)
		end
	end
end

function WorldScene:OnAchievementAchieved(arg_238_1, arg_238_2, arg_238_3, arg_238_4)
	if arg_238_3 then
		for iter_238_0, iter_238_1 in ipairs(arg_238_3) do
			pg.TipsMgr.GetInstance():ShowTips(iter_238_1)
		end
	end

	if arg_238_4 then
		local var_238_0 = nowWorld()

		if var_238_0.isAutoFight then
			var_238_0:AddAutoInfo("message", i18n("autofight_discovery", arg_238_4.config.target_desc))
		else
			table.insert(self.achievedList, {
				arg_238_4,
				self.wsMapRight.btnInformation.position
			})
		end
	end
end

function WorldScene:DoAnim(arg_239_1, arg_239_2)
	self:downloadWorldResList(self:getUIAnimResList(arg_239_1), function()
		if not self.wsAnim:GetAnim(arg_239_1) then
			self.wsAnim:SetAnim(arg_239_1, self:NewUIAnim(arg_239_1))
		end

		self.wsAnim:GetAnim(arg_239_1):Play(arg_239_2)
	end)
end

function WorldScene:NewUIAnim(arg_241_1)
	local var_241_0 = UIAnim.New()

	var_241_0:Setup(arg_241_1)
	var_241_0:AddListener(UIAnim.EventLoaded, function()
		var_241_0.transform:SetParent(self.rtTop, false)
	end)
	var_241_0:Load()

	return var_241_0
end

function WorldScene:DoStrikeAnim(arg_243_1, arg_243_2, arg_243_3)
	self:downloadWorldResList(self:getStrikeAnimResList(arg_243_1, arg_243_2), function()
		local var_244_0 = self.wsAnim

		if not self.wsAnim:GetAnim(arg_243_1) then
			var_244_0:SetAnim(arg_243_1, self:NewStrikeAnim(arg_243_1, arg_243_2))
		else
			var_244_0:GetAnim(arg_243_1):ReloadShip(arg_243_2)
		end

		var_244_0:GetAnim(arg_243_1):Play(arg_243_3)
	end)
end

function WorldScene:NewStrikeAnim(arg_245_1, arg_245_2)
	local var_245_0 = UIStrikeAnim.New()

	var_245_0:Setup(arg_245_1, arg_245_2)
	var_245_0:AddListener(UIStrikeAnim.EventLoaded, function()
		var_245_0.transform:SetParent(self.rtTop, false)
	end)
	var_245_0:Load()

	return var_245_0
end

function WorldScene:StopAnim()
	self.wsAnim:Stop()
end

function WorldScene:UpdateSystemOpen()
	local var_248_0 = nowWorld()

	if self:GetInMap() then
		self.wsMapLeft.onAgonyClickEnabled = var_248_0:IsSystemOpen(WorldConst.SystemInventory)

		setActive(self.wsMapRight.btnInventory, var_248_0:IsSystemOpen(WorldConst.SystemInventory))
		setActive(self.wsMapRight.btnTransport, var_248_0:IsSystemOpen(WorldConst.SystemOutMap))
		setActive(self.wsMapRight.btnDetail, var_248_0:IsSystemOpen(WorldConst.SystemFleetDetail))
		setActive(self.wsMapRight.rtCompassPanel, var_248_0:IsSystemOpen(WorldConst.SystemCompass))
		setActive(self.wsMapRight.toggleAutoFight, var_248_0:GetActiveMap():CanAutoFight())
		setActive(self.wsMapRight.toggleAutoSwitch, var_248_0:IsSystemOpen(WorldConst.SystemAutoSwitch))
	else
		setActive(self.wsAtlasBottom.btnBoss, var_248_0:IsSystemOpen(WorldConst.SystemWorldBoss))

		local var_248_1 = var_248_0:GetBossProxy()
		local var_248_2 = var_248_0:GetBossProxy()
		local var_248_3 = WorldBossConst.CanUnlockCurrBoss()
		local var_248_4 = not var_248_2:ExistSelfBoss() and not var_248_3

		setActive(self.wsAtlasBottom.btnBoss:Find("tip"), var_248_1:NeedTip() or var_248_3 or WorldBossConst.AnyArchivesBossCanGetAward())
		setActive(self.wsAtlasBottom.btnBoss:Find("sel"), not var_248_4)

		local var_248_5 = self.rtTopAtlas:Find("reset_coutdown")

		onButton(self, var_248_5, function()
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = i18n("world_reset_tip")
			})
		end, SFX_PANEL)

		local var_248_6 = var_248_0:IsSystemOpen(WorldConst.SystemResetCountDown) and var_248_0:CheckResetProgress()

		setActive(var_248_5, var_248_6)

		if var_248_6 then
			local var_248_7 = math.floor(var_248_0:GetResetWaitingTime() / 86400)

			if var_248_7 > 0 then
				setText(var_248_5:Find("Text"), i18n("world_reset_1", string.format("  %d  ", var_248_7)))
			elseif var_248_7 == 0 then
				setText(var_248_5:Find("Text"), i18n("world_reset_2", string.format("  %d  ", 0)))
			elseif var_248_7 < 0 then
				setText(var_248_5:Find("Text"), i18n("world_reset_3"))
			end
		end

		setActive(self.wsAtlasBottom.btnShop, var_248_0:IsSystemOpen(WorldConst.SystemResetShop))
		setActive(self.wsAtlasBottom.btnDailyTask:Find("mask"), not var_248_0:IsSystemOpen(WorldConst.SystemDailyTask))
		setActive(self.wsAtlasRight.btnSwitch, var_248_0:IsSystemOpen(WorldConst.SystemAutoSwitch))
		setActive(self.wsAtlasRight.btnDelegate, var_248_0:IsSystemOpen(WorldConst.SystemAutoSwitch))
	end

	setActive(self.resAtlas._tf, var_248_0:IsSystemOpen(WorldConst.SystemResource))
	setActive(self.resMap._tf, var_248_0:IsSystemOpen(WorldConst.SystemResource))
end

function WorldScene:EnterToModelMap(arg_250_1)
	local var_250_0 = {}

	table.insert(var_250_0, function(arg_251_0)
		setActive(self.rtTopAtlas:Find("print/title_world"), true)
		setActive(self.rtTopAtlas:Find("print/title_view"), false)
		self.wsAtlasBottom:UpdateScale(1, true, arg_251_0)
	end)
	table.insert(var_250_0, function(arg_252_0)
		self.wsAtlas:SwitchArea(arg_250_1, true, arg_252_0)
	end)
	parallelAsync(var_250_0, function()
		local var_253_0 = nowWorld():GetAtlas():GetActiveEntrance()

		if arg_250_1 == var_253_0:GetAreaId() then
			self.wsAtlas:UpdateSelect(var_253_0)
		end
	end)
end

function WorldScene:ReturnToModelArea()
	self.wsAtlas:UpdateSelect()

	local var_254_0 = {}

	table.insert(var_254_0, function(arg_255_0)
		setActive(self.rtTopAtlas:Find("print/title_world"), false)
		setActive(self.rtTopAtlas:Find("print/title_view"), true)
		self.wsAtlasBottom:UpdateScale(0, true, arg_255_0)
	end)
	table.insert(var_254_0, function(arg_256_0)
		self.wsAtlas:SwitchArea(nil, true, arg_256_0)
	end)
	parallelAsync(var_254_0, function()
		return
	end)
end

function WorldScene:EnterTransportWorld(arg_258_1)
	local var_258_0 = nowWorld()

	arg_258_1 = arg_258_1 or {
		entrance = var_258_0:GetActiveEntrance()
	}

	local var_258_1 = {}

	if self:GetInMap() then
		table.insert(var_258_1, function(arg_259_0)
			self:Op("OpSetInMap", false, arg_259_0)
		end)
	elseif not self.wsAtlas.nowArea then
		table.insert(var_258_1, function(arg_260_0)
			self.wsAtlas:SwitchArea(arg_258_1.entrance:GetAreaId(), false, arg_260_0)
		end)
	end

	seriesAsync(var_258_1, function()
		self.wsAtlas:UpdateSelect()
		self.wsAtlas:UpdateSelect(arg_258_1.entrance, arg_258_1.mapId, arg_258_1.mapTypes)
		self.wsAtlas:DisplayTransport(self.contextData.displayTransDic or {}, function()
			self.contextData.displayTransDic = Clone(var_258_0:GetAtlas().transportDic)
		end)
	end)
end

function WorldScene:BackToMap()
	if self.wsAtlas:CheckIsTweening() then
		return
	end

	self:Op("OpSetInMap", true)
end

function WorldScene:DisplayEnv(arg_264_1)
	local var_264_0 = checkExist(nowWorld():GetActiveMap(), {
		"config"
	}, {
		"map_bg"
	}, {
		1
	}) or "model_bg"
	local var_264_1 = {}

	if self.rtEnvBG:GetComponent(typeof(Image)).sprite.name ~= var_264_0 then
		table.insert(var_264_1, function(arg_265_0)
			self:downloadWorldResList({
				"world/map/" .. var_264_0
			}, arg_265_0)
		end)
		table.insert(var_264_1, function(arg_266_0)
			GetSpriteFromAtlasAsync("world/map/" .. var_264_0, var_264_0, function(arg_267_0)
				setImageSprite(self.rtEnvBG, arg_267_0)

				return arg_266_0()
			end)
		end)
	end

	seriesAsync(var_264_1, arg_264_1)
end

function WorldScene:ScreenPos2MapPos(arg_268_1)
	local var_268_0 = self.camera:ScreenPointToRay(arg_268_1)
	local var_268_1, var_268_2 = Plane.New(self.wsMap.rtQuads.forward, -Vector3.Dot(self.wsMap.rtQuads.position, self.wsMap.rtQuads.forward)):Raycast(var_268_0)

	if var_268_1 then
		local var_268_3 = self.wsMap.rtQuads:InverseTransformPoint((var_268_0:GetPoint(var_268_2)))

		return self.wsMap.map.theme:Y2Row(var_268_3.y), (self.wsMap.map.theme:X2Column(var_268_3.x))
	end
end

function WorldScene:BuildCutInAnim(arg_269_1, arg_269_2)
	self.tfAnim = self.rtPanelList:Find(arg_269_1 .. "(Clone)")

	local var_269_0 = {}

	if not self.tfAnim then
		table.insert(var_269_0, function(arg_270_0)
			self:downloadWorldResList({
				"ui/" .. arg_269_1
			}, arg_270_0)
		end)
		table.insert(var_269_0, function(arg_271_0)
			PoolMgr.GetInstance():GetUI(arg_269_1, true, function(arg_272_0)
				arg_272_0:SetActive(false)

				self.tfAnim = tf(arg_272_0)

				self.tfAnim:SetParent(self.rtPanelList, false)

				return arg_271_0()
			end)
		end)
	end

	table.insert(var_269_0, function(arg_273_0)
		self.inCutIn = true

		self.tfAnim:GetComponent("DftAniEvent"):SetEndEvent(function(arg_274_0)
			if not IsNil(self.tfAnim) then
				self.inCutIn = false

				self:UnOverlayPanel(self.tfAnim, self.rtPanelList)
				setActive(self.tfAnim, false)

				return arg_273_0()
			end
		end)
		self:OverlayPanel(self.tfAnim)
		setActive(self.tfAnim, true)
	end)
	seriesAsync(var_269_0, function()
		return existCall(arg_269_2)
	end)
end

function WorldScene:PlaySound(arg_276_1, arg_276_2)
	if self.cueName then
		pg.CriMgr.GetInstance():StopSE_V3()

		self.cueName = nil
	end

	pg.CriMgr.GetInstance():PlaySE_V3(arg_276_1, function()
		self.cueName = nil
	end)

	return existCall(arg_276_2)
end

function WorldScene:ChangeTopRaycasts(arg_278_1)
	GetOrAddComponent(self.rtTop, typeof(CanvasGroup)).blocksRaycasts = tobool(arg_278_1)
end

function WorldScene:DoTopBlock(arg_279_1)
	self:ChangeTopRaycasts(false)

	return function(...)
		self:ChangeTopRaycasts(true)

		return existCall(arg_279_1, ...)
	end
end

function WorldScene:SetMoveQueue(arg_281_1)
	self:ReContinueMoveQueue()

	self.moveQueue = arg_281_1
end

function WorldScene:ClearMoveQueue()
	self:DisplayMoveStopClick(false)

	self.moveQueueInteractive = true

	if #self.moveQueue > 0 then
		self.moveQueue = {}
	end

	self:ShowFleetMoveTurn(false)
end

function WorldScene:DoQueueMove(arg_283_1)
	assert(#self.moveQueue > 0, "without move queue")
	self:DisplayMoveStopClick(true)

	local var_283_0 = nowWorld():GetActiveMap()
	local var_283_1 = _.detect(self.moveQueue, function(arg_284_0)
		return arg_284_0.stay
	end)

	if #self.moveQueue == 1 and var_283_0:IsSign(var_283_1.row, var_283_1.column) then
		self:ClearMoveQueue()
		self:Op("OpTriggerSign", arg_283_1, var_283_0:GetCell(var_283_1.row, var_283_1.column):GetEventAttachment(), function()
			self:Op("OpInteractive")
		end)
	else
		self:ReContinueMoveQueue()
		self:ShowFleetMoveTurn(true)
		self:Op("OpReqMoveFleet", arg_283_1, var_283_1.row, var_283_1.column)
	end
end

function WorldScene:CheckMoveQueue(arg_286_1)
	if #self.moveQueue < #arg_286_1 or #arg_286_1 == 0 then
		self:ClearMoveQueue()
	elseif self.moveQueue[#arg_286_1].row ~= arg_286_1[#arg_286_1].row or self.moveQueue[#arg_286_1].column ~= arg_286_1[#arg_286_1].column then
		self:ClearMoveQueue()
	else
		for iter_286_0 = 1, #arg_286_1 do
			table.remove(self.moveQueue, 1)
		end

		if #self.moveQueue == 0 then
			self:ResetLostMoveQueueCount()

			self.moveQueueInteractive = true
		end
	end
end

function WorldScene:InteractiveMoveQueue()
	if self.moveQueueInteractive then
		self:ClearMoveQueue()
	else
		self:DisplayMoveStopClick(false)

		self.moveQueueInteractive = true
	end
end

function WorldScene:ReContinueMoveQueue()
	self.moveQueueInteractive = false
end

function WorldScene:CheckLostMoveQueueCount()
	self.lostMoveQueueCount = defaultValue(self.lostMoveQueueCount, 0) + 1

	return self.lostMoveQueueCount > WorldConst.AutoFightLoopCountLimit
end

function WorldScene:ResetLostMoveQueueCount(arg_290_1)
	if arg_290_1 then
		self.inLoopAutoFight = true
	end

	self.lostMoveQueueCount = 0
end

function WorldScene:DisplayMoveStopClick(arg_291_1)
	setActive(self.rtClickStop, arg_291_1)

	if arg_291_1 then
		local var_291_0 = nowWorld().isAutoFight

		setActive(self.rtClickStop:Find("long_move"), not var_291_0)
		setActive(self.rtClickStop:Find("auto_fight"), var_291_0)
	end
end

function WorldScene:ShowFleetMoveTurn(arg_292_1)
	if self.wsMap then
		if arg_292_1 then
			self.wsMap:GetFleet():PlusMoveTurn()
		else
			self.wsMap:GetFleet():ClearMoveTurn()
		end
	end
end

function WorldScene:GetAllPessingAward(arg_293_1)
	local var_293_0 = nowWorld()
	local var_293_1 = var_293_0:GetAtlas()
	local var_293_2 = {}

	for iter_293_0, iter_293_1 in pairs(var_293_0.pressingAwardDic) do
		if iter_293_1.flag then
			var_293_0:FlagMapPressingAward(iter_293_0)
			var_293_1:MarkMapTransport(iter_293_0)

			if #pg.world_event_complete[iter_293_1.id].event_reward_slgbuff > 0 then
				var_293_2[pg.world_event_complete[iter_293_1.id].event_reward_slgbuff[1]] = defaultValue(var_293_2[pg.world_event_complete[iter_293_1.id].event_reward_slgbuff[1]], 0) + pg.world_event_complete[iter_293_1.id].event_reward_slgbuff[2]
			end
		end
	end

	local var_293_3 = var_293_0:GetActiveMap()

	if not var_293_3.visionFlag and var_293_0:IsMapVisioned(var_293_3.id) then
		var_293_3:UpdateVisionFlag(true)
	end

	if self.wsAtlas then
		self.wsAtlas:OnUpdatePressingAward()
	end

	local var_293_4 = {}

	for iter_293_2, iter_293_3 in pairs(var_293_2) do
		table.insert(var_293_4, function(arg_294_0)
			local var_294_0 = {
				id = iter_293_2,
				floor = iter_293_3
			}

			var_294_0.before = var_293_0:GetGlobalBuff(iter_293_2):GetFloor()

			self:ShowSubView("GlobalBuff", {
				var_294_0,
				arg_294_0
			})
		end)
		table.insert(var_293_4, function(arg_295_0)
			var_293_0:AddGlobalBuff(iter_293_2, iter_293_3)
			arg_295_0()
		end)
	end

	seriesAsync(var_293_4, function()
		return existCall(arg_293_1)
	end)
end

function WorldScene:GetDelegatedAwards(arg_297_1, arg_297_2, arg_297_3, arg_297_4)
	local var_297_0 = nowWorld()
	local var_297_1 = var_297_0:GetAtlas()
	local var_297_2 = {}

	for iter_297_0, iter_297_1 in ipairs(arg_297_1) do
		if var_297_0.pressingAwardDic[iter_297_1].flag then
			var_297_0:FlagMapPressingAward(iter_297_1)
			var_297_1:MarkMapTransport(iter_297_1)

			if #pg.world_event_complete[var_297_0.pressingAwardDic[iter_297_1].id].event_reward_slgbuff > 0 then
				var_297_2[pg.world_event_complete[var_297_0.pressingAwardDic[iter_297_1].id].event_reward_slgbuff[1]] = defaultValue(var_297_2[pg.world_event_complete[var_297_0.pressingAwardDic[iter_297_1].id].event_reward_slgbuff[1]], 0) + pg.world_event_complete[var_297_0.pressingAwardDic[iter_297_1].id].event_reward_slgbuff[2]
			end
		end
	end

	if self.wsAtlas then
		self.wsAtlas:OnUpdatePressingAward()
	end

	local var_297_3 = {}
	local var_297_4 = {}

	for iter_297_2, iter_297_3 in pairs(var_297_2) do
		table.insert(var_297_3, function(arg_298_0)
			local var_298_0 = {
				id = iter_297_2,
				floor = iter_297_3
			}

			var_298_0.before = var_297_0:GetGlobalBuff(iter_297_2):GetFloor()

			table.insert(var_297_4, var_298_0)
			self:ShowSubView("GlobalBuff", {
				var_298_0,
				arg_298_0
			})
		end)
		table.insert(var_297_3, function(arg_299_0)
			var_297_0:AddGlobalBuff(iter_297_2, iter_297_3)
			arg_299_0()
		end)
	end

	if #arg_297_2 > 0 then
		table.insert(var_297_3, function(arg_300_0)
			self:Op("OpOpenLayer", Context.New({
				viewComponent = WorldChapterAutoRewardLayer,
				mediator = WorldChapterAutoRewardMediator,
				data = {
					awards = arg_297_2,
					buffInfos = var_297_4,
					proficiency = arg_297_3,
					onClose = arg_300_0
				}
			}))
		end)
	end

	seriesAsync(var_297_3, arg_297_4)
end

function WorldScene:CheckGuideSLG(arg_301_1, arg_301_2)
	local var_301_0 = nowWorld()
	local var_301_1 = {}

	table.insert(var_301_1, {
		"WorldG007",
		function()
			local var_302_0 = arg_301_1:GetPort()

			if var_302_0 and not var_302_0:IsTempPort() then
				local var_302_1 = arg_301_1:GetFleet()

				return not arg_301_1:GetCell(var_302_1.row, var_302_1.column):ExistEnemy()
			end
		end
	})
	table.insert(var_301_1, {
		"WorldG111",
		function()
			return arg_301_1:canExit()
		end
	})
	table.insert(var_301_1, {
		"WorldG112",
		function()
			local var_304_0 = var_301_0:GetActiveEntrance()

			return var_304_0.becomeSairen and var_304_0:GetSairenMapId() == arg_301_1.id
		end
	})
	table.insert(var_301_1, {
		"WorldG124",
		function()
			return var_301_0:IsSystemOpen(WorldConst.SystemOrderSubmarine) and arg_301_1:GetConfig("instruction_available")[1] ~= 0 and var_301_0:CanCallSubmarineSupport()
		end
	})
	table.insert(var_301_1, {
		"WorldG162",
		function()
			return _.any(arg_301_1:GetNormalFleets(), function(arg_307_0)
				return _.any(arg_307_0:GetShips(true), function(arg_308_0)
					return arg_308_0:IsBroken()
				end)
			end)
		end
	})
	table.insert(var_301_1, {
		"WorldG163",
		function()
			return underscore.any(var_301_0:GetTaskProxy():getDoingTaskVOs(), function(arg_310_0)
				return not arg_310_0:IsAutoSubmit() and arg_310_0:isFinished()
			end)
		end
	})
	table.insert(var_301_1, {
		"WorldG164",
		function()
			return arg_301_1:CheckFleetSalvage(true)
		end
	})
	table.insert(var_301_1, {
		"WorldG181",
		function()
			return var_301_0:GetInventoryProxy():GetItemCount(102) > 0
		end
	})
	table.insert(var_301_1, {
		"WorldG191",
		function()
			local var_313_0 = WorldBossConst.CanUnlockCurrBoss()

			var_313_0 = var_313_0 and nowWorld():IsSystemOpen(WorldConst.SystemWorldBoss)

			return var_313_0
		end
	})

	local var_301_2 = _.filter(arg_301_1:FindAttachments(WorldMapAttachment.TypeEvent), function(arg_314_0)
		return arg_314_0:IsAlive()
	end)

	for iter_301_0, iter_301_1 in ipairs(pg.gameset.world_guide_event.description) do
		table.insert(var_301_1, {
			iter_301_1[2],
			function()
				return _.any(var_301_2, function(arg_316_0)
					return arg_316_0.id == iter_301_1[1]
				end)
			end
		})
	end

	local var_301_3 = pg.NewStoryMgr.GetInstance()

	for iter_301_2, iter_301_3 in ipairs(var_301_1) do
		if not var_301_3:IsPlayed(iter_301_3[1]) and iter_301_3[2]() then
			WorldGuider.GetInstance():PlayGuide(iter_301_3[1])

			return true
		end
	end

	return false
end

function WorldScene:CheckEventForMsg(arg_317_1)
	local var_317_0 = pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "EventMediator")

	var_317_0 = var_317_0 and getProxy(EventProxy).eventForMsg

	return var_317_0
end

function WorldScene:OpenPortLayer(arg_318_1)
	self:Op("OpOpenLayer", Context.New({
		mediator = WorldPortMediator,
		viewComponent = WorldPortLayer,
		data = arg_318_1
	}))
end

function WorldScene:ShowTransportMarkOverview(arg_319_1, arg_319_2)
	if nowWorld():GetActiveMap():CheckFleetSalvage(true) then
		self:Op("OpShowMarkOverview", arg_319_1, function()
			pg.NewStoryMgr.GetInstance():Play(pg.gameset.world_catsearch_special.description[1], arg_319_2, true)
		end)
	else
		self:Op("OpShowMarkOverview", arg_319_1, arg_319_2)
	end
end

function WorldScene:UpdateAutoFightDisplay()
	self:ClearMoveQueue()

	local var_321_0 = nowWorld().isAutoFight

	if self.wsMapRight then
		setActive(self.wsMapRight.toggleAutoFight:Find("off"), not var_321_0)
		setActive(self.wsMapRight.toggleAutoFight:Find("on"), var_321_0)
		setActive(self.wsMapRight.toggleSkipPrecombat, not var_321_0)
		triggerToggle(self.wsMapRight.toggleSkipPrecombat, PlayerPrefs.GetInt("world_skip_precombat", 0) == 1)
	end
end

function WorldScene:UpdateAutoSwitchDisplay()
	local var_322_0 = nowWorld().isAutoSwitch

	if self.wsMapRight then
		setActive(self.wsMapRight.toggleAutoSwitch:Find("off"), not var_322_0)
		setActive(self.wsMapRight.toggleAutoSwitch:Find("on"), var_322_0)
	end
end

function WorldScene:GuideShowScannerEvent(arg_323_1)
	assert(self.svScannerPanel:isShowing(), "scanner mode is closed")

	local var_323_0 = self.wsMap.map:FindAttachments(WorldMapAttachment.TypeEvent, arg_323_1)

	assert(#var_323_0 == 1, "event number error: " .. #var_323_0)

	local var_323_1, var_323_2 = self:CheckScannerEnable(var_323_0[1].row, var_323_0[1].column)

	assert(var_323_1, "without scanner attachment")
	self.svScannerPanel:ActionInvoke("DisplayWindow", var_323_1, var_323_2)
end

function WorldScene:DisplayAwards(arg_324_1, arg_324_2, arg_324_3)
	local var_324_0 = {}
	local var_324_1 = {}

	for iter_324_0, iter_324_1 in ipairs(arg_324_1) do
		if iter_324_1.type == DROP_TYPE_WORLD_COLLECTION then
			table.insert(var_324_1, iter_324_1)
		else
			table.insert(var_324_0, iter_324_1)
		end
	end

	seriesAsync({
		function(arg_325_0)
			if #var_324_0 == 0 then
				return arg_325_0()
			end

			arg_324_2.items = var_324_0
			arg_324_2.removeFunc = arg_325_0

			self:emit(BaseUI.ON_WORLD_ACHIEVE, arg_324_2)
		end,
		function(arg_326_0)
			local var_326_0 = var_324_1[1]

			if not var_324_1[1] then
				arg_326_0()

				return
			end

			assert(WorldCollectionProxy.GetCollectionType(var_326_0.id) == WorldCollectionProxy.WorldCollectionType.FILE, string.format("collection drop type error#%d", var_326_0.id))
			self:emit(WorldMediator.OnOpenLayer, Context.New({
				mediator = WorldMediaCollectionFilePreviewMediator,
				viewComponent = WorldMediaCollectionFilePreviewLayer,
				data = {
					collectionId = var_326_0.id
				},
				onRemoved = arg_326_0
			}))
		end
	}, arg_324_3)
end

function WorldScene:DisplayPhaseAction(arg_327_1)
	local var_327_0 = {}

	while #arg_327_1 > 0 do
		local var_327_1 = nowWorld()
		local var_327_2 = table.remove(arg_327_1, 1)

		table.insert(var_327_0, function(arg_328_0)
			if var_327_2.anim then
				self:BuildCutInAnim(var_327_2.anim, arg_328_0)
			elseif var_327_2.story then
				if var_327_1.isAutoFight then
					arg_328_0()
				else
					pg.NewStoryMgr.GetInstance():Play(var_327_2.story, arg_328_0, true)
				end
			elseif var_327_2.drops then
				if var_327_1.isAutoFight then
					var_327_1:AddAutoInfo("drops", var_327_2.drops)
					arg_328_0()
				else
					self:DisplayAwards(var_327_2.drops, {}, arg_328_0)
				end
			end
		end)
	end

	seriesAsync(var_327_0, function()
		self:Op("OpInteractive")
	end)
end

function WorldScene:StartAutoSwitch()
	local var_330_0 = nowWorld()
	local var_330_1 = var_330_0:GetActiveEntrance()
	local var_330_2 = var_330_0:GetActiveMap()

	if PlayerPrefs.GetInt("auto_switch_mode", 0) == WorldSwitchPlanningLayer.MODE_SAFE and PlayerPrefs.GetString("auto_switch_difficult_safe", "only") == "only" and World.ReplacementMapType(var_330_1, var_330_2) ~= "complete_chapter" then
		pg.TipsMgr.GetInstance():ShowTips(i18n("world_automode_start_tip3"))

		return
	elseif PlayerPrefs.GetInt("auto_switch_mode", 0) == WorldSwitchPlanningLayer.MODE_TREASURE and not var_330_0:GetGobalFlag("treasure_flag") then
		pg.TipsMgr.GetInstance():ShowTips("without auto switch flag")

		return
	end

	self:QueryTransport(function(arg_331_0)
		if not arg_331_0 then
			if PlayerPrefs.GetInt("auto_switch_mode", 0) == WorldSwitchPlanningLayer.MODE_TREASURE and World.ReplacementMapType(var_330_1, var_330_2) == "teasure_chapter" then
				pg.TipsMgr.GetInstance():ShowTips(i18n("world_automode_start_tip5"))
			else
				pg.TipsMgr.GetInstance():ShowTips(i18n("world_automode_start_tip4"))
			end
		else
			getProxy(MetaCharacterProxy):setMetaTacticsInfoOnStart()
			PlayerPrefs.SetInt("world_skip_precombat", 1)
			PlayerPrefs.SetInt("autoBotIsAcitve" .. AutoBotCommand.GetAutoBotMark(SYSTEM_WORLD), 1)
			self:Op("OpAutoSwitchMap")
		end
	end)
end

function WorldScene:MoveAndOpenLayer(arg_332_1)
	local var_332_0 = {}

	table.insert(var_332_0, function(arg_333_0)
		self:Op("OpSetInMap", arg_332_1.inMap, arg_333_0)
	end)
	seriesAsync(var_332_0, function()
		self:Op("OpOpenLayer", arg_332_1.context)
	end)
end

function WorldScene:GetDepth()
	return #self.wsCommands
end

function WorldScene:GetCommand(arg_336_1)
	return self.wsCommands[arg_336_1 or self:GetDepth()]
end

function WorldScene:Op(arg_337_1, ...)
	self:GetCommand():Op(arg_337_1, ...)
end

function WorldScene:OpRaw(arg_338_1, ...)
	self:GetCommand():OpRaw(arg_338_1, ...)
end

function WorldScene:OpOpen()
	local var_339_0 = self:GetDepth()

	WorldConst.Print("open operation stack: " .. var_339_0 + 1)
	table.insert(self.wsCommands, WSCommand.New(var_339_0 + 1))
end

function WorldScene:OpClose()
	local var_340_0 = self:GetDepth()

	assert(var_340_0 > 0)
	WorldConst.Print("close operation stack: " .. var_340_0)
	self.wsCommands[var_340_0]:Dispose()
	table.remove(self.wsCommands, var_340_0)
end

function WorldScene:OpClear()
	for iter_341_0, iter_341_1 in ipairs(self.wsCommands) do
		iter_341_1:OpClear()
	end
end

function WorldScene:OpDispose()
	for iter_342_0, iter_342_1 in ipairs(self.wsCommands) do
		iter_342_1:Dispose()
	end

	self.wsCommands = nil
end

function WorldScene:NewMapOp(arg_343_1)
	local var_343_0 = WBank:Fetch(WorldMapOp)

	var_343_0.depth = self:GetDepth()

	for iter_343_0, iter_343_1 in pairs(arg_343_1) do
		var_343_0[iter_343_0] = iter_343_1
	end

	return var_343_0
end

function WorldScene:RegistMapOp(arg_344_1)
	assert(arg_344_1, "mapOp can not be nil.")
	assert(not table.contains(self.mapOps, arg_344_1), "repeated registered mapOp.")
	table.insert(self.mapOps, arg_344_1)
	arg_344_1:AddCallbackWhenApplied(function()
		for iter_345_0 = #self.mapOps, 1, -1 do
			if self.mapOps[iter_345_0] == arg_344_1 then
				table.remove(self.mapOps, iter_345_0)
			end
		end
	end)
end

function WorldScene:VerifyMapOp()
	for iter_346_0 = #self.mapOps, 1, -1 do
		local var_346_0 = table.remove(self.mapOps, iter_346_0)

		if not var_346_0.applied then
			var_346_0:Apply()
		end
	end

	self:OpClear()
end

function WorldScene:GetCompassGridPos(arg_347_1, arg_347_2, arg_347_3)
	WorldGuider.GetInstance():SetTempGridPos(self.wsMapRight.wsCompass:GetMarkPosition(arg_347_1, arg_347_2), arg_347_3)
end

function WorldScene:GetEntranceTrackMark(arg_348_1, arg_348_2)
	WorldGuider.GetInstance():SetTempGridPos(self.wsMapRight.wsCompass:GetEntranceTrackMark(arg_348_1), arg_348_2)
end

function WorldScene:GetSlgTilePos(arg_349_1, arg_349_2, arg_349_3)
	WorldGuider.GetInstance():SetTempGridPos2(self.wsMap:GetCell(arg_349_1, arg_349_2):GetWorldPos(), arg_349_3)
end

function WorldScene:GetScannerPos(arg_350_1)
	WorldGuider.GetInstance():SetTempGridPos(self.svScannerPanel.rtPanel.transform:TransformPoint((Vector3.New(self.svScannerPanel.rtWindow.transform.localPosition.x + self.svScannerPanel.rtWindow.transform.rect.width * (0.5 - self.svScannerPanel.rtWindow.transform.pivot.x), self.svScannerPanel.rtWindow.transform.localPosition.y + self.svScannerPanel.rtWindow.transform.rect.height * (0.5 - self.svScannerPanel.rtWindow.transform.pivot.y), 0))), arg_350_1)
end

function WorldScene:GuideSelectModelMap(arg_351_1)
	assert(self.wsAtlas, "didn't enter the world map mode")
	self:ClickAtlas((nowWorld():GetEntrance(arg_351_1)))
end

return WorldScene
