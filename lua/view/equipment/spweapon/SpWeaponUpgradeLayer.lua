local SpWeaponUpgradeLayer = class("SpWeaponUpgradeLayer", import("view.base.BaseUI"))
local var_0_1 = 1
local var_0_2 = 2
local var_0_3 = 1
local var_0_4 = 2
local var_0_5 = 3
local var_0_6 = {
	15015,
	15016,
	15017
}
local var_0_7 = {
	typeIndex = IndexConst.SpWeaponTypeAll,
	rarityIndex = IndexConst.SpWeaponRarityAll
}

function SpWeaponUpgradeLayer:getUIName()
	return "SpWeaponUpgradeUI"
end

function SpWeaponUpgradeLayer:getResource()
	local var_2_0 = {
		"weaponframes",
		"shiptype",
		"ui/iconcolorful",
		"ui/CustomIndexUI",
		"ui/SkillInfoUI",
		"ui/MsgBox"
	}

	table.insertto(var_2_0, SpWeaponUpgradeLayer.super.getResource(self))

	return var_2_0
end

function SpWeaponUpgradeLayer:init()
	self:InitUI()

	self.consumeItems, self.consumeSpweapons = {}, {}
	self.loader = AutoLoader.New()
end

function SpWeaponUpgradeLayer:InitUI()
	self.rightPanel = self._tf:Find("Right")
	self.leftPanel = self._tf:Find("Left")
	self.equipmentPanel = self.rightPanel:Find("EquipmentPanel")
	self.equipmentPanelTitleStrengthen = self.equipmentPanel:Find("Title/Strengthen")
	self.equipmentPanelTitleUpgrade = self.equipmentPanel:Find("Title/Upgrade")
	self.equipmentPanelTitleComposite = self.equipmentPanel:Find("Title/Composite")
	self.equipmentPanelIcon1 = self.equipmentPanel:Find("Container/Equiptpl")
	self.equipmentPanelIcon2 = self.equipmentPanel:Find("Container/Equiptpl2")
	self.equipmentPanelArrow = self.equipmentPanel:Find("Container/Slot")
	self.craftTargetCount = self.equipmentPanel:Find("TotalCount")
	self.materialPanel = self.rightPanel:Find("MaterialPanel")
	self.materialPanelAttrList = self.materialPanel:Find("ScrollView/List")
	self.materialPanelExpLv = self.materialPanel:Find("ExpLv")
	self.materialPanelExpLvText = self.materialPanel:Find("ExpLv/Number")

	setActive(self.materialPanelExpLvText, false)

	self.materialPanelExpFullText = self.materialPanel:Find("ExpFull")
	self.materialPanelExpBar = self.materialPanel:Find("ExpBar")
	self.materialPanelExpBarFill = self.materialPanel:Find("ExpBar/Fill")
	self.materialPanelExpBarFull = self.materialPanel:Find("ExpBar/Full")

	setText(self.materialPanel:Find("ExpFull"), i18n("spweapon_ui_levelmax"))

	self.materialPanelExpTotalText = self.materialPanel:Find("ExpTotal")
	self.materialPanelExpCurrentText = self.materialPanel:Find("ExpTotal/ExpCurrent")
	self.materialPanelMaterialList = self.materialPanel:Find("Materials/List")
	self.materialPanelMaterialListLimit = self.materialPanel:Find("Materials/Limit")
	self.materialPanelMaterialItems = CustomIndexLayer.Clone2Full(self.materialPanelMaterialList, 3)

	setText(self.materialPanel:Find("Materials/Title"), i18n("spweapon_ui_need_resource"))
	setText(self.materialPanel:Find("Materials/Limit/text"), i18n("spweapon_ui_levelmax2"))

	self.materialPanelCostText = self.materialPanel:Find("Cost/Consume")
	self.materialPanelButton = self.materialPanel:Find("Button")
	self.materialPanelButtonUpgrade = self.materialPanel:Find("Button/Upgrade")
	self.materialPanelButtonStrengthen = self.materialPanel:Find("Button/Strengthen")
	self.materialPanelButtonCreate = self.materialPanel:Find("Button/Create")

	setText(self.materialPanelButtonUpgrade, i18n("msgbox_text_breakthrough"))
	setText(self.materialPanelButtonStrengthen, i18n("msgbox_text_noPos_intensify"))
	setText(self.materialPanelButtonCreate, i18n("spweapon_ui_create_button"))

	self.leftPanelAutoSelectButton = self.leftPanel:Find("Title/AutoSelect")
	self.leftPanelClearSelectButton = self.leftPanel:Find("Title/ClearSelect")
	self.leftPanelItem = self.leftPanel:Find("Items")
	self.leftPanelItemRect = UIItemList.New(self.leftPanel:Find("Items/Content"), (self.leftPanel:Find("Items/EquipItem")))

	setText(self.leftPanel:Find("Items/Top/TextName"), i18n("spweapon_ui_ptitem"))
	setText(self.leftPanelAutoSelectButton:Find("On/Text"), i18n("spweapon_ui_autoselect"))
	setText(self.leftPanelAutoSelectButton:Find("Off/Text"), i18n("spweapon_ui_autoselect"))
	setText(self.leftPanelClearSelectButton:Find("On/Text"), i18n("spweapon_ui_cancelselect"))
	setText(self.leftPanelClearSelectButton:Find("Off/Text"), i18n("spweapon_ui_cancelselect"))

	self.LeftPanelEquip = self.leftPanel:Find("Equips")
	self.leftPanelEquipScrollComp = GetComponent(self.leftPanel:Find("Equips/Scroll View"), "LScrollRect")

	setText(self.leftPanel:Find("Equips/Top/TextName"), i18n("spweapon_ui_spweapon"))

	self.leftPanelFilterButton = self.leftPanel:Find("Equips/Top/Filter")

	setText(self.leftPanel:Find("TipText"), i18n("spweapon_ui_helptext"))
	setText(self.equipmentPanel:Find("Ship/Detail"), i18n("spweapon_tip_view"))
	setText(self.equipmentPanel:Find("Ship/Title"), i18n("spweapon_tip_ship"))
	setText(self.equipmentPanel:Find("ShipType/Title"), i18n("spweapon_tip_type"))
	setText(self.craftTargetCount:Find("Tip"), i18n("spweapon_tip_owned", ""))
	Canvas.ForceUpdateCanvases()
