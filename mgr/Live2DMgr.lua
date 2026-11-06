pg = pg or {}
pg.Live2DMgr = singletonClass("Live2DMgr")

function pg.Live2DMgr.Ctor(arg_1_0)
	arg_1_0.loadingDic = {}
	arg_1_0.nameList = {}
end

function pg.Live2DMgr:preloadL2dModelAsync(arg_2_1, arg_2_2)
	table.insert(self.nameList, arg_2_1)

	self.loadingDic[arg_2_1] = #self.nameList

	PoolMgr.GetInstance():GetLive2D(arg_2_1, true, function(arg_3_0)
		self.loadingDic[arg_2_1] = nil

		PoolMgr.GetInstance():ReturnLive2D(arg_2_1, arg_3_0)
		existCall(arg_2_2, {})
	end)
end

function pg.Live2DMgr:GetLive2DModelAsync(arg_4_1, arg_4_2)
	table.insert(self.nameList, arg_4_1)

	local var_4_0 = #self.nameList

	self.loadingDic[arg_4_1] = #self.nameList

	PoolMgr.GetInstance():GetLive2D(arg_4_1, true, function(arg_5_0)
		if self.loadingDic[arg_4_1] ~= var_4_0 then
			warning("l2d loaded dispose return  " .. arg_4_1)
			PoolMgr.GetInstance():ReturnLive2D(arg_4_1, arg_5_0)
		end

		self.loadingDic[arg_4_1] = nil

		existCall(arg_4_2, arg_5_0)
	end)
end

function pg.Live2DMgr.ReturnLive2DModel(arg_6_0, arg_6_1, arg_6_2)
	PoolMgr.GetInstance():ReturnLive2D(arg_6_1, arg_6_2)
end

function pg.Live2DMgr:StopLoadingLive2d(arg_7_1)
	if self.loadingDic[self.nameList[arg_7_1]] == arg_7_1 then
		self.loadingDic[self.nameList[arg_7_1]] = nil
	end
end
