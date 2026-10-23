local StoreHouseScene = class("StoreHouseScene", import("view.base.BaseUI"))
local var_0_2 = 0
local var_0_3 = 1
local var_0_4 = 2
local var_0_5 = 1
local var_0_6 = 2
local var_0_7 = 3

function StoreHouseScene:getResource()
	return table.insertto({
		"ui/share/index_atlas",
		"ui/storehouseui",
		"ui/equipmentui_atlas",
		"ui/recordablesearchbarui",
		"ui/iconcolorful"
	}, StoreHouseScene.super.getResource(self))
end

function StoreHouseScene:getUIName()
	return "StoreHouseUI"
end

function StoreHouseScene:setEquipments(arg_3_1)
	self.equipmentVOs = arg_3_1

	self:setEquipmentByIds(arg_3_1)
end

function StoreHouseScene:setEquipmentByIds(arg_4_1)
	self.equipmentVOByIds = {}

	for iter_4_0, iter_4_1 in pairs(arg_4_1) do
		if not iter_4_1.isSkin then
			self.equipmentVOByIds[iter_4_1.id] = iter_4_1
		end
	end
end

local EquipmentSortCfg = require("view.equipment.EquipmentSortCfg")
local SpWeaponSortCfg = require("view.equipment.SpWeaponSortCfg")

function StoreHouseScene:init()
	self.filterEquipWaitting = 0

	local var_5_0 = self.contextData

	self.topItems = self._tf:Find("topItems")
	self.equipmentView = self._tf:Find("adapt/equipment_scrollview")
	self.blurPanel = self._tf:Find("blur_panel")
	self.topPanel = self.blurPanel:Find("adapt/top")
	self.indexBtn = self.topPanel:Find("buttons/index_button")
	self.sortBtn = self.topPanel:Find("buttons/sort_button")
	self.sortPanel = self.topItems:Find("sort")
	self.sortPanelTG = self.sortPanel:GetComponent("ToggleGroup")
	self.sortPanelTG.allowSwitchOff = true
	self.sortContain = self.sortPanel:Find("adapt/mask/panel")
	self.sortTpl = self.sortContain:Find("tpl")

	setActive(self.sortTpl, false)

	self.equipSkinFilteBtn = self.topPanel:Find("buttons/EquipSkinFilteBtn")
	self.searchBar = RecordableSearchBar.New(RecordableSearchBar.CreateData({
		enabledFlag = false,
		holder = i18n("search_equipment"),
		onInputChanged = function()
			self:filterEquipment()
		end,
		key = self.__cname,
		parent = self.topPanel:Find("buttons"),
		expand_parent = self.blurPanel:Find("adapt"),
		anchoredPosition = Vector3(-1305, self.topPanel.sizeDelta.y * -0.5, 0)
	}))
	self.itemView = self._tf:Find("adapt/item_scrollview")

	local var_5_1 = (NotchAdapt.CheckNotchRatio == 2 or not getProxy(SettingsProxy):CheckLargeScreen()) and self.itemView.rect.width > 2000 or NotchAdapt.CheckNotchRatio >= 2

	self.equipmentView:Find("equipment_grid"):GetComponent(typeof(GridLayoutGroup)).constraintCount = var_5_1 and 8 or 7
	self.itemView:Find("item_grid"):GetComponent(typeof(GridLayoutGroup)).constraintCount = var_5_1 and 8 or 7
	self.decBtn = findTF(self.topPanel, "buttons/dec_btn")
	self.sortImgAsc = findTF(self.decBtn, "asc")
	self.sortImgDec = findTF(self.decBtn, "desc")
	self.equipmentToggle = self._tf:Find("blur_panel/adapt/left_length/frame/toggle_root")

	setActive(self.equipmentToggle, false)

	self.filterBusyToggle = self._tf:Find("blur_panel/adapt/left_length/frame/toggle_equip")

	setActive(self.filterBusyToggle, false)

	self.designTabRoot = self._tf:Find("blur_panel/adapt/left_length/frame/toggle_design")

	setActive(self.designTabRoot, false)

	self.designTabs = CustomIndexLayer.Clone2Full(self.designTabRoot, 3)
	self.bottomBack = self.topItems:Find("adapt/bottom_back")
	self.bottomPanel = self.bottomBack:Find("types")
	self.materialToggle = self.bottomPanel:Find("material")
	self.weaponToggle = self.bottomPanel:Find("weapon")
	self.designToggle = self.bottomPanel:Find("design")
	self.capacityTF = self.bottomBack:Find("bottom_left/tip/capcity/Text")
	self.tipTF = self.bottomBack:Find("bottom_left/tip")
	self.tip = self.tipTF:Find("label")
	self.helpBtn = self.topItems:Find("adapt/help_btn")

	setActive(self.helpBtn, true)

	self.backBtn = self._tf:Find("blur_panel/adapt/top/back_btn")
	self.selectedMin = defaultValue(var_5_0.selectedMin, 1)
	self.selectedMax = defaultValue(var_5_0.selectedMax, pg.gameset.equip_select_limit.key_value or 0)
	self.selectedIds = Clone(var_5_0.selectedIds or {})
	self.checkEquipment = var_5_0.onEquipment or function(arg_7_0, arg_7_1, arg_7_2)
		return true
	end
	self.onSelected = var_5_0.onSelected or function()
		warning("not implemented.")
	end
	self.BatchDisposeBtn = self.bottomPanel:Find("dispos") or self.bottomBack:Find("dispos")
	self.selectPanel = self.topItems:Find("adapt/select_panel")

	setActive(self.selectPanel, true)
	setAnchoredPosition(self.selectPanel, {
		y = -124
	})

	self.selectTransformPanel = self.topItems:Find("adapt/select_transform_panel")

	setActive(self.selectTransformPanel, false)

	self.listEmptyTF = self._tf:Find("adapt/empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")
	self.destroyConfirmView = DestroyConfirmView.New(self.topItems, self.event)
	self.assignedItemView = AssignedItemView.New(self.topItems, self.event)
	self.blueprintAssignedItemView = BlueprintAssignedItemView.New(self.topItems, self.event)
	self.equipDestroyConfirmWindow = EquipDestoryConfirmWindow.New(self.topItems, self.event)
	self.isEquipingOn = false
	self.msgBox = SelectSkinMsgbox.New(self._tf, self.event)
end

function StoreHouseScene:setEquipment(arg_9_1)
	local var_9_0 = #self.equipmentVOs + 1

	for iter_9_0, iter_9_1 in ipairs(self.equipmentVOs) do
		if not iter_9_1.shipId and iter_9_1.id == arg_9_1.id then
			var_9_0 = iter_9_0

			break
		end
	end

	if arg_9_1.count > 0 then
		self.equipmentVOs[var_9_0] = arg_9_1
		self.equipmentVOByIds[arg_9_1.id] = arg_9_1
	else
		table.remove(self.equipmentVOs, var_9_0)

		self.equipmentVOByIds[arg_9_1.id] = nil
	end
end

function StoreHouseScene:setEquipmentUpdate()
	if self.contextData.warp == StoreHouseConst.WARP_TO_WEAPON then
		self:filterEquipment()
		self:updateCapacity()
	end
end

