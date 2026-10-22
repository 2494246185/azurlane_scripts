local URExchangeActivity = class("URExchangeActivity", import("model.vo.Activity"))

function URExchangeActivity:GetConfigClientURPTDrop()
	if self:isEnd() then
		return nil
	end

	if self:GetConfigClientSetting("PT_ACT_UR") then
		local var_1_0 = getProxy(ActivityProxy):getActivityById(self:GetConfigClientSetting("PT_ACT_UR"))

		return var_1_0 and var_1_0:GetPTDrop() or nil
	elseif self:GetConfigClientSetting("uPtId") then
		return Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = self:GetConfigClientSetting("uPtId")
		})
	end

	return nil
end

function URExchangeActivity:GetConfigClientURPTActivity()
	if self:isEnd() then
		return nil
	end

	if self:GetConfigClientSetting("PT_ACT_UR") then
		return getProxy(ActivityProxy):getActivityById(self:GetConfigClientSetting("PT_ACT_UR"))
	else
		local var_2_0 = self:GetConfigClientURPTDrop()

		return (var_2_0 or nil) and (getProxy(ActivityProxy):GetPTActivityByRes(var_2_0) or nil)
	end
end

return URExchangeActivity
