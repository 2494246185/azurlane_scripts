local EquipmentInfoLayer = class("EquipmentInfoLayer", import("..base.BaseUI"))

function EquipmentInfoLayer:getUIName()
	return "EquipmentInfoUI"
end

function EquipmentInfoLayer:getResource()
	local var_2_0 = {
		"ui/equipmentinfoui_atlas",
		"equiptype"
	}

	table.insertto(var_2_0, EquipmentInfoLayer.super.getResource(self))

	return var_2_0
end

EquipmentInfoLayer.PANEL_DESTROY = "Destroy"
EquipmentInfoLayer.PANEL_REVERT = "Revert"
EquipmentInfoLayer.Left = 1
EquipmentInfoLayer.Middle = 2
EquipmentInfoLayer.Right = 3
EquipmentInfoLayer.pos = {
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

function EquipmentInfoLayer:init()
	self.toggles = {}

	for iter_3_0, iter_3_1 in ipairs({
		"default",
		"replace",
		"display",
		"destroy",
		"revert"
	}) do
		self[iter_3_1 .. "Panel"] = self._tf:Find(iter_3_1)
		self.toggles[iter_3_1 .. "Panel"] = self._tf:Find("toggle_controll/" .. iter_3_1)
	end

	self.sample = self._tf:Find("sample")

	setActive(self.sample, false)
	setActive(self.defaultPanel:Find("transform_tip"), false)

	self.txtQuickEnable = findTF(self._tf, "txtQuickEnable")

	setText(self.txtQuickEnable, i18n("ship_equip_check"))

	self.equipDestroyConfirmWindow = EquipDestoryConfirmWindow.New(self._tf, self.event)
end

function EquipmentInfoLayer:setEquipment(arg_4_1)
	self.equipmentVO = arg_4_1
end

function EquipmentInfoLayer:setShip(arg_5_1, arg_5_2)
	self.shipVO = arg_5_1
	self.oldShipVO = arg_5_2
end

function EquipmentInfoLayer:setPlayer(arg_6_1)
	self.player = arg_6_1
end

function EquipmentInfoLayer:checkOverGold(arg_7_1)
	if self.player:GoldMax(_.detect(arg_7_1, function(arg_8_0)
		return arg_8_0.type == DROP_TYPE_RESOURCE and arg_8_0.id == 1
	end).count or 0) then
		pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title") .. i18n("resource_max_tip_destroy"))

		return false
	end

	return true
end

function EquipmentInfoLayer:setDestroyCount(arg_9_1)
	arg_9_1 = math.clamp(arg_9_1, 1, self.equipmentVO.count)

	if self.destroyCount ~= arg_9_1 then
		self.destroyCount = arg_9_1

		self:updateDestroyCount()
	end
end

function EquipmentInfoLayer:didEnter()
	setActive(self.txtQuickEnable, self.contextData.quickFlag or false)

	local var_10_1 = defaultValue(self.contextData.type, EquipmentInfoMediator.TYPE_DEFAULT)

	self.isShowUnique = table.contains(EquipmentInfoMediator.SHOW_UNIQUE, var_10_1)

	onButton(self, self._tf:Find("bg"), function()
		if isActive(self.destroyPanel) then
			triggerToggle(self.toggles.defaultPanel, true)

			return
		end

		self:closeView()
	end, SOUND_BACK)
	self:initAndSetBtn(var_10_1)

	if var_10_1 == EquipmentInfoMediator.TYPE_DEFAULT then
		self:updateOperation1()
	elseif var_10_1 == EquipmentInfoMediator.TYPE_SHIP then
		self:updateOperation2()
	elseif var_10_1 == EquipmentInfoMediator.TYPE_REPLACE then
		self:updateOperation3()
	elseif var_10_1 == EquipmentInfoMediator.TYPE_DISPLAY then
		self:updateOperation4()
	end

	pg.UIMgr.GetInstance():BlurPanel(self._tf, {
		staticBlur = true
	})
end

function EquipmentInfoLayer:initAndSetBtn(arg_12_1)
	if arg_12_1 == EquipmentInfoMediator.TYPE_DEFAULT or arg_12_1 == EquipmentInfoMediator.TYPE_SHIP then
		self.defaultEquipTF = self.defaultPanel:Find("equipment") or self:cloneSampleTo(self.defaultPanel, EquipmentInfoLayer.Middle, "equipment")
		self.defaultReplaceBtn = self.defaultPanel:Find("actions/action_button_3")
		self.defaultDestroyBtn = self.defaultPanel:Find("actions/action_button_1")
		self.defaultEnhanceBtn = self.defaultPanel:Find("actions/action_button_2")
		self.defaultUnloadBtn = self.defaultPanel:Find("actions/action_button_4")
		self.defaultRevertBtn = self.defaultEquipTF:Find("info/equip/revert_btn")
		self.defaultTransformTipBar = self.defaultEquipTF:Find("transform_tip")

		if arg_12_1 == EquipmentInfoMediator.TYPE_DEFAULT and not self.defaultTransformTipBar then
			local var_12_0 = self.defaultPanel:Find("transform_tip")

			setParent(var_12_0, self.defaultEquipTF)

			var_12_0.sizeDelta.y = 0
			var_12_0.sizeDelta = var_12_0.sizeDelta

			setAnchoredPosition(var_12_0, Vector2.zero)

			self.defaultTransformTipBar = var_12_0
		end

		onButton(self, self.defaultReplaceBtn, function()
			local var_13_0, var_13_1 = ShipStatus.ShipStatusCheck("onModify", self.shipVO)

			if not var_13_0 then
				pg.TipsMgr.GetInstance():ShowTips(var_13_1)

				return
			end

			self:emit(EquipmentInfoMediator.ON_CHANGE)
		end, SFX_PANEL)
		onButton(self, self.defaultEnhanceBtn, function()
			if self.shipVO then
				local var_14_0, var_14_1 = ShipStatus.ShipStatusCheck("onModify", self.shipVO)

				if not var_14_0 then
					pg.TipsMgr.GetInstance():ShowTips(var_14_1)

					return
				end
			end

			self:emit(EquipmentInfoMediator.ON_INTENSIFY)
		end, SFX_PANEL)
		onButton(self, self.defaultUnloadBtn, function()
			local var_15_0, var_15_1 = ShipStatus.ShipStatusCheck("onModify", self.shipVO)

			if not var_15_0 then
				pg.TipsMgr.GetInstance():ShowTips(var_15_1)

				return
			end

			self:emit(EquipmentInfoMediator.ON_UNEQUIP)
		end, SFX_UI_DOCKYARD_EQUIPOFF)
		onButton(self, self.defaultDestroyBtn, function()
			triggerToggle(self.toggles.destroyPanel, true)

			if not self.initDestroyPanel then
				self:initAndSetBtn(EquipmentInfoLayer.PANEL_DESTROY)
			end

			self:updateEquipmentPanel(self.destroyEquipTF, self.equipmentVO)

			if self.equipmentVO.count > 0 then
				self:setDestroyCount(1)
			end
		end, SFX_PANEL)
		onButton(self, self.defaultRevertBtn, function()
			triggerToggle(self.toggles.revertPanel, true)

			if not self.initRevertPanel then
				self:initAndSetBtn(EquipmentInfoLayer.PANEL_REVERT)
			end

			self:updateRevertPanel()
		end, SFX_PANEL)
	elseif arg_12_1 == EquipmentInfoMediator.TYPE_REPLACE then
		self.replaceSrcEquipTF = self.replacePanel:Find("equipment") or self:cloneSampleTo(self.replacePanel, EquipmentInfoLayer.Left, "equipment")
		self.replaceDstEquipTF = self.replacePanel:Find("equipment_on_ship") or self:cloneSampleTo(self.replacePanel, EquipmentInfoLayer.Right, "equipment_on_ship")
		self.replaceCancelBtn = self.replacePanel:Find("actions/cancel_button")
		self.replaceConfirmBtn = self.replacePanel:Find("actions/action_button_2")

		onButton(self, self.replaceCancelBtn, function()
			if isActive(self.destroyPanel) then
				triggerToggle(self.toggles.defaultPanel, true)

				return
			end

			self:closeView()
		end, SFX_CANCEL)
		onButton(self, self.replaceConfirmBtn, function()
			local var_19_0, var_19_1 = self.shipVO:canEquipAtPos(self.equipmentVO, self.contextData.pos)

			if not var_19_0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("equipment_equipmentInfoLayer_error_canNotEquip", var_19_1))

				return
			end

			if self.contextData.quickCallback then
				self.contextData.quickCallback()
				self:closeView()
			else
				self:emit(EquipmentInfoMediator.ON_EQUIP)
			end
		end, SFX_UI_DOCKYARD_EQUIPADD)
	elseif arg_12_1 == EquipmentInfoMediator.TYPE_DISPLAY then
		self.displayEquipTF = self.displayPanel:Find("equipment") or self:cloneSampleTo(self.displayPanel, EquipmentInfoLayer.Middle, "equipment")
		self.displayMoveBtn = self.displayPanel:Find("actions/move_button")
		self.defaultTransformTipBar = self.displayEquipTF:Find("transform_tip")

		if self.contextData.showTransformTip and not self.defaultTransformTipBar then
			local var_12_1 = self.defaultPanel:Find("transform_tip")

			setParent(var_12_1, self.displayEquipTF)

			var_12_1.sizeDelta.y = 0
			var_12_1.sizeDelta = var_12_1.sizeDelta

			setAnchoredPosition(var_12_1, Vector2.zero)

			self.defaultTransformTipBar = var_12_1
		end

		onButton(self, self.displayMoveBtn, function()
			self:emit(EquipmentInfoMediator.ON_MOVE, self.shipVO.id)
		end)
	elseif arg_12_1 == EquipmentInfoLayer.PANEL_DESTROY then
		self.initDestroyPanel = true
		self.destroyEquipTF = self.destroyPanel:Find("equipment") or self:cloneSampleTo(self.destroyPanel, EquipmentInfoLayer.Left, "equipment")
		self.destroyCounter = self.destroyPanel:Find("destroy")
		self.destroyValue = self.destroyCounter:Find("count/number_panel/value")
		self.destroyLeftButton = self.destroyCounter:Find("count/number_panel/left")
		self.destroyRightButton = self.destroyCounter:Find("count/number_panel/right")
		self.destroyBonusList = self.destroyCounter:Find("got/list")
		self.destroyBonusItem = self.destroyCounter:Find("got/item")
		self.destroyCancelBtn = self.destroyPanel:Find("actions/cancel_button")
		self.destroyConfirmBtn = self.destroyPanel:Find("actions/destroy_button")

		onButton(self, self.destroyLeftButton, function()
			self:setDestroyCount(self.destroyCount - 1)
		end, SFX_PANEL)
		onButton(self, self.destroyRightButton, function()
			self:setDestroyCount(self.destroyCount + 1)
		end, SFX_PANEL)
		onButton(self, self.destroyCounter:Find("count/max"), function()
			self:setDestroyCount(self.equipmentVO.count)
		end, SFX_PANEL)
		onButton(self, self.destroyCancelBtn, function()
			triggerToggle(self.toggles.defaultPanel, true)
		end, SFX_CANCEL)
		onButton(self, self.destroyConfirmBtn, function()
			if not self:checkOverGold(self.awards) then
				return
			end

			local var_25_0 = {}

			if self.equipmentVO:isImportance() then
				table.insert(var_25_0, function(arg_26_0)
					self.equipDestroyConfirmWindow:Load()
					self.equipDestroyConfirmWindow:ActionInvoke("Show", {
						setmetatable({
							count = self.destroyCount
						}, {
							__index = self.equipmentVO
						})
					}, arg_26_0)
				end)
			end

			seriesAsync(var_25_0, function()
				self:emit(EquipmentInfoMediator.ON_DESTROY, self.destroyCount)
			end)
		end, SFX_UI_EQUIPMENT_RESOLVE)
	elseif arg_12_1 == EquipmentInfoLayer.PANEL_REVERT then
		self.initRevertPanel = true
		self.revertEquipTF = self.revertPanel:Find("equipment") or self:cloneSampleTo(self.revertPanel, EquipmentInfoLayer.Left, "equipment")
		self.revertAwardContainer = self.revertPanel:Find("item_panel/got/list")
		self.revertCancelBtn = self.revertPanel:Find("actions/cancel_button")
		self.revertConfirmBtn = self.revertPanel:Find("actions/revert_button")
		self.itemTpl = self:getTpl("item_panel/got/item", self.revertPanel)

		onButton(self, self.revertCancelBtn, function()
			triggerToggle(self.toggles.defaultPanel, true)
		end, SFX_CANCEL)
		onButton(self, self.revertConfirmBtn, function()
			if not self:checkOverGold(self.awards) then
				return
			end

			self:emit(EquipmentInfoMediator.ON_REVERT, self.equipmentVO.id)
		end, SFX_UI_EQUIPMENT_RESOLVE)
	end
