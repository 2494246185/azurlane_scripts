local Dorm3dSceneMgr = class("Dorm3dSceneMgr")

function Dorm3dSceneMgr:ParseInfo()
	return unpack(string.split(self, "|"))
end

function Dorm3dSceneMgr:Ctor(arg_2_1, arg_2_2)
	self.sceneInfo = arg_2_1
	self.artSceneInfo = self.sceneInfo
	self.subSceneInfo = self.sceneInfo
	self.lastSceneRootDict = {}
	self.cacheSceneDic = {}

	local var_2_0, var_2_1 = Dorm3dSceneMgr.ParseInfo(self.sceneInfo)

	seriesAsync({
		function(arg_3_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_2_1 .. "/" .. var_2_0 .. "_scene"), var_2_0, LoadSceneMode.Additive, function(arg_4_0, arg_4_1)
				self.originArtScene = arg_4_0

				SceneManager.SetActiveScene(arg_4_0)

				local var_4_0 = getSceneRootTFDic(arg_4_0).MainCamera

				if var_4_0 then
					setActive(var_4_0, false)
				end

				arg_3_0()
			end)
		end,
		function(arg_5_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_2_1 .. "/" .. var_2_0 .. "_base_scene"), var_2_0 .. "_base", LoadSceneMode.Additive, arg_5_0)
		end
	}, arg_2_2)
end

function Dorm3dSceneMgr:EnableSceneDisplay(arg_6_1, arg_6_2)
	assert(tobool(self.lastSceneRootDict[arg_6_1]) == arg_6_2)

	if arg_6_2 then
		table.Foreach(self.lastSceneRootDict[arg_6_1], function(arg_7_0, arg_7_1)
			if IsNil(arg_7_0) then
				return
			end

			setActive(arg_7_0, arg_7_1)
		end)

		self.lastSceneRootDict[arg_6_1] = nil
	else
		self.lastSceneRootDict[arg_6_1] = {}

		table.IpairsCArray(SceneManager.GetSceneByName(arg_6_1):GetRootGameObjects(), function(arg_8_0, arg_8_1)
			if tostring(arg_8_1.hideFlags) ~= "None" then
				return
			end

			self.lastSceneRootDict[arg_6_1][arg_8_1] = isActive(arg_8_1)

			setActive(arg_8_1, false)
		end)
	end
end

function Dorm3dSceneMgr:LoadTimelineScene(arg_9_1, arg_9_2)
	local var_9_0 = {}
	local var_9_1

	if not self.cacheSceneDic[arg_9_1.name] then
		self.cacheSceneDic[arg_9_1.name] = arg_9_1

		table.insert(var_9_0, function(arg_10_0)
			pg.SceneAnimMgr.GetInstance():Dorm3DSceneChange(function(arg_11_0)
				if arg_9_1.waitForTimeline then
					arg_9_1.waitForTimeline(arg_11_0)
				else
					var_9_1 = arg_11_0
				end

				arg_10_0()
			end)
		end)
		table.insert(var_9_0, function(arg_12_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/character/" .. arg_9_1.assetRootName .. "/timeline/" .. arg_9_1.name .. "/" .. arg_9_1.name .. "_scene"), arg_9_1.name, LoadSceneMode.Additive, function(arg_13_0, arg_13_1)
				existCall(arg_9_1.loadSceneFunc, arg_13_0, arg_13_1)
				setActive(GameObject.Find("[camera]").transform:GetComponentInChildren(typeof(Camera)), false)
				arg_12_0()
			end)
		end)
	end

	table.insert(var_9_0, function(arg_14_0)
		if tobool(self.lastSceneRootDict[arg_9_1.name]) ~= tobool(arg_9_1.isCache) then
			self:EnableSceneDisplay(arg_9_1.name, not arg_9_1.isCache)
		end

		arg_14_0()
		existCall(var_9_1)
	end)
	seriesAsync(var_9_0, arg_9_2)
end

function Dorm3dSceneMgr:UnloadTimelineScene(arg_15_1, arg_15_2, arg_15_3)
	assert(self.cacheSceneDic[arg_15_1])

	if tobool(arg_15_2) == tobool(self.cacheSceneDic[arg_15_1].isCache) then
		SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/character/scenes/" .. self.cacheSceneDic[arg_15_1].assetRootName .. "/timeline/" .. arg_15_1 .. "/" .. arg_15_1 .. "_scene"), arg_15_1, function()
			self.cacheSceneDic[arg_15_1] = nil
			self.lastSceneRootDict[arg_15_1] = nil

			existCall(arg_15_3)
		end)
	else
		self:EnableSceneDisplay(arg_15_1, false)
		existCall(arg_15_3)
	end
end

