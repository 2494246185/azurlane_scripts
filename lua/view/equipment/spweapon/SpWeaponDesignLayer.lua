local SpWeaponDesignLayer = class("SpWeaponDesignLayer", import("view.base.BaseUI"))

function SpWeaponDesignLayer:getUIName()
	return "SpWeaponDesignUI"
end

function SpWeaponDesignLayer:getResource()
	local var_2_0 = {}

	_.each(pg.spweapon_data_statistics.all, function(arg_3_0)
		local var_3_0 = SpWeapon.New({
			id = arg_3_0
		})

		if var_3_0:IsCraftable() then
			table.insert(var_2_0, (var_3_0:GetIconPath()))
		end
	end)

	return ResPathSupport.MergeLuaArr(SpWeaponDesignLayer.super.getResource(self), {
		"ui/SpWeaponDesignUI",
		"bg/equipment_bg_1",
		"bg/equipment_bg_2",
		"bg/equipment_bg_3",
		"bg/equipment_bg_4",
		"bg/equipment_bg_5",
		"bg/equipment_bg_6",
		"ui/equipmentdesignui_atlas",
		"ui/share/index_atlas",
		"weaponframes"
	}, var_2_0)
end

function SpWeaponDesignLayer:SetCraftList(arg_4_1)
	self.craftList = arg_4_1
end

function SpWeaponDesignLayer:SetSpWeapons(arg_5_1)
	assert(self.craftList)

	if self.craftList then
		_.each(self.craftList, function(arg_6_0)
			arg_6_0.owned = not not (arg_6_0:IsUnique() and table.Find(arg_5_1, function(arg_7_0, arg_7_1)
				return arg_7_1:GetOriginID() == arg_6_0:GetConfigID()
			end))
		end)
	end
end

function SpWeaponDesignLayer:setItems(arg_8_1)
	self.itemVOs = arg_8_1
end

function SpWeaponDesignLayer:setPlayer(arg_9_1)
	self.player = arg_9_1
end

function SpWeaponDesignLayer:init()
	self.designScrollView = self._tf:Find("equipment_scrollview")
	self.equipmentTpl = self._tf:Find("Template")

	setActive(self.equipmentTpl, false)

	self.equipmentContainer = self.designScrollView:Find("equipment_grid")

	local var_10_0

	if NotchAdapt.CheckNotchRatio ~= 2 then
		if not getProxy(SettingsProxy):CheckLargeScreen() then
			var_10_0 = self.designScrollView.rect.width > 2000

			goto label_10_0
		end
	end

	::label_10_0::

	self.equipmentContainer:GetComponent(typeof(GridLayoutGroup)).constraintCount = NotchAdapt.CheckNotchRatio >= 2 and 8 or 7
	self.top = self._tf:Find("top")
	self.toggleOwned = self._tf:Find("toggle_owned")
	self.sortBtn = self.top:Find("sort_button")
	self.indexBtn = self.top:Find("index_button")
	self.decBtn = self.sortBtn:Find("dec_btn")
	self.sortImgAsc = self.decBtn:Find("desc")
	self.sortImgDec = self.decBtn:Find("asc")
	self.indexPanel = self._tf:Find("index")
	self.tagContainer = self.indexPanel:Find("adapt/mask/panel")
	self.tagTpl = self.tagContainer:Find("tpl")
	self.listEmptyTF = self._tf:Find("empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")

	setText(self.listEmptyTxt, i18n("list_empty_tip_equipmentdesignui"))
	self:OverlayPanel(self.indexPanel)
end

function SpWeaponDesignLayer:SetParentTF(arg_11_1)
	self.parentTF = arg_11_1
	self.equipmentView = self.parentTF:Find("adapt/equipment_scrollview")

	setActive(self.equipmentView, false)
end

function SpWeaponDesignLayer:SetTopContainer(arg_12_1)
	self.topPanel = arg_12_1
end

function SpWeaponDesignLayer:SetTopItems(arg_13_1)
	self.topItems = arg_13_1
end

local var_0_1 = {
	"sort_rarity"
}

function SpWeaponDesignLayer:didEnter()
	setParent(self._tf, self.parentTF)
	self._tf:SetSiblingIndex((self.equipmentView:GetSiblingIndex()))

	self.contextData.indexDatas = self.contextData.indexDatas or {}
	self.contextData.index = self.contextData.index or 1

	setParent(self.top, self.topPanel)
	setParent(self.toggleOwned, self.topItems:Find("adapt/bottom_back"))
	self:initDesigns()
	onToggle(self, self.sortBtn, function(arg_15_0)
		setActive(self.indexPanel, arg_15_0)
	end, SFX_PANEL)
	onButton(self, self.indexPanel, function()
		triggerToggle(self.sortBtn, false)
	end, SFX_PANEL)
	onButton(self, self.indexBtn, function()
		self:emit(SpWeaponDesignMediator.OPEN_EQUIPMENTDESIGN_INDEX, {
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
				if not isActive(self._tf) then
					return
				end

				self.contextData.indexDatas.typeIndex = self.typeIndex
				self.contextData.indexDatas.rarityIndex = self.rarityIndex

				self:filter()
			end
		})
	end, SFX_PANEL)

	self.contextData.showOwned = defaultValue(self.contextData.showOwned, false)

	triggerToggle(self.toggleOwned, self.contextData.showOwned)
	onToggle(self, self.toggleOwned, function(arg_19_0)
		self.contextData.showOwned = arg_19_0

		self:filter()
	end)
	self:initTags()
