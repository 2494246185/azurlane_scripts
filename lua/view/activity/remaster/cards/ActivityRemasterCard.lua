local ActivityRemasterCard = class("ActivityRemasterCard")

function ActivityRemasterCard:Ctor(arg_1_1)
	self._go = arg_1_1
	self._tf = arg_1_1.transform
	self.doingTr = self._tf:Find("doing")
	self.finishTr = self._tf:Find("finish")
	self.finishTagTr = self._tf:Find("finish_tag")
	self.ico = self._tf:Find("border/ico"):GetComponent(typeof(Image))
	self.title = self._tf:Find("border/title"):GetComponent(typeof(Image))
	self.modelTxt = self._tf:Find("border/model"):GetComponent(typeof(Text))
	self.furTxt = self._tf:Find("border/fur"):GetComponent(typeof(Text))
	self.finishToggle = self._tf:Find("finish_toggle")
	self.uiShipList = UIItemList.New(self._tf:Find("border/ships"), self._tf:Find("border/ships/tpl"))

	setText(self._tf:Find("border/label"), i18n("act_remaster_colllect_progress"))
end

function ActivityRemasterCard:Update(arg_2_1)
	self.remasterData = arg_2_1

	self:UpdateStyle(arg_2_1)
	self:UpdateProgress(arg_2_1)
	self:UpdateShips(arg_2_1)
end

function ActivityRemasterCard:UpdateStyle(arg_3_1)
	local var_3_0 = arg_3_1:GetBanner()

	self.ico.sprite = GetSpriteFromAtlas("ActivityRemaster/" .. var_3_0, "banner")
	self.title.sprite = GetSpriteFromAtlas("ActivityRemaster/" .. var_3_0, "title")

	triggerToggle(self.finishToggle, (arg_3_1:IsFinish()))
end

function ActivityRemasterCard:UpdateProgress(arg_4_1)
	self.modelTxt.text = arg_4_1:GetShipProgress() .. "/" .. arg_4_1:GetShipTotalCnt()
	self.furTxt.text = arg_4_1:GetFurnitureProgress() .. "/" .. arg_4_1:GetFurnitureTotalCnt()
end

function ActivityRemasterCard:UpdateShips(arg_5_1)
	local var_5_0 = arg_5_1:GetCollectableShipIdList()

	self.uiShipList:make(function(arg_6_0, arg_6_1, arg_6_2)
		if arg_6_0 == UIItemList.EventUpdate then
			local var_6_0 = pg.ship_skin_template[ShipGroup.getDefaultShipConfig(var_5_0[arg_6_1 + 1]).skin_id]

			GetImageSpriteFromAtlasAsync("shipYardIcon/" .. var_6_0.painting, var_6_0.painting, arg_6_2:Find("ico"))
			setActive(arg_6_2:Find("mask"), (getProxy(CollectionProxy):getShipGroup(var_5_0[arg_6_1 + 1])))
		end
	end)
	self.uiShipList:align(#var_5_0)
end

function ActivityRemasterCard:Dispose()
	return
end

return ActivityRemasterCard
