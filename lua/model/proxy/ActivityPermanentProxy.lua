local ActivityPermanentProxy = class("ActivityPermanentProxy", import(".NetProxy"))

ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY = 1
ActivityPermanentProxy.TYPE_REMASTER_ACTIVITY = 2
ActivityPermanentProxy.ACTIVITY_GROUP_RANGES = {
	[ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY] = {
		max = 1999,
		min = 1
	},
	[ActivityPermanentProxy.TYPE_REMASTER_ACTIVITY] = {
		max = 2999,
		min = 2000
	}
}

function ActivityPermanentProxy:register()
	self:on(11210, function(arg_2_0)
		self.finishActivity = {}
		self.doingActivities = {}
		self.activityProgressList = {}

		underscore.each(arg_2_0.permanent_activity, function(arg_3_0)
			self.finishActivity[arg_3_0] = true
		end)

		if type(arg_2_0.permanent_now) == "number" then
			table.insert(self.doingActivities, arg_2_0.permanent_now)
		else
			for iter_2_0, iter_2_1 in ipairs(arg_2_0.permanent_now) do
				table.insert(self.doingActivities, iter_2_1)
			end
		end

		_.each(arg_2_0.progress, function(arg_4_0)
			self.activityProgressList[arg_4_0.key] = arg_4_0.value
		end)
	end)
end

function ActivityPermanentProxy:UpdateActivityProgress(arg_5_1, arg_5_2)
	if not self.activityProgressList then
		return
	end

	self.activityProgressList[arg_5_1] = arg_5_2
end

function ActivityPermanentProxy:GetActivityProgress(arg_6_1)
	return self.activityProgressList[arg_6_1] or 0
end

function ActivityPermanentProxy:startSelectActivity(arg_7_1)
	local var_7_0 = self:GetActivityTypeById(arg_7_1)

	for iter_7_0 = #self.doingActivities, 1, -1 do
		if self.doingActivities[iter_7_0] == arg_7_1 or var_7_0 and self:GetActivityTypeById(self.doingActivities[iter_7_0]) == var_7_0 then
			table.remove(self.doingActivities, iter_7_0)
		end
	end

	table.insert(self.doingActivities, arg_7_1)
end

function ActivityPermanentProxy:StopNowActivity(arg_8_1)
	if table.contains(self.doingActivities, arg_8_1) then
		table.removebyvalue(self.doingActivities, arg_8_1)
	end
end

function ActivityPermanentProxy:finishNowActivity(arg_9_1)
	self.finishActivity[arg_9_1] = true

	self:StopNowActivity(arg_9_1)
end

function ActivityPermanentProxy:isActivityFinish(arg_10_1)
	return self.finishActivity[arg_10_1]
end

function ActivityPermanentProxy:IsActivityGroupByType(arg_11_1, arg_11_2)
	return ActivityPermanentProxy.ACTIVITY_GROUP_RANGES[arg_11_2] and arg_11_1 >= ActivityPermanentProxy.ACTIVITY_GROUP_RANGES[arg_11_2].min and arg_11_1 <= ActivityPermanentProxy.ACTIVITY_GROUP_RANGES[arg_11_2].max
end

function ActivityPermanentProxy:GetActivityTypeById(arg_12_1)
	if not pg.activity_task_permanent[arg_12_1] then
		return nil
	end

	for iter_12_0, iter_12_1 in pairs(ActivityPermanentProxy.ACTIVITY_GROUP_RANGES) do
		if self:IsActivityGroupByType(pg.activity_task_permanent[arg_12_1].activity_group, iter_12_0) then
			return iter_12_0
		end
	end

	return nil
end

function ActivityPermanentProxy:IsActivityIdByType(arg_13_1, arg_13_2)
	return self:GetActivityTypeById(arg_13_1) == arg_13_2
end

function ActivityPermanentProxy:IsNormalActivityId(arg_14_1)
	return self:IsActivityIdByType(arg_14_1, ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY)
end

function ActivityPermanentProxy:getActivityIdsByType(arg_15_1)
	arg_15_1 = arg_15_1 or ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY

	return _.select(pg.activity_task_permanent.all, function(arg_16_0)
		return self:IsActivityIdByType(arg_16_0, arg_15_1)
	end)
end

function ActivityPermanentProxy:getDoingActivityId(arg_17_1, arg_17_2)
	arg_17_1 = arg_17_1 or ActivityPermanentProxy.TYPE_NORMAL_ACTIVITY

	for iter_17_0, iter_17_1 in ipairs(self.doingActivities or {}) do
		if (not arg_17_2 or arg_17_2 == iter_17_1) and self:IsActivityIdByType(iter_17_1, arg_17_1) then
			return iter_17_1
		end
	end

	return nil
end

function ActivityPermanentProxy:getDoingActivityById(arg_18_1, arg_18_2)
	local var_18_0 = self:getDoingActivityId(arg_18_1, arg_18_2)

	return (var_18_0 or nil) and (getProxy(ActivityProxy):getActivityById(var_18_0) or nil)
end

function ActivityPermanentProxy:getDoingActivity(arg_19_1)
	if #self.doingActivities == 0 then
		return nil
	end

	return self:getDoingActivityById(arg_19_1)
end

return ActivityPermanentProxy