end

function SpWeaponDesignLayer:isDefaultStatus()
	return (not self.contextData.indexDatas.typeIndex or self.contextData.indexDatas.typeIndex == IndexConst.SpWeaponTypeAll) and (not self.contextData.indexDatas.rarityIndex or self.contextData.indexDatas.rarityIndex == IndexConst.SpWeaponRarityAll)
end

function SpWeaponDesignLayer:initTags()
	onButton(self, self.decBtn, function()
		self.contextData.asc = not self.contextData.asc

		self:filter()
	end)

	self.tagTFs = {}

	eachChild(self.tagContainer, function(arg_23_0)
		setActive(arg_23_0, false)
	end)

	for iter_21_0, iter_21_1 in ipairs(var_0_1) do
		local var_21_0 = iter_21_0 <= self.tagContainer.childCount and self.tagContainer:GetChild(iter_21_0 - 1) or cloneTplTo(self.tagTpl, self.tagContainer)

		setActive(var_21_0, true)
		setImageSprite(findTF(var_21_0, "Image"), GetSpriteFromAtlas("ui/equipmentdesignui_atlas", iter_21_1))
		onToggle(self, var_21_0, function(arg_24_0)
			if arg_24_0 then
				self.contextData.index = iter_21_0

				self:filter()
			end

			triggerButton(self.indexPanel)
		end, SFX_PANEL)
		table.insert(self.tagTFs, var_21_0)
	end

	triggerToggle(self.tagTFs[self.contextData.index], true)
end

function SpWeaponDesignLayer:initDesigns()
	self.scollRect = self.designScrollView:GetComponent("LScrollRect")
	self.scollRect.decelerationRate = 0.07

	function self.scollRect.onInitItem(arg_26_0)
		self:initDesign(arg_26_0)
	end

	function self.scollRect.onUpdateItem(arg_27_0, arg_27_1)
		self:updateDesign(arg_27_0, arg_27_1)
	end

	function self.scollRect.onReturnItem(arg_28_0, arg_28_1)
		self:returnDesign(arg_28_0, arg_28_1)
	end

	self.desgins = {}
end

function SpWeaponDesignLayer:initDesign(arg_29_1)
	local var_29_0 = SpWeaponItemView.New(arg_29_1)

	onButton(self, var_29_0.go, function()
		self:emit(SpWeaponDesignMediator.ON_COMPOSITE, var_29_0.spWeaponVO:GetConfigID())
	end)

	self.desgins[arg_29_1] = var_29_0
end

function SpWeaponDesignLayer:updateDesign(arg_31_1, arg_31_2)
	if not self.desgins[arg_31_2] then
		self:initDesign(arg_31_2)
	end

	self.desgins[arg_31_2]:update(self.filterCraftList[arg_31_1 + 1])
end

function SpWeaponDesignLayer:returnDesign(arg_32_1, arg_32_2)
	if self.exited then
		return
	end

	if self.desgins[arg_32_2] then
		self.desgins[arg_32_2]:clear()
	end
end

function SpWeaponDesignLayer:getDesignVO(arg_33_1)
	return arg_33_1
end

local SpWeaponSortCfg = require("view.equipment.SpWeaponSortCfg")

function SpWeaponDesignLayer:filter()
	GetSpriteFromAtlasAsync("ui/share/index_atlas", self:isDefaultStatus() and "shaixuan_off" or "shaixuan_on", function(arg_35_0)
		setImageSprite(self.indexBtn, arg_35_0, true)
	end)

	local var_34_0 = {}

	for iter_34_0, iter_34_1 in pairs(self.craftList) do
		if IndexConst.filterSpWeaponByType(iter_34_1, self.contextData.indexDatas.typeIndex) and IndexConst.filterSpWeaponByRarity(iter_34_1, self.contextData.indexDatas.rarityIndex) and (self.contextData.showOwned or not iter_34_1.owned) then
			table.insert(var_34_0, iter_34_1)
		end
	end

	local var_34_1 = self.contextData.index or 1

	table.sort(var_34_0, CompareFuncs(SpWeaponSortCfg.sortFunc(SpWeaponSortCfg.sort[1], self.contextData.asc)))

	self.filterCraftList = var_34_0

	self:UpdateCraftList()
	setImageSprite(self.sortBtn:Find("Image"), (GetSpriteFromAtlas("ui/equipmentdesignui_atlas", var_0_1[var_34_1])))
	setActive(self.sortImgAsc, self.contextData.asc)
	setActive(self.sortImgDec, not self.contextData.asc)
end

function SpWeaponDesignLayer:UpdateCraftList()
	self.scollRect:SetTotalCount(#self.filterCraftList)
	setActive(self.listEmptyTF, #self.filterCraftList <= 0)
	Canvas.ForceUpdateCanvases()
end

function SpWeaponDesignLayer:onBackPressed()
	if isActive(self.indexPanel) then
		triggerButton(self.indexPanel)

		return
	end

	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	self:emit(SpWeaponDesignLayer.ON_BACK)
end

function SpWeaponDesignLayer:willExit()
	self:UnOverlayPanel(self.indexPanel, self._tf)
	setParent(self.toggleOwned, self._tf)
	setParent(self.top, self._tf)
end

return SpWeaponDesignLayer
