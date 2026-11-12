local SpWeaponInfoLayer = class("SpWeaponInfoLayer", import("view.base.BaseUI"))

function SpWeaponInfoLayer:getUIName()
	return "SpWeaponInfoUI"
end

function SpWeaponInfoLayer:getResource()
	local var_2_0 = {
		"ui/equipmentinfoui_atlas",
		"equiptype",
		"weaponframes",
		"shiptype"
	}

	table.insertto(var_2_0, SpWeaponInfoLayer.super.getResource(self))

	return var_2_0
end

SpWeaponInfoLayer.Left = 1
SpWeaponInfoLayer.Middle = 2
SpWeaponInfoLayer.Right = 3
SpWeaponInfoLayer.pos = {
	{
		-353,
		30,
		0
	},
	{
		0,
		30,
		0
	},
	{
		353,
		30,
		0
	}
}
SpWeaponInfoLayer.TYPE_DEFAULT = 1
SpWeaponInfoLayer.TYPE_SHIP = 2
SpWeaponInfoLayer.TYPE_REPLACE = 3
SpWeaponInfoLayer.TYPE_DISPLAY = 4
SpWeaponInfoLayer.SHOW_UNIQUE = {
	1,
	2,
	3,
	4
}

function SpWeaponInfoLayer:init()
	self.toggles = {}

	for iter_3_0, iter_3_1 in ipairs({
		"default",
		"replace",
		"display"
	}) do
		self[iter_3_1 .. "Panel"] = self._tf:Find(iter_3_1)
		self.toggles[iter_3_1 .. "Panel"] = self._tf:Find("toggle_controll/" .. iter_3_1)
	end

	Canvas.ForceUpdateCanvases()

	self.sample = self._tf:Find("sample")

	setActive(self.sample, false)

	self.txtQuickEnable = findTF(self._tf, "txtQuickEnable")

	setText(self.txtQuickEnable, i18n("ship_equip_check"))
	setText(self._tf:Find("sample/empty/Text"), i18n("spweapon_ui_empty"))
end

function SpWeaponInfoLayer:setEquipment(arg_4_1, arg_4_2)
	self.equipmentVO = arg_4_1
	self.oldEquipmentVO = arg_4_2
end

function SpWeaponInfoLayer:setShip(arg_5_1, arg_5_2)
	self.shipVO = arg_5_1
	self.oldShipVO = arg_5_2
end

function SpWeaponInfoLayer:setPlayer(arg_6_1)
	self.player = arg_6_1
end

function SpWeaponInfoLayer:checkOverGold(arg_7_1)
	if self.player:GoldMax(_.detect(arg_7_1, function(arg_8_0)
		return arg_8_0.type == DROP_TYPE_RESOURCE and arg_8_0.id == 1
	end).count or 0) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title") .. i18n("resource_max_tip_destroy"))

		return false
	end

	return true
end

function SpWeaponInfoLayer:didEnter()
	setActive(self.txtQuickEnable, self.contextData.quickFlag or false)

	local var_9_1 = defaultValue(self.contextData.type, SpWeaponInfoLayer.TYPE_DEFAULT)

	self.isShowUnique = table.contains(SpWeaponInfoLayer.SHOW_UNIQUE, var_9_1)

	onButton(self, self._tf:Find("bg"), function()
		self:closeView()
	end, SOUND_BACK)
	self:initAndSetBtn(var_9_1)

	if var_9_1 == SpWeaponInfoLayer.TYPE_DEFAULT then
		self:updateOperation1()
	elseif var_9_1 == SpWeaponInfoLayer.TYPE_SHIP then
		self:updateOperation2()
	elseif var_9_1 == SpWeaponInfoLayer.TYPE_REPLACE then
		self:updateOperation3()
	elseif var_9_1 == SpWeaponInfoLayer.TYPE_DISPLAY then
		self:updateOperation4()
	end

	pg.UIMgr.GetInstance():BlurPanel(self._tf, {
		staticBlur = true
	})
end