end

function SpWeaponUpgradeLayer:setItems(arg_5_1)
	self.itemVOs = arg_5_1
end

function SpWeaponUpgradeLayer:updateRes(arg_6_1)
	self.playerVO = arg_6_1
end

function SpWeaponUpgradeLayer:SetSpWeapon(arg_7_1)
	self.spWeaponVO = arg_7_1
end

function SpWeaponUpgradeLayer:SetSpWeaponList(arg_8_1)
	self.spWeaponList = arg_8_1
end

function SpWeaponUpgradeLayer:didEnter()
	onButton(self, self._tf:Find("BG"), function()
		self:emit(SpWeaponUpgradeLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self.leftPanelFilterButton, function()
		self:emit(SpWeaponUpgradeMediator.OPEN_EQUIPMENT_INDEX, {
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

				self:UpdateAll()
			end
		})
	end, SFX_PANEL)
	onButton(self, self.leftPanelAutoSelectButton, function()
		self:AutoSelectMaterials()
	end)
	onButton(self, self.leftPanelClearSelectButton, function()
		table.clear(self.consumeItems)
		self:UpdateAll(true)
	end, SFX_CANCEL)

	function self.leftPanelEquipScrollComp:onInitItem()
		ClearTweenItemAlphaAndWhite(self.gameObject)
	end

	function self.leftPanelEquipScrollComp.onUpdateItem(arg_16_0, arg_16_1)
		self:UpdateEquipItemByIndex(arg_16_0, arg_16_1)
	end

	function self.leftPanelEquipScrollComp.onReturnItem(arg_17_0, arg_17_1)
		ClearTweenItemAlphaAndWhite(go(arg_17_1))
	end

	self.leftPanelItemRect:make(function(arg_18_0, arg_18_1, arg_18_2)
		arg_18_1 = arg_18_1 + 1

		if arg_18_0 == UIItemList.EventInit then
			pressPersistTrigger(arg_18_2:Find("IconTpl"), 0.5, function(arg_19_0)
				local var_19_0 = self.candicateMaterials[arg_18_1].id
				local var_19_1 = self:GetSelectMaterial(self.candicateMaterials[arg_18_1].id)

				if var_19_1 then
					if self.itemVOs[var_19_0] then
						local var_19_3 = self.itemVOs[var_19_0].count or 0

						if self.ptMax then
							pg.TipsMgr.GetInstance():ShowTips(i18n("spweapon_tip_upgrade"))
							arg_19_0()
						elseif (var_19_1.count or 0) == var_19_3 then
							arg_19_0()
						end

						if not var_19_1 then
							var_19_1 = Item.New({
								count = 0,
								id = var_19_0
							})

							table.insert(self.consumeItems, var_19_1)
						end
					end
				end

				var_19_1.count = var_19_1.count + 1

				self:UpdateAll(true)
			end, nil, true, true, 0.15, SFX_PANEL)
			pressPersistTrigger(arg_18_2:Find("IconTpl/Reduce"), 0.5, function(arg_20_0)
				local var_20_0 = self:GetSelectMaterial(self.candicateMaterials[arg_18_1].id)

				if var_20_0 then
					if (var_20_0.count or 0) == 0 then
						arg_20_0()

						return
					end
				end

				var_20_0.count = var_20_0.count - 1

				if var_20_0.count <= 0 then
					table.removebyvalue(self.consumeItems, var_20_0)
				end

				self:UpdateAll(true)
			end, nil, true, true, 0.15, SFX_PANEL)
		elseif arg_18_0 == UIItemList.EventUpdate then
			local var_18_0 = self.candicateMaterials[arg_18_1]

			updateDrop(arg_18_2:Find("IconTpl"), Drop.New({
				type = DROP_TYPE_ITEM,
				id = self.candicateMaterials[arg_18_1].id,
				count = self.candicateMaterials[arg_18_1].count
			}))
			setScrollText(arg_18_2:Find("Mask/NameText"), var_18_0:getConfig("name"))
			setText(arg_18_2:Find("IconTpl/icon_bg/count"), var_18_0.count)
			setActive(arg_18_2:Find("IconTpl/mask"), var_18_0.count == 0)

			local var_18_1 = self:GetSelectMaterial(var_18_0.id)

			setActive(arg_18_2:Find("IconTpl/Reduce"), var_18_1 and var_18_1.count > 0)

			if var_18_1 then
				setText(arg_18_2:Find("IconTpl/Reduce/Text"), var_18_1.count)
			end
		end
	end)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.contextData.indexDatas = self.contextData.indexDatas or Clone(var_0_7)

	self:UpdateAll()
end

function SpWeaponUpgradeLayer:UpdateEquipItemByIndex(arg_21_1, arg_21_2)
	arg_21_1 = arg_21_1 + 1

	TweenItemAlphaAndWhite(arg_21_2)
	self:UpdateEquipItem(self.candicateSpweapons[arg_21_1], arg_21_2)
end

function SpWeaponUpgradeLayer:UpdateEquipItem(arg_22_1, arg_22_2)
	local var_22_0 = tf(arg_22_2)

	onButton(self, var_22_0, function()
		if self:GetSelectSpWeapon(arg_22_1) then
			return
		end

		if self.ptMax then
			pg.TipsMgr.GetInstance():ShowTips(i18n("spweapon_tip_upgrade"))

			return
		end

		seriesAsync({
			function(arg_24_0)
				if not arg_22_1:IsImportant() then
					return arg_24_0()
				end

				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					modal = true,
					type = MSGBOX_TYPE_CONFIRM_DELETE,
					title = pg.MsgboxMgr.TITLE_INFORMATION,
					onYes = arg_24_0,
					data = {
						name = arg_22_1:GetName()
					}
				})
			end,
			function()
				table.insert(self.consumeSpweapons, arg_22_1)
				self:UpdateAll(true)
				self:UpdateEquipItem(arg_22_1, arg_22_2)
			end
		})
	end)
	onButton(self, var_22_0:Find("IconTpl/Reduce"), function()
		local var_26_0 = self:GetSelectSpWeapon(arg_22_1)

		if not var_26_0 then
			return
		end

		table.removebyvalue(self.consumeSpweapons, var_26_0)
		self:UpdateEquipItem(arg_22_1, arg_22_2)
		self:UpdateAll(true)
	end)
	updateSpWeapon(var_22_0:Find("IconTpl"), arg_22_1)
	setScrollText(var_22_0:Find("Mask/NameText"), arg_22_1:GetName())

	local var_22_1 = arg_22_1:GetShipId()

	setActive(var_22_0:Find("EquipShip"), var_22_1)

	if var_22_1 and var_22_1 > 0 then
		setImageSprite(var_22_0:Find("EquipShip/Image"), LoadSprite("qicon/" .. getProxy(BayProxy):getShipById(var_22_1):getPainting()))
	end

	local var_22_2 = self:GetSelectSpWeapon(arg_22_1)

	setActive(var_22_0:Find("IconTpl/Reduce"), var_22_2)

	if var_22_2 then
		setText(var_22_0:Find("IconTpl/Reduce/Text"), 1)
	end
