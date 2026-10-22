local CollectionScene = class("CollectionScene", import("..base.BaseUI"))

CollectionScene.SHOW_DETAIL = "event show detail"
CollectionScene.GET_AWARD = "event get award"
CollectionScene.ACTIVITY_OP = "event activity op"
CollectionScene.BEGIN_STAGE = "event begin state"
CollectionScene.ON_INDEX = "event on index"
CollectionScene.UPDATE_RED_POINT = "CollectionScene:UPDATE_RED_POINT"
CollectionScene.ShipOrderAsc = false
CollectionScene.ShipIndex = {
	typeIndex = ShipIndexConst.TypeAll,
	campIndex = ShipIndexConst.CampAll,
	rarityIndex = ShipIndexConst.RarityAll,
	collExtraIndex = ShipIndexConst.CollExtraAll
}
CollectionScene.ShipIndexData = {
	customPanels = {
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
		collExtraIndex = {
			blueSeleted = true,
			mode = CustomIndexLayer.Mode.AND,
			options = ShipIndexConst.CollExtraIndexs,
			names = ShipIndexConst.CollExtraNames
		}
	},
	groupList = {
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
				"collExtraIndex"
			}
		}
	}
}
CollectionScene.SHIPCOLLECTION_INDEX = 1
CollectionScene.MANGA_INDEX = 4
CollectionScene.GALLERY_INDEX = 5
CollectionScene.MUSIC_INDEX = 6

function CollectionScene:isDefaultStatus()
	return CollectionScene.ShipIndex.typeIndex == ShipIndexConst.TypeAll and (CollectionScene.ShipIndex.campIndex == ShipIndexConst.CampAll or self.contextData.toggle == 1 and self.contextData.cardToggle == 2) and CollectionScene.ShipIndex.rarityIndex == ShipIndexConst.RarityAll and CollectionScene.ShipIndex.collExtraIndex == ShipIndexConst.CollExtraAll
end

function CollectionScene:getUIName()
	return "CollectionUI"
end

function CollectionScene:getResource()
	return ResPathSupport.UniqueLuaArr(ResPathSupport.MergeLuaArr(CollectionScene.super.getResource(self), {
		"ui/collectionui",
		"ui/share/index_atlas"
	}, (function()
		local var_4_0 = {}

		for iter_4_0, iter_4_1 in ipairs(pg.storeup_data_template.all) do
			for iter_4_2, iter_4_3 in ipairs(pg.storeup_data_template[iter_4_1].char_list or {}) do
				local var_4_2 = ShipGroup.getDefaultSkin(iter_4_3)

				if var_4_2 then
					table.insertto(var_4_0, ResPathSupport.GetShipSkinSpineShipModelList(var_4_2.id))
				end
			end
		end

		return var_4_0
	end)(), (function()
		local var_7_0 = {}

		for iter_7_0, iter_7_1 in ipairs(pg.ship_data_group.all) do
			local var_7_1 = ShipGroup.getDefaultSkin(pg.ship_data_group[iter_7_1].group_type)
			local var_7_2 = ShipGroup.New({
				id = pg.ship_data_group[iter_7_1].group_type
			})

			if var_7_1 then
				table.insertto(var_7_0, ResPathSupport.GetShipSkinPaintingShipYardIconList(var_7_1.id))
			end

			table.insert(var_7_0, string.format(ResPathSupport.ConstPath.BG.ShipCard, var_7_2:rarity2bgPrint(false)))

			if pg.ship_data_trans[pg.ship_data_group[iter_7_1].group_type] then
				local var_7_3 = ShipGroup.getModSkin(pg.ship_data_group[iter_7_1].group_type)

				if var_7_3 then
					table.insertto(var_7_0, ResPathSupport.GetShipSkinPaintingShipYardIconList(var_7_3.id))
				end

				var_7_2.trans = true

				table.insert(var_7_0, string.format(ResPathSupport.ConstPath.BG.ShipCard, var_7_2:rarity2bgPrint(true)))
			end
		end

		return var_7_0
	end)(), (function()
		local var_5_0 = {}

		local function var_5_1(arg_6_0)
			local var_6_0 = Drop.New({
				type = arg_6_0[1],
				id = arg_6_0[2],
				count = arg_6_0[3]
			})

			if var_6_0.type == DROP_TYPE_SHIP then
				local var_6_1 = Ship.New({
					configId = var_6_0.id
				})

				table.insertto(var_5_0, ResPathSupport.GetPaintingSquareIconListByPaintingName(var_6_1:getPainting()))
				table.insertto(var_5_0, ResPathSupport.GetPaintingShipYardIconListByPaintingName(var_6_1:getPainting()))
				table.insert(var_5_0, string.format(ResPathSupport.ConstPath.BG.ShipCard, var_6_1:rarity2bgPrint()))
			elseif var_6_0.type == DROP_TYPE_EQUIP then
				table.insert(var_5_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.Equipment.Equip, var_6_0:getSubClass():getConfig("icon")))
			elseif var_6_0.type == DROP_TYPE_FURNITURE then
				table.insert(var_5_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.FurnitureIcon, var_6_0:getIcon()))
			elseif var_6_0.type == DROP_TYPE_ITEM or var_6_0.type == DROP_TYPE_VITEM or var_6_0.type == DROP_TYPE_META_PT or var_6_0.type == DROP_TYPE_LOVE_LETTER then
				local var_6_2 = var_6_0:getSubClass()
				local var_6_3 = var_6_2.icon or var_6_2:getConfig("icon")

				if noEmptyStr(var_6_3) then
					table.insert(var_5_0, var_6_3)
				end
			elseif var_6_0.type == DROP_TYPE_RESOURCE then
				local var_6_4 = id2ItemId(var_6_0.id)

				if var_6_4 then
					var_5_1({
						DROP_TYPE_ITEM,
						var_6_4,
						var_6_0.count
					})
				end
			end
		end

		for iter_5_0, iter_5_1 in ipairs(pg.storeup_data_template.all) do
			for iter_5_2, iter_5_3 in ipairs(pg.storeup_data_template[iter_5_1].award_display or {}) do
				var_5_1(iter_5_3)
			end
		end

		return var_5_0
	end)(), (function()
		local var_8_0 = {}

		for iter_8_0, iter_8_1 in ipairs(pg.music_album.all) do
			if pg.music_album[iter_8_1].cover and pg.music_album[iter_8_1].cover ~= "" then
				table.insert(var_8_0, MusicCollectionConst.MUSIC_COVER_PATH_PREFIX .. pg.music_album[iter_8_1].cover)
			end
		end

		for iter_8_2, iter_8_3 in ipairs(pg.music_collect_config.all) do
			table.insert(var_8_0, MusicCollectionConst.MUSIC_SONG_PATH_PREFIX .. pg.music_collect_config[iter_8_3].music .. ".b")
		end

		return var_8_0
	end)()))