function StoreHouseScene:addShipEquipment(arg_11_1)
	for iter_11_0, iter_11_1 in pairs(self.equipmentVOs) do
		if EquipmentProxy.SameEquip(iter_11_1, arg_11_1) then
			self.equipmentVOs[iter_11_0] = arg_11_1

			return
		end
	end

	table.insert(self.equipmentVOs, arg_11_1)
end

function StoreHouseScene:removeShipEquipment(arg_12_1)
	for iter_12_0 = #self.equipmentVOs, 1, -1 do
		if EquipmentProxy.SameEquip(self.equipmentVOs[iter_12_0], arg_12_1) then
			table.remove(self.equipmentVOs, iter_12_0)
		end
	end
end

function StoreHouseScene:setEquipmentSkin(arg_13_1)
	local var_13_0 = true

	for iter_13_0, iter_13_1 in pairs(self.equipmentVOs) do
		if iter_13_1.id == arg_13_1.id and iter_13_1.isSkin then
			self.equipmentVOs[iter_13_0] = {
				isSkin = true,
				id = arg_13_1.id,
				count = arg_13_1.count
			}
			var_13_0 = false
		end
	end

	if var_13_0 then
		table.insert(self.equipmentVOs, {
			isSkin = true,
			id = arg_13_1.id,
			count = arg_13_1.count
		})
	end
end

function StoreHouseScene:setEquipmentSkinUpdate()
	if self.contextData.warp == StoreHouseConst.WARP_TO_WEAPON then
		self:filterEquipment()
		self:updateCapacity()
	end
end

function StoreHouseScene:SetSpWeapons(arg_15_1)
	self.spweaponVOs = arg_15_1
end

function StoreHouseScene:SetSpWeaponUpdate()
	if self.contextData.warp == StoreHouseConst.WARP_TO_WEAPON and self.page == var_0_4 then
		self:filterEquipment()
		self:UpdateSpweaponCapacity()
	elseif self.contextData.warp == StoreHouseConst.WARP_TO_DESIGN and self.contextData.designPage == var_0_6 then
		self:UpdateSpweaponCapacity()
	end
end

