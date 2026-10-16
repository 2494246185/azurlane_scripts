local DockyardScene = class("DockyardScene", import("..base.BaseUI"))

DockyardScene.MODE_OVERVIEW = "overview"
DockyardScene.MODE_DESTROY = "destroy"
DockyardScene.MODE_SELECT = "select"
DockyardScene.MODE_MOD = "modify"
DockyardScene.MODE_WORLD = "world"
DockyardScene.MODE_REMOULD = "remould"
DockyardScene.MODE_UPGRADE = "upgrade"
DockyardScene.MODE_GUILD_BOSS = "guildboss"
DockyardScene.MODE_SHIP_PHANTOM = "phantom"
DockyardScene.TITLE_CN_OVERVIEW = i18n("word_dockyard")
DockyardScene.TITLE_CN_UPGRADE = i18n("word_dockyardUpgrade")
DockyardScene.TITLE_CN_DESTROY = i18n("word_dockyardDestroy")
DockyardScene.TITLE_EN_OVERVIEW = "dockyard"
DockyardScene.TITLE_EN_UPGRADE = "modernization"
DockyardScene.TITLE_EN_DESTROY = "retirement"
DockyardScene.PRIOR_MODE_EQUIP_UP = 1
DockyardScene.PRIOR_MODE_SHIP_UP = 2

function DockyardScene:getUIName()
	return "DockyardUI"
end

function DockyardScene:getResource()
	local var_2_0 = {
		"ui/dockyardui_atlas",
		"energy",
		"shipstatus",
		"shipframe",
		"shiptype",
		"ui/proposeshipcard",
		"ui/heartshipcard",
		"shipYardIcon/unknown",
		"ui/iconcolorful",
		"ui/recordablesearchbarui"
	}

	table.insertto(var_2_0, self:getDockyardShipResList())

	return table.insertto(var_2_0, DockyardScene.super.getResource(self))
end

function DockyardScene:getDockyardShipResList()
	local var_3_0 = {}
	local var_3_1 = {}

	if self.contextData and self.contextData.shipVOs then
		for iter_3_0, iter_3_1 in ipairs(self.contextData.shipVOs) do
			var_3_1[iter_3_1.id] = iter_3_1
		end
	elseif self.contextData and self.contextData.mode == DockyardScene.MODE_WORLD then
		for iter_3_2, iter_3_3 in ipairs(nowWorld():GetShipVOs()) do
			var_3_1[iter_3_3.id] = iter_3_3
		end
	else
		for iter_3_4, iter_3_5 in pairs(getProxy(BayProxy).data) do
			var_3_1[iter_3_4] = iter_3_5
		end
	end

	if self.contextData and self.contextData.ignoredIds then
		for iter_3_6, iter_3_7 in ipairs(self.contextData.ignoredIds) do
			var_3_1[iter_3_7] = nil
		end
	end

	for iter_3_8, iter_3_9 in pairs(var_3_1) do
		self:insertDockyardShipItemRes(var_3_0, iter_3_9)
	end

	if self.contextData and self.contextData.mode == DockyardScene.MODE_SHIP_PHANTOM then
		local var_3_2 = getProxy(BayProxy)

		for iter_3_10, iter_3_11 in ipairs(getProxy(TechnologyProxy):getAllBluePrintShipIds()) do
			local var_3_3 = var_3_2:getShipById(iter_3_11)

			if var_3_3 and #var_3_3:getAllShipPhantomMarks() > 1 then
				_.each(var_3_3:getAllShipPhantom(), function(arg_4_0)
					table.insertto(var_3_0, (ResPathSupport.GetPaintingShipYardIconListByPaintingName(arg_4_0:getPainting())))
				end)
			end
		end
	end

	return var_3_0
end

function DockyardScene:insertDockyardShipItemRes(arg_5_1, arg_5_2)
	table.insert(arg_5_1, (string.format(ResPathSupport.ConstPath.BG.ShipCard, arg_5_2:rarity2bgPrint())))
	table.insertto(arg_5_1, (ResPathSupport.GetPaintingShipYardIconListByPaintingName(arg_5_2:getPainting())))

	local var_5_0, var_5_1 = arg_5_2:GetFrameAndEffect()

	table.insert(arg_5_1, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, var_5_1)))

	if arg_5_2.user then
		table.insertto(arg_5_1, (ResPathSupport.GetSpineQIconListByPrefabName((Ship.New({
			configId = arg_5_2.user.icon
		}):getPrefab()))))
		table.insert(arg_5_1, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.IconFrame, (AttireFrame.attireFrameRes(arg_5_2.user, false, AttireConst.TYPE_ICON_FRAME, arg_5_2.user.propose)))))
	end
end

function DockyardScene:init()
	self.contextData.mode = defaultValue(self.contextData.mode, DockyardScene.MODE_SELECT)
	self.contextData.otherSelectedIds = defaultValue(self.contextData.otherSelectedIds, {})
	self.teamTypeFilter = self.contextData.teamFilter
	self.selectedMin = self.contextData.selectedMin or 1
	self.leastLimitMsg = self.contextData.leastLimitMsg
	self.selectedMax = self.contextData.selectedMax or 0
	self.contextData.selectedIds = self.contextData.selectedIds or {}

	if self.contextData.infoShipId then
		table.insert(self.contextData.selectedIds, self.contextData.infoShipId)

		self.contextData.infoShipId = nil
	end

	self.selectedIds = underscore(self.contextData.selectedIds):chain():select(function(arg_7_0)
		return getProxy(BayProxy):RawGetShipById(arg_7_0) ~= nil
	end):first(self.selectedMax):value()
	self.contextData.selectedIds = nil
	self.checkShip = self.contextData.onShip or function(arg_8_0, arg_8_1, arg_8_2)
		return true
	end
	self.onCancelShip = self.contextData.onCancelShip or function(arg_9_0, arg_9_1, arg_9_2)
		return true
	end
	self.onClick = self.contextData.onClick or function(arg_10_0, arg_10_1, arg_10_2)
		self:emit(DockyardMediator.ON_SHIP_DETAIL, arg_10_0, arg_10_1, arg_10_2)
	end
	self.confirmSelect = self.contextData.confirmSelect
	self.callbackQuit = self.contextData.callbackQuit
	self.onSelected = self.contextData.onSelected or function(arg_11_0, arg_11_1)
		warning("not implemented.")
	end
	self.blurPanel = self._tf:Find("blur_panel")
	self.settingBtn = self.blurPanel:Find("adapt/left_length/frame/setting")
	self.settingPanel = DockyardQuickSelectSettingPage.New(self._tf, self.event)

	self.settingPanel:OnSettingChanged(function()
		self:unselecteAllShips()
	end)

	self.topPanel = self.blurPanel:Find("adapt/top")
	self.sortBtn = self.topPanel:Find("sort_button")
	self.sortImgAsc = self.sortBtn:Find("asc")
	self.sortImgDesc = self.sortBtn:Find("desc")
	self.leftTipsText = self.topPanel:Find("capacity")

	onButton(self, self.leftTipsText:Find("switch"), function()
		self.isCapacityMeta = not self.isCapacityMeta

		self:updateCapacityDisplay()
	end, SFX_PANEL)
	onButton(self, self.leftTipsText:Find("plus"), function()
		gotoChargeScene()
	end, SFX_PANEL)
	onButton(self, self.leftTipsText:Find("tip"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			hideNo = true,
			content = i18n("specialshipyard_tip")
		})
	end, SFX_PANEL)
	setActive(self.leftTipsText, false)

	self.indexBtn = self.topPanel:Find("index_button")
	self.switchPanel = self.topPanel:Find("switch")
	self.preferenceAndAttrContainer = self.switchPanel:Find("toggles")
	self.preferenceBtn = self.switchPanel:Find("toggles/preference_toggle")
	self.attrBtn = self.switchPanel:Find("toggles/attr_toggle")
	self.modLockFilter = self.topPanel:Find("mod_flter_lock")
	self.modLeveFilter = self.topPanel:Find("mod_flter_level")
	self.energyDescTF = self._tf:Find("energy_desc")
	self.energyDescTextTF = self.energyDescTF:Find("Text")
	self.selectPanel = self.blurPanel:Find("select_panel_adapt/select_panel")
	self.selectPanelBg = self.blurPanel:Find("select_panel_bg")
	self.bottomTipsText = self.selectPanel:Find("tip")
	self.bottomTipsWithFrame = self.selectPanel:Find("tipwithframe")

	setText(self.selectPanel:Find("bottom_info/bg_input/selected"), i18n("disassemble_selected") .. ":")

	self.awardTF = self.selectPanel:Find("bottom_info/bg_award")

	setText(self.awardTF:Find("label"), i18n("disassemble_available") .. ":")

	self.modAttrsTF = self.selectPanel:Find("bottom_info/bg_mod")
	self.viewEquipmentBtn = self.selectPanel:Find("view_equipments")
	self.tipPanel = self.blurPanel:Find("TipPanel")

	setActive(self.tipPanel, false)

	self.worldPanel = self.blurPanel:Find("world_port_panel")

	setActive(self.worldPanel, self.contextData.mode == DockyardScene.MODE_WORLD)

	self.assultBtn = self.blurPanel:Find("adapt/top/assult_btn")
	self.stampBtn = self.topPanel:Find("stamp")
	self.isRemouldOrUpgradeMode = self.contextData.mode == DockyardScene.MODE_REMOULD or self.contextData.mode == DockyardScene.MODE_UPGRADE

	setActive(self.modLeveFilter, self.isRemouldOrUpgradeMode)
	setActive(self.modLockFilter, self.isRemouldOrUpgradeMode)
	setActive(self.assultBtn, self.contextData.mode == DockyardScene.MODE_GUILD_BOSS)
	switch(self.contextData.mode, {
		[DockyardScene.MODE_OVERVIEW] = function()
			self.selecteEnabled = false
		end,
		[DockyardScene.MODE_DESTROY] = function()
			self.selecteEnabled = true
			self.blacklist = {}
			self.destroyResList = UIItemList.New(self.awardTF:Find("res_list"), self.awardTF:Find("res_list/res"))
		end,
		[DockyardScene.MODE_MOD] = function()
			self.selecteEnabled = true

			setText(self.modAttrsTF:Find("title/Text"), i18n("word_mod_value"))

			self.modAttrContainer = self.modAttrsTF:Find("attrs")
		end,
		[DockyardScene.MODE_SHIP_PHANTOM] = function()
			self.selecteEnabled = false
		end
	}, function()
		self.selecteEnabled = true
	end)

	local var_6_0 = self.selecteEnabled and self.contextData.mode ~= DockyardScene.MODE_WORLD

	setActive(self.selectPanel, var_6_0)
	setActive(self.selectPanelBg, var_6_0)
	setActive(self.worldPanel, self.contextData.mode == DockyardScene.MODE_WORLD)

	local var_6_1 = self.contextData.mode == DockyardScene.MODE_DESTROY

	setActive(self.settingBtn, self.contextData.mode == DockyardScene.MODE_DESTROY)
	setActive(self.selectPanel:Find("quick_select"), var_6_1)

	if self.contextData.priorEquipUpShipIDList and self.contextData.priorMode then
		setActive(self.tipPanel, true)

		local var_6_2 = self.tipPanel:Find("EquipUP")
		local var_6_3 = self.tipPanel:Find("ShipUP")

		setText(var_6_2, i18n("fightfail_choiceequip"))
		setText(var_6_3, i18n("fightfail_choicestrengthen"))
		setActive(var_6_2, self.contextData.priorMode == DockyardScene.PRIOR_MODE_EQUIP_UP)
		setActive(var_6_3, self.contextData.priorMode == DockyardScene.PRIOR_MODE_SHIP_UP)
	end

	self.togglePhantom = self._tf:Find("blur_panel/adapt/left_length/frame/toggle_phantom")

	onToggle(self, self.togglePhantom, function(arg_21_0)
		if self.inPhantom ~= arg_21_0 then
			self.inPhantom = arg_21_0

			self:SwitchContainerDisplay()
		end
	end, SFX_PANEL)
	setActive(self.togglePhantom, false)

	self.helpPhantom = self._tf:Find("blur_panel/adapt/left_length/frame/help_phantom")

	onButton(self, self.helpPhantom, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("projection_help")
		})
	end, SFX_PANEL)

	local var_6_4 = self.contextData.mode == DockyardScene.MODE_SHIP_PHANTOM and "phantom" or "dockyard"

	eachChild(self.topPanel:Find("titles"), function(arg_23_0, arg_23_1)
		setActive(arg_23_0, arg_23_0.name == var_6_4)
	end)

	self.listEmptyTF = self._tf:Find("empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")

	setText(self.listEmptyTxt, i18n("list_empty_tip_dockyardui"))

	self.destroyPage = ShipDestroyPage.New(self._tf, self.event)

	self.destroyPage:SetCardClickCallBack(function(arg_24_0)
		self.blacklist[arg_24_0.shipVO:getGroupId()] = true

		local var_24_0 = table.indexof(self.selectedIds, arg_24_0.shipVO.id)

		if var_24_0 and var_24_0 > 0 then
			table.remove(self.selectedIds, var_24_0)
		end

		self:updateDestroyRes()
		self:updateSelected()
	end)
	self.destroyPage:SetConfirmCallBack(function()
		local var_25_0 = {}
		local var_25_1, var_25_2 = self:checkDestroyGold()

		if not var_25_2 then
			table.insert(var_25_0, function(arg_26_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("oil_max_tip_title") .. i18n("resource_max_tip_retire_1"),
					onYes = arg_26_0
				})
			end)
		end

		local var_25_3 = underscore.map(self.selectedIds, function(arg_27_0)
			return self.shipVOsById[arg_27_0]
		end)

		table.insert(var_25_0, function(arg_28_0)
			self:checkDestroyShips(var_25_3, arg_28_0)
		end)
		seriesAsync(var_25_0, function()
			self:emit(DockyardMediator.ON_DESTROY_SHIPS, self.selectedIds)
		end)
	end)

	self.destroyConfirmWindow = ShipDestoryConfirmWindow.New(self._tf, self.event)
	self.searchBar = RecordableSearchBar.New(RecordableSearchBar.CreateData({
		refresh_pos_when_expand = true,
		holder = i18n("dockyard_search_holder"),
		onActive = function(arg_30_0)
			setActive(self.preferenceAndAttrContainer, not arg_30_0)
		end,
		onInputChanged = function()
			self:filter()
		end,
		key = self.__cname,
		parent = self.switchPanel,
		expand_parent = self.blurPanel:Find("adapt"),
		anchoredPosition = Vector3(-33, -33, 0)
	}))