end

function SpWeaponUpgradeLayer:UpdateSelectPt()
	self.nextSpWeaponVO = nil
	self.upgradeType = nil
	self.upgradeMaxLevel = false
	self.ptMax = false

	local var_27_0 = self.spWeaponVO:GetPt() + SpWeapon.CalculateHistoryPt(self.consumeItems, self.consumeSpweapons)
	local var_27_1 = self.spWeaponVO:GetConfigID()
	local var_27_2 = 0
	local var_27_3 = 0
	local var_27_4 = 0
	local var_27_5 = 0
	local var_27_6 = {}

	local function var_27_7(arg_28_0)
		for iter_28_0, iter_28_1 in ipairs(arg_28_0) do
			local var_28_0 = iter_28_1[1]
			local var_28_1 = underscore.detect(var_27_6, function(arg_29_0)
				return arg_29_0.id == var_28_0
			end)

			if not var_28_1 then
				var_28_1 = Item.New({
					id = iter_28_1[1]
				})
				var_28_1.count = 0

				table.insert(var_27_6, var_28_1)
			end

			var_28_1.count = var_28_1.count + iter_28_1[2]
		end
	end

	if self.craftMode == var_0_1 then
		local var_27_8 = SpWeapon.New({
			id = var_27_1
		}):GetUpgradeConfig()

		var_27_3 = var_27_3 + var_27_8.create_use_pt

		var_27_7(var_27_8.create_use_item)

		var_27_5 = var_27_5 + var_27_8.create_use_gold
		self.upgradeType = var_0_3
	end

	if var_27_3 <= var_27_0 then
		self.upgradeType = var_0_4

		repeat
			local var_27_9 = SpWeapon.New({
				id = var_27_1
			})
			local var_27_10 = var_27_9:GetNextUpgradeID()

			if var_27_10 == 0 then
				break
			end

			local var_27_11 = var_27_9:GetUpgradeConfig()

			var_27_2 = var_27_3
			var_27_3 = var_27_3 + var_27_11.upgrade_use_pt

			local var_27_12 = SpWeapon.New({
				id = var_27_10
			})

			if var_27_4 > 0 and var_27_12:GetRarity() > var_27_9:GetRarity() then
				break
			end

			if var_27_12:GetRarity() > var_27_9:GetRarity() then
				self.upgradeType = var_0_5
			end

			if var_27_0 < var_27_3 then
				break
			end

			var_27_7(var_27_11.upgrade_use_item)

			var_27_5 = var_27_5 + var_27_11.upgrade_use_gold
			var_27_4 = var_27_4 + 1
			var_27_1 = var_27_10
		until var_27_12:GetRarity() > var_27_9:GetRarity()
	end

	self.ptMax = var_27_3 <= var_27_0
	self.upgradeLevel = var_27_4
	self.upgradePtOrigin = var_27_2
	self.upgradePtTotal = math.min(var_27_0, var_27_3)
	self.upgradePtMax = var_27_3
	self.upgradNeedMaterials = var_27_6
	self.upgradNeedGold = var_27_5
	self.nextSpWeaponVO = self.spWeaponVO:MigrateTo(var_27_1)

	if self.craftMode == var_0_2 then
		self.upgradeMaxLevel = self.spWeaponVO:GetNextUpgradeID() == 0
	end