end

function CollectionScene:setShipGroups(arg_9_1)
	self.shipGroups = arg_9_1
end

function CollectionScene:setAwards(arg_10_1)
	self.awards = arg_10_1
end

function CollectionScene:setCollectionRate(arg_11_1, arg_11_2, arg_11_3)
	self.rate = arg_11_1
	self.count = arg_11_2
	self.totalCount = arg_11_3
end

function CollectionScene:setLinkCollectionCount(arg_12_1)
	self.linkCount = arg_12_1
end

function CollectionScene:setPlayer(arg_13_1)
	self.player = arg_13_1
end

function CollectionScene:setProposeList(arg_14_1)
	self.proposeList = arg_14_1
end

function CollectionScene:init()
	self:initEvents()

	self.blurPanel = self._tf:Find("blur_panel")
	self.top = self._tf:Find("blur_panel/adapt/top")
	self.leftPanel = self._tf:Find("blur_panel/adapt/left_length")
	self.backBtn = findTF(self.top, "back_btn")
	self.contextData.toggle = self.contextData.toggle or 2
	self.toggles = {
		self.leftPanel:Find("frame/tagRoot/card"),
		self.leftPanel:Find("frame/tagRoot/display"),
		self.leftPanel:Find("frame/tagRoot/trans"),
		self.leftPanel:Find("frame/tagRoot/manga"),
		self.leftPanel:Find("frame/tagRoot/gallery"),
		self.leftPanel:Find("frame/tagRoot/music")
	}
	self.toggleUpdates = {
		"initCardPanel",
		"initDisplayPanel",
		"initCardPanel",
		"initMangaPanel",
		"initGalleryPanel",
		"initMusicPanel"
	}
	self.cardList = self._tf:Find("main/list_card/scroll"):GetComponent("LScrollRect")

	function self.cardList.onInitItem(arg_16_0)
		self:onInitCard(arg_16_0)
	end

	function self.cardList.onUpdateItem(arg_17_0, arg_17_1)
		self:onUpdateCard(arg_17_0, arg_17_1)
	end

	function self.cardList.onReturnItem(arg_18_0, arg_18_1)
		self:onReturnCard(arg_18_0, arg_18_1)
	end

	self.cardItems = {}
	self.cardContent = tf(self.cardList):Find("ships")
	self.contextData.cardToggle = self.contextData.cardToggle or 1
	self.cardToggleGroup = self._tf:Find("main/list_card/types")
	self.cardToggles = {
		self.cardToggleGroup:Find("char"),
		self.cardToggleGroup:Find("link"),
		self.cardToggleGroup:Find("blueprint"),
		self.cardToggleGroup:Find("meta")
	}
	self.cardList.decelerationRate = 0.07

	local var_15_0 = self.cardContent:GetComponentInChildren(typeof(GridLayoutGroup))

	if var_15_0.cellSize.x + var_15_0.spacing.x > 0 then
		var_15_0.constraintCount = math.max(6, (math.floor((tf(self.cardList).rect.width - var_15_0.padding.left - var_15_0.padding.right + var_15_0.spacing.x) / (var_15_0.cellSize.x + var_15_0.spacing.x))))
	end

	self.bonusPanel = self._tf:Find("bonus_panel")
	self.charTpl = self:getTpl("chartpl")
	self.tip = self.toggles[2]:Find("tip")
	self.favoriteVOs = {}

	for iter_15_0, iter_15_1 in ipairs(pg.storeup_data_template.all) do
		table.insert(self.favoriteVOs, (Favorite.New({
			id = iter_15_0
		})))
	end

	self.memoryGroups = _.map(pg.memory_group.all, function(arg_19_0)
		return pg.memory_group[arg_19_0]
	end)
	self.memories = nil
	self.memoryList = self._tf:Find("main/list_memory"):GetComponent("LScrollRect")

	function self.memoryList.onInitItem(arg_20_0)
		self:onInitMemory(arg_20_0)
	end

	function self.memoryList.onUpdateItem(arg_21_0, arg_21_1)
		self:onUpdateMemory(arg_21_0, arg_21_1)
	end

	function self.memoryList.onReturnItem(arg_22_0, arg_22_1)
		self:onReturnMemory(arg_22_0, arg_22_1)
	end

	self.memoryViewport = self._tf:Find("main/list_memory/viewport")
	self.memoriesGrid = self._tf:Find("main/list_memory/viewport/memories"):GetComponent(typeof(GridLayoutGroup))
	self.memoryItems = {}
	self.memoryMask = self._tf:Find("blur_panel/story_mask")

	setActive(tf(self.memoryList):Find("memory"), false)
	setActive(self.memoryMask, false)

	self.memoryTogGroup = self.top:Find("memory")

	setActive(self.memoryTogGroup, false)

	self.memoryToggles = {
		self.top:Find("memory/0"),
		self.top:Find("memory/1"),
		self.top:Find("memory/2"),
		self.top:Find("memory/3")
	}
	self.memoryFilterIndex = {
		true,
		true,
		true
	}
	self.galleryPanelContainer = self._tf:Find("main/GalleryContainer")
	self.musicPanelContainer = self._tf:Find("main/MusicContainer")
	self.mangaPanelContainer = self._tf:Find("main/MangaContainer")

	self:initIndexPanel()
