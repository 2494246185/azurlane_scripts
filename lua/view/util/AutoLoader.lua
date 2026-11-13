local AutoLoader = class("AutoLoader")
local var_0_1 = false
local var_0_2 = false
local LoadPrefabRequestPackage = import("view.util.RequestPackages.LoadPrefabRequestPackage")
local LoadReferenceRequestPackage = import("view.util.RequestPackages.LoadReferenceRequestPackage")
local LoadLive2dRequestPackage = import("view.util.RequestPackages.LoadLive2dRequestPackage")
local LoadBundleRequesetPackage = import("view.util.RequestPackages.LoadBundleRequesetPackage")
local GetSpineRequestPackage = import("view.util.RequestPackages.GetSpineRequestPackage")
local GetPrefabRequestPackage = import("view.util.RequestPackages.GetPrefabRequestPackage")
local GetSpriteRequestPackage = import("view.util.RequestPackages.GetSpriteRequestPackage")
local ReturnPrefabRequestPackage = import("view.util.RequestPackages.ReturnPrefabRequestPackage")
local ReturnSpineRequestPackage = import("view.util.RequestPackages.ReturnSpineRequestPackage")
local UnloadBundleRequesetPackage = import("view.util.RequestPackages.UnloadBundleRequesetPackage")
local DestroyAtlasPoolRequestPackage = import("view.util.RequestPackages.DestroyAtlasPoolRequestPackage")

AutoLoader.PartLoading = bit.lshift(1, 0)
AutoLoader.PartLoaded = bit.lshift(1, 1)

function AutoLoader:Ctor()
	self._loadingRequest = {}
	self._returnRequest = {}
	self._instKeyDict = {}
	self._keyInstDict = {}
	self._groupDict = {}
end

function AutoLoader:GenerateUID4LoadingRequest()
	self._uidCounter = (self._uidCounter or 0) + 1

	assert(self._uidCounter ~= 0, "Error on Generating UID Too much times")

	return self._uidCounter
end