function StoreHouseScene:didEnter()
	setText(self.selectPanel:Find("tip"), i18n("equipment_select_device_destroy_tip"))
	setActive(self.topItems:Find("adapt/stamp"), getProxy(TaskProxy):mingshiTouchFlagEnabled())
	onButton(self, self.topItems:Find("adapt/stamp"), function()
		getProxy(TaskProxy):dealMingshiTouchFlag(2)
	end, SFX_CONFIRM)
	onButton(self, self.helpBtn, function()
		local var_19_0

		if self.contextData.warp == StoreHouseConst.WARP_TO_WEAPON then
			if self.page == var_0_2 then
				var_19_0 = pg.gametip.help_equipment.tip
			elseif self.page == var_0_3 then
				var_19_0 = pg.gametip.help_equipment_skin.tip
			elseif self.page == var_0_4 then
				var_19_0 = pg.gametip.spweapon_help_storage.tip
			end
		elseif self.contextData.warp == StoreHouseConst.WARP_TO_DESIGN then
			if self.contextData.designPage == var_0_5 then
				var_19_0 = pg.gametip.help_equipment.tip
			elseif self.contextData.designPage == var_0_6 then
				var_19_0 = pg.gametip.spweapon_help_storage.tip
			end
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = var_19_0
		})
	end, SFX_PANEL)
	onToggle(self, self.equipmentToggle:Find("equipment"), function(arg_20_0)
		if arg_20_0 then
			self.page = var_0_2

			self:SwitchEquipmentType(var_0_2)
			self:UpdateWeaponWrapButtons()
			self:filterEquipment()
		end
	end, SFX_PANEL)
	onToggle(self, self.equipmentToggle:Find("skin"), function(arg_21_0)
		if arg_21_0 then
			self.page = var_0_3

			self:SwitchEquipmentType(var_0_3)
			self:UpdateWeaponWrapButtons()
			self:filterEquipment()
		end
	end, SFX_PANEL)
	onToggle(self, self.equipmentToggle:Find("spweapon"), function(arg_22_0)
		if arg_22_0 then
			self.page = var_0_4

			self:SwitchEquipmentType(var_0_4)
			self:UpdateWeaponWrapButtons()
			self:filterEquipment()
		end
	end, SFX_PANEL)
	setActive(self.equipmentToggle:Find("spweapon"), not LOCK_SP_WEAPON)
	onToggle(self, self.designTabs[var_0_5], function(arg_23_0)
		if arg_23_0 then
			self.contextData.designPage = var_0_5

			self:emit(EquipmentMediator.OPEN_DESIGN)
			self:updateCapacity()
			setActive(self.tip, false)
			setActive(self.listEmptyTF, false)
		else
			self:emit(EquipmentMediator.CLOSE_DESIGN_LAYER)
		end

		setActive(self.designTabs[var_0_7], arg_23_0)
	end, SFX_PANEL)
	onToggle(self, self.designTabs[var_0_6], function(arg_24_0)
		if arg_24_0 then
			self.contextData.designPage = var_0_6

			self:emit(EquipmentMediator.OPEN_SPWEAPON_DESIGN)
			self:UpdateSpweaponCapacity()
			setActive(self.tip, false)
			setActive(self.listEmptyTF, false)
		else
			self:emit(EquipmentMediator.CLOSE_SPWEAPON_DESIGN_LAYER)
		end
	end, SFX_PANEL)
	setActive(self.designTabs[var_0_7], self.contextData.designPage == var_0_5)

	self.isShowAllDesign = false

	onToggle(self, self.designTabs[var_0_7], function(arg_25_0)
		self.isShowAllDesign = arg_25_0

		self:emit(EquipmentMediator.DESIGN_FILTER_CHANGED, self.isShowAllDesign)
	end, SFX_PANEL)
	onButton(self, self.backBtn, function()
		if self.mode == StoreHouseConst.DESTROY then
			triggerButton(self.BatchDisposeBtn)

			return
		end

		GetOrAddComponent(self._tf, typeof(CanvasGroup)).interactable = false

		self:emit(StoreHouseScene.ON_BACK)
	end, SFX_CANCEL)
	onToggle(self, self.sortBtn, function(arg_27_0)
		if arg_27_0 then
			self:OverlayPanel(self.sortPanel)
			setActive(self.sortPanel, true)
			onNextTick(function()
				self.sortPanelTG.allowSwitchOff = false
			end)
		else
			self:UnOverlayPanel(self.sortPanel, self.topItems)
			setActive(self.sortPanel, false)

			self.sortPanelTG.allowSwitchOff = true
		end
	end, SFX_PANEL)
	onButton(self, self.sortPanel, function()
		triggerToggle(self.sortBtn, false)
	end, SFX_PANEL)
	onButton(self, self.indexBtn, function()
		self:emit(EquipmentMediator.OPEN_EQUIPMENT_INDEX, (switch(self.page, {
			[var_0_2] = function()
				return setmetatable({
					indexDatas = Clone(self.contextData.indexDatas),
					callback = function(self)
						self.contextData.indexDatas.typeIndex = self.typeIndex
						self.contextData.indexDatas.equipPropertyIndex = self.equipPropertyIndex
						self.contextData.indexDatas.equipPropertyIndex2 = self.equipPropertyIndex2
						self.contextData.indexDatas.equipAmmoIndex1 = self.equipAmmoIndex1
						self.contextData.indexDatas.equipAmmoIndex2 = self.equipAmmoIndex2
						self.contextData.indexDatas.equipCampIndex = self.equipCampIndex
						self.contextData.indexDatas.rarityIndex = self.rarityIndex
						self.contextData.indexDatas.extraIndex = self.extraIndex

						if self.filterBusyToggle:GetComponent(typeof(Toggle)) then
							if bit.band(self.extraIndex, IndexConst.EquipmentExtraEquiping) > 0 then
								self:SetShowBusyFlag(true)
							end

							triggerToggle(self.filterBusyToggle, self:GetShowBusyFlag())
						else
							self:filterEquipment()
						end
					end
				}, {
					__index = StoreHouseConst.EQUIPMENT_INDEX_COMMON
				})
			end,
			[var_0_4] = function()
				return setmetatable({
					indexDatas = Clone(self.contextData.spweaponIndexDatas),
					callback = function(self)
						self.contextData.spweaponIndexDatas.typeIndex = self.typeIndex
						self.contextData.spweaponIndexDatas.rarityIndex = self.rarityIndex

						self:filterEquipment()
					end
				}, {
					__index = StoreHouseConst.SPWEAPON_INDEX_COMMON
				})
			end
		})))
	end, SFX_PANEL)
	onButton(self, self.equipSkinFilteBtn, function()
		local var_35_0 = {
			display = {
				equipSkinIndex = IndexConst.FlagRange2Bits(IndexConst.EquipSkinIndexAll, IndexConst.EquipSkinIndexAux),
				equipSkinTheme = IndexConst.FlagRange2Str(IndexConst.EquipSkinThemeAll, IndexConst.EquipSkinThemeEnd)
			}
		}

		var_35_0.equipSkinSort = self.equipSkinSort or IndexConst.EquipSkinSortType
		var_35_0.equipSkinIndex = self.equipSkinIndex or IndexConst.Flags2Bits({
			IndexConst.EquipSkinIndexAll
		})
		var_35_0.equipSkinTheme = self.equipSkinTheme or IndexConst.Flags2Str({
			IndexConst.EquipSkinThemeAll
		})

		function var_35_0:callback()
			self.equipSkinSort = self.equipSkinSort
			self.equipSkinIndex = self.equipSkinIndex
			self.equipSkinTheme = self.equipSkinTheme

			self:filterEquipment()
		end

		self:emit(EquipmentMediator.OPEN_EQUIPSKIN_INDEX_LAYER, var_35_0)
	end, SFX_PANEL)

	self.equipmetItems = {}
	self.itemCards = {}

	self:initItems()
	self:initEquipments()

	self.asc = self.contextData.asc or false
	self.contextData.sortData = self.contextData.sortData or EquipmentSortCfg.sort[1]
	self.contextData.indexDatas = self.contextData.indexDatas or {}
	self.contextData.spweaponIndexDatas = self.contextData.spweaponIndexDatas or {}
	self.contextData.spweaponSortData = self.contextData.spweaponSortData or SpWeaponSortCfg.sort[1]

	self:initSort()
	setActive(self.itemView, false)
	setActive(self.equipmentView, false)
	onToggle(self, self.materialToggle, function(arg_37_0)
		self.inMaterial = arg_37_0

		if arg_37_0 and self.contextData.warp ~= StoreHouseConst.WARP_TO_MATERIAL then
			self.contextData.warp = StoreHouseConst.WARP_TO_MATERIAL

			setText(self.tip, i18n("equipment_select_materials_tip"))
			setActive(self.capacityTF.parent, false)
			setActive(self.tip, true)
			self:sortItems()
		end

		setActive(self.helpBtn, not arg_37_0)
	end, SFX_PANEL)
	onToggle(self, self.weaponToggle, function(arg_38_0)
		if arg_38_0 then
			if self.contextData.warp ~= StoreHouseConst.WARP_TO_WEAPON then
				self.contextData.warp = StoreHouseConst.WARP_TO_WEAPON

				setActive(self.tip, false)
				setActive(self.capacityTF.parent, true)

				if self.page == var_0_3 then
					triggerToggle(self.equipmentToggle:Find("skin"), true)
				elseif self.page == var_0_4 then
					triggerToggle(self.equipmentToggle:Find("spweapon"), true)
				else
					triggerToggle(self.equipmentToggle:Find("equipment"), true)
				end
			end
		else
			setActive(self.BatchDisposeBtn, false)
			setActive(self.filterBusyToggle, false)
			setActive(self.equipmentToggle, false)
		end

		self.searchBar:EnableOrDisable(arg_38_0)
	end, SFX_PANEL)
	onToggle(self, self.designToggle, function(arg_39_0)
		if arg_39_0 then
			self.contextData.warp = StoreHouseConst.WARP_TO_DESIGN

			triggerToggle(self.designTabs[self.contextData.designPage or var_0_5], true)
			setActive(self.capacityTF.parent, true)
		else
			self:emit(EquipmentMediator.CLOSE_DESIGN_LAYER)
			self:emit(EquipmentMediator.CLOSE_SPWEAPON_DESIGN_LAYER)
		end

		setActive(self.designTabRoot, arg_39_0 and not LOCK_SP_WEAPON)
	end, SFX_PANEL)
	onToggle(self, self.filterBusyToggle, function(arg_40_0)
		self:SetShowBusyFlag(arg_40_0)
		self:filterEquipment()
	end, SFX_PANEL)

	self.filterEquipWaitting = self.filterEquipWaitting + 1

	triggerToggle(self.filterBusyToggle, self.shipVO)
	onButton(self, self.BatchDisposeBtn, function()
		if self.mode == StoreHouseConst.DESTROY then
			self.mode = StoreHouseConst.OVERVIEW
			self.asc = self.lastasc
			self.lastasc = nil
			self.filterImportance = nil

			shiftPanel(self.bottomBack, nil, 0, nil, 0, true, true)
			shiftPanel(self.selectPanel, nil, -124, nil, 0, true, true)
			self:filterEquipment()
		else
			self.mode = StoreHouseConst.DESTROY
			self.lastasc = self.asc
			self.filterImportance = true
			self.asc = true

			shiftPanel(self.bottomBack, nil, -124, nil, 0, true, true)
			shiftPanel(self.selectPanel, nil, 0, nil, 0, true, true)

			self.contextData.asc = self.asc
			self.contextData.sortData = EquipmentSortCfg.sort[1]

			self:filterEquipment()
		end

		self:UpdateWeaponWrapButtons()
	end, SFX_PANEL)
	onButton(self, findTF(self.selectPanel, "cancel_button"), function()
		self:unselecteAllEquips()
		triggerButton(self.BatchDisposeBtn)
	end, SFX_CANCEL)
	onButton(self, findTF(self.selectPanel, "confirm_button"), function()
		local var_43_0 = {}

		if underscore.any(self.selectedIds, function(arg_44_0)
			return self.equipmentVOByIds[arg_44_0[1]]:getConfig("rarity") >= 4 or self.equipmentVOByIds[arg_44_0[1]]:getConfig("level") > 1
		end) then
			table.insert(var_43_0, function(arg_45_0)
				self.equipDestroyConfirmWindow:Load()
				self.equipDestroyConfirmWindow:ActionInvoke("Show", underscore.map(self.selectedIds, function(arg_46_0)
					return setmetatable({
						count = arg_46_0[2]
					}, {
						__index = self.equipmentVOByIds[arg_46_0[1]]
					})
				end), arg_45_0)
			end)
		end

		seriesAsync(var_43_0, function()
			self.destroyConfirmView:Load()
			self.destroyConfirmView:ActionInvoke("Show")
			self.destroyConfirmView:ActionInvoke("DisplayDestroyBonus", self.selectedIds)
			self.destroyConfirmView:ActionInvoke("SetConfirmBtnCB", function()
				self:unselecteAllEquips()
			end)
		end)
	end, SFX_CONFIRM)
	self:OverlayPanel(self.blurPanel)
	self:PlayUIAnimation(self.blurPanel, "enter")
	self:OverlayPanel(self.topItems)

	local var_17_0 = self.contextData.warp or StoreHouseConst.WARP_TO_MATERIAL
	local var_17_1 = self.contextData.mode or StoreHouseConst.OVERVIEW

	self.contextData.warp = nil
	self.contextData.mode = nil
	self.mode = self.mode or StoreHouseConst.OVERVIEW

	if var_17_0 == StoreHouseConst.WARP_TO_DESIGN then
		triggerToggle(self.designToggle, true)
	elseif var_17_0 == StoreHouseConst.WARP_TO_MATERIAL then
		triggerToggle(self.materialToggle, true)
	elseif var_17_0 == StoreHouseConst.WARP_TO_WEAPON then
		if var_17_1 == StoreHouseConst.DESTROY then
			self.filterEquipWaitting = self.filterEquipWaitting + 1

			triggerToggle(self.weaponToggle, true)
			triggerButton(self.BatchDisposeBtn)
		else
			self.page = var_17_1 == StoreHouseConst.SKIN and var_0_3 or var_17_1 == StoreHouseConst.SPWEAPON and var_0_4 or var_0_2

			triggerToggle(self.weaponToggle, true)
		end
	end

	self.bulinTip = AprilFoolBulinSubView.ShowAprilFoolBulin(self, self.topItems)