end

function SpWeaponUpgradeLayer:AutoSelectMaterials()
	local var_30_0 = self.spWeaponVO:GetPt() + SpWeapon.CalculateHistoryPt(self.consumeItems, self.consumeSpweapons)
	local var_30_1 = self.spWeaponVO:GetConfigID()
	local var_30_2 = 0

	if self.craftMode == var_0_1 then
		var_30_2 = SpWeapon.New({
			id = var_30_1
		}):GetUpgradeConfig().create_use_pt
	end

	while true do
		local var_30_3 = SpWeapon.New({
			id = var_30_1
		})
		local var_30_4 = var_30_3:GetNextUpgradeID()

		if var_30_4 == 0 then
			break
		end

		var_30_2 = var_30_2 + var_30_3:GetUpgradeConfig().upgrade_use_pt

		if SpWeapon.New({
			id = var_30_4
		}):GetRarity() > self.spWeaponVO:GetRarity() then
			break
		end

		var_30_1 = var_30_4
	end

	if var_30_2 <= var_30_0 then
		return
	end

	local var_30_5 = _.values(_.map(self.candicateMaterials, function(arg_31_0)
		local var_31_0 = self:GetSelectMaterial(arg_31_0.id)
		local var_31_1 = arg_31_0.count - ((var_31_0 or nil) and (var_31_0.count or 0))

		return var_31_1 > 0 and Item.New({
			id = arg_31_0.id,
			count = var_31_1
		}) or nil
	end))

	local function var_30_6(arg_32_0)
		return Item.getConfigData(arg_32_0.id).usage_arg[1]
	end

	table.sort(var_30_5, function(arg_33_0, arg_33_1)
		return var_30_6(arg_33_0) > var_30_6(arg_33_1)
	end)

	local function var_30_8(arg_34_0, arg_34_1, arg_34_2)
		if not var_30_5[arg_34_0] then
			return false
		end

		local var_34_0 = var_30_6(var_30_5[arg_34_0])
		local var_34_1 = math.min(math.ceil(arg_34_1 / var_34_0), var_30_5[arg_34_0].count)

		arg_34_2 = Clone(arg_34_2)

		if arg_34_1 - var_34_0 * var_34_1 == 0 then
			table.insert(arg_34_2, {
				id = var_30_5[arg_34_0].id,
				count = var_34_1
			})

			return true, arg_34_2
		elseif arg_34_1 - var_34_0 * var_34_1 > 0 then
			local var_34_2, var_34_3 = var_30_8(arg_34_0 + 1, arg_34_1 - var_34_0 * var_34_1, {})

			if var_34_2 then
				table.insert(arg_34_2, {
					id = var_30_5[arg_34_0].id,
					count = var_34_1
				})
				table.insertto(arg_34_2, var_34_3)

				return true, arg_34_2
			else
				return false
			end
		elseif arg_34_1 - var_34_0 * var_34_1 < 0 then
			local var_34_4, var_34_5 = var_30_8(arg_34_0 + 1, arg_34_1 - var_34_0 * var_34_1 + var_34_0, {})

			if var_34_4 then
				table.insert(arg_34_2, {
					id = var_30_5[arg_34_0].id,
					count = math.max(var_34_1 - 1, 0)
				})
				table.insertto(arg_34_2, var_34_5)

				return true, arg_34_2
			else
				table.insert(arg_34_2, {
					id = var_30_5[arg_34_0].id,
					count = math.max(var_34_1, 0)
				})

				return true, arg_34_2
			end
		end
	end

	local var_30_9, var_30_10 = (nil)(1, var_30_2 - var_30_0, {})

	var_30_10 = var_30_9 and var_30_10 or var_30_5

	_.each(var_30_10, function(arg_35_0)
		self:UpdateSelectMaterial(arg_35_0.id, arg_35_0.count)
		self:UpdateAll(true)
	end)