end

function CollectionScene:didEnter()
	onButton(self, self.backBtn, function()
		self.contextData.cardScrollValue = 0

		self:emit(CollectionScene.ON_BACK)
	end, SFX_CANCEL)

	self.helpBtn = self.leftPanel:Find("help_btn")

	onButton(self, self.helpBtn, function()
		if self.contextData.toggle == CollectionScene.MUSIC_INDEX then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = pg.gametip.NewMusic_help.tip
			})
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				type = MSGBOX_TYPE_HELP,
				helps = pg.gametip.collection_help.tip
			})
		end
	end, SFX_PANEL)

	local var_23_0 = self.top:Find("stamp")

	setActive(var_23_0, getProxy(TaskProxy):mingshiTouchFlagEnabled())
	onButton(self, var_23_0, function()
		getProxy(TaskProxy):dealMingshiTouchFlag(8)
	end, SFX_CONFIRM)

	for iter_23_0, iter_23_1 in ipairs(self.toggles) do
		if PLATFORM_CODE == PLATFORM_CH and (iter_23_0 == 1 or iter_23_0 == 3) and LOCK_COLLECTION then
			setActive(iter_23_1, false)
		else
			onToggle(self, iter_23_1, function(arg_27_0)
				if arg_27_0 then
					if self.contextData.toggle ~= iter_23_0 then
						if self.contextData.toggle == CollectionScene.SHIPCOLLECTION_INDEX then
							setActive(self.helpBtn, false)

							if self.bulinTip then
								self.bulinTip.buffer:Hide()
							end

							if self.contextData.cardToggle == 1 then
								self.contextData.cardScrollValue = self.cardList.value
							end
						end

						self.contextData.toggle = iter_23_0

						if self.toggleUpdates[iter_23_0] then
							self[self.toggleUpdates[iter_23_0]](self)
							self:calFavoriteRate()
						end
					end

					if iter_23_0 == CollectionScene.SHIPCOLLECTION_INDEX then
						setActive(self.helpBtn, true)

						local var_27_0 = getProxy(SettingsProxy)

						if not var_27_0:IsShowCollectionHelp() then
							triggerButton(self.helpBtn)
							var_27_0:SetCollectionHelpFlag(true)
						end

						if self.bulinTip then
							self.bulinTip.buffer:Show()
						else
							self.bulinTip = AprilFoolBulinSubView.ShowAprilFoolBulin(self, self._tf:Find("main"))
						end
					end

					if iter_23_0 ~= CollectionScene.MUSIC_INDEX then
						if self.musicView and self.musicView:CheckState(BaseSubView.STATES.INITED) then
							self.musicView:tryPauseMusic()
							self.musicView:closeAlbumListPanel()
						end

						pg.BgmMgr.GetInstance():ContinuePlay()
					elseif iter_23_0 == CollectionScene.MUSIC_INDEX then
						pg.BgmMgr.GetInstance():StopPlay()

						if self.musicView and self.musicView:CheckState(BaseSubView.STATES.INITED) then
							self.musicView:tryPlayMusic()
						end
					end
				end
			end, SFX_UI_TAG)
		end
	end

	for iter_23_2, iter_23_3 in ipairs(self.memoryToggles) do
		onToggle(self, iter_23_3, function(arg_28_0)
			if arg_28_0 then
				if iter_23_2 == 1 then
					self.memoryFilterIndex = {
						true,
						true,
						true
					}
				else
					for iter_28_0 in ipairs(self.memoryFilterIndex) do
						self.memoryFilterIndex[iter_28_0] = iter_23_2 - 1 == iter_28_0
					end
				end

				self:memoryFilter()
			end
		end, SFX_UI_TAG)
	end

	self.contextData.toggle = -1

	triggerToggle(self.toggles[self.contextData.toggle], true)

	if self.contextData.memoryGroup and pg.memory_group[self.contextData.memoryGroup] then
		self:showSubMemories(pg.memory_group[self.contextData.memoryGroup])
	else
		triggerToggle(self.memoryToggles[1], true)
	end

	for iter_23_4, iter_23_5 in ipairs(self.cardToggles) do
		triggerToggle(iter_23_5, self.contextData.cardToggle == iter_23_4)
		onToggle(self, iter_23_5, function(arg_29_0)
			if arg_29_0 and self.contextData.cardToggle ~= iter_23_4 then
				if self.contextData.cardToggle == 1 then
					self.contextData.cardScrollValue = self.cardList.value
				end

				self.contextData.cardToggle = iter_23_4

				self:initCardPanel()
				self:calFavoriteRate()
			end
		end)
	end

	self:calFavoriteRate()
	self:OverlayPanel(self.blurPanel)
	onButton(self, self.bonusPanel, function()
		self:closeBonus()
	end, SFX_PANEL)