local var_0_1 = {
	{
		"Enhance",
		"msgbox_text_noPos_intensify"
	},
	{
		"Replace",
		"msgbox_text_replace"
	},
	{
		"Unload",
		"msgbox_text_unload"
	},
	{
		"Modify",
		"msgbox_text_modify"
	}
}

function SpWeaponInfoLayer:initAndSetBtn(arg_11_1)
	if arg_11_1 == SpWeaponInfoLayer.TYPE_DEFAULT or arg_11_1 == SpWeaponInfoLayer.TYPE_SHIP then
		self.defaultEquipTF = self.defaultPanel:Find("equipment") or self:cloneSampleTo(self.defaultPanel, SpWeaponInfoLayer.Middle, "equipment")

		table.Foreach(var_0_1, function(arg_12_0, arg_12_1)
			local var_12_0 = self.defaultPanel:Find("actions/action_button_" .. arg_12_0)

			self["default" .. arg_12_1[1] .. "Btn"] = var_12_0

			setText(var_12_0:GetChild(0), i18n(arg_12_1[2]))
		end)
		onButton(self, self.defaultReplaceBtn, function()
			self:emit(SpWeaponInfoMediator.ON_CHANGE)
		end, SFX_PANEL)
		onButton(self, self.defaultEnhanceBtn, function()
			self:emit(SpWeaponInfoMediator.ON_INTENSIFY)
		end, SFX_PANEL)
		onButton(self, self.defaultUnloadBtn, function()
			self:emit(SpWeaponInfoMediator.ON_UNEQUIP)
		end, SFX_UI_DOCKYARD_EQUIPOFF)
		onButton(self, self.defaultModifyBtn, function()
			self:emit(SpWeaponInfoMediator.ON_MODIFY)
		end, SFX_PANEL)
	elseif arg_11_1 == SpWeaponInfoLayer.TYPE_REPLACE then
		self.replaceSrcEquipTF = self.replacePanel:Find("equipment") or self:cloneSampleTo(self.replacePanel, SpWeaponInfoLayer.Left, "equipment")
		self.replaceDstEquipTF = self.replacePanel:Find("equipment_on_ship") or self:cloneSampleTo(self.replacePanel, SpWeaponInfoLayer.Right, "equipment_on_ship")
		self.replaceCancelBtn = self.replacePanel:Find("actions/cancel_button")
		self.replaceConfirmBtn = self.replacePanel:Find("actions/action_button_2")

		setText(self.replaceConfirmBtn:Find("label"), i18n("msgbox_text_confirm"))
		setText(self.replaceCancelBtn:Find("label"), i18n("msgbox_text_cancel"))
		onButton(self, self.replaceCancelBtn, function()
			self:closeView()
		end, SFX_CANCEL)
		onButton(self, self.replaceConfirmBtn, function()
			if self.contextData.quickCallback then
				self.contextData.quickCallback()
				self:closeView()
			else
				self:emit(SpWeaponInfoMediator.ON_EQUIP)
			end
		end, SFX_UI_DOCKYARD_EQUIPADD)
	elseif arg_11_1 == SpWeaponInfoLayer.TYPE_DISPLAY then
		self.displayEquipTF = self.displayPanel:Find("equipment") or self:cloneSampleTo(self.displayPanel, SpWeaponInfoLayer.Middle, "equipment")
		self.displayMoveBtn = self.displayPanel:Find("actions/move_button")

		setText(self.displayMoveBtn:Find("label"), i18n("msgbox_text_equipdetail"))
		onButton(self, self.displayMoveBtn, function()
			self:emit(SpWeaponInfoMediator.ON_MOVE, self.shipVO.id)
		end)
	end
end