end

function SpWeaponUpgradeLayer:UpdateAll(arg_36_1)
	if not self.spWeaponVO:IsReal() then
		self.craftMode = var_0_1 or var_0_2
	end

	self:UpdateSelectPt()

	local var_36_0 = self.craftMode == var_0_2 and self.nextSpWeaponVO:GetConfigID() ~= self.spWeaponVO:GetConfigID()

	setActive(self.equipmentPanelIcon2, var_36_0)
	setActive(self.equipmentPanelArrow, var_36_0)

	if var_36_0 then
		updateSpWeapon(self.equipmentPanelIcon1, self.spWeaponVO)
		updateSpWeapon(self.equipmentPanelIcon2, self.nextSpWeaponVO)
		self:UpdateAttrs(self.materialPanelAttrList, self.spWeaponVO, self.nextSpWeaponVO)
	else
		updateSpWeapon(self.equipmentPanelIcon1, self.nextSpWeaponVO)
		self:UpdateAttrs(self.materialPanelAttrList, self.nextSpWeaponVO)
	end

	setText(self.equipmentPanel:Find("Name"), self.nextSpWeaponVO:GetName())

	local var_36_1 = self.nextSpWeaponVO:IsUnique()

	setActive(self.equipmentPanel:Find("ShipType"), not var_36_1)
	setActive(self.equipmentPanel:Find("Ship"), var_36_1)

	if var_36_1 then
		local var_36_2 = ShipGroup.getDefaultShipConfig(self.nextSpWeaponVO:GetUniqueGroup())
		local var_36_3

		if var_36_2 then
			var_36_3 = var_36_2.id or nil
		end

		assert(var_36_3 and var_36_3 > 0)

		if var_36_3 and var_36_3 > 0 then
			self.loader:GetSprite("qicon/" .. Ship.New({
				configId = var_36_3
			}):getPainting(), nil, self.equipmentPanel:Find("Ship/Icon/Image"))

			local function var_36_4()
				self:emit(BaseUI.ON_DROP, {
					type = DROP_TYPE_SHIP,
					id = var_36_3
				})
			end

			self.equipmentPanel:Find("Ship/Detail"):GetComponent("RichText"):AddListener(var_36_4)
			onButton(self, self.equipmentPanel:Find("Ship/Icon"), var_36_4)
		end
	else
		local var_36_5 = ShipType.FilterOverQuZhuType((_.filter(self.nextSpWeaponVO:GetWearableShipTypes(), function(arg_38_0)
			return table.contains(ShipType.AllShipType, arg_38_0)
		end)))

		CustomIndexLayer.Clone2Full(self.equipmentPanel:Find("ShipType/List"), #var_36_5)

		for iter_36_0, iter_36_1 in ipairs(var_36_5) do
			self.loader:GetSprite("shiptype", ShipType.Type2CNLabel(iter_36_1), (self.equipmentPanel:Find("ShipType/List"):GetChild(iter_36_0 - 1)))
		end
	end

	self:UpdateExpBar()
	self:UpdateMaterials()
	self:UpdatePtMaterials(arg_36_1)
	self:UpdateCraftTargetCount()
end

function SpWeaponUpgradeLayer:UpdateCraftTargetCount()
	setActive(self.craftTargetCount, self.craftMode == var_0_1)

	if not self.craftMode == var_0_1 then
		return
	end

	setText(self.craftTargetCount:Find("Text"), (_.reduce(self.spWeaponList, 0, function(arg_40_0, arg_40_1)
		if self.nextSpWeaponVO:GetOriginID() == arg_40_1:GetOriginID() then
			arg_40_0 = arg_40_0 + 1
		end

		return arg_40_0
	end)))
end

function SpWeaponUpgradeLayer:UpdateAttrs(arg_41_1, arg_41_2, arg_41_3)
	local var_41_0
	local var_41_1

	if self.craftMode == var_0_1 then
		var_41_0 = SpWeaponHelper.TransformCompositeInfo(arg_41_2)
		var_41_1 = arg_41_2:GetSkillGroup()
		arg_41_3 = arg_41_2
	elseif self.craftMode == var_0_2 then
		arg_41_3 = arg_41_3 or arg_41_2
		var_41_0 = SpWeaponHelper.TransformUpgradeInfo(arg_41_2, arg_41_3)
		var_41_1 = arg_41_3:GetSkillGroup()
	end

	self:UpdateSpWeaponUpgradeInfo(arg_41_1, var_41_0, var_41_1, arg_41_3)
end

function SpWeaponUpgradeLayer:UpdateSpWeaponUpgradeInfo(arg_42_1, arg_42_2, arg_42_3, arg_42_4)
	local var_42_0 = arg_42_1:Find("attr_tpl")

	removeAllChildren(arg_42_1:Find("attrs"))

	local function var_42_1(arg_43_0, arg_43_1)
		local var_43_0 = arg_43_0:Find("base")

		setText(var_43_0:Find("name"), arg_43_1.name)
		setActive(var_43_0:Find("value"), true)
		setText(var_43_0:Find("value"), arg_43_1.value)
		setActive(var_43_0:Find("effect"), false)
		setActive(var_43_0:Find("value/up"), arg_43_1.compare and arg_43_1.compare > 0)
		setActive(var_43_0:Find("value/down"), arg_43_1.compare and arg_43_1.compare < 0)
		triggerToggle(var_43_0, arg_43_1.lock_open)

		if not arg_43_1.lock_open and arg_43_1.sub and #arg_43_1.sub > 0 then
			GetComponent(var_43_0, typeof(Toggle)).enabled = true
		else
			setActive(var_43_0:Find("name/close"), false)
			setActive(var_43_0:Find("name/open"), false)

			GetComponent(var_43_0, typeof(Toggle)).enabled = false
		end
	end

	;(function(arg_44_0, arg_44_1, arg_44_2)
		for iter_44_0, iter_44_1 in ipairs(arg_44_2) do
			var_42_1(cloneTplTo(arg_44_1, arg_44_0), iter_44_1)
		end
	end)(arg_42_1:Find("attrs"), var_42_0, arg_42_2)

	local var_42_2 = {}

	if arg_42_3[1].skillId > 0 then
		table.insert(var_42_2, {
			name = i18n("spweapon_attr_effect"),
			effect = arg_42_3[1]
		})
	end

	for iter_42_0, iter_42_1 in ipairs(arg_42_3[2]) do
		table.insert(var_42_2, {
			isSkill = true,
			name = i18n("spweapon_attr_skillupgrade"),
			effect = iter_42_1
		})
	end

	local function var_42_3(arg_45_0, arg_45_1)
		local var_45_0 = arg_45_0:Find("base")
		local var_45_1 = arg_45_1.effect

		setText(var_45_0:Find("name"), arg_45_1.name)
		setActive(var_45_0:Find("value"), false)
		setActive(var_45_0:Find("effect"), true)

		local var_45_2 = getSkillName(arg_45_1.effect.skillId)

		if not arg_45_1.effect.unlock then
			var_45_2 = setColorStr(var_45_2, "#a2a2a2")

			setTextColor(var_45_0:Find("effect"), SummerFeastScene.TransformColor("a2a2a2"))
		else
			setTextColor(var_45_0:Find("effect"), SummerFeastScene.TransformColor("FFDE00"))
		end

		local var_45_3 = "<material=underline event=displaySkill>" .. var_45_2 .. "</material>"

		var_45_0:Find("effect"):GetComponent("RichText"):AddListener(function(arg_46_0, arg_46_1)
			if arg_46_0 == "displaySkill" then
				local var_46_0 = getSkillDesc(var_45_1.skillId, var_45_1.lv)

				if not var_45_1.unlock then
					var_46_0 = setColorStr(i18n("spweapon_tip_skill_locked") .. var_46_0, "#a2a2a2")
				end

				if not arg_45_1.isSkill then
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						type = MSGBOX_TYPE_SINGLE_ITEM,
						drop = {
							type = DROP_TYPE_SPWEAPON,
							id = arg_42_4:GetConfigID()
						},
						name = var_45_2,
						content = var_46_0
					})
				else
					self:emit(SpWeaponUpgradeMediator.ON_SKILLINFO, var_45_1.skillId, var_45_1.unlock, 10)
				end
			end
		end)
		setText(var_45_0:Find("effect"), var_45_3)
		setActive(var_45_0:Find("value/up"), false)
		setActive(var_45_0:Find("value/down"), false)
		triggerToggle(var_45_0, false)
		setActive(var_45_0:Find("name/close"), false)
		setActive(var_45_0:Find("name/open"), false)

		GetComponent(var_45_0, typeof(Toggle)).enabled = false
	end

	;(function(arg_47_0, arg_47_1, arg_47_2)
		for iter_47_0, iter_47_1 in ipairs(arg_47_2) do
			var_42_3(cloneTplTo(arg_47_1, arg_47_0), iter_47_1)
		end
	end)(arg_42_1:Find("attrs"), var_42_0, var_42_2)
