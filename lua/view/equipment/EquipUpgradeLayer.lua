local EquipUpgradeLayer = class("EquipUpgradeLayer", import("..base.BaseUI"))

EquipUpgradeLayer.CHAT_DURATION_TIME = 0.3

function EquipUpgradeLayer:getUIName()
	return "EquipUpgradeUI"
end

function EquipUpgradeLayer:getResource()
	local var_2_0 = {
		"weaponframes",
		"shiptype",
		"ui/iconcolorful"
	}

	table.insertto(var_2_0, EquipUpgradeLayer.super.getResource(self))

	return var_2_0
end

function EquipUpgradeLayer:init()
	pg.UIMgr.GetInstance():BlurPanel(self._tf, {
		staticBlur = true
	})

	self.mainPanel = self._tf:Find("main")
	self.finishPanel = self._tf:Find("finish_panel")

	setActive(self.mainPanel, true)
	setActive(self.finishPanel, false)

	self.equipmentList = self.mainPanel:Find("panel/equipment_list")
	self.equipmentContain = self.equipmentList:Find("equipments")
	self.equipmentTpl = self:getTpl("equiptpl", self.equipmentContain)

	setActive(self.equipmentList, false)

	self.equipmentPanel = self.mainPanel:Find("panel/equipment_panel")
	self.materialPanel = self.mainPanel:Find("panel/material_panel")
	self.startBtn = self.materialPanel:Find("start_btn")
	self.overLimit = self.materialPanel:Find("materials/limit")

	setText(self.overLimit:Find("text"), i18n("equipment_upgrade_overlimit"))

	self.materialsContain = self.materialPanel:Find("materials/materials")

	setText(self.rtTogglesEmpty:Find("Text"), i18n("equip_enhancement_finish"))
	setText(self.rtPanelTitle, i18n("equip_enhancement_required"))
	setText(self.rtTitle, i18n("equip_enhancement_title"))
end

function EquipUpgradeLayer:didEnter()
	onButton(self, self._tf:Find("bg"), function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.btnCancel, function()
		self:closeView()
	end, SFX_CANCEL)
	self:updateAll()
end

function EquipUpgradeLayer:updateAll()
	setActive(self.equipmentList, self.contextData.shipVO)

	if self.contextData.shipVO then
		self:displayEquipments()

		if self.contextData.pos then
			triggerButton(self.equipmentTFs[self.contextData.pos])
		else
			triggerButton(self.equipmentContain:GetChild(0))
		end
	else
		self:updateEquipment()
		self:updateMaterials()
	end
end

function EquipUpgradeLayer:displayEquipments()
	self.equipmentTFs = {}

	removeAllChildren(self.equipmentContain)

	local var_8_0 = self.contextData.shipVO

	for iter_8_0, iter_8_1 in ipairs(self.contextData.shipVO.equipments) do
		if iter_8_1 then
			local var_8_1 = cloneTplTo(self.equipmentTpl, self.equipmentContain)

			updateEquipment(var_8_1, iter_8_1)

			local var_8_2 = var_8_1:Find("tip")

			setActive(var_8_2, false)

			if self:isMaterialEnough(iter_8_1) and iter_8_1:getConfig("next") ~= 0 then
				setActive(var_8_2, true)
				blinkAni(var_8_2, 0.5)
			end

			onButton(self, var_8_1, function()
				if self.contextData.pos then
					setActive(self.equipmentTFs[self.contextData.pos]:Find("selected"), false)

					local var_9_0 = self:isMaterialEnough(var_8_0:getEquip(self.contextData.pos))

					if var_9_0 then
						var_9_0 = var_8_0:getEquip(self.contextData.pos):getConfig("next") ~= 0
					end

					setActive(self.equipmentTFs[self.contextData.pos]:Find("tip"), var_9_0)
				end

				self.contextData.pos = iter_8_0
				self.contextData.equipmentId = iter_8_1.id
				self.contextData.equipmentVO = iter_8_1

				setActive(self.equipmentTFs[self.contextData.pos]:Find("selected"), true)
				setActive(self.equipmentTFs[self.contextData.pos]:Find("tip"), false)
				self:updateEquipment()
				self:updateMaterials()
			end, SFX_PANEL)

			self.equipmentTFs[iter_8_0] = var_8_1
		end
	end
end

