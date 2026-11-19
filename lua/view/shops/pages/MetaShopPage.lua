local MetaShopPage = class("MetaShopPage", import(".ActivitySelectableShopPage"))

function MetaShopPage:ResId2ItemId(arg_1_1)
	return arg_1_1
end

function MetaShopPage:SetResIcon()
	MetaShopPage.super.SetResIcon(self, DROP_TYPE_ITEM)
end

function MetaShopPage:UpdateTip()
	self.tipText.text = i18n("meta_shop_tip")
end

function MetaShopPage:SetPurchaseConfirmCb(arg_4_1)
	self.purchaseWindow:ExecuteAction("SetConfirmCb", function(arg_5_0, arg_5_1, arg_5_2)
		self:emit(NewShopMainMediator.ON_META_SHOP, self.shop.activityId, 1, arg_5_0, arg_5_2, arg_5_1)
	end)
	self.purchaseWindow:ExecuteAction("Hide")
end

function MetaShopPage:OnUpdatePlayer()
	return
end

function MetaShopPage:OnUpdateItems()
	self:RefreshResItemList()
end

function MetaShopPage:GetResDataList()
	return self.shop:GetResList()
end

function MetaShopPage:RefreshUI()
	self:UpdateTip()
	setActive(self.tipTextGo, true)
	setActive(self.helpBtn, false)
	setActive(self.resolveBtn, false)
	setActive(self.refreshBtn, false)
end

function MetaShopPage:OnPurchase(arg_10_1, arg_10_2)
	self:emit(NewShopMainMediator.ON_META_SHOP, self.shop.activityId, 1, arg_10_1.id, arg_10_2, {
		{
			key = arg_10_1:getConfig("commodity_id"),
			value = arg_10_2
		}
	})
end

function MetaShopPage:GetPaintingName()
	local var_11_0, var_11_1, var_11_2 = MetaShopPage.super.GetPaintingName(self)

	return type(var_11_0) == "table" and var_11_0[math.random(1, #var_11_0)] or var_11_0, var_11_1, var_11_2
end

return MetaShopPage