end

function EquipmentInfoLayer:updateOperation1()
	triggerToggle(self.toggles.defaultPanel, true)
	self:updateEquipmentPanel(self.defaultEquipTF, self.equipmentVO)

	local var_30_0 = setActive
	local var_30_1 = self.defaultRevertBtn
	local var_30_2

	if not LOCK_EQUIP_REVERT then
		var_30_2 = self.fromEquipmentView

		if self.fromEquipmentView then
			if self.equipmentVO:getConfig("level") > 1 then
				if getProxy(BagProxy):getItemCountById(Item.REVERT_EQUIPMENT_ID) <= 0 then
					var_30_2 = false

					goto label_30_0
				end
			end

			var_30_2 = true
		end
	end

	::label_30_0::

	var_30_0(var_30_1, var_30_2)
	setActive(self.defaultReplaceBtn, false)
	setActive(self.defaultUnloadBtn, false)
	setActive(self.defaultDestroyBtn, self.contextData.destroy and self.equipmentVO.count > 0)
	self:UpdateTransformTipBar(self.equipmentVO)
end

function EquipmentInfoLayer:updateOperation2()
	triggerToggle(self.toggles.defaultPanel, true)
	self:updateEquipmentPanel(self.defaultEquipTF, self.shipVO:getEquip(self.contextData.pos))
	setActive(self.defaultDestroyBtn, false)
	setActive(self.defaultReplaceBtn, true)
	setActive(self.defaultUnloadBtn, true)
	setActive(self.defaultRevertBtn, false)

	local var_31_0 = self.defaultEquipTF:Find("head")

	setActive(var_31_0, self.shipVO)

	if self.shipVO then
		setImageSprite(findTF(var_31_0, "Image"), LoadSprite("qicon/" .. self.shipVO:getPainting()))
	end

	if self.defaultTransformTipBar then
		setActive(self.defaultTransformTipBar, false)
	end
