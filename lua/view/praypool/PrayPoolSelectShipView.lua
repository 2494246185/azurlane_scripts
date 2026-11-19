local PrayPoolSelectShipView = class("PrayPoolSelectShipView", import("..base.BaseSubView"))

PrayPoolSelectShipView.WIDTH_MIN = 328
PrayPoolSelectShipView.WIDTH_MAX = 438
PrayPoolSelectShipView.FONT_SIZE_MIN = 55
PrayPoolSelectShipView.FONT_SIZE_MID = 44
PrayPoolSelectShipView.FONT_SIZE_MAX = 34

function PrayPoolSelectShipView:getResource()
	local var_1_0 = {
		"weaponframes"
	}

	for iter_1_0, iter_1_1 in ipairs(pg.activity_ship_create.all) do
		for iter_1_2, iter_1_3 in ipairs(pg.activity_ship_create[iter_1_1].pickup_list or {}) do
			table.insertto(var_1_0, ResPathSupport.GetPaintingSquareIconListByPaintingName(Ship.getPaintingName(iter_1_3)))
		end
	end

	for iter_1_4, iter_1_5 in ipairs(getProxy(PrayProxy):getSelectedShipIDList() or {}) do
		local var_1_2 = Ship.getPaintingName(iter_1_5)

		table.insertto(var_1_0, ResPathSupport.GetPaintingListByPaintingName(var_1_2))
		table.insertto(var_1_0, ResPathSupport.GetPaintingHeroHrzIconListByPaintingName(var_1_2))
	end

	return table.insertto(var_1_0, PrayPoolSelectShipView.super.getResource(self))
end

function PrayPoolSelectShipView:getUIName()
	return "PrayPoolSelectShipView"
end

PrayPoolSelectShipView.ShipIndex = {
	typeIndex = ShipIndexConst.TypeAll,
	campIndex = ShipIndexConst.CampAll,
	rarityIndex = ShipIndexConst.RarityAll
}
PrayPoolSelectShipView.ShipIndexData = {
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
		}
	}
}

function PrayPoolSelectShipView:OnInit()
	self:initData()
	self:initUI()
	self:updateUI()
	self:Show()
end

function PrayPoolSelectShipView:OnDestroy()
	return
end

function PrayPoolSelectShipView:OnBackPress()
	return
end

function PrayPoolSelectShipView:initData()
	self.prayProxy = getProxy(PrayProxy)
	self.poolType = self.prayProxy:getSelectedPoolType()
	self.selectedCount = self.prayProxy:getSelectedShipCount()
	self.pickUpNum = pg.activity_ship_create[self.poolType].pickup_num
	self.fliteList = Clone(pg.activity_ship_create[self.poolType].pickup_list)

	self:orderIDListByRarity(self.fliteList)

	self.orderFullList = Clone(self.fliteList)
end