end

function DockyardScene:SwitchContainerDisplay()
	self.isPhantomMode = self.contextData.mode == DockyardScene.MODE_SHIP_PHANTOM or self.inPhantom

	setActive(self.switchPanel, not self.isRemouldOrUpgradeMode and not self.isPhantomMode)
	setActive(self.indexBtn, not self.isRemouldOrUpgradeMode and not self.isPhantomMode)
	setActive(self.sortBtn, not self.isRemouldOrUpgradeMode and not self.isPhantomMode)
	setActive(self._tf:Find("main/ship_container"), not self.isPhantomMode)
	setActive(self._tf:Find("main/phantom_container"), self.isPhantomMode)
	setActive(self.preferenceBtn, not self.isPhantomMode)
	self:updateBarInfo()
	setActive(self.helpPhantom, self.contextData.mode == DockyardScene.MODE_SHIP_PHANTOM)

	if pg.SeriesGuideMgr.GetInstance():isEnd() and PlayerPrefs.GetInt("PHANTOM_HELP_FIRST", 0) == 0 then
		PlayerPrefs.SetInt("PHANTOM_HELP_FIRST", 1)
		triggerButton(self.helpPhantom)
	end

	switch(tobool(self.isPhantomMode), {
		[true] = function()
			self.initDic = self.initDic or {}

			if self.initDic.phantom then
				return
			end

			self.initDic.phantom = true

			local var_33_0 = self._tf:Find("main/phantom_container/title/content")

			UIItemList.StaticAlign(var_33_0, var_33_0:GetChild(0), getProxy(TechnologyProxy):getConfigMaxVersion() + 1, function(arg_34_0, arg_34_1, arg_34_2)
				if arg_34_0 == UIItemList.EventUpdate then
					arg_34_2.name = "phase_" .. arg_34_1

					GetImageSpriteFromAtlasAsync("ui/dockyardui_atlas", arg_34_1, arg_34_2:Find("on"))
					GetImageSpriteFromAtlasAsync("ui/dockyardui_atlas", arg_34_1, arg_34_2:Find("off"))
					onToggle(self, arg_34_2, function(arg_35_0)
						if arg_35_0 then
							self.selectVersion = arg_34_1
							self.filterBluePrint = underscore.filter(self.shipBluePrints, function(arg_36_0)
								return arg_34_1 == 0 or arg_36_0:getConfig("blueprint_version") == arg_34_1
							end)

							self.phantomContainer:SetTotalCount(#self.filterBluePrint, 0)
						end
					end, SFX_PANEL)
				end
			end)
			setActive(self._tf:Find("main/phantom_container/view/tpl"), false)

			self.phantomContainer = self._tf:Find("main/phantom_container/view/groups"):GetComponent("LScrollRect")
			self.phantomContainer.enabled = true
			self.phantomContainer.decelerationRate = 0.07

			function self.phantomContainer.onInitItem(arg_37_0)
				self:getOrInitPhantom(arg_37_0)
				ClearTweenItemAlphaAndWhite(arg_37_0)
			end

			function self.phantomContainer.onUpdateItem(arg_38_0, arg_38_1)
				self:updatePhantomGroup(self.filterBluePrint[arg_38_0 + 1], arg_38_1)
				TweenItemAlphaAndWhite(arg_38_1)
			end

			function self.phantomContainer.onReturnItem(arg_39_0, arg_39_1)
				if self.exited then
					return
				end

				self:getOrInitPhantom(arg_39_1):clear()
				ClearTweenItemAlphaAndWhite(arg_39_1)
			end

			self.scrollPhantoms = {}
			self.phantomGroupDic = {}

			local var_33_1 = 0

			if self.contextData.techVersion and #underscore.filter(self.shipBluePrints, function(arg_40_0)
				return self.contextData.techVersion == 0 or arg_40_0:getConfig("blueprint_version") == self.contextData.techVersion
			end) > 0 then
				var_33_1 = self.contextData.techVersion
			end

			self.contextData.techVersion = nil

			triggerToggle(self._tf:Find("main/phantom_container/title/content"):GetChild(var_33_1), true)
		end,
		[false] = function()
			self.initDic = self.initDic or {}

			if self.initDic.ship then
				return
			end

			self.initDic.ship = true
			self.shipContainer = self._tf:Find("main/ship_container/ships"):GetComponent("LScrollRect")
			self.shipContainer.enabled = true
			self.shipContainer.decelerationRate = 0.07

			function self.shipContainer.onInitItem(arg_42_0)
				self:onInitItem(arg_42_0)
			end

			function self.shipContainer.onUpdateItem(arg_43_0, arg_43_1)
				self:onUpdateItem(arg_43_0, arg_43_1)
			end

			function self.shipContainer.onReturnItem(arg_44_0, arg_44_1)
				self:onReturnItem(arg_44_0, arg_44_1)
			end

			function self.shipContainer.onStart()
				self:updateSelected()
			end

			self.shipLayout = self._tf:Find("main/ship_container/ships")
			self.scrollItems = {}
			self.cardItemDic = {}

			if _G[self.contextData.preView] then
				self.sortIndex = _G[self.contextData.preView].sortIndex or ShipIndexConst.SortLevel
				self.selectAsc = _G[self.contextData.preView].selectAsc or false
				self.typeIndex = _G[self.contextData.preView].typeIndex or ShipIndexConst.TypeAll
				self.campIndex = _G[self.contextData.preView].campIndex or ShipIndexConst.CampAll
				self.rarityIndex = _G[self.contextData.preView].rarityIndex or ShipIndexConst.RarityAll
				self.extraIndex = _G[self.contextData.preView].extraIndex or ShipIndexConst.ExtraAll
				self.commonTag = _G[self.contextData.preView].commonTag or Ship.PREFERENCE_TAG_NONE
			elseif self.contextData.sortData then
				self.sortIndex = self.contextData.sortData.sort or ShipIndexConst.SortLevel
				self.selectAsc = self.contextData.sortData.Asc or false
				self.typeIndex = self.contextData.sortData.typeIndex or ShipIndexConst.TypeAll
				self.campIndex = self.contextData.sortData.campIndex or ShipIndexConst.CampAll
				self.rarityIndex = self.contextData.sortData.rarityIndex or ShipIndexConst.RarityAll
				self.extraIndex = self.contextData.sortData.extraIndex or ShipIndexConst.ExtraAll
				self.commonTag = self.contextData.sortData.commonTag or Ship.PREFERENCE_TAG_NONE
			else
				if not DockyardScene.selectAsc then
					self.selectAsc = false
				end

				self.sortIndex = DockyardScene.sortIndex or ShipIndexConst.SortLevel
				self.typeIndex = DockyardScene.typeIndex or ShipIndexConst.TypeAll
				self.campIndex = DockyardScene.campIndex or ShipIndexConst.CampAll
				self.rarityIndex = DockyardScene.rarityIndex or ShipIndexConst.RarityAll
				self.extraIndex = DockyardScene.extraIndex or ShipIndexConst.ExtraAll
				self.commonTag = DockyardScene.commonTag or Ship.PREFERENCE_TAG_NONE
			end

			self:updateIndexDatas()
			triggerToggle(self.preferenceBtn, self.commonTag == Ship.PREFERENCE_TAG_COMMON)
			self:initIndexPanel()

			self.itemDetailType = -1

			if self.contextData.mode == DockyardScene.MODE_DESTROY then
				self.blacklist = {}
				self.selectPanel:GetComponent("HorizontalLayoutGroup").padding.right = 50

				setActive(self.selectPanel:Find("quick_select"), true)
				setActive(self.settingBtn, true)
			else
				self.selectPanel:GetComponent("HorizontalLayoutGroup").padding.right = 250

				setActive(self.selectPanel:Find("quick_select"), false)
				setActive(self.settingBtn, false)
			end

			if self.contextData.mode == DockyardScene.MODE_GUILD_BOSS then
				self.isShowAssultShips = false

				triggerToggle(self.assultBtn, true)

				self.guildShipEquipmentsPage = GuildShipEquipmentsPage.New(self._tf, self.event)

				self.guildShipEquipmentsPage:SetCallBack(function()
					self:TriggerCard(-1)
				end, function()
					self:TriggerCard(1)
				end)
			end

			eachChild(self.attrBtn, function(arg_48_0)
				setActive(arg_48_0, false)
			end)

			self.isFormTactics = self.contextData.prevPage == "NewNavalTacticsMediator"

			local var_41_1 = self.attrBtn:Find("off"):GetComponent("Image")
			local var_41_2 = self.attrBtn:Find("on"):GetComponent("Image")

			if self.isFormTactics then
				GetImageSpriteFromAtlasAsync("ui/dockyardui_atlas", "skill_off", var_41_1)
				GetImageSpriteFromAtlasAsync("ui/dockyardui_atlas", "skill_on", var_41_2)
			else
				GetImageSpriteFromAtlasAsync("ui/dockyardui_atlas", "attr_off", var_41_1)
				GetImageSpriteFromAtlasAsync("ui/dockyardui_atlas", "attr_on", var_41_2)
			end

			triggerButton(self.attrBtn)

			if self.isRemouldOrUpgradeMode then
				local var_41_3 = getProxy(SettingsProxy)

				self.isFilterLevelForMod = var_41_3:GetDockYardLevelBtnFlag()

				self:OnSwitch(self.modLeveFilter, self.isFilterLevelForMod, function(arg_49_0)
					self.isFilterLevelForMod = arg_49_0

					self:filter()
				end)

				self.isFilterLockForMod = var_41_3:GetDockYardLockBtnFlag()

				self:OnSwitch(self.modLockFilter, self.isFilterLockForMod, function(arg_50_0)
					self.isFilterLockForMod = arg_50_0

					self:filter()
				end)
			end

			local var_41_4 = self.shipContainer:GetComponentInChildren(typeof(GridLayoutGroup))

			if var_41_4.cellSize.x + var_41_4.spacing.x > 0 then
				var_41_4.constraintCount = math.max(7, math.floor((self._tf:Find("main/ship_container").rect.width - var_41_4.padding.left - var_41_4.padding.right + var_41_4.spacing.x) / (var_41_4.cellSize.x + var_41_4.spacing.x)) - 1)
			end

			self:filter()
		end
	})

	if self.isPhantomMode then
		setActive(self.listEmptyTF, #self.filterBluePrint == 0)
	else
		setActive(self.listEmptyTF, #self.shipVOs <= 0)
	end
end

function DockyardScene:isDefaultStatus()
	return self.sortIndex == ShipIndexConst.SortLevel and (not self.typeIndex or self.typeIndex == ShipIndexConst.TypeAll) and (not self.campIndex or self.campIndex == ShipIndexConst.CampAll) and (not self.rarityIndex or self.rarityIndex == ShipIndexConst.RarityAll) and (not self.extraIndex or self.extraIndex == ShipIndexConst.ExtraAll)
end

function DockyardScene:setShipsCount(arg_52_1, arg_52_2)
	self.shipsCount = arg_52_1
	self.specialShipCount = arg_52_2
end

function DockyardScene:GetCard(arg_53_1)
	return DockyardShipItem.New(arg_53_1, self.contextData.hideTagFlags, self.contextData.blockTagFlags)
end

function DockyardScene:OnClickCard(arg_54_1)
	if arg_54_1.shipVO then
		if not self.selecteEnabled then
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_CLICK)

			DockyardScene.value = self.shipContainer.value

			self.onClick(arg_54_1.shipVO, self.shipVOs)
		else
			pg.CriMgr.GetInstance():PlaySoundEffect_V3((table.contains(self.selectedIds, arg_54_1.shipVO.id) or nil) and (SFX_UI_CANCEL or SFX_UI_FORMATION_SELECT))
			self:selectShip(arg_54_1.shipVO)
		end
	else
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_UI_CLICK)

		if self.callbackQuit then
			self.onSelected({}, function()
				self:back()
			end)
		elseif not arg_54_1.isLoading then
			self.onSelected({})
			self:back()
		end
	end
