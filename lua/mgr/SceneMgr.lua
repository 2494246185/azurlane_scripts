pg = pg or {}
pg.SceneMgr = singletonClass("SceneMgr")

function pg.SceneMgr.Ctor(arg_1_0)
	arg_1_0._cacheUI = {}
	arg_1_0._gcLimit = 7
	arg_1_0._gcCounter = 0
end

local function var_0_0(arg_2_0, arg_2_1)
	local var_2_0

	if not noEmptyStr(nil) and arg_2_0 then
		var_2_0 = arg_2_0.__cname
	end

	if not noEmptyStr(var_2_0) and arg_2_1 then
		var_2_0 = arg_2_1.scene or arg_2_1.mediator and arg_2_1.mediator.__cname or arg_2_1.viewComponent and arg_2_1.viewComponent.__cname
	end

	return tostring(var_2_0 or "Unknown")
end

local function var_0_1(arg_3_0, arg_3_1)
	local var_3_0 = string.format("进入界面: %s", var_0_0(arg_3_0, arg_3_1))

	print(var_3_0)

	local var_3_1, var_3_2 = pcall(function()
		ReflectionHelp.RefCallMethod(typeof(ResourceMgr), "WriteMarkedShortPathLog", ResourceMgr.Inst, {
			typeof("System.String")
		}, {
			var_3_0
		})
		ReflectionHelp.RefCallMethod(typeof(ResourceMgr), "WriteExtraShortPathFilterLog", ResourceMgr.Inst, {
			typeof("System.String")
		}, {
			var_3_0
		})
	end)

	if not var_3_1 then
		warning(string.format("Write ui load log failed: %s", tostring(var_3_2)))
	end
end

function pg.SceneMgr:prepare(arg_5_1, arg_5_2, arg_5_3)
	local var_5_0 = arg_5_2.mediator
	local var_5_1
	local var_5_2

	if self._cacheUI[arg_5_2.mediator.__cname] ~= nil then
		var_5_2 = self._cacheUI[arg_5_2.mediator.__cname]
		self._cacheUI[arg_5_2.mediator.__cname] = nil

		if EDITOR_TOOL then
			var_0_1(var_5_2, arg_5_2)
		end

		var_5_1 = arg_5_2.mediator.New(var_5_2)

		var_5_1:setContextData(arg_5_2.data)
		arg_5_1:registerMediator(var_5_1)
		arg_5_3(var_5_1)
	else
		var_5_2 = arg_5_2.viewComponent.New()

		assert(isa(var_5_2, BaseUI), "should be an instance of BaseUI: " .. var_5_2.__cname)
		var_5_2:setContextData(arg_5_2.data)

		if EDITOR_TOOL then
			var_0_1(var_5_2, arg_5_2)
		end

		local function var_5_4()
			var_5_2.event:disconnect(BaseUI.LOADED, var_5_4)

			var_5_1 = var_5_0.New(var_5_2)

			var_5_1:setContextData(arg_5_2.data)
			arg_5_1:registerMediator(var_5_1)
			arg_5_3(var_5_1)
		end

		if var_5_2:isLoaded() then
			var_5_4()
		else
			var_5_2.event:connect(BaseUI.LOADED, var_5_4)
			var_5_2:load()
		end
	end
end

