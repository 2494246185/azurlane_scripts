local WindFogCorridorCollectPage = class("WindFogCorridorCollectPage", import("view.activity.CorePage.DOA.DOACoreActivityCollectPage"))

function WindFogCorridorCollectPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.btnList = self.bg:Find("btn_list")
	self.itemPanel = self.bg:Find("item_panel")
	self.togglesTF = self.itemPanel:Find("toggles")
	self.content = self.itemPanel:Find("item_list/content")
	self.itemList = UIItemList.New(self.content, self.content:Find("tpl"))
	self.msgBox = WindFogCorridorCollectMsgBox.New(self._tf, self.event)
end

function WindFogCorridorCollectPage:GetTogglesDropTypes()
	return {
		DROP_TYPE_SHIP,
		{
			DROP_TYPE_FURNITURE,
			DROP_TYPE_RESOURCE,
			DROP_TYPE_ICON_FRAME,
			DROP_TYPE_COMMANDER_CAT,
			DROP_TYPE_EQUIP
		},
		{
			DROP_TYPE_EQUIPMENT_SKIN
		}
	}
end

function WindFogCorridorCollectPage:IsShowingPopWindow()
	return self.msgBox and self.msgBox:isShowing() or false
end

function WindFogCorridorCollectPage:ClosePopWindow()
	if self.msgBox and self.msgBox:isShowing() then
		self.msgBox:Hide()
	end
end

function WindFogCorridorCollectPage:OnUpdateItem(arg_5_1, arg_5_2)
	local var_5_0 = self.showDataList[arg_5_1 + 1]
	local var_5_1 = arg_5_2:Find("icon_mask/icon")
	local var_5_2 = {
		type = self.showDataList[arg_5_1 + 1].config.type,
		id = self.showDataList[arg_5_1 + 1].config.drop_id
	}

	updateDrop(var_5_1, var_5_2)
	onButton(self, var_5_1, function()
		self:OnClickItem(var_5_0)
	end, SFX_PANEL)
	changeToScrollText(arg_5_2:Find("name_mask/mask/name"), Drop.New({
		type = var_5_0.config.type,
		id = var_5_0.config.drop_id
	}):getName())

	local var_5_3 = var_5_0.count > 0 and var_5_0.count >= var_5_0.config.count
	local var_5_4 = GetOrAddComponent(arg_5_2:Find("owner"), typeof(CanvasGroup))

	if var_5_2.type == 4 then
		var_5_0.count = #getProxy(BayProxy):findShipsByGroup((Ship.getGroupIdByConfigId(var_5_0.config.drop_id)))
		var_5_3 = var_5_0.count >= 1
	end

	self:RefreshCountText(var_5_0, arg_5_2)

	var_5_4.alpha = var_5_3 and 0.5 or 1

	setActive(arg_5_2:Find("got"), var_5_3)
	setActive(arg_5_2:Find("new"), var_5_0.config.is_new == "1")
end

return WindFogCorridorCollectPage