end

function DockyardScene:OnClickPhantom(arg_56_1)
	if arg_56_1.phantomId == 0 then
		return
	else
		self:emit(DockyardMediator.CHANGE_SKIN, arg_56_1)
	end
end

function DockyardScene:onInitItem(arg_57_1)
	if self.scrollItems[arg_57_1] then
		return self.scrollItems[arg_57_1]
	end

	local var_57_0 = self:GetCard(arg_57_1)

	var_57_0:updateDetail(self.itemDetailType)

	var_57_0.isLoading = true

	onButton(self, var_57_0.go, function()
		self:OnClickCard(var_57_0)
	end)

	local var_57_1 = GetOrAddComponent(var_57_0.go, "UILongPressTrigger").onLongPressed

	if self.contextData.preView == NewBackYardShipInfoLayer.__cname then
		var_57_1:RemoveAllListeners()
		var_57_1:AddListener(function()
			if var_57_0.shipVO then
				self.contextData.selectedIds = self.selectedIds

				self.onClick(var_57_0.shipVO, underscore.select(self.shipVOs, function(arg_60_0)
					return arg_60_0
				end), self.contextData)
			end
		end)
	else
		var_57_1:RemoveAllListeners()
	end

	self.scrollItems[arg_57_1] = var_57_0

	return var_57_0
end

function DockyardScene:getOrInitPhantom(arg_61_1)
	self.scrollPhantoms[arg_61_1] = self.scrollPhantoms[arg_61_1] or {
		isClear = true,
		go = arg_61_1,
		tf = tf(arg_61_1),
		updateSelected = function(self, arg_62_1)
			self.shipCard:updateSelected(arg_62_1[0])
			eachChild(self.tf:Find("phantoms"), function(arg_63_0, arg_63_1)
				arg_63_1 = arg_63_1 + 1

				setActive(arg_63_0:Find("selected"), self.phantoms[arg_63_1 + 1] and arg_62_1[self.phantoms[arg_63_1 + 1].phantomId])
			end)
		end,
		clear = function(self)
			if self.isClear then
				return
			end

			self.shipCard:clear()

			self.isClear = true
		end
	}

	return self.scrollPhantoms[arg_61_1]
end

function DockyardScene:updatePhantomGroup(arg_65_1, arg_65_2)
	local var_65_0 = self:getOrInitPhantom(arg_65_2)

	var_65_0.isClear = false
	self.phantomGroupDic[arg_65_1.shipId] = arg_65_2
	var_65_0.shipCard = var_65_0.shipCard or self:GetCard(var_65_0.tf:Find("card"):GetChild(0).gameObject)

	local var_65_1 = self.shipVOsById[arg_65_1.shipId]:getAllShipPhantom()

	assert(var_65_1[1].phantomId == 0)

	var_65_0.phantoms = var_65_1

	var_65_0.shipCard:update(var_65_1[1])
	var_65_0.shipCard:updateSelected(underscore.any(self.selectedIds, function(arg_66_0)
		return arg_66_0 == var_65_1[1].id
	end))
	self:updateItemBlackBlock(var_65_0.shipCard)

	var_65_0.shipCard.isLoading = false

	var_65_0.shipCard:updateIntimacyEnergy(false)
	var_65_0.shipCard:updateIntimacy(false)
	onButton(self, var_65_0.shipCard.tr, function()
		self:OnClickPhantom(var_65_1[1])
	end, SFX_UI_CLICK)

	local var_65_2 = var_65_0.tf:Find("phantoms")

	UIItemList.StaticAlign(var_65_2, var_65_2:GetChild(0), getGameset("technology_shadow_num")[1], function(arg_68_0, arg_68_1, arg_68_2)
		arg_68_1 = arg_68_1 + 1

		if arg_68_0 == UIItemList.EventUpdate then
			local var_68_0 = var_65_1[arg_68_1 + 1]

			setActive(arg_68_2:Find("skin"), tobool(var_65_1[arg_68_1 + 1]))
			setActive(arg_68_2:Find("lock"), not var_68_0)

			if var_68_0 then
				GetImageSpriteFromAtlasAsync("shipYardIcon/" .. var_68_0:getPainting(), "", arg_68_2:Find("skin/Image"))
				changeToScrollText(arg_68_2:Find("skin/name/Text"), pg.ship_skin_template[var_68_0:getSkinId()].name)
				setActive(arg_68_2:Find("skin/status"), false)

				local var_68_1 = var_68_0:GetShipPhantomMark()

				setActive(arg_68_2:Find("selected"), underscore.any(self.selectedMarks or {}, function(arg_69_0)
					return var_68_1 == arg_69_0
				end))
				setActive(arg_68_2:Find("skin/mark/base"), self.contextData.mode ~= DockyardScene.MODE_SHIP_PHANTOM)
				setActive(arg_68_2:Find("skin/mark/toggle"), self.contextData.mode == DockyardScene.MODE_SHIP_PHANTOM)

				local var_68_2 = var_68_0:getRandomFlag()

				onToggle(self, arg_68_2:Find("skin/mark/toggle"), function(arg_70_0)
					if arg_70_0 ~= var_68_2 then
						var_68_2 = arg_70_0

						self:emit(DockyardMediator.CHANGE_RANDOM_FLAG, var_68_0:GetShipPhantomMark(), var_68_2)
					end
				end, SFX_UI_CLICK)
				triggerToggle(arg_68_2:Find("skin/mark/toggle"), var_68_2)
			else
				setActive(arg_68_2:Find("selected"), false)
			end

			onButton(self, arg_68_2, function()
				if var_68_0 then
					self:OnClickPhantom(var_68_0)
				else
					pg.TipsMgr.GetInstance():ShowTips(i18n("shadow_unlock_tip"))
				end
			end, SFX_UI_CLICK)
		end
	end)