end

function SpWeaponUpgradeLayer:UpdateExpBar()
	setActive(self.materialPanelExpLv, not self.upgradeMaxLevel)
	setActive(self.materialPanelExpFullText, self.upgradeMaxLevel)
	setActive(self.materialPanelExpBarFull, self.upgradeMaxLevel)

	if not self.upgradeMaxLevel then
		setSlider(self.materialPanelExpBar, 0, 1, (self.upgradePtTotal - self.upgradePtOrigin) / (self.upgradePtMax - self.upgradePtOrigin))

		if self.upgradeType == var_0_3 then
			setText(self.materialPanelExpLv, i18n("spweapon_ui_create_exp"))
		elseif self.upgradeType == var_0_4 then
			setText(self.materialPanelExpLv, i18n("spweapon_ui_upgrade_exp"))
		elseif self.upgradeType == var_0_5 then
			setText(self.materialPanelExpLv, i18n("spweapon_ui_breakout_exp"))
		end

		setText(self.materialPanelExpCurrentText, self.upgradePtTotal - self.upgradePtOrigin)
		setText(self.materialPanelExpTotalText, self.upgradePtMax - self.upgradePtOrigin)
	else
		setText(self.materialPanelExpCurrentText, 0)
		setText(self.materialPanelExpTotalText, 0)
	end
