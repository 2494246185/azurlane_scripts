local FormationSuggestionShipEquipPanel = class("FormationSuggestionShipEquipPanel", import("view.base.BasePanel"))

function FormationSuggestionShipEquipPanel:Ctor(arg_1_1, arg_1_2, arg_1_3)
	self._go = arg_1_1.gameObject

	FormationSuggestionShipEquipPanel.super.Ctor(self, self._go)

	self._parentClass = arg_1_2

	self:attach(arg_1_2)
	self:Init()
end

function FormationSuggestionShipEquipPanel:Init()
	setText(self.uiCopyText, i18n("formation_suggestion_info_equip_copy"))
	setScrollText(self.uiSpUnownedText, i18n("equipcode_equipment_unowned"))
	onButton(self, self.uiCopyBtn, function()
		local var_3_0 = {}

		for iter_3_0, iter_3_1 in ipairs(self.equipDataList[1]) do
			table.insert(var_3_0, Equipment.New({
				id = iter_3_1[1],
				config_id = iter_3_1[1] + iter_3_1[2],
				skinId = iter_3_1[1]
			}))
		end

		UniPasteBoard.SetClipBoardString((buildEquipAndSpCode(var_3_0, (SpWeapon.New({
			id = self.equipDataList[2][1][1] + self.equipDataList[2][1][2]
		})))))
		pg.TipsMgr.GetInstance():ShowTips(i18n("equipcode_export_success"))
	end, SFX_PANEL)

	self.equipItemList = UIItemList.New(self.uiEquipParent, self.uiEquipItem)
end

function FormationSuggestionShipEquipPanel:SetData(arg_4_1)
	self.equipDataList = arg_4_1

	local var_4_0 = arg_4_1[1]

	self.equipItemList:make(function(arg_5_0, arg_5_1, arg_5_2)
		if arg_5_0 == UIItemList.EventUpdate then
			local var_5_0 = EquipmentTools.HasEquipByGroup(pg.equip_data_template[var_4_0[arg_5_1 + 1][1]].group)
			local var_5_1

			if var_5_0 then
				var_5_1 = var_4_0[arg_5_1 + 1][1] + var_4_0[arg_5_1 + 1][2] or var_4_0[arg_5_1 + 1][1]
			end

			updateEquipment(arg_5_2, (Equipment.New({
				id = var_5_1,
				config_id = var_5_1,
				skinId = var_5_1
			})))
			setActive(findTF(arg_5_2, "unOwned"), not var_5_0)
			setScrollText(findTF(arg_5_2, "unOwned/Text"), i18n("equipcode_equipment_unowned"))
			onButton(self, arg_5_2, function()
				self:emit(BaseUI.ON_ADD_SUBLAYER, Context.New({
					mediator = EquipmentInfoMediator,
					viewComponent = EquipmentInfoLayer,
					data = {
						equipmentId = var_5_1,
						type = EquipmentInfoMediator.TYPE_DISPLAY
					}
				}))
			end)
		end
	end)
	self.equipItemList:align(#arg_4_1[1])

	local var_4_1 = EquipmentTools.HasBaseSpWeapon(arg_4_1[2][1][1])
	local var_4_2

	if var_4_1 then
		var_4_2 = arg_4_1[2][1][1] + arg_4_1[2][1][2] or arg_4_1[2][1][1]
	end

	UpdateSpWeaponSlot(self.uiSpTf, (SpWeapon.New({
		id = var_4_2
	})))
	setActive(self.uiSpUnownedGo, not var_4_1)
	onButton(self, self.uiSpTf, function()
		self:emit(BaseUI.ON_ADD_SUBLAYER, Context.New({
			mediator = SpWeaponInfoMediator,
			viewComponent = SpWeaponInfoLayer,
			data = {
				spWeaponConfigId = var_4_2,
				type = SpWeaponInfoLayer.TYPE_DISPLAY
			}
		}))
	end)
end

function FormationSuggestionShipEquipPanel:willExit()
	self.equipItemList:Dispose()
	self:detach()
end

return FormationSuggestionShipEquipPanel
