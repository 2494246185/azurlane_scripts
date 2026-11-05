local ChargeCommodity = class("ChargeCommodity", import(".BaseCommodity"))

function ChargeCommodity:bindConfigTable()
	return pg.pay_data_display
end

function ChargeCommodity:isChargeType()
	return true
end

function ChargeCommodity:canPurchase()
	local var_3_0 = self:getLimitCount()

	return var_3_0 <= 0 or var_3_0 > self.buyCount
end

function ChargeCommodity:firstPayDouble()
	return self:getConfig("first_pay_double") ~= 0
end

function ChargeCommodity:hasExtraGem()
	return self:getConfig("extra_gem") ~= 0
end

function ChargeCommodity:GetGemCnt()
	return self:getConfig("gem") + self:getConfig("extra_gem")
end

function ChargeCommodity:isGem()
	return self:getConfig("extra_service") == Goods.GEM
end

function ChargeCommodity:isGiftBox()
	return self:getConfig("extra_service") == Goods.GIFT_BOX
end

function ChargeCommodity:isMonthCard()
	return self:getConfig("extra_service") == Goods.MONTH_CARD
end

function ChargeCommodity:isItemBox()
	return self:getConfig("extra_service") == Goods.ITEM_BOX
end

function ChargeCommodity:isPassItem()
	return self:getConfig("extra_service") == Goods.PASS_ITEM
end

function ChargeCommodity:getLimitCount()
	return self:getConfig("limit_arg")
end

function ChargeCommodity:GetName()
	return self:getConfig("name")
end

function ChargeCommodity:GetDropList()
	local var_14_0 = self:getConfig("display")

	if #var_14_0 == 0 then
		var_14_0 = self:getConfig("extra_service_item")
	end

	local var_14_1 = {}

	for iter_14_0, iter_14_1 in ipairs(var_14_0) do
		table.insert(var_14_1, Drop.Create(iter_14_1))
	end

	return var_14_1
end

function ChargeCommodity:GetExtraServiceItem()
	local var_15_0

	if self:isPassItem() then
		local var_15_1, var_15_2, var_15_3 = self:GetActData()

		if var_15_3 == 130 then
			var_15_0 = PlayerConst.MergePassItemDrop(underscore.map(pg.black_friday_battlepass_event_pt[var_15_1].award_pay, function(arg_16_0)
				return Drop.Create(pg.black_friday_battlepass_event_award[arg_16_0].drop_client)
			end))
		elseif var_15_3 == 54 then
			var_15_0 = PlayerConst.MergePassItemDrop(underscore.map(pg.battlepass_event_pt[var_15_1].award_pay, function(arg_17_0)
				return Drop.Create(pg.battlepass_event_award[arg_17_0].drop_client)
			end))
		end
	else
		var_15_0 = underscore.map(self:getConfig("extra_service_item"), function(arg_18_0)
			return Drop.Create(arg_18_0)
		end)
	end

	local var_15_5 = self:GetGemCnt()

	if not self:isMonthCard() and var_15_5 > 0 then
		table.insert(var_15_0, Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = PlayerConst.ResDiamond,
			count = var_15_5
		}))
	end

	return var_15_0
end

function ChargeCommodity:GetBonusItem()
	if self:isMonthCard() then
		return Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = PlayerConst.ResDiamond,
			count = self:GetGemCnt()
		})
	end

	return nil
end

function ChargeCommodity:GetChargeTip()
	local var_20_0
	local var_20_1

	if self:isPassItem() then
		var_20_0 = i18n("battlepass_pay_tip")
	elseif self:isMonthCard() then
		var_20_0 = i18n("charge_title_getitem_month")
		var_20_1 = i18n("charge_title_getitem_soon")
	else
		var_20_0 = i18n("charge_title_getitem")
	end

	return var_20_0, var_20_1
end

function ChargeCommodity:GetActData()
	local var_21_0, var_21_1 = unpack(self:getConfig("sub_display"))
	local var_21_2 = getProxy(ActivityProxy):getActivityById(var_21_0)
	local var_21_3

	if not var_21_2 or var_21_2:isEnd() then
		local var_21_4, var_21_5 = PrevPeriodCrusingActivity.StaticExistPrevPeriodCrusingActivity()

		if var_21_4 then
			local var_21_6 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING):GetPreviousPeriodAct()

			var_21_0 = var_21_6.id

			if var_21_6 and not var_21_6:isEnd() then
				var_21_3 = var_21_6:getConfig("type")
			end
		end
	else
		var_21_3 = var_21_2:getConfig("type")
	end

	return var_21_0, var_21_1, var_21_3
end

function ChargeCommodity:GetExtraDrop()
	local var_22_0

	if self:isPassItem() then
		local var_22_1, var_22_2, var_22_3 = self:GetActData()

		assert(var_22_3, "activity type is nil")

		if var_22_3 == 130 then
			var_22_0 = Drop.New({
				type = DROP_TYPE_VITEM,
				id = pg.black_friday_battlepass_event_pt[var_22_1].pt,
				count = var_22_2
			})
		elseif var_22_3 == 54 then
			var_22_0 = Drop.New({
				type = DROP_TYPE_VITEM,
				id = pg.battlepass_event_pt[var_22_1].pt,
				count = var_22_2
			})
		end
	end

	return var_22_0
end