function AutoLoader:GetPrefab(arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	arg_3_2 = arg_3_2 or ""

	self:ClearRequest(arg_3_4)

	arg_3_4 = arg_3_4 or self:GenerateUID4LoadingRequest()

	local var_3_0 = GetPrefabRequestPackage.New(arg_3_1, arg_3_2, function(arg_4_0)
		self._loadingRequest[arg_3_4] = nil
		self._instKeyDict[arg_4_0] = arg_3_4
		self._keyInstDict[arg_3_4] = arg_4_0
		self._returnRequest[arg_3_4] = ReturnPrefabRequestPackage.New(arg_3_1, arg_3_2, arg_4_0)

		if arg_3_3 then
			arg_3_3(arg_4_0)
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Path: " .. arg_3_1 .. " Name: " .. arg_3_2 .. " ;")
	end

	self._loadingRequest[arg_3_4] = var_3_0

	var_3_0:Start()

	return arg_3_4
end

function AutoLoader:GetPrefabBYStopLoading(arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	arg_5_2 = arg_5_2 or ""

	self:ClearRequest(arg_5_4, AutoLoader.PartLoading)

	arg_5_4 = arg_5_4 or self:GenerateUID4LoadingRequest()

	local var_5_0 = GetPrefabRequestPackage.New(arg_5_1, arg_5_2, function(arg_6_0)
		self._loadingRequest[arg_5_4] = nil

		self:ClearRequest(arg_5_4, AutoLoader.PartLoaded)

		self._instKeyDict[arg_6_0] = arg_5_4
		self._keyInstDict[arg_5_4] = arg_6_0
		self._returnRequest[arg_5_4] = ReturnPrefabRequestPackage.New(arg_5_1, arg_5_2, arg_6_0)

		if arg_5_3 then
			arg_5_3(arg_6_0)
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Path: " .. arg_5_1 .. " Name: " .. arg_5_2 .. " ;")
	end

	self._loadingRequest[arg_5_4] = var_5_0

	var_5_0:Start()

	return arg_5_4
end

function AutoLoader:GetPrefabBYGroup(arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	local var_7_0 = self:GetPrefab(arg_7_1, arg_7_2, arg_7_3)

	self._groupDict[var_7_0] = arg_7_4

	return var_7_0
end

function AutoLoader:ReturnPrefab(arg_8_1)
	self:ClearRequest(self._instKeyDict[go(arg_8_1)])
end

function AutoLoader:ReturnGroup(arg_9_1)
	if not arg_9_1 then
		return
	end

	for iter_9_0, iter_9_1 in pairs(self._groupDict) do
		if iter_9_1 == arg_9_1 then
			self:ClearRequest(iter_9_0)
		end
	end
end

function AutoLoader:GetSpine(arg_10_1, arg_10_2, arg_10_3)
	if not noEmptyStr(arg_10_1) then
		return
	end

	arg_10_1 = arg_10_1 or ""

	self:ClearRequest(arg_10_3)

	arg_10_3 = arg_10_3 or self:GenerateUID4LoadingRequest()

	local var_10_0 = GetSpineRequestPackage.New(arg_10_1, function(arg_11_0)
		self._loadingRequest[arg_10_3] = nil
		self._instKeyDict[arg_11_0] = arg_10_3
		self._keyInstDict[arg_10_3] = arg_11_0
		self._returnRequest[arg_10_3] = ReturnSpineRequestPackage.New(arg_10_1, arg_11_0)

		if arg_10_2 then
			arg_10_2(arg_11_0)
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Spine: " .. arg_10_1 .. " ;")
	end

	self._loadingRequest[arg_10_3] = var_10_0

	var_10_0:Start()

	return arg_10_3
end

function AutoLoader:ReturnSpine(arg_12_1)
	self:ClearRequest(self._instKeyDict[go(arg_12_1)])
end

function AutoLoader:GetSprite(arg_13_1, arg_13_2, arg_13_3, arg_13_4)
	arg_13_3:GetComponent(typeof(Image)).enabled = false

	return self:GetSpriteQuiet(arg_13_1, arg_13_2, arg_13_3, arg_13_4)
end

function AutoLoader:GetSpriteQuiet(arg_14_1, arg_14_2, arg_14_3, arg_14_4)
	arg_14_2 = arg_14_2 or ""

	local var_14_0 = tf(arg_14_3)

	self:GetSpriteDirect(arg_14_1, arg_14_2, function(arg_15_0)
		local var_15_0 = arg_14_3:GetComponent(typeof(Image))

		var_15_0.enabled = true
		var_15_0.sprite = arg_15_0

		if arg_14_4 then
			var_15_0:SetNativeSize()
		end
	end, var_14_0)

	return var_14_0
end

function AutoLoader:GetSpriteDirect(arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	arg_16_1, arg_16_2 = HXSet.autoHxShiftPath(arg_16_1, arg_16_2)

	self:ClearRequest(arg_16_4)

	arg_16_4 = arg_16_4 or self:GenerateUID4LoadingRequest()

	local function var_16_0(arg_17_0)
		self._loadingRequest[arg_16_4] = nil

		if arg_16_3 then
			arg_16_3(arg_17_0)
		end
	end

	local function var_16_1(arg_18_0, arg_18_1, arg_18_2)
		local var_18_0 = GetSpriteRequestPackage.New(arg_18_0, arg_18_1, arg_18_2)

		if var_0_1 then
			warning("AutoLoader Loading Atlas: " .. arg_18_0 .. " Name: " .. arg_18_1 .. " ;")
		end

		self._loadingRequest[arg_16_4] = var_18_0
		self._returnRequest[arg_18_0] = DestroyAtlasPoolRequestPackage.New(arg_18_0)

		var_18_0:Start()
	end

	if HXSet.isHx() then
		local var_16_2 = arg_16_1
		local var_16_3 = arg_16_2

		if arg_16_2 == "" then
			if checkABExist(var_16_2 .. "_hx") then
				var_16_2 = var_16_2 .. "_hx"
			end
		else
			var_16_3 = var_16_3 .. "_hx"
		end

		var_16_1(var_16_2, var_16_3, function(arg_19_0)
			if arg_19_0 == nil then
				var_16_1(arg_16_1, arg_16_2, var_16_0)
			else
				var_16_0(arg_19_0)
			end
		end)
	else
		var_16_1(arg_16_1, arg_16_2, var_16_0)
	end

	return arg_16_4
end

function AutoLoader:GetOffSpriteRequest(arg_20_1)
	self:ClearRequest(arg_20_1)
end

function AutoLoader:LoadPrefab(arg_21_1, arg_21_2, arg_21_3, arg_21_4)
	arg_21_2 = arg_21_2 or ""

	self:ClearRequest(arg_21_4)

	arg_21_4 = arg_21_4 or self:GenerateUID4LoadingRequest()

	local var_21_0 = LoadPrefabRequestPackage.New(arg_21_1, arg_21_2, function(arg_22_0)
		self._loadingRequest[arg_21_4] = nil

		if arg_21_3 then
			arg_21_3(arg_22_0)
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Once Path: " .. arg_21_1 .. " Name: " .. arg_21_2 .. " ;")
	end

	self._loadingRequest[arg_21_4] = var_21_0

	var_21_0:Start()

	return arg_21_4
end

function AutoLoader:LoadLive2D(arg_23_1, arg_23_2, arg_23_3)
	local var_23_1, var_23_2 = HXSet.autoHxShift("live2d/", arg_23_1)

	arg_23_1 = var_23_2

	local var_23_3 = var_23_1 .. var_23_2

	self:ClearRequest(arg_23_3)

	arg_23_3 = arg_23_3 or self:GenerateUID4LoadingRequest()

	local var_23_4 = LoadLive2dRequestPackage.New(var_23_3, "", function(arg_24_0)
		self._loadingRequest[arg_23_3] = nil

		if arg_23_2 then
			arg_23_2(arg_24_0)
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Live2D Once Path: " .. var_23_3 .. " Name: " .. arg_23_1 .. " ;")
	end

	self._loadingRequest[arg_23_3] = var_23_4

	var_23_4:Start()

	return arg_23_3
end

function AutoLoader:LoadSprite(arg_25_1, arg_25_2, arg_25_3, arg_25_4)
	local var_25_0 = arg_25_3:GetComponent(typeof(Image))

	var_25_0.enabled = false
	arg_25_2 = arg_25_2 or ""

	local var_25_1 = tf(arg_25_3)

	self:ClearRequest(var_25_1)

	local var_25_2 = LoadReferenceRequestPackage.New(arg_25_1, arg_25_2, typeof(Sprite), function(arg_26_0)
		self._loadingRequest[var_25_1] = nil
		var_25_0.enabled = true
		var_25_0.sprite = arg_26_0

		if arg_25_4 then
			var_25_0:SetNativeSize()
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Once Path: " .. arg_25_1 .. " Name: " .. arg_25_2 .. " ;")
	end

	self._loadingRequest[var_25_1] = var_25_2

	var_25_2:Start()

	return var_25_1
end

function AutoLoader:LoadReference(arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5)
	arg_27_2 = arg_27_2 or ""

	self:ClearRequest(arg_27_5)

	arg_27_5 = arg_27_5 or self:GenerateUID4LoadingRequest()

	local var_27_0 = LoadReferenceRequestPackage.New(arg_27_1, arg_27_2, arg_27_3, function(arg_28_0)
		self._loadingRequest[arg_27_5] = nil

		if arg_27_4 then
			arg_27_4(arg_28_0)
		end
	end)

	if var_0_1 then
		warning("AutoLoader Loading Once Path: " .. arg_27_1 .. " Name: " .. arg_27_2 .. " ;")
	end

	self._loadingRequest[arg_27_5] = var_27_0

	var_27_0:Start()

	return arg_27_5
end

function AutoLoader:DestroyAtlas(arg_29_1)
	self:ClearRequest(arg_29_1)
end

function AutoLoader:LoadBundle(arg_30_1, arg_30_2)
	local var_30_0 = self:GenerateUID4LoadingRequest()
	local var_30_1 = LoadBundleRequesetPackage.New(arg_30_1, function(arg_31_0)
		self._loadingRequest[var_30_0] = nil
		self._returnRequest[var_30_0] = UnloadBundleRequesetPackage.New(arg_30_1)

		existCall(arg_30_2, arg_31_0)
	end)

	if var_0_1 then
		warning("AutoLoader Loading Bundle: " .. arg_30_1 .. " ;")
	end

	self._loadingRequest[var_30_0] = var_30_1

	var_30_1:Start()

	return var_30_0
end

function AutoLoader:GetRequestPackage(arg_32_1, arg_32_2)
	arg_32_2 = arg_32_2 or AutoLoader.PartLoading + AutoLoader.PartLoaded

	local var_32_0

	if bit.band(arg_32_2, AutoLoader.PartLoading) > 0 then
		var_32_0 = self._loadingRequest[arg_32_1]

		if not self._loadingRequest[arg_32_1] then
			if bit.band(arg_32_2, AutoLoader.PartLoaded) > 0 then
				var_32_0 = self._returnRequest[arg_32_1] or nil
			end
		end
	end

	return var_32_0
end

function AutoLoader:GetLoadingRP(arg_33_1)
	return self._loadingRequest[arg_33_1]
end

function AutoLoader:ClearRequest(arg_34_1, arg_34_2)
	if (not arg_34_2 or bit.band(arg_34_2, AutoLoader.PartLoading) > 0) and self._loadingRequest[arg_34_1] then
		if var_0_2 then
			warning("AutoLoader Unload loading Path: " .. self._loadingRequest[arg_34_1].path .. " Name: " .. self._loadingRequest[arg_34_1].name .. " ;")
		end

		self._loadingRequest[arg_34_1]:Stop()

		self._loadingRequest[arg_34_1] = nil
	end

	if not arg_34_2 or bit.band(arg_34_2, AutoLoader.PartLoaded) > 0 then
		if self._returnRequest[arg_34_1] then
			if var_0_2 then
				if isa(self._returnRequest[arg_34_1], ReturnSpineRequestPackage) then
					warning("AutoLoader Unload Spine: " .. self._returnRequest[arg_34_1].name .. " ;")
				elseif isa(self._returnRequest[arg_34_1], DestroyAtlasPoolRequestPackage) then
					warning("AutoLoader Unload Atlas: " .. self._returnRequest[arg_34_1].path .. " ;")
				elseif isa(self._returnRequest[arg_34_1], UnloadBundleRequesetPackage) then
					warning("AutoLoader Unload Bundle: " .. self._returnRequest[arg_34_1].path .. " ;")
				elseif isa(self._returnRequest[arg_34_1], ReturnPrefabRequestPackage) then
					warning("AutoLoader Unload Path: " .. self._returnRequest[arg_34_1].path .. " Name: " .. self._returnRequest[arg_34_1].name .. " ;")
				else
					warning("Not Handle " .. self._returnRequest[arg_34_1].__cname .. " " .. ((not self._returnRequest[arg_34_1].name or nil) and "NIL"))
				end
			end

			self._returnRequest[arg_34_1]:Start()

			self._returnRequest[arg_34_1] = nil
		end

		if self._keyInstDict[arg_34_1] then
			self._instKeyDict[self._keyInstDict[arg_34_1]] = nil
			self._keyInstDict[arg_34_1] = nil
		end
	end

	if arg_34_1 then
		self._groupDict[arg_34_1] = nil
	end
end

function AutoLoader:ClearLoadingRequests()
	for iter_35_0 in pairs(self._loadingRequest) do
		self:ClearRequest(iter_35_0)
	end

	table.clear(self._loadingRequest)
end

function AutoLoader:ClearLoadedRequests()
	for iter_36_0 in pairs(self._returnRequest) do
		self:ClearRequest(iter_36_0)
	end

	table.clear(self._returnRequest)
end

function AutoLoader:ClearRequests()
	self:ClearLoadingRequests()
	self:ClearLoadedRequests()
	table.clear(self._instKeyDict)
	table.clear(self._keyInstDict)
end

function AutoLoader:RegisterLoaded(arg_38_1, arg_38_2)
	self._instKeyDict[arg_38_2] = arg_38_1
	self._keyInstDict[arg_38_1] = arg_38_2
	self._returnRequest[arg_38_1] = {
		Start = function()
			Destroy(arg_38_2)
		end
	}
end

function AutoLoader:Clear()
	self:ClearRequests()
end

return AutoLoader
