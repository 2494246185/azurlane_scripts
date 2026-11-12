local ShanChengPtSkinPage = class("ShanChengPtSkinPage", import("...base.BaseActivityPage"))

function ShanChengPtSkinPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.shop = self.bg:Find("go")
end

function ShanChengPtSkinPage:OnFirstFlush()
	local var_2_0 = getProxy(ActivityProxy):GetShopActivityByRes(Drop.New({
		type = DROP_TYPE_RESOURCE,
		id = self.activity:getConfig("config_client").pt_id
	}))

	onButton(self, self.shop, function()
		local var_3_0 = {
			warp = NewShopsScene.TYPE_ACTIVITY
		}

		var_3_0.actId = var_2_0 and var_2_0.id

		self:emit(ActivityMediator.GO_SHOPS_LAYER, var_3_0)
	end)
end

return ShanChengPtSkinPage