function pg.SceneMgr.prepareLayer(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	local var_7_0 = {}
	local var_7_1 = {}

	if arg_7_2 ~= nil then
		if arg_7_2:getContextByMediator(arg_7_3.mediator) then
			originalPrint("mediator already exist: " .. arg_7_3.mediator.__cname)
			arg_7_4(var_7_1)

			return
		end

		table.insert(var_7_0, arg_7_3)
		arg_7_2:addChild(arg_7_3)
	else
		table.insertto(var_7_0, arg_7_3.children)
	end

	local var_7_2 = {}

	while #var_7_0 > 0 do
		local var_7_3 = table.remove(var_7_0, 1)

		table.insert(var_7_2, function(arg_8_0)
			local var_8_0 = arg_7_1:retrieveMediator(var_7_3.parent.mediator.__cname):getViewComponent()

			arg_7_0:prepare(arg_7_1, var_7_3, function(arg_9_0)
				arg_9_0.viewComponent:attach(var_8_0)
				table.insert(var_7_1, arg_9_0)
				arg_8_0()
			end)
		end)
		table.insertto(var_7_0, var_7_3.children)
	end

	seriesAsync(var_7_2, function()
		arg_7_4(var_7_1)
	end)
end

function pg.SceneMgr.enter(arg_11_0, arg_11_1, arg_11_2)
	if #arg_11_1 == 0 then
		arg_11_2()
	end

	local var_11_0 = #arg_11_1

	for iter_11_0, iter_11_1 in ipairs(arg_11_1) do
		local var_11_1 = iter_11_1.viewComponent

		if iter_11_1.viewComponent._isCachedView then
			iter_11_1.viewComponent:setVisible(true)
		end

		local function var_11_3()
			var_11_1.event:disconnect(BaseUI.AVALIBLE, var_11_3)

			var_11_0 = var_11_0 - 1

			if var_11_0 == 0 then
				arg_11_2()
			end
		end

		iter_11_1.viewComponent.event:connect(BaseUI.AVALIBLE, nil)
		iter_11_1.viewComponent:enter()
	end
end

function pg.SceneMgr.removeLayer(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
	local var_13_0 = {
		arg_13_2
	}
	local var_13_1 = {}

	while #var_13_0 > 0 do
		local var_13_2 = table.remove(var_13_0, 1)

		if var_13_2.mediator then
			table.insert(var_13_1, var_13_2)
		end

		table.insertto(var_13_0, var_13_2.children)
	end

	if arg_13_2.parent == nil then
		table.remove(var_13_1, 1)
	else
		arg_13_2.parent:removeChild(arg_13_2)
	end

	local var_13_3 = {}

	for iter_13_0 = #var_13_1, 1, -1 do
		local var_13_4 = var_13_1[iter_13_0]
		local var_13_5 = arg_13_1:removeMediator(var_13_1[iter_13_0].mediator.__cname)

		table.insert(var_13_3, function(arg_14_0)
			if var_13_5 then
				arg_13_0:remove(var_13_5, function()
					var_13_4:onContextRemoved()
					arg_14_0()
				end)
			else
				arg_14_0()
			end
		end)
	end

	seriesAsync(var_13_3, arg_13_3)
end

function pg.SceneMgr.removeLayerMediator(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
	local var_16_0 = {
		arg_16_2
	}
	local var_16_2 = {}

	while #var_16_0 > 0 do
		local var_16_3 = table.remove(var_16_0, 1)

		if var_16_3.mediator then
			table.insert(var_16_2, var_16_3)
		end

		table.insertto(var_16_0, var_16_3.children)
	end

	if arg_16_2.parent ~= nil then
		arg_16_2.parent:removeChild(arg_16_2)
	end

	local var_16_4 = {}

	for iter_16_0 = #var_16_2, 1, -1 do
		local var_16_5 = arg_16_1:removeMediator(var_16_2[iter_16_0].mediator.__cname)

		if var_16_5 then
			local var_16_6 = var_16_5:getViewComponent()

			if var_16_6:CheckTempCache() then
				PoolMgr.GetInstance():KeepUICache(var_16_6:getUIName(), false)
			end

			table.insert(var_16_4, {
				mediator = var_16_5,
				context = var_16_2[iter_16_0]
			})
		end
	end

	arg_16_3(var_16_4)
end

function pg.SceneMgr:remove(arg_17_1, arg_17_2)
	local var_17_0 = arg_17_1:getViewComponent()

	if var_17_0 == nil then
		arg_17_2()
	end

	if var_17_0:needCache() and not self._cacheUI[arg_17_1.__cname] then
		var_17_0:setVisible(false)

		self._cacheUI[arg_17_1.__cname] = var_17_0
		var_17_0._isCachedView = true

		arg_17_2()
	else
		var_17_0._isCachedView = false

		self:removeView(var_17_0, arg_17_2)
	end
end

function pg.SceneMgr.removeView(arg_18_0, arg_18_1, arg_18_2)
	arg_18_1._isCachedView = false

	arg_18_1.event:connect(BaseUI.DID_EXIT, function()
		arg_18_1.event:clear()
		arg_18_0:gc(arg_18_1)
		arg_18_2()
	end)
	arg_18_1:exit()
end

function pg.SceneMgr:clearCacheUI()
	parallelAsync(underscore(self._cacheUI):chain():values():map(function(arg_21_0)
		return function(arg_22_0)
			self:removeView(arg_21_0, arg_22_0)
		end
	end):value(), function()
		self._cacheUI = {}
	end)
end

function pg.SceneMgr:gc(arg_24_1)
	table.clear(arg_24_1)

	arg_24_1.exited = true

	if arg_24_1:DontGC() then
		return
	end

	if arg_24_1:forceGC() or self._gcCounter >= self._gcLimit then
		self._gcCounter = 0

		gcAll(false)
	else
		self._gcCounter = self._gcCounter + 1

		GCThread.GetInstance():LuaGC(false)
	end
end
