local ActivityBanProxy = class("ActivityBanProxy", import(".NetProxy"))

ActivityBanProxy.TYPE = {
	SCENE = 1
}

function ActivityBanProxy:register()
	self:on(11039, function(arg_2_0)
		if arg_2_0.result == 0 then
			self:SetData(arg_2_0.ban_list)
		else
			pg.TipsMgr.GetInstance():ShowTips(ERROR_MESSAGE[arg_2_0.result] .. arg_2_0.result)
		end
	end)
end

function ActivityBanProxy:SetData(arg_3_1)
	self.banList = {}
	self.banMediatorDic = {}

	for iter_3_0, iter_3_1 in ipairs(arg_3_1) do
		table.insert(self.banList, iter_3_1)

		if pg.activity_ban[iter_3_1].type == ActivityBanProxy.TYPE.SCENE then
			local var_3_0 = pg.activity_ban[iter_3_1].mediator
			local var_3_1

			if type(pg.activity_ban[iter_3_1].data) == "table" then
				var_3_1 = pg.activity_ban[iter_3_1].data or {}
				self.banMediatorDic[var_3_0] = self.banMediatorDic[var_3_0] or {}
			end

			table.insert(self.banMediatorDic[var_3_0], var_3_1)
		end
	end
end

function ActivityBanProxy:GetBanMediatorDic()
	return self.banMediatorDic or {}
end

function ActivityBanProxy:GetBanList()
	return self.banList or {}
end

function ActivityBanProxy:IsBan()
	return table.contains(getProxy(ActivityBanProxy):GetBanList(), self)
end

return ActivityBanProxy