end

function DockyardScene:showEnergyDesc(arg_72_1, arg_72_2)
	if LeanTween.isTweening(go(self.energyDescTF)) then
		LeanTween.cancel(go(self.energyDescTF))

		self.energyDescTF.localScale = Vector3.one
	end

	setText(self.energyDescTextTF, i18n(arg_72_2))

	self.energyDescTF.position = arg_72_1

	setActive(self.energyDescTF, true)
	LeanTween.scale(self.energyDescTF, Vector3.zero, 0.2):setDelay(1):setFrom(Vector3.one):setOnComplete(System.Action(function()
		self.energyDescTF.localScale = Vector3.one

		setActive(self.energyDescTF, false)
	end))
end

function DockyardScene:onUpdateItem(arg_74_1, arg_74_2)
	local var_74_0 = self.shipVOs[arg_74_1 + 1]

	self.cardItemDic[(self.shipVOs[arg_74_1 + 1] or nil) and (var_74_0.id or 0)] = arg_74_2

	local var_74_1 = self:onInitItem(arg_74_2)

	var_74_1:update(var_74_0)

	if self.contextData.mode == DockyardScene.MODE_WORLD then
		var_74_1:updateWorld()
	end

	var_74_1:updateSelected(var_74_1.shipVO and underscore.any(self.selectedIds, function(arg_75_0)
		return var_74_1.shipVO.id == arg_75_0
	end))
	self:updateItemBlackBlock(var_74_1)

	var_74_1.isLoading = false

	var_74_1:updateIntimacyEnergy(self.contextData.energyDisplay or self.sortIndex == ShipIndexConst.SortEnergy)
	var_74_1:updateIntimacy((self.sortIndex == ShipIndexConst.SortIntimacy or self.extraIndex == ShipIndexConst.ExtraMarry) and self.contextData.mode ~= DockyardScene.MODE_UPGRADE)
end

function DockyardScene:onReturnItem(arg_76_1, arg_76_2)
	if self.exited then
		return
	end

	if self.scrollItems[arg_76_2] then
		self.scrollItems[arg_76_2]:clear()
	end
end

function DockyardScene:updateIndexDatas()
	self.contextData.indexDatas = self.contextData.indexDatas or {}
	self.contextData.indexDatas.sortIndex = self.sortIndex
	self.contextData.indexDatas.typeIndex = self.typeIndex
	self.contextData.indexDatas.campIndex = self.campIndex
	self.contextData.indexDatas.rarityIndex = self.rarityIndex
	self.contextData.indexDatas.extraIndex = self.extraIndex
end

function DockyardScene:initIndexPanel()
	onButton(self, self.indexBtn, function()
		self:emit(DockyardMediator.OPEN_DOCKYARD_INDEX, {
			indexDatas = Clone(self.contextData.indexDatas),
			customPanels = {
				minHeight = 650,
				sortIndex = {
					isSort = true,
					mode = CustomIndexLayer.Mode.OR,
					options = ShipIndexConst.SortIndexs,
					names = ShipIndexConst.SortNames
				},
				sortPropertyIndex = {
					blueSeleted = true,
					mode = CustomIndexLayer.Mode.OR,
					options = ShipIndexConst.SortPropertyIndexs,
					names = ShipIndexConst.SortPropertyNames
				},
				typeIndex = {
					blueSeleted = true,
					mode = CustomIndexLayer.Mode.AND,
					options = ShipIndexConst.TypeIndexs,
					names = ShipIndexConst.TypeNames
				},
				campIndex = {
					blueSeleted = true,
					mode = CustomIndexLayer.Mode.AND,
					options = ShipIndexConst.CampIndexs,
					names = ShipIndexConst.CampNames
				},
				rarityIndex = {
					blueSeleted = true,
					mode = CustomIndexLayer.Mode.AND,
					options = ShipIndexConst.RarityIndexs,
					names = ShipIndexConst.RarityNames
				},
				extraIndex = {
					blueSeleted = true,
					mode = CustomIndexLayer.Mode.OR,
					options = ShipIndexConst.ExtraIndexs,
					names = ShipIndexConst.ExtraNames
				},
				layoutPos = Vector2(0, -25)
			},
			groupList = {
				{
					titleTxt = "indexsort_sort",
					dropdown = false,
					titleENTxt = "indexsort_sorteng",
					tags = {
						"sortIndex"
					},
					simpleDropdown = {
						"sortPropertyIndex"
					}
				},
				{
					dropdown = false,
					titleENTxt = "indexsort_indexeng",
					titleTxt = "indexsort_index",
					tags = {
						"typeIndex"
					}
				},
				{
					dropdown = false,
					titleENTxt = "indexsort_campeng",
					titleTxt = "indexsort_camp",
					tags = {
						"campIndex"
					}
				},
				{
					dropdown = false,
					titleENTxt = "indexsort_rarityeng",
					titleTxt = "indexsort_rarity",
					tags = {
						"rarityIndex"
					}
				},
				{
					dropdown = false,
					titleENTxt = "indexsort_indexeng",
					titleTxt = "indexsort_extraindex",
					tags = {
						"extraIndex"
					}
				}
			},
			callback = function(self)
				self.sortIndex = self.sortIndex
				self.typeIndex = self.typeIndex
				self.campIndex = self.campIndex
				self.rarityIndex = self.rarityIndex
				self.extraIndex = self.extraIndex

				self:updateIndexDatas()
				self:filter()
			end
		})
	end, SFX_PANEL)
	onToggle(self, self.preferenceBtn, function(arg_81_0)
		self.commonTag = arg_81_0 and Ship.PREFERENCE_TAG_COMMON or Ship.PREFERENCE_TAG_NONE

		self:filter()
	end)
end

function DockyardScene:setShips(arg_82_1)
	self.shipVOsById = arg_82_1

	local var_82_0 = getProxy(TechnologyProxy)

	self.shipBluePrints = {}

	for iter_82_0, iter_82_1 in ipairs(var_82_0:getAllBluePrintShipIds()) do
		local var_82_1 = getProxy(BayProxy):getShipById(iter_82_1)

		if #var_82_1:getAllShipPhantomMarks() > 1 then
			table.insert(self.shipBluePrints, var_82_0:getBluePrintById(var_82_1.groupId))
		end
	end

	table.sort(self.shipBluePrints, CompareFuncs({
		function(arg_83_0)
			return arg_83_0:getConfig("blueprint_version")
		end,
		function(arg_84_0)
			return arg_84_0.id
		end
	}))
end

function DockyardScene:setPlayer(arg_85_1)
	self.player = arg_85_1

	self:updateBarInfo()
end

function DockyardScene:updateBarInfo()
	setActive(self.bottomTipsText, self.contextData.leftTopInfo)
	setText(self.bottomTipsText, self.contextData.leftTopInfo and i18n("dock_yard_left_tips", self.contextData.leftTopInfo) or "")
	setActive(self.bottomTipsWithFrame, self.contextData.leftTopWithFrameInfo)
	setText(self.bottomTipsWithFrame:Find("Text"), self.contextData.leftTopWithFrameInfo or "")

	if self.contextData.mode == DockyardScene.MODE_WORLD or self.contextData.mode == DockyardScene.MODE_GUILD_BOSS or self.contextData.mode == DockyardScene.MODE_REMOULD or self.isPhantomMode then
		setActive(self.leftTipsText, false)
	else
		setActive(self.leftTipsText, true)
		self:updateCapacityDisplay()
	end
end

function DockyardScene:updateCapacityDisplay()
	setActive(self.leftTipsText:Find("plus"), not self.isCapacityMeta)
	setActive(self.leftTipsText:Find("tip"), self.isCapacityMeta)
	setActive(self.leftTipsText:Find("switch/off"), not self.isCapacityMeta)
	setActive(self.leftTipsText:Find("switch/on"), self.isCapacityMeta)

	if self.isCapacityMeta then
		setText(self.leftTipsText:Find("label"), i18n("specialshipyard_name"))
		setText(self.leftTipsText:Find("Text"), self.specialShipCount)
	else
		setText(self.leftTipsText:Find("label"), i18n("ship_dockyardScene_capacity"))
		setText(self.leftTipsText:Find("Text"), self.shipsCount .. "/" .. self.player:getMaxShipBag())
	end
end

