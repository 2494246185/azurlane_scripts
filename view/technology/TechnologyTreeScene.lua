local TechnologyTreeScene = class("TechnologyTreeScene", import("..base.BaseUI"))

TechnologyTreeScene.NationTrige = {
	All = 0,
	Mot = 3,
	Meta = 2,
	Other = 1
}
TechnologyTreeScene.TypeTrige = {
	All = 0,
	Other = 1
}

function TechnologyTreeScene:getUIName()
	return "TechnologyTreeUI"
end

function TechnologyTreeScene:getResource()
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in ipairs(pg.fleet_tech_ship_class.all) do
		for iter_2_2, iter_2_3 in ipairs(pg.fleet_tech_ship_class[iter_2_1].ships) do
			local var_2_1 = ShipGroup.getDefaultSkin(iter_2_3)

			if var_2_1 then
				table.insertto(var_2_0, ResPathSupport.GetShipSkinSpineShipModelList(var_2_1.id))
			end
		end
	end

	return ResPathSupport.MergeLuaArr(TechnologyTreeScene.super.getResource(self), {
		"ui/Technologytreeui",
		"ui/technologytreeui_atlas",
		"tecclasslevelicon",
		"tecnation",
		"shipraritybaseicon",
		"tecnation"
	}, var_2_0)
end

function TechnologyTreeScene:init()
	self:initData()
	self:findUI()
	self:initNationToggleUIList()
	self:initTecClassUIList()
end

function TechnologyTreeScene:didEnter()
	self:initTypeToggleUIList()
	self:updateTecItemList()
	self:addBtnListener()
	setText(self.pointNumText, self.point)
	self:updateRedPoint(getProxy(TechnologyNationProxy):getShowRedPointTag())

	if not PlayerPrefs.HasKey("first_comein_technologytree") then
		triggerButton(self.helpBtn)
		PlayerPrefs.SetInt("first_comein_technologytree", 1)
		PlayerPrefs.Save()
	end
end

function TechnologyTreeScene:updateRedPoint(arg_5_1)
	setActive(self.redPointImg, arg_5_1)
end

function TechnologyTreeScene:willExit()
	self:UnOverlayPanel(self.blurPanel, self._tf)

	self.rightLSC.onReturnItem = nil

	if self.emptyPage then
		self.emptyPage:Destroy()

		self.emptyPage = nil
	end
end

function TechnologyTreeScene:initData()
	TechnologyConst.CreateMetaClassConfig()

	self.nationToggleList = {}
	self.typeToggleList = {}
	self.nationSelectedList = {}
	self.typeSelectedList = {}
	self.nationSelectedCount = 0
	self.typeSelectedCount = 0
	self.lastNationTrige = nil
	self.lastTypeTrige = nil
	self.countInEveryRow = 5
	self.collectionProxy = getProxy(CollectionProxy)
	self.nationProxy = getProxy(TechnologyNationProxy)
	self.curClassIDList = nil
	self.groupIDGotList = {}

	for iter_7_0, iter_7_1 in pairs(self.collectionProxy.shipGroups) do
		self.groupIDGotList[#self.groupIDGotList + 1] = iter_7_1.id
	end

	self.point = self.nationProxy:getPoint()
	self.expanded = {}
end

function TechnologyTreeScene:findUI()
	self.nationAllToggle = nil
	self.nationAllToggleCom = nil
	self.nationMetaToggle = self._tf:Find("Adapt/Left/MetaToggle")
	self.nationMetaToggleCom = GetComponent(self.nationMetaToggle, "Toggle")
	self.nationMotToggle = self._tf:Find("Adapt/Left/MotToggle")
	self.nationMotToggleCom = GetComponent(self.nationMotToggle, "Toggle")
	self.typeAllToggle = nil
	self.typeAllToggleCom = nil
	self.blurPanel = self._tf:Find("blur_panel")
	self.adapt = self.blurPanel:Find("adapt")
	self.backBtn = self.adapt:Find("top/back")
	self.homeBtn = self.adapt:Find("top/option")
	self.additionDetailBtn = self.adapt:Find("AdditionDetailBtn")
	self.switchBtn = self.adapt:Find("SwitchToggle")
	self.pointTF = self.adapt:Find("PointCount")
	self.pointNumText = self.adapt:Find("PointCount/PointNumText")
	self.redPointImg = self.switchBtn:Find("RedPoint")
	self.helpBtn = self.adapt:Find("help_btn")
	self.leftContainer = self._tf:Find("Adapt/Left/Scroll View/Content")
	self.selectNationItem = self._tf:Find("SelectCampItem")
	self.bottomContainer = self._tf:Find("Adapt/Bottom/Content")
	self.selectTypeItem = self._tf:Find("SelectTypeItem")
	self.rightContainer = self._tf:Find("Adapt/Right/Container")
	self.rightLSC = self.rightContainer:GetComponent("LScrollRect")
	self.rightLayoutGroup = self.rightContainer:GetComponent("VerticalLayoutGroup")
	self.headItem = self._tf:Find("HeadItem")
	self.rowHeight = self.headItem.rect.height
	self.maxRowHeight = 853.5
	self.emptyPage = BaseEmptyListPage.New(self._tf:Find("Adapt/Right/ViewPort"), self.event)
end

function TechnologyTreeScene:onBackPressed()
	triggerButton(self.backBtn)
end

function TechnologyTreeScene:addBtnListener()
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.additionDetailBtn, function()
		self:emit(TechnologyConst.OPEN_ALL_BUFF_DETAIL)
	end)
	onToggle(self, self.switchBtn, function(arg_13_0)
		if arg_13_0 then
			setActive(self.pointTF, false)
			self:OverlayPanel(self.blurPanel)
			self:emit(TechnologyConst.OPEN_TECHNOLOGY_NATION_LAYER)
		else
			setActive(self.pointTF, true)
			self:UnOverlayPanel(self.blurPanel, self._tf)
			self:emit(TechnologyConst.CLOSE_TECHNOLOGY_NATION_LAYER)
		end
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		if pg.gametip.help_technologytree then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = pg.gametip.help_technologytree.tip
			})
		end
	end, SFX_PANEL)