end

function EquipmentInfoLayer:updateOperation3()
	triggerToggle(self.toggles.replacePanel, true)

	local var_32_0 = self.shipVO:getEquip(self.contextData.pos)

	if var_32_0 then
		local var_32_1 = var_32_0:GetPropertiesInfo()
		local var_32_2 = self.equipmentVO:GetPropertiesInfo()

		if EquipType.getCompareGroup(var_32_0.configId) == EquipType.getCompareGroup(self.equipmentVO.configId) then
			Equipment.InsertAttrsCompare(var_32_1.attrs, var_32_2.attrs, self.shipVO)
		end

		self:updateEquipmentPanel(self.replaceSrcEquipTF, var_32_0, var_32_1)
		self:updateEquipmentPanel(self.replaceDstEquipTF, self.equipmentVO, var_32_2)
	else
		self:updateEquipmentPanel(self.replaceSrcEquipTF, var_32_0)
		self:updateEquipmentPanel(self.replaceDstEquipTF, self.equipmentVO)
	end

	local var_32_3 = self.replaceDstEquipTF:Find("head")

	setActive(var_32_3, self.oldShipVO)

	if self.oldShipVO then
		setImageSprite(findTF(var_32_3, "Image"), LoadSprite("qicon/" .. self.oldShipVO:getPainting()))
	end