function PrayPoolSelectShipView:initUI()
	self.minRaritySpriteMap = {}
	self.maxRaritySpriteMap = {}
	self.ratioSpriteMap = {}

	local var_7_0 = self._tf:Find("MiniRarity")
	local var_7_1 = self._tf:Find("MaxRarity")
	local var_7_2 = self._tf:Find("Ratio")

	for iter_7_0 = 2, 6 do
		local var_7_3 = getImageSprite(var_7_1:Find(tostring(iter_7_0)))
		local var_7_4 = getImageSprite(var_7_2:Find(tostring(iter_7_0)))

		self.minRaritySpriteMap[iter_7_0] = getImageSprite(var_7_0:Find(tostring(iter_7_0)))
		self.maxRaritySpriteMap[iter_7_0] = var_7_3
		self.ratioSpriteMap[iter_7_0] = var_7_4
	end

	self.poolSpriteMap = {}

	local var_7_5 = self._tf:Find("Pool")

	for iter_7_1 = 1, 3 do
		self.poolSpriteMap[iter_7_1] = getImageSprite(var_7_5:Find(tostring(iter_7_1)))
	end

	self.poolNameImg = self._tf:Find("PoolNameImg")
	self.shipCardTpl = self._tf:Find("ShipCardTpl")

	local var_7_6 = self._tf:Find("SelectedShipMax")
	local var_7_7 = self._tf:Find("SelectedShipMini")

	self.selectedShipTFMap = {}
	self.selectedShipTFMap.Max = {
		lightTF = var_7_6:Find("Light"),
		var_7_6:Find("Ship1"),
		(var_7_6:Find("Ship2"))
	}
	self.selectedShipTFMap.Min = {
		lightTF = var_7_7:Find("Light"),
		var_7_7:Find("Ship1"),
		(var_7_7:Find("Ship2"))
	}

	local var_7_8 = self:isMinPrefs()

	setActive(var_7_6, not var_7_8)
	setActive(var_7_7, var_7_8)

	self.shipListArea = self._tf:Find("ShipListArea")
	self.shipListContainer = self.shipListArea:Find("Viewport/Content")
	self.shipListSC = GetComponent(self.shipListArea, "LScrollRect")

	setLocalPosition(self.shipListArea, {
		x = 0,
		y = var_7_8 and -40 or -120
	})

	self.bg2 = self._tf:Find("BG2")

	setLocalPosition(self.bg2, {
		x = 0,
		y = var_7_8 and -62.5 or -174
	})

	self.indexBtn = self._tf:Find("IndexBtn")
	self.preBtn = self._tf:Find("PreBtn")
	self.nextBtn = self._tf:Find("NextBtn")
	self.nextBtnCom = GetComponent(self.nextBtn, "Button")

	self.indexBtn:GetComponent(typeof(Image)):SetNativeSize()

	for iter_7_2, iter_7_3 in ipairs(self.selectedShipTFMap.Max) do
		iter_7_3:Find("Tip/Tip"):GetComponent(typeof(Image)):SetNativeSize()
	end

	for iter_7_4, iter_7_5 in ipairs(self.selectedShipTFMap.Min) do
		iter_7_5:Find("Tip/Tip"):GetComponent(typeof(Image)):SetNativeSize()
	end

	self.nextBtnCom.interactable = false

	setText(self._tf:Find("InstructionText"), i18n("pray_build_select_ship_instruction"))
	onButton(self, self.preBtn, function()
		self.prayProxy:updatePageState(PrayProxy.STATE_SELECT_POOL)
		self:emit(PrayPoolConst.SWITCH_TO_SELECT_POOL_PAGE, PrayProxy.STATE_SELECT_POOL)
	end, SFX_PANEL)
	onButton(self, self.nextBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("warning_pray_build_pool"),
			onYes = function()
				local function var_10_0()
					self:emit(PrayPoolConst.CLICK_BUILD_BTN, {
						pooltype = self.prayProxy:getSelectedPoolType(),
						shipIDList = self.prayProxy:getSelectedShipIDList()
					})
				end

				if not self:isMinPrefs() then
					var_10_0()
				else
					local var_10_1 = {}

					for iter_10_0, iter_10_1 in ipairs((self.prayProxy:getSelectedShipIDList())) do
						PaintingGroupConst.AddPaintingNameByShipConfigID(var_10_1, iter_10_1)
					end

					PaintingGroupConst.PaintingDownload({
						isShowBox = true,
						paintingNameList = var_10_1,
						finishFunc = var_10_0
					})
				end
			end
		})
	end, SFX_PANEL)
	onButton(self, self.indexBtn, function()
		local var_12_0 = Clone(PrayPoolSelectShipView.ShipIndexData)

		var_12_0.indexDatas = Clone(PrayPoolSelectShipView.ShipIndex)

		function var_12_0:callback()
			PrayPoolSelectShipView.ShipIndex.typeIndex = self.typeIndex
			PrayPoolSelectShipView.ShipIndex.rarityIndex = self.rarityIndex

			if self.campIndex then
				PrayPoolSelectShipView.ShipIndex.campIndex = self.campIndex
			end

			self:fliteShipIDList()
			self:updateShipList(self.fliteList)
		end

		self:emit(PrayPoolConst.CLICK_INDEX_BTN, var_12_0)
	end)
end

function PrayPoolSelectShipView:updateUI()
	setImageSprite(self.poolNameImg, self.poolSpriteMap[self.poolType], true)
	self:updateSelectedShipList()
	self:updateShipList(self.fliteList)
end

function PrayPoolSelectShipView:updateSelectedShipList()
	local var_15_0 = {}

	for iter_15_0, iter_15_1 in ipairs(self.prayProxy:getSelectedShipIDList() or {}) do
		local var_15_1 = Ship.getPaintingName(iter_15_1)

		table.insertto(var_15_0, ResPathSupport.GetPaintingListByPaintingName(var_15_1))
		table.insertto(var_15_0, ResPathSupport.GetPaintingHeroHrzIconListByPaintingName(var_15_1))
	end

	SplitPackConst.DownloadByLuaArr(var_15_0, function()
		if self:isMinPrefs() then
			self:updateMin()
		else
			self:updateMax()
		end
	end)
