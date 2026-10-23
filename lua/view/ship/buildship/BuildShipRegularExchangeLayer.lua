local BuildShipRegularExchangeLayer = class("BuildShipRegularExchangeLayer", import("view.base.BaseUI"))

function BuildShipRegularExchangeLayer:getUIName()
	return "BuildShipRegularExchangeUI"
end

function BuildShipRegularExchangeLayer:getResource()
	local var_2_0 = {
		"regularexchangeicon",
		"shiptype"
	}

	for iter_2_0, iter_2_1 in ipairs(pg.ship_data_create_exchange[REGULAR_BUILD_POOL_EXCHANGE_ID].exchange_ship_id or {}) do
		local var_2_1 = pg.ship_data_statistics[iter_2_1] and pg.ship_skin_template[pg.ship_data_statistics[iter_2_1].skin_id]

		if pg.ship_data_statistics[iter_2_1] and pg.ship_skin_template[pg.ship_data_statistics[iter_2_1].skin_id] and noEmptyStr(var_2_1.painting) then
			table.insertto(var_2_0, ResPathSupport.GetPaintingListByPaintingName(var_2_1.painting))
		end
	end

	return table.insertto(var_2_0, BuildShipRegularExchangeLayer.super.getResource(self))
end

function BuildShipRegularExchangeLayer:preload(arg_3_1)
	self.cfg = pg.ship_data_create_exchange[REGULAR_BUILD_POOL_EXCHANGE_ID]
	self.ids = self.cfg.exchange_ship_id
	self.iconSprites = {}

	AssetBundleHelper.LoadManyAssets("RegularExchangeIcon", underscore.map(self.ids, function(arg_4_0)
		return tostring(arg_4_0)
	end), typeof(Sprite), true, function(arg_5_0)
		for iter_5_0, iter_5_1 in pairs(arg_5_0) do
			self.iconSprites[tonumber(iter_5_0)] = iter_5_1
		end

		existCall(arg_3_1)
	end, true)
end

function BuildShipRegularExchangeLayer:setCount(arg_6_1)
	self.count = arg_6_1

	setText(self.textCount, self.count .. "/" .. self.cfg.exchange_request)
	setGray(self.btnConfirm, self.count < self.cfg.exchange_request)
end

function BuildShipRegularExchangeLayer:init()
	self.btnBack = self._tf:Find("top/bg/btn_back")

	onButton(self, self.btnBack, function()
		self:closeView()
	end, SFX_CANCEL)

	local var_7_0 = self._tf:Find("select/view/container")

	self.iconList = UIItemList.New(var_7_0, var_7_0:Find("tpl"))

	self.iconList:make(function(arg_9_0, arg_9_1, arg_9_2)
		arg_9_1 = arg_9_1 + 1

		if arg_9_0 == UIItemList.EventUpdate then
			local var_9_0 = Ship.New({
				configId = self.ids[arg_9_1]
			})

			setImageSprite(arg_9_2:Find("Image"), self.iconSprites[var_9_0.configId], true)
			setActive(arg_9_2:Find("noget"), not getProxy(CollectionProxy):getShipGroup(var_9_0:getGroupId()))
			onToggle(self, arg_9_2, function(arg_10_0)
				if arg_10_0 then
					self:setSelectedShip(var_9_0)
				end
			end, SFX_PANEL)
			triggerToggle(arg_9_2, arg_9_1 == 1)
		end
	end)
	onButton(self, self._tf:Find("select/operation/help"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("Normalbuild_URexchange_help")
		})
	end, SFX_PANEL)
	setText(self._tf:Find("select/operation/count/Text"), i18n("Normalbuild_URexchange_text2") .. ":")

	self.textCount = self._tf:Find("select/operation/count/num")
	self.btnConfirm = self._tf:Find("select/operation/confirm")

	onButton(self, self.btnConfirm, function()
		if self.count < self.cfg.exchange_request then
			pg.TipsMgr.GetInstance():ShowTips(i18n("Normalbuild_URexchange_warning1"))
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("Normalbuild_URexchange_confirm", self.shipVO:getName()),
				onYes = function()
					self:emit(BuildShipRegularExchangeMediator.EXCHAGNE_SHIP, self.shipVO.configId)
					self:closeView()
				end
			})
		end
	end, SFX_CONFIRM)

	self.rtName = self._tf:Find("select/name_bg")
	self.rtPaint = self._tf:Find("main/paint")

	self:OverlayPanel(self._tf)
end

function BuildShipRegularExchangeLayer:setSelectedShip(arg_14_1)
	if self.shipVO then
		retPaintingPrefab(self.rtPaint, self.shipVO:getPainting())
	end

	self.shipVO = arg_14_1

	GetImageSpriteFromAtlasAsync("shiptype", ShipType.Type2BattlePrint(arg_14_1:getShipType()), self.rtName:Find("shiptype/Image"), true)
	setText(self.rtName:Find("name"), arg_14_1:getName())
	setText(self.rtName:Find("english"), string.upper(arg_14_1:getConfig("english_name")))
	setPaintingPrefabAsync(self.rtPaint, arg_14_1:getPainting(), "huode")
end

function BuildShipRegularExchangeLayer:flush()
	mergeSort(self.ids, CompareFuncs({
		function(arg_16_0)
			return getProxy(CollectionProxy):getShipGroup(Ship.New({
				configId = arg_16_0
			}):getGroupId()) and 1 or 0
		end
	}, true))
	self.iconList:align(#self.ids)
end

function BuildShipRegularExchangeLayer:didEnter()
	self:flush()
end

function BuildShipRegularExchangeLayer:willExit()
	self.iconSprites = nil

	if self.shipVO then
		retPaintingPrefab(self.rtPaint, self.shipVO:getPainting())
	end

	self:UnOverlayPanel(self._tf)
end

return BuildShipRegularExchangeLayer