function Dorm3dSceneMgr:ChangeArtScene(arg_17_1, arg_17_2)
	if Dorm3dSceneMgr.IsSameSceneInfo(arg_17_1, self.artSceneInfo) then
		existCall(arg_17_2)

		return
	end

	local var_17_0 = {}
	local var_17_1

	table.insert(var_17_0, function(arg_18_0)
		pg.SceneAnimMgr.GetInstance():Dorm3DSceneChange(function(arg_19_0)
			var_17_1 = arg_19_0

			arg_18_0()
		end)
	end)

	local var_17_2, var_17_3 = Dorm3dSceneMgr.ParseInfo(arg_17_1)

	table.insert(var_17_0, function(arg_20_0)
		SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_17_3 .. "/" .. var_17_2 .. "_scene"), var_17_2, LoadSceneMode.Additive, function(arg_21_0, arg_21_1)
			SceneManager.SetActiveScene(arg_21_0)

			local var_21_0 = getSceneRootTFDic(arg_21_0).MainCamera

			if var_21_0 then
				setActive(var_21_0, false)
			end

			arg_20_0()
		end)
	end)

	local var_17_4, var_17_5 = Dorm3dSceneMgr.ParseInfo(self.artSceneInfo)

	table.insert(var_17_0, function(arg_22_0)
		SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_17_5 .. "/" .. var_17_4 .. "_scene"), var_17_4, arg_22_0)
	end)
	table.insert(var_17_0, function(arg_23_0)
		self.artSceneInfo = arg_17_1

		arg_23_0()
	end)
	seriesAsync(var_17_0, function()
		existCall(arg_17_2)
		existCall(var_17_1)
	end)
end

function Dorm3dSceneMgr:ChangeSubScene(arg_25_1, arg_25_2)
	if Dorm3dSceneMgr.IsSameSceneInfo(arg_25_1, self.subSceneInfo) then
		return existCall(arg_25_2)
	end

	local var_25_0 = {}
	local var_25_1 = false
	local var_25_2

	if not Dorm3dSceneMgr.IsSameSceneInfo(arg_25_1, self.sceneInfo) then
		var_25_1 = true

		table.insert(var_25_0, function(arg_26_0)
			pg.SceneAnimMgr.GetInstance():Dorm3DSceneChange(function(arg_27_0)
				var_25_2 = arg_27_0

				arg_26_0()
			end)
		end)

		local var_25_3, var_25_4 = Dorm3dSceneMgr.ParseInfo(arg_25_1)
		local var_25_5 = var_25_3 .. "_base"

		table.insert(var_25_0, function(arg_28_0)
			SceneOpMgr.Inst:LoadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_25_4 .. "/" .. var_25_5 .. "_scene"), var_25_5, LoadSceneMode.Additive, arg_28_0)
		end)
	end

	if not Dorm3dSceneMgr.IsSameSceneInfo(self.subSceneInfo, self.sceneInfo) then
		local var_25_6, var_25_7 = Dorm3dSceneMgr.ParseInfo(self.subSceneInfo)
		local var_25_8 = var_25_6 .. "_base"

		table.insert(var_25_0, function(arg_29_0)
			SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_25_7 .. "/" .. var_25_8 .. "_scene"), var_25_8, arg_29_0)
		end)
	end

	table.insert(var_25_0, function(arg_30_0)
		self.subSceneInfo = arg_25_1

		arg_30_0()

		if var_25_1 then
			var_25_2()
		end
	end)
	seriesAsync(var_25_0, arg_25_2)
end

function Dorm3dSceneMgr:Dispose()
	local var_31_0 = {}

	for iter_31_0, iter_31_1 in pairs(self.cacheSceneDic) do
		if iter_31_1 then
			local var_31_1 = iter_31_1.assetRootName

			table.insert(var_31_0, function(arg_32_0)
				SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/character/scenes/" .. var_31_1 .. "/timeline/" .. iter_31_0 .. "/" .. iter_31_0 .. "_scene"), iter_31_0, arg_32_0)
			end)
		end
	end

	local var_31_2 = {
		self.sceneInfo
	}

	if not Dorm3dSceneMgr.IsSameSceneInfo(self.subSceneInfo, self.sceneInfo) then
		table.insert(var_31_2, self.subSceneInfo)
	end

	for iter_31_2, iter_31_3 in ipairs(var_31_2) do
		local var_31_3, var_31_4 = Dorm3dSceneMgr.ParseInfo(iter_31_3)
		local var_31_5 = var_31_3 .. "_base"

		table.insert(var_31_0, function(arg_33_0)
			SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_31_4 .. "/" .. var_31_5 .. "_scene"), var_31_5, arg_33_0)
		end)
	end

	local var_31_6 = {
		self.sceneInfo
	}

	if not Dorm3dSceneMgr.IsSameSceneInfo(self.artSceneInfo, self.sceneInfo) then
		table.insert(var_31_6, self.artSceneInfo)
	end

	for iter_31_4, iter_31_5 in ipairs(var_31_6) do
		local var_31_7, var_31_8 = Dorm3dSceneMgr.ParseInfo(iter_31_5)

		table.insert(var_31_0, function(arg_34_0)
			SceneOpMgr.Inst:UnloadSceneAsync(string.lower("dorm3d/scenesres/scenes/" .. var_31_8 .. "/" .. var_31_7 .. "_scene"), var_31_7, arg_34_0)
		end)
	end

	seriesAsync(var_31_0, function()
		self.sceneInfo = nil
		self.artSceneInfo = nil
		self.subSceneInfo = nil
		self.lastSceneRootDict = nil
		self.cacheSceneDic = nil

		print("unload scene finish !")
	end)
end

function Dorm3dSceneMgr:IsSameSceneInfo(arg_36_1)
	return string.lower(self) == string.lower(arg_36_1)
end

return Dorm3dSceneMgr