function SpWeaponInfoLayer:updateOperation1()
	triggerToggle(self.toggles.defaultPanel, true)

	if not self.equipmentVO then
		if self.contextData.spWeaponUid then
			self.equipmentVO = getProxy(EquipmentProxy):GetSpWeaponByUid(self.contextData.spWeaponUid)

			if not self.equipmentVO then
				local var_20_0 = getProxy(BayProxy)

				for iter_20_0, iter_20_1 in pairs(var_20_0:getRawData()) do
					local var_20_1 = iter_20_1:GetSpWeapon()

					if var_20_1 and var_20_1:GetUID() == self.contextData.spWeaponUid then
						self.shipVO = var_20_0:getShipById(iter_20_0)
						self.equipmentVO = self.shipVO:GetSpWeapon()
						self.contextData.shipId = iter_20_0
						self.contextData.type = SpWeaponInfoLayer.TYPE_SHIP
					end
				end
			end
		end
	end

	self:updateEquipmentPanel(self.defaultEquipTF, self.equipmentVO, SpWeaponHelper.TransformNormalInfo(self.equipmentVO))
	setActive(self.defaultEnhanceBtn, true)
	setActive(self.defaultReplaceBtn, false)
	setActive(self.defaultUnloadBtn, false)
	setActive(self.defaultModifyBtn, true)
end

function SpWeaponInfoLayer:updateOperation2()
	triggerToggle(self.toggles.defaultPanel, true)

	local var_21_0 = self.shipVO:GetSpWeapon()

	self:updateEquipmentPanel(self.defaultEquipTF, var_21_0, SpWeaponHelper.TransformNormalInfo(var_21_0))
	setActive(self.defaultEnhanceBtn, true)
	setActive(self.defaultReplaceBtn, true)
	setActive(self.defaultUnloadBtn, true)
	setActive(self.defaultModifyBtn, true)

	local var_21_1 = self.defaultEquipTF:Find("head")

	setActive(var_21_1, self.shipVO)

	if self.shipVO then
		setImageSprite(findTF(var_21_1, "Image"), LoadSprite("qicon/" .. self.shipVO:getPainting()))
	end
end

function SpWeaponInfoLayer:updateOperation3()
	triggerToggle(self.toggles.replacePanel, true)

	if self.equipmentVO then
		local var_22_0, var_22_1 = SpWeaponHelper.CompareNormalInfo(self.equipmentVO, self.oldEquipmentVO)

		self:updateEquipmentPanel(self.replaceSrcEquipTF, self.equipmentVO, var_22_0)
		self:updateEquipmentPanel(self.replaceDstEquipTF, self.oldEquipmentVO, var_22_1)
	else
		self:updateEquipmentPanel(self.replaceSrcEquipTF, nil)
		self:updateEquipmentPanel(self.replaceDstEquipTF, self.oldEquipmentVO, SpWeaponHelper.TransformNormalInfo(self.oldEquipmentVO))
	end

	local var_22_2 = self.replaceDstEquipTF:Find("head")

	setActive(var_22_2, self.oldShipVO)

	if self.oldShipVO then
		setImageSprite(findTF(var_22_2, "Image"), LoadSprite("qicon/" .. self.oldShipVO:getPainting()))
	end
end

function SpWeaponInfoLayer:updateOperation4()
	triggerToggle(self.toggles.displayPanel, true)
	self:updateEquipmentPanel(self.displayEquipTF, self.equipmentVO, SpWeaponHelper.TransformNormalInfo(self.equipmentVO))
	setActive(self.displayMoveBtn, self.shipVO)

	local var_23_0 = self.displayEquipTF:Find("head")

	setActive(var_23_0, self.shipVO)

	if self.shipVO then
		setImageSprite(findTF(var_23_0, "Image"), LoadSprite("qicon/" .. self.shipVO:getPainting()))
	end
end

function SpWeaponInfoLayer:updateOperationAward(arg_24_1, arg_24_2, arg_24_3)
	self.awards = arg_24_3

	if arg_24_1.childCount == 0 then
		for iter_24_0 = 1, #arg_24_3 do
			cloneTplTo(arg_24_2, arg_24_1)
		end
	end

	for iter_24_1 = 1, #arg_24_3 do
		local var_24_0 = arg_24_1:GetChild(iter_24_1 - 1)
		local var_24_1 = arg_24_3[iter_24_1]

		updateDrop(var_24_0, arg_24_3[iter_24_1])
		onButton(self, var_24_0, function()
			self:emit(SpWeaponInfoLayer.ON_DROP, var_24_1)
		end, SFX_PANEL)
		setText(findTF(var_24_0, "name_panel/name"), getText(findTF(var_24_0, "name")))
		setText(findTF(var_24_0, "name_panel/number"), " x " .. getText(findTF(var_24_0, "icon_bg/count")))
		setActive(findTF(var_24_0, "icon_bg/count"), false)
	end
