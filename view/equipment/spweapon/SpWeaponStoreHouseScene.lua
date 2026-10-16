local SpWeaponStoreHouseScene = class("SpWeaponStoreHouseScene", import("view.base.BaseUI"))

function SpWeaponStoreHouseScene:getUIName()
	return "SpWeaponStoreHouseUI"
end

function SpWeaponStoreHouseScene:getResource()
	local var_2_0 = {
		"ui/equipmentui_atlas",
		"ui/share/index_atlas",
		"weaponframes",
		"ui/iconcolorful",
		"ui/CustomIndexUI",
		"ui/MsgBox",
		"ui/SpWeaponUpgradeUI"
	}

	local function var_2_1(arg_3_0)
		if not arg_3_0 then
			return
		end

		table.insert(var_2_0, arg_3_0:GetIconPath())

		local var_3_0 = arg_3_0:GetShipId()

		if var_3_0 and var_3_0 > 0 then
			local var_3_1 = getProxy(BayProxy):RawGetShipById(var_3_0)

			if var_3_1 then
				table.insert(var_2_0, "qicon/" .. var_3_1:getPainting())
			end
		end
	end

	local var_2_2 = getProxy(BayProxy)
	local var_2_3 = self.contextData.shipId and var_2_2:RawGetShipById(self.contextData.shipId)

	for iter_2_0, iter_2_1 in ipairs(var_2_2:GetSpWeaponsInShips(var_2_3)) do
		var_2_1(iter_2_1)
	end

	for iter_2_2, iter_2_3 in pairs(getProxy(EquipmentProxy):GetSpWeapons()) do
		if not var_2_3 or not var_2_3:IsSpWeaponForbidden(iter_2_3) then
			var_2_1(iter_2_3)
		end
	end

	for iter_2_4, iter_2_5 in ipairs(SpWeapon.bindConfigTable().all) do
		local var_2_4 = SpWeapon.New({
			id = iter_2_5
		})

		if var_2_4:IsCraftable() and (not var_2_3 or not var_2_3:IsSpWeaponForbidden(var_2_4)) then
			var_2_1(var_2_4)
		end
	end

	table.insertto(var_2_0, SpWeaponStoreHouseScene.super.getResource(self))

	return var_2_0
end

function SpWeaponStoreHouseScene:setEquipments(arg_4_1)
	self.equipmentVOs = arg_4_1
end

function SpWeaponStoreHouseScene:SetCraftList(arg_5_1)
	self.craftList = arg_5_1
end

local SpWeaponSortCfg = require("view.equipment.SpWeaponSortCfg")

function SpWeaponStoreHouseScene:init()
	self.topItems = self._tf:Find("topItems")
	self.equipmentView = self.rtAdapt:Find("ScrollView")
	self.equipmentsGrid = self.equipmentView:Find("Viewport/Content/StoreHouse/Grid")
	self.craftsGrid = self.equipmentView:Find("Viewport/Content/Craft/Grid")

	setActive(self.equipmentView:Find("Template"), false)

	self.blurPanel = self._tf:Find("blur_panel")
	self.topPanel = self.blurPanel:Find("adapt/top")
	self.indexBtn = self.topPanel:Find("buttons/index_button")
	self.sortBtn = self.topPanel:Find("buttons/sort_button")
	self.sortPanel = self.topItems:Find("sort")
	self.sortContain = self.sortPanel:Find("adapt/mask/panel")
	self.sortTpl = self.sortContain:Find("tpl")

	setActive(self.sortTpl, false)

	local var_6_0 = (NotchAdapt.CheckNotchRatio == 2 or not getProxy(SettingsProxy):CheckLargeScreen()) and self.equipmentView.rect.width > 2000 or NotchAdapt.CheckNotchRatio >= 2

	self.equipmentsGrid:GetComponent(typeof(GridLayoutGroup)).constraintCount = var_6_0 and 8 or 7
	self.craftsGrid:GetComponent(typeof(GridLayoutGroup)).constraintCount = var_6_0 and 8 or 7
	self.decBtn = findTF(self.topPanel, "buttons/dec_btn")
	self.sortImgAsc = findTF(self.decBtn, "asc")
	self.sortImgDec = findTF(self.decBtn, "desc")
	self.filterBusyToggle = self._tf:Find("blur_panel/adapt/left_length/frame/toggle_equip")

	setActive(self.filterBusyToggle, false)

	self.bottomBack = self.topItems:Find("adapt/bottom_back")
	self.capacityTF = self.bottomBack:Find("bottom_left/tip/capcity/Text")
	self.tipTF = self.bottomBack:Find("bottom_left/tip")
	self.tip = self.tipTF:Find("label")
	self.helpBtn = self.topItems:Find("adapt/help_btn")

	setActive(self.helpBtn, true)

	self.backBtn = self._tf:Find("blur_panel/adapt/top/back_btn")
	self.listEmptyTF = self._tf:Find("empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")

	setText(self.listEmptyTxt, i18n("list_empty_tip_storehouseui_equip"))
	setText(self.equipmentView:Find("Viewport/Content/Craft/Banner/Text"), i18n("spweapon_ui_create"))
	setText(self.equipmentView:Find("Viewport/Content/StoreHouse/Banner/Text"), i18n("spweapon_ui_storage"))

	self.isEquipingOn = false
	self.filterImportance = nil