function DockyardScene:initWorldPanel()
	onButton(self, self.worldPanel:Find("btn_repair"), function()
		if #self.selectedIds > 0 then
			self:repairWorldShip(self.shipVOsById[self.selectedIds[1]])
		end
	end, SFX_PANEL)
	onButton(self, self.worldPanel:Find("btn_repair_all"), function()
		local var_90_0 = {}
		local var_90_1 = 0

		for iter_90_0, iter_90_1 in pairs(self.shipVOsById) do
			local var_90_2 = WorldConst.FetchWorldShip(iter_90_1.id)

			if var_90_2:IsBroken() or not var_90_2:IsHpFull() then
				table.insert(var_90_0, var_90_2.id)

				var_90_1 = var_90_1 + nowWorld():CalcRepairCost(var_90_2)
			end
		end

		if #var_90_0 == 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("world_ship_repair_no_need"))
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("world_ship_repair_all", var_90_1),
				onYes = function()
					self:emit(DockyardMediator.ON_SHIP_REPAIR, var_90_0, var_90_1)
				end
			})
		end
	end, SFX_PANEL)
end

function DockyardScene:repairWorldShip(arg_92_1)
	local var_92_0 = WorldConst.FetchWorldShip(arg_92_1.id)
	local var_92_1 = nowWorld():CalcRepairCost(var_92_0)

	if var_92_0:IsBroken() then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("world_ship_repair_2", arg_92_1:getName(), var_92_1),
			onYes = function()
				self:emit(DockyardMediator.ON_SHIP_REPAIR, {
					var_92_0.id
				}, var_92_1)
			end
		})
	elseif not var_92_0:IsHpFull() then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("world_ship_repair_1", arg_92_1:getName(), var_92_1),
			onYes = function()
				self:emit(DockyardMediator.ON_SHIP_REPAIR, {
					var_92_0.id
				}, var_92_1)
			end
		})
	else
		pg.TipsMgr.GetInstance():ShowTips(i18n("world_ship_repair_no_need"))
	end
end

function DockyardScene:filter()
	LoadImageSpriteAtlasAsync("ui/dockyardui_atlas", self:isDefaultStatus() and "shaixuan_off" or "shaixuan_on", self.indexBtn, true)

	if self.isRemouldOrUpgradeMode then
		self:filterForRemouldAndUpgrade()
	else
		self:filterCommon()
	end

	local var_95_0 = 0

	if self.contextData.quitTeam then
		var_95_0 = var_95_0 + 1

		table.insert(self.shipVOs, var_95_0, false)
	end

	if self.contextData.priorEquipUpShipIDList then
		local var_95_1 = {}

		for iter_95_0, iter_95_1 in ipairs(self.contextData.priorEquipUpShipIDList) do
			var_95_1[iter_95_1] = true
		end

		for iter_95_2 = #self.shipVOs, 1, -1 do
			local var_95_2 = type(self.shipVOs[iter_95_2]) == "table" and self.shipVOs[iter_95_2].id

			if var_95_1[var_95_2] then
				var_95_1[var_95_2] = table.remove(self.shipVOs, iter_95_2)
			end
		end

		for iter_95_3, iter_95_4 in ipairs(self.contextData.priorEquipUpShipIDList) do
			if type(var_95_1[iter_95_4]) == "table" then
				var_95_0 = var_95_0 + 1

				table.insert(self.shipVOs, var_95_0, var_95_1[iter_95_4])
			end
		end
	end

	if DockyardScene.MODE_OVERVIEW == self.contextData.mode and DockyardScene.value then
		self:updateShipCount(DockyardScene.value or 0)

		DockyardScene.value = nil
	else
		self:updateShipCount(0)
	end
end

function DockyardScene:filterForRemouldAndUpgrade()
	self.shipVOs = {}

	local var_96_0 = self.isFilterLockForMod
	local var_96_1 = self.isFilterLevelForMod

	local function var_96_2(arg_97_0)
		return (not var_96_1 and arg_97_0.level > 1 or nil) and false
	end

	for iter_96_0, iter_96_1 in pairs(self.shipVOsById) do
		if var_96_2(iter_96_1) then
			table.insert(self.shipVOs, iter_96_1)
		end
	end

	table.sort(self.shipVOs, CompareFuncs({
		function(arg_98_0)
			return arg_98_0.level
		end,
		function(arg_99_0)
			return arg_99_0:isTestShip() and 1 or 0
		end
	}))
end

function DockyardScene:filterCommon()
	self.shipVOs = {}

	local var_100_0 = self.sortIndex

	local function var_100_1(arg_101_0)
		if self.contextData.mode ~= DockyardScene.MODE_GUILD_BOSS then
			return true
		end

		if self.isShowAssultShips then
			return true
		end

		if not arg_101_0.user then
			return true
		end

		if arg_101_0.user.id == self.player.id then
			return true
		end

		return false
	end

	for iter_100_0, iter_100_1 in pairs(self.shipVOsById) do
		if self.contextData.blockLock and iter_100_1:GetLockState() == Ship.LOCK_STATE_LOCK then
			-- block empty
		elseif self.teamTypeFilter and iter_100_1:getTeamType() ~= self.teamTypeFilter then
			-- block empty
		elseif ShipIndexConst.filterByType(iter_100_1, self.typeIndex) and ShipIndexConst.filterByCamp(iter_100_1, self.campIndex) and ShipIndexConst.filterByRarity(iter_100_1, self.rarityIndex) and ShipIndexConst.filterByExtra(iter_100_1, self.extraIndex) and (self.commonTag == Ship.PREFERENCE_TAG_NONE or self.commonTag == iter_100_1:GetPreferenceTag()) and var_100_1(iter_100_1) then
			table.insert(self.shipVOs, iter_100_1)
		end
	end

	local var_100_2 = self.searchBar:GetInputText()

	if var_100_2 and var_100_2 ~= "" then
		self.shipVOs = underscore.filter(self.shipVOs, function(arg_102_0)
			return arg_102_0:IsMatchKey(var_100_2)
		end)
	end

	local var_100_3, var_100_4 = ShipIndexConst.getSortFuncAndName(var_100_0, self.selectAsc)

	if var_100_0 ~= ShipIndexConst.SortIntimacy then
		if not defaultValue((self.contextData.hideTagFlags or {}).inFleet, ShipStatus.TAG_HIDE_BASE.inFleet) then
			table.insert(var_100_3, 1, function(arg_103_0)
				return arg_103_0:getFlag("inFleet") and 0 or 1
			end)
		end
	end

	if var_100_3 then
		self:SortShips(var_100_3)
	end

	self:updateSelected()
	setActive(self.sortImgAsc, self.selectAsc)
	setActive(self.sortImgDesc, not self.selectAsc)
	setText(self.sortBtn:Find("Image"), i18n(var_100_4))
end

function DockyardScene:SortShips(arg_104_1)
	if pg.NewGuideMgr.GetInstance():IsBusy() then
		local var_104_0 = {
			101171,
			201211,
			401231,
			301051
		}

		arg_104_1 = {
			function(arg_105_0)
				return table.contains(var_104_0, arg_105_0.configId) and 0 or 1
			end
		}
	elseif self.isFormTactics then
		table.insert(arg_104_1, 1, function(arg_106_0)
			return arg_106_0:getNation() == Nation.META and 1 or 0
		end)
		table.insert(arg_104_1, 1, function(arg_107_0)
			return arg_107_0:isFullSkillLevel() and 1 or 0
		end)
	elseif self.contextData.mode == DockyardScene.MODE_OVERVIEW or self.contextData.mode == DockyardScene.MODE_SELECT then
		table.insert(arg_104_1, 1, function(arg_108_0)
			return -arg_108_0.activityNpc
		end)
	elseif self.contextData.mode == DockyardScene.MODE_GUILD_BOSS then
		table.insert(arg_104_1, 1, function(arg_109_0)
			return arg_109_0.guildRecommand and 0 or 1
		end)
	end

	table.sort(self.shipVOs, CompareFuncs(arg_104_1))
end