end

function PrayPoolSelectShipView:updateMax()
	local var_17_0 = self.prayProxy:getSelectedShipIDList()

	for iter_17_0 = 1, 2 do
		local var_17_1 = var_17_0[iter_17_0]
		local var_17_2 = self.selectedShipTFMap.Max[iter_17_0]:Find("Paint")
		local var_17_3 = self.selectedShipTFMap.Max[iter_17_0]:Find("Tip")
		local var_17_4 = self.selectedShipTFMap.Max[iter_17_0]:Find("Info")
		local var_17_5 = self.selectedShipTFMap.Max[iter_17_0]:Find("Btn")
		local var_17_6 = var_17_4:Find("Name/Text")
		local var_17_7 = self.selectedShipTFMap.Max[iter_17_0]:Find("RarityBG")

		if var_17_0[iter_17_0] then
			setActive(var_17_2, true)
			setPaintingPrefabAsync(var_17_2, Ship.getPaintingName(var_17_1), "biandui")

			if iter_17_0 == 2 then
				setLocalRotation(var_17_2, {
					z = 180
				})
			end

			setActive(var_17_3, false)
			setActive(var_17_4, true)
			setText(var_17_6, pg.ship_data_statistics[var_17_1].name)

			if #pg.ship_data_statistics[var_17_1].name <= 6 then
				var_17_4.sizeDelta = Vector2(PrayPoolSelectShipView.WIDTH_MIN, var_17_4.sizeDelta.y)
				GetComponent(var_17_6, "Text").fontSize = PrayPoolSelectShipView.FONT_SIZE_MIN

				setAnchoredPosition(var_17_6, {
					y = 14
				})
			elseif #pg.ship_data_statistics[var_17_1].name <= 21 then
				var_17_4.sizeDelta = Vector2(PrayPoolSelectShipView.WIDTH_MAX, var_17_4.sizeDelta.y)
				GetComponent(var_17_6, "Text").fontSize = PrayPoolSelectShipView.FONT_SIZE_MID

				setAnchoredPosition(var_17_6, {
					y = 19
				})
			else
				var_17_4.sizeDelta = Vector2(PrayPoolSelectShipView.WIDTH_MAX, var_17_4.sizeDelta.y)
				GetComponent(var_17_6, "Text").fontSize = PrayPoolSelectShipView.FONT_SIZE_MAX

				setAnchoredPosition(var_17_6, {
					y = 25
				})
			end

			local var_17_9 = pg.ship_data_statistics[var_17_1].rarity

			setImageSprite(var_17_4:Find("Ratio/NumImg"), self.ratioSpriteMap[pg.ship_data_statistics[var_17_1].rarity], true)
			setActive(var_17_7, true)
			setImageSprite(var_17_7, self.maxRaritySpriteMap[var_17_9])
		else
			setActive(var_17_2, false)
			setActive(var_17_3, true)
			setActive(var_17_4, false)
			setActive(var_17_7, false)
		end

		onButton(self, var_17_5, function()
			if isActive(var_17_2) then
				self.prayProxy:removeSelectedShipIDList(var_17_1)

				self.selectedCount = self.selectedCount - 1

				self:updateSelectedShipList()
				self:updateShipList(self.fliteList)
			end
		end, SFX_PANEL)
	end

	if #var_17_0 == self.pickUpNum then
		self.nextBtnCom.interactable = true

		setActive(self.selectedShipTFMap.Max.lightTF, true)
	elseif #var_17_0 < self.pickUpNum then
		self.nextBtnCom.interactable = false

		setActive(self.selectedShipTFMap.Max.lightTF, false)
	end
end

