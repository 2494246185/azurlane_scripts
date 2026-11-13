local DelayedDataProcessor = class("DelayedDataProcessor")

function DelayedDataProcessor:Ctor(arg_1_1, arg_1_2, arg_1_3)
	self.delayedDataDic = {}
	self.preTimeStampDic = {}
	self.delayedTime = arg_1_1
	self.intervalTime = arg_1_2
	self.func = arg_1_3
end

function DelayedDataProcessor:Add(arg_2_1, arg_2_2)
	self.delayedDataDic[arg_2_1] = self.delayedDataDic[arg_2_1] or {}

	local var_2_0 = pg.TimeMgr.GetInstance():GetServerTimeMs()
	local var_2_1 = self.preTimeStampDic[arg_2_1] and math.min(self.preTimeStampDic[arg_2_1] + self.intervalTime, var_2_0 + self.delayedTime) or var_2_0 + self.delayedTime

	table.insert(self.delayedDataDic[arg_2_1], {
		data = arg_2_2,
		timeStamp = var_2_1
	})

	self.preTimeStampDic[arg_2_1] = var_2_1
end

function DelayedDataProcessor:Update()
	local var_3_0 = pg.TimeMgr.GetInstance():GetServerTimeMs()

	for iter_3_0, iter_3_1 in pairs(self.delayedDataDic) do
		if #iter_3_1 > 0 and var_3_0 >= iter_3_1[1].timeStamp then
			xpcall(function()
				self.func(iter_3_1[1].data)
			end, function(...)
				errorMsg(debug.traceback(...))
			end)
			table.remove(iter_3_1, 1)
		end
	end
end

function DelayedDataProcessor:RemoveDataById(arg_6_1)
	if self.delayedDataDic[arg_6_1] then
		self.delayedDataDic[arg_6_1] = nil
	end

	if self.preTimeStampDic[arg_6_1] then
		self.preTimeStampDic[arg_6_1] = nil
	end
end

function DelayedDataProcessor:Dispose()
	self.delayedDataDic = {}
	self.preTimeStampDic = {}
end

return DelayedDataProcessor