function DockyardScene:UpdateGuildViewEquipmentsBtn()
	setActive(self.viewEquipmentBtn, self.contextData.mode == DockyardScene.MODE_GUILD_BOSS and #self.selectedIds > 0)
end

function DockyardScene:GetSelectCount()
	return #self.selectedIds
end

function DockyardScene:GetConfirmSelect()
	return self.selectedIds
end

function DockyardScene:didEnter()
	if self:isLayer() then
		self:OverlayPanel(self._tf, {
			groupDelta = -1
		})
	end

	self:OverlayPanel(self.blurPanel)
	self:PlayUIAnimation(self.blurPanel, "enter")

	local var_113_0 = getProxy(TaskProxy):mingshiTouchFlagEnabled()

	var_113_0 = var_113_0 and self.contextData.mode ~= DockyardScene.MODE_GUILD_BOSS

	setActive(self.stampBtn, var_113_0)
	self:UpdateGuildViewEquipmentsBtn()
	onButton(self, self.stampBtn, function()
		getProxy(TaskProxy):dealMingshiTouchFlag(1)
	end, SFX_CONFIRM)
	onButton(self, self.topPanel:Find("back"), function()
		self:back()
	end, SFX_CANCEL)
	onButton(self, self.sortBtn, function()
		self.selectAsc = not self.selectAsc

		self:filter()
	end, SFX_UI_CLICK)
	onToggle(self, self.assultBtn, function(arg_117_0)
		self.isShowAssultShips = arg_117_0

		self:filter()
	end, SFX_PANEL)
	onButton(self, self.viewEquipmentBtn, function()
		if not self.selectedIds[#self.selectedIds] then
			return
		end

		self.guildShipEquipmentsPage:ExecuteAction("Show", self.shipVOsById[self.selectedIds[#self.selectedIds]], self.shipVOsById[self.selectedIds[#self.selectedIds]].user)
	end, SFX_PANEL)
	onButton(self, self.attrBtn, function()
		if not self.isFormTactics then
			self.itemDetailType = (self.itemDetailType + 1) % 4
		elseif self.itemDetailType == DockyardShipItem.DetailType0 then
			self.itemDetailType = DockyardShipItem.DetailType3 or DockyardShipItem.DetailType0
		end

		setActive(self.attrBtn:Find("off"), self.itemDetailType == DockyardShipItem.DetailType0)
		setActive(self.attrBtn:Find("on"), self.itemDetailType ~= DockyardShipItem.DetailType0)

		if self.itemDetailType == DockyardShipItem.DetailType0 then
			self.attrBtn:GetComponent("Button").targetGraphic = imageOff or imageOn
		end

		self:updateItemDetailType()
	end, SFX_PANEL)
	onButton(self, self.selectPanel:Find("cancel_button"), function()
		if self.animating then
			return
		end

		if self.contextData.mode == DockyardScene.MODE_DESTROY then
			if #self.selectedIds > 0 then
				self:unselecteAllShips()
				self:back()
			else
				self:back()
			end
		else
			self:back()

			return
		end
	end, SFX_CANCEL)
	onButton(self, self.selectPanel:Find("confirm_button"), function()
		if self.animating then
			return
		end

		if self.contextData.mode == DockyardScene.MODE_DESTROY then
			local var_121_0, var_121_1 = self:checkDestroyGold()

			if not var_121_0 or not var_121_1 then
				if not var_121_0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title") .. i18n("resource_max_tip_retire"))
				elseif not var_121_0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("oil_max_tip_title") .. i18n("resource_max_tip_retire"))
				end

				return
			end
		end

		if self:GetSelectCount() < self.selectedMin then
			if self.leastLimitMsg then
				pg.TipsMgr.GetInstance():ShowTips(self.leastLimitMsg)
			else
				pg.TipsMgr.GetInstance():ShowTips(i18n("ship_dockyardScene_error_choiseRoleMore", self.selectedMin))
			end

			return
		end

		if self.contextData.mode == DockyardScene.MODE_DESTROY then
			self:displayDestroyPanel()
		else
			local var_121_2 = {}

			if self.contextData.destroyCheck then
				local var_121_3 = underscore.map(self.selectedIds, function(arg_122_0)
					return self.shipVOsById[arg_122_0]
				end)

				table.insert(var_121_2, function(arg_123_0)
					self:checkDestroyShips(var_121_3, arg_123_0)
				end)
			end

			local var_121_4 = self:GetConfirmSelect()

			if self.confirmSelect then
				table.insert(var_121_2, function(arg_124_0)
					self.confirmSelect(var_121_4, function()
						arg_124_0(true)
					end, arg_124_0)
				end)
				seriesAsync(var_121_2, function(arg_126_0)
					if arg_126_0 then
						self.onSelected(var_121_4)
					end

					self:back()
				end)
			else
				table.insert(var_121_2, function(arg_127_0)
					if self.callbackQuit then
						self.onSelected(var_121_4, arg_127_0)
					else
						self.onSelected(var_121_4)
						arg_127_0()
					end
				end)
				seriesAsync(var_121_2, function()
					self:back()
				end)
			end
		end
	end, SFX_CONFIRM)
	onButton(self, self.selectPanel:Find("quick_select"), function()
		if self.animating then
			return
		end

		local var_129_0 = {
			PlayerPrefs.GetInt("QuickSelectRarity1", 3),
			PlayerPrefs.GetInt("QuickSelectRarity2", 4),
			PlayerPrefs.GetInt("QuickSelectRarity3", 2)
		}
		local var_129_1 = {}

		for iter_129_0, iter_129_1 in pairs(var_129_0) do
			if iter_129_1 ~= 0 then
				var_129_1[iter_129_1] = var_129_1[iter_129_1] or 3
			end
		end

		local var_129_3 = {}
		local var_129_4 = {}

		for iter_129_2, iter_129_3 in pairs((getProxy(BayProxy):getShips())) do
			if iter_129_3:isMaxStar() then
				var_129_3[iter_129_3:getGroupId()] = true
			else
				local var_129_5 = iter_129_3:getMaxStar() - iter_129_3:getStar() + 1

				if iter_129_3:GetLockState() == Ship.LOCK_STATE_UNLOCK then
					var_129_5 = var_129_5 + 1
				end

				local var_129_6 = var_129_4[iter_129_3:getGroupId()]

				var_129_4[iter_129_3:getGroupId()] = var_129_6 and var_129_6 < var_129_5 and var_129_6 or var_129_5
			end
		end

		local var_129_7 = _.select(self.shipVOs, function(arg_130_0)
			return arg_130_0.configId ~= 100001 and arg_130_0.configId ~= 100011 and arg_130_0:GetLockState() == Ship.LOCK_STATE_UNLOCK and table.contains(var_129_0, arg_130_0:getRarity()) and arg_130_0.level == 1 and not self.blacklist[arg_130_0:getGroupId()] and not table.contains(self.selectedIds, arg_130_0.id) and not arg_130_0:hasAnyFlag({
				"inFleet",
				"inChapter",
				"inWorld",
				"inEvent",
				"inBackyard",
				"inClass",
				"inTactics",
				"inExercise",
				"inAdmiral",
				"inElite",
				"inActivity",
				"inGuildEvent",
				"inGuildBossEvent"
			})
		end)

		if not _.all(var_129_7, function(arg_131_0)
			return self.blacklist[arg_131_0:getGroupId()]
		end) then
			var_129_7 = _.select(var_129_7, function(arg_132_0)
				return not self.blacklist[arg_132_0:getGroupId()]
			end)
		elseif #self.selectedIds > 0 then
			var_129_7 = {}
		end

		table.sort(var_129_7, function(arg_133_0, arg_133_1)
			local var_133_0 = var_129_1[arg_133_0:getRarity()] or 0
			local var_133_1 = var_129_1[arg_133_1:getRarity()] or 0

			if var_133_0 == var_133_1 then
				if arg_133_0:getGroupId() == arg_133_1:getGroupId() then
					return arg_133_0.createTime > arg_133_1.createTime
				end

				return arg_133_0.configId > arg_133_1.configId
			else
				return var_133_1 < var_133_0
			end
		end)

		local var_129_8 = PlayerPrefs.GetString("QuickSelectWhenHasAtLeastOneMaxstar", "KeepNone")
		local var_129_9 = PlayerPrefs.GetString("QuickSelectWithoutMaxstar", "KeepAll")
		local var_129_10 = {}
		local var_129_11 = 0
		local var_129_12 = false
		local var_129_13 = false
		local var_129_14 = 0
		local var_129_15 = 0

		for iter_129_4, iter_129_5 in ipairs(self.selectedIds) do
			local var_129_16, var_129_17 = self.shipVOsById[iter_129_5]:calReturnRes()

			var_129_14 = var_129_14 + var_129_16
			var_129_15 = var_129_15 + var_129_17
		end

		for iter_129_6, iter_129_7 in ipairs((_.select(var_129_7, function(arg_134_0)
			if var_129_3[arg_134_0:getGroupId()] then
				if var_129_8 == "KeepNone" then
					return true
				elseif var_129_8 == "KeepOne" then
					if not var_129_10[arg_134_0:getGroupId()] then
						var_129_10[arg_134_0:getGroupId()] = true

						return false
					end

					return true
				elseif var_129_8 == "KeepAll" then
					return false
				end
			elseif var_129_9 == "KeepNone" then
				return true
			elseif var_129_9 == "KeepNeeded" then
				if var_129_4[arg_134_0:getGroupId()] > 0 then
					var_129_4[arg_134_0:getGroupId()] = var_129_4[arg_134_0:getGroupId()] - 1

					return false
				end

				return true
			elseif var_129_9 == "KeepAll" then
				return false
			end
		end))) do
			if self.selectedMax > 0 and self.selectedMax <= self:GetSelectCount() then
				break
			end

			local var_129_18, var_129_19 = iter_129_7:calReturnRes()

			var_129_14 = var_129_14 + var_129_18
			var_129_15 = var_129_15 + var_129_19
			var_129_12 = self.player:OilMax(var_129_15)
			var_129_13 = self.player:GoldMax(var_129_14)

			if var_129_13 then
				break
			end

			var_129_11 = var_129_11 + 1

			self:selectShip(iter_129_7)
		end

		if var_129_11 == 0 then
			if var_129_13 then
				if #self.selectedIds == 0 then
					pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title") .. i18n("resource_max_tip_retire"))
				else
					pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title"))
				end
			elseif #self.selectedIds > 0 then
				self:displayDestroyPanel()
			else
				pg.TipsMgr.GetInstance():ShowTips(i18n("retire_selectzero"))
			end
		elseif var_129_12 then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("oil_max_tip_title") .. i18n("resource_max_tip_retire_1"),
				onYes = function()
					self:displayDestroyPanel()
				end
			})
		else
			self:displayDestroyPanel()
		end
	end, SFX_CONFIRM)

	if isActive(self.togglePhantom) then
		triggerToggle(self.togglePhantom, tobool(self.inPhantom))
	else
		self:SwitchContainerDisplay()
	end

	self:updateBarInfo()

	if self.contextData.mode == DockyardScene.MODE_WORLD then
		self:initWorldPanel()
	elseif self.contextData.mode == DockyardScene.MODE_DESTROY and not LOCK_DESTROY_GUIDE then
		pg.SystemGuideMgr.GetInstance():Play(self)
	end

	setAnchoredPosition(self.topPanel, {
		y = self.topPanel.rect.height
	})
	setAnchoredPosition(self.selectPanel, {
		y = -1 * self.selectPanel.rect.height
	})
	onNextTick(function()
		if self.exited then
			return
		end

		self:uiStartAnimating()
	end)

	self.bulinTip = AprilFoolBulinSubView.ShowAprilFoolBulin(self)

	onButton(self, self.settingBtn, function()
		self.settingPanel:Load()
		self.settingPanel:ActionInvoke("Show")
	end)
	pg.SystemGuideMgr.GetInstance():Play(self)
end

function DockyardScene:TriggerCard(arg_138_1)
	local var_138_0 = self.selectedIds[1]

	if not self.selectedIds[1] then
		return
	end

	local var_138_1

	for iter_138_0, iter_138_1 in ipairs(self.shipVOs) do
		if iter_138_1 and iter_138_1.id == var_138_0 then
			var_138_1 = iter_138_0

			break
		end
	end

	if not var_138_1 then
		return
	end

	local var_138_2 = var_138_1

	local function var_138_4()
		var_138_2 = var_138_2 + arg_138_1

		if not self.shipVOs[var_138_2] or self.checkShip(self.shipVOs[var_138_2]) then
			return self.shipVOs[var_138_2]
		else
			return var_138_4()
		end
	end

	local var_138_5 = (nil)()

	if not var_138_5 then
		return
	end

	local function var_138_6()
		local var_140_0

		for iter_140_0, iter_140_1 in pairs(self.scrollItems) do
			if iter_140_1.shipVO and iter_140_1.go.name ~= "-1" and iter_140_1.shipVO.id == var_138_5.id then
				var_140_0 = iter_140_1

				break
			end
		end

		return var_140_0
	end

	local var_138_7 = self.cardItemDic[var_138_0] and self.scrollItems[self.cardItemDic[var_138_0]]
	local var_138_8 = self.cardItemDic[var_138_0] and self.scrollItems[self.cardItemDic[var_138_0]] and var_138_7.shipVO.id == var_138_5.id and var_138_7 or nil

	if self.cardItemDic[var_138_0] and self.scrollItems[self.cardItemDic[var_138_0]] and var_138_7.shipVO.id == var_138_5.id and var_138_7 or nil then
		if not getBounds(self._tf:Find("main/ship_container")):Intersects((getBounds(var_138_8.tr))) then
			self.shipContainer:SetNormalizedPosition(self.shipContainer.value + arg_138_1 * (self.shipContainer:HeadIndexToValue(7) - self.shipContainer:HeadIndexToValue(1)), 1)
		end
	end

	if not var_138_8 then
		self.shipContainer:SetNormalizedPosition(self.shipContainer.value + (math.ceil(var_138_2 / 7) - math.ceil(var_138_1 / 7)) * (self.shipContainer:HeadIndexToValue(21) - self.shipContainer:HeadIndexToValue(1)), 1)

		var_138_8 = var_138_6()
	end

	if var_138_8 then
		triggerButton(var_138_8.tr)
		self.guildShipEquipmentsPage:Refresh(self.shipVOsById[var_138_8.shipVO.id], self.shipVOsById[var_138_8.shipVO.id].user)
	end
end

function DockyardScene:OnSwitch(arg_141_1, arg_141_2, arg_141_3)
	local function var_141_0()
		setActive(arg_141_1:Find("off"), not arg_141_2)
		setActive(arg_141_1:Find("on"), arg_141_2)
	end

	onButton(self, arg_141_1, function()
		arg_141_2 = not arg_141_2

		if arg_141_3 then
			arg_141_3(arg_141_2)
		end

		var_141_0()
	end, SFX_PANEL)
	var_141_0()
end

function DockyardScene:OnShipSkinChanged(arg_144_1)
	local var_144_0, var_144_1 = ShipPhantom.UnpackMark(arg_144_1)

	if self.phantomGroupDic[var_144_0] and self.scrollPhantoms[self.phantomGroupDic[var_144_0]] and (self.phantomGroupDic[var_144_0] and self.scrollPhantoms[self.phantomGroupDic[var_144_0]]).shipCard.shipVO.id == var_144_0 then
		self:updatePhantomGroup(underscore.detect(self.filterBluePrint, function(arg_145_0)
			return arg_145_0.shipId == var_144_0
		end), self.phantomGroupDic[var_144_0])
	end
end

function DockyardScene:onBackPressed()
	if self.destroyConfirmWindow:isShowing() then
		self.destroyConfirmWindow:Hide()

		return
	end

	if self.destroyPage:isShowing() then
		self.destroyPage:Hide()

		return
	end

	if self.settingPanel:isShowing() then
		self.settingPanel:Hide()

		return
	end

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	self:back()
end

function DockyardScene:updateShipStatusById(arg_147_1)
	local var_147_0 = self.cardItemDic[arg_147_1] and self.scrollItems[self.cardItemDic[arg_147_1]]

	if self.cardItemDic[arg_147_1] and self.scrollItems[self.cardItemDic[arg_147_1]] and var_147_0.shipVO.id == arg_147_1 then
		var_147_0:flush(self.selectedIds)

		if self.contextData.mode == DockyardScene.MODE_WORLD then
			var_147_0:updateWorld()
		end
	end
end

function DockyardScene:checkDestroyGold(arg_148_1)
	local var_148_0 = 0
	local var_148_1 = 0

	for iter_148_0, iter_148_1 in ipairs(self.selectedIds) do
		local var_148_2, var_148_3 = self.shipVOsById[iter_148_1]:calReturnRes()

		var_148_0 = var_148_0 + var_148_2
		var_148_1 = var_148_1 + var_148_3
	end

	if arg_148_1 then
		local var_148_4, var_148_5 = arg_148_1:calReturnRes()

		var_148_0 = var_148_0 + var_148_4
		var_148_1 = var_148_1 + var_148_5
	end

	local var_148_6 = self.player:OilMax(var_148_1)

	if self.player:GoldMax(var_148_0) then
		return false, not var_148_6
	end

	return true, not var_148_6
end

function DockyardScene:selectShip(arg_149_1)
	local var_149_0 = false
	local var_149_1

	for iter_149_0, iter_149_1 in ipairs(self.selectedIds) do
		if iter_149_1 == arg_149_1.id then
			var_149_0 = true
			var_149_1 = iter_149_0

			break
		end
	end

	if var_149_0 or self.selectedMax == 1 and self:GetSelectCount() > 0 then
		local var_149_2 = defaultValue(var_149_1, 1)
		local var_149_3, var_149_4 = self.onCancelShip(self.shipVOsById[self.selectedIds[var_149_2]], function()
			if not self.exited then
				return
			end

			self:selectShip(arg_149_1)
		end, self.selectedIds)

		if not var_149_3 then
			if var_149_4 then
				pg.TipsMgr.GetInstance():ShowTips(var_149_4)
			end

			return
		end

		table.remove(self.selectedIds, var_149_2)

		if self.selectedMax ~= 1 then
			self:updateBlackBlocks(self.shipVOsById[self.selectedIds[var_149_2]])
		end
	end

	if not var_149_0 then
		local var_149_5, var_149_6 = self.checkShip(arg_149_1, function()
			if self.exited then
				return
			end

			self:selectShip(arg_149_1)
		end, self.selectedIds)

		if not var_149_5 then
			if var_149_6 then
				pg.TipsMgr.GetInstance():ShowTips(var_149_6)
			end

			return
		end

		if self.selectedMax == 0 or self:GetSelectCount() < self.selectedMax then
			table.insert(self.selectedIds, arg_149_1.id)

			if self.selectedMax ~= 1 then
				self:updateBlackBlocks(removeShip)
			end
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("ship_dockyardScene_error_choiseRoleLess", self.selectedMax))

			return
		end
	end

	self:updateSelected()

	if self.contextData.mode == DockyardScene.MODE_DESTROY then
		self:updateDestroyRes()
	elseif self.contextData.mode == DockyardScene.MODE_MOD then
		self:updateModAttr()
	end

	self:UpdateGuildViewEquipmentsBtn()
end

function DockyardScene:updateBlackBlocks(arg_152_1)
	if not self.contextData.useBlackBlock or not arg_152_1 then
		return
	end

	for iter_152_0, iter_152_1 in pairs(self.scrollItems) do
		self:updateItemBlackBlock(iter_152_1)
	end
end

function DockyardScene:updateItemBlackBlock(arg_153_1)
	if self.contextData.useBlackBlock then
		if self.selectedMax == 1 then
			arg_153_1:updateBlackBlock(self.contextData.otherSelectedIds)
		else
			arg_153_1:updateBlackBlock(self.selectedIds)
		end
	else
		arg_153_1:updateBlackBlock()
	end
end

function DockyardScene:unselecteAllShips()
	self.selectedIds = {}

	self:updateSelected()
	self:updateDestroyRes()
end

function DockyardScene:updateSelected()
	if self.shipContainer then
		for iter_155_0, iter_155_1 in pairs(self.scrollItems) do
			if not iter_155_1.isClear then
				if iter_155_1.shipVO then
					local var_155_0 = iter_155_1.shipVO.id or nil
				end

				iter_155_1:updateSelected(iter_155_1.shipVO and underscore.any(self.selectedIds, function(arg_156_0)
					return var_155_0 == arg_156_0
				end))
			end
		end
	end

	if self.phantomContainer then
		for iter_155_2, iter_155_3 in pairs(self.scrollPhantoms) do
			if not iter_155_3.isClear then
				local var_155_1 = iter_155_3.shipCard.shipVO.id
				local var_155_2 = {}

				for iter_155_4 = 0, getGameset("technology_shadow_num")[1] do
					var_155_2[iter_155_4] = iter_155_4 == 0 and underscore.any(self.selectedIds, function(arg_157_0)
						return var_155_1 == arg_157_0
					end) or underscore.any(self.selectedMarks, function(arg_158_0)
						return arg_158_0 == ShipPhantom.PackMark(var_155_1, iter_155_4)
					end)
				end

				iter_155_3:updateSelected(var_155_2)
			end
		end
	end

	if self.selectedMax == 0 then
		setText(self.selectPanel:Find("bottom_info/bg_input/count"), self:GetSelectCount())
	else
		local var_155_3 = self:GetSelectCount()

		if self.contextData.mode ~= DockyardScene.MODE_DESTROY or self:GetSelectCount() == 0 then
			var_155_3 = setColorStr(var_155_3, COLOR_WHITE)
		elseif self.contextData.mode == DockyardScene.MODE_DESTROY then
			var_155_3 = setColorStr(var_155_3, (#self.selectedIds == 10 or nil) and (COLOR_RED or COLOR_GREEN))
		end

		setText(self.selectPanel:Find("bottom_info/bg_input/count"), var_155_3 .. "/" .. self.selectedMax)
	end

	if self:GetSelectCount() < self.selectedMin then
		setActive(self.selectPanel:Find("confirm_button/mask"), true)
	else
		setActive(self.selectPanel:Find("confirm_button/mask"), false)
	end

	if self.contextData.mode == DockyardScene.MODE_MOD then
		self:updateModAttr()
	end
end

function DockyardScene:updateItemDetailType()
	for iter_159_0, iter_159_1 in pairs(self.scrollItems) do
		iter_159_1:updateDetail(self.itemDetailType)
	end

	self.shipLayout.anchoredPosition = self.shipLayout.anchoredPosition + Vector3(0, 0.001, 0)
end

function DockyardScene:closeDestroyMode()
	setActive(self.awardTF, false)
	setActive(self.bottomTipsText, true)
end

function DockyardScene:updateDestroyRes()
	if table.getCount(self.selectedIds) == 0 then
		self:closeDestroyMode()
	else
		setActive(self.awardTF, true)
		setActive(self.bottomTipsText, false)
	end

	local var_161_0, var_161_1, var_161_2 = ShipCalcHelper.CalcDestoryRes((_.map(self.selectedIds, function(arg_162_0)
		return self.shipVOsById[arg_162_0]
	end)))
	local var_161_3 = var_161_1 == 0

	if self.destroyResList then
		self.destroyResList:make(function(arg_163_0, arg_163_1, arg_163_2)
			if arg_163_0 == UIItemList.EventUpdate then
				local var_163_0 = ""
				local var_163_1 = 0

				if arg_163_1 == 0 then
					var_163_1 = var_161_0
					var_163_0 = "Props/gold"
				elseif arg_163_1 == 1 then
					if not var_161_3 then
						var_163_1 = var_161_1
						var_163_0 = "Props/oil"
					else
						var_163_1 = var_161_2[1].count
						var_163_0 = Item.getConfigData(var_161_2[1].id).icon
					end
				elseif arg_163_1 > 1 then
					local var_163_2

					if var_161_3 then
						var_163_2 = var_161_2[arg_163_1]

						if not var_161_2[arg_163_1] then
							var_163_2 = var_161_2[arg_163_1 - 1]
							var_163_1 = var_163_2.count
						end
					end

					var_163_0 = Item.getConfigData(var_163_2.id).icon
				end

				GetImageSpriteFromAtlasAsync(var_163_0, "", arg_163_2:Find("icon"))
				setText(arg_163_2:Find("Text"), "X" .. var_163_1)
			end
		end)
		self.destroyResList:align((var_161_3 and 1 or 2) + #var_161_2)
	end

	if self.destroyPage and self.destroyPage:GetLoaded() and self.destroyPage:isShowing() then
		self.destroyPage:RefreshRes()
	end
end

function DockyardScene:setModShip(arg_164_1)
	self.modShip = arg_164_1
end

function DockyardScene:updateModAttr()
	if table.getCount(self.selectedIds) == 0 then
		self:closeModAttr()
	else
		setActive(self.modAttrsTF, true)
		setActive(self.bottomTipsText, false)
	end

	local var_165_1 = {}

	for iter_165_0, iter_165_1 in ipairs(self.selectedIds) do
		table.insert(var_165_1, self.shipVOsById[iter_165_1])
	end

	local var_165_2 = ShipModLayer.getModExpAdditions(self.modShip, var_165_1)

	for iter_165_2, iter_165_3 in pairs(ShipModAttr.ID_TO_ATTR) do
		if iter_165_2 ~= ShipModLayer.IGNORE_ID then
			local var_165_3 = self.modAttrContainer:Find("attr_" .. iter_165_2)

			setText(var_165_3:Find("value"), var_165_2[iter_165_3])
			setText(var_165_3:Find("name"), ShipModAttr.id2Name(iter_165_2))
		end
	end
end

function DockyardScene:closeModAttr()
	setActive(self.modAttrsTF, false)
	setActive(self.bottomTipsText, true)
end

function DockyardScene:removeShip(arg_167_1)
	for iter_167_0, iter_167_1 in ipairs(self.selectedIds) do
		if iter_167_1 == arg_167_1 then
			table.remove(self.selectedIds, iter_167_0)

			break
		end
	end

	for iter_167_2 = #self.shipVOs, 1, -1 do
		if self.shipVOs[iter_167_2].id == arg_167_1 then
			table.remove(self.shipVOs, iter_167_2)

			break
		end
	end

	self.shipVOsById[arg_167_1] = nil
end

function DockyardScene:updateShipCount(arg_168_1)
	self.shipContainer:SetTotalCount(#self.shipVOs, defaultValue(arg_168_1, -1))
	setActive(self.listEmptyTF, #self.shipVOs <= 0)
end

function DockyardScene:ClearShipsBlackBlock()
	if not self.shipVOsById then
		return
	end

	for iter_169_0, iter_169_1 in pairs(self.shipVOsById) do
		iter_169_1.blackBlock = false
	end
end

function DockyardScene:willExit()
	self:closeDestroyMode()
	self:closeModAttr()
	self:ClearShipsBlackBlock()

	if self.guildShipEquipmentsPage then
		self.guildShipEquipmentsPage:Destroy()
	end

	if self.settingPanel then
		self.settingPanel:Destroy()
	end

	if self.destroyPage then
		self.destroyPage:Destroy()
	end

	if self.destroyConfirmWindow then
		self.destroyConfirmWindow:Destroy()
	end

	if self.contextData.mode == DockyardScene.MODE_MOD then
		-- block empty
	elseif not self.contextData.sortData then
		if _G[self.contextData.preView] then
			_G[self.contextData.preView].sortIndex = self.sortIndex
			_G[self.contextData.preView].selectAsc = self.selectAsc
			_G[self.contextData.preView].typeIndex = self.typeIndex
			_G[self.contextData.preView].campIndex = self.campIndex
			_G[self.contextData.preView].rarityIndex = self.rarityIndex
			_G[self.contextData.preView].extraIndex = self.extraIndex
			_G[self.contextData.preView].commonTag = self.commonTag
		else
			DockyardScene.sortIndex = self.sortIndex
			DockyardScene.selectAsc = self.selectAsc
			DockyardScene.typeIndex = self.typeIndex
			DockyardScene.campIndex = self.campIndex
			DockyardScene.rarityIndex = self.rarityIndex
			DockyardScene.extraIndex = self.extraIndex
			DockyardScene.commonTag = self.commonTag
		end
	end

	if self.shipContainer then
		self.shipContainer.enabled = false

		for iter_170_0, iter_170_1 in pairs(self.scrollItems) do
			iter_170_1:clear()
			GetOrAddComponent(iter_170_1.go, "UILongPressTrigger").onLongPressed:RemoveAllListeners()
		end
	end

	if self.phantomContainer then
		self.phantomContainer.enabled = false

		for iter_170_2, iter_170_3 in pairs(self.scrollPhantoms) do
			iter_170_3:clear()
		end
	end

	if LeanTween.isTweening(go(self.energyDescTF)) then
		setActive(self.energyDescTF, false)
		LeanTween.cancel(go(self.energyDescTF))
	end

	self:cancelAnimating()

	if self.isRemouldOrUpgradeMode then
		local var_170_0 = getProxy(SettingsProxy)

		var_170_0:SetDockYardLockBtnFlag(self.isFilterLockForMod)
		var_170_0:SetDockYardLevelBtnFlag(self.isFilterLevelForMod)
	end

	if self.bulinTip then
		self.bulinTip:Destroy()

		self.bulinTip = nil
	end

	if self.searchBar then
		self.searchBar:Dispose()

		self.searchBar = nil
	end

	self:UnOverlayPanel(self.blurPanel, self._tf)

	if self:isLayer() then
		self:UnOverlayPanel(self._tf)
	end
end

function DockyardScene:uiStartAnimating()
	local var_171_0 = self.topPanel:Find("back")

	if isActive(self.selectPanel) then
		shiftPanel(self.selectPanel, nil, 0, 0.3, 0, true, true)
	end
end

function DockyardScene:uiExitAnimating()
	if self.contextData.mode == DockyardScene.MODE_OVERVIEW then
		-- block empty
	else
		shiftPanel(self.selectPanel, nil, -1 * self.selectPanel.rect.height, 0.3, 0, true, true)
	end
end

function DockyardScene:back()
	if self.exited then
		return
	end

	self:closeView()
end

function DockyardScene:cancelAnimating()
	if LeanTween.isTweening(go(self.topPanel)) then
		LeanTween.cancel(go(self.topPanel))
	end

	if LeanTween.isTweening(go(self.selectPanel)) then
		LeanTween.cancel(go(self.selectPanel))
	end

	if self.tweens then
		cancelTweens(self.tweens)
	end
end

function DockyardScene:quickExitFunc()
	seriesAsync({
		function(arg_176_0)
			if self.contextData.onQuickHome then
				self.contextData.onQuickHome(arg_176_0)
			else
				arg_176_0()
			end
		end,
		function(arg_177_0)
			self:emit(DockyardScene.ON_HOME)
		end
	})
end

function DockyardScene:displayDestroyPanel()
	self.destroyPage:ExecuteAction("Show")
	self.destroyPage:ActionInvoke("Refresh", self.selectedIds, self.shipVOsById)
end

function DockyardScene:closeDestroyPanel()
	if self.destroyPage:isShowing() then
		self.destroyPage:Hide()
	end
end

function DockyardScene:checkDestroyShips(arg_180_1, arg_180_2)
	local var_180_0 = {}

	if PlayerPrefs.GetInt("RetireProtect", 1) == 0 then
		local var_180_1 = {}

		for iter_180_0, iter_180_1 in pairs(arg_180_1) do
			local var_180_2 = 0

			for iter_180_2, iter_180_3 in pairs(arg_180_1) do
				if iter_180_3:getGroupId() == iter_180_1:getGroupId() then
					var_180_2 = var_180_2 + 1
				end
			end

			if #getProxy(BayProxy):findShipsByGroup(iter_180_1:getGroupId()) == var_180_2 then
				local var_180_3 = false

				for iter_180_4, iter_180_5 in pairs(var_180_1) do
					if iter_180_5:getGroupId() == iter_180_1:getGroupId() then
						var_180_3 = true

						break
					end
				end

				if not var_180_3 then
					table.insert(var_180_1, iter_180_1)
				end
			end
		end

		if #var_180_1 > 0 then
			table.insert(var_180_0, function(arg_181_0)
				self.destroyConfirmWindow:ExecuteAction("ShowOneShipProtect", var_180_1, arg_181_0)
			end)
		end
	end

	local var_180_4, var_180_5 = ShipCalcHelper.GetEliteAndHightLevelShips(arg_180_1)

	if #var_180_4 > 0 or #var_180_5 > 0 then
		table.insert(var_180_0, function(arg_182_0)
			self.destroyConfirmWindow:ExecuteAction("Show", var_180_4, var_180_5, (self.contextData.mode == DockyardScene.MODE_DESTROY or nil) and ({
				ShipCalcHelper.CalcDestoryRes(arg_180_1)
			})[4], arg_182_0)
		end)
	end

	local var_180_6 = underscore.filter(arg_180_1, function(arg_183_0)
		return arg_183_0:getFlag("inElite")
	end)

	if #var_180_6 > 0 then
		table.insert(var_180_0, function(arg_184_0)
			self.destroyConfirmWindow:ExecuteAction("ShowEliteTag", var_180_6, arg_184_0)
		end)
	end

	seriesAsync(var_180_0, arg_180_2)
end

return DockyardScene
