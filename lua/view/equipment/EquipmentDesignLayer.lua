local EquipmentDesignLayer = class("EquipmentDesignLayer", import("..base.BaseUI"))

function EquipmentDesignLayer:getUIName()
	return "EquipmentDesignUI"
end

function EquipmentDesignLayer:getResource()
	local var_2_0 = {
		"ui/equipmentdesignui",
		"ui/equipmentdesignui_atlas",
		"ui/equipmenttransformui_atlas",
		"equiptype",
		"bg/equipment_bg_1",
		"bg/equipment_bg_2",
		"bg/equipment_bg_3",
		"bg/equipment_bg_4",
		"bg/equipment_bg_5",
		"bg/equipment_bg_6"
	}

	table.insertto(var_2_0, EquipmentDesignLayer.super.getResource(self))

	return var_2_0
end

function EquipmentDesignLayer:setItems(arg_3_1)
	self.itemVOs = arg_3_1
end

function EquipmentDesignLayer:setPlayer(arg_4_1)
	self.player = arg_4_1
end

function EquipmentDesignLayer:setCapacity(arg_5_1)
	self.capacity = arg_5_1
end

function EquipmentDesignLayer:init()
	self.designScrollView = self._tf:Find("equipment_scrollview")
	self.equipmentTpl = self._tf:Find("equipment_tpl")
	self.equipmentContainer = self.designScrollView:Find("equipment_grid")
	self.msgBoxTF = self._tf:Find("msg_panel")

	setActive(self.msgBoxTF, false)

	self.top = self._tf:Find("top")
	self.sortBtn = self.top:Find("sort_button")
	self.indexBtn = self.top:Find("index_button")
	self.decBtn = self.sortBtn:Find("dec_btn")
	self.sortImgAsc = self.decBtn:Find("asc")
	self.sortImgDec = self.decBtn:Find("desc")
	self.indexPanel = self._tf:Find("index")
	self.tagContainer = self.indexPanel:Find("adapt/mask/panel")
	self.tagTpl = self.tagContainer:Find("tpl")
	self.listEmptyTF = self._tf:Find("empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")

	setText(self.listEmptyTxt, i18n("list_empty_tip_equipmentdesignui"))
	self:OverlayPanel(self.indexPanel)

	self.obtainWayPage = EquipmentDesignObtainWayPage.New(self._tf, self.event)

	self.obtainWayPage:RegisterView(self)
end

function EquipmentDesignLayer:SetParentTF(arg_7_1)
	self.parentTF = arg_7_1
	self.equipmentView = self.parentTF:Find("adapt/equipment_scrollview")

	setActive(self.equipmentView, false)
end

function EquipmentDesignLayer:SetTopContainer(arg_8_1)
	self.topPanel = arg_8_1
end

local var_0_1 = {
	"sort_default",
	"sort_rarity",
	"sort_count"
}