end

function StoreHouseScene:isDefaultStatus()
	return underscore(self.contextData.indexDatas):chain():keys():all(function(arg_50_0)
		return self.contextData.indexDatas[arg_50_0] == StoreHouseConst.EQUIPMENT_INDEX_COMMON.customPanels[arg_50_0].options[1]
	end):value()
end

function StoreHouseScene:isDefaultSpWeaponIndexData()
	return underscore(self.contextData.spweaponIndexDatas):chain():keys():all(function(arg_52_0)
		return self.contextData.spweaponIndexDatas[arg_52_0] == StoreHouseConst.SPWEAPON_INDEX_COMMON.customPanels[arg_52_0].options[1]
	end):value()
end

function StoreHouseScene:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	if isActive(self.sortPanel) then
		triggerButton(self.sortPanel)
	elseif self.destroyConfirmView:isShowing() then
		self.destroyConfirmView:Hide()
	elseif self.assignedItemView:isShowing() then
		self.assignedItemView:Hide()
	elseif self.blueprintAssignedItemView:isShowing() then
		self.blueprintAssignedItemView:Hide()
	elseif self.equipDestroyConfirmWindow:isShowing() then
		self.equipDestroyConfirmWindow:Hide()
	else
		triggerButton(self.backBtn)
	end
end

function StoreHouseScene:updateCapacity()
	if self.contextData.warp == StoreHouseConst.WARP_TO_MATERIAL then
		return
	end

	setText(self.tip, "")
	setText(self.capacityTF, self.capacity .. "/" .. self.player:getMaxEquipmentBag())
end

function StoreHouseScene:setCapacity(arg_55_1)
	self.capacity = arg_55_1
end

function StoreHouseScene:UpdateSpweaponCapacity()
	local var_56_0 = getProxy(EquipmentProxy)

	setText(self.capacityTF, var_56_0:GetSpWeaponCount() .. "/" .. var_56_0:GetSpWeaponCapacity())
end

function StoreHouseScene:setShip(arg_57_1)
	self.shipVO = arg_57_1

	setActive(self.bottomPanel, not tobool(arg_57_1))
end

function StoreHouseScene:setPlayer(arg_58_1)
	self.player = arg_58_1

	if self.contextData.warp == StoreHouseConst.WARP_TO_WEAPON and self.page == var_0_2 then
		self:updateCapacity()
	elseif self.contextData.warp == StoreHouseConst.WARP_TO_DESIGN and self.contextData.designPage == var_0_5 then
		self:updateCapacity()
	end
end

function StoreHouseScene:initSort()
	onButton(self, self.decBtn, function()
		self.asc = not self.asc
		self.contextData.asc = self.asc

		self:filterEquipment()
	end)

	self.sortButtons = {}

	eachChild(self.sortContain, function(arg_61_0)
		setActive(arg_61_0, false)
	end)

	for iter_59_0, iter_59_1 in ipairs(EquipmentSortCfg.sort) do
		local var_59_0 = iter_59_0 <= self.sortContain.childCount and self.sortContain:GetChild(iter_59_0 - 1) or cloneTplTo(self.sortTpl, self.sortContain)

		setActive(var_59_0, true)
		setImageSprite(findTF(var_59_0, "Image"), GetSpriteFromAtlas("ui/equipmentui_atlas", iter_59_1.spr), true)
		onToggle(self, var_59_0, function(arg_62_0)
			if arg_62_0 then
				if self.page == var_0_2 then
					self.contextData.sortData = iter_59_1
				elseif self.page == var_0_4 then
					self.contextData.spweaponSortData = SpWeaponSortCfg.sort[iter_59_0]
				end

				self:filterEquipment()
				triggerToggle(self.sortBtn, false)
			end
		end, SFX_PANEL)

		self.sortButtons[iter_59_0] = var_59_0
	end
end

function StoreHouseScene:UpdateWeaponWrapButtons()
	setActive(self.indexBtn, self.page == var_0_2 or self.page == var_0_4)
	setActive(self.sortBtn, self.page == var_0_2 or self.page == var_0_4)
	setActive(self.BatchDisposeBtn, self.page == var_0_2)
	setActive(self.capacityTF.parent, self.page == var_0_2 or self.page == var_0_4)
	setActive(self.equipSkinFilteBtn, self.page == var_0_3)
	setActive(self.filterBusyToggle, self.mode == StoreHouseConst.OVERVIEW)
	setActive(self.equipmentToggle, self.mode == StoreHouseConst.OVERVIEW and not self.contextData.shipId)
	self:updatePageFilterButtons(self.page)
end

function StoreHouseScene:updatePageFilterButtons(arg_64_1)
	for iter_64_0, iter_64_1 in ipairs(EquipmentSortCfg.sort) do
		triggerToggle(self.sortButtons[iter_64_0], false)
		setActive(self.sortButtons[iter_64_0], table.contains(iter_64_1.pages, arg_64_1))
	end
end

function StoreHouseScene:initEquipments()
	self.isInitWeapons = true
	self.equipmentRect = self.equipmentView:GetComponent("LScrollRect")

	function self.equipmentRect.onInitItem(arg_66_0)
		self:initEquipment(arg_66_0)
	end

	function self.equipmentRect.onUpdateItem(arg_67_0, arg_67_1)
		self:updateEquipment(arg_67_0, arg_67_1)
	end

	function self.equipmentRect.onReturnItem(arg_68_0, arg_68_1)
		self:returnEquipment(arg_68_0, arg_68_1)
	end

	function self.equipmentRect.onStart()
		self:updateSelected()
	end

	self.equipmentRect.decelerationRate = 0.07