end

function EquipmentInfoLayer:updateOperation4()
	triggerToggle(self.toggles.displayPanel, true)
	self:updateEquipmentPanel(self.displayEquipTF, self.equipmentVO)
	setActive(self.displayMoveBtn, self.shipVO)

	local var_33_0 = self.displayEquipTF:Find("head")

	setActive(var_33_0, self.shipVO)

	if self.shipVO then
		setImageSprite(findTF(var_33_0, "Image"), LoadSprite("qicon/" .. self.shipVO:getPainting()))
	end

	self:UpdateTransformTipBar(self.equipmentVO)
end

function EquipmentInfoLayer:updateRevertPanel()
	local var_34_0 = self.equipmentVO:GetRootEquipment()
	local var_34_1 = var_34_0:GetPropertiesInfo()

	Equipment.InsertAttrsCompare(self.equipmentVO:GetPropertiesInfo().attrs, var_34_1.attrs, self.shipVO)
	self:updateEquipmentPanel(self.revertEquipTF, var_34_0, var_34_1, self.equipmentVO:getConfig("level"))
	self:updateOperationAward(self.revertAwardContainer, self.itemTpl, self.equipmentVO:getRevertAwards())
end

function EquipmentInfoLayer:updateDestroyCount()
	setText(self.destroyValue, self.destroyCount)

	local var_35_0 = {}
	local var_35_1 = self.equipmentVO:getConfig("destory_item") or {}
	local var_35_2 = 0 + (self.equipmentVO:getConfig("destory_gold") or 0) * self.destroyCount

	for iter_35_0, iter_35_1 in ipairs(var_35_1) do
		table.insert(var_35_0, {
			type = DROP_TYPE_ITEM,
			id = iter_35_1[1],
			count = iter_35_1[2] * self.destroyCount
		})
	end

	table.insert(var_35_0, {
		id = 1,
		type = DROP_TYPE_RESOURCE,
		count = var_35_2
	})
	self:updateOperationAward(self.destroyBonusList, self.destroyBonusItem, var_35_0)
