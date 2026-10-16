local MainActRemasterMapBtn = class("MainActRemasterMapBtn", import(".MainActMapBtn"))

function MainActRemasterMapBtn:GetEventName()
	return "event_remaster_map"
end

function MainActRemasterMapBtn:GetLinkConfig()
	local var_2_0 = getProxy(ActivityRemasterProxy):GetActiveActID()

	if not var_2_0 or var_2_0 <= 0 then
		return nil
	end

	return {
		param = "0",
		name = "event_remaster_map",
		text_pic = "text_event_map",
		type = 0,
		id = 1,
		group_id = 1,
		order = 1,
		pic = var_2_0 .. "",
		time = {
			"default",
			51033
		}
	}
end

function MainActRemasterMapBtn:InShowTime()
	if not getProxy(ActivityRemasterProxy):IsActivating() then
		return false
	end

	local var_3_0 = self:GetActivity()

	if not var_3_0 or var_3_0:isEnd() then
		return false
	end

	self.config = self:GetLinkConfig()

	return true
end

function MainActRemasterMapBtn:GetActivity()
	local var_4_0 = {
		ActivityConst.ACTIVITY_TYPE_BOSSRUSH,
		ActivityConst.ACTIVITY_TYPE_ZPROJECT
	}

	for iter_4_0, iter_4_1 in ipairs(pg.activity_re[getProxy(ActivityRemasterProxy):GetActiveActID()].act_id) do
		if pg.activity_template[iter_4_1] and table.contains(var_4_0, pg.activity_template[iter_4_1].type) then
			local var_4_1 = getProxy(ActivityProxy):getActivityById(iter_4_1)

			if var_4_1 and not var_4_1:isEnd() then
				return var_4_1
			end
		end
	end

	return nil
end

function MainActRemasterMapBtn:ResPath()
	return "ActRemasterMapBtn"
end

return MainActRemasterMapBtn