function PrayPoolSelectShipView:updateMin()
	local var_19_0 = self.prayProxy:getSelectedShipIDList()

	for iter_19_0 = 1, 2 do
		local var_19_1 = var_19_0[iter_19_0]
		local var_19_2 = self.selectedShipTFMap.Min[iter_19_0]:Find("Mask/Paint")
		local var_19_3 = self.selectedShipTFMap.Min[iter_19_0]:Find("Tip")
		local var_19_4 = self.selectedShipTFMap.Min[iter_19_0]:Find("Info")
		local var_19_5 = self.selectedShipTFMap.Min[iter_19_0]:Find("Btn")
		local var_19_6 = var_19_4:Find("Name/Text")
		local var_19_7 = self.selectedShipTFMap.Min[iter_19_0]:Find("Mask/RarityBG")

		if var_19_0[iter_19_0] then
			setActive(var_19_2, true)
			setImageSprite(var_19_2, LoadSprite("herohrzicon/" .. Ship.getPaintingName(var_19_1)))
			setActive(var_19_3, false)
			setActive(var_19_4, true)
			setText(var_19_6, pg.ship_data_statistics[var_19_1].name)

			if #pg.ship_data_statistics[var_19_1].name <= 6 then
				var_19_4.sizeDelta = Vector2(PrayPoolSelectShipView.WIDTH_MIN, var_19_4.sizeDelta.y)
				GetComponent(var_19_6, "Text").fontSize = PrayPoolSelectShipView.FONT_SIZE_MIN

				setAnchoredPosition(var_19_6, {
					y = 0
				})
			elseif #pg.ship_data_statistics[var_19_1].name <= 21 then
				var_19_4.sizeDelta = Vector2(PrayPoolSelectShipView.WIDTH_MAX, var_19_4.sizeDelta.y)
				GetComponent(var_19_6, "Text").fontSize = PrayPoolSelectShipView.FONT_SIZE_MID

				setAnchoredPosition(var_19_6, {
					y = 5
				})
			else
				var_19_4.sizeDelta = Vector2(PrayPoolSelectShipView.WIDTH_MAX, var_19_4.sizeDelta.y)
				GetComponent(var_19_6, "Text").fontSize = PrayPoolSelectShipView.FONT_SIZE_MAX

				setAnchoredPosition(var_19_6, {
					y = 11
				})
			end

			Canvas.ForceUpdateCanvases()
			setImageSprite(var_19_4:Find("Ratio/NumImg"), self.ratioSpriteMap[pg.ship_data_statistics[var_19_1].rarity], true)
			setActive(var_19_7, true)
			setImageSprite(var_19_7, self.minRaritySpriteMap[pg.ship_data_statistics[var_19_1].rarity])
		else
			setActive(var_19_2, false)
			setActive(var_19_3, true)
			setActive(var_19_4, false)
			setActive(var_19_7, false)
		end

		onButton(self, var_19_5, function()
			if isActive(var_19_2) then
				self.prayProxy:removeSelectedShipIDList(var_19_1)

				self.selectedCount = self.selectedCount - 1

				self:updateSelectedShipList()
				self:updateShipList(self.fliteList)
			end
		end, SFX_PANEL)
	end

	if #var_19_0 == self.pickUpNum then
		self.nextBtnCom.interactable = true

		setActive(self.selectedShipTFMap.Min.lightTF, true)
	elseif #var_19_0 < self.pickUpNum then
		self.nextBtnCom.interactable = false

		setActive(self.selectedShipTFMap.Min.lightTF, false)
	end
end