end

function SpWeaponUpgradeLayer:UpdateMaterials()
	local var_49_0 = self.upgradNeedGold
	local var_49_1 = self.spWeaponVO:GetNextUpgradeID() == 0

	setActive(self.materialPanelMaterialList, not var_49_1)
	setActive(self.materialPanelMaterialListLimit, var_49_1)

	local var_49_2
	local var_49_3 = true

	for iter_49_0 = 1, #self.materialPanelMaterialItems do
		setActive(findTF(self.materialPanelMaterialItems[iter_49_0], "off"), not self.upgradNeedMaterials[iter_49_0])
		setActive(findTF(self.materialPanelMaterialItems[iter_49_0], "Icon"), self.upgradNeedMaterials[iter_49_0])

		if self.upgradNeedMaterials[iter_49_0] then
			local var_49_4 = findTF(self.materialPanelMaterialItems[iter_49_0], "Icon")
			local var_49_5 = {
				type = DROP_TYPE_ITEM,
				id = self.upgradNeedMaterials[iter_49_0].id,
				count = self.upgradNeedMaterials[iter_49_0].count
			}

			updateDrop(var_49_4, var_49_5)
			onButton(self, var_49_4, function()
				self:emit(BaseUI.ON_DROP, var_49_5)
			end)

			local var_49_6 = defaultValue(self.itemVOs[self.upgradNeedMaterials[iter_49_0].id], {
				count = 0
			})
			local var_49_7 = self.upgradNeedMaterials[iter_49_0].count .. "/" .. var_49_6.count

			if var_49_6.count < self.upgradNeedMaterials[iter_49_0].count then
				var_49_7 = setColorStr(var_49_6.count, COLOR_RED) .. "/" .. self.upgradNeedMaterials[iter_49_0].count
				var_49_3 = false
				var_49_2 = self.upgradNeedMaterials[iter_49_0].id
			end

			local var_49_8 = findTF(var_49_4, "icon_bg/count")

			setActive(var_49_8, true)
			setText(var_49_8, var_49_7)

			local var_49_9 = var_49_4:Find("Click")

			setActive(var_49_9, not self.confirmUpgrade and self.upgradeType == var_0_5)
			onButton(self, var_49_9, function()
				self.confirmUpgrade = true

				setActive(var_49_9, not self.confirmUpgrade)
			end)
		end
	end

	setText(self.materialPanelCostText, var_49_0)
	setActive(self.materialPanelButtonCreate, self.craftMode == var_0_1)
	setActive(self.materialPanelButtonUpgrade, self.craftMode == var_0_2 and self.upgradeType == var_0_5)
	setActive(self.materialPanelButtonStrengthen, self.craftMode == var_0_2 and self.upgradeType == var_0_4)
	setActive(self.equipmentPanelTitleComposite, self.craftMode == var_0_1)
	setActive(self.equipmentPanelTitleUpgrade, self.craftMode == var_0_2 and self.upgradeType == var_0_5)
	setActive(self.equipmentPanelTitleStrengthen, self.craftMode == var_0_2 and self.upgradeType == var_0_4)
	onButton(self, self.materialPanelButton, function()
		if not var_49_3 then
			if not ItemTipPanel.ShowItemTipbyID(var_49_2) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("spweapon_tip_materal_no_enough"))
			end

			return
		end

		if self.playerVO.gold < var_49_0 then
			GoShoppingMsgBox(i18n("switch_to_shop_tip_2", i18n("word_gold")), ChargeScene.TYPE_ITEM, {
				{
					59001,
					var_49_0 - self.playerVO.gold,
					var_49_0
				}
			})

			return
		end

		if not self.confirmUpgrade and self.upgradeType == var_0_5 and #self.upgradNeedMaterials > 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("spweapon_tip_breakout_materal_check"))

			return
		end

		if self.craftMode == var_0_1 then
			self:emit(SpWeaponUpgradeMediator.EQUIPMENT_COMPOSITE, self.spWeaponVO:GetConfigID(), self.consumeItems, self.consumeSpweapons)
		elseif self.craftMode == var_0_2 then
			self:emit(SpWeaponUpgradeMediator.EQUIPMENT_UPGRADE, self.spWeaponVO:GetUID(), self.consumeItems, self.consumeSpweapons)
		end
	end, SFX_UI_DOCKYARD_REINFORCE)
	setGray(self.materialPanelButton, self.upgradeMaxLevel)
	setButtonEnabled(self.materialPanelButton, not self.upgradeMaxLevel)