end

function CollectionScene:updateCollectNotices(arg_31_1)
	setActive(self.tip, arg_31_1)
	setActive(self.toggles[CollectionScene.GALLERY_INDEX]:Find("tip"), getProxy(AppreciateProxy):isGalleryHaveNewRes())
	setActive(self.toggles[CollectionScene.MUSIC_INDEX]:Find("tip"), getProxy(AppreciateProxy):isMusicHaveNewRes())
	setActive(self.toggles[CollectionScene.MANGA_INDEX]:Find("tip"), getProxy(AppreciateProxy):isMangaHaveNewRes())
end

function CollectionScene:calFavoriteRate()
	local var_32_0 = self.contextData.toggle == 1 and self.contextData.cardToggle == 2

	setActive(self.top:Find("total/char"), not (self.contextData.toggle == 1 and self.contextData.cardToggle == 2))
	setActive(self.top:Find("total/link"), var_32_0)
	setText(self.top:Find("total/char/rate/Text"), self.rate * 100 .. "%")
	setText(self.top:Find("total/char/count/Text"), self.count .. "/" .. self.totalCount)
	setText(self.top:Find("total/link/count/Text"), self.linkCount)
end

function CollectionScene:initCardPanel()
	GetSpriteFromAtlasAsync("ui/share/index_atlas", self:isDefaultStatus() and "shaixuan_off" or "shaixuan_on", function(arg_34_0)
		setImageSprite(self.indexBtn, arg_34_0, true)
	end)

	if self.contextData.toggle == 1 then
		setActive(self.cardToggleGroup, true)
		self:cardFilter()
	elseif self.contextData.toggle == 3 then
		setActive(self.cardToggleGroup, false)
		self:transFilter()
	end

	table.sort(self.codeShips, function(arg_35_0, arg_35_1)
		return arg_35_0.index_id < arg_35_1.index_id
	end)
	self.cardList:SetTotalCount(#self.codeShips, self.contextData.cardScrollValue or 0)
end

function CollectionScene:initIndexPanel()
	self.indexBtn = self.top:Find("index_button")

	onButton(self, self.indexBtn, function()
		local var_37_0 = Clone(CollectionScene.ShipIndexData)

		if self.contextData.toggle == 1 and self.contextData.cardToggle == 2 then
			var_37_0.customPanels.campIndex = nil
			var_37_0.groupList[2] = nil
		end

		var_37_0.indexDatas = Clone(CollectionScene.ShipIndex)

		function var_37_0:callback()
			CollectionScene.ShipIndex.typeIndex = self.typeIndex

			if self.campIndex then
				CollectionScene.ShipIndex.campIndex = self.campIndex
			end

			CollectionScene.ShipIndex.rarityIndex = self.rarityIndex
			CollectionScene.ShipIndex.collExtraIndex = self.collExtraIndex

			self:initCardPanel()
		end

		self:emit(CollectionScene.ON_INDEX, var_37_0)
	end, SFX_PANEL)
end

function CollectionScene:onInitCard(arg_39_1)
	if self.exited then
		return
	end

	local var_39_0 = CollectionShipCard.New(arg_39_1)

	onButton(self, var_39_0.go, function()
		if not self.isClicked then
			self.isClicked = true

			LeanTween.delayedCall(0.2, System.Action(function()
				self.isClicked = false

				if not var_39_0:getIsInited() then
					return
				end

				if var_39_0.state == ShipGroup.STATE_UNLOCK then
					self.contextData.cardScrollValue = self.cardList.value

					self:emit(CollectionScene.SHOW_DETAIL, var_39_0.showTrans, var_39_0.shipGroup.id)
				elseif var_39_0.state == ShipGroup.STATE_NOTGET then
					if var_39_0.showTrans == true and var_39_0.shipGroup.trans == true then
						return
					end

					if var_39_0.config then
						self:showObtain(var_39_0.config.description, var_39_0.shipGroup:getShipConfigId())
					end
				end
			end))
		end
	end, SOUND_BACK)

	self.cardItems[arg_39_1] = var_39_0
end

function CollectionScene:showObtain(arg_42_1, arg_42_2)
	local var_42_0 = {
		type = MSGBOX_TYPE_OBTAIN,
		shipId = arg_42_2,
		list = arg_42_1,
		mediatorName = CollectionMediator.__cname
	}

	if PLATFORM_CODE == PLATFORM_CH and HXSet.isHx() then
		var_42_0.unknown_small = true
	end

	self.contextData.cardScrollValue = self.cardList.value

	pg.MsgboxMgr.GetInstance():ShowMsgBox(var_42_0)
end

function CollectionScene:skipIn(arg_43_1, arg_43_2)
	self.contextData.displayGroupId = arg_43_2

	triggerToggle(self.toggles[arg_43_1], true)
end

function CollectionScene:onUpdateCard(arg_44_1, arg_44_2)
	if self.exited then
		return
	end

	local var_44_0 = self.cardItems[arg_44_2]

	if not self.cardItems[arg_44_2] then
		self:onInitCard(arg_44_2)

		var_44_0 = self.cardItems[arg_44_2]
	end

	local var_44_1 = self.codeShips[arg_44_1 + 1]

	if not self.codeShips[arg_44_1 + 1] then
		return
	end

	var_44_0:update(var_44_1.code, var_44_1.group, var_44_1.showTrans, (var_44_1.group or nil) and self.proposeList[var_44_1.group.id], var_44_1.id)
end

function CollectionScene:onReturnCard(arg_45_1, arg_45_2)
	if self.exited then
		return
	end

	if self.cardItems[arg_45_2] then
		self.cardItems[arg_45_2]:clear()
	end
end

function CollectionScene:cardFilter()
	self.codeShips = {}

	local var_46_0 = _.filter(pg.ship_data_group.all, function(arg_47_0)
		return pg.ship_data_group[arg_47_0].handbook_type == self.contextData.cardToggle - 1
	end)

	table.sort(var_46_0)

	for iter_46_0, iter_46_1 in ipairs(var_46_0) do
		local var_46_1 = pg.ship_data_group[iter_46_1]
		local var_46_2 = self.shipGroups[pg.ship_data_group[iter_46_1].group_type] or ShipGroup.New({
			id = var_46_1.group_type
		})

		if ShipIndexConst.filterByType(var_46_2, CollectionScene.ShipIndex.typeIndex) and (self.contextData.cardToggle == 2 or ShipIndexConst.filterByCamp(var_46_2, CollectionScene.ShipIndex.campIndex)) and self.contextData.cardToggle == 4 == Nation.IsMeta(ShipGroup.getDefaultShipConfig(var_46_1.group_type).nationality) and ShipIndexConst.filterByRarity(var_46_2, CollectionScene.ShipIndex.rarityIndex) and ShipIndexConst.filterByCollExtra(var_46_2, CollectionScene.ShipIndex.collExtraIndex) then
			self.codeShips[#self.codeShips + 1] = {
				showTrans = false,
				id = iter_46_1,
				code = iter_46_1 - (self.contextData.cardToggle - 1) * 10000,
				group = self.shipGroups[var_46_1.group_type],
				index_id = var_46_1.index_id
			}
		end
	end
end

function CollectionScene:transFilter()
	self.codeShips = {}

	local var_48_0 = _.filter(pg.ship_data_group.all, function(arg_49_0)
		return pg.ship_data_group[arg_49_0].handbook_type == 0
	end)

	table.sort(var_48_0)

	for iter_48_0, iter_48_1 in ipairs(var_48_0) do
		local var_48_1 = pg.ship_data_group[iter_48_1]

		if pg.ship_data_trans[pg.ship_data_group[iter_48_1].group_type] then
			local var_48_2 = self.shipGroups[var_48_1.group_type] or ShipGroup.New({
				remoulded = true,
				id = var_48_1.group_type
			})

			if ShipIndexConst.filterByType(var_48_2, CollectionScene.ShipIndex.typeIndex) and ShipIndexConst.filterByCamp(var_48_2, CollectionScene.ShipIndex.campIndex) and ShipIndexConst.filterByRarity(var_48_2, CollectionScene.ShipIndex.rarityIndex) and ShipIndexConst.filterByCollExtra(var_48_2, CollectionScene.ShipIndex.collExtraIndex) then
				self.codeShips[#self.codeShips + 1] = {
					showTrans = true,
					id = iter_48_1,
					code = 3000 + iter_48_1,
					group = var_48_2.trans and var_48_2 or nil,
					index_id = var_48_1.index_id
				}
			end
		end
	end
end

function CollectionScene:sortDisplay()
	table.sort(self.favoriteVOs, function(arg_51_0, arg_51_1)
		local var_51_0 = arg_51_0:getState(self.shipGroups, self.awards)
		local var_51_1 = arg_51_1:getState(self.shipGroups, self.awards)

		if var_51_0 == var_51_1 then
			return arg_51_0.id < arg_51_1.id
		else
			return var_51_0 < var_51_1
		end
	end)

	local var_50_0 = 0

	for iter_50_0, iter_50_1 in ipairs(self.favoriteVOs) do
		if iter_50_1:containShipGroup(self.contextData.displayGroupId) then
			var_50_0 = iter_50_0

			break
		end
	end

	self.displayRect:SetTotalCount(#self.favoriteVOs, self.displayRect:HeadIndexToValue(var_50_0 - 1))
end

function CollectionScene:initDisplayPanel()
	if not self.isInitDisplay then
		self.isInitDisplay = true
		self.displayRect = self._tf:Find("main/list_display"):GetComponent("LScrollRect")
		self.displayRect.decelerationRate = 0.07

		function self.displayRect.onInitItem(arg_53_0)
			self:initFavoriteCard(arg_53_0)
		end

		function self.displayRect.onUpdateItem(arg_54_0, arg_54_1)
			self:updateFavoriteCard(arg_54_0, arg_54_1)
		end

		self.favoriteCards = {}
	end

	self:sortDisplay()
end

function CollectionScene:initFavoriteCard(arg_55_1)
	if self.exited then
		return
	end

	local var_55_0 = FavoriteCard.New(arg_55_1, self.charTpl)

	onButton(self, var_55_0.awardTF, function()
		if var_55_0.state == Favorite.STATE_AWARD then
			self:emit(CollectionScene.GET_AWARD, var_55_0.favoriteVO.id, var_55_0.favoriteVO:getNextAwardIndex(var_55_0.awards))
		elseif var_55_0.state == Favorite.STATE_LOCK then
			pg.TipsMgr.GetInstance():ShowTips(i18n("collection_lock"))
		elseif var_55_0.state == Favorite.STATE_FETCHED then
			pg.TipsMgr.GetInstance():ShowTips(i18n("collection_fetched"))
		elseif var_55_0.state == Favorite.STATE_STATE_WAIT then
			pg.TipsMgr.GetInstance():ShowTips(i18n("collection_nostar"))
		end
	end, SFX_PANEL)
	onButton(self, var_55_0.box, function()
		self:openBonus(var_55_0.favoriteVO)
	end, SFX_PANEL)

	self.favoriteCards[arg_55_1] = var_55_0
end

function CollectionScene:updateFavoriteCard(arg_58_1, arg_58_2)
	if self.exited then
		return
	end

	if not self.favoriteCards[arg_58_2] then
		self:initFavoriteCard(arg_58_2)
	end

	self.favoriteCards[arg_58_2]:update(self.favoriteVOs[arg_58_1 + 1], self.shipGroups, self.awards)
end

function CollectionScene:openBonus(arg_59_1)
	if not self.isInitBound then
		self.isInitBound = true
		self.boundName = findTF(self.bonusPanel, "frame/name/Text"):GetComponent(typeof(Text))
		self.progressSlider = findTF(self.bonusPanel, "frame/process"):GetComponent(typeof(Slider))
	end

	pg.UIMgr.GetInstance():BlurPanel(self.bonusPanel)
	setActive(self.bonusPanel, true)

	self.boundName.text = arg_59_1:getConfig("name")

	local var_59_0 = arg_59_1:getConfig("award_display")
	local var_59_1 = arg_59_1:getConfig("level")

	for iter_59_0, iter_59_1 in ipairs(var_59_1) do
		local var_59_2 = var_59_0[iter_59_0]
		local var_59_3 = findTF(self.bonusPanel, "frame/awards/award" .. iter_59_0)

		setText(findTF(var_59_3, "process"), iter_59_1)

		local var_59_4 = arg_59_1:getAwardState(self.shipGroups, self.awards, iter_59_0)

		setActive(findTF(var_59_3, "item_tpl/unfinish"), var_59_4 == Favorite.STATE_WAIT)
		setActive(findTF(var_59_3, "item_tpl/get"), var_59_4 == Favorite.STATE_AWARD)
		setActive(findTF(var_59_3, "item_tpl/got"), var_59_4 == Favorite.STATE_FETCHED)
		setActive(findTF(var_59_3, "item_tpl/lock"), var_59_4 == Favorite.STATE_LOCK)
		setActive(findTF(var_59_3, "item_tpl/icon_bg"), var_59_4 ~= Favorite.STATE_LOCK)
		setActive(findTF(var_59_3, "item_tpl/bg"), var_59_4 ~= Favorite.STATE_LOCK)

		if var_59_2 then
			local var_59_5 = {
				count = 0,
				type = var_59_2[1],
				id = var_59_2[2]
			}

			updateDrop(findTF(var_59_3, "item_tpl"), var_59_5)

			var_59_5.count = var_59_2[3]

			onButton(self, var_59_3, function()
				self:emit(CollectionScene.ON_DROP, var_59_5)
			end, SFX_PANEL)
		else
			GetOrAddComponent(var_59_3, typeof(Button)).onClick:RemoveAllListeners()
		end
	end

	self.progressSlider.value = arg_59_1:getStarCount(self.shipGroups) / var_59_1[#var_59_1]
end

function CollectionScene:closeBonus()
	pg.UIMgr.GetInstance():UnOverlayPanel(self.bonusPanel, self._tf)
	setActive(self.bonusPanel, false)
end

function CollectionScene:showSubMemories(arg_62_1)
	self.contextData.memoryGroup = arg_62_1.id
	self.memories = _.map(arg_62_1.memories, function(arg_63_0)
		return pg.memory_template[arg_63_0]
	end)

	for iter_62_0 in ipairs(self.memories) do
		self.memories[iter_62_0].index = iter_62_0
	end

	self.memoryList:SetTotalCount(#self.memories, 0)
	setActive(self.top:Find("memory"), false)
end

local var_0_1 = 3

function CollectionScene:return2MemoryGroup()
	self.contextData.memoryGroup = nil
	self.memories = nil

	local var_64_0 = 0

	if self.contextData.memoryGroup then
		local var_64_1 = 0

		for iter_64_0, iter_64_1 in ipairs(self.memoryGroups) do
			if iter_64_1.id == self.contextData.memoryGroup then
				var_64_1 = iter_64_0

				break
			end
		end

		if var_64_1 >= 0 then
			var_64_0 = ((self.memoriesGrid.cellSize.y + self.memoriesGrid.spacing.y) * math.floor((var_64_1 - 1) / var_0_1) + self.memoryList.paddingFront) / ((self.memoriesGrid.cellSize.y + self.memoriesGrid.spacing.y) * math.ceil(#self.memoryGroups / var_0_1) - self.memoryViewport.rect.height)
			var_64_0 = Mathf.Clamp01(var_64_0)
		end
	end

	self.memoryList:SetTotalCount(#self.memoryGroups, var_64_0)
	setActive(self.top:Find("memory"), true)
end

function CollectionScene:initMemoryPanel()
	local var_65_0 = getProxy(ActivityProxy):getActivityById(ActivityConst.QIXI_ACTIVITY_ID)

	if var_65_0 and not var_65_0:isEnd() then
		local var_65_1 = _.flatten((var_65_0:getConfig("config_data")))
		local var_65_2 = getProxy(TaskProxy):getTaskById(var_65_1[#var_65_1])

		if var_65_2 and not var_65_2:isFinish() then
			pg.NewStoryMgr.GetInstance():Play("HOSHO8", function()
				self:emit(CollectionScene.ACTIVITY_OP, {
					cmd = 2,
					activity_id = var_65_0.id
				})
			end, true)
		end
	end

	self:memoryFilter()
end

function CollectionScene:onInitMemory(arg_67_1)
	if self.exited then
		return
	end

	local var_67_0 = MemoryCard.New(arg_67_1)

	onButton(self, var_67_0.go, function()
		if var_67_0.info then
			if var_67_0.isGroup then
				self:showSubMemories(var_67_0.info)
			elseif var_67_0.info.is_open ~= 1 then
				if pg.NewStoryMgr.GetInstance():IsPlayed(var_67_0.info.unlock_pre, true) then
					self:playMemory(var_67_0.info)
				end
			end
		end
	end, SOUND_BACK)

	self.memoryItems[arg_67_1] = var_67_0
end

function CollectionScene:onUpdateMemory(arg_69_1, arg_69_2)
	if self.exited then
		return
	end

	local var_69_0 = self.memoryItems[arg_69_2]

	if not self.memoryItems[arg_69_2] then
		self:onInitMemory(arg_69_2)

		var_69_0 = self.memoryItems[arg_69_2]
	end

	if self.memories then
		var_69_0:update(false, self.memories[arg_69_1 + 1])
	else
		var_69_0:update(true, self.memoryGroups[arg_69_1 + 1])
	end

	_.any({
		var_69_0.lock,
		var_69_0.normal,
		var_69_0.group
	}, function(arg_70_0)
		local var_70_0 = isActive(arg_70_0)

		if var_70_0 then
			var_69_0.go:GetComponent(typeof(Button)).targetGraphic = arg_70_0:GetComponent(typeof(Image))
		end

		return var_70_0
	end)
end

function CollectionScene:onReturnMemory(arg_71_1, arg_71_2)
	if self.exited then
		return
	end

	if self.memoryItems[arg_71_2] then
		self.memoryItems[arg_71_2]:clear()
	end
end

function CollectionScene:playMemory(arg_72_1)
	if arg_72_1.type == 1 then
		local var_72_0 = findTF(self.memoryMask, "pic")

		if string.len(arg_72_1.mask) > 0 then
			setActive(var_72_0, true)

			var_72_0:GetComponent(typeof(Image)).sprite = LoadSprite(arg_72_1.mask)
		else
			setActive(var_72_0, false)
		end

		setActive(self.memoryMask, true)
		pg.NewStoryMgr.GetInstance():Play(arg_72_1.story, function()
			setActive(self.memoryMask, false)
		end, true)
	elseif arg_72_1.type == 2 then
		self:emit(CollectionScene.BEGIN_STAGE, {
			memory = true,
			system = SYSTEM_PERFORM,
			stageId = pg.NewStoryMgr.GetInstance():StoryName2StoryId(arg_72_1.story)
		})
	end
end

function CollectionScene:memoryFilter()
	self.memoryGroups = {}

	for iter_74_0, iter_74_1 in ipairs(pg.memory_group.all) do
		if self.memoryFilterIndex[pg.memory_group[iter_74_1].type] then
			table.insert(self.memoryGroups, pg.memory_group[iter_74_1])
		end
	end

	table.sort(self.memoryGroups, function(arg_75_0, arg_75_1)
		return arg_75_0.id < arg_75_1.id
	end)
	self.memoryList:SetTotalCount(#self.memoryGroups, 0)
end

function CollectionScene:willExit()
	if self.bulinTip then
		self.bulinTip:Destroy()

		self.bulinTip = nil
	end

	if self.tweens then
		cancelTweens(self.tweens)
	end

	self:UnOverlayPanel(self.blurPanel, self._tf)

	if self.bonusPanel.gameObject.activeSelf then
		self:closeBonus()
	end

	Destroy(self.bonusPanel)

	self.bonusPanel = nil

	for iter_76_0, iter_76_1 in pairs(self.cardItems) do
		iter_76_1:clear()
	end

	if self.resPanel then
		self.resPanel:exit()

		self.resPanel = nil
	end

	if self.galleryView then
		self.galleryView:Destroy()

		self.galleryView = nil
	end

	if self.musicView then
		self.musicView:Destroy()

		self.musicView = nil
	end

	if self.mangaView then
		self.mangaView:Destroy()

		self.mangaView = nil
	end
end

function CollectionScene:initGalleryPanel()
	if not self.galleryView then
		self.galleryView = GalleryView.New(self.galleryPanelContainer, self.event, self.contextData)

		self.galleryView:RegisterView(self)
		self.galleryView:Reset()
		self.galleryView:Load()
	end
end

function CollectionScene:initMusicPanel()
	if not self.musicView then
		self.musicView = MusicCollectionView.New(self.musicPanelContainer, self.event, self.contextData)

		self.musicView:Reset()
		self.musicView:Load()
		pg.CriMgr.GetInstance():StopBGM()
	end
end

function CollectionScene:initMangaPanel()
	if not self.mangaView then
		self.mangaView = MangaView.New(self.mangaPanelContainer, self.event, self.contextData)

		self.mangaView:Reset()
		self.mangaView:Load()
	end
end

function CollectionScene:initEvents()
	self:bind(CollectionScene.UPDATE_RED_POINT, function()
		self:updateCollectNotices()
	end)
end

function CollectionScene:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if self.bonusPanel.gameObject.activeSelf then
		self:closeBonus()

		return
	end

	if self.galleryView then
		if self.galleryView:onBackPressed() == true then
			self.galleryView:Destroy()

			self.galleryView = nil
		else
			return
		end
	end

	if self.musicView then
		if self.musicView:onBackPressed() == true then
			self.musicView:Destroy()

			self.musicView = nil
		else
			return
		end
	end

	if self.mangaView then
		if self.mangaView:onBackPressed() == true then
			self.mangaView:Destroy()

			self.mangaView = nil
		else
			return
		end
	end

	triggerButton(self.backBtn)
end

return CollectionScene