end

function SpWeaponStoreHouseScene:setEquipmentUpdate()
	self:filterEquipment()
	self:updateCapacity()
end

function SpWeaponStoreHouseScene:didEnter()
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.spweapon_help_storage.tip
		})
	end, SFX_PANEL)
	onButton(self, self.backBtn, function()
		GetOrAddComponent(self._tf, typeof(CanvasGroup)).interactable = false

		self:emit(SpWeaponStoreHouseScene.ON_BACK)
	end, SFX_CANCEL)
	onToggle(self, self.sortBtn, function(arg_11_0)
		if arg_11_0 then
			self:OverlayPanel(self.sortPanel)
			setActive(self.sortPanel, true)
		else
			self:UnOverlayPanel(self.sortPanel, self.topItems)
			setActive(self.sortPanel, false)
		end
	end, SFX_PANEL)
	onButton(self, self.sortPanel, function()
		triggerToggle(self.sortBtn, false)
	end, SFX_PANEL)
	onButton(self, self.indexBtn, function()
		self:emit(SpWeaponStoreHouseMediator.OPEN_EQUIPMENT_INDEX, {
			indexDatas = Clone(self.contextData.indexDatas),
			customPanels = {
				typeIndex = {
					mode = CustomIndexLayer.Mode.OR,
					options = IndexConst.SpWeaponTypeIndexs,
					names = IndexConst.SpWeaponTypeNames
				},
				rarityIndex = {
					mode = CustomIndexLayer.Mode.AND,
					options = IndexConst.SpWeaponRarityIndexs,
					names = IndexConst.SpWeaponRarityNames
				}
			},
			groupList = {
				{
					dropdown = false,
					titleENTxt = "indexsort_typeeng",
					titleTxt = "indexsort_type",
					tags = {
						"typeIndex"
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
			},
			callback = function(self)
				self.contextData.indexDatas.typeIndex = self.typeIndex
				self.contextData.indexDatas.rarityIndex = self.rarityIndex

				self:filterEquipment()
			end
		})
	end, SFX_PANEL)

	local var_8_0 = self.equipmentView:Find("Viewport/Content/Craft/Banner/Arrow")

	onToggle(self, var_8_0, function(arg_15_0)
		self.hideCraft = not arg_15_0

		self:UpdateCraftCount()
	end, SFX_PANEL, SFX_PANEL)

	local var_8_1 = self.equipmentView:Find("Viewport/Content/StoreHouse/Banner/Arrow")

	onToggle(self, var_8_1, function(arg_16_0)
		self.hideSpweapon = not arg_16_0

		self:updateEquipmentCount()
	end, SFX_PANEL, SFX_PANEL)

	self.equipmetItems = {}
	self.craftItems = {}

	self:initEquipments()

	self.asc = self.contextData.asc or false
	self.contextData.sortData = self.contextData.sortData or SpWeaponSortCfg.sort[1]
	self.contextData.indexDatas = self.contextData.indexDatas or {}

	self:initSort()
	onToggle(self, self.filterBusyToggle, function(arg_17_0)
		self:SetShowBusyFlag(arg_17_0)
		self:filterEquipment()
	end, SFX_PANEL)
	triggerToggle(self.filterBusyToggle, self.shipVO)
	self:OverlayPanel(self.blurPanel)
	self:OverlayPanel(self.topItems)

	self.contextData.mode = self.contextData.mode or StoreHouseConst.OVERVIEW

	self:updateCapacity()
	setActive(self.tip, false)
	setActive(self.capacityTF.parent, true)
	setActive(self.filterBusyToggle, true)
	setActive(self.indexBtn, true)
	setActive(self.sortBtn, false)
	triggerToggle(var_8_0, true)
	triggerToggle(var_8_1, true)
end

function SpWeaponStoreHouseScene:isDefaultStatus()
	return (not self.contextData.indexDatas.typeIndex or self.contextData.indexDatas.typeIndex == IndexConst.SpWeaponTypeAll) and (not self.contextData.indexDatas.rarityIndex or self.contextData.indexDatas.rarityIndex == IndexConst.SpWeaponRarityAll)
end

function SpWeaponStoreHouseScene:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if isActive(self.sortPanel) then
		triggerButton(self.sortPanel)
	else
		triggerButton(self.backBtn)
	end
end

function SpWeaponStoreHouseScene:updateCapacity()
	setText(self.tip, "")
	setText(self.capacityTF, getProxy(EquipmentProxy):GetSpWeaponCount() .. "/" .. getProxy(EquipmentProxy):GetSpWeaponCapacity())
end

function SpWeaponStoreHouseScene:setShip(arg_21_1)
	self.shipVO = arg_21_1
end

function SpWeaponStoreHouseScene:setPlayer(arg_22_1)
	self.player = arg_22_1
end

function SpWeaponStoreHouseScene:initSort()
	onButton(self, self.decBtn, function()
		self.asc = not self.asc
		self.contextData.asc = self.asc

		self:filterEquipment()
	end)

	self.sortButtons = {}

	eachChild(self.sortContain, function(arg_25_0)
		setActive(arg_25_0, false)
	end)

	for iter_23_0, iter_23_1 in ipairs(SpWeaponSortCfg.sort) do
		local var_23_0 = iter_23_0 <= self.sortContain.childCount and self.sortContain:GetChild(iter_23_0 - 1) or cloneTplTo(self.sortTpl, self.sortContain)

		setActive(var_23_0, true)
		setImageSprite(findTF(var_23_0, "Image"), GetSpriteFromAtlas("ui/equipmentui_atlas", iter_23_1.spr), true)
		onToggle(self, var_23_0, function(arg_26_0)
			if arg_26_0 then
				self.contextData.sortData = iter_23_1

				self:filterEquipment()
				triggerToggle(self.sortBtn, false)
			end
		end, SFX_PANEL)

		self.sortButtons[iter_23_0] = var_23_0
	end
end

function SpWeaponStoreHouseScene:initEquipments()
	self.equipmentRect = UIItemList.New(self.equipmentsGrid, self.equipmentView:Find("Template"))

	self.equipmentRect:make(function(arg_28_0, arg_28_1, arg_28_2)
		local var_28_0 = go(arg_28_2)

		if arg_28_0 == UIItemList.EventInit then
			self:InitSpWeapon(var_28_0)
		elseif arg_28_0 == UIItemList.EventUpdate then
			self:UpdateSpWeapon(arg_28_1, var_28_0)
		elseif arg_28_0 == UIItemList.EventExcess then
			self:ReturnSpWeapon(arg_28_1, var_28_0)
		end
	end)

	self.craftRect = UIItemList.New(self.craftsGrid, self.equipmentView:Find("Template"))

	self.craftRect:make(function(arg_29_0, arg_29_1, arg_29_2)
		local var_29_0 = go(arg_29_2)

		if arg_29_0 == UIItemList.EventInit then
			self:InitCraftItem(var_29_0)
		elseif arg_29_0 == UIItemList.EventUpdate then
			self:UpdateCraftItem(arg_29_1, var_29_0)
		elseif arg_29_0 == UIItemList.EventExcess then
			self:ReturnCraftItem(arg_29_1, var_29_0)
		end
	end)
end

function SpWeaponStoreHouseScene:InitSpWeapon(arg_30_1)
	local var_30_0 = SpWeaponItemView.New(arg_30_1)

	onButton(self, var_30_0.unloadBtn, function()
		self:emit(SpWeaponStoreHouseMediator.ON_UNEQUIP)
	end, SFX_PANEL)

	self.equipmetItems[arg_30_1] = var_30_0
end

function SpWeaponStoreHouseScene:UpdateSpWeapon(arg_32_1, arg_32_2)
	assert(self.equipmetItems[arg_32_2], "without init item")

	local var_32_0 = self.loadEquipmentVOs[arg_32_1 + 1]

	self.equipmetItems[arg_32_2]:update(self.loadEquipmentVOs[arg_32_1 + 1])

	if not self.loadEquipmentVOs[arg_32_1 + 1] or self.loadEquipmentVOs[arg_32_1 + 1].mask then
		removeOnButton(self.equipmetItems[arg_32_2].go)
	else
		onButton(self, self.equipmetItems[arg_32_2].go, function()
			local var_33_0

			if self.shipVO then
				var_33_0 = {
					type = EquipmentInfoMediator.TYPE_REPLACE,
					shipId = self.contextData.shipId,
					oldSpWeaponUid = var_32_0:GetUID(),
					oldShipId = var_32_0:GetShipId()
				}

				if not var_33_0 then
					if var_32_0:GetShipId() then
						var_33_0 = {
							type = EquipmentInfoMediator.TYPE_DISPLAY,
							spWeaponUid = var_32_0:GetUID(),
							shipId = var_32_0:GetShipId()
						} or {
							type = EquipmentInfoMediator.TYPE_DEFAULT,
							spWeaponUid = var_32_0:GetUID()
						}
					end
				end
			end

			self:emit(SpWeaponStoreHouseScene.ON_SPWEAPON, var_33_0)
		end, SFX_PANEL)
	end
end

function SpWeaponStoreHouseScene:ReturnSpWeapon(arg_34_1, arg_34_2)
	if self.exited then
		return
	end

	local var_34_0 = self.equipmetItems[arg_34_2]

	if self.equipmetItems[arg_34_2] then
		removeOnButton(var_34_0.go)
		var_34_0:clear()
	end
end

function SpWeaponStoreHouseScene:updateEquipmentCount()
	local var_35_0 = self.hideSpweapon and 0 or #self.loadEquipmentVOs

	self.equipmentRect:align(self.hideSpweapon and 0 or #self.loadEquipmentVOs)

	local var_35_1 = self.equipmentsGrid:GetComponent(typeof(GridLayoutGroup))
	local var_35_2 = var_35_1.padding

	if var_35_0 then
		var_35_2.top = 31
		var_35_2.bottom = 25
	else
		var_35_2.top = 0
		var_35_2.bottom = 0
	end

	var_35_1.padding = var_35_2
end

function SpWeaponStoreHouseScene:filterEquipment()
	GetSpriteFromAtlasAsync("ui/share/index_atlas", self:isDefaultStatus() and "shaixuan_off" or "shaixuan_on", function(arg_37_0)
		setImageSprite(self.indexBtn, arg_37_0, true)
	end)

	local var_36_0 = self.contextData.sortData

	;(function()
		self.loadEquipmentVOs = {}

		local var_38_0 = {}

		for iter_38_0, iter_38_1 in pairs(self.equipmentVOs) do
			table.insert(var_38_0, iter_38_1)
		end

		for iter_38_2, iter_38_3 in pairs(var_38_0) do
			if self:checkFitBusyCondition(iter_38_3) and IndexConst.filterSpWeaponByType(iter_38_3, self.contextData.indexDatas.typeIndex) and IndexConst.filterSpWeaponByRarity(iter_38_3, self.contextData.indexDatas.rarityIndex) and (self.filterImportance == nil or iter_38_3:IsImportant()) then
				table.insert(self.loadEquipmentVOs, iter_38_3)
			end
		end

		if var_36_0 then
			table.sort(self.loadEquipmentVOs, CompareFuncs(SpWeaponSortCfg.sortFunc(var_36_0, self.asc)))
		end

		if self.contextData.qiutBtn then
			table.insert(self.loadEquipmentVOs, 1, false)
		end
	end)()
	self:updateEquipmentCount()
	;(function()
		self.showCraftList = {}

		local var_39_0 = {}

		for iter_39_0, iter_39_1 in pairs(self.craftList) do
			table.insert(var_39_0, iter_39_1)
		end

		for iter_39_2, iter_39_3 in pairs(var_39_0) do
			if self:checkFitBusyCondition(iter_39_3) and IndexConst.filterSpWeaponByType(iter_39_3, self.contextData.indexDatas.typeIndex) and IndexConst.filterSpWeaponByRarity(iter_39_3, self.contextData.indexDatas.rarityIndex) and (self.filterImportance == nil or iter_39_3:IsImportant()) then
				table.insert(self.showCraftList, iter_39_3)
			end
		end

		if var_36_0 then
			table.sort(self.showCraftList, CompareFuncs(SpWeaponSortCfg.sortFunc(var_36_0, self.asc)))
		end
	end)()
	self:UpdateCraftCount()
	setImageSprite(self.sortBtn:Find("Image"), GetSpriteFromAtlas("ui/equipmentui_atlas", self.contextData.sortData.spr), true)
	setActive(self.sortImgAsc, self.asc)
	setActive(self.sortImgDec, not self.asc)
end

function SpWeaponStoreHouseScene:InitCraftItem(arg_40_1)
	self.craftItems[arg_40_1] = SpWeaponItemView.New(arg_40_1)
end

function SpWeaponStoreHouseScene:UpdateCraftItem(arg_41_1, arg_41_2)
	assert(self.craftItems[arg_41_2], "without init item")

	local var_41_0 = self.showCraftList[arg_41_1 + 1]

	self.craftItems[arg_41_2]:update(self.showCraftList[arg_41_1 + 1])
	onButton(self, self.craftItems[arg_41_2].go, function()
		self:emit(SpWeaponStoreHouseMediator.ON_COMPOSITE, var_41_0:GetConfigID())
	end, SFX_PANEL)
end

function SpWeaponStoreHouseScene:ReturnCraftItem(arg_43_1, arg_43_2)
	if self.craftItems[arg_43_2] then
		removeOnButton(self.craftItems[arg_43_2].go)
		self.craftItems[arg_43_2]:clear()
	end
end

function SpWeaponStoreHouseScene:UpdateCraftCount()
	local var_44_0 = self.hideCraft and 0 or #self.showCraftList

	self.craftRect:align(self.hideCraft and 0 or #self.showCraftList)

	local var_44_1 = self.craftsGrid:GetComponent(typeof(GridLayoutGroup))
	local var_44_2 = var_44_1.padding

	if var_44_0 > 0 then
		var_44_2.top = 31
		var_44_2.bottom = 25
	else
		var_44_2.top = 0
		var_44_2.bottom = 0
	end

	var_44_1.padding = var_44_2
end

function SpWeaponStoreHouseScene:GetShowBusyFlag()
	return self.isEquipingOn
end

function SpWeaponStoreHouseScene:SetShowBusyFlag(arg_46_1)
	self.isEquipingOn = arg_46_1
end

function SpWeaponStoreHouseScene:checkFitBusyCondition(arg_47_1)
	return self:GetShowBusyFlag() or not arg_47_1:GetShipId()
end

function SpWeaponStoreHouseScene:willExit()
	self:UnOverlayPanel(self.blurPanel, self._tf)
	self:UnOverlayPanel(self.topItems, self._tf)
end

return SpWeaponStoreHouseScene