end

function TechnologyTreeScene:initNationToggleUIList()
	self.nationAllToggle = nil
	self.nationAllToggleCom = nil
	self.nationMetaToggle = self._tf:Find("Adapt/Left/MetaToggle")
	self.nationMetaToggleCom = GetComponent(self.nationMetaToggle, "Toggle")
	self.nationMotToggle = self._tf:Find("Adapt/Left/MotToggle")
	self.nationMotToggleCom = GetComponent(self.nationMotToggle, "Toggle")

	setActive(self.nationMetaToggle, not LOCK_TEC_META)

	if LOCK_TEC_META then
		local var_15_0 = self._tf:Find("Adapt/Left/Scroll View")

		var_15_0.offsetMin = Vector2.New(var_15_0.offsetMin.x, 0)
	end

	local var_15_1 = UIItemList.New(self.leftContainer, self.selectNationItem)

	var_15_1:make(function(arg_16_0, arg_16_1, arg_16_2)
		if arg_16_0 == UIItemList.EventUpdate then
			arg_16_2:Find("UnSelectedImg"):GetComponent("Image").sprite, arg_16_2:Find("SelectedImg"):GetComponent("Image").sprite = TechnologyConst.GetNationSpriteByIndex(arg_16_1 + 1)

			if arg_16_1 == 0 then
				self.nationAllToggle = arg_16_2
				self.nationAllToggleCom = GetComponent(arg_16_2, "Toggle")
				self.nationAllToggleCom.interactable = false

				triggerToggle(arg_16_2, true)
			else
				self.nationToggleList[arg_16_1] = arg_16_2

				triggerToggle(arg_16_2, false)
			end

			setActive(arg_16_2, true)
		end
	end)
	var_15_1:align(#TechnologyConst.NationResName)
	setActive(self.nationMotToggle, not LOCK_TEC_MOT)

	if not LOCK_TEC_MOT then
		setParent(self.nationMotToggle, self.leftContainer)
	end

	onToggle(self, self.nationAllToggle, function(arg_17_0)
		if arg_17_0 == true then
			self.lastNationTrige = TechnologyTreeScene.NationTrige.All
			self.nationAllToggleCom.interactable = false
			self.nationSelectedCount = 0
			self.nationSelectedList = {}

			self:updateTecItemList()
			self:updateNationToggleUIList()
		else
			self.nationAllToggleCom.interactable = true
		end
	end, SFX_PANEL)
	onToggle(self, self.nationMetaToggle, function(arg_18_0)
		if arg_18_0 == true then
			self.lastNationTrige = TechnologyTreeScene.NationTrige.Meta
			self.nationMetaToggleCom.interactable = false
			self.nationSelectedCount = 0
			self.nationSelectedList = {}

			self:updateTecItemList()
			self:updateNationToggleUIList()
		else
			self.nationMetaToggleCom.interactable = true
		end
	end, SFX_PANEL)
	onToggle(self, self.nationMotToggle, function(arg_19_0)
		if arg_19_0 == true then
			self.lastNationTrige = TechnologyTreeScene.NationTrige.Mot
			self.nationMotToggleCom.interactable = false
			self.nationSelectedCount = 0
			self.nationSelectedList = {}

			self:updateTecItemList()
			self:updateNationToggleUIList()
		else
			self.nationMotToggleCom.interactable = true
		end
	end, SFX_PANEL)

	for iter_15_0, iter_15_1 in ipairs(self.nationToggleList) do
		onToggle(self, iter_15_1, function(arg_20_0)
			if arg_20_0 == true then
				self.lastNationTrige = TechnologyTreeScene.NationTrige.Other
				self.nationSelectedCount = self.nationSelectedCount + 1

				table.insert(self.nationSelectedList, TechnologyConst.NationOrder[iter_15_0])

				if self.nationSelectedCount < #self.nationToggleList then
					self:updateNationToggleUIList()
					self:updateTecItemList()
				elseif self.nationSelectedCount == #self.nationToggleList then
					self:updateNationToggleUIList()
				end
			elseif self.nationSelectedCount > 0 then
				self.nationSelectedCount = self.nationSelectedCount - 1

				local var_20_0 = table.indexof(self.nationSelectedList, TechnologyConst.NationOrder[iter_15_0], 1)

				if var_20_0 then
					table.remove(self.nationSelectedList, var_20_0)
				end

				if self.nationSelectedCount > 0 then
					self:updateNationToggleUIList()
					self:updateTecItemList()
				elseif self.nationSelectedCount == 0 then
					self:updateNationToggleUIList()
				end
			end
		end, SFX_PANEL)
	end
end

function TechnologyTreeScene:updateNationToggleUIList()
	if self.lastNationTrige == TechnologyTreeScene.NationTrige.All then
		_.each(self.nationToggleList, function(arg_22_0)
			triggerToggle(arg_22_0, false)
			onNextTick(function()
				setActive(arg_22_0:Find("UnSelectedImg"), true)
			end)
		end)
		triggerToggle(self.nationMetaToggle, false)
		triggerToggle(self.nationMotToggle, false)
	elseif self.lastNationTrige == TechnologyTreeScene.NationTrige.Meta then
		triggerToggle(self.nationAllToggle, false)
		_.each(self.nationToggleList, function(arg_24_0)
			triggerToggle(arg_24_0, false)
		end)
		triggerToggle(self.nationMotToggle, false)
	elseif self.lastNationTrige == TechnologyTreeScene.NationTrige.Mot then
		triggerToggle(self.nationAllToggle, false)
		_.each(self.nationToggleList, function(arg_25_0)
			triggerToggle(arg_25_0, false)
		end)
		triggerToggle(self.nationMetaToggle, false)
	elseif self.lastNationTrige == TechnologyTreeScene.NationTrige.Other then
		if self.nationSelectedCount <= 0 or self.nationSelectedCount >= #self.nationToggleList then
			triggerToggle(self.nationAllToggle, true)
		else
			triggerToggle(self.nationAllToggle, false)
			triggerToggle(self.nationMetaToggle, false)
			triggerToggle(self.nationMotToggle, false)
		end
	end
end

function TechnologyTreeScene:initTypeToggleUIList()
	self.typeAllToggle = nil
	self.typeAllToggleCom = nil

	local var_26_0 = UIItemList.New(self.bottomContainer, self.selectTypeItem)

	var_26_0:make(function(arg_27_0, arg_27_1, arg_27_2)
		if arg_27_0 == UIItemList.EventUpdate then
			arg_27_2:Find("UnSelectedImg"):GetComponent("Image").sprite, arg_27_2:Find("SelectedImg"):GetComponent("Image").sprite = TechnologyConst.GetTypeSpriteByIndex(arg_27_1 + 1)
			arg_27_1 = arg_27_1 + 1

			if arg_27_1 == #TechnologyConst.TypeResName then
				self.typeAllToggle = arg_27_2
				self.typeAllToggleCom = GetComponent(arg_27_2, "Toggle")
				self.typeAllToggleCom.interactable = false

				triggerToggle(arg_27_2, true)
			else
				self.typeToggleList[arg_27_1] = arg_27_2

				triggerToggle(arg_27_2, false)
			end

			setActive(arg_27_2, true)
		end
	end)
	var_26_0:align(#TechnologyConst.TypeResName)
	onToggle(self, self.typeAllToggle, function(arg_28_0)
		self.lastTypeTrige = TechnologyTreeScene.TypeTrige.All

		if arg_28_0 == true then
			self.typeAllToggleCom.interactable = false
			self.typeSelectedCount = 0
			self.typeSelectedList = {}

			self:updateTecItemList()
			self:updateTypeToggleUIList()
		else
			self.typeAllToggleCom.interactable = true
		end
	end)

	for iter_26_0, iter_26_1 in ipairs(self.typeToggleList) do
		onToggle(self, iter_26_1, function(arg_29_0)
			self.lastTypeTrige = TechnologyTreeScene.TypeTrige.Other

			if arg_29_0 == true then
				self.typeSelectedCount = self.typeSelectedCount + 1

				for iter_29_0, iter_29_1 in ipairs(TechnologyConst.TypeOrder[iter_26_0]) do
					table.insert(self.typeSelectedList, iter_29_1)
				end

				if self.typeSelectedCount < #self.typeToggleList then
					self:updateTypeToggleUIList()
					self:updateTecItemList()
				elseif self.typeSelectedCount == #self.typeToggleList then
					self:updateTypeToggleUIList()
				end
			elseif self.typeSelectedCount > 0 then
				self.typeSelectedCount = self.typeSelectedCount - 1

				for iter_29_2, iter_29_3 in ipairs(TechnologyConst.TypeOrder[iter_26_0]) do
					local var_29_0 = table.indexof(self.typeSelectedList, iter_29_3, 1)

					if var_29_0 then
						table.remove(self.typeSelectedList, var_29_0)
					end
				end

				if self.typeSelectedCount > 0 then
					self:updateTypeToggleUIList()
					self:updateTecItemList()
				elseif self.typeSelectedCount == 0 then
					self:updateTypeToggleUIList()
				end
			end
		end, SFX_PANEL)
	end
end

function TechnologyTreeScene:updateTypeToggleUIList()
	if self.lastTypeTrige == TechnologyTreeScene.TypeTrige.All then
		_.each(self.typeToggleList, function(arg_31_0)
			triggerToggle(arg_31_0, false)
			onNextTick(function()
				setActive(arg_31_0:Find("UnSelectedImg"), true)
			end)
		end)
	elseif self.lastTypeTrige == TechnologyTreeScene.TypeTrige.Other then
		if self.typeSelectedCount <= 0 or self.typeSelectedCount >= #self.typeToggleList then
			triggerToggle(self.typeAllToggle, true)
		else
			triggerToggle(self.typeAllToggle, false)
		end
	end
end

function TechnologyTreeScene:updatePreferredHeight(arg_33_1, arg_33_2)
	local var_33_0 = tf(arg_33_1):Find("ShipScrollView/ShipContainer")

	self.rightLayoutGroup.padding.bottom = self.rightLayoutGroup.padding.bottom + (arg_33_2 + self.rowHeight) - GetComponent(arg_33_1, "LayoutElement").preferredHeight
	GetComponent(arg_33_1, "LayoutElement").preferredHeight = arg_33_2 + self.rowHeight

	setLocalRotation(tf(arg_33_1):Find("ClickBtn/ArrowBtn"), {
		z = arg_33_2 > 0 and 0 or 180
	})
end

function TechnologyTreeScene:onClassItemUpdate(arg_34_1, arg_34_2)
	local var_34_0 = tf(arg_34_2):Find("CampBG")
	local var_34_1 = tf(arg_34_2):Find("Level/LevelImg")
	local var_34_2 = tf(arg_34_2):Find("Level/TypeTextImg")
	local var_34_3 = tf(arg_34_2)
	local var_34_4 = var_34_3:Find("ClickBtn")
	local var_34_5 = var_34_4:Find("ArrowBtn")
	local var_34_6 = self:getClassConfigForShow(arg_34_1 + 1)
	local var_34_7 = var_34_6.ships
	local var_34_8 = self:isMetaOn()
	local var_34_9 = self:isMotOn()

	setText(tf(arg_34_2):Find("Name/NameText"), var_34_3.name)

	local var_34_10

	if var_34_8 or var_34_9 then
		setActive(var_34_1, false)
		setActive(var_34_2, false)

		if var_34_8 then
			var_34_10 = GetSpriteFromAtlas("TecNation", "bg_nation_meta")
		elseif var_34_9 then
			var_34_10 = GetSpriteFromAtlas("TecNation", "bg_nation_mot")
		end
	else
		setImageSprite(var_34_1, GetSpriteFromAtlas("TecClassLevelIcon", "T" .. var_34_6.t_level), true)
		setImageSprite(var_34_2, GetSpriteFromAtlas("ShipType", "ch_title_" .. var_34_6.shiptype), true)
		setActive(var_34_1, true)
		setActive(var_34_2, true)

		var_34_10 = GetSpriteFromAtlas("TecNation", "bg_nation_" .. var_34_6.nation)
	end

	setImageSprite(var_34_0, var_34_10)
	setLocalRotation(tf(arg_34_2):Find("ClickBtn/ArrowBtn"), {
		z = 180
	})

	local var_34_11 = tf(arg_34_2):Find("ShipScrollView/ShipContainer")

	self:updateShipItemList(var_34_7, var_34_11)

	self.expanded[arg_34_1] = 0

	self:updatePreferredHeight(arg_34_2, self.expanded[arg_34_1])
	setActive(var_34_4, #var_34_7 > 5)
	onButton(self, var_34_4, function()
		self.expanded[arg_34_1] = defaultValue(self.expanded[arg_34_1], 0) > 0 and 0 or var_34_11.rect.height - self.rowHeight

		self:updatePreferredHeight(arg_34_2, self.expanded[arg_34_1])
	end, SFX_PANEL)
end

function TechnologyTreeScene:onClassItemReturn(arg_36_1, arg_36_2)
	if defaultValue(self.expanded[arg_36_1], 0) > 0 then
		self.expanded[arg_36_1] = 0

		self:updatePreferredHeight(arg_36_2, self.expanded[arg_36_1])
	end
end

function TechnologyTreeScene:initTecClassUIList()
	function self.rightLSC.onUpdateItem(arg_38_0, arg_38_1)
		self:onClassItemUpdate(arg_38_0, arg_38_1)
	end

	function self.rightLSC.onReturnItem(arg_39_0, arg_39_1)
		self:onClassItemReturn(arg_39_0, arg_39_1)
	end
end

function TechnologyTreeScene:updateTecItemList()
	self.expanded = {}

	local var_40_0 = self:getClassIDListForShow()

	if self.rightLSC.totalCount ~= 0 then
		self.rightLSC:SetTotalCount(0)
	end

	self.rightLSC:SetTotalCount(#var_40_0)
	self.rightLSC:BeginLayout()
	self.rightLSC:EndLayout()

	if #var_40_0 <= 0 then
		self.emptyPage:ExecuteAction("ShowOrHide", true)
		self.emptyPage:ExecuteAction("SetEmptyText", i18n("technology_filter_placeholder"))
	elseif #var_40_0 > 0 and self.emptyPage:GetLoaded() then
		self.emptyPage:ExecuteAction("ShowOrHide", false)
	end
end

function TechnologyTreeScene:updateShipItemList(arg_41_1, arg_41_2)
	local var_41_0 = UIItemList.New(arg_41_2, self.headItem)

	var_41_0:make(function(arg_42_0, arg_42_1, arg_42_2)
		if arg_42_0 == UIItemList.EventUpdate then
			local var_42_0 = arg_42_2:Find("BaseImg/CharImg")
			local var_42_1 = arg_42_2:Find("NameBG")
			local var_42_2 = arg_42_2:Find("Frame")
			local var_42_3 = arg_42_2:Find("Star")
			local var_42_4 = arg_42_2:Find("Star/StarImg")
			local var_42_5 = arg_42_2:Find("Info")
			local var_42_6 = var_42_5:Find("PointText")
			local var_42_7 = var_42_5:Find("BuffGet")
			local var_42_8 = var_42_7:Find("TypeIcon")
			local var_42_9 = var_42_5:Find("Lock")
			local var_42_10 = var_42_5:Find("BuffComplete")
			local var_42_11 = var_42_10:Find("TypeIcon")
			local var_42_12 = arg_42_2:Find("BottomBG")
			local var_42_13 = arg_42_2:Find("BottomBG/StatusUnknow")
			local var_42_14 = arg_42_2:Find("BottomBG/StatusResearching")
			local var_42_15 = arg_42_2:Find("ViewIcon")
			local var_42_16 = arg_42_2:Find("keyansaohguang")
			local var_42_17 = arg_41_1[arg_42_1 + 1]

			setText(var_42_1:Find("NameText"), shortenString(ShipGroup.getDefaultShipNameByGroupID(arg_41_1[arg_42_1 + 1]), 6))
			setImageSprite(arg_42_2:Find("BaseImg"), GetSpriteFromAtlas("shipraritybaseicon", "base_" .. pg.ship_data_statistics[var_42_17 * 10 + 1].rarity))
			LoadSpriteAsync("shipmodels/" .. Ship.getPaintingName(var_42_17 * 10 + 1), function(arg_43_0)
				if arg_43_0 and not self.exited then
					setImageSprite(var_42_0, arg_43_0, true)

					rtf(var_42_0).pivot = getSpritePivot(arg_43_0)
				end
			end)

			if table.indexof(self.groupIDGotList, var_42_17, 1) then
				setImageSprite(var_42_8, GetSpriteFromAtlas("ui/technologytreeui_atlas", "label_" .. pg.fleet_tech_ship_template[var_42_17].add_get_shiptype[1]))
				setImageSprite(var_42_8:Find("AttrIcon"), GetSpriteFromAtlas("attricon", pg.attribute_info_by_type[pg.fleet_tech_ship_template[var_42_17].add_get_attr].name))
				setText(var_42_8:Find("NumText"), "+" .. pg.fleet_tech_ship_template[var_42_17].add_get_value)
				setActive(var_42_7, true)

				local var_42_18 = self.collectionProxy:getShipGroup(var_42_17)

				if var_42_18.maxLV < TechnologyConst.SHIP_LEVEL_FOR_BUFF then
					setActive(var_42_14, true)
					setActive(var_42_13, false)
					setActive(var_42_10, false)
					setImageSprite(var_42_2, GetSpriteFromAtlas("ui/technologytreeui_atlas", "card_bg_normal"))
					setActive(var_42_12, true)
					setActive(var_42_15, true)
					setActive(var_42_9, true)
					setActive(var_42_16, false)

					if var_42_18.star == pg.fleet_tech_ship_template[var_42_17].max_star then
						setText(var_42_6, "+" .. pg.fleet_tech_ship_template[var_42_17].pt_get + pg.fleet_tech_ship_template[var_42_17].pt_upgrage)
					else
						setText(var_42_6, "+" .. pg.fleet_tech_ship_template[var_42_17].pt_get)
					end
				else
					setImageSprite(var_42_11, GetSpriteFromAtlas("ui/technologytreeui_atlas", "label_" .. pg.fleet_tech_ship_template[var_42_17].add_level_shiptype[1]))
					setImageSprite(var_42_11:Find("AttrIcon"), GetSpriteFromAtlas("attricon", pg.attribute_info_by_type[pg.fleet_tech_ship_template[var_42_17].add_level_attr].name))
					setText(var_42_11:Find("NumText"), "+" .. pg.fleet_tech_ship_template[var_42_17].add_level_value)
					setActive(var_42_10, true)

					if var_42_18.star == pg.fleet_tech_ship_template[var_42_17].max_star then
						setText(var_42_6, "+" .. pg.fleet_tech_ship_template[var_42_17].pt_get + pg.fleet_tech_ship_template[var_42_17].pt_level + pg.fleet_tech_ship_template[var_42_17].pt_upgrage)
						setImageSprite(var_42_2, GetSpriteFromAtlas("ui/technologytreeui_atlas", "card_bg_finished"))
						setActive(var_42_12, false)
						setActive(var_42_15, false)
						setActive(var_42_14, false)
						setActive(var_42_13, false)
						setActive(var_42_16, true)
					else
						setText(var_42_6, "+" .. pg.fleet_tech_ship_template[var_42_17].pt_get + pg.fleet_tech_ship_template[var_42_17].pt_level)
						setImageSprite(var_42_2, GetSpriteFromAtlas("ui/technologytreeui_atlas", "card_bg_normal"))
						setActive(var_42_12, true)
						setActive(var_42_15, true)
						setActive(var_42_14, true)
						setActive(var_42_13, false)
						setActive(var_42_16, false)
					end

					setActive(var_42_9, false)
				end

				setImageColor(var_42_0, Color.New(1, 1, 1, 1))
				setActive(var_42_1, true)
				setActive(var_42_5, true)
				setActive(var_42_3, true)

				if var_42_18.star == pg.fleet_tech_ship_template[var_42_17].max_star then
					setActive(var_42_4, true)
				else
					setActive(var_42_4, false)
				end

				onButton(self, arg_42_2, function()
					self:emit(TechnologyConst.OPEN_SHIP_BUFF_DETAIL, var_42_17, var_42_18.maxLV, var_42_18.star)
				end)
			else
				setImageSprite(var_42_2, GetSpriteFromAtlas("ui/technologytreeui_atlas", "card_bg_normal"))
				setImageColor(var_42_0, Color.New(0, 0, 0, 0.4))
				setActive(var_42_15, false)
				setActive(var_42_1, false)
				setActive(var_42_5, false)
				setActive(var_42_14, false)
				setActive(var_42_13, true)
				setActive(var_42_3, false)
				setActive(var_42_9, false)
				setActive(var_42_16, false)
				removeOnButton(arg_42_2)
			end

			setActive(arg_42_2, true)
		end
	end)
	var_41_0:align(#arg_41_1)
end

function TechnologyTreeScene:getClassIDListForShow(arg_45_1, arg_45_2)
	arg_45_1 = arg_45_1 or self.nationSelectedList
	arg_45_2 = arg_45_2 or self.typeSelectedList

	local var_45_0 = self:isMetaOn()
	local var_45_1 = self:isMotOn()

	if not var_45_0 and not var_45_1 then
		local var_45_2 = TechnologyConst.GetOrderClassList()
		local var_45_3

		if #arg_45_1 == 0 and #arg_45_2 == 0 then
			var_45_3 = var_45_2
		else
			if #arg_45_1 == 0 then
				local var_45_4 = TechnologyConst.NationOrder or arg_45_1
			end

			var_45_3 = _.select(var_45_2, function(arg_46_0)
				if table.contains(var_45_4, pg.fleet_tech_ship_class[arg_46_0].nation) then
					if #self.typeSelectedList == 0 then
						return true
					else
						return table.contains(self.typeSelectedList, pg.fleet_tech_ship_class[arg_46_0].shiptype)
					end
				else
					return false
				end
			end)
		end

		self.curClassIDList = var_45_3

		return var_45_3
	elseif var_45_0 then
		self.curMetaClassIDList = TechnologyConst.GetOrderMetaClassList(arg_45_2)

		return self.curMetaClassIDList
	elseif var_45_1 then
		self.curMotClassIDList = TechnologyConst.GetOrderMotClassList(arg_45_2)

		return self.curMotClassIDList
	end
end

function TechnologyTreeScene:getClassConfigForShow(arg_47_1)
	local var_47_0 = self:isMetaOn()
	local var_47_1 = self:isMotOn()

	if not var_47_0 and not var_47_1 then
		return pg.fleet_tech_ship_class[self.curClassIDList[arg_47_1]]
	elseif var_47_0 then
		return TechnologyConst.GetMetaClassConfig(self.curMetaClassIDList[arg_47_1], self.typeSelectedList)
	elseif var_47_1 then
		return TechnologyConst.GetMotClassConfig(self.curMotClassIDList[arg_47_1], self.typeSelectedList)
	end
end

function TechnologyTreeScene:isMetaOn()
	if self.lastNationTrige == TechnologyTreeScene.NationTrige.All then
		return false
	elseif self.lastNationTrige == TechnologyTreeScene.NationTrige.Mot then
		return false
	end

	return self.nationMetaToggleCom.isOn
end

function TechnologyTreeScene:isMotOn()
	if self.lastNationTrige == TechnologyTreeScene.NationTrige.All then
		return false
	elseif self.lastNationTrige == TechnologyTreeScene.NationTrige.Meta then
		return false
	end

	return self.nationMotToggleCom.isOn
end

return TechnologyTreeScene