end

function EquipmentInfoLayer:updateOperationAward(arg_36_1, arg_36_2, arg_36_3)
	self.awards = arg_36_3

	if arg_36_1.childCount == 0 then
		for iter_36_0 = 1, #arg_36_3 do
			cloneTplTo(arg_36_2, arg_36_1)
		end
	end

	for iter_36_1 = 1, #arg_36_3 do
		local var_36_0 = arg_36_1:GetChild(iter_36_1 - 1)
		local var_36_1 = arg_36_3[iter_36_1]

		updateDrop(var_36_0, arg_36_3[iter_36_1])
		onButton(self, var_36_0, function()
			self:emit(EquipmentInfoLayer.ON_DROP, var_36_1)
		end, SFX_PANEL)
		setText(findTF(var_36_0, "name_panel/name"), getText(findTF(var_36_0, "name")))
		setText(findTF(var_36_0, "name_panel/number"), " x " .. getText(findTF(var_36_0, "icon_bg/count")))
		setActive(findTF(var_36_0, "icon_bg/count"), false)
	end
end

function EquipmentInfoLayer:updateEquipmentPanel(arg_38_1, arg_38_2, arg_38_3, arg_38_4)
	local var_38_0 = arg_38_1:Find("info")

	setActive(var_38_0, arg_38_2)
	setActive(arg_38_1:Find("empty"), not arg_38_2)

	if arg_38_2 then
		local var_38_1 = findTF(var_38_0, "name")

		setScrollText(findTF(var_38_1, "mask/Text"), arg_38_2:getConfig("name"))
		setActive(findTF(var_38_1, "unique"), arg_38_2:isUnique() and self.isShowUnique)

		local var_38_2 = findTF(var_38_0, "equip")

		setImageSprite(findTF(var_38_2, "bg"), GetSpriteFromAtlas("ui/equipmentinfoui_atlas", "equip_bg_" .. EquipmentRarity.Rarity2Print(arg_38_2:getConfig("rarity"))))
		updateEquipment(var_38_2, arg_38_2, {
			noIconColorful = true
		})
		setActive(findTF(var_38_2, "revert_btn"), false)
		setActive(findTF(var_38_2, "slv"), arg_38_4 or arg_38_2:getConfig("level") > 1)
		setText(findTF(var_38_2, "slv/Text"), (arg_38_4 or nil) and (arg_38_4 - 1 or arg_38_2:getConfig("level") - 1))
		setActive(findTF(var_38_2, "slv/next"), arg_38_4)
		setText(findTF(var_38_2, "slv/next/Text"), arg_38_2:getConfig("level") - 1)

		local var_38_5 = var_38_2:Find("tier")

		setActive(var_38_5, arg_38_2)

		local var_38_6 = arg_38_2:getConfig("tech") or 1

		eachChild(var_38_5, function(arg_39_0)
			setActive(arg_39_0, tostring(var_38_6) == arg_39_0.gameObject.name)
		end)
		setImageSprite(findTF(var_38_2, "title"), GetSpriteFromAtlas("equiptype", EquipType.type2Tag(arg_38_2:getConfig("type"))))
		setText(var_38_2:Find("speciality/Text"), arg_38_2:getConfig("speciality") ~= "无" and arg_38_2:getConfig("speciality") or i18n1("—"))
		updateEquipInfo(var_38_0:Find("attributes/view/content"), arg_38_3 or arg_38_2:GetPropertiesInfo(), arg_38_2:GetSkill(), self.shipVO)
	end
