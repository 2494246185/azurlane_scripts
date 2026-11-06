local ChargeActGiftLayer = class("ChargeActGiftLayer", import("view.base.BaseUI"))

function ChargeActGiftLayer:getUIName()
	return "ChargeIActGiftUI"
end

function ChargeActGiftLayer:preload(arg_2_1)
	local var_2_0 = getProxy(ActivityProxy):getActivityById(self.contextData.actId)
	local var_2_1 = {}

	if var_2_0 and not var_2_0:isEnd() then
		self.spriteDic = {
			name = {},
			icon = {}
		}

		for iter_2_0, iter_2_1 in ipairs(var_2_0:getConfig("config_data")[1]) do
			table.insert(var_2_1, function(arg_3_0)
				LoadSpriteAtlasAsync("actgiftpackages/skin_card_name_" .. iter_2_1, "", function(arg_4_0)
					self.spriteDic.name[iter_2_1] = arg_4_0

					arg_3_0()
				end)
			end)
			table.insert(var_2_1, function(arg_5_0)
				LoadSpriteAtlasAsync("actgiftpackages/skin_card_" .. iter_2_1, "", function(arg_6_0)
					self.spriteDic.icon[iter_2_1] = arg_6_0

					arg_5_0()
				end)
			end)
		end
	end

	parallelAsync(var_2_1, arg_2_1)
end

function ChargeActGiftLayer:getResource()
	local var_7_0 = ChargeActGiftLayer.super.getResource(self)
	local var_7_1 = {}

	local function var_7_2(arg_8_0)
		if noEmptyStr(arg_8_0) and not table.contains(var_7_1, arg_8_0) then
			table.insert(var_7_1, arg_8_0)
		end
	end

	local var_7_3 = getProxy(ActivityProxy):getActivityById(self.contextData.actId)

	if var_7_3 and not var_7_3:isEnd() then
		for iter_7_0, iter_7_1 in ipairs(var_7_3:getConfig("config_data")[1] or {}) do
			var_7_2("actgiftpackages/skin_card_name_" .. iter_7_1)
			var_7_2("actgiftpackages/skin_card_" .. iter_7_1)
		end
	end

	for iter_7_2, iter_7_3 in ipairs(var_7_1) do
		if not table.contains(var_7_0, iter_7_3) then
			table.insert(var_7_0, iter_7_3)
		end
	end

	return var_7_0
end

function ChargeActGiftLayer:init()
	setText(self.rtTip:Find("Text"), i18n("black5_bundle_desc"))
	setText(self.rtAward:Find("word/Text"), i18n("black5_bundle_tip"))
	setText(self.btnPay:Find("Text"), i18n("black5_bundle_buy_all"))
	setText(self.btnGet:Find("Text"), i18n("black5_bundle_receive"))
	self:BlurPanel(self._tf)
end

function ChargeActGiftLayer:didEnter()
	onButton(self, self.rtBg, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.rtTip, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("black5_bundle_help")
		})
	end, SFX_PANEL)

	local var_10_0 = getProxy(ActivityProxy):getActivityById(self.contextData.actId)
	local var_10_1 = var_10_0:getConfig("config_data")[1]

	UIItemList.StaticAlign(self.rtContainer, self.rtSkinTpl, #var_10_1, function(arg_13_0, arg_13_1, arg_13_2)
		arg_13_1 = arg_13_1 + 1

		if arg_13_0 == UIItemList.EventUpdate then
			local var_13_0 = var_10_1[arg_13_1]

			setImageSprite(arg_13_2:Find("name"), self.spriteDic.name[var_10_1[arg_13_1]])
			setImageSprite(arg_13_2, self.spriteDic.icon[var_10_1[arg_13_1]])

			local var_13_1 = getProxy(ShipSkinProxy):hasNonLimitSkin(var_10_1[arg_13_1])

			setActive(arg_13_2:Find("btn_skin"), not var_13_1)
			setActive(arg_13_2:Find("got"), var_13_1)

			if var_13_1 then
				setText(arg_13_2:Find("got/Text"), i18n("black5_bundle_purchased"))
			else
				setText(arg_13_2:Find("btn_skin/price/Text"), (Goods.Create({
					id = pg.ship_skin_template[var_10_1[arg_13_1]].shop_id
				}, Goods.TYPE_SKIN):getConfig("resource_num")))
				onButton(self, arg_13_2:Find("btn_skin"), function()
					self:emit(ChargeActGiftMediator.GO_SHOP, var_13_0)
				end, SFX_PANEL)
			end
		end
	end)

	local var_10_2 = Drop.Create(var_10_0:GetConfigClientSetting("drop"))

	updateDrop(self.rtAward:Find("icon/bg/IconTpl"), var_10_2)
	onButton(self, self.rtAward:Find("icon"), function()
		self:emit(BaseUI.ON_DROP, var_10_2)
	end, SFX_PANEL)

	local var_10_3, var_10_4, var_10_5 = GiftActCommodity.CalcPrice(var_10_0)

	setActive(self.rtAward:Find("word"), var_10_3 > 0)
	setActive(self.btnPay, var_10_3 > 0)
	setActive(self.btnGet, var_10_3 == 0)

	if var_10_3 > 0 then
		setActive(self.btnPay:Find("price/old"), var_10_3 < var_10_5)
		setText(self.btnPay:Find("price/old"), string.format("<material=strike>%d</material>", var_10_5))
		setText(self.btnPay:Find("price/price"), var_10_3)
		onButton(self, self.btnPay, function()
			local var_16_0 = Drop.New({
				type = DROP_TYPE_RESOURCE,
				id = PlayerConst.ResDiamond,
				count = var_10_3
			})

			if var_16_0.count > var_16_0:getOwnedCount() then
				pg.TipsMgr.GetInstance():ShowTips(i18n("temple_consume_not_enough"))

				return
			end

			local var_16_1 = Goods.Create({
				shop_id = var_10_0:GetConfigClientSetting("packageID")
			}, Goods.TYPE_GIFT_PACKAGE_ACT)

			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("black5_bundle_popup", var_16_0.count, var_16_1:GetName()),
				onYes = function()
					self:emit(ChargeActGiftMediator.DO_PAY)
				end
			})
		end, SFX_CONFIRM)
	else
		onButton(self, self.btnGet, function()
			self:emit(ChargeActGiftMediator.DO_PAY)
		end, SFX_CONFIRM)
	end
end

function ChargeActGiftLayer:willExit()
	self:UnOverlayPanel(self._tf)
end

return ChargeActGiftLayer
