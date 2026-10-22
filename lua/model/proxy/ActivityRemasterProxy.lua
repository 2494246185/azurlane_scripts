local ActivityRemasterProxy = class("ActivityRemasterProxy", import("model.proxy.NetProxy"))

function ActivityRemasterProxy:register()
	self.actTimeID = 0
	self.activeActID = 0
	self.remasterActList = {}

	for iter_1_0, iter_1_1 in ipairs(pg.activity_re.all) do
		self.remasterActList[iter_1_1] = ActivityRemasterData.New({
			id = iter_1_1
		})
	end

	self:on(11213, function(arg_2_0)
		self.actTimeID = arg_2_0.activity_re_timer_id
		self.activeActID = arg_2_0.activity_re_id

		for iter_2_0, iter_2_1 in ipairs(arg_2_0.finish_re_id) do
			self:SetRemasterDataFinish(iter_2_1)
		end
	end)
end

function ActivityRemasterProxy:CanActiveRemaster(arg_3_1)
	local var_3_0 = self:GetReamsterData(arg_3_1)

	if not var_3_0 then
		return false
	end

	if var_3_0:IsSpecial() then
		return true
	end

	if var_3_0:IsFinish() then
		return false
	end

	return true
end

function ActivityRemasterProxy:ActiveActivity(arg_4_1, arg_4_2)
	self.activeActID = arg_4_1
	self.actTimeID = arg_4_2

	self:SetRemasterDataFinish(arg_4_1)
end

function ActivityRemasterProxy:SetRemasterDataFinish(arg_5_1)
	local var_5_0 = self:GetReamsterData(arg_5_1)

	if var_5_0 then
		var_5_0:MarkFinish()
	end
end

function ActivityRemasterProxy:GetActivaingReamsterData()
	return self:GetReamsterData(self.activeActID)
end

function ActivityRemasterProxy:GetRemasterActList()
	return self.remasterActList
end

function ActivityRemasterProxy:GetReamsterData(arg_8_1)
	return self.remasterActList[arg_8_1]
end

function ActivityRemasterProxy:InActTime()
	for iter_9_0, iter_9_1 in ipairs(pg.activity_re_timer.all) do
		if pg.TimeMgr.GetInstance():inTime(pg.activity_re_timer[iter_9_1].timer) then
			return true, iter_9_1
		end
	end

	return false, self.actTimeID
end

function ActivityRemasterProxy:GetActiveActID()
	return self.activeActID
end

function ActivityRemasterProxy:IsActivating()
	if not self.activeActID or self.activeActID == 0 then
		return false
	end

	if not self.actTimeID or self.actTimeID == 0 then
		return false
	end

	local var_11_0 = pg.activity_re_timer[self.actTimeID]

	if not pg.activity_re_timer[self.actTimeID] then
		return false
	end

	return (pg.TimeMgr.GetInstance():inTime(var_11_0.timer))
end

function ActivityRemasterProxy:IsShowTime()
	if not self.activeActID or self.activeActID == 0 then
		return false
	end

	if not self.actTimeID or self.actTimeID == 0 then
		return false
	end

	local var_12_0 = self:GetReamsterData(self.activeActID)
	local var_12_1 = getProxy(ActivityProxy)
	local var_12_2 = 0

	for iter_12_0, iter_12_1 in ipairs((var_12_0:GetActList())) do
		local var_12_3 = var_12_1:RawGetActivityById(iter_12_1)

		if var_12_3 and var_12_2 < var_12_3.stopTime then
			var_12_2 = var_12_3.stopTime
		end
	end

	if var_12_2 <= 0 then
		return false
	end

	return var_12_2 > pg.TimeMgr.GetInstance():GetServerTime()
end

function ActivityRemasterProxy:ShouldShowActiveBtn()
	local var_13_0 = getProxy(ActivityRemasterProxy):InActTime()

	if var_13_0 then
		var_13_0 = not getProxy(ActivityRemasterProxy):IsActivating()
	end

	return var_13_0
end

function ActivityRemasterProxy:GetBanners()
	if not self:IsActivating() then
		return {}
	end

	local var_14_0 = pg.activity_re[self.activeActID]

	if not pg.activity_re[self.activeActID] then
		return {}
	end

	local var_14_1 = {}

	for iter_14_0, iter_14_1 in ipairs(var_14_0.act_time or {}) do
		local var_14_4 = iter_14_1[3] or 0

		if var_14_4 > 0 then
			table.insert(var_14_1, var_14_4)
		end
	end

	return var_14_1
end

function ActivityRemasterProxy:GetShopBanner()
	if not self:ExistShopBanner() then
		return nil
	end

	local var_15_0 = Clone(pg.shop_banner_template[pg.shop_banner_template.all[#pg.shop_banner_template.all]])

	var_15_0.pic = "shopbanner_remaster/" .. self.activeActID
	var_15_0.param = {
		"scene shop",
		{
			warp = "activity"
		}
	}
	var_15_0.relation_param = ""
	var_15_0.name = "banner_small3"
	var_15_0.time = "always"
	var_15_0.time_lable = 0
	var_15_0.type = 2

	return var_15_0
end

function ActivityRemasterProxy:ExistShopBanner()
	if not self.activeActID or self.activeActID == 0 then
		return false
	end

	if not self.actTimeID or self.actTimeID == 0 then
		return false
	end

	local var_16_0 = self:GetReamsterData(self.activeActID)

	if not var_16_0 then
		return false
	end

	local var_16_1 = getProxy(ActivityProxy)

	for iter_16_0, iter_16_1 in ipairs(var_16_0:GetActList()) do
		local var_16_2 = var_16_1:RawGetActivityById(iter_16_1)

		if var_16_2 and not var_16_2:isEnd() and var_16_2:getConfig("type") == ActivityConst.ACTIVITY_TYPE_SHOP then
			return true
		end
	end

	return false
end

function ActivityRemasterProxy:remove()
	return
end

return ActivityRemasterProxy