end

function EquipmentInfoLayer:UpdateTransformTipBar(arg_40_1)
	if not self.defaultTransformTipBar then
		return
	end

	local var_40_0 = pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getData().level, "EquipmentTransformTreeMediator")
	local var_40_1 = EquipmentProxy.GetTransformTargets(Equipment.GetEquipRootStatic(arg_40_1.id))

	setActive(self.defaultTransformTipBar, not LOCK_EQUIPMENT_TRANSFORM and var_40_0 and #var_40_1 > 0)

	if isActive(self.defaultTransformTipBar) then
		local var_40_2 = pg.equip_upgrade_data

		UIItemList.StaticAlign(self.defaultTransformTipBar:Find("list"), self.defaultTransformTipBar:Find("list/transformTarget"), #var_40_1, function(arg_41_0, arg_41_1, arg_41_2)
			if arg_41_0 == UIItemList.EventUpdate then
				setActive(arg_41_2:Find("link"), arg_41_1 > 0)

				local var_41_0 = var_40_2[var_40_1[arg_41_1 + 1]] and var_40_2[var_40_1[arg_41_1 + 1]].target_id

				if not (var_40_2[var_40_1[arg_41_1 + 1]] and var_40_2[var_40_1[arg_41_1 + 1]].target_id) then
					setActive(arg_41_2, false)

					return
				end

				updateDrop(arg_41_2:Find("item"), {
					type = DROP_TYPE_EQUIP,
					id = var_41_0
				})
				onButton(self, arg_41_2:Find("item"), function()
					local var_42_0 = CreateShell(arg_40_1)

					if self.shipVO then
						var_42_0.shipId = self.shipVO.id
						var_42_0.shipPos = self.contextData.pos
					end

					self:emit(EquipmentInfoMediator.OPEN_LAYER, Context.New({
						mediator = EquipmentTransformMediator,
						viewComponent = EquipmentTransformLayer,
						data = {
							fromStoreHouse = true,
							formulaId = var_40_1[arg_41_1 + 1],
							sourceEquipmentInstance = {
								type = DROP_TYPE_EQUIP,
								id = arg_40_1.id,
								template = var_42_0
							}
						}
					}))
				end, SFX_PANEL)
				arg_41_2:Find("mask/name"):GetComponent("ScrollText"):SetText(Equipment.getConfigData(var_41_0).name)
			end
		end)
	end
end

function EquipmentInfoLayer:cloneSampleTo(arg_43_1, arg_43_2, arg_43_3, arg_43_4)
	local var_43_0 = cloneTplTo(self.sample, arg_43_1, arg_43_3)

	var_43_0.localPosition = Vector3.New(EquipmentInfoLayer.pos[arg_43_2][1], EquipmentInfoLayer.pos[arg_43_2][2], EquipmentInfoLayer.pos[arg_43_2][3])

	if arg_43_4 then
		var_43_0:SetSiblingIndex(arg_43_4)
	end

	return var_43_0
end

function EquipmentInfoLayer:willExit()
	self.equipDestroyConfirmWindow:Destroy()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

function EquipmentInfoLayer:onBackPressed()
	if self.equipDestroyConfirmWindow:isShowing() then
		self.equipDestroyConfirmWindow:Hide()

		return
	end

	if isActive(self.destroyPanel) then
		triggerToggle(self.toggles.defaultPanel, true)

		return
	end

	self:closeView()
end

return EquipmentInfoLayer