function ChargeCommodity:getConfig(arg_23_1)
	if arg_23_1 == "money" and PLATFORM_CODE == PLATFORM_CHT then
		local var_23_0 = pg.SdkMgr.GetInstance():GetProduct(self:getConfig("id_str"))

		if var_23_0 then
			return var_23_0.price
		else
			return self:RawGetConfig(arg_23_1)
		end
	elseif arg_23_1 == "money" and PLATFORM_CODE == PLATFORM_US then
		local var_23_1 = self:RawGetConfig(arg_23_1)

		return math.floor(var_23_1 / 100) .. "." .. var_23_1 - math.floor(var_23_1 / 100) * 100
	else
		return self:RawGetConfig(arg_23_1)
	end
end

function ChargeCommodity:RawGetConfig(arg_24_1)
	return ChargeCommodity.super.getConfig(self, arg_24_1)
end

function ChargeCommodity:IsLocalPrice()
	return self:getConfig("money") ~= self:RawGetConfig("money")
end

function ChargeCommodity:isLevelLimit(arg_26_1, arg_26_2)
	local var_26_0, var_26_1 = self:getLevelLimit()

	if arg_26_2 and var_26_1 then
		return false
	end

	return var_26_0 > 0 and arg_26_1 < var_26_0
end

function ChargeCommodity:getLevelLimit()
	for iter_27_0, iter_27_1 in ipairs((self:getConfig("limit_args"))) do
		if type(iter_27_1) == "table" and iter_27_1[1] == "level" then
			return iter_27_1[2], iter_27_1[3]
		end
	end

	return 0
end

function ChargeCommodity:getSameLimitGroupTecGoods()
	local var_28_0 = {}
	local var_28_1 = self:getConfig("limit_group")
	local var_28_2 = self:bindConfigTable()

	for iter_28_0, iter_28_1 in ipairs(var_28_2.all) do
		if var_28_2[iter_28_1].limit_group == var_28_1 then
			table.insert(var_28_0, (Goods.Create({
				shop_id = iter_28_1
			}, Goods.TYPE_CHARGE)))
		end
	end

	return var_28_0
end

function ChargeCommodity:getShowType()
	local var_29_0 = self:getConfig("show_group")

	if var_29_0 == "" then
		-- block empty
	end

	return var_29_0
end

function ChargeCommodity:CanViewSkinProbability()
	local var_30_0 = self:getConfig("skin_inquire_relation")

	if not var_30_0 or var_30_0 <= 0 then
		return false
	end

	if pg.gameset.package_view_display.key_value == 0 then
		return false
	end

	return true
end

function ChargeCommodity:GetSkinProbability()
	return (self:CanViewSkinProbability() or nil) and Item.getConfigData((self:getConfig("skin_inquire_relation"))).combination_display
end

function ChargeCommodity:GetSkinProbabilityItem()
	local var_32_0

	if not self:CanViewSkinProbability() then
		do return nil end

		var_32_0 = {
			count = 1,
			type = DROP_TYPE_ITEM
		}
	end

	var_32_0.id = self:getConfig("skin_inquire_relation")

	return var_32_0
end

function ChargeCommodity:GetDropItem()
	local var_33_0 = self:getConfig("drop_item")

	if #var_33_0 > 0 then
		return var_33_0
	else
		assert(false, "should exist drop item")
	end
end

function ChargeCommodity:GetLimitDesc()
	local var_34_0 = self:getLimitCount()

	if var_34_0 > 0 then
		return i18n("charge_limit_all", var_34_0 - (self.buyCount or 0), var_34_0)
	end

	local var_34_1 = self:getConfig("group_limit")

	if var_34_1 > 0 then
		local var_34_2 = self:getConfig("group_type") or 0

		if var_34_2 == 1 then
			return i18n("charge_limit_daily", var_34_1 - self.groupCount, var_34_1)
		elseif var_34_2 == 2 then
			return i18n("charge_limit_weekly", var_34_1 - self.groupCount, var_34_1)
		elseif var_34_2 == 3 then
			return i18n("charge_limit_monthly", var_34_1 - self.groupCount, var_34_1)
		end
	end

	return ""
end

function ChargeCommodity:GetInfoTip()
	if not self:isItemBox() or self:getConfig("tip_open") == 0 then
		return ""
	else
		return self:getConfig("tip")
	end
end

function ChargeCommodity:GetPackageTag()
	if not self:isItemBox() or self:getConfig("package_tag_open") == 0 then
		return ""
	else
		return self:getConfig("package_tag")
	end
end

function ChargeCommodity:isTip()
	if self:isGiftPackage() or self:isActGiftPackage() then
		local var_37_0 = self:getConfig("akashi_pick") > 0 and "payshop_pack_red_dot" or "gemshop_pack_red_dot"
		local var_37_1, var_37_2 = unpack(getGameset(var_37_0))

		if PlayerPrefs.GetInt(var_37_0, 0) ~= var_37_1 and table.contains(var_37_2[1], self.id) then
			return true
		end

		return self:isFree()
	end
end

function ChargeCommodity:isTip()
	local var_38_0 = self:getConfig("akashi_pick") > 0 and "payshop_pack_red_dot" or "gemshop_pack_red_dot"
	local var_38_1, var_38_2 = unpack(getGameset(var_38_0))

	if PlayerPrefs.GetInt(var_38_0, 0) ~= var_38_1 and table.contains(var_38_2[2], self.id) then
		return true
	end

	return self:isFree()
end

return ChargeCommodity