function EquipUpgradeLayer:isMaterialEnough(arg_10_1)
	local var_10_0 = arg_10_1:getConfig("trans_use_item")

	if not var_10_0 then
		return false
	end

	for iter_10_0, iter_10_1 in ipairs(underscore.map(var_10_0, function(arg_11_0)
		local var_11_0, var_11_1 = unpack(arg_11_0)

		return Drop.New({
			type = DROP_TYPE_ITEM,
			id = var_11_0,
			count = var_11_1
		})
	end)) do
		if iter_10_1.count > iter_10_1:getOwnedCount() then
			return false
		end
	end

	return true
end

function EquipUpgradeLayer:updateEquipment()
	local var_12_0 = self.contextData.equipmentVO

	self.contextData.equipmentId = self.contextData.equipmentVO.id

	changeToScrollText(self.equipmentPanel:Find("name_container"), var_12_0:getConfig("name"))
	setActive(findTF(self.equipmentPanel, "unique"), var_12_0:isUnique())
	updateEquipment(self.equipmentPanel:Find("equiptpl"), var_12_0)

	self.nextEquips = {}

	while var_12_0:getConfig("next") > 0 do
		var_12_0 = var_12_0:MigrateTo(var_12_0:getConfig("next"))

		table.insert(self.nextEquips, var_12_0)
	end

	if #self.nextEquips == 0 then
		self.toggleEquips = nil
	else
		self.toggleEquips = {
			self.nextEquips[1]
		}

		if #self.nextEquips > 0 then
			local var_12_1 = self.nextEquips[#self.nextEquips]:getConfig("level")

			for iter_12_0, iter_12_1 in ipairs((switch(self.nextEquips[#self.nextEquips]:getConfig("level") - 1, {
				[13] = function()
					return {
						10,
						13
					}
				end,
				[11] = function()
					return {
						10,
						11
					}
				end,
				[10] = function()
					return {
						10
					}
				end,
				[7] = function()
					return {
						6,
						7
					}
				end,
				[6] = function()
					return {
						6
					}
				end,
				[3] = function()
					return {
						3
					}
				end
			}, function()
				return {}
			end))) do
				if #self.nextEquips > var_12_1 - 1 - iter_12_1 then
					table.insert(self.toggleEquips, self.nextEquips[#self.nextEquips - (var_12_1 - 1 - iter_12_1)])
				end
			end
		end
	end

	self:updateToggles()
end

function EquipUpgradeLayer:updateToggles()
	setActive(self.rtToggles, tobool(self.toggleEquips))
	setActive(self.rtTogglesEmpty, not tobool(self.toggleEquips))

	if self.toggleEquips then
		UIItemList.StaticAlign(self.rtToggles, self.rtToggleTpl, #self.toggleEquips, function(arg_21_0, arg_21_1, arg_21_2)
			arg_21_1 = arg_21_1 + 1

			if arg_21_0 == UIItemList.EventUpdate then
				local var_21_0 = self.toggleEquips[arg_21_1]

				if arg_21_1 == 1 then
					setText(arg_21_2:Find("Text"), i18n("equip_enhancement_lv1"))
				else
					setText(arg_21_2:Find("Text"), i18n("equip_enhancement_lvx", self.toggleEquips[arg_21_1]:getConfig("level") - 1))
				end

				onToggle(self, arg_21_2, function(arg_22_0)
					if arg_22_0 then
						self.targetEquip = var_21_0

						self:updateMaterials()
					end
				end, SFX_PANEL)
			end
		end)
		triggerToggle(self.rtToggles:GetChild(0), true)
	else
		self.targetEquip = nil

		self:updateMaterials()
	end
end

local function var_0_1(arg_23_0)
	arg_23_0.sub = {
		(_.detect(arg_23_0.sub, function(arg_24_0)
			return arg_24_0.type == AttributeType.Damage
		end))
	}
end

local function var_0_2(arg_25_0)
	arg_25_0.sub = {
		(_.detect(arg_25_0.sub, function(arg_26_0)
			return arg_26_0.type == AttributeType.Corrected
		end))
	}
end

function EquipUpgradeLayer:updateAttrs(arg_27_1, arg_27_2, arg_27_3)
	local var_27_0 = arg_27_2:GetPropertiesInfo()

	for iter_27_0 = 1, #var_27_0.weapon.sub do
		var_0_1(var_27_0.weapon.sub[iter_27_0])
	end

	var_0_2(var_27_0.equipInfo)

	var_27_0.equipInfo.lock_open = true

	if arg_27_3 then
		local var_27_1 = arg_27_3:GetPropertiesInfo()

		Equipment.InsertAttrsUpgrade(var_27_0.attrs, var_27_1.attrs)

		local var_27_2 = arg_27_2:GetSkill()
		local var_27_3 = arg_27_3:GetSkill()

		if checkExist(var_27_2, {
			"name"
		}) ~= checkExist(var_27_3, {
			"name"
		}) then
			local var_27_4 = {
				lock_open = true,
				name = i18n("skill")
			}

			var_27_4.value = setColorStr(checkExist(var_27_2, {
				"name"
			}) or i18n("equip_info_25"), "#FFDE00FF")

			local var_27_5 = {}
			local var_27_6 = {
				name = i18n("equip_info_26")
			}

			var_27_6.value = setColorStr(checkExist(var_27_3, {
				"name"
			}) or i18n("equip_info_25"), "#FFDE00FF")
			var_27_5[1] = var_27_6
			var_27_4.sub = var_27_5

			table.insert(var_27_0.attrs, var_27_4)
		end

		if #var_27_1.weapon.sub > #var_27_0.weapon.sub then
			for iter_27_1 = #var_27_0.weapon.sub, #var_27_1.weapon.sub do
				table.insert(var_27_0.weapon.sub, {
					name = i18n("equip_info_25"),
					sub = {}
				})
			end
		end

		for iter_27_2 = #var_27_0.weapon.sub, 1, -1 do
			local var_27_7 = var_27_0.weapon.sub[iter_27_2]
			local var_27_8 = var_27_1.weapon.sub[iter_27_2]

			if var_27_1.weapon.sub[iter_27_2] then
				var_0_1(var_27_1.weapon.sub[iter_27_2])
			else
				var_27_8 = {
					name = i18n("equip_info_25"),
					sub = {}
				}
			end

			if var_27_7.name ~= var_27_8.name then
				var_27_7.sub = {
					{
						name = i18n("equip_info_27"),
						value = var_27_8.name
					}
				}
			else
				Equipment.InsertAttrsUpgrade(var_27_7.sub, var_27_8.sub)
			end

			if #var_27_7.sub == 0 then
				table.remove(var_27_0.weapon.sub, iter_27_2)

				if var_27_1.weapon.sub[iter_27_2] then
					table.remove(var_27_1.weapon.sub, iter_27_2)
				end
			end
		end

		var_0_2(var_27_1.equipInfo)
		Equipment.InsertAttrsUpgrade(var_27_0.equipInfo.sub, var_27_1.equipInfo.sub)
	end

	updateEquipUpgradeInfo(arg_27_1, var_27_0, self.contextData.shipVO)
end

function EquipUpgradeLayer:updateMaterials()
	local var_28_0 = tobool(self.targetEquip)

	setActive(self.materialsContain, var_28_0)
	setActive(self.overLimit, not var_28_0)
	setButtonEnabled(self.startBtn, var_28_0)
	setTextAlpha(self.startBtn:Find("consume"), var_28_0 and 1 or 0.5)
	self:updateAttrs(self.equipmentPanel:Find("view/content"), self.contextData.equipmentVO, self.targetEquip)
	setText(self.rtLevel:Find("before"), i18n("equip_enhancement_lv"))
	setText(self.rtLevel:Find("before/number"), self.contextData.equipmentVO:getConfig("level") - 1)
	setText(self.rtLevel:Find("after"), i18n("equip_enhancement_lv"))
	setText(self.rtLevel:Find("after/number"), (self.targetEquip or self.contextData.equipmentVO):getConfig("level") - 1)
	setActive(self.rtLevel:Find("before"), var_28_0)
	setActive(self.rtLevel:Find("Image"), var_28_0)

	local var_28_1

	if not var_28_0 then
		setText(self.startBtn:Find("consume"), 0)

		do return end

		var_28_1 = self.contextData.equipmentVO:getConfig("trans_use_item") or {}
	end

	local var_28_2 = underscore.to_array(var_28_1)
	local var_28_3 = defaultValue(self.contextData.equipmentVO:getConfig("trans_use_gold"), 0)

	for iter_28_0, iter_28_1 in ipairs(self.nextEquips) do
		if iter_28_1 == self.targetEquip then
			break
		else
			table.insertto(var_28_2, iter_28_1:getConfig("trans_use_item") or {})

			var_28_3 = var_28_3 + defaultValue(iter_28_1:getConfig("trans_use_gold"), 0)
		end
	end

	local var_28_4 = PlayerConst.MergeSameDrops(underscore.map(var_28_2, function(arg_29_0)
		local var_29_0, var_29_1 = unpack(arg_29_0)

		return Drop.New({
			type = DROP_TYPE_ITEM,
			id = var_29_0,
			count = var_29_1
		})
	end))
	local var_28_5 = true
	local var_28_6
	local var_28_7 = 0

	for iter_28_2 = 1, 5 do
		local var_28_8 = self.materialsContain:GetChild(iter_28_2 - 1)
		local var_28_9 = var_28_4[iter_28_2]

		setActive(findTF(var_28_8, "off"), not var_28_4[iter_28_2])
		setActive(findTF(var_28_8, "equiptpl"), var_28_9)

		if var_28_9 then
			local var_28_10 = findTF(var_28_8, "equiptpl")

			updateItem(var_28_10, var_28_9:getSubClass())
			onButton(self, var_28_10, function()
				self:emit(BaseUI.ON_DROP, var_28_9)
			end, SFX_PANEL)

			local var_28_11 = var_28_9:getOwnedCount()
			local var_28_12 = var_28_10:Find("icon_bg/count")

			if var_28_11 < var_28_9.count then
				setText(var_28_12, setColorStr(var_28_11, COLOR_RED) .. "/" .. var_28_9.count)

				var_28_5 = false
				var_28_6 = var_28_9.id
			else
				setText(var_28_12, var_28_11 .. "/" .. var_28_9.count)
			end

			setActive(var_28_12, true)
			onButton(self, var_28_10:Find("click"), function()
				setActive(var_28_10:Find("click"), false)

				var_28_7 = var_28_7 - 1
			end, SFX_PANEL)

			local var_28_13 = var_28_9:getDropRarity() > 3

			setActive(var_28_10:Find("click"), var_28_13)

			var_28_7 = var_28_7 + (var_28_13 and 1 or 0)
		end
	end

	local var_28_14 = Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = PlayerConst.ResGold,
		count = var_28_3
	})
	local var_28_15 = var_28_14:getOwnedCount()

	if var_28_15 < var_28_14.count then
		setText(self.startBtn:Find("consume"), setColorStr(var_28_3, COLOR_RED))
	else
		setText(self.startBtn:Find("consume"), var_28_3)
	end

	onButton(self, self.startBtn, function()
		if not var_28_5 then
			if not ItemTipPanel.ShowItemTipbyID(var_28_6) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ship_shipUpgradeLayer2_noMaterail"))
			end

			return
		end

		if var_28_7 > 0 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("equipment_upgrade_costcheck_error"))

			return
		end

		if var_28_15 < var_28_3 then
			GoShoppingMsgBox(i18n("switch_to_shop_tip_2", i18n("word_gold")), ChargeScene.TYPE_ITEM, {
				{
					59001,
					var_28_3 - var_28_15,
					var_28_3
				}
			})

			return
		end

		self:emit(EquipUpgradeMediator.EQUIPMENT_UPGRDE, self.targetEquip, var_28_4, var_28_3)
	end, SFX_UI_DOCKYARD_REINFORCE)
end

function EquipUpgradeLayer:upgradeFinish(arg_33_1, arg_33_2)
	setActive(self.mainPanel, false)
	setActive(self.finishPanel, true)
	onButton(self, self.finishPanel:Find("bg"), function()
		setActive(self.mainPanel, true)
		setActive(self.finishPanel, false)
	end, SFX_CANCEL)
	changeToScrollText(self.finishPanel:Find("frame/equipment_panel/name_container"), arg_33_2:getConfig("name"))
	setActive(findTF(self.finishPanel, "frame/equipment_panel/unique"), arg_33_2:isUnique())
	updateEquipment(self.finishPanel:Find("frame/equipment_panel/equiptpl"), arg_33_2)
	self:updateAttrs(self.finishPanel:Find("frame/equipment_panel/view/content"), arg_33_1, arg_33_2)
end

function EquipUpgradeLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return EquipUpgradeLayer