end

function StoreHouseScene:initEquipment(arg_70_1)
	local var_70_0 = EquipmentItem.New(arg_70_1)

	onButton(self, var_70_0.unloadBtn, function()
		if self.page == var_0_3 then
			self:emit(EquipmentMediator.ON_UNEQUIP_EQUIPMENT_SKIN)
		elseif self.page == var_0_2 then
			self:emit(EquipmentMediator.ON_UNEQUIP_EQUIPMENT)
		end
	end, SFX_PANEL)
	onButton(self, var_70_0.reduceBtn, function()
		self:selectEquip(var_70_0.equipmentVO, 1)
	end, SFX_PANEL)

	self.equipmetItems[arg_70_1] = var_70_0
end

function StoreHouseScene:updateEquipment(arg_73_1, arg_73_2)
	assert(self.equipmetItems[arg_73_2], "without init item")

	local var_73_0 = self.loadEquipmentVOs[arg_73_1 + 1]

	self.equipmetItems[arg_73_2]:update(self.loadEquipmentVOs[arg_73_1 + 1])

	local var_73_1 = false
	local var_73_2 = 0

	if self.loadEquipmentVOs[arg_73_1 + 1] then
		for iter_73_0, iter_73_1 in ipairs(self.selectedIds) do
			if self.loadEquipmentVOs[arg_73_1 + 1].id == iter_73_1[1] then
				var_73_1 = true
				var_73_2 = iter_73_1[2]

				break
			end
		end
	end

	self.equipmetItems[arg_73_2]:updateSelected(var_73_1, var_73_2)

	if not self.loadEquipmentVOs[arg_73_1 + 1] then
		removeOnButton(self.equipmetItems[arg_73_2].go)
	elseif isa(self.loadEquipmentVOs[arg_73_1 + 1], SpWeapon) then
		onButton(self, self.equipmetItems[arg_73_2].go, function()
			local var_74_0

			if self.shipVO then
				var_74_0 = {
					type = EquipmentInfoMediator.TYPE_REPLACE,
					shipId = self.contextData.shipId,
					oldSpWeaponUid = var_73_0:GetUID(),
					oldShipId = var_73_0:GetShipId()
				}

				if not var_74_0 then
					if var_73_0:GetShipId() then
						var_74_0 = {
							type = EquipmentInfoMediator.TYPE_DISPLAY,
							spWeaponUid = var_73_0:GetUID(),
							shipId = var_73_0:GetShipId()
						} or {
							type = EquipmentInfoMediator.TYPE_DEFAULT,
							spWeaponUid = var_73_0:GetUID()
						}
					end
				end
			end

			self:emit(StoreHouseScene.ON_SPWEAPON, var_74_0)
		end, SFX_PANEL)
	elseif self.equipmetItems[arg_73_2].equipmentVO.isSkin then
		if self.loadEquipmentVOs[arg_73_1 + 1].shipId then
			onButton(self, self.equipmetItems[arg_73_2].go, function()
				assert(var_73_0.shipPos, "equipment skin pos is nil")
				self:emit(EquipmentMediator.ON_EQUIPMENT_SKIN_INFO, var_73_0.id, self.contextData.pos, {
					id = var_73_0.shipId,
					pos = var_73_0.shipPos
				})
			end, SFX_PANEL)
		else
			onButton(self, self.equipmetItems[arg_73_2].go, function()
				self:emit(EquipmentMediator.ON_EQUIPMENT_SKIN_INFO, var_73_0.id, self.contextData.pos)
			end, SFX_PANEL)
		end
	elseif self.loadEquipmentVOs[arg_73_1 + 1].mask then
		removeOnButton(self.equipmetItems[arg_73_2].go)
	elseif self.mode == StoreHouseConst.DESTROY then
		onButton(self, self.equipmetItems[arg_73_2].go, function()
			self:selectEquip(var_73_0, var_73_0.count)
		end, SFX_PANEL)
	else
		onButton(self, self.equipmetItems[arg_73_2].go, function()
			self:emit(StoreHouseScene.ON_EQUIPMENT, self.shipVO and {
				type = EquipmentInfoMediator.TYPE_REPLACE,
				equipmentId = var_73_0.id,
				shipId = self.contextData.shipId,
				pos = self.contextData.pos,
				oldShipId = var_73_0.shipId,
				oldPos = var_73_0.shipPos
			} or var_73_0.shipId and {
				showTransformTip = true,
				type = EquipmentInfoMediator.TYPE_DISPLAY,
				equipmentId = var_73_0.id,
				shipId = var_73_0.shipId,
				pos = var_73_0.shipPos
			} or {
				destroy = true,
				type = EquipmentInfoMediator.TYPE_DEFAULT,
				equipmentId = var_73_0.id
			})
		end, SFX_PANEL)
	end
end

function StoreHouseScene:returnEquipment(arg_79_1, arg_79_2)
	if self.exited then
		return
	end

	local var_79_0 = self.equipmetItems[arg_79_2]

	if self.equipmetItems[arg_79_2] then
		removeOnButton(var_79_0.go)
		var_79_0:clear()
	end
end