function PrayPoolSelectShipView:updateShipList(arg_21_1)
	local var_21_0 = self.prayProxy:getSelectedShipIDList()

	function self.shipListSC.onUpdateItem(arg_22_0, arg_22_1)
		local var_22_0 = arg_21_1[arg_22_0 + 1]

		arg_22_1 = tf(arg_22_1)

		GetImageSpriteFromAtlasAsync("SquareIcon/" .. Ship.getPaintingName(arg_21_1[arg_22_0 + 1]), "", (arg_22_1:Find("BG/Icon")))

		local var_22_1 = arg_22_1:Find("BG/GroupLocked")

		if pg.ship_data_template[var_22_0].group_type and pg.ship_data_template[var_22_0].group_type > 0 then
			setActive(var_22_1, not getProxy(CollectionProxy):getShipGroup(pg.ship_data_template[var_22_0].group_type))
		end

		local var_22_3
		local var_22_2

		do
			setActive(var_22_1, false)

			var_22_2 = pg.ship_data_statistics[var_22_0].rarity
			var_22_3 = ShipRarity.Rarity2Print(pg.ship_data_statistics[var_22_0].rarity)
		end

		setFrame(arg_22_1:Find("BG/icon_bg/frame"), var_22_3)
		setIconColorful(arg_22_1:Find("BG"), var_22_2 - 1, {})
		setImageSprite(arg_22_1:Find("BG"), GetSpriteFromAtlas("weaponframes", "bg" .. var_22_3))
		setText(arg_22_1:Find("NameBG/NameText"), shortenString(pg.ship_data_statistics[var_22_0].name, 6))

		local var_22_4 = arg_22_1:Find("BG/SelectedImg")

		if table.indexof(var_21_0, var_22_0, 1) then
			SetActive(var_22_4, true)
		end

		local var_22_5

		do
			SetActive(var_22_4, false)

			var_22_5 = var_22_2 == ShipRarity.SSR and self:isSelectedSSR() and not isActive(var_22_4)
		end

		setBlackMask(tf(arg_22_1), var_22_5, {
			recursive = true,
			color = Color(0, 0, 0, 0.6)
		})
		onButton(self, arg_22_1, function()
			if self.selectedCount < self.pickUpNum then
				if isActive(var_22_4) then
					self.prayProxy:removeSelectedShipIDList(var_22_0)

					self.selectedCount = self.selectedCount - 1

					SetActive(var_22_4, false)
					self:updateSelectedShipList()
					self:updateShipList(self.fliteList)
				elseif var_22_2 == ShipRarity.SSR and self:isSelectedSSR() then
					pg.TipsMgr.GetInstance():ShowTips(i18n("pray_build_UR_warning"))
				else
					self.prayProxy:insertSelectedShipIDList(var_22_0)

					self.selectedCount = self.selectedCount + 1

					SetActive(var_22_4, true)
					self:updateSelectedShipList()
					self:updateShipList(self.fliteList)
				end
			elseif self.selectedCount == self.pickUpNum then
				if isActive(var_22_4) then
					self.prayProxy:removeSelectedShipIDList(var_22_0)

					self.selectedCount = self.selectedCount - 1

					SetActive(var_22_4, false)
					self:updateSelectedShipList()
					self:updateShipList(self.fliteList)
				else
					pg.TipsMgr.GetInstance():ShowTips(i18n("error_pray_select_ship_max"))
				end
			end
		end, SFX_PANEL)
	end

	function self.shipListSC.onReturnItem(arg_24_0, arg_24_1)
		return
	end

	self.shipListSC:SetTotalCount(#arg_21_1)
end

function PrayPoolSelectShipView:orderIDListByRarity(arg_25_1)
	local var_25_0 = getProxy(CollectionProxy)

	table.sort(arg_25_1, function(arg_26_0, arg_26_1)
		local var_26_0 = pg.ship_data_statistics[arg_26_0].rarity
		local var_26_1 = pg.ship_data_statistics[arg_26_1].rarity
		local var_26_2 = var_25_0:getShipGroup(pg.ship_data_template[arg_26_0].group_type) and 1 or 0
		local var_26_3 = var_25_0:getShipGroup(pg.ship_data_template[arg_26_1].group_type) and 1 or 0

		if var_26_2 == var_26_3 then
			return var_26_1 < var_26_0
		else
			return var_26_2 < var_26_3
		end
	end)
end

function PrayPoolSelectShipView:fliteShipIDList()
	local var_27_0 = {}
	local var_27_1 = self.prayProxy:getSelectedShipIDList()

	if var_27_1 and #var_27_1 > 0 then
		for iter_27_0, iter_27_1 in ipairs(var_27_1) do
			table.insert(var_27_0, 1, iter_27_1)
		end
	end

	for iter_27_2, iter_27_3 in ipairs(self.orderFullList) do
		if not table.indexof(var_27_1, iter_27_3, 1) then
			local var_27_2 = ShipGroup.New({
				id = math.modf(iter_27_3 / 10)
			})

			if ShipIndexConst.filterByType(var_27_2, PrayPoolSelectShipView.ShipIndex.typeIndex) and ShipIndexConst.filterByRarity(var_27_2, PrayPoolSelectShipView.ShipIndex.rarityIndex) and ShipIndexConst.filterByCamp(var_27_2, PrayPoolSelectShipView.ShipIndex.campIndex) then
				var_27_0[#var_27_0 + 1] = iter_27_3
			end
		end
	end

	self.fliteList = var_27_0
end

function PrayPoolSelectShipView:isMinPrefs()
	return GroupHelper.GetGroupPrefsByName("PAINTING") == DMFileChecker.Prefs.Min
end

function PrayPoolSelectShipView:isSelectedSSR()
	local var_29_0 = false
	local var_29_1 = self.prayProxy:getSelectedShipIDList()

	if var_29_1 and #var_29_1 > 0 then
		for iter_29_0, iter_29_1 in ipairs(var_29_1) do
			if pg.ship_data_statistics[iter_29_1].rarity == ShipRarity.SSR then
				var_29_0 = true

				break
			end
		end
	end

	return var_29_0
end

return PrayPoolSelectShipView