function EquipmentDesignLayer:didEnter()
	setParent(self._tf, self.parentTF)
	self._tf:SetSiblingIndex((self.equipmentView:GetSiblingIndex()))

	self.contextData.indexDatas = self.contextData.indexDatas or {}

	setParent(self.top, self.topPanel)
	self:initDesigns()
	onToggle(self, self.sortBtn, function(arg_10_0)
		if arg_10_0 then
			setActive(self.indexPanel, true)
		else
			setActive(self.indexPanel, false)
		end
	end, SFX_PANEL)
	onButton(self, self.indexPanel, function()
		triggerToggle(self.sortBtn, false)
	end, SFX_PANEL)
	onButton(self, self.indexBtn, function()
		self:emit(EquipmentDesignMediator.OPEN_EQUIPMENTDESIGN_INDEX, {
			indexDatas = Clone(self.contextData.indexDatas),
			customPanels = {
				minHeight = 650,
				typeIndex = {
					mode = CustomIndexLayer.Mode.OR,
					options = IndexConst.EquipmentTypeIndexs,
					names = IndexConst.EquipmentTypeNames
				},
				equipPropertyIndex = {
					mode = CustomIndexLayer.Mode.OR,
					options = IndexConst.EquipPropertyIndexs,
					names = IndexConst.EquipPropertyNames
				},
				equipPropertyIndex2 = {
					mode = CustomIndexLayer.Mode.OR,
					options = IndexConst.EquipPropertyIndexs,
					names = IndexConst.EquipPropertyNames
				},
				equipAmmoIndex1 = {
					mode = CustomIndexLayer.Mode.OR,
					options = IndexConst.EquipAmmoIndexs_1,
					names = IndexConst.EquipAmmoIndexs_1_Names
				},
				equipAmmoIndex2 = {
					mode = CustomIndexLayer.Mode.OR,
					options = IndexConst.EquipAmmoIndexs_2,
					names = IndexConst.EquipAmmoIndexs_2_Names
				},
				equipCampIndex = {
					mode = CustomIndexLayer.Mode.AND,
					options = IndexConst.EquipCampIndexs,
					names = IndexConst.EquipCampNames
				},
				rarityIndex = {
					mode = CustomIndexLayer.Mode.AND,
					options = IndexConst.EquipmentRarityIndexs,
					names = IndexConst.RarityNames
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
					dropdown = true,
					titleENTxt = "indexsort_indexeng",
					titleTxt = "indexsort_index",
					tags = {
						"equipPropertyIndex",
						"equipPropertyIndex2",
						"equipAmmoIndex1",
						"equipAmmoIndex2"
					}
				},
				{
					dropdown = false,
					titleENTxt = "indexsort_campeng",
					titleTxt = "indexsort_camp",
					tags = {
						"equipCampIndex"
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
			dropdownLimit = {
				equipPropertyIndex = {
					include = {
						typeIndex = IndexConst.EquipmentTypeAll
					},
					exclude = {}
				},
				equipPropertyIndex2 = {
					include = {
						typeIndex = IndexConst.EquipmentTypeEquip
					},
					exclude = {
						typeIndex = IndexConst.EquipmentTypeAll
					}
				},
				equipAmmoIndex1 = {
					include = {
						typeIndex = IndexConst.BitAll({
							IndexConst.EquipmentTypeSmallCannon,
							IndexConst.EquipmentTypeMediumCannon,
							IndexConst.EquipmentTypeBigCannon
						})
					},
					exclude = {
						typeIndex = IndexConst.EquipmentTypeAll
					}
				},
				equipAmmoIndex2 = {
					include = {
						typeIndex = IndexConst.BitAll({
							IndexConst.EquipmentTypeWarshipTorpedo,
							IndexConst.EquipmentTypeSubmaraineTorpedo
						})
					},
					exclude = {
						typeIndex = IndexConst.EquipmentTypeAll
					}
				}
			},
			callback = function(self)
				if not isActive(self._tf) then
					return
				end

				self.contextData.indexDatas.typeIndex = self.typeIndex
				self.contextData.indexDatas.equipPropertyIndex = self.equipPropertyIndex
				self.contextData.indexDatas.equipPropertyIndex2 = self.equipPropertyIndex2
				self.contextData.indexDatas.equipAmmoIndex1 = self.equipAmmoIndex1
				self.contextData.indexDatas.equipAmmoIndex2 = self.equipAmmoIndex2
				self.contextData.indexDatas.equipCampIndex = self.equipCampIndex
				self.contextData.indexDatas.rarityIndex = self.rarityIndex

				self:filter(self.contextData.index or 1)
			end
		})
	end, SFX_PANEL)
	self:initTags()
end

function EquipmentDesignLayer:isDefaultStatus()
	return (not self.contextData.indexDatas.typeIndex or self.contextData.indexDatas.typeIndex == IndexConst.EquipmentTypeAll) and (not self.contextData.indexDatas.equipPropertyIndex or self.contextData.indexDatas.equipPropertyIndex == IndexConst.EquipPropertyAll) and (not self.contextData.indexDatas.equipPropertyIndex2 or self.contextData.indexDatas.equipPropertyIndex2 == IndexConst.EquipPropertyAll) and (not self.contextData.indexDatas.equipAmmoIndex1 or self.contextData.indexDatas.equipAmmoIndex1 == IndexConst.EquipAmmoAll_1) and (not self.contextData.indexDatas.equipAmmoIndex2 or self.contextData.indexDatas.equipAmmoIndex2 == IndexConst.EquipAmmoAll_2) and (not self.contextData.indexDatas.equipCampIndex or self.contextData.indexDatas.equipCampIndex == IndexConst.EquipCampAll) and (not self.contextData.indexDatas.rarityIndex or self.contextData.indexDatas.rarityIndex == IndexConst.EquipmentRarityAll)
end

function EquipmentDesignLayer:initTags()
	onButton(self, self.decBtn, function()
		self.asc = not self.asc
		self.contextData.asc = self.asc

		self:filter(self.contextData.index or 1)
	end)

	self.tagTFs = {}

	eachChild(self.tagContainer, function(arg_17_0)
		setActive(arg_17_0, false)
	end)

	for iter_15_0, iter_15_1 in ipairs(var_0_1) do
		local var_15_0 = iter_15_0 <= self.tagContainer.childCount and self.tagContainer:GetChild(iter_15_0 - 1) or cloneTplTo(self.tagTpl, self.tagContainer)

		setActive(var_15_0, true)
		setImageSprite(findTF(var_15_0, "Image"), GetSpriteFromAtlas("ui/equipmentdesignui_atlas", iter_15_1))
		onToggle(self, var_15_0, function(arg_18_0)
			if arg_18_0 then
				self:filter(iter_15_0)
				triggerButton(self.indexPanel)

				self.contextData.index = iter_15_0
			else
				triggerButton(self.indexPanel)
			end
		end, SFX_PANEL)
		table.insert(self.tagTFs, var_15_0)

		self.contextData.index = self.contextData.index or iter_15_0
	end

	triggerToggle(self.tagTFs[self.contextData.index], true)
end

function EquipmentDesignLayer:initDesigns()
	self.scollRect = self.designScrollView:GetComponent("LScrollRect")
	self.scollRect.decelerationRate = 0.07

	function self.scollRect.onInitItem(arg_20_0)
		self:initDesign(arg_20_0)
	end

	function self.scollRect.onUpdateItem(arg_21_0, arg_21_1)
		self:updateDesign(arg_21_0, arg_21_1)
	end

	function self.scollRect.onReturnItem(arg_22_0, arg_22_1)
		self:returnDesign(arg_22_0, arg_22_1)
	end

	self.desgins = {}
end

local function var_0_2(arg_23_0, arg_23_1)
	local var_23_0 = findTF(arg_23_0, "attrs")

	setImageSprite(findTF(arg_23_0, "name_bg/tag"), GetSpriteFromAtlas("equiptype", EquipType.type2Tag(arg_23_1:getConfig("type"))))
	eachChild(var_23_0, function(arg_24_0)
		setActive(arg_24_0, false)
	end)

	local var_23_1 = underscore.filter(arg_23_1:GetPropertiesInfo().attrs, function(arg_25_0)
		return not arg_25_0.type or arg_25_0.type ~= AttributeType.AntiSiren
	end)
	local var_23_2 = arg_23_1:getConfig("skill_id")
	local var_23_3 = var_23_2[1] and var_23_2[1][1]

	for iter_23_0, iter_23_1 in ipairs(var_23_3 and arg_23_1:isDevice() and {
		1,
		2,
		5
	} or {
		1,
		4,
		2,
		3
	}) do
		local var_23_4 = var_23_0:Find("attr_" .. iter_23_1)

		setActive(var_23_4, true)

		if iter_23_1 == 5 then
			setText(var_23_4:Find("value"), getSkillName(var_23_3))
		else
			local var_23_5 = ""
			local var_23_6 = ""

			if #var_23_1 > 0 then
				var_23_5, var_23_6 = Equipment.GetInfoTrans((table.remove(var_23_1, 1)))
			end

			setText(var_23_4:Find("tag"), var_23_5)
			setText(var_23_4:Find("value"), var_23_6)
		end
	end
end

function EquipmentDesignLayer:createDesign(arg_26_1)
	arg_26_1 = tf(arg_26_1)

	local var_26_0 = findTF(arg_26_1, "info/count")
	local var_26_1 = findTF(arg_26_1, "mask")
	local var_26_2 = {
		go = arg_26_1,
		nameTxt = arg_26_1:Find("name_bg/mask/name")
	}

	ClearTweenItemAlphaAndWhite(var_26_2.go)

	function var_26_2:getItemById(arg_27_1)
		return self.itemVOs[arg_27_1] or Item.New({
			count = 0,
			id = arg_27_1
		})
	end

	function var_26_2:update(arg_28_1, arg_28_2)
		self.designId = arg_28_1
		self.itemVOs = arg_28_2

		local var_28_0 = pg.compose_data_template[arg_28_1]

		assert(pg.compose_data_template[arg_28_1], "必须存在配置" .. arg_28_1)
		TweenItemAlphaAndWhite(self.go)

		local var_28_1 = Equipment.getConfigData(pg.compose_data_template[arg_28_1].equip_id)

		assert(var_28_1, "必须存在装备" .. pg.compose_data_template[arg_28_1].equip_id)
		setText(self.nameTxt, shortenString(var_28_1.name, 6))

		local var_28_2 = Equipment.New({
			id = pg.compose_data_template[arg_28_1].equip_id
		})

		updateEquipment(findTF(arg_26_1, "equipment/bg"), var_28_2)
		var_0_2(arg_26_1, var_28_2)
		;(function()
			local var_29_0 = self.itemVOs[var_28_0.material_id] or Item.New({
				count = 0,
				id = var_28_0.material_id
			})
			local var_29_1 = var_29_0.count .. "/" .. var_28_0.material_num

			var_29_1 = var_29_0.count >= var_28_0.material_num and setColorStr(var_29_1, COLOR_WHITE) or setColorStr(var_29_1, COLOR_RED)

			setText(var_26_0, var_29_1)
			setActive(var_26_1, var_29_0.count < var_28_0.material_num)
		end)()
	end

	function var_26_2:clear()
		ClearTweenItemAlphaAndWhite(self.go)
	end

	return var_26_2
end

function EquipmentDesignLayer:initDesign(arg_31_1)
	local var_31_0 = self:createDesign(arg_31_1)

	onButton(self, tf(var_31_0.go):Find("info/make_btn"), function()
		self:showDesignDesc(var_31_0.designId)
	end, SFX_PANEL)
	onButton(self, tf(var_31_0.go):Find("look"), function()
		self.obtainWayPage:ExecuteAction("Show", var_31_0.designId)
	end, SFX_PANEL)

	self.desgins[arg_31_1] = var_31_0
end

function EquipmentDesignLayer:updateDesign(arg_34_1, arg_34_2)
	if not self.desgins[arg_34_2] then
		self:initDesign(arg_34_2)
	end

	self.desgins[arg_34_2]:update(self.desginIds[arg_34_1 + 1], self.itemVOs)
end

function EquipmentDesignLayer:returnDesign(arg_35_1, arg_35_2)
	if self.exited then
		return
	end

	if self.desgins[arg_35_2] then
		self.desgins[arg_35_2]:clear()
	end
end

function EquipmentDesignLayer:getDesignVO(arg_36_1)
	local var_36_0 = {}

	var_36_0.equipmentCfg = Equipment.getConfigData(pg.compose_data_template[arg_36_1].equip_id)
	var_36_0.designCfg = pg.compose_data_template[arg_36_1]
	var_36_0.id = arg_36_1

	local var_36_1 = self:getItemById(pg.compose_data_template[arg_36_1].material_id).count

	var_36_0.itemCount = var_36_1
	var_36_0.canMakeCount = math.floor(var_36_1 / pg.compose_data_template[arg_36_1].material_num)
	var_36_0.canMake = math.min(var_36_0.canMakeCount, 1)

	local var_36_2 = Equipment.getConfigData(pg.compose_data_template[arg_36_1].equip_id)

	assert(var_36_2, "equip config not exist: " .. pg.compose_data_template[arg_36_1].equip_id)

	var_36_0.config = var_36_2

	function var_36_0.getNation(arg_37_0)
		return var_36_2.nationality
	end

	function var_36_0.getConfig(arg_38_0, arg_38_1)
		return var_36_2[arg_38_1]
	end

	return var_36_0
end

function EquipmentDesignLayer:filter(arg_39_1, arg_39_2)
	GetSpriteFromAtlasAsync("ui/share/index_atlas", self:isDefaultStatus() and "shaixuan_off" or "shaixuan_on", function(arg_40_0)
		setImageSprite(self.indexBtn, arg_40_0, true)
	end)

	local var_39_0 = {}
	local var_39_1 = getProxy(EquipmentProxy)

	for iter_39_0, iter_39_1 in ipairs(pg.compose_data_template.all) do
		if self:getItemById(pg.compose_data_template[iter_39_1].material_id).count > 0 or self.contextData.isShowAllDesign and var_39_1:ShouldShowEquipmentDesignObtainWay(iter_39_1) then
			table.insert(var_39_0, iter_39_1)
		end
	end

	local var_39_2 = {}
	local var_39_3 = table.mergeArray({}, {
		self.contextData.indexDatas.equipPropertyIndex,
		self.contextData.indexDatas.equipPropertyIndex2
	}, true)

	for iter_39_2, iter_39_3 in pairs(var_39_0) do
		local var_39_4 = self:getDesignVO(iter_39_3)

		if IndexConst.filterEquipByType(var_39_4, self.contextData.indexDatas.typeIndex) and IndexConst.filterEquipByProperty(var_39_4, var_39_3) and IndexConst.filterEquipAmmo1(var_39_4, self.contextData.indexDatas.equipAmmoIndex1) and IndexConst.filterEquipAmmo2(var_39_4, self.contextData.indexDatas.equipAmmoIndex2) and IndexConst.filterEquipByCamp(var_39_4, self.contextData.indexDatas.equipCampIndex) and IndexConst.filterEquipByRarity(var_39_4, self.contextData.indexDatas.rarityIndex) then
			table.insert(var_39_2, iter_39_3)
		end
	end

	if arg_39_1 == 1 then
		if self.asc then
			table.sort(var_39_2, function(arg_41_0, arg_41_1)
				local var_41_0 = self:getDesignVO(arg_41_0)
				local var_41_1 = self:getDesignVO(arg_41_1)

				if var_41_0.canMake == var_41_1.canMake then
					if var_41_0.equipmentCfg.rarity == var_41_1.equipmentCfg.rarity then
						return var_41_0.equipmentCfg.id < var_41_1.equipmentCfg.id
					else
						return var_41_0.equipmentCfg.rarity > var_41_1.equipmentCfg.rarity
					end
				else
					return var_41_0.canMake < var_41_1.canMake
				end
			end)
		else
			table.sort(var_39_2, function(arg_42_0, arg_42_1)
				local var_42_0 = self:getDesignVO(arg_42_0)
				local var_42_1 = self:getDesignVO(arg_42_1)

				if var_42_0.canMake == var_42_1.canMake then
					if var_42_0.equipmentCfg.rarity == var_42_1.equipmentCfg.rarity then
						return var_42_0.equipmentCfg.id < var_42_1.equipmentCfg.id
					else
						return var_42_0.equipmentCfg.rarity > var_42_1.equipmentCfg.rarity
					end
				else
					return var_42_0.canMake > var_42_1.canMake
				end
			end)
		end
	elseif arg_39_1 == 2 then
		if self.asc then
			table.sort(var_39_2, function(arg_43_0, arg_43_1)
				local var_43_0 = self:getDesignVO(arg_43_0)
				local var_43_1 = self:getDesignVO(arg_43_1)

				if var_43_0.equipmentCfg.rarity == var_43_1.equipmentCfg.rarity then
					return var_43_0.equipmentCfg.id < var_43_0.equipmentCfg.id
				end

				return var_43_0.equipmentCfg.rarity < var_43_1.equipmentCfg.rarity
			end)
		else
			table.sort(var_39_2, function(arg_44_0, arg_44_1)
				local var_44_0 = self:getDesignVO(arg_44_0)
				local var_44_1 = self:getDesignVO(arg_44_1)

				if var_44_0.equipmentCfg.rarity == var_44_1.equipmentCfg.rarity then
					return var_44_0.equipmentCfg.id < var_44_0.equipmentCfg.id
				end

				return var_44_0.equipmentCfg.rarity > var_44_1.equipmentCfg.rarity
			end)
		end
	elseif arg_39_1 == 3 then
		if self.asc then
			table.sort(var_39_2, function(arg_45_0, arg_45_1)
				local var_45_0 = self:getDesignVO(arg_45_0)
				local var_45_1 = self:getDesignVO(arg_45_1)

				if var_45_0.itemCount == var_45_1.itemCount then
					return var_45_0.equipmentCfg.id < var_45_1.equipmentCfg.id
				end

				return var_45_0.itemCount < var_45_1.itemCount
			end)
		else
			table.sort(var_39_2, function(arg_46_0, arg_46_1)
				local var_46_0 = self:getDesignVO(arg_46_0)
				local var_46_1 = self:getDesignVO(arg_46_1)

				if var_46_0.itemCount == var_46_1.itemCount then
					return var_46_0.equipmentCfg.id < var_46_1.equipmentCfg.id
				end

				return var_46_0.itemCount > var_46_1.itemCount
			end)
		end
	end

	self.desginIds = var_39_2

	self.scollRect:SetTotalCount(#var_39_2, arg_39_2 and -1 or 0)
	setActive(self.listEmptyTF, #var_39_2 <= 0)
	Canvas.ForceUpdateCanvases()
	setImageSprite(self.sortBtn:Find("Image"), (GetSpriteFromAtlas("ui/equipmentdesignui_atlas", var_0_1[arg_39_1])))
	setActive(self.sortImgAsc, self.asc)
	setActive(self.sortImgDec, not self.asc)
end

function EquipmentDesignLayer:getItemById(arg_47_1)
	return self.itemVOs[arg_47_1] or Item.New({
		count = 0,
		id = arg_47_1
	})
end

function EquipmentDesignLayer:showDesignDesc(arg_48_1)
	self.isShowDesc = true

	if IsNil(self.msgBoxTF) then
		return
	end

	pg.UIMgr.GetInstance():BlurPanel(self.msgBoxTF)
	setActive(self.msgBoxTF, true)

	local var_48_0 = self.msgBoxTF
	local var_48_1 = pg.compose_data_template[arg_48_1]
	local var_48_2 = Equipment.New({
		id = pg.compose_data_template[arg_48_1].equip_id
	})

	updateEquipInfo(self.msgBoxTF:Find("bg/attrs/content"), var_48_2:GetPropertiesInfo(), var_48_2:GetSkill())
	GetImageSpriteFromAtlasAsync("equips/" .. var_48_2:getConfig("icon"), "", (var_48_0:Find("bg/frame/icon")))
	changeToScrollText(var_48_0:Find("bg/name"), var_48_2:getConfig("name"))
	UIItemList.New(var_48_0:Find("bg/frame/stars"), var_48_0:Find("bg/frame/stars/sarttpl")):align(var_48_2:getConfig("rarity"))
	setImageSprite(findTF(var_48_0, "bg/frame/type"), GetSpriteFromAtlas("equiptype", EquipType.type2Tag(var_48_2:getConfig("type"))))
	setText(var_48_0:Find("bg/frame/speciality/Text"), var_48_2:getConfig("speciality") ~= "无" and var_48_2:getConfig("speciality") or i18n1("—"))

	var_48_0:Find("bg/frame"):GetComponent(typeof(Image)).sprite = LoadSprite("bg/equipment_bg_" .. var_48_2:getConfig("rarity"))

	local var_48_3 = findTF(var_48_0, "bg/frame/numbers")
	local var_48_4 = var_48_2:getConfig("tech") or 1

	for iter_48_0 = 0, var_48_3.childCount - 1 do
		setActive(var_48_3:GetChild(iter_48_0), iter_48_0 == var_48_4)
	end

	local var_48_5 = math.floor(self:getItemById(var_48_1.material_id).count / var_48_1.material_num)
	local var_48_6 = 1
	local var_48_7 = var_48_0:Find("bg/calc/values/Text")
	local var_48_8 = var_48_1.gold_num
	local var_48_9 = var_48_0:Find("bg/calc/gold/Text")

	local function var_48_10(arg_49_0)
		setText(var_48_7, arg_49_0)
		setText(var_48_9, arg_49_0 * var_48_8)
	end

	var_48_10(1)
	pressPersistTrigger(findTF(var_48_0, "bg/calc/minus"), 0.5, function(arg_50_0)
		if var_48_6 <= 1 then
			arg_50_0()

			return
		end

		var_48_6 = var_48_6 - 1

		var_48_10(var_48_6)
	end, nil, true, true, 0.1, SFX_PANEL)
	pressPersistTrigger(findTF(var_48_0, "bg/calc/add"), 0.5, function(arg_51_0)
		if var_48_6 == var_48_5 then
			arg_51_0()

			return
		end

		var_48_6 = var_48_6 + 1

		var_48_10(var_48_6)
	end, nil, true, true, 0.1, SFX_PANEL)
	onButton(self, findTF(var_48_0, "bg/calc/max"), function()
		if var_48_6 == var_48_5 then
			return
		end

		var_48_6 = math.max(math.min(var_48_5, self.player:getMaxEquipmentBag() - self.capacity), 1)

		var_48_10(var_48_6)
	end, SFX_PANEL)
	onButton(self, findTF(var_48_0, "bg/cancel_btn"), function()
		self:hideMsgBox()
	end, SFX_CANCEL)
	onButton(self, findTF(var_48_0, "bg/confirm_btn"), function()
		self:emit(EquipmentDesignMediator.MAKE_EQUIPMENT, arg_48_1, var_48_6)
		self:hideMsgBox()
	end, SFX_CONFIRM)
	onButton(self, var_48_0, function()
		self:hideMsgBox()
	end, SFX_CANCEL)
end

function EquipmentDesignLayer:hideMsgBox()
	if not IsNil(self.msgBoxTF) then
		self.isShowDesc = nil

		pg.UIMgr.GetInstance():UnOverlayPanel(self.msgBoxTF, self._tf)
		setActive(self.msgBoxTF, false)
	end
end

function EquipmentDesignLayer:onBackPressed()
	if isActive(self.indexPanel) then
		triggerButton(self.indexPanel)

		return
	end

	if self.isShowDesc then
		self:hideMsgBox()
	else
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
		self:emit(EquipmentDesignLayer.ON_BACK)
	end
end

function EquipmentDesignLayer:willExit()
	self:UnOverlayPanel(self.indexPanel, self._tf)

	if self.leftEventTrigger then
		ClearEventTrigger(self.leftEventTrigger)
	end

	if self.rightEventTrigger then
		ClearEventTrigger(self.rightEventTrigger)
	end

	setParent(self.sortBtn.parent, self._tf)

	if self.obtainWayPage then
		self.obtainWayPage:Destroy()
	end

	self.obtainWayPage = nil
end

return EquipmentDesignLayer
