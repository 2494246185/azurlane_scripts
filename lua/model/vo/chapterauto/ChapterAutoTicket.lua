local ChapterAutoTicket = class("ChapterAutoTicket")

ChapterAutoTicket.TYPE = {
	TIME = 3,
	WORLD = 2,
	MAIN = 1
}
ChapterAutoTicket.GET_SHOW_ID = {
	[ChapterAutoTicket.TYPE.MAIN] = 68710,
	[ChapterAutoTicket.TYPE.TIME] = 68711,
	[ChapterAutoTicket.TYPE.WORLD] = 68712
}
ChapterAutoTicket.FOREVER_TIME = 4294967295

function ChapterAutoTicket:Ctor(arg_1_1)
	self.id = arg_1_1.time
	self.type = arg_1_1.type
	self.count = arg_1_1.num
	self.expireTime = self.id
end

function ChapterAutoTicket:GetRemainTime()
	return self.expireTime - pg.TimeMgr.GetInstance():GetServerTime()
end

function ChapterAutoTicket:IsForever()
	return self.expireTime == ChapterAutoTicket.FOREVER_TIME
end

function ChapterAutoTicket:IsExpired()
	return self:GetRemainTime() < 0
end

function ChapterAutoTicket:WillExpire()
	local var_5_0 = self:GetRemainTime()

	return var_5_0 > 0 and var_5_0 < 86400 * pg.gameset.auto_battle_ticket_warning_time.key_value
end

function ChapterAutoTicket:GetCount()
	return self.count
end

function ChapterAutoTicket:IncreaseCount(arg_7_1)
	self.count = self.count + arg_7_1
end

function ChapterAutoTicket:ReduceCount(arg_8_1)
	self.count = math.max(0, self.count - arg_8_1)
end

function ChapterAutoTicket:GetDrop()
	return Drop.New({
		count = 0,
		type = DROP_TYPE_VITEM,
		id = ChapterAutoTicket.GET_SHOW_ID[self]
	})
end

function ChapterAutoTicket:CreateByItem(arg_10_1)
	return ChapterAutoTicket.New({
		type = self,
		time = ChapterAutoTicket.GetExpireTimeByArg(arg_10_1:getConfig("drop_arg")),
		num = arg_10_1.count
	})
end

function ChapterAutoTicket:GetExpireTimeByArg()
	if type(self) ~= "table" then
		return ChapterAutoTicket.FOREVER_TIME
	end

	if #self == 0 then
		return ChapterAutoTicket.FOREVER_TIME
	end

	local var_11_0 = self[1]
	local var_11_1 = self[2]

	if type(self[1]) == "table" then
		return pg.TimeMgr.GetInstance():parseTimeFromConfig(self)
	end

	if type(var_11_0) == "string" then
		local var_11_2 = pg.TimeMgr.GetInstance()

		return switch(var_11_0, {
			always = function()
				return ChapterAutoTicket.FOREVER_TIME
			end,
			day = function()
				return var_11_2:GetTimeToNextTime() + var_11_1 * 86400
			end,
			week = function()
				return var_11_2:GetNextWeekTime(1, 0, 0, 0) + var_11_1 * 604800
			end,
			month = function()
				local var_15_0 = var_11_2:STimeDescS(var_11_2:GetServerTime(), "*t")

				return var_11_2:Table2ServerTime({
					hour = 0,
					min = 0,
					sec = 0,
					day = 1,
					year = var_15_0.year + math.floor((var_15_0.month + var_11_1 + 1 - 1) / 12),
					month = (var_15_0.month + var_11_1 + 1 - 1) % 12 + 1
				})
			end,
			year = function()
				return var_11_2:Table2ServerTime({
					hour = 0,
					month = 1,
					min = 0,
					sec = 0,
					day = 1,
					year = tonumber(var_11_2:STimeDescS(var_11_2:GetServerTime(), "%Y")) + var_11_1 + 1
				})
			end,
			act = function()
				local var_17_0 = getProxy(ActivityProxy):getActivityById(var_11_1)

				if not var_17_0 or var_17_0:isEnd() then
					return 0
				else
					return var_17_0.stopTime
				end
			end
		}, function()
			return ChapterAutoTicket.FOREVER_TIME
		end)
	end

	return ChapterAutoTicket.FOREVER_TIME
end

return ChapterAutoTicket