end

function SpWeaponInfoLayer:updateEquipmentPanel(arg_26_1, arg_26_2, arg_26_3)
	local var_26_0 = arg_26_1:Find("info")

	setActive(var_26_0, arg_26_2)
	setActive(arg_26_1:Find("empty"), not arg_26_2)

	if not arg_26_2 then
		return
	end

	setScrollText(findTF(findTF(var_26_0, "name"), "mask/Text"), arg_26_2:GetName())

	local var_26_1 = findTF(var_26_0, "equip")

	setImageSprite(findTF(var_26_1, "bg"), GetSpriteFromAtlas("ui/equipmentinfoui_atlas", "equip_bg_" .. ItemRarity.Rarity2Print(arg_26_2:GetRarity())))
	updateSpWeapon(var_26_1, arg_26_2, {
		noIconColorful = true
	})
	setActive(findTF(var_26_1, "slv"), arg_26_2:GetLevel() > 1)
	setText(findTF(var_26_1, "slv/Text"), arg_26_2:GetLevel() - 1)
	setActive(findTF(var_26_1, "slv/next"), false)
	setText(findTF(var_26_1, "slv/next/Text"), arg_26_2:GetLevel() - 1)

	local var_26_2 = var_26_1:Find("tier")

	setActive(var_26_2, arg_26_2)

	local var_26_3 = arg_26_2:GetTechTier()

	eachChild(var_26_2, function(arg_27_0)
		setActive(arg_27_0, tostring(var_26_3) == arg_27_0.gameObject.name)
	end)
	updateSpWeaponInfo(var_26_0:Find("attributes/view/content"), arg_26_3, arg_26_2:GetSkillGroup())

	local var_26_4 = arg_26_1:Find("info/unique")

	setActive(var_26_4, arg_26_2:IsUnique())

	if arg_26_2:IsUnique() then
		self:updateUnique(var_26_4, arg_26_2)
	end
end

function SpWeaponInfoLayer:updateUnique(arg_28_1, arg_28_2)
	local var_28_0 = arg_28_2:GetUniqueShips()
	local var_28_1 = Ship.New({
		configId = ShipGroup.getDefaultShipConfig(arg_28_2:GetUniqueGroup()).id
	})

	setImageSprite(arg_28_1:Find("head/icon"), LoadSprite("SquareIcon/" .. var_28_1:getPainting()))
	setText(arg_28_1:Find("title"), i18n("spweapon_unique_title"))
	setText(arg_28_1:Find("btn_skip/text"), i18n("spweapon_tip_jump"))
	onButton(self, arg_28_1:Find("btn_skip"), function()
		self:emit(SpWeaponInfoMediator.ON_SKIP_UNIQUE_SHIPS, {
			shipId = var_28_1.id,
			shipVOs = var_28_0
		})
	end)
end

function SpWeaponInfoLayer:cloneSampleTo(arg_30_1, arg_30_2, arg_30_3, arg_30_4)
	local var_30_0 = cloneTplTo(self.sample, arg_30_1, arg_30_3)

	var_30_0.localPosition = Vector3.New(SpWeaponInfoLayer.pos[arg_30_2][1], SpWeaponInfoLayer.pos[arg_30_2][2], SpWeaponInfoLayer.pos[arg_30_2][3])

	if arg_30_4 then
		var_30_0:SetSiblingIndex(arg_30_4)
	end

	return var_30_0
end

function SpWeaponInfoLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

function SpWeaponInfoLayer:onBackPressed()
	self:closeView()
end

return SpWeaponInfoLayer