end

function SpWeaponUpgradeLayer:UpdatePtMaterials(arg_53_1)
	self.candicateMaterials = _.map(var_0_6, function(arg_54_0)
		return self.itemVOs[arg_54_0] or Item.New({
			count = 0,
			id = arg_54_0
		})
	end)

	table.sort(self.candicateMaterials, function(arg_55_0, arg_55_1)
		return arg_55_0.id < arg_55_1.id
	end)

	local var_53_0 = table.equal(self.contextData.indexDatas, var_0_7)

	setActive(self.leftPanelFilterButton:Find("Off"), var_53_0)
	setActive(self.leftPanelFilterButton:Find("On"), not var_53_0)

	self.candicateSpweapons = {}

	for iter_53_0, iter_53_1 in pairs(self.spWeaponList) do
		if iter_53_1:GetUID() ~= self.spWeaponVO:GetUID() and not iter_53_1:IsUnCraftable() and not iter_53_1:GetShipId() and IndexConst.filterSpWeaponByType(iter_53_1, self.contextData.indexDatas.typeIndex) and IndexConst.filterSpWeaponByRarity(iter_53_1, self.contextData.indexDatas.rarityIndex) then
			table.insert(self.candicateSpweapons, iter_53_1)
		end
	end

	table.sort(self.candicateSpweapons, CompareFuncs(SpWeaponSortCfg.sortFunc(SpWeaponSortCfg.sort[1], true)))
	self.leftPanelItemRect:align(#self.candicateMaterials)

	if not arg_53_1 then
		self.leftPanelEquipScrollComp:SetTotalCount(#self.candicateSpweapons)
	end

	setActive(self.leftPanelAutoSelectButton:Find("On"), not self.ptMax)
	setActive(self.leftPanelAutoSelectButton:Find("Off"), self.ptMax)
	setButtonEnabled(self.leftPanelAutoSelectButton, not self.ptMax)

	local var_53_1 = #self.consumeItems > 0

	setActive(self.leftPanelClearSelectButton:Find("On"), #self.consumeItems > 0)
	setActive(self.leftPanelClearSelectButton:Find("Off"), not var_53_1)
	setButtonEnabled(self.leftPanelClearSelectButton, var_53_1)
end

function SpWeaponUpgradeLayer:UpdateSelectMaterial(arg_56_1, arg_56_2)
	local var_56_0 = self:GetSelectMaterial(arg_56_1)

	if var_56_0 then
		local var_56_1 = var_56_0.count or 0

		if self.itemVOs[arg_56_1] then
			local var_56_2 = self.itemVOs[arg_56_1].count or 0

			if arg_56_2 > 0 then
				if self.ptMax then
					pg.TipsMgr.GetInstance():ShowTips(i18n("spweapon_tip_upgrade"))

					return true
				end

				arg_56_2 = math.min(arg_56_2, (math.max(var_56_2 - var_56_1, 0)))

				if arg_56_2 > 0 then
					if not var_56_0 then
						var_56_0 = Item.New({
							count = 0,
							id = arg_56_1
						})

						table.insert(self.consumeItems, var_56_0)
					end

					var_56_0.count = var_56_0.count + arg_56_2
				end

				if var_56_2 <= var_56_1 + arg_56_2 then
					return true
				end
			elseif arg_56_2 < 0 then
				arg_56_2 = math.max(arg_56_2, -var_56_1)

				if arg_56_2 < 0 and var_56_0 then
					var_56_0.count = var_56_0.count + arg_56_2

					if var_56_0.count <= 0 then
						table.removebyvalue(self.consumeItems, var_56_0)
					end
				end

				if var_56_1 + arg_56_2 <= 0 then
					return true
				end
			end
		end
	end
end

function SpWeaponUpgradeLayer:GetSelectMaterial(arg_57_1)
	return _.detect(self.consumeItems, function(arg_58_0)
		return arg_58_0.id == arg_57_1
	end)
end

function SpWeaponUpgradeLayer:GetSelectSpWeapon(arg_59_1)
	if table.contains(self.consumeSpweapons, arg_59_1) then
		return arg_59_1
	end
end

function SpWeaponUpgradeLayer:ClearSelectMaterials()
	table.clear(self.consumeItems)
	table.clear(self.consumeSpweapons)
end

function SpWeaponUpgradeLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	ClearLScrollrect(self.leftPanelEquipScrollComp)
	self.loader:Clear()
end

return SpWeaponUpgradeLayer