function StoreHouseScene:updateEquipmentCount(arg_80_1)
	self.equipmentRect:SetTotalCount(arg_80_1 or #self.loadEquipmentVOs, -1)
	setActive(self.listEmptyTF, (arg_80_1 or #self.loadEquipmentVOs) <= 0)
	setText(self.listEmptyTxt, i18n("list_empty_tip_storehouseui_equip"))
	Canvas.ForceUpdateCanvases()
end

function StoreHouseScene:filterEquipment()
	if self.filterEquipWaitting > 0 then
		self.filterEquipWaitting = self.filterEquipWaitting - 1

		return
	end

	if self.page == var_0_3 then
		self:filterEquipSkin()

		return
	else
		local var_81_0

		if self.page == var_0_4 then
			self:filterSpWeapon()

			do return end

			var_81_0 = GetSpriteFromAtlasAsync
		end
	end

	var_81_0("ui/share/index_atlas", self:isDefaultStatus() and "shaixuan_off" or "shaixuan_on", function(arg_82_0)
		setImageSprite(self.indexBtn, arg_82_0, true)
	end)

	local var_81_1 = {}

	self.loadEquipmentVOs = {}

	for iter_81_0, iter_81_1 in pairs(self.equipmentVOs) do
		if not iter_81_1.isSkin then
			table.insert(var_81_1, iter_81_1)
		end
	end

	local var_81_2 = {
		self.contextData.indexDatas.equipPropertyIndex,
		self.contextData.indexDatas.equipPropertyIndex2
	}

	for iter_81_2, iter_81_3 in pairs(var_81_1) do
		if (iter_81_3.count > 0 or iter_81_3.shipId) and self:checkFitBusyCondition(iter_81_3) and IndexConst.filterEquipByType(iter_81_3, self.contextData.indexDatas.typeIndex) and IndexConst.filterEquipByProperty(iter_81_3, var_81_2) and IndexConst.filterEquipAmmo1(iter_81_3, self.contextData.indexDatas.equipAmmoIndex1) and IndexConst.filterEquipAmmo2(iter_81_3, self.contextData.indexDatas.equipAmmoIndex2) and IndexConst.filterEquipByCamp(iter_81_3, self.contextData.indexDatas.equipCampIndex) and IndexConst.filterEquipByRarity(iter_81_3, self.contextData.indexDatas.rarityIndex) and IndexConst.filterEquipByExtra(iter_81_3, self.contextData.indexDatas.extraIndex) then
			table.insert(self.loadEquipmentVOs, iter_81_3)
		end
	end

	if self.filterImportance ~= nil then
		for iter_81_4 = #self.loadEquipmentVOs, 1, -1 do
			if self.loadEquipmentVOs[iter_81_4].isSkin or not self.loadEquipmentVOs[iter_81_4].isSkin and self.loadEquipmentVOs[iter_81_4]:isImportance() then
				table.remove(self.loadEquipmentVOs, iter_81_4)
			end
		end
	end

	local var_81_3 = self.searchBar:GetInputText()

	if var_81_3 and var_81_3 ~= "" then
		self.loadEquipmentVOs = underscore.filter(self.loadEquipmentVOs, function(arg_83_0)
			return arg_83_0:IsMatchKey(var_81_3)
		end)
	end

	local var_81_4 = self.contextData.sortData

	if self.contextData.sortData then
		table.sort(self.loadEquipmentVOs, CompareFuncs(EquipmentSortCfg.sortFunc(var_81_4, self.asc)))
	end

	if self.contextData.qiutBtn then
		table.insert(self.loadEquipmentVOs, 1, false)
	end

	self:updateSelected()
	self:updateEquipmentCount()
	setImageSprite(self.sortBtn:Find("Image"), GetSpriteFromAtlas("ui/equipmentui_atlas", var_81_4.spr), true)
	setActive(self.sortImgAsc, self.asc)
	setActive(self.sortImgDec, not self.asc)
	self:updateCapacity()
end

function StoreHouseScene:filterEquipSkin()
	local var_84_0 = {}

	self.loadEquipmentVOs = {}

	if self.page ~= var_0_3 then
		assert(false, "不是外观分页")
	end

	local var_84_1 = self.searchBar:GetInputText()

	for iter_84_0, iter_84_1 in pairs(self.equipmentVOs) do
		if iter_84_1.isSkin and iter_84_1.count > 0 and (var_84_1 == "" or EquipmentTools.IsMatchEquipmentSkinKey(iter_84_1.id, var_84_1)) then
			table.insert(var_84_0, iter_84_1)
		end
	end

	for iter_84_2, iter_84_3 in pairs(var_84_0) do
		if IndexConst.filterEquipSkinByIndex(iter_84_3, self.equipSkinIndex) and IndexConst.filterEquipSkinByTheme(iter_84_3, self.equipSkinTheme) and self:checkFitBusyCondition(iter_84_3) then
			table.insert(self.loadEquipmentVOs, iter_84_3)
		end
	end

	if self.filterImportance ~= nil then
		for iter_84_4 = #self.loadEquipmentVOs, 1, -1 do
			if self.loadEquipmentVOs[iter_84_4].isSkin or not self.loadEquipmentVOs[iter_84_4].isSkin and self.loadEquipmentVOs[iter_84_4]:isImportance() then
				table.remove(self.loadEquipmentVOs, iter_84_4)
			end
		end
	end

	if self.contextData.sortData then
		table.sort(self.loadEquipmentVOs, CompareFuncs(EquipmentSortCfg.sortFunc(self.contextData.sortData, self.asc)))
	end

	if self.contextData.qiutBtn then
		table.insert(self.loadEquipmentVOs, 1, false)
	end

	self:updateSelected()
	self:updateEquipmentCount()
	setActive(self.sortImgAsc, self.asc)
	setActive(self.sortImgDec, not self.asc)
end

function StoreHouseScene:filterSpWeapon()
	local var_85_0

	if self.page ~= var_0_4 then
		assert(false, "不是特殊兵装分页")

		var_85_0 = GetSpriteFromAtlasAsync
	end

	var_85_0("ui/share/index_atlas", self:isDefaultSpWeaponIndexData() and "shaixuan_off" or "shaixuan_on", function(arg_86_0)
		setImageSprite(self.indexBtn, arg_86_0, true)
	end)

	self.loadEquipmentVOs = {}

	for iter_85_0, iter_85_1 in pairs(self.spweaponVOs) do
		if IndexConst.filterSpWeaponByType(iter_85_1, self.contextData.spweaponIndexDatas.typeIndex) and IndexConst.filterSpWeaponByRarity(iter_85_1, self.contextData.spweaponIndexDatas.rarityIndex) and self:checkFitBusyCondition(iter_85_1) and (self.filterImportance == nil or iter_85_1:IsImportant()) then
			table.insert(self.loadEquipmentVOs, iter_85_1)
		end
	end

	local var_85_1 = self.searchBar:GetInputText()

	if var_85_1 and var_85_1 ~= "" then
		local var_85_2 = EquipmentTools.GetMatchSpEquipmentListKeyByShip(var_85_1)

		self.loadEquipmentVOs = underscore.filter(self.loadEquipmentVOs, function(arg_87_0)
			return arg_87_0:IsMatchKey(var_85_1) or table.contains(var_85_2, arg_87_0.id)
		end)
	end

	local var_85_3 = self.contextData.spweaponSortData

	if self.contextData.spweaponSortData then
		table.sort(self.loadEquipmentVOs, CompareFuncs(SpWeaponSortCfg.sortFunc(var_85_3, self.asc)))
	end

	if self.contextData.qiutBtn then
		table.insert(self.loadEquipmentVOs, 1, false)
	end

	self:updateSelected()
	self:updateEquipmentCount()
	setImageSprite(self.sortBtn:Find("Image"), GetSpriteFromAtlas("ui/equipmentui_atlas", var_85_3.spr), true)
	setActive(self.sortImgAsc, self.asc)
	setActive(self.sortImgDec, not self.asc)
	self:UpdateSpweaponCapacity()
end

function StoreHouseScene:GetShowBusyFlag()
	return self.isEquipingOn
end

function StoreHouseScene:SetShowBusyFlag(arg_89_1)
	self.isEquipingOn = arg_89_1
end

function StoreHouseScene:Scroll2Equip(arg_90_1)
	if self.contextData.warp ~= StoreHouseConst.WARP_TO_WEAPON or self.page ~= var_0_2 then
		return
	end

	for iter_90_0, iter_90_1 in ipairs(self.loadEquipmentVOs) do
		if EquipmentProxy.SameEquip(iter_90_1, arg_90_1) then
			local var_90_0 = self.equipmentView:Find("equipment_grid"):GetComponent(typeof(GridLayoutGroup))

			self:ScrollEquipPos((var_90_0.cellSize.y + var_90_0.spacing.y) * math.floor((iter_90_0 - 1) / var_90_0.constraintCount) + self.equipmentRect.paddingFront + self.equipmentView.rect.height * 0.5 - self.equipmentRect.paddingFront)

			break
		end
	end
end

function StoreHouseScene:ScrollEquipPos(arg_91_1)
	local var_91_0 = self.equipmentView:Find("equipment_grid")
	local var_91_1 = var_91_0:GetComponent(typeof(GridLayoutGroup))
	local var_91_2 = var_91_0 - self.equipmentView.rect.height

	var_91_2 = var_91_0 - self.equipmentView.rect.height > 0 and var_91_2 or (var_91_1.cellSize.y + var_91_1.spacing.y) * math.ceil(#self.loadEquipmentVOs / var_91_1.constraintCount) - var_91_1.spacing.y + self.equipmentRect.paddingFront + self.equipmentRect.paddingEnd

	self.equipmentRect:ScrollTo((arg_91_1 - self.equipmentView.rect.height * 0.5) / var_91_2)
end

function StoreHouseScene:checkFitBusyCondition(arg_92_1)
	return not arg_92_1.shipId or self:GetShowBusyFlag() and self.mode ~= StoreHouseConst.DESTROY
end

function StoreHouseScene:setItems(arg_93_1)
	self.itemVOs = arg_93_1

	if self.isInitItems and self.contextData.warp == StoreHouseConst.WARP_TO_MATERIAL then
		self:sortItems()
	end
end

function StoreHouseScene:initItems()
	self.isInitItems = true
	self.itemRect = self.itemView:GetComponent("LScrollRect")

	function self.itemRect.onInitItem(arg_95_0)
		self:initItem(arg_95_0)
	end

	function self.itemRect.onUpdateItem(arg_96_0, arg_96_1)
		self:updateItem(arg_96_0, arg_96_1)
	end

	function self.itemRect.onReturnItem(arg_97_0, arg_97_1)
		self:returnItem(arg_97_0, arg_97_1)
	end

	self.itemRect.decelerationRate = 0.07
end

function StoreHouseScene:sortItems()
	table.sort(self.itemVOs, CompareFuncs({
		function(arg_99_0)
			return -arg_99_0:getConfig("order")
		end,
		function(arg_100_0)
			return -arg_100_0:getConfig("rarity")
		end,
		function(arg_101_0)
			return arg_101_0.id
		end
	}))
	self.itemRect:SetTotalCount(#self.itemVOs, -1)
	setActive(self.listEmptyTF, #self.itemVOs <= 0)
	setText(self.listEmptyTxt, i18n("list_empty_tip_storehouseui_item"))
	Canvas.ForceUpdateCanvases()
end

function StoreHouseScene:initItem(arg_102_1)
	self.itemCards[arg_102_1] = ItemCard.New(arg_102_1)
end

function StoreHouseScene:updateItem(arg_103_1, arg_103_2)
	assert(self.itemCards[arg_103_2], "without init item")

	local var_103_0 = self.itemVOs[arg_103_1 + 1]

	self.itemCards[arg_103_2]:update(self.itemVOs[arg_103_1 + 1])

	if not self.itemVOs[arg_103_1 + 1] then
		removeOnButton(self.itemCards[arg_103_2].go)
	elseif tobool(getProxy(TechnologyProxy):getItemCanUnlockBluePrint(self.itemVOs[arg_103_1 + 1].id)) then
		local var_103_1 = getProxy(TechnologyProxy)
		local var_103_2 = underscore.map(var_103_1:getItemCanUnlockBluePrint(self.itemVOs[arg_103_1 + 1].id), function(arg_104_0)
			return var_103_1:getBluePrintById(arg_104_0)
		end)
		local var_103_3 = underscore.detect(var_103_2, function(arg_105_0)
			return not arg_105_0:isUnlock()
		end)

		if var_103_3 then
			onButton(self, self.itemCards[arg_103_2].go, function()
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_BLUEPRINT_UNLOCK_ITEM,
					item = var_103_0,
					blueprints = var_103_2,
					onYes = function()
						self:emit(EquipmentMediator.ITEM_GO_SCENE, SCENE.SHIPBLUEPRINT, {
							shipBluePrintVO = var_103_3
						})
					end,
					yesText = i18n("text_forward")
				})
			end, SFX_PANEL)
		else
			onButton(self, self.itemCards[arg_103_2].go, function()
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					type = MSGBOX_TYPE_BLUEPRINT_UNLOCK_ITEM,
					windowSize = Vector2(1010, 685),
					item = var_103_0,
					blueprints = var_103_2,
					onYes = function()
						pg.MsgboxMgr.GetInstance():ShowMsgBox({
							type = MSGBOX_TYPE_ITEM_BOX,
							content = i18n("techpackage_item_use_confirm"),
							items = underscore.map(var_103_0:getConfig("display_icon"), function(arg_110_0)
								return {
									type = arg_110_0[1],
									id = arg_110_0[2],
									count = arg_110_0[3]
								}
							end),
							onYes = function()
								self:emit(EquipmentMediator.ON_USE_ITEM, var_103_0.id, 1)
							end
						})
					end
				})
			end, SFX_PANEL)
		end
	elseif self.itemVOs[arg_103_1 + 1]:getConfig("type") == Item.INVITATION_TYPE then
		onButton(self, self.itemCards[arg_103_2].go, function()
			self:emit(EquipmentMediator.ITEM_GO_SCENE, SCENE.INVITATION, {
				itemVO = var_103_0
			})
		end, SFX_PANEL)
	elseif self.itemVOs[arg_103_1 + 1]:getConfig("type") == Item.ASSIGNED_TYPE or self.itemVOs[arg_103_1 + 1]:getConfig("type") == Item.EQUIPMENT_ASSIGNED_TYPE then
		if self.itemVOs[arg_103_1 + 1]:getConfig("usage") == ItemUsage.EX_RE_MAP then
			onButton(self, self.itemCards[arg_103_2].go, function()
				self:emit(StoreHouseScene.ON_ITEM, var_103_0.id)
			end, SFX_PANEL)
		elseif underscore.any(pg.gameset.general_blueprint_list.description, function(arg_114_0)
			return var_103_0.id == arg_114_0
		end) then
			onButton(self, self.itemCards[arg_103_2].go, function()
				self.blueprintAssignedItemView:Load()
				self.blueprintAssignedItemView:ActionInvoke("Show")
				self.blueprintAssignedItemView:ActionInvoke("update", var_103_0)
			end, SFX_PANEL)
		else
			onButton(self, self.itemCards[arg_103_2].go, function()
				self.assignedItemView:Load()
				self.assignedItemView:ActionInvoke("Show")
				self.assignedItemView:ActionInvoke("update", var_103_0)
			end, SFX_PANEL)
		end
	elseif Item.IsLoveLetterCheckItem(self.itemVOs[arg_103_1 + 1].id) then
		onButton(self, self.itemCards[arg_103_2].go, function()
			self:emit(StoreHouseScene.ON_ITEM_EXTRA, var_103_0.id, var_103_0.extra)
		end, SFX_PANEL)
	elseif self.itemVOs[arg_103_1 + 1]:getConfig("type") == Item.LOVE_LETTER_TYPE then
		onButton(self, self.itemCards[arg_103_2].go, function()
			self:emit(StoreHouseScene.ON_ITEM_EXTRA, var_103_0.id, var_103_0.extra)
		end, SFX_PANEL)
	elseif self.itemVOs[arg_103_1 + 1]:getConfig("type") == Item.SKIN_ASSIGNED_TYPE then
		onButton(self, self.itemCards[arg_103_2].go, function()
			self:emit(StoreHouseScene.ON_ITEM, var_103_0.id, function()
				local var_120_0 = var_103_0:getConfig("usage_arg")

				if var_103_0:IsAllSkinOwner() then
					local var_120_1 = Drop.New({
						count = 1,
						type = DROP_TYPE_ITEM,
						id = var_120_0[5]
					})

					self.msgBox:ExecuteAction("Show", {
						content = i18n("blackfriday_pack_select_skinall_dialog", var_103_0:getConfig("name"), var_120_1:getName()),
						leftDrop = {
							count = 1,
							type = DROP_TYPE_ITEM,
							id = var_103_0.id
						},
						rightDrop = var_120_1,
						onYes = function()
							self:emit(EquipmentMediator.ON_USE_ITEM, var_103_0.id, 1, {
								0
							})
						end
					})
				else
					local var_120_2 = {}

					for iter_120_0, iter_120_1 in ipairs(var_120_0[2]) do
						var_120_2[iter_120_1] = true
					end

					self:emit(EquipmentMediator.ITEM_ADD_LAYER, Context.New({
						viewComponent = NewSelectSkinLayer,
						mediator = NewSkinAtlasMediator,
						data = {
							mode = SelectSkinLayer.MODE_SELECT,
							itemId = var_103_0.id,
							selectableSkinList = underscore.map(var_103_0:GetValidSkinList(), function(arg_122_0)
								local var_122_0 = {
									id = arg_122_0
								}

								var_122_0.isTimeLimit = var_120_2[arg_122_0] or false

								return SelectableSkin.New(var_122_0)
							end),
							OnConfirm = function(arg_123_0)
								self:emit(EquipmentMediator.ON_USE_ITEM, var_103_0.id, 1, {
									arg_123_0
								})
							end
						}
					}))
				end
			end)
		end, SFX_PANEL)
	else
		onButton(self, self.itemCards[arg_103_2].go, function()
			self:emit(StoreHouseScene.ON_ITEM, var_103_0.id)
		end, SFX_PANEL)
	end
end

function StoreHouseScene:returnItem(arg_125_1, arg_125_2)
	if self.exited then
		return
	end

	local var_125_0 = self.itemCards[arg_125_2]

	if self.itemCards[arg_125_2] then
		removeOnButton(var_125_0.go)
		var_125_0:clear()
	end
end

function StoreHouseScene:selectCount()
	local var_126_0 = 0

	for iter_126_0, iter_126_1 in ipairs(self.selectedIds) do
		var_126_0 = var_126_0 + iter_126_1[2]
	end

	return var_126_0
end

function StoreHouseScene:selectEquip(arg_127_1, arg_127_2)
	if not self:checkDestroyGold(arg_127_1, arg_127_2) then
		return
	end

	if self.mode == StoreHouseConst.DESTROY then
		local var_127_0 = false
		local var_127_1
		local var_127_2 = 0

		for iter_127_0, iter_127_1 in pairs(self.selectedIds) do
			if iter_127_1[1] == arg_127_1.id then
				var_127_0 = true
				var_127_1 = iter_127_0
				var_127_2 = iter_127_1[2]

				break
			end
		end

		if not var_127_0 then
			local var_127_3, var_127_4 = self.checkEquipment(arg_127_1, function()
				self:selectEquip(arg_127_1, arg_127_2)
			end, self.selectedIds)

			if not var_127_3 then
				if var_127_4 then
					pg.TipsMgr.GetInstance():ShowTips(var_127_4)
				end

				return
			end

			local var_127_5 = self:selectCount()

			if self.selectedMax > 0 and var_127_5 + arg_127_2 > self.selectedMax then
				arg_127_2 = self.selectedMax - var_127_5
			end

			if self.selectedMax == 0 or var_127_5 < self.selectedMax then
				table.insert(self.selectedIds, {
					arg_127_1.id,
					arg_127_2
				})
			elseif self.selectedMax == 1 then
				self.selectedIds[1] = {
					arg_127_1.id,
					arg_127_2
				}
			else
				pg.TipsMgr.GetInstance():ShowTips(i18n("equipment_equipmentScene_selectError_more", self.selectedMax))

				return
			end
		elseif var_127_2 - arg_127_2 > 0 then
			self.selectedIds[var_127_1][2] = var_127_2 - arg_127_2
		else
			table.remove(self.selectedIds, var_127_1)
		end
	end

	self:updateSelected()
end

function StoreHouseScene:unselecteAllEquips()
	self.selectedIds = {}

	self:updateSelected()
end

function StoreHouseScene:checkDestroyGold(arg_130_1, arg_130_2)
	local var_130_0 = 0
	local var_130_1 = false

	for iter_130_0, iter_130_1 in pairs(self.selectedIds) do
		if Equipment.CanInBag(iter_130_1[1]) then
			var_130_0 = var_130_0 + (Equipment.getConfigData(iter_130_1[1]).destory_gold or 0) * iter_130_1[2]
		end

		if arg_130_1 and iter_130_1[1] == arg_130_1.configId then
			var_130_1 = true
		end
	end

	if not var_130_1 and arg_130_1 and arg_130_2 > 0 then
		var_130_0 = var_130_0 + (arg_130_1:getConfig("destory_gold") or 0) * arg_130_2
	end

	if self.player:GoldMax(var_130_0) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title") .. i18n("resource_max_tip_destroy"))

		return false
	end

	return true
end

function StoreHouseScene:updateSelected()
	for iter_131_0, iter_131_1 in pairs(self.equipmetItems) do
		if iter_131_1.equipmentVO then
			local var_131_0 = false
			local var_131_1 = 0

			for iter_131_2, iter_131_3 in pairs(self.selectedIds) do
				if iter_131_1.equipmentVO.id == iter_131_3[1] then
					var_131_0 = true
					var_131_1 = iter_131_3[2]

					break
				end
			end

			iter_131_1:updateSelected(var_131_0, var_131_1)
		end
	end

	if self.mode == StoreHouseConst.DESTROY then
		local var_131_2 = self:selectCount()

		if self.selectedMax == 0 then
			setText(findTF(self.selectPanel, "bottom_info/bg_input/count"), var_131_2)
		else
			setText(findTF(self.selectPanel, "bottom_info/bg_input/count"), var_131_2 .. "/" .. self.selectedMax)
		end

		if #self.selectedIds < self.selectedMin then
			setActive(findTF(self.selectPanel, "confirm_button/mask"), true)
		else
			setActive(findTF(self.selectPanel, "confirm_button/mask"), false)
		end
	end
end

function StoreHouseScene:SwitchToDestroy()
	self.page = var_0_2
	self.filterEquipWaitting = self.filterEquipWaitting + 1

	triggerToggle(self.weaponToggle, true)
	triggerButton(self.BatchDisposeBtn)
end

function StoreHouseScene:SwitchToSpWeaponStoreHouse()
	self.page = var_0_4

	triggerToggle(self.weaponToggle, true)
end

function StoreHouseScene:SwitchEquipmentType(arg_134_1)
	self.searchBar:UpdateHolder(arg_134_1 == var_0_4 and i18n("search_sp_equipment") or arg_134_1 == var_0_3 and i18n("search_equipment_appearance") or i18n("search_equipment"))
	self.searchBar:ClearInputText()
end

function StoreHouseScene:willExit()
	self:UnOverlayPanel(self.blurPanel, self._tf)
	self:UnOverlayPanel(self.topItems, self._tf)

	if self.bulinTip then
		self.bulinTip:Destroy()

		self.bulinTip = nil
	end

	if self.searchBar then
		self.searchBar:Dispose()

		self.searchBar = nil
	end

	self.destroyConfirmView:Destroy()
	self.assignedItemView:Destroy()
	self.blueprintAssignedItemView:Destroy()
	self.equipDestroyConfirmWindow:Destroy()
	self.msgBox:Destroy()
end

return StoreHouseScene
