local AssignedShipForBuildURScene = class("AssignedShipForBuildURScene", import("view.base.BaseUI"))

function AssignedShipForBuildURScene:getUIName()
	return "AssignedShipBuildURUI"
end

function AssignedShipForBuildURScene:setItemVO(arg_2_1)
	self.itemVO = arg_2_1
end

function AssignedShipForBuildURScene:preload(arg_3_1)
	self.shipUsageDic = {}
	self.ids = underscore.map(self.contextData.itemVO:getConfig("usage_arg"), function(arg_4_0)
		self.shipUsageDic[pg.item_usage_invitation[arg_4_0].ship_id] = arg_4_0

		return pg.item_usage_invitation[arg_4_0].ship_id
	end)
	self.iconSprites = {}

	local var_3_0 = {}

	for iter_3_0, iter_3_1 in ipairs(self.ids) do
		table.insert(var_3_0, function(arg_5_0)
			GetSpriteFromAtlasAsync("RegularExchangeIcon", tostring(iter_3_1), function(arg_6_0)
				self.iconSprites[iter_3_1] = arg_6_0

				arg_5_0()
			end)
		end)
	end

	seriesAsync(var_3_0, arg_3_1)
end

function AssignedShipForBuildURScene:getResource()
	local var_7_0 = AssignedShipForBuildURScene.super.getResource(self)
	local var_7_1 = {
		"RegularExchangeIcon"
	}
	local var_7_2 = self.contextData.itemVO or self.itemVO

	if var_7_2 then
		for iter_7_0, iter_7_1 in ipairs(var_7_2:getConfig("usage_arg")) do
			local var_7_3 = Ship.New({
				configId = pg.item_usage_invitation[iter_7_1].ship_id
			}):getPainting()

			if noEmptyStr(var_7_3) then
				table.insert(var_7_1, "painting/" .. var_7_3)
			end
		end
	end

	for iter_7_2, iter_7_3 in ipairs(var_7_1) do
		if not table.contains(var_7_0, iter_7_3) then
			table.insert(var_7_0, iter_7_3)
		end
	end

	return var_7_0
end

function AssignedShipForBuildURScene:init()
	self.backBtn = self._tf:Find("top/bg/btn_back")

	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)

	local var_8_0 = self._tf:Find("select/view/container")

	self.iconList = UIItemList.New(var_8_0, var_8_0:Find("tpl"))

	self.iconList:make(function(arg_10_0, arg_10_1, arg_10_2)
		arg_10_1 = arg_10_1 + 1

		if arg_10_0 == UIItemList.EventUpdate then
			local var_10_0 = Ship.New({
				configId = self.ids[arg_10_1]
			})

			setImageSprite(arg_10_2:Find("Image"), self.iconSprites[var_10_0.configId], true)
			setActive(arg_10_2:Find("noget"), not getProxy(CollectionProxy):getShipGroup(var_10_0:getGroupId()))
			onToggle(self, arg_10_2, function(arg_11_0)
				if arg_11_0 then
					self:setSelectedShip(var_10_0)
				end
			end, SFX_PANEL)
			triggerToggle(arg_10_2, arg_10_1 == 1)
		end
	end)

	self.btnConfirm = self._tf:Find("select/operation/confirm")

	onButton(self, self.btnConfirm, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("handbook_ur_double_check", self.shipVO:getName()),
			onYes = function()
				self:emit(AssignedShipMediator.ON_USE_ITEM, self.itemVO.id, 1, {
					self.shipUsageDic[self.shipVO:GetConfigID()]
				})
			end
		})
	end, SFX_CONFIRM)

	self.rtName = self._tf:Find("select/name_bg")
	self.rtPaint = self._tf:Find("main/paint")
end

function AssignedShipForBuildURScene:setSelectedShip(arg_14_1)
	if self.shipVO then
		retPaintingPrefab(self.rtPaint, self.shipVO:getPainting())
	end

	self.shipVO = arg_14_1

	GetImageSpriteFromAtlasAsync("shiptype", ShipType.Type2BattlePrint(arg_14_1:getShipType()), self.rtName:Find("shiptype/Image"), true)
	setText(self.rtName:Find("name"), arg_14_1:getName())
	setText(self.rtName:Find("english"), string.upper(arg_14_1:getConfig("english_name")))
	setPaintingPrefabAsync(self.rtPaint, arg_14_1:getPainting(), "huode")
end

function AssignedShipForBuildURScene:flush()
	self.iconList:align(#self.ids)
end

function AssignedShipForBuildURScene:didEnter()
	self:flush()
end

function AssignedShipForBuildURScene:willExit()
	self.iconSprites = nil

	if self.shipVO then
		retPaintingPrefab(self.rtPaint, self.shipVO:getPainting())
	end
end

return AssignedShipForBuildURScene
